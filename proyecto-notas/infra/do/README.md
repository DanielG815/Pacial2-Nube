DigitalOcean Terraform (simple droplet)

This folder contains a minimal Terraform configuration that creates a single DigitalOcean droplet and provisions it with Docker and your repository using cloud-init. It's designed for quick demos (teacher checks) and is NOT marketed for production use.

Pre-requisitos

- Cuenta DigitalOcean
- Token personal (Personal Access Token) — puedes exportarlo como env var `DIGITALOCEAN_TOKEN` o pasarlo como variable `do_token` al ejecutar Terraform
- Tu clave SSH agregada a DigitalOcean (opcional, puedes usar contraseña en la droplet, pero SSH key es más seguro)

Instrucciones básicas

1. Exporta el token (opcional):

```bash
# PowerShell
$env:DIGITALOCEAN_TOKEN = "<tu-token>"

# cmd
set DIGITALOCEAN_TOKEN=<tu-token>

# Linux/Mac
export DIGITALOCEAN_TOKEN=<tu-token>
```

2. (Opcional) Si tienes fingerprint/ID de tu clave SSH en DO, edítalo en `variables.tf` o pásalo por `-var "ssh_fingerprint=<id>"`.

3. Inicializa y aplica Terraform:

```bash
cd proyecto-notas/infra/do
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

4. Al finalizar, Terraform mostrará la IP pública del droplet (`droplet_ip`). Abre en el navegador:

```
http://<droplet_ip>:3000/api/notes
```

Notas

- El cloud-init clona el repo y ejecuta `docker compose up -d --build`. Si tu repo necesita permisos para hacer `docker compose`, el script procura instalar docker y docker compose.
- Si quieres que la base de datos sea gestionada (Managed DB), puedo añadir un bloque adicional que cree un DigitalOcean Managed Database y variables para conectarla. Esto incrementa el coste, pero es recomendado para producción.
- Este setup es ideal para demostraciones y revisiones (por ejemplo que el docente vea la app corriendo en la nube). Para producción necesitarás seguridad adicional (firewall, backups, certificados SSL/HTTPS, etc).
