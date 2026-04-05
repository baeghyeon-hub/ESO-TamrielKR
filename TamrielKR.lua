local addon = TamrielKR

local function OnPlayerActivated()
  addon:ApplyFonts()
  addon:HookSkillsUI()
  addon:HookGuildRosterUI()
end

local function OnAddonLoaded(_, addonName)
  if addonName ~= addon.name then
    return
  end

  EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)
  addon.savedVars = ZO_SavedVars:NewAccountWide("TamrielKR_Variables", 1, nil, addon.defaults)

  local currentLang = addon:GetLanguage()
  if currentLang == "en" and addon.savedVars.lang == "kr" then
    SetCVar("language.2", "kr")
    SetCVar("IgnorePatcherLanguageSetting", 1)
    ReloadUI()
    return
  end

  if currentLang ~= "en" then
    SetCVar("IgnorePatcherLanguageSetting", 1)
  else
    SetCVar("IgnorePatcherLanguageSetting", 0)
  end

  addon:RegisterFonts()
  addon:ApplyFonts()
  addon:ApplyTooltipFonts()
  addon:SetupLanguageUI()

  local anchor = addon.savedVars.anchor or { BOTTOMRIGHT, BOTTOMRIGHT, 0, 7 }
  TamrielKRUI:ClearAnchors()
  TamrielKRUI:SetAnchor(anchor[1], GuiRoot, anchor[2], anchor[3], anchor[4])

  local mainMenu = SCENE_MANAGER:GetScene("gameMenuInGame")
  if mainMenu then
    mainMenu:RegisterCallback("StateChange", function(_, newState)
      if newState == SCENE_SHOWN then
        TamrielKRUI:SetHidden(false)
      elseif newState == SCENE_HIDDEN then
        TamrielKRUI:SetHidden(true)
      end
    end)
  end
end

-- 디버그: 퀘스트 조건 텍스트 바이트 덤프
SLASH_COMMANDS["/tkqdump"] = function()
  for i = 1, MAX_JOURNAL_QUESTS do
    for s = 1, GetJournalQuestNumSteps(i) do
      for c = 1, GetJournalQuestNumConditions(i, s, c) do
        local t = GetJournalQuestConditionInfo(i, s, c)
        if t ~= "" and t:find("0/") then
          local hex = {}
          for j = 1, #t do
            hex[#hex + 1] = string.format("%02X", t:byte(j))
          end
          d("[tkqdump] " .. table.concat(hex, " "))
        end
      end
    end
  end
end

EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
EVENT_MANAGER:RegisterForEvent(addon.name .. "_Activated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
