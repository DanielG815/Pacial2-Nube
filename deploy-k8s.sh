#!/bin/bash

# Script para desplegar la aplicación en Kubernetes después de que Terraform haya creado la infraestructura

set -e

echo "========================================="
echo "Despliegue de Aplicación en Kubernetes"
echo "========================================="

# Variables
AWS_REGION="${AWS_REGION:-us-east-1}"
AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID}"
CLUSTER_NAME="notes-eks-cluster"
PROJECT_NAME="proyecto-notas"
K8S_DIR="$PROJECT_NAME/k8s"

# 1. Configurar kubectl
echo ""
echo "1. Configurando kubectl para EKS..."
aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME

# 2. Verificar conexión
echo ""
echo "2. Verificando conexión al cluster..."
kubectl cluster-info
kubectl get nodes

# 3. Obtener información de RDS desde Terraform
echo ""
echo "3. Obteniendo información de base de datos..."
cd $PROJECT_NAME/infra
RDS_ENDPOINT=$(terraform output -raw rds_endpoint | cut -d: -f1)
DB_NAME=$(terraform output -raw rds_database_name)
cd ../..

echo "RDS Endpoint: $RDS_ENDPOINT"
echo "DB Name: $DB_NAME"

# 4. Actualizar ConfigMap
echo ""
echo "4. Actualizando ConfigMap con información de RDS..."
cat > $K8S_DIR/configmap.yml <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: api-config
  namespace: default
data:
  DB_HOST: "$RDS_ENDPOINT"
  DB_NAME: "$DB_NAME"
  DB_PORT: "5432"
EOF

# 5. Crear Secret (si no existe)
echo ""
echo "5. Verificando Secret de base de datos..."
if ! kubectl get secret db-credentials 2>/dev/null; then
    echo "Creando Secret..."
    read -s -p "Ingresa el usuario de base de datos: " DB_USER
    echo
    read -s -p "Ingresa la contraseña de base de datos: " DB_PASSWORD
    echo
    
    kubectl create secret generic db-credentials \
        --from-literal=DB_USER=$DB_USER \
        --from-literal=DB_PASSWORD=$DB_PASSWORD
else
    echo "Secret ya existe"
fi

# 6. Actualizar Deployment con imagen de ECR
echo ""
echo "6. Actualizando imagen de ECR en Deployment..."
if [ -z "$AWS_ACCOUNT_ID" ]; then
    read -p "Ingresa tu AWS Account ID: " AWS_ACCOUNT_ID
fi

ECR_IMAGE="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/notes-api:latest"

cat > $K8S_DIR/deployment-api.yml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: notes-api
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: notes-api
  template:
    metadata:
      labels:
        app: notes-api
    spec:
      containers:
        - name: notes-api
          image: $ECR_IMAGE
          imagePullPolicy: Always
          ports:
            - containerPort: 3000
          env:
            - name: DB_HOST
              valueFrom:
                configMapKeyRef:
                  name: api-config
                  key: DB_HOST
            - name: DB_NAME
              valueFrom:
                configMapKeyRef:
                  name: api-config
                  key: DB_NAME
            - name: DB_PORT
              valueFrom:
                configMapKeyRef:
                  name: api-config
                  key: DB_PORT
            - name: DB_USER
              valueFrom:
                secretKeyRef:
                  name: db-credentials
                  key: DB_USER
            - name: DB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: db-credentials
                  key: DB_PASSWORD
          resources:
            requests:
              memory: "128Mi"
              cpu: "100m"
            limits:
              memory: "256Mi"
              cpu: "200m"
          livenessProbe:
            httpGet:
              path: /api/notes
              port: 3000
            initialDelaySeconds: 30
            periodSeconds: 10
          readinessProbe:
            httpGet:
              path: /api/notes
              port: 3000
            initialDelaySeconds: 5
            periodSeconds: 5
EOF

# 7. Aplicar manifiestos
echo ""
echo "7. Aplicando manifiestos de Kubernetes..."
kubectl apply -f $K8S_DIR/configmap.yml
kubectl apply -f $K8S_DIR/secret-db.yml
kubectl apply -f $K8S_DIR/deployment-api.yml
kubectl apply -f $K8S_DIR/service-api.yml

# 8. Esperar a que los pods estén listos
echo ""
echo "8. Esperando a que los pods estén listos..."
kubectl rollout status deployment/notes-api --timeout=5m

# 9. Mostrar información del servicio
echo ""
echo "========================================="
echo "Despliegue completado"
echo "========================================="
echo ""
kubectl get services
echo ""
echo "Para obtener la URL del LoadBalancer:"
echo "kubectl get service notes-api-svc -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
echo ""
