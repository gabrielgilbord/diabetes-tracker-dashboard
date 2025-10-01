import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";
import { AuthProvider } from "@/contexts/AuthContext";
import { AppAuthProvider } from "@/contexts/AppAuthContext";
import { LanguageProvider } from "@/contexts/LanguageContext";

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "H2TRAIN Dashboard",
  description: "Panel de administración para el seguimiento de la salud con tecnología H2TRAIN",
  manifest: '/manifest.json',
  icons: {
    icon: '/favicon.svg',
    shortcut: '/favicon.svg',
    apple: '/favicon.svg',
  },
  themeColor: '#2563EB',
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="es">
      <body className={inter.className}>
        <LanguageProvider>
          <AuthProvider>
            <AppAuthProvider>
              {children}
            </AppAuthProvider>
          </AuthProvider>
        </LanguageProvider>
      </body>
    </html>
  );
}
