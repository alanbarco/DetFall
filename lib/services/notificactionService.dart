import 'package:flutter_local_notifications/flutter_local_notifications.dart'; 

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');

  const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

Future<void> notificacionConexion() async{
  const AndroidNotificationDetails andoirdNotificationDetails = 
  AndroidNotificationDetails('channelId', 'channelName', importance: Importance.high, priority: Priority.high, ticker: 'ticker');

  const NotificationDetails notificationDetails = NotificationDetails(android: andoirdNotificationDetails);

  await flutterLocalNotificationsPlugin
  .show(1, 'Detector conectado', 'Se logró conectar el detector de caídas correctamente', notificationDetails);
}
Future<void> notificacionCaida() async{
  const AndroidNotificationDetails andoirdNotificationDetails = 
  AndroidNotificationDetails('channelId', 'channelName', importance: Importance.high, priority: Priority.high, ticker: 'ticker');

  const NotificationDetails notificationDetails = NotificationDetails(android: andoirdNotificationDetails);

  await flutterLocalNotificationsPlugin
  .show(1, 'CAIDA DETECTADA', 'Alerta enviada!', notificationDetails);
}