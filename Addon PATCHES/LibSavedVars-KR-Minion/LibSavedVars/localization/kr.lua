local function TamrielKR_IsKoreanClient()
	if TamrielKR and TamrielKR.GetLanguage then
		local ok, lang = pcall(TamrielKR.GetLanguage, TamrielKR)
		if ok and lang == "kr" then
			return true
		end
	end
	return GetCVar("language.2") == "kr"
end

if not TamrielKR_IsKoreanClient() then
	return
end

local strings = {
    ["SI_LSV_ACCOUNT_WIDE"]    = "계정 공용 설정",
    ["SI_LSV_ACCOUNT_WIDE_TT"] = "아래 설정이 모든 캐릭터에 동일하게 적용됩니다.",
}

for stringId, value in pairs(strings) do
    LIBSAVEDVARS_STRINGS[stringId] = value
end
