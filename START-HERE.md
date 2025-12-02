# 🚀 INSTRUCCIONES DE DESPLIEGUE FINAL

## Tu Proyecto Está Listo ✅

Toda tu infraestructura, aplicación y scripts están configurados correctamente. Solo necesitas ejecutar el despliegue.

---

## Paso 1: Verifica Prerequisitos

Abre PowerShell y ejecuta:

```powershell
# Ir a tu carpeta del proyecto
cd "D:\1. UNAS\8. Octavo Ciclo\DESARROLLO DE APLICACIONES PARA LA NUBE\Parcial2-Nube"

# Verificar herramientas
aws --version
terraform --version
kubectl version --client
docker --version

# Verificar credenciales AWS
aws sts get-caller-identity
```

Si todo muestra información ✅ continúa.

---

## Paso 2: Elige tu Método de Despliegue

### 🎯 Método A: AUTOMÁTICO (Recomendado)

Ejecuta estos comandos en orden:

```powershell
# 1. Inicializar
.\deploy.ps1 -Action terraform-init

# 2. Planificar
.\deploy.ps1 -Action terraform-plan

# 3. Aplicar (ESTO CREA LOS RECURSOS)
.\deploy.ps1 -Action terraform-apply

# 4. Preparar Docker
.\deploy.ps1 -Action ecr-setup
.\deploy.ps1 -Action docker-build
.\deploy.ps1 -Action docker-push

# 5. Configurar Kubernetes
.\deploy.ps1 -Action kubectl-config
.\deploy.ps1 -Action k8s-deploy

# 6. Probar
.\deploy.ps1 -Action test-api
```

### 📖 Método B: MANUAL

Ve a `INICIO-RAPIDO.md` y sigue paso a paso.

### 📚 Método C: INFORMACIÓN COMPLETA

Lee `README-DESPLIEGUE.md` para documentación completa.

---

## ⏱️ Tiempo de Ejecución

```
Terraform init:     ~2 minutos
Terraform plan:     ~3 minutos
Terraform apply:    ~20 minutos ⏳ (ESPERA AQUÍ)
Docker setup:       ~5 minutos
Kubernetes deploy:  ~5 minutos
Test API:           ~2 minutos
─────────────────────────────
TOTAL:             ~37 minutos
```

---

## 📋 Checklist Antes de Empezar

- [ ] AWS CLI configurado con credenciales válidas
- [ ] Terraform instalado (versión >= 1.5.0)
- [ ] kubectl instalado
- [ ] Docker instalado y en ejecución
- [ ] Cuota de recursos en AWS (us-east-1)
- [ ] Repositorio Git sincronizado
- [ ] Terminal PowerShell ejecutándose como administrador

---

## 🎬 Comienza Ahora

```powershell
# Navega a la carpeta
cd "D:\1. UNAS\8. Octavo Ciclo\DESARROLLO DE APLICACIONES PARA LA NUBE\Parcial2-Nube"

# Ver ayuda
.\deploy.ps1 -Action help

# ¡COMIENZA! 🚀
.\deploy.ps1 -Action terraform-init
```

---

## 📞 Si Algo Falla

1. Lee el error cuidadosamente
2. Consulta `README-DESPLIEGUE.md` sección "Troubleshooting"
3. Ejecuta nuevamente - muchos errores se resuelven solos

---

## 🎯 Resultado Final

Después de completar todo tendrás:

✅ VPC en AWS con subnets públicas y privadas
✅ Cluster EKS con 2 nodos
✅ Base de datos PostgreSQL en RDS
✅ Tu aplicación Node.js corriendo en Kubernetes
✅ LoadBalancer exponiendo tu API
✅ Logs y monitoreo habilitados

**URL de tu API:** `http://<loadbalancer-dns>/api/notes`

---

## 🧹 Cuando Termines (IMPORTANTE - Evita Costos)

Para evitar costos innecesarios, destruye todo cuando termines:

```powershell
.\deploy.ps1 -Action destroy

# O manual:
cd proyecto-notas\infra
terraform destroy
```

---

**¡ADELANTE! 🚀 Tu proyecto está listo para desplegar en AWS.**
