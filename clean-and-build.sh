#!/bin/bash

set -e

echo "🧹 Limpiando cache de Docker y builds anteriores..."

# Configuración
DOCKER_USERNAME="${DOCKER_USERNAME:-alangonzalez93}"
IMAGE_NAME="mileto-chatwoot"
VERSION="${VERSION:-latest}"
FULL_IMAGE_NAME="${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION}"

# 1. Limpiar imagenes antiguas locales
echo "🗑️  Eliminando imagenes locales antiguas..."
docker rmi -f ${FULL_IMAGE_NAME} 2>/dev/null || true
docker rmi -f ${DOCKER_USERNAME}/${IMAGE_NAME}:v$(date +%Y%m%d) 2>/dev/null || true

# 2. Limpiar cache de build de Docker
echo "🧽 Limpiando cache de Docker build..."
docker builder prune -f

# 3. Limpiar node_modules y builds de JS (opcional pero recomendado)
echo "🧹 Limpiando node_modules y builds locales..."
rm -rf node_modules/.cache 2>/dev/null || true
rm -rf public/packs 2>/dev/null || true
rm -rf tmp/cache 2>/dev/null || true

echo ""
echo "✅ Limpieza completa!"
echo ""
echo "🚀 Iniciando build limpio de Mileto Chatwoot..."
echo ""

# 4. Build sin cache
docker build \
    --no-cache \
    -f docker/Dockerfile \
    -t ${FULL_IMAGE_NAME} \
    -t ${DOCKER_USERNAME}/${IMAGE_NAME}:v$(date +%Y%m%d) \
    .

echo ""
echo "✅ Build completo exitosamente (sin cache)"
echo ""

# 5. Push automático
echo "🔐 Verificando sesión en Docker Hub..."
docker login

echo "⬆️  Subiendo imagen a Docker Hub..."
docker push ${FULL_IMAGE_NAME}
docker push ${DOCKER_USERNAME}/${IMAGE_NAME}:v$(date +%Y%m%d)

echo ""
echo "✅ Imagen publicada exitosamente!"
echo "📍 Imagen disponible en: ${FULL_IMAGE_NAME}"
echo ""
echo "🎉 ¡Proceso completado con build limpio!"
echo ""
echo "⚠️  IMPORTANTE: En EasyPanel, asegúrate de:"
echo "   1. Hacer PULL de la nueva imagen"
echo "   2. REINICIAR completamente el contenedor"
echo "   3. Verificar que la variable MILETO_API_KEY esté configurada"
