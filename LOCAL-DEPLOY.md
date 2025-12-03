Despliegue local con Docker Compose (Windows PowerShell)

Resumen: levantarás Postgres y la API Node.js localmente, sin costo en la nube.

Requisitos:
- Docker Desktop instalado y funcionando
- Windows PowerShell

1) Copiar el archivo de ejemplo de variables de entorno

```powershell
cd "D:\1. UNAS\8. Octavo Ciclo\DESARROLLO DE APLICACIONES PARA LA NUBE\Parcial2-Nube"
copy .env.example .env
# Edita .env si quieres otra contraseña
notepad .env
```

2) Construir y levantar los contenedores

```powershell
# Levanta en background y construye la imagen de la app
docker compose up --build -d

# Ver logs
docker compose logs -f app
```

3) Verificar la API

```powershell
# En otra terminal PowerShell
curl http://localhost:3000/api/notes
```

4) Crear una nota de prueba

```powershell
curl -X POST http://localhost:3000/api/notes -H "Content-Type: application/json" -d '{"title":"Prueba local","content":"Funcionando"}'
```

5) Comandos útiles

```powershell
# Ver contenedores
docker compose ps

# Parar y remover
docker compose down

# Borrar volúmenes si quieres resetear la DB
docker compose down -v
```

Notas:
- El archivo `proyecto-notas/infra/init-db.sql` se montará en Postgres para inicializar la tabla `notes` la primera vez.
- Si la app falla por tiempos de arranque, espera 10-20 segundos y revisa `docker compose logs -f app`.

Si quieres, puedo ajustar el `docker-compose.yml` para usar un healthcheck más robusto o para montar el código en modo desarrollo (nodemon).