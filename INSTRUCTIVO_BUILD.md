# Instructivo: Build y Deploy de Mileto Chatwoot

Este documento explica cómo compilar y desplegar tu versión personalizada de Chatwoot (Mileto) desde cero.

## Tabla de Contenidos

1. [Requisitos Previos](#requisitos-previos)
2. [Estructura del Proyecto](#estructura-del-proyecto)
3. [Hacer Cambios](#hacer-cambios)
4. [Compilar la Imagen](#compilar-la-imagen)
5. [Subir a Docker Hub](#subir-a-docker-hub)
6. [Desplegar en EasyPanel](#desplegar-en-easypanel)
7. [Troubleshooting](#troubleshooting)

---

## Requisitos Previos

### Software necesario:
- **Docker Desktop** instalado y corriendo
- **Git** instalado
- Cuenta en **Docker Hub** (gratis)
- Acceso a tu servidor **EasyPanel**

### Verificar que Docker está corriendo:
```bash
docker --version
docker info
```

Si ves la versión de Docker y no hay errores, estás listo.

---

## Estructura del Proyecto

Tu proyecto tiene esta estructura:

```
/personal/chatwoot/
├── app/javascript/
│   ├── dashboard/
│   │   ├── i18n/locale/          # Traducciones del dashboard
│   │   │   ├── es/               # Español
│   │   │   │   ├── login.json
│   │   │   │   ├── settings.json
│   │   │   │   ├── miletoBot.json
│   │   │   │   └── ... (más archivos)
│   │   │   └── en/               # Inglés
│   │   │       ├── login.json
│   │   │       └── ... (más archivos)
│   │   ├── api/
│   │   │   └── miletoBot.js      # API del Mileto Bot
│   │   ├── routes/dashboard/settings/
│   │   │   ├── miletobot/        # Componentes Mileto Bot
│   │   │   │   ├── Index.vue
│   │   │   │   ├── Wrapper.vue
│   │   │   │   └── miletobot.routes.js
│   │   │   └── settings.routes.js
│   │   └── assets/scss/
│   │       ├── _mileto-custom.scss  # Estilos personalizados
│   │       └── _woot.scss           # Estilos principales
│   ├── widget/i18n/locale/       # Traducciones del widget
│   │   ├── es.json
│   │   └── en.json
│   └── survey/i18n/locale/       # Traducciones de encuestas
│       └── es.json
├── public/brand-assets/          # Logos de Mileto
│   ├── logo.svg
│   ├── logo_dark.svg
│   └── logo_thumbnail.svg
├── theme/
│   └── colors.js                 # Colores de Mileto
├── db/migrate/
│   └── 20251123131512_update_branding_to_mileto.rb  # Migración
├── build-mileto-full.sh          # Script de build automático
└── INSTRUCTIVO_BUILD.md          # Este archivo
```

---

## Hacer Cambios

### 1. Cambiar Textos (Traducciones)

#### Para el Dashboard (pantalla de administración):

**Español:**
```bash
# Editar archivos en:
app/javascript/dashboard/i18n/locale/es/

# Archivos principales:
- login.json           # Pantalla de login
- settings.json        # Configuración general
- generalSettings.json # Ajustes generales
- miletoBot.json       # Pantalla de Mileto Bot (si aplica)
```

**Inglés:**
```bash
# Editar archivos en:
app/javascript/dashboard/i18n/locale/en/

# Los mismos archivos que español
```

**Formato de los archivos JSON:**
```json
{
  "SECCION": {
    "SUBSECCION": {
      "TITULO": "Texto que ves en la pantalla",
      "DESCRIPCION": "Descripción más larga"
    }
  }
}
```

**Ejemplo real (login.json):**
```json
{
  "LOGIN": {
    "TITLE": "Iniciar sesión en Mileto",
    "SUBMIT": "Iniciar sesión"
  }
}
```

#### Para el Widget (chat que ven tus clientes):

```bash
# Editar:
app/javascript/widget/i18n/locale/es.json  # Español
app/javascript/widget/i18n/locale/en.json  # Inglés
```

**Ejemplo:**
```json
{
  "POWERED_BY": "Desarrollado por Mileto",
  "CHAT_PLACEHOLDER": "Escribe tu mensaje..."
}
```

#### Para Encuestas:

```bash
# Editar:
app/javascript/survey/i18n/locale/es.json
```

---

### 2. Cambiar Logos

Necesitas 3 archivos SVG:

```bash
public/brand-assets/
├── logo.svg           # Logo principal (se ve en la barra superior)
├── logo_dark.svg      # Logo para modo oscuro
└── logo_thumbnail.svg # Logo pequeño (favicon, notificaciones)
```

**Cómo reemplazarlos:**
1. Prepara tus logos en formato SVG
2. Nómbralos exactamente como se indica arriba
3. Cópialos a `public/brand-assets/`

**Recomendaciones:**
- Tamaño recomendado del logo principal: 150-200px de ancho
- Thumbnail: 32x32px o 64x64px
- Usa SVG optimizado (sin código innecesario)

---

### 3. Cambiar Colores

Edita el archivo: `theme/colors.js`

**Busca estas líneas (~213-215):**
```javascript
black: '#000000',
brand: '#1E6FFF',           // Color principal de Mileto (azul)
'brand-secondary': '#8B5CF6', // Color secundario (morado)
```

**Para cambiar los colores:**
1. Reemplaza los códigos hexadecimales (#1E6FFF, #8B5CF6)
2. Puedes usar herramientas como [ColorPicker](https://htmlcolorcodes.com/) para obtener códigos hex

**Cambiar el gradiente de botones:**

Edita: `app/javascript/dashboard/assets/scss/_mileto-custom.scss`

```scss
.bg-gradient-primary {
  background: linear-gradient(135deg, hsl(217 91% 60%), hsl(268 83% 58%));
  /* Cambia estos valores HSL por tus colores */
}
```

---

## Compilar la Imagen

### Método Simple (RECOMENDADO)

Este repositorio YA ES Chatwoot con todas tus personalizaciones. Solo necesitas compilarlo:

```bash
# 1. Dar permisos de ejecución (solo la primera vez)
chmod +x build-mileto-full.sh

# 2. Ejecutar el build
./build-mileto-full.sh
```

**¿Qué hace este script?**
1. Verifica que tus personalizaciones estén presentes
2. Compila todo usando Docker (tarda 10-20 minutos)
3. Crea la imagen con tags: `latest` y `v20251127` (fecha de hoy)
4. Te pregunta si querés subirla a Docker Hub

**Ver el progreso:**

El build puede tardar 10-20 minutos. Verás mensajes como:
```
🚀 Iniciando build de Mileto Chatwoot...
📋 Verificando personalizaciones de Mileto...
✅ Personalizaciones verificadas
🔨 Construyendo imagen Docker (esto puede tardar varios minutos)...
```

**Mientras compila, verás:**
```
#1 [pre-builder 2/15] RUN apk update && apk add...
#2 [stage-1 3/7] RUN if [ "production" != "production" ]...
...
```

No te preocupes, es normal. Docker está instalando dependencias y compilando los assets.

### Método Manual (Si querés más control)

Si preferís hacerlo paso a paso:

```bash
# Buildear directamente desde este directorio
docker build \
    -f docker/Dockerfile \
    -t alangonzalez93/mileto-chatwoot:latest \
    -t alangonzalez93/mileto-chatwoot:v$(date +%Y%m%d) \
    .
```

Eso es todo. No necesitás clonar nada ni copiar archivos porque este repo ya tiene todo.

---

## Subir a Docker Hub

### 1. Iniciar sesión en Docker Hub

```bash
docker login
```

Te pedirá:
- **Username:** tu usuario de Docker Hub (ej: `alangonzalez93`)
- **Password:** tu contraseña

### 2. Verificar que la imagen se creó correctamente

```bash
docker images | grep mileto-chatwoot
```

Deberías ver algo como:
```
alangonzalez93/mileto-chatwoot   latest      abc123def456   5 minutes ago   1.2GB
alangonzalez93/mileto-chatwoot   v20251127   abc123def456   5 minutes ago   1.2GB
```

### 3. Hacer push a Docker Hub

```bash
# Push con tag "latest"
docker push alangonzalez93/mileto-chatwoot:latest

# Push con tag de fecha (ej: v20251127)
docker push alangonzalez93/mileto-chatwoot:v$(date +%Y%m%d)
```

**Esto puede tardar 10-15 minutos** dependiendo de tu conexión a internet (la imagen pesa ~1GB).

Verás algo como:
```
The push refers to repository [docker.io/alangonzalez93/mileto-chatwoot]
abc123: Pushed
def456: Pushed
...
latest: digest: sha256:... size: 1234
```

### 4. Verificar en Docker Hub

1. Ve a https://hub.docker.com
2. Inicia sesión
3. Ve a "Repositories"
4. Deberías ver `mileto-chatwoot` con las tags `latest` y `v20251127`

---

## Desplegar en EasyPanel

### Opción A: Actualizar Deployment Existente

Si ya tienes Mileto desplegado:

1. Ve a EasyPanel
2. Encuentra tu aplicación "Mileto Chatwoot"
3. Ve a la pestaña "General" o "Docker"
4. Cambia la imagen a: `alangonzalez93/mileto-chatwoot:latest`
5. Guarda cambios
6. Reinicia el servicio

**IMPORTANTE:** Tus datos (base de datos, Redis) NO se pierden porque están en contenedores separados.

### Opción B: Deploy Nuevo

1. En EasyPanel, crea un nuevo servicio
2. Selecciona "Docker Image"
3. Imagen: `alangonzalez93/mileto-chatwoot:latest`
4. Configura las variables de entorno (igual que la instalación original de Chatwoot)
5. Despliega

### Variables de Entorno Importantes

```bash
# Base de datos
DATABASE_URL=postgresql://usuario:password@postgres:5432/chatwoot

# Redis
REDIS_URL=redis://redis:6379

# Rails
RAILS_ENV=production
SECRET_KEY_BASE=tu_secret_key_aqui

# Frontend
FRONTEND_URL=https://tu-dominio.com
```

### Aplicar la Migración de Base de Datos

**Solo la primera vez** después de desplegar:

```bash
# Conectarte al contenedor
docker exec -it nombre-del-contenedor bash

# O en EasyPanel, usar la consola web

# Ejecutar migración
bundle exec rails db:migrate

# O actualizar directamente en Rails console:
bundle exec rails console

# Dentro de la consola:
config = InstallationConfig.find_or_create_by(name: 'INSTALLATION_NAME')
config.value = 'Mileto'
config.locked = true
config.save!

config = InstallationConfig.find_or_create_by(name: 'BRAND_NAME')
config.value = 'Mileto'
config.locked = true
config.save!

GlobalConfig.clear_cache
exit
```

---

## Troubleshooting

### Problema: "Docker no está corriendo"

**Error:**
```
Cannot connect to the Docker daemon
```

**Solución:**
1. Abre Docker Desktop
2. Espera a que inicie completamente
3. Vuelve a intentar

### Problema: "Build falla por falta de espacio"

**Error:**
```
no space left on device
```

**Solución:**
```bash
# Limpiar imágenes viejas
docker system prune -a

# Esto libera espacio eliminando:
# - Imágenes no usadas
# - Contenedores detenidos
# - Cachés de build
```

### Problema: "No veo las traducciones después de desplegar"

**Posibles causas:**
1. Estás usando la imagen vieja

**Solución:**
```bash
# Verificar qué imagen estás usando
docker ps

# Forzar pull de la nueva imagen
docker pull alangonzalez93/mileto-chatwoot:latest

# Reiniciar contenedor
docker restart nombre-del-contenedor
```

2. No aplicaste la migración de base de datos

**Solución:**
```bash
# Ver sección "Aplicar la Migración" arriba
```

### Problema: "Build tarda mucho (más de 30 minutos)"

**Esto es normal la primera vez** porque Docker tiene que:
- Descargar imágenes base
- Instalar Node.js, Ruby, PostgreSQL, etc.
- Compilar assets con Vite

**Builds subsecuentes serán más rápidos** gracias al caché de Docker.

### Problema: "Error al hacer push a Docker Hub"

**Error:**
```
denied: requested access to the resource is denied
```

**Solución:**
1. Verifica que hiciste login: `docker login`
2. Verifica que el nombre de la imagen coincide con tu username de Docker Hub
3. Cambia el username en el script si es necesario:

```bash
# En build-mileto-full.sh, línea 11:
DOCKER_USERNAME="tu_usuario_dockerhub"
```

### Problema: "Los logos no aparecen"

**Posibles causas:**
1. Los archivos SVG están corruptos
2. Los nombres no coinciden exactamente

**Solución:**
1. Verifica que los archivos SVG son válidos (ábrelos en un navegador)
2. Verifica los nombres exactos:
   - `logo.svg` (sin mayúsculas, sin espacios)
   - `logo_dark.svg`
   - `logo_thumbnail.svg`
3. Reconstruye la imagen

### Problema: "Los colores no cambiaron"

**Causa:** El navegador tiene caché

**Solución:**
1. Abre tu Mileto en el navegador
2. Presiona `Ctrl + Shift + R` (Windows/Linux) o `Cmd + Shift + R` (Mac)
3. Esto recarga sin caché

---

## Resumen del Flujo Completo

```bash
# 1. Hacer cambios
# Edita traducciones, logos, colores, etc.

# 2. Verificar Docker
docker info

# 3. Compilar
./build-mileto-full.sh

# Esperar 10-20 minutos mientras compila...

# 4. Login a Docker Hub
docker login

# 5. Push
docker push alangonzalez93/mileto-chatwoot:latest
docker push alangonzalez93/mileto-chatwoot:v$(date +%Y%m%d)

# 6. En EasyPanel
# - Actualizar imagen a: alangonzalez93/mileto-chatwoot:latest
# - Reiniciar servicio

# 7. Verificar
# Abrir Mileto en el navegador y revisar cambios
```

---

## Comandos Útiles

### Ver logs del build en tiempo real:
```bash
# Si ejecutaste el script en background
docker ps  # Ver contenedores corriendo
docker logs -f <container_id>
```

### Ver imágenes locales:
```bash
docker images
```

### Eliminar imagen local (para liberar espacio):
```bash
docker rmi alangonzalez93/mileto-chatwoot:v20251126
```

### Ver tags disponibles en Docker Hub:
```bash
# En el navegador:
https://hub.docker.com/r/alangonzalez93/mileto-chatwoot/tags
```

### Probar la imagen localmente antes de subir:
```bash
docker run -p 3000:3000 \
  -e DATABASE_URL=postgresql://... \
  -e REDIS_URL=redis://... \
  -e RAILS_ENV=production \
  -e SECRET_KEY_BASE=test123 \
  alangonzalez93/mileto-chatwoot:latest
```

---

## Versionado de Imágenes

El script crea 2 tags automáticamente:

1. **`latest`**: Siempre apunta a la última versión
   - Usa este en producción si quieres actualizaciones automáticas

2. **`v20251127`**: Tag con fecha (YYYYMMDD)
   - Usa este si quieres controlar exactamente qué versión estás usando
   - Útil para rollbacks

### Hacer rollback a una versión anterior:

```bash
# En EasyPanel, cambia la imagen a:
alangonzalez93/mileto-chatwoot:v20251126  # Versión de ayer
```

---

## Notas Finales

- **Tiempo total del proceso:** ~30-45 minutos (incluyendo build y push)
- **Frecuencia recomendada:** Solo cuando hagas cambios importantes
- **Backups:** EasyPanel maneja backups de tu base de datos automáticamente
- **Costos:** Docker Hub es gratis para repositorios públicos

**¿Dudas?** Revisa la sección de Troubleshooting o consulta los logs de Docker.

---

## Changelog de Personalizaciones

### Versión v20251127
- ✅ Traducciones completas (ES/EN)
- ✅ Logos de Mileto (3 archivos SVG)
- ✅ Colores de marca (gradiente azul-morado)
- ✅ Componente Mileto Bot en Settings
- ✅ Migración de base de datos para branding

### Archivos Personalizados Total:
- **Traducciones:** ~80 archivos JSON (ES/EN)
- **Traducciones de emails:** 2 archivos YML (devise.es.yml, devise.en.yml)
- **Templates de emails:** 4 archivos ERB (reset_password, confirmation, password_change, unlock)
- **Componentes Vue:** 2 archivos (Index.vue, Wrapper.vue)
- **API:** 1 archivo (miletoBot.js)
- **Rutas:** 2 archivos (miletobot.routes.js, settings.routes.js)
- **Estilos:** 2 archivos SCSS
- **Colores:** 1 archivo JS
- **Logos:** 3 archivos SVG
- **Migración:** 1 archivo Ruby

**Total:** ~96 archivos personalizados sobre Chatwoot base
