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

async function testAdminNavigationWithLanguage() {
  console.log('🧪 Verificando Navigation con selector de idioma en Admin...\n')

  try {
    console.log('📡 Accediendo a /admin...')
    const result = await makeRequest('http://localhost:3002/admin')
    
    if (result.status === 200) {
      console.log('✅ Página /admin: OK')
      
      // Verificar que el Navigation está presente
      const navigationIndicators = [
        'Navigation',
        'showBackButton',
        'title={t.dashboard.administration}'
      ]
      
      console.log('\n🔍 Verificando componente Navigation:')
      navigationIndicators.forEach(indicator => {
        if (result.data.includes(indicator)) {
          console.log(`   ✅ "${indicator}" - Encontrado`)
        } else {
          console.log(`   ❌ "${indicator}" - No encontrado`)
        }
      })
      
      // Verificar que no hay elementos decorativos comentados
      const commentedElements = [
        'fixed inset-0 pointer-events-none',
        'bg-blue-400 rounded-full mix-blend-multiply',
        'bg-indigo-400 rounded-full mix-blend-multiply',
        'bg-purple-400 rounded-full mix-blend-multiply'
      ]
      
      console.log('\n🚫 Verificando que se removieron elementos decorativos:')
      commentedElements.forEach(element => {
        if (result.data.includes(element)) {
          console.log(`   ⚠️ "${element}" - Aún aparece (debería estar comentado)`)
        } else {
          console.log(`   ✅ "${element}" - Correctamente removido`)
        }
      })
      
      // Verificar estructura limpia
      const cleanStructureIndicators = [
        'max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12',
        'bg-white/90 backdrop-blur-xl border border-gray-200/50 rounded-3xl',
        'flex items-center justify-between'
      ]
      
      console.log('\n✅ Verificando estructura limpia:')
      cleanStructureIndicators.forEach(indicator => {
        if (result.data.includes(indicator)) {
          console.log(`   ✅ "${indicator}" - Encontrado (estructura correcta)`)
        } else {
          console.log(`   ❌ "${indicator}" - No encontrado`)
        }
      })
      
    } else if (result.status === 302 || result.status === 301) {
      console.log('🔄 Página /admin: Redirección (normal para rutas protegidas)')
      console.log('   Status:', result.status)
      console.log('   Location:', result.headers.location)
    } else {
      console.log('❌ Página /admin: Error HTTP', result.status)
    }
  } catch (error) {
    console.log('❌ Error accediendo a /admin:', error.message)
  }

  console.log('\n🏁 Prueba completada')
}

testAdminNavigationWithLanguage().catch(console.error)

