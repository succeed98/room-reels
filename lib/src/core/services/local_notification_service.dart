import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _flnPlugin =
      FlutterLocalNotificationsPlugin();

  static void init({Future<dynamic> Function(String?)? onSelectNotification}) {
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: AndroidInitializationSettings('@mipmap/ic_launcher'));

    _flnPlugin.initialize(
      initializationSettings,
      onSelectNotification: onSelectNotification,
    );
  }

  static void showNotification(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      const notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          'buy_or_rent_property',
          'Client delivery due channel',
          importance: Importance.max,
          priority: Priority.high,
        ),
      );

      await _flnPlugin.show(
        id,
        message.notification!.title,
        message.notification!.body,
        notificationDetails,
      );
    } catch (e) {
      print(e);
    }
  }
}
