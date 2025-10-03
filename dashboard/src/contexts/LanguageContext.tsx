'use client'

import { createContext, useState, useContext, useEffect, ReactNode } from 'react'
import { Language, translations } from '@/lib/translations'

interface LanguageContextType {
  language: Language
  setLanguage: (language: Language) => void
  t: typeof translations.es
}

const LanguageContext = createContext<LanguageContextType | undefined>(undefined)

export function LanguageProvider({ children }: { children: ReactNode }) {
  // Inicializar con el idioma por defecto para evitar problemas de hidratación
  const [language, setLanguage] = useState<Language>('es')
  const [isClient, setIsClient] = useState(false)

  // Detectar si estamos en el cliente
  useEffect(() => {
    setIsClient(true)
  }, [])

  // Cargar idioma desde localStorage al inicializar (solo después de la hidratación)
  useEffect(() => {
    if (isClient) {
      const savedLanguage = localStorage.getItem('language') as Language
      if (savedLanguage && (savedLanguage === 'es' || savedLanguage === 'en')) {
        setLanguage(savedLanguage)
      }
    }
  }, [isClient])

  // Guardar idioma en localStorage cuando cambie
  const handleSetLanguage = (newLanguage: Language) => {
    setLanguage(newLanguage)
    if (isClient) {
      localStorage.setItem('language', newLanguage)
    }
  }

  const t = translations[language]

  return (
    <LanguageContext.Provider value={{ language, setLanguage: handleSetLanguage, t }}>
      {children}
    </LanguageContext.Provider>
  )
}

export function useLanguage() {
  const context = useContext(LanguageContext)
  if (context === undefined) {
    throw new Error('useLanguage must be used within a LanguageProvider')
  }
  return context
}
