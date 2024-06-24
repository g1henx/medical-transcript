import 'dart:io';

import 'package:flutter/material.dart';
import 'package:medical_transcript/shared_preferences/shared_preferences.dart';
import 'package:medical_transcript/shared_preferences/shared_preferences_references.dart';
import 'package:medical_transcript/theme/theme.dart';
import 'package:medical_transcript/whisper/whisper.dart';
import 'package:provider/provider.dart';

import '../../whisper/whisper_model_downloader.dart';

class SelectModel extends StatefulWidget {
  const SelectModel({super.key});

  @override
  State<SelectModel> createState() => _SelectModelState();
}

class _SelectModelState extends State<SelectModel> {
  bool downloading = false;
  bool deleting = false;
  double progress = 0.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, TranscriptProvider transcript, _){
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<String>(
                value: transcript.selectedModel,
                onChanged: (String? model) {
                  if (model == null) {
                    return;
                  }
                  transcript.setSelectedModel(model);
                  if(SettingsPreferences.getString(model) != null){
                    transcript.initWhisper();
                  }
                },
                items: WhisperModelDownloader.models.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(color: SettingsPreferences.getString(value) != null ? appTheme.highlightColor : Colors.white),),
                  );
                }).toList(),
              ),
              deleting || downloading ?
              CircularProgressIndicator() :
              SettingsPreferences.getString(transcript.selectedModel!) != null ?
              IconButton(
                onPressed: ()async {
                  try{
                  await File(SettingsPreferences.getString(transcript.selectedModel!)!).delete();
                  }catch(e){
                    debugPrint(e.toString());
                  }
                  SettingsPreferences.removeKey(transcript.selectedModel!);
                  setState(() {
                  });
                },
                icon: const Icon(Icons.delete),
              ) :
              IconButton(
                onPressed: () {
                  progress = 0.0;
                  downloading = true;
                  WhisperModelDownloader().downloadModel(transcript.selectedModel!, (double progress){
                    setState(() {
                      this.progress = progress;
                    });
                  },
                          () {
                            transcript.initWhisper();
                        setState(() {
                          downloading = false;
                          progress = 1.0;
                        });
                      }
                  );
                  setState(() {
                  });
                },
                icon: const Icon(Icons.download),
              ),
            ],
          ),
          Visibility(
              child:  LinearProgressIndicator(
                value: progress,
              ),
              visible: progress > 0.0 && progress < 1.0
          ),
        ],
      );
    });
  }
}
