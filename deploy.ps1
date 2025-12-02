# Script de despliegue para Windows PowerShell
# Despliegue completo de infraestructura en AWS

param(
    [string]$Action = "help",
    [string]$AwsRegion = "us-east-1",
    [string]$AccountId = ""
)

function Show-Help {
    Write-Host @"
    
╔═══════════════════════════════════════════════════════════════╗
║         Despliegue de Aplicación de Notas en AWS              ║
║                   PowerShell Script                           ║
╚═══════════════════════════════════════════════════════════════╝

Uso:
    .\deploy.ps1 -Action [acción] -AwsRegion [región]

Acciones disponibles:
    1. terraform-init      - Inicializar Terraform
    2. terraform-plan      - Crear plan de Terraform
    3. terraform-apply     - Aplicar cambios de Terraform
    4. ecr-setup          - Configurar repositorio ECR
    5. docker-build       - Construir imagen Docker
    6. docker-push        - Subir imagen a ECR
    7. kubectl-config     - Configurar kubectl
    8. k8s-deploy         - Desplegar en Kubernetes
    9. test-api           - Probar API
    10. destroy           - Destruir todos los recursos
    help                  - Mostrar esta ayuda

Ejemplos:
    .\deploy.ps1 -Action terraform-init
    .\deploy.ps1 -Action terraform-apply -AwsRegion us-east-1
    .\deploy.ps1 -Action docker-build
    .\deploy.ps1 -Action destroy

"@
}

function Check-Prerequisites {
    Write-Host "Verificando herramientas requeridas..." -ForegroundColor Cyan
    
    $tools = @("aws", "terraform", "kubectl", "docker")
    $missing = @()
    
    foreach ($tool in $tools) {
        try {
            $output = & $tool --version 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✓ $tool encontrado" -ForegroundColor Green
            } else {
                $missing += $tool
            }
        } catch {
            $missing += $tool
        }
    }
    
    if ($missing.Count -gt 0) {
        Write-Host "✗ Herramientas faltantes: $($missing -join ', ')" -ForegroundColor Red
        exit 1
    }
}

function Terraform-Init {
    Write-Host "`nInicializando Terraform..." -ForegroundColor Cyan
    Push-Location "proyecto-notas/infra"
    terraform init
    Pop-Location
}

function Terraform-Plan {
    Write-Host "`nCreando plan de Terraform..." -ForegroundColor Cyan
    Push-Location "proyecto-notas/infra"
    terraform plan -out=tfplan
    Pop-Location
}

function Terraform-Apply {
    Write-Host "`nAplicando cambios de Terraform..." -ForegroundColor Cyan
    Push-Location "proyecto-notas/infra"
    
    $confirm = Read-Host "¿Deseas continuar con el despliegue? (yes/no)"
    if ($confirm -eq "yes") {
        terraform apply tfplan
        
        Write-Host "`nObteniendo información de la infraestructura..." -ForegroundColor Yellow
        $clusterName = terraform output -raw eks_cluster_name
        $clusterEndpoint = terraform output -raw eks_cluster_endpoint
        $rdsEndpoint = terraform output -raw rds_endpoint
        
        Write-Host @"
╔═══════════════════════════════════════════════════════════════╗
║                  Información del Despliegue                   ║
╠═══════════════════════════════════════════════════════════════╣
║ Cluster EKS: $clusterName
║ Endpoint EKS: $clusterEndpoint
║ RDS Endpoint: $rdsEndpoint
╚═══════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Green
    } else {
        Write-Host "Despliegue cancelado" -ForegroundColor Yellow
    }
    
    Pop-Location
}

function ECR-Setup {
    Write-Host "`nConfigurando repositorio ECR..." -ForegroundColor Cyan
    
    if (-not $AccountId) {
        $AccountId = aws sts get-caller-identity --query Account --output text
    }
    
    try {
        aws ecr describe-repositories `
            --repository-names notes-api `
            --region $AwsRegion 2>$null | Out-Null
        
        Write-Host "✓ Repositorio 'notes-api' ya existe" -ForegroundColor Green
    } catch {
        Write-Host "Creando repositorio 'notes-api'..." -ForegroundColor Yellow
        aws ecr create-repository `
            --repository-name notes-api `
            --region $AwsRegion
        
        Write-Host "✓ Repositorio creado" -ForegroundColor Green
    }
}

function Docker-Build {
    Write-Host "`nConstruyendo imagen Docker..." -ForegroundColor Cyan
    Push-Location "proyecto-notas/app"
    docker build -t notes-api:latest .
    Pop-Location
}

function Docker-Push {
    Write-Host "`nSubiendo imagen a ECR..." -ForegroundColor Cyan
    
    if (-not $AccountId) {
        $AccountId = aws sts get-caller-identity --query Account --output text
    }
    
    $ecrRepo = "$AccountId.dkr.ecr.$AwsRegion.amazonaws.com"
    
    Write-Host "Obteniendo credenciales de ECR..." -ForegroundColor Yellow
    aws ecr get-login-password --region $AwsRegion | `
        docker login --username AWS --password-stdin $ecrRepo
    
    Write-Host "Etiquetando imagen..." -ForegroundColor Yellow
    docker tag notes-api:latest "$ecrRepo/notes-api:latest"
    
    Write-Host "Subiendo imagen..." -ForegroundColor Yellow
    docker push "$ecrRepo/notes-api:latest"
    
    Write-Host "✓ Imagen subida exitosamente" -ForegroundColor Green
}

function Kubectl-Config {
    Write-Host "`nConfigurando kubectl..." -ForegroundColor Cyan
    
    $clusterName = Push-Location "proyecto-notas/infra" -PassThru | `
        & { terraform output -raw eks_cluster_name }
    Pop-Location
    
    aws eks update-kubeconfig `
        --region $AwsRegion `
        --name $clusterName
    
    Write-Host "`nVerificando conexión..." -ForegroundColor Yellow
    kubectl cluster-info
    kubectl get nodes
}

function K8s-Deploy {
    Write-Host "`nDespliegue en Kubernetes..." -ForegroundColor Cyan
    
    # Aplicar ConfigMap
    Write-Host "Aplicando ConfigMap..." -ForegroundColor Yellow
    kubectl apply -f proyecto-notas/k8s/configmap.yml
    
    # Crear Secret si no existe
    $secretExists = kubectl get secret db-credentials 2>$null
    if (-not $secretExists) {
        Write-Host "Creando Secret de base de datos..." -ForegroundColor Yellow
        $dbUser = Read-Host "Usuario de base de datos"
        $dbPassword = Read-Host "Contraseña de base de datos" -AsSecureString
        $plainPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($dbPassword))
        
        kubectl create secret generic db-credentials `
            --from-literal=DB_USER=$dbUser `
            --from-literal=DB_PASSWORD=$plainPassword
    }
    
    # Desplegar aplicación
    Write-Host "Desplegando aplicación..." -ForegroundColor Yellow
    kubectl apply -f proyecto-notas/k8s/deployment-api.yml
    kubectl apply -f proyecto-notas/k8s/service-api.yml
    
    # Esperar a que los pods estén listos
    Write-Host "Esperando a que los pods estén listos..." -ForegroundColor Yellow
    kubectl rollout status deployment/notes-api --timeout=5m
    
    # Mostrar información
    Write-Host "`n✓ Despliegue completado" -ForegroundColor Green
    Write-Host "`nServicios:" -ForegroundColor Cyan
    kubectl get services
}

function Test-API {
    Write-Host "`nProbando API..." -ForegroundColor Cyan
    
    $loadBalancer = kubectl get service notes-api-svc `
        -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
    
    if (-not $loadBalancer) {
        Write-Host "⚠ LoadBalancer aún no tiene IP asignada" -ForegroundColor Yellow
        Write-Host "Esperando 30 segundos..." -ForegroundColor Yellow
        Start-Sleep -Seconds 30
        $loadBalancer = kubectl get service notes-api-svc `
            -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
    }
    
    $url = "http://$loadBalancer"
    Write-Host "URL de la API: $url" -ForegroundColor Green
    
    # Probar GET
    Write-Host "`nProbando GET /api/notes..." -ForegroundColor Yellow
    $response = Invoke-WebRequest -Uri "$url/api/notes" -Method Get
    Write-Host "✓ Respuesta: $($response.StatusCode)" -ForegroundColor Green
    
    # Probar POST
    Write-Host "`nProbando POST /api/notes..." -ForegroundColor Yellow
    $body = @{
        title = "Nota de prueba"
        content = "Esta es una nota de prueba"
    } | ConvertTo-Json
    
    $response = Invoke-WebRequest -Uri "$url/api/notes" -Method Post `
        -Headers @{"Content-Type"="application/json"} -Body $body
    Write-Host "✓ Respuesta: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Cuerpo: $($response.Content)" -ForegroundColor Green
}

function Destroy {
    Write-Host "`n⚠ ADVERTENCIA: Esto eliminará todos los recursos de AWS" -ForegroundColor Red
    $confirm = Read-Host "¿Está seguro? Escriba 'yes' para confirmar"
    
    if ($confirm -eq "yes") {
        Write-Host "Eliminando aplicación de Kubernetes..." -ForegroundColor Yellow
        kubectl delete -f proyecto-notas/k8s/ 2>$null
        
        Write-Host "Destruyendo infraestructura..." -ForegroundColor Yellow
        Push-Location "proyecto-notas/infra"
        terraform destroy
        Pop-Location
        
        Write-Host "✓ Recursos eliminados" -ForegroundColor Green
    } else {
        Write-Host "Operación cancelada" -ForegroundColor Yellow
    }
}

# Main
Clear-Host
Write-Host "╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     Despliegue de Aplicación de Notas en AWS - PowerShell     ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

switch ($Action) {
    "terraform-init" { Check-Prerequisites; Terraform-Init }
    "terraform-plan" { Check-Prerequisites; Terraform-Plan }
    "terraform-apply" { Check-Prerequisites; Terraform-Apply }
    "ecr-setup" { Check-Prerequisites; ECR-Setup }
    "docker-build" { Check-Prerequisites; Docker-Build }
    "docker-push" { Check-Prerequisites; Docker-Push }
    "kubectl-config" { Check-Prerequisites; Kubectl-Config }
    "k8s-deploy" { Check-Prerequisites; K8s-Deploy }
    "test-api" { Test-API }
    "destroy" { Destroy }
    "help" { Show-Help }
    default { Show-Help }
}
