# Action Duration Reminder KR Minion Patch

이 패키지는 `ActionDurationReminder` 원본 폴더에 덮어쓰는 한국어 패치입니다.

## 포함 파일

- `ActionDurationReminder/i18n/kr.lua`

## 설치 방식

압축본 또는 이 폴더 안의 `ActionDurationReminder` 폴더를 원본 애드온 폴더 위에 그대로 덮어쓰면 됩니다.

## 메모

- 원본 매니페스트의 `i18n/$(language).lua` 로딩 구조를 그대로 사용합니다.
- `kr.lua`는 메뉴/툴팁만 한국어로 바꾸고, 애드온 목록 제목은 원래 영문 `Action Duration Reminder`를 유지합니다.
- `ActionDurationReminder`는 알파벳상 TamrielKR보다 먼저 로드되므로, `language.2 = kr` 환경에서 `kr.lua`가 직접 로드됩니다.
