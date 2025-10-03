const http = require('http');

function testAdminDatabase() {
  console.log('🧪 Probando página /admin-new/database...');
  
  const options = {
    hostname: 'localhost',
    port: 3000,
    path: '/admin-new/database',
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
      const databaseCardsCount = (data.match(/bg-white\/90 backdrop-blur-xl/g) || []).length;
      
      console.log(`✅ HybridNavigation: ${hybridNavigationCount} encontrado(s)`);
      console.log(`✅ LanguageSelector: ${languageSelectorCount} encontrado(s)`);
      console.log(`✅ Database Cards: ${databaseCardsCount} encontrado(s)`);
      
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
      const hasDatabaseTitle = data.includes('Administración de Base de Datos') || data.includes('Database Administration');
      const hasTableExplorer = data.includes('Explorador de Tablas') || data.includes('Table Explorer');
      const hasExportData = data.includes('Exportar Datos') || data.includes('Export Data');
      const hasCreateBackup = data.includes('Crear Respaldo') || data.includes('Create Backup');
      
      console.log(`\n📋 Verificación de contenido:`);
      console.log(`📊 Título de administración: ${hasDatabaseTitle ? 'SÍ' : 'NO'}`);
      console.log(`📊 Explorador de tablas: ${hasTableExplorer ? 'SÍ' : 'NO'}`);
      console.log(`📊 Exportar datos: ${hasExportData ? 'SÍ' : 'NO'}`);
      console.log(`📊 Crear respaldo: ${hasCreateBackup ? 'SÍ' : 'NO'}`);
      
      // Verificar tablas
      const hasUsersTable = data.includes('users');
      const hasInsulinTable = data.includes('insulin_data');
      const hasFoodTable = data.includes('food_data');
      
      console.log(`\n🗄️ Verificación de tablas:`);
      console.log(`📊 Tabla users: ${hasUsersTable ? 'SÍ' : 'NO'}`);
      console.log(`📊 Tabla insulin_data: ${hasInsulinTable ? 'SÍ' : 'NO'}`);
      console.log(`📊 Tabla food_data: ${hasFoodTable ? 'SÍ' : 'NO'}`);
      
      console.log('\n🎉 ¡Prueba completada!');
    });
  });

  req.on('error', (error) => {
    console.error('❌ Error:', error.message);
  });

  req.end();
}

testAdminDatabase();

