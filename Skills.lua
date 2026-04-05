local addon = TamrielKR

local SKILL_INFO_RANK_NAME = "ZO_SkillsSkillInfoRank"
local SKILL_INFO_TITLE_NAME = "ZO_SkillsSkillInfoName"
local SKILL_INFO_UPDATE_NAME = "TamrielKR_SkillsRefresh"

local SKILL_INFO_RANK_FALLBACK_FONT = "TamrielKR/fonts/univers47.slug"

-- 서브클래싱 패널 랭크 라벨 (Univers67 원본 기준)
local SUBCLASS_RANK_HEIGHT = 67
local SUBCLASS_RANK_FONT_SIZE = 40

local function ResolveFontParts(fontString, fallbackFont, fallbackSize)
  if not fontString or fontString == "" then
    return fallbackFont, fallbackSize, nil
  end

  local fileName, fontSize, fontEffect = tostring(fontString):match("([^|]+)|(%d+)|?(.*)")
  if fileName and fontSize then
    return fileName, tonumber(fontSize), fontEffect
  end

  local fontObject = _G[fontString]
  if fontObject and fontObject.GetFontInfo then
    local objectFileName, objectFontSize, objectFontEffect = fontObject:GetFontInfo()
    if objectFileName and objectFontSize then
      return objectFileName, tonumber(objectFontSize), objectFontEffect
    end
  end

  return fallbackFont, fallbackSize, nil
end

local function ConfigureSingleLineLabel(control, horizontalAlignment, verticalAlignment)
  if not control then
    return
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
  if horizontalAlignment and control.SetHorizontalAlignment then
    control:SetHorizontalAlignment(horizontalAlignment)
  end
  if verticalAlignment and control.SetVerticalAlignment then
    control:SetVerticalAlignment(verticalAlignment)
  end
end

local function FixSkillInfoRankLabel()
  local rank = _G[SKILL_INFO_RANK_NAME]
  if not rank or not rank.GetText or not rank.SetFont then
    return false
  end

  local text = rank:GetText()
  if not text or text == "" or not text:match("^%d+$") then
    return false
  end

  if rank.SetDimensions then
    rank:SetDimensions(84, SUBCLASS_RANK_HEIGHT)
  end
  if rank.SetDimensionConstraints then
    rank:SetDimensionConstraints(84, SUBCLASS_RANK_HEIGHT, 84, SUBCLASS_RANK_HEIGHT)
  end

  ConfigureSingleLineLabel(rank, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

  local fontFile, _, effect = ResolveFontParts(rank:GetFont(), SKILL_INFO_RANK_FALLBACK_FONT, SUBCLASS_RANK_FONT_SIZE)
  local newFont = string.format("%s|%d", fontFile, SUBCLASS_RANK_FONT_SIZE)
  if effect and effect ~= "" then
    newFont = newFont .. "|" .. effect
  end

  rank:SetFont(newFont)
  rank:SetText(text)
  return true
end

local function FixSkillInfoTitleLabel()
  local title = _G[SKILL_INFO_TITLE_NAME]
  if not title then
    return false
  end

  ConfigureSingleLineLabel(title, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
  return true
end

local function FixSubclassRankLabel(rank)
  if not rank or not rank.GetText or not rank.SetFont or not rank.GetFont then
    return
  end

  local text = rank:GetText()
  if not text or text == "" or not text:match("^%d+$") then
    return
  end

  if rank.SetHeight then
    rank:SetHeight(SUBCLASS_RANK_HEIGHT)
  end
  if rank.SetDimensionConstraints then
    rank:SetDimensionConstraints(0, 0, 0, SUBCLASS_RANK_HEIGHT)
  end

  local fontFile, _, effect = ResolveFontParts(rank:GetFont(), SKILL_INFO_RANK_FALLBACK_FONT, SUBCLASS_RANK_FONT_SIZE)
  local newFont = string.format("%s|%d", fontFile, SUBCLASS_RANK_FONT_SIZE)
  if effect and effect ~= "" then
    newFont = newFont .. "|" .. effect
  end

  rank:SetFont(newFont)
  rank:SetText(text)
end

local function FixSubclassSkillInfoRank()
  local rank = rawget(_G, "ZO_SkillsSubclassingPanelSkillsListContainerSkillInfoRank")
  if rank and rank.GetText and rank.SetFont and rank.GetFont then
    local text = rank:GetText()
    if text and text ~= "" and text:match("^%d+$") then
      if rank.SetHeight then
        rank:SetHeight(SUBCLASS_RANK_HEIGHT)
      end
      if rank.SetDimensionConstraints then
        rank:SetDimensionConstraints(0, 0, 0, SUBCLASS_RANK_HEIGHT)
      end

      local fontFile, _, effect = ResolveFontParts(rank:GetFont(), SKILL_INFO_RANK_FALLBACK_FONT, SUBCLASS_RANK_FONT_SIZE)
      local newFont = string.format("%s|%d", fontFile, SUBCLASS_RANK_FONT_SIZE)
      if effect and effect ~= "" then
        newFont = newFont .. "|" .. effect
      end

      rank:SetFont(newFont)
      rank:SetText(text)
    end
  end
end

local function RefreshSubclassRankLabels()
  for list = 1, 5 do
    for row = 1, 30 do
      local rankName = string.format("ZO_SkillsSubclassingPanelClassSkillLineList%dRow%dRank", list, row)
      local rank = rawget(_G, rankName)
      if rank then
        FixSubclassRankLabel(rank)
      end
    end
  end
end

local function RefreshSkillInfoHeader()
  if addon:GetLanguage() ~= "kr" then
    return
  end

  FixSkillInfoRankLabel()
  FixSkillInfoTitleLabel()
  RefreshSubclassRankLabels()
  FixSubclassSkillInfoRank()
end

local function StartSkillsRefresh()
  EVENT_MANAGER:UnregisterForUpdate(SKILL_INFO_UPDATE_NAME)
  EVENT_MANAGER:RegisterForUpdate(SKILL_INFO_UPDATE_NAME, 100, RefreshSkillInfoHeader)
  zo_callLater(RefreshSkillInfoHeader, 10)
  zo_callLater(RefreshSkillInfoHeader, 100)
  zo_callLater(RefreshSkillInfoHeader, 300)
  zo_callLater(RefreshSkillInfoHeader, 600)
end

local function StopSkillsRefresh()
  EVENT_MANAGER:UnregisterForUpdate(SKILL_INFO_UPDATE_NAME)
end

function addon:HookSkillsUI()
  if self.skillsHooked then
    return
  end

  if not SCENE_MANAGER then
    self.skillsHookRetryCount = (self.skillsHookRetryCount or 0) + 1
    if self.skillsHookRetryCount <= 10 then
      zo_callLater(function()
        addon:HookSkillsUI()
      end, 1000)
    end
    return
  end

  self.skillsHooked = true

  local hookedScene = false
  for _, sceneName in ipairs({ "skills", "gamepad_skills", "gamepadSkills" }) do
    local scene = SCENE_MANAGER:GetScene(sceneName)
    if scene then
      hookedScene = true
      scene:RegisterCallback("StateChange", function(_, newState)
        if newState == SCENE_SHOWN then
          StartSkillsRefresh()
        elseif newState == SCENE_HIDDEN then
          StopSkillsRefresh()
        end
      end)

      if scene:IsShowing() then
        StartSkillsRefresh()
      end
    end
  end

  if not hookedScene then
    StartSkillsRefresh()
  end
end
