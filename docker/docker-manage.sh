#!/bin/bash

# Docker management script for GPT-2 Chat Server
# Usage: ./docker-manage.sh [command]

set -e

DOCKER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$DOCKER_DIR/.." && pwd)"
COMPOSE_FILE="$DOCKER_DIR/docker-compose.yml"
DEV_COMPOSE_FILE="$DOCKER_DIR/docker-compose.dev.yml"
CPU_COMPOSE_FILE="$DOCKER_DIR/docker-compose.cpu.yml"
COMPOSE_CMD=""  # Will be set by check_dependencies function

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

# Check if Docker and Docker Compose are installed
check_dependencies() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi

    # Check for Docker Compose (V1 or V2)
    if command -v docker-compose &> /dev/null; then
        COMPOSE_CMD="docker-compose"
        print_status "Using Docker Compose V1"
    elif docker compose version &> /dev/null; then
        COMPOSE_CMD="docker compose"
        print_status "Using Docker Compose V2"
    else
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi

    # Check for NVIDIA GPU and drivers
    if ! command -v nvidia-smi &> /dev/null; then
        print_warning "nvidia-smi not found. GPU acceleration may not be available."
        print_warning "Install NVIDIA drivers and NVIDIA Container Toolkit for GPU support."
    else
        print_status "NVIDIA GPU detected. Checking Docker GPU support..."
        if docker info 2>/dev/null | grep -q nvidia; then
            print_status "NVIDIA Container Toolkit detected. GPU acceleration enabled."
        else
            print_warning "NVIDIA Container Toolkit not detected. Install it for GPU support:"
            print_warning "https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html"
        fi
    fi
}

# Build the Docker image (creates gpt2-server image)
build() {
    print_header "Building Docker Image: gpt2-server (GPU)"
    cd "$PROJECT_ROOT"
    docker build -f docker/Dockerfile -t gpt2-server .
    print_status "Build completed successfully. Image tagged as 'gpt2-server'"
}

# Build CPU-only Docker image
build_cpu() {
    print_header "Building Docker Image: gpt2-server-cpu (CPU Only)"
    cd "$PROJECT_ROOT"
    docker build -f docker/Dockerfile.cpu -t gpt2-server-cpu .
    print_status "CPU build completed successfully. Image tagged as 'gpt2-server-cpu'"
}

# Start the application in production mode
start() {
    print_header "Starting GPT-2 Chat Server (Production - GPU)"
    
    # Check if gpt2-server image exists
    if ! docker images | grep -q "gpt2-server"; then
        print_error "Image 'gpt2-server' not found. Please build it first using: $0 build"
        exit 1
    fi
    
    cd "$PROJECT_ROOT"
    $COMPOSE_CMD -f "$COMPOSE_FILE" up -d
    print_status "Application started successfully"
    print_status "Access the application at: http://localhost:7137"
}

# Start CPU-only application
start_cpu() {
    print_header "Starting GPT-2 Chat Server (Production - CPU Only)"
    
    # Check if gpt2-server-cpu image exists
    if ! docker images | grep -q "gpt2-server-cpu"; then
        print_error "Image 'gpt2-server-cpu' not found. Please build it first using: $0 build-cpu"
        exit 1
    fi
    
    cd "$PROJECT_ROOT"
    $COMPOSE_CMD -f "$CPU_COMPOSE_FILE" up -d
    print_status "CPU application started successfully"
    print_status "Access the application at: http://localhost:7137"
}

# Start the application in development mode
dev() {
    print_header "Starting GPT-2 Chat Server (Development - GPU)"
    
    # Check if gpt2-server image exists
    if ! docker images | grep -q "gpt2-server"; then
        print_error "Image 'gpt2-server' not found. Please build it first using: $0 build"
        exit 1
    fi
    
    cd "$PROJECT_ROOT"
    $COMPOSE_CMD -f "$DEV_COMPOSE_FILE" up
}

# Stop the application
stop() {
    print_header "Stopping GPT-2 Chat Server"
    cd "$PROJECT_ROOT"
    $COMPOSE_CMD -f "$COMPOSE_FILE" down 2>/dev/null || true
    $COMPOSE_CMD -f "$DEV_COMPOSE_FILE" down 2>/dev/null || true
    $COMPOSE_CMD -f "$CPU_COMPOSE_FILE" down 2>/dev/null || true
    print_status "Application stopped successfully"
}

# Restart the application
restart() {
    print_header "Restarting GPT-2 Chat Server"
    stop
    start
}

# View logs
logs() {
    print_header "Viewing Application Logs"
    cd "$PROJECT_ROOT"
    
    # Check which containers are running and show logs
    if $COMPOSE_CMD -f "$COMPOSE_FILE" ps | grep -q "Up"; then
        print_status "Showing GPU container logs..."
        $COMPOSE_CMD -f "$COMPOSE_FILE" logs -f gpt-chat-app
    elif $COMPOSE_CMD -f "$CPU_COMPOSE_FILE" ps | grep -q "Up"; then
        print_status "Showing CPU container logs..."
        $COMPOSE_CMD -f "$CPU_COMPOSE_FILE" logs -f gpt-chat-app-cpu
    else
        print_error "No containers are running. Start the application first."
        exit 1
    fi
}

# Clean up containers and images
clean() {
    print_header "Cleaning Up Docker Resources"
    cd "$PROJECT_ROOT"
    
    # Stop and remove containers
    $COMPOSE_CMD -f "$COMPOSE_FILE" down --remove-orphans 2>/dev/null || true
    $COMPOSE_CMD -f "$DEV_COMPOSE_FILE" down --remove-orphans 2>/dev/null || true
    $COMPOSE_CMD -f "$CPU_COMPOSE_FILE" down --remove-orphans 2>/dev/null || true
    
    # Remove unused images
    docker image prune -f
    
    print_status "Cleanup completed successfully"
}

# Check GPU status
gpu() {
    print_header "GPU Status Check"
    cd "$PROJECT_ROOT"
    
    print_status "Host GPU Status:"
    if command -v nvidia-smi &> /dev/null; then
        nvidia-smi
    else
        print_warning "nvidia-smi not available on host"
    fi
    
    print_status "Container GPU Status:"
    if $COMPOSE_CMD -f "$COMPOSE_FILE" ps | grep -q "Up"; then
        $COMPOSE_CMD -f "$COMPOSE_FILE" exec gpt-chat-app nvidia-smi 2>/dev/null || print_warning "GPU not accessible in container"
        print_status "PyTorch CUDA Status:"
        $COMPOSE_CMD -f "$COMPOSE_FILE" exec gpt-chat-app python -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}'); print(f'CUDA version: {torch.version.cuda}'); print(f'GPU count: {torch.cuda.device_count()}'); [print(f'GPU {i}: {torch.cuda.get_device_name(i)}') for i in range(torch.cuda.device_count())]" 2>/dev/null || print_warning "Cannot check PyTorch CUDA status"
    else
        print_warning "Container not running. Start the application first."
    fi
}

# Show application status
status() {
    print_header "Application Status"
    cd "$PROJECT_ROOT"
    print_status "GPU Containers:"
    $COMPOSE_CMD -f "$COMPOSE_FILE" ps 2>/dev/null || echo "No GPU containers running"
    print_status "CPU Containers:"
    $COMPOSE_CMD -f "$CPU_COMPOSE_FILE" ps 2>/dev/null || echo "No CPU containers running"
}

# Execute command in container
shell() {
    print_header "Opening Shell in Container"
    cd "$PROJECT_ROOT"
    
    # Check which containers are running
    if $COMPOSE_CMD -f "$COMPOSE_FILE" ps | grep -q "Up"; then
        print_status "Opening shell in GPU container..."
        $COMPOSE_CMD -f "$COMPOSE_FILE" exec gpt-chat-app bash
    elif $COMPOSE_CMD -f "$CPU_COMPOSE_FILE" ps | grep -q "Up"; then
        print_status "Opening shell in CPU container..."
        $COMPOSE_CMD -f "$CPU_COMPOSE_FILE" exec gpt-chat-app-cpu bash
    else
        print_error "No containers are running. Start the application first."
        exit 1
    fi
}

# Show help
help() {
    echo "GPT-2 Chat Server Docker Management Script"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "GPU Commands (CUDA support):"
    echo "  build        Build the Docker image with GPU support (gpt2-server)"
    echo "  start        Start the application (production mode - GPU)"
    echo "  dev          Start the application (development mode - GPU)"
    echo ""
    echo "CPU Commands (Lightweight, no CUDA):"
    echo "  build-cpu    Build the Docker image with CPU-only support (gpt2-server-cpu)"
    echo "  start-cpu    Start the application (production mode - CPU only)"
    echo ""
    echo "General Commands:"
    echo "  stop         Stop all running containers"
    echo "  restart      Restart the GPU application"
    echo "  logs         View application logs"
    echo "  status       Show application status"
    echo "  gpu          Check GPU availability and CUDA status"
    echo "  shell        Open shell in running container"
    echo "  clean        Clean up Docker resources"
    echo "  help         Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 build                # Build GPU-enabled image"
    echo "  $0 build-cpu            # Build CPU-only image"
    echo "  $0 start                # Start GPU version"
    echo "  $0 start-cpu            # Start CPU version"
    echo "  $0 dev                  # Start in development mode (GPU)"
    echo "  $0 gpu                  # Check GPU status"
    echo ""
    echo "Note: You must build the appropriate image first before starting the application."
    echo ""
    echo "GPU Requirements:"
    echo "  - NVIDIA GPU with CUDA Compute Capability 3.5+"
    echo "  - NVIDIA Driver 450.80.02+"
    echo "  - NVIDIA Container Toolkit installed"
    echo ""
    echo "CPU Version:"
    echo "  - Lighter weight image (~1.5GB vs ~8GB)"
    echo "  - No GPU dependencies"
    echo "  - Suitable for development and light usage"
}

# Main script logic
main() {
    check_dependencies
    
    case "${1:-help}" in
        build)
            build
            ;;
        build-cpu)
            build_cpu
            ;;
        start)
            start
            ;;
        start-cpu)
            start_cpu
            ;;
        dev)
            dev
            ;;
        stop)
            stop
            ;;
        restart)
            restart
            ;;
        logs)
            logs
            ;;
        status)
            status
            ;;
        gpu)
            gpu
            ;;
        shell)
            shell
            ;;
        clean)
            clean
            ;;
        help|--help|-h)
            help
            ;;
        *)
            print_error "Unknown command: $1"
            echo ""
            help
            exit 1
            ;;
    esac
}

# Run the main function with all arguments
main "$@"
