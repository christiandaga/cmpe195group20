import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_directions_api/google_directions_api.dart' as api;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';
import '../utils/contact_controller.dart';
import '../utils/api.dart';

class MapDisplay extends StatefulWidget {
  const MapDisplay({super.key});

  @override
  State<MapDisplay> createState() => MapDisplayState();
}

class MapDisplayState extends State<MapDisplay> {

  final Completer<GoogleMapController> _controller = Completer();
  final _directionsService = api.DirectionsService();
  Set<Marker>? _markers;
  Set<Circle>? _circles;
  final Set<Marker> _destMarkers = {};

  late Position _currentPosition;
  String _currentAddress = '';

  final _startAddressController = TextEditingController();
  final _destinationAddressController = TextEditingController();

  final _startAddressFocusNode = FocusNode();
  final _destinationAddressFocusNode = FocusNode();

  String _startAddress = '';
  String _destinationAddress = '';

  String _eta = '';
  final _contact = Get.put(ContactController());

  late PolylinePoints _polylinePoints;
  final Map<PolylineId, Polyline> _polylines = {};
  final List<LatLng> _polylineCoordinates = [];

  static const CameraPosition _kSchool = CameraPosition(
      target: LatLng(37.334465, -121.8812),
      zoom: 15.5
  );
  
  init() async {
    if (_contact.number.value.isEmpty) {
      final _prefs = await SharedPreferences.getInstance();
      _contact.name(_prefs.getString('contact_name') ?? '');
      _contact.number(_prefs.getString('contact_number') ?? '');
    }
  }

  @override
  void initState() {
    super.initState();
    init();
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
              myLocationButtonEnabled: false,
              initialCameraPosition: _kSchool,
              markers: {...(_markers ?? {}), ..._destMarkers},
              circles: _circles ?? {},
              polylines: Set<Polyline>.of(_polylines.values),
              onMapCreated: (GoogleMapController controller) {
                if (!_controller.isCompleted) _controller.complete(controller);
              },
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(220, 255, 255, 255),
                    boxShadow: [BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: const Offset(0, 1)
                    )],
                    borderRadius: const BorderRadius.all(Radius.circular(10))
                  ),
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
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
              ),
            ),
            if (_eta.isNotEmpty) SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.blueAccent),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    boxShadow: [BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: const Offset(0, 1)
                    )],
                  ),
                  margin: const EdgeInsets.all(20.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.directions_walk),
                            Text(_eta),
                          ],
                        ),
                        Obx(() => Text(
                          'Emergency Contact: ' + (_contact.name.value.isEmpty?'None':_contact.name.value),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey
                          ),
                        )),
                        ElevatedButton(
                          onPressed: _trip,
                          child: const Text('Start Trip')
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
          ]
        ),
        floatingActionButton: FloatingActionButton.small(
          onPressed: _getCurrentLocation,
          child: const Icon(Icons.my_location),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      )
    );
  }

  _fetchData() async {
    Set<Marker> newMarkers = {};
    var data = await rootBundle.loadString('assets/sampleData.json');
    var icon = await rootBundle.load('assets/images/phone.png');
    var dec = json.decode(data);
    dec["bluelight"].asMap().forEach((i, v) {
      newMarkers.add(Marker(
        markerId: MarkerId(i.toString()),
        position: LatLng(v[0], v[1]),
        icon: BitmapDescriptor.fromBytes(Uint8List.view(icon.buffer), size: const Size(30, 30))
      ));
    });

    Set<Circle> newCircles = {};
    var crimeData = await Api.getCrimeData();
    crimeData.asMap().forEach((i, v) {
      newCircles.add(Circle(
        circleId: CircleId(i.toString()),
        center: LatLng(v.latitude, v.longitude),
        radius: 75,
        fillColor: const Color.fromARGB(95, 244, 67, 54),
        strokeWidth: 1
      ));
    });
    
    setState(() {
      _markers = newMarkers;
      _circles = newCircles;
    });
  }

  _goToTheSchool() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kSchool));
  }

  _getCurrentLocation() async {
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
  Future<String> _calculateDistance() async {
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

      final request = api.DirectionsRequest(
        origin: _startAddress,
        destination: _destinationAddress,
        travelMode: api.TravelMode.walking
      );

      String eta = '';
      await _directionsService.route(request, (response, status) {
        if (status == api.DirectionsStatus.ok) {
          eta = response.routes?[0].legs?[0].duration?.text ?? '';
          logger.i('Eta: '+eta);
        }
      });

      return eta;
    } catch (e) {
      ScaffoldMessenger.of(context)
        .showSnackBar(
          const SnackBar(content: Text('Address Not Found'), backgroundColor: Colors.red,)
        );
      logger.e(e);
    }
    return '';
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
      config.apiKey, // Google Maps API Key
      PointLatLng(startLatitude, startLongitude),
      PointLatLng(destinationLatitude, destinationLongitude),
      travelMode: TravelMode.walking,
    );

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        _polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }

    PolylineId id = const PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.lightBlue,
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
      if (_eta.isNotEmpty) _eta = '';
    });

    final eta = await _calculateDistance();
    if (eta.isNotEmpty) {
      setState(() {
        _eta = eta;
      });
    }
  }

  _trip() async {
    ScaffoldMessenger.of(context)
      .showSnackBar(
        const SnackBar(content: Text('Trip Started'))
      );
  }
}