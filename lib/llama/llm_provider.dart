import 'dart:async';

import 'package:dvdb/dvdb.dart';
import 'package:fllama/fllama.dart';
import 'package:fllama/io/fllama_bindings_generated.dart';
import 'package:flutter/cupertino.dart';
import 'package:medical_transcript/llama/llm_model_downloader.dart';
import 'package:medical_transcript/llama/llm_models.dart';
import 'package:medical_transcript/llama/native/lib/llama_cpp_dart.dart';
import 'package:medical_transcript/shared_preferences/shared_preferences.dart';
import 'package:medical_transcript/shared_preferences/shared_preferences_references.dart';
import 'package:provider/provider.dart';

import '../data_models/chat_data.dart';
import '../embeddings/embeddings.dart';
import 'native/lib/src/context_params.dart';

class LlmProvider extends ChangeNotifier{
  bool downloading = false;
  int downloadProgress = 0;
  List<ChatData> messages = [];
  bool thinking = false;
  TextEditingController messageController = TextEditingController();
  String selectedModel = SettingsPreferences.getString(selectedLLM) ?? qwen215Big.name;
  LlamaProcessor? llamaProcessor;
  bool isModelLoaded = false;
  StreamSubscription<String>? _streamSubscription;
  void startThinking(){
    thinking = true;
    notifyListeners();
  }
  void setSelectedModel(String model){
    selectedModel = model;
    SettingsPreferences.setString(selectedLLM, model);
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
  Future<void> stopThinking()async{
    thinking = false;
    notifyListeners();
  }
Future<void> sendMessage()async{
  thinking = true;
  messages.add(ChatData(message: messageController.text, sender: MessageSender.user, time: DateTime.now().millisecondsSinceEpoch));
  messageController.clear();
  notifyListeners();
  // ContextParams contextParams = ContextParams(
  // );
  // int size = 32768;
  // size = 8192 * 4;
  // contextParams.embedding = false;
  // contextParams.batch = 1000;
  // contextParams.context = 2000;
  // contextParams.mulMatQ = false;
  // contextParams.threads = 6;
  //contextParams.ropeFreqBase = 57200 * 4;
  //contextParams.ropeFreqScale = 0.75 / 4;
  debugPrint('Loading model');
  llamaProcessor = LlamaProcessor(
    path: SettingsPreferences.getString(SettingsPreferences.getString(selectedLLM)),
    modelParams: ModelParams(),
    samplingParams: SamplingParams(),
    contextParams: ContextParams()
  );
  debugPrint('Model Loaded');
  // Llama llama = Llama(
  //     , // Change this to the path of your model
  //     ModelParams(),
  //     contextParams);
  //Last 4 messages String
  String last4Messages = messages.length > 4 ? messages.sublist(messages.length - 4).map((e) => e.sender + ': ' + e.message).join(' -') : messages.map((e) => e.message).join(' -');
  //llama.setPrompt(last4Messages); // Change this to your prompt
  messages.add(ChatData(message: '', sender: MessageSender.ai, time: DateTime.now().millisecondsSinceEpoch + 10));
  // Sort messages by time descending
  messages.sort((a, b) => b.time.compareTo(a.time));
  // Asynchronous generation
  // await for (String token in llama.prompt(last4Messages)) {
  //   messages.first.message += token;
  //   notifyListeners();
  // }
  _streamSubscription?.cancel();
  debugPrint('Starting Inference');
  _streamSubscription =
      llamaProcessor?.stream.listen((data) {
        messages.first.message += data;
        debugPrint(data);
        notifyListeners();
      }, onError: (error) {
        messages.first.message += "Error: $error";
        thinking = false;
        debugPrint(error.toString());
        notifyListeners();
      }, onDone: () {
         debugPrint('Finish');
         llamaProcessor?.unloadModel();
         thinking = false;
      });
  llamaProcessor?.prompt(last4Messages);
  // Synchronous generation
  // while (true) {
  //   var (token, done) = llama.getNext();
  //   stdout.write(token);
  //   if (done) {
  //     break;
  //   }
  // }

  //llama.dispose();

  notifyListeners();
}
Future<void> sendMessageFllama(BuildContext context)async{
  thinking = true;
  messages.add(ChatData(message: messageController.text, sender: MessageSender.user, time: DateTime.now().millisecondsSinceEpoch));
  messageController.clear();
  notifyListeners();
  var embeddings = Provider.of<Embeddings>(context, listen: false);
  var searchResults;
  List<Message> last4Messages = messages.length > 4 ? messages.sublist(messages.length - 4).map((e) => Message(e.sender == MessageSender.user? Role.user : Role.assistant, e.message)).toList() : messages.map((e) => Message(e.sender == MessageSender.user? Role.user : Role.assistant, e.message)).toList();
  try{
    if(DVDB().getCollection(SettingsPreferences.getString(selectedCollection)) != null) {
        searchResults = await embeddings.search(messageController.text);
        last4Messages.add(Message(
            Role.system,
            'You can use this information to provide an answer: ' +
                searchResults.join(' - ')));
      }
    }catch(e){
    print(e);
  }
  var model = LlmModelDownloader.models.firstWhere((element) => element.name == selectedModel);
  //llama.setPrompt(last4Messages); // Change this to your prompt
  messages.add(ChatData(message: '...', sender: MessageSender.ai, time: DateTime.now().millisecondsSinceEpoch + 10));
  // Sort messages by time descending
  messages.sort((a, b) => b.time.compareTo(a.time));
  debugPrint(last4Messages.map((e) => e.text).toString());
  final request = OpenAiRequest(
    maxTokens: 512,
    messages: last4Messages,
    numGpuLayers: 99, /* this seems to have no adverse effects in environments w/o GPU support, ex. Android and web */
    modelPath: SettingsPreferences.getString(SettingsPreferences.getString(selectedLLM)),
    frequencyPenalty: 1.1,
    // Don't use below 1.1, LLMs without a repeat penalty
    // will repeat the same token.
    presencePenalty: 1.8,
    topP: 1.0,
    // Proportional to RAM use.
    // 4096 is a good default.
    // 2048 should be considered on devices with low RAM (<8 GB)
    // 8192 and higher can be considered on device with high RAM (>16 GB)
    // Models are trained on <= a certain context size. Exceeding that # can/will lead to completely incoherent output.
    contextSize: model.maxContext > 2048? 2048 : model.maxContext,
    // Don't use 0.0, some models will repeat the same token.
    temperature: 1,
    logger: (log) {
      // ignore: avoid_print
      print('[llama.cpp] $log');
    },
  );
  await fllamaChat(request, (response, done) {
    //print(response);
    messages.first.message = response;
    if(done){
      thinking = false;
    }
    notifyListeners();
  },
  model.template.template,
    model.template.eosToken,
    model.template.bosToken
  );
}
}