
import 'package:flutter/material.dart';
import 'package:mocksum_flutter/view/goal/subpage/goal_setting.dart';

class GoalProvider with ChangeNotifier {

  Set<GoalType> _settedGoalTypes = {};
  Map<String, dynamic> _goalMap = {'score': {}, 'time': {}};

  Set<GoalType> get settedGoalTypes => _settedGoalTypes;
  Map<String, dynamic> get goalMap => _goalMap;

  void addSettedGoalTypes(GoalType goalType) {
    _settedGoalTypes.add(goalType);
    notifyListeners();
  }

  void deleteSettedGoalTypes(GoalType goalType) {
    _settedGoalTypes.remove(goalType);
    notifyListeners();
  }

  void updateGoalMap(Map<String, dynamic> newMap) {
    _goalMap = newMap;
    notifyListeners();
  }

}
