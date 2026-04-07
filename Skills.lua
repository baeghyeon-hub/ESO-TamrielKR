local addon = TamrielKR

local SKILL_INFO_RANK_NAME = "ZO_SkillsSkillInfoRank"
local SKILL_INFO_TITLE_NAME = "ZO_SkillsSkillInfoName"
local SKILL_INFO_UPDATE_NAME = "TamrielKR_SkillsRefresh"
local CRAFT_SKILL_UPDATE_NAME = "TamrielKR_CraftSkillRefresh"

local SKILL_INFO_RANK_FALLBACK_FONT = "TamrielKR/fonts/univers47.slug"

-- 서브클래싱 패널 랭크 라벨 (Univers67 원본 기준)
local SUBCLASS_RANK_HEIGHT = 67
local SUBCLASS_RANK_FONT_SIZE = 40

-- 크래프팅 스테이션 SkillInfo 컨트롤 접두사
local CRAFT_SKILL_INFO_PREFIXES = {
  "ZO_SmithingTopLevelSkillInfo",       -- 대장장이/재봉/보석세공
  "ZO_EnchantingTopLevelSkillInfo",     -- 부여
  "ZO_AlchemyTopLevelSkillInfo",        -- 연금술
  "ZO_ProvisionerTopLevelSkillInfo",    -- 요리
}
-- 크래프팅 랭크: 원본 width=60 height=미지정(auto)
-- Name은 Rank의 TOPRIGHT에 앵커 → Rank 폭 변경하면 Name 위치도 밀림
-- 폭을 늘리지 않고, 폰트 재적용만 수행
local CRAFT_RANK_FONT_SIZE = 54

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

-- ============================================================
-- 크래프팅 스테이션 SkillInfo 수정
-- ============================================================

local function FixCraftSkillInfoRank(rank)
  if not rank or not rank.GetText or not rank.SetFont or not rank.GetFont then
    return
  end

  local text = rank:GetText()
  if not text or text == "" or not text:match("^%d+$") then
    return
  end

  -- 원본: width=60, height=auto, anchor=LEFT
  -- Name이 Rank의 TOPRIGHT에 앵커 → 폭/높이를 변경하면 Name 위치가 깨짐
  -- 폰트 재적용만 수행하여 한글 폰트 메트릭에서의 렌더링 보정
  ConfigureSingleLineLabel(rank, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

  local fontFile, _, effect = ResolveFontParts(rank:GetFont(), SKILL_INFO_RANK_FALLBACK_FONT, CRAFT_RANK_FONT_SIZE)
  local newFont = string.format("%s|%d", fontFile, CRAFT_RANK_FONT_SIZE)
  if effect and effect ~= "" then
    newFont = newFont .. "|" .. effect
  end

  rank:SetFont(newFont)
  rank:SetText(text)
end

local function FixCraftSkillInfoName(name)
  if not name then
    return
  end

  -- 앵커/dimension을 건드리지 않고 텍스트 넘침만 ellipsis로 처리
  ConfigureSingleLineLabel(name, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

local function RefreshCraftSkillInfo()
  if addon:GetLanguage() ~= "kr" then
    return
  end

  for _, prefix in ipairs(CRAFT_SKILL_INFO_PREFIXES) do
    local rank = rawget(_G, prefix .. "Rank")
    if rank then
      FixCraftSkillInfoRank(rank)
    end
    local name = rawget(_G, prefix .. "Name")
    if name then
      FixCraftSkillInfoName(name)
    end
  end
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

-- ============================================================
-- 크래프팅 씬 리프레시
-- ============================================================

local function StartCraftSkillRefresh()
  EVENT_MANAGER:UnregisterForUpdate(CRAFT_SKILL_UPDATE_NAME)
  EVENT_MANAGER:RegisterForUpdate(CRAFT_SKILL_UPDATE_NAME, 100, RefreshCraftSkillInfo)
  zo_callLater(RefreshCraftSkillInfo, 10)
  zo_callLater(RefreshCraftSkillInfo, 100)
  zo_callLater(RefreshCraftSkillInfo, 300)
end

local function StopCraftSkillRefresh()
  EVENT_MANAGER:UnregisterForUpdate(CRAFT_SKILL_UPDATE_NAME)
end

-- ============================================================
-- 훅 등록
-- ============================================================

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

  -- 스킬 패널
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

  -- 크래프팅 스테이션
  local craftScenes = {
    "smithing", "enchanting", "alchemy", "provisioner",
    "gamepad_smithing", "gamepad_enchanting", "gamepad_alchemy", "gamepad_provisioner",
  }
  for _, sceneName in ipairs(craftScenes) do
    local scene = SCENE_MANAGER:GetScene(sceneName)
    if scene then
      scene:RegisterCallback("StateChange", function(_, newState)
        if newState == SCENE_SHOWN then
          StartCraftSkillRefresh()
        elseif newState == SCENE_HIDDEN then
          StopCraftSkillRefresh()
        end
      end)
    end
  end
end
