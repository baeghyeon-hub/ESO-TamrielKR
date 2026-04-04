TamrielKR = TamrielKR or {
  name = "TamrielKR",
  version = "1.0.0",
  langCode = "kr",
  defaults = {
    lang = "kr",
  },
}

local realGetCVar = GetCVar
local realSetCVar = SetCVar

-- 다른 애드온 호환: language.2를 항상 "en"으로 보고
-- ESO 엔진은 실제 CVar("kr")로 한글 리소스를 로드하지만
-- Lua 레벨에서는 "en"을 반환하여 TTC 등이 정상 동작
GetCVar = function(cvar)
  if cvar == "language.2" then
    return "en"
  end
  return realGetCVar(cvar)
end

function TamrielKR:SetLanguage(lang)
  if self.savedVars then
    self.savedVars.lang = lang
  end

  realSetCVar("language.2", lang)
  ReloadUI()
end

function TamrielKR:GetLanguage()
  return realGetCVar("language.2")
end
