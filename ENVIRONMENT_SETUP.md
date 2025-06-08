# 🐍 KFP v2.2.0 Environment Setup Guide

## 📋 Prerequisites

- **macOS with Apple Silicon (M1/M2)** - Optimized for ARM64
- **Miniforge/Conda** - For Python environment management
- **Docker Desktop** - For Kubernetes container runtime
- **Minikube** - For local Kubernetes cluster

## 🚀 Quick Setup

### 1. Create KFP v2 Environment
```bash
# Create environment from exported configuration
conda env create -f environment.yml

# Activate environment
conda activate kfp-v2

# Verify installation
kfp --version  # Should show: 2.13.0
python --version  # Should show: Python 3.11.13
```

### 2. Start KFP Infrastructure
```bash
# Start Minikube (if not already running)
minikube start

# Start KFP UI
./manage-kfp.sh start-ui

# Access UI at: http://localhost:8080
```

### 3. Test Environment
```bash
# Compile a test pipeline
python examples/src/test-pipeline-simple.py

# Upload test-kfp-v2.yaml to KFP UI
# Create and run a test execution
```

## 🔧 Environment Details

### Python Environment
- **Python**: 3.11.13 (ARM64 optimized)
- **KFP SDK**: 2.13.0 (latest stable)
- **KFP Server**: 2.2.0 (running in cluster)

### Key Dependencies
- `kfp==2.13.0` - Main KFP v2 SDK
- `kfp-pipeline-spec==0.6.0` - Pipeline specification
- `kfp-server-api==2.4.0` - Server API client
- `google-cloud-*` - Google Cloud integrations
- `pyyaml==6.0.2` - YAML processing

### Resource Optimization
- **Memory**: 2Gi limits for ML pipeline API server
- **CPU**: 1 CPU limits for enhanced stability
- **Storage**: MinIO for artifact persistence
- **Networking**: Istio ingress gateway

## 🛠️ Development Workflow

### Pipeline Development
```bash
# Activate environment
conda activate kfp-v2

# Edit pipeline source
code examples/src/ml_pipeline_no_emojis_v2.py

# Compile pipeline
python examples/src/ml_pipeline_no_emojis_v2.py

# Upload examples/working/ml_pipeline_no_emojis_v2.yaml to KFP UI
```

### Environment Management
```bash
# Update environment
conda env update -f environment.yml --prune

# Export changes
conda env export > environment.yml

# Remove environment (if needed)
conda env remove -n kfp-v2
```

## 🔍 Troubleshooting

### Common Issues

#### Import Error: No module named 'kfp'
```bash
# Ensure environment is activated
conda activate kfp-v2

# Verify KFP installation
pip show kfp
```

#### KFP UI Not Accessible
```bash
# Check cluster status
./manage-kfp.sh status

# Restart port forwarding
./manage-kfp.sh restart
```

#### Environment Conflicts
```bash
# Clean reinstall
conda env remove -n kfp-v2
conda env create -f environment.yml
```

## 📊 Platform Compatibility

### Supported Platforms
- ✅ **macOS Apple Silicon (M1/M2)** - Primary target
- ✅ **macOS Intel** - Should work with x86_64 images
- ⚠️ **Linux ARM64** - May require image adjustments
- ⚠️ **Linux x86_64** - May require image adjustments
- ❌ **Windows** - Not tested, use WSL2

### Apple Silicon Optimizations
- Native ARM64 Python environment
- ARM64-compatible container images
- Optimized resource allocation for M1/M2
- Native Docker Desktop integration

## 🎯 Next Steps

1. **Explore Examples**: Try all pipelines in `examples/working/`
2. **Create Custom Pipelines**: Use examples as templates
3. **Access Logs**: Use MinIO at http://localhost:9001
4. **Advanced Features**: Experiment with conditional execution

For detailed usage, see the main [README.md](README.md)

---

*Environment optimized for Apple Silicon M1/M2 with resource constraints*