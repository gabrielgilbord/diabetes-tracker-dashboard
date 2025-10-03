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

async function testPieChartLegend() {
  console.log('🧪 Verificando leyenda del gráfico de distribución...\n')

  try {
    console.log('📡 Accediendo a /overview...')
    const result = await makeRequest('http://localhost:3002/overview')
    
    if (result.status === 200) {
      console.log('✅ Página /overview: OK')
      
      // Verificar textos específicos de la leyenda del gráfico
      const legendTexts = [
        'Insulina',
        'Comidas', 
        'Ejercicio',
        'Períodos',
        'Estado de Ánimo'
      ]
      
      console.log('\n🔍 Verificando leyenda del gráfico...')
      let foundHardcoded = false
      
      for (const text of legendTexts) {
        if (result.data.includes(text)) {
          console.log(`❌ Texto hardcodeado encontrado en leyenda: "${text}"`)
          foundHardcoded = true
        } else {
          console.log(`✅ Texto traducido correctamente: "${text}"`)
        }
      }
      
      if (!foundHardcoded) {
        console.log('\n🎉 ¡La leyenda del gráfico está completamente traducida!')
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

testPieChartLegend().catch(console.error)

