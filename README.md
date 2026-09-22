# Carrot Timer 🥕

토마토 대신 당근. 라이브스트림 화면 한구석에 띄워두는 200×200 뽀모도로 타이머 (macOS, Flutter).

- 집중 25분 → 짧은 휴식 5분. 집중 4·8·12…번째 완료 후에는 긴 휴식 20분
- 타이머가 끝나면 비프음 + macOS 알림 배너. 다음 단계는 재생을 눌러야 시작
- 📌 고정: 항상 위에 표시 + 모든 Space(워크스페이스)와 전체화면 앱 위에서 따라다님. 설정은 재시작 후에도 유지
- 타이틀 바 없음. 창 아무 곳이나 끌어서 이동, 종료는 ⌘Q

## 실행

```sh
flutter run -d macos                 # 개발 실행
flutter build macos --release        # build/macos/Build/Products/Release/Carrot Timer.app
```

## 개발

```sh
flutter test                                                   # 엔진·컨트롤러 단위 테스트
flutter run -d macos --dart-define=CARROT_FAST=true           # 6초/3초/5초 사이클로 빠르게 확인
flutter run -d macos -t test_driver/app.dart                  # flutter_driver 확장 켜서 실행 (툴링에서 버튼 조작용)
```

## 구조

```
lib/domain/      순수 상태 머신 (PomodoroEngine) — Timer 없음, 테스트 대상
lib/controller/  TimerController — 벽시계 기준으로 엔진 구동, 완료 시 알림
lib/services/    알림(비프 + 배너), 설정 저장, 창(고정) 제어
lib/ui/          200×200 레이아웃과 위젯
```
