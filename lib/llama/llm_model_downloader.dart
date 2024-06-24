import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:medical_transcript/llama/llm_models.dart';
import 'package:medical_transcript/shared_preferences/shared_preferences.dart';
import 'package:medical_transcript/shared_preferences/shared_preferences_references.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'llm_provider.dart';

class LlmModelDownloader{
  static List<LlmModel> models = [
    llamaSmall,
    qwen205Small,
    qwen215Small,
    qwen27Small,
    mistralSmall,
    llamaMedium,
    qwen205Medium,
    qwen215Medium,
    qwen27Medium,
    phi3Medium,
    gemma,
    mistralMedium,
    llamaBig,
    qwen205Big,
    qwen215Big,
    qwen27Big,
    phi3Big,
    mistralBig
  ];
  // Future<void> downloadModel(LlmModel model, Function(double) onProgress, Function onComplete) async {
  //
  //
  //   final directory = await getApplicationDocumentsDirectory();
  //   final modelsPath = directory.path;
  //
  //   final modelFilePath = '$modelsPath/${model.path.split('/').last}';
  //
  //   // if (await File(modelFilePath).exists()) {
  //   //   print('Model $model already exists. Skipping download.');
  //   //   return;
  //   // }
  //
  //
  //   print('Downloading ggml model $model from ${model.path} ...');
  //
  //   final request = http.Request('GET', Uri.parse(model.path));
  //   final response = await http.Client().send(request);
  //
  //   if (response.statusCode == 200) {
  //     final contentLength = response.contentLength ?? 0;
  //     int bytesDownloaded = 0;
  //     List<int> bytes = [];
  //
  //     response.stream.listen(
  //           (List<int> newBytes) {
  //         bytes.addAll(newBytes);
  //         bytesDownloaded += newBytes.length;
  //         double progress = bytesDownloaded / contentLength;
  //         onProgress(progress);
  //       },
  //       onDone: () async {
  //         final file = File(modelFilePath);
  //         await file.writeAsBytes(bytes);
  //         await SettingsPreferences.setString(selectedLLM, model.name);
  //         await SettingsPreferences.setString(model.name, modelFilePath);
  //         await onComplete();
  //         print('Done! Model $model saved in $modelFilePath');
  //       },
  //       onError: (error) {
  //         print('Failed to download ggml model $model');
  //         throw Exception('Failed to download model');
  //       },
  //       cancelOnError: true,
  //     );
  //   } else {
  //     print('Failed to download ggml model $model');
  //     throw Exception('Failed to download model');
  //   }
  // }
  static Future<void> downloadModel(LlmModel model, BuildContext context) async {
    var llm = Provider.of<LlmProvider>(context, listen: false);
    llm.setDownloading(true);
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
    llm.setDownloading(false);

  }
  static Future<void> updateDownloadStatus(String taskID, BuildContext context)async{
    var llm = Provider.of<LlmProvider>(context, listen: false);
    llm.setDownloading(true);
    var downloadTask = await FlutterDownloader.loadTasksWithRawQuery(
        query: 'SELECT * FROM task WHERE task_id = "$taskID"').then((
        value) {
          if(value!.isEmpty){
            return null;
          }
      return value.first;
    });
    if(downloadTask == null){
      llm.setDownloading(false);
      return;
    }
    while (downloadTask!.status == DownloadTaskStatus.running ||
        downloadTask.status == DownloadTaskStatus.enqueued) {
      await Future.delayed(Duration(seconds: 1));
      downloadTask = await FlutterDownloader.loadTasksWithRawQuery(
          query: 'SELECT * FROM task WHERE task_id = "$taskID"').then((
          value) => value!.first);
      if(downloadTask.status == DownloadTaskStatus.running){
        llm.setDownloadProgress(downloadTask.progress);
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
    llm.setDownloading(false);
  }
}