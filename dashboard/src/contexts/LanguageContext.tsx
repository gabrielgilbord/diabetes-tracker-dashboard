'use client'

import { createContext, useContext, ReactNode } from 'react'
import { Language, translations } from '@/lib/translations'

interface LanguageContextType {
  language: Language
  setLanguage: (language: Language) => void
  t: typeof translations.es
}

const LanguageContext = createContext<LanguageContextType | undefined>(undefined)

export function LanguageProvider({ children }: { children: ReactNode }) {
  // Valores por defecto estáticos
  const language: Language = 'es'
  const t = translations.es

  // Función simple para cambiar idioma
  const setLanguage = (newLanguage: Language) => {
    // Por ahora solo log, sin persistencia
    console.log('Language changed to:', newLanguage)
  }

  return (
    <LanguageContext.Provider value={{ language, setLanguage, t }}>
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
