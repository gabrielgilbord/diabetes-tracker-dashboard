const http = require('http');

function testAdminSimple() {
  console.log('🧪 Probando estructura final de /admin...');
  
  const options = {
    hostname: 'localhost',
    port: 3000,
    path: '/admin',
    method: 'GET'
  };

  const req = http.request(options, (res) => {
    let data = '';
    
    res.on('data', (chunk) => {
      data += chunk;
    });
    
    res.on('end', () => {
      console.log('📊 Análisis del HTML:');
      
      // Contar elementos
      const hybridNavigationCount = (data.match(/bg-gradient-to-r from-blue-600/g) || []).length;
      const languageSelectorCount = (data.match(/absolute top-6 right-6/g) || []).length;
      const databaseCardCount = (data.match(/bg-white\/90 backdrop-blur-xl/g) || []).length;
      
      console.log(`✅ HybridNavigation: ${hybridNavigationCount} encontrado(s)`);
      console.log(`✅ LanguageSelector: ${languageSelectorCount} encontrado(s)`);
      console.log(`✅ Database Card: ${databaseCardCount} encontrado(s)`);
      
      // Verificar duplicación
      console.log(`\n🔍 Verificación de duplicación:`);
      if (hybridNavigationCount === 1 && languageSelectorCount === 1) {
        console.log('✅ ¡PERFECTO! No hay duplicación');
      } else {
        console.log('❌ PROBLEMA: Hay duplicación');
        console.log(`   - Headers: ${hybridNavigationCount} (debería ser 1)`);
        console.log(`   - LanguageSelectors: ${languageSelectorCount} (debería ser 1)`);
      }
      
      // Verificar traducciones
      const hasSpanishText = data.includes('Gestión de Datos');
      const hasEnglishText = data.includes('Data Management');
      
      console.log(`\n🌐 Verificación de traducciones:`);
      console.log(`📊 Texto en español: ${hasSpanishText ? 'SÍ' : 'NO'}`);
      console.log(`📊 Texto en inglés: ${hasEnglishText ? 'SÍ' : 'NO'}`);
      
      console.log('\n🎉 ¡Prueba completada!');
    });
  });

  req.on('error', (error) => {
    console.error('❌ Error:', error.message);
  });

  req.end();
}

testAdminSimple();

