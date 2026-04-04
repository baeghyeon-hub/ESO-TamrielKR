local self = VOTANS_MINIMAP

self:AddBorderStyle("Default", GetString(SI_VOTANSMINIMAP_BORDER_STYLE_DEFAULT), function(settings, background, frame)
	local alpha = settings.borderAlpha / 100 or 1
	background:SetCenterColor(0, 0, 0, alpha)
	background:SetEdgeColor(0, 0, 0, 0)
	background:SetCenterTexture("")
	background:SetInsets(0, 0, 0, 0)
	frame:SetEdgeTexture("/esoui/art/worldmap/worldmap_frame_edge.dds", 128, 16)
	frame:SetAlpha(1)
	frame:SetHidden(false)
end )

self:AddBorderStyle("ESO", GetString(SI_VOTANSMINIMAP_BORDER_STYLE_ESO), function(settings, background, frame)
	local alpha = settings.borderAlpha / 100 or 1
	background:SetCenterColor(0, 0, 0, alpha)
	background:SetEdgeColor(0, 0, 0, alpha)
	background:SetEdgeTexture("/esoui/art/chatwindow/chat_bg_edge.dds", 256, 128, 16)
	background:SetCenterTexture("/esoui/art/chatwindow/chat_bg_center.dds")
	background:SetInsets(16, 16, -16, -16)
	frame:SetEdgeTexture("VotansMiniMap/WorldMapFrame.dds", 128, 16, 32)
	frame:SetAlpha(1)
	frame:SetHidden(false)
end )

self:AddBorderStyle("Flat", GetString(SI_VOTANSMINIMAP_BORDER_STYLE_FLAT), function(settings, background, frame)
	local alpha = settings.borderAlpha / 100 or 1
	background:SetCenterColor(0, 0, 0, alpha)
	background:SetEdgeColor(0, 0, 0, 0)
	background:SetCenterTexture("")
	background:SetInsets(0, 0, 0, 0)
	frame:SetHidden(true)
end )

self:AddBorderStyle("Gamepad", GetString(SI_VOTANSMINIMAP_BORDER_STYLE_GAMEPAD), function(settings, background, frame)
	local alpha = settings.borderAlpha / 100 or 1
	background:SetCenterColor(0, 0, 0, alpha)
	background:SetEdgeColor(0, 0, 0, 0)
	background:SetCenterTexture("")
	background:SetInsets(0, 0, 0, 0)
	frame:SetEdgeTexture("esoui/art/miscellaneous/gamepad/edgeframegamepadborder.dds", 128, 16)
	frame:SetAlpha(1)
	frame:SetHidden(false)
end )

self:AddBorderStyle("Modern", GetString(SI_VOTANSMINIMAP_BORDER_STYLE_MODERN), function(settings, background, frame)
	local alpha = settings.borderAlpha / 100 or 1
	background:SetCenterColor(0.5, 0.5, 0.5, alpha)
	background:SetEdgeColor(0, 0, 0, 0)
	background:SetCenterTexture("")
	background:SetInsets(11, 6, -9, -10)
	background:SetAnchor(BOTTOMRIGHT, nil, BOTTOMRIGHT, 6, -30)
	frame:SetEdgeTexture("", 128, 16)
	frame:SetAlpha(0)
	frame:SetHidden(false)
end , function(settings, background, frame)
	background:SetAnchor(BOTTOMRIGHT, nil, BOTTOMRIGHT, 6, 0)
end )

self:AddFont("", GetString(SI_VOTANSMINIMAP_FONT_NONE))

self:AddFont("MEDIUM_FONT", GetString(SI_VOTANSMINIMAP_FONT_KEYBOARD_MEDIUM))
self:AddFont("BOLD_FONT", GetString(SI_VOTANSMINIMAP_FONT_KEYBOARD_BOLD))
self:AddFont("CHAT_FONT", GetString(SI_VOTANSMINIMAP_FONT_KEYBOARD_CHAT))

self:AddFont("GAMEPAD_LIGHT_FONT", GetString(SI_VOTANSMINIMAP_FONT_GAMEPAD_LIGHT))
self:AddFont("GAMEPAD_MEDIUM_FONT", GetString(SI_VOTANSMINIMAP_FONT_GAMEPAD_MEDIUM))
self:AddFont("GAMEPAD_BOLD_FONT", GetString(SI_VOTANSMINIMAP_FONT_GAMEPAD_BOLD))

self:AddFont("ANTIQUE_FONT", GetString(SI_VOTANSMINIMAP_FONT_ANTIQUE))
self:AddFont("HANDWRITTEN_FONT", GetString(SI_VOTANSMINIMAP_FONT_HANDWRITTEN))
self:AddFont("STONE_TABLET_FONT", GetString(SI_VOTANSMINIMAP_FONT_STONE_TABLET))

self:AddFontSize(12, GetString(SI_VOTANSMINIMAP_FONT_SIZE_SMALLER), 7)
self:AddFontSize(15, GetString(SI_VOTANSMINIMAP_FONT_SIZE_SMALL), 6)
self:AddFontSize(16, GetString(SI_VOTANSMINIMAP_FONT_SIZE_MEDIUM), 4)
self:AddFontSize(19, GetString(SI_VOTANSMINIMAP_FONT_SIZE_LARGE), 2)
self:AddFontSize(22, GetString(SI_VOTANSMINIMAP_FONT_SIZE_HUGE), 2)
