# [UI/폰트] 업적 창 숫자 겹침 디버깅

작성일: 2026-03-29  
상태: 해결 완료

## 문서 메타

- 문제 유형 태그: `UI 레이아웃`, `폰트 메트릭`, `숫자 라벨`, `런타임 보정`
- 원인 레이어: `폰트 메트릭`, `컨트롤 구조`, `런타임 훅`
- 핵심 한 줄 요약: 업적 리스트 점수 라벨은 행 내부 자식이 아니라 전역 패턴 `ZO_Achievement%d+Points`였고, 해당 라벨만 직접 보정해서 숫자 겹침을 해결했다.

## 1. 문제 요약

TamrielKR에서 한글 UI 출력은 성공했지만, 업적 창 오른쪽 점수 숫자가 서로 겹쳐 보이는 문제가 발생했다.

대표 증상:

- 업적 리스트의 점수 숫자 `15`, `10`, `9` 등이 세로로 길게 늘어지거나 겹쳐 보였다.
- 같은 한글 폰트 계열이라도 `맑은 고딕`으로 테스트했을 때는 정상처럼 보이는 경우가 있었다.
- 그래서 단순히 “한글이 안 나오는 문제”가 아니라, **특정 점수 라벨이 사용하는 폰트 메트릭과 현재 slug 폰트 메트릭이 맞지 않는 문제**로 의심되었다.

초기 사용자 가설도 매우 중요했다.

- 굵기나 크기 차이 때문에 잘리는 것 같다.
- 업적 창 쪽에만 별도 폰트 적용이 필요할 수 있다.

결론적으로 이 방향은 절반은 맞고, 절반은 틀렸다.

- 맞았던 부분: 실제로는 점수 라벨이 원래 쓰던 대형 숫자 폰트 메트릭과 현재 slug 폰트 메트릭이 맞지 않았다.
- 틀렸던 부분: 문제 컨트롤을 처음엔 잘못 잡고 있었고, 업적 행 내부 구조를 예상한 방식으로 접근할 수 있다고 믿은 것이 오히려 시간을 많이 썼다.

## 2. 환경과 당시 구조

당시 업적 보정 로직은 단일 파일에 섞여 있었고, 최종 정리 후 현재 구현은 아래 파일에 분리되어 있다.

- `TEST/TamrielKR/Achievements.lua`

문제 당시 관련 레이어는 크게 3개였다.

1. 폰트 정의 레이어
2. 업적 UI 행 컨트롤 레이어
3. 실제 점수 라벨에 `SetFont`를 적용하는 레이어

핵심은 “조정해야 하는 진짜 대상 컨트롤이 무엇이냐”였다.

## 3. 처음 세운 가설

### 가설 1. 업적 행 내부에 `Points` 같은 자식 라벨이 있을 것이다

처음에는 일반적인 ESO 템플릿 구조를 가정했다.

- `control:GetNamedChild("Points")`
- `control:GetNamedChild("AchievementPoints")`
- `control:GetNamedChild("PointsLabel")`

이 접근은 많은 UI에서 통하지만, 이번 건에서는 핵심 타깃을 놓쳤다.

### 가설 2. `ACHIEVEMENTS` 객체의 Setup 함수에 훅을 걸면 행 컨트롤을 바로 잡을 수 있을 것이다

예상한 훅 대상:

- `ACHIEVEMENTS.SetupAchievement`
- `ACHIEVEMENTS.SetupBaseAchievement`
- `ACHIEVEMENTS.Row_Setup`
- `ACHIEVEMENTS.Refresh`
- `ACHIEVEMENTS.list.dataTypes[*].setupCallback`

이 가설도 부분적으로만 맞았다.

- 일부 환경에서는 유효할 수 있다.
- 하지만 실제 사용 중인 구조에서는 로그상 `SetupAchievement=false`, `SetupBaseAchievement=false`, `Row_Setup=false`, `Refresh=false`, `list=false`가 확인되었다.

즉, 기대한 방식으로는 핵심 진입점을 못 잡고 있었다.

### 가설 3. 같은 라벨에 ESO 기본 스타일과 TamrielKR 스타일이 중복으로 덮여서 이중 렌더링처럼 보일 수 있다

이건 충분히 의심할 만했다.

왜냐하면 화면상으로는 다음 가능성이 모두 있어 보였기 때문이다.

- 폰트 자체가 너무 큼
- 같은 라벨에 두 번 `SetFont`가 적용됨
- popup용 라벨과 row용 라벨을 혼동하고 있음
- 그림자/outline 효과 때문에 겹쳐 보임

그래서 실제로 `SetFont` 호출 흔적을 추적하는 로그를 넣었다.

## 4. 디버깅 과정

### 4.1. `/script d(ACHIEVEMENTS)` 덤프로 구조 확인

사용자가 인게임에서 `ACHIEVEMENTS` 덤프를 뽑아주었고, 여기서 중요한 단서가 나왔다.

- 일부 엔트리에 `points` 필드가 있었다.
- 하지만 화면에 보이는 행 라벨과 1:1로 대응되는 확신은 없었다.
- `dependentAnchoredAchievement`, `control`, `title`, `date`, `points` 같은 필드가 섞여 있어 구조가 생각보다 복잡했다.

이 단계의 핵심 교훈:

- 덤프에 `points`가 있다고 해서 그것이 화면의 최종 표시 라벨이라는 보장은 없다.

### 4.2. 업적 행 전체 재귀 스캔 시도

다음으로는 스크롤 자식 전체를 재귀적으로 훑어서 숫자 라벨을 찾는 방식을 넣었다.

의도:

- 행 내부 구조를 몰라도 숫자 라벨을 결국 잡아내자

문제:

- 업적 창을 열 때 프리징 발생
- 프레임이 심하게 떨어짐

원인:

- 업적 씬이 열릴 때마다 넓은 범위를 재귀 탐색
- 여기에 반복 재적용까지 겹치면서 UI 스레드 비용이 커짐

이 시도는 바로 폐기했다.

중요 교훈:

- ESO UI에서는 “보이는 컨트롤 몇 개를 정확히 잡는 방식”이 훨씬 중요하다.
- 전체 트리 재귀 탐색은 디버깅 1회 용도까지만 허용하고, 상시 로직으로 두면 안 된다.

### 4.3. popup 라벨이 진짜 타깃인지 검증

다음 로그가 결정적이었다.

```text
[TamrielKR] debug hook snapshot name=ZO_AchievementPopupAchievementPoints text= font=ZoFontCallout3
[TamrielKR] popup direct probe name=ZO_AchievementPopupAchievementPoints text= font=ZoFontCallout3
```

이 로그로 확인한 사실:

- `ZO_AchievementPopupAchievementPoints`는 실제로 존재한다.
- 폰트는 `ZoFontCallout3`를 사용한다.
- 하지만 이 라벨은 **지금 보고 있는 업적 리스트 오른쪽 점수 라벨이 아니라 popup 계열 컨트롤**이었다.

초반에 맞았다고 착각했던 대상은 실제 문제 대상이 아니었다.

### 4.4. row scan 실패 로그로 “잘못된 트리를 보고 있다”는 점 확인

다음 로그도 매우 중요했다.

```text
[TamrielKR] achievement row scan scroll=ZO_AchievementsContentsContentListScrollChild rows=0 found=0
[TamrielKR] achievement points labels were not found in row controls
```

이 로그가 의미하는 것:

- 접근한 `ZO_AchievementsContentsContentListScrollChild` 아래에서 실제 보이는 행을 기대했지만,
- 당시 시점 기준으로는 `rows=0`이었다.

즉,

- 스크롤 자식 이름은 맞더라도
- 생각한 타이밍에 자식이 아직 붙지 않았거나
- 실제 렌더 구조가 전역 컨트롤 기반으로 만들어져 있었던 것이다.

### 4.5. 진짜 정답: 전역 라벨 이름 패턴 발견

결정적인 전환점은 아래 로그였다.

```text
[TamrielKR] fix SetFont #1 name=ZO_Achievement1Points old=ZoFontCallout3 new=TamrielKR/fonts/univers47.slug30|soft-shadow-thick applied=TamrielKR/fonts/univers47.slug
[TamrielKR] fix SetFont #1 name=ZO_Achievement2Points old=ZoFontCallout3 new=TamrielKR/fonts/univers47.slug30|soft-shadow-thick applied=TamrielKR/fonts/univers47.slug
[TamrielKR] fix SetFont #1 name=ZO_Achievement3Points old=ZoFontCallout3 new=TamrielKR/fonts/univers47.slug30|soft-shadow-thick applied=TamrielKR/fonts/univers47.slug
```

여기서 드디어 확인한 사실:

- 실제 업적 리스트 점수 라벨은 행 내부 익명 자식이 아니라
- `ZO_Achievement1Points`, `ZO_Achievement2Points` 같은 **전역 라벨**이었다.

즉, 문제는 처음부터 “행 자식 탐색”보다 “전역으로 생성된 점수 라벨 패턴 탐색”으로 가는 게 정답이었다.

이 순간부터 해결 방향이 명확해졌다.

## 5. 최종 원인 정리

문제를 최종적으로 정리하면 원인은 3개였다.

### 원인 1. 타깃 컨트롤을 잘못 잡고 있었다

초기에는 popup 라벨과 row 내부 자식을 의심했지만, 실제 점수 라벨은 전역 이름 패턴 `ZO_Achievement%d+Points`로 생성되고 있었다.

### 원인 2. 점수 라벨이 `ZoFontCallout3` 계열의 큰 숫자 메트릭을 사용하고 있었다

이 라벨은 원래 큰 숫자용 폰트 메트릭을 기대한다.  
그런데 TamrielKR slug 폰트를 같은 감각으로 덮으면 다음 문제가 생긴다.

- 숫자 폭이 달라짐
- 세로 비율이 달라짐
- shadow/outline 효과가 더 두껍게 느껴짐
- 결과적으로 숫자가 겹쳐 보임

### 원인 3. 과한 재귀 탐색/반복 적용은 성능 문제를 만들었다

문제를 빨리 잡으려고 넣었던 광범위한 재귀 탐색은 실제 게임 UI에서 너무 무거웠다.

즉, 이 문제는 단순 폰트 크기 문제가 아니라,

- 잘못된 컨트롤 타깃
- 잘못된 훅 포인트
- 잘못된 탐색 전략

이 세 가지가 겹친 문제였다.

## 6. 해결 전략

최종 해결 전략은 다음과 같이 정리되었다.

### 6.1. 전역 점수 라벨을 직접 찾는다

아래 패턴으로 전역 컨트롤을 찾는다.

```lua
^ZO_Achievement%d+Points$
```

이 패턴은 스크롤 자식 탐색 실패 시에도 안정적으로 실제 점수 라벨을 잡을 수 있었다.

### 6.2. 폰트 문자열을 직접 해석하고 크기만 줄인다

점수 라벨이 이미 가진 폰트 문자열에서 다음을 분리한다.

- 파일 경로
- 크기
- 효과

그 다음:

- 파일 경로는 유지
- 크기만 비율로 축소
- 효과는 `soft-shadow-thin`으로 정리

즉 “무조건 다른 폰트로 갈아치운다”가 아니라, **현재 라벨이 쓰는 폰트 정보를 기준으로 안전하게 축소 적용**하는 방식으로 갔다.

### 6.3. 레이아웃도 함께 보정한다

폰트만 줄이는 것으로 끝내지 않고, 라벨 박스 자체도 같이 보정했다.

최종 적용값:

- width: `84`
- height: `32`
- scale: `0.9`
- size ratio: `0.44`
- min size: `18`
- max size: `24`
- anchor: 부모 기준 오른쪽 `-6`
- multiline: `false`
- max line count: `1`
- horizontal align: `RIGHT`
- vertical align: `CENTER`

이 보정이 같이 들어가야 숫자가 안정적으로 오른쪽 열에 들어간다.

### 6.4. 훅은 여러 경로로 걸되, 비용은 낮춘다

최종 구현은 아래 경로를 사용한다.

- `ACHIEVEMENTS.SetupAchievement`
- `ACHIEVEMENTS.SetupBaseAchievement`
- `ACHIEVEMENTS.Row_Setup`
- `ACHIEVEMENTS.list.dataTypes[*].setupCallback`
- `ACHIEVEMENTS.Refresh`
- achievements scene `SCENE_SHOWN`

중요한 점:

- 전체 트리 재귀 상시 스캔은 하지 않음
- 씬이 열릴 때 `10ms`, `100ms`, `300ms` 지연 적용만 수행

이렇게 해서 타이밍 문제는 피하고, 성능도 유지했다.

## 7. 현재 코드 구조

리팩터링 이후 업적 관련 최종 구현은 아래 파일에 있다.

- `TEST/TamrielKR/Achievements.lua`

핵심 함수:

- `FindAchievementPointsLabel`
- `FindPointsLabelInControlTree`
- `ResolveAchievementFontParts`
- `FixPointsLabel`
- `RefreshVisibleAchievementPoints`
- `HookAchievementUI`

이 구조 덕분에 이제 업적 관련 문제는 메인 파일 전체를 뒤질 필요 없이 이 모듈만 보면 된다.

## 8. 검증 결과

최종 단계에서 사용자가 업적 창을 다시 확인했을 때,

- 오른쪽 점수 숫자가 겹치지 않음
- `15`, `10` 등 2자리 숫자도 정상 표시
- 업적 창 열 때 프리징/프레임 드랍 문제도 제거됨

즉, 이번 이슈는 **해결 완료** 상태로 판단했다.

## 9. 이번 디버깅에서 얻은 자산

이번 세션의 진짜 자산은 단순히 “고쳤다”가 아니라, 다음 원칙이 확인된 것이다.

### 자산 1. ESO UI는 이름이 그럴듯한 자식 컨트롤보다 실제 생성 패턴을 잡는 게 더 중요하다

겉보기에는 `Points` 자식 라벨일 것 같아도, 실제로는 전역 `ZO_Achievement%d+Points`일 수 있다.

### 자산 2. popup 컨트롤과 list 컨트롤은 반드시 분리해서 검증해야 한다

`ZO_AchievementPopupAchievementPoints`가 존재한다는 사실만으로 리스트 점수 문제를 해결했다고 판단하면 안 된다.

### 자산 3. 성능 문제는 디버깅 로직에서 더 쉽게 터진다

재귀 탐색과 반복 적용은 디버깅용으로는 편하지만, 실사용 훅으로 남기면 바로 프레임 드랍으로 이어진다.

### 자산 4. 폰트 이슈는 “폰트 파일”만의 문제가 아니라 박스 폭/앵커/라인 수까지 함께 봐야 한다

특히 큰 숫자용 라벨은 다음을 한 번에 봐야 한다.

- 폰트 크기
- 폰트 효과
- 라벨 폭
- 정렬
- 스케일
- 한 줄 고정 여부

## 10. 다음에 같은 문제를 만나면

다음 순서로 바로 접근하면 된다.

1. 실제 깨지는 라벨이 popup인지 list row인지 먼저 분리한다.
2. 전역 이름 패턴이 있는지 본다.
3. `GetFont()`가 문자열인지, 폰트 오브젝트 이름인지 확인한다.
4. 폰트 크기만 줄이지 말고 width/anchor/multiline도 같이 본다.
5. 상시 재귀 스캔은 금지하고, 지연 적용 몇 번으로 끝낸다.

## 11. 부록: 당시 핵심 로그

실제 방향 전환에 도움이 된 로그만 다시 모아두면 아래와 같다.

### 실패 방향을 보여준 로그

```text
[TamrielKR] achievement points labels were not found on visible rows
[TamrielKR] achievement row scan scroll=ZO_AchievementsContentsContentListScrollChild rows=0 found=0
[TamrielKR] HookAchievementUI SetupAchievement=false SetupBaseAchievement=false Row_Setup=false Refresh=false list=false
```

의미:

- 기대한 스크롤 자식/설정 훅 경로가 실제 구조와 다르다.

### popup 오인 가능성을 보여준 로그

```text
[TamrielKR] debug hook snapshot name=ZO_AchievementPopupAchievementPoints text= font=ZoFontCallout3
[TamrielKR] popup direct probe name=ZO_AchievementPopupAchievementPoints text= font=ZoFontCallout3
```

의미:

- popup 라벨은 잡았지만, 리스트 점수 라벨 문제의 정답은 아니다.

### 실제 정답 경로를 보여준 로그

```text
[TamrielKR] fix SetFont #1 name=ZO_Achievement1Points old=ZoFontCallout3 ...
[TamrielKR] fix SetFont #1 name=ZO_Achievement2Points old=ZoFontCallout3 ...
[TamrielKR] fix SetFont #1 name=ZO_Achievement3Points old=ZoFontCallout3 ...
```

의미:

- 진짜 타깃은 `ZO_Achievement%d+Points`
- 이 순간부터 해결 경로가 확정되었다.

---

이 문서는 “업적 점수 숫자 겹침” 이슈에 한정한 디버깅 기록이다.  
채팅 CNKR 역변환, BackupFont 체인, 원본 ESO 메트릭 보존 실험은 별도 문서로 분리하는 것이 좋다.
