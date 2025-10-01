import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class BackgroundService {
  static const String _serviceId = 'diabetes_tracker_service';
  static const String _notificationTitle = 'Diabetes Tracker';
  static const String _notificationContent = 'Recogiendo datos del Polar H10...';
  
  // UUIDs específicos del Polar H10
  static const String polarServiceUuid = "6e400001-b5a3-f393-e0a9-e50e24dcca9e"; // Nordic UART
  static const String polarCharUuid = "6e400003-b5a3-f393-e0a9-e50e24dcca9e"; // RX characteristic
  static const String hrServiceUuid = "0000180d-0000-1000-8000-00805f9b34fb";
  static const String hrCharUuid = "00002a37-0000-1000-8000-00805f9b34fb";

  static Future<void> initializeService() async {
    // Verificar si estamos en una plataforma soportada
    if (kIsWeb) {
      print("FlutterBackgroundService no es compatible con web");
      return;
    }

    try {
      final service = FlutterBackgroundService();

      // Configurar el servicio con configuración mínima para evitar problemas
      await service.configure(
        androidConfiguration: AndroidConfiguration(
          onStart: onStart,
          autoStart: false,
          isForegroundMode: false, // Deshabilitado para evitar problemas con Android 14+
          notificationChannelId: 'diabetes_tracker_channel',
          initialNotificationTitle: _notificationTitle,
          initialNotificationContent: _notificationContent,
          foregroundServiceNotificationId: 888,
        ),
        iosConfiguration: IosConfiguration(
          autoStart: false,
          onForeground: onStart,
          onBackground: onIosBackground,
        ),
      );

      service.startService();
      print("Servicio de fondo inicializado correctamente en ${getPlatformInfo()}");
    } catch (e) {
      print("Error inicializando FlutterBackgroundService: $e");
      // Continuar sin servicio de fondo - la app seguirá funcionando
    }
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    print("Servicio de fondo iniciado");
    
    // Solo para Android
    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        try {
          service.setAsForegroundService();
          print("Servicio establecido como foreground");
        } catch (e) {
          print("Error estableciendo foreground service: $e");
          // Continuar sin foreground service
        }
      });

      service.on('setAsBackground').listen((event) {
        try {
          service.setAsBackgroundService();
          print("Servicio establecido como background");
        } catch (e) {
          print("Error estableciendo background service: $e");
        }
      });
    }

    service.on('stopService').listen((event) {
      print("Deteniendo servicio de fondo");
      service.stopSelf();
    });

    // Inicializar Bluetooth
    await _initializeBluetooth();
    
    // Bucle principal del servicio
    Timer.periodic(const Duration(seconds: 30), (timer) async {
      try {
        await _collectAndUploadData();
      } catch (e) {
        print("Error en bucle de recogida de datos: $e");
      }
    });
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      DartPluginRegistrant.ensureInitialized();
      
      // En iOS, el background service tiene limitaciones de tiempo
      // Solo ejecutar tareas críticas
      await _collectAndUploadData();
      
      return true;
    } catch (e) {
      print("Error en iOS background service: $e");
      return false;
    }
  }

  static Future<void> _initializeBluetooth() async {
    try {
      // Verificar si estamos en web
      if (kIsWeb) {
        print("Bluetooth no disponible en web");
        return;
      }

      // Verificar si Bluetooth está habilitado
      if (await FlutterBluePlus.isSupported == false) {
        print("Bluetooth no soportado");
        return;
      }

      // En iOS, no necesitamos "encender" Bluetooth explícitamente
      // Solo verificar el estado
      if (await FlutterBluePlus.isOn) {
        print("Bluetooth ya está habilitado");
      } else {
        print("Bluetooth no está habilitado");
        // En iOS, el usuario debe habilitar Bluetooth manualmente
        return;
      }
      
      print("Bluetooth inicializado en background service");
    } catch (e) {
      print("Error inicializando Bluetooth: $e");
    }
  }

  static Future<void> _collectAndUploadData() async {
    try {
      final logMessage = "🔄 Iniciando recogida de datos del Polar H10...";
      print(logMessage);
      await _addToLog(logMessage);
      
      // Verificar si estamos en web
      if (kIsWeb) {
        final webMessage = "❌ Recogida de datos no disponible en web";
        print(webMessage);
        await _addToLog(webMessage);
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final isCollecting = prefs.getBool('is_collecting_data') ?? false;
      
      if (!isCollecting) {
        final pauseMessage = "⏸️ No está recogiendo datos automáticamente";
        print(pauseMessage);
        await _addToLog(pauseMessage);
        return; // No está recogiendo datos
      }

      final activeMessage = "✅ Recogida automática activada";
      print(activeMessage);
      await _addToLog(activeMessage);

      // En iOS, verificar si Bluetooth está disponible
      if (!(await FlutterBluePlus.isOn)) {
        final btMessage = "❌ Bluetooth no está habilitado";
        print(btMessage);
        await _addToLog(btMessage);
        return;
      }

      final btOkMessage = "✅ Bluetooth habilitado";
      print(btOkMessage);
      await _addToLog(btOkMessage);
      final connectedDevices = FlutterBluePlus.connectedDevices;
      if (connectedDevices.isEmpty) {
        final noDevicesMessage = "❌ No hay dispositivos conectados";
        print(noDevicesMessage);
        await _addToLog(noDevicesMessage);
        return;
      }

      final devicesMessage = "📱 Dispositivos conectados: ${connectedDevices.length}";
      print(devicesMessage);
      await _addToLog(devicesMessage);

      // Buscar específicamente el Polar H10
      BluetoothDevice? polarDevice;
      for (var device in connectedDevices) {
        final checkMessage = "🔍 Verificando dispositivo: ${device.name}";
        print(checkMessage);
        await _addToLog(checkMessage);
        
        if (device.name.toLowerCase().contains('polar') || 
            device.name.toLowerCase().contains('h10')) {
          polarDevice = device;
          final foundMessage = "✅ Polar H10 encontrado: ${device.name}";
          print(foundMessage);
          await _addToLog(foundMessage);
          break;
        }
      }

      if (polarDevice == null) {
        final notFoundMessage = "❌ No se encontró dispositivo Polar H10 conectado";
        print(notFoundMessage);
        await _addToLog(notFoundMessage);
        return;
      }

      // Recoger datos del Polar H10
      final readingMessage = "📊 Leyendo datos del Polar H10...";
      print(readingMessage);
      await _addToLog(readingMessage);
      
      final data = await _readPolarH10Data(polarDevice);
      
      if (data != null) {
        final successMessage = "✅ Datos leídos correctamente: HR=${data['heart_rate']} bpm";
        print(successMessage);
        await _addToLog(successMessage);
        await _uploadDataToCloud(data);
      } else {
        final errorMessage = "❌ No se pudieron leer datos del Polar H10";
        print(errorMessage);
        await _addToLog(errorMessage);
      }
      
    } catch (e) {
      print("❌ Error en recogida de datos: $e");
    }
  }

  static Future<Map<String, dynamic>?> _readPolarH10Data(BluetoothDevice device) async {
    try {
      // Buscar el servicio de frecuencia cardíaca del Polar H10
      final services = await device.discoverServices();
      
      for (var service in services) {
        // Buscar características de frecuencia cardíaca
        for (var characteristic in service.characteristics) {
          final charUuid = characteristic.uuid.toString().toLowerCase();
          
          // Característica de frecuencia cardíaca (UUID largo o corto)
          if (charUuid == hrCharUuid || charUuid.endsWith('2a37')) {
            if (characteristic.properties.read) {
              try {
                final value = await characteristic.read();
                if (value.isNotEmpty) {
                  // Procesar datos del Polar H10
                  return _processPolarH10Data(value);
                }
              } catch (e) {
                print("Error leyendo característica de frecuencia cardíaca: $e");
              }
            }
          }
        }
      }
    } catch (e) {
      print("Error leyendo datos del Polar H10: $e");
    }
    return null;
  }

  static Map<String, dynamic> _processPolarH10Data(List<int> rawData) {
    // Procesar datos según el protocolo del Polar H10
    final timestamp = DateTime.now().toIso8601String();
    
    if (rawData.isNotEmpty) {
      int flags = rawData[0];
      int offset = 1;
      int heartRate;
      List<int> rriData = [];
      
      // Extraer frecuencia cardíaca
      if ((flags & 0x01) == 0) {
        heartRate = rawData[offset];
        offset += 1;
      } else {
        heartRate = (rawData[offset + 1] << 8) | rawData[offset];
        offset += 2;
      }
      
      // Extraer datos RRi
      while (offset + 1 < rawData.length) {
        int rri = (rawData[offset] | (rawData[offset + 1] << 8));
        rriData.add(rri);
        offset += 2;
      }
      
      return {
        'timestamp': timestamp,
        'heart_rate': heartRate,
        'rri_data': rriData,
        'device_id': 'polar_h10',
        'data_type': 'heart_rate_reading',
      };
    }
    
    // Valor por defecto si no se pueden procesar los datos
    return {
      'timestamp': timestamp,
      'heart_rate': 0,
      'rri_data': [],
      'device_id': 'polar_h10',
      'data_type': 'heart_rate_reading',
    };
  }

  static Future<void> _uploadDataToCloud(Map<String, dynamic> data) async {
    try {
      final uploadMessage = "☁️ Iniciando subida de datos a la nube...";
      print(uploadMessage);
      await _addToLog(uploadMessage);
      
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username');
      final token = prefs.getString('auth_token');
      
      if (username == null) {
        final authMessage = "❌ Usuario no autenticado";
        print(authMessage);
        await _addToLog(authMessage);
        return;
      }

      final userMessage = "👤 Usuario: $username";
      print(userMessage);
      await _addToLog(userMessage);

      // Añadir username a los datos
      data['username'] = username;

      final headers = {
        'Content-Type': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
        final tokenMessage = "🔑 Token de autenticación presente";
        print(tokenMessage);
        await _addToLog(tokenMessage);
      } else {
        final noTokenMessage = "⚠️ No hay token de autenticación";
        print(noTokenMessage);
        await _addToLog(noTokenMessage);
      }

      final urlMessage = "📡 Enviando datos a: https://diabetes-tracker-backend.vercel.app/polarData";
      print(urlMessage);
      await _addToLog(urlMessage);
      
      final dataMessage = "📦 Datos a enviar: ${json.encode(data)}";
      print(dataMessage);
      await _addToLog(dataMessage);

      // Enviar a endpoint específico para datos del Polar H10
      final response = await http.post(
        Uri.parse('https://diabetes-tracker-backend.vercel.app/polarData'),
        headers: headers,
        body: json.encode(data),
      );

      final responseMessage = "📊 Respuesta del servidor: ${response.statusCode}";
      print(responseMessage);
      await _addToLog(responseMessage);

      if (response.statusCode == 200) {
        final successMessage = "✅ Datos del Polar H10 enviados correctamente a Supabase";
        print(successMessage);
        await _addToLog(successMessage);
        
        final bodyMessage = "📄 Respuesta: ${response.body}";
        print(bodyMessage);
        await _addToLog(bodyMessage);
      } else {
        final errorMessage = "❌ Error enviando datos del Polar H10: ${response.statusCode}";
        print(errorMessage);
        await _addToLog(errorMessage);
        
        final errorBodyMessage = "📄 Respuesta de error: ${response.body}";
        print(errorBodyMessage);
        await _addToLog(errorBodyMessage);
        // Guardar localmente para sincronizar después
        await _saveDataLocally(data);
      }
    } catch (e) {
      final catchMessage = "❌ Error en upload: $e";
      print(catchMessage);
      await _addToLog(catchMessage);
      await _saveDataLocally(data);
    }
  }

  static Future<void> _saveDataLocally(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingData = prefs.getStringList('pending_polar_data') ?? [];
      
      pendingData.add(json.encode(data));
      
      // Mantener solo los últimos 100 registros pendientes
      if (pendingData.length > 100) {
        pendingData.removeRange(0, pendingData.length - 100);
      }
      
      await prefs.setStringList('pending_polar_data', pendingData);
      print("Datos del Polar H10 guardados localmente para sincronización posterior");
    } catch (e) {
      print("Error guardando datos del Polar H10 localmente: $e");
    }
  }

  // Métodos públicos para controlar el servicio
  static Future<void> startDataCollection() async {
    print("🚀 Iniciando recogida automática de datos del Polar H10...");
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_collecting_data', true);
    print("✅ Flag de recogida automática activado");
    
    if (!kIsWeb) {
      try {
        final service = FlutterBackgroundService();
        // Solo intentar foreground si es necesario
        service.invoke('setAsForeground');
        print("✅ Servicio de fondo iniciado");
      } catch (e) {
        print("⚠️ Error iniciando servicio de fondo: $e");
        // Continuar sin foreground service
      }
    }
    
    print("✅ Iniciada recogida automática de datos del Polar H10");
    print("⏰ Los datos se recogerán cada 30 segundos automáticamente");
  }

  static Future<void> stopDataCollection() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_collecting_data', false);
    
    if (!kIsWeb) {
      try {
        final service = FlutterBackgroundService();
        service.invoke('setAsBackground');
      } catch (e) {
        print("Error deteniendo servicio de fondo: $e");
      }
    }
    
    print("Detenida recogida automática de datos del Polar H10");
  }

  static Future<bool> isCollectingData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_collecting_data') ?? false;
  }

  // Verificar si la plataforma soporta background services
  static bool isBackgroundServiceSupported() {
    if (kIsWeb) return false;
    // iOS y Android soportan background services
    return true;
  }

  // Obtener información específica de la plataforma
  static String getPlatformInfo() {
    if (kIsWeb) return "Web";
    // Aquí podrías usar device_info_plus para obtener más detalles
    return "Mobile";
  }

  // Método para agregar logs a SharedPreferences para mostrarlos en la UI
  static Future<void> _addToLog(String message) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentLogs = prefs.getStringList('background_service_logs') ?? [];
      
      // Agregar timestamp al mensaje
      final timestamp = DateTime.now().toString().substring(11, 19); // HH:MM:SS
      final logEntry = "[$timestamp] $message";
      
      currentLogs.add(logEntry);
      
      // Mantener solo los últimos 50 logs para no saturar la memoria
      if (currentLogs.length > 50) {
        currentLogs.removeRange(0, currentLogs.length - 50);
      }
      
      await prefs.setStringList('background_service_logs', currentLogs);
    } catch (e) {
      print("Error agregando log: $e");
    }
  }

  // Método para obtener logs para mostrar en la UI
  static Future<List<String>> getLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList('background_service_logs') ?? [];
    } catch (e) {
      print("Error obteniendo logs: $e");
      return [];
    }
  }

  // Método para limpiar logs
  static Future<void> clearLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('background_service_logs');
    } catch (e) {
      print("Error limpiando logs: $e");
    }
  }

  static Future<void> syncPendingData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingData = prefs.getStringList('pending_polar_data') ?? [];
      
      if (pendingData.isEmpty) return;

      final token = prefs.getString('auth_token');
      final headers = {
        'Content-Type': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      // Enviar todos los datos pendientes
      for (String dataString in pendingData) {
        try {
          final data = json.decode(dataString);
          final response = await http.post(
            Uri.parse('https://diabetes-tracker-backend.vercel.app/polarData'),
            headers: headers,
            body: json.encode(data),
          );
          
          if (response.statusCode == 200) {
            print("Dato pendiente del Polar H10 sincronizado");
          }
        } catch (e) {
          print("Error sincronizando dato pendiente del Polar H10: $e");
        }
      }

      // Limpiar datos sincronizados
      await prefs.remove('pending_polar_data');
      print("Sincronización de datos pendientes del Polar H10 completada");
    } catch (e) {
      print("Error en sincronización: $e");
    }
  }
} 