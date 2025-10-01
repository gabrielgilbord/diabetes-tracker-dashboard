import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'

const inter = Inter({ subsets: ['latin'] })

// Forzar renderizado dinámico para toda la aplicación
export const dynamic = 'force-dynamic'

export const metadata: Metadata = {
  title: 'Diabetes Tracker Dashboard',
  description: 'Dashboard de administración para el sistema Diabetes Tracker',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="es">
      <body className={inter.className}>
        {children}
      </body>
    </html>
  )
}