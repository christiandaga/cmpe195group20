import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;

class MapDisplay extends StatefulWidget {
  const MapDisplay({Key? key}) : super(key: key);

  @override
  State<MapDisplay> createState() => MapDisplayState();
}

class MapDisplayState extends State<MapDisplay> {
  final Completer<GoogleMapController> _controller = Completer();
  Set<Marker>? _markers;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.334465, -121.8812),
    zoom: 15.5,
  );

  static const CameraPosition _kSchool = CameraPosition(
      target: LatLng(37.334465, -121.8812),
      zoom: 15.5);

  @override
  Widget build(BuildContext context) {
    if (_markers == null) _fetchData();
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _kGooglePlex,
        markers: _markers ?? {},
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: _goToTheLake,
        child: const Icon(Icons.school),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kSchool));
  }

  Future<void> _fetchData() async {
    Set<Marker> newMarkers = {};
    var data = await rootBundle.loadString('assets/sampleData.json');
    var icon = await rootBundle.load('assets/images/phone.png');
    var dec = json.decode(data);
    dec.forEach((k,v) {
      newMarkers.add(Marker(
        markerId: MarkerId(k),
        position: LatLng(v['lat']!, v['lng']!),
        icon: BitmapDescriptor.fromBytes(Uint8List.view(icon.buffer))
      ));
    });
    setState(() => _markers = newMarkers);
  }
}