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

async function testAdminHybridNavigation() {
  console.log('🧪 Verificando HybridNavigation en Admin (igual que /data)...\n')

  try {
    console.log('📡 Accediendo a /admin...')
    const result = await makeRequest('http://localhost:3002/admin')
    
    if (result.status === 200) {
      console.log('✅ Página /admin: OK')
      
      // Verificar que usa HybridNavigation (igual que /data)
      const hybridNavigationIndicators = [
        'HybridNavigation',
        'showBackButton',
        'title={t.dashboard.administration}'
      ]
      
      console.log('\n🔍 Verificando HybridNavigation:')
      hybridNavigationIndicators.forEach(indicator => {
        if (result.data.includes(indicator)) {
          console.log(`   ✅ "${indicator}" - Encontrado`)
        } else {
          console.log(`   ❌ "${indicator}" - No encontrado`)
        }
      })
      
      // Verificar que LanguageSelector está por separado (igual que /data)
      const languageSelectorIndicators = [
        'LanguageSelector',
        'absolute top-6 right-6 z-20'
      ]
      
      console.log('\n🔍 Verificando LanguageSelector separado:')
      languageSelectorIndicators.forEach(indicator => {
        if (result.data.includes(indicator)) {
          console.log(`   ✅ "${indicator}" - Encontrado`)
        } else {
          console.log(`   ❌ "${indicator}" - No encontrado`)
        }
      })
      
      // Verificar que NO hay Navigation duplicado
      const navigationCount = (result.data.match(/Navigation/g) || []).length
      console.log(`\n🔍 Número de componentes Navigation: ${navigationCount}`)
      
      if (navigationCount <= 1) {
        console.log('   ✅ Solo un componente Navigation (correcto)')
      } else {
        console.log(`   ❌ ${navigationCount} componentes Navigation (duplicación)`)
      }
      
      // Verificar que NO hay LanguageSelector duplicado
      const languageSelectorCount = (result.data.match(/LanguageSelector/g) || []).length
      console.log(`\n🔍 Número de LanguageSelector: ${languageSelectorCount}`)
      
      if (languageSelectorCount === 1) {
        console.log('   ✅ Solo un LanguageSelector (correcto)')
      } else {
        console.log(`   ❌ ${languageSelectorCount} LanguageSelector (duplicación)`)
      }
      
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

testAdminHybridNavigation().catch(console.error)

