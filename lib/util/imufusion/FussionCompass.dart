import 'dart:math';

import 'fusion_convention.dart';
import 'fusion_math.dart';

double fusionCompassCalculateHeading(
    FusionConvention convention, FusionVector accelerometer, FusionVector magnetometer) {
  switch (convention) {
    case FusionConvention.NWU:
      {
        FusionVector west = FusionVectorNormalise(FusionVectorCrossProduct(accelerometer, magnetometer));
        FusionVector north =FusionVectorNormalise(FusionVectorCrossProduct(west, accelerometer));
        return FusionRadiansToDegrees(atan2(west.x, north.x));
      }
    case FusionConvention.ENU:
      {
        FusionVector west = FusionVectorNormalise(FusionVectorCrossProduct(accelerometer, magnetometer));
        FusionVector north = FusionVectorNormalise(FusionVectorCrossProduct(west, accelerometer));
        FusionVector east = FusionVectorMultiplyScalar(west, -1.0);
        return FusionRadiansToDegrees(atan2(north.x, east.x));
      }
    case FusionConvention.NED:
      {
        FusionVector up = FusionVectorMultiplyScalar(accelerometer, -1.0);
        FusionVector west = FusionVectorNormalise(FusionVectorCrossProduct(up, magnetometer));
        FusionVector north = FusionVectorNormalise(FusionVectorCrossProduct(west, up));
        return FusionRadiansToDegrees(atan2(west.x, north.x));
      }
    default:
      return 0.0; // avoid compiler warning
  }
}