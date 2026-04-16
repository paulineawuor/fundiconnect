import os
from channels.auth import AuthMiddlewareStack
from channels.routing import ProtocolTypeRouter, URLRouter
from django.core.asgi import get_asgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'fundiconnect.settings')

django_asgi_app = get_asgi_application()

from .routing import websocket_urlpatterns

application = ProtocolTypeRouter(
    {
        'http': django_asgi_app,
        'websocket': AuthMiddlewareStack(URLRouter(websocket_urlpatterns)),
    }
)

# Wrap with WhiteNoise for static file serving under ASGI
try:
    from whitenoise import WhiteNoise
    from django.conf import settings as _settings
    application = WhiteNoise(application, root=str(_settings.STATIC_ROOT), prefix='static')
except Exception:
    pass
