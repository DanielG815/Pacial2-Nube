# Despliegue en Render.com (Gratuito)

## ¿Por qué Render?
- ✅ Plan gratuito (sin tarjeta de crédito)
- ✅ Deploy automático desde GitHub
- ✅ PostgreSQL incluido en el plan gratuito
- ✅ URL pública y HTTPS automático
- ✅ Ideal para demos y proyectos escolares

## Pasos para desplegar

### 1. Crear cuenta en Render
- Abre https://render.com
- Haz clic en "Sign Up"
- Regístrate con GitHub (más fácil) o email
- Verifica tu correo

### 2. Conectar tu repositorio GitHub
- En Render, ve a "Dashboards"
- Haz clic en "New +" → "Web Service"
- Selecciona "GitHub" y autoriza Render
- Busca tu repo: `Parcial2-Nube`
- Selecciona y conecta

### 3. Configurar el servicio web
**Rellena estos campos:**

- **Name:** `notes-api` (o el que prefieras)
- **Runtime:** Node
- **Build Command:** `npm install`
- **Start Command:** `node src/app.js`
- **Plan:** Free (predeterminado)

Haz clic en "Advanced" y agrega variables de entorno:
```
DB_HOST = <veremos después>
DB_PORT = 5432
DB_USER = notesuser
DB_PASSWORD = notespass123
DB_NAME = notesdb
```

### 4. Crear la base de datos PostgreSQL
- Ve a "Databases" en Render
- Haz clic en "New Database"
- **Name:** `notes-db`
- **Region:** elige la más cercana
- **Database:** `notesdb`
- **User:** `notesuser`
- **Plan:** Free

Cuando se cree, copia la **Internal Database URL** (es la que usarás).

### 5. Actualizar variables de entorno del servicio web
- Vuelve a tu Web Service (notes-api)
- Ve a "Environment"
- Actualiza `DB_HOST` con el hostname de la BD (puedes obtenerlo de la URL de conexión)

O más fácil: en la BD copiada, verás algo como `postgres://notesuser:password@hostname:5432/notesdb`
Usa `hostname` como `DB_HOST`.

### 6. Agregar el script de inicialización
Como Render no ejecuta automáticamente `init-db.sql`, necesitas que tu app cree la tabla al iniciar.

**Opción A (recomendada):** 
Crearé un script que ejecute el SQL en el arranque. Dime y lo agrego.

**Opción B:** 
Conecta manualmente a la BD y ejecuta el SQL:
```bash
psql "postgres://notesuser:password@hostname:5432/notesdb" < proyecto-notas/infra/init-db.sql
```

### 7. Deploy
- Haz clic en "Create Web Service"
- Render construye la imagen automáticamente
- Cuando vea "Deploy live", tu app está en línea

### 8. Obtener URL
- En la página del servicio, verás una URL como:
  ```
  https://notes-api-xxxxx.onrender.com
  ```
- Accede a:
  ```
  https://notes-api-xxxxx.onrender.com/api/notes
  ```

## Problemas comunes

**App dice "not found":**
- Verifica que tu `package.json` tiene el script `start: "node src/app.js"`
- Render busca `npm start`

**Base de datos no conecta:**
- Verifica credenciales en variables de entorno
- Asegúrate de que el `DB_HOST` es el hostname correcto (sin `postgres://` ni puertos)

**¿Dónde veo los logs?**
- En la página del servicio, abre "Logs"

## Próximos pasos

1. Crea cuenta y conecta repo
2. Crea la BD PostgreSQL
3. Configura variables de entorno
4. Deploy
5. Prueba tu API
6. Comparte la URL con tu docente

---

**Nota:** El plan gratuito de Render suspende servicios inactivos tras 15 minutos. Si tu app no responde, dale unos segundos para "despertar". No es problema para una demo.

**¿Necesitas ayuda con algún paso?** Dime cuál y te guío en detalle.
