import 'package:flutter/material.dart' show WidgetsFlutterBinding, runApp;

import './app.dart' show MyApp;
import './config.dart' show config;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ignore: await_only_futures
  await config.initConfig();

  runApp(MyApp());
}


