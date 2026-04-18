import logging
import os
import sys
import traceback

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'fundiconnect.settings')

logger = logging.getLogger(__name__)

try:
    from channels.auth import AuthMiddlewareStack
    from channels.routing import ProtocolTypeRouter, URLRouter
    from django.core.asgi import get_asgi_application

    django_asgi_app = get_asgi_application()

    from .routing import websocket_urlpatterns

    application = ProtocolTypeRouter(
        {
            'http': django_asgi_app,
            'websocket': AuthMiddlewareStack(URLRouter(websocket_urlpatterns)),
        }
    )

    logger.info('ASGI application initialised successfully.')

except Exception as _asgi_init_error:
    # Print to stderr immediately so the error appears in Railway logs even if
    # the logging subsystem itself hasn't been configured yet.
    print('CRITICAL: ASGI application failed to initialise:', file=sys.stderr)
    traceback.print_exc(file=sys.stderr)
    sys.stderr.flush()

    # Re-raise so Daphne / the pre-flight check in start.sh sees the failure
    # rather than silently serving nothing.
    raise

