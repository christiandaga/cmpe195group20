import 'package:flutter/material.dart';
import 'package:get/get.dart';

import './screens/home.dart' show HomePage;
import './screens/settings.dart' show SettingsPage;

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SafeStreets',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      getPages: [
        GetPage(name: '/home', page: () => const HomePage()),
        GetPage(name: '/settings', page: () => const SettingsPage())
      ],
    );
  }
}