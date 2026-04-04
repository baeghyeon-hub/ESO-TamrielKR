# [호환성/언어] 애드온 언어 호환성 해결

작성일: 2026-03-29
상태: 해결 완료

## 문서 메타

- 문제 유형 태그: `애드온 호환성`, `언어 감지`, `GetCVar`, `$(language)`, `동기화`
- 원인 레이어: `엔진 로딩`, `Lua 호환성`, `동기화`
- 핵심 한 줄 요약: TamrielKR은 엔진에는 `kr`를 유지하면서 Lua에는 `en`을 반환하는 이중 구조로 영문 전용 애드온과 공존하고, 필요한 `kr` 파일은 별도 생성해 해결한다.

## 1. 문제 요약

TamrielKR은 `language.2 = "kr"`로 설정하여 ESO 엔진이 한글 리소스(.str, .lang, backupfont_kr.xml)를 로드하게 한다. 그런데 TTC(Tamriel Trade Centre) 같은 다른 애드온들이 이 값을 읽고 "English only" 에러를 표시하거나, `$(language)` 파일 확장에서 존재하지 않는 kr 파일을 참조하여 실패했다.

대표 증상:

- TTC: "Tamriel Trade Centre only supports English client at this time" 에러
- TTC: "Item lookup table is missing" 에러

## 2. 원인 분석: 두 개의 레이어

ESO에서 `language.2` CVar를 읽는 경로가 두 가지 있다.

### 레이어 1: C++ 엔진 레벨

애드온 매니페스트(.txt)의 `$(language)` 확장은 C++ 엔진이 실제 CVar 값으로 처리한다.

```
backupfont_$(language).xml        → backupfont_kr.xml ✓ (TamrielKR이 제공)
ItemLookUpTable_$(language).lua   → ItemLookUpTable_kr.lua ✗ (TTC에 없음)
lang\$(language).lua              → lang\kr.lua ✗ (TTC에 없음)
```

이 레이어는 Lua 코드로 제어할 수 없다. 파일이 없으면 조용히 스킵하지만, 애드온 Lua 코드가 해당 파일의 결과물(함수, 테이블 등)을 기대하면 런타임 에러가 발생한다.

### 레이어 2: Lua 레벨

애드온의 Lua 코드가 `GetCVar("language.2")`를 호출하여 언어를 확인한다.

```lua
-- TTC 내부 코드 (추정)
if GetCVar("language.2") ~= "en" then
    -- "English only" 에러 표시
end
```

이 레이어는 Lua 함수 후킹으로 제어할 수 있다.

## 3. 해결: 두 레이어 각각 대응

### 3.1. Lua 레벨: GetCVar 훅 (Core.lua)

`GetCVar`를 후킹하여 `language.2` 요청 시 항상 `"en"`을 반환한다.

```lua
local realGetCVar = GetCVar
local realSetCVar = SetCVar

GetCVar = function(cvar)
  if cvar == "language.2" then
    return "en"
  end
  return realGetCVar(cvar)
end
```

핵심 설계:

- ESO C++ 엔진은 실제 CVar `"kr"`을 사용하여 한글 리소스를 정상 로드
- Lua 레벨에서는 `"en"`을 반환하여 다른 애드온이 영문 클라로 인식
- TamrielKR 자체는 `realGetCVar`(원본 함수 참조)로 진짜 언어를 확인

| 호출자 | 사용 함수 | 반환값 | 목적 |
|---|---|---|---|
| ESO C++ 엔진 | 직접 CVar 읽기 | `"kr"` | 한글 리소스 로드 |
| TamrielKR | `realGetCVar` | `"kr"` | 내부 언어 판단 |
| TTC 등 다른 애드온 | `GetCVar` (훅) | `"en"` | 영문 호환 동작 |

훅 타이밍도 중요하다. `Core.lua`는 TamrielKR 매니페스트에서 3번째 Lua 파일이고, TamrielKR은 알파벳순으로 TamrielTradeCentre보다 먼저 로드된다. 따라서 TTC의 `OnAddonLoaded`가 실행되기 전에 훅이 설치된다.

### 3.2. C++ 레벨: $(language) 파일 복사

`$(language)` 확장은 Lua 훅으로 제어할 수 없으므로, 해당 애드온 디렉토리에 kr 파일을 직접 생성해야 한다.

TTC의 경우:

```
ItemLookUpTable_EN.lua  →  ItemLookUpTable_kr.lua (복사)
lang\en.lua             →  lang\kr.lua (최초 1회 생성만)
```

이 복사는 `sync-to-live-addons.ps1`에 자동화했다:

```powershell
$ttcPath = Join-Path $targetRoot "TamrielTradeCentre"
if (Test-Path $ttcPath) {
    Copy-Item -Path (Join-Path $ttcPath "ItemLookUpTable_EN.lua") `
              -Destination (Join-Path $ttcPath "ItemLookUpTable_kr.lua") -Force
    if (-not (Test-Path (Join-Path $ttcPath "lang\kr.lua"))) {
        Copy-Item -Path (Join-Path $ttcPath "lang\en.lua") `
                  -Destination (Join-Path $ttcPath "lang\kr.lua") -Force
    }
}
```

주의:

- TTC Client.exe를 재실행하면 `ItemLookUpTable_EN.lua`가 갱신되지만 `_kr.lua`는 자동 갱신되지 않는다. `sync-to-live-addons.ps1`을 다시 실행하면 최신 EN 데이터가 kr로 복사된다.
- `lang\kr.lua`에 직접 한글 번역을 넣은 뒤에는 자동 동기화가 이를 덮어쓰지 않도록, 스크립트는 `lang\kr.lua`가 없을 때만 최초 생성해야 한다.

## 4. 번역이 있는 애드온과의 관계: 알파벳 순서 의존성

GetCVar 훅은 `Core.lua` 파일 실행 시점에 설치된다. 즉, TamrielKR이 로드되는 순간부터 활성화된다. ESO는 애드온을 알파벳순으로 로드하므로, 훅 설치 시점을 기준으로 동작이 갈린다.

```
알파벳순 로딩:
  Azurah ("A")           → GetCVar 훅 미설치 → "kr" 반환 → 한글 적용 ✓
  Fancy Action Bar+ ("F") → GetCVar 훅 미설치 → "kr" 반환 → 한글 적용 ✓
  LibMediaProvider ("L")  → GetCVar 훅 미설치 → "kr" 반환
  TamrielKR ("T")         → ★ Core.lua 실행 → GetCVar 훅 설치 ★
  TamrielTradeCentre ("T", TamrielKR 뒤) → GetCVar 훅 적용 → "en" 반환 → 정상 동작 ✓
```

### 현재 잘 동작하는 이유

Azurah KR 패치(`Korean_kr.lua`)는 `GetCVar("language.2") == "kr"` 조건으로 한글을 활성화한다:

```lua
if (GetCVar("language.2") == "kr") then
    function Azurah:GetLocale()
        return L
    end
end
```

이 코드는 Azurah 로딩 시점에 실행되고, Azurah("A")는 TamrielKR("T")보다 먼저 로드되므로 훅이 설치되기 전에 실제 CVar `"kr"`을 받아 한글이 정상 적용된다.

### 주의: "T" 이후 알파벳의 애드온

알파벳순으로 TamrielKR 뒤에 오는 애드온이 `GetCVar("language.2")`로 한글 번역을 판별하면, 훅에 의해 `"en"`을 받아 한글이 적용되지 않는다. 이런 경우 해당 애드온의 KR 패치에서 언어 판별 조건을 수정해야 한다:

```lua
-- 방법 1: TamrielKR의 realGetCVar 사용
if TamrielKR and TamrielKR.GetLanguage then
    local lang = TamrielKR:GetLanguage()
    if lang == "kr" then ... end
end

-- 방법 2: SavedVariables 기반 판별
-- GetCVar 대신 TamrielKR_Variables.lang == "kr" 체크
```

현재까지 이 문제가 실제로 발생한 애드온은 없다. 대부분의 한글 번역 대상 애드온(Azurah, Fancy Action Bar+ 등)은 알파벳순으로 TamrielKR보다 앞에 있다.

## 5. 향후 같은 문제를 만나면

다른 애드온에서 언어 호환 에러가 발생할 때 확인 순서:

1. **Lua 레벨 체크인지 확인**: 에러 메시지가 "English only" 류면 GetCVar 훅으로 이미 해결됨
2. **$(language) 파일 누락인지 확인**: 에러 메시지가 "missing" 류면 해당 애드온의 .txt 매니페스트에서 `$(language)` 패턴을 찾고, EN 파일을 kr로 복사
3. **번역 패치와 충돌하는지 확인**: KR 패치가 있는 애드온이 GetCVar 훅 때문에 영어로 표시되면, 알파벳 로딩 순서를 확인하고 필요시 언어 판별 조건을 수정
4. **알파벳순 확인**: 문제 애드온의 이름이 "T" 이전이면 훅 영향 없음, "T" 이후면 훅 영향 있음

## 6. 현재 코드 위치

- `TEST/TamrielKR/Core.lua` — GetCVar 훅, realGetCVar/realSetCVar 보존
- `TEST/sync-to-live-addons.ps1` — TTC 파일 복사 자동화

---

이 문서는 "다른 애드온 언어 호환성" 이슈에 한정한 기록이다.
채팅 CNKR 디코딩은 `compat-cnkr-chat.md`, 길드 UI 디코딩은 `compat-cnkr-guild-ui.md`를 참고할 것.
