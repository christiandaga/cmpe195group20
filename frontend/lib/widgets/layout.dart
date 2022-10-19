import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Layout extends StatelessWidget {
  final String title;
  final Widget body;

  const Layout({super.key, this.title = 'SafeStreets', required this.body});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: GestureDetector(
              onTap: () => Get.toNamed('/settings'),
              child: const Icon(Icons.settings),
            ),
          )
        ],
      ),
      body: body
    );
  }
}