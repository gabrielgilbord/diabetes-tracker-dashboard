// import 'dart:async';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:flutter_timezone/flutter_timezone.dart';

// class LocalNotificationService {
//   static final notificationsPlugin = FlutterLocalNotificationsPlugin();
//   bool _inInitialized = false;

//   bool get inInitialized => _inInitialized;

//   Future<void> initNotification() async {
//     if (_inInitialized) return;

//     print('Iniciando configuración de notificaciones...');

//     // Timezone
//     tz.initializeTimeZones();
//     final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
//     tz.setLocalLocation(tz.getLocation(currentTimeZone));
//     print('Zona horaria configurada: $currentTimeZone');

//     // Configuración para Android
//     const initSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    
//     // Configuración para iOS
//     const initSettingsIOS = DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );

//     const initSettings = InitializationSettings(
//       android: initSettingsAndroid,
//       iOS: initSettingsIOS,
//     );

//     // Inicializar el plugin
//     await notificationsPlugin.initialize(
//       initSettings,
//       onDidReceiveNotificationResponse: (NotificationResponse response) async {
//         print('Notificación presionada: ${response.payload}');
//       },
//     );

//     // Configurar el canal de notificaciones para Android
//     final androidPlugin = notificationsPlugin
//         .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
//     if (androidPlugin != null) {
//       await androidPlugin.createNotificationChannel(
//         const AndroidNotificationChannel(
//           'daily_channel_id',
//           'Daily Notifications',
//           description: 'Daily notification channel',
//           importance: Importance.max,
//           enableVibration: true,
//           enableLights: true,
//           playSound: true,
//         ),
//       );
//       print('Canal de notificaciones Android creado');
//     }

//     _inInitialized = true;
//     print('Inicialización de notificaciones completada');
//   }

//   NotificationDetails _notificationDetails() {
//     return const NotificationDetails(
//       android: AndroidNotificationDetails(
//         'daily_channel_id',
//         'Daily Notifications',
//         channelDescription: 'Daily notification channel',
//         importance: Importance.max,
//         priority: Priority.high,
//         enableLights: true,
//         enableVibration: true,
//         playSound: true,
//         showWhen: true,
//         autoCancel: false,
//         fullScreenIntent: true,
//         category: AndroidNotificationCategory.reminder,
//       ),
//       iOS: DarwinNotificationDetails(
//         presentAlert: true,
//         presentBadge: true,
//         presentSound: true,
//       ),
//     );
//   }

//   Future<void> showNotification({
//     int id = 0,
//     String? title,
//     String? body,
//     String? payload,
//   }) async {
//     print('Intentando mostrar notificación inmediata...');
//     try {
//       await notificationsPlugin.show(
//         id,
//         title,
//         body,
//         _notificationDetails(),
//         payload: payload,
//       );
//       print('Notificación inmediata mostrada correctamente');
//     } catch (e) {
//       print('Error al mostrar notificación inmediata: $e');
//     }
//   }

//   Future<void> scheduleDailyShow({
//     int id = 0,
//     required String title,
//     required String body,
//     required int hour,
//     required int minute,
//   }) async {
//     print('Iniciando programación de notificación diaria...');
    
//     try {
//       // Cancelar notificaciones existentes
//       await notificationsPlugin.cancel(id);
//       print('Notificaciones anteriores canceladas');

//       // Obtener la zona horaria local
//       final location = tz.local;
//       print('Zona horaria local: ${location.name}');

//       // Crear la fecha para la primera notificación
//       var now = tz.TZDateTime.now(location);
//       var scheduledDate = tz.TZDateTime(
//         location,
//         now.year,
//         now.month,
//         now.day,
//         hour,
//         minute,
//       );

//       // Si la hora ya pasó hoy, programar para mañana
//       if (scheduledDate.isBefore(now)) {
//         scheduledDate = scheduledDate.add(const Duration(days: 1));
//       }

//       print('Fecha programada: $scheduledDate');

//       // Intentar programar con matchDateTimeComponents primero
//       try {
//         await notificationsPlugin.zonedSchedule(
//           id,
//           title,
//           body,
//           scheduledDate,
//           _notificationDetails(),
//           androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
//           uiLocalNotificationDateInterpretation:
//               UILocalNotificationDateInterpretation.absoluteTime,
//           matchDateTimeComponents: DateTimeComponents.time,
//         );
//         print('Notificación programada con matchDateTimeComponents');
//       } catch (e) {
//         print('Error al programar con matchDateTimeComponents: $e');
//         // Si falla, intentar sin matchDateTimeComponents
//         print('Intentando programar sin matchDateTimeComponents...');
//         await notificationsPlugin.zonedSchedule(
//           id,
//           title,
//           body,
//           scheduledDate,
//           _notificationDetails(),
//           androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
//           uiLocalNotificationDateInterpretation:
//               UILocalNotificationDateInterpretation.absoluteTime,
//         );
//         print('Notificación programada sin matchDateTimeComponents');
//       }

//       // Mostrar una notificación de prueba inmediata
//       // await showNotification(
//       //   id: id + 1,
//       //   title: 'Notificación de prueba',
//       //   body: 'Esta es una notificación de prueba para verificar que el sistema funciona.',
//       // );
//     } catch (e) {
//       print('Error al programar la notificación: $e');
//     }
//   }

//   Future<void> cancelNotification(int id) async {
//     try {
//       await notificationsPlugin.cancel(id);
//       print('Notificación $id cancelada');
//     } catch (e) {
//       print('Error al cancelar la notificación: $e');
//     }
//   }

//   Future<void> cancelAllNotifications() async {
//     try {
//       await notificationsPlugin.cancelAll();
//       print('Todas las notificaciones canceladas');
//     } catch (e) {
//       print('Error al cancelar todas las notificaciones: $e');
//     }
//   }
// }
