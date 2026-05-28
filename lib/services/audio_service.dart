import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

import '../model/audio_model.dart';

class AudioService {
  static AudioService? _instance;
  static final AudioPlayer _audioPlayer = AudioPlayer();

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          _audioPlayer.positionStream,
          _audioPlayer.bufferedPositionStream,
          _audioPlayer.durationStream,
              (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  bool get isPlaying => _audioPlayer.playing;

  AudioService._internal() {
    _instance = this;
  }

  factory AudioService() =>
      _instance ?? AudioService._internal();

  void setFile(String filePath) {
    _audioPlayer.setFilePath(filePath);
  }

  void changeStatus() {
    if(_audioPlayer.playing){
      pause();
    }else{
      play();
    }
  }
  void play() {
    if(_audioPlayer.playing){
      return;
    }
    _audioPlayer.play();
  }

  void pause() {
    if(!_audioPlayer.playing){
      return;
    }
    _audioPlayer.pause();
  }

  void stop() {
    _audioPlayer.stop();
  }

  Stream<PositionData> getDurationStream() {
   return _positionDataStream;
  }

  void setDuration(Duration position) {
    _audioPlayer.seek(position);
  }


}