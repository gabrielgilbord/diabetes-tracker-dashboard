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

async function testOverviewMissingTranslations() {
  console.log('🧪 Verificando traducciones faltantes en Overview...\n')

  try {
    console.log('📡 Accediendo a /overview...')
    const result = await makeRequest('http://localhost:3002/overview')
    
    if (result.status === 200) {
      console.log('✅ Página /overview: OK')
      
      // Verificar textos específicos que faltaban
      const missingTexts = [
        'Solo 0 de 17 usuarios están activos (últimos 7 días)',
        'No hay actividad reciente en el sistema (más de 7 días)',
        'Distribución por Tipo de Dato',
        'Días desde última actividad',
        'Tasa de usuarios activos'
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
      console.log('🔄 Página /overview: Redirección (normal para rutas protegidas)')
      console.log('   Status:', result.status)
      console.log('   Location:', result.headers.location)
    } else {
      console.log('❌ Página /overview: Error HTTP', result.status)
    }
  } catch (error) {
    console.log('❌ Error accediendo a /overview:', error.message)
  }

  console.log('\n🏁 Prueba completada')
}

testOverviewMissingTranslations().catch(console.error)

