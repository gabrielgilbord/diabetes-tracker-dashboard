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

async function testAdminNoDuplicateHeader() {
  console.log('🧪 Verificando que no hay header duplicado en Admin...\n')

  try {
    console.log('📡 Accediendo a /admin...')
    const result = await makeRequest('http://localhost:3002/admin')
    
    if (result.status === 200) {
      console.log('✅ Página /admin: OK')
      
      // Verificar que solo hay un Navigation component
      const navigationCount = (result.data.match(/Navigation/g) || []).length
      console.log(`\n🔍 Número de componentes Navigation: ${navigationCount}`)
      
      if (navigationCount <= 1) {
        console.log('   ✅ Solo un componente Navigation (correcto)')
      } else {
        console.log('   ❌ Múltiples componentes Navigation (duplicación)')
      }
      
      // Verificar que no hay elementos Hero duplicados
      const heroIndicators = [
        'Hero Section',
        'text-6xl md:text-8xl',
        'bg-gradient-to-r from-blue-800 via-blue-600 to-blue-400',
        'inline-flex items-center space-x-3 bg-white/80'
      ]
      
      console.log('\n🚫 Verificando que se removieron elementos Hero duplicados:')
      heroIndicators.forEach(indicator => {
        if (result.data.includes(indicator)) {
          console.log(`   ⚠️ "${indicator}" - Aún aparece (posible duplicación)`)
        } else {
          console.log(`   ✅ "${indicator}" - Correctamente removido`)
        }
      })
      
      // Verificar que la estructura es simple como en users
      const simpleStructureIndicators = [
        'max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12',
        'bg-white/90 backdrop-blur-xl border border-gray-200/50 rounded-3xl',
        'flex items-center justify-between'
      ]
      
      console.log('\n✅ Verificando estructura simplificada:')
      simpleStructureIndicators.forEach(indicator => {
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

testAdminNoDuplicateHeader().catch(console.error)

