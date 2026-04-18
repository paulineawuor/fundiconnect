#!/bin/bash
set -e

echo "==> Python version: $(python --version 2>&1)"
echo "==> Working directory: $(pwd)"

echo "==> Running database migrations..."
python -u manage.py migrate --noinput

echo "==> Collecting static files..."
mkdir -p staticfiles
python -u manage.py collectstatic --noinput --clear

echo "==> Pre-flight: verifying Django settings import..."
python -u -c "
import sys, os, traceback
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'fundiconnect.settings')
try:
    import django
    django.setup()
    print('Django setup OK')
except Exception:
    print('ERROR: Django setup failed:', file=sys.stderr)
    traceback.print_exc()
    sys.exit(1)
"

echo "==> Pre-flight: verifying ASGI application import..."
python -u -c "
import sys, os, traceback
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'fundiconnect.settings')
try:
    from fundiconnect.asgi import application
    print('ASGI application import OK:', application)
except Exception:
    print('ERROR: ASGI application import failed:', file=sys.stderr)
    traceback.print_exc()
    sys.exit(1)
"

echo "==> Starting Daphne ASGI server on 0.0.0.0:${PORT:-8000}..."
exec python -u -m daphne \
    --verbosity 2 \
    -b 0.0.0.0 \
    -p "${PORT:-8000}" \
    fundiconnect.asgi:application

