import 'dart:io';

import 'package:flutter/material.dart';
import 'package:medical_transcript/data_models/chat_data.dart';
import 'package:medical_transcript/llama/llm_model_downloader.dart';
import 'package:medical_transcript/llama/llm_models.dart';
import 'package:medical_transcript/llama/llm_provider.dart';
import 'package:medical_transcript/screens/home/select_embeddings.dart';
import 'package:medical_transcript/screens/home/select_llm.dart';
import 'package:medical_transcript/shared_preferences/shared_preferences.dart';
import 'package:medical_transcript/shared_preferences/shared_preferences_references.dart';
import 'package:provider/provider.dart';

import '../../embeddings/embeddings.dart';
import '../../theme/theme.dart';

class LlmChat extends StatefulWidget {
  const LlmChat({super.key});

  @override
  State<LlmChat> createState() => _LlmChatState();
}

class _LlmChatState extends State<LlmChat> {
bool deleting = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // if(SettingsPreferences.getString(lastDownloadTaskID) != null && SettingsPreferences.getString(lastDownloadTaskID)!.isNotEmpty) {
    //   LlmModelDownloader.downloadModel(SettingsPreferences.getString(lastDownloadTaskID), context);
    // }
  }
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, LlmProvider llmProvider, _){
      return SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                height: MediaQuery.of(context).size.height*0.9,
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                  itemCount: llmProvider.messages.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    bool isUser = llmProvider.messages[index].sender == MessageSender.user;
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.all(8),
                            width: MediaQuery.of(context).size.width * 0.8,
                            decoration: BoxDecoration(
                              color: isUser ? Colors.blue[300] : Colors.blueGrey,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SelectableText(llmProvider.messages[index].message, style: appTheme.textTheme.titleLarge,),

                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            SelectLlm(),
            SelectEmbeddings(),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: TextField(
                        controller: llmProvider.messageController,
                        enabled: !llmProvider.thinking,
                        decoration: InputDecoration(
                          hintText: llmProvider.thinking? 'Thinking...'  : 'Type a message',
                          hintStyle: TextStyle(color: Colors.white30),
                        ),
                        onSubmitted: (message)async{
                        await llmProvider.sendMessage();
                        },
                      ),
                    ),
                    GestureDetector(
                      onTap:
                      ()async{
                        if(llmProvider.thinking) {
                          await llmProvider.stopThinking();
                        }else{
                          //await llmProvider.sendMessage();
                          await llmProvider.sendMessageFllama(context);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: llmProvider.thinking? Colors.red : Colors.blue[300],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(llmProvider.thinking? Icons.stop : Icons.send, color: Colors.white,),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      );
    });
  }
}
