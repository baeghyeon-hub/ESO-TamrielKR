local Bridge = {
  name = "TamrielKR_Bridge",
  chatReceiveHooked = false,
  chatSendHooked = false,
  guildHooked = false,
}

-- ============================================================
-- UTF-8 유틸리티
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

-- UTF-8 텍스트를 순회하며 매핑 함수를 적용하는 공통 변환기
local function TransformText(text, mapFunc)
  if not text or text == "" then
    return text
  end

  local changed = false
  local parts = {}
  local index = 1
  local length = #text

  while index <= length do
    local byte1 = string.byte(text, index)
    if not byte1 then
      break
    end

    if byte1 < 0x80 then
      parts[#parts + 1] = string.char(byte1)
      index = index + 1
    elseif byte1 >= 0xE0 and byte1 < 0xF0 and index + 2 <= length then
      local byte2 = string.byte(text, index + 1)
      local byte3 = string.byte(text, index + 2)
      if byte2 and byte3 and byte2 >= 0x80 and byte2 < 0xC0 and byte3 >= 0x80 and byte3 < 0xC0 then
        local codepoint = (byte1 - 0xE0) * 0x1000 + (byte2 - 0x80) * 0x40 + (byte3 - 0x80)
        local mapped = mapFunc(codepoint)
        if mapped then
          parts[#parts + 1] = Utf8EncodeCodepoint(mapped)
          changed = true
        else
          parts[#parts + 1] = string.sub(text, index, index + 2)
        end
        index = index + 3
      else
        parts[#parts + 1] = string.char(byte1)
        index = index + 1
      end
    else
      parts[#parts + 1] = string.char(byte1)
      index = index + 1
    end
  end

  if changed then
    return table.concat(parts)
  end

  return text
end

-- ============================================================
-- 코드포인트 매핑
-- ============================================================

-- CJK → 한글 (수신 디코딩: EsoKR → TamrielKR)
local function MapCNKRToKR(codepoint)
  if codepoint >= 0x4E00 and codepoint <= 0x4EFF then
    return codepoint - 0x3D00
  end

  if codepoint >= 0x5F01 and codepoint <= 0x5F5F then
    return codepoint - 0x2DD0
  end

  if codepoint >= 0x6E00 and codepoint <= 0x99AC then
    return codepoint + 0x3E00
  end

  return nil
end

-- 한글 → CJK (송신 인코딩: TamrielKR → EsoKR)
local function MapKRToCNKR(codepoint)
  if codepoint >= 0x1100 and codepoint <= 0x11FF then
    return codepoint + 0x3D00
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
-- 변환 함수
-- ============================================================

local function DecodeCNKR(text)
  return TransformText(text, MapCNKRToKR)
end

local function EncodeCNKR(text)
  return TransformText(text, MapKRToCNKR)
end

-- ============================================================
-- 채팅 수신 훅 (EsoKR → TamrielKR 디코딩)
-- ============================================================

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
    local changed, values = DecodeChatMessageArgs(fromName, text, ...)
    if changed then
      router:FormatAndAddChatMessage(eventCode, channelType, unpack(values))
      return true
    end
  end)
end

-- ============================================================
-- 채팅 송신 훅 (TamrielKR → EsoKR 인코딩)
-- ============================================================

function Bridge:HookChatSend()
  if self.chatSendHooked then
    return
  end

  self.chatSendHooked = true

  -- 글로벌 SendChatMessage 훅 — 모든 채팅 전송이 여기를 통과
  local origSendChatMessage = SendChatMessage
  SendChatMessage = function(text, channel, target, ...)
    return origSendChatMessage(EncodeCNKR(text), channel, target, ...)
  end
end

-- ============================================================
-- 길드 UI 훅 (MOTD/소개말 CJK 디코딩)
-- ============================================================

function Bridge:HookGuildUI()
  if self.guildHooked then
    return
  end

  self.guildHooked = true

  -- 단일 반환값 API: 반환 문자열을 직접 디코딩
  local singleReturnApis = {
    "GetGuildMotD",
    "GetGuildDescription",
    "GetGuildRankCustomName",
  }

  for _, funcName in ipairs(singleReturnApis) do
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

  -- 복수 반환값 API: 모든 문자열 반환값을 디코딩
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

  local guildScenes = { "guildHome", "guildRoster", "guildRanks", "guildHistory", "guildHeraldry" }
  for _, sceneName in ipairs(guildScenes) do
    local scene = SCENE_MANAGER:GetScene(sceneName)
    if scene then
      scene:RegisterCallback("StateChange", function(_, newState)
        if newState == SCENE_SHOWN then
          zo_callLater(function()
            Bridge:DecodeVisibleGuildTexts()
          end, 100)
          zo_callLater(function()
            Bridge:DecodeVisibleGuildTexts()
          end, 500)
        end
      end)
    end
  end
end

function Bridge:DecodeVisibleGuildTexts()
  local containers = { "ZO_GuildHome", "ZO_GuildSharedInfo", "ZO_GuildRoster", "ZO_GuildRanks" }
  for _, containerName in ipairs(containers) do
    local container = _G[containerName]
    if container then
      Bridge:DecodeControlTree(container, 8)
    end
  end
end

function Bridge:DecodeControlTree(control, depth)
  if not control or depth < 0 then
    return
  end

  if control.GetText and control.SetText then
    local text = control:GetText()
    if text and text ~= "" then
      local decoded = DecodeCNKR(text)
      if decoded ~= text then
        control:SetText(decoded)
      end
    end
  end

  if control.GetNumChildren and control.GetChild then
    for i = 1, control:GetNumChildren() do
      Bridge:DecodeControlTree(control:GetChild(i), depth - 1)
    end
  end
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

  Bridge:HookChatReceive()
  Bridge:HookChatSend()
end

SLASH_COMMANDS["/tkbridge"] = function()
  d("[TamrielKR_Bridge v1.0.1]")
  d("  chatReceiveHooked: " .. tostring(Bridge.chatReceiveHooked))
  d("  chatSendHooked: " .. tostring(Bridge.chatSendHooked))
  d("  guildHooked: " .. tostring(Bridge.guildHooked))
  -- 인코딩 테스트
  local test = "테스트"
  local encoded = EncodeCNKR(test)
  if encoded ~= test then
    d("  encode test: OK")
  else
    d("  encode test: FAIL")
  end
end

EVENT_MANAGER:RegisterForEvent(Bridge.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
EVENT_MANAGER:RegisterForEvent(Bridge.name .. "_Activated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
