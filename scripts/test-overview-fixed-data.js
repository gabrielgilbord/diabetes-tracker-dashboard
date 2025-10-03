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

async function testOverviewFixedData() {
  console.log('🧪 Verificando datos corregidos en Overview...\n')

  try {
    console.log('📡 Accediendo a /overview...')
    const result = await makeRequest('http://localhost:3002/overview')
    
    if (result.status === 200) {
      console.log('✅ Página /overview: OK')
      
      // Buscar los valores específicos en las tarjetas
      const patterns = [
        { name: 'Insulina', pattern: /(\d+).*?Insulina/ },
        { name: 'Comidas', pattern: /(\d+).*?Comidas/ },
        { name: 'Ejercicio', pattern: /(\d+).*?Ejercicio/ },
        { name: 'Períodos', pattern: /(\d+).*?Períodos/ },
        { name: 'Estado de Ánimo', pattern: /(\d+).*?Estado de Ánimo/ },
        { name: 'Total Registros', pattern: /Total Registros.*?(\d+)/ }
      ]
      
      console.log('\n🔍 Valores encontrados en las tarjetas:')
      patterns.forEach(({ name, pattern }) => {
        const match = result.data.match(pattern)
        if (match) {
          console.log(`   ${name}: ${match[1]}`)
        } else {
          console.log(`   ${name}: No encontrado`)
        }
      })
      
      // Verificar que los valores no sean 0 (excepto períodos que puede ser 0)
      const expectedValues = {
        'Insulina': 21,
        'Comidas': 34,
        'Ejercicio': 3,
        'Períodos': 0,
        'Estado de Ánimo': 11,
        'Total Registros': 69
      }
      
      console.log('\n📊 Verificando valores esperados:')
      patterns.forEach(({ name, pattern }) => {
        const match = result.data.match(pattern)
        const foundValue = match ? parseInt(match[1]) : 0
        const expectedValue = expectedValues[name]
        
        if (foundValue === expectedValue) {
          console.log(`   ✅ ${name}: ${foundValue} (correcto)`)
        } else {
          console.log(`   ❌ ${name}: ${foundValue} (esperado: ${expectedValue})`)
        }
      })
      
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

testOverviewFixedData().catch(console.error)

