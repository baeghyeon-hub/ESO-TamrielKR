local Bridge = {
  name = "TamrielKR_Bridge",
  chatReceiveHooked = false,
  chatSendHooked = false,
  guildHooked = false,
  -- P2: 래핑된 전역 API 원본 참조 보관
  originalApis = {},
}

-- ============================================================
-- P1: 기능별 토글 옵션 + 통계
-- ============================================================

local DEFAULT_OPTIONS = {
  chatReceive = true,
  chatSend = true,
  guildApi = true,
  guildUi = true,
}

Bridge.options = {}

Bridge.stats = {
  decodeCount = 0,
  encodeCount = 0,
  decodeChars = 0,
  encodeChars = 0,
  guildUiDecodeCount = 0,
  guildUiControlsVisited = 0,
  guildUiDecodeSkipped = 0,
  lastSource = "",
}

local function ResetStats()
  for k in pairs(Bridge.stats) do
    if type(Bridge.stats[k]) == "number" then
      Bridge.stats[k] = 0
    else
      Bridge.stats[k] = ""
    end
  end
end

-- ============================================================
-- P5: UTF-8 유틸리티 (방어적 리팩토링)
-- ============================================================

local function Utf8EncodeCodepoint(codepoint)
  if codepoint <= 0x7F then
    return string.char(codepoint)
  end

  if codepoint <= 0x7FF then
    local byte1 = 0xC0 + math.floor(codepoint / 0x40)
    local byte2 = 0x80 + (codepoint % 0x40)
    return string.char(byte1, byte2)
  end

  if codepoint <= 0xFFFF then
    local byte1 = 0xE0 + math.floor(codepoint / 0x1000)
    local byte2 = 0x80 + (math.floor(codepoint / 0x40) % 0x40)
    local byte3 = 0x80 + (codepoint % 0x40)
    return string.char(byte1, byte2, byte3)
  end

  local byte1 = 0xF0 + math.floor(codepoint / 0x40000)
  local byte2 = 0x80 + (math.floor(codepoint / 0x1000) % 0x40)
  local byte3 = 0x80 + (math.floor(codepoint / 0x40) % 0x40)
  local byte4 = 0x80 + (codepoint % 0x40)
  return string.char(byte1, byte2, byte3, byte4)
end

-- P5: UTF-8 텍스트를 순회하며 매핑 함수를 적용하는 공통 변환기
-- 2바이트/4바이트 시퀀스를 명시적으로 처리하여 방어성 확보
local function TransformText(text, mapFunc)
  if not text or text == "" then
    return text, 0
  end

  local changed = false
  local mappedCount = 0
  local parts = {}
  local index = 1
  local length = #text

  while index <= length do
    local byte1 = string.byte(text, index)
    if not byte1 then
      break
    end

    if byte1 < 0x80 then
      -- 1바이트 ASCII
      parts[#parts + 1] = string.char(byte1)
      index = index + 1
    elseif byte1 < 0xC0 then
      -- 잘못된 연속 바이트 (단독 출현) — 그대로 통과
      parts[#parts + 1] = string.char(byte1)
      index = index + 1
    elseif byte1 < 0xE0 then
      -- 2바이트 UTF-8 (라틴 확장 등) — 변환 대상 아님, 통째로 복사
      if index + 1 <= length then
        parts[#parts + 1] = string.sub(text, index, index + 1)
        index = index + 2
      else
        parts[#parts + 1] = string.char(byte1)
        index = index + 1
      end
    elseif byte1 < 0xF0 then
      -- 3바이트 UTF-8 — 한글/CJK 변환 대상
      if index + 2 <= length then
        local byte2 = string.byte(text, index + 1)
        local byte3 = string.byte(text, index + 2)
        if byte2 and byte3 and byte2 >= 0x80 and byte2 < 0xC0 and byte3 >= 0x80 and byte3 < 0xC0 then
          local codepoint = (byte1 - 0xE0) * 0x1000 + (byte2 - 0x80) * 0x40 + (byte3 - 0x80)
          local mapped = mapFunc(codepoint)
          if mapped then
            parts[#parts + 1] = Utf8EncodeCodepoint(mapped)
            changed = true
            mappedCount = mappedCount + 1
          else
            parts[#parts + 1] = string.sub(text, index, index + 2)
          end
          index = index + 3
        else
          -- 잘못된 3바이트 시퀀스
          parts[#parts + 1] = string.char(byte1)
          index = index + 1
        end
      else
        -- 잘린 3바이트 시퀀스
        parts[#parts + 1] = string.sub(text, index, length)
        index = length + 1
      end
    else
      -- 4바이트 UTF-8 (이모지 등) — 변환 대상 아님, 통째로 복사
      if index + 3 <= length then
        parts[#parts + 1] = string.sub(text, index, index + 3)
        index = index + 4
      else
        parts[#parts + 1] = string.sub(text, index, length)
        index = length + 1
      end
    end
  end

  if changed then
    return table.concat(parts), mappedCount
  end

  return text, 0
end

-- ============================================================
-- 코드포인트 매핑
-- ============================================================

-- CJK -> 한글 (수신 디코딩: EsoKR -> TamrielKR)
local function MapCNKRToKR(codepoint)
  if codepoint >= 0x5E00 and codepoint <= 0x5EFF then
    return codepoint - 0x4D00
  end

  if codepoint >= 0x5F01 and codepoint <= 0x5F5F then
    return codepoint - 0x2DD0
  end

  if codepoint >= 0x6E00 and codepoint <= 0x99AC then
    return codepoint + 0x3E00
  end

  return nil
end

-- 한글 -> CJK (송신 인코딩: TamrielKR -> EsoKR)
local function MapKRToCNKR(codepoint)
  if codepoint >= 0x1100 and codepoint <= 0x11FF then
    return codepoint + 0x4D00
  end

  if codepoint >= 0x3131 and codepoint <= 0x318F then
    return codepoint + 0x2DD0
  end

  if codepoint >= 0xAC00 and codepoint <= 0xD7AC then
    return codepoint - 0x3E00
  end

  return nil
end

-- ============================================================
-- 변환 함수 (P1: 통계 추적 포함)
-- ============================================================

local function DecodeCNKR(text, source)
  local result, count = TransformText(text, MapCNKRToKR)
  if count > 0 then
    Bridge.stats.decodeCount = Bridge.stats.decodeCount + 1
    Bridge.stats.decodeChars = Bridge.stats.decodeChars + count
    if source then
      Bridge.stats.lastSource = source
    end
  end
  return result
end

local function EncodeCNKR(text, source)
  local result, count = TransformText(text, MapKRToCNKR)
  if count > 0 then
    Bridge.stats.encodeCount = Bridge.stats.encodeCount + 1
    Bridge.stats.encodeChars = Bridge.stats.encodeChars + count
    if source then
      Bridge.stats.lastSource = source
    end
  end
  return result
end

-- P3: CJK 범위 바이트가 포함되어 있는지 빠르게 사전 검사
-- 0x6E00~0x99AC의 UTF-8 첫 바이트: 0xE6~0xE9
-- 0x5E00~0x5F5F의 UTF-8 첫 바이트: 0xE5
local function MayContainCNKR(text)
  return text:find("[\xE5-\xE9]") ~= nil
end

-- ============================================================
-- P2: 전역 API 래핑 헬퍼
-- ============================================================

local function WrapSingleReturnApi(funcName)
  if Bridge.originalApis[funcName] then
    return -- 이미 래핑됨
  end
  local original = _G[funcName]
  if not original then
    return
  end
  Bridge.originalApis[funcName] = original
  _G[funcName] = function(...)
    if not Bridge.options.guildApi then
      return original(...)
    end
    local result = original(...)
    if type(result) == "string" and result ~= "" then
      return DecodeCNKR(result, "guild_api")
    end
    return result
  end
end

local function WrapMultiReturnApi(funcName)
  if Bridge.originalApis[funcName] then
    return
  end
  local original = _G[funcName]
  if not original then
    return
  end
  Bridge.originalApis[funcName] = original
  _G[funcName] = function(...)
    local results = { original(...) }
    if not Bridge.options.guildApi then
      return unpack(results)
    end
    for i = 1, #results do
      if type(results[i]) == "string" and results[i] ~= "" then
        results[i] = DecodeCNKR(results[i], "guild_api")
      end
    end
    return unpack(results)
  end
end

-- ============================================================
-- 채팅 수신 훅 (EsoKR -> TamrielKR 디코딩)
-- ============================================================

local function DecodeChatMessageArgs(...)
  local changed = false
  local values = { ... }

  for index = 1, #values do
    local value = values[index]
    if type(value) == "string" and value ~= "" then
      local decoded = DecodeCNKR(value, "chat_receive")
      if decoded ~= value then
        values[index] = decoded
        changed = true
      end
    end
  end

  return changed, values
end

function Bridge:HookChatReceive()
  if self.chatReceiveHooked then
    return
  end

  if not CHAT_ROUTER then
    self.chatReceiveRetryCount = (self.chatReceiveRetryCount or 0) + 1
    if self.chatReceiveRetryCount <= 10 then
      zo_callLater(function()
        Bridge:HookChatReceive()
      end, 1000)
    end
    return
  end

  self.chatReceiveHooked = true
  ZO_PreHook(CHAT_ROUTER, "FormatAndAddChatMessage", function(router, eventCode, channelType, fromName, text, ...)
    -- P1: 토글 체크
    if not Bridge.options.chatReceive then return end

    local changed, values = DecodeChatMessageArgs(fromName, text, ...)
    if changed then
      router:FormatAndAddChatMessage(eventCode, channelType, unpack(values))
      return true
    end
  end)
end

-- ============================================================
-- 채팅 송신 훅 (TamrielKR -> EsoKR 인코딩)
-- P4: 변화 감지 캐시 + IME 조합 중 스킵
-- ============================================================

function Bridge:HookChatSend()
  if self.chatSendHooked then
    return
  end

  self.chatSendHooked = true

  -- EsoKR과 동일한 방식: TextChanged 시점에 인코딩
  -- SendChatMessage는 보호 함수라 애드온 코드가 call stack에 있으면 호출 불가
  -- TextChanged에서 인코딩하면 Enter(Execute) 시점에는 call stack이 깨끗함
  local encoding = false
  local lastEncodedText = nil
  ZO_PreHook("ZO_ChatTextEntry_TextChanged", function(control, newText)
    -- P1: 토글 체크
    if not Bridge.options.chatSend then return end

    if encoding then return end
    local textEntry = control.system and control.system.textEntry
    if not textEntry then return end

    local editCtrl = textEntry.editControl
    if not editCtrl then return end

    local cursorPos = editCtrl:GetCursorPosition()
    if cursorPos == 0 then return end

    local text = editCtrl:GetText()
    if not text or text == "" then return end

    -- P4: IME 조합 중이면 인코딩 스킵
    if _G.TamrielKR_IME_IsComposing and TamrielKR_IME_IsComposing() then
      return
    end

    -- P4: 이전 인코딩 결과와 같으면 스킵
    if text == lastEncodedText then return end

    local encoded = EncodeCNKR(text, "chat_send")
    if encoded ~= text then
      lastEncodedText = encoded
      encoding = true
      editCtrl:SetText(encoded)
      editCtrl:SetCursorPosition(cursorPos)
      encoding = false
    end
  end)
end

-- ============================================================
-- 길드 API 훅 (MOTD/소개말 CJK 디코딩)
-- P2: originalApis 저장 + 이중 래핑 방지
-- ============================================================

function Bridge:HookGuildApis()
  -- 단일 반환값 API
  local singleReturnApis = {
    "GetGuildMotD",
    "GetGuildDescription",
    "GetGuildRankCustomName",
    "GetGuildRecruitmentHeaderMessage",
    "GetGuildRecruitmentRecruitmentMessage",
  }

  for _, funcName in ipairs(singleReturnApis) do
    WrapSingleReturnApi(funcName)
  end

  -- 복수 반환값 API
  local multiReturnApis = {
    "GetGuildMemberInfo",
    "GetGuildMemberCharacterInfo",
  }

  for _, funcName in ipairs(multiReturnApis) do
    WrapMultiReturnApi(funcName)
  end
end

-- ============================================================
-- 길드 UI 훅 (씬 콜백 + 컨트롤 트리 디코딩)
-- P3: 씬 축소 + 디바운스
-- P6: 컨트롤 트리 범위 축소 + 사전 검사
-- ============================================================

-- P3: 디바운스 — 여러 콜백이 동시 발화해도 1회만 실행
local guildUiDecodePending = false
local guildUiDecodeSecondPending = false

local function ScheduleGuildUiDecode()
  if guildUiDecodePending then return end
  guildUiDecodePending = true
  guildUiDecodeSecondPending = false
  zo_callLater(function()
    guildUiDecodePending = false
    local decoded = Bridge:DecodeVisibleGuildTexts()
    -- 첫 디코딩에서 변환 건수 > 0이면 2차 디코딩 예약 (비동기 데이터 로드 대기)
    if decoded > 0 and not guildUiDecodeSecondPending then
      guildUiDecodeSecondPending = true
      zo_callLater(function()
        guildUiDecodeSecondPending = false
        Bridge:DecodeVisibleGuildTexts()
      end, 400)
    end
  end, 100)
end

function Bridge:HookGuildScenes()
  -- P3: 실제 CJK 텍스트가 표시되는 씬만 대상
  local guildScenes = {
    "guildHome",              -- MOTD/소개말
    "guildRoster",            -- 멤버 노트/존
    "guildRanks",             -- 랭크 커스텀 이름
    "guildBrowserKeyboard",   -- 길드 파인더
  }
  for _, sceneName in ipairs(guildScenes) do
    local scene = SCENE_MANAGER and SCENE_MANAGER:GetScene(sceneName)
    if scene then
      scene:RegisterCallback("StateChange", function(_, newState)
        if newState == SCENE_SHOWN then
          ScheduleGuildUiDecode()
        end
      end)
    end
  end

  -- 길드 브라우저 매니저 콜백 훅
  if GUILD_BROWSER_MANAGER then
    local guildBrowserCallbacks = {
      "OnGuildDataReady", "OnGuildInfoReady", "OnGuildDataLoaded",
    }
    for _, callbackName in ipairs(guildBrowserCallbacks) do
      pcall(function()
        GUILD_BROWSER_MANAGER:RegisterCallback(callbackName, function()
          ScheduleGuildUiDecode()
        end)
      end)
    end
  end
end

-- P6: 컨트롤 트리 범위 축소
function Bridge:DecodeVisibleGuildTexts()
  -- P1: 토글 체크
  if not Bridge.options.guildUi then return 0 end

  -- P3: 대상 컨테이너 축소
  local containers = {
    "ZO_GuildHome",
    "ZO_GuildSharedInfo",
    "ZO_GuildRoster",
    "ZO_GuildRanks",
    "ZO_GuildBrowser_GuildInfo_Keyboard",
    "ZO_GuildBrowser_Keyboard",
  }
  local totalDecoded = 0
  for _, containerName in ipairs(containers) do
    local container = _G[containerName]
    if container then
      totalDecoded = totalDecoded + self:DecodeControlTree(container, 8)
    end
  end
  Bridge.stats.guildUiDecodeCount = Bridge.stats.guildUiDecodeCount + 1
  return totalDecoded
end

-- P6: depth 축소 (12->8), 사전 검사 추가, 방문 카운트
function Bridge:DecodeControlTree(control, depth)
  if not control or depth < 0 then
    return 0
  end

  local decoded = 0
  Bridge.stats.guildUiControlsVisited = Bridge.stats.guildUiControlsVisited + 1

  if control.GetText and control.SetText then
    local text = control:GetText()
    if text and text ~= "" then
      -- P6: CJK 범위 바이트가 없으면 즉시 스킵
      if MayContainCNKR(text) then
        local result = DecodeCNKR(text, "guild_ui")
        if result ~= text then
          control:SetText(result)
          decoded = decoded + 1
        end
      else
        Bridge.stats.guildUiDecodeSkipped = Bridge.stats.guildUiDecodeSkipped + 1
      end
    end
  end

  if control.GetNumChildren and control.GetChild then
    for i = 1, control:GetNumChildren() do
      decoded = decoded + self:DecodeControlTree(control:GetChild(i), depth - 1)
    end
  end

  return decoded
end

-- ============================================================
-- 통합 길드 훅 (API + UI)
-- ============================================================

function Bridge:HookGuildUI()
  if self.guildHooked then
    return
  end

  self.guildHooked = true
  self:HookGuildApis()
  self:HookGuildScenes()
end

-- ============================================================
-- 초기화
-- ============================================================

local function OnPlayerActivated()
  Bridge:HookChatReceive()
  Bridge:HookChatSend()
  Bridge:HookGuildUI()
end

local function OnAddonLoaded(_, addonName)
  if addonName ~= Bridge.name then
    return
  end

  EVENT_MANAGER:UnregisterForEvent(Bridge.name, EVENT_ADD_ON_LOADED)

  -- P1: SavedVariables 초기화
  Bridge.savedVars = ZO_SavedVars:NewAccountWide("TamrielKR_Bridge_Variables", 1, nil, DEFAULT_OPTIONS)
  Bridge.options = Bridge.savedVars

  -- chatSend만 여기서 훅 (전역 함수 훅이라 CHAT_ROUTER 불필요)
  Bridge:HookChatSend()
end

-- ============================================================
-- P1: 슬래시 명령 (토글 + 상태 + 통계)
-- ============================================================

local function PrintStatus()
  d("[TamrielKR_Bridge v1.1.0]")
  d("  hooks: chatReceive=" .. tostring(Bridge.chatReceiveHooked)
    .. " chatSend=" .. tostring(Bridge.chatSendHooked)
    .. " guild=" .. tostring(Bridge.guildHooked))
  d("  options:")
  d("    chat.receive = " .. tostring(Bridge.options.chatReceive))
  d("    chat.send    = " .. tostring(Bridge.options.chatSend))
  d("    guild.api    = " .. tostring(Bridge.options.guildApi))
  d("    guild.ui     = " .. tostring(Bridge.options.guildUi))
  -- P2: 래핑된 API 목록
  local wrappedApis = {}
  for funcName in pairs(Bridge.originalApis) do
    wrappedApis[#wrappedApis + 1] = funcName
  end
  if #wrappedApis > 0 then
    table.sort(wrappedApis)
    d("  wrapped apis: " .. table.concat(wrappedApis, ", "))
  end
  -- 인코딩 테스트
  local test = "\xED\x85\x8C\xEC\x8A\xA4\xED\x8A\xB8"  -- "테스트" UTF-8
  local encoded = EncodeCNKR(test)
  d("  encode test: " .. (encoded ~= test and "OK" or "FAIL"))
end

local function PrintStats()
  d("[Bridge Stats]")
  d("  decode: " .. Bridge.stats.decodeCount .. " calls, " .. Bridge.stats.decodeChars .. " chars")
  d("  encode: " .. Bridge.stats.encodeCount .. " calls, " .. Bridge.stats.encodeChars .. " chars")
  d("  guildUi: " .. Bridge.stats.guildUiDecodeCount .. " sweeps, "
    .. Bridge.stats.guildUiControlsVisited .. " controls visited, "
    .. Bridge.stats.guildUiDecodeSkipped .. " skipped")
  d("  lastSource: " .. (Bridge.stats.lastSource ~= "" and Bridge.stats.lastSource or "(none)"))
end

local TOGGLE_MAP = {
  ["chat.receive"] = "chatReceive",
  ["chat.send"] = "chatSend",
  ["guild.api"] = "guildApi",
  ["guild.ui"] = "guildUi",
}

local function HandleToggle(key, value)
  local optionKey = TOGGLE_MAP[key]
  if not optionKey then
    d("[Bridge] Unknown option: " .. key)
    d("[Bridge] Available: chat.receive, chat.send, guild.api, guild.ui")
    return
  end
  if value == "on" then
    Bridge.options[optionKey] = true
    d("[Bridge] " .. key .. " = ON")
  elseif value == "off" then
    Bridge.options[optionKey] = false
    d("[Bridge] " .. key .. " = OFF")
  else
    d("[Bridge] " .. key .. " = " .. tostring(Bridge.options[optionKey]))
    d("[Bridge] Usage: /tkbridge " .. key .. " on|off")
  end
end

SLASH_COMMANDS["/tkbridge"] = function(args)
  if not args or args == "" then
    PrintStatus()
    return
  end

  if args == "stats" then
    PrintStats()
    return
  end

  if args == "stats reset" then
    ResetStats()
    d("[Bridge] Stats reset.")
    return
  end

  if args == "apis" then
    d("[Bridge] Wrapped APIs:")
    for funcName in pairs(Bridge.originalApis) do
      local current = _G[funcName]
      local original = Bridge.originalApis[funcName]
      local status = (current ~= original) and "wrapped" or "restored"
      d("  " .. funcName .. ": " .. status)
    end
    return
  end

  -- 토글 명령: /tkbridge chat.receive on|off
  local key, value = args:match("^(%S+)%s+(%S+)$")
  if key then
    HandleToggle(key, value)
    return
  end

  -- 키만 입력: /tkbridge chat.receive
  local keyOnly = args:match("^(%S+)$")
  if keyOnly and TOGGLE_MAP[keyOnly] then
    HandleToggle(keyOnly)
    return
  end

  d("[Bridge] Commands:")
  d("  /tkbridge              - status")
  d("  /tkbridge stats        - conversion stats")
  d("  /tkbridge stats reset  - reset stats")
  d("  /tkbridge apis         - wrapped API status")
  d("  /tkbridge <key> on|off - toggle feature")
  d("  Keys: chat.receive, chat.send, guild.api, guild.ui")
end

EVENT_MANAGER:RegisterForEvent(Bridge.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
EVENT_MANAGER:RegisterForEvent(Bridge.name .. "_Activated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
