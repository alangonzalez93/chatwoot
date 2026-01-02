# ✅ Checklist: Verificar configuración actual en EasyPanel

## Paso 1: Identificar tus servicios

Ve a EasyPanel → Tu proyecto Chatwoot y anota los nombres:

```
Mis servicios actuales:
[ ] PostgreSQL: _____________________ (ej: chatwoot-db)
[ ] Redis: _____________________ (ej: chatwoot-redis)
[ ] Web/Rails: _____________________ (ej: chatwoot-web)
[ ] Sidekiq/Worker: _____________________ (ej: chatwoot-worker)
[ ] Otros: _____________________
```

## Paso 2: Copiar variables de entorno del servicio Web

En EasyPanel → Servicio Web → Settings → Environment Variables

Copia y pega aquí:

```bash
# === APLICACIÓN ===
SECRET_KEY_BASE=
FRONTEND_URL=
INSTALLATION_ENV=

# === BASE DE DATOS ===
DATABASE_URL=
POSTGRES_HOST=
POSTGRES_USERNAME=
POSTGRES_PASSWORD=
POSTGRES_DATABASE=

# === REDIS ===
REDIS_URL=
REDIS_HOST=

# === RAILS ===
RAILS_ENV=
NODE_ENV=
RAILS_LOG_TO_STDOUT=

# === EMAIL (si está configurado) ===
MAILER_SENDER_EMAIL=
SMTP_ADDRESS=
SMTP_PORT=
SMTP_USERNAME=
SMTP_PASSWORD=
SMTP_AUTHENTICATION=
SMTP_ENABLE_STARTTLS_AUTO=

# === STORAGE (si usas S3) ===
ACTIVE_STORAGE_SERVICE=
S3_BUCKET_NAME=
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_REGION=

# === OTRAS ===
ENABLE_ACCOUNT_SIGNUP=
```

## Paso 3: Copiar variables del Worker/Sidekiq

En EasyPanel → Servicio Worker → Settings → Environment Variables

Copia y pega aquí (deben ser IGUALES al Web):

```bash
# Pega las variables del worker aquí para comparar
```

## Paso 4: Verificar comandos

### Servicio Web:
```bash
Command actual: ___________________________________
                (debe ser algo como: bundle exec rails s -p 3000 -b 0.0.0.0)

Entrypoint: ___________________________________
            (puede ser: docker/entrypoints/rails.sh)

Puerto expuesto: _____
                 (debe ser 3000)
```

### Servicio Worker:
```bash
Command actual: ___________________________________
                (debe ser: bundle exec sidekiq -C config/sidekiq.yml)
```

## Paso 5: Verificar volúmenes/storage

¿Tienes volúmenes montados?

```
[ ] Sí - ¿Cuáles?:
    - /app/storage
    - /app/public/uploads
    - Otros: _______________

[ ] No - Probablemente uses S3 o almacenamiento externo
```

## Paso 6: Plan de Actualización

Basado en tu configuración, elige:

### ✅ Plan A: Update directo (si te sientes confiado)

```
1. Build imagen: ./build-and-push.sh
2. Actualizar Web: Image → alangonzalez93/mileto-chatwoot:latest
3. Actualizar Worker: Image → alangonzalez93/mileto-chatwoot:latest
4. Migración: bundle exec rails db:migrate
```

### ✅ Plan B: Testing paralelo (más seguro)

```
1. Build imagen: ./build-and-push.sh
2. Crear mileto-web-test (puerto 3001)
3. Crear mileto-worker-test
4. Probar con misma DB
5. Si funciona → cambiar producción
```

## Paso 7: Backup antes de actualizar

```bash
# PostgreSQL backup
[ ] Backup realizado
    Comando usado: ___________________________________
    Archivo guardado: ___________________________________

# Variables de entorno
[ ] Copiadas a archivo de texto
    Archivo: ___________________________________
```

---

## 📝 Notas adicionales

Anota cualquier configuración especial que tengas:

```
- ¿Usas dominio personalizado? _____
- ¿Tienes SSL configurado? _____
- ¿Usas S3 para archivos? _____
- ¿Tienes webhooks configurados? _____
- ¿Integraciones activas? _____
```

---

## 🎯 Siguiente Paso

Una vez completado este checklist:

1. Si elegiste Plan A → Lee: QUICK_START.md
2. Si elegiste Plan B → Lee: EASYPANEL_UPDATE_GUIDE.md sección "Opción B"
