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

async function testAdminSimplified() {
  console.log('🧪 Verificando vista admin simplificada...\n')

  try {
    console.log('📡 Accediendo a /admin...')
    const result = await makeRequest('http://localhost:3002/admin')
    
    if (result.status === 200) {
      console.log('✅ Página /admin: OK')
      
      // Verificar que solo aparece la funcionalidad de base de datos
      const textsToCheck = [
        'Base de Datos',
        'Gestionar Base de Datos',
        'Gestión de Datos',
        'Administración de Base de Datos'
      ]
      
      console.log('\n🔍 Verificando contenido:')
      textsToCheck.forEach(text => {
        if (result.data.includes(text)) {
          console.log(`   ✅ "${text}" - Encontrado`)
        } else {
          console.log(`   ❌ "${text}" - No encontrado`)
        }
      })
      
      // Verificar que NO aparecen las otras funcionalidades
      const removedTexts = [
        'Seguridad Avanzada',
        'Gestión de Roles',
        'Configurar',
        'Administrar'
      ]
      
      console.log('\n🚫 Verificando que se removieron otras funcionalidades:')
      removedTexts.forEach(text => {
        if (result.data.includes(text)) {
          console.log(`   ⚠️ "${text}" - Aún aparece (debería haberse removido)`)
        } else {
          console.log(`   ✅ "${text}" - Correctamente removido`)
        }
      })
      
    } else if (result.status === 302 || result.status === 301) {
      console.log('🔄 Página /admin: Redirección (normal para rutas protegidas)')
      console.log('   Status:', result.status)
      console.log('   Location:', result.headers.location)
    } else {
      console.log('❌ Página /admin: Error HTTP', result.status)
    }
  } catch (error) {
    console.log('❌ Error accediendo a /admin:', error.message)
  }

  console.log('\n🏁 Prueba completada')
}

testAdminSimplified().catch(console.error)

