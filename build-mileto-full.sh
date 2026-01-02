#!/bin/bash

# Script para buildear Mileto Chatwoot directamente desde este repositorio
# Este repo YA ES Chatwoot con tus personalizaciones aplicadas

set -e

echo "🚀 Iniciando build de Mileto Chatwoot..."

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

# Verificar que existen las personalizaciones clave
if [ ! -f "app/javascript/dashboard/i18n/locale/es/login.json" ]; then
    echo "⚠️  Advertencia: No se encuentran traducciones en español"
fi

if [ ! -f "public/brand-assets/logo.svg" ]; then
    echo "⚠️  Advertencia: No se encuentran logos de Mileto"
fi

if [ ! -f "theme/colors.js" ]; then
    echo "⚠️  Advertencia: No se encuentra el archivo de colores"
fi

echo "✅ Personalizaciones verificadas"

# Buildear usando el Dockerfile oficial de Chatwoot
echo "🔨 Construyendo imagen Docker (esto puede tardar varios minutos)..."
docker build \
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
echo "Para usar en EasyPanel, usa esta imagen:"
echo "   ${FULL_IMAGE_NAME}"
