import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ContactsForm extends StatefulWidget {
  const ContactsForm({super.key});

  @override
  ContactsFormState createState() {
    return ContactsFormState();
  }
}

class ContactsFormState extends State<ContactsForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            decoration: const InputDecoration(
              hintText: '888-888-8888'
            ),
          ),
          const SizedBox(height: 10,),
          ElevatedButton(
            onPressed: _onClick,
            child: const Text('Update Emergency Contact')
          )
        ],
      ),
    );
  }

  _onClick() {
    // update stuff here
    Get.toNamed('/home');
  }
}