import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../config.dart';

class MapDisplay extends StatefulWidget {
  const MapDisplay({Key? key}) : super(key: key);

  @override
  State<MapDisplay> createState() => MapDisplayState();
}

class MapDisplayState extends State<MapDisplay> {

  final Completer<GoogleMapController> _controller = Completer();
  Set<Marker>? _markers;

  late Position _currentPosition;
  String _currentAddress = '';

  final startAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();

  final startAddressFocusNode = FocusNode();
  final desrinationAddressFocusNode = FocusNode();

  String _startAddress = '';
  String _destinationAddress = '';
  String? _placeDistance;

  static const CameraPosition _kSchool = CameraPosition(
      target: LatLng(37.334465, -121.8812),
      zoom: 15.5
  );

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    if (_markers == null) _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        initialCameraPosition: _kSchool,
        markers: _markers ?? {},
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: _goToTheSchool,
        child: const Icon(Icons.school),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
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

  Future<void> _goToTheSchool() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kSchool));
  }

  Future<void> _getCurrentLocation() async {
    final GoogleMapController controller = await _controller.future;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
      .then((Position position) async {
      setState(() {
        _currentPosition = position;

        logger.i('CURRENT POS: $_currentPosition');

        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 18.0,
            ),
          ),
        );
      });
      await _getAddress();
    }).catchError((e) {
      logger.e(e);
    });
  }

  _getAddress() async {
  try {
    List<Placemark> p = await placemarkFromCoordinates(
        _currentPosition.latitude, _currentPosition.longitude);
    Placemark place = p[0];

    setState(() {
      _currentAddress =
          "${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}";
      startAddressController.text = _currentAddress;
      _startAddress = _currentAddress;
    });
  } catch (e) {
    logger.e(e);
  }
}
}