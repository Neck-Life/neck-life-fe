import '../models/stretching_action.dart';

final List<StretchingGroup> stretchingGroups = [
  StretchingGroup(
    groupName: '목 기울이기 운동',
    actions: [
      StretchingAction(
        name: '고개 아래로 기울이기',
        isCompleted: (pitch, roll, yaw) => pitch < -0.8,
        duration: 3, // 3초 동안 유지
      ),
      StretchingAction(
        name: '고개 위로 기울이기',
        isCompleted: (pitch, roll, yaw) => pitch > 0.8,
        duration: 3, // 3초 동안 유지
      ),
      StretchingAction(
        name: '고개 왼쪽 기울이기',
        isCompleted: (pitch, roll, yaw) => roll < -0.8,
        duration: 3, // 3초 동안 유지
      ),
      StretchingAction(
        name: '고개 오른쪽 기울이기',
        isCompleted: (pitch, roll, yaw) => roll > 0.8,
        duration: 3, // 3초 동안 유지
      ),
    ],
  ),
  StretchingGroup(
    groupName: '반시계방향 목 돌리기 운동',
    actions: [
      StretchingAction(
        name: '목을 아래로 기울이기 (Down)',
        isCompleted: (pitch, roll, yaw) => pitch < -0.5,
        duration: 0.5, // 3초 동안 유지
      ),
      StretchingAction(
        name: '목을 왼쪽으로 돌리기 (Left)',
        isCompleted: (pitch, roll, yaw) => roll < -0.5,
        duration: 0.5, // 4초 동안 유지
      ),
      StretchingAction(
        name: '목을 위로 기울이기 (Up)',
        isCompleted: (pitch, roll, yaw) => pitch > 0.5,
        duration: 0.5, // 5초 동안 유지
      ),
      StretchingAction(
        name: '목을 오른쪽으로 돌리기 (Right)',
        isCompleted: (pitch, roll, yaw) => roll > 0.5,
        duration: 0.5, // 3초 동안 유지
      ),
    ],
  ),
  StretchingGroup(
    groupName: '시계방향 목 돌리기 운동',
    actions: [
      StretchingAction(
        name: '목을 아래로 기울이기 (Down)',
        isCompleted: (pitch, roll, yaw) => pitch < -0.5,
        duration: 0.5, // 3초 동안 유지
      ),
      StretchingAction(
        name: '목을 오른쪽으로 돌리기 (Right)',
        isCompleted: (pitch, roll, yaw) => roll > 0.5,
        duration: 0.5, // 3초 동안 유지
      ),
      StretchingAction(
        name: '목을 위로 기울이기 (Up)',
        isCompleted: (pitch, roll, yaw) => pitch > 0.5,
        duration: 0.5, // 5초 동안 유지
      ),
      StretchingAction(
        name: '목을 왼쪽으로 돌리기 (Left)',
        isCompleted: (pitch, roll, yaw) => roll < -0.5,
        duration: 0.5, // 4초 동안 유지
      ),

    ],
  ),
  StretchingGroup(
    groupName: '반시계2번, 시계2번 목회전운동',
    actions: [
      StretchingAction(
        name: '목을 아래로 기울이기 (Down)',
        isCompleted: (pitch, roll, yaw) => pitch < -0.5,
        duration: 0.5, // 3초 동안 유지
      ),
      StretchingAction(
        name: '목을 왼쪽으로 돌리기 (Left)',
        isCompleted: (pitch, roll, yaw) => roll < -0.5,
        duration: 0.5, // 4초 동안 유지
      ),
      StretchingAction(
        name: '목을 위로 기울이기 (Up)',
        isCompleted: (pitch, roll, yaw) => pitch > 0.5,
        duration: 0.5, // 5초 동안 유지
      ),
      StretchingAction(
        name: '목을 오른쪽으로 돌리기 (Right)',
        isCompleted: (pitch, roll, yaw) => roll > 0.5,
        duration: 0.5, // 3초 동안 유지
      ),
      StretchingAction(
        name: '목을 아래로 기울이기 (Down)',
        isCompleted: (pitch, roll, yaw) => pitch < -0.5,
        duration: 0.5, // 3초 동안 유지
      ),
      StretchingAction(
        name: '목을 왼쪽으로 돌리기 (Left)',
        isCompleted: (pitch, roll, yaw) => roll < -0.5,
        duration: 0.5, // 4초 동안 유지
      ),
      StretchingAction(
        name: '목을 위로 기울이기 (Up)',
        isCompleted: (pitch, roll, yaw) => pitch > 0.5,
        duration: 0.5, // 5초 동안 유지
      ),
      StretchingAction(
        name: '목을 오른쪽으로 돌리기 (Right)',
        isCompleted: (pitch, roll, yaw) => roll > 0.5,
        duration: 0.5, // 3초 동안 유지
      ),
      StretchingAction(
        name: '목을 아래로 기울이기 (Down)',
        isCompleted: (pitch, roll, yaw) => pitch < -0.5,
        duration: 0.5, // 3초 동안 유지
      ),
      StretchingAction(
        name: '목을 오른쪽으로 돌리기 (Right)',
        isCompleted: (pitch, roll, yaw) => roll > 0.5,
        duration: 0.5, // 3초 동안 유지
      ),
      StretchingAction(
        name: '목을 위로 기울이기 (Up)',
        isCompleted: (pitch, roll, yaw) => pitch > 0.5,
        duration: 0.5, // 5초 동안 유지
      ),
      StretchingAction(
        name: '목을 왼쪽으로 돌리기 (Left)',
        isCompleted: (pitch, roll, yaw) => roll < -0.5,
        duration: 0.5, // 4초 동안 유지
      ),
      StretchingAction(
        name: '목을 아래로 기울이기 (Down)',
        isCompleted: (pitch, roll, yaw) => pitch < -0.5,
        duration: 0.5, // 3초 동안 유지
      ),
      StretchingAction(
        name: '목을 오른쪽으로 돌리기 (Right)',
        isCompleted: (pitch, roll, yaw) => roll > 0.5,
        duration: 0.5, // 3초 동안 유지
      ),
      StretchingAction(
        name: '목을 위로 기울이기 (Up)',
        isCompleted: (pitch, roll, yaw) => pitch > 0.5,
        duration: 0.5, // 5초 동안 유지
      ),
      StretchingAction(
        name: '목을 왼쪽으로 돌리기 (Left)',
        isCompleted: (pitch, roll, yaw) => roll < -0.5,
        duration: 0.5, // 4초 동안 유지
      ),

    ],
  ),
  StretchingGroup(
    groupName: '목 도리도리 운동',
    actions: [
      StretchingAction(
        name: '목 돌려서 왼쪽 바라보기',
        isCompleted: (pitch, roll, yaw) => yaw > 1.0,
        duration: 5, // 5초 동안 유지
      ),
      StretchingAction(
        name: '목 돌려서 오른쪽 바라보기',
        isCompleted: (pitch, roll, yaw) => yaw < -1.0,
        duration: 5, // 5초 동안 유지
      ),
    ],
  ),
];