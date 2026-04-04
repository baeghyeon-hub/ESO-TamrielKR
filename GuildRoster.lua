local addon = TamrielKR

local GUILD_ROSTER_UPDATE_NAME = "TamrielKR_GuildRosterRefresh"
local GUILD_ROSTER_LEVEL_PATTERN = "^ZO_GuildRosterList%d+Row%d+Level$"
local GUILD_ROSTER_ROW_PATTERN = "^ZO_GuildRosterList%d+Row%d+$"
local GUILD_ROSTER_REFRESH_INTERVAL_MS = 33
local GUILD_ROSTER_LEVEL_WIDTH = 60
local GUILD_ROSTER_LEVEL_HEIGHT = 20
local GUILD_ROSTER_LEVEL_FONT_SIZE = 17

local function LooksLikeGuildRosterLevelText(text)
  return text and text ~= "" and text:match("^%d+%.?%.?%.?$")
end

local function IsGuildRosterLevelLabel(control)
  if not control or type(control) ~= "userdata" or not control.GetName or not control.GetText then
    return false
  end

  local name = control:GetName()
  if not name or not name:match(GUILD_ROSTER_LEVEL_PATTERN) then
    return false
  end

  return LooksLikeGuildRosterLevelText(control:GetText())
end

local function ResolveControlFontInfo(fontReference)
  if not fontReference or fontReference == "" then
    return nil, nil, nil
  end

  local fontFile, fontSize, fontEffect = tostring(fontReference):match("([^|]+)|(%d+)|?(.*)")
  if fontFile and fontSize then
    return fontFile, tonumber(fontSize), fontEffect
  end

  local fontObject = _G[fontReference]
  if fontObject and fontObject.GetFontInfo then
    local objectFile, objectSize, objectEffect = fontObject:GetFontInfo()
    if objectFile and objectSize then
      return objectFile, tonumber(objectSize), objectEffect
    end
  end

  return nil, nil, nil
end

local function BuildFontString(fontFile, fontSize, fontEffect)
  if not fontFile or not fontSize then
    return nil
  end

  if fontEffect and fontEffect ~= "" then
    return string.format("%s|%d|%s", fontFile, fontSize, fontEffect)
  end

  return string.format("%s|%d", fontFile, fontSize)
end

local function ApplyGuildRosterLevelFont(control, text)
  if not control or not control.GetFont or not control.SetFont then
    return
  end

  local fontFile, fontSize, fontEffect = ResolveControlFontInfo(control:GetFont())
  if not fontFile then
    return
  end

  local finalFont = BuildFontString(fontFile, math.min(fontSize or GUILD_ROSTER_LEVEL_FONT_SIZE, GUILD_ROSTER_LEVEL_FONT_SIZE), fontEffect)
  if finalFont then
    control:SetFont(finalFont)
    if control.SetText and text then
      control:SetText(text)
    end
  end
end

local function FixGuildRosterLevelLabel(control)
  if not IsGuildRosterLevelLabel(control) then
    return false
  end

  local text = control:GetText()

  if control.SetWidth then
    control:SetWidth(GUILD_ROSTER_LEVEL_WIDTH)
  end
  if control.SetHeight then
    control:SetHeight(GUILD_ROSTER_LEVEL_HEIGHT)
  end
  if control.SetDimensions then
    control:SetDimensions(GUILD_ROSTER_LEVEL_WIDTH, GUILD_ROSTER_LEVEL_HEIGHT)
  end
  if control.SetDimensionConstraints then
    control:SetDimensionConstraints(GUILD_ROSTER_LEVEL_WIDTH, GUILD_ROSTER_LEVEL_HEIGHT, GUILD_ROSTER_LEVEL_WIDTH, GUILD_ROSTER_LEVEL_HEIGHT)
  end
  if control.SetMultiLine then
    control:SetMultiLine(false)
  end
  if control.SetMaxLineCount then
    control:SetMaxLineCount(1)
  end
  if control.SetWrapMode and TEXT_WRAP_MODE_ELLIPSIS then
    control:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
  end
  if control.SetHorizontalAlignment then
    control:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
  end
  if control.SetVerticalAlignment then
    control:SetVerticalAlignment(TEXT_ALIGN_CENTER)
  end
  if control.SetText and text then
    control:SetText(text)
  end

  ApplyGuildRosterLevelFont(control, text)

  return true
end

local function RefreshVisibleGuildRosterLevels()
  -- _G를 순회하지 않고 예상되는 컨트롤 이름을 직접 조회
  -- (pairs(_G)는 보호 함수 값 접근 시 taint 에러 발생)
  for list = 1, 5 do
    for row = 1, 30 do
      local rowName = "ZO_GuildRosterList" .. list .. "Row" .. row
      local rowCtrl = rawget(_G, rowName)
      if rowCtrl and type(rowCtrl) == "userdata" and rowCtrl.GetNamedChild then
        local level = rowCtrl:GetNamedChild("Level")
        if level then
          FixGuildRosterLevelLabel(level)
        end
      end
      local levelCtrl = rawget(_G, rowName .. "Level")
      if levelCtrl and type(levelCtrl) == "userdata" then
        FixGuildRosterLevelLabel(levelCtrl)
      end
    end
  end
end

local function StartGuildRosterRefresh()
  EVENT_MANAGER:UnregisterForUpdate(GUILD_ROSTER_UPDATE_NAME)
  EVENT_MANAGER:RegisterForUpdate(GUILD_ROSTER_UPDATE_NAME, GUILD_ROSTER_REFRESH_INTERVAL_MS, RefreshVisibleGuildRosterLevels)
  zo_callLater(RefreshVisibleGuildRosterLevels, 10)
  zo_callLater(RefreshVisibleGuildRosterLevels, 100)
  zo_callLater(RefreshVisibleGuildRosterLevels, 300)
  zo_callLater(RefreshVisibleGuildRosterLevels, 600)
  zo_callLater(RefreshVisibleGuildRosterLevels, 1000)
end

local function ApplyGuildRosterLevelFromRowControl(control)
  if not control or not control.GetNamedChild then
    return
  end

  local level = control:GetNamedChild("Level")
  if level then
    FixGuildRosterLevelLabel(level)
    zo_callLater(function()
      if level and level.GetName then
        FixGuildRosterLevelLabel(level)
      end
    end, 10)
  end
end

function addon:HookGuildRosterUI()
  if self.guildRosterHooked then
    return
  end

  if not SCENE_MANAGER then
    self.guildRosterHookRetryCount = (self.guildRosterHookRetryCount or 0) + 1
    if self.guildRosterHookRetryCount <= 10 then
      zo_callLater(function()
        addon:HookGuildRosterUI()
      end, 1000)
    end
    return
  end

  self.guildRosterHooked = true

  if GUILD_ROSTER_KEYBOARD and GUILD_ROSTER_KEYBOARD.SetupRow then
    SecurePostHook(GUILD_ROSTER_KEYBOARD, "SetupRow", function(_, control)
      ApplyGuildRosterLevelFromRowControl(control)
    end)
  end

  local scene = SCENE_MANAGER:GetScene("guildRoster")
  if scene then
    scene:RegisterCallback("StateChange", function(_, newState)
      if newState == SCENE_SHOWN then
        StartGuildRosterRefresh()
      end
    end)
  end

  StartGuildRosterRefresh()
end
