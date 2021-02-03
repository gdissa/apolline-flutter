import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class LocalKeyValuePersistance {

  static String generateKey(String key) {
    return "apolline_$key";
  }
  
  static Future<void> saveObject(String key, Map<String, dynamic> data) async{
    var prefs = await SharedPreferences.getInstance();
    var stringObject = JsonEncoder().convert(data);
    await prefs.setString(generateKey(key), stringObject);
  }

  static Future<Map<String, dynamic>> getObject(String key) async{
    var prefs = await SharedPreferences.getInstance();
    var stringObject = prefs.getString(generateKey(key));
    if(stringObject != null)  {
      return JsonDecoder().convert(stringObject) as Map<String, dynamic>;
    }
    return null;
  }
}