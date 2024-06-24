import 'dart:io';

import 'package:flutter/material.dart';
import 'package:medical_transcript/llama/llm_model_downloader.dart';
import 'package:provider/provider.dart';

import '../../llama/llm_models.dart';
import '../../llama/llm_provider.dart';
import '../../shared_preferences/shared_preferences.dart';
import '../../theme/theme.dart';

class SelectLlm extends StatefulWidget {
  const SelectLlm({super.key});

  @override
  State<SelectLlm> createState() => _SelectLlmState();
}

class _SelectLlmState extends State<SelectLlm> {
  bool deleting = false;
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, LlmProvider llmProvider, _){
      return Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButton<String>(
                    value: llmProvider.selectedModel,
                    onChanged: (String? model) {
                      if (model == null) {
                        return;
                      }
                      llmProvider.setSelectedModel(model);
                    },
                    items: LlmModelDownloader.models.map<DropdownMenuItem<String>>((LlmModel value) {
                      return DropdownMenuItem<String>(
                        value: value.name,
                        child: Text(value.name, style: TextStyle(color: SettingsPreferences.getString(value.name) != null ? appTheme.highlightColor : Colors.white),),
                      );
                    }).toList(),
                  ),
                  deleting || llmProvider.downloading ?
                  CircularProgressIndicator() :
                  SettingsPreferences.getString(llmProvider.selectedModel) != null ?
                  IconButton(
                    onPressed: ()async {
                      setState(() {
                        deleting = true;
                      });
                      try{
                        await File(SettingsPreferences.getString(llmProvider.selectedModel!)!).delete();
                      }catch(e){
                        debugPrint(e.toString());
                      }
                      SettingsPreferences.removeKey(llmProvider.selectedModel!);
                      setState(() {
                        deleting = false;
                      });
                    },
                    icon: const Icon(Icons.delete),
                  ) :
                  IconButton(
                    onPressed: () {
                      LlmModelDownloader.downloadModel(LlmModelDownloader.models.firstWhere((e) => e.name == llmProvider.selectedModel), context);
                    },
                    icon: const Icon(Icons.download),
                  ),
                ],
              ),
              Visibility(
                  child:  LinearProgressIndicator(
                    value: llmProvider.downloadProgress/100,
                  ),
                  visible: llmProvider.downloadProgress/100 > 0.0 && llmProvider.downloadProgress/100 < 1.0
              ),
            ],
          ),
        ),
      );
    });
  }
}
