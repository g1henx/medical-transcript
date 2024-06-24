import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:medical_transcript/components/spacing.dart';
import 'package:provider/provider.dart';

import '../../whisper/whisper.dart';

class Transcript extends StatefulWidget {
  const Transcript({super.key});

  @override
  State<Transcript> createState() => _TranscriptState();
}

class _TranscriptState extends State<Transcript> {
  _init(){
    var transcript = Provider.of<TranscriptProvider>(context, listen: false);
    transcript.initWhisper();
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_){
      _init();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, TranscriptProvider transcript, _) {
      return transcript.selectedModel != null? Column(
        children: [
        transcript.loadingWhisper?  CircularProgressIndicator() : IconButton(onPressed: (){
            if(transcript.isRecording) {
              transcript.stopRecording();
            }else{
              transcript.startRecording();
            }
          }, icon: Icon(transcript.isRecording ? Icons.stop : Icons.mic)),
          addVerticalSpace(10),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.5,
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.all(20),
              children: [
                Text(transcript.transcript, style: TextStyle(fontSize: 20))
              ],
            ),
          ),
        ],
      ) : SizedBox();
    });
  }
}