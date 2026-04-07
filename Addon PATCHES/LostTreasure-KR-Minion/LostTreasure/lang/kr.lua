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

local function SafeStrings(strings)
	for stringId, stringValue in pairs(strings) do
		SafeAddString(_G[stringId], stringValue, 0)
	end
	ZO_ClearTable(strings)
end

local message = {}
table.insert(message, "LOST TREASURE 최신 버전을 사용 중인가요?\n현재 로컬 버전은 %d입니다. 보고를 보내기 전에 먼저 ESOUI/Minion 버전과 비교해 주세요!")
table.insert(message, "*** 이 부분은 수정하지 마세요 ***")
table.insert(message, "Zone: %s")
table.insert(message, "MapId: %d")
table.insert(message, "{ %.4f, %.4f, %%22%s%%22, %d }, -- %s")
table.insert(message, "*** 아래에 메시지를 작성하세요 ***")

local strings = {
	SI_LOST_TREASURE_BUGREPORT_PICKUP_MESSAGE = table.concat(message, "\n"),
	SI_LOST_TREASURE_BUGREPORT_PICKUP_TITLE = "v%d 새 핀: [%d] %s",
	SI_LOST_TREASURE_BUGREPORT_PICKUP_NO_MAP = "열린 지도가 없음",

	SI_LOST_TREASURE_MAP_FILTER_CHECKBOX_NAME = "<<C:1>> (<<C:2>>)",

	SI_LOST_TREASURE_SHOW_ON_MAP_TT = "플레이어 지도에 핀을 표시합니다.",
	SI_LOST_TREASURE_SHOW_ON_COMPASS = "나침반에 표시",
	SI_LOST_TREASURE_SHOW_ON_COMPASS_TT = "나침반에 핀을 표시합니다.",
	SI_LOST_TREASURE_PIN_ICON_TT = "원하는 핀 아이콘을 선택합니다.",
	SI_LOST_TREASURE_PIN_SIZE = "크기",
	SI_LOST_TREASURE_PIN_SIZE_TT = "플레이어 지도에서 핀 크기를 선택합니다.",
	SI_LOST_TREASURE_MARK_OPTION = "표시 옵션",
	SI_LOST_TREASURE_MARK_OPTION_TT = "플레이어 지도와 나침반에서 핀이 언제 보일지 정합니다.",
	SI_LOST_TREASURE_MARK_OPTION1_TT = "보물 지도나 조사 보고서를 연 뒤에만 핀을 표시합니다.",
	SI_LOST_TREASURE_MARK_OPTION2_TT = "인벤토리에 있는 보물 지도와 조사 보고서의 핀을 표시합니다.",
	SI_LOST_TREASURE_MARK_OPTION3_TT = "인벤토리 보유 여부와 상관없이 모든 핀을 표시합니다.",
	SI_LOST_TREASURE_MARK_MAP_MENU_OPTION1 = "사용 시",
	SI_LOST_TREASURE_MARK_MAP_MENU_OPTION2 = "인벤토리 내 전체",
	SI_LOST_TREASURE_MARK_MAP_MENU_OPTION3 = "모든 위치",
	SI_LOST_TREASURE_PIN_LEVEL = "지도 레벨",
	SI_LOST_TREASURE_PIN_LEVEL_TT = "값이 높을수록 낮은 레벨의 다른 핀 위에 그려집니다. 다른 핀에 가려질 때 값을 높이세요.",
	SI_LOST_TREASURE_MARKER_DELAY = "숨김 지연",

	SI_LOST_TREASURE_SHOW_MINIMAP_HEADER = "미니 지도",
	SI_LOST_TREASURE_SHOW_MINIMAP = "미니 지도 표시",
	SI_LOST_TREASURE_SHOW_MINIMAP_TT = "보물 지도나 조사 보고서를 사용한 뒤 미니 지도를 표시합니다.",
	SI_LOST_TREASURE_SHOW_MINIMAP_SIZE = "미니 지도 크기",
	SI_LOST_TREASURE_SHOW_MINIMAP_DELAY = "숨김 지연",
	SI_LOST_TREASURE_SHOW_MINIMAP_DELAY_TT = "보물이나 조사 지점을 획득한 뒤 미니 지도를 숨기기 전까지의 지연 시간(초)입니다.",

	SI_LOST_TREASURE_NOTIFICATION_MESSAGE = "새로운 미확인 데이터를 찾았습니다.",
	SI_LOST_TREASURE_NOTIFICATION_NOTE = "새 데이터를 제보해 주세요. 보고서를 제출하려면 ESOUI.com 계정이 필요합니다. 수락을 누르기 전에 먼저 로그인되어 있는지 확인하세요!",

	SI_LOST_TREASURE_DEBUG = "디버그 활성화",
	SI_LOST_TREASURE_DEBUG_TT = "문제 원인 파악을 돕기 위해 디버그 기능을 활성화합니다. 이 설정은 로그아웃 후 초기화됩니다.",
}

SafeStrings(strings)

strings = {
	SI_LOST_TREASURE_MARKER_DELAY_TT = zo_strformat("지도에서 표시된 위치를 지우기 전에 지연 시간을 추가합니다. 이 옵션은 <<1>> 또는 <<2>>와 함께 사용할 때만 동작합니다. <<3>>를 선택했거나 지도를 열어 모든 핀이 새로고침될 때는 동작하지 않습니다.", ZO_SELECTED_TEXT:Colorize(GetString(SI_LOST_TREASURE_MARK_MAP_MENU_OPTION1)), ZO_SELECTED_TEXT:Colorize(GetString(SI_LOST_TREASURE_MARK_MAP_MENU_OPTION2)), ZO_SELECTED_TEXT:Colorize(GetString(SI_LOST_TREASURE_MARK_MAP_MENU_OPTION3))),
}

SafeStrings(strings)
