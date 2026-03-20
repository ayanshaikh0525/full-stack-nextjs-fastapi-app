#!/bin/bash
set -e

echo "Running migrations..."
python -m alembic upgrade head

echo "Starting FastAPI..."
exec uvicorn app.main:app --host 0.0.0.0 --port 8000
