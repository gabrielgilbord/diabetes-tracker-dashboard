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

async function testAdminSingleHeader() {
  console.log('🧪 Verificando header único en Admin...\n')

  try {
    console.log('📡 Accediendo a /admin...')
    const result = await makeRequest('http://localhost:3002/admin')
    
    if (result.status === 200) {
      console.log('✅ Página /admin: OK')
      
      // Verificar que solo hay un Navigation component
      const navigationCount = (result.data.match(/Navigation/g) || []).length
      console.log(`\n🔍 Número de componentes Navigation: ${navigationCount}`)
      
      if (navigationCount === 1) {
        console.log('   ✅ Solo un componente Navigation (correcto)')
      } else {
        console.log(`   ❌ ${navigationCount} componentes Navigation (debería ser 1)`)
      }
      
      // Verificar que no hay LanguageSelector duplicado
      const languageSelectorCount = (result.data.match(/LanguageSelector/g) || []).length
      console.log(`\n🔍 Número de LanguageSelector: ${languageSelectorCount}`)
      
      if (languageSelectorCount <= 1) {
        console.log('   ✅ LanguageSelector no duplicado (correcto)')
      } else {
        console.log(`   ❌ ${languageSelectorCount} LanguageSelector (duplicación)`)
      }
      
      // Verificar que no hay elementos de header duplicados
      const headerIndicators = [
        'absolute top-6 right-6',
        'bg-white/90 backdrop-blur-xl border border-white/30',
        'HTRAIN',
        'Administración',
        'Administration'
      ]
      
      console.log('\n🔍 Verificando elementos de header:')
      headerIndicators.forEach(indicator => {
        const count = (result.data.match(new RegExp(indicator, 'g')) || []).length
        if (count <= 1) {
          console.log(`   ✅ "${indicator}" - ${count} ocurrencias (correcto)`)
        } else {
          console.log(`   ⚠️ "${indicator}" - ${count} ocurrencias (posible duplicación)`)
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

testAdminSingleHeader().catch(console.error)

