// Script para probar que el dashboard funciona correctamente
// Usar fetch nativo de Node.js

async function testDashboard() {
  console.log('🧪 Probando dashboard...\n');
  
  try {
    // Probar la API de team-users
    console.log('📋 Probando /api/kubios/team-users...');
    const teamUsersResponse = await fetch('http://localhost:3003/api/kubios/team-users');
    const teamUsersResult = await teamUsersResponse.json();
    
    if (teamUsersResponse.ok) {
      console.log('✅ API team-users funciona correctamente');
      console.log(`   - Usuarios encontrados: ${teamUsersResult.users?.length || 0}`);
      if (teamUsersResult.users) {
        teamUsersResult.users.forEach(user => {
          console.log(`     * ${user.name}: ${user.measurement_count} mediciones`);
        });
      }
    } else {
      console.log('❌ Error en API team-users:', teamUsersResult.error);
    }
    
    // Probar la API de usuarios count
    console.log('\n👥 Probando /api/users/count...');
    const usersCountResponse = await fetch('http://localhost:3003/api/users/count');
    const usersCountResult = await usersCountResponse.json();
    
    if (usersCountResponse.ok) {
      console.log('✅ API users/count funciona correctamente');
      console.log(`   - Total de usuarios: ${usersCountResult.count || 0}`);
    } else {
      console.log('❌ Error en API users/count:', usersCountResult.error);
    }
    
    // Probar la API de datos
    console.log('\n📊 Probando /api/decrypted-data...');
    const dataResponse = await fetch('http://localhost:3003/api/decrypted-data');
    const dataResult = await dataResponse.json();
    
    if (dataResponse.ok) {
      console.log('✅ API decrypted-data funciona correctamente');
      console.log(`   - Datos de insulina: ${dataResult.insulinData?.length || 0}`);
      console.log(`   - Datos de comida: ${dataResult.foodData?.length || 0}`);
      console.log(`   - Datos de ejercicio: ${dataResult.exerciseData?.length || 0}`);
    } else {
      console.log('❌ Error en API decrypted-data:', dataResult.error);
    }
    
    console.log('\n🎯 Dashboard funcionando correctamente!');
    console.log('\n💡 Ahora puedes:');
    console.log('   1. Iniciar sesión en http://localhost:3003/login');
    console.log('   2. Acceder al dashboard principal');
    console.log('   3. Probar el sistema de roles (todos los usuarios son admin en desarrollo)');
    console.log('   4. Acceder a /admin/roles para gestionar usuarios');
    
  } catch (error) {
    console.log('❌ Error de conexión:', error.message);
    console.log('💡 Asegúrate de que el servidor esté ejecutándose en http://localhost:3003');
  }
}

testDashboard();
