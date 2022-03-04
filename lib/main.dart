import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Google Maps Demo',
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();

  //default target location
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(16.027832, 108.220177),
    zoom: 16.4746,
  );

  //school target location
  static final CameraPosition _kSchool = CameraPosition(
      bearing: 180,
      target: LatLng(16.032010, 108.221182),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: Icon(Icons.arrow_back_ios),
        title: Text(
          'Google Maps',
        ),
      ),
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: Row(
        children: [
          SizedBox(
            width: 45,
          ),
          FloatingActionButton.extended(
            onPressed: _goToTheSchool,
            label: Text('Go to school!'),
            icon: Icon(Icons.school),
          ),
          SizedBox(
            width: 10,
          ),
          FloatingActionButton.extended(
            onPressed: _backToTheOrigin,
            label: Text('Go home!'),
            icon: Icon(Icons.home),
          ),
        ],
      ),
    );
  }

  Future<void> _goToTheSchool() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kSchool));
  }

  Future<void> _backToTheOrigin() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kGooglePlex));
  }
}
