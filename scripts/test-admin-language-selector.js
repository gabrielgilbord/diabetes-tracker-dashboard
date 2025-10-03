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

async function testAdminLanguageSelector() {
  console.log('🧪 Verificando selector de idioma en Admin...\n')

  try {
    console.log('📡 Accediendo a /admin...')
    const result = await makeRequest('http://localhost:3002/admin')
    
    if (result.status === 200) {
      console.log('✅ Página /admin: OK')
      
      // Verificar que el LanguageSelector está presente
      const languageSelectorIndicators = [
        'absolute top-6 right-6',
        'LanguageSelector',
        'bg-white/90 backdrop-blur-xl',
        'rounded-2xl shadow-lg'
      ]
      
      console.log('\n🔍 Verificando selector de idioma:')
      languageSelectorIndicators.forEach(indicator => {
        if (result.data.includes(indicator)) {
          console.log(`   ✅ "${indicator}" - Encontrado`)
        } else {
          console.log(`   ❌ "${indicator}" - No encontrado`)
        }
      })
      
      // Verificar que no hay el selector anterior (flex justify-end)
      const oldSelectorIndicators = [
        'flex justify-end p-6',
        'Header con selector de idioma'
      ]
      
      console.log('\n🚫 Verificando que se removió el selector anterior:')
      oldSelectorIndicators.forEach(indicator => {
        if (result.data.includes(indicator)) {
          console.log(`   ⚠️ "${indicator}" - Aún aparece (debería haberse removido)`)
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

testAdminLanguageSelector().catch(console.error)

