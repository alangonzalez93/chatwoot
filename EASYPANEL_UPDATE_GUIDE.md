# 🔄 Guía: Actualizar Chatwoot Template en EasyPanel a Mileto

## Situación Actual

Tienes instalado el template de Chatwoot que incluye múltiples servicios:

```
📦 chatwoot-project (tu proyecto en EasyPanel)
  ├─ 🐘 PostgreSQL
  ├─ 🔴 Redis
  ├─ 🌐 Chatwoot Web (Rails)
  ├─ ⚙️  Chatwoot Sidekiq (workers)
  └─ 📧 Mailhog (opcional)
```

## ✅ Cómo Actualizar SIN perder nada

### Opción A: Actualizar solo el servicio Web (RECOMENDADO)

#### 1. Identificar tus servicios actuales

En EasyPanel → Tu proyecto Chatwoot, verás algo como:

```
Services:
- chatwoot-db (PostgreSQL)
- chatwoot-redis (Redis)
- chatwoot-web (Rails) ← Este es el que vamos a cambiar
- chatwoot-worker (Sidekiq) ← Este también
```

#### 2. Actualizar Chatwoot Web

```bash
# En EasyPanel:
1. Click en "chatwoot-web" (o como se llame el servicio web)
2. Settings → Image
3. Cambiar de:
   chatwoot/chatwoot:latest
   A:
   alangonzalez93/mileto-chatwoot:latest
4. Click "Update" o "Deploy"
5. Esperar que reinicie (1-2 minutos)
```

#### 3. Actualizar Chatwoot Sidekiq/Worker

```bash
# En EasyPanel:
1. Click en "chatwoot-worker" (o similar)
2. Settings → Image
3. Cambiar de:
   chatwoot/chatwoot:latest
   A:
   alangonzalez93/mileto-chatwoot:latest
4. Click "Update" o "Deploy"
```

#### 4. PostgreSQL y Redis

**NO TOCAR** - Estos siguen funcionando igual

#### 5. Ejecutar migración

Desde la terminal del servicio `chatwoot-web`:

```bash
bundle exec rails db:migrate
```

### Resultado

```
📦 chatwoot-project
  ├─ 🐘 PostgreSQL (sin cambios)
  ├─ 🔴 Redis (sin cambios)
  ├─ 🌐 Mileto Web ← Actualizado ✅
  ├─ ⚙️  Mileto Sidekiq ← Actualizado ✅
  └─ 📧 Mailhog (sin cambios)
```

---

## 🧪 Opción B: Crear stack paralelo para testing (MÁS SEGURO)

Si quieres estar 100% seguro antes de cambiar producción:

### 1. Duplicar solo los servicios de aplicación

```bash
# En EasyPanel → Tu proyecto

# Crear nuevo servicio: mileto-web-test
Type: Docker Image
Image: alangonzalez93/mileto-chatwoot:latest
Port: 3001
Command: bundle exec rails s -p 3000 -b 0.0.0.0

# Variables de entorno: COPIAR EXACTAMENTE las del chatwoot-web original
# IMPORTANTE: Usar los MISMOS valores para:
- DATABASE_URL → mismo PostgreSQL ✅
- REDIS_URL → mismo Redis ✅
- SECRET_KEY_BASE → mismo valor ✅
```

### 2. Crear worker de testing

```bash
# Crear nuevo servicio: mileto-worker-test
Type: Docker Image
Image: alangonzalez93/mileto-chatwoot:latest
Command: bundle exec sidekiq -C config/sidekiq.yml

# Variables de entorno: COPIAR del chatwoot-worker original
```

### 3. Probar

```bash
# Accede a mileto-web-test
# Verifica que todo funciona
# Si está OK → elimina chatwoot-web y chatwoot-worker
# Renombra mileto-web-test → chatwoot-web
```

---

## 📋 Checklist de Variables de Entorno

Asegúrate de que estos servicios tengan las MISMAS variables:

### Variables críticas (deben ser IDÉNTICAS):

```bash
# Base de datos
DATABASE_URL=postgresql://user:pass@postgres-host:5432/chatwoot
POSTGRES_HOST=chatwoot-db (o el nombre de tu servicio PostgreSQL)
POSTGRES_USERNAME=postgres
POSTGRES_PASSWORD=tu-password
POSTGRES_DATABASE=chatwoot

# Redis
REDIS_URL=redis://chatwoot-redis:6379
REDIS_HOST=chatwoot-redis

# Aplicación
SECRET_KEY_BASE=el-mismo-valor-largo-hex
FRONTEND_URL=https://tu-dominio.com

# Rails
RAILS_ENV=production
NODE_ENV=production
```

### Variables opcionales (pueden ser diferentes):

```bash
# Logging
RAILS_LOG_TO_STDOUT=true

# Email (solo en web, no en worker)
MAILER_SENDER_EMAIL=noreply@mileto.com
SMTP_ADDRESS=smtp.gmail.com
# etc.
```

---

## 🔍 Cómo encontrar los nombres exactos de tus servicios

### En EasyPanel:

```bash
1. Ve a tu proyecto Chatwoot
2. En la sección "Services" verás todos los contenedores
3. Anota los nombres exactos, por ejemplo:
   - chatwoot-db-1
   - chatwoot-redis-1
   - chatwoot-rails-1 ← Este es el web
   - chatwoot-sidekiq-1 ← Este es el worker
```

### Comandos importantes según el tipo de servicio:

```bash
# Web/Rails (puerto 3000)
Command: bundle exec rails s -p 3000 -b 0.0.0.0
Entrypoint: docker/entrypoints/rails.sh

# Sidekiq/Worker
Command: bundle exec sidekiq -C config/sidekiq.yml
```

---

## ⚠️ Errores Comunes y Soluciones

### Error: "Can't connect to database"

```bash
Problema: DATABASE_URL apunta al servicio viejo
Solución: Verifica que DATABASE_URL use el nombre correcto del servicio PostgreSQL

# Ejemplo correcto:
DATABASE_URL=postgresql://postgres:password@chatwoot-db:5432/chatwoot
                                          ^^^^^^^^^^^
                                          Nombre del servicio PostgreSQL
```

### Error: "Redis connection failed"

```bash
Problema: REDIS_URL apunta al servicio viejo
Solución: Verifica el nombre del servicio Redis

# Ejemplo correcto:
REDIS_URL=redis://chatwoot-redis:6379
                  ^^^^^^^^^^^^^^
                  Nombre del servicio Redis
```

### Error: "Jobs not processing"

```bash
Problema: Sidekiq no se actualizó
Solución: Actualiza AMBOS servicios (web Y worker) a la misma imagen
```

---

## 🎯 Plan Recomendado para Ti

### Día 1: Preparación

```bash
1. Hacer backup de variables de entorno
   - Copia TODAS las variables de chatwoot-web
   - Copia TODAS las variables de chatwoot-worker
   - Guárdalas en un archivo de texto

2. Build y publicar imagen
   ./build-and-push.sh

3. Verificar en Docker Hub
   https://hub.docker.com/r/alangonzalez93/mileto-chatwoot
```

### Día 2: Testing (Opción Conservadora)

```bash
1. Crear servicios paralelos:
   - mileto-web-test (puerto 3001)
   - mileto-worker-test

2. Usar MISMOS PostgreSQL y Redis

3. Probar todo:
   - Login
   - Conversaciones
   - Envío de mensajes
   - Jobs en background

4. Si funciona → migrar a producción
```

### Día 2 Alternativo: Update directo (Opción Rápida)

```bash
1. Actualizar chatwoot-web:
   Image → alangonzalez93/mileto-chatwoot:latest

2. Actualizar chatwoot-worker:
   Image → alangonzalez93/mileto-chatwoot:latest

3. Ejecutar migración:
   bundle exec rails db:migrate

4. Verificar que todo funciona
```

---

## 🆘 Rollback de Emergencia

Si algo sale mal:

```bash
1. EasyPanel → chatwoot-web → Settings → Image
   Cambiar a: chatwoot/chatwoot:latest

2. EasyPanel → chatwoot-worker → Settings → Image
   Cambiar a: chatwoot/chatwoot:latest

3. Deploy/Restart

Todo vuelve a la normalidad en 2-3 minutos
```

---

## ✅ Verificación Final

Después de actualizar, verifica:

- [ ] Web funciona: https://tu-dominio.com
- [ ] Login dice "Iniciar sesión en Mileto"
- [ ] Conversaciones cargan correctamente
- [ ] Puedes enviar/recibir mensajes
- [ ] Sidekiq procesa jobs (ver logs)
- [ ] No hay errores en logs de web ni worker

---

## 📞 Necesitas ayuda?

Si tienes dudas:
1. Revisa los logs: EasyPanel → Servicio → Logs
2. Verifica variables de entorno
3. Compara con configuración original
