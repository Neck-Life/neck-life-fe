class KalmanFilter {
  double processNoise;  // 프로세스 노이즈 분산
  double measurementNoise;  // 측정 노이즈 분산
  double estimatedError;  // 추정된 오류
  double lastEstimate;  // 마지막 추정값

  // 생성자
  KalmanFilter({
    required this.processNoise,
    required this.measurementNoise,
    required this.estimatedError,
    required this.lastEstimate,
  });

  // 새로운 측정값으로 필터 업데이트
  double update(double measurement) {
    // 예측 업데이트
    double errorCovariancePrediction = estimatedError + processNoise;

    // 측정 업데이트
    double kalmanGain = errorCovariancePrediction / (errorCovariancePrediction + measurementNoise);
    lastEstimate = lastEstimate + kalmanGain * (measurement - lastEstimate);
    estimatedError = (1 - kalmanGain) * errorCovariancePrediction;

    return lastEstimate;
  }
}

void main() {
  // 필터 초기화 및 노이즈 매개변수와 초기 상태 설정
  var filter = KalmanFilter(
    processNoise: 1e-5,
    measurementNoise: 1e-4,
    estimatedError: 1,
    lastEstimate: 0,
  );

  // 예시 측정값
  List<double> measurements = [0.39, 0.50, 0.48, 0.29, 0.25, 0.32, 0.34, 0.48, 0.41, 0.45];

  // 각 측정값에 대한 칼만 필터 적용
  for (var measurement in measurements) {
    double filteredValue = filter.update(measurement);
    print('필터링된 가속도: $filteredValue');
  }
}