// ignore_for_file: prefer_const_constructors, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/auth_provider.dart';
import '../components/curved_navigation_bar.dart';
import '../components/loading.dart';
import 'add_property.dart';
import 'chat_history.dart';
import 'home.dart';
import 'properties.dart';
import 'settings.dart';

final selectedBottomNavIndex = StateProvider.autoDispose<int>((ref) => 0);

class BottomNavigationScreen extends ConsumerWidget {
  const BottomNavigationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final currentUser = watch(currentUserProvider);
    final user = watch(userStreamProvider(currentUser!.uid));

    return Scaffold(
      body: user.when(
        data: (userModel) {
          if (userModel.userType == 'seller') {
            return PropertyOwnerBottomNavigator();
          } else {
            return NormalUserBottomNavigator();
          }
        },
        loading: () => Loading(),
        error: (error, stack) => TextButton(
          onPressed: () => context.read(userStreamProvider(currentUser.uid)),
          child: Icon(Icons.refresh_sharp),
        ),
      ),
    );
  }
}

class NormalUserBottomNavigator extends ConsumerWidget {
  const NormalUserBottomNavigator({Key? key}) : super(key: key);

  static List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    ChatHistory(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final selectedIndex = watch(selectedBottomNavIndex);

    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(selectedIndex.state),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Theme.of(context).primaryColor,
        // ignore: prefer_const_literals_to_create_immutables
        items: <Widget>[
          Icon(Icons.home, size: 30),
          Icon(Icons.message, size: 30),
          Icon(Icons.settings, size: 30),
        ],
        index: selectedIndex.state,
        onTap: (index) => selectedIndex.state = index,
      ),
    );
  }
}

class PropertyOwnerBottomNavigator extends ConsumerWidget {
  const PropertyOwnerBottomNavigator({Key? key}) : super(key: key);

  static List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    PropertiesScreen(),
    AddPropertyScreen(),
    ChatHistory(),
    SettingsScreen()
  ];

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final selectedIndex = watch(selectedBottomNavIndex);

    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(selectedIndex.state),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Theme.of(context).primaryColor,
        // ignore: prefer_const_literals_to_create_immutables
        items: <Widget>[
          Icon(Icons.home, size: 30),
          Icon(Icons.favorite, size: 30),
          Icon(Icons.add, size: 30),
          Icon(Icons.message, size: 30),
          Icon(Icons.settings, size: 30),
        ],
        index: selectedIndex.state,
        onTap: (index) => selectedIndex.state = index,
      ),
    );
  }
}
