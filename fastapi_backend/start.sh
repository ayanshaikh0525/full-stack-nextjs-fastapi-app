#!/bin/bash
set -e

echo "PATH=$PATH"
which python
ls /app/.venv/bin | grep alembic

echo "Running migrations..."
/app/.venv/bin/python -m alembic upgrade head

echo "Starting FastAPI..."
exec /app/.venv/bin/uvicorn app.main:app --host 0.0.0.0 --port 8000
