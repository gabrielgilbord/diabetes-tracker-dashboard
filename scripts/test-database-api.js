// Usar fetch nativo de Node.js (disponible desde Node 18+)

async function testDatabaseAPI() {
  console.log('🔍 Probando API de base de datos...\n');
  
  try {
    // Probar la API de tablas
    console.log('📋 Probando /api/admin/database/tables...');
    const tablesResponse = await fetch('http://localhost:3002/api/admin/database/tables');
    const tablesResult = await tablesResponse.json();
    
    if (tablesResult.success) {
      console.log('✅ API de tablas funciona correctamente');
      console.log(`   - Tablas accesibles: ${tablesResult.accessibleCount}`);
      console.log(`   - Total de registros: ${tablesResult.totalRecords}`);
      console.log(`   - Total de tablas probadas: ${tablesResult.totalCount}`);
      
      // Mostrar todas las tablas para debugging
      console.log(`\n📋 Todas las tablas:`);
      tablesResult.tables.forEach(table => {
        const status = table.accessible ? '✅' : '❌';
        const error = table.error ? ` (${table.error})` : '';
        console.log(`   ${status} ${table.name}: ${table.recordCount} registros${error}`);
      });
      
      const mainTables = tablesResult.tables.filter(t => 
        ['insulindata', 'fooddata', 'exercisedata', 'mooddata', 'periodrecords', 'users'].includes(t.name) && t.accessible
      );
      
      if (mainTables.length > 0) {
        console.log(`\n🎯 Tablas principales con datos:`);
        mainTables.forEach(table => {
          console.log(`     * ${table.name}: ${table.recordCount} registros`);
        });
      } else {
        console.log(`\n⚠️  No se encontraron tablas principales accesibles`);
      }
      
      // Probar la API de datos de tabla
      if (mainTables.length > 0) {
        const testTable = mainTables[0];
        console.log(`\n📄 Probando /api/admin/database/table-data con tabla ${testTable.name}...`);
        
        const dataResponse = await fetch(`http://localhost:3002/api/admin/database/table-data?table=${testTable.name}&limit=5`);
        const dataResult = await dataResponse.json();
        
        if (dataResult.success) {
          console.log('✅ API de datos de tabla funciona correctamente');
          console.log(`   - Registros devueltos: ${dataResult.returnedRecords}`);
          console.log(`   - Total en tabla: ${dataResult.totalRecords}`);
          console.log(`   - Columnas: ${Object.keys(dataResult.data[0] || {}).join(', ')}`);
        } else {
          console.log('❌ Error en API de datos de tabla:', dataResult.error);
        }
      }
      
    } else {
      console.log('❌ Error en API de tablas:', tablesResult.error);
    }
    
  } catch (error) {
    console.log('❌ Error de conexión:', error.message);
    console.log('💡 Asegúrate de que el servidor esté ejecutándose en http://localhost:3002');
  }
}

testDatabaseAPI();
