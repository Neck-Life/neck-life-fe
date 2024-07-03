import 'dart:math';
import 'dart:typed_data';


/**
 * @brief Vector of zeros.
 */
final FusionVector FUSION_VECTOR_ZERO = FusionVector(0.0, 0.0, 0.0);

/**
 * @brief Vector of ones.
 */
final FusionVector FUSION_VECTOR_ONES = FusionVector(1.0, 1.0, 1.0);

/**
 * @brief Identity quaternion.
 */
final FusionQuaternion FUSION_IDENTITY_QUATERNION = FusionQuaternion(1.0, 0.0, 0.0, 0.0);


/**
 * @brief Identity matrix.
 */
final FUSION_IDENTITY_MATRIX = FusionMatrix(1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0);


/**
 * @brief Euler angles of zero.
 */
final FUSION_EULER_ZERO  = FusionEuler(0.0, 0.0, 0.0);

final M_PI = 3.14159265358979323846;


class FusionVector {
  late double x;
  late double y;
  late double z;


  FusionVector(x, y,z){
    this.x = x;
    this.y = y;
    this.z = z;
  }

}

class FusionQuaternion {
  late double w;
  late double x;
  late double y;
  late double z;

  FusionQuaternion(this.w, this.x, this.y, this.z);
  }


  class FusionMatrix{

    late double xx;
    late double xy;
    late double xz;
    late double yx;
    late double yy;
    late double yz;
    late double zx;
    late double zy;
    late double zz;

    FusionMatrix(this.xx, this.xy, this.xz, this.yx, this.yy, this.yz, this.zx, this.zy, this.zz);

  }

  class FusionEuler{
   late double roll;
    late double pitch;
    late double yaw;

    FusionEuler(this.roll, this.pitch, this.yaw);

}


//------------------------------------------------------------------------------
// Inline functions - Degrees and radians conversion


double FusionDegreesToRadians(double degrees) {
  return degrees * (M_PI / 180.0);
}

double FusionRadiansToDegrees(double radians) {
  return radians * (180.0 / M_PI);
}

//------------------------------------------------------------------------------
// Inline functions - Arc sine


double fusionAsin(double value) {
  if (value <= -1.0) {
    return -pi / 2.0;
  }
  if (value >= 1.0) {
    return pi / 2.0;
  }
  return asin(value);
}

double fusionFastInverseSqrt(double x) {
  // Float to bit conversion
  var buffer = Float32List(1);
  buffer[0] = x;
  var intView = buffer.buffer.asInt32List();

  int i = intView[0];
  i = 0x5F1F1412 - (i >> 1);

  // Bit to float conversion
  intView[0] = i;
  double y = buffer[0];

  // Apply the Newton's approximation
  y = y * (1.69000231 - 0.714158168 * x * y * y);

  return y;
}

bool FusionVectorIsZero(FusionVector vector) {
  return (vector.x == 0.0) && (vector.y == 0.0) && (vector.z == 0.0);
}

FusionVector FusionVectorAdd(FusionVector vectorA, FusionVector vectorB) {
  return FusionVector(
    vectorA.x + vectorB.x,
    vectorA.y + vectorB.y,
    vectorA.z + vectorB.z,
  );
}


FusionVector FusionVectorSubtract(FusionVector vectorA, FusionVector vectorB) {
  return FusionVector(
    vectorA.x - vectorB.x,
    vectorA.y - vectorB.y,
    vectorA.z - vectorB.z,
  );
}

double FusionVectorSum(FusionVector vector  ) {
  return vector.x + vector.y + vector.z;
}



FusionVector FusionVectorMultiplyScalar(FusionVector vector, double scalar) {
  return FusionVector(
    vector.x * scalar,
    vector.y * scalar,
    vector.z * scalar,
  );
}

FusionVector FusionVectorHadamardProduct(FusionVector vectorA, FusionVector vectorB) {
  return FusionVector(
    vectorA.x * vectorB.x,
    vectorA.y * vectorB.y,
    vectorA.z * vectorB.z,
  );
}

FusionVector FusionVectorCrossProduct(FusionVector vectorA, FusionVector vectorB) {
  return FusionVector(
    vectorA.y * vectorB.z - vectorA.z * vectorB.y,
    vectorA.z * vectorB.x - vectorA.x * vectorB.z,
    vectorA.x * vectorB.y - vectorA.y * vectorB.x,
  );
}

double FusionVectorDotProduct(FusionVector vectorA, FusionVector vectorB) {
  return FusionVectorSum(FusionVectorHadamardProduct(vectorA, vectorB));
}

double FusionVectorMagnitudeSquared(FusionVector vector) {
  return FusionVectorSum(FusionVectorHadamardProduct(vector, vector));
}


double FusionVectorMagnitude(FusionVector vector) {
  return sqrt(FusionVectorMagnitudeSquared(vector));
}

FusionVector FusionVectorNormalise( FusionVector vector){

  double magnitudeReciprocal =
  fusionFastInverseSqrt(FusionVectorMagnitudeSquared(vector));

  return FusionVectorMultiplyScalar(vector, magnitudeReciprocal);
}


//------------------------------------------------------------------------------
// Inline functions - Quaternion operations
FusionQuaternion FusionQuaternionAdd(FusionQuaternion quaternionA, FusionQuaternion quaternionB) {
  return FusionQuaternion(
    quaternionA.w + quaternionB.w,
    quaternionA.x + quaternionB.x,
    quaternionA.y + quaternionB.y,
    quaternionA.z + quaternionB.z,
  );
}

FusionQuaternion FusionQuaternionMultiply(FusionQuaternion quaternionA, FusionQuaternion quaternionB) {
  return FusionQuaternion(
    quaternionA.w * quaternionB.w - quaternionA.x * quaternionB.x - quaternionA.y * quaternionB.y - quaternionA.z * quaternionB.z,
    quaternionA.w * quaternionB.x + quaternionA.x * quaternionB.w + quaternionA.y * quaternionB.z - quaternionA.z * quaternionB.y,
    quaternionA.w * quaternionB.y - quaternionA.x * quaternionB.z + quaternionA.y * quaternionB.w + quaternionA.z * quaternionB.x,
    quaternionA.w * quaternionB.z + quaternionA.x * quaternionB.y - quaternionA.y * quaternionB.x + quaternionA.z * quaternionB.w,
  );
}

FusionQuaternion FusionQuaternionMultiplyVector(FusionQuaternion quaternion, FusionVector vector) {
  return FusionQuaternion(
    -quaternion.x * vector.x - quaternion.y * vector.y - quaternion.z * vector.z,
    quaternion.w * vector.x + quaternion.y * vector.z - quaternion.z * vector.y,
    quaternion.w * vector.y - quaternion.x * vector.z + quaternion.z * vector.x,
    quaternion.w * vector.z + quaternion.x * vector.y - quaternion.y * vector.x,
  );
}


// 빠른 역제곱근 계산 메서드
 double FusionFastInverseSqrt(double x) {
   var buffer = Float32List(1);
   buffer[0] = x;
   var intView = buffer.buffer.asInt32List();

   int i = intView[0];
   i = 0x5F1F1412 - (i >> 1);

   intView[0] = i;
   double y = buffer[0];

   y = y * (1.69000231 - 0.714158168 * x * y * y);

   return y;
 }

 FusionQuaternion FusionQuaternionNormalise(FusionQuaternion quaternion) {
   double magnitudeReciprocal = FusionFastInverseSqrt(
       quaternion.w * quaternion.w + quaternion.x * quaternion.x + quaternion.y * quaternion.y + quaternion.z * quaternion.z);

   return FusionQuaternion(
     quaternion.w * magnitudeReciprocal,
     quaternion.x * magnitudeReciprocal,
     quaternion.y * magnitudeReciprocal,
     quaternion.z * magnitudeReciprocal,
   );
 }





//------------------------------------------------------------------------------
// Inline functions - Matrix operations

FusionVector FusionMatrixMultiplyVector(FusionMatrix matrix,FusionVector vector) {
  return FusionVector(
    matrix.xx * vector.x + matrix.xy * vector.y + matrix.xz * vector.z,
    matrix.yx * vector.x + matrix.yy * vector.y + matrix.yz * vector.z,
    matrix.zx * vector.x + matrix.zy * vector.y + matrix.zz * vector.z,
  );
}

//------------------------------------------------------------------------------
// Inline functions - Conversion operations

FusionMatrix FusionQuaternionToMatrix(FusionQuaternion quaternion) {
  final double qwqw = quaternion.w * quaternion.w;
  final double qwqx = quaternion.w * quaternion.x;
  final double qwqy = quaternion.w * quaternion.y;
  final double qwqz = quaternion.w * quaternion.z;
  final double qxqy = quaternion.x * quaternion.y;
  final double qxqz = quaternion.x * quaternion.z;
  final double qyqz = quaternion.y * quaternion.z;

  return FusionMatrix(
    2.0 * (qwqw - 0.5 + quaternion.x * quaternion.x),
    2.0 * (qxqy - qwqz),
    2.0 * (qxqz + qwqy),
    2.0 * (qxqy + qwqz),
    2.0 * (qwqw - 0.5 + quaternion.y * quaternion.y),
    2.0 * (qyqz - qwqx),
    2.0 * (qxqz - qwqy),
    2.0 * (qyqz + qwqx),
    2.0 * (qwqw - 0.5 + quaternion.z * quaternion.z),
  );
}
FusionEuler FusionQuaternionToEuler(FusionQuaternion quaternion) {
  final double halfMinusQySquared = 0.5 - quaternion.y * quaternion.y;

  final double roll = FusionRadiansToDegrees(
      atan2(quaternion.w * quaternion.x + quaternion.y * quaternion.z,
          halfMinusQySquared - quaternion.x * quaternion.x));
  final double pitch = FusionRadiansToDegrees(
      fusionAsin(2.0 * (quaternion.w * quaternion.y - quaternion.z * quaternion.x)));
  final double yaw = FusionRadiansToDegrees(
      atan2(quaternion.w * quaternion.z + quaternion.x * quaternion.y,
          halfMinusQySquared - quaternion.z * quaternion.z));

  return FusionEuler(roll, pitch, yaw);
}