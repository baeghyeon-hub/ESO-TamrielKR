# USPF Korean Patch

덮어쓰기용 한국어 패치입니다.

## 대상 애드온
- `USPF` (Urich's Skill Point Finder)

## 포함 파일
- `USPF/lang/kr.lua`
- `USPF/lang/strings.lua`
- `USPF/USPF.lua`
- `USPF/USPF_Menu.lua`

## 적용 방법
1. `USPF` 원본 애드온이 설치되어 있어야 합니다.
2. 이 패치의 `USPF` 폴더를 ESO `live/AddOns` 경로에 그대로 덮어씁니다.
3. 게임에서 `/reloadui`를 실행합니다.

## 메모
- `USPF.txt`가 `lang/$(language).lua`를 로드하므로 `kr.lua`를 추가하면 한국어 문자열이 붙습니다.
- 이번 패치는 정렬 드롭다운 선택지, 설정창 제목, 캐릭터 선택 툴팁, 키바인드 이름 같은 하드코딩 영문도 함께 한국어화합니다.
