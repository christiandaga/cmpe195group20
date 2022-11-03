import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

import '../config.dart';

class Api {
  static Future<List<Location>> getCrimeData() async {
    DateTime now = DateTime.now();
    DateTime date = DateTime(now.year, now.month, now.day);
    var url = Uri.https('data.sccgov.org', '/resource/n9u6-aijz.json', {
      r'$where': "incident_datetime>'${date.toIso8601String()}'"
    });
    var response = await http.get(url, headers: {
      'X-App-Token': '5c7yGnp23fEA4F2b9CpnTsOCs'
    });
    List<dynamic> data = jsonDecode(response.body);
    List<Location> locations = [];
    for (var value in data) {
      List<String> spl = value['address_1'].split(' ');
      spl.removeWhere((String element) => element.toLowerCase() == 'block');
      String address = spl.join(' ');
      try {
        var location = await locationFromAddress(address);
        locations.add(location.first);
      } catch (e) {
        logger.w('Could not find location for $address');
      }
    }
    logger.i(locations);

    return locations;
  }
}