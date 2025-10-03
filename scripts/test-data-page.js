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
          data: data.substring(0, 500) // Solo los primeros 500 caracteres
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

async function testDataPage() {
  console.log('🧪 Probando página de Health Data...\n')

  try {
    console.log('📡 Accediendo a /data...')
    const result = await makeRequest('http://localhost:3002/data')
    
    if (result.status === 200) {
      console.log('✅ Página /data: OK')
      console.log('   Headers:', JSON.stringify(result.headers, null, 2))
      console.log('   Contenido (primeros 500 chars):', result.data)
    } else if (result.status === 302 || result.status === 301) {
      console.log('🔄 Página /data: Redirección (normal para rutas protegidas)')
      console.log('   Status:', result.status)
      console.log('   Location:', result.headers.location)
    } else {
      console.log('❌ Página /data: Error HTTP', result.status)
    }
  } catch (error) {
    console.log('❌ Error accediendo a /data:', error.message)
  }

  console.log('\n🏁 Prueba completada')
}

testDataPage().catch(console.error)

