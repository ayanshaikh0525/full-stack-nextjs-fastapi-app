# ----------- Builder Stage -----------
FROM python:3.12-bookworm AS builder

WORKDIR /app

# Install required tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates

# Install uv
ADD https://astral.sh/uv/install.sh /uv-installer.sh
RUN sh /uv-installer.sh && rm /uv-installer.sh

ENV PATH="/root/.local/bin/:$PATH"

# Copy only dependency files first (for caching)
COPY pyproject.toml uv.lock ./

# Install dependencies into .venv
RUN uv sync --frozen

# ----------- Runtime Stage -----------
FROM python:3.12-slim-bookworm

WORKDIR /app

# Copy virtual environment from builder
COPY --from=builder /app/.venv /app/.venv

# Set PATH to use venv
ENV PATH="/app/.venv/bin:$PATH"

# Copy application code
COPY . .

# Expose port
EXPOSE 8000

# Run app
CMD ["./start.sh"]
