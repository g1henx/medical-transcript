import 'dart:io';

import 'package:flutter/material.dart';
import 'package:medical_transcript/embeddings/embeddings.dart';
import 'package:medical_transcript/embeddings/embeddings_downloader.dart';
import 'package:medical_transcript/embeddings/embeddings_models.dart';
import 'package:medical_transcript/embeddings/ingest_pdf.dart';
import 'package:provider/provider.dart';
import '../../shared_preferences/shared_preferences.dart';
import '../../theme/theme.dart';

class SelectEmbeddings extends StatefulWidget {
  const SelectEmbeddings({super.key});

  @override
  State<SelectEmbeddings> createState() => _SelectEmbeddingsState();
}

class _SelectEmbeddingsState extends State<SelectEmbeddings> {
  bool deleting = false;
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, Embeddings embeddings, _){
      return Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.15),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(onPressed: (){
                    IngestPdf.ingest(context);
                  }, icon: Icon(Icons.add)),
                  DropdownButton<String>(
                    value: embeddings.selectedModel,
                    onChanged: (String? model) {
                      if (model == null) {
                        return;
                      }
                      embeddings.setSelectedModel(model);
                    },
                    items: EmbeddingsDownloader.models.map<DropdownMenuItem<String>>((EmbeddingsModel value) {
                      return DropdownMenuItem<String>(
                        value: value.name,
                        child: Text(value.name, style: TextStyle(color: SettingsPreferences.getString(value.name) != null ? appTheme.highlightColor : Colors.white),),
                      );
                    }).toList(),
                  ),
                  deleting || embeddings.downloading ?
                  CircularProgressIndicator() :
                  SettingsPreferences.getString(embeddings.selectedModel) != null ?
                  IconButton(
                    onPressed: ()async {
                      setState(() {
                        deleting = true;
                      });
                      try{
                        await File(SettingsPreferences.getString(embeddings.selectedModel!)!).delete();
                      }catch(e){
                        debugPrint(e.toString());
                      }
                      SettingsPreferences.removeKey(embeddings.selectedModel!);
                      setState(() {
                        deleting = false;
                      });
                    },
                    icon: const Icon(Icons.delete),
                  ) :
                  IconButton(
                    onPressed: () {
                      EmbeddingsDownloader.downloadModel(EmbeddingsDownloader.models.firstWhere((e) => e.name == embeddings.selectedModel), context);
                    },
                    icon: const Icon(Icons.download),
                  ),
                ],
              ),
              Visibility(
                  child:  LinearProgressIndicator(
                    value: embeddings.downloadProgress/100,
                  ),
                  visible: embeddings.downloadProgress/100 > 0.0 && embeddings.downloadProgress/100 < 1.0
              ),
            ],
          ),
        ),
      );
    });
  }
}
