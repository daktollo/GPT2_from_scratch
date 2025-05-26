# Use NVIDIA CUDA base image with Python 3.9
FROM nvidia/cuda:12.4.1-runtime-ubuntu22.04

# Set environment variables to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install Python 3.9 and system dependencies
RUN apt-get update && apt-get install -y \
    software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update && apt-get install -y \
    python3.9 \
    python3.9-dev \
    python3.9-distutils \
    python3-pip \
    build-essential \
    curl \
    wget \
    git \
    && rm -rf /var/lib/apt/lists/*

# Create symlinks for python
RUN ln -sf /usr/bin/python3.9 /usr/bin/python3 \
    && ln -sf /usr/bin/python3.9 /usr/bin/python

# Upgrade pip
RUN python3 -m pip install --upgrade pip

# Set working directory in container
WORKDIR /app

# Copy requirements first for better caching
COPY requirements.txt .

# Install PyTorch with CUDA support first
RUN pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# Handle system package conflicts by removing problematic system packages first
# This completely removes the distutils-installed packages that cause conflicts
RUN python3 -m pip uninstall -y blinker markupsafe itsdangerous werkzeug jinja2 click flask || true

# Install all system-conflicting packages with ignore-installed and no-deps
RUN pip install --ignore-installed --no-deps blinker markupsafe itsdangerous werkzeug jinja2 click flask

# Install Python dependencies with force-reinstall for any remaining conflicts
RUN pip install --no-cache-dir -r requirements.txt || \
    pip install --no-cache-dir --force-reinstall -r requirements.txt

# Verify CUDA installation
RUN python3 -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}'); print(f'CUDA version: {torch.version.cuda}'); print(f'Device count: {torch.cuda.device_count()}')"

# Copy the entire application
COPY . .

# Create necessary directories
RUN mkdir -p model/gpt2/124M

# Set environment variables
ENV PYTHONPATH=/app
ENV PYTHONUNBUFFERED=1
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility
ENV CUDA_VISIBLE_DEVICES=all

# Expose the port the app runs on
EXPOSE 7137

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:7137/ || exit 1

# Run the application
CMD ["python", "run_server.py"]
