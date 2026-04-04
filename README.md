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
| UI 패치 | 폰트 교체만 | 업적/스킬/길드 등 **한글 깨짐 UI 개별 수정** |
| 서드파티 애드온 한글화 | 불가 | **가능** |

EsoKR은 한글 유니코드를 중국어(CJK) 코드포인트로 변환해서 표시합니다. 이 방식은 ESO 엔진이 한글 클라를 "중국어"처럼 인식하게 되어, TTC 등 영문 전용 애드온이 동작하지 않습니다. TTC를 쓰려면 매번 영문 클라로 전환해야 했습니다.

TamrielKR은 네이티브 UTF-8 한글을 그대로 사용하면서, `GetCVar` 후킹으로 다른 애드온에는 영문 클라(`"en"`)로 인식시킵니다. 덕분에 **한글 클라 상태에서 TTC 등 영문 애드온이 정상 동작**하고, 영문 애드온의 한글 번역 패치도 가능해졌습니다.

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

1. **[최신 릴리즈 다운로드 (TamrielKR-release.zip)](https://github.com/baeghyeon-hub/ESO-TamrielKR/releases/latest/download/TamrielKR-release.zip)**
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

   > **중요:** 기존 ESO 한글 번역팀이 배포하는 `kr.lang` 파일은 EsoKR 방식(CJK 코드포인트 인코딩)으로 되어 있습니다. TamrielKR은 네이티브 UTF-8 한글을 사용하므로, **CJK 인코딩된 lang 파일을 UTF-8로 직접 변환해야 합니다.**
   >
   > CJK → UTF-8 변환이 되지 않은 lang 파일을 그대로 사용하면 한글이 중국어 글자로 표시됩니다.

   변환한 `kr.lang` 파일을 `AddOns\gamedata\lang\kr.lang`에 넣어주세요.

4. 게임 실행 후 애드온 목록에서 TamrielKR, TamrielKR_Bridge 활성화

### 빠른 배포 (개발용)

```powershell
.\sync-to-live-addons.ps1
```

---

## 폰트

| 용도 | 폰트 |
|---|---|
| 일반 UI | 마루 부리 SemiBold |
| 타이틀/강조 | 여기어때 잘난체 |

slug 재생성이 필요하면:

```bat
tools\generate_slugs.bat "C:\...\game\client\slugfont.exe"
```

---

## 서드파티 애드온 한글 패치

`Addon PATCHES/` 폴더에 개별 애드온 한글 패치가 포함되어 있습니다. 필요한 패치의 zip 파일을 받아 기존 애드온 폴더에 덮어 쓰세요.

---

## 의존성

- [LibMediaProvider](https://www.esoui.com/downloads/info7-LibMediaProvider.html) >= 34

---

## 라이선스

This Add-on is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its affiliates. The Elder Scrolls and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries.
