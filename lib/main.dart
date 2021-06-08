import 'package:flutter/material.dart';
import 'package:trip_tracker/map_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  late List<String> entries = [];

  @override
  void initState() {
    setDataFromSharedPref();
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
        itemCount: entries.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            height: 50,
            color: Colors.amber[200],
            child: Center(child: Text('Trip ${entries[index]}')),
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
            entries.add(elapsedTime);
            storeTimeAndRoute(entries, polylineCoordinates);
          }

        },
        child: Icon(Icons.add),
      ),
    );
  }

  setDataFromSharedPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      entries = prefs.getStringList('entries')!;
    });
  }

  storeTimeAndRoute(List<String> entries, List<LatLng> polylineCoordinates) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('entries', entries);
  }
}
