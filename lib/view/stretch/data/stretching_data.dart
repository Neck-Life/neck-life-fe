import '../models/stretching_action.dart';


final strchLan = {
  'ko': {
    'group1': '목 뒤로 젖히기 운동',
    'group2': '국군도수체조 : 목운동[beta]',
    'group3': '목 좌우 돌리기 운동[beta]',
    'stretch1': '목을 뒤로 젖히기',
    'stretch2': '잠시 휴식',
    'stretch3': '다시 목을 뒤로 젖히기',
    'stretch4': '목을 앞으로 숙이기',
    'stretch5': '목을 왼쪽으로 돌리기',
    'stretch5_r': '목을 오른쪽으로 돌리기',
    'stretch6': '목을 뒤로 젖히기 (위)',
    'stretch7': '목을 오른쪽으로 돌리기 (오른쪽)',
    'stretch8': '왼쪽 바라보기',
    'stretch9': '오른쪽 바라보기',
    'stretch10': '다시 왼쪽 바라보기',
    'stretch11': '다시 오른쪽 바라보기',
  },
  'en': {
    'group1': 'Neck Backward Stretching Exercise',
    'group2': 'Korean Military Neck Exercise [beta]',
    'group3': 'Neck Rotation Exercise [beta]',
    'stretch1': 'Tilt Neck Backward',
    'stretch2': 'Short Break',
    'stretch3': 'Tilt Neck Backward Again',
    'stretch4': 'Tilt Neck Forward',
    'stretch5': 'Turn Neck to Left',
    'stretch5_r': 'Turn Neck to Right',
    'stretch6': 'Tilt Neck Backward (Up)',
    'stretch7': 'Turn Neck to Right (Right)',
    'stretch8': 'Look to the Left',
    'stretch9': 'Look to the Right',
    'stretch10': 'Look to the Left Again',
    'stretch11': 'Look to the Right Again',
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
    'stretch5_r': '首を右に回す (左)',
    'stretch6': '首を後ろに傾ける (上)',
    'stretch7': '首を右に回す (右)',
    'stretch8': '左を見る',
    'stretch9': '右を見る',
    'stretch10': '再び左を見る',
    'stretch11': '再び右を見る',
  }
};


class StretchingData {
  // late List<StretchingGroup> groups;

  static List<StretchingGroup> init(String lanCode) {
    return [
      //목 뒤로 젖히기 운동
      StretchingGroup(
        time: 20,
        groupName: strchLan[lanCode]?['group1'] ?? 'Neck Backward Stretching Exercise',
        actions: [
          StretchingAction(
            animationAvailable: true,
            name: strchLan[lanCode]?['stretch1'] ?? 'Tilt Neck Backward',
            isCompleted: (pitch, roll, yaw) => pitch > 0.8,
            duration: 10,
            progressVariable: ProgressVariable.pitch,
          ),
          StretchingAction(
            animationAvailable: true,
            name: strchLan[lanCode]?['stretch2'] ?? 'Short Break',
            isCompleted: (pitch, roll, yaw) => true,
            duration: 5,
            progressVariable: ProgressVariable.none,
          ),
          StretchingAction(
            animationAvailable: true,
            name: strchLan[lanCode]?['stretch3'] ?? 'Tilt Neck Backward Again',
            isCompleted: (pitch, roll, yaw) => pitch > 0.8,
            duration: 10,
            progressVariable: ProgressVariable.pitch,
          ),
        ],
      ),

      //국군도수체조
      StretchingGroup(
        time: 15,
        groupName: strchLan[lanCode]?['group2'] ?? 'Military Physical Training: Neck Exercise',
        actions: [
          StretchingAction(
            animationAvailable: true,
            name: strchLan[lanCode]?['stretch1'] ?? 'Tilt Neck Backward',
            isCompleted: (pitch, roll, yaw) => pitch > 0.8,
            duration: 2,
            progressVariable: ProgressVariable.pitch,
          ),
          StretchingAction(
            name: strchLan[lanCode]?['stretch4'] ?? 'Tilt Neck Forward',
            isCompleted: (pitch, roll, yaw) => pitch < -0.5,
            duration: 0.5,
            progressVariable: ProgressVariable.negativePitch,
          ),
          StretchingAction(
            name: strchLan[lanCode]?['stretch5'] ?? 'Turn Neck to Left',
            isCompleted: (pitch, roll, yaw) => roll < -0.5,
            duration: 0.5,
            progressVariable: ProgressVariable.negativeRoll,
          ),
          StretchingAction(
            name: strchLan[lanCode]?['stretch5'] ?? 'Turn Neck to Left',
            isCompleted: (pitch, roll, yaw) => pitch > 0.5,
            duration: 0.5,
            progressVariable: ProgressVariable.pitch,
          ),
          StretchingAction(
            name: strchLan[lanCode]?['stretch5'] ?? 'Turn Neck to Left',
            isCompleted: (pitch, roll, yaw) => roll > 0.5,
            duration: 0.5,
            progressVariable: ProgressVariable.roll,
          ),
          //둘둘셋넷
          StretchingAction(
            animationAvailable: true,
            name: strchLan[lanCode]?['stretch1'] ?? 'Tilt Neck Backward',
            isCompleted: (pitch, roll, yaw) => pitch > 0.8,
            duration: 2,
            progressVariable: ProgressVariable.pitch,
          ),
          StretchingAction(
            name: strchLan[lanCode]?['stretch4'] ?? 'Tilt Neck Forward',
            isCompleted: (pitch, roll, yaw) => pitch < -0.5,
            duration: 0.5,
            progressVariable: ProgressVariable.negativePitch,
          ),
          StretchingAction(
            name: strchLan[lanCode]?['stretch5_r'] ?? 'Turn Neck to Right',
            isCompleted: (pitch, roll, yaw) => roll > 0.5,
            duration: 0.5,
            progressVariable: ProgressVariable.roll,
          ),
          StretchingAction(
            name: strchLan[lanCode]?['stretch5_r'] ?? 'Turn Neck to Right',
            isCompleted: (pitch, roll, yaw) => pitch > 0.5,
            duration: 0.5,
            progressVariable: ProgressVariable.pitch,
          ),
          StretchingAction(
            name: strchLan[lanCode]?['stretch5_r'] ?? 'Turn Neck to Right',
            isCompleted: (pitch, roll, yaw) => roll < -0.5,
            duration: 0.5,
            progressVariable: ProgressVariable.negativeRoll,
          ),
        ],
      ),

      //목 좌우 돌리기
      StretchingGroup(
        time: 20,
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
          //둘둘셋넷
          StretchingAction(
            name: strchLan[lanCode]?['stretch10'] ?? 'Look to the Left Again',
            isCompleted: (pitch, roll, yaw) => yaw > 1.0,
            duration: 5,
            progressVariable: ProgressVariable.yaw,
          ),
          StretchingAction(
            name: strchLan[lanCode]?['stretch11'] ?? 'Look to the Right Again',
            isCompleted: (pitch, roll, yaw) => yaw < -1.0,
            duration: 5,
            progressVariable: ProgressVariable.negativeYaw,
          ),
        ],
      ),
    ];
  }
}