import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:medical_transcript/embeddings/embeddings.dart';
import 'package:medical_transcript/embeddings/embeddings_models.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../shared_preferences/shared_preferences.dart';
import '../shared_preferences/shared_preferences_references.dart';

class EmbeddingsDownloader{
  static List<EmbeddingsModel> models = [
    nomic,
    nomicQ,
    nomicGGUF,
    allMiniLLm6
  ];
  static Future<void> downloadModel(EmbeddingsModel model, BuildContext context) async {
    var embeddings = Provider.of<Embeddings>(context, listen: false);
    embeddings.setDownloading(true);
    try {
      final appDir = await getApplicationDocumentsDirectory();
      String modelDir = '${appDir.path}/${model.path.split('/').last}';
      debugPrint(modelDir);
      final taskId = await FlutterDownloader.enqueue(
        url: model.path,
        headers: {},
        // optional: header send with url (auth token etc)
        savedDir: appDir.path,
        showNotification: true,
        // show download progress in status bar (for Android)
        openFileFromNotification: false, // click on notification to open downloaded file (for Android)
      );
      SettingsPreferences.setString(lastDownloadTaskID, taskId!);
      SettingsPreferences.setString(lastDownloadModelName, model.name);
      SettingsPreferences.setString(lastDownloadModelPath, modelDir);
      await updateDownloadStatus(taskId!, context);
    }catch(e){
      debugPrint(e.toString());
    }
    embeddings.setDownloading(false);

  }
  static Future<void> updateDownloadStatus(String taskID, BuildContext context)async{
    var embeddings = Provider.of<Embeddings>(context, listen: false);
    embeddings.setDownloading(true);
    var downloadTask = await FlutterDownloader.loadTasksWithRawQuery(
        query: 'SELECT * FROM task WHERE task_id = "$taskID"').then((
        value) {
      if(value!.isEmpty){
        return null;
      }
      return value.first;
    });
    if(downloadTask == null){
      embeddings.setDownloading(false);
      return;
    }
    while (downloadTask!.status == DownloadTaskStatus.running ||
        downloadTask.status == DownloadTaskStatus.enqueued) {
      await Future.delayed(Duration(seconds: 1));
      downloadTask = await FlutterDownloader.loadTasksWithRawQuery(
          query: 'SELECT * FROM task WHERE task_id = "$taskID"').then((
          value) => value!.first);
      if(downloadTask.status == DownloadTaskStatus.running){
        embeddings.setDownloadProgress(downloadTask.progress);
      }
      if(downloadTask.status == DownloadTaskStatus.complete){
        // debugPrint('FINISH');
        // debugPrint(downloadTask.savedDir);
        // debugPrint(downloadTask.filename);
        SettingsPreferences.setString(lastDownloadTaskID, '');
        SettingsPreferences.setString(SettingsPreferences.getString(lastDownloadModelName), '${downloadTask.savedDir}/${downloadTask.filename}');
        SettingsPreferences.setString(lastDownloadModelName, '');
        SettingsPreferences.setString(lastDownloadModelPath, '');
        break;
      }
    }
    embeddings.setDownloading(false);
  }
}