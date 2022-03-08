import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
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
  TextEditingController _originController = TextEditingController();
  TextEditingController _destinationController = TextEditingController();

  Set<Marker> _markers = Set<Marker>();
  Set<Polygon> _polygons = Set<Polygon>();
  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polygonLatLngs = <LatLng>[];
  int _polygonIdCounter = 1;
  int _polylineIdCounter = 1;

  @override
  void initState() {
    super.initState();
    _setDefaultMarker(LatLng(16.027832, 108.220177));
  }

  void _setDefaultMarker(LatLng point) {
    setState(() {
      _markers.add(
        Marker(markerId: MarkerId('marker'), position: point),
      );
    });
  }

  void _setPolygons() {
    final String polygonIdVal = 'polygon_$_polygonIdCounter';
    _polygonIdCounter++;

    _polygons.add(
      Polygon(
        polygonId: PolygonId(polygonIdVal),
        points: polygonLatLngs,
        strokeWidth: 2,
        fillColor: Colors.transparent,
      ),
    );
  }

  void _setPolylines(List<PointLatLng> points) {
    final String polylineIdVal = 'polyline_$_polylineIdCounter';
    _polylineIdCounter++;

    _polylines.add(
      Polyline(
        polylineId: PolylineId(polylineIdVal),
        width: 2,
        color: Colors.blue,
        points: points
            .map(
              (point) => LatLng(point.latitude, point.longitude),
            )
            .toList(),
      ),
    );
  }

  //default target location
  // static final CameraPosition _kGooglePlex = CameraPosition(
  //   target: LatLng(16.027832, 108.220177),
  //   zoom: 18.4746,
  // );

  //school target location
  // static final CameraPosition _kSchool = CameraPosition(
  //     bearing: 180,
  //     target: LatLng(16.032010, 108.221182),
  //     tilt: 59.440717697143555,
  //     zoom: 19.151926040649414);

  //school marker
  // static final Marker _kSchoolMarker = Marker(
  //   markerId: MarkerId('_kSchool'),
  //   infoWindow: InfoWindow(title: 'Dong A University'),
  //   icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
  //   position: LatLng(16.032010, 108.221182),
  // );

//generating marker
  //origin marker
  static final CameraPosition _kGooglePlexMarker = CameraPosition(
    target: LatLng(16.027832, 108.220177),
    zoom: 19.5876,
  );

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
                child: Column(
                  children: [
                    TextFormField(
                      controller: _originController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(left: 8.0),
                          hintText: ' Origin'),
                      onChanged: (value) {
                        print(value);
                      },
                    ),
                    TextFormField(
                      controller: _destinationController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(left: 8.0),
                          hintText: ' Destination'),
                      onChanged: (value) {
                        print(value);
                      },
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () async {
                  var directions = await LocationServices().getDirections(
                    _originController.text,
                    _destinationController.text,
                  );
                  _goToPlace(
                    directions['start_location']['lat'],
                    directions['start_location']['lng'],
                    directions['bounds_ne'],
                    directions['bounds_sw'],
                  );

                  _setPolylines(directions['polyline_decoded']);
                },
                icon: Icon(Icons.search),
              ),
            ],
          ),
          Expanded(
            child: GoogleMap(
              mapType: MapType.hybrid,
              markers: _markers,
              polygons: _polygons,
              polylines: _polylines,
              initialCameraPosition: _kGooglePlexMarker,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              onTap: (point) {
                setState(() {
                  polygonLatLngs.add(point);
                  _setPolygons();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _goToPlace(
    double lat,
    double lng,
    Map<String, dynamic> boundsNe,
    Map<String, dynamic> boundsSw,
  ) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 14.667),
      ),
    );

    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(boundsSw['lat'], boundsSw['lng']),
            northeast: LatLng(boundsNe['lat'], boundsNe['lng']),
          ),
          30),
    );
    _setDefaultMarker(LatLng(lat, lng));
  }
}
