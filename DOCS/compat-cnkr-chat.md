# [호환성/채팅] 채팅 CJK→한글 디코딩

작성일: 2026-03-29
상태: 해결 완료

## 문서 메타

- 문제 유형 태그: `채팅`, `CNKR`, `EsoKR 호환`, `문자열 디코딩`
- 원인 레이어: `문자열 인코딩`, `채팅 파이프라인`, `호환성`
- 핵심 한 줄 요약: EsoKR가 CJK 영역으로 변환한 한글 채팅을 TamrielKR 쪽에서 역변환해, 구형 패치 사용자와도 채팅이 상호 호환되도록 만들었다.

## 1. 문제 요약

TamrielKR은 네이티브 한글 유니코드를 사용하지만, 기존 EsoKR 사용자들은 채팅 시 한글을 CJK 코드포인트로 변환(con2CNKR encode)하여 전송한다. TamrielKR 사용자가 이 메시지를 수신하면:

- 한글 slug 폰트 사용 시: CJK 코드포인트에 글리프가 없어 □□□□로 표시
- 중국어 지원 폰트 사용 시: 중국어 한자로 표시

핵심: TamrielKR 사용자끼리는 네이티브 한글로 통신하므로 문제없지만, EsoKR 사용자와의 호환성을 위해 수신 메시지를 디코딩해야 했다.

## 2. EsoKR의 con2CNKR 인코딩 구조

### 원본 코드 위치

`기존 ESO 한글패치/EsoKR/EsoKR.lua` 57~112줄

### 인코딩 방향 (한글 → CJK)

EsoKR은 채팅 입력 시 `Convert()` 함수에서 `con2CNKR(text, true)`를 호출하여 한글을 CJK 코드포인트로 변환한 후 전송한다.

변환은 UTF-8 바이트 트리플 레벨에서 수행된다:

| 입력 범위 (UTF-8 바이트) | 유니코드 범위 | 설명 | 바이트 오프셋 |
|---|---|---|---|
| `0xE18480 ~ 0xE187BF` | U+1100 ~ U+11FF | 한글 자모 (ㄱ-ㅎ 등) | +0x43400 |
| `0xE384B1 ~ 0xE384BF` | U+3131 ~ U+313F | 호환용 자모 추가 1 | +0x237D0 |
| `0xE38580 ~ 0xE3868F` | U+3140 ~ U+318F | 호환용 자모 추가 2 | +0x23710 |
| `0xEAB880 ~ 0xEABFBF` | U+AE00 ~ U+AFFF | 한글 음절 특수 1 | -0x33800 |
| `0xEBB880 ~ 0xEBBFBF` | U+BE00 ~ U+BFFF | 한글 음절 특수 2 | -0x33800 |
| `0xECB880 ~ 0xECBFBF` | U+CE00 ~ U+CFFF | 한글 음절 특수 3 | -0x33800 |
| 나머지 `0xEAB080 ~ 0xED9EAC` | U+AC00 ~ U+D7AC | 한글 음절 메인 | -0x3F800 |

### 왜 오프셋이 여러 개인가

UTF-8 바이트 트리플에 상수를 더하거나 빼면 바이트 오버플로우가 발생할 수 있다. 예를 들어 byte3이 0xBF를 초과하면 byte2로 캐리가 발생하고, 결과가 유효한 UTF-8이 아닐 수 있다.

con2CNKR은 이 문제를 피하기 위해 특정 범위에서 다른 오프셋(-0x33800 vs -0x3F800)을 사용한다. 결과적으로 한글 음절이 CJK 한자 범위(U+4E00~U+9FFF 부근)에 골고루 분산된다.

## 3. 디코딩 전략 선택

### 방법 1: 바이트 트리플 레벨 역변환 (초기 시도)

con2CNKR과 동일한 바이트 레벨에서 역 오프셋을 적용하는 방식.

```lua
-- 초기 구현 (바이트 레벨)
local val = tonumber(temp, 16)  -- 3바이트를 하나의 정수로
if val >= 0xE4B880 and val <= 0xE4BBBF then
  val = val - 0x43400  -- 자모 역변환
elseif val >= 0xE6B880 and val <= 0xE9A6AC then
  val = val + 0x3F800  -- 음절 역변환
  -- + 특수 sub-range 처리
end
```

문제점:

- con2CNKR의 바이트 오프셋 로직을 그대로 뒤집어야 해서 복잡
- 특수 sub-range 경계값 계산이 오류에 취약
- 코드 가독성이 낮음

### 방법 2: 코드포인트 레벨 역변환 (최종 채택)

UTF-8 바이트를 먼저 유니코드 코드포인트로 디코딩한 뒤, 코드포인트 레벨에서 매핑하는 방식.

```lua
local function MapCNKRCodepoint(codepoint)
  if codepoint >= 0x4E00 and codepoint <= 0x4EFF then
    return codepoint - 0x3D00  -- U+4E00~4EFF → U+1100~11FF (자모)
  end
  if codepoint >= 0x5F01 and codepoint <= 0x5F5F then
    return codepoint - 0x2DD0  -- U+5F01~5F5F → U+3131~318F (호환 자모)
  end
  if codepoint >= 0x6E00 and codepoint <= 0x99AC then
    return codepoint + 0x3E00  -- U+6E00~99AC → U+AC00~D7AC (음절)
  end
  return nil
end
```

장점:

- UTF-8 인코딩/디코딩을 분리하여 매핑 로직이 단순
- 바이트 오버플로우 걱정 없음
- 코드포인트 범위만 보면 되므로 검증이 쉬움

### 코드포인트 오프셋 도출 과정

바이트 트리플 오프셋을 코드포인트 오프셋으로 변환:

| 바이트 연산 | 입력 코드포인트 | 출력 코드포인트 | CP 오프셋 |
|---|---|---|---|
| +0x43400 | U+1100 | U+4E00 | +0x3D00 |
| +0x237D0 | U+3131 | U+5F01 | +0x2DD0 |
| +0x23710 | U+3140 | U+5F10 | +0x2BD0 |
| -0x3F800 | U+AC00 | U+6E00 | -0x3E00 |
| -0x33800 | U+AE00 | U+7000 | -0x3E00 |

주목: 바이트 레벨에서는 -0x3F800과 -0x33800으로 다른 오프셋이었지만, 코드포인트 레벨에서는 모두 -0x3E00으로 동일하다. 이것이 코드포인트 레벨 접근이 더 단순한 이유이다.

디코딩(역변환)은 부호를 뒤집으면 된다:

| 디코딩 | CJK 코드포인트 | 한글 코드포인트 | CP 오프셋 |
|---|---|---|---|
| 자모 | U+4E00 ~ U+4EFF | U+1100 ~ U+11FF | -0x3D00 |
| 호환 자모 | U+5F01 ~ U+5F5F | U+3131 ~ U+318F | -0x2DD0 |
| 한글 음절 | U+6E00 ~ U+99AC | U+AC00 ~ U+D7AC | +0x3E00 |

## 4. 채팅 훅 구현

### 훅 대상

`CHAT_ROUTER:FormatAndAddChatMessage`를 `ZO_PreHook`으로 후킹.

```lua
ZO_PreHook(CHAT_ROUTER, "FormatAndAddChatMessage", function(router, eventCode, channelType, fromName, text, ...)
  local changed, values = DecodeChatMessageArgs(fromName, text, ...)
  if changed then
    router:FormatAndAddChatMessage(eventCode, channelType, unpack(values))
    return true  -- 원본 호출 차단
  end
end)
```

### 디코딩 대상

`fromName`과 `text` 뿐 아니라 가변 인자(`...`)의 모든 문자열을 디코딩한다. EsoKR 사용자의 캐릭터 이름이나 길드 이름도 CJK 인코딩일 수 있기 때문.

```lua
local function DecodeChatMessageArgs(...)
  local changed = false
  local values = { ... }
  for index = 1, #values do
    local value = values[index]
    if type(value) == "string" and value ~= "" then
      local decoded = DecodeCNKR(value)
      if decoded ~= value then
        values[index] = decoded
        changed = true
      end
    end
  end
  return changed, values
end
```

### CHAT_ROUTER 존재 보장

`OnPlayerActivated` 시점에 `CHAT_ROUTER`가 아직 없을 수 있다. 최대 10회 1초 간격으로 재시도한다.

```lua
if not CHAT_ROUTER then
  self.chatHookRetryCount = (self.chatHookRetryCount or 0) + 1
  if self.chatHookRetryCount <= 10 then
    zo_callLater(function() addon:HookChatSystem() end, 1000)
  end
  return
end
```

### 중복 훅 방지

`self.chatHooked` 플래그로 한 번만 훅이 걸리도록 한다. `OnAddonLoaded`와 `OnPlayerActivated` 모두에서 `HookChatSystem()`을 호출하므로 중복 방지가 필요.

## 5. pChat 호환성

pChat을 사용하는 경우:

- pChat도 `CHAT_ROUTER`를 후킹하므로 훅 순서에 따라 동작이 달라질 수 있다
- TamrielKR의 `ZO_PreHook`은 원본 함수 호출 전에 실행되므로, pChat보다 먼저 텍스트를 디코딩한다
- 디코딩된 텍스트가 pChat에 전달되므로 pChat의 기능(타임스탬프, 채널 색상 등)은 정상 작동한다

현재까지 pChat과의 충돌은 보이지 않았다.

## 6. 오탐(False Positive) 위험

`MapCNKRCodepoint`가 일반 CJK 한자를 한글로 잘못 변환할 위험이 있다.

| 범위 | 포함된 실제 CJK 한자 | 위험도 |
|---|---|---|
| U+4E00 ~ U+4EFF | 一, 丁, 七, 万, 丈 등 기초 한자 | **높음** |
| U+5F01 ~ U+5F5F | 弁, 弄 등 | 낮음 |
| U+6E00 ~ U+99AC | 많은 상용 한자 | **높음** |

실제로 ESO 채팅에서 중국어 원문이 오가는 경우는 극히 드물고, EsoKR 사용자가 보낸 CJK 인코딩 텍스트는 특정 패턴(연속된 CJK 문자열)을 보이므로 실사용에서 오탐 문제는 발생하지 않았다.

만약 오탐이 문제가 된다면:

- 연속 CJK 문자 수 기반 휴리스틱 추가
- 채널별 디코딩 활성화/비활성화 옵션 추가
- 사용자 설정으로 디코딩 on/off 토글

등을 고려할 수 있다.

## 7. TamrielKR → EsoKR 방향 (보내기)

현재 TamrielKR은 네이티브 한글을 그대로 전송한다. EsoKR 사용자가 이 메시지를 받으면:

- EsoKR의 `con2CNKR(text, false)` (decode 모드)가 90번줄에서 CJK→한글 역변환을 시도
- 이 역변환은 `not encode` 조건 하에서만 동작: `temp >= 0xE6B880 and temp <= 0xE9A6A3 then temp = temp + 0x3F800`
- 하지만 이 범위는 CJK에서 한글로의 역변환이므로, TamrielKR이 보낸 네이티브 한글(U+AC00~D7A3)은 이 범위에 해당하지 않음

결론: EsoKR 사용자는 TamrielKR 사용자의 한글 메시지를 **볼 수 없다** (□ 또는 깨진 문자로 표시). 이는 EsoKR이 네이티브 한글 렌더링을 지원하지 않기 때문이며, TamrielKR 측에서 해결할 수 없는 문제이다.

## 8. 현재 코드 위치

- `TEST/TamrielKR/Chat.lua`
  - `MapCNKRCodepoint()` - CJK 코드포인트 → 한글 코드포인트 매핑
  - `Utf8EncodeCodepoint()` - 코드포인트 → UTF-8 바이트 인코딩
  - `DecodeCNKR()` - 문자열 전체 디코딩
  - `DecodeChatMessageArgs()` - 가변 인자 일괄 디코딩
  - `HookChatSystem()` - CHAT_ROUTER 훅

## 9. 이 이슈에서 얻은 교훈

### 교훈 1. 바이트 레벨보다 코드포인트 레벨이 낫다

con2CNKR의 바이트 오프셋을 그대로 역산하려면 7개 분기가 필요하지만, 코드포인트 레벨로 올리면 3개 분기로 줄어든다. UTF-8의 비선형 인코딩이 바이트 레벨에서는 복잡성을 만들지만, 코드포인트 레벨에서는 단순한 덧셈/뺄셈이 된다.

### 교훈 2. 채팅 훅은 가능한 이른 시점에 걸어야 한다

다른 채팅 애드온(pChat 등)보다 먼저 디코딩해야 디코딩된 텍스트가 전체 채팅 파이프라인에 흐른다. `ZO_PreHook`이 이 목적에 적합하다.

### 교훈 3. 양방향 호환은 한쪽에서만 해결할 수 없다

TamrielKR → EsoKR 방향의 한글 표시는 EsoKR이 네이티브 한글을 지원하지 않는 한 불가능하다. 이는 기술적 한계이며 TamrielKR의 결함이 아니다.

---

이 문서는 "채팅 CJK 디코딩" 이슈에 한정한 기록이다.
길드 UI 디코딩은 `compat-cnkr-guild-ui.md`, 업적 점수 겹침은 `ui-font-achievement-points.md`를 참고할 것.
