# DolgubonsLazyWritCreator KR Minion Patch

`DolgubonsLazyWritCreator`용 한국어 패치입니다.

## 포함 파일

- `DolgubonsLazyWritCreator/Languages/kr.lua`

## 적용 방식

원본 애드온의 `DolgubonsLazyWritCreator/Languages/` 폴더에 `kr.lua`를 추가하면 됩니다.

## 메모

- 이 애드온은 manifest에서 `Languages/$(language).lua`를 직접 읽으므로 별도 manifest 수정은 필요하지 않습니다.
- 기존 EsoKR용 한국어 패치의 기능 핵심 문자열을 TamrielKR/native UTF-8 기준으로 옮긴 버전입니다.
- 설정 메뉴 문자열은 원본 `default.lua`의 영어 fallback을 주로 유지하지만, 의뢰 인식, 제작, 제작대, 보상상자 같은 기능 핵심 문자열은 한국어로 맞췄습니다.
