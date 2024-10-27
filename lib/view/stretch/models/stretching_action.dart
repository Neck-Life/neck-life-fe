enum ProgressVariable {
  pitch,
  negativePitch,
  roll,
  negativeRoll,
  yaw,
  negativeYaw,
}

class StretchingAction {
  final String name;
  final bool Function(double pitch, double roll, double yaw) isCompleted;
  final double duration;
  final ProgressVariable progressVariable;

  StretchingAction({
    required this.name,
    required this.isCompleted,
    required this.duration,
    required this.progressVariable,
  });
}

class StretchingGroup {
  final String groupName;
  final List<StretchingAction> actions;

  StretchingGroup({
    required this.groupName,
    required this.actions,
  });
}