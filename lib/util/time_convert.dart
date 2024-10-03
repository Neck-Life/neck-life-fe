

class TimeConvert {
  static String sec2Min(int sec) {
    if (sec < 60) return '$sec초';
    if (sec < 3600) return '${sec~/60}분 ${sec % 60}초';
    return '${sec~/3600}시간 ${(sec%3600) ~/ 60}분 ${(sec%3600) % 60}초';
  }

  static String sec2TimeFormat(int sec) {
    if (sec < 3600) return '${(sec~/60).toString().padLeft(2, '0')}:${(sec % 60).toString().padLeft(2, '0')}';
    return '${(sec~/3600).toString().padLeft(2, '0')}:${((sec%3600) ~/ 60).toString().padLeft(2, '0')}:${((sec%3600) % 60).toString().padLeft(2, '0')}';
  }
}