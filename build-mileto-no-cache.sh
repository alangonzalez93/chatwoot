#!/bin/bash

# Script para buildear Mileto Chatwoot SIN CACHE
# Usar solo cuando necesites un build 100% limpio

set -e

echo "🚀 Iniciando build LIMPIO de Mileto Chatwoot (sin cache)..."

# Configuración
DOCKER_USERNAME="${DOCKER_USERNAME:-alangonzalez93}"
IMAGE_NAME="mileto-chatwoot"
VERSION="${VERSION:-latest}"
FULL_IMAGE_NAME="${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION}"

# Verificar que estamos en el directorio correcto
if [ ! -f "docker/Dockerfile" ]; then
    echo "❌ Error: No se encuentra docker/Dockerfile"
    echo "Asegúrate de ejecutar este script desde la raíz del repositorio de Chatwoot"
    exit 1
fi

echo "📋 Verificando personalizaciones de Mileto..."

# Verificar archivos clave
if [ ! -f "app/controllers/api/v1/accounts/mileto_bot_controller.rb" ]; then
    echo "⚠️  Advertencia: No se encuentra el controller de Mileto Bot"
fi

echo "✅ Personalizaciones verificadas"

# Buildear SIN CACHE usando el Dockerfile oficial de Chatwoot
echo "🔨 Construyendo imagen Docker SIN CACHE (esto tardará más tiempo)..."
docker build \
    --no-cache \
    -f docker/Dockerfile \
    -t ${FULL_IMAGE_NAME} \
    -t ${DOCKER_USERNAME}/${IMAGE_NAME}:v$(date +%Y%m%d) \
    .

echo ""
echo "✅ Build completo exitosamente"
echo ""

# Push automático a Docker Hub
echo "🔐 Verificando sesión en Docker Hub..."
docker login

echo "⬆️  Subiendo imagen a Docker Hub..."
docker push ${FULL_IMAGE_NAME}
docker push ${DOCKER_USERNAME}/${IMAGE_NAME}:v$(date +%Y%m%d)

echo ""
echo "✅ Imagen publicada exitosamente!"
echo "📍 Imagen disponible en: ${FULL_IMAGE_NAME}"
echo ""
echo "🎉 ¡Proceso completado!"
echo ""
echo "Para usar en EasyPanel:"
echo "   1. Imagen: ${FULL_IMAGE_NAME}"
echo "   2. Asegúrate de configurar MILETO_API_KEY en las variables de entorno"
echo "   3. Reinicia completamente el contenedor después del pull"
