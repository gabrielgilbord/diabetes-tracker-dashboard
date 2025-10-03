const http = require('http');

function testAdminNew() {
  console.log('🧪 Probando nueva página /admin-new...');
  
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
      console.log('📊 Análisis del HTML:');
      
      // Contar elementos
      const hybridNavigationCount = (data.match(/bg-gradient-to-r from-blue-600/g) || []).length;
      const languageSelectorCount = (data.match(/absolute top-6 right-6/g) || []).length;
      const adminCardsCount = (data.match(/bg-white\/90 backdrop-blur-xl/g) || []).length;
      
      console.log(`✅ HybridNavigation: ${hybridNavigationCount} encontrado(s)`);
      console.log(`✅ LanguageSelector: ${languageSelectorCount} encontrado(s)`);
      console.log(`✅ Admin Cards: ${adminCardsCount} encontrado(s)`);
      
      // Verificar duplicación
      console.log(`\n🔍 Verificación de duplicación:`);
      if (hybridNavigationCount === 1 && languageSelectorCount === 1) {
        console.log('✅ ¡PERFECTO! No hay duplicación');
      } else {
        console.log('❌ PROBLEMA: Hay duplicación');
        console.log(`   - Headers: ${hybridNavigationCount} (debería ser 1)`);
        console.log(`   - LanguageSelectors: ${languageSelectorCount} (debería ser 1)`);
      }
      
      // Verificar contenido
      const hasAdminTitle = data.includes('Administración') || data.includes('Administration');
      const hasDatabaseCard = data.includes('Base de Datos') || data.includes('Database');
      const hasUserManagement = data.includes('Gestión de Usuarios') || data.includes('User Management');
      
      console.log(`\n📋 Verificación de contenido:`);
      console.log(`📊 Título de administración: ${hasAdminTitle ? 'SÍ' : 'NO'}`);
      console.log(`📊 Tarjeta de base de datos: ${hasDatabaseCard ? 'SÍ' : 'NO'}`);
      console.log(`📊 Gestión de usuarios: ${hasUserManagement ? 'SÍ' : 'NO'}`);
      
      console.log('\n🎉 ¡Prueba completada!');
    });
  });

  req.on('error', (error) => {
    console.error('❌ Error:', error.message);
  });

  req.end();
}

testAdminNew();

