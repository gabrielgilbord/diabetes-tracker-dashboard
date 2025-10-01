import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'main.dart';
import 'config_service.dart';

class SupabaseAuthService {
  static const String _tokenKey = 'supabase_access_token';
  static const String _userKey = 'supabase_user_data';
  static String get _baseUrl => ConfigService.baseUrl; // URL centralizada
  
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
        final message = responseData['error']?.toString().toLowerCase() ?? '';
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
  static Future<void> handleTokenExpiration(BuildContext context) async {
    print('🔐 Token de Supabase expirado - cerrando sesión automáticamente');
    
    // Limpiar las preferencias de sesión
    await _clearSession();
    
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
  
  /// Limpia solo las preferencias de sesión (token y datos de usuario)
  static Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Solo eliminar las preferencias relacionadas con la sesión de Supabase
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    
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
  
  /// Método de prueba para verificar qué preferencias se mantienen después del logout
  static Future<void> debugPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    print('=== PREFERENCIAS DESPUÉS DEL LOGOUT SUPABASE ===');
    print('device_id: ${prefs.getString('device_id')}');
    print('has_consented: ${prefs.getBool('has_consented')}');
    print('is_first_login: ${prefs.getBool('is_first_login')}');
    print('sexo: ${prefs.getString('sexo')}');
    print('bomba_insulina: ${prefs.getBool('bomba_insulina')}');
    print('supabase_access_token: ${prefs.getString(_tokenKey)}');
    print('supabase_user_data: ${prefs.getString(_userKey)}');
    print('===============================================');
  }
  
  /// Registro de usuario con Supabase
  static Future<Map<String, dynamic>?> register({
    required String email,
    required String password,
    String? username,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/auth/register');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'username': username,
        }),
      );
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data;
      } else {
        final error = json.decode(response.body);
        print('❌ Error en registro: ${error['error']}');
        return null;
      }
    } catch (e) {
      print('❌ Error en registro: $e');
      return null;
    }
  }
  
  /// Login de usuario con Supabase
  static Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/auth/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Guardar token y datos de usuario
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, data['access_token']);
        await prefs.setString(_userKey, json.encode(data['user']));
        
        return data;
      } else {
        final error = json.decode(response.body);
        print('❌ Error en login: ${error['error']}');
        return null;
      }
    } catch (e) {
      print('❌ Error en login: $e');
      return null;
    }
  }
  
  /// Logout de usuario
  static Future<void> logout(BuildContext context) async {
    try {
      final token = await getCurrentToken();
      if (token != null) {
        final url = Uri.parse('$_baseUrl/auth/logout');
        await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }
    } catch (e) {
      print('❌ Error en logout: $e');
    } finally {
      await _clearSession();
      
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }
  
  /// Obtiene el token actual
  static Future<String?> getCurrentToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
  
  /// Obtiene los datos del usuario actual
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      try {
        return json.decode(userData);
      } catch (e) {
        print('❌ Error al decodificar datos de usuario: $e');
      }
    }
    return null;
  }
  
  /// Verifica si el usuario está autenticado
  static Future<bool> isAuthenticated() async {
    final token = await getCurrentToken();
    return token != null && token.isNotEmpty;
  }
  
  /// Verifica la validez del token con el servidor
  static Future<bool> verifyTokenValidity() async {
    try {
      final token = await getCurrentToken();
      if (token == null) return false;
      
      final url = Uri.parse('$_baseUrl/auth/verify');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        return true;
      } else {
        // Token inválido o expirado
        return false;
      }
    } catch (e) {
      print('❌ Error verificando token: $e');
      return false;
    }
  }
  
  /// Migra un usuario existente a Supabase Auth
  static Future<Map<String, dynamic>?> migrateUser({
    required String username,
    required String password,
    required String email,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/auth/migrate');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
          'email': email,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Guardar token y datos de usuario
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, data['access_token']);
        await prefs.setString(_userKey, json.encode(data['user']));
        
        return data;
      } else {
        final error = json.decode(response.body);
        print('❌ Error en migración: ${error['error']}');
        return null;
      }
    } catch (e) {
      print('❌ Error en migración: $e');
      return null;
    }
  }
  
  /// Verifica si el token ha expirado en una respuesta HTTP
  static Future<bool> checkTokenExpiration(int statusCode, String responseBody) async {
    if (_isTokenExpired(statusCode, responseBody)) {
      return true;
    }
    return false;
  }
}
