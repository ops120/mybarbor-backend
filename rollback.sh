#!/bin/bash
# rollback.sh - K8s 回滚脚本

set -e

NAMESPACE="k8s-demo"

echo ""
echo "========================================"
echo "     K8s 滚动回滚脚本"
echo "========================================"
echo ""

show_menu() {
    echo "请选择要回滚的服务:"
    echo "1. 回滚后端服务"
    echo "2. 回滚前端服务"
    echo "3. 回滚所有服务"
    echo "4. 查看部署历史"
    echo "5. 退出"
    echo ""
}

show_history() {
    echo "===== 后端部署历史 ====="
    kubectl rollout history deployment/backend-app -n $NAMESPACE
    echo ""
    echo "===== 前端部署历史 ====="
    kubectl rollout history deployment/frontend-app -n $NAMESPACE
}

rollback_backend() {
    echo "正在回滚后端服务..."
    kubectl rollout undo deployment/backend-app -n $NAMESPACE
    echo "等待回滚完成..."
    kubectl rollout status deployment/backend-app -n $NAMESPACE --timeout=300s
    echo "后端回滚完成"
}

rollback_frontend() {
    echo "正在回滚前端服务..."
    kubectl rollout undo deployment/frontend-app -n $NAMESPACE
    echo "等待回滚完成..."
    kubectl rollout status deployment/frontend-app -n $NAMESPACE --timeout=300s
    echo "前端回滚完成"
}

rollback_all() {
    rollback_backend
    rollback_frontend
}

main() {
    if [ -n "$1" ]; then
        case $1 in
            backend)
                rollback_backend
                ;;
            frontend)
                rollback_frontend
                ;;
            all)
                rollback_all
                ;;
            history)
                show_history
                ;;
            *)
                echo "未知参数: $1"
                echo "用法: $0 [backend|frontend|all|history]"
                ;;
        esac
        exit 0
    fi
    
    while true; do
        show_menu
        read -p "请输入选项 (1-5): " choice
        case $choice in
            1)
                rollback_backend
                ;;
            2)
                rollback_frontend
                ;;
            3)
                rollback_all
                ;;
            4)
                show_history
                ;;
            5)
                echo "退出"
                exit 0
                ;;
            *)
                echo "无效选项，请重新选择"
                ;;
        esac
    done
}

main "$@"
