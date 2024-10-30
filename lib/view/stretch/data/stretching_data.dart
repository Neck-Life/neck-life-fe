import '../models/stretching_action.dart';

final List<StretchingGroup> stretchingGroups = [
  // // 0. 4방향 목 기울이기 운동 TODO: 안좋은 운동으로 소개되어 비활성화
  // StretchingGroup(
  //   groupName: '목 상하좌우 스트레칭',
  //   actions: [
  //     StretchingAction(
  //       name: '목을 뒤로 젖히기',
  //       isCompleted: (pitch, roll, yaw) => pitch > 0.8,
  //       duration: 10,
  //       progressVariable: ProgressVariable.pitch,
  //     ),
  //     StretchingAction(
  //       name: '목을 앞으로 숙이기',
  //       isCompleted: (pitch, roll, yaw) => pitch < -0.8,
  //       duration: 10,
  //       progressVariable: ProgressVariable.negativePitch,
  //     ),
  //     StretchingAction(
  //       name: '목을 왼쪽으로 기울이기',
  //       isCompleted: (pitch, roll, yaw) => roll < -0.8,
  //       duration: 10,
  //       progressVariable: ProgressVariable.negativeRoll,
  //     ),
  //     StretchingAction(
  //       name: '목을 오른쪽으로 기울이기',
  //       isCompleted: (pitch, roll, yaw) => roll > 0.8,
  //       duration: 10,
  //       progressVariable: ProgressVariable.roll,
  //     ),
  //   ],
  // ),
  // 4. 목 뒤로 젖히기 운동
  StretchingGroup(
    groupName: '목 뒤로 젖히기 운동',
    actions: [
      // 첫 번째 목을 뒤로 젖히기 동작
      StretchingAction(
        name: '목을 뒤로 젖히기',
        isCompleted: (pitch, roll, yaw) => pitch > 0.8,
        duration: 8,
        progressVariable: ProgressVariable.pitch,
      ),
      // 잠시 휴식 동작
      StretchingAction(
        name: '잠시 휴식',
        isCompleted: (pitch, roll, yaw) => true,  // 조건 없이 일정 시간 대기
        duration: 5,  // 원하는 휴식 시간(예: 3초)
        progressVariable: ProgressVariable.none,  // 진행 변수를 설정하지 않음
      ),
      // 두 번째 목을 뒤로 젖히기 동작
      StretchingAction(
        name: '다시 목을 뒤로 젖히기',
        isCompleted: (pitch, roll, yaw) => pitch > 0.8,
        duration: 8,
        progressVariable: ProgressVariable.pitch,
      ),
    ],
  ),


  // 3. 반시계 2회, 시계 2회 목 돌리기
  StretchingGroup(
    groupName: '국군도수체조 : 목운동 ',
    actions: [
      StretchingAction(
        name: '목을 뒤로 젖히기',
        isCompleted: (pitch, roll, yaw) => pitch > 0.8,
        duration: 2,
        progressVariable: ProgressVariable.pitch,
      ),
      StretchingAction(
        name: '목을 앞으로 숙이기 (아래)',
        isCompleted: (pitch, roll, yaw) => pitch < -0.5,
        duration: 0.5,
        progressVariable: ProgressVariable.negativePitch,
      ),
      StretchingAction(
        name: '목을 왼쪽으로 돌리기 (왼쪽)',
        isCompleted: (pitch, roll, yaw) => roll < -0.5,
        duration: 0.5,
        progressVariable: ProgressVariable.negativeRoll,
      ),
      StretchingAction(
        name: '목을 뒤로 젖히기 (위)',
        isCompleted: (pitch, roll, yaw) => pitch > 0.5,
        duration: 0.5,
        progressVariable: ProgressVariable.pitch,
      ),
      StretchingAction(
        name: '목을 오른쪽으로 돌리기 (오른쪽)',
        isCompleted: (pitch, roll, yaw) => roll > 0.5,
        duration: 0.5,
        progressVariable: ProgressVariable.roll,
      ),
      StretchingAction(
        name: '목을 뒤로 젖히기',
        isCompleted: (pitch, roll, yaw) => pitch > 0.8,
        duration: 2,
        progressVariable: ProgressVariable.pitch,
      ),
      StretchingAction(
        name: '목을 앞으로 숙이기 (아래)',
        isCompleted: (pitch, roll, yaw) => pitch < -0.5,
        duration: 0.5,
        progressVariable: ProgressVariable.negativePitch,
      ),
      StretchingAction(
        name: '목을 오른쪽으로 돌리기 (오른쪽)',
        isCompleted: (pitch, roll, yaw) => roll > 0.5,
        duration: 0.5,
        progressVariable: ProgressVariable.roll,
      ),
      StretchingAction(
        name: '목을 뒤로 젖히기 (위)',
        isCompleted: (pitch, roll, yaw) => pitch > 0.5,
        duration: 0.5,
        progressVariable: ProgressVariable.pitch,
      ),
      StretchingAction(
        name: '목을 왼쪽으로 돌리기 (왼쪽)',
        isCompleted: (pitch, roll, yaw) => roll < -0.5,
        duration: 0.5,
        progressVariable: ProgressVariable.negativeRoll,
      ),
    ],
  ),



  // 5. 목 좌우 돌리기
  StretchingGroup(
    groupName: '목 좌우 돌리기 운동[beta]',
    actions: [
      StretchingAction(
        name: '왼쪽 바라보기',
        isCompleted: (pitch, roll, yaw) => yaw > 1.0,
        duration: 5,
        progressVariable: ProgressVariable.yaw,
      ),
      StretchingAction(
        name: '오른쪽 바라보기',
        isCompleted: (pitch, roll, yaw) => yaw < -1.0,
        duration: 5,
        progressVariable: ProgressVariable.negativeYaw,
      ),
      StretchingAction(
        name: '왼쪽 바라보기',
        isCompleted: (pitch, roll, yaw) => yaw > 1.0,
        duration: 5,
        progressVariable: ProgressVariable.yaw,
      ),
      StretchingAction(
        name: '오른쪽 바라보기',
        isCompleted: (pitch, roll, yaw) => yaw < -1.0,
        duration: 5,
        progressVariable: ProgressVariable.negativeYaw,
      ),
    ],
  ),
];