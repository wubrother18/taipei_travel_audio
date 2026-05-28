import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:taipei_travel_audio/services/audio_service.dart';

import '../model/audio_model.dart';

class PlayPage extends StatefulWidget {
  final String title;

  const PlayPage({super.key, required this.title});

  @override
  State<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {
  //controller

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    AudioService().stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        titleSpacing: 0,
        shadowColor: Colors.black,
        flexibleSpace: Container(color: Colors.white),
        title: Row(
          children: [
            Text(
              "FUNDAY",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.0,
                fontWeight: FontWeight.w700,
                fontFamily: 'Lato',
                fontFamilyFallback: <String>['Noto Sans TC'],
              ),
            ),
          ],
        ),
      ),
      body: body(),
    );
  }

  //region widget

  Widget body() {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 4),
            SizedBox(height: 8),
            playControllerArea(),
          ],
        ),
      ),
    );
  }

  Widget playControllerArea() {
    return Container(
      child: Column(
        children: [
          StreamBuilder<PositionData>(
            stream: AudioService().getDurationStream(),
            // Combined stream of position and total duration
            builder: (context, snapshot) {
              final durationState = snapshot.data;
              final progress = durationState?.position ?? Duration.zero;
              final total = durationState?.duration ?? Duration.zero;

              return Slider(
                min: 0.0,
                max: total.inMilliseconds.toDouble(),
                value: progress.inMilliseconds.toDouble().clamp(
                  0.0,
                  total.inMilliseconds.toDouble(),
                ),
                onChanged: (value) {
                  AudioService().setDuration(
                    Duration(milliseconds: value.toInt()),
                  );
                },
              );
            },
          ),
          SizedBox(height: 8),
          TextButton(
            onPressed: () {
              setState(() {
                AudioService().changeStatus();
              });
            },
            style: TextButton.styleFrom(),
            child: Icon(
              AudioService().isPlaying ? Icons.pause : Icons.play_arrow,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
  //endregion
}
