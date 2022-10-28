import 'package:flutter/material.dart';

import '../widgets/contacts_form.dart';
import '../widgets/layout.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return const Layout(
      title: 'Settings',
      body: Padding(
        padding: EdgeInsets.all(10),
        child: ContactsForm(),
      ),
    );
  }
}