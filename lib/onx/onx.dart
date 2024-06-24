import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medical_transcript/onx/uint8list.dart';
import 'package:medical_transcript/tokenizer/wordpieze_tokenizer.dart';
import 'package:onnxruntime/onnxruntime.dart';

import '../tokenizer/bert_voclab.dart';
class Onx {

  static Future<dynamic> executeEmbeddingsInference({required String modelPath, required String text}) async {
    final sessionOptions = OrtSessionOptions();
    final modelBytes = await File(modelPath).readAsBytes();
    final session = OrtSession.fromBuffer(modelBytes, sessionOptions!);
    final tokenizer = WordpieceTokenizer(
      encoder: bertEncoder,
      decoder: bertDecoder,
      unkString: '[UNK]',
      unkToken: 100,
      startToken: 101,
      endToken: 102,
      maxInputTokens: 512,
      maxInputCharsPerWord: 100,
    );
    final tokens = tokenizer.tokenize(text).first.tokens;
    var inputIdsTensor = OrtValueTensor.createTensorWithDataList([tokens]);
    var attentionMaskTensor = OrtValueTensor.createTensorWithDataList([List.generate(tokens.length, (index2)=> 1, growable: false)]) ;
    var tokenTypeIdsTensor = OrtValueTensor.createTensorWithDataList([List.generate(tokens.length, (index2)=> 0, growable: false)]);
     final inputs = {'input_ids': inputIdsTensor,
       'token_type_ids': tokenTypeIdsTensor,
       'attention_mask': attentionMaskTensor,
     };
    final runOptions = OrtRunOptions();
    final outputs = await session.runAsync(runOptions, inputs);
    runOptions.release();
    var finalOutput = outputs?.map((e) => e?.value).toList();
    outputs?.forEach((element) {
      print((element?.value).toString());
      element?.release();
    });
    session.release();
    return finalOutput;
  }

  static Future<dynamic> executeWhisperInference({required String audioPath}) async {
    final sessionOptions = OrtSessionOptions();
    final rawAssetFile = await rootBundle.load('assets/models/base-encoder.onnx');
    final bytes = rawAssetFile.buffer.asUint8List();
    final session = OrtSession.fromBuffer(bytes, sessionOptions);
    final runOptions = OrtRunOptions();
    debugPrint(session.inputNames.toString());
    List<int> audioBytes = await File(audioPath).readAsBytes();
    var melTensor = OrtValueTensor.createTensorWithDataList([[audioBytes.toAudioFloat32List()]]);
    final inputs = {session.inputNames.first: melTensor};
    final outputs = await session.runAsync(runOptions, inputs);
     runOptions.release();
     var finalOutput = outputs?.map((e) => e?.value).toList();
     outputs?.forEach((element) {
       print((element?.value).toString());
       element?.release();
     });
     session.release();
    // return finalOutput;
  }

}