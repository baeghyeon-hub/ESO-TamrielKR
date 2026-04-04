# [UI/폰트] 스킬 창 행 어긋남 디버깅

작성일: 2026-03-30  
상태: 진행 중, 1차 원인 분석 및 직접 보정 완료

## 문서 메타

- 문제 유형 태그: `UI 레이아웃`, `폰트 메트릭`, `Hover Inspector`, `직접 보정`
- 원인 레이어: `폰트 메트릭`, `컨트롤 구조`, `런타임 훅`
- 핵심 한 줄 요약: 스킬 창 상단 깨짐은 `ZO_SkillsSkillInfoRank`의 메트릭 문제였고, hover 인스펙터로 실제 스타일을 식별해 직접 보정하는 방향으로 정리했다.

## 1. 문제 요약

TamrielKR 적용 후 스킬 창 상단 일부가 영문 UI와 다르게 보였다.

대표 증상:

- 스킬 라인 레벨 숫자 `49`, `50`이 세로로 찢어지거나 두 줄처럼 보임
- 숫자 라벨이 아래 행을 밀어내면서 상단 줄 전체가 어긋남
- 같은 화면 안에서도 `궁극기`, `액티브 어빌리티` 같은 헤더는 비교적 정상인데, 큰 숫자만 문제를 일으킴

이 문제는 문자열 번역이 아니라 **특정 UI 컨트롤이 기대하는 원본 폰트 메트릭과 현재 한글 폰트 체인의 메트릭이 맞지 않는 문제**였다.

## 2. 초기 가설과 실제 차이

처음에는 다음 중 하나일 가능성이 높다고 봤다.

1. 기본 UI용 한글 폰트가 전체적으로 너무 큼
2. 좁은 UI 영역은 별도 폰트가 필요함
3. 특정 화면이 폭이 매우 좁은 레이블을 쓰고 있음

방향 자체는 틀리지 않았지만, 바로 전역 폰트를 바꾸면 안 되는 이유가 있었다.

- TamrielKR의 기본 구조는 `BackupFont` 체인 기반이다.
- 따라서 `backupfont_kr.xml`에서 한 폰트 계열을 바꾸면, 그 원본 폰트를 쓰는 다른 화면도 같이 바뀐다.
- 즉 "기본 UI 폰트를 전부 더 좁은 폰트로 교체"는 영향 범위가 너무 크다.

결론적으로 이번 문제는 전역 폰트 교체보다 **문제가 나는 실제 컨트롤이나 스타일을 먼저 식별하는 작업**이 먼저였다.

## 3. 현재 폰트 구조

TamrielKR의 폰트 구조는 크게 3층으로 나뉜다.

### 3.1. 폰트 별칭 정의

파일:

- `fontstrings.xml`

정의된 주요 별칭:

- `TAMRIELKR_FUTURA_BOOK -> TamrielKR/fonts/ftn47.slug`
- `TAMRIELKR_FUTURA_MEDIUM -> TamrielKR/fonts/ftn57.slug`
- `TAMRIELKR_FUTURA_BOLD -> TamrielKR/fonts/ftn87.slug`
- `TAMRIELKR_PROSE_ANTIQUE -> TamrielKR/fonts/proseantiquepsmt.slug`
- `TAMRIELKR_UNIVERS_BOLD -> TamrielKR/fonts/univers47.slug`
- `TAMRIELKR_UNIVERS_MEDIUM -> TamrielKR/fonts/univers55.slug`
- `TAMRIELKR_UNIVERS_CONDENSED -> TamrielKR/fonts/univers57.slug`

### 3.2. BackupFont 체인

파일:

- `backupfont_kr.xml`

핵심 매핑:

- `TamrielKR/fonts/univers47.slug -> TamrielKR/fonts/kr_gothic_bold.slug`
- `TamrielKR/fonts/univers55.slug -> TamrielKR/fonts/kr_maruburi.slug`
- `TamrielKR/fonts/univers57.slug -> TamrielKR/fonts/kr_gothic.slug`

원본 ESO 폰트와 직접 연결되는 부분도 있다.

- `$(BOLD_FONT) -> kr_gothic_bold`
- `$(UNIVERS67_FONT) -> kr_gothic_bold`
- `$(UNIVERS55_FONT) -> kr_maruburi`
- `$(MEDIUM_FONT) -> kr_gothic`
- `$(UNIVERS57_FONT) -> kr_gothic`

즉, `BackupFont`는 "문제 나는 화면만" 따로 바꾸는 방식이 아니라 **원본 폰트 계열 전체**에 영향을 준다.

### 3.3. 런타임 예외 적용

파일:

- `Fonts.lua`
- `Achievements.lua`
- `Skills.lua`

현재 런타임에서 별도로 만지는 영역:

- SCT
- 네임플레이트
- Tribute
- 툴팁
- 업적 점수 라벨
- 스킬 창 상단 랭크 라벨

이 계층은 전역 `BackupFont`와 달리 **특정 컨트롤만 직접 보정**할 수 있다.

## 4. 왜 hover 폰트 인스펙터가 필요했나

문제의 핵심은 "어떤 화면이 깨지느냐"가 아니라 **정확히 어느 컨트롤이 어떤 폰트 스타일을 쓰는지** 알아야 한다는 점이었다.

처음에는 스킬 창 보정을 추측 기반으로 시도했다.

- 숫자만 있는 큰 레이블을 전역 스캔
- 이름에 `rank`, `level`, `skill` 같은 문자열이 들어가면 후보로 간주
- 폰트 크기가 크면 일괄 보정

이 방식은 다음 한계가 있었다.

- 실제 대상이 아닌 다른 숫자 레이블을 건드릴 수 있음
- 컨테이너와 실제 텍스트 라벨을 구분하지 못함
- 화면에 따라 이름 규칙이 일정하지 않음
- 디버깅 시간이 길어짐

그래서 **마우스 오버한 UI의 실제 폰트 정보를 보여주는 별도 디버그 애드온**을 만들었다.

## 5. Hover Font Inspector 애드온 제작

애드온 경로:

- `tools/TamrielKRFontInspector`
- 라이브 설치 경로: `live/AddOns/TamrielKRFontInspector`
- 패키지 경로: `Addon PATCHES/TamrielKRFontInspector`

구성 파일:

- `TamrielKRFontInspector.txt`
- `TamrielKRFontInspector.lua`
- `README.md`

### 5.1. 설계 목표

최소한 아래 정보는 즉시 볼 수 있어야 했다.

- 현재 hover된 컨트롤 이름
- 컨트롤 텍스트
- `GetFont()` 결과
- 가능하면 `GetFontInfo()`로 풀린 실제 파일, 크기, 효과
- 부모 체인
- 컨트롤 생성 소스 정보
- 현재 컨트롤 하이라이트

### 5.2. 사용한 API

이번 애드온에서 사용한 핵심 API는 아래와 같다.

- `WINDOW_MANAGER:GetMouseOverControl()`
- `control:GetText()`
- `control:GetFont()`
- `fontObject:GetFontInfo()`
- `control:GetNumChildren()`
- `control:GetChild(index)`
- `control:GetDimensions()`
- `control:GetTextDimensions()`
- `GetControlCreatingSourceName(control)`
- `GetControlCreatingSourceCallSiteInfo(control)`

### 5.3. 첫 번째 버전의 한계

첫 번째 버전은 hover된 컨트롤 자신만 분석했다.

하지만 스킬 창에서는 `ZO_SkillsSkillInfo` 같은 **컨테이너**가 잡히고,
실제 텍스트 라벨은 그 내부 자식 컨트롤이었다.

그래서 다음처럼 보였다.

- `Text: <none>`
- `Font ref: <none>`
- `Font file: <unknown>`

즉 애드온이 실패한 것이 아니라, **내가 보고 싶은 대상이 부모 컨테이너 안쪽에 숨어 있었던 것**이다.

### 5.4. 두 번째 버전 개선

이 문제를 해결하기 위해 인스펙터를 확장했다.

추가 기능:

- hover된 컨트롤의 자식 트리를 제한 깊이까지 스캔
- 텍스트가 있거나 폰트가 있는 자식 컨트롤을 후보로 추출
- `Descendant font candidates` 섹션으로 표시

이 개선으로 부모 컨테이너만 잡히는 화면에서도 실제 라벨 후보를 확인할 수 있게 되었다.

### 5.5. 애드온 명령어

- `/tkfi`
- `/tkfi on`
- `/tkfi off`
- `/tkfi freeze`
- `/tkfi dump`

`freeze`는 현재 대상을 고정하고, `dump`는 채팅창으로 현재 분석 결과를 출력한다.

## 6. 스킬 창에서 실제로 잡힌 결과

### 6.1. 상단 정보 영역

`ZO_SkillsSkillInfo` 컨테이너를 hover했을 때 내부 후보가 다음처럼 확인되었다.

- `ZO_SkillsSkillInfoRank`
  - text=`49`
  - font=`ZoFontCallout3`
  - file=`TamrielKR/fonts/univers47.slug`
  - size=`54`
  - effect=`soft-shadow-thick`
- `ZO_SkillsSkillInfoName`
  - text=`동물 동료`
  - font=`ZoFontHeader2`
  - file=`TamrielKR/fonts/univers47.slug`
  - size=`20`
  - effect=`soft-shadow-thick`

이 결과로 확인된 사실:

- 문제의 핵심은 큰 숫자 라벨 `ZO_SkillsSkillInfoRank`
- 이름 라벨도 같은 계열을 쓰지만, 실제로 깨지는 것은 숫자 라벨 쪽
- 적어도 이 구간은 `univers47.slug` 계열을 타고 있음

### 6.2. 오른쪽 스킬 리스트 영역

`ZO_SkillsSkillListContents` 계열을 hover했을 때 다음 후보가 확인되었다.

- `ZO_SkillsSkillList2Row1Label`
  - text=`궁극기`
  - font=`ZoFontHeader2`
  - file=`TamrielKR/fonts/univers47.slug`
  - size=`20`
- `ZO_SkillsSkillList2Row1Name`
  - text=`Eternal Guardian IV`
  - font=`ZoFontGameLargeBold`
  - file=`TamrielKR/fonts/univers47.slug`
  - size=`18`
- `ZO_SkillsSkillList2Row2Label`
  - text=`액티브 어빌리티`
  - font=`ZoFontHeader2`
  - file=`TamrielKR/fonts/univers47.slug`
  - size=`20`
- `ZO_SkillsSkillList1Row2Name`
  - text=`Screaming Cliff Racer IV`
  - font=`ZoFontGameLargeBold`
  - file=`TamrielKR/fonts/univers47.slug`
  - size=`18`

이 부분은 시각적으로 행 정렬이 괜찮았고, 실제로 별도 보정이 필요하지 않았다.

## 7. 현재 원인 정리

이번 단계에서 확인된 원인은 아래와 같다.

### 원인 1. 문제는 스킬 창 전체가 아니라 특정 라벨에 집중되어 있었다

영역 전체가 망가진 것이 아니라, 상단의 큰 랭크 숫자 라벨 하나가 레이아웃을 밀어내고 있었다.

### 원인 2. hover 대상과 실제 텍스트 라벨이 달랐다

겉으로 보이는 영역을 hover해도 실제 라벨이 아니라 부모 컨테이너가 먼저 잡혔다.
그래서 자식 탐색 기능이 없는 디버거로는 정확한 폰트 대상을 파악할 수 없었다.

### 원인 3. `BackupFont`는 최종 glyph fallback 경로를 직접 보여주지 않는다

인스펙터에서 확인 가능한 것은 다음까지다.

- 컨트롤이 참조하는 스타일 이름
- 스타일이 가리키는 원본 폰트 파일

하지만 "한글 글리프가 최종적으로 어느 backup slug로 떨어졌는지"는 API가 바로 주지 않는다.

즉 최종 해석은 항상:

1. 인스펙터 출력 확인
2. `backupfont_kr.xml`에서 매핑 확인

이 2단계로 해야 한다.

## 8. 스킬 창 보정 방식 변경

초기 스킬 보정은 전역 스캔 방식이었다.

- 큰 폰트
- 숫자만 있는 레이블
- 이름이나 부모 이름에 `rank`, `level`, `skill`이 들어가는지 확인

이 방식은 정확도가 낮았다.

그래서 현재는 실제로 확인된 컨트롤 이름을 직접 대상으로 바꿨다.

파일:

- `Skills.lua`

현재 직접 보정 대상:

- `ZO_SkillsSkillInfoRank`
- `ZO_SkillsSkillInfoName`

### 8.1. `ZO_SkillsSkillInfoRank` 보정

현재 보정 내용:

- 폭 고정: `84`
- 높이 고정: `72`
- 단일 행 강제
- 가운데 정렬
- 현재 폰트 정보를 읽은 뒤, 크기만 `0.92` 비율로 축소

핵심 아이디어는 "다른 폰트로 완전히 갈아치우는 것"이 아니라 **원래 쓰이던 스타일의 계열은 유지하되 크기와 박스만 보정하는 것**이다.

이 방식으로 큰 숫자 `49`, `50`이 두 줄로 찢어지는 문제는 해소되었다.

### 8.2. `ZO_SkillsSkillInfoName` 보정

이름 라벨은 문제 정도가 약했기 때문에 보정은 최소화했다.

- 단일 행 강제
- 필요 시 최소 폭 확보

현재 확인된 기준으로는 이 정도면 충분하다.

## 9. 이번 작업으로 얻은 결론

### 결론 1. "좁은 UI만 따로 폰트"는 가능하다

다만 방식은 두 가지로 나뉜다.

- 특정 스타일 계열만 따로 매핑
- 문제 컨트롤만 직접 `SetFont` 보정

### 결론 2. 지금은 전역 교체보다 직접 보정이 더 안전하다

이번 스킬 창처럼 문제가 한두 개 라벨에 집중된 경우에는
전역 `BackupFont`를 건드리는 것보다 해당 컨트롤만 고치는 쪽이 훨씬 안전하다.

### 결론 3. 스타일/컨트롤 식별 없이 폰트만 바꾸는 접근은 위험하다

같은 `univers47.slug` 계열을 많은 화면이 공유할 수 있기 때문에,
원인 컨트롤을 식별하지 않고 `univers47` 전체 fallback을 바꾸면 다른 UI가 연쇄적으로 달라질 수 있다.

## 10. 앞으로 비슷한 문제를 만났을 때 작업 순서

1. `TamrielKRFontInspector`를 켠다.
2. 문제 구간을 hover해서 부모 컨트롤과 자식 후보를 본다.
3. 실제 문제 라벨의 이름과 스타일을 기록한다.
4. 먼저 컨트롤 단위 보정을 시도한다.
5. 같은 스타일이 여러 화면에서 반복적으로 깨질 때만 스타일 단위 또는 `BackupFont` 계층 조정을 검토한다.

## 11. 관련 파일

디버그 애드온:

- `tools/TamrielKRFontInspector/TamrielKRFontInspector.lua`
- `tools/TamrielKRFontInspector/TamrielKRFontInspector.txt`
- `tools/TamrielKRFontInspector/README.md`

현재 스킬 창 보정:

- `Skills.lua`

폰트 정의:

- `fontstrings.xml`
- `backupfont_kr.xml`
- `Fonts.lua`

참고 문서:

- `DOCS/ui-font-achievement-points.md`

---

이 문서는 스킬 UI 행 어긋남 문제를 추적하면서
"전역 폰트 교체" 대신 "실제 컨트롤 식별 -> hover 인스펙터 분석 -> 직접 보정" 흐름으로 정리한 작업 기록이다.
