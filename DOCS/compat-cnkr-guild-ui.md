# [호환성/UI] 길드 UI CJK→한글 디코딩

작성일: 2026-03-29
상태: 해결 완료

## 문서 메타

- 문제 유형 태그: `길드 UI`, `CNKR`, `API 훅`, `컨트롤 트리 스캔`
- 원인 레이어: `문자열 인코딩`, `API 반환값`, `UI 바인딩`
- 핵심 한 줄 요약: 길드 MOTD와 소개말은 채팅 경로가 아니라 별도 API/UI 경로로 들어오므로, API 훅과 보조 컨트롤 스캔을 조합해 디코딩했다.

## 1. 문제 요약

TamrielKR은 네이티브 한글 유니코드를 사용하지만, 기존 EsoKR 사용자들이 작성한 길드 MOTD/소개말은 CJK 인코딩(con2CNKR)으로 저장되어 있다. 이 텍스트가 길드 UI에서 □□□□로 깨져 보였다.

대표 증상:

- 길드 홈 화면의 "오늘의 메시지"(MOTD) 내용이 전부 □로 표시
- "소개말"(길드 설명) 내용도 동일하게 깨짐
- UI 라벨(업데이트, 오늘의 메시지, 배경 정보 등)은 정상 표시 (이들은 .str 파일의 네이티브 한글)
- 채팅은 이미 DecodeCNKR 훅으로 해결된 상태였음

핵심: 채팅은 `CHAT_ROUTER.FormatAndAddChatMessage` 훅으로 잡았지만, 길드 UI 텍스트는 별도 경로로 렌더링되므로 추가 훅이 필요했다.

## 2. 첫 번째 시도: 컨트롤 이름 추측

### 접근 방식

길드 UI의 컨트롤 이름을 추측하여 직접 `GetText()`/`SetText()` 호출로 디코딩하려 했다.

시도한 컨트롤 이름들:

```
ZO_GuildHomeInfoMotd
ZO_GuildHomeInfoMotdBody
ZO_GuildHomeMotd
ZO_GuildHomeMotdBody
ZO_GuildHomeInfoDescription
ZO_GuildHomeInfoDescriptionBody
ZO_GuildHomeDescription
ZO_GuildHomeDescriptionBody
ZO_GuildHomeAbout
ZO_GuildHomeAboutBody
```

### 시도한 훅 포인트

```lua
GUILD_HOME.RefreshGuildInfo
GUILD_SELECTOR.SelectGuild
길드 관련 씬 StateChange (guildHome, guildRoster 등)
```

### 결과

실패. 컨트롤 이름이 맞지 않았거나, 훅 타이밍이 맞지 않았다. 길드 UI가 열렸을 때 텍스트가 여전히 □□□□로 표시되었다.

### 교훈

ESO의 UI 컨트롤 이름은 외부에서 추측하기 어렵다. 특히 길드 UI처럼 복잡한 패널은 내부 구조가 버전마다 다를 수 있다.

## 3. 해결: API 레벨 래핑

### 발상의 전환

컨트롤을 직접 찾는 대신, **데이터를 반환하는 ESO API 함수 자체를 래핑**하면 해당 데이터를 표시하는 모든 UI가 자동으로 디코딩된 텍스트를 받는다.

### 핵심 코드

```lua
local apiFunctions = {
  "GetGuildMotD",
  "GetGuildDescription",
}

for _, funcName in ipairs(apiFunctions) do
  local original = _G[funcName]
  if original then
    _G[funcName] = function(...)
      local result = original(...)
      if type(result) == "string" and result ~= "" then
        return DecodeCNKR(result)
      end
      return result
    end
  end
end
```

### 보조: 컨트롤 트리 순회

API 래핑으로 잡히지 않는 경우를 대비하여, 길드 씬이 열릴 때 컨트롤 트리를 순회하며 CJK 텍스트를 디코딩하는 보조 로직도 추가했다.

```lua
local guildScenes = { "guildHome", "guildRoster", "guildRanks", "guildHistory", "guildHeraldry" }
for _, sceneName in ipairs(guildScenes) do
  local scene = SCENE_MANAGER:GetScene(sceneName)
  if scene then
    scene:RegisterCallback("StateChange", function(_, newState)
      if newState == SCENE_SHOWN then
        zo_callLater(function() addon:DecodeVisibleGuildTexts() end, 100)
        zo_callLater(function() addon:DecodeVisibleGuildTexts() end, 500)
      end
    end)
  end
end
```

`DecodeVisibleGuildTexts`는 `ZO_GuildHome`, `ZO_GuildSharedInfo` 등 컨테이너 아래의 모든 텍스트 라벨을 depth 8까지 순회하며 디코딩한다.

### 결과

성공. 길드 MOTD와 소개말 모두 한글로 정상 표시.

## 4. 왜 API 래핑이 컨트롤 이름 추측보다 좋은가

| 방식 | 장점 | 단점 |
|---|---|---|
| 컨트롤 이름 직접 접근 | 특정 컨트롤만 처리 가능 | 이름을 정확히 알아야 함, ESO 업데이트 시 깨질 수 있음 |
| API 함수 래핑 | 해당 데이터를 쓰는 모든 UI에 적용 | 래핑할 함수를 알아야 함 |
| 컨트롤 트리 순회 | 이름 몰라도 됨 | 비용 있음, 타이밍 이슈 가능 |

최종 구현은 API 래핑(1차) + 컨트롤 트리 순회(2차 보조)를 조합했다.

## 5. 채팅 디코딩과의 관계

채팅과 길드 UI는 같은 `DecodeCNKR` 함수를 공유하지만 훅 경로가 다르다.

| 대상 | 훅 방식 |
|---|---|
| 채팅 메시지 | `ZO_PreHook(CHAT_ROUTER, "FormatAndAddChatMessage", ...)` |
| 길드 MOTD | `GetGuildMotD` API 래핑 |
| 길드 설명 | `GetGuildDescription` API 래핑 |
| 기타 길드 UI | 컨트롤 트리 순회 (보조) |

## 6. 현재 코드 위치

- `TEST/TamrielKR/Chat.lua`
  - `DecodeCNKR()` - CJK→한글 역변환 (코드포인트 레벨)
  - `HookChatSystem()` - 채팅 훅
  - `HookGuildUI()` - 길드 API 래핑 + 씬 훅
  - `DecodeVisibleGuildTexts()` - 컨트롤 트리 순회
  - `DecodeControlTree()` - 재귀 순회 유틸

## 7. 향후 고려사항

### 다른 유저 생성 콘텐츠

EsoKR 사용자가 CJK 인코딩으로 작성할 수 있는 다른 텍스트:

- 길드 멤버 노트
- 우편 제목/본문
- 친구 노트
- 그룹 찾기 설명

이들도 같은 방식(API 래핑)으로 처리 가능. 관련 API 함수를 찾아서 래핑 목록에 추가하면 된다.

### DecodeCNKR의 범위

현재 `MapCNKRCodepoint`는 EsoKR의 con2CNKR encode 역연산에 해당하는 3개 범위만 처리한다:

```lua
U+4E00~U+4EFF → -0x3D00 (자모)
U+5F01~U+5F5F → -0x2DD0 (자모 추가)
U+6E00~U+99AC → +0x3E00 (한글 음절)
```

이 범위는 EsoKR의 con2CNKR이 실제로 사용하는 매핑과 일치해야 하며, 일반 CJK 한자(중국어 원문)와 혼동하지 않도록 주의가 필요하다. 현재까지 오탐은 보고되지 않았다.

---

이 문서는 "길드 UI CJK 텍스트 깨짐" 이슈 중 MOTD/소개말에 한정한 기록이다.
길드 명부·계급으로의 확장은 `compat-cnkr-guild-roster-ranks.md`를 참고할 것.
업적 점수 겹침 문제는 `ui-font-achievement-points.md`를 참고할 것.
