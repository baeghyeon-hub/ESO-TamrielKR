# pChat Korean Patch

덮어쓰기용 한국어 패치입니다.

## 대상 애드온
- `pChat`

## 포함 파일
- `pChat/i18n/kr.lua`

## 적용 방법
1. `pChat` 원본 애드온이 설치되어 있어야 합니다.
2. 이 패치의 `pChat` 폴더를 ESO `live/AddOns` 경로에 그대로 덮어씁니다.
3. 게임에서 `/reloadui`를 실행합니다.

## 메모
- `pChat.txt`가 이미 `i18n/$(language).lua`를 로드하므로 `kr.lua`만 추가해도 한국어 로케일이 붙습니다.
- `DOCS/addon-language-compatibility.md` 기준으로, 이번 패치는 Lua `GetCVar` 훅 수정 없이 엔진 레벨 언어 파일 추가 방식으로 작업했습니다.
