import 'package:firebase_core/firebase_core.dart';
import 'package:google_directions_api/google_directions_api.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

import './firebase_options.dart';

class _Config {
  // TODO: secrets
  String get apiKey => 'AIzaSyBalXW7bdb97Rc8vI8Nd2FkKQxcYqqZLVQ';
  String get crimeApiKey => '5c7yGnp23fEA4F2b9CpnTsOCs';

  initConfig() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
    );

    // init stuff
    if (await Permission.location.request().isGranted) {
      await Permission.locationAlways.request();
    }
    final _status = await Permission.location.serviceStatus;
    logger.d(_status);

    DirectionsService.init(apiKey);
  }
}
final _Config config = _Config();
final Logger logger = Logger();