const puppeteer = require('puppeteer');

async function testAdminFinalStructure() {
  console.log('🧪 Probando estructura final de /admin...');
  
  const browser = await puppeteer.launch({ 
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });
  
  try {
    const page = await browser.newPage();
    
    // Navegar a la página admin
    await page.goto('http://localhost:3000/admin', { 
      waitUntil: 'networkidle0',
      timeout: 10000 
    });
    
    // Esperar a que se cargue el contenido
    await page.waitForTimeout(2000);
    
    // Verificar elementos
    const hybridNavigation = await page.$('div[class*="bg-gradient-to-r from-blue-600"]');
    const languageSelector = await page.$('div[class*="absolute top-6 right-6"]');
    const databaseCard = await page.$('div[class*="bg-white/90 backdrop-blur-xl"]');
    
    console.log('📊 Resultados:');
    console.log(`✅ HybridNavigation: ${hybridNavigation ? 'ENCONTRADO' : 'NO ENCONTRADO'}`);
    console.log(`✅ LanguageSelector: ${languageSelector ? 'ENCONTRADO' : 'NO ENCONTRADO'}`);
    console.log(`✅ Database Card: ${databaseCard ? 'ENCONTRADO' : 'NO ENCONTRADO'}`);
    
    // Verificar que NO hay duplicación
    const allLanguageSelectors = await page.$$('div[class*="absolute top-6 right-6"]');
    const allHeaders = await page.$$('div[class*="bg-gradient-to-r from-blue-600"]');
    
    console.log(`\n🔍 Verificación de duplicación:`);
    console.log(`📊 LanguageSelectors encontrados: ${allLanguageSelectors.length}`);
    console.log(`📊 Headers encontrados: ${allHeaders.length}`);
    
    if (allLanguageSelectors.length === 1 && allHeaders.length === 1) {
      console.log('✅ ¡PERFECTO! No hay duplicación');
    } else {
      console.log('❌ PROBLEMA: Hay duplicación');
    }
    
    // Verificar textos traducidos
    const pageContent = await page.content();
    const hasSpanishText = pageContent.includes('Gestión de Datos');
    const hasEnglishText = pageContent.includes('Data Management');
    
    console.log(`\n🌐 Verificación de traducciones:`);
    console.log(`📊 Texto en español: ${hasSpanishText ? 'SÍ' : 'NO'}`);
    console.log(`📊 Texto en inglés: ${hasEnglishText ? 'SÍ' : 'NO'}`);
    
    console.log('\n🎉 ¡Prueba completada!');
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await browser.close();
  }
}

testAdminFinalStructure();

