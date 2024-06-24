
import 'dart:io';
import 'package:medical_transcript/shared_preferences/shared_preferences_references.dart';
import 'package:medical_transcript/whisper/whisper_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPreferences {
  static late SharedPreferences _preferences;
  static List<Uri> recievedPlans = [];
  static containsKey(String key){
    return _preferences.containsKey(key);
  }
  static initLocalSetting(String key, dynamic defaultValue)async{
    if(_preferences.containsKey(key)){
      return;
    }
    if(defaultValue.runtimeType == int){
      await  setInt(key, defaultValue);
    }
    if(defaultValue.runtimeType == bool){
      await  setBool(key, defaultValue);
    }
    if(defaultValue.runtimeType == double){
      await  setDouble(key, defaultValue);
    }
    if(defaultValue.runtimeType == String){
      await setString(key, defaultValue);
    }
  }
  static Future initLocal()async{
    _preferences = await SharedPreferences.getInstance();
    await initLocalSetting(selectedWhisperModel, WhisperModels.smallQ51);
  }

  static Future setInt (String key, int value) async {
    await _preferences.setInt(key, value);
  }

  static Future setBool (String key, bool value) async {
    await _preferences.setBool(key, value);
  }
  static Future setDouble (String key, double value) async {
    await _preferences.setDouble(key, value);
  }
  static Future setString (String key, String value) async {
    await _preferences.setString(key, value);
  }
  static Future removeKey (String key) async {
    await _preferences.remove(key);
  }
  static getInt (String key)  {
    return  _preferences.getInt(key);
  }
  static getBool (String key) {
    return  _preferences.getBool(key);
  }
  static getDouble (String key)  {
    return  _preferences.getDouble(key);
  }
  static getString (String key) {
    return  _preferences.getString(key);
  }
}