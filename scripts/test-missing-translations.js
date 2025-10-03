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

async function testMissingTranslations() {
  console.log('🧪 Verificando traducciones faltantes en Analytics...\n')

  try {
    console.log('📡 Accediendo a /analytics...')
    const result = await makeRequest('http://localhost:3002/analytics')
    
    if (result.status === 200) {
      console.log('✅ Página /analytics: OK')
      
      // Verificar textos específicos que faltaban
      const missingTexts = [
        'Tipos de Comida Registrados',
        'Actividad General por Fecha'
      ]
      
      console.log('\n🔍 Verificando textos que faltaban...')
      let foundMissing = false
      
      for (const text of missingTexts) {
        if (result.data.includes(text)) {
          console.log(`❌ Texto hardcodeado encontrado: "${text}"`)
          foundMissing = true
        } else {
          console.log(`✅ Texto traducido correctamente: "${text}"`)
        }
      }
      
      if (!foundMissing) {
        console.log('\n🎉 ¡Todos los textos están traducidos correctamente!')
      }
      
    } else if (result.status === 302 || result.status === 301) {
      console.log('🔄 Página /analytics: Redirección (normal para rutas protegidas)')
      console.log('   Status:', result.status)
      console.log('   Location:', result.headers.location)
    } else {
      console.log('❌ Página /analytics: Error HTTP', result.status)
    }
  } catch (error) {
    console.log('❌ Error accediendo a /analytics:', error.message)
  }

  console.log('\n🏁 Prueba completada')
}

testMissingTranslations().catch(console.error)

