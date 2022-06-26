// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/services/local_notification_service.dart';
import '../../utils/constants.dart';
import 'notifications.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  @override
  initState() {
    super.initState();

    LocalNotificationService.init(
      onSelectNotification: (String? payload) async {
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => NotificationsScreen()));
      },
    );

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => NotificationsScreen()),
        );
      }
    });
    // handle foreground notification
    FirebaseMessaging.onMessage.listen((message) {
      LocalNotificationService.showNotification(message);
    });
    // handle background(but opened while app is not closed) notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => NotificationsScreen()),
      );
    });
  }

  /// container created for hi
  Container buildHiContainer() {
    return Container(
      height: 120,
      width: 120,
      margin: EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: Center(child: Text("Hey", style: F_60_MEDIUM_PC)),
    );
  }

  @override
  Widget build(BuildContext context) {
    double mScreenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: mScreenHeight / 6),
            buildHiContainer(),
            SizedBox(height: mScreenHeight / 6),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "Let's find your Dream Home",
                style: F_36_MEDIUM_WHITE,
              ),
            ),
            Container(
              height: 60,
              margin: EdgeInsets.all(40),
              width: double.infinity,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.white),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                child: Text("Get started", style: F_24_MEDIUM_PC),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AuthenticationWrapper(),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
