# 🚀 Guía Rápida: Deploy de Mileto en EasyPanel

## Paso a Paso

### 1️⃣ Preparar tus logos (IMPORTANTE)

```bash
# Coloca tus 3 logos SVG en la carpeta public/brand-assets/
cp /ruta/a/logo.svg public/brand-assets/logo.svg
cp /ruta/a/logo_dark.svg public/brand-assets/logo_dark.svg
cp /ruta/a/logo_thumbnail.svg public/brand-assets/logo_thumbnail.svg
```

**Luego edita `Dockerfile.mileto` y descomenta las líneas 29-31:**

```dockerfile
# Cambia de:
# COPY public/brand-assets/logo.svg /app/public/brand-assets/logo.svg
# COPY public/brand-assets/logo_dark.svg /app/public/brand-assets/logo_dark.svg
# COPY public/brand-assets/logo_thumbnail.svg /app/public/brand-assets/logo_thumbnail.svg

# A (sin el #):
COPY public/brand-assets/logo.svg /app/public/brand-assets/logo.svg
COPY public/brand-assets/logo_dark.svg /app/public/brand-assets/logo_dark.svg
COPY public/brand-assets/logo_thumbnail.svg /app/public/brand-assets/logo_thumbnail.svg
```

### 2️⃣ Configurar Docker Hub

1. Crea cuenta en https://hub.docker.com (si no tienes)
2. Crea un repositorio llamado `mileto-chatwoot` (público o privado)
3. Edita `build-and-push.sh` línea 8:
   ```bash
   DOCKER_USERNAME="TU-USUARIO-DOCKERHUB"  # Cambia esto
   ```

### 3️⃣ Buildear y publicar

```bash
# Método fácil: usa el script
./build-and-push.sh

# O manualmente:
docker login
docker build -f Dockerfile.mileto -t tu-usuario/mileto-chatwoot:latest .
docker push tu-usuario/mileto-chatwoot:latest
```

### 4️⃣ Desplegar en EasyPanel

**Opción A: Actualizar el servicio existente**
1. Ve a EasyPanel → Tu app Chatwoot → Settings
2. En "Image", cambia de `chatwoot/chatwoot:latest` a:
   ```
   tu-usuario/mileto-chatwoot:latest
   ```
3. Click "Update" o "Redeploy"

**Opción B: Crear nuevo servicio** (recomendado para testing)
1. EasyPanel → New Service → Docker Image
2. Image: `tu-usuario/mileto-chatwoot:latest`
3. Copia TODAS las variables de entorno de tu Chatwoot actual:
   - DATABASE_URL
   - REDIS_URL
   - SECRET_KEY_BASE
   - FRONTEND_URL
   - etc.
4. Deploy

### 5️⃣ Ejecutar migración (IMPORTANTE)

Después del primer deploy, ve a EasyPanel → Terminal del contenedor y ejecuta:

```bash
bundle exec rails db:migrate
```

Esto actualizará `INSTALLATION_NAME` y `BRAND_NAME` a "Mileto".

### 6️⃣ Verificar

Abre tu URL de Chatwoot y verifica:
- ✅ Login dice "Iniciar sesión en Mileto"
- ✅ Logos son los de Mileto
- ✅ Dashboard dice "Mileto" en lugar de "Chatwoot"

---

## 🔥 Atajos

**Si no tienes logos aún:**
```bash
# Puedes desplegar sin logos, solo con textos cambiados
# Comenta o deja comentadas las líneas de COPY en Dockerfile.mileto (29-31)
```

**Build rápido sin cache:**
```bash
docker build --no-cache -f Dockerfile.mileto -t tu-usuario/mileto-chatwoot:latest .
```

**Ver logs en EasyPanel:**
```
EasyPanel → Tu servicio → Logs
```

---

## ❓ FAQ

**P: ¿Cuánto tarda el build?**
R: 2-5 minutos en la primera vez (descarga imagen base ~1GB)

**P: ¿Cuánto pesa la imagen?**
R: ~1.2GB (similar a Chatwoot oficial)

**P: ¿Necesito pagar Docker Hub?**
R: No, la cuenta gratuita permite 1 repositorio privado o ilimitados públicos

**P: ¿Los datos se pierden al actualizar?**
R: No, si usas la misma base de datos y Redis

**P: ¿Puedo hacer rollback?**
R: Sí, cambia la imagen en EasyPanel a la versión anterior o a `chatwoot/chatwoot:latest`

---

## 📞 Siguiente paso

Lee `MILETO_DEPLOYMENT.md` para más detalles y troubleshooting.
