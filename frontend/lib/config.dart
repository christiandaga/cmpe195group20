import 'package:google_directions_api/google_directions_api.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

class _Config {
  // TODO: secrets
  String get apiKey => 'AIzaSyBalXW7bdb97Rc8vI8Nd2FkKQxcYqqZLVQ';

  initConfig() async {
    // init stuff
    if (await Permission.location.request().isGranted) {
      await Permission.locationAlways.request();
    }
    final _status = await Permission.location.serviceStatus;
    logger.w(_status);

    DirectionsService.init(apiKey);
  }
}
final _Config config = _Config();
final Logger logger = Logger();