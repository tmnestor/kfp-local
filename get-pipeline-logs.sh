#!/bin/bash

# Script to retrieve KFP v2 pipeline component logs
# Usage: ./get-pipeline-logs.sh [workflow-name]

WORKFLOW_NAME=${1:-"ml-pipeline-no-emojis-v2-mp5tk"}
NAMESPACE="kubeflow"

echo "=== Retrieving logs for workflow: $WORKFLOW_NAME ==="

# Create temporary MinIO client pod
kubectl run temp-minio-client --image=minio/mc --restart=Never --command -- sleep 3600

# Wait for pod to be ready
echo "Waiting for MinIO client pod..."
kubectl wait --for=condition=ready pod/temp-minio-client --timeout=60s

# Configure MinIO client
kubectl exec temp-minio-client -- mc alias set minio http://minio-service.kubeflow.svc.cluster.local:9000 minio minio123

# List available logs
echo ""
echo "=== Available component logs ==="
kubectl exec temp-minio-client -- mc ls minio/mlpipeline/artifacts/$WORKFLOW_NAME/

# Get specific log paths
echo ""
echo "=== Component log contents ==="
LOG_DIRS=$(kubectl exec temp-minio-client -- mc ls minio/mlpipeline/artifacts/$WORKFLOW_NAME/2025/06/08/ | awk '{print $5}')

for dir in $LOG_DIRS; do
    if [[ $dir == *"container"* ]]; then
        echo ""
        echo "--- Component: $dir ---"
        kubectl exec temp-minio-client -- mc cat minio/mlpipeline/artifacts/$WORKFLOW_NAME/2025/06/08/$dir/main.log | tail -20
    fi
done

# Cleanup
kubectl delete pod temp-minio-client

echo ""
echo "=== Log retrieval complete ==="