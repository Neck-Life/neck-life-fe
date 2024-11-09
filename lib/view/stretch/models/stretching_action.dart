enum ProgressVariable {
  pitch,
  negativePitch,
  roll,
  negativeRoll,
  yaw,
  negativeYaw,
  none,
}

class StretchingAction {
  final String name;
  final bool Function(double pitch, double roll, double yaw) isCompleted;
  final double duration;
  final ProgressVariable progressVariable;
  final bool? animationAvailable;

  StretchingAction({
    required this.name,
    required this.isCompleted,
    required this.duration,
    required this.progressVariable,
    this.animationAvailable
  });
}

class StretchingGroup {
  final String groupName;
  final List<StretchingAction> actions;
  final int time;

  StretchingGroup({
    required this.groupName,
    required this.actions,
    required this.time
  });
}