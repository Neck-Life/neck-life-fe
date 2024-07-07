import 'dart:math';

class Matrix {
  static List<List<double>> multiply(List<List<double>> a, List<List<double>> b) {
    var aRows = a.length, aCols = a[0].length, bRows = b.length, bCols = b[0].length;
    var result = List.generate(aRows, (_) => List<double>.filled(bCols, 0.0));
    for (var i = 0; i < aRows; i++) {
      for (var j = 0; j < bCols; j++) {
        for (var k = 0; k < aCols; k++) {
          result[i][j] += a[i][k] * b[k][j];
        }
      }
    }
    return result;
  }

  static List<double> multiplyVector(List<List<double>> a, List<double> x) {
    var result = List<double>.filled(a.length, 0.0);
    for (var i = 0; i < a.length; i++) {
      for (var j = 0; j < x.length; j++) {
        result[i] += a[i][j] * x[j];
      }
    }
    return result;
  }


  static List<List<double>> scalarMultiply(double scalar, List<List<double>> matrix) {
    return matrix.map((row) => row.map((val) => val * scalar).toList()).toList();
  }

  static List<List<double>> inverse2x2(List<List<double>> matrix) {
    if (matrix.length != 2 || matrix.any((row) => row.length != 2)) {
      throw Exception('Matrix.inverse2x2 requires a 2x2 matrix.');
    }

    double a = matrix[0][0];
    double b = matrix[0][1];
    double c = matrix[1][0];
    double d = matrix[1][1];

    // Calculate the determinant
    double det = a * d - b * c;
    if (det == 0) {
      throw Exception('Matrix is singular and cannot be inverted.');
    }

    // Calculate the inverse of the matrix
    return [
      [d / det, -b / det],
      [-c / det, a / det]
    ];
  }



  static List<List<double>> transpose(List<List<double>> matrix) {
    int numRows = matrix.length;
    int numCols = matrix[0].length;
    List<List<double>> transposed = List.generate(numCols, (_) => List<double>.filled(numRows, 0.0));

    for (int i = 0; i < numRows; i++) {
      for (int j = 0; j < numCols; j++) {
        transposed[j][i] = matrix[i][j];
      }
    }
    return transposed;
  }

  static List<List<double>> add(List<List<double>> a, List<List<double>> b) {
    if (a.length != b.length || a[0].length != b[0].length) {
      throw Exception('Matrix dimensions must match!');
    }
    List<List<double>> result = List.generate(a.length,
            (i) => List.generate(a[0].length, (j) => a[i][j] + b[i][j]));
    return result;
  }
  static List<double> vectorAdd(List<double> vectorA, List<double> vectorB) {
    if (vectorA.length != vectorB.length) {
      throw Exception('Both vectors must be of the same length to add.');
    }
    List<double> result = List.generate(vectorA.length, (i) => vectorA[i] + vectorB[i]);
    return result;
  }
//

}

abstract class KalmanFilter {
  static double dt = 0.4;
  List<List<double>> A = [[1, dt], [0, 1]];
  List<List<double>> H =[[0,1]];
  List<List<double>> Q = [[1, 0], [0, 1]];
  List<List<double>> R = [[10]];
  List<List<double>> P = [[1, 0.005], [0, 1]];
  List<double> x_esti = [0.0, 0.0];

  void setX(List<double> x) {
    x_esti = x;
  }

  void iterate(List<double> z) {
    // Prediction step
    var x_pred = Matrix.multiplyVector(A, x_esti);
    var P_pred = Matrix.add(Matrix.multiply(Matrix.multiply(A, P), Matrix.transpose(A)), Q);

    // Kalman Gain calculation
    var temp1 = Matrix.multiply(H, P_pred);
    var temp = Matrix.multiply(Matrix.multiply(H, P_pred), Matrix.transpose(H));
    var S = Matrix.add(Matrix.multiply(Matrix.multiply(H, P_pred), Matrix.transpose(H)), R);

    var K = Matrix.multiply(Matrix.multiply(P_pred, Matrix.transpose(H)), S);

    // Update step
    var z_pred = Matrix.multiplyVector(H, x_pred);
    x_esti = Matrix.vectorAdd(x_pred, Matrix.multiplyVector(K, [z[0] - z_pred[0]]));
    P = Matrix.add(P_pred, Matrix.scalarMultiply(-1, Matrix.multiply(Matrix.multiply(K, H), P_pred)));

    // Extract positions and velocities for output
    double vel = x_esti[0];
    double acc = x_esti[1];
    // print(' Velocity: $vel Acceleration: $acc');
  }

  void setDt(double d) {
    dt = d;
  }

}