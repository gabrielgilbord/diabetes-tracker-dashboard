import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'main.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  
  /// Verifica si el token ha expirado basándose en la respuesta del servidor
  static bool _isTokenExpired(int statusCode, String? responseBody) {
    // Si el servidor devuelve 401, el token ha expirado
    if (statusCode == 401) {
      return true;
    }
    
    // También verificar si la respuesta contiene un mensaje de token expirado
    if (responseBody != null) {
      try {
        final responseData = json.decode(responseBody);
        final message = responseData['message']?.toString().toLowerCase() ?? '';
        return message.contains('token') && 
               (message.contains('expired') || 
                message.contains('invalid') || 
                message.contains('unauthorized'));
      } catch (e) {
        // Si no se puede parsear el JSON, continuar con la verificación normal
      }
    }
    
    return false;
  }
  
  /// Maneja la expiración del token cerrando la sesión automáticamente
  static Future<void> _handleTokenExpiration(BuildContext context) async {
    print('🔐 Token expirado - cerrando sesión automáticamente');
    
    // Limpiar las preferencias de sesión
    await _clearSession();
    
    // Debug: mostrar qué preferencias se mantienen
    await debugPreferences();
    
    // Mostrar mensaje al usuario
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tu sesión ha expirado. Por favor, inicia sesión nuevamente.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      
      // Navegar a la pantalla de login
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }
  
  /// Limpia solo las preferencias de sesión (token y username)
  static Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Solo eliminar las preferencias relacionadas con la sesión
    await prefs.remove(_tokenKey);
    await prefs.remove('username');
    
    // Mantener todas las demás preferencias como:
    // - device_id
    // - has_consented
    // - is_first_login
    // - sexo
    // - bomba_insulina
    // - etc.
  }
  
  /// Limpia completamente todas las preferencias (solo para casos especiales)
  static Future<void> _clearAllPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final deviceId = prefs.getString('device_id');
    
    // Limpiar todas las preferencias excepto el device_id
    await prefs.clear();
    if (deviceId != null) {
      await prefs.setString('device_id', deviceId);
    }
  }
  
  /// Verifica y maneja la respuesta de una petición HTTP
  /// Retorna true si la petición fue exitosa, false si hubo error
  static Future<bool> handleHttpResponse(
    BuildContext context,
    int statusCode,
    String? responseBody,
  ) async {
    if (_isTokenExpired(statusCode, responseBody)) {
      await _handleTokenExpiration(context);
      return false;
    }
    
    return statusCode == 200;
  }
  
  /// Obtiene el token actual del usuario
  static Future<String?> getCurrentToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
  
  /// Verifica si el usuario está autenticado
  static Future<bool> isAuthenticated() async {
    final token = await getCurrentToken();
    return token != null && token.isNotEmpty;
  }
  
  /// Cierra la sesión del usuario manualmente (mantiene preferencias del perfil)
  static Future<void> logout(BuildContext context) async {
    await _clearSession();
    
    // Debug: mostrar qué preferencias se mantienen
    await debugPreferences();
    
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }
  
  /// Cierra la sesión y limpia todas las preferencias (para casos como revocar consentimiento)
  static Future<void> logoutAndClearAll(BuildContext context) async {
    await _clearAllPreferences();
    
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }
  
  /// Verifica si el token está próximo a expirar (opcional - para futuras mejoras)
  /// Este método puede ser usado para mostrar advertencias al usuario
  static Future<bool> isTokenNearExpiration() async {
    // Por ahora, siempre retornamos false ya que no tenemos información
    // sobre la duración del token desde el servidor
    // En el futuro, se puede implementar lógica para verificar la fecha de expiración
    return false;
  }
  
  /// Verifica la validez del token haciendo una petición de prueba
  static Future<bool> verifyTokenValidity(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      final username = prefs.getString('username');
      
      if (token == null || username == null) {
        return false;
      }
      
      // Hacer una petición simple para verificar el token
      final response = await http.get(
        Uri.parse('https://diabetes-tracker-backend.vercel.app/allData/$username'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      // Si el token ha expirado, manejar la expiración
      if (_isTokenExpired(response.statusCode, response.body)) {
        await _handleTokenExpiration(context);
        return false;
      }
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error verificando token: $e');
      return false;
    }
  }
  
  /// Método de prueba para verificar qué preferencias se mantienen después del logout
  static Future<void> debugPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    print('=== PREFERENCIAS DESPUÉS DEL LOGOUT ===');
    print('device_id: ${prefs.getString('device_id')}');
    print('has_consented: ${prefs.getBool('has_consented')}');
    print('is_first_login: ${prefs.getBool('is_first_login')}');
    print('sexo: ${prefs.getString('sexo')}');
    print('bomba_insulina: ${prefs.getBool('bomba_insulina')}');
    print('auth_token: ${prefs.getString('auth_token')}');
    print('username: ${prefs.getString('username')}');
    print('=====================================');
  }
}
