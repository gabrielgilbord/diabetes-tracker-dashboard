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
        try {
          const jsonData = JSON.parse(data)
          resolve({ status: res.statusCode, data: jsonData })
        } catch (error) {
          resolve({ status: res.statusCode, data: data, error: 'Invalid JSON' })
        }
      })
    })
    
    req.on('error', (error) => {
      reject(error)
    })
    
    req.setTimeout(5000, () => {
      req.destroy()
      reject(new Error('Timeout'))
    })
  })
}

async function testDashboardAPIs() {
  console.log('🧪 Probando APIs del dashboard...\n')

  const baseUrl = 'http://localhost:3002'
  const apis = [
    { name: 'Users Count', url: '/api/users/count' },
    { name: 'Decrypted Data', url: '/api/decrypted-data' },
    { name: 'Kubios Team Users', url: '/api/kubios/team-users' }
  ]

  for (const api of apis) {
    try {
      console.log(`📡 Probando ${api.name}...`)
      const result = await makeRequest(`${baseUrl}${api.url}`)
      
      if (result.status !== 200) {
        console.log(`❌ ${api.name}: HTTP ${result.status}`)
        continue
      }

      console.log(`✅ ${api.name}: OK`)
      console.log(`   Datos:`, JSON.stringify(result.data, null, 2).substring(0, 200) + '...')
      console.log('')
    } catch (error) {
      console.log(`❌ ${api.name}: Error - ${error.message}`)
      console.log('')
    }
  }

  console.log('🏁 Prueba completada')
}

testDashboardAPIs().catch(console.error)
