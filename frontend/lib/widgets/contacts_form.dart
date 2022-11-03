import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/contact_controller.dart';

class ContactsForm extends StatefulWidget {
  const ContactsForm({super.key});

  @override
  ContactsFormState createState() {
    return ContactsFormState();
  }
}

class ContactsFormState extends State<ContactsForm> {
  final _formKey = GlobalKey<FormState>();
  
  final ContactController _contact = Get.find();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(
              hintText: _contact.name.value.isEmpty?'None':_contact.name.value
            ),
            onChanged: ((value) => _contact.name(value)),
            validator: ((value) {
              if (value == null || value.isEmpty) {
                return 'Name cannot be empty';
              }
              return null;
            }),
          ),
          TextFormField(
            decoration: InputDecoration(
              hintText: _contact.number.value.isEmpty?'888-888-8888':_contact.number.value
            ),
            onChanged: ((value) => _contact.number(value)),
            validator: ((value) {
              RegExp exp = RegExp(r'^(1-)?\d{3}-\d{3}-\d{4}$');
              if (!exp.hasMatch(value ?? '')) {
                return 'Invalid Phone Number';
              }
              return null;
            }),
          ),
          const SizedBox(height: 10,),
          ElevatedButton(
            onPressed: () => _onClick(_contact),
            child: const Text('Update Emergency Contact')
          )
        ],
      ),
    );
  }

  _onClick(ContactController _contact) async {
    if (_formKey.currentState!.validate()) {
      final _prefs = await SharedPreferences.getInstance();
      await _prefs.setString('contact_name', _contact.name.value);
      await _prefs.setString('contact_number', _contact.number.value);
      
      ScaffoldMessenger.of(context)
        .showSnackBar(
          const SnackBar(
            content: Text('Saved'),
            backgroundColor: Colors.green,
          )
        );
    }
  }
}