import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'supabase_auth_service.dart';
import 'config_service.dart';

class ApiService {
  final String baseUrl = ConfigService.baseUrl;  // URL centralizada
  
  final BuildContext? context;
  
  ApiService({this.context});

  /// Helper method para obtener el token de Supabase
  Future<String?> _getToken() async {
    return await SupabaseAuthService.getCurrentToken();
  }

  /// Helper method para verificar si el token ha expirado
  Future<bool> _checkTokenExpiration(int statusCode, String responseBody) async {
    if (context != null) {
      // Verificar si el token ha expirado
      final isExpired = await SupabaseAuthService.checkTokenExpiration(statusCode, responseBody);
      if (isExpired) {
        await SupabaseAuthService.handleTokenExpiration(context!);
        return false;
      }
    }
    return statusCode == 200;
  }

  // Método para enviar los datos de los formularios
  Future<bool> sendFormData(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/$endpoint');  // Eliminamos la barra extra

    // Obtener token JWT de Supabase
    final token = await _getToken();

    // Preparar headers con token si existe
    final headers = {
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(data),
      );
      print('estamos en el sendFormData');
      
      // Verificar si el token ha expirado
      final isSuccess = await _checkTokenExpiration(response.statusCode, response.body);
      if (!isSuccess) {
        return false;
      }
      
      if (response.statusCode == 200) {
        print('Datos enviados correctamente');
        return true;
      } else {
        print('Error en el login: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

 Future<Map<String, dynamic>?> fetchAllData(String username) async {
  print("entramos a fetchAllData");
  print("username: $username");
  
  final url = Uri.parse('$baseUrl/allData/$username');
  print('la url es: $url');

  // Obtener token JWT
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');

  // Preparar headers con token si existe
  final headers = {
    'ngrok-skip-browser-warning': 'true',
  };
  
  if (token != null) {
    headers['Authorization'] = 'Bearer $token';
  }

  try {
    final response = await http.get(
      url,
      headers: headers,
    );

    // Verificar si el token ha expirado
    final isSuccess = await _checkTokenExpiration(response.statusCode, response.body);
    if (!isSuccess) {
      return null;
    }

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Error al obtener los datos: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error: $e');
    return null;
  }
}

  Future<bool> updateInsulinRecord(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/updateInsulinRecord');

    // Obtener token JWT
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    // Preparar headers con token si existe
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        print('Registro de insulina actualizado correctamente');
        return true;
      } else {
        print('Error al actualizar el registro: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  Future<bool> updateFoodRecord(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/updateFoodRecord');

    // Obtener token JWT
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    // Preparar headers con token si existe
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        print('Registro de comida actualizado correctamente');
        return true;
      } else {
        print('Error al actualizar el registro: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  Future<bool> updateExerciseRecord(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/updateExerciseRecord');

    // Obtener token JWT
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    // Preparar headers con token si existe
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        print('Registro de ejercicio actualizado correctamente');
        return true;
      } else {
        print('Error al actualizar el registro: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  Future<bool> updatePeriodRecord(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/updatePeriodRecord');

    // Obtener token JWT
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    // Preparar headers con token si existe
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        print('Registro de período actualizado correctamente');
        return true;
      } else {
        print('Error al actualizar el registro de período: \\${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getAllData(String username) async {
    // Obtener token JWT
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    // Preparar headers con token si existe
    final headers = <String, String>{};
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/allData/$username'),
        headers: headers,
      );
      
      // Verificar si el token ha expirado
      final isSuccess = await _checkTokenExpiration(response.statusCode, response.body);
      if (!isSuccess) {
        throw Exception('Token expirado - sesión cerrada');
      }
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al obtener los datos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener los datos: $e');
    }
  }

  Future<bool> deleteAllUserData(String username) async {
    final url = Uri.parse('$baseUrl/deleteAllData/$username');

    // Obtener token JWT
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    // Preparar headers con token si existe
    final headers = {
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await http.delete(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        print('Datos eliminados correctamente');
        return true;
      } else {
        print('Error al eliminar los datos: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  // Método para enviar los datos de estado de ánimo
  Future<bool> sendMoodData(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/moodForm');
    
    // Obtener token JWT
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    // Preparar headers con token si existe
    final headers = {
      'Content-Type': 'application/json', 
      'ngrok-skip-browser-warning': 'true',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(data),
      );
      if (response.statusCode == 200) {
        print('Estado de ánimo enviado correctamente');
        return true;
      } else {
        print('Error al enviar estado de ánimo: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  // Método para actualizar un registro de estado de ánimo
  Future<bool> updateMoodRecord(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/updateMoodRecord');
    
    // Obtener token JWT
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    // Preparar headers con token si existe
    final headers = {
      'Content-Type': 'application/json', 
      'ngrok-skip-browser-warning': 'true',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(data),
      );
      if (response.statusCode == 200) {
        print('Registro de estado de ánimo actualizado correctamente');
        return true;
      } else {
        print('Error al actualizar el registro de estado de ánimo: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  // ==================== MÉTODOS DE KUBIOS ====================

  /// Autenticar con Kubios Cloud
  Future<Map<String, dynamic>?> authenticateKubios({
    required String username,
    required String password,
    required String clientId,
  }) async {
    final url = Uri.parse('$baseUrl/kubios/authenticate');
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    final headers = {
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    final data = {
      'username': username,
      'password': password,
      'client_id': clientId,
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Error en autenticación Kubios: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error en autenticación Kubios: $e');
      return null;
    }
  }

  /// Obtener información del usuario de Kubios
  Future<Map<String, dynamic>?> getKubiosUserInfo({
    required String username,
    required String password,
    required String clientId,
  }) async {
    final url = Uri.parse('$baseUrl/kubios/user-info?username=$username&password=$password&client_id=$clientId');
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    final headers = {
      'ngrok-skip-browser-warning': 'true',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Error obteniendo info usuario Kubios: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error obteniendo info usuario Kubios: $e');
      return null;
    }
  }

  /// Obtener mediciones de Kubios
  Future<Map<String, dynamic>?> getKubiosMeasurements({
    required String username,
    required String password,
    required String clientId,
    int limit = 10,
  }) async {
    final url = Uri.parse('$baseUrl/kubios/measurements?username=$username&password=$password&client_id=$clientId&limit=$limit');
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    final headers = {
      'ngrok-skip-browser-warning': 'true',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Error obteniendo mediciones Kubios: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error obteniendo mediciones Kubios: $e');
      return null;
    }
  }

  /// Obtener detalles de una medición específica de Kubios
  Future<Map<String, dynamic>?> getKubiosMeasurementDetails({
    required String measurementId,
    required String username,
    required String password,
    required String clientId,
  }) async {
    final url = Uri.parse('$baseUrl/kubios/measurement/$measurementId?username=$username&password=$password&client_id=$clientId');
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    final headers = {
      'ngrok-skip-browser-warning': 'true',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Error obteniendo detalles medición Kubios: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error obteniendo detalles medición Kubios: $e');
      return null;
    }
  }

  /// Descargar datos de una medición de Kubios
  Future<Map<String, dynamic>?> downloadKubiosMeasurementData({
    required String measurementId,
    required String username,
    required String password,
    required String clientId,
  }) async {
    final url = Uri.parse('$baseUrl/kubios/measurement/$measurementId/download?username=$username&password=$password&client_id=$clientId');
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    final headers = {
      'ngrok-skip-browser-warning': 'true',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Error descargando datos medición Kubios: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error descargando datos medición Kubios: $e');
      return null;
    }
  }

  /// Obtener resultados HRV de Kubios
  Future<Map<String, dynamic>?> getKubiosHrvResults({
    required String username,
    required String password,
    required String clientId,
  }) async {
    final url = Uri.parse('$baseUrl/kubios/hrv-results?username=$username&password=$password&client_id=$clientId');
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    final headers = {
      'ngrok-skip-browser-warning': 'true',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Error obteniendo resultados HRV Kubios: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error obteniendo resultados HRV Kubios: $e');
      return null;
    }
  }

  // ==================== MÉTODOS DE ELIMINACIÓN ====================

  /// Eliminar un registro de insulina específico
  Future<bool> deleteInsulinRecord(String recordId) async {
    final url = Uri.parse('$baseUrl/deleteInsulinRecord/$recordId');
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await http.delete(url, headers: headers);
      
      // Verificar si el token ha expirado
      final isSuccess = await _checkTokenExpiration(response.statusCode, response.body);
      if (!isSuccess) {
        return false;
      }

      if (response.statusCode == 200) {
        print('Registro de insulina eliminado correctamente');
        return true;
      } else {
        print('Error al eliminar registro de insulina: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error eliminando registro de insulina: $e');
      return false;
    }
  }

  /// Eliminar un registro de comida específico
  Future<bool> deleteFoodRecord(String recordId) async {
    final url = Uri.parse('$baseUrl/deleteFoodRecord/$recordId');
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await http.delete(url, headers: headers);
      
      // Verificar si el token ha expirado
      final isSuccess = await _checkTokenExpiration(response.statusCode, response.body);
      if (!isSuccess) {
        return false;
      }

      if (response.statusCode == 200) {
        print('Registro de comida eliminado correctamente');
        return true;
      } else {
        print('Error al eliminar registro de comida: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error eliminando registro de comida: $e');
      return false;
    }
  }

  /// Eliminar un registro de ejercicio específico
  Future<bool> deleteExerciseRecord(String recordId) async {
    final url = Uri.parse('$baseUrl/deleteExerciseRecord/$recordId');
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await http.delete(url, headers: headers);
      
      // Verificar si el token ha expirado
      final isSuccess = await _checkTokenExpiration(response.statusCode, response.body);
      if (!isSuccess) {
        return false;
      }

      if (response.statusCode == 200) {
        print('Registro de ejercicio eliminado correctamente');
        return true;
      } else {
        print('Error al eliminar registro de ejercicio: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error eliminando registro de ejercicio: $e');
      return false;
    }
  }

  /// Eliminar un registro de período específico
  Future<bool> deletePeriodRecord(String recordId) async {
    final url = Uri.parse('$baseUrl/deletePeriodRecord/$recordId');
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await http.delete(url, headers: headers);
      
      // Verificar si el token ha expirado
      final isSuccess = await _checkTokenExpiration(response.statusCode, response.body);
      if (!isSuccess) {
        return false;
      }

      if (response.statusCode == 200) {
        print('Registro de período eliminado correctamente');
        return true;
      } else {
        print('Error al eliminar registro de período: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error eliminando registro de período: $e');
      return false;
    }
  }

  /// Eliminar un registro de estado de ánimo específico
  Future<bool> deleteMoodRecord(String recordId) async {
    final url = Uri.parse('$baseUrl/deleteMoodRecord/$recordId');
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await http.delete(url, headers: headers);
      
      // Verificar si el token ha expirado
      final isSuccess = await _checkTokenExpiration(response.statusCode, response.body);
      if (!isSuccess) {
        return false;
      }

      if (response.statusCode == 200) {
        print('Registro de estado de ánimo eliminado correctamente');
        return true;
      } else {
        print('Error al eliminar registro de estado de ánimo: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error eliminando registro de estado de ánimo: $e');
      return false;
    }
  }
}
