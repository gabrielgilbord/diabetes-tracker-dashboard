@echo off
REM Script para resolver el merge sin problemas de paginador
cd /d "C:\Users\ggil_admin\diabetes_tracker"

REM Configurar variables de entorno para desactivar paginador
set GIT_PAGER=cat
set LESS=
set MORE=

echo Limpiando estado de Git...
git reset --hard HEAD

echo Abortando merge...
git merge --abort

echo Actualizando configuración...
git config core.pager ""

echo Configuración de vercel para dashboard...
cd dashboard
echo { > vercel.json
echo   "buildCommand": "npm run build", >> vercel.json
echo   "outputDirectory": ".next", >> vercel.json
echo   "framework": "nextjs", >> vercel.json
echo   "installCommand": "npm install", >> vercel.json
echo   "git": { >> vercel.json
echo     "deploymentEnabled": { >> vercel.json
echo       "main": true >> vercel.json
echo     } >> vercel.json
echo   }, >> vercel.json
echo   "ignoreCommand": "exit 1" >> vercel.json
echo } >> vercel.json

cd ..
git add dashboard/vercel.json
git add dashboard/vercel-build.sh
git commit -m "fix: configurar despliegues automáticos en Vercel"
git push origin main

echo.
echo ¡Completado! Presiona cualquier tecla para cerrar...
pause

