import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'src/app.dart';

/// receive message when app is in background
Future<void> backgroundHandler(RemoteMessage message) async {
  print('handling background message');
  print(message.notification!.title);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // handle isolate background nofication
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  // disable landscape mode or screen auto-rotate
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(MyApp());
}
