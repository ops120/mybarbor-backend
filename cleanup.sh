#!/bin/bash
# cleanup.sh - K8s 清理脚本

set -e

NAMESPACE="k8s-demo"

echo ""
echo "========================================"
echo "     K8s 资源清理脚本"
echo "========================================"
echo ""

read -p "确定要删除命名空间 '$NAMESPACE' 吗？这将删除所有相关资源 (y/N): " confirm

if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "取消删除"
    exit 0
fi

echo ""
echo "开始删除资源..."

# 删除命名空间
kubectl delete namespace $NAMESPACE

echo "等待命名空间删除..."
kubectl wait --for=delete namespace/$NAMESPACE --timeout=60s 2>/dev/null || true

echo ""
echo "========================================"
echo "清理完成!"
echo "========================================"
