#!/bin/bash

# Script para desplegar toda la infraestructura en AWS

set -e

echo "========================================="
echo "Despliegue de Aplicación de Notas en AWS"
echo "========================================="

# Variables
AWS_REGION="${AWS_REGION:-us-east-1}"
PROJECT_NAME="proyecto-notas"
INFRA_DIR="$PROJECT_NAME/infra"

# 1. Inicializar Terraform
echo ""
echo "1. Inicializando Terraform..."
cd $INFRA_DIR
terraform init

# 2. Validar configuración
echo ""
echo "2. Validando configuración de Terraform..."
terraform validate

# 3. Plan
echo ""
echo "3. Creando plan de despliegue..."
terraform plan -out=tfplan

# 4. Apply
echo ""
echo "4. Aplicando cambios..."
read -p "¿Deseas continuar con el despliegue? (yes/no) " -n 3 -r
echo
if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    terraform apply tfplan
else
    echo "Despliegue cancelado"
    exit 1
fi

# 5. Obtener outputs
echo ""
echo "5. Obteniendo información de la infraestructura..."
terraform output

# Guardar outputs
CLUSTER_NAME=$(terraform output -raw eks_cluster_name)
CLUSTER_ENDPOINT=$(terraform output -raw eks_cluster_endpoint)
RDS_ENDPOINT=$(terraform output -raw rds_endpoint)

echo ""
echo "========================================="
echo "Información del Despliegue"
echo "========================================="
echo "Cluster EKS: $CLUSTER_NAME"
echo "Endpoint EKS: $CLUSTER_ENDPOINT"
echo "RDS Endpoint: $RDS_ENDPOINT"
echo "========================================="

cd ../..
