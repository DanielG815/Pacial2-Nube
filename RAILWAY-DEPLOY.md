# Despliegue en Railway.app (Gratuito, sin tarjeta)

## ¿Por qué Railway?
- ✅ Completamente gratuito (crédito $5/mes suficiente para demo)
- ✅ Sin tarjeta de crédito requerida
- ✅ Deploy automático desde GitHub
- ✅ PostgreSQL incluido
- ✅ URL pública y HTTPS automático
- ✅ Interfaz muy intuitiva

## Pasos para desplegar

### 1. Crear cuenta en Railway
- Abre https://railway.app
- Haz clic en "Start Free"
- Regístrate con GitHub (recomendado)
- Autoriza Railway en tu cuenta de GitHub
- Verifica tu correo

### 2. Crear nuevo proyecto
- En el dashboard, haz clic en "New Project"
- Selecciona "Deploy from GitHub repo"
- Busca y selecciona `Pacial2-Nube`
- Railway detectará automáticamente que es una app Node.js

### 3. Railway configurará automáticamente:
- ✅ Detecta `package.json` y `Dockerfile`
- ✅ Build automático
- ✅ Start command

**Pero necesitas agregar la BD PostgreSQL:**
- En el mismo proyecto, haz clic en "+ New"
- Selecciona "Database" → "PostgreSQL"
- Railway crea la BD automáticamente

### 4. Configurar variables de entorno
- Ve a tu servicio web (notes-api)
- Abre "Variables"
- Railway automáticamente debería crear:
  - `DATABASE_URL` (URL de conexión a Postgres)

**Pero tu app espera variables individuales, así que agrega:**
```
DB_HOST = <hostname de la BD>
DB_PORT = 5432
DB_USER = postgres (usuario por defecto)
DB_PASSWORD = <contraseña autogenerada>
DB_NAME = railway (nombre de BD por defecto)
```

**Para obtener estos valores:**
- Abre el plugin PostgreSQL
- Ve a "Connect"
- Verás la URL: `postgresql://postgres:password@host:port/railway`
- De ahí extrae los valores

**O más fácil:** usa la variable `DATABASE_URL` directamente si conectas así:
```javascript
const pool = new Pool({
  connectionString: process.env.DATABASE_URL
});
```

### 5. Ejecutar script de inicialización
Railway ejecuta automáticamente migraciones si agregas un `railway.json`. Pero para ti es más fácil:

**Opción A (manual, fácil):**
- Conecta a la BD desde tu PC con `psql`:
  ```bash
  psql "postgresql://postgres:password@host:port/railway" < proyecto-notas/infra/init-db.sql
  ```

**Opción B (automático):**
Dime y agrego un script que se ejecute al startup.

### 6. Deploy automático
- Railway detecta cambios en tu repo automáticamente
- Cada push a `main` redeploya la app
- Ver estado en "Deployments"

### 7. Obtener URL
- En "Settings" del servicio web, verás:
  ```
  https://pacial2-nube-production-xxxx.railway.app
  ```
- Accede a:
  ```
  https://pacial2-nube-production-xxxx.railway.app/api/notes
  ```

## Railway CLI (opcional, para desarrollo local)

Si quieres trabajar localmente con la BD de Railway:

```powershell
# Instalar Railway CLI
npm install -g @railway/cli

# Conectar a tu proyecto
railway link

# Ver variables (incluido DATABASE_URL)
railway variables

# Conectar con psql
railway run psql
```

## Ventajas vs Render
- ✅ Railway es **más rápido** en deploys
- ✅ Mejor interfaz
- ✅ $5 de crédito mensual (suficiente para pequeños proyectos)
- ✅ No suspende servicios como Render

## Troubleshooting

**App no inicia / Build fails:**
- Abre "Logs" en el servicio
- Busca el error (típicamente falta de dependencias)

**Base de datos no conecta:**
- Verifica credenciales en variables de entorno
- Asegúrate de usar el hostname correcto (sin `postgres://`)

**¿Dónde veo los logs?**
- En el servicio, abre "Logs"
- O en "Deployments" → haz clic en el deploy → "View logs"

## Pasos resumidos (quick start)

1. Crea cuenta en railway.app (GitHub)
2. New Project → Deploy from GitHub → Pacial2-Nube
3. Agrega PostgreSQL
4. Configura variables de entorno
5. Crea tabla en la BD (psql o via Railway CLI)
6. Deploy automático
7. Abre la URL y prueba

---

**¿Necesitas ayuda con algún paso?** Dime cuál y te guío en detalle.
