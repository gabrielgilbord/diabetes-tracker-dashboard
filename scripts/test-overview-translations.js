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

async function testOverviewTranslations() {
  console.log('🧪 Verificando traducciones en Overview...\n')

  try {
    console.log('📡 Accediendo a /overview...')
    const result = await makeRequest('http://localhost:3002/overview')
    
    if (result.status === 200) {
      console.log('✅ Página /overview: OK')
      
      // Verificar textos específicos que deberían estar traducidos
      const hardcodedTexts = [
        'Resumen General del Sistema',
        'Vista general y métricas principales del sistema de seguimiento de salud',
        'Sistema Activo',
        'Total Usuarios',
        'Total Registros',
        'Promedio Insulina',
        'Estado de Ánimo',
        'unidades por registro',
        'promedio general',
        'Insulina',
        'Comidas',
        'Ejercicio',
        'Períodos',
        'Estado de Ánimo',
        'Alertas del Sistema',
        'Actividad de los Últimos 7 Días',
        'Usuarios Más Activos',
        'Actividad Reciente',
        'Métricas Adicionales del Sistema',
        'Promedio carbohidratos',
        'Registros por usuario',
        'Desconocido'
      ]
      
      console.log('\n🔍 Verificando textos hardcodeados...')
      let foundHardcoded = false
      
      for (const text of hardcodedTexts) {
        if (result.data.includes(text)) {
          console.log(`❌ Texto hardcodeado encontrado: "${text}"`)
          foundHardcoded = true
        } else {
          console.log(`✅ Texto traducido correctamente: "${text}"`)
        }
      }
      
      if (!foundHardcoded) {
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

testOverviewTranslations().catch(console.error)

