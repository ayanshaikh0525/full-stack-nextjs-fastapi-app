# ----------- Builder Stage -----------
FROM python:3.12-slim-bookworm AS builder

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates

ADD https://astral.sh/uv/install.sh /uv-installer.sh
RUN sh /uv-installer.sh && rm /uv-installer.sh

ENV PATH="/root/.local/bin:$PATH"

COPY pyproject.toml uv.lock ./


RUN uv venv /app/.venv

RUN uv sync --frozen

# ----------- Runtime Stage -----------
FROM python:3.12-slim-bookworm

WORKDIR /app

RUN pip install uv

COPY pyproject.toml uv.lock ./

RUN uv sync --frozen

COPY . .

CMD ["./start.sh"]
