#cloud-config

package_update: true
packages:
  - git
  - curl
  - apt-transport-https
  - ca-certificates
  - gnupg
  - lsb-release

runcmd:
  - [ sh, -c, "curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh" ]
  - [ sh, -c, "apt-get install -y docker-compose || true" ]
  - [ sh, -c, "mkdir -p /opt/notes-app && chown -R root:root /opt/notes-app" ]
  - [ sh, -c, "if [ -d /opt/notes-app/.git ]; then cd /opt/notes-app && git fetch origin && git reset --hard origin/${branch}; else git clone -b ${branch} ${repo_url} /opt/notes-app; fi" ]
  - [ sh, -c, "cd /opt/notes-app && cp .env.example .env || true" ]
  - [ sh, -c, "cd /opt/notes-app && docker compose up -d --build" ]

final_message: "La instancia ha sido provisionada y la aplicación debería estar en ejecución"
