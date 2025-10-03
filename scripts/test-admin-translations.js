const https = require('https')
const http = require('http')

function makeRequest(url) {
  return new Promise((resolve, reject) => {
    const client = url.startsWith('https') ? https : http
    
    const req = client.get(url, (res) => {
      let data = ''
      
      res.on('data', (chunk) => {
        data += chunk
      })
      
      res.on('end', () => {
        resolve({ 
          status: res.statusCode, 
          headers: res.headers,
          data: data
        })
      })
    })
    
    req.on('error', (error) => {
      reject(error)
    })
    
    req.setTimeout(10000, () => {
      req.destroy()
      reject(new Error('Timeout'))
    })
  })
}

async function testAdminTranslations() {
  console.log('🧪 Verificando traducciones en Admin...\n')

  const languages = [
    { code: 'es', name: 'Español' },
    { code: 'en', name: 'English' }
  ]

  for (const lang of languages) {
    try {
      console.log(`📡 Probando ${lang.name} (${lang.code})...`)
      const result = await makeRequest(`http://localhost:3002/admin?lang=${lang.code}`)
      
      if (result.status === 200) {
        console.log(`✅ Página /admin (${lang.name}): OK`)
        
        // Verificar textos específicos según el idioma
        const textsToCheck = lang.code === 'es' ? [
          'Administración de Base de Datos',
          'Gestión de Datos',
          'Base de Datos',
          'Gestiona datos, realiza respaldos y supervisa el rendimiento',
          'Gestionar Base de Datos',
          'Acceder'
        ] : [
          'Database Administration',
          'Data Management',
          'Database',
          'Manage data, perform backups and monitor database performance',
          'Manage Database',
          'Access'
        ]
        
        console.log(`\n🔍 Verificando textos en ${lang.name}:`)
        textsToCheck.forEach(text => {
          if (result.data.includes(text)) {
            console.log(`   ✅ "${text}" - Encontrado`)
          } else {
            console.log(`   ❌ "${text}" - No encontrado`)
          }
        })
        
      } else if (result.status === 302 || result.status === 301) {
        console.log(`🔄 Página /admin (${lang.name}): Redirección (normal para rutas protegidas)`)
        console.log('   Status:', result.status)
        console.log('   Location:', result.headers.location)
      } else {
        console.log(`❌ Página /admin (${lang.name}): Error HTTP`, result.status)
      }
    } catch (error) {
      console.log(`❌ Error accediendo a /admin (${lang.name}):`, error.message)
    }
    
    console.log('') // Línea en blanco entre idiomas
  }

  console.log('🏁 Prueba completada')
}

testAdminTranslations().catch(console.error)

