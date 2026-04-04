# LostTreasure KR Minion Patch

이 패키지는 `LostTreasure` 원본 폴더에 덮어쓰는 한국어 패치입니다.

## 포함 파일

- `LostTreasure/lang/kr.lua`

## 설치 방식

압축본 또는 이 폴더 안의 `LostTreasure` 폴더를 원본 애드온 폴더 위에 그대로 덮어쓰면 됩니다.

## 메모

- 원본 매니페스트의 `lang/$(language).lua` 구조를 그대로 사용합니다.
- 애드온 제목 `Lost Treasure`는 영문으로 유지하고, 옵션/툴팁/알림 문자열만 한국어로 덮어씁니다.
- 화면의 `Account-wide Settings` 항목은 `LibSavedVars` 공용 문자열이므로 별도 `LibSavedVars-KR-Minion` 패치에서 함께 처리합니다.
