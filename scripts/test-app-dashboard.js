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

async function testAppDashboard() {
  console.log('🧪 Probando página de App Dashboard...\n')

  try {
    console.log('📡 Accediendo a /app-dashboard...')
    const result = await makeRequest('http://localhost:3002/app-dashboard')
    
    if (result.status === 200) {
      console.log('✅ Página /app-dashboard: OK')
      console.log('   Headers:', JSON.stringify(result.headers, null, 2))
      console.log('   Contenido (primeros 500 chars):', result.data)
    } else if (result.status === 302 || result.status === 301) {
      console.log('🔄 Página /app-dashboard: Redirección (normal para rutas protegidas)')
      console.log('   Status:', result.status)
      console.log('   Location:', result.headers.location)
    } else {
      console.log('❌ Página /app-dashboard: Error HTTP', result.status)
    }
  } catch (error) {
    console.log('❌ Error accediendo a /app-dashboard:', error.message)
  }

  console.log('\n🏁 Prueba completada')
}

testAppDashboard().catch(console.error)

