import 'package:chatbox_app/Screens/callsScreen.dart';
import 'package:chatbox_app/Screens/contactScreen.dart';
import 'package:chatbox_app/Screens/homeScreen.dart';
import 'package:chatbox_app/Screens/settingsScreen.dart';
import 'package:flutter/material.dart';

import '../const/colors.dart';
import 'baseScreen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    Homescreen(),
    Callsscreen(),
    ContactScreen(),
    SettingsScreen()
  ];
  final List<String> _titles = [
    "Home",
    "Calls",
    "Contacts",
    "Settings"
  ];

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: _titles[_currentIndex],
      currentIndex: _currentIndex,
      onTabTapped: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      child: _screens[_currentIndex],
    );
  }
}
