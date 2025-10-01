// Servicio de configuración centralizado para Flutter
class ConfigService {
  // URLs del backend
  static const String _localUrl = 'http://localhost:3000';
  static const String _productionUrl = 'https://diabetes-tracker-backend.vercel.app';
  static const String _ngrokUrl = 'https://9c94-193-145-130-62.ngrok-free.app';
  static const String _androidEmulatorUrl = 'http://10.0.2.2:3000';
  
  // URL actual (cambiar aquí para diferentes entornos)
  static const String _currentUrl = _productionUrl;
  
  /// Obtiene la URL base del backend
  static String get baseUrl => _currentUrl;
  
  /// Obtiene la URL para el emulador de Android
  static String get androidEmulatorUrl => _androidEmulatorUrl;
  
  /// Obtiene la URL de producción
  static String get productionUrl => _productionUrl;
  
  /// Obtiene la URL de ngrok
  static String get ngrokUrl => _ngrokUrl;
  
  /// Obtiene la URL local
  static String get localUrl => _localUrl;
  
  /// Verifica si estamos usando la URL local
  static bool get isLocal => _currentUrl == _localUrl;
  
  /// Verifica si estamos usando la URL de producción
  static bool get isProduction => _currentUrl == _productionUrl;
  
  /// Obtiene headers comunes para las peticiones
  static Map<String, String> get commonHeaders => {
    'Content-Type': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };
  
  /// Obtiene headers para peticiones autenticadas
  static Map<String, String> getAuthHeaders(String token) => {
    ...commonHeaders,
    'Authorization': 'Bearer $token',
  };
}
