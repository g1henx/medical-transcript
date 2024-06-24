import 'package:flutter/material.dart';
import 'package:medical_transcript/components/spacing.dart';
import 'package:medical_transcript/screens/home/llm_chat.dart';
import 'package:medical_transcript/screens/home/select_microphone.dart';
import 'package:medical_transcript/screens/home/select_model.dart';
import 'package:medical_transcript/screens/home/transcript.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: true? LlmChat() : Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SelectModel(),
            SelectMicrophone(),
            Transcript()
          ],
        ),
      ),
    );
  }
}
