# Opciones de Build para Mileto Chatwoot

## Problema Actual

El build con `Dockerfile.mileto` falló porque la imagen oficial `chatwoot/chatwoot:latest` ya no incluye las herramientas de compilación (Node.js, pnpm). Esto es normal para imágenes de producción optimizadas.

## Soluciones Disponibles

### ✅ Opción 1: Solo Traducciones (RECOMENDADO AHORA)

**Qué incluye:**
- ✅ Todas las traducciones en español e inglés
- ✅ Cambio de "Chatwoot" a "Mileto" en toda la UI
- ✅ Migración de base de datos para branding
- ❌ NO incluye: Colores personalizados, componentes Vue nuevos (Mileto Bot)

**Ventajas:**
- Build rápido (< 1 minuto)
- No requiere recompilación
- Funciona inmediatamente
- Imagen pequeña

**Cómo usar:**
```bash
# Usar el Dockerfile simplificado
docker build -f Dockerfile.mileto.simple -t alangonzalez93/mileto-chatwoot:latest .

# O modificar build-and-push.sh para usar Dockerfile.mileto.simple
```

**Cuándo usar:**
- Para deploy rápido AHORA
- Cuando solo necesitas las traducciones
- Como solución temporal mientras preparas el build completo

---

### 🔧 Opción 2: Build Completo desde Código Fuente (LARGO PLAZO)

**Qué incluye:**
- ✅ Todas las traducciones
- ✅ Colores personalizados de Mileto (gradiente azul-morado)
- ✅ Componentes Vue nuevos (Mileto Bot settings)
- ✅ Estilos CSS personalizados
- ✅ TODO compilado y optimizado

**Ventajas:**
- Control total sobre el build
- Incluye TODAS las personalizaciones
- Versionado específico de Chatwoot

**Desventajas:**
- Build lento (5-15 minutos primera vez)
- Requiere clonar repositorio completo
- Imagen más grande durante el build

**Cómo usar:**
```bash
# Ejecutar el script de build completo
./build-mileto-full.sh

# O especificar versión de Chatwoot
CHATWOOT_VERSION=v3.14.0 ./build-mileto-full.sh
```

**Cuándo usar:**
- Cuando necesites los componentes Vue nuevos (Mileto Bot)
- Para colores y estilos personalizados
- Para deploy de producción a largo plazo

---

### 🏗️ Opción 3: Multi-stage Build (ALTERNATIVA)

**Qué incluye:**
- Todo lo de la Opción 2
- Build optimizado en dos etapas

**Ventajas:**
- Imagen final pequeña (igual que Opción 1)
- Incluye todas las personalizaciones

**Desventajas:**
- Build lento
- Más complejo de mantener

**Estado:** Requiere crear nuevo Dockerfile multi-stage (no implementado aún)

---

## Recomendación

### Para AHORA (Desplegar Hoy):
1. Usa **Opción 1** (Dockerfile.mileto.simple)
2. Esto te da todas las traducciones funcionando
3. El Mileto Bot settings NO estará disponible (pero no tienes el backend aún de todas formas)

### Para DESPUÉS (Cuando tengas el backend de Mileto Bot listo):
1. Usa **Opción 2** (build-mileto-full.sh)
2. Esto incluirá los componentes Vue de Mileto Bot
3. Podrás usar la página de settings completa

---

## Archivos Relacionados

- `Dockerfile.mileto.simple` - Build rápido solo con traducciones
- `Dockerfile.mileto` - Build original (actualmente NO funciona)
- `build-and-push.sh` - Script original de build
- `build-mileto-full.sh` - Script de build completo desde código fuente

---

## Preguntas Frecuentes

### ¿Por qué funcionaba antes y ahora no?
La imagen `chatwoot/chatwoot:latest` cambió. Antes incluía herramientas de desarrollo, ahora no.

### ¿Puedo usar ambas opciones?
Sí. Usa Opción 1 ahora para tener las traducciones, y luego cambia a Opción 2 cuando necesites el Mileto Bot.

### ¿Las traducciones requieren recompilación?
No. Los archivos JSON se cargan dinámicamente en runtime, no se compilan.

### ¿Los componentes Vue requieren recompilación?
Sí. Chatwoot usa Vite que compila los archivos .vue en bundles JavaScript.

### ¿Qué hago con mi deploy actual?
Si ya tienes Mileto desplegado con traducciones, sigue usando esa imagen. Solo necesitas rebuild cuando:
1. Actualices traducciones
2. Agregues nuevos componentes (Mileto Bot)
3. Cambies colores/estilos

---

## Próximos Pasos

1. **Ahora:** Usa Opción 1 para deployment
2. **Corto plazo:** Cuando tengas el backend de Mileto Bot, usa Opción 2
3. **Largo plazo:** Considera mantener tu propio fork de Chatwoot si necesitas muchas personalizaciones
