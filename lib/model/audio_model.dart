const langOptions = {
  'zh-tw': '繁中',
  'zh-cn': '简中',
  'en': 'EN',
  'ja': 'JA',
  'ko': 'KO',
};

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData(this.position, this.bufferedPosition, this.duration);
}