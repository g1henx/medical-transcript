import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:medical_transcript/embeddings/embeddings.dart';
import 'package:medical_transcript/screens/home/home.dart';
import 'package:medical_transcript/shared_preferences/shared_preferences.dart';
import 'package:medical_transcript/theme/theme.dart';
import 'package:medical_transcript/whisper/whisper.dart';
import 'package:provider/provider.dart';

import 'llama/llm_provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await SettingsPreferences.initLocal();
  await FlutterDownloader.initialize(
      debug: true, // optional: set to false to disable printing logs to console (default: true)
      ignoreSsl: true // option: set to false to disable working with http links (default: false)
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TranscriptProvider()),
        ChangeNotifierProvider(create: (context) => LlmProvider()),
        ChangeNotifierProvider(create: (context) => Embeddings()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,

        theme: appTheme,
        home: const Home(),
      ),
    );
  }
}


