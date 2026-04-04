local addon = TamrielKR

function addon:SetupLanguageUI()
  local flags = { "kr", "en" }

  for index, flagCode in ipairs(flags) do
    local controlName = "TamrielKR_Flag_" .. flagCode
    local control = GetControl(controlName)

    if not control then
      control = CreateControlFromVirtual("TamrielKR_Flag_", TamrielKRUI, "TamrielKR_FlagTemplate", flagCode)
      GetControl(controlName .. "Texture"):SetTexture("TamrielKR/flags/" .. flagCode .. ".dds")

      if self:GetLanguage() ~= flagCode then
        control:SetAlpha(0.3)
        control:SetHandler("OnMouseDown", function()
          addon:SetLanguage(flagCode)
        end)
      end
    end

    control:ClearAnchors()
    control:SetAnchor(LEFT, TamrielKRUI, LEFT, 14 + (index - 1) * 34, 0)
  end

  TamrielKRUI:SetDimensions(25 + #flags * 34, 50)
  TamrielKRUI:SetMouseEnabled(true)
end

function addon:SaveAnchor()
  local isValid, point, _, relativePoint, offsetX, offsetY = TamrielKRUI:GetAnchor()
  if isValid then
    self.savedVars.anchor = { point, relativePoint, offsetX, offsetY }
  end
end
