import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps/services/location_services.dart';
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
  TextEditingController _searchController = TextEditingController();

  //default target location
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(16.027832, 108.220177),
    zoom: 18.4746,
  );

  //school target location
  static final CameraPosition _kSchool = CameraPosition(
      bearing: 180,
      target: LatLng(16.032010, 108.221182),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  //generating marker
  //origin marker
  static final Marker _kGooglePlexMarker = Marker(
    markerId: MarkerId('_kGooglePlex'),
    infoWindow: InfoWindow(title: 'My home'),
    icon: BitmapDescriptor.defaultMarker,
    position: LatLng(16.027832, 108.220177),
  );

  //school marker
  static final Marker _kSchoolMarker = Marker(
    markerId: MarkerId('_kSchool'),
    infoWindow: InfoWindow(title: 'Dong A University'),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    position: LatLng(16.032010, 108.221182),
  );

  // //draw polylines in the maps
  // static final Polyline _kPolyline = Polyline(
  //   consumeTapEvents: true,
  //   polylineId: PolylineId('_kPolyline'),
  //   points: [
  //     LatLng(16.027832, 108.220177),
  //     LatLng(16.032010, 108.221182),
  //   ],
  //   width: 3,
  //   color: Color.fromARGB(255, 69, 127, 175),
  //   jointType: JointType.round,
  // );

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
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _searchController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(
                      left: 10,
                    ),
                    hintText: 'Search by location...',
                    hintStyle: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                  onChanged: (value) => print(value),
                ),
              ),
              IconButton(
                  onPressed: () {
                    LocationService().getPlaceId(_searchController.text);
                  },
                  icon: Icon(Icons.search))
            ],
          ),
          Expanded(
            child: GoogleMap(
              mapType:
                  MapType.hybrid, //4 types: normal, hybrid, terrain & satellite
              markers: {
                _kGooglePlexMarker,
                _kSchoolMarker,
              },
              // polylines: {
              //   _kPolyline,
              // },
              initialCameraPosition: _kGooglePlex,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
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

  Future<void> _viewArea() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(16.027832, 108.220177),
            northeast: LatLng(16.032010, 108.221182),
          ),
          48.0),
    );
  }
}
