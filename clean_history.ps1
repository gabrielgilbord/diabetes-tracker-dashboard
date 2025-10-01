# Script para limpiar archivos grandes del historial de Git
$ErrorActionPreference = "Continue"

Write-Host "Limpiando archivos grandes del historial de Git..." -ForegroundColor Cyan

# Configurar Git sin paginador
$env:GIT_PAGER = ""
git config core.pager ""

# Eliminar archivos del historial
Write-Host "`nEliminando dashboard.zip del historial..." -ForegroundColor Yellow
git filter-branch --force --index-filter "git rm --cached --ignore-unmatch dashboard.zip" --prune-empty --tag-name-filter cat -- --all 2>&1 | Out-Null

Write-Host "Eliminando kub-kubioscloud-demo.zip del historial..." -ForegroundColor Yellow
git filter-branch --force --index-filter "git rm --cached --ignore-unmatch kub-kubioscloud-demo.zip" --prune-empty --tag-name-filter cat -- --all 2>&1 | Out-Null

# Limpiar referencias
Write-Host "`nLimpiando referencias..." -ForegroundColor Yellow
Remove-Item -Path .git/refs/original -Recurse -Force -ErrorAction SilentlyContinue
git reflog expire --expire=now --all 2>&1 | Out-Null
git gc --prune=now --aggressive 2>&1 | Out-Null

# Agregar cambios del .gitignore
Write-Host "`nAgregando .gitignore actualizado..." -ForegroundColor Yellow
git add .gitignore
git add dashboard/vercel.json -ErrorAction SilentlyContinue
git add dashboard/vercel-build.sh -ErrorAction SilentlyContinue

# Hacer commit
Write-Host "`nCreando commit..." -ForegroundColor Yellow
git commit -m "fix: configurar despliegues automáticos y limpiar archivos grandes" 2>&1 | Out-Null

# Push forzado
Write-Host "`nSubiendo cambios a GitHub (force push)..." -ForegroundColor Yellow
git push origin main --force

Write-Host "`n¡Completado exitosamente!" -ForegroundColor Green
Write-Host "`nPresiona cualquier tecla para continuar..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

