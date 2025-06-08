#!/bin/bash

# Kubeflow Pipelines v2.2.0 Management Script for Minikube
# Usage: ./manage-kfp.sh [command]
#
# Commands:
#   start-ui   - Start port forwarding to KFP UI
#   stop-ui    - Stop port forwarding
#   status     - Check cluster and KFP status
#   logs       - Show KFP logs
#   restart    - Restart port forwarding
#   help       - Show this help

set -e  # Exit on any error

# Configuration for KFP v2.2.0
KFP_VERSION="2.2.0"
CLUSTER_CONTEXT="minikube"
NAMESPACE="kubeflow"
UI_PORT="8080"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_command() {
    echo -e "${CYAN}[CMD]${NC} $1"
}

# Function to check if kubectl is available
check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl not found. Please install kubectl first."
        exit 1
    fi
}

# Function to check if minikube cluster exists
check_cluster() {
    print_status "Checking if minikube cluster is accessible..."
    if ! kubectl cluster-info --context "$CLUSTER_CONTEXT" &> /dev/null; then
        print_error "Minikube cluster not found or not accessible."
        print_status "Please ensure minikube is running: minikube status"
        print_status "Start minikube with: minikube start"
        exit 1
    fi
    print_success "Minikube cluster is accessible"
}

# Function to start UI port forwarding
start_ui() {
    check_kubectl
    check_cluster

    # Check if port forwarding is already running
    if pgrep -f "kubectl port-forward.*istio-ingressgateway.*$UI_PORT" > /dev/null; then
        print_warning "Port forwarding to port $UI_PORT is already running"
        print_status "KFP UI should be accessible at: http://localhost:$UI_PORT"
        return 0
    fi

    # Check if istio-ingressgateway is ready (primary access method)
    if kubectl get svc istio-ingressgateway -n istio-system --context "$CLUSTER_CONTEXT" &> /dev/null; then
        print_status "Starting port forwarding via Istio gateway..."
        kubectl port-forward -n istio-system svc/istio-ingressgateway "$UI_PORT:80" --context "$CLUSTER_CONTEXT" &
    # Fallback to direct ml-pipeline-ui service
    elif kubectl get svc ml-pipeline-ui -n "$NAMESPACE" --context "$CLUSTER_CONTEXT" &> /dev/null; then
        print_status "Starting port forwarding via ml-pipeline-ui service..."
        kubectl port-forward -n "$NAMESPACE" svc/ml-pipeline-ui "$UI_PORT:80" --context "$CLUSTER_CONTEXT" &
    else
        print_error "Neither Istio gateway nor ml-pipeline-ui service found."
        print_status "Please check KFP installation status: ./manage-kfp.sh status"
        exit 1
    fi

    sleep 3  # Give it a moment to start

    if pgrep -f "kubectl port-forward.*$UI_PORT" > /dev/null; then
        print_success "Port forwarding started successfully"
        print_status "KFP UI is now accessible at: http://localhost:$UI_PORT"
        print_status "Press Ctrl+C to stop port forwarding, or use: ./manage-kfp.sh stop-ui"
    else
        print_error "Failed to start port forwarding"
        exit 1
    fi
}

# Function to stop UI port forwarding
stop_ui() {
    print_status "Stopping KFP UI port forwarding..."
    
    if pgrep -f "kubectl port-forward.*$UI_PORT" > /dev/null; then
        pkill -f "kubectl port-forward.*$UI_PORT"
        print_success "Port forwarding stopped"
    else
        print_warning "No port forwarding process found for port $UI_PORT"
    fi
}

# Function to restart port forwarding
restart_ui() {
    print_status "Restarting KFP UI port forwarding..."
    stop_ui
    sleep 2
    start_ui
}

# Function to check status
check_status() {
    check_kubectl
    
    echo "=== Minikube Cluster Status ==="
    if kubectl cluster-info --context "$CLUSTER_CONTEXT" &> /dev/null; then
        print_success "Minikube cluster is running"
        kubectl cluster-info --context "$CLUSTER_CONTEXT"
    else
        print_error "Minikube cluster is not accessible"
        return 1
    fi

    echo ""
    echo "=== KFP v2.2.0 Namespace ==="
    if kubectl get namespace "$NAMESPACE" --context "$CLUSTER_CONTEXT" &> /dev/null; then
        print_success "Namespace '$NAMESPACE' exists"
    else
        print_error "Namespace '$NAMESPACE' not found - KFP not installed"
        return 1
    fi

    echo ""
    echo "=== KFP v2.2.0 Core Services ==="
    kubectl get pods -n "$NAMESPACE" --context "$CLUSTER_CONTEXT" | grep -E "(ml-pipeline|mysql|minio|workflow|cache|metadata)" | grep -v "Completed"

    echo ""
    echo "=== KFP v2.2.0 Service Status ==="
    core_services=("ml-pipeline" "ml-pipeline-ui" "mysql" "minio" "workflow-controller")
    
    for service in "${core_services[@]}"; do
        if kubectl get deployment "$service" -n "$NAMESPACE" --context "$CLUSTER_CONTEXT" &> /dev/null; then
            ready=$(kubectl get deployment "$service" -n "$NAMESPACE" --context "$CLUSTER_CONTEXT" -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
            total=$(kubectl get deployment "$service" -n "$NAMESPACE" --context "$CLUSTER_CONTEXT" -o jsonpath='{.spec.replicas}' 2>/dev/null || echo "1")
            
            if [ "$ready" = "$total" ] && [ "$ready" != "0" ]; then
                print_success "$service: $ready/$total ready"
            else
                print_warning "$service: $ready/$total ready"
            fi
        else
            print_warning "$service: not found"
        fi
    done

    echo ""
    echo "=== Port Forwarding Status ==="
    if pgrep -f "kubectl port-forward.*$UI_PORT" > /dev/null; then
        print_success "Port forwarding to port $UI_PORT is active"
        print_status "KFP UI accessible at: http://localhost:$UI_PORT"
    else
        print_warning "Port forwarding not active"
        print_status "Start with: ./manage-kfp.sh start-ui"
    fi

    echo ""
    echo "=== Recent Workflows ==="
    kubectl get workflows -n "$NAMESPACE" --context "$CLUSTER_CONTEXT" 2>/dev/null | head -6 || print_warning "No workflows found or Argo not installed"

    echo ""
    echo "=== KFP v2.2.0 Version Info ==="
    api_version=$(kubectl get deployment ml-pipeline -n "$NAMESPACE" --context "$CLUSTER_CONTEXT" -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null | grep -o 'api-server:[^"]*' | cut -d: -f2 || echo "unknown")
    print_status "API Server version: $api_version"
    print_status "Expected version: 2.2.0"

    echo ""
    echo "=== Resource Usage ==="
    echo "Minikube status:"
    minikube status 2>/dev/null || print_warning "Minikube status unavailable"
}

# Function to show logs
show_logs() {
    check_kubectl
    check_cluster

    echo "=== KFP v2.2.0 API Server Logs ==="
    kubectl logs -n "$NAMESPACE" deployment/ml-pipeline --tail=20 --context "$CLUSTER_CONTEXT" 2>/dev/null || print_warning "ml-pipeline logs not available"

    echo ""
    echo "=== KFP UI Logs ==="
    kubectl logs -n "$NAMESPACE" deployment/ml-pipeline-ui --tail=20 --context "$CLUSTER_CONTEXT" 2>/dev/null || print_warning "ml-pipeline-ui logs not available"

    echo ""
    echo "=== Workflow Controller Logs ==="
    kubectl logs -n "$NAMESPACE" deployment/workflow-controller --tail=20 --context "$CLUSTER_CONTEXT" 2>/dev/null || print_warning "workflow-controller logs not available"

    echo ""
    echo "=== Metadata Service Logs ==="
    kubectl logs -n "$NAMESPACE" deployment/metadata-grpc-deployment --tail=10 --context "$CLUSTER_CONTEXT" 2>/dev/null || print_warning "metadata service logs not available"

    echo ""
    print_status "For real-time logs, use:"
    print_command "kubectl logs -n $NAMESPACE deployment/ml-pipeline -f --context $CLUSTER_CONTEXT"
}

# Function to show help
show_help() {
    echo "Kubeflow Pipelines v2.2.0 Management Script"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  start-ui   - Start port forwarding to KFP UI (port $UI_PORT)"
    echo "  stop-ui    - Stop port forwarding"
    echo "  restart    - Restart port forwarding"
    echo "  status     - Check cluster and KFP v2.2.0 status"
    echo "  logs       - Show recent KFP logs"
    echo "  help       - Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 start-ui          # Start UI access"
    echo "  $0 status            # Check everything"
    echo "  $0 logs              # View service logs"
    echo ""
    echo "KFP v2.2.0 Environment:"
    echo "  - UI Access: http://localhost:$UI_PORT"
    echo "  - v2 Pipeline Support: @dsl.component syntax"
    echo "  - Automatic Data Passing: task.output references"
    echo "  - Enhanced Resources: 2Gi memory, 1 CPU limits"
    echo ""
    echo "Development Environment:"
    echo "  - KFP v2 SDK: conda activate kfp-v2"
    echo "  - Pipeline Examples: examples/working/*_v2.yaml"
    echo "  - Log Access: ./get-pipeline-logs.sh [workflow-name]"
    echo "  - MinIO Artifacts: http://localhost:9001 (minio/minio123)"
    echo ""
    echo "Prerequisites:"
    echo "  - Minikube cluster must be running"
    echo "  - kubectl must be installed and working"
    echo "  - KFP v2.2.0 deployed and operational"
    echo ""
    echo "Configuration:"
    echo "  Cluster: $CLUSTER_CONTEXT"
    echo "  KFP Version: $KFP_VERSION"
    echo "  UI Port: $UI_PORT"
    echo "  Namespace: $NAMESPACE"
}

# Main script logic
case "${1:-help}" in
    "start-ui")
        start_ui
        ;;
    "stop-ui")
        stop_ui
        ;;
    "restart")
        restart_ui
        ;;
    "status")
        check_status
        ;;
    "logs")
        show_logs
        ;;
    "help"|"-h"|"--help"|"")
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac