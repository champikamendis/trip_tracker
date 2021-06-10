import 'dart:core';
import 'package:flutter/material.dart';
import 'package:trip_tracker/map_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trip_tracker/route_preview_screen.dart';
import 'package:trip_tracker/shared_preference.dart';
import 'package:trip_tracker/trip.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: MyHomePage(title: 'Trip Details'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var result;
  List<LatLng> polylineCoordinates = [];
  String googleAPiKey = "AIzaSyCmdIrgckY68EcKrytDL8u74U-YXIPl0CQ";
  String elapsedTime = '';
  late List <Trip> trips = [];
  SharedPreference sharedPref = SharedPreference();

  @override
  void initState() {
    getPreviousTrips();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: trips.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: ()=>{ Navigator.push(context, MaterialPageRoute(builder: (context) => RouteViewScreen(trip: trips[index]),),)},
            child: Container(
              height: 50,
              color: Colors.amber[200],
              child: Center(child: Text('Trip ${trips[index].time}')),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          result = await Navigator.push(context, MaterialPageRoute(builder: (context) => MapScreen()));
          if (result != null) {
            setState(() {
              elapsedTime = result[0];
              polylineCoordinates = result[1];
            });
            storeTimeAndRoute(elapsedTime, polylineCoordinates);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  getPreviousTrips() async {
    // List<Trip> tripData = Trip.fromJson(await sharedPref.readTrips('trips')) as List<Trip>;
    // setState(() {
    //   trips = tripData;
    // });
  }

  storeTimeAndRoute(String time, List<LatLng> route) async{
    setState(() {
      trips.add(Trip(t: time, r: route));
      sharedPref.saveTrips('trips', trips);
    });

  }
}
