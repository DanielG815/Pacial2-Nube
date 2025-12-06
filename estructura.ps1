# Nombre de la carpeta principal
$baseDir = "mi-proyecto-cloud"

# 1. Crear las carpetas
Write-Host "Creando carpetas..."
New-Item -Path "$baseDir/app" -ItemType Directory -Force
New-Item -Path "$baseDir/terraform" -ItemType Directory -Force
New-Item -Path "$baseDir/k8s" -ItemType Directory -Force

# 2. Crear archivos vacíos en 'app'
New-Item -Path "$baseDir/app/app.py" -ItemType File -Force
New-Item -Path "$baseDir/app/requirements.txt" -ItemType File -Force
New-Item -Path "$baseDir/app/Dockerfile" -ItemType File -Force

# 3. Crear archivos vacíos en 'terraform'
New-Item -Path "$baseDir/terraform/main.tf" -ItemType File -Force
New-Item -Path "$baseDir/terraform/variables.tf" -ItemType File -Force
New-Item -Path "$baseDir/terraform/outputs.tf" -ItemType File -Force

# 4. Crear archivos vacíos en 'k8s'
New-Item -Path "$baseDir/k8s/postgres.yaml" -ItemType File -Force
New-Item -Path "$baseDir/k8s/web-app.yaml" -ItemType File -Force

Write-Host "¡Listo! Estructura creada en la carpeta '$baseDir'."
Start-Sleep -Seconds 3