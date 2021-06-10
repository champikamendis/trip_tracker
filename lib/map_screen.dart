import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class MapScreen extends StatefulWidget {
  MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {

  Completer<GoogleMapController> _controller = Completer();
  Map<MarkerId, Marker> markers = {};
  late LatLng _originLocation;
  late LatLng _destLocation;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = "AIzaSyCmdIrgckY68EcKrytDL8u74U-YXIPl0CQ";
  IconData startStopIcon = Icons.navigation;
  String appBarText = 'Route Track';

  Stopwatch watch = Stopwatch();
  late Timer timer;
  bool startStop = true;

  String elapsedTime = '';

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  void initState() {
    _determinePosition();
    super.initState();
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          startOrStopTrip();
          },
        child: Icon(startStopIcon),
      ),
    );
  }
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    final GoogleMapController controller = await _controller.future;

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.best, distanceFilter: 0).listen(
            (Position position) {
              setState(() {
                _destLocation = LatLng(position.latitude, position.longitude);
                polylineCoordinates.add(_destLocation);
              });
            print(position == null ? 'Unknown' : position.latitude.toString() + ', ' + position.longitude.toString());
            final cameraPosition = CameraPosition(target: LatLng(position.latitude, position.longitude), zoom: 20);
            controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
        });
    return position;
  }

  updateTime(Timer timer) {
    if (watch.isRunning) {
      setState(() {
        elapsedTime = transformMilliSeconds(watch.elapsedMilliseconds);
        appBarText = '$elapsedTime';
      });
    }
  }

  _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker = Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
  }

  _getPolyline() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(googleAPiKey,
        PointLatLng(_originLocation.latitude, _originLocation.longitude),
        PointLatLng(_destLocation.latitude, _destLocation.longitude)
    );
    _addPolyLine();
  }

  _addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.red,
        points: polylineCoordinates,
    );
    setState(() {
      polylines[id] = polyline;
    });
  }

  stopWatch() {
    setState(() {
      startStop = true;
      watch.stop();
      setTime();
    });
  }

  setTime() {
    var timeSoFar = watch.elapsedMilliseconds;
    setState(() {
      elapsedTime = transformMilliSeconds(timeSoFar);
    });
  }

  startOrStopTrip() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best, forceAndroidLocationManager: true);
    if(startStop) {
      setState(() {
        _originLocation = LatLng(position.latitude, position.longitude);
        startStopIcon = Icons.stop;
        appBarText = '$elapsedTime';
      });
      startWatch();
      getTrackedPath();
    } else {
      setState(() {
        startStopIcon = Icons.navigation;
        appBarText = 'Track Route';
      });
      stopWatch();
      Navigator.pop(context, [elapsedTime, polylineCoordinates]);
    }
  }

  startWatch() {
    setState(() {
      startStop = false;
      watch.start();
      timer = Timer.periodic(Duration(milliseconds: 100), updateTime);
    });
  }

  transformMilliSeconds(int milliseconds) {
    int hundreds = (milliseconds / 10).truncate();
    int seconds = (hundreds / 100).truncate();
    int minutes = (seconds / 60).truncate();
    int hours = (minutes / 60).truncate();

    String hoursStr = (hours % 60).toString().padLeft(2, '0');
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');

    return "$hoursStr:$minutesStr:$secondsStr";
  }

  getTrackedPath () {
    /// origin marker
    _addMarker(_originLocation, "origin",
        BitmapDescriptor.defaultMarker);
    _getPolyline();
  }
}
