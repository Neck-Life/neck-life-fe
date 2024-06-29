import 'fusion_math.dart';

enum FusionAxesAlignment {
  PXPYPZ, // +X+Y+Z
  PXNZPY, // +X-Z+Y
  PXNYNZ, // +X-Y-Z
  PXPZNY, // +X+Z-Y
  NXPYNZ, // -X+Y-Z
  NXPZPY, // -X+Z+Y
  NXNYPZ, // -X-Y+Z
  NXNZNY, // -X-Z-Y
  PYNXPZ, // +Y-X+Z
  PYNZNX, // +Y-Z-X
  PYPXNZ, // +Y+X-Z
  PYPZPX, // +Y+Z+X
  NYPXPZ, // -Y+X+Z
  NYNZPX, // -Y-Z+X
  NYNXNZ, // -Y-X-Z
  NYPZNX, // -Y+Z-X
  PZPYNX, // +Z+Y-X
  PZPXPY, // +Z+X+Y
  PZNYPX, // +Z-Y+X
  PZNXNY, // +Z-X-Y
  NZPYPX, // -Z+Y+X
  NZNXPY, // -Z-X+Y
  NZNYNX, // -Z-Y-X
  NZPXNY  // -Z+X-Y
}


FusionVector FusionAxesSwap(FusionVector sensor, FusionAxesAlignment alignment) {
  switch (alignment) {
    case FusionAxesAlignment.PXPYPZ:
      return sensor;
    case FusionAxesAlignment.PXNZPY:
      return FusionVector(sensor.x, -sensor.z, sensor.y);
    case FusionAxesAlignment.PXNYNZ:
      return FusionVector(sensor.x, -sensor.y, -sensor.z);
    case FusionAxesAlignment.PXPZNY:
      return FusionVector(sensor.x, sensor.z, -sensor.y);
    case FusionAxesAlignment.NXPYNZ:
      return FusionVector(-sensor.x, sensor.y, -sensor.z);
    case FusionAxesAlignment.NXPZPY:
      return FusionVector(-sensor.x, sensor.z, sensor.y);
    case FusionAxesAlignment.NXNYPZ:
      return FusionVector(-sensor.x, -sensor.y, sensor.z);
    case FusionAxesAlignment.NXNZNY:
      return FusionVector(-sensor.x, -sensor.z, -sensor.y);
    case FusionAxesAlignment.PYNXPZ:
      return FusionVector(sensor.y, -sensor.x, sensor.z);
    case FusionAxesAlignment.PYNZNX:
      return FusionVector(sensor.y, -sensor.z, -sensor.x);
    case FusionAxesAlignment.PYPXNZ:
      return FusionVector(sensor.y, sensor.x, -sensor.z);
    case FusionAxesAlignment.PYPZPX:
      return FusionVector(sensor.y, sensor.z, sensor.x);
    case FusionAxesAlignment.NYPXPZ:
      return FusionVector(-sensor.y, sensor.x, sensor.z);
    case FusionAxesAlignment.NYNZPX:
      return FusionVector(-sensor.y, -sensor.z, sensor.x);
    case FusionAxesAlignment.NYNXNZ:
      return FusionVector(-sensor.y, -sensor.x, -sensor.z);
    case FusionAxesAlignment.NYPZNX:
      return FusionVector(-sensor.y, sensor.z, -sensor.x);
    case FusionAxesAlignment.PZPYNX:
      return FusionVector(sensor.z, sensor.y, -sensor.x);
    case FusionAxesAlignment.PZPXPY:
      return FusionVector(sensor.z, sensor.x, sensor.y);
    case FusionAxesAlignment.PZNYPX:
      return FusionVector(sensor.z, -sensor.y, sensor.x);
    case FusionAxesAlignment.PZNXNY:
      return FusionVector(sensor.z, -sensor.x, -sensor.y);
    case FusionAxesAlignment.NZPYPX:
      return FusionVector(-sensor.z, sensor.y, sensor.x);
    case FusionAxesAlignment.NZNXPY:
      return FusionVector(-sensor.z, -sensor.x, sensor.y);
    case FusionAxesAlignment.NZNYNX:
      return FusionVector(-sensor.z, -sensor.y, -sensor.x);
    case FusionAxesAlignment.NZPXNY:
      return FusionVector(-sensor.z, sensor.x, -sensor.y);
    default:
      return sensor; // avoid compiler warning
  }
}