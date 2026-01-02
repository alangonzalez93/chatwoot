#!/bin/bash

set -e

echo "🧹 Limpiando SOLO cache de Mileto Chatwoot..."

# Configuración
DOCKER_USERNAME="${DOCKER_USERNAME:-alangonzalez93}"
IMAGE_NAME="mileto-chatwoot"
VERSION="${VERSION:-latest}"
FULL_IMAGE_NAME="${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION}"

# 1. Limpiar SOLO imagenes de mileto-chatwoot locales
echo "🗑️  Eliminando imagenes de mileto-chatwoot locales..."
docker images | grep "mileto-chatwoot" | awk '{print $3}' | xargs docker rmi -f 2>/dev/null || true

# 2. Limpiar cache de node local (sin tocar Docker cache global)
echo "🧹 Limpiando cache local de node..."
rm -rf node_modules/.cache 2>/dev/null || true
rm -rf public/packs 2>/dev/null || true
rm -rf tmp/cache 2>/dev/null || true

echo ""
echo "✅ Limpieza conservadora completa!"
echo ""
echo "🚀 Iniciando build de Mileto Chatwoot con --no-cache..."
echo ""

# 3. Build sin cache (pero Docker puede usar cache de otras imagenes base)
docker build \
    --no-cache \
    -f docker/Dockerfile \
    -t ${FULL_IMAGE_NAME} \
    -t ${DOCKER_USERNAME}/${IMAGE_NAME}:v$(date +%Y%m%d) \
    .

echo ""
echo "✅ Build completo exitosamente"
echo ""

# 4. Push automático
echo "🔐 Verificando sesión en Docker Hub..."
docker login

echo "⬆️  Subiendo imagen a Docker Hub..."
docker push ${FULL_IMAGE_NAME}
docker push ${DOCKER_USERNAME}/${IMAGE_NAME}:v$(date +%Y%m%d)

echo ""
echo "✅ Imagen publicada exitosamente!"
echo "📍 Imagen disponible en: ${FULL_IMAGE_NAME}"
echo ""
echo "🎉 ¡Build limpio completado!"
