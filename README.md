# 🏥 Diabetes Tracker Dashboard - Vercel Deploy Fix

Dashboard administrativo completo para gestionar usuarios y visualizar datos del Polar H10 en tiempo real.

## ✨ Características

### 📊 **Dashboard Principal**
- **Estadísticas en tiempo real**: Total de usuarios, datos del Polar H10, actividad diaria
- **Métricas clave**: Frecuencia cardíaca promedio, usuarios activos, datos de hoy
- **Navegación rápida** a todas las secciones del sistema

### 👥 **Gestión de Usuarios**
- **Lista completa** de usuarios registrados
- **Búsqueda y filtrado** por nombre de usuario
- **Acciones CRUD**: Ver detalles, editar, eliminar usuarios
- **Estadísticas por usuario** con actividad reciente

### 📈 **Datos del Polar H10**
- **Visualización en tiempo real** de frecuencia cardíaca
- **Filtros avanzados**: Por usuario, rango de fechas
- **Gráficos interactivos**: Líneas de tiempo, estadísticas por usuario
- **Exportación a CSV** de todos los datos
- **Tabla detallada** con todos los registros

### 🔍 **Análisis Avanzado**
- **Gráficos temporales** de evolución de FC
- **Distribución por rangos** de frecuencia cardíaca
- **Análisis por hora** del día (patrones de actividad)
- **Ranking de usuarios** más activos
- **Métricas detalladas** por períodos de tiempo

## 🚀 Instalación

### 1. **Clonar el proyecto**
```bash
git clone <tu-repositorio>
cd diabetes-tracker
```

### 2. **Instalar dependencias del Dashboard**
```bash
cd dashboard
npm install
```

### 3. **Configurar variables de entorno**
Crear archivo `.env.local` en la carpeta `dashboard`:
```env
NEXT_PUBLIC_SUPABASE_URL=tu_url_de_supabase_aqui
NEXT_PUBLIC_SUPABASE_ANON_KEY=tu_clave_anonima_de_supabase_aqui
```

### 4. **Obtener credenciales de Supabase**
1. Ve a tu [proyecto de Supabase](https://supabase.com)
2. Ve a **Settings** → **API**
3. Copia la **URL** y **anon key**
4. Pégala en tu archivo `.env.local`

### 5. **Ejecutar el dashboard**
```bash
cd dashboard
npm run dev
```

El dashboard estará disponible en: `http://localhost:3000`

## 🗄️ Configuración de la Base de Datos

### **Tablas Requeridas**

#### 1. **Tabla `users`**
```sql
CREATE TABLE users (
  UserID SERIAL PRIMARY KEY,
  Username VARCHAR(255) UNIQUE NOT NULL,
  PasswordHash VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### 2. **Tabla `polar_data`**
```sql
CREATE TABLE polar_data (
  id SERIAL PRIMARY KEY,
  username VARCHAR(255) NOT NULL,
  timestamp TIMESTAMP NOT NULL,
  heart_rate INTEGER NOT NULL,
  rri_data INTEGER[],
  device_id VARCHAR(255) DEFAULT 'polar_h10',
  data_type VARCHAR(255) DEFAULT 'heart_rate_reading',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### **Políticas de Seguridad (RLS)**
```sql
-- Habilitar RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE polar_data ENABLE ROW LEVEL SECURITY;

-- Política para usuarios (solo lectura para el dashboard)
CREATE POLICY "Users can be read by authenticated users" ON users
  FOR SELECT USING (true);

-- Política para datos del Polar H10 (solo lectura para el dashboard)
CREATE POLICY "Polar data can be read by authenticated users" ON polar_data
  FOR SELECT USING (true);
```

## 🎯 Uso del Dashboard

### **1. Dashboard Principal**
- **Vista general** de todas las métricas del sistema
- **Navegación rápida** a todas las secciones
- **Estadísticas en tiempo real** actualizadas automáticamente

### **2. Gestión de Usuarios**
- **Ver todos los usuarios** registrados en el sistema
- **Buscar usuarios** por nombre
- **Eliminar usuarios** (con confirmación)
- **Ver detalles** de cada usuario

### **3. Datos del Polar H10**
- **Filtrar por usuario** específico
- **Seleccionar rango de fechas** (1 día, 7 días, 30 días, 90 días)
- **Visualizar gráficos** de frecuencia cardíaca
- **Exportar datos** a formato CSV
- **Ver tabla completa** de registros

### **4. Análisis Avanzado**
- **Cambiar período de tiempo** para análisis
- **Gráficos de distribución** por rangos de FC
- **Análisis temporal** de actividad
- **Ranking de usuarios** más activos
- **Exportar análisis** completo

## 🔧 Tecnologías Utilizadas

- **Frontend**: Next.js 15, React 19, TypeScript
- **Styling**: Tailwind CSS 4
- **Gráficos**: Recharts
- **Iconos**: Lucide React
- **Base de Datos**: Supabase (PostgreSQL)
- **Autenticación**: Supabase Auth
- **App Móvil**: Flutter

## 📱 Responsive Design

El dashboard está completamente optimizado para:
- **Desktop** (1200px+)
- **Tablet** (768px - 1199px)
- **Mobile** (320px - 767px)

## 🚀 Despliegue

### **Vercel (Recomendado)**
```bash
cd dashboard
npm run build
vercel --prod
```

### **Docker**
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build
EXPOSE 3000
CMD ["npm", "start"]
```

## 🔒 Seguridad

- **Variables de entorno** para credenciales sensibles
- **Políticas RLS** en Supabase para control de acceso
- **Validación de datos** en el frontend y backend
- **HTTPS obligatorio** en producción

## 📊 Monitoreo y Logs

- **Logs de consola** para debugging
- **Métricas de rendimiento** integradas
- **Errores capturados** y mostrados al usuario
- **Estado de conexión** con Supabase

## 🤝 Contribución

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 🆘 Soporte

Si tienes problemas o preguntas:

1. **Revisa la documentación** de Supabase
2. **Verifica las variables de entorno**
3. **Comprueba la conexión** a la base de datos
4. **Revisa los logs** del navegador

## 🔄 Actualizaciones

Para mantener el dashboard actualizado:

```bash
cd dashboard
npm update
npm audit fix
```

---

**Desarrollado con ❤️ para el seguimiento de diabetes**
