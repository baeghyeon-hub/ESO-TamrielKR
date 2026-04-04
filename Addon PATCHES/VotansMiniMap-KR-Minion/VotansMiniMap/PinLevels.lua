local addon = VOTANS_MINIMAP

local settingsControls

local function UpdateControls()
	if settingsControls.selected then
		settingsControls:UpdateControls()
	end
end

function addon:InitPinLevels()
	local LibHarvensAddonSettings = LibHarvensAddonSettings or LibStub("LibHarvensAddonSettings-1.0")
	if not LibHarvensAddonSettings then return end

	local settings = LibHarvensAddonSettings:AddAddon(GetString(SI_VOTANSMINIMAP_PINLEVELS_PANEL_TITLE))
	if not settings then return end
	settingsControls = settings
	settings.allowDefaults = true;

	local function UpdatePin(pinType, pin)
		local control = pin:GetControl()
		local singlePinData = ZO_MapPin.PIN_DATA[pinType]
		if singlePinData then
			local labelControl = GetControl(control, "Label")
			local overlayControl = GetControl(control, "Background")
			local highlightControl = GetControl(control, "Highlight")

			local pinLevel = zo_max(singlePinData.level, 1)
			control:SetDrawLevel(pinLevel)

			overlayControl:SetDrawLevel(pinLevel)
			highlightControl:SetDrawLevel(pinLevel - 1)
			labelControl:SetDrawLevel(pinLevel + 1)
		end
	end
	local function UpdateDrawLevel(pinType)
		for _, pin in pairs(addon.pinManager:GetActiveObjects()) do
			if pinType == pin:GetPinType() then UpdatePin(pinType, pin) end
		end
	end

	local function UpdateDrawLevels(pins)
		for _, pin in pairs(addon.pinManager:GetActiveObjects()) do
			local pinType = pin:GetPinType()
			if pins[pinType] then UpdatePin(pinType, pin) end
		end
	end

	local function AddPin(pinType, caption)
		local pinData = ZO_MapPin.PIN_DATA[pinType]
		settings:AddSetting {
			type = LibHarvensAddonSettings.ST_SLIDER,
			label = caption,
			min = 2,
			max = 240,
			step = 1,
			default = pinData.level,
			unit = "",
			getFunction = function() return pinData.level end,
			setFunction = function(value)
				pinData.level = value
				self.account.pinLevels[pinType] = value
				UpdateControls()
				UpdateDrawLevel(pinType)
			end,
		}
		pinData.level = self.account.pinLevels[pinType] or pinData.level
		UpdateDrawLevel(pinType)
	end

	local function AddPins(pins, caption)
		local pinType = next(pins)
		local first = ZO_MapPin.PIN_DATA[pinType]

		settings:AddSetting {
			type = LibHarvensAddonSettings.ST_SLIDER,
			label = caption,
			min = 2,
			max = 240,
			step = 1,
			default = first.level,
			unit = "",
			getFunction = function() return first.level end,
			setFunction = function(value)
				for pinType in pairs(pins) do
					local pinData = ZO_MapPin.PIN_DATA[pinType]
					pinData.level = value
					self.account.pinLevels[pinType] = value
				end
				UpdateControls()
				UpdateDrawLevels(pins)
			end,
		}
		for pinType in pairs(pins) do
			local pinData = ZO_MapPin.PIN_DATA[pinType]
			if first.level ~= pinData.level then
				d("ups", caption)
			end
			pinData.level = self.account.pinLevels[pinType] or pinData.level
		end
		UpdateDrawLevels(pins)

	end

	AddPin(MAP_PIN_TYPE_PLAYER, GetString(SI_BATTLEGROUND_YOU))
	AddPin(MAP_PIN_TYPE_GROUP, GetString(SI_MAPFILTER9))
	AddPin(MAP_PIN_TYPE_GROUP_LEADER, GetString(SI_GROUP_LEADER_TOOLTIP))
	AddPin(MAP_PIN_TYPE_LOCATION, GetString(SI_MAP_INFO_MODE_LOCATIONS))

	AddPins(ZO_MapPin.FAST_TRAVEL_WAYSHRINE_PIN_TYPES, GetString(SI_MAPFILTER8))
	AddPins(ZO_MapPin.POI_PIN_TYPES, GetString(SI_MAPFILTER1))

	AddPins(ZO_MapPin.QUEST_PIN_TYPES, GetString(SI_MAPFILTER4))
	AddPins(ZO_MapPin.MAP_PING_PIN_TYPES, GetString(SI_TOOLTIP_UNIT_MAP_PLAYER_WAYPOINT))
	AddPins(ZO_MapPin.FAST_TRAVEL_KEEP_PIN_TYPES, GetString(SI_VOTANSMINIMAP_PINSIZE_KEEP_FAST_TRAVEL))

	--AddPins(ZO_MapPin.AVA_OBJECTIVE_PIN_TYPES, "AvA Objectives")
	--AddPins(ZO_MapPin.KEEP_PIN_TYPES, "Keeps")
	AddPins(ZO_MapPin.IMPERIAL_CITY_GATE_TYPES, GetString(SI_VOTANSMINIMAP_PIN_IMPERIAL_CITY_GATES))
	-- AddPins(ZO_MapPin.DISTRICT_PIN_TYPES, "Districts")
	AddPins(ZO_MapPin.KILL_LOCATION_PIN_TYPES, GetString(SI_VOTANSMINIMAP_PIN_KILL_LOCATIONS))
	AddPins(ZO_MapPin.FORWARD_CAMP_PIN_TYPES, GetString(SI_VOTANSMINIMAP_PIN_FORWARD_CAMPS))
	AddPins(ZO_MapPin.AVA_RESPAWN_PIN_TYPES, GetString(SI_VOTANSMINIMAP_PIN_AVA_RESPAWN))
	AddPins(ZO_MapPin.AVA_RESTRICTED_LINK_PIN_TYPES, GetString(SI_VOTANSMINIMAP_PIN_AVA_RESTRICTED_LINKS))
end

