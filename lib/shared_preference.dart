import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreference {

  readTrips(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return json.decode(prefs.getString(key)!);
  }

  saveTrips(String key, value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, json.encode(value));
  }

  removeTrips(String key) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }
}