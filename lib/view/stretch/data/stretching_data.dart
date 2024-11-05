import '../models/stretching_action.dart';


final strchLan = {
  'ko': {
    'group1': '목 뒤로 젖히기 운동',
    'group2': '국군도수체조 : 목운동',
    'group3': '목 좌우 돌리기 운동[beta]',
    'stretch1': '목을 뒤로 젖히기',
    'stretch2': '잠시 휴식',
    'stretch3': '다시 목을 뒤로 젖히기',
    'stretch4': '목을 앞으로 숙이기 (아래)',
    'stretch5': '목을 왼쪽으로 돌리기 (왼쪽)',
    'stretch6': '목을 뒤로 젖히기 (위)',
    'stretch7': '목을 오른쪽으로 돌리기 (오른쪽)',
    'stretch8': '왼쪽 바라보기',
    'stretch9': '오른쪽 바라보기',
  },
  'en': {
    'group1': 'Neck Backward Stretching Exercise',
    'group2': 'Korean Military Neck Exercise',
    'group3': 'Neck Rotation Exercise [beta]',
    'stretch1': 'Tilt Neck Backward',
    'stretch2': 'Short Break',
    'stretch3': 'Tilt Neck Backward Again',
    'stretch4': 'Tilt Neck Forward (Down)',
    'stretch5': 'Turn Neck to Left (Left)',
    'stretch6': 'Tilt Neck Backward (Up)',
    'stretch7': 'Turn Neck to Right (Right)',
    'stretch8': 'Look to the Left',
    'stretch9': 'Look to the Right',
  },
  'ja': {
    'group1': '首を後ろに反らす運動',
    'group2': '軍の体操: 首の運動',
    'group3': '首の左右回転運動[ベータ版]',
    'stretch1': '首を後ろに反らす',
    'stretch2': '短い休憩',
    'stretch3': '再び首を後ろに反らす',
    'stretch4': '首を前に傾ける (下)',
    'stretch5': '首を左に回す (左)',
    'stretch6': '首を後ろに傾ける (上)',
    'stretch7': '首を右に回す (右)',
    'stretch8': '左を見る',
    'stretch9': '右を見る',
  }
};


class StretchingData {
  // late List<StretchingGroup> groups;

  static List<StretchingGroup> init(String lanCode) {
    return [
      StretchingGroup(
        time: 20,
        groupName: strchLan[lanCode]?['group1'] ?? 'Neck Backward Stretching Exercise',
        actions: [
          StretchingAction(
            name: strchLan[lanCode]?['stretch1'] ?? 'Tilt Neck Backward',
            isCompleted: (pitch, roll, yaw) => pitch > 0.8,
            duration: 7,
            progressVariable: ProgressVariable.pitch,
          ),
          StretchingAction(
            name: strchLan[lanCode]?['stretch2'] ?? 'Short Break',
            isCompleted: (pitch, roll, yaw) => true,
            duration: 5,
            progressVariable: ProgressVariable.none,
          ),
          StretchingAction(
            name: strchLan[lanCode]?['stretch3'] ?? 'Tilt Neck Backward Again',
            isCompleted: (pitch, roll, yaw) => pitch > 0.8,
            duration: 7,
            progressVariable: ProgressVariable.pitch,
          ),
        ],
      ),
      StretchingGroup(
        time: 10,
        groupName: strchLan[lanCode]?['group2'] ?? 'Military Physical Training: Neck Exercise',
        actions: [
          StretchingAction(
            name: strchLan[lanCode]?['stretch1'] ?? 'Tilt Neck Backward',
            isCompleted: (pitch, roll, yaw) => pitch > 0.8,
            duration: 2,
            progressVariable: ProgressVariable.pitch,
          ),
          StretchingAction(
            name: strchLan[lanCode]?['stretch4'] ?? 'Tilt Neck Forward (Down)',
            isCompleted: (pitch, roll, yaw) => pitch < -0.5,
            duration: 0.5,
            progressVariable: ProgressVariable.negativePitch,
          ),
          StretchingAction(
            name: strchLan[lanCode]?['stretch5'] ?? 'Turn Neck to Left (Left)',
            isCompleted: (pitch, roll, yaw) => roll < -0.5,
            duration: 0.5,
            progressVariable: ProgressVariable.negativeRoll,
          ),
          StretchingAction(
            name: strchLan[lanCode]?['stretch6'] ?? 'Tilt Neck Backward (Up)',
            isCompleted: (pitch, roll, yaw) => pitch > 0.5,
            duration: 0.5,
            progressVariable: ProgressVariable.pitch,
          ),
          StretchingAction(
            name: strchLan[lanCode]?['stretch7'] ?? 'Turn Neck to Right (Right)',
            isCompleted: (pitch, roll, yaw) => roll > 0.5,
            duration: 0.5,
            progressVariable: ProgressVariable.roll,
          ),
        ],
      ),
      StretchingGroup(
        time: 10,
        groupName: strchLan[lanCode]?['group3'] ?? 'Neck Left-Right Rotation Exercise [beta]',
        actions: [
          StretchingAction(
            name: strchLan[lanCode]?['stretch8'] ?? 'Look to the Left',
            isCompleted: (pitch, roll, yaw) => yaw > 1.0,
            duration: 5,
            progressVariable: ProgressVariable.yaw,
          ),
          StretchingAction(
            name: strchLan[lanCode]?['stretch9'] ?? 'Look to the Right',
            isCompleted: (pitch, roll, yaw) => yaw < -1.0,
            duration: 5,
            progressVariable: ProgressVariable.negativeYaw,
          ),
        ],
      ),
    ];
  }
}