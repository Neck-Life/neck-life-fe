
import 'dart:math';
import 'fusion_convention.dart';
import 'fusion_math.dart';

final INITIAL_GAIN = 10.0;

final INITIALISATION_PERIOD=3.0;
final double FLT_MAX = double.maxFinite;


class FusionAhrsSettings {
  late FusionConvention convention;
  late double gain;
  late double gyroscopeRange;
  late double accelerationRejection;
  late double magneticRejection;
  late int recoveryTriggerPeriod;

  FusionAhrsSettings({
    this.convention = FusionConvention.NWU,
    this.gain =  0.5,
    this.gyroscopeRange = 0.0,
    this.accelerationRejection =90.0,
    this.magneticRejection=90.0,
    this.recoveryTriggerPeriod=0,
  });
}

class FusionAhrs {
  late FusionAhrsSettings settings;
  late FusionQuaternion quaternion;
  late FusionVector accelerometer;
  late bool initialising;
  late double rampedGain;
  late double rampedGainStep;
  late bool angularRateRecovery;
  late FusionVector halfAccelerometerFeedback;
  late FusionVector halfMagnetometerFeedback;
  late bool accelerometerIgnored;
  late int accelerationRecoveryTrigger;
  late int accelerationRecoveryTimeout;
  late bool magnetometerIgnored;
  late int magneticRecoveryTrigger;
  late int magneticRecoveryTimeout;

  FusionAhrs({
    this.initialising = true,
    this.rampedGain = 0.0,
    this.rampedGainStep = 0.0,
    this.angularRateRecovery = false,
    this.accelerometerIgnored = false,
    this.accelerationRecoveryTrigger = 0,
    this.accelerationRecoveryTimeout = 0,
    this.magnetometerIgnored = false,
    this.magneticRecoveryTrigger = 0,
    this.magneticRecoveryTimeout = 0,
  });
}

class FusionAhrsInternalStates {
   double accelerationError;
   bool accelerometerIgnored;
   double accelerationRecoveryTrigger;
   double magneticError;
   bool magnetometerIgnored;
   double magneticRecoveryTrigger;

  FusionAhrsInternalStates({
    required this.accelerationError,
    required this.accelerometerIgnored,
    required this.accelerationRecoveryTrigger,
    required this.magneticError,
    required this.magnetometerIgnored,
    required this.magneticRecoveryTrigger,
  });
}
class FusionAhrsFlags {
  bool initialising;
  bool angularRateRecovery;
  bool accelerationRecovery;
  bool magneticRecovery;

  FusionAhrsFlags({
    required this.initialising,
    required this.angularRateRecovery,
    required this.accelerationRecovery,
    required this.magneticRecovery,
  });
}


//------------------------------------------------------------------------------
// Functions


void FusionAhrsInitialise(FusionAhrs ahrs) {
 FusionAhrsSettings settings = FusionAhrsSettings(
    convention: FusionConvention.NWU,
    gain: 0.5,
    gyroscopeRange: 0.0,
    accelerationRejection: 90.0,
    magneticRejection: 90.0,
    recoveryTriggerPeriod: 0,
  );
  FusionAhrsSetSettings(ahrs , settings);
  FusionAhrsReset(ahrs);
}

void FusionAhrsSetSettings(FusionAhrs ahrs, FusionAhrsSettings newSettings) {
  var settings = FusionAhrsSettings(
    convention: newSettings.convention,
    gain: newSettings.gain,
    gyroscopeRange: newSettings.gyroscopeRange == 0.0
        ? FLT_MAX
        : 0.98 * newSettings.gyroscopeRange,
    accelerationRejection: newSettings.accelerationRejection == 0.0
        ? FLT_MAX
        : pow(0.5 * sin(FusionDegreesToRadians(newSettings.accelerationRejection)), 2).toDouble(),
    magneticRejection: newSettings.magneticRejection == 0.0
        ? FLT_MAX
        : pow(0.5 * sin(FusionDegreesToRadians(newSettings.magneticRejection)), 2).toDouble(),
    recoveryTriggerPeriod: newSettings.recoveryTriggerPeriod,
  );
  ahrs.accelerationRecoveryTimeout = settings.recoveryTriggerPeriod;
  ahrs.magneticRecoveryTimeout = settings.recoveryTriggerPeriod;


  if (newSettings.gain == 0.0 || newSettings.recoveryTriggerPeriod == 0) {
    settings = FusionAhrsSettings(
      convention: settings.convention,
      gain: settings.gain,
      gyroscopeRange: settings.gyroscopeRange,
      accelerationRejection: FLT_MAX,
      magneticRejection: FLT_MAX,
      recoveryTriggerPeriod: settings.recoveryTriggerPeriod,
    );
  }
  if (!ahrs.initialising) {
    ahrs.rampedGain = settings.gain;
  }
  ahrs.rampedGainStep = (INITIAL_GAIN - settings.gain) / INITIALISATION_PERIOD;
}


void FusionAhrsReset(FusionAhrs ahrs) {
  ahrs.quaternion = FUSION_IDENTITY_QUATERNION;
  ahrs.accelerometer = FUSION_VECTOR_ZERO;
  ahrs.initialising = true;
  ahrs.rampedGain = INITIAL_GAIN;
  ahrs.angularRateRecovery = false;
  ahrs. halfAccelerometerFeedback = FUSION_VECTOR_ZERO;
  ahrs.halfMagnetometerFeedback = FUSION_VECTOR_ZERO;
  ahrs.accelerometerIgnored = false;
  ahrs.accelerationRecoveryTrigger = 0;
  ahrs. accelerationRecoveryTimeout = ahrs.settings.recoveryTriggerPeriod;
  ahrs. magnetometerIgnored = false;
  ahrs.magneticRecoveryTrigger = 0;
  ahrs.magneticRecoveryTimeout = ahrs.settings.recoveryTriggerPeriod;
}


void FusionAhrsUpdate(FusionAhrs ahrs, FusionVector gyroscope, FusionVector accelerometer, FusionVector magnetometer, double deltaTime) {
  // Store accelerometer
  ahrs.accelerometer = accelerometer;

  // Reinitialise if gyroscope range exceeded
  if ((gyroscope.x.abs() > ahrs.settings.gyroscopeRange) || (gyroscope.y.abs() > ahrs.settings.gyroscopeRange) || (gyroscope.z.abs() > ahrs.settings.gyroscopeRange)) {
    final quaternionBackup = ahrs.quaternion;
    FusionAhrsReset(ahrs);
    ahrs.quaternion = quaternionBackup;
    ahrs.angularRateRecovery = true;
  }

  // Ramp down gain during initialisation
  if (ahrs.initialising) {
    ahrs.rampedGain -= ahrs.rampedGainStep * deltaTime;
    if ((ahrs.rampedGain < ahrs.settings.gain) || (ahrs.settings.gain == 0.0)) {
      ahrs.rampedGain = ahrs.settings.gain;
      ahrs.initialising = false;
      ahrs.angularRateRecovery = false;
    }
  }

  // Calculate direction of gravity indicated by algorithm
  final halfGravity = HalfGravity(ahrs);

  // Calculate accelerometer feedback
  FusionVector halfAccelerometerFeedback = FUSION_VECTOR_ZERO;
  ahrs.accelerometerIgnored = true;
  if ( !FusionVectorIsZero(accelerometer)){

    // Calculate accelerometer feedback scaled by 0.5
    ahrs.halfAccelerometerFeedback = Feedback(FusionVectorNormalise(accelerometer), halfGravity);

    // Don't ignore accelerometer if acceleration error below threshold
    if (ahrs.initialising || (FusionVectorMagnitudeSquared(ahrs.halfAccelerometerFeedback) <= ahrs.settings.accelerationRejection)) {
      ahrs.accelerometerIgnored = false;
      ahrs.accelerationRecoveryTrigger -= 9;
    } else {
      ahrs.accelerationRecoveryTrigger += 1;
    }

    // Don't ignore accelerometer during acceleration recovery
    if (ahrs.accelerationRecoveryTrigger > ahrs.accelerationRecoveryTimeout) {
      ahrs.accelerationRecoveryTimeout = 0;
      ahrs.accelerometerIgnored = false;
    } else {
      ahrs.accelerationRecoveryTimeout = ahrs.settings.recoveryTriggerPeriod;
    }
    ahrs.accelerationRecoveryTrigger = clamp(ahrs.accelerationRecoveryTrigger, 0, ahrs.settings.recoveryTriggerPeriod);

    // Apply accelerometer feedback
    if (!ahrs.accelerometerIgnored) {
      halfAccelerometerFeedback = ahrs.halfAccelerometerFeedback;
    }
  }

  // Calculate magnetometer feedback
  FusionVector halfMagnetometerFeedback = FUSION_VECTOR_ZERO;
  ahrs.magnetometerIgnored = true;
  if (FusionVectorIsZero(magnetometer) == false) {

    // Calculate direction of magnetic field indicated by algorithm
    final halfMagnetic = HalfMagnetic(ahrs);

    // Calculate magnetometer feedback scaled by 0.5
    halfMagnetometerFeedback = Feedback(FusionVectorNormalise(FusionVectorCrossProduct(halfGravity, magnetometer)), halfMagnetic);

    // Don't ignore magnetometer if magnetic error below threshold
    if (ahrs.initialising || (FusionVectorMagnitudeSquared(ahrs.halfMagnetometerFeedback) <=ahrs.settings.magneticRejection)) {
      ahrs.magnetometerIgnored = false;
      ahrs.magneticRecoveryTrigger -= 9;
    } else {
      ahrs.magneticRecoveryTrigger += 1;
    }

    // Don't ignore magnetometer during magnetic recovery
    if (ahrs.magneticRecoveryTrigger > ahrs.magneticRecoveryTimeout) {
      ahrs.magneticRecoveryTimeout = 0;
      ahrs.magnetometerIgnored = false;
    } else {
      ahrs.magneticRecoveryTimeout = ahrs.settings.recoveryTriggerPeriod;
    }
    ahrs.magneticRecoveryTrigger = clamp(ahrs.magneticRecoveryTrigger, 0, ahrs.settings.recoveryTriggerPeriod);

    // Apply magnetometer feedback
    if (!ahrs.magnetometerIgnored) {
      halfMagnetometerFeedback = ahrs.halfMagnetometerFeedback;
    }
  }

  // Convert gyroscope to radians per second scaled by 0.5
  final halfGyroscope =FusionVectorMultiplyScalar(gyroscope, FusionDegreesToRadians(0.5));

  // Apply feedback to gyroscope
  final adjustedHalfGyroscope = FusionVectorAdd(halfGyroscope, FusionVectorMultiplyScalar(FusionVectorAdd(halfAccelerometerFeedback, halfMagnetometerFeedback), ahrs.rampedGain));


  // Integrate rate of change of quaternion
  ahrs.quaternion = FusionQuaternionAdd(ahrs.quaternion, FusionQuaternionMultiplyVector(ahrs.quaternion, FusionVectorMultiplyScalar(adjustedHalfGyroscope, deltaTime)));

  // Normalise quaternion
  ahrs.quaternion = FusionQuaternionNormalise(ahrs.quaternion);



}


FusionVector HalfGravity(FusionAhrs ahrs) {
  final q = ahrs.quaternion;

  switch (ahrs.settings.convention) {
    case FusionConvention.NWU:
    case FusionConvention.ENU:
      return FusionVector(
        q.x * q.z - q.w * q.y,
        q.y * q.z + q.w * q.x,
        q.w * q.w - 0.5 + q.z * q.z,
      ); // third column of transposed rotation matrix scaled by 0.5
    case FusionConvention.NED:
      return FusionVector(
        q.w * q.y - q.x * q.z,
        -1.0 * (q.y * q.z + q.w * q.x),
        0.5 - q.w * q.w - q.z * q.z,
      ); // third column of transposed rotation matrix scaled by -0.5
    default:
      return FUSION_VECTOR_ZERO; // avoid compiler warning
  }
}

FusionVector Feedback(FusionVector sensor, FusionVector reference) {
  if (FusionVectorDotProduct(sensor,reference) < 0.0) { // if error is >90 degrees
    return FusionVectorNormalise(FusionVectorCrossProduct(sensor,reference));
  }
  return FusionVectorCrossProduct(sensor,reference);
}

int clamp(int value, int min, int max) {
  if (value < min) {
    return min;
  }
  if (value > max) {
    return max;
  }
  return value;
}

FusionVector HalfMagnetic(FusionAhrs ahrs) {
  final q = ahrs.quaternion;

  switch (ahrs.settings.convention) {
    case FusionConvention.NWU:
      return FusionVector(
        q.x * q.y + q.w * q.z,
        q.w * q.w - 0.5 + q.y * q.y,
        q.y * q.z - q.w * q.x,
      ); // second column of transposed rotation matrix scaled by 0.5
    case FusionConvention.ENU:
      return FusionVector(
        0.5 - q.w * q.w - q.x * q.x,
        q.w * q.z - q.x * q.y,
        -(q.x * q.z + q.w * q.y),
      ); // first column of transposed rotation matrix scaled by -0.5
    case FusionConvention.NED:
      return FusionVector(
        -(q.x * q.y + q.w * q.z),
        0.5 - q.w * q.w - q.y * q.y,
        q.w * q.x - q.y * q.z,
      ); // second column of transposed rotation matrix scaled by -0.5
    default:
      return FUSION_VECTOR_ZERO; // avoid compiler warning
  }
}


void FusionAhrsUpdateNoMagnetometer(FusionAhrs ahrs, FusionVector gyroscope, FusionVector accelerometer, double deltaTime) {
  // Update AHRS algorithm
  FusionAhrsUpdate(ahrs,gyroscope, accelerometer, FUSION_VECTOR_ZERO, deltaTime);

  // Zero heading during initialisation
  if (ahrs.initialising) {
    FusionAhrsSetHeading(ahrs,0.0);
  }
}

void fusionAhrsUpdateExternalHeading(FusionAhrs ahrs, FusionVector gyroscope, FusionVector accelerometer, double heading, double deltaTime) {
  final q = ahrs.quaternion;

  // Calculate roll
  double roll = atan2(q.w * q.x + q.y * q.z, 0.5 - q.y * q.y - q.x * q.x);

  // Calculate magnetometer
  double headingRadians = FusionDegreesToRadians(heading);
  double sinHeadingRadians = sin(headingRadians);
  FusionVector magnetometer = FusionVector(
    cos(headingRadians),
    -1.0 * cos(roll) * sinHeadingRadians,
    sinHeadingRadians * sin(roll),
  );

  // Update AHRS algorithm
  FusionAhrsUpdate(ahrs,gyroscope, accelerometer, magnetometer, deltaTime);
}

FusionQuaternion FusionAhrsGetQuaternion( FusionAhrs ahrs) {
  return ahrs.quaternion;
}

void FusionAhrsSetQuaternion(FusionAhrs ahrs, FusionQuaternion quaternion) {
  ahrs.quaternion = quaternion;
}

FusionVector fusionAhrsGetLinearAcceleration(FusionAhrs ahrs) {
  final q = ahrs.quaternion;

  // Calculate gravity in the sensor coordinate frame
  FusionVector gravity = FusionVector(
    2.0 * (q.x * q.z - q.w * q.y),
    2.0 * (q.y * q.z + q.w * q.x),
    2.0 * (q.w * q.w - 0.5 + q.z * q.z),
  ); // third column of transposed rotation matrix

  // Remove gravity from accelerometer measurement
  switch (ahrs.settings.convention) {
    case FusionConvention.NWU:
    case FusionConvention.ENU:
      return FusionVectorSubtract(ahrs.accelerometer, gravity);
    case FusionConvention.NED:
      return FusionVectorAdd(ahrs.accelerometer, gravity);
    default:
      return FUSION_VECTOR_ZERO; // avoid compiler warning
  }
}

FusionVector FusionAhrsGetEarthAcceleration(FusionAhrs ahrs) {
  final q = ahrs.quaternion;
  final a = ahrs.accelerometer;

  // Calculate accelerometer measurement in the Earth coordinate frame
  final qwqw = q.w * q.w; // calculate common terms to avoid repeated operations
  final qwqx = q.w * q.x;
  final qwqy = q.w * q.y;
  final qwqz = q.w * q.z;
  final qxqy = q.x * q.y;
  final qxqz = q.x * q.z;
  final qyqz = q.y * q.z;

  FusionVector accelerometer = FusionVector(
    2.0 * ((qwqw - 0.5 + q.x * q.x) * a.x + (qxqy - qwqz) * a.y + (qxqz + qwqy) * a.z),
    2.0 * ((qxqy + qwqz) * a.x + (qwqw - 0.5 + q.y * q.y) * a.y + (qyqz - qwqx) * a.z),
    2.0 * ((qxqz - qwqy) * a.x + (qyqz + qwqx) * a.y + (qwqw - 0.5 + q.z * q.z) * a.z),
  ); // rotation matrix multiplied with the accelerometer

  // Remove gravity from accelerometer measurement
  switch (ahrs.settings.convention) {
    case FusionConvention.NWU:
    case FusionConvention.ENU:
      accelerometer = FusionVector(accelerometer.x, accelerometer.y, accelerometer.z - 1.0);
      break;
    case FusionConvention.NED:
      accelerometer = FusionVector(accelerometer.x, accelerometer.y, accelerometer.z + 1.0);
      break;
    default:
      return FUSION_VECTOR_ZERO; // avoid compiler warning
  }

  return accelerometer;
}

FusionAhrsInternalStates FusionAhrsGetInternalStates(FusionAhrs ahrs) {
  double accelerationError = FusionRadiansToDegrees(asin(2.0 *FusionVectorMagnitude(ahrs.halfAccelerometerFeedback)));
  double accelerationRecoveryTrigger = ahrs.settings.recoveryTriggerPeriod == 0
      ? 0.0
      : ahrs.accelerationRecoveryTrigger / ahrs.settings.recoveryTriggerPeriod;

  double magneticError = FusionRadiansToDegrees(asin(2.0 * FusionVectorMagnitude(ahrs.halfMagnetometerFeedback)));
  double magneticRecoveryTrigger = ahrs.settings.recoveryTriggerPeriod == 0
      ? 0.0
      : ahrs.magneticRecoveryTrigger / ahrs.settings.recoveryTriggerPeriod;

  return FusionAhrsInternalStates(
    accelerationError: accelerationError,
    accelerometerIgnored: ahrs.accelerometerIgnored,
    accelerationRecoveryTrigger: accelerationRecoveryTrigger,
    magneticError: magneticError,
    magnetometerIgnored: ahrs.magnetometerIgnored,
    magneticRecoveryTrigger: magneticRecoveryTrigger,
  );
}


FusionAhrsFlags FusionAhrsGetFlags(FusionAhrs ahrs) {
  return FusionAhrsFlags(
    initialising: ahrs.initialising,
    angularRateRecovery: ahrs.angularRateRecovery,
    accelerationRecovery: ahrs.accelerationRecoveryTrigger > ahrs.accelerationRecoveryTimeout,
    magneticRecovery: ahrs.magneticRecoveryTrigger > ahrs.magneticRecoveryTimeout,
  );
}

void FusionAhrsSetHeading(FusionAhrs ahrs, double heading) {
  final q = ahrs.quaternion;
  double yaw = atan2(q.w * q.z + q.x * q.y, 0.5 - q.y * q.y - q.z * q.z);
  double halfYawMinusHeading = 0.5 * (yaw - FusionDegreesToRadians(heading));
  FusionQuaternion rotation = FusionQuaternion(
    cos(halfYawMinusHeading),
    0.0,
    0.0,
    -sin(halfYawMinusHeading),
  );
  ahrs.quaternion = FusionQuaternionMultiply(rotation, ahrs.quaternion);

}


