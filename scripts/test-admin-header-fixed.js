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

async function testAdminHeaderFixed() {
  console.log('🧪 Verificando header corregido en Admin...\n')

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
      
      // Verificar que el LanguageSelector está presente
      const languageSelectorIndicators = [
        'LanguageSelector',
        'absolute top-6 right-6',
        'bg-white/90 backdrop-blur-xl'
      ]
      
      console.log('\n🔍 Verificando LanguageSelector:')
      languageSelectorIndicators.forEach(indicator => {
        if (result.data.includes(indicator)) {
          console.log(`   ✅ "${indicator}" - Encontrado`)
        } else {
          console.log(`   ❌ "${indicator}" - No encontrado`)
        }
      })
      
      // Verificar que no hay duplicación
      const duplicateIndicators = [
        'flex justify-end p-6',
        'Header con selector de idioma'
      ]
      
      console.log('\n🚫 Verificando que no hay duplicación:')
      duplicateIndicators.forEach(indicator => {
        if (result.data.includes(indicator)) {
          console.log(`   ⚠️ "${indicator}" - Aún aparece (duplicación)`)
        } else {
          console.log(`   ✅ "${indicator}" - Correctamente removido`)
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

testAdminHeaderFixed().catch(console.error)

