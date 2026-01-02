#!/bin/bash

set -e

echo "🧹 Limpiando cache de Mileto Chatwoot..."

# Configuración
DOCKER_USERNAME="${DOCKER_USERNAME:-alangonzalez93}"
IMAGE_NAME="mileto-chatwoot"

# 1. Limpiar SOLO imagenes de mileto-chatwoot locales
echo "🗑️  Eliminando imagenes de mileto-chatwoot locales..."
docker images | grep "${IMAGE_NAME}" | awk '{print $3}' | xargs docker rmi -f 2>/dev/null || echo "No hay imágenes locales de ${IMAGE_NAME}"

# 2. Limpiar cache de node local
echo "🧹 Limpiando cache local de node..."
rm -rf node_modules/.cache 2>/dev/null || true
rm -rf public/packs 2>/dev/null || true
rm -rf tmp/cache 2>/dev/null || true

echo ""
echo "✅ Cache limpiado!"
echo ""
echo "Ahora podés ejecutar:"
echo "  ./build-mileto-full.sh          (build normal con cache)"
echo "  ./build-mileto-no-cache.sh      (build limpio sin cache)"
