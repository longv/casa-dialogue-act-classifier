# Use Python 3.8 base image (ARM64 compatible)
FROM python:3.8-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    build-essential \
    gcc \
    g++ \
    gfortran \
    libopenblas-dev \
    liblapack-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Rust (needed for tokenizers package)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Upgrade pip and install build tools
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# Install PyTorch CPU-only version (ARM64 compatible)
# RUN pip install --no-cache-dir torch==2.0.0 torchvision torchaudio

# Install numpy first (needed for scikit-learn)
RUN pip install --no-cache-dir "numpy<2.0"

# Copy requirements and modify for ARM64 compatibility
COPY requirements.txt .

# Install updated versions of packages with ARM64 support
# RUN pip install --no-cache-dir \
#     transformers>=4.20.0 \
#     datasets>=2.0.0 \
#     scikit-learn>=1.0.0 \
#     wandb>=0.12.0 \
#     pytorch_lightning>=1.5.0 \
#     tensorboard
RUN pip install --no-cache-dir -r requirements.txt

# Create necessary directories
RUN mkdir -p /app/checkpoints /app/data

# Copy and unzip switchboard dataset
COPY data/switchboard.zip /app/data/
RUN cd /app/data && unzip -q switchboard.zip && rm switchboard.zip

# Copy project files
COPY . .

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV CUDA_VISIBLE_DEVICES=""

# Expose port for TensorBoard (optional)
EXPOSE 6006

# Default command
CMD ["python", "main.py"]
