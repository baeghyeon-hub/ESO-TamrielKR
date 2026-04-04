TamrielKRFontInspector = TamrielKRFontInspector or {}

local addon = TamrielKRFontInspector

addon.name = "TamrielKRFontInspector"
addon.displayName = "TamrielKR Font Inspector"
addon.version = "1.0.0"

local UPDATE_EVENT_NAME = addon.name .. "_Update"
local UPDATE_INTERVAL_MS = 100
local MAX_TEXT_LENGTH = 180
local MAX_PARENT_DEPTH = 8
local MAX_DESCENDANT_DEPTH = 4
local MAX_DESCENDANT_NODES = 80
local MAX_CANDIDATES = 6

local function SafeCall(target, methodName, ...)
  if not target then
    return nil
  end

  local targetType = type(target)
  if targetType ~= "userdata" and targetType ~= "table" then
    return nil
  end

  local method = target[methodName]
  if type(method) ~= "function" then
    return nil
  end

  local ok, a, b, c, d, e = pcall(method, target, ...)
  if ok then
    return a, b, c, d, e
  end

  return nil
end

local function SafeGlobalCall(functionName, ...)
  local func = _G[functionName]
  if type(func) ~= "function" then
    return nil
  end

  local ok, a, b, c, d, e = pcall(func, ...)
  if ok then
    return a, b, c, d, e
  end

  return nil
end

local function NormalizeText(value)
  if value == nil then
    return "<none>"
  end

  local text = tostring(value)
  text = text:gsub("[\r\n]+", " "):gsub("%s%s+", " ")
  if text == "" then
    return "<empty>"
  end

  if #text > MAX_TEXT_LENGTH then
    text = text:sub(1, MAX_TEXT_LENGTH - 3) .. "..."
  end

  return text
end

local function NumberOrFallback(value)
  if value == nil then
    return "?"
  end

  if type(value) == "number" then
    return string.format("%.0f", value)
  end

  return tostring(value)
end

local function GetControlDisplayName(control)
  if control == nil then
    return "<none>"
  end

  local controlType = type(control)
  if controlType ~= "userdata" and controlType ~= "table" then
    return tostring(control)
  end

  local name = SafeCall(control, "GetName")
  if name and name ~= "" then
    return name
  end

  return tostring(control)
end

local function GetParentChain(control)
  local parts = {}
  local current = control
  local depth = 0

  while current and depth < MAX_PARENT_DEPTH do
    parts[#parts + 1] = GetControlDisplayName(current)
    current = SafeCall(current, "GetParent")
    depth = depth + 1
  end

  return table.concat(parts, " <- ")
end

local function CountChildren(control)
  return SafeCall(control, "GetNumChildren") or 0
end

local function GetAnchorTargetName(target)
  if not target then
    return "<none>"
  end

  if type(target) == "number" and target == 0 then
    return "<none>"
  end

  return GetControlDisplayName(target)
end

local function BuildAnchorSummary(control)
  local numAnchors = SafeCall(control, "GetNumAnchors") or 0
  if numAnchors <= 0 then
    return "anchors=none"
  end

  local parts = {}
  for anchorIndex = 1, math.min(numAnchors, 3) do
    local point, relativeTo, relativePoint, offsetX, offsetY = SafeCall(control, "GetAnchor", anchorIndex)
    parts[#parts + 1] = string.format(
      "#%d(%s -> %s:%s %+d,%+d)",
      anchorIndex,
      NormalizeText(point),
      GetAnchorTargetName(relativeTo),
      NormalizeText(relativePoint),
      tonumber(offsetX) or 0,
      tonumber(offsetY) or 0
    )
  end

  return table.concat(parts, " ")
end

local function ResolveFontInfo(fontReference)
  local info = {
    reference = NormalizeText(fontReference),
    file = "<unknown>",
    size = "?",
    effect = "-",
  }

  if not fontReference or fontReference == "" then
    return info
  end

  local fontFile, fontSize, fontEffect = tostring(fontReference):match("([^|]+)|(%d+)|?(.*)")
  if fontFile and fontSize then
    info.file = fontFile
    info.size = fontSize
    if fontEffect and fontEffect ~= "" then
      info.effect = fontEffect
    end
    return info
  end

  local fontObject = _G[fontReference]
  local objectFile, objectSize, objectEffect = SafeCall(fontObject, "GetFontInfo")
  if objectFile then
    info.file = objectFile
    info.size = NumberOrFallback(objectSize)
    if objectEffect and objectEffect ~= "" then
      info.effect = objectEffect
    end
  end

  return info
end

local function FormatCallSite(sourceFile, sourceLine)
  if not sourceFile then
    return "-"
  end

  if sourceLine then
    return string.format("%s:%s", tostring(sourceFile), tostring(sourceLine))
  end

  return tostring(sourceFile)
end

local function CollectDescendantFontCandidates(control, depth, results, state)
  if not control or depth < 0 or state.visitedNodes >= MAX_DESCENDANT_NODES then
    return
  end

  state.visitedNodes = state.visitedNodes + 1

  local childCount = CountChildren(control)
  for childIndex = 1, childCount do
    if #results >= MAX_CANDIDATES or state.visitedNodes >= MAX_DESCENDANT_NODES then
      return
    end

    local child = SafeCall(control, "GetChild", childIndex)
    if child then
      local childText = NormalizeText(SafeCall(child, "GetText"))
      local childFontRef = SafeCall(child, "GetFont")
      local hasUsefulText = childText ~= "<none>" and childText ~= "<empty>"
      local hasUsefulFont = childFontRef ~= nil and tostring(childFontRef) ~= ""

      if hasUsefulText or hasUsefulFont then
        local fontInfo = ResolveFontInfo(childFontRef)
        local textWidth, textHeight = SafeCall(child, "GetTextDimensions")
        results[#results + 1] = {
          depth = MAX_DESCENDANT_DEPTH - depth + 1,
          name = GetControlDisplayName(child),
          text = childText,
          fontReference = fontInfo.reference,
          fontFile = NormalizeText(fontInfo.file),
          fontSize = fontInfo.size,
          fontEffect = NormalizeText(fontInfo.effect),
          dimensions = string.format("%s x %s", NumberOrFallback(SafeCall(child, "GetWidth")), NumberOrFallback(SafeCall(child, "GetHeight"))),
          textDimensions = string.format("%s x %s", NumberOrFallback(textWidth), NumberOrFallback(textHeight)),
          anchors = BuildAnchorSummary(child),
        }
      end

      CollectDescendantFontCandidates(child, depth - 1, results, state)
    end
  end
end

local function BuildCandidateLines(control)
  local candidates = {}
  local state = { visitedNodes = 0 }
  CollectDescendantFontCandidates(control, MAX_DESCENDANT_DEPTH, candidates, state)

  if #candidates == 0 then
    local ancestor = SafeCall(control, "GetParent")
    local ancestorDepth = 0

    while ancestor and ancestorDepth < MAX_PARENT_DEPTH do
      local ancestorCandidates = {}
      local ancestorState = { visitedNodes = 0 }
      CollectDescendantFontCandidates(ancestor, MAX_DESCENDANT_DEPTH, ancestorCandidates, ancestorState)

      if #ancestorCandidates > 0 then
        local lines = {
          string.format("Related ancestor candidates from %s:", GetControlDisplayName(ancestor)),
        }

        for index, candidate in ipairs(ancestorCandidates) do
          lines[#lines + 1] = string.format(
            "  %d. depth=%s name=%s text=%s font=%s file=%s size=%s effect=%s dims=%s textDims=%s %s",
            index,
            NumberOrFallback(candidate.depth),
            NormalizeText(candidate.name),
            candidate.text,
            candidate.fontReference,
            candidate.fontFile,
            candidate.fontSize,
            candidate.fontEffect,
            candidate.dimensions,
            candidate.textDimensions,
            candidate.anchors
          )
        end

        return lines
      end

      ancestor = SafeCall(ancestor, "GetParent")
      ancestorDepth = ancestorDepth + 1
    end

    return {
      "Descendant font candidates: none",
    }
  end

  local lines = {
    "Descendant font candidates:",
  }

  for index, candidate in ipairs(candidates) do
    lines[#lines + 1] = string.format(
      "  %d. depth=%s name=%s text=%s font=%s file=%s size=%s effect=%s dims=%s textDims=%s %s",
      index,
      NumberOrFallback(candidate.depth),
      NormalizeText(candidate.name),
      candidate.text,
      candidate.fontReference,
      candidate.fontFile,
      candidate.fontSize,
      candidate.fontEffect,
      candidate.dimensions,
      candidate.textDimensions,
      candidate.anchors
    )
  end

  return lines
end

function addon:IsOwnControl(control)
  local current = control
  while current do
    if current == self.panel or current == self.highlight then
      return true
    end
    current = SafeCall(current, "GetParent")
  end

  return false
end

function addon:CreateLabel(parent, name, font, anchorPoint, relativeTo, relativePoint, offsetX, offsetY, width, height)
  local label = WINDOW_MANAGER:CreateControl(name, parent, CT_LABEL)
  label:SetAnchor(anchorPoint, relativeTo, relativePoint, offsetX, offsetY)
  label:SetDimensions(width, height)
  label:SetFont(font)
  label:SetColor(1, 1, 1, 1)
  label:SetMouseEnabled(false)
  return label
end

function addon:CreateUI()
  if self.panel then
    return
  end

  local panel = WINDOW_MANAGER:CreateTopLevelWindow(self.name .. "Panel")
  panel:SetDimensions(940, 540)
  panel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 30, 120)
  panel:SetHidden(true)
  panel:SetClampedToScreen(true)
  panel:SetMouseEnabled(false)
  panel:SetMovable(false)
  panel:SetDrawLayer(DL_OVERLAY)
  panel:SetDrawTier(DT_HIGH)
  panel:SetDrawLevel(50)

  local backdrop = WINDOW_MANAGER:CreateControl(nil, panel, CT_BACKDROP)
  backdrop:SetAnchorFill(panel)
  backdrop:SetCenterColor(0, 0, 0, 0.82)
  backdrop:SetEdgeColor(0.9, 0.85, 0.65, 0.95)
  backdrop:SetEdgeTexture("", 2, 2, 2)
  backdrop:SetMouseEnabled(false)

  local title = self:CreateLabel(panel, nil, "ZoFontWinH2", TOPLEFT, panel, TOPLEFT, 16, 14, 900, 28)
  title:SetColor(0.96, 0.9, 0.68, 1)

  local subtitle = self:CreateLabel(panel, nil, "ZoFontGame", TOPLEFT, title, BOTTOMLEFT, 0, 8, 900, 24)
  subtitle:SetColor(0.75, 0.86, 1, 1)
  subtitle:SetText("Hover a control. Commands: /tkfi, /tkfifreeze, /tkfidump")

  local body = self:CreateLabel(panel, nil, "ZoFontGameSmall", TOPLEFT, subtitle, BOTTOMLEFT, 0, 10, 908, 430)
  body:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
  body:SetVerticalAlignment(TEXT_ALIGN_TOP)
  body:SetColor(1, 1, 1, 1)

  local footer = self:CreateLabel(panel, nil, "ZoFontGameSmall", BOTTOMLEFT, panel, BOTTOMLEFT, 16, -14, 908, 22)
  footer:SetColor(0.7, 0.7, 0.7, 1)
  footer:SetText("BackupFont-resolved Korean glyph fallback is not exposed directly. Compare Font ref/file with backupfont_kr.xml.")

  local highlight = WINDOW_MANAGER:CreateTopLevelWindow(self.name .. "Highlight")
  highlight:SetHidden(true)
  highlight:SetMouseEnabled(false)
  highlight:SetClampedToScreen(true)
  highlight:SetDrawLayer(DL_OVERLAY)
  highlight:SetDrawTier(DT_HIGH)
  highlight:SetDrawLevel(60)

  local highlightBackdrop = WINDOW_MANAGER:CreateControl(nil, highlight, CT_BACKDROP)
  highlightBackdrop:SetAnchorFill(highlight)
  highlightBackdrop:SetCenterColor(0, 0, 0, 0)
  highlightBackdrop:SetEdgeColor(0.18, 0.95, 0.95, 0.95)
  highlightBackdrop:SetEdgeTexture("", 3, 3, 3)
  highlightBackdrop:SetMouseEnabled(false)

  self.panel = panel
  self.highlight = highlight
  self.labels = {
    title = title,
    body = body,
    footer = footer,
  }
  self.state = {
    enabled = false,
    frozen = false,
    currentControl = nil,
    lastTarget = nil,
    cachedDump = "",
  }
end

function addon:ShowMessage(message)
  d(string.format("[%s] %s", self.displayName, tostring(message)))
end

function addon:GetHoveredControl()
  local hovered = SafeCall(WINDOW_MANAGER, "GetMouseOverControl")
  if hovered and self:IsOwnControl(hovered) then
    return self.state.currentControl or self.state.lastTarget
  end

  if hovered then
    self.state.lastTarget = hovered
  end

  return hovered
end

function addon:CollectControlInfo(control)
  if not control then
    return {
      title = self.displayName,
      body = "No hovered control",
      dump = "No hovered control",
    }
  end

  local controlName = GetControlDisplayName(control)
  local controlText = NormalizeText(SafeCall(control, "GetText"))
  local fontReference = SafeCall(control, "GetFont")
  local fontInfo = ResolveFontInfo(fontReference)
  local width, height = SafeCall(control, "GetDimensions")
  local textWidth, textHeight = SafeCall(control, "GetTextDimensions")
  local hidden = SafeCall(control, "IsHidden")
  if hidden == nil then
    hidden = SafeCall(control, "GetHidden")
  end
  local alpha = SafeCall(control, "GetAlpha")
  local numChildren = SafeCall(control, "GetNumChildren")
  local drawLayer = SafeCall(control, "GetDrawLayer")
  local drawTier = SafeCall(control, "GetDrawTier")
  local drawLevel = SafeCall(control, "GetDrawLevel")
  local sourceName = SafeGlobalCall("GetControlCreatingSourceName", control)
  local sourceFile, sourceLine = SafeGlobalCall("GetControlCreatingSourceCallSiteInfo", control)

  local lines = {
    string.format("Control: %s", controlName),
    string.format("Object: %s", tostring(control)),
    string.format("Text: %s", controlText),
    string.format("Font ref: %s", fontInfo.reference),
    string.format("Font file: %s", NormalizeText(fontInfo.file)),
    string.format("Font size: %s", fontInfo.size),
    string.format("Font effect: %s", NormalizeText(fontInfo.effect)),
    string.format("Dimensions: %s x %s", NumberOrFallback(width), NumberOrFallback(height)),
    string.format("Text dimensions: %s x %s", NumberOrFallback(textWidth), NumberOrFallback(textHeight)),
    string.format("Children: %s", NumberOrFallback(numChildren)),
    string.format("Hidden: %s", tostring(hidden)),
    string.format("Alpha: %s", NumberOrFallback(alpha)),
    string.format("Draw: layer=%s tier=%s level=%s", NormalizeText(drawLayer), NormalizeText(drawTier), NormalizeText(drawLevel)),
    string.format("Source name: %s", NormalizeText(sourceName)),
    string.format("Call site: %s", FormatCallSite(sourceFile, sourceLine)),
    string.format("Parent chain: %s", GetParentChain(control)),
  }

  local candidateLines = BuildCandidateLines(control)
  for _, line in ipairs(candidateLines) do
    lines[#lines + 1] = line
  end

  local title = self.displayName
  if self.state.frozen then
    title = title .. " [Frozen]"
  end

  local body = table.concat(lines, "\n")
  return {
    title = title,
    body = body,
    dump = body,
  }
end

function addon:UpdateHighlight(control)
  if not control then
    self.highlight:SetHidden(true)
    return
  end

  self.highlight:ClearAnchors()
  self.highlight:SetAnchor(TOPLEFT, control, TOPLEFT, -2, -2)
  self.highlight:SetAnchor(BOTTOMRIGHT, control, BOTTOMRIGHT, 2, 2)
  self.highlight:SetHidden(false)
end

function addon:Refresh()
  if not self.state.enabled then
    return
  end

  local control = self.state.frozen and self.state.currentControl or self:GetHoveredControl()
  self.state.currentControl = control

  local ok, info = pcall(function()
    return self:CollectControlInfo(control)
  end)

  if not ok then
    info = {
      title = self.displayName .. " [Error]",
      body = string.format("Inspector refresh failed:\n%s", tostring(info)),
      dump = tostring(info),
    }
  end

  self.labels.title:SetText(info.title)
  self.labels.body:SetText(info.body)
  self.state.cachedDump = info.dump

  self:UpdateHighlight(control)
end

function addon:SetEnabled(enabled)
  self.state.enabled = enabled
  self.panel:SetHidden(not enabled)

  if enabled then
    EVENT_MANAGER:UnregisterForUpdate(UPDATE_EVENT_NAME)
    EVENT_MANAGER:RegisterForUpdate(UPDATE_EVENT_NAME, UPDATE_INTERVAL_MS, function()
      addon:Refresh()
    end)
    self:Refresh()
    self:ShowMessage("Inspector enabled")
  else
    EVENT_MANAGER:UnregisterForUpdate(UPDATE_EVENT_NAME)
    self.highlight:SetHidden(true)
    self.state.currentControl = nil
    self.state.lastTarget = nil
    self.state.cachedDump = ""
    self:ShowMessage("Inspector disabled")
  end
end

function addon:ToggleFreeze()
  if not self.state.enabled then
    self:SetEnabled(true)
  end

  self.state.frozen = not self.state.frozen
  self:Refresh()
  self:ShowMessage(self.state.frozen and "Inspector frozen" or "Inspector unfrozen")
end

function addon:DumpCurrentControl()
  if not self.state.enabled then
    self:SetEnabled(true)
  end

  self:Refresh()
  if not self.state.cachedDump or self.state.cachedDump == "" then
    self:ShowMessage("No hovered control")
    return
  end

  for line in self.state.cachedDump:gmatch("[^\n]+") do
    self:ShowMessage(line)
  end
end

function addon:HandleSlashCommand(rawInput)
  local input = rawInput and zo_strtrim(rawInput) or ""
  local lowerInput = zo_strlower(input)

  if lowerInput == "" or lowerInput == "toggle" then
    self:SetEnabled(not self.state.enabled)
    return
  end

  if lowerInput == "on" then
    self:SetEnabled(true)
    return
  end

  if lowerInput == "off" then
    self:SetEnabled(false)
    return
  end

  if lowerInput == "freeze" then
    self:ToggleFreeze()
    return
  end

  if lowerInput == "dump" then
    self:DumpCurrentControl()
    return
  end

  self:ShowMessage("Usage: /tkfi [on|off|toggle|freeze|dump]")
end

function addon:Initialize()
  self:CreateUI()

  SLASH_COMMANDS["/tkfi"] = function(input)
    addon:HandleSlashCommand(input)
  end
  SLASH_COMMANDS["/tkfifreeze"] = function()
    addon:ToggleFreeze()
  end
  SLASH_COMMANDS["/tkfidump"] = function()
    addon:DumpCurrentControl()
  end
end

local function OnAddonLoaded(_, addonName)
  if addonName ~= addon.name then
    return
  end

  EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)
  addon:Initialize()
end

EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
