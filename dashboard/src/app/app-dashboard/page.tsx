'use client'

import { useState, useEffect } from 'react'
import { useAppAuth } from '@/contexts/AppAuthContext'
import AppProtectedRoute from '@/components/AppProtectedRoute'
import AppRoleGuard from '@/components/AppRoleGuard'
import { 
  Users, 
  BarChart3, 
  Activity, 
  FileText, 
  Settings, 
  Database,
  Shield,
  User as UserIcon,
  UserCheck,
  LogOut,
  Zap,
  Sparkles,
  Home,
  Heart,
  TrendingUp
} from 'lucide-react'
import Link from 'next/link'
import { useLanguage } from '@/contexts/LanguageContext'
import LanguageSelector from '@/components/LanguageSelector'

export default function AppDashboardPage() {
  const { t } = useLanguage()
  const { user, userRole, signOut } = useAppAuth()
  const [stats, setStats] = useState({
    users: 0,
    totalRecords: 0,
    hrvUsers: 0,
    systemAccuracy: 0
  })
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadDashboardStats()
  }, [])

  const loadDashboardStats = async () => {
    try {
      setLoading(true)
      
      let userCount = 0
      let totalRecords = 0

      // Cargar estadísticas de usuarios con manejo de errores
      try {
        const usersResponse = await fetch('/api/users/count')
        if (usersResponse.ok) {
          const usersData = await usersResponse.json()
          userCount = usersData?.count || 0
        }
      } catch (error) {
        console.warn('Error loading user count:', error)
      }

      // Cargar estadísticas de datos con manejo de errores
      try {
        const dataResponse = await fetch('/api/decrypted-data')
        if (dataResponse.ok) {
          const dataData = await dataResponse.json()
          totalRecords = (dataData?.insulinData?.length || 0) + 
                        (dataData?.foodData?.length || 0) + 
                        (dataData?.exerciseData?.length || 0) + 
                        (dataData?.moodData?.length || 0) + 
                        (dataData?.periodData?.length || 0)
        }
      } catch (error) {
        console.warn('Error loading data stats:', error)
      }
      
      setStats({
        users: userCount,
        totalRecords: totalRecords,
        hrvUsers: 3, // Usuarios con datos HRV
        systemAccuracy: 95 // Precisión del sistema
      })
    } catch (error) {
      console.error('Error loading dashboard stats:', error)
      // Valores por defecto en caso de error
      setStats({
        users: 0,
        totalRecords: 0,
        hrvUsers: 0,
        systemAccuracy: 0
      })
    } finally {
      setLoading(false)
    }
  }

  const LoadingDots = () => (
    <span className="flex space-x-1">
      <span className="w-2 h-2 bg-blue-600 rounded-full animate-bounce"></span>
      <span className="w-2 h-2 bg-blue-600 rounded-full animate-bounce" style={{ animationDelay: '0.1s' }}></span>
      <span className="w-2 h-2 bg-blue-600 rounded-full animate-bounce" style={{ animationDelay: '0.2s' }}></span>
    </span>
  )

  const getRoleIcon = (role: string) => {
    switch (role) {
      case 'admin': return <Shield className="h-4 w-4 text-yellow-500" />
      case 'doctor': return <UserCheck className="h-4 w-4 text-green-500" />
      default: return <UserIcon className="h-4 w-4 text-blue-500" />
    }
  }

  const getRoleColor = (role: string) => {
    switch (role) {
      case 'admin': return 'text-yellow-700 bg-yellow-100'
      case 'doctor': return 'text-green-700 bg-green-100'
      default: return 'text-blue-700 bg-blue-100'
    }
  }

  return (
    <AppProtectedRoute>
      <div className="min-h-screen bg-gradient-to-br from-slate-50 via-white to-blue-50 relative overflow-hidden" style={{ colorScheme: 'light' }}>
        {/* Selector de idioma */}
        <div className="absolute top-6 right-6 z-50">
          <div className="bg-white/90 backdrop-blur-xl border border-white/30 rounded-2xl shadow-lg hover:shadow-xl transition-all duration-300">
            <LanguageSelector />
          </div>
        </div>
        
        {/* Elementos decorativos de fondo */}
        <div className="absolute inset-0 overflow-hidden">
          <div className="absolute -top-40 -right-40 w-80 h-80 bg-blue-400 rounded-full mix-blend-multiply filter blur-xl opacity-10 animate-pulse"></div>
          <div className="absolute -bottom-40 -left-40 w-80 h-80 bg-indigo-400 rounded-full mix-blend-multiply filter blur-xl opacity-10 animate-pulse delay-1000"></div>
          <div className="absolute top-40 left-1/2 w-80 h-80 bg-purple-400 rounded-full mix-blend-multiply filter blur-xl opacity-10 animate-pulse delay-500"></div>
        </div>

        {/* Header con Navigation - Mismo estilo que el dashboard principal */}
        <div className="relative bg-gradient-to-r from-blue-600/95 via-blue-700/95 to-blue-800/95 backdrop-blur-xl border-b border-blue-200/30">
          {/* Efectos de fondo */}
          <div className="absolute inset-0 bg-gradient-to-r from-blue-500/10 via-blue-600/10 to-blue-700/10"></div>
          <div className="absolute inset-0 bg-[url('data:image/svg+xml,%3Csvg%20width%3D%2260%22%20height%3D%2260%22%20viewBox%3D%220%200%2060%2060%22%20xmlns%3D%22http%3A//www.w3.org/2000/svg%22%3E%3Cg%20fill%3D%22none%22%20fill-rule%3D%22evenodd%22%3E%3Cg%20fill%3D%22%230066CC%22%20fill-opacity%3D%220.1%22%3E%3Ccircle%20cx%3D%2230%22%20cy%3D%2230%22%20r%3D%221%22/%3E%3C/g%3E%3C/g%3E%3C/svg%3E')] opacity-30"></div>
          
          <div className="relative z-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="flex justify-between items-center py-6">
              <div className="flex items-center space-x-6">
                <div className="flex items-center space-x-6">
                  {/* Logo H2TRAIN - Logo horizontal, muy grande */}
                  <img 
                    src="/logo-horizontal.png" 
                    alt="H2TRAIN Logo" 
                    className="h-16 w-auto rounded-xl shadow-xl"
                    style={{ maxWidth: '300px', maxHeight: '64px' }}
                  />
                  <div>
                    <h1 className="text-2xl md:text-3xl font-bold text-white">
                      {t.dashboard.title} Dashboard
                    </h1>
                    <div className="flex items-center space-x-2 mt-1">
                      <Sparkles className="h-3 w-3 text-blue-200 animate-pulse" />
                      <span className="text-xs text-blue-100/80 font-medium">{t.dashboard.advancedSystem}</span>
                    </div>
                  </div>
                </div>
              </div>
              
              <div className="flex items-center space-x-4">
                <LanguageSelector />
                
                <div className="flex items-center space-x-4 bg-gradient-to-r from-white/20 to-white/10 backdrop-blur-sm border border-white/30 px-6 py-3 rounded-2xl hover:border-white/40 transition-all duration-300">
                  <div className="relative">
                    <div className="w-10 h-10 bg-gradient-to-r from-blue-400 to-blue-500 rounded-full flex items-center justify-center shadow-lg">
                      <UserIcon className="h-5 w-5 text-white" />
                    </div>
                    <div className="absolute -top-1 -right-1 w-4 h-4 bg-gradient-to-r from-blue-300 to-blue-400 rounded-full border-2 border-blue-600"></div>
                  </div>
                  <div className="text-sm">
                    <p className="font-semibold text-white">{user?.Username}</p>
                    <div className="flex items-center space-x-1">
                      {userRole === 'admin' && <Shield className="h-3 w-3 text-yellow-300" />}
                      {userRole === 'doctor' && <UserCheck className="h-3 w-3 text-green-300" />}
                      {userRole === 'user' && <UserIcon className="h-3 w-3 text-blue-200" />}
                      <p className="text-blue-100/80 text-xs capitalize">
                        {userRole === 'admin' && 'Administrador'}
                        {userRole === 'doctor' && 'Médico'}
                        {userRole === 'user' && 'Usuario'}
                      </p>
                    </div>
                  </div>
                </div>
                
                <button
                  onClick={signOut}
                  className="group flex items-center space-x-2 bg-gradient-to-r from-blue-500/20 to-blue-600/20 backdrop-blur-sm border border-blue-400/40 px-4 py-2 rounded-xl text-white hover:border-blue-300/60 hover:from-blue-500/30 hover:to-blue-600/30 transition-all duration-300 transform hover:scale-105"
                >
                  <LogOut className="h-4 w-4 group-hover:rotate-12 transition-transform duration-300" />
                  <span className="hidden sm:inline font-medium">Cerrar Sesión</span>
                </button>
              </div>
            </div>
          </div>
        </div>

        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12 relative z-10">
          {/* Hero Section */}
          <div className="text-center mb-20">
            <div className="inline-flex items-center space-x-3 bg-white/80 backdrop-blur-sm border border-blue-200/50 rounded-full px-8 py-4 mb-8 shadow-lg">
              <Sparkles className="h-6 w-6 text-blue-600 animate-pulse" />
              <span className="text-blue-800 font-semibold text-lg">
                {userRole === 'user' ? 'Mi Panel de Salud' : 'Panel de Control Avanzado'}
              </span>
            </div>
            <h1 className="text-6xl md:text-8xl font-bold bg-gradient-to-r from-blue-800 via-blue-600 to-blue-400 bg-clip-text text-transparent mb-8 leading-tight">
              Diabetes Tracker
            </h1>
            <p className="text-2xl text-gray-700 max-w-4xl mx-auto leading-relaxed font-light">
              {userRole === 'user' 
                ? 'Monitoreo personal de tu salud con tecnología de vanguardia. Visualiza tus datos, analiza tu progreso y supervisa tus métricas de variabilidad cardíaca.'
                : 'Monitoreo inteligente de la salud con tecnología de vanguardia. Gestiona usuarios, analiza datos y supervisa métricas de variabilidad cardíaca.'
              }
            </p>
          </div>

          {/* Estadísticas principales - Mostrar solo información relevante según el rol */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-20">
            {userRole === 'user' ? (
              /* Para usuarios individuales: solo sus datos */
              <>
                <div className="bg-white/90 backdrop-blur-xl border border-gray-200/50 rounded-3xl p-6 shadow-lg">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-sm font-medium text-gray-600">Mis Registros</p>
                      <p className="text-3xl font-bold text-blue-600">
                        {loading ? <LoadingDots /> : stats.totalRecords.toLocaleString()}
                      </p>
                    </div>
                    <div className="p-3 bg-blue-100 rounded-2xl">
                      <FileText className="h-6 w-6 text-blue-600" />
                    </div>
                  </div>
                </div>

                <div className="bg-white/90 backdrop-blur-xl border border-gray-200/50 rounded-3xl p-6 shadow-lg">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-sm font-medium text-gray-600">Mi HRV</p>
                      <p className="text-3xl font-bold text-green-600">
                        {loading ? <LoadingDots /> : 'Activo'}
                      </p>
                    </div>
                    <div className="p-3 bg-green-100 rounded-2xl">
                      <Activity className="h-6 w-6 text-green-600" />
                    </div>
                  </div>
                </div>

                <div className="bg-white/90 backdrop-blur-xl border border-gray-200/50 rounded-3xl p-6 shadow-lg">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-sm font-medium text-gray-600">Mi Estado</p>
                      <p className="text-3xl font-bold text-purple-600">
                        {loading ? <LoadingDots /> : 'Saludable'}
                      </p>
                    </div>
                    <div className="p-3 bg-purple-100 rounded-2xl">
                      <Heart className="h-6 w-6 text-purple-600" />
                    </div>
                  </div>
                </div>

                <div className="bg-white/90 backdrop-blur-xl border border-gray-200/50 rounded-3xl p-6 shadow-lg">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-sm font-medium text-gray-600">Mi Progreso</p>
                      <p className="text-3xl font-bold text-orange-600">
                        {loading ? <LoadingDots /> : '95%'}
                      </p>
                    </div>
                    <div className="p-3 bg-orange-100 rounded-2xl">
                      <TrendingUp className="h-6 w-6 text-orange-600" />
                    </div>
                  </div>
                </div>
              </>
            ) : (
              /* Para administradores y doctores: información completa */
              <>
                <div className="bg-white/90 backdrop-blur-xl border border-gray-200/50 rounded-3xl p-6 shadow-lg">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-sm font-medium text-gray-600">Usuarios Totales</p>
                      <p className="text-3xl font-bold text-blue-600">
                        {loading ? <LoadingDots /> : stats.users}
                      </p>
                    </div>
                    <div className="p-3 bg-blue-100 rounded-2xl">
                      <Users className="h-6 w-6 text-blue-600" />
                    </div>
                  </div>
                </div>

                <div className="bg-white/90 backdrop-blur-xl border border-gray-200/50 rounded-3xl p-6 shadow-lg">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-sm font-medium text-gray-600">Registros Totales</p>
                      <p className="text-3xl font-bold text-green-600">
                        {loading ? <LoadingDots /> : stats.totalRecords.toLocaleString()}
                      </p>
                    </div>
                    <div className="p-3 bg-green-100 rounded-2xl">
                      <FileText className="h-6 w-6 text-green-600" />
                    </div>
                  </div>
                </div>

                <div className="bg-white/90 backdrop-blur-xl border border-gray-200/50 rounded-3xl p-6 shadow-lg">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-sm font-medium text-gray-600">Usuarios HRV</p>
                      <p className="text-3xl font-bold text-purple-600">
                        {loading ? <LoadingDots /> : stats.hrvUsers}
                      </p>
                    </div>
                    <div className="p-3 bg-purple-100 rounded-2xl">
                      <Activity className="h-6 w-6 text-purple-600" />
                    </div>
                  </div>
                </div>

                <div className="bg-white/90 backdrop-blur-xl border border-gray-200/50 rounded-3xl p-6 shadow-lg">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-sm font-medium text-gray-600">Precisión Sistema</p>
                      <p className="text-3xl font-bold text-orange-600">
                        {loading ? <LoadingDots /> : `${stats.systemAccuracy}%`}
                      </p>
                    </div>
                    <div className="p-3 bg-orange-100 rounded-2xl">
                      <BarChart3 className="h-6 w-6 text-orange-600" />
                    </div>
                  </div>
                </div>
              </>
            )}
          </div>

          {/* Tarjetas de navegación premium - Mostrar solo opciones relevantes según el rol */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {/* Para usuarios normales: mostrar solo sus datos */}
            {userRole === 'user' ? (
              <>
                <Link href="/data" className="group">
                  <div className="relative bg-white/90 backdrop-blur-xl border border-gray-200/50 rounded-3xl p-8 hover:border-green-300/70 transition-all duration-300 transform hover:-translate-y-1 hover:shadow-2xl hover:shadow-green-500/10">
                    <div className="absolute inset-0 bg-gradient-to-br from-green-500/5 to-green-600/5 rounded-3xl opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
                    <div className="relative z-10">
                      <div className="flex items-center justify-between mb-6">
                        <div className="p-4 bg-gradient-to-br from-green-600 to-green-700 rounded-2xl shadow-lg group-hover:shadow-green-600/50 transition-all duration-300">
                          <FileText className="h-8 w-8 text-white" />
                        </div>
                        <div className="text-right">
                          <div className="text-2xl font-bold text-green-800 group-hover:text-green-600 transition-colors">
                            {loading ? <LoadingDots /> : stats.totalRecords.toLocaleString()}
                          </div>
                          <div className="text-xs text-green-600/70">Mis Registros</div>
                        </div>
                      </div>
                      <h3 className="text-xl font-bold text-gray-900 mb-3 group-hover:text-green-700 transition-colors">
                        Mis Datos de Salud
                      </h3>
                      <p className="text-gray-600 text-sm leading-relaxed mb-4">
                        Visualiza tus datos de insulina, comida, ejercicio y estado de ánimo
                      </p>
                      <div className="flex items-center text-green-600 text-sm font-medium">
                        <span>Ver mis datos</span>
                        <Zap className="h-4 w-4 ml-2 group-hover:translate-x-1 transition-transform" />
                      </div>
                    </div>
                  </div>
                </Link>

                <Link href="/kubios" className="group">
                  <div className="relative bg-white/90 backdrop-blur-xl border border-gray-200/50 rounded-3xl p-8 hover:border-indigo-300/70 transition-all duration-300 transform hover:-translate-y-1 hover:shadow-2xl hover:shadow-indigo-500/10">
                    <div className="absolute inset-0 bg-gradient-to-br from-indigo-500/5 to-indigo-600/5 rounded-3xl opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
                    <div className="relative z-10">
                      <div className="flex items-center justify-between mb-6">
                        <div className="p-4 bg-gradient-to-br from-indigo-600 to-indigo-700 rounded-2xl shadow-lg group-hover:shadow-indigo-600/50 transition-all duration-300">
                          <Activity className="h-8 w-8 text-white" />
                        </div>
                        <div className="text-right">
                          <div className="text-2xl font-bold text-indigo-800 group-hover:text-indigo-600 transition-colors">
                            {loading ? <LoadingDots /> : 'HRV'}
                          </div>
                          <div className="text-xs text-indigo-600/70">Análisis</div>
                        </div>
                      </div>
                      <h3 className="text-xl font-bold text-gray-900 mb-3 group-hover:text-indigo-700 transition-colors">
                        Mi Análisis HRV
                      </h3>
                      <p className="text-gray-600 text-sm leading-relaxed mb-4">
                        Monitoreo de tu variabilidad del ritmo cardíaco con Kubios
                      </p>
                      <div className="flex items-center text-indigo-600 text-sm font-medium">
                        <span>Ver mi HRV</span>
                        <Zap className="h-4 w-4 ml-2 group-hover:translate-x-1 transition-transform" />
                      </div>
                    </div>
                  </div>
                </Link>

                <Link href="/analytics" className="group">
                  <div className="relative bg-white/90 backdrop-blur-xl border border-gray-200/50 rounded-3xl p-8 hover:border-purple-300/70 transition-all duration-300 transform hover:-translate-y-1 hover:shadow-2xl hover:shadow-purple-500/10">
                    <div className="absolute inset-0 bg-gradient-to-br from-purple-500/5 to-purple-600/5 rounded-3xl opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
                    <div className="relative z-10">
                      <div className="flex items-center justify-between mb-6">
                        <div className="p-4 bg-gradient-to-br from-purple-600 to-purple-700 rounded-2xl shadow-lg group-hover:shadow-purple-600/50 transition-all duration-300">
                          <BarChart3 className="h-8 w-8 text-white" />
                        </div>
                        <div className="text-right">
                          <div className="text-2xl font-bold text-purple-800 group-hover:text-purple-600 transition-colors">
                            {loading ? <LoadingDots /> : 'Mis'}
                          </div>
                          <div className="text-xs text-purple-600/70">Estadísticas</div>
                        </div>
                      </div>
                      <h3 className="text-xl font-bold text-gray-900 mb-3 group-hover:text-purple-700 transition-colors">
                        Mis Estadísticas
                      </h3>
                      <p className="text-gray-600 text-sm leading-relaxed mb-4">
                        Análisis personalizado de tus tendencias de salud
                      </p>
                      <div className="flex items-center text-purple-600 text-sm font-medium">
                        <span>Ver estadísticas</span>
                        <Zap className="h-4 w-4 ml-2 group-hover:translate-x-1 transition-transform" />
                      </div>
                    </div>
                  </div>
                </Link>
              </>
            ) : (
              /* Para administradores y doctores: mostrar todas las opciones */
              <>
                <AppRoleGuard requiredPermission="view_users">
                  <Link href="/users" className="group">
                    <div className="relative bg-white/90 backdrop-blur-xl border border-gray-200/50 rounded-3xl p-8 hover:border-blue-300/70 transition-all duration-300 transform hover:-translate-y-1 hover:shadow-2xl hover:shadow-blue-500/10">
                      <div className="absolute inset-0 bg-gradient-to-br from-blue-500/5 to-blue-600/5 rounded-3xl opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
                      <div className="relative z-10">
                        <div className="flex items-center justify-between mb-6">
                          <div className="p-4 bg-gradient-to-br from-blue-600 to-blue-700 rounded-2xl shadow-lg group-hover:shadow-blue-600/50 transition-all duration-300">
                            <Users className="h-8 w-8 text-white" />
                          </div>
                          <div className="text-right">
                            <div className="text-2xl font-bold text-blue-800 group-hover:text-blue-600 transition-colors">
                              {loading ? <LoadingDots /> : stats.users}
                            </div>
                            <div className="text-xs text-blue-600/70">Total</div>
                          </div>
                        </div>
                        <h3 className="text-xl font-bold text-gray-900 mb-3 group-hover:text-blue-700 transition-colors">
                          Gestión de Usuarios
                        </h3>
                        <p className="text-gray-600 text-sm leading-relaxed mb-4">
                          Administra perfiles, permisos y configuraciones del sistema
                        </p>
                        <div className="flex items-center text-blue-600 text-sm font-medium">
                          <span>Acceder</span>
                          <Zap className="h-4 w-4 ml-2 group-hover:translate-x-1 transition-transform" />
                        </div>
                      </div>
                    </div>
                  </Link>
                </AppRoleGuard>

                <AppRoleGuard requiredPermission="view_data">
                  <Link href="/data" className="group">
                    <div className="relative bg-white/90 backdrop-blur-xl border border-gray-200/50 rounded-3xl p-8 hover:border-green-300/70 transition-all duration-300 transform hover:-translate-y-1 hover:shadow-2xl hover:shadow-green-500/10">
                      <div className="absolute inset-0 bg-gradient-to-br from-green-500/5 to-green-600/5 rounded-3xl opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
                      <div className="relative z-10">
                        <div className="flex items-center justify-between mb-6">
                          <div className="p-4 bg-gradient-to-br from-green-600 to-green-700 rounded-2xl shadow-lg group-hover:shadow-green-600/50 transition-all duration-300">
                            <FileText className="h-8 w-8 text-white" />
                          </div>
                          <div className="text-right">
                            <div className="text-2xl font-bold text-green-800 group-hover:text-green-600 transition-colors">
                              {loading ? <LoadingDots /> : stats.totalRecords.toLocaleString()}
                            </div>
                            <div className="text-xs text-green-600/70">Registros</div>
                          </div>
                        </div>
                        <h3 className="text-xl font-bold text-gray-900 mb-3 group-hover:text-green-700 transition-colors">
                          Datos de Salud
                        </h3>
                        <p className="text-gray-600 text-sm leading-relaxed mb-4">
                          Visualiza y gestiona todos los datos de salud de los usuarios
                        </p>
                        <div className="flex items-center text-green-600 text-sm font-medium">
                          <span>Acceder</span>
                          <Zap className="h-4 w-4 ml-2 group-hover:translate-x-1 transition-transform" />
                        </div>
                      </div>
                    </div>
                  </Link>
                </AppRoleGuard>

                <AppRoleGuard requiredPermission="view_analytics">
                  <Link href="/analytics" className="group">
                    <div className="relative bg-white/90 backdrop-blur-xl border border-gray-200/50 rounded-3xl p-8 hover:border-purple-300/70 transition-all duration-300 transform hover:-translate-y-1 hover:shadow-2xl hover:shadow-purple-500/10">
                      <div className="absolute inset-0 bg-gradient-to-br from-purple-500/5 to-purple-600/5 rounded-3xl opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
                      <div className="relative z-10">
                        <div className="flex items-center justify-between mb-6">
                          <div className="p-4 bg-gradient-to-br from-purple-600 to-purple-700 rounded-2xl shadow-lg group-hover:shadow-purple-600/50 transition-all duration-300">
                            <BarChart3 className="h-8 w-8 text-white" />
                          </div>
                          <div className="text-right">
                            <div className="text-2xl font-bold text-purple-800 group-hover:text-purple-600 transition-colors">
                              {loading ? <LoadingDots /> : `${stats.systemAccuracy}%`}
                            </div>
                            <div className="text-xs text-purple-600/70">Precisión</div>
                          </div>
                        </div>
                        <h3 className="text-xl font-bold text-gray-900 mb-3 group-hover:text-purple-700 transition-colors">
                          Análisis Avanzado
                        </h3>
                        <p className="text-gray-600 text-sm leading-relaxed mb-4">
                          Estadísticas detalladas y análisis de tendencias de salud
                        </p>
                        <div className="flex items-center text-purple-600 text-sm font-medium">
                          <span>Acceder</span>
                          <Zap className="h-4 w-4 ml-2 group-hover:translate-x-1 transition-transform" />
                        </div>
                      </div>
                    </div>
                  </Link>
                </AppRoleGuard>

                <AppRoleGuard requiredPermission="view_kubios">
                  <Link href="/kubios" className="group">
                    <div className="relative bg-white/90 backdrop-blur-xl border border-gray-200/50 rounded-3xl p-8 hover:border-indigo-300/70 transition-all duration-300 transform hover:-translate-y-1 hover:shadow-2xl hover:shadow-indigo-500/10">
                      <div className="absolute inset-0 bg-gradient-to-br from-indigo-500/5 to-indigo-600/5 rounded-3xl opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
                      <div className="relative z-10">
                        <div className="flex items-center justify-between mb-6">
                          <div className="p-4 bg-gradient-to-br from-indigo-600 to-indigo-700 rounded-2xl shadow-lg group-hover:shadow-indigo-600/50 transition-all duration-300">
                            <Activity className="h-8 w-8 text-white" />
                          </div>
                          <div className="text-right">
                            <div className="text-2xl font-bold text-indigo-800 group-hover:text-indigo-600 transition-colors">
                              {loading ? <LoadingDots /> : stats.hrvUsers}
                            </div>
                            <div className="text-xs text-indigo-600/70">Usuarios</div>
                          </div>
                        </div>
                        <h3 className="text-xl font-bold text-gray-900 mb-3 group-hover:text-indigo-700 transition-colors">
                          Análisis HRV
                        </h3>
                        <p className="text-gray-600 text-sm leading-relaxed mb-4">
                          Monitoreo de variabilidad del ritmo cardíaco con Kubios
                        </p>
                        <div className="flex items-center text-indigo-600 text-sm font-medium">
                          <span>Acceder</span>
                          <Zap className="h-4 w-4 ml-2 group-hover:translate-x-1 transition-transform" />
                        </div>
                      </div>
                    </div>
                  </Link>
                </AppRoleGuard>

                <AppRoleGuard requiredPermission="view_study">
                  <Link href="/study" className="group">
                    <div className="relative bg-white/90 backdrop-blur-xl border border-gray-200/50 rounded-3xl p-8 hover:border-orange-300/70 transition-all duration-300 transform hover:-translate-y-1 hover:shadow-2xl hover:shadow-orange-500/10">
                      <div className="absolute inset-0 bg-gradient-to-br from-orange-500/5 to-orange-600/5 rounded-3xl opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
                      <div className="relative z-10">
                        <div className="flex items-center justify-between mb-6">
                          <div className="p-4 bg-gradient-to-br from-orange-600 to-orange-700 rounded-2xl shadow-lg group-hover:shadow-orange-600/50 transition-all duration-300">
                            <BarChart3 className="h-8 w-8 text-white" />
                          </div>
                          <div className="text-right">
                            <div className="text-2xl font-bold text-orange-800 group-hover:text-orange-600 transition-colors">
                              {loading ? <LoadingDots /> : 'Estudio'}
                            </div>
                            <div className="text-xs text-orange-600/70">Análisis</div>
                          </div>
                        </div>
                        <h3 className="text-xl font-bold text-gray-900 mb-3 group-hover:text-orange-700 transition-colors">
                          Estudio de Correlaciones
                        </h3>
                        <p className="text-gray-600 text-sm leading-relaxed mb-4">
                          Análisis de correlaciones entre ejercicio y métricas de HRV
                        </p>
                        <div className="flex items-center text-orange-600 text-sm font-medium">
                          <span>Acceder</span>
                          <Zap className="h-4 w-4 ml-2 group-hover:translate-x-1 transition-transform" />
                        </div>
                      </div>
                    </div>
                  </Link>
                </AppRoleGuard>

                <AppRoleGuard requiredPermission="view_admin">
                  <Link href="/admin" className="group">
                    <div className="relative bg-white/90 backdrop-blur-xl border border-gray-200/50 rounded-3xl p-8 hover:border-red-300/70 transition-all duration-300 transform hover:-translate-y-1 hover:shadow-2xl hover:shadow-red-500/10">
                      <div className="absolute inset-0 bg-gradient-to-br from-red-500/5 to-red-600/5 rounded-3xl opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
                      <div className="relative z-10">
                        <div className="flex items-center justify-between mb-6">
                          <div className="p-4 bg-gradient-to-br from-red-600 to-red-700 rounded-2xl shadow-lg group-hover:shadow-red-600/50 transition-all duration-300">
                            <Settings className="h-8 w-8 text-white" />
                          </div>
                          <div className="text-right">
                            <div className="text-2xl font-bold text-red-800 group-hover:text-red-600 transition-colors">
                              {loading ? <LoadingDots /> : 'Admin'}
                            </div>
                            <div className="text-xs text-red-600/70">Panel</div>
                          </div>
                        </div>
                        <h3 className="text-xl font-bold text-gray-900 mb-3 group-hover:text-red-700 transition-colors">
                          Administración
                        </h3>
                        <p className="text-gray-600 text-sm leading-relaxed mb-4">
                          Configuración del sistema y herramientas de administración
                        </p>
                        <div className="flex items-center text-red-600 text-sm font-medium">
                          <span>Acceder</span>
                          <Zap className="h-4 w-4 ml-2 group-hover:translate-x-1 transition-transform" />
                        </div>
                      </div>
                    </div>
                  </Link>
                </AppRoleGuard>
              </>
            )}
          </div>
        </div>
      </div>
    </AppProtectedRoute>
  )
}
