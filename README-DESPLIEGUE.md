# Proyecto de Notas - Despliegue en AWS

Este proyecto es una aplicación de notas completa desplegada en AWS con Docker, Kubernetes (EKS), PostgreSQL (RDS) y administración de infraestructura con Terraform.

## Arquitectura

```
┌─────────────────────────────────────────────────────────────────┐
│                          AWS (us-east-1)                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                    VPC (10.0.0.0/16)                     │   │
│  │                                                          │   │
│  │  ┌─────────────────────────────────────────────────┐    │   │
│  │  │  EKS Cluster (Kubernetes)                       │    │   │
│  │  │  ┌──────────────────────────────────────────┐   │    │   │
│  │  │  │  Deployment: notes-api (2 replicas)     │   │    │   │
│  │  │  │  - Pod 1: notes-api container           │   │    │   │
│  │  │  │  - Pod 2: notes-api container           │   │    │   │
│  │  │  └──────────────────────────────────────────┘   │    │   │
│  │  │  ┌──────────────────────────────────────────┐   │    │   │
│  │  │  │  Service: LoadBalancer (notas-api-svc)  │   │    │   │
│  │  │  │  Puerto: 80 → 3000                       │   │    │   │
│  │  │  └──────────────────────────────────────────┘   │    │   │
│  │  └─────────────────────────────────────────────────┘    │   │
│  │                                                          │   │
│  │  ┌──────────────────────────────────────────────────┐   │   │
│  │  │  RDS PostgreSQL (Private Subnet)                 │   │   │
│  │  │  - Database: notesdb                             │   │   │
│  │  │  - User: notesuser                               │   │   │
│  │  │  - Engine: PostgreSQL 16                         │   │   │
│  │  └──────────────────────────────────────────────────┘   │   │
│  │                                                          │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

## Requisitos Previos

### Herramientas Locales
- AWS CLI v2
- Terraform >= 1.5.0
- kubectl >= 1.28
- Docker (para construir imágenes localmente)
- Git

### Credenciales AWS
```bash
aws configure
# Ingresa:
# AWS Access Key ID
# AWS Secret Access Key
# Default region: us-east-1
# Default output format: json
```

## Estructura del Proyecto

```
proyecto-notas/
├── app/                          # Aplicación Node.js
│   ├── src/
│   │   ├── app.js               # Entrada principal
│   │   ├── controllers/         # Lógica de controladores
│   │   ├── services/            # Lógica de negocio
│   │   ├── repositories/        # Acceso a datos
│   │   ├── routes/              # Definición de rutas
│   │   └── db/                  # Conexión a BD
│   ├── Dockerfile               # Imagen Docker
│   └── package.json             # Dependencias Node
│
├── infra/                        # Infraestructura Terraform
│   ├── main.tf                  # Módulos principales
│   ├── variables.tf             # Variables de entrada
│   ├── outputs.tf               # Outputs
│   ├── init-db.sql              # Script de inicialización BD
│   └── modules/
│       ├── network/             # VPC y subnets
│       ├── eks/                 # Kubernetes cluster
│       └── rds/                 # Base de datos
│
└── k8s/                         # Manifiestos Kubernetes
    ├── deployment-api.yml       # Deployment de la app
    ├── service-api.yml          # LoadBalancer service
    ├── configmap.yml            # Configuración
    └── secret-db.yml            # Credenciales BD
```

## Paso 1: Despliegue de Infraestructura con Terraform

### 1.1 Inicializar Terraform

```bash
cd proyecto-notas/infra
terraform init
```

### 1.2 Validar Configuración

```bash
terraform validate
```

### 1.3 Crear Plan (Revisar cambios)

```bash
terraform plan -out=tfplan
```

**Esto mostrará:**
- 1 VPC con subnets públicas y privadas
- 1 Cluster EKS con node group
- 1 Base de datos RDS PostgreSQL
- Security groups y roles necesarios

### 1.4 Aplicar Cambios

```bash
terraform apply tfplan
```

**Tiempo estimado:** 15-20 minutos

### 1.5 Obtener Información de la Infraestructura

```bash
terraform output
```

**Guarda estos valores:**
- `eks_cluster_name`: Nombre del cluster EKS
- `eks_cluster_endpoint`: URL del API server
- `rds_endpoint`: Endpoint de la base de datos

## Paso 2: Construir y Subir Imagen Docker a ECR

### 2.1 Crear Repositorio en ECR

```bash
aws ecr create-repository \
  --repository-name notes-api \
  --region us-east-1
```

### 2.2 Obtener Login

```bash
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin $(aws sts get-caller-identity --query Account --output text).dkr.ecr.us-east-1.amazonaws.com
```

### 2.3 Construir Imagen

```bash
cd ../../app
docker build -t notes-api:latest .
```

### 2.4 Etiquetar Imagen

```bash
docker tag notes-api:latest $(aws sts get-caller-identity --query Account --output text).dkr.ecr.us-east-1.amazonaws.com/notes-api:latest
```

### 2.5 Subir a ECR

```bash
docker push $(aws sts get-caller-identity --query Account --output text).dkr.ecr.us-east-1.amazonaws.com/notes-api:latest
```

## Paso 3: Configurar kubectl

```bash
aws eks update-kubeconfig \
  --region us-east-1 \
  --name notes-eks-cluster
```

Verificar conexión:
```bash
kubectl cluster-info
kubectl get nodes
```

## Paso 4: Desplegar Aplicación en Kubernetes

### 4.1 Crear ConfigMap

```bash
kubectl apply -f k8s/configmap.yml
```

### 4.2 Crear Secret para Credenciales BD

```bash
kubectl create secret generic db-credentials \
  --from-literal=DB_USER=notesuser \
  --from-literal=DB_PASSWORD=tu-password-aqui
```

### 4.3 Desplegar Aplicación

```bash
kubectl apply -f k8s/deployment-api.yml
kubectl apply -f k8s/service-api.yml
```

### 4.4 Verificar Despliegue

```bash
kubectl get pods
kubectl get services
kubectl logs -f deployment/notes-api
```

### 4.5 Obtener URL del LoadBalancer

```bash
kubectl get service notes-api-svc -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

## Paso 5: Probar la Aplicación

### 5.1 Obtener la URL

```bash
LOAD_BALANCER=$(kubectl get service notes-api-svc -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "URL: http://$LOAD_BALANCER"
```

### 5.2 Crear una Nota

```bash
curl -X POST http://$LOAD_BALANCER/api/notes \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Mi primera nota",
    "content": "Contenido de la nota"
  }'
```

### 5.3 Obtener todas las Notas

```bash
curl http://$LOAD_BALANCER/api/notes
```

## Monitoreo y Mantenimiento

### Ver Logs de Pods

```bash
kubectl logs -f pod/notes-api-xxx
```

### Ver Recursos Utilizados

```bash
kubectl top nodes
kubectl top pods
```

### Escalado Manual

```bash
kubectl scale deployment notes-api --replicas=4
```

### Actualizar Imagen

```bash
# Subir nueva imagen a ECR
docker build -t notes-api:v2 .
docker tag notes-api:v2 $ECR_REPO/notes-api:v2
docker push $ECR_REPO/notes-api:v2

# Actualizar Deployment
kubectl set image deployment/notes-api \
  notes-api=$ECR_REPO/notes-api:v2
```

## Limpiar Recursos (Destruir Todo)

### 1. Eliminar Aplicación de Kubernetes

```bash
kubectl delete -f k8s/
```

### 2. Destruir Infraestructura

```bash
cd proyecto-notas/infra
terraform destroy
```

**Advertencia:** Esto eliminará todos los recursos de AWS.

## Troubleshooting

### Error: "Pod no inicia"

```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Error: "Base de datos no accesible"

Verificar security groups:
```bash
aws ec2 describe-security-groups \
  --filters Name=group-name,Values=notes-rds-sg
```

### Error: "Imagen no encontrada en ECR"

Verificar login:
```bash
aws ecr describe-repositories --repository-names notes-api
```

### Error: "EKS node no ready"

```bash
kubectl describe nodes
aws eks describe-nodegroup \
  --cluster-name notes-eks-cluster \
  --nodegroup-name notes-node-group
```

## Costos Estimados (AWS)

- **EKS Cluster**: $0.10/hora
- **EC2 Nodes (2x t3.medium)**: ~$0.084/hora
- **RDS PostgreSQL (db.t3.micro)**: ~$0.019/hora
- **Data Transfer**: Varía según uso

**Total estimado**: ~$75-100/mes en low traffic

## Endpoints de API

```
GET  /api/notes       - Obtener todas las notas
POST /api/notes       - Crear una nueva nota
```

## Seguridad

- ✅ Base de datos en subred privada
- ✅ Secretos almacenados en Kubernetes Secret
- ✅ RBAC habilitado en EKS
- ✅ Network policies pueden habilitarse
- ⚠️ Habilitar SSL/TLS con Ingress controller para producción

## Próximos Pasos

1. **Agregar CI/CD** con GitHub Actions
2. **Implementar Ingress** con NGINX o ALB
3. **Agregar Monitoring** con Prometheus/Grafana
4. **Logging Centralizado** con CloudWatch/ELK
5. **Backup automático** de BD RDS
6. **Auto-scaling** basado en métricas

---

**Última actualización:** Diciembre 2025
**Autor:** Equipo de Desarrollo en la Nube
