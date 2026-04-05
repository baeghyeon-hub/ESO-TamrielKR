-- ============================================================
-- TamrielKR IME: Main Entry Point
-- English keystrokes -> Korean composition for macOS ESO users
-- ============================================================

local IME = {
  name = "TamrielKR_IME",
  enabled = false,
  composer = nil,
  composing = false,
  prevCharCursor = 0,       -- cursor in CHARACTER units (Mac uses this)
  prevTextLen = 0,          -- text length in BYTES
  composingByteLen = 0,     -- composing char byte length
  composingInsertPos = 0,   -- composing char byte position (1-based)
  hooked = false,
  debugMode = false,
}

local KM = TamrielKR_IME_KeyMap

-- ============================================================
-- UTF-8 helpers: convert between character and byte positions
-- ============================================================

-- Character position -> byte position (end of char at charPos)
local function CharToBytePos(text, charPos)
  local bytePos = 0
  local chars = 0
  while chars < charPos and bytePos < #text do
    local b = text:byte(bytePos + 1)
    if b < 0x80 then
      bytePos = bytePos + 1
    elseif b < 0xE0 then
      bytePos = bytePos + 2
    elseif b < 0xF0 then
      bytePos = bytePos + 3
    else
      bytePos = bytePos + 4
    end
    chars = chars + 1
  end
  return bytePos
end

-- Byte position -> character position
local function ByteToCharPos(text, targetBytePos)
  local bytePos = 0
  local chars = 0
  while bytePos < targetBytePos and bytePos < #text do
    local b = text:byte(bytePos + 1)
    if b < 0x80 then
      bytePos = bytePos + 1
    elseif b < 0xE0 then
      bytePos = bytePos + 2
    elseif b < 0xF0 then
      bytePos = bytePos + 3
    else
      bytePos = bytePos + 4
    end
    chars = chars + 1
  end
  return chars
end

-- Count characters in UTF-8 text
local function Utf8CharCount(text)
  return ByteToCharPos(text, #text)
end

-- ============================================================
-- Get edit control safely via CHAT_SYSTEM
-- ============================================================

local function GetEditControl()
  if CHAT_SYSTEM and CHAT_SYSTEM.textEntry and CHAT_SYSTEM.textEntry.editControl then
    return CHAT_SYSTEM.textEntry.editControl
  end
  return nil
end

-- ============================================================
-- Debug / Status
-- ============================================================

local function DebugLog(msg)
  if IME.debugMode then
    d("[IME] " .. msg)
  end
end

local function ShowStatus(msg)
  if CHAT_SYSTEM and CHAT_SYSTEM.AddMessage then
    CHAT_SYSTEM:AddMessage(msg)
  else
    d(msg)
  end
end

-- ============================================================
-- Toggle IME on/off
-- ============================================================

function TamrielKR_IME_Toggle()
  IME.enabled = not IME.enabled
  if IME.enabled then
    IME.composer = TamrielKR_IME_Composer:New()
    IME.composingByteLen = 0
    IME.composingInsertPos = 0
    IME.prevCharCursor = 0
    IME.prevTextLen = 0
    local editCtrl = GetEditControl()
    if editCtrl then
      pcall(function()
        IME.prevCharCursor = editCtrl:GetCursorPosition() or 0
        IME.prevTextLen = #(editCtrl:GetText() or "")
      end)
    end
    ShowStatus("[TamrielKR IME] |c00FF00ON|r - English keys -> Korean")
  else
    if IME.composer and IME.composer.state ~= "EMPTY" then
      local remaining = IME.composer:Reset()
      if remaining and remaining ~= "" then
        local editCtrl = GetEditControl()
        if editCtrl and IME.composingByteLen > 0 and IME.composingInsertPos > 0 then
          pcall(function()
            local text = editCtrl:GetText() or ""
            local before = text:sub(1, IME.composingInsertPos - 1)
            local after = text:sub(IME.composingInsertPos + IME.composingByteLen)
            local newText = before .. remaining .. after
            IME.composing = true
            editCtrl:SetText(newText)
            editCtrl:SetCursorPosition(ByteToCharPos(newText, IME.composingInsertPos - 1 + #remaining))
            IME.composing = false
          end)
        end
      end
    end
    IME.composingByteLen = 0
    IME.composingInsertPos = 0
    ShowStatus("[TamrielKR IME] |cFF0000OFF|r")
  end
end

-- ============================================================
-- TextChanged hook
-- ============================================================

local function OnTextChanged(control, newText)
  if IME.composing then return end
  if not IME.enabled then return end
  if not IME.composer then return end

  local editCtrl = GetEditControl()
  if not editCtrl then return end

  -- Get text: prefer newText parameter
  local text = (type(newText) == "string" and newText ~= "") and newText or nil
  if not text then
    local ok, result = pcall(function() return editCtrl:GetText() end)
    if ok and result then text = result end
  end
  if not text then return end

  -- Get cursor (CHARACTER-based on Mac)
  local charCursor = 0
  local ok
  ok, charCursor = pcall(function() return editCtrl:GetCursorPosition() end)
  if not ok or not charCursor then charCursor = Utf8CharCount(text) end

  -- Convert char cursor to byte position for text operations
  local byteCursor = CharToBytePos(text, charCursor)

  -- Detect changes
  local textLenDiff = #text - IME.prevTextLen
  local charDelta = charCursor - IME.prevCharCursor

  DebugLog(string.format("charCur=%d prevChar=%d charDelta=%d byteCur=%d textDiff=%d len=%d",
    charCursor, IME.prevCharCursor, charDelta, byteCursor, textLenDiff, #text))

  -- Single ASCII char typed: charDelta=1 (one new char), textLenDiff=1 (one byte = ASCII)
  if charDelta == 1 and textLenDiff == 1 and byteCursor >= 1 and byteCursor <= #text then
    local newChar = text:sub(byteCursor, byteCursor)
    local jamo = KM.QWERTY_TO_JAMO[newChar]

    if jamo then
      DebugLog("jamo: " .. newChar .. " -> " .. string.format("0x%04X", jamo))

      -- Remove the typed English character
      local beforeNew = text:sub(1, byteCursor - 1)
      local afterNew = text:sub(byteCursor + 1)

      -- Remove old composing character
      local baseText
      if IME.composingByteLen > 0 and IME.composingInsertPos > 0
         and IME.composingInsertPos + IME.composingByteLen - 1 <= #beforeNew then
        baseText = beforeNew:sub(1, IME.composingInsertPos - 1)
                .. beforeNew:sub(IME.composingInsertPos + IME.composingByteLen)
      else
        baseText = beforeNew
        if IME.composingByteLen > 0 then
          DebugLog("composing mismatch, resetting")
          IME.composer:Reset()
          IME.composingByteLen = 0
          IME.composingInsertPos = 0
        end
      end

      -- Feed jamo to composer
      local committed = IME.composer:Feed(jamo)
      local composing = IME.composer:GetComposing()

      DebugLog("committed=" .. #committed .. "b composing=" .. #composing .. "b state=" .. IME.composer.state)

      -- Build new text
      local resultText = baseText .. committed .. composing .. afterNew
      local resultByteCursor = #baseText + #committed + #composing
      local resultCharCursor = ByteToCharPos(resultText, resultByteCursor)

      -- Apply
      IME.composing = true
      editCtrl:SetText(resultText)
      editCtrl:SetCursorPosition(resultCharCursor)
      IME.composing = false

      -- Update tracking
      IME.prevCharCursor = resultCharCursor
      IME.prevTextLen = #resultText
      IME.composingByteLen = #composing
      IME.composingInsertPos = (#composing > 0) and (#baseText + #committed + 1) or 0

      return

    else
      -- Non-jamo: commit composition
      if IME.composer.state ~= "EMPTY" then
        local committed = IME.composer:Reset()
        if committed ~= "" and IME.composingByteLen > 0 and IME.composingInsertPos > 0
           and IME.composingInsertPos + IME.composingByteLen - 1 <= #text then
          local before = text:sub(1, IME.composingInsertPos - 1)
          local after = text:sub(IME.composingInsertPos + IME.composingByteLen)
          local resultText = before .. committed .. after
          local adj = #committed - IME.composingByteLen
          local newByteCursor = math.max(0, byteCursor + adj)
          local newCharCursor = ByteToCharPos(resultText, newByteCursor)

          IME.composing = true
          editCtrl:SetText(resultText)
          editCtrl:SetCursorPosition(newCharCursor)
          IME.composing = false

          IME.prevCharCursor = newCharCursor
          IME.prevTextLen = #resultText
          IME.composingByteLen = 0
          IME.composingInsertPos = 0
          return
        end
      end
      IME.prevCharCursor = charCursor
      IME.prevTextLen = #text
      IME.composingByteLen = 0
      IME.composingInsertPos = 0
    end

  elseif charDelta < 0 and textLenDiff < 0 then
    -- Backspace
    if IME.composingByteLen > 0 and IME.composer.state ~= "EMPTY" then
      local handled = IME.composer:Backspace()
      if handled then
        local composing = IME.composer:GetComposing()
        local pos = IME.composingInsertPos
        if pos > #text + 1 then pos = #text + 1 end

        local resultText = text:sub(1, pos - 1) .. composing .. text:sub(pos)
        local resultByteCursor = pos - 1 + #composing
        local resultCharCursor = ByteToCharPos(resultText, resultByteCursor)

        IME.composing = true
        editCtrl:SetText(resultText)
        editCtrl:SetCursorPosition(resultCharCursor)
        IME.composing = false

        IME.prevCharCursor = resultCharCursor
        IME.prevTextLen = #resultText
        IME.composingByteLen = #composing
        if #composing == 0 then IME.composingInsertPos = 0 end
        return
      end
    end
    IME.prevCharCursor = charCursor
    IME.prevTextLen = #text
    if IME.composer.state == "EMPTY" then
      IME.composingByteLen = 0
      IME.composingInsertPos = 0
    end

  elseif textLenDiff == 0 then
    -- Text size unchanged: encoding (Bridge Korean→CJK), cursor movement, or no change
    -- Do NOT reset composition - just ignore
    DebugLog("textLenDiff=0, ignoring (encoding/cursor)")
    return

  else
    -- Complex change - commit
    DebugLog("complex change, committing")
    if IME.composer.state ~= "EMPTY" then
      local committed = IME.composer:Reset()
      if committed ~= "" and IME.composingByteLen > 0 and IME.composingInsertPos > 0
         and IME.composingInsertPos + IME.composingByteLen - 1 <= #text then
        local before = text:sub(1, IME.composingInsertPos - 1)
        local after = text:sub(IME.composingInsertPos + IME.composingByteLen)
        local resultText = before .. committed .. after
        local adj = #committed - IME.composingByteLen
        local newByteCursor = math.max(0, byteCursor + adj)
        local newCharCursor = ByteToCharPos(resultText, newByteCursor)

        IME.composing = true
        editCtrl:SetText(resultText)
        editCtrl:SetCursorPosition(newCharCursor)
        IME.composing = false

        IME.prevCharCursor = newCharCursor
        IME.prevTextLen = #resultText
      else
        IME.prevCharCursor = charCursor
        IME.prevTextLen = #text
      end
    else
      IME.prevCharCursor = charCursor
      IME.prevTextLen = #text
    end
    IME.composingByteLen = 0
    IME.composingInsertPos = 0
  end
end

-- ============================================================
-- Initialization
-- ============================================================

local function HookTextChanged()
  if IME.hooked then return end
  IME.hooked = true
  ZO_PreHook("ZO_ChatTextEntry_TextChanged", OnTextChanged)
end

local function OnPlayerActivated()
  IME.composer = TamrielKR_IME_Composer:New()
  HookTextChanged()
end

local function OnAddonLoaded(_, addonName)
  if addonName ~= IME.name then return end
  EVENT_MANAGER:UnregisterForEvent(IME.name, EVENT_ADD_ON_LOADED)
  ZO_CreateStringId("SI_BINDING_NAME_TAMRIELKR_IME_TOGGLE", "TamrielKR IME (Korean Input)")
  ShowStatus("[TamrielKR IME] Loaded. /tkime to toggle.")
end

EVENT_MANAGER:RegisterForEvent(IME.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
EVENT_MANAGER:RegisterForEvent(IME.name .. "_Activated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

-- ============================================================
-- Slash commands
-- ============================================================

SLASH_COMMANDS["/tkime"] = function(args)
  if args == "on" then
    if not IME.enabled then TamrielKR_IME_Toggle() end
  elseif args == "off" then
    if IME.enabled then TamrielKR_IME_Toggle() end
  elseif args == "debug" then
    IME.debugMode = not IME.debugMode
    d("[IME] Debug: " .. tostring(IME.debugMode))
    d("[IME] state=" .. (IME.composer and IME.composer.state or "nil"))
    d("[IME] compByteLen=" .. IME.composingByteLen .. " compInsertPos=" .. IME.composingInsertPos)
    d("[IME] prevCharCursor=" .. IME.prevCharCursor .. " prevTextLen=" .. IME.prevTextLen)
  elseif args == "test" then
    local testCases = {
      { "gksrmf", "한글" },
      { "dkssud", "안녕" },
      { "dkfrl", "알기" },
      { "gksrnrtlrhf", "한국시골" },
    }
    for _, tc in ipairs(testCases) do
      local c = TamrielKR_IME_Composer:New()
      local result = ""
      for i = 1, #tc[1] do
        local ch = tc[1]:sub(i, i)
        local jamo = KM.QWERTY_TO_JAMO[ch]
        if jamo then result = result .. c:Feed(jamo) end
      end
      result = result .. c:Reset()
      d("[IME Test] " .. tc[1] .. " -> " .. result .. " (expect: " .. tc[2] .. ")")
    end
  else
    TamrielKR_IME_Toggle()
  end
end
