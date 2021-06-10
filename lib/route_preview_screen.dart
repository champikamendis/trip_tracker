import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class RouteViewScreen extends StatefulWidget {
  final  trip;
  RouteViewScreen({Key? key, required this.trip}) : super(key: key);

  @override
  _RouteViewScreenState createState() => _RouteViewScreenState();
}

class _RouteViewScreenState extends State<RouteViewScreen> {

  Completer<GoogleMapController> _controller = Completer();
  Map<MarkerId, Marker> markers = {};

  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = "AIzaSyCmdIrgckY68EcKrytDL8u74U-YXIPl0CQ";
  String appBarText = 'Route Track';

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );


  @override
  void initState() {
    super.initState();
    _addPolyLine();
    // polylineCoordinates = trip
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarText),
      ),
      body: GoogleMap(
        mapType: MapType.hybrid,
        myLocationButtonEnabled: false,
        myLocationEnabled: true,
        initialCameraPosition: _kGooglePlex,
        markers: Set<Marker>.of(markers.values),
        polylines: Set<Polyline>.of(polylines.values),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }
  _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker = Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
  }

  _addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: this.polylineCoordinates,
    );
    setState(() {
      polylines[id] = polyline;
    });
  }
}


