local addon = TamrielKR

local ACHIEVEMENT_POINTS_FONT = "TamrielKR/fonts/univers55.slug"
local ACHIEVEMENT_POINTS_WIDTH = 84
local ACHIEVEMENT_POINTS_HEIGHT = 28
local ACHIEVEMENT_POINTS_MIN_SIZE = 20
local ACHIEVEMENT_POINTS_MAX_SIZE = 36
local ACHIEVEMENT_POINTS_SCALE = 0.9
local ACHIEVEMENT_POINTS_SIZE_RATIO = 0.62
local ACHIEVEMENT_POINTS_OFFSET_X = -10
local ACHIEVEMENT_POINTS_OFFSET_Y = 1
local ACHIEVEMENT_DATE_OFFSET_X = 0
local ACHIEVEMENT_DATE_OFFSET_Y = 2

local function FindAchievementDateLabel(target, points)
  if type(target) == "table" and target.date then
    return target.date
  end

  if points and points.GetName then
    local pointName = points:GetName()
    if pointName and pointName:find("Points", 1, true) then
      local sibling = _G[pointName:gsub("Points", "Date")]
      if sibling then
        return sibling
      end
    end
  end

  local parent = points and points.GetParent and points:GetParent() or nil
  if parent and parent.GetNamedChild then
    for _, childName in ipairs({ "Date", "AchievementDate", "CompletedDate" }) do
      local child = parent:GetNamedChild(childName)
      if child then
        return child
      end
    end
  end

  return nil
end

local function IsAchievementPointsCandidate(control)
  if not control or type(control) ~= "userdata" then
    return false
  end

  local controlName = control.GetName and control:GetName()
  if controlName and controlName:lower():find("points", 1, true) then
    return true
  end

  if control.GetText and control.SetFont then
    local text = control:GetText()
    if text and text ~= "" and text:match("^%d+$") then
      return true
    end
  end

  return false
end

local function FindAchievementPointsLabel(target)
  if not target then
    return nil
  end

  if type(target) == "table" then
    if target.points then
      return target.points
    end

    if target.control then
      local nested = FindAchievementPointsLabel(target.control)
      if nested then
        return nested
      end
    end
  end

  if type(target) ~= "userdata" then
    return nil
  end

  if IsAchievementPointsCandidate(target) then
    return target
  end

  if target.GetNamedChild then
    for _, childName in ipairs({ "Points", "AchievementPoints", "PointsLabel" }) do
      local child = target:GetNamedChild(childName)
      if child then
        return child
      end
    end
  end

  return nil
end

local function FindPointsLabelInControlTree(control, depth)
  if not control or depth < 0 then
    return nil
  end

  local direct = FindAchievementPointsLabel(control)
  if direct then
    return direct
  end

  if control.GetNumChildren and control.GetChild then
    for childIndex = 1, control:GetNumChildren() do
      local child = control:GetChild(childIndex)
      local nested = FindPointsLabelInControlTree(child, depth - 1)
      if nested then
        return nested
      end
    end
  end

  return nil
end

local function ResolveAchievementFontParts(fontString)
  if not fontString or fontString == "" then
    return ACHIEVEMENT_POINTS_FONT, ACHIEVEMENT_POINTS_MAX_SIZE, nil
  end

  local fileName, fontSize, fontEffect = fontString:match("([^|]+)|(%d+)|?(.*)")
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

  return ACHIEVEMENT_POINTS_FONT, ACHIEVEMENT_POINTS_MAX_SIZE, nil
end

local function FixPointsLabel(target)
  local points = FindAchievementPointsLabel(target)
  if not points then
    return false
  end

  local parent = points.GetParent and points:GetParent() or nil
  if parent and points.ClearAnchors and points.SetAnchor then
    points:ClearAnchors()
    points:SetAnchor(TOPRIGHT, parent, TOPRIGHT, ACHIEVEMENT_POINTS_OFFSET_X, ACHIEVEMENT_POINTS_OFFSET_Y)
  end

  if points.SetWidth then
    points:SetWidth(ACHIEVEMENT_POINTS_WIDTH)
  end
  if points.SetDimensionConstraints then
    points:SetDimensionConstraints(ACHIEVEMENT_POINTS_WIDTH, 0, ACHIEVEMENT_POINTS_WIDTH, 0)
  end
  if points.SetHeight then
    points:SetHeight(ACHIEVEMENT_POINTS_HEIGHT)
  end
  if points.SetHorizontalAlignment then
    points:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
  end
  if points.SetVerticalAlignment then
    points:SetVerticalAlignment(TEXT_ALIGN_CENTER)
  end
  if points.SetMultiLine then
    points:SetMultiLine(false)
  end
  if points.SetMaxLineCount then
    points:SetMaxLineCount(1)
  end
  if points.SetScale then
    points:SetScale(ACHIEVEMENT_POINTS_SCALE)
  end

  if not points.SetFont then
    return false
  end

  local _, baseSize, effect = ResolveAchievementFontParts(points:GetFont())
  local newSize = tonumber(baseSize) or ACHIEVEMENT_POINTS_MAX_SIZE
  newSize = math.floor(newSize * ACHIEVEMENT_POINTS_SIZE_RATIO)
  newSize = zo_clamp(newSize, ACHIEVEMENT_POINTS_MIN_SIZE, ACHIEVEMENT_POINTS_MAX_SIZE)

  local newFont = string.format("%s|%d", ACHIEVEMENT_POINTS_FONT, newSize)
  if effect and effect ~= "" then
    newFont = newFont .. "|" .. effect
  end

  points:SetFont(newFont)

  local date = FindAchievementDateLabel(target, points)
  if date then
    if date.ClearAnchors and date.SetAnchor then
      date:ClearAnchors()
      date:SetAnchor(TOPRIGHT, points, BOTTOMRIGHT, ACHIEVEMENT_DATE_OFFSET_X, ACHIEVEMENT_DATE_OFFSET_Y)
    end
    if date.SetHorizontalAlignment then
      date:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    end
    if date.SetVerticalAlignment then
      date:SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
    end
    if date.SetMultiLine then
      date:SetMultiLine(false)
    end
    if date.SetMaxLineCount then
      date:SetMaxLineCount(1)
    end
  end

  return true
end

local function FixAchievementPointsFromArgs(...)
  for index = 1, select("#", ...) do
    if FixPointsLabel(select(index, ...)) then
      return
    end
  end
end

local function RefreshVisibleAchievementPoints()
  local scrollChild = _G["ZO_AchievementsContentsContentListScrollChild"]

  if not scrollChild and _G["ZO_AchievementsContentsContentList"] and _G["ZO_AchievementsContentsContentList"].GetNamedChild then
    scrollChild = _G["ZO_AchievementsContentsContentList"]:GetNamedChild("ScrollChild")
  end

  if scrollChild and scrollChild.GetNumChildren and scrollChild.GetChild then
    for childIndex = 1, scrollChild:GetNumChildren() do
      local rowControl = scrollChild:GetChild(childIndex)
      local points = FindPointsLabelInControlTree(rowControl, 4)
      if points then
        FixPointsLabel(points)
      end
    end
  end

  local missCount = 0
  for index = 1, 200 do
    local control = _G[string.format("ZO_Achievement%dPoints", index)]
    if control then
      missCount = 0
      FixPointsLabel(control)
    else
      missCount = missCount + 1
      if missCount >= 20 and index > 20 then
        break
      end
    end
  end
end

local function ScheduleAchievementPointsRefresh()
  zo_callLater(RefreshVisibleAchievementPoints, 10)
  zo_callLater(RefreshVisibleAchievementPoints, 100)
  zo_callLater(RefreshVisibleAchievementPoints, 300)
  zo_callLater(RefreshVisibleAchievementPoints, 600)
  zo_callLater(RefreshVisibleAchievementPoints, 1000)
end

function addon:HookAchievementUI()
  if self.achievementHooked then
    return
  end

  if not ACHIEVEMENTS then
    self.achievementHookRetryCount = (self.achievementHookRetryCount or 0) + 1
    if self.achievementHookRetryCount <= 10 then
      zo_callLater(function()
        addon:HookAchievementUI()
      end, 1000)
    end
    return
  end

  self.achievementHooked = true

  for _, methodName in ipairs({ "SetupAchievement", "SetupBaseAchievement", "Row_Setup" }) do
    if ACHIEVEMENTS[methodName] then
      SecurePostHook(ACHIEVEMENTS, methodName, function(_, control, ...)
        FixAchievementPointsFromArgs(control, ...)
      end)
    end
  end

  if ACHIEVEMENTS.list and ACHIEVEMENTS.list.dataTypes then
    for _, dataType in pairs(ACHIEVEMENTS.list.dataTypes) do
      if dataType.setupCallback then
        local originalSetup = dataType.setupCallback
        dataType.setupCallback = function(control, data, ...)
          originalSetup(control, data, ...)
          FixAchievementPointsFromArgs(control, data, ...)
        end
      end
    end
  end

  if ACHIEVEMENTS.Refresh then
    SecurePostHook(ACHIEVEMENTS, "Refresh", ScheduleAchievementPointsRefresh)
  end

  local scene = SCENE_MANAGER:GetScene("achievements")
  if scene then
    scene:RegisterCallback("StateChange", function(_, newState)
      if newState == SCENE_SHOWN then
        ScheduleAchievementPointsRefresh()
      end
    end)
  end

  ScheduleAchievementPointsRefresh()
end
