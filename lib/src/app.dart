// ignore_for_file: prefer_const_constructors, no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/auth_provider.dart';
import 'screens/components/loading.dart';
import 'screens/views/auth_screen.dart';
import 'screens/views/bottom_navigation.dart';
import 'screens/views/onboarding.dart';

class MyApp extends StatelessWidget {
  static Map<int, Color> color = {
    50: Color(0xff7241D1).withOpacity(.1),
    100: Color(0xff7241D1).withOpacity(.2),
    200: Color(0xff7241D1).withOpacity(.3),
    300: Color(0xff7241D1).withOpacity(.4),
    400: Color(0xff7241D1).withOpacity(.5),
    500: Color(0xff7241D1).withOpacity(.6),
    600: Color(0xff7241D1).withOpacity(.7),
    700: Color(0xff7241D1).withOpacity(.8),
    800: Color(0xff7241D1).withOpacity(.9),
    900: Color(0xff7241D1).withOpacity(1),
  };

  final MaterialColor customColor = MaterialColor(0xFF7241D1, color);

  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Efiewura',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: customColor,
          primaryColor: Color(0xff7241D1),
        ),
        home: OnBoardingScreen(),
      ),
    );
  }
}

class AuthenticationWrapper extends ConsumerWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final _authState = watch(authStateProvider);
    final _appLoginState = watch(appLoginStateProvider);

    return _authState.map(
      data: (data) {
        if (data.value != null &&
            _appLoginState.state == ApplicationLoginState.signedIn) {
          return BottomNavigationScreen();
        }
        return AuthScreen();
      },
      loading: (_) => Loading(),
      error: (e) => Text('An error occurred...'),
    );
  }
}
