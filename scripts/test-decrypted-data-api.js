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
          resolve({ 
            status: res.statusCode, 
            headers: res.headers,
            data: jsonData
          })
        } catch (error) {
          resolve({ 
            status: res.statusCode, 
            headers: res.headers,
            data: data.substring(0, 500)
          })
        }
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

async function testDecryptedDataAPI() {
  console.log('🧪 Verificando API de datos descifrados...\n')

  try {
    console.log('📡 Accediendo a /api/decrypted-data...')
    const result = await makeRequest('http://localhost:3002/api/decrypted-data')
    
    if (result.status === 200) {
      console.log('✅ API /api/decrypted-data: OK')
      
      if (typeof result.data === 'object') {
        console.log('\n📊 Datos recibidos:')
        console.log(`   Insulina: ${result.data.insulinData?.length || 0} registros`)
        console.log(`   Comidas: ${result.data.foodData?.length || 0} registros`)
        console.log(`   Ejercicio: ${result.data.exerciseData?.length || 0} registros`)
        console.log(`   Períodos: ${result.data.periodData?.length || 0} registros`)
        console.log(`   Estado de Ánimo: ${result.data.moodData?.length || 0} registros`)
        
        const totalRecords = (result.data.insulinData?.length || 0) + 
                           (result.data.foodData?.length || 0) + 
                           (result.data.exerciseData?.length || 0) + 
                           (result.data.periodData?.length || 0) + 
                           (result.data.moodData?.length || 0)
        console.log(`   Total: ${totalRecords} registros`)
        
        // Mostrar algunos ejemplos
        if (result.data.insulinData?.length > 0) {
          console.log('\n📝 Ejemplo de insulina:')
          console.log('   ', JSON.stringify(result.data.insulinData[0], null, 2).substring(0, 200) + '...')
        }
      } else {
        console.log('❌ Los datos no son un objeto JSON válido')
        console.log('   Respuesta:', result.data)
      }
      
    } else {
      console.log('❌ API /api/decrypted-data: Error HTTP', result.status)
      console.log('   Respuesta:', result.data)
    }
  } catch (error) {
    console.log('❌ Error accediendo a /api/decrypted-data:', error.message)
  }

  console.log('\n🏁 Prueba completada')
}

testDecryptedDataAPI().catch(console.error)

