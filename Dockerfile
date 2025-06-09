# Use Python slim image for smaller size
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install system dependencies and uv
RUN apt-get update && apt-get install -y \
    supervisor \
    curl \
    openssh-client \
    git \ 
    && curl -LsSf https://astral.sh/uv/install.sh | sh \
    && rm -rf /var/lib/apt/lists/*

ADD .ssh /root/.ssh
RUN chmod 600 /root/.ssh/* && \
    ssh-keyscan github.com >> /root/.ssh/known_hosts

# Add uv to PATH for all users
ENV PATH="/root/.local/bin:$PATH"

# Copy project files for uv
COPY pyproject.toml requirements.txt ./

# Install Python dependencies using uv (much faster than pip)
RUN /root/.local/bin/uv venv /opt/venv && \
    /root/.local/bin/uv pip install --python /opt/venv/bin/python -r requirements.txt

# Add virtual environment to PATH
ENV PATH="/opt/venv/bin:$PATH"

# Create supervisor config directory
RUN mkdir -p /var/log/supervisor

# Copy supervisor configuration
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Create non-root user
RUN useradd -m -u 1000 mcpuser && chown -R mcpuser:mcpuser /app
