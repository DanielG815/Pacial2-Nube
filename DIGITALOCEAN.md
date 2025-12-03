Despliegue rápido en DigitalOcean (para demos/docente)

Resumen

Este documento te guía para crear un droplet barato en DigitalOcean, que instalará Docker, clonará tu repositorio y levantará la aplicación usando `docker compose`.

Recomendación

- Usa la prueba gratuita de DigitalOcean (si está disponible) o una cuenta nueva.
- Tamaño recomendado para demo: `s-1vcpu-1gb` (~$4/mo)
- Zona recomendada: `nyc3` o la que prefieras.

Pasos (resumen)

1) Crea cuenta en DigitalOcean
2) Añade tu clave SSH en "Settings → Security → Add SSH Key"
3) Genera un token personal (API → Tokens / Keys → Generate New Token)
4) En tu máquina local, exporta el token en una variable de entorno:

```powershell
$env:DIGITALOCEAN_TOKEN = "<tu-token>"
```

5) Opcional: anota el "Fingerprint" de tu SSH key (lo verás en la UI)

6) Despliegue con Terraform (desde el repo):

```powershell
cd proyecto-notas\infra\do
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

7) Al terminar, copia la IP que Terraform imprime en `droplet_ip` y abre:

```
http://<droplet_ip>:3000/api/notes
```

Detalles del cloud-init

- Instala Docker y (si puede) Docker Compose
- Clona la rama `main` de `https://github.com/DanielG815/Pacial2-Nube.git` por defecto (puedes cambiar la URL en `variables.tf`)
- Copia `.env.example` a `.env` y lanza `docker compose up -d --build`

Notas y recomendaciones rápidas

- Si la app no responde inmediatamente, espera 1-2 minutos (arranque y build docker)
- Para ver logs, conecta por SSH al droplet y ejecuta:

```bash
ssh root@<droplet_ip>
cd /opt/notes-app
docker compose logs -f app
```

- Para actualizar la app en el droplet (por ejemplo tras push a GitHub):

```bash
ssh root@<droplet_ip>
cd /opt/notes-app
git pull
docker compose up -d --build
```

- Si prefieres usar Managed DB de DigitalOcean en lugar de Postgres en el droplet, dímelo y lo añado al Terraform.

Coste estimado

- Droplet `s-1vcpu-1gb`: ~$4 / mes
- Managed DB (opcional): desde ~$15 / mes

Si quieres que cree también el bloque Terraform para la DB gestionada (y la vincule a la app), dime y lo agrego. También puedo generar un script que haga un `ssh root@<ip>` y ejecute `git pull && docker compose up -d --build` para actualizaciones rápidas.