import '../../status_provider.dart';

class RotationImplement{
  double _rotateDeg = 0;
  double _pitch = 0;
  double _pitchTemp = 0;
  double _prevPitch = 0;
  final List<double> _turtleThreshold = [0.3, 0.4, 0.5];

  bool isTurtleNeck() {
    if (DetectStatus.initialPitch - _pitchTemp > _turtleThreshold[DetectStatus.sSensitivity]) {
      return true;
    } else {
      return false;
    }
  }
}