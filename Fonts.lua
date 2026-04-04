local addon = TamrielKR
local LMP = LibMediaProvider
local FONT_ROOT = "TamrielKR/fonts/"

function addon:RegisterFonts()
  if self.fontsRegistered then
    return
  end

  self.fontsRegistered = true
  LMP:Register("font", "KR Futura Book", "$(TAMRIELKR_FUTURA_BOOK)")
  LMP:Register("font", "KR Futura Medium", "$(TAMRIELKR_FUTURA_MEDIUM)")
  LMP:Register("font", "KR Futura Bold", "$(TAMRIELKR_FUTURA_BOLD)")
  LMP:Register("font", "KR ProseAntique", "$(TAMRIELKR_PROSE_ANTIQUE)")
  LMP:Register("font", "KR Univers Bold", "$(TAMRIELKR_UNIVERS_BOLD)")
  LMP:Register("font", "KR Univers Medium", "$(TAMRIELKR_UNIVERS_MEDIUM)")
  LMP:Register("font", "KR Univers Condensed", "$(TAMRIELKR_UNIVERS_CONDENSED)")
end

function addon:ApplyFonts()
  local sctFont = FONT_ROOT .. "univers47.slug"

  SetSCTKeyboardFont(sctFont .. "|29|soft-shadow-thick")
  SetSCTGamepadFont(sctFont .. "|35|soft-shadow-thick")
  SetNameplateKeyboardFont(sctFont, 4)
  SetNameplateGamepadFont(sctFont, 4)

  if ZoFontTributeAntique40 then
    ZoFontTributeAntique40:SetFont(FONT_ROOT .. "proseantiquepsmt.slug|40")
  end
  if ZoFontTributeAntique30 then
    ZoFontTributeAntique30:SetFont(FONT_ROOT .. "proseantiquepsmt.slug|30")
  end
  if ZoFontTributeAntique20 then
    ZoFontTributeAntique20:SetFont(FONT_ROOT .. "proseantiquepsmt.slug|20")
  end
end

function addon:ApplyTooltipFonts()
  local fontFile = FONT_ROOT .. "ftn47.slug"
  local styles = {
    "ZO_TOOLTIP_STYLES",
    "ZO_CRAFTING_TOOLTIP_STYLES",
    "ZO_GAMEPAD_DYEING_TOOLTIP_STYLES",
  }

  for _, styleName in ipairs(styles) do
    local styleTable = _G[styleName]
    if styleTable then
      for _, fontData in pairs(styleTable) do
        if type(fontData) == "table" and fontData.fontFace then
          fontData.fontFace = fontFile
        end
      end
    end
  end
end
