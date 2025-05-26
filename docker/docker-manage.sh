#!/bin/bash

# Docker management script for GPT-2 Chat Server
# Usage: ./docker-manage.sh [command]

set -e

DOCKER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$DOCKER_DIR/.." && pwd)"
COMPOSE_FILE="$DOCKER_DIR/docker-compose.yml"
DEV_COMPOSE_FILE="$DOCKER_DIR/docker-compose.dev.yml"
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
    print_header "Building Docker Image: gpt2-server"
    cd "$PROJECT_ROOT"
    docker build -f docker/Dockerfile -t gpt2-server .
    print_status "Build completed successfully. Image tagged as 'gpt2-server'"
}

# Start the application in production mode
start() {
    print_header "Starting GPT-2 Chat Server (Production)"
    
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

# Start the application in development mode
dev() {
    print_header "Starting GPT-2 Chat Server (Development)"
    
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
    $COMPOSE_CMD -f "$COMPOSE_FILE" down
    $COMPOSE_CMD -f "$DEV_COMPOSE_FILE" down 2>/dev/null || true
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
    $COMPOSE_CMD -f "$COMPOSE_FILE" logs -f gpt-chat-app
}

# Clean up containers and images
clean() {
    print_header "Cleaning Up Docker Resources"
    cd "$PROJECT_ROOT"
    
    # Stop and remove containers
    $COMPOSE_CMD -f "$COMPOSE_FILE" down --remove-orphans
    $COMPOSE_CMD -f "$DEV_COMPOSE_FILE" down --remove-orphans 2>/dev/null || true
    
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
    $COMPOSE_CMD -f "$COMPOSE_FILE" ps
}

# Execute command in container
shell() {
    print_header "Opening Shell in Container"
    cd "$PROJECT_ROOT"
    $COMPOSE_CMD -f "$COMPOSE_FILE" exec gpt-chat-app bash
}

# Show help
help() {
    echo "GPT-2 Chat Server Docker Management Script"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  build     Build the Docker image and tag it as 'gpt2-server'"
    echo "  start     Start the application (production mode)"
    echo "  dev       Start the application (development mode)"
    echo "  stop      Stop the application"
    echo "  restart   Restart the application"
    echo "  logs      View application logs"
    echo "  status    Show application status"
    echo "  gpu       Check GPU availability and CUDA status"
    echo "  shell     Open shell in container"
    echo "  clean     Clean up Docker resources"
    echo "  help      Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 build                # Build the gpt2-server image"
    echo "  $0 start                # Start using pre-built gpt2-server image"
    echo "  $0 dev                  # Start in development mode"
    echo "  $0 gpu                  # Check GPU status"
    echo "  $0 logs                 # View logs"
    echo ""
    echo "Note: You must build the image first before starting the application."
    echo "      The image will be tagged as 'gpt2-server' and used by compose files."
    echo ""
    echo "GPU Requirements:"
    echo "  - NVIDIA GPU with CUDA Compute Capability 3.5+"
    echo "  - NVIDIA Driver 450.80.02+"
    echo "  - NVIDIA Container Toolkit installed"
}

# Main script logic
main() {
    check_dependencies
    
    case "${1:-help}" in
        build)
            build
            ;;
        start)
            start
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
