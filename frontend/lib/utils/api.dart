import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../config.dart';

class Api {
  static Future<List<LatLng>> getCrimeData() async {
    List<LatLng> locations = [];
    try {
      DateTime date = DateTime.now().subtract(const Duration(days: 3));
      var url = Uri.https('data.sccgov.org', '/resource/n9u6-aijz.json', {
        r'$where': "incident_datetime>'${date.toIso8601String()}'"
      });
      var response = await http.get(url, headers: {
        'X-App-Token': config.crimeApiKey
      });
      List<dynamic> data = jsonDecode(response.body);
      
      for (var value in data) {
        var address = "";
        try {
          List<String> spl = value['address_1'].split(' ');
          spl.removeWhere((String element) => element.toLowerCase() == 'block');
          address = spl.join(' ');
          var location = await locationFromAddress(address);
          locations.add(LatLng(location.first.latitude, location.first.longitude));
        } catch (e) {
          logger.w('Could not find location for $address');
        }
      }
    } catch (e) {
      logger.e('Failed to get crime data', e);
    }
    
    logger.i(locations);
    return locations;
  }

  static Future<List<LatLng>> getEmergencyPhoneData() async {
    List<LatLng> locations = [];
    try {
      var data = await rootBundle.loadString('assets/sampleData.json');
      var dec = json.decode(data);
      dec["bluelight"].forEach((v) =>
        locations.add(LatLng(v[0], v[1])));
    } catch (e) {
      logger.e('Failed to get emergency phone data', e);
    }
    
    // logger.i(locations);
    return locations;
  }

  static Future<List<LatLng>> getStreetLightData() async {
    List<LatLng> locations = [];
    try {
      var data = await rootBundle.loadString('assets/sampleData.json');
      var dec = json.decode(data);
      dec["streetlight"].forEach((v) =>
        locations.add(LatLng(v[0], v[1])));
    } catch (e) {
      logger.e('Failed to get street pole data', e);
    }
    
    // logger.i(locations);
    return locations;
  }
}