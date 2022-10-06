import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
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
  final Set<Marker> _destMarkers = {};

  late Position _currentPosition;
  String _currentAddress = '';

  final _startAddressController = TextEditingController();
  final _destinationAddressController = TextEditingController();

  final _startAddressFocusNode = FocusNode();
  final _destinationAddressFocusNode = FocusNode();

  String _startAddress = '';
  String _destinationAddress = '';
  String? _placeDistance;

  late PolylinePoints _polylinePoints;
  final Map<PolylineId, Polyline> _polylines = {};
  final List<LatLng> _polylineCoordinates = [];

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
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            GoogleMap(
              mapType: MapType.normal,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomGesturesEnabled: true,
              initialCameraPosition: _kSchool,
              markers: {...(_markers ?? {}), ..._destMarkers},
              polylines: Set<Polyline>.of(_polylines.values),
              onMapCreated: (GoogleMapController controller) {
                if (!_controller.isCompleted) _controller.complete(controller);
              },
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white70,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextField(
                        focusNode: _startAddressFocusNode,
                        controller: _startAddressController,
                        onChanged: (String value) => setState(() {
                          _startAddressController.text = _currentAddress;
                          _startAddress = value;
                        }),
                      ),
                      TextField(
                        focusNode: _destinationAddressFocusNode,
                        onChanged: (String value) => setState(() {
                          _destinationAddress = value;
                        }),
                      ),
                      ElevatedButton(
                        onPressed: _route,
                        child: const Text('Route')
                      )
                    ],
                  ),
                ),
              ),
            )
          ]
        ),
        floatingActionButton: FloatingActionButton.small(
          onPressed: _goToTheSchool,
          child: const Icon(Icons.school),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      )
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
        _startAddressController.text = _currentAddress;
        _startAddress = _currentAddress;
      });
    } catch (e) {
      logger.e(e);
    }
  }

  // Method for calculating the distance between two places
  Future<bool> _calculateDistance() async {
    try {
      final GoogleMapController controller = await _controller.future;
      // Retrieving placemarks from addresses
      List<Location> startPlacemark = await locationFromAddress(_startAddress);
      List<Location> destinationPlacemark =
          await locationFromAddress(_destinationAddress);

      // Use the retrieved coordinates of the current position,
      // instead of the address if the start position is user's
      // current position, as it results in better accuracy.
      double startLatitude = _startAddress == _currentAddress
          ? _currentPosition.latitude
          : startPlacemark[0].latitude;

      double startLongitude = _startAddress == _currentAddress
          ? _currentPosition.longitude
          : startPlacemark[0].longitude;

      double destinationLatitude = destinationPlacemark[0].latitude;
      double destinationLongitude = destinationPlacemark[0].longitude;

      String startCoordinatesString = '($startLatitude, $startLongitude)';
      String destinationCoordinatesString =
          '($destinationLatitude, $destinationLongitude)';

      // Start Location Marker
      Marker startMarker = Marker(
        markerId: MarkerId(startCoordinatesString),
        position: LatLng(startLatitude, startLongitude),
        infoWindow: InfoWindow(
          title: 'Start $startCoordinatesString',
          snippet: _startAddress,
        ),
        icon: BitmapDescriptor.defaultMarker,
      );

      // Destination Location Marker
      Marker destinationMarker = Marker(
        markerId: MarkerId(destinationCoordinatesString),
        position: LatLng(destinationLatitude, destinationLongitude),
        infoWindow: InfoWindow(
          title: 'Destination $destinationCoordinatesString',
          snippet: _destinationAddress,
        ),
        icon: BitmapDescriptor.defaultMarker,
      );

      // Adding the markers to the list
      _destMarkers.add(startMarker);
      _destMarkers.add(destinationMarker);

      logger.i(
        'START COORDINATES: ($startLatitude, $startLongitude)',
      );
      logger.i(
        'DESTINATION COORDINATES: ($destinationLatitude, $destinationLongitude)',
      );

      // Calculating to check that the position relative
      // to the frame, and pan & zoom the camera accordingly.
      double miny = (startLatitude <= destinationLatitude)
          ? startLatitude
          : destinationLatitude;
      double minx = (startLongitude <= destinationLongitude)
          ? startLongitude
          : destinationLongitude;
      double maxy = (startLatitude <= destinationLatitude)
          ? destinationLatitude
          : startLatitude;
      double maxx = (startLongitude <= destinationLongitude)
          ? destinationLongitude
          : startLongitude;

      double southWestLatitude = miny;
      double southWestLongitude = minx;

      double northEastLatitude = maxy;
      double northEastLongitude = maxx;

      // Accommodate the two locations within the
      // camera view of the map
      controller.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            northeast: LatLng(northEastLatitude, northEastLongitude),
            southwest: LatLng(southWestLatitude, southWestLongitude),
          ),
          100.0,
        ),
      );

      await _createPolylines(startLatitude, startLongitude, destinationLatitude,
          destinationLongitude);

      double totalDistance = 0.0;

      // Calculating the total distance by adding the distance
      // between small segments
      for (int i = 0; i < _polylineCoordinates.length - 1; i++) {
        totalDistance += _coordinateDistance(
          _polylineCoordinates[i].latitude,
          _polylineCoordinates[i].longitude,
          _polylineCoordinates[i + 1].latitude,
          _polylineCoordinates[i + 1].longitude,
        );
      }

      setState(() {
        _placeDistance = totalDistance.toStringAsFixed(2);
        logger.i('DISTANCE: $_placeDistance km');
      });

      return true;
    } catch (e) {
      logger.e(e);
    }
    return false;
  }

  // Formula for calculating distance between two coordinates
  // https://stackoverflow.com/a/54138876/11910277
  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  // Create the polylines for showing the route between two places
  _createPolylines(
    double startLatitude,
    double startLongitude,
    double destinationLatitude,
    double destinationLongitude,
  ) async {
    _polylinePoints = PolylinePoints();
    PolylineResult result = await _polylinePoints.getRouteBetweenCoordinates(
      'AIzaSyBalXW7bdb97Rc8vI8Nd2FkKQxcYqqZLVQ', // Google Maps API Key
      PointLatLng(startLatitude, startLongitude),
      PointLatLng(destinationLatitude, destinationLongitude),
      travelMode: TravelMode.transit,
    );

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        _polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }

    PolylineId id = const PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: _polylineCoordinates,
      width: 3,
    );
    _polylines[id] = polyline;
  }

  _route() async {
    if (_startAddress.isEmpty || _destinationAddress.isEmpty) return;
    _startAddressFocusNode.unfocus();
    _destinationAddressFocusNode.unfocus();
    setState(() {
      if (_destMarkers.isNotEmpty) _destMarkers.clear();
      if (_polylines.isNotEmpty) _polylines.clear();
      if (_polylineCoordinates.isNotEmpty) _polylineCoordinates.clear();
      _placeDistance = null;
    });

    await _calculateDistance();
  }
}