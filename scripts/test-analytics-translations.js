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
          data: data.substring(0, 1000) // Solo los primeros 1000 caracteres
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

async function testAnalyticsTranslations() {
  console.log('🧪 Probando traducciones en Analytics...\n')

  try {
    console.log('📡 Accediendo a /analytics...')
    const result = await makeRequest('http://localhost:3002/analytics')
    
    if (result.status === 200) {
      console.log('✅ Página /analytics: OK')
      
      // Verificar que no hay texto hardcodeado en español
      const spanishTexts = [
        'Tipos de Insulina Utilizados',
        'Promedio de Dosis de Insulina por Día',
        'Distribución de Estado de Ánimo',
        'Evolución de Registros de Insulina',
        'Evolución de Registros de Comidas',
        'Evolución de Registros de Ejercicio',
        'Evolución de Registros de Estado de Ánimo'
      ]
      
      console.log('\n🔍 Verificando textos hardcodeados...')
      let foundHardcoded = false
      
      for (const text of spanishTexts) {
        if (result.data.includes(text)) {
          console.log(`❌ Texto hardcodeado encontrado: "${text}"`)
          foundHardcoded = true
        }
      }
      
      if (!foundHardcoded) {
        console.log('✅ No se encontraron textos hardcodeados en español')
      }
      
      console.log('\n📊 Contenido (primeros 1000 chars):', result.data)
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

testAnalyticsTranslations().catch(console.error)

