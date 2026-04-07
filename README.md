# TamrielKR

ESO(The Elder Scrolls Online) 네이티브 한글 패치 애드온

기존 한글패치(EsoKR)와 달리 **CJK 코드포인트 우회 없이 네이티브 UTF-8 한글**을 사용합니다.

---

## 기존 한글패치(EsoKR)와의 차이

### 네이티브 한글 렌더링

| | EsoKR (기존) | TamrielKR |
|---|---|---|
| 한글 처리 | UTF-8 → CJK 코드포인트 변환 | **네이티브 UTF-8 한글** |
| 폰트 | 단일 폰트, 단방향 매핑 | 마루부리/잘난체, **양방향 BackupFont 체이닝** |
| 영문 애드온 호환 | 영문 클라 전환 필요 | **한글 클라에서 정상 동작** |
| UI 패치 | 폰트 교체만 | 스킬/길드 등 **한글 깨짐 UI 개별 수정** |
| 서드파티 애드온 한글화 | 불가 | **가능** |

EsoKR은 한글 유니코드를 중국어(CJK) 코드포인트로 변환해서 표시합니다. ESO 엔진이 공식적으로 한국어를 지원한 적이 없기 때문에, 이미 엔진에 구현되어 있던 중국어 렌더링 경로를 활용하는 방식이었습니다. **EsoKR 팀이 이 방식을 선택한 건 당시로서는 유일한 선택지였기 때문입니다:**

| 시기 | ESO 업데이트 | 추가된 기능 |
|---|---|---|
| **2020년 2월** | Update 25 | `<BackupFont>` XML 글리프 폴백 기능 추가 |
| **2024년 3월** | Update 41 | Slug 폰트 시스템 도입, `slugfont.exe` 클라이언트에 포함 |

EsoKR이 처음 만들어질 당시에는 slugfont.exe를 통한 커스텀 폰트 생성이 불가능했습니다. 중국어 폰트 경로에 한글을 매핑하는 CJK 우회가 한글을 표시할 수 있는 사실상 유일한 방법이었고, 이 기반 패치가 있었기에 ESO 한글패치가 유지될 수 있었습니다.

TamrielKR은 BackupFont 체이닝(2020)과 이후 추가된 Slug 폰트 시스템(2024) 덕분에 가능해진 방식입니다. 네이티브 UTF-8 한글을 그대로 사용하면서, `GetCVar` 후킹으로 다른 애드온에는 영문 클라(`"en"`)로 인식시킵니다. 덕분에 **한글 클라 상태에서 TTC 등 영문 애드온이 정상 동작**하고, 영문 애드온의 한글 번역 패치도 가능해졌습니다.

### 왜 네이티브 UTF-8이 더 좋은가?

"어차피 한글 잘 보이면 되는 거 아닌가?"라고 생각할 수 있지만, CJK 우회 방식은 근본적인 한계가 있습니다:

**CJK 우회 방식의 문제점:**
- ESO 엔진이 언어를 `"kr"`이 아닌 사실상 중국어로 인식 → **영문 전용 애드온(TTC 등)이 작동 불가**, 매번 영문 클라로 전환해야 함
- 한글이 중국어 코드포인트에 매핑되어 있으므로 **다른 애드온에서 한글 텍스트를 읽거나 가공할 수 없음** → 애드온 한글 번역 패치 자체가 불가능
- 채팅/길드 메모 등에서 한글을 보내면 상대방도 같은 CJK 매핑 패치가 있어야 읽을 수 있음

**네이티브 UTF-8 방식의 이점:**
- ESO 엔진에는 `"kr"`, 다른 애드온에는 `"en"` → **TTC, BanditsUI 등 영문 애드온이 한글 클라에서 정상 동작**
- 한글이 표준 유니코드 그대로이므로 **어떤 애드온이든 한글 텍스트를 읽고 가공 가능** → 서드파티 애드온 한글 번역 패치가 가능
- 표준 인코딩이므로 **채팅 복사, 검색, 외부 도구 연동** 등이 자연스럽게 동작
- 영문 클라 전환 없이 **한글 클라 하나로 모든 작업 가능**

한마디로, CJK 우회는 "화면에 한글이 보이게 하는 것"까지만 해결하고, 네이티브 UTF-8은 "한글이 ESO 생태계 전체에서 자연스럽게 동작하는 것"을 해결합니다.

### 영문 애드온 호환 원리

ESO에서 `language.2` CVar를 읽는 경로는 두 가지입니다:

**1. C++ 엔진 레벨** — 애드온 매니페스트의 `$(language)` 확장

```
backupfont_$(language).xml  →  backupfont_kr.xml (TamrielKR 제공)
```

엔진은 실제 CVar `"kr"`을 사용해 한글 리소스를 정상 로드합니다.

**2. Lua 레벨** — 애드온 코드의 `GetCVar("language.2")` 호출

```lua
-- TamrielKR Core.lua
GetCVar = function(cvar)
  if cvar == "language.2" then
    return "en"  -- 다른 애드온에는 영문으로 보임
  end
  return realGetCVar(cvar)
end
```

| 호출자 | 반환값 | 결과 |
|---|---|---|
| ESO 엔진 (C++) | `"kr"` | 한글 리소스 로드 |
| TamrielKR 내부 | `"kr"` (원본 함수) | 한글 모드 인식 |
| TTC 등 다른 애드온 | `"en"` (후킹) | 영문 전용 애드온 정상 동작 |

### TTC(Tamriel Trade Centre) 지원

TTC는 `$(language)` 기반 파일 로드를 사용합니다. 한글 클라에서 TTC가 동작하려면 kr 파일이 필요합니다:

```
ItemLookUpTable_EN.lua  →  ItemLookUpTable_kr.lua (복사)
lang\en.lua             →  lang\kr.lua (최초 1회 생성)
```

`sync-to-live-addons.ps1`을 실행하면 이 파일이 자동으로 생성됩니다.

### EsoKR 유저와의 채팅 호환

TamrielKR_Bridge 애드온이 EsoKR(CJK 인코딩)과 TamrielKR(네이티브 한글) 간 채팅 메시지를 자동 변환합니다. EsoKR 유저와 TamrielKR 유저가 같은 길드/채팅에서 한글로 소통할 수 있습니다.

---

## 스크린샷

### TTC 한글 클라 정상 동작
![TTC 설정](screenshot/1.png)

### 캐릭터 정보 한글 UI
![캐릭터 정보](screenshot/2.png)

### 인벤토리 + TTC 가격 정보
![인벤토리](screenshot/3.png)

---

## 설치 방법

1. **[최신 릴리즈 다운로드 (TamrielKR-release.zip)](https://github.com/baeghyeon-hub/ESO-TamrielKR/releases/download/v1.0.6/TamrielKR-release.zip)**
2. 압축 해제 후 3개 폴더를 ESO 애드온 폴더에 복사:

```
TamrielKR-release.zip
├── TamrielKR/           →  AddOns\TamrielKR\
├── TamrielKR_Bridge/    →  AddOns\TamrielKR_Bridge\
└── EsoUI/lang/          →  AddOns\EsoUI\lang\
```

복사 경로:
```
C:\Users\<사용자>\Documents\Elder Scrolls Online\live\AddOns\
```

3. **게임 번역 데이터** (`gamedata/lang/kr.lang`)는 본 패치에 포함되어 있지 않습니다.

   > `kr.lang`은 기존 EsoKR 번역팀이 오랫동안 작업해온 번역 데이터이며, ESO 업데이트 주기마다 새로 갱신되고 있습니다. TamrielKR은 폰트/UI 패치만 담당하며, 번역 데이터는 **EsoKR 팀이 배포하는 kr.lang 파일을 직접 받아서 사용**해야 합니다.
   >
   > TamrielKR은 **CNKR(CJK 인코딩) 방식의 kr.lang과 UTF-8 방식의 kr.lang 모두 호환**됩니다.
   > 모든 slug 폰트에 CNKR 매핑이 포함되어 있어, 기존 EsoKR용 kr.lang을 변환 없이 그대로 사용할 수 있습니다.

   **UTF-8 변환 (선택사항):**
   CJK 인코딩된 kr.lang을 UTF-8로 변환하면 캐릭터 선택 화면 등에서 더 깨끗한 렌더링을 얻을 수 있습니다.

   1. [Releases](https://github.com/baeghyeon-hub/ESO-TamrielKR/releases)에서 `convert_cnkr_to_utf8.zip` 다운로드
   2. 압축 해제 후 같은 폴더에 EsoKR용 `kr.lang` 파일을 넣기
   3. `convert_cnkr_to_utf8.bat` 실행 (더블클릭)
   4. 변환된 `kr.lang`을 `AddOns\gamedata\lang\`에 복사

4. 게임 실행 후 애드온 목록에서 TamrielKR, TamrielKR_Bridge 활성화

### 빠른 배포 (개발용)

```powershell
.\sync-to-live-addons.ps1
```

---

## 기능

### 한/영 전환
- 인게임 국기 UI 클릭으로 한글/영문 전환
- **단축키 지원**: 설정 → Addon Keybinds → TamrielKR에서 원하는 키 바인딩

### 폰트
| 용도 | 폰트 |
|---|---|
| 일반 UI / 채팅 | 마루 부리 Bold |
| 타이틀 / 강조 | 여기어때 잘난체 |

slug 재생성이 필요하면:

```bat
tools\generate_slugs.bat "C:\...\game\client\slugfont.exe"
```

### UI 수정
| 대상 | 수정 내용 |
|---|---|
| 스킬 서브클래싱 | 랭크 숫자 겹침 수정 (높이/폰트 크기 조정) |
| 길드 로스터 | 보호함수(Disconnect 등) 접근 에러 수정 |

---

## 서드파티 애드온 한글 패치

현재 GitHub 릴리즈 [addon-patches-v1.0.0](https://github.com/baeghyeon-hub/ESO-TamrielKR/releases/tag/addon-patches-v1.0.0) 에는 `오버라이트가 필요한 패치`만 먼저 올립니다.

이 방식이 필요한 이유:
- 일부 애드온은 설정/UI 초기화 파일을 직접 수정해야 해서, 별도 `-KR` 의존성 애드온으로 분리하면 로드 순서 문제나 재초기화 문제로 깨질 수 있습니다.
- 이런 애드온은 현재 기준으로 `원본 애드온 폴더에 직접 덮어쓰기`가 가장 안전합니다.

### 오버라이트 전용 다운로드

설치 순서:
- 기존에 설치해 둔 해당 애드온 폴더가 있으면 먼저 삭제합니다.
- 원본 애드온 최신 버전을 다시 받아 `AddOns\` 폴더에 새로 설치합니다.
- 아래 KR 패치 zip을 받아 압축 해제 후, 같은 이름의 원본 애드온 폴더에 덮어씁니다.

| 애드온 | 설명 |
|---|---|
| [BanditsUserInterface](https://github.com/baeghyeon-hub/ESO-TamrielKR/releases/download/addon-patches-v1.0.0/BanditsUserInterface-KR-Overwrite.zip) | 올인원 UI 개선 |
| [FancyActionBar+](https://github.com/baeghyeon-hub/ESO-TamrielKR/releases/download/addon-patches-v1.0.0/FancyActionBarPlus-KR-Overwrite.zip) | 액션바 강화 |
| [LibAddonMenu-2.0](https://github.com/baeghyeon-hub/ESO-TamrielKR/releases/download/addon-patches-v1.0.0/LibAddonMenu-2.0-KR-Overwrite.zip) | 애드온 설정 메뉴 라이브러리 |
| [USPF](https://github.com/baeghyeon-hub/ESO-TamrielKR/releases/download/addon-patches-v1.0.0/USPF-KR-Overwrite.zip) | 스킬/CP 세팅 공유 |
| [VotansMiniMap](https://github.com/baeghyeon-hub/ESO-TamrielKR/releases/download/addon-patches-v1.0.0/VotansMiniMap-KR-Overwrite.zip) | 미니맵 |

### GitHub 선배포 다운로드

아래 3개 애드온은 사용 체감이 큰 편이라, ESOUI/Minion 전환 전에 GitHub 릴리즈에서 먼저 직접 배포합니다.

설치 순서:
- 기존에 설치해 둔 해당 원본 애드온 폴더와 이전 `-KR` 패치 폴더가 있으면 먼저 삭제합니다.
- 원본 애드온 최신 버전을 다시 받아 `AddOns\` 폴더에 새로 설치합니다.
- 아래 KR 패치 zip을 받아 압축 해제 후, `AddOns\` 폴더에 그대로 추가합니다.

| 애드온 | 설명 |
|---|---|
| [CrutchAlerts](https://github.com/baeghyeon-hub/ESO-TamrielKR/releases/download/addon-patches-v1.0.0/CrutchAlerts-KR-Minion.zip) | 트라이얼/던전 전투 경고 |
| [DolgubonsLazyWritCreator](https://github.com/baeghyeon-hub/ESO-TamrielKR/releases/download/addon-patches-v1.0.0/DolgubonsLazyWritCreator-KR-Minion.zip) | 일일/거장 제작 의뢰 자동화 |
| [TamrielTradeCentre (TTC)](https://github.com/baeghyeon-hub/ESO-TamrielKR/releases/download/addon-patches-v1.0.0/TamrielTradeCentre-KR-Minion.zip) | 거래소 가격 검색 |

### Minion / ESOUI 순차 재배포 예정

아래 애드온은 별도 `-KR` 애드온으로 분리 가능한 구조라, ESOUI 등록 후 Minion에서 순차적으로 재배포할 예정입니다.

이 방식이 필요한 이유:
- 원본 애드온이 업데이트돼도 한국어 패치 파일이 지워지지 않습니다.
- Minion은 GitHub 릴리즈가 아니라 `ESOUI 등록 애드온` 기준으로 배포를 인식합니다.
- 따라서 GitHub zip만 올리는 것보다, `ESOUI 등록 -> Minion 배포` 흐름이 장기적으로 안전합니다.

| 애드온 | 상태 |
|---|---|
| ActionDurationReminder | ESOUI/Minion 순차 전환 예정 |
| Azurah | ESOUI/Minion 순차 전환 예정 |
| Destinations | ESOUI/Minion 순차 전환 예정 |
| HarvestMap | ESOUI/Minion 순차 전환 예정 |
| LibSavedVars | ESOUI/Minion 순차 전환 예정 |
| LostTreasure | ESOUI/Minion 순차 전환 예정 |
| pChat | ESOUI/Minion 순차 전환 예정 |
| CrutchAlerts | GitHub 선배포 후 ESOUI/Minion 전환 예정 |
| DolgubonsLazyWritCreator | GitHub 선배포 후 ESOUI/Minion 전환 예정 |
| TamrielTradeCentre (TTC) | GitHub 선배포 후 ESOUI/Minion 전환 예정 |

---

## macOS 지원

macOS ESO에서는 Windows와 다른 두 가지 문제가 있습니다:

1. **slug 폰트가 로드되지 않음** — macOS ESO 클라이언트는 `.slug` 포맷을 인식하지 못해 한글이 □로 표시됩니다.
2. **시스템 한글 IME가 차단됨** — macOS의 한글 입력기가 ESO 엔진에 도달하지 않아 한글 타이핑이 불가능합니다.

### macOS 호환 패치 설치

**[macOS 호환 패치 다운로드 (TamrielKR_Mac-v1.0.0)](https://github.com/baeghyeon-hub/ESO-TamrielKR/releases/tag/mac-v1.0.0)**

기본 TamrielKR 패치를 먼저 설치한 후, 아래 파일을 덮어쓰거나 추가합니다:

| 파일 | 설치 위치 | 설명 |
|---|---|---|
| `backupfont_kr.xml` | `AddOns/TamrielKR/backupfont_kr.xml` (덮어쓰기) | slug → OTF 직접 참조로 변경 |
| `MaruBuri-CNKR.otf` | `AddOns/TamrielKR/fonts/` | 한글 본문 폰트 (OTF) |
| `JalnanGothic-CNKR.otf` | `AddOns/TamrielKR/fonts/` | 한글 볼드 폰트 (OTF) |
| `TamrielKR_IME/` | `AddOns/TamrielKR_IME/` (폴더 통째로) | 한글 입력 애드온 |

### macOS 한글 입력 방법

macOS에서는 시스템 IME 대신 `TamrielKR_IME` 애드온이 한글 입력을 처리합니다:

1. macOS 시스템 입력기를 **영문(ABC)**으로 설정
2. 게임 내 채팅창에서 `/tkime` 입력 또는 키바인딩으로 IME 토글
3. 영문 키보드 그대로 두벌식 한글 입력 (r=ㄱ, k=ㅏ, ...)

| 명령어 | 설명 |
|---|---|
| `/tkime` | 한글 입력 토글 (on/off) |
| `/tkime on` | 한글 입력 켜기 |
| `/tkime off` | 한글 입력 끄기 |
| `/tkime debug` | 디버그 모드 토글 |
| `/tkime test` | 조합 테스트 실행 |

---

## 변경 이력

### [v1.0.6](https://github.com/baeghyeon-hub/ESO-TamrielKR/releases/tag/v1.0.6)
- 트리뷰트/GroupFinder 문자열 포맷 수정

### [v1.0.5](https://github.com/baeghyeon-hub/ESO-TamrielKR/releases/tag/v1.0.5)
- BackupFont 체인 수정: TamrielKR slug → kr_maruburi_cnkr.slug 직접 1단계 연결
- 커스텀 폰트 적용 시 채팅 입력 한글 깨짐(ㅁㅁㅁ) 수정

### [Font Changer v1.0.0](https://github.com/baeghyeon-hub/ESO-TamrielKR/releases/tag/fontchanger-v1.0.0)
- 게임 내 폰트 변경 도구 첫 릴리즈
- 기본 폰트(MaruBuri/Jalnan/고딕) 선택 또는 커스텀 TTF/OTF 적용
- CNKR 호환 구조상 전체 폰트 일괄 변경만 지원 (카테고리별 변경 불가)

### [v1.0.4.1](https://github.com/baeghyeon-hub/ESO-TamrielKR/releases/tag/v1.0.4.1)
- NPC 채팅 메시지(말/귓속말/외침) 출력 안 되던 버그 수정: `<<C:1>>` → `%s` 포맷 변경

### [v1.0.4](https://github.com/baeghyeon-hub/ESO-TamrielKR/releases/tag/v1.0.4)
- CNKR 인코딩 kr.lang 호환 수정: BackupFont 체이닝에 `kr_maruburi_cnkr.slug` 적용
- Bridge v1.0.6: 길드 브라우저 씬/콜백/API 훅 추가
- macOS 호환 패치 추가 (별도 릴리즈: [mac-v1.0.0](https://github.com/baeghyeon-hub/ESO-TamrielKR/releases/tag/mac-v1.0.0))

### v1.0.3
- 한/영 전환 단축키 지원 (Addon Keybinds)
- MaruBuri SemiBold → Bold 전환 (가독성 개선)
- 업적 UI 강제 정렬 코드 제거 (마루부리에서 불필요)
- 스킬 서브클래싱 랭크 숫자 겹침 수정
- 스킬 정보 랭크 표시 수정

### v1.0.2
- 게임패드 UI 중국어 표시 수정 (Jalnan CNKR 폰트)
- 전체 slug 폰트 CNKR 매핑 적용

### v1.0.1
- 길드 로스터 보호함수 에러 수정 (rawget 방식)
- CNKR→UTF-8 변환기 바이너리 인덱스 보존 버그 수정

### v1.0.0
- 최초 릴리즈

---

## 의존성

- [LibMediaProvider](https://www.esoui.com/downloads/info7-LibMediaProvider.html) >= 34

---

## 라이선스

This Add-on is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its affiliates. The Elder Scrolls and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries.
