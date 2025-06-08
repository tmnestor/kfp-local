# 📋 MinIO Pipeline Log Access Guide

## 🎯 Overview

This guide shows you how to access KFP v2.2.0 pipeline execution logs stored in MinIO. Pipeline logs are automatically stored as artifacts during execution and can be accessed through multiple methods.

## 🚀 Quick Access Methods

### Method 1: MinIO Web Interface (Recommended)

#### Step 1: Start MinIO Port Forwarding
```bash
kubectl port-forward svc/minio-service -n kubeflow 9001:9000 &
```

#### Step 2: Access MinIO Web UI
Open your browser and go to: **http://localhost:9001**

#### Step 3: Login to MinIO
- **Access Key**: `minio`
- **Secret Key**: `minio123`

#### Step 4: Navigate to Pipeline Logs
1. Click on **"Buckets"** in the left sidebar
2. Click on **"mlpipeline"** bucket
3. Navigate to: **artifacts** → **[your-pipeline-name]** → **2025/06/08/** (or current date)
4. You'll see folders for each pipeline component
5. Click on any component folder and download the **main.log** file

### Method 2: Automated Log Retrieval Script

#### Use the Pipeline Log Script
```bash
# Get logs for the most recent pipeline
./get-pipeline-logs.sh

# Get logs for a specific pipeline
./get-pipeline-logs.sh ml-pipeline-no-emojis-v2-mp5tk
```

This script will:
- Create a temporary MinIO client pod
- Configure access to the MinIO storage
- List all available component logs
- Display the last 20 lines of each component's execution

### Method 3: Direct kubectl Access (While Pods Exist)

#### List Available Pipeline Pods
```bash
kubectl get pods -n kubeflow | grep [pipeline-name]
```

#### Get Logs from Specific Component
```bash
# Replace [pod-name] with actual pod name from above
kubectl logs [pod-name] -n kubeflow -c main
```

**Note**: This method only works while the component pods still exist (usually a few hours after execution).

## 📁 MinIO Storage Structure

### Pipeline Artifact Organization
```
mlpipeline/
└── artifacts/
    └── [pipeline-name]/
        └── 2025/06/08/          # Date of execution
            ├── [component-1-pod-name]/
            │   └── main.log      # Component 1 execution logs
            ├── [component-2-pod-name]/
            │   └── main.log      # Component 2 execution logs
            └── [component-n-pod-name]/
                └── main.log      # Component N execution logs
```

### Example Log Paths
For a pipeline named `ml-pipeline-no-emojis-v2-mp5tk`:
```
mlpipeline/artifacts/ml-pipeline-no-emojis-v2-mp5tk/2025/06/08/
├── ml-pipeline-no-emojis-v2-mp5tk-system-container-driver-410787095/main.log
├── ml-pipeline-no-emojis-v2-mp5tk-system-container-driver-1463122469/main.log
├── ml-pipeline-no-emojis-v2-mp5tk-system-container-driver-2919375261/main.log
└── ml-pipeline-no-emojis-v2-mp5tk-system-container-driver-2993516554/main.log
```

## 🔍 Understanding Log Contents

### Component Driver Logs
These contain execution metadata and component orchestration information:
- Component input parameters
- Execution context and IDs
- Caching decisions
- Output parameter configurations

### Component Implementation Logs
These contain your actual pipeline component execution:
- Print statements from your Python functions
- Component processing results
- Error messages if any occur
- Data processing outputs

## 🛠️ Troubleshooting MinIO Access

### Common Issues and Solutions

#### Issue: MinIO Web UI Won't Load
**Solution**:
```bash
# Check if port forwarding is active
ps aux | grep "kubectl port-forward.*minio"

# Restart port forwarding if needed
pkill -f "kubectl port-forward.*minio"
kubectl port-forward svc/minio-service -n kubeflow 9001:9000 &
```

#### Issue: Wrong Credentials Error
**Verify credentials**:
```bash
# Get MinIO access key
kubectl get secret mlpipeline-minio-artifact -n kubeflow -o jsonpath='{.data.accesskey}' | base64 -d

# Get MinIO secret key  
kubectl get secret mlpipeline-minio-artifact -n kubeflow -o jsonpath='{.data.secretkey}' | base64 -d
```

#### Issue: No Pipeline Logs Found
**Check pipeline execution**:
```bash
# List recent workflows
kubectl get workflows -n kubeflow

# Check specific workflow status
kubectl describe workflow [workflow-name] -n kubeflow
```

#### Issue: Logs Script Fails
**Manual MinIO client approach**:
```bash
# Create MinIO client pod
kubectl run temp-minio-client --image=minio/mc --restart=Never --command -- sleep 3600

# Configure MinIO client
kubectl exec temp-minio-client -- mc alias set minio http://minio-service.kubeflow.svc.cluster.local:9000 minio minio123

# List pipeline artifacts
kubectl exec temp-minio-client -- mc ls minio/mlpipeline/artifacts/

# Get specific log file
kubectl exec temp-minio-client -- mc cat minio/mlpipeline/artifacts/[pipeline-name]/2025/06/08/[component-folder]/main.log

# Cleanup
kubectl delete pod temp-minio-client
```

## 📊 Log Analysis Tips

### Finding Specific Information

#### Component Execution Order
Look for timestamps in logs to understand execution sequence:
```
I0608 02:30:06.689478 - Step 1: Data Generation
I0608 02:30:15.713820 - Step 2: Data Cleaning  
I0608 02:30:25.965657 - Step 3: Data Analysis
I0608 02:30:39.117967 - Step 4: Report Generation
```

#### Data Passing Between Components
Check for input/output parameter values:
```
"inputs": {
  "parameterValues": {
    "data_summary": "Generated 50 samples, avg: 20.64°C"
  }
}
```

#### Error Diagnosis
Look for error messages or stack traces in component implementation logs.

#### Performance Analysis
Check execution timestamps to identify slow components.

## 🔗 Related Commands

### KFP Management
```bash
# Check pipeline status
./manage-kfp.sh status

# View recent KFP logs
./manage-kfp.sh logs

# Start KFP UI
./manage-kfp.sh start-ui
```

### Kubernetes Diagnostics
```bash
# Check MinIO pod status
kubectl get pods -n kubeflow | grep minio

# Check MinIO service
kubectl get svc minio-service -n kubeflow

# Check recent workflows
kubectl get workflows -n kubeflow --sort-by='.metadata.creationTimestamp'
```

## 📝 Quick Reference

### MinIO Access
- **URL**: http://localhost:9001
- **Username**: minio  
- **Password**: minio123
- **Bucket**: mlpipeline

### Log Script
```bash
./get-pipeline-logs.sh [workflow-name]
```

### Port Forwarding
```bash
# Start MinIO access
kubectl port-forward svc/minio-service -n kubeflow 9001:9000 &

# Stop MinIO access
pkill -f "kubectl port-forward.*minio"
```

---

## 🎯 Summary

Pipeline logs in KFP v2.2.0 are automatically stored in MinIO and accessible through:
1. **Web Interface**: Best for browsing and downloading logs
2. **Automated Script**: Best for quick log viewing in terminal
3. **Direct kubectl**: Best for real-time debugging while pods exist

Choose the method that best fits your workflow and debugging needs!

*For more help, see the main README.md or use `./manage-kfp.sh help`*