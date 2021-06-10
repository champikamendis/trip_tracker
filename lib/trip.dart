import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Trip {
  late String time;
  late List<LatLng> route;

  Trip({ required String t, required List<LatLng> r}) {
    time = t;
    route = r;
  }

  factory Trip.fromJson(Map<String, dynamic> parsedJson) {
    return new Trip(
      t: parsedJson['time'] ?? "",
      r: parsedJson['route'] ?? ""
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "time": this.time,
      "route": this.route
    };
  }
  // static getTrips() async {
  //   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  //   String? tripEncoded = sharedPreferences.getString('trips');
  //   List<dynamic> dynamicTrips = jsonDecode(tripEncoded!);
  //   print(dynamicTrips);
  //   return dynamicTrips;
  // }
}

// void saveTrips(List<Trip> trips) async {
//   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
//   String tripEncoded = jsonEncode(trips);
//   var res = await sharedPreferences.setString('trips', tripEncoded);
//   print(res);
// }