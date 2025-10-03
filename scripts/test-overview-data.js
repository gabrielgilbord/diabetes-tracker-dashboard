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

async function testOverviewData() {
  console.log('🧪 Verificando datos en Overview...\n')

  try {
    console.log('📡 Accediendo a /overview...')
    const result = await makeRequest('http://localhost:3002/overview')
    
    if (result.status === 200) {
      console.log('✅ Página /overview: OK')
      
      // Buscar los valores en las tarjetas de estadísticas
      const dataPattern = /(\d+).*?Insulina|(\d+).*?Comidas|(\d+).*?Ejercicio|(\d+).*?Períodos|(\d+).*?Estado de Ánimo/g
      const matches = result.data.match(dataPattern)
      
      console.log('\n🔍 Valores encontrados en las tarjetas:')
      if (matches) {
        matches.forEach(match => console.log(`   ${match}`))
      } else {
        console.log('   No se encontraron valores en las tarjetas')
      }
      
      // Buscar el total de registros
      const totalRecordsMatch = result.data.match(/Total Registros.*?(\d+)/)
      if (totalRecordsMatch) {
        console.log(`\n📊 Total de registros mostrado: ${totalRecordsMatch[1]}`)
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

testOverviewData().catch(console.error)

