#!/bin/bash

# Script para verificar que todo está listo antes del build
# Uso: ./pre-build-check.sh

echo "🔍 Verificando configuración pre-build de Mileto..."
echo ""

ERRORS=0
WARNINGS=0

# Verificar Docker
if command -v docker &> /dev/null; then
    echo "✅ Docker instalado"
    if docker info > /dev/null 2>&1; then
        echo "✅ Docker corriendo"
    else
        echo "❌ Docker no está corriendo - inicia Docker Desktop"
        ERRORS=$((ERRORS + 1))
    fi
else
    echo "❌ Docker no instalado - instálalo desde https://docker.com"
    ERRORS=$((ERRORS + 1))
fi

echo ""

# Verificar archivos necesarios
echo "📁 Verificando archivos..."

required_files=(
    "Dockerfile.mileto"
    "build-and-push.sh"
    "db/migrate/20251123131512_update_branding_to_mileto.rb"
    "app/javascript/dashboard/i18n/locale/es/login.json"
    "app/javascript/dashboard/i18n/locale/en/login.json"
)

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file"
    else
        echo "❌ $file NO ENCONTRADO"
        ERRORS=$((ERRORS + 1))
    fi
done

echo ""

# Verificar logos
echo "🎨 Verificando logos..."

logo_files=(
    "public/brand-assets/logo.svg"
    "public/brand-assets/logo_dark.svg"
    "public/brand-assets/logo_thumbnail.svg"
)

LOGOS_FOUND=0
for logo in "${logo_files[@]}"; do
    if [ -f "$logo" ]; then
        # Verificar tamaño del archivo
        size=$(stat -f%z "$logo" 2>/dev/null || stat -c%s "$logo" 2>/dev/null)
        if [ "$size" -gt 1000 ]; then
            echo "✅ $logo (${size} bytes)"
            LOGOS_FOUND=$((LOGOS_FOUND + 1))
        else
            echo "⚠️  $logo existe pero parece vacío o muy pequeño"
            WARNINGS=$((WARNINGS + 1))
        fi
    else
        echo "⚠️  $logo NO ENCONTRADO - usando logo de Chatwoot por defecto"
        WARNINGS=$((WARNINGS + 1))
    fi
done

echo ""

# Verificar configuración en Dockerfile.mileto
echo "⚙️  Verificando Dockerfile.mileto..."

if grep -q "^COPY public/brand-assets/logo.svg" Dockerfile.mileto; then
    if [ $LOGOS_FOUND -eq 3 ]; then
        echo "✅ Logos configurados en Dockerfile y archivos presentes"
    else
        echo "⚠️  Logos configurados en Dockerfile pero faltan archivos"
        echo "   Comenta las líneas de COPY en Dockerfile.mileto si no tienes logos aún"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    if [ $LOGOS_FOUND -gt 0 ]; then
        echo "⚠️  Tienes logos pero no están configurados en Dockerfile.mileto"
        echo "   Descomenta las líneas 29-31 en Dockerfile.mileto"
        WARNINGS=$((WARNINGS + 1))
    else
        echo "ℹ️  Logos no configurados (se usarán los de Chatwoot por defecto)"
    fi
fi

echo ""

# Verificar configuración de Docker Hub en script
echo "🐳 Verificando configuración Docker Hub..."

if grep -q "tu-usuario-dockerhub" build-and-push.sh; then
    echo "⚠️  Necesitas cambiar 'tu-usuario-dockerhub' en build-and-push.sh"
    echo "   Edita la línea 8 con tu usuario real de Docker Hub"
    WARNINGS=$((WARNINGS + 1))
else
    echo "✅ Usuario de Docker Hub configurado"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Resumen
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo "✅ ¡Todo listo para buildear!"
    echo ""
    echo "Siguiente paso:"
    echo "   ./build-and-push.sh"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo "⚠️  Puedes continuar pero hay $WARNINGS advertencia(s)"
    echo ""
    echo "Revisa las advertencias arriba antes de continuar."
    echo "Si está todo bien, ejecuta:"
    echo "   ./build-and-push.sh"
    exit 0
else
    echo "❌ Encontrados $ERRORS error(es) y $WARNINGS advertencia(s)"
    echo ""
    echo "Corrige los errores antes de continuar."
    exit 1
fi
