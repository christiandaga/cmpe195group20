import 'package:flutter/material.dart';

import '../widgets/layout.dart';
import '../widgets/map.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  final String title = 'SafeStreets';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return const Layout(
      body: MapDisplay()
    );
  }
}
