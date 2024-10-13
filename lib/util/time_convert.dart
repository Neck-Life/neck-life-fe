

class TimeConvert {
  static List<String> monthArr = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
  static String sec2Min(int sec, String langCode) {
    if (langCode == 'ko') {
      if (sec < 60) return '$sec초';
      if (sec < 3600) return '${sec ~/ 60}분 ${sec % 60}초';
      return '${sec ~/ 3600}시간 ${(sec % 3600) ~/ 60}분 ${(sec % 3600) % 60}초';
    }
    if (sec < 60) return '${sec}s';
    if (sec < 3600) return '${sec~/60}m ${sec % 60}s';
    return '${sec~/3600}h ${(sec%3600) ~/ 60}m ${(sec%3600) % 60}s';
  }

  static String sec2TimeFormat(int sec) {
    if (sec < 3600) return '${(sec~/60).toString().padLeft(2, '0')}:${(sec % 60).toString().padLeft(2, '0')}';
    return '${(sec~/3600).toString().padLeft(2, '0')}:${((sec%3600) ~/ 60).toString().padLeft(2, '0')}:${((sec%3600) % 60).toString().padLeft(2, '0')}';
  }

  static String engDateFormat(int month, int date) {
    String eow = 'th';
    if (date != 11 && date % 10 == 1) {
      eow = 'st';
    } else if (date != 12 && date % 10 == 2) {
      eow = 'nd';
    } else if (date != 13 && date % 10 == 3) {
      eow = 'rd';
    }
      return '${monthArr[month-1]} $date$eow';
  }
}