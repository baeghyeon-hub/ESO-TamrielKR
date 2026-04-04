# TamrielKR 문서 허브

TamrielKR 문서는 `문제 유형 태그`, `원인 레이어`, `핵심 한 줄 요약`을 기준으로 정리한다.  
문서를 찾을 때는 먼저 문제를 분류하고, 그다음 해당 레이어 문서를 보면 된다.

## 분류 기준

### 문제 유형 태그

- `UI 레이아웃`: 글자 겹침, 줄바꿈, 정렬, 잘림 문제
- `폰트 메트릭`: 같은 스타일인데도 한글/숫자 조합에 따라 폭과 높이 감각이 달라지는 문제
- `CNKR`: EsoKR 계열 CJK 우회 인코딩과의 호환 문제
- `애드온 호환`: 영문 애드온이 `GetCVar`, `$(language)` 구조 때문에 한국어 로딩에 실패하는 문제
- `Hover Inspector`: 실제 컨트롤과 폰트 스타일을 추적하기 위한 디버그 도구

### 원인 레이어

- `엔진 로딩`: `$(language)` 확장, `.str/.lang`, `BackupFont`처럼 Lua 이전에 결정되는 레이어
- `Lua 호환`: `GetCVar`, 초기화 순서, 애드온 로직처럼 후킹으로 조정 가능한 레이어
- `문자열 인코딩`: CJK 우회 코드, UTF-8, 디코딩 경로 문제
- `컨트롤 구조`: 실제 UI 컨트롤 이름, 부모/자식 구조, 전역 컨트롤 패턴 문제
- `후킹 시점`: 화면 생성 직후에 먹여야 하는지, 나중 보정으로 충분한지에 대한 문제
- `폰트 메트릭`: 같은 박스에서도 글자 조합별 폭 차이가 생기는 문제

## 권장 읽기 순서

1. [애드온 언어 호환성 해결](./compat-language-addons.md)
2. [채팅 CNKR/한글 디코딩](./compat-cnkr-chat.md)
3. [길드 UI CNKR/한글 디코딩](./compat-cnkr-guild-ui.md)
4. [업적 창 숫자 겹침 디버깅](./ui-font-achievement-points.md)
5. [스킬 창 레이아웃 디버깅](./ui-font-skills.md)
6. [길드 로스터 숫자 컬럼 정렬 디버깅](./ui-font-guild-roster.md)
7. [길드 명부·계급 CNKR/한글 디코딩](./compat-cnkr-guild-roster-ranks.md)
8. [BackupFont 체이닝과 특수문자 □ 렌더링](./font-backupfont-chain.md)

## 문서 목록

### UI / 폰트

- [업적 창 숫자 겹침 디버깅](./ui-font-achievement-points.md)  
상태: 해결 완료  
문제 유형 태그: `UI 레이아웃`, `폰트 메트릭`, `숫자 라벨`, `후킹 보정`  
원인 레이어: `폰트 메트릭`, `컨트롤 구조`, `후킹 시점`  
핵심 요약: 업적 리스트 점수 라벨은 전역 패턴 `ZO_Achievement%d+Points`를 직접 보정해야 안정적으로 해결된다.

- [스킬 창 레이아웃 디버깅](./ui-font-skills.md)  
상태: 1차 분석 및 직접 보정 완료  
문제 유형 태그: `UI 레이아웃`, `폰트 메트릭`, `Hover Inspector`, `직접 보정`  
원인 레이어: `폰트 메트릭`, `컨트롤 구조`, `후킹 시점`  
핵심 요약: 스킬 창 상단 큰 숫자는 `ZO_SkillsSkillInfoRank` 한 개 컨트롤을 직접 보정하는 방식이 가장 안전하다.

- [길드 로스터 숫자 컬럼 정렬 디버깅](./ui-font-guild-roster.md)  
상태: 해결 완료  
문제 유형 태그: `UI 레이아웃`, `폰트 메트릭`, `Hover Inspector`, `숫자 컬럼`, `초기화 시점`  
원인 레이어: `폰트 메트릭`, `컨트롤 구조`, `후킹 시점`  
핵심 요약: 길드 로스터 `Level` 컬럼은 기본 `45x20`이 경계값이라 숫자 조합에 따라 잘렸고, `SetupRow` 후킹과 fresh session 검증으로 해결됐다.

### 폰트 / 엔진

- [BackupFont 체이닝과 특수문자 □ 렌더링](./font-backupfont-chain.md)
상태: 해결 완료
문제 유형 태그: `폰트 메트릭`, `BackupFont`, `slug 변환`, `특수문자`, `유니코드 커버리지`
원인 레이어: `엔진 로딩`, `폰트 메트릭`
핵심 요약: slug 폰트의 BackupFont가 한글 전용 폰트로만 연결되어 있어 특수 유니코드 심볼이 □로 렌더링됐고, 폴백 순서를 ESO 원본 우선으로 뒤집어 해결을 시도 중이다.

### 호환성 / 언어

- [애드온 언어 호환성 해결](./compat-language-addons.md)  
상태: 해결 완료  
문제 유형 태그: `애드온 호환`, `언어 감지`, `GetCVar`, `$(language)`, `후킹`  
원인 레이어: `엔진 로딩`, `Lua 호환`, `후킹 시점`  
핵심 요약: TamrielKR은 엔진에는 `kr`를 유지하면서 Lua에는 `en`을 돌려주는 구조로 영문 애드온과 공존한다.

### 호환성 / CNKR

- [채팅 CNKR/한글 디코딩](./compat-cnkr-chat.md)  
상태: 해결 완료  
문제 유형 태그: `채팅`, `CNKR`, `EsoKR 호환`, `문자열 디코딩`  
원인 레이어: `문자열 인코딩`, `채팅 파이프라인`, `호환성`  
핵심 요약: 구형 EsoKR 사용자와 섞여도 채팅이 읽히도록 CNKR 문자열을 채팅 경로에서만 복원한다.

- [길드 UI CNKR/한글 디코딩](./compat-cnkr-guild-ui.md)
상태: 해결 완료
문제 유형 태그: `길드 UI`, `CNKR`, `API 값`, `컨트롤 텍스트`
원인 레이어: `문자열 인코딩`, `API 반환값`, `UI 바인딩`
핵심 요약: 길드 MOTD와 소개말은 채팅 경로가 아니라 별도 API/UI 경로를 쓰므로 별도 복원이 필요하다.

- [길드 명부·계급 CNKR/한글 디코딩](./compat-cnkr-guild-roster-ranks.md)
상태: 해결 완료
문제 유형 태그: `길드 UI`, `CNKR`, `API 훅`, `복수 반환값`, `컨트롤 트리 스캔`
원인 레이어: `문자열 인코딩`, `API 반환값`, `UI 바인딩`
핵심 요약: 길드 명부 멤버 정보와 계급 이름은 MOTD/소개말과 다른 API 경로를 사용하므로, 복수 반환값 래핑으로 확장했다.

## 빠른 탐색 가이드

- 영문 애드온이 `English only`, `missing kr file`로 실패하면: [애드온 언어 호환성 해결](./compat-language-addons.md)
- 채팅에서 예전 중국어 우회 문자열이 보이면: [채팅 CNKR/한글 디코딩](./compat-cnkr-chat.md)
- 길드 MOTD, 소개말만 깨지면: [길드 UI CNKR/한글 디코딩](./compat-cnkr-guild-ui.md)
- 숫자 라벨이나 헤더가 겹치면: [업적 창 숫자 겹침 디버깅](./ui-font-achievement-points.md), [스킬 창 레이아웃 디버깅](./ui-font-skills.md), [길드 로스터 숫자 컬럼 정렬 디버깅](./ui-font-guild-roster.md)
- 특수문자(영문 특수기호 등)가 □로 깨지면: [BackupFont 체이닝과 특수문자 □ 렌더링](./font-backupfont-chain.md)
