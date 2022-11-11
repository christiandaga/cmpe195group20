import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_directions_api/google_directions_api.dart';

import '../config.dart';
import '../utils/contact_controller.dart';

class Trip {
  static const collectionName = 'trip';

  late final Timestamp? eta;
  late final Map<String, GeoPoint>? route;
  late final Map<String, String>? contact;
  late final GeoPoint? lastLocation;

  String? _id;

  Trip(
    Leg leg,
    ContactController contact,
  ) {
    eta = Timestamp.fromDate(DateTime.now().add(Duration(seconds: leg.duration!.value!.toInt())));
    route = {
      "start": GeoPoint(leg.startLocation!.latitude, leg.startLocation!.longitude),
      "destination": GeoPoint(leg.endLocation!.latitude, leg.endLocation!.longitude)
    };
    this.contact = {
      "name": contact.name.value,
      "number": contact.number.value
    };
    lastLocation = GeoPoint(leg.startLocation!.latitude, leg.startLocation!.longitude);
  }

  Future<bool> commit() async {
    var db = FirebaseFirestore.instance;
    return await db.collection(collectionName).add({
      "eta": eta,
      "route": route,
      "contact": contact,
      "last_location": lastLocation,
      "created": Timestamp.now()
    }).then(
      (doc) {
        _id = doc.id;
        return true;
      },
      onError: (e) {
        logger.e('Failed to add trip', e);
        return false;
      }
    );
  }

  Future<bool> complete() async {
    var db = FirebaseFirestore.instance;
    return await db.collection(collectionName).doc(_id)
      .delete()
      .then(
        (doc) => true,
        onError: (e) {
          logger.e('Failed to delete trip', e);
          return false;
        }
      );
  }
}