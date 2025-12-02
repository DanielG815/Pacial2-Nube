# 🚀 GUÍA DE INICIO RÁPIDO - Despliegue en AWS

## 5 Pasos para Desplegar tu Aplicación

### ✅ Requisitos Previos

```powershell
# Verificar que tengas instalado:
aws --version
terraform --version
kubectl version --client
docker --version
```

Si faltan herramientas, instálalas desde:
- [AWS CLI](https://aws.amazon.com/cli/)
- [Terraform](https://www.terraform.io/downloads)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Docker](https://www.docker.com/products/docker-desktop)

### 🔑 Configurar AWS

```powershell
aws configure
# Ingresa:
# - Access Key ID
# - Secret Access Key
# - Región: us-east-1
# - Formato: json
```

---

## 🏗️ PASO 1: Desplegar Infraestructura (20 minutos)

```powershell
# Ir a la carpeta del proyecto
cd "ruta\a\Parcial2-Nube"

# Opción A: Script automatizado
.\deploy.ps1 -Action terraform-init
.\deploy.ps1 -Action terraform-plan
.\deploy.ps1 -Action terraform-apply

# Opción B: Manual
cd proyecto-notas\infra
terraform init
terraform plan -out=tfplan
terraform apply tfplan

# Ver outputs
terraform output
```

**Salida esperada:**
```
eks_cluster_name = "notes-eks-cluster"
eks_cluster_endpoint = "https://xxx.eks.amazonaws.com"
rds_endpoint = "notes-db.xxx.rds.amazonaws.com:5432"
vpc_id = "vpc-xxxxx"
```

---

## 🐳 PASO 2: Construir y Subir Imagen Docker (10 minutos)

```powershell
# Opción A: Script automatizado
.\deploy.ps1 -Action ecr-setup
.\deploy.ps1 -Action docker-build
.\deploy.ps1 -Action docker-push

# Opción B: Manual
# 1. Crear repositorio ECR
aws ecr create-repository --repository-name notes-api --region us-east-1

# 2. Obtener Account ID
$ACCOUNT_ID = aws sts get-caller-identity --query Account --output text
Write-Host "Account ID: $ACCOUNT_ID"

# 3. Login en ECR
aws ecr get-login-password --region us-east-1 | `
  docker login --username AWS --password-stdin "$ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com"

# 4. Construir imagen
cd proyecto-notas\app
docker build -t notes-api:latest .

# 5. Etiquetar imagen
docker tag notes-api:latest "$ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/notes-api:latest"

# 6. Subir a ECR
docker push "$ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/notes-api:latest"
```

---

## ☸️ PASO 3: Configurar Kubernetes (5 minutos)

```powershell
# Opción A: Script automatizado
.\deploy.ps1 -Action kubectl-config

# Opción B: Manual
# 1. Actualizar kubeconfig
aws eks update-kubeconfig --region us-east-1 --name notes-eks-cluster

# 2. Verificar conexión
kubectl cluster-info
kubectl get nodes

# Esperado: Debe mostrar 2 nodos en estado Ready
```

---

## 📦 PASO 4: Desplegar Aplicación (5 minutos)

```powershell
# Opción A: Script automatizado
.\deploy.ps1 -Action k8s-deploy

# Opción B: Manual
# 1. Aplicar ConfigMap
kubectl apply -f proyecto-notas\k8s\configmap.yml

# 2. Crear Secret (credenciales de BD)
kubectl create secret generic db-credentials `
  --from-literal=DB_USER=notesuser `
  --from-literal=DB_PASSWORD=micontraseña123

# 3. Desplegar aplicación
kubectl apply -f proyecto-notas\k8s\deployment-api.yml
kubectl apply -f proyecto-notas\k8s\service-api.yml

# 4. Esperar a que esté listo
kubectl rollout status deployment/notes-api --timeout=5m

# 5. Verificar
kubectl get pods
kubectl get services
```

---

## 🧪 PASO 5: Probar la Aplicación (2 minutos)

```powershell
# Opción A: Script automatizado
.\deploy.ps1 -Action test-api

# Opción B: Manual
# 1. Obtener URL del LoadBalancer
$URL = kubectl get service notes-api-svc `
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
Write-Host "URL: http://$URL"

# 2. Probar GET (obtener notas)
curl "http://$URL/api/notes"

# 3. Probar POST (crear nota)
$body = @{
    title = "Mi primer nota"
    content = "Contenido de la nota"
} | ConvertTo-Json

curl -X POST "http://$URL/api/notes" `
  -Headers @{"Content-Type"="application/json"} `
  -Body $body
```

**Respuesta esperada:**
```json
{
  "id": 1,
  "title": "Mi primer nota",
  "content": "Contenido de la nota",
  "created_at": "2025-12-01T10:30:00Z"
}
```

---

## 📊 Monitoreo

```powershell
# Ver logs de la aplicación
kubectl logs -f deployment/notes-api

# Ver recursos utilizados
kubectl top nodes
kubectl top pods

# Ver eventos
kubectl get events --sort-by='.lastTimestamp'

# Describir pod
kubectl describe pod <pod-name>
```

---

## 🧹 Limpiar Recursos (Evitar Costos)

```powershell
# IMPORTANTE: Esto eliminará todo y no se puede recuperar
# Tiempo estimado: 10-15 minutos

# 1. Eliminar aplicación de Kubernetes
kubectl delete -f proyecto-notas\k8s\

# 2. Destruir infraestructura
cd proyecto-notas\infra
terraform destroy

# Confirmar escribiendo 'yes'
```

---

## 🆘 Problemas Comunes

### Error: "Pod no inicia"
```powershell
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Error: "LoadBalancer no tiene IP"
```powershell
# Esperar 1-2 minutos adicionales
Start-Sleep -Seconds 120
kubectl get service notes-api-svc
```

### Error: "Base de datos no accesible"
```powershell
# Verificar security group
aws ec2 describe-security-groups --filters Name=group-name,Values=notes-rds-sg
```

### Error: "No puedo conectar a EKS"
```powershell
# Reconfigurar kubectl
aws eks update-kubeconfig --region us-east-1 --name notes-eks-cluster --force
```

---

## 💡 Consejos

✅ **Antes de comenzar:**
- Asegúrate de tener suficiente cuota de recursos en AWS
- Verifica que tu región es `us-east-1`
- Ten a mano tu contraseña de BD

✅ **Durante el despliegue:**
- El despliegue inicial tarda ~20 minutos
- No cierres la terminal durante `terraform apply`
- Los pods pueden tardar 1-2 minutos en estar listos

✅ **Después del despliegue:**
- Guarda el output de `terraform output`
- Monitorea los logs regularmente
- Configura backups automáticos en RDS

---

## 📱 API Endpoints

```
Base URL: http://<loadbalancer-dns>

GET  /api/notes
- Obtiene todas las notas
- Respuesta: Array de notas

POST /api/notes
- Crea una nueva nota
- Body: { "title": "...", "content": "..." }
- Respuesta: Nota creada con ID
```

---

## 🎯 Próximos Pasos

1. **Agregar más endpoints** (DELETE, PUT)
2. **Implementar Ingress** con NGINX
3. **Agregar SSL/TLS** con Let's Encrypt
4. **Configurar auto-scaling**
5. **Agregar monitoring** con Prometheus
6. **Implementar CI/CD** con GitHub Actions

---

## 📞 Soporte

- Revisa `README-DESPLIEGUE.md` para documentación completa
- Consulta logs: `kubectl logs -f deployment/notes-api`
- Ver estado: `kubectl get all`

**¡Listo para desplegar! 🚀**
