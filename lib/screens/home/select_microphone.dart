import 'package:flutter/material.dart';
import 'package:medical_transcript/whisper/whisper.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

import '../../theme/theme.dart';
class SelectMicrophone extends StatefulWidget {
  const SelectMicrophone({super.key});

  @override
  State<SelectMicrophone> createState() => _SelectMicrophoneState();
}

class _SelectMicrophoneState extends State<SelectMicrophone> {
  List<InputDevice?> mics = [];
  bool isLoaded = false;
  _getMicrophones() async {
    var transcriptProvider = Provider.of<TranscriptProvider>(context, listen: false);
    mics.addAll(await AudioRecorder().listInputDevices()) ;
    mics.add(transcriptProvider.inputDevice);
    setState(() {
      isLoaded = true;
    });
    // print(mics);
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getMicrophones();
  }
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, TranscriptProvider transcriptProvider, _){
        return isLoaded? DropdownButton<InputDevice?>(
          value: transcriptProvider.inputDevice,
          onChanged: (InputDevice? mic) {
            if (mic == null) {
              return;
            }
            setState(() {
              transcriptProvider.inputDevice = mic;
            });
          },
          items: mics.map<DropdownMenuItem<InputDevice?>>((InputDevice? value) {
            return DropdownMenuItem<InputDevice?>(
              value: value,
              child: Text(value?.label ?? 'any', style: TextStyle(color: transcriptProvider.inputDevice == value ? appTheme.highlightColor : Colors.white),),
            );
          }).toList(),
        ) : CircularProgressIndicator();
      },
    );
  }
}
