import 'package:dvdb/dvdb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:medical_transcript/embeddings/embeddings_models.dart';
import 'package:medical_transcript/shared_preferences/shared_preferences_references.dart';

import '../onx/onx.dart';
import '../shared_preferences/shared_preferences.dart';

class Embeddings extends ChangeNotifier{
  bool isModelLoaded = false;
  bool downloading = false;
  int downloadProgress = 0;
  String selectedModel = SettingsPreferences.getString(selectedEmbeddingsModel) ?? nomic.name;
  void setSelectedModel(String model){
    selectedModel = model;
    SettingsPreferences.setString(selectedEmbeddingsModel, model);
    notifyListeners();
  }
  void setDownloading(bool value){
    downloading = value;
    notifyListeners();
  }
  void setDownloadProgress(int value){
    downloadProgress = value;
    notifyListeners();
  }
  void loadModel()async{
    isModelLoaded = true;
    notifyListeners();
  }
  Future<void> getEmbeddings(String text)async{
    // Get embeddings
   await Onx.executeEmbeddingsInference(modelPath: SettingsPreferences.getString(SettingsPreferences.getString(selectedEmbeddingsModel)), text: text
    );
    notifyListeners();
  }
  Future<List<String>> search(String text)async{
    // Get embeddings
    final embeddings = await Onx.executeEmbeddingsInference(modelPath: SettingsPreferences.getString(SettingsPreferences.getString(selectedEmbeddingsModel)), text: text
    );
    List<double> vectors = ((embeddings as List<Object?>).first as List<List<List<double>>>).first.first;
    final collection = DVDB().getCollection(SettingsPreferences.getString(selectedCollection))!;
    final searchResults = collection.search(Float64List.fromList(vectors), numResults: 5);
    return searchResults.map((e) => e.text).toList();
    notifyListeners();
  }
}