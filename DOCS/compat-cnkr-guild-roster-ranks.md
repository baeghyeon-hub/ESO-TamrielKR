# [호환성/길드] 길드 명부·계급 CJK→한글 디코딩

작성일: 2026-03-31
상태: 해결 완료

## 문서 메타

- 문제 유형 태그: `길드 UI`, `CNKR`, `API 훅`, `복수 반환값`, `컨트롤 트리 스캔`
- 원인 레이어: `문자열 인코딩`, `API 반환값`, `UI 바인딩`
- 핵심 한 줄 요약: 길드 명부 멤버 정보와 계급 이름은 `GetGuildMotD`/`GetGuildDescription`과 다른 API 경로를 사용하므로, 별도 API 래핑이 필요했다.

## 1. 문제 요약

`compat-cnkr-guild-ui.md`에서 길드 MOTD와 소개말의 CJK 디코딩은 해결했지만, 같은 길드 UI 안의 다른 영역에서 추가 깨짐이 발견됐다.

### 증상 1: 길드 명부 (Guild Roster)

- `@x253x247` 등 EsoKR 사용자의 캐릭터명/노트가 CJK 인코딩 상태로 표시
- 예: "Stop that □x b ‡ ∅ □ℸ□r" (CJK 글리프 미지원 문자 → □)
- Font Inspector: `ZO_GuildRosterList1Row2DisplayName`, `TamrielKR/fonts/univers57.slug`

### 증상 2: 길드 계급 (Guild Ranks)

- 커스텀 계급 이름이 전부 □□로 표시
- EsoKR 사용자가 CJK 인코딩으로 설정한 계급명이 디코딩 안 됨
- Font Inspector: `ZO_GuildRanksListHeader1Text`, `TamrielKR/fonts/univers47.slug`

## 2. 원인 분석

기존 Bridge의 API 래핑 범위가 부족했다:

| 데이터 | API 함수 | 기존 훅 여부 |
|--------|----------|-------------|
| 길드 MOTD | `GetGuildMotD` | ✓ 있음 |
| 길드 소개말 | `GetGuildDescription` | ✓ 있음 |
| 멤버 정보 (이름, 노트 등) | `GetGuildMemberInfo` | ✗ 없음 |
| 멤버 캐릭터 정보 (캐릭터명, 존 등) | `GetGuildMemberCharacterInfo` | ✗ 없음 |
| 계급 이름 | `GetGuildRankCustomName` | ✗ 없음 |

또한 `DecodeVisibleGuildTexts()`가 스캔하는 컨테이너도 부족했다:

| 컨테이너 | 기존 스캔 여부 |
|----------|---------------|
| `ZO_GuildHome` | ✓ 있음 |
| `ZO_GuildSharedInfo` | ✓ 있음 |
| `ZO_GuildRoster` | ✗ 없음 |
| `ZO_GuildRanks` | ✗ 없음 |

## 3. 해결: API 래핑 확장

### 단일 반환값 API

`GetGuildRankCustomName`은 문자열 하나만 반환하므로 기존 `GetGuildMotD`와 같은 방식으로 래핑:

```lua
local singleReturnApis = {
  "GetGuildMotD",
  "GetGuildDescription",
  "GetGuildRankCustomName",  -- 추가
}
```

### 복수 반환값 API

`GetGuildMemberInfo`와 `GetGuildMemberCharacterInfo`는 여러 값을 반환한다. 문자열 인자만 선별 디코딩하는 래퍼를 추가했다:

```lua
local multiReturnApis = {
  "GetGuildMemberInfo",           -- displayName, note, rankIndex, playerStatus, secsSinceLogoff
  "GetGuildMemberCharacterInfo",  -- hasCharacter, rawCharacterName, zone, classType, alliance, level, championPoints, zoneId
}

for _, funcName in ipairs(multiReturnApis) do
  local original = _G[funcName]
  if original then
    _G[funcName] = function(...)
      local results = { original(...) }
      local changed = false
      for i = 1, #results do
        if type(results[i]) == "string" and results[i] ~= "" then
          local decoded = DecodeCNKR(results[i])
          if decoded ~= results[i] then
            results[i] = decoded
            changed = true
          end
        end
      end
      return unpack(results)
    end
  end
end
```

핵심: `{ original(...) }`로 모든 반환값을 캡처하고, `type(results[i]) == "string"`으로 문자열만 필터링하여 디코딩 후 `unpack(results)`로 원래 형태 유지.

### 컨트롤 트리 스캔 확장

```lua
local containers = { "ZO_GuildHome", "ZO_GuildSharedInfo", "ZO_GuildRoster", "ZO_GuildRanks" }
```

## 4. 결과

| 항목 | 수정 전 | 수정 후 |
|------|---------|---------|
| 길드 계급 이름 | □□ | 데스, 운치골 동노예 등 한글 정상 표시 |
| 길드 멤버 캐릭터명 | 확인 필요 | API 래핑으로 디코딩 적용됨 |
| 길드 멤버 노트 | 확인 필요 | API 래핑으로 디코딩 적용됨 |

길드 계급은 스크린샷으로 확인 완료. 멤버 캐릭터명/노트는 CJK 인코딩 사례가 나타나면 추가 검증 예정.

## 5. 현재 코드 위치

- `TamrielKR_Bridge/TamrielKR_Bridge.lua`
  - `HookGuildUI()` — 단일 반환값 + 복수 반환값 API 래핑
  - `DecodeVisibleGuildTexts()` — 확장된 컨테이너 스캔

## 6. compat-cnkr-guild-ui.md와의 관계

`compat-cnkr-guild-ui.md`는 MOTD/소개말에 한정한 기록이다. 이 문서는 같은 Bridge의 길드 훅을 명부와 계급으로 확장한 후속 기록이며, 동일한 `DecodeCNKR` 함수와 `HookGuildUI()` 진입점을 공유한다.

---

이 문서는 "길드 명부/계급 CJK 텍스트 깨짐" 이슈에 한정한 기록이다.
길드 명부에서 발견된 특수문자 □ 렌더링 문제(CJK 인코딩 무관)는 `font-backupfont-chain.md`를 참고할 것.
