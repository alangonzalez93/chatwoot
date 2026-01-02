#!/bin/bash

# Script para buildear y publicar la imagen personalizada de Mileto en Docker Hub
# Uso: ./build-and-push.sh

set -e

# Configuración
DOCKER_USERNAME="${DOCKER_USERNAME:-alangonzalez93}" 
IMAGE_NAME="mileto-chatwoot"
VERSION="${VERSION:-latest}"
FULL_IMAGE_NAME="${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION}"

echo "🚀 Iniciando build de Mileto Chatwoot..."
echo "📦 Imagen: ${FULL_IMAGE_NAME}"

# Verificar que Docker esté corriendo
if ! docker info > /dev/null 2>&1; then
    echo "❌ Error: Docker no está corriendo"
    exit 1
fi

# Buildear la imagen
echo "🔨 Construyendo imagen Docker..."
docker build \
    -f Dockerfile.mileto \
    -t ${FULL_IMAGE_NAME} \
    -t ${DOCKER_USERNAME}/${IMAGE_NAME}:v$(date +%Y%m%d) \
    .

echo "✅ Build completado exitosamente"

# Preguntar si quiere hacer push
read -p "¿Deseas hacer push a Docker Hub? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🔐 Iniciando sesión en Docker Hub..."
    docker login

    echo "⬆️  Subiendo imagen a Docker Hub..."
    docker push ${FULL_IMAGE_NAME}
    docker push ${DOCKER_USERNAME}/${IMAGE_NAME}:v$(date +%Y%m%d)

    echo "✅ Imagen publicada exitosamente!"
    echo "📍 Puedes usar: ${FULL_IMAGE_NAME}"
else
    echo "ℹ️  Imagen construida localmente. Para subirla manualmente ejecuta:"
    echo "   docker push ${FULL_IMAGE_NAME}"
fi

echo ""
echo "🎉 ¡Proceso completado!"
echo ""
echo "Para usar en EasyPanel, usa esta imagen:"
echo "   ${FULL_IMAGE_NAME}"
