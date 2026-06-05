#!/bin/bash
# deploy.sh - K8s 一键部署脚本

set -e

# 配置
NAMESPACE="k8s-demo"
BACKEND_IMAGE="${DOCKER_REGISTRY:-your-registry.com}/backend:1.0.0"
FRONTEND_IMAGE="${DOCKER_REGISTRY:-your-registry.com}/frontend:1.0.0"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查 kubectl
check_kubectl() {
    log_info "检查 kubectl 配置..."
    if ! kubectl cluster-info &> /dev/null; then
        log_error "kubectl 未配置或无法连接到集群"
        exit 1
    fi
    log_info "kubectl 配置正确"
}

# 更新镜像地址
update_images() {
    log_info "更新镜像地址..."
    sed -i "s|your-repo/backend:1.0.0|$BACKEND_IMAGE|g" backend/k8s/deployment.yaml
    sed -i "s|your-repo/frontend:1.0.0|$FRONTEND_IMAGE|g" frontend/k8s/deployment.yaml
    log_info "镜像地址已更新"
}

# 部署公共资源
deploy_common() {
    log_info "部署公共资源..."
    kubectl apply -f k8s/common/namespace.yaml
    kubectl apply -f k8s/common/secrets.yaml
    kubectl apply -f k8s/common/pvc.yaml
    log_info "公共资源部署完成"
}

# 部署 MySQL
deploy_mysql() {
    log_info "部署 MySQL..."
    kubectl apply -f mysql/k8s/deployment.yaml
    kubectl apply -f mysql/k8s/service.yaml
    log_info "等待 MySQL 就绪..."
    kubectl rollout status deployment/mysql -n $NAMESPACE --timeout=180s
    log_info "MySQL 部署完成"
}

# 部署 Redis
deploy_redis() {
    log_info "部署 Redis..."
    kubectl apply -f redis/k8s/deployment.yaml
    kubectl apply -f redis/k8s/service.yaml
    log_info "等待 Redis 就绪..."
    kubectl rollout status deployment/redis -n $NAMESPACE --timeout=180s
    log_info "Redis 部署完成"
}

# 部署后端
deploy_backend() {
    log_info "部署后端服务..."
    kubectl apply -f backend/k8s/deployment.yaml
    kubectl apply -f backend/k8s/service.yaml
    log_info "等待后端服务就绪..."
    kubectl rollout status deployment/backend-app -n $NAMESPACE --timeout=300s
    log_info "后端服务部署完成"
}

# 部署前端
deploy_frontend() {
    log_info "部署前端服务..."
    kubectl apply -f frontend/k8s/deployment.yaml
    kubectl apply -f frontend/k8s/service.yaml
    log_info "等待前端服务就绪..."
    kubectl rollout status deployment/frontend-app -n $NAMESPACE --timeout=300s
    log_info "前端服务部署完成"
}

# 部署 Ingress
deploy_ingress() {
    log_info "部署 Ingress..."
    kubectl apply -f k8s/common/ingress.yaml
    log_info "Ingress 部署完成"
}

# 部署 HPA
deploy_hpa() {
    log_info "部署 HPA..."
    kubectl apply -f k8s/common/hpa.yaml
    log_info "HPA 部署完成"
}

# 验证部署
verify_deployment() {
    log_info "验证部署状态..."
    echo ""
    echo "===== 命名空间 ====="
    kubectl get namespace $NAMESPACE
    echo ""
    echo "===== Pods ====="
    kubectl get pods -n $NAMESPACE
    echo ""
    echo "===== Services ====="
    kubectl get svc -n $NAMESPACE
    echo ""
    echo "===== Deployments ====="
    kubectl get deployment -n $NAMESPACE
}

# 主函数
main() {
    echo ""
    echo "========================================"
    echo "     K8s Demo 应用部署脚本"
    echo "========================================"
    echo ""
    
    check_kubectl
    update_images
    deploy_common
    deploy_mysql
    deploy_redis
    deploy_backend
    deploy_frontend
    deploy_ingress
    deploy_hpa
    verify_deployment
    
    echo ""
    echo "========================================"
    log_info "部署完成!"
    echo "========================================"
    echo ""
    echo "访问方式:"
    echo "  - NodePort: http://<node-ip>:30080"
    echo "  - Ingress: http://k8s-demo.local (需配置 hosts)"
    echo ""
    echo "常用命令:"
    echo "  - 查看 Pods: kubectl get pods -n $NAMESPACE"
    echo "  - 查看日志: kubectl logs -f -n $NAMESPACE -l app=backend"
    echo "  - 滚动更新: kubectl set image deployment/backend-app backend=<new-image> -n $NAMESPACE"
    echo ""
}

main "$@"
