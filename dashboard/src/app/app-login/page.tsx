'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { useAppAuth } from '@/contexts/AppAuthContext'
import { User, Lock, Eye, EyeOff, LogIn, Shield, Mail, Activity } from 'lucide-react'
import Image from 'next/image'
import { useLanguage } from '@/contexts/LanguageContext'
import LanguageSelector from '@/components/LanguageSelector'

export default function AppLoginPage() {
  const { t } = useLanguage()
  const [username, setUsername] = useState('')
  const [password, setPassword] = useState('')
  const [showPassword, setShowPassword] = useState(false)
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)
  
  const { signIn } = useAppAuth()
  const router = useRouter()

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError('')
    setLoading(true)

    try {
      const { error } = await signIn(username, password)
      
      if (error) {
        setError(error.message)
      } else {
        // Redirigir al dashboard personalizado
        router.push('/app-dashboard')
      }
    } catch (err) {
      setError(t.auth.unexpectedError)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 via-blue-50 to-indigo-100 flex relative overflow-hidden">
      {/* Selector de idioma mejorado */}
      <div className="absolute top-6 right-6 z-50">
        <div className="bg-white/90 backdrop-blur-xl border border-white/30 rounded-2xl shadow-lg hover:shadow-xl transition-all duration-300">
          <LanguageSelector />
        </div>
      </div>
      
      {/* Elementos decorativos de fondo */}
      <div className="absolute inset-0 overflow-hidden">
        <div className="absolute -top-40 -right-40 w-80 h-80 bg-blue-400 rounded-full mix-blend-multiply filter blur-xl opacity-20 animate-pulse"></div>
        <div className="absolute -bottom-40 -left-40 w-80 h-80 bg-indigo-400 rounded-full mix-blend-multiply filter blur-xl opacity-20 animate-pulse delay-1000"></div>
        <div className="absolute top-40 left-1/2 w-80 h-80 bg-purple-400 rounded-full mix-blend-multiply filter blur-xl opacity-20 animate-pulse delay-500"></div>
      </div>

      {/* Lado izquierdo - Información */}
      <div className="hidden lg:flex lg:w-1/2 bg-gradient-to-br from-blue-600 via-blue-700 to-indigo-800 text-white p-12 flex-col justify-center items-center relative">
        {/* Patrón de fondo */}
        <div className="absolute inset-0 opacity-10">
          <div className="absolute inset-0" style={{
            backgroundImage: `url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%23ffffff' fill-opacity='0.1'%3E%3Ccircle cx='30' cy='30' r='4'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E")`,
          }}></div>
        </div>
        
        <div className="max-w-md relative z-10">
          <div className="mb-12">
            <div className="flex items-center justify-center mb-6">
              <div className="bg-white/20 backdrop-blur-sm p-4 rounded-3xl">
                <Image 
                  src="/logo-horizontal.png?v=10" 
                  alt="H2TRAIN Logo" 
                  width={700}
                  height={250}
                  className="h-32 w-auto rounded-2xl"
                  priority
                />
              </div>
            </div>
            <h1 className="text-5xl font-bold mb-4 text-center bg-gradient-to-r from-white to-blue-100 bg-clip-text text-transparent">
              Diabetes Tracker Dashboard
            </h1>
          </div>
          
          <div className="space-y-8">
            <div className="flex items-start space-x-4 group">
              <div className="bg-white/20 backdrop-blur-sm p-4 rounded-xl group-hover:bg-white/30 transition-all duration-300">
                <User className="h-7 w-7" />
              </div>
              <div>
                <h3 className="font-semibold text-lg mb-2">Acceso Directo</h3>
                <p className="text-blue-100 text-sm leading-relaxed">Inicia sesión con tu nombre de usuario de la aplicación</p>
              </div>
            </div>
            
            <div className="flex items-start space-x-4 group">
              <div className="bg-white/20 backdrop-blur-sm p-4 rounded-xl group-hover:bg-white/30 transition-all duration-300">
                <Shield className="h-7 w-7" />
              </div>
              <div>
                <h3 className="font-semibold text-lg mb-2">Seguridad Avanzada</h3>
                <p className="text-blue-100 text-sm leading-relaxed">Sistema de autenticación seguro sin necesidad de email</p>
              </div>
            </div>
            
            <div className="flex items-start space-x-4 group">
              <div className="bg-white/20 backdrop-blur-sm p-4 rounded-xl group-hover:bg-white/30 transition-all duration-300">
                <Activity className="h-7 w-7" />
              </div>
              <div>
                <h3 className="font-semibold text-lg mb-2">Datos de Salud</h3>
                <p className="text-blue-100 text-sm leading-relaxed">Accede a tus datos de insulina, ejercicio y métricas HRV</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Lado derecho - Formulario */}
      <div className="w-full lg:w-1/2 flex items-center justify-center p-8 relative z-10">
        <div className="w-full max-w-md">
          <div className="text-center mb-10">
            {/* Logo H2TRAIN - Solo visible en móvil */}
            <div className="flex justify-center mb-8 lg:hidden">
              <div className="bg-white/90 backdrop-blur-sm p-6 rounded-2xl shadow-lg border border-white/20">
                <Image 
                  src="/logo-horizontal.png?v=10" 
                  alt="H2TRAIN Logo" 
                  width={300}
                  height={90}
                  className="h-16 w-auto rounded-xl"
                  priority
                />
              </div>
            </div>
            
            <h2 className="text-4xl font-bold text-gray-900 mb-3">
              {t.auth.welcome}
            </h2>
            <p className="text-gray-600 text-lg">
              {t.auth.accessUser}
            </p>
          </div>

          <div className="bg-white/80 backdrop-blur-xl rounded-3xl shadow-2xl p-10 border border-white/20 relative">
            {/* Elemento decorativo */}
            <div className="absolute -top-4 -right-4 w-8 h-8 bg-gradient-to-r from-blue-500 to-indigo-500 rounded-full opacity-20"></div>
            <div className="absolute -bottom-4 -left-4 w-6 h-6 bg-gradient-to-r from-purple-500 to-pink-500 rounded-full opacity-20"></div>
            <form onSubmit={handleSubmit} className="space-y-8">
              {error && (
                <div className="bg-red-50/80 backdrop-blur-sm border border-red-200 text-red-700 px-4 py-4 rounded-xl text-sm flex items-center space-x-2">
                  <div className="w-2 h-2 bg-red-500 rounded-full"></div>
                  <span>{error}</span>
                </div>
              )}

              <div className="space-y-2">
                <label htmlFor="username" className="block text-sm font-semibold text-gray-700">
                  {t.auth.username}
                </label>
                <div className="relative group">
                  <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                    <User className="h-5 w-5 text-gray-400 group-focus-within:text-blue-500 transition-colors" />
                  </div>
                  <input
                    id="username"
                    type="text"
                    value={username}
                    onChange={(e) => setUsername(e.target.value)}
                    required
                    className="block w-full pl-12 pr-4 py-4 bg-white/50 border border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200 text-gray-900 placeholder-gray-500 hover:bg-white/70"
                    placeholder="tu_usuario"
                  />
                </div>
              </div>

              <div className="space-y-2">
                <label htmlFor="password" className="block text-sm font-semibold text-gray-700">
                  {t.auth.password}
                </label>
                <div className="relative group">
                  <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                    <Lock className="h-5 w-5 text-gray-400 group-focus-within:text-blue-500 transition-colors" />
                  </div>
                  <input
                    id="password"
                    type={showPassword ? 'text' : 'password'}
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    required
                    className="block w-full pl-12 pr-12 py-4 bg-white/50 border border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200 text-gray-900 placeholder-gray-500 hover:bg-white/70"
                    placeholder="••••••••"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute inset-y-0 right-0 pr-4 flex items-center hover:bg-gray-50 rounded-r-xl transition-colors"
                  >
                    {showPassword ? (
                      <EyeOff className="h-5 w-5 text-gray-400 hover:text-gray-600" />
                    ) : (
                      <Eye className="h-5 w-5 text-gray-400 hover:text-gray-600" />
                    )}
                  </button>
                </div>
              </div>

              <button
                type="submit"
                disabled={loading}
                className="w-full bg-gradient-to-r from-blue-600 via-blue-700 to-indigo-600 text-white py-4 px-6 rounded-xl font-semibold text-lg hover:from-blue-700 hover:via-blue-800 hover:to-indigo-700 focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition-all duration-300 disabled:opacity-50 disabled:cursor-not-allowed shadow-lg hover:shadow-xl transform hover:-translate-y-0.5"
              >
                {loading ? (
                  <div className="flex items-center justify-center">
                    <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-white mr-3"></div>
                    {t.auth.loggingIn}
                  </div>
                ) : (
                  <div className="flex items-center justify-center">
                    <LogIn className="h-5 w-5 mr-2" />
                    {t.auth.signIn}
                  </div>
                )}
              </button>
            </form>

            <div className="mt-8 space-y-6">
              <button
                type="button"
                className="w-full text-blue-600 hover:text-blue-700 font-semibold transition-colors text-lg"
                disabled
              >
                ¿No tienes cuenta? Regístrate
              </button>
              
              <div className="relative">
                <div className="absolute inset-0 flex items-center">
                  <div className="w-full border-t border-gray-300"></div>
                </div>
                <div className="relative flex justify-center text-sm">
                  <span className="px-4 bg-white/80 text-gray-500">o</span>
                </div>
              </div>
              
              <a
                href="/login"
                className="w-full flex items-center justify-center px-4 py-3 border border-gray-300 rounded-xl text-gray-700 hover:bg-gray-50 transition-colors font-medium"
              >
                <Mail className="h-5 w-5 mr-2" />
                {t.auth.adminAccess}
              </a>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
