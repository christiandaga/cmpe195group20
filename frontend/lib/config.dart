import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

class _Config {
  initConfig() async {
    // init stuff
    if (await Permission.location.request().isGranted) {
      await Permission.locationAlways.request();
    }
    logger.w(Permission.location.serviceStatus);
  }
}
final _Config config = _Config();
final Logger logger = Logger();