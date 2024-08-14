import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; 

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('ic_launcher_foreground');

  const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

Future<void> notificacionCaida() async{
  const AndroidNotificationDetails andoirdNotificationDetails = 
  AndroidNotificationDetails('channelId', 'channelName', importance: Importance.high, priority: Priority.high, ticker: 'ticker');

  const NotificationDetails notificationDetails = NotificationDetails(android: andoirdNotificationDetails);

  await flutterLocalNotificationsPlugin
  .show(1, 'ALERTA DETECTADA', 'Alerta enviada!', notificationDetails);
}
Future<void> notificacionCaidaError() async{
  const AndroidNotificationDetails andoirdNotificationDetails = 
  AndroidNotificationDetails('channelId', 'channelName', importance: Importance.high, priority: Priority.high, ticker: 'ticker');

  const NotificationDetails notificationDetails = NotificationDetails(android: andoirdNotificationDetails);

  await flutterLocalNotificationsPlugin
  .show(1, 'ERROR ENVIO DE ALERTA', 'No se pudo enviar la alerta debido a un error del servidor.', notificationDetails);
}

Future<void> showNotificationWithSound() async {
    const platform = MethodChannel('com.example.falldetapp/notification');
    try {
      await platform.invokeMethod('showNotification', {
        'title': 'Se detectó una emergencia!',
        'message': 'Descartar si se encuentra bien',
      });
    } on PlatformException catch (e) {
      print("Failed to show notification: '${e.message}'.");
    }
  }

Future<void> notificationBattery() async {
  AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'NOTIFICACIÓN BATERÍA', 'Se desconectó el dispositivo',
    importance: Importance.max,
    priority: Priority.high,
    sound: RawResourceAndroidNotificationSound('notification'),
    playSound: true,
    enableVibration: true,
    vibrationPattern: Int64List.fromList([0, 4000]),
    audioAttributesUsage: AudioAttributesUsage.alarm,
  );
  NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );

  await flutterLocalNotificationsPlugin.show(
    0,
    'NOTIFICACIÓN BATERÍA',
    'Se desconectó el dispositivo',
    platformChannelSpecifics,
    payload: 'item x',
  );
}
