# GPT-2 Chat Server - Docker Setup Guide

## Overview

This Docker setup provides complete containerized environments for the GPT-2 chat server with both GPU (CUDA) and CPU-only variants, suitable for development, testing, and production deployments.

## Available Versions

### 🚀 GPU Version (CUDA Support)
- **NVIDIA CUDA 12.4** runtime with development tools
- **PyTorch with CUDA** support automatically installed
- **Automatic GPU detection** and utilization
- **Image Size**: ~8GB
- **Use Case**: Production deployments with GPU acceleration

### 💻 CPU Version (Lightweight)
- **Python 3.9 slim** base image
- **PyTorch CPU-only** version
- **No GPU dependencies**
- **Image Size**: ~1.5GB
- **Use Case**: Development, testing, CPU-only deployments

## Quick Start

### GPU Version (Production)
```bash
# Build and start GPU version
./docker/docker-manage.sh build
./docker/docker-manage.sh start

# Access the application
# Open browser: http://localhost:7137

# Stop application
./docker/docker-manage.sh stop
```

### CPU Version (Lightweight)
```bash
# Build and start CPU version
./docker/docker-manage.sh build-cpu
./docker/docker-manage.sh start-cpu

# Access the application
# Open browser: http://localhost:7137

# Stop application
./docker/docker-manage.sh stop
```

### Development Mode (GPU with Live Reload)
```bash
# Start with live code reload
./docker/docker-manage.sh dev
```

## Performance Comparison

| Feature | GPU Version | CPU Version |
|---------|-------------|-------------|
| Build Time | ~10-15 min | ~3-5 min |
| Image Size | ~8GB | ~1.5GB |
| Hardware Req | NVIDIA GPU + CUDA | Any x86_64 CPU |
| Performance | Fast inference | Slower inference |
| Memory | Higher | Lower |
| Use Case | Production | Development/Testing |

## Key Features

### 🚀 CUDA Support (GPU Version)
- **NVIDIA CUDA 12.4** runtime with development tools
- **PyTorch with CUDA** support automatically installed
- **Automatic GPU detection** and utilization
- **Fallback to CPU** if GPU is not available

### 🐳 Docker Configuration
- **Multi-variant setup** (GPU and CPU images)
- **Health checks** for monitoring application status
- **Persistent volumes** for model storage
- **Environment variable** configuration
- **Development and production** modes

### 🛠 Management Tools
- **docker-manage.sh** - Comprehensive management script
- **Support for both** Docker Compose V1 and V2
- **GPU status checking** and verification
- **Easy development workflow**

## Advantages of CPU Version

- **Smaller Image Size**: ~1.5GB vs ~8GB for GPU version
- **No GPU Requirements**: Works on any system with Docker
- **Faster Build Time**: Simpler dependencies
- **Lower Memory Usage**: No CUDA overhead
- **Perfect for Development**: Quick setup for testing and development

## Commands Reference

All commands use the same `docker-manage.sh` script:

### Build Commands
```bash
# Build GPU image
./docker/docker-manage.sh build

# Build CPU image
./docker/docker-manage.sh build-cpu
```

### Start Commands
```bash
# Start GPU version
./docker/docker-manage.sh start

# Start CPU version
./docker/docker-manage.sh start-cpu

# Start development mode (GPU with live reload)
./docker/docker-manage.sh dev
```

### Monitoring Commands
```bash
# Check status
./docker/docker-manage.sh status

# View logs
./docker/docker-manage.sh logs

# Check GPU status (GPU version only)
./docker/docker-manage.sh gpu

# Open shell in container
./docker/docker-manage.sh shell
```

### Management Commands
```bash
# Stop all containers
./docker/docker-manage.sh stop

# Clean up resources
./docker/docker-manage.sh clean

# Show help
./docker/docker-manage.sh help
```

### Direct Docker Compose
```bash
# Production GPU
docker compose -f docker/docker-compose.yml up --build

# Production CPU
docker compose -f docker/docker-compose.cpu.yml up --build

# Development
docker compose -f docker/docker-compose.dev.yml up --build
```

### System Monitoring
```bash
# System resource usage
docker stats

# GPU utilization (GPU version only)
watch -n 1 nvidia-smi

# Application health
curl http://localhost:7137/health
```

## Docker Files Structure

```
docker/
├── Dockerfile                   # Main Docker image with CUDA support
├── Dockerfile.cpu              # CPU-only Docker image
├── docker-compose.yml          # Production GPU configuration
├── docker-compose.cpu.yml      # CPU-only compose configuration
├── docker-compose.dev.yml      # Development configuration
├── docker-manage.sh            # Management script
├── .dockerignore               # Build optimization
├── .env.example                # Environment template
└── README.md                   # This comprehensive documentation
```

## Troubleshooting

### Build Issues
```bash
# Clean up and rebuild (GPU)
./docker/docker-manage.sh clean
./docker/docker-manage.sh build

# Clean up and rebuild (CPU)
./docker/docker-manage.sh clean
./docker/docker-manage.sh build-cpu
```

### Runtime Issues
```bash
# Check logs
./docker/docker-manage.sh logs

# Check container status
./docker/docker-manage.sh status

# Open shell for debugging
./docker/docker-manage.sh shell
```

### Port Conflicts
If port 7137 is in use:
```bash
# Stop all containers
./docker/docker-manage.sh stop

# Or modify port in docker-compose files
# Change "7137:7137" to "8137:7137" for port 8137
```

### GPU Issues (GPU Version)
```bash
# Check GPU availability
./docker/docker-manage.sh gpu

# Verify NVIDIA Docker runtime
docker run --rm --gpus all nvidia/cuda:12.4-base-ubuntu20.04 nvidia-smi

# Check CUDA support in container
./docker/docker-manage.sh shell
# Then run: python -c "import torch; print(torch.cuda.is_available())"
```

## Development Workflows

### CPU Development Workflow
1. **Initial Setup**:
   ```bash
   ./docker/docker-manage.sh build-cpu
   ./docker/docker-manage.sh start-cpu
   ```

2. **Code Changes**: 
   - CPU version doesn't have live reload
   - Rebuild after changes: `./docker/docker-manage.sh build-cpu`
   - Restart: `./docker/docker-manage.sh stop && ./docker/docker-manage.sh start-cpu`

3. **Testing**:
   ```bash
   # View logs
   ./docker/docker-manage.sh logs
   
   # Debug in container
   ./docker/docker-manage.sh shell
   ```

4. **Cleanup**:
   ```bash
   ./docker/docker-manage.sh clean
   ```

### GPU Development Workflow
1. **Initial Setup**:
   ```bash
   ./docker/docker-manage.sh build
   ./docker/docker-manage.sh dev  # Live reload enabled
   ```

2. **Code Changes**: 
   - Development mode has live reload
   - Changes are automatically reflected

3. **Testing**:
   ```bash
   # View logs
   ./docker/docker-manage.sh logs
   
   # Check GPU utilization
   ./docker/docker-manage.sh gpu
   ```

4. **Production Build**:
   ```bash
   ./docker/docker-manage.sh stop
   ./docker/docker-manage.sh build
   ./docker/docker-manage.sh start
   ```

## Performance Considerations

### CPU Version
- **Inference Speed**: Slower than GPU version (expected)
- **Memory Usage**: Lower overall memory footprint
- **CPU Usage**: Will utilize available CPU cores
- **Suitable for**: Development, testing, small-scale deployments

### GPU Version
- **Inference Speed**: Significantly faster with GPU acceleration
- **Memory Usage**: Higher due to CUDA overhead
- **GPU Usage**: Utilizes available GPU memory and compute
- **Suitable for**: Production deployments, high-throughput scenarios

## Use Case Recommendations

### Choose CPU Version When:
- Developing and testing locally
- No GPU hardware available
- Small-scale deployments
- Budget-conscious setups
- Quick prototyping

### Choose GPU Version When:
- Production deployments
- High-throughput requirements
- GPU hardware available
- Performance is critical
- Serving many concurrent users

## Access Information

- **Application URL**: http://localhost:7137
- **Health Check**: http://localhost:7137/health
- **Default Port**: 7137 (configurable in docker-compose files)

This comprehensive Docker setup provides a robust, scalable environment for the GPT-2 chat server, suitable for both development and production use cases with flexible GPU and CPU-only options.
