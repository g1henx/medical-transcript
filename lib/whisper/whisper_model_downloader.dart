import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medical_transcript/shared_preferences/shared_preferences.dart';
import 'package:medical_transcript/shared_preferences/shared_preferences_references.dart';
import 'package:medical_transcript/whisper/whisper_models.dart';
import 'package:path_provider/path_provider.dart';

class WhisperModelDownloader {
  static const String src = 'https://huggingface.co/ggerganov/whisper.cpp';
  static const String pfx = 'resolve/main/ggml';

  static const List<String> models = [
    WhisperModels.tiny,
    WhisperModels.tinyEn,
    WhisperModels.tinyQ51,
    WhisperModels.tinyEnQ51,
    WhisperModels.base,
    WhisperModels.baseEn,
    WhisperModels.baseQ51,
    WhisperModels.baseEnQ51,
    WhisperModels.small,
    WhisperModels.smallEn,
    WhisperModels.smallEnTdrz,
    WhisperModels.smallQ51,
    WhisperModels.smallEnQ51,
    WhisperModels.medium,
    WhisperModels.mediumEn,
    WhisperModels.mediumQ50,
    WhisperModels.mediumEnQ50,
    WhisperModels.largeV1,
    WhisperModels.largeV2,
    WhisperModels.largeV2Q50,
    WhisperModels.largeV3,
    WhisperModels.largeV3Q50,
  ];

  Future<void> downloadModel(String model, Function(double) onProgress, Function onComplete) async {
    if (!models.contains(model)) {
      throw Exception('Invalid model: $model');
    }

    final directory = await getApplicationDocumentsDirectory();
    final modelsPath = directory.path;

    final modelFilePath = '$modelsPath/ggml-$model.bin';

    // if (await File(modelFilePath).exists()) {
    //   print('Model $model already exists. Skipping download.');
    //   return;
    // }

    final modelUrl = '$src/$pfx-$model.bin';

    print('Downloading ggml model $model from $modelUrl ...');

    final request = http.Request('GET', Uri.parse(modelUrl));
    final response = await http.Client().send(request);

    if (response.statusCode == 200) {
      final contentLength = response.contentLength ?? 0;
      int bytesDownloaded = 0;
      List<int> bytes = [];

      response.stream.listen(
            (List<int> newBytes) {
          bytes.addAll(newBytes);
          bytesDownloaded += newBytes.length;
          double progress = bytesDownloaded / contentLength;
          onProgress(progress);
        },
        onDone: () async {
          final file = File(modelFilePath);
          await file.writeAsBytes(bytes);
          await SettingsPreferences.setString(selectedWhisperModel, model);
          await SettingsPreferences.setString(model, modelFilePath);
          await onComplete();
          print('Done! Model $model saved in $modelFilePath');
        },
        onError: (error) {
          print('Failed to download ggml model $model');
          throw Exception('Failed to download model');
        },
        cancelOnError: true,
      );
    } else {
      print('Failed to download ggml model $model');
      throw Exception('Failed to download model');
    }
  }
}


