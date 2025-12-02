# Use an official Python runtime as a parent image
FROM python:3.11-slim

# Set work directory in container
WORKDIR /app

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV PIP_NO_CACHE_DIR 1
ENV PIP_DISABLE_PIP_VERSION_CHECK 1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    make \
    curl \
    wget \
    git \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip and install common AI/ML dependencies
RUN pip install --upgrade pip

# Copy requirements file first (for better Docker layer caching)
COPY requirements.txt .

# Install Python dependencies
RUN pip install -r requirements.txt

# Copy application code
COPY . .

# Create non-root user for security
RUN groupadd -r appuser && \
    useradd --gid appuser --home-dir /home/appuser --shell /bin/bash appuser && \
    chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose port (adjust as needed)
EXPOSE 8000

# Health check (adjust URL as needed)
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f -s -S --retry 3 http://localhost:8000/health || exit 1

# Default command (adjust as needed)
CMD ["python", "app.py"]