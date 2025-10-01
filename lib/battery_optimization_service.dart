import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:device_info_plus/device_info_plus.dart';

class BatteryOptimizationService {
  static const String _hasShownBatteryDialog = 'has_shown_battery_dialog';
  static const String _hasShownOptimizationGuide = 'has_shown_optimization_guide';

  // Verificar si es Android
  static Future<bool> isAndroid() async {
    if (kIsWeb) {
      return false; // No es Android si estamos en web
    }
    
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.brand.isNotEmpty; // Use any property to check if it's Android
    } catch (e) {
      print("Error verificando si es Android: $e");
      return false;
    }
  }

  // Verificar si ya se mostró el diálogo de batería
  static Future<bool> hasShownBatteryDialog() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasShownBatteryDialog) ?? false;
  }

  // Marcar que se mostró el diálogo
  static Future<void> markBatteryDialogShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasShownBatteryDialog, true);
  }

  // Verificar si ya se mostró la guía de optimización
  static Future<bool> hasShownOptimizationGuide() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasShownOptimizationGuide) ?? false;
  }

  // Marcar que se mostró la guía
  static Future<void> markOptimizationGuideShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasShownOptimizationGuide, true);
  }

  // Mostrar diálogo de configuración de batería
  static Future<void> showBatteryOptimizationDialog(BuildContext context) async {
    if (!await isAndroid()) return;
    
    final hasShown = await hasShownBatteryDialog();
    if (hasShown) return;

    await markBatteryDialogShown();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.battery_charging_full, color: Colors.orange, size: 28),
              SizedBox(width: 8),
              Text('Optimización de Batería'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Para que la recogida automática de datos funcione correctamente con el móvil bloqueado, necesitas desactivar la optimización de batería para esta app.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¿Por qué es necesario?',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• La optimización de batería puede detener la app en segundo plano\n'
                      '• Sin esto, la recogida automática de datos se interrumpirá\n'
                      '• Es necesario para el funcionamiento completo de la app',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Más tarde'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _openBatteryOptimizationSettings(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: Text('Configurar ahora'),
            ),
          ],
        );
      },
    );
  }

  // Abrir configuración de optimización de batería
  static Future<void> _openBatteryOptimizationSettings(BuildContext context) async {
    if (kIsWeb) {
      _showManualGuideDialog(context);
      return;
    }
    
    try {
      final intent = AndroidIntent(
        action: 'android.settings.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS',
        data: 'package:com.example.diabetes_tracker',
      );
      await intent.launch();
    } catch (e) {
      // Fallback: abrir configuración general de batería
      try {
        final intent = AndroidIntent(
          action: 'android.settings.BATTERY_SAVER_SETTINGS',
        );
        await intent.launch();
      } catch (e) {
        _showManualGuideDialog(context);
      }
    }
  }

  // Mostrar guía manual si no se puede abrir automáticamente
  static void _showManualGuideDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.help_outline, color: Colors.blue, size: 28),
              SizedBox(width: 8),
              Text('Configuración Manual'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sigue estos pasos para desactivar la optimización de batería:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                _buildStep(1, 'Ajustes > Batería'),
                _buildStep(2, 'Optimización de batería'),
                _buildStep(3, 'Busca "Diabetes Tracker"'),
                _buildStep(4, 'Selecciona "No optimizar"'),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Text(
                    '💡 La ubicación exacta puede variar según tu dispositivo y versión de Android.',
                    style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Entendido'),
            ),
          ],
        );
      },
    );
  }

  static Widget _buildStep(int number, String description) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // Mostrar recordatorio si la optimización no está configurada
  static Future<void> showOptimizationReminder(BuildContext context) async {
    if (!await isAndroid()) return;
    
    final hasShown = await hasShownOptimizationGuide();
    if (hasShown) return;

    await markOptimizationGuideShown();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange, size: 28),
              SizedBox(width: 8),
              Text('Configuración Recomendada'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Para una experiencia óptima con la recogida automática de datos, te recomendamos configurar la optimización de batería.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Beneficios:',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '✅ Recogida continua de datos\n'
                      '✅ Funciona con el móvil bloqueado\n'
                      '✅ Sincronización automática\n'
                      '✅ Mejor rendimiento general',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Omitir'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _openBatteryOptimizationSettings(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text('Configurar'),
            ),
          ],
        );
      },
    );
  }
} 