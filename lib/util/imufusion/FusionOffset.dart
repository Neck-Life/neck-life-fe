import 'fusion_math.dart';

final CUTOFF_FREQUENCY = 0.02;

final TIMEOUT=5;

final THRESHOLD = 3.0;



class FusionOffset {
  late double filterCoefficient;
  late int timeout;
  late int timer;
  late FusionVector gyroscopeOffset;

  FusionOffset(int sampleRate){
    filterCoefficient = 2.0 * M_PI * CUTOFF_FREQUENCY * (1.0 / sampleRate);
    timeout = TIMEOUT * sampleRate;
    timer = 0;
    gyroscopeOffset = FUSION_VECTOR_ZERO;

  }

}


FusionVector FusionOffsetUpdate(FusionOffset offset ,FusionVector gyroscope) {
  // Subtract offset from gyroscope measurement
  gyroscope = FusionVectorSubtract(gyroscope, offset.gyroscopeOffset);

  // Reset timer if gyroscope not stationary
  if (gyroscope.x.abs() > THRESHOLD || gyroscope.y.abs() > THRESHOLD || gyroscope.z.abs() > THRESHOLD) {
    offset.timer = 0;
    return gyroscope;
  }

  // Increment timer while gyroscope stationary
  if (offset.timer < offset.timeout) {
      offset.timer++;
    return gyroscope;
  }
  offset.gyroscopeOffset = FusionVectorAdd(offset.gyroscopeOffset, FusionVectorMultiplyScalar(gyroscope, offset.filterCoefficient));

  return gyroscope;

}