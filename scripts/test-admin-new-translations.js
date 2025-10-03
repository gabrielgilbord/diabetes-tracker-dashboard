const http = require('http');

function testAdminNewTranslations() {
  console.log('🧪 Probando traducciones de /admin-new...');
  
  const options = {
    hostname: 'localhost',
    port: 3000,
    path: '/admin-new',
    method: 'GET'
  };

  const req = http.request(options, (res) => {
    let data = '';
    
    res.on('data', (chunk) => {
      data += chunk;
    });
    
    res.on('end', () => {
      console.log('📊 Análisis de traducciones:');
      
      // Verificar textos en español
      const spanishTexts = [
        'Estado del Sistema',
        'Monitoreo en tiempo real',
        'Operativo',
        'Tamaño de Base de Datos',
        'Tiempo de Actividad',
        'Registros Totales',
        'Gestión de Usuarios',
        'Análisis avanzado y reportes del sistema',
        'Configuración del sistema y preferencias'
      ];
      
      // Verificar textos en inglés
      const englishTexts = [
        'System Status',
        'Real-time monitoring',
        'Operational',
        'Database Size',
        'Uptime',
        'Total Records',
        'User Management',
        'Advanced analysis and system reports',
        'System configuration and preferences'
      ];
      
      console.log('\n🇪🇸 Textos en español encontrados:');
      spanishTexts.forEach(text => {
        const found = data.includes(text);
        console.log(`  ${found ? '✅' : '❌'} ${text}`);
      });
      
      console.log('\n🇺🇸 Textos en inglés encontrados:');
      englishTexts.forEach(text => {
        const found = data.includes(text);
        console.log(`  ${found ? '✅' : '❌'} ${text}`);
      });
      
      // Verificar que no hay duplicación de headers
      const headerCount = (data.match(/bg-gradient-to-r from-blue-600/g) || []).length;
      const languageSelectorCount = (data.match(/absolute top-6 right-6/g) || []).length;
      
      console.log(`\n🔍 Verificación de duplicación:`);
      console.log(`📊 Headers: ${headerCount} (debería ser 1)`);
      console.log(`📊 LanguageSelectors: ${languageSelectorCount} (debería ser 1)`);
      
      if (headerCount === 1 && languageSelectorCount === 1) {
        console.log('✅ ¡PERFECTO! No hay duplicación');
      } else {
        console.log('❌ PROBLEMA: Hay duplicación');
      }
      
      console.log('\n🎉 ¡Prueba completada!');
    });
  });

  req.on('error', (error) => {
    console.error('❌ Error:', error.message);
  });

  req.end();
}

testAdminNewTranslations();

