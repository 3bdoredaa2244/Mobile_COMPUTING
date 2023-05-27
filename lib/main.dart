import 'dart:async';

import 'package:flutter/material.dart';
import 'package:record/record.dart';
void main() {
  runApp(const MaterialApp(home: MicPage()));
}


class MicPage extends StatefulWidget {
  const MicPage({super.key});
  

  @override
  State<MicPage> createState() => _MicPageState();
}

class _MicPageState extends State<MicPage> {
  Record myRecording = Record();
  Timer? timer;
  List<double> volumeList = [];

  static double volume = 0.0;
  double minVolume = -45.0;
  double average = 0.0;
  double total=0;
  int counter=0;
  startTimer() async {
    timer ??= Timer.periodic(
        const Duration(milliseconds: 50), (timer) => updateVolume());
  }

  updateVolume() async {
    Amplitude ampl = await myRecording.getAmplitude();
    if (ampl.current > minVolume) {

      setState(() {
        volume = (ampl.current - minVolume) / minVolume;
        volumeList.add(volume);
      });
    }
  }

  int volume0to(int maxVolumeToDisplay) {
    if(counter ==10)
    {
      average =total/10;
      counter=0;
    }
    else{
      total=volume+total;
      counter =counter+1;
    }
    return (volume * maxVolumeToDisplay).round().abs();
  }

  // double calculateAverage(List<double> volumes) {
  //   double sum = 0.0;
  //   volumes.forEach((volume) {
  //     sum += volume;
  //   });
  //   return sum / volumes.length;
  // }

  // void compareWith70() {
  //   double averageVolume = calculateAverage(volumeList);
  //   if (averageVolume >= 70.0) {
  //     print(
  //         "The average volume is ${averageVolume.toStringAsFixed(2)} - Too loud!");
  //   } else {
  //     print(
  //         "The average volume is ${averageVolume.toStringAsFixed(2)} - Safe volume.");
  //   }
  //   volumeList.clear();
  // }

  Future<bool> startRecording() async {
    if (await myRecording.hasPermission()) {
      if (!await myRecording.isRecording()) {
        await myRecording.start();
      }
      startTimer();
      //calculateAverage();
      Timer.periodic(const Duration(seconds: 10), (timer) {
       // compareWith70();
      });
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Future<bool> recordFutureBuilder =
        Future<bool>.delayed(const Duration(seconds: 3), (() async {
      return startRecording();
    }));

    return FutureBuilder(
        future: recordFutureBuilder,
        builder: (context, AsyncSnapshot<bool> snapshot) {
          return Scaffold(
            body: Center(
                child: Column(
                  children: [
                    snapshot.hasData
                        ? Text("VOLUME NOISE\n${volume0to(100)}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 42, fontWeight: FontWeight.bold))
                        : const CircularProgressIndicator(),
                        Text("average = ${average}")
                  ],
                )),
          );
        });
  }
}