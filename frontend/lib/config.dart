import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

class _Config {
  initConfig() async {
    // init stuff
    await Permission.location.request();
    logger.i(Permission.location);
  }
}
final _Config config = _Config();
final Logger logger = Logger();