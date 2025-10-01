# 🔧 Configuración de URLs - Diabetes Tracker

## 📋 **Resumen**
Este documento explica cómo cambiar las URLs del backend entre diferentes entornos (local, producción, etc.).

## 🏗️ **Arquitectura de Configuración**

### **Flutter App**
- **Archivo**: `lib/config_service.dart`
- **Función**: Centraliza todas las URLs del backend
- **Cambio**: Modificar `_currentUrl` en `ConfigService`

### **Dashboard (Next.js)**
- **Archivo**: `dashboard/src/lib/config.ts`
- **Función**: Centraliza URLs del backend para el dashboard
- **Cambio**: Modificar `backendUrl` o usar variables de entorno

## 🔄 **Cómo Cambiar Entornos**

### **Para Flutter App**

1. **Abrir**: `lib/config_service.dart`
2. **Cambiar**: La variable `_currentUrl`
3. **Opciones**:
   ```dart
   // Desarrollo local
   static const String _currentUrl = _localUrl;
   
   // Producción
   static const String _currentUrl = _productionUrl;
   
   // Ngrok (para testing)
   static const String _currentUrl = _ngrokUrl;
   
   // Emulador Android
   static const String _currentUrl = _androidEmulatorUrl;
   ```

### **Para Dashboard**

1. **Opción 1 - Variables de entorno**:
   ```bash
   # Crear archivo .env.local en dashboard/
   NEXT_PUBLIC_BACKEND_URL=http://localhost:3000
   ```

2. **Opción 2 - Modificar código**:
   ```typescript
   // En dashboard/src/lib/config.ts
   backendUrl: 'http://localhost:3000', // Cambiar aquí
   ```

## 🌐 **URLs Disponibles**

| Entorno | URL | Descripción |
|---------|-----|-------------|
| **Local** | `http://localhost:3000` | Servidor local |
| **Producción** | `https://diabetes-tracker-backend.vercel.app` | Vercel |
| **Ngrok** | `https://9c94-193-145-130-62.ngrok-free.app` | Túnel ngrok |
| **Android Emulator** | `http://10.0.2.2:3000` | Emulador Android |

## 🚀 **Para Despliegue a Producción**

### **Flutter App**
1. Cambiar en `lib/config_service.dart`:
   ```dart
   static const String _currentUrl = _productionUrl;
   ```

### **Dashboard**
1. Cambiar en `dashboard/.env.local`:
   ```bash
   NEXT_PUBLIC_BACKEND_URL=https://diabetes-tracker-backend.vercel.app
   ```

## 🔍 **Verificación**

### **Flutter App**
- Verificar que `ConfigService.baseUrl` devuelve la URL correcta
- Revisar logs de la app para confirmar peticiones a la URL correcta

### **Dashboard**
- Verificar que `getBackendUrl()` devuelve la URL correcta
- Revisar Network tab en DevTools para confirmar peticiones

## ⚠️ **Notas Importantes**

1. **CORS**: Asegúrate de que el backend tenga configurado CORS para la URL del dashboard
2. **HTTPS**: En producción, usa siempre HTTPS
3. **Variables de entorno**: Para el dashboard, es mejor usar variables de entorno
4. **Testing**: Siempre prueba en local antes de desplegar a producción

## 🛠️ **Troubleshooting**

### **Error de CORS**
- Verificar configuración CORS en `backend/server.js`
- Añadir la URL del dashboard a la lista de orígenes permitidos

### **Error de conexión**
- Verificar que el servidor esté corriendo
- Verificar que la URL sea accesible
- Revisar logs del servidor

### **Error de autenticación**
- Verificar que el token se esté enviando correctamente
- Revisar logs de autenticación en el backend
