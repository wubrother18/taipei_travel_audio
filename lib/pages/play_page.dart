import 'package:flutter/material.dart';
import 'package:taipei_travel_audio/services/audio_service.dart';

import '../model/audio_model.dart';

class PlayPage extends StatefulWidget {
  final String title;
  final String id;

  const PlayPage({super.key, required this.title, required this.id});

  @override
  State<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {

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
          children: [
            Container(
              width: double.infinity,
              height: 200,
              color: Colors.black,
            ),
            Spacer(),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 4),
            Text(
              "${widget.id}.mp3",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.grey),
            ),
            SizedBox(height: 24),
            playControllerArea(),
            Spacer(flex: 2),
          ],
        ),
      ),
    );
  }

  Widget playControllerArea() {
    return StreamBuilder<PositionData>(
      stream: AudioService().getDurationStream(),
      builder: (context, snapshot) {
        final durationState = snapshot.data;
        final progress = durationState?.position ?? Duration.zero;
        final total = durationState?.duration ?? Duration.zero;
        final double safeMax = total.inMilliseconds.toDouble();

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Slider(
                min: 0.0,
                max: safeMax > 0 ? safeMax : 1.0,
                value: progress.inMilliseconds.toDouble().clamp(0.0, safeMax > 0 ? safeMax : 1.0),
                onChanged: (value) {
                  AudioService().setDuration(Duration(milliseconds: value.toInt()));
                },
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDuration(progress), style: TextStyle(fontSize: 12, color: Colors.grey),),
                    Text(_formatDuration(total), style: TextStyle(fontSize: 12, color: Colors.grey),),
                  ],
                ),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    AudioService().changeStatus();
                  });
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(20),
                ),
                child: Icon(
                  AudioService().isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 36,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  //endregion

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
