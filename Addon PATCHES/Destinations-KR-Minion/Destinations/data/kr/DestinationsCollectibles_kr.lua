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

-- Korean override placeholder for Destinations collectibles.
-- The base English collectible data is loaded first and kept as-is for now.
