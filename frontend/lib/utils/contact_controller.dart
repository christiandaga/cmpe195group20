import 'package:get/get.dart';

class ContactController extends GetxController {
  final name = ''.obs;
  final number = ''.obs;
  final user = ''.obs;

  checkEmpty() {
    return name.value.isEmpty || name.value.isEmail || user.value.isEmpty;
  }
}