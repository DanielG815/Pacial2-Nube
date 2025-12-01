@echo off
setlocal

REM Carpeta raíz del proyecto (se creará dentro de la carpeta donde ejecutes el .bat)
set "ROOT=%cd%\proyecto-notas"

echo Creando estructura de proyecto en: %ROOT%
echo.

REM ====== CARPETAS PRINCIPALES ======
mkdir "%ROOT%" 2>nul
mkdir "%ROOT%\app" 2>nul
mkdir "%ROOT%\app\src" 2>nul
mkdir "%ROOT%\app\src\routes" 2>nul
mkdir "%ROOT%\app\src\controllers" 2>nul
mkdir "%ROOT%\app\src\services" 2>nul
mkdir "%ROOT%\app\src\repositories" 2>nul
mkdir "%ROOT%\app\src\db" 2>nul

mkdir "%ROOT%\k8s" 2>nul

mkdir "%ROOT%\infra" 2>nul
mkdir "%ROOT%\infra\modules" 2>nul
mkdir "%ROOT%\infra\modules\network" 2>nul
mkdir "%ROOT%\infra\modules\eks" 2>nul
mkdir "%ROOT%\infra\modules\rds" 2>nul

echo Carpetas creadas.

REM ====== ARCHIVOS APP (backend) ======
REM Archivos JS (vacíos, tu luego pegas el código)
type nul > "%ROOT%\app\src\db\connection.js"
type nul > "%ROOT%\app\src\repositories\notesRepository.js"
type nul > "%ROOT%\app\src\services\notesService.js"
type nul > "%ROOT%\app\src\controllers\notesController.js"
type nul > "%ROOT%\app\src\routes\notesRoutes.js"
type nul > "%ROOT%\app\src\app.js"

REM Otros archivos de app
type nul > "%ROOT%\app\package.json"
type nul > "%ROOT%\app\Dockerfile"

echo Archivos base de la app creados.

REM ====== ARCHIVOS KUBERNETES ======
type nul > "%ROOT%\k8s\deployment-api.yml"
type nul > "%ROOT%\k8s\service-api.yml"
type nul > "%ROOT%\k8s\secret-db.yml"
type nul > "%ROOT%\k8s\configmap.yml"

echo Archivos YAML de Kubernetes creados.

REM ====== ARCHIVOS TERRAFORM ======
type nul > "%ROOT%\infra\main.tf"
type nul > "%ROOT%\infra\variables.tf"
type nul > "%ROOT%\infra\outputs.tf"

type nul > "%ROOT%\infra\modules\network\main.tf"
type nul > "%ROOT%\infra\modules\eks\main.tf"
type nul > "%ROOT%\infra\modules\rds\main.tf"

echo Archivos Terraform creados.

echo.
echo Listo bro, estructura creada en: %ROOT%
pause
endlocal
