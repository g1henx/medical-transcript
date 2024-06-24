
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:medical_transcript/shared_preferences/shared_preferences.dart';
import 'package:medical_transcript/shared_preferences/shared_preferences_references.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../native_bridge/whisper/scheme/transcribe.dart';
import '../native_bridge/whisper/whisper_api.dart';
import '../onx/onx.dart';
//import 'package:record/record.dart';

class TranscriptProvider extends ChangeNotifier {
  String? selectedModel = SettingsPreferences.getString(selectedWhisperModel);
  String androidPath = "libwhisper.so";
  String iosPath = "libwhisper.dylib";
  String transcriptKey = '';
  String transcript = "";
  String currentTranscript = '';
  String lastAudioPath = "";
  bool isRecording = false;
  bool loadingWhisper = false;
  InputDevice? inputDevice;
  late AudioRecorder record;
  Timer? _timer;

  void setSelectedModel(String model) {
    selectedModel = model;
    SettingsPreferences.setString(selectedWhisperModel, model);
    notifyListeners();
  }

  Future<void> executeWhisperONNX({required String inputPath}) async {
    try {
      //String totalTranscript = '$transcript $currentTranscript';
     await Onx.executeWhisperInference(audioPath: inputPath);
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }

  }
  Future<Uint8List> collectStreamData(Stream<Uint8List> stream) async {
    final List<int> allBytes = []; // Use a List<int> to store all bytes
    await for (final chunk in stream) {
      allBytes.addAll(chunk); // Use addAll to efficiently append byte chunks
    }
    return Uint8List.fromList(allBytes); // Create the final Uint8List
  }
  Future<void> saveAudioChunkAndExecuteWhisper({bool awaitWhisper = false})async{
    if(awaitWhisper){
     await executeWhisper(inputPath: lastAudioPath.toString(), increaseVolume: true);
    }else{
      executeWhisper(inputPath: lastAudioPath.toString(), increaseVolume: true);
    }
  }
  Future<void> executeWhisper({required String inputPath, bool? increaseVolume}) async {
    try {
      //String totalTranscript = '$transcript $currentTranscript';
      Whisper whisper = Whisper(
          whisperLib: Platform.isAndroid ? androidPath : iosPath);
      debugPrint('Init transcript');
      debugPrint('Model Name: ${SettingsPreferences.getString(selectedWhisperModel)}');
      debugPrint('Model Path: ${SettingsPreferences.getString(
          SettingsPreferences.getString(selectedWhisperModel)) ?? "base"}');
      debugPrint('Pre-Audio Path: $inputPath');
      String outputPath = inputPath;
      int now = DateTime
          .now()
          .millisecondsSinceEpoch;
      if(increaseVolume!) {
        outputPath = inputPath
            .split('.wav')
            .first + '_boost' + '.wav';
        await FFmpegKit.execute('-i $inputPath -filter:a volume=4 $outputPath')
            .then(
                (result) async {
              //debugPrint(await result.getAllLogsAsString());
            }
        );
      }

      debugPrint('Post-Audio Path: $outputPath');
      Transcribe transcribeAnyAudio = await whisper.transcribe(
        whisperLib: Platform.isAndroid ? androidPath : iosPath,
        audio: outputPath,
        threads: 8,
        model: SettingsPreferences.getString(
            SettingsPreferences.getString(selectedWhisperModel)) ?? "base",
        // model
        //prompt the last 100 characters of the transcript
        prompt: transcript.substring(transcript.length - 200 < 0 ? 0 : transcript.length - 200),
        language: "es", // language
      );
      debugPrint('Finish transcript, Time: ${(DateTime.now().millisecondsSinceEpoch - now)/1000} s');
      print(transcribeAnyAudio.rawData);
      transcript = '$transcript ${transcribeAnyAudio.text ?? ''}';
      //File(inputPath).delete();
      //File(outputPath).delete();
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }

  }
  Future<void> initWhisper()async{
    // if(SettingsPreferences.getString(SettingsPreferences.getString(selectedWhisperModel) ?? 'base') != null){
    //   Directory directory = await getApplicationDocumentsDirectory();
    //   var initWavPath = directory.path + '/' + "init.wav";
    //   if(!(await File(initWavPath).exists())) {
    //     ByteData data = await rootBundle.load("assets/audio/init.wav");
    //     List<int> bytes =
    //         data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    //     await File(initWavPath).writeAsBytes(bytes);
    //   }
    //   loadingWhisper = true;
    //   notifyListeners();
    //   Whisper whisper = Whisper(
    //       whisperLib: Platform.isAndroid ? androidPath : iosPath);
    //   await whisper.load(model: SettingsPreferences.getString(
    //       SettingsPreferences.getString(selectedWhisperModel)) ?? "base",);
    //   await executeWhisper(inputPath: initWavPath, increaseVolume: false);
    //   transcript = '';
    //   loadingWhisper = false;
    //   notifyListeners();
    // }
  }
  Future<void> recording() async{
    String outputPath = (await getApplicationDocumentsDirectory()).path;
    int transcriptNumber = SettingsPreferences.getInt('transcript_number') ?? 0;
    transcriptKey = '${transcriptNumber}_transcript';
    lastAudioPath = outputPath + '/audio_${DateTime.now().millisecondsSinceEpoch}.wav';
     //lastAudioPath = '/data/data/com.myoxyn.medical_transcript/app_flutter/audio_1718522173706.wav';

    // debugPrint('loading model');
     // await executeWhisper(inputPath: lastAudioPath);
    bool updateTranscriptNumber = true;
    await record.start(
        RecordConfig(encoder:  AudioEncoder.wav, bitRate: 320000, sampleRate: 16000, device: inputDevice, noiseSuppress: false,  autoGain: true),
            path: lastAudioPath
    );
    await Future.delayed(Duration(seconds: 5));
    while(isRecording){
      await Future.delayed(Duration(seconds: 5));
      await record.stop();
      String path = outputPath + '/audio_${DateTime.now().millisecondsSinceEpoch}.wav';
      await record.start( RecordConfig(encoder:  AudioEncoder.wav, bitRate: 320000,  sampleRate: 16000, device: inputDevice, noiseSuppress: false,  autoGain: true), path: path);
       await saveAudioChunkAndExecuteWhisper(awaitWhisper: true);
      lastAudioPath = path.toString();
      SettingsPreferences.setString(transcriptKey, transcript);
      if(updateTranscriptNumber){
        SettingsPreferences.setInt('transcript_number', transcriptNumber++);
        updateTranscriptNumber = false;
      }
    }
    await record.stop();
    await saveAudioChunkAndExecuteWhisper(awaitWhisper: true);
    SettingsPreferences.setString(transcriptKey, transcript);
    //await whisper.unload();
     record.dispose();
    notifyListeners();
  }
  Future<void> startRecording() async {
    isRecording = true;
    notifyListeners();
    try{
      record = AudioRecorder();
    if (await record.hasPermission()) {
      recording();
      // _timer = Timer.periodic(Duration(seconds: 15), (Timer timer) async {
      //   try{
      //   await record.stop();
      //   executeWhisper(inputPath: lastAudioPath.toString());
      //   lastAudioPath = outputPath + '/audio_${DateTime.now().millisecondsSinceEpoch}.wav';
      //   final stream = await record.startStream( const RecordConfig(encoder:  AudioEncoder.wav));
      //   notifyListeners();
      //   } catch (e) {
      //     debugPrint(e.toString());
      //     recording = false;
      //     notifyListeners();
      //   }
      // });

      // Start the first recording immediately
     //  await record.record(path: lastAudioPath, androidEncoder: AndroidEncoder.aac, androidOutputFormat: AndroidOutputFormat.mpeg4, iosEncoder: IosEncoder.kAudioFormatMPEG4AAC);
       notifyListeners();
    }
    } catch (e) {
      debugPrint(e.toString());
      isRecording = false;
      notifyListeners();
    }
  }
  Future<void> stopRecording() async {
    if (_timer != null) {
      _timer!.cancel();
    }
    isRecording = false;
    notifyListeners();
  }
}