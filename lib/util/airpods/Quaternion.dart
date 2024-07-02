import 'dart:math';

class Quaternion {
  final double w, x, y, z;

  Quaternion(this.w, this.x, this.y, this.z);

  // Computes the magnitude of the quaternion
  double magnitude() {
    return sqrt(w * w + x * x + y * y + z * z);
  }

  // Computes the conjugate of the quaternion
  Quaternion conjugate() {
    return Quaternion(w, -x, -y, -z);
  }

  // Multiplies this quaternion with another
  Quaternion multiply(Quaternion other) {
    return Quaternion(
      w * other.w - x * other.x - y * other.y - z * other.z,
      w * other.x + x * other.w + y * other.z + z * other.y,
      w * other.y - x * other.z + y * other.w + z * other.x,
      w * other.z + x * other.y - y * other.x + z * other.w,
    );
  }

  // Normalizes the quaternion
  Quaternion normalize() {
    double mag = magnitude();
    return Quaternion(w / mag, x / mag, y / mag, z / mag);
  }
}

// Function to calculate the angle between two quaternions
double calculateRotationAngle(Quaternion q1, Quaternion q2) {
  // Normalize quaternions to ensure they represent valid rotations
  Quaternion normQ1 = q1.normalize();
  Quaternion normQ2 = q2.normalize();

  // Calculate the relative rotation quaternion
  Quaternion relativeRotation = normQ2.multiply(normQ1.conjugate()).normalize();

  // Calculate the angle of rotation
  double cosTheta = relativeRotation.w;
  double angle = 2 * acos(cosTheta);

  // Ensure the angle is not negative
  return angle >= 0 ? angle : angle + 2 * pi;
}

void main() {
  Quaternion q1 = Quaternion(1, 0, 0, 0); // Identity quaternion
  Quaternion q2 = Quaternion(0.707, 0, 0.707, 0); // 90 degrees around Y-axis

  double angle = calculateRotationAngle(q1, q2);
  print('Rotation angle in radians: $angle');
  print('Rotation angle in degrees: ${angle * 180 / pi}');
}