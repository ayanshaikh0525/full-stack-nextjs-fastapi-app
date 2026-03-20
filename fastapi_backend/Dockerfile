# ----------- Builder Stage -----------

FROM python:3.12-slim-bookworm AS builder

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates

ADD https://astral.sh/uv/install.sh /uv-installer.sh
RUN sh /uv-installer.sh && rm /uv-installer.sh

ENV PATH="/root/.local/bin:$PATH"

# MUST be before uv commands
ENV UV_SYSTEM_PYTHON=1

COPY pyproject.toml uv.lock ./

# remove any old venv just in case
RUN rm -rf /app/.venv

# create fresh venv using system python
RUN uv venv /app/.venv

# install deps into that venv
RUN uv sync --frozen

# ----------- Runtime Stage -----------
FROM python:3.12-slim-bookworm

WORKDIR /app

COPY --from=builder /app/.venv /app/.venv

ENV PATH="/app/.venv/bin:$PATH"

COPY . .

RUN chmod +x start.sh

CMD ["./start.sh"]
