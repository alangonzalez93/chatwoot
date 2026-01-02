# Deployment de Mileto (Chatwoot Personalizado)

Este documento explica cómo buildear y desplegar la versión personalizada de Chatwoot con branding de Mileto.

## 📋 Pre-requisitos

1. **Docker Desktop** instalado y corriendo
2. **Cuenta en Docker Hub** (crear en https://hub.docker.com)
3. **Logos de Mileto** en formato SVG:
   - `logo.svg` (modo claro)
   - `logo_dark.svg` (modo oscuro)
   - `logo_thumbnail.svg` (favicon)

## 🚀 Paso 1: Preparar los logos

1. Coloca tus logos en la carpeta `public/brand-assets/`:
   ```bash
   cp /ruta/a/tus/logos/logo.svg public/brand-assets/logo.svg
   cp /ruta/a/tus/logos/logo_dark.svg public/brand-assets/logo_dark.svg
   cp /ruta/a/tus/logos/logo_thumbnail.svg public/brand-assets/logo_thumbnail.svg
   ```

2. Descomenta las líneas de logos en `Dockerfile.mileto` (líneas 29-31)

## 🔨 Paso 2: Buildear la imagen

### Opción A: Usando el script automatizado

```bash
# Edita el script y cambia tu usuario de Docker Hub
nano build-and-push.sh
# Cambia: DOCKER_USERNAME="${DOCKER_USERNAME:-tu-usuario-dockerhub}"

# Ejecuta el script
./build-and-push.sh
```

### Opción B: Manualmente

```bash
# 1. Login en Docker Hub
docker login

# 2. Build de la imagen
docker build -f Dockerfile.mileto -t tu-usuario/mileto-chatwoot:latest .

# 3. Etiquetar con fecha (opcional)
docker tag tu-usuario/mileto-chatwoot:latest tu-usuario/mileto-chatwoot:v$(date +%Y%m%d)

# 4. Push a Docker Hub
docker push tu-usuario/mileto-chatwoot:latest
docker push tu-usuario/mileto-chatwoot:v$(date +%Y%m%d)
```

## 📦 Paso 3: Desplegar en EasyPanel

### Método 1: Actualizar la imagen existente

1. Ve a EasyPanel → Tu proyecto Chatwoot → Settings
2. Cambia la imagen de `chatwoot/chatwoot:latest` a `tu-usuario/mileto-chatwoot:latest`
3. Click en "Update" o "Redeploy"

### Método 2: Crear nuevo servicio

1. En EasyPanel, crea un nuevo servicio
2. Selecciona "Docker Image"
3. Usa la imagen: `tu-usuario/mileto-chatwoot:latest`
4. Configura las variables de entorno (copia las de tu instalación actual):
   - `DATABASE_URL`
   - `REDIS_URL`
   - `SECRET_KEY_BASE`
   - Todas las demás variables de Chatwoot

## 🔧 Paso 4: Ejecutar la migración

Después del primer despliegue, ejecuta la migración para actualizar la configuración:

```bash
# En EasyPanel, abre la terminal del contenedor y ejecuta:
bundle exec rails db:migrate
```

O si prefieres, usa Rails console:

```bash
bundle exec rails console

# Ejecuta:
config = InstallationConfig.find_or_create_by(name: 'INSTALLATION_NAME')
config.value = 'Mileto'
config.save!

config = InstallationConfig.find_or_create_by(name: 'BRAND_NAME')
config.value = 'Mileto'
config.save!

GlobalConfig.clear_cache
exit
```

## ✅ Verificación

1. Accede a tu URL de Chatwoot
2. Verifica que:
   - ✅ El título dice "Iniciar sesión en Mileto"
   - ✅ Los logos son los de Mileto
   - ✅ Los textos del dashboard dicen "Mileto"

## 🔄 Actualizar en el futuro

Cuando hagas cambios:

```bash
# 1. Realiza tus cambios en el código
# 2. Rebuild la imagen
docker build -f Dockerfile.mileto -t tu-usuario/mileto-chatwoot:latest .

# 3. Push a Docker Hub
docker push tu-usuario/mileto-chatwoot:latest

# 4. En EasyPanel, haz Redeploy del servicio
```

## 📝 Notas importantes

- **Backups**: Antes de actualizar, haz backup de tu base de datos
- **Versiones**: Usa tags con fecha para poder hacer rollback si es necesario
- **Cache**: Si no ves los cambios, limpia el cache del navegador (Ctrl+Shift+R)
- **Redis**: Puede ser necesario reiniciar Redis para limpiar el cache

## 🆘 Troubleshooting

### Los cambios no se reflejan
```bash
# Limpia el cache de Rails
GlobalConfig.clear_cache

# Reinicia Redis
docker restart redis-container
```

### Error de permisos
```bash
# Verifica que los archivos tienen los permisos correctos
chown -R chatwoot:chatwoot /app
```

### Imagen muy grande
- La imagen base de Chatwoot ya es grande (~1GB)
- Considera usar Docker Hub o un registry privado para almacenarla

## 📞 Soporte

Si tienes problemas:
1. Revisa los logs: `docker logs nombre-contenedor`
2. Verifica variables de entorno
3. Asegúrate que la migración se ejecutó correctamente
