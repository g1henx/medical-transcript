import 'dart:io';
import 'dart:typed_data';
import 'package:dvdb/dvdb.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:medical_transcript/llama/llm_provider.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../onx/onx.dart';
import '../shared_preferences/shared_preferences.dart';
import '../shared_preferences/shared_preferences_references.dart';

class IngestPdf{
  static Future<void> ingest(BuildContext context)async {
    var llmProvider = Provider.of<LlmProvider>(context, listen: false);
    llmProvider.startThinking();
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if(result == null) {
      return;
    }
    final file = File(result.files.first.path!);
    final PdfDocument document =
    PdfDocument(inputBytes: file.readAsBytesSync());
//Extract the text from all the pages.
    String text = PdfTextExtractor(document).extractText();
//Dispose the document.
    document.dispose();
    List<String> textList = recursiveTextSplitter(text);

    final collection = DVDB().collection(file.path.split('/').last);
    SettingsPreferences.setString(selectedCollection, collection.name);
    for(var text in textList){
      // Get embeddings
      final embeddings = await Onx.executeEmbeddingsInference(modelPath: SettingsPreferences.getString(SettingsPreferences.getString(selectedEmbeddingsModel)),
          text: text);
    List<double> vectors = ((embeddings as List<Object?>).first as List<List<List<double>>>).first.first;
    collection.addDocument(DateTime.now().microsecondsSinceEpoch.toString(), text, Float64List.fromList(vectors));
    }
    debugPrint('FINISH-------');
    llmProvider.stopThinking();
  }

  static List<String> recursiveTextSplitter(String text){
    List<String> textList = text.split('.');
    List<String> finalTextList = [];
    for(String text in textList){
      if(finalTextList.isEmpty){
        finalTextList.add(text);
      }else{
        String lastText = finalTextList.last;
        if(lastText.length + text.length < 500){
          finalTextList[finalTextList.length - 1] = '$lastText. $text';
        }else{
          finalTextList.add(text);
        }
      }
    }
    return finalTextList;
  }
}