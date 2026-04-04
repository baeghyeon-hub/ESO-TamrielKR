# Azurah KR Minion Patch

이 패키지는 `Azurah` 원본 폴더를 직접 교체하는 "덮어쓰기용" 한국어 패치입니다.

## 왜 별도 런타임 애드온이 아닌가

`Azurah`는 로드 초기에 아래처럼 로케일을 즉시 고정합니다.

- `Core.lua`: `local L = Azurah:GetLocale()`
- `Settings.lua`: `local L = Azurah:GetLocale()`
- `Unlock.lua`: `local L = Azurah:GetLocale()`
- `Thievery.lua`: `local L = Azurah:GetLocale()`

즉, 원본이 먼저 로드된 뒤에 별도 KR 애드온이 나중에 들어와 `Azurah.GetLocale`만 바꿔도 이미 늦습니다.
그래서 `Minion` 기준으로는 원본 `Azurah` 폴더 안에

- `Azurah.txt`
- `Locales/Korean_kr.lua`

를 직접 덮어쓰는 패치 패키지가 가장 안정적입니다.

## 포함 파일

- `Azurah/Azurah.txt`
- `Azurah/Locales/Korean_kr.lua`

## 설치 방식

압축본 `Azurah-KR-Minion.zip` 안의 루트는 `Azurah` 폴더입니다.

이 zip을 기준으로 설치하면 기존 `Azurah` 폴더의 같은 경로 파일만 덮어씁니다.

## 주의

`Azurah`가 업데이트되면 `Azurah.txt`가 원본으로 되돌아갈 수 있으니, 업데이트 후에는 이 KR 패치를 다시 적용해야 합니다.
