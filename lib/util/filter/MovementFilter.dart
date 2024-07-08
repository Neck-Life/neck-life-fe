class MovementFilter {
  final int windowSize;
  List<double> buffer = [];
  double sum = 0.0;

  MovementFilter(this.windowSize);

  double update(double newValue) {
// 버퍼가 아직 최대 크기에 도달하지 않았다면 값을 추가만 하고, 도달했다면 가장 오래된 값을 제거하고 새 값을 추가
    if (buffer.length < windowSize) {
      buffer.add(newValue);
      sum += newValue;
    } else {
// 버퍼에서 가장 오래된 데이터 제거
      sum -= buffer[0];
      buffer.removeAt(0);
// 새 데이터 추가
      buffer.add(newValue);
      sum += newValue;
    }

// 평균 계산
    return sum / buffer.length - buffer[0];
  }

  void clear() {
    buffer.clear();
    sum = 0.0;
  }
}
