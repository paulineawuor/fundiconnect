#!/bin/bash

echo "==> Collecting static files..."
mkdir -p staticfiles
python manage.py collectstatic --noinput --clear || echo "WARNING: collectstatic failed, continuing..."

echo "==> Attempting database migrations (with retry)..."
MAX_RETRIES=10
RETRY_DELAY=5
attempt=1

while [ $attempt -le $MAX_RETRIES ]; do
    echo "    Migration attempt $attempt of $MAX_RETRIES..."
    if python manage.py migrate --noinput 2>&1; then
        echo "==> Migrations completed successfully."
        break
    else
        echo "    WARNING: Migration attempt $attempt failed (database may not be ready yet)."
        if [ $attempt -eq $MAX_RETRIES ]; then
            echo "    WARNING: All migration attempts exhausted. Starting server anyway — migrations can be retried later."
        else
            echo "    Retrying in ${RETRY_DELAY}s..."
            sleep $RETRY_DELAY
        fi
    fi
    attempt=$((attempt + 1))
done

echo "==> Starting Daphne ASGI server..."
exec daphne -b 0.0.0.0 -p "${PORT:-8000}" fundiconnect.asgi:application
