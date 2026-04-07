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

-----------------------------------------------------------------------------------
-- Addon Name: Dolgubon's Lazy Writ Crafter
-- Creator: Dolgubon (Joseph Heinzle)
-- File Name: Languages/kr.lua
-- File Description: Korean localization for TamrielKR/native UTF-8
-----------------------------------------------------------------------------------

WritCreater = WritCreater or {}

local function myLower(str)
	return zo_strformat("<<z:1>>", str)
end

function WritCreater.getWritAndSurveyType(link)
	local itemName = GetItemLinkName(link)
	local kernels = {
		[CRAFTING_TYPE_ENCHANTING] = {"마법부여"},
		[CRAFTING_TYPE_BLACKSMITHING] = {"대장기술", "대장"},
		[CRAFTING_TYPE_CLOTHIER] = {"재봉"},
		[CRAFTING_TYPE_PROVISIONING] = {"요리"},
		[CRAFTING_TYPE_WOODWORKING] = {"목공", "목세공"},
		[CRAFTING_TYPE_ALCHEMY] = {"연금술", "연금"},
		[CRAFTING_TYPE_JEWELRYCRAFTING] = {"장신구", "장신구 제작", "보석 공예", "보석"},
	}
	local loweredName = myLower(itemName)
	for craft, values in pairs(kernels) do
		for _, kernel in ipairs(values) do
			if string.find(loweredName, myLower(kernel)) then
				return craft
			end
		end
	end
end

function WritCreater.langParser(str)
	local seperater = "[ ]+"

	str = zo_strformat("<<1>>", str)
	str = string.gsub(str, "을", "")
	str = string.gsub(str, "를", "")
	str = string.gsub(str, "_", " ")

	local params = {}
	local i = 1
	local searchResult1, searchResult2 = string.find(str, seperater)
	if searchResult1 == 1 then
		str = string.sub(str, searchResult2 + 1)
		searchResult1, searchResult2 = string.find(str, seperater)
	end

	while searchResult1 do
		params[i] = string.sub(str, 1, searchResult1 - 1)
		str = string.sub(str, searchResult2 + 1)
		searchResult1, searchResult2 = string.find(str, seperater)
		i = i + 1
	end
	params[i] = str
	return params
end

function WritCreater.langWritNames()
	local names = {
		["G"] = "의뢰서를 확인한다.",
		[CRAFTING_TYPE_ENCHANTING] = "마법부여가",
		[CRAFTING_TYPE_BLACKSMITHING] = "대장장이",
		[CRAFTING_TYPE_CLOTHIER] = "재봉사",
		[CRAFTING_TYPE_PROVISIONING] = "요리사",
		[CRAFTING_TYPE_WOODWORKING] = "목세공사",
		[CRAFTING_TYPE_ALCHEMY] = "연금술사",
		[CRAFTING_TYPE_JEWELRYCRAFTING] = "장신구",
	}
	return names
end

function WritCreater.surveyNames()
	local names = {
		[CRAFTING_TYPE_ENCHANTING] = "마법부여",
		[CRAFTING_TYPE_BLACKSMITHING] = "대장기술",
		[CRAFTING_TYPE_CLOTHIER] = "재봉",
		[CRAFTING_TYPE_PROVISIONING] = "요리",
		[CRAFTING_TYPE_WOODWORKING] = "목공",
		[CRAFTING_TYPE_ALCHEMY] = "연금술",
		[CRAFTING_TYPE_JEWELRYCRAFTING] = "장신구 제작",
	}
	return names
end

function WritCreater.langCraftKernels()
	return {
		[CRAFTING_TYPE_ENCHANTING] = "마법부여",
		[CRAFTING_TYPE_BLACKSMITHING] = "대장",
		[CRAFTING_TYPE_CLOTHIER] = "재봉",
		[CRAFTING_TYPE_PROVISIONING] = "요리",
		[CRAFTING_TYPE_WOODWORKING] = "목공",
		[CRAFTING_TYPE_ALCHEMY] = "연금술",
		[CRAFTING_TYPE_JEWELRYCRAFTING] = "장신구",
	}
end

function WritCreater.langMasterWritNames()
	local names = {
		["M"] = "거장의",
		["M1"] = "거장",
		[CRAFTING_TYPE_ALCHEMY] = "혼합물",
		[CRAFTING_TYPE_ENCHANTING] = "글리프",
		[CRAFTING_TYPE_PROVISIONING] = "성찬",
		["plate"] = "방어구",
		["tailoring"] = "재단",
		["leatherwear"] = "가죽 장비",
		["weapon"] = "무기",
		["shield"] = "방패",
		["jewelry"] = "장신구",
	}
	return names
end

function WritCreater.writCompleteStrings()
	local strings = {
		["place"] = "<물건을 상자에 넣는다.>",
		["sign"] = "<화물 목록에 서명합니다.>",
		["masterPlace"] = "작업을 끝냈습니다.",
		["masterSign"] = "<일을 끝마친다.>",
		["masterStart"] = "<계약을 받아들인다.>",
		["Rolis Hlaalu"] = "롤리스 흐랄루",
		["Deliver"] = "배달하기",
		["Acquire"] = "획득",
	}
	return strings
end

function WritCreater.languageInfo()
	local craftInfo = {
		[CRAFTING_TYPE_CLOTHIER] = {
			["pieces"] = {
				[1] = "로브",
				[2] = "조끼",
				[3] = "신발",
				[4] = "장갑",
				[5] = "모자",
				[6] = "바지",
				[7] = "어깨장식",
				[8] = "허리띠",
				[9] = "가죽 갑옷",
				[10] = "장화",
				[11] = "팔목보호대",
				[12] = "머리보호대",
				[13] = "다리보호대",
				[14] = "어깨보호대",
				[15] = "벨트",
			},
			["match"] = {
				[1] = "수제",
				[2] = "아마포",
				[3] = "면포",
				[4] = "거미 비단",
				[5] = "에본실",
				[6] = "크레시",
				[7] = "철실",
				[8] = "은섬유",
				[9] = "그림자 천",
				[10] = "선조",
				[11] = "생가죽",
				[12] = "가죽",
				[13] = "가공 가죽",
				[14] = "그레인",
				[15] = "모피",
				[16] = "브리간딘",
				[17] = "철 가죽",
				[18] = "최상급",
				[19] = "그림자가죽",
				[20] = "루베도",
			},
		},
		[CRAFTING_TYPE_BLACKSMITHING] = {
			["pieces"] = {
				[1] = "도끼",
				[2] = "둔기",
				[3] = "검",
				[4] = "전투도끼",
				[5] = "전투망치",
				[6] = "대검",
				[7] = "단검",
				[8] = "흉갑",
				[9] = "쇠구두",
				[10] = "건틀렛",
				[11] = "투구",
				[12] = "각갑",
				[13] = "견갑",
				[14] = "복대",
			},
			["match"] = {
				[1] = "철",
				[2] = "강철",
				[3] = "오리할쿰",
				[4] = "드워븐",
				[5] = "에보니",
				[6] = "칼시니움",
				[7] = "갈라타이트",
				[8] = "수은",
				[9] = "공허강",
				[10] = "루비다이트",
			},
		},
		[CRAFTING_TYPE_WOODWORKING] = {
			["pieces"] = {
				[1] = "활",
				[2] = "방패",
				[3] = "화염",
				[4] = "냉기",
				[5] = "전격",
				[6] = "치유",
			},
			["match"] = {
				[1] = "단풍나무",
				[2] = "참나무",
				[3] = "너도밤나무",
				[4] = "히코리",
				[5] = "주목",
				[6] = "자작나무",
				[7] = "물푸레나무",
				[8] = "마호가니",
				[9] = "깊은밤나무",
				[10] = "루비",
			},
		},
		[CRAFTING_TYPE_JEWELRYCRAFTING] = {
			["pieces"] = {
				[1] = "반지",
				[2] = "목걸이",
			},
			["match"] = {
				[1] = "백랍",
				[2] = "구리",
				[3] = "은",
				[4] = "호박금",
				[5] = "백금",
			},
		},
		[CRAFTING_TYPE_ENCHANTING] = {
			["pieces"] = {
				{"질병 저항", 45841, 2},
				{"역병", 45841, 1},
				{"스태미나 흡수", 45833, 2},
				{"매지카 흡수", 45832, 2},
				{"체력 흡수", 45831, 2},
				{"냉기 저항", 45839, 2},
				{"냉기", 45839, 1},
				{"행동 소비 감소", 45836, 2},
				{"스태미나 재생", 45836, 1},
				{"경화", 45842, 1},
				{"분쇄", 45842, 2},
				{"프리즘 맹습", 68342, 2},
				{"프리즘 방어", 68342, 1},
				{"방어", 45849, 2},
				{"강타", 45849, 1},
				{"독 저항", 45837, 2},
				{"독", 45837, 1},
				{"마법 피해 감소", 45848, 2},
				{"마법 피해 증가", 45848, 1},
				{"매지카 재생", 45835, 1},
				{"주문 소비 감소", 45835, 2},
				{"전격 저항", 45840, 2},
				{"전격", 45840, 1},
				{"체력 재생", 45834, 1},
				{"체력 감소", 45834, 2},
				{"쇠약", 45843, 2},
				{"무기 피해", 45843, 1},
				{"물약 강화", 45846, 1},
				{"물약 속도 상승", 45846, 2},
				{"화염 저항", 45838, 2},
				{"화염", 45838, 1},
				{"물리 피해 감소", 45847, 2},
				{"물리 피해 증가", 45847, 1},
				{"스태미나", 45833, 1},
				{"체력", 45831, 1},
				{"매지카", 45832, 1},
			},
			["match"] = {
				[1] = {"티끌만한", 45855},
				[2] = {"열등한", 45856},
				[3] = {"하찮은", 45857},
				[4] = {"미약한", 45806},
				[5] = {"아담한", 45807},
				[6] = {"하등한", 45808},
				[7] = {"일반적인", 45809},
				[8] = {"평균적인", 45810},
				[9] = {"강력한", 45811},
				[10] = {"우수한", 45812},
				[11] = {"대단한", 45813},
				[12] = {"강대한", 45814},
				[13] = {"탁월한", 45815},
				[14] = {"기념적인", 45816},
				[15] = {"초월적인", {68341, 68340}},
				[16] = {"최상급", {64509, 64508}},
			},
			["quality"] = {
				{"기본적인", 45850},
				{"좋은", 45851},
				{"우수한", 45852},
				{"유물의", 45853},
				{"전설적인", 45854},
				{"", 45850},
			},
		},
	}

	return craftInfo
end

function WritCreater.masterWritQuality()
	return {{"유물의", 4}, {"전설적인", 5}}
end

function WritCreater.langEssenceNames()
	local essenceNames = {
		[1] = "오코",
		[2] = "데니",
		[3] = "마코",
	}
	return essenceNames
end

function WritCreater.langPotencyNames()
	local potencyNames = {
		[1] = "조라",
		[2] = "포라데",
		[3] = "제라",
		[4] = "제조라",
		[5] = "오드라",
		[6] = "포조라",
		[7] = "에도라",
		[8] = "제에라",
		[9] = "포라",
		[10] = "데나라",
		[11] = "레라",
		[12] = "데라도",
		[13] = "레쿠라",
		[14] = "쿠라",
		[15] = "레제라",
		[16] = "레포라",
	}
	return potencyNames
end

local exceptions = {
	[1] = {
		["original"] = "강철",
		["corrected"] = "Steel",
	},
	[2] = {
		["original"] = "루비 물푸레나무",
		["corrected"] = "루비",
	},
}

function WritCreater.questExceptions(condition)
	condition = string.gsub(condition, "혻", " ")
	return condition
end

function WritCreater.enchantExceptions(condition)
	condition = string.gsub(condition, "혻", " ")
	return condition
end

function WritCreater.exceptions(condition)
	condition = string.gsub(condition, "혻", " ")
	condition = string.lower(condition)

	for i = 1, #exceptions do
		if string.find(condition, exceptions[i]["original"]) then
			condition = string.gsub(condition, exceptions[i]["original"], exceptions[i]["corrected"])
		end
	end
	return condition
end

function WritCreater.langTutorial(i)
	local t = {
		[1] = "Dolgubon's Lazy Writ Crafter에 오신 것을 환영합니다!\n먼저 몇 가지 설정을 골라두는 것이 좋습니다.\n설정 메뉴에서 언제든 다시 바꿀 수 있습니다.",
		[2] = "첫 번째로 고를 설정은 자동 제작 사용 여부입니다.\n켜 두면 제작대에 들어갔을 때 애드온이 곧바로 제작을 시작합니다.",
		[3] = "다음으로 제작대를 사용할 때 이 창을 볼지 선택할 수 있습니다.\n이 창은 의뢰에 필요한 재료 수량과 현재 보유 수량을 보여줍니다.",
		[4] = "마지막으로 각 전문기술별로 이 애드온을 켜거나 끌 수 있습니다.\n기본값은 가능한 제작 모두 활성화입니다.\n끄고 싶은 제작이 있다면 설정에서 바꾸면 됩니다.",
		[5] = "알아둘 점이 하나 더 있습니다.\n`/dailyreset` 슬래시 명령어를 쓰면 다음 일일 초기화까지 남은 시간을 확인할 수 있습니다.",
	}
	return t[i]
end

function WritCreater.langTutorialButton(i, onOrOff)
	local tOn = {
		[1] = "기본값 사용",
		[2] = "켜기",
		[3] = "표시",
		[4] = "계속",
		[5] = "완료",
	}
	local tOff = {
		[1] = "계속",
		[2] = "끄기",
		[3] = "다시 표시 안 함",
	}
	if onOrOff then
		return tOn[i]
	end
	return tOff[i]
end

function WritCreater.langStationNames()
	return {
		["대장기술 제작대"] = 1,
		["재봉 제작대"] = 2,
		["마법부여 제작대"] = 3,
		["연금술 제작대"] = 4,
		["요리용 화로"] = 5,
		["목공 제작대"] = 6,
		["장신구 제작대"] = 7,
	}
end

function WritCreater.langWritRewardBoxes()
	return {
		[CRAFTING_TYPE_ALCHEMY] = "연금술사의 용기",
		[CRAFTING_TYPE_ENCHANTING] = "마법부여가의 궤짝",
		[CRAFTING_TYPE_PROVISIONING] = "요리사의 꾸러미",
		[CRAFTING_TYPE_BLACKSMITHING] = "대장장이의 상자",
		[CRAFTING_TYPE_CLOTHIER] = "재봉사의 가방",
		[CRAFTING_TYPE_WOODWORKING] = "목세공사의 상자",
		[CRAFTING_TYPE_JEWELRYCRAFTING] = "보석 공예가의 상자",
		[8] = "적하물",
		[10] = "적하물",
	}
end

function WritCreater.getTaString()
	return "타"
end

WritCreater.lang = "kr"
WritCreater.langIsMasterWritSupported = true

WritCreater.strings = WritCreater.strings or {}
WritCreater.strings["moreStyle"] = "|cf60000사용 가능한 스타일 재료가 없습니다.\n인벤토리와 설정을 확인하세요.|r"
WritCreater.strings["moreStyleSettings"] = "|cf60000사용 가능한 스타일 재료가 없습니다.\n설정 메뉴에서 더 많은 스타일 재료를 허용해야 할 수 있습니다.|r"
WritCreater.strings["moreStyleKnowledge"] = "|cf60000사용 가능한 스타일 재료가 없습니다.\n더 많은 제작 스타일을 배워야 할 수 있습니다.|r"
WritCreater.strings["craftAnyway"] = "그래도 제작"
WritCreater.strings["craft"] = "|c00ff00제작|r"
WritCreater.strings["crafting"] = "|c00ff00제작 중...|r"
WritCreater.strings["complete"] = "|c00FF00의뢰 완료.|r"
WritCreater.strings["keybindStripBlurb"] = "의뢰 아이템 제작"
WritCreater.strings["pressToCraft"] = "\n|t32:32:<<1>>|t 를 눌러 제작"
WritCreater.strings["welcomeMessage"] = "Dolgubon's Lazy Writ Crafter를 설치해 주셔서 감사합니다! 설정에서 애드온 동작을 조정할 수 있습니다."
WritCreater.strings["surveys"] = "제작 조사 보고서"
WritCreater.strings["sealedWrits"] = "봉인된 의뢰서"
WritCreater.strings["fullBag"] = "가방 공간이 부족합니다. 인벤토리를 비워주세요."
WritCreater.strings["masterWritSave"] = "Dolgubon's Lazy Writ Crafter가 실수로 거장 의뢰를 수락하는 것을 막았습니다. 비활성화하려면 설정 메뉴를 확인하세요."
WritCreater.strings["missingLibraries"] = "Dolgubon's Lazy Writ Crafter에는 다음 독립 라이브러리가 필요합니다. 다운로드하거나 활성화해 주세요: "
WritCreater.strings["resetWarningMessageText"] = "일일 의뢰 초기화까지 <<1>>시간 <<2>>분 남았습니다.\n이 경고는 설정에서 조정하거나 끌 수 있습니다."
WritCreater.strings["resetWarningExampleText"] = "경고는 다음과 같이 표시됩니다."
WritCreater.strings["masterWritQueueCleared"] = "거장 의뢰 제작 대기열을 비웠습니다."
WritCreater.strings["stealingProtection"] = "Lazy Writ Crafter가 의뢰 중 도둑질을 막았습니다!"
WritCreater.strings["countSurveys"] = "조사 보고서 <<1>>개 보유 중"
WritCreater.strings["countVouchers"] = "미획득 의뢰 증서 <<1>>개 보유 중"
WritCreater.strings["includesStorage"] = function(type)
	local labels = {"조사 보고서", "거장 의뢰"}
	return zo_strformat("집 보관함의 <<1>>도 포함해 계산합니다.", labels[type])
end
WritCreater.strings["withdrawItem"] = function(amount, link, remaining)
	return "Dolgubon's Lazy Writ Crafter가 "..amount.." "..link.." 을(를) 꺼냈습니다. (은행 잔여 "..remaining..")"
end
WritCreater.strings["masterQueueBlurb"] = "의뢰 제작"
WritCreater.strings["masterQueueSummary"] = "Writ Crafter가 봉인된 의뢰 <<1>>개를 대기열에 추가했습니다."

WritCreater.optionStrings = WritCreater.optionStrings or {}
WritCreater.optionStrings.nowEditing = "%s 설정을 변경 중입니다"
WritCreater.optionStrings.accountWide = "계정 전체"
WritCreater.optionStrings.characterSpecific = "캐릭터별"
WritCreater.optionStrings.useCharacterSettings = "캐릭터별 설정 사용"
WritCreater.optionStrings.useCharacterSettingsTooltip = "이 캐릭터에만 별도 설정을 사용합니다."
WritCreater.optionStrings["style tooltip"] = function(styleName, styleStone)
	return zo_strformat("<<1>> 스타일 제작을 허용합니다. 이 스타일은 "..styleStone.." 스타일 재료를 사용합니다.", styleName, styleStone)
end
WritCreater.optionStrings["show craft window"] = "제작 창 표시"
WritCreater.optionStrings["show craft window tooltip"] = "제작대를 열었을 때 제작 창을 표시합니다."
WritCreater.optionStrings["autocraft"] = "자동 제작"
WritCreater.optionStrings["autocraft tooltip"] = "활성화하면 제작대에 들어가자마자 자동으로 제작을 시작합니다. 제작 창을 숨기면 이 옵션은 항상 켜집니다."
WritCreater.optionStrings["blackmithing"] = "대장기술"
WritCreater.optionStrings["blacksmithing tooltip"] = "대장기술 의뢰에 애드온을 사용합니다."
WritCreater.optionStrings["clothing"] = "재봉"
WritCreater.optionStrings["clothing tooltip"] = "재봉 의뢰에 애드온을 사용합니다."
WritCreater.optionStrings["enchanting"] = "마법부여"
WritCreater.optionStrings["enchanting tooltip"] = "마법부여 의뢰에 애드온을 사용합니다."
WritCreater.optionStrings["alchemy"] = "연금술"
WritCreater.optionStrings["alchemy tooltip"] = "연금술 의뢰에 애드온을 사용합니다. 미리 의뢰용 물약을 제작해 두는 편이 좋지만 자동 제작도 지원합니다."
WritCreater.optionStrings["alchemyChoices"] = {"끔", "모든 기능", "자동 제작 제외"}
WritCreater.optionStrings["provisioning"] = "요리"
WritCreater.optionStrings["provisioning tooltip"] = "요리 의뢰에 애드온을 사용합니다. 미리 의뢰용 음식을 제작해 두는 편이 좋지만 자동 제작도 지원합니다."
WritCreater.optionStrings["woodworking"] = "목공"
WritCreater.optionStrings["woodworking tooltip"] = "목공 의뢰에 애드온을 사용합니다."
WritCreater.optionStrings["jewelry crafting"] = "장신구 제작"
WritCreater.optionStrings["jewelry crafting tooltip"] = "장신구 제작 의뢰에 애드온을 사용합니다."
WritCreater.optionStrings["writ grabbing"] = "의뢰 재료 꺼내기"
WritCreater.optionStrings["writ grabbing tooltip"] = "은행에서 의뢰에 필요한 아이템(예: 니른루트, 타 룬 등)을 꺼냅니다."
WritCreater.optionStrings["style stone menu"] = "사용할 스타일 재료"
WritCreater.optionStrings["style stone menu tooltip"] = "애드온이 사용할 스타일 재료를 선택합니다."
WritCreater.optionStrings["exit when done"] = "제작 창 닫기"
WritCreater.optionStrings["exit when done tooltip"] = "모든 제작이 끝나면 제작 창을 닫습니다."
WritCreater.optionStrings["automatic complete"] = "자동 퀘스트 대화"
WritCreater.optionStrings["automatic complete tooltip"] = "의뢰 게시판과 납품 NPC 대화를 자동으로 수락/완료합니다."
WritCreater.optionStrings["new container"] = "새 아이템 표시 유지"
WritCreater.optionStrings["new container tooltip"] = "의뢰 보상 상자의 새 아이템 표시를 유지합니다."
WritCreater.optionStrings["master"] = "거장 의뢰"
WritCreater.optionStrings["master tooltip"] = "활성화하면 현재 진행 중인 거장 의뢰도 제작합니다."
WritCreater.optionStrings["right click to craft"] = "우클릭으로 제작"
WritCreater.optionStrings["right click to craft tooltip"] = "활성화하면 봉인된 의뢰서를 우클릭했을 때 제작 대기열에 넣습니다. LibCustomMenu가 필요합니다."
WritCreater.optionStrings["crafting submenu"] = "제작할 일일 의뢰"
WritCreater.optionStrings["crafting submenu tooltip"] = "특정 제작 종류에서는 애드온을 끌 수 있습니다."
WritCreater.optionStrings["timesavers submenu"] = "시간 절약"
WritCreater.optionStrings["timesavers submenu tooltip"] = "소소한 자동화 옵션입니다."
WritCreater.optionStrings["loot container"] = "획득 즉시 상자 열기"
WritCreater.optionStrings["loot container tooltip"] = "의뢰 보상 상자를 받자마자 엽니다."
WritCreater.optionStrings["master writ saver"] = "거장 의뢰 보호"
WritCreater.optionStrings["master writ saver tooltip"] = "거장 의뢰를 실수로 수락하지 않게 막습니다."
WritCreater.optionStrings["loot output"] = "고가 보상 알림"
WritCreater.optionStrings["loot output tooltip"] = "의뢰 보상에서 가치 있는 아이템을 얻었을 때 메시지를 출력합니다."
WritCreater.optionStrings["autoloot behaviour"] = "자동 획득 동작"
WritCreater.optionStrings["autoloot behaviour tooltip"] = "의뢰 보상 상자를 언제 자동 획득할지 선택합니다."
WritCreater.optionStrings["autoloot behaviour choices"] = {"게임플레이 설정 따름", "자동 획득", "자동 획득 안 함"}
WritCreater.optionStrings["hide when done"] = "완료 시 숨기기"
WritCreater.optionStrings["hide when done tooltip"] = "모든 아이템을 제작하면 애드온 창을 숨깁니다."
WritCreater.optionStrings["reticleColour"] = "조준점 색상 변경"
WritCreater.optionStrings["reticleColourTooltip"] = "해당 제작대 의뢰 상태에 따라 조준점 색상을 바꿉니다."
WritCreater.optionStrings["autoCloseBank"] = "자동 은행 대화"
WritCreater.optionStrings["autoCloseBankTooltip"] = "꺼낼 아이템이 있으면 은행 대화를 자동으로 열고 닫습니다."
WritCreater.optionStrings["despawnBanker"] = "은행원 해제 소환 (출금)"
WritCreater.optionStrings["despawnBankerTooltip"] = "아이템을 꺼낸 뒤 은행원을 자동으로 해제 소환합니다."
WritCreater.optionStrings["despawnBankerDeposit"] = "은행원 해제 소환 (입금)"
WritCreater.optionStrings["despawnBankerDepositTooltip"] = "입금 후 은행원을 자동으로 해제 소환합니다."
WritCreater.optionStrings["dailyResetWarnTime"] = "초기화 전 알림 시간"
WritCreater.optionStrings["dailyResetWarnTimeTooltip"] = "일일 초기화 몇 분 전에 경고를 표시할지 정합니다."
WritCreater.optionStrings["dailyResetWarnType"] = "일일 초기화 경고"
WritCreater.optionStrings["dailyResetWarnTypeTooltip"] = "일일 초기화가 다가올 때 어떤 방식으로 경고를 표시할지 정합니다."
WritCreater.optionStrings["dailyResetWarnTypeChoices"] = {"없음", "공지", "오른쪽 위", "채팅", "팝업", "전체"}
WritCreater.optionStrings["stealingProtection"] = "도둑질 방지"
WritCreater.optionStrings["stealingProtectionTooltip"] = "의뢰를 수행 중일 때 실수로 훔치는 행동을 막습니다."
WritCreater.optionStrings["noDELETEConfirmJewelry"] = "장신구 의뢰 삭제 간소화"
WritCreater.optionStrings["noDELETEConfirmJewelryTooltip"] = "장신구 의뢰 삭제 확인창에 DELETE 문구를 자동으로 입력합니다."
WritCreater.optionStrings["suppressQuestAnnouncements"] = "의뢰 알림 숨기기"
WritCreater.optionStrings["suppressQuestAnnouncementsTooltip"] = "의뢰 시작/제작 시 화면 중앙에 뜨는 알림 문구를 숨깁니다."
WritCreater.optionStrings["questBuffer"] = "의뢰 버퍼 유지"
WritCreater.optionStrings["questBufferTooltip"] = "언제나 새 의뢰를 받을 자리가 남도록 퀘스트 수를 조절합니다."
WritCreater.optionStrings["craftMultiplier"] = "제작 배수 (장비/글리프)"
WritCreater.optionStrings["craftMultiplierTooltip"] = "필요 아이템을 여러 개 미리 제작해 다음 의뢰 때 재제작을 줄입니다. 1을 넘길 때마다 인벤토리 공간이 많이 필요할 수 있습니다."
WritCreater.optionStrings["craftMultiplierConsumables"] = "제작 배수 (연금술/요리)"
WritCreater.optionStrings["craftMultiplierConsumablesTooltip"] = "1회 제작은 제작 행동 1번만 수행합니다. 전체 묶음은 배수 패시브가 있을 때 필요한 아이템을 100개 제작합니다."
WritCreater.optionStrings["craftMultiplierConsumablesChoices"] = {"1회 제작", "전체 묶음"}
WritCreater.optionStrings["hireling behaviour"] = "조수 우편 처리"
WritCreater.optionStrings["hireling behaviour tooltip"] = "조수 우편을 어떻게 처리할지 정합니다."
WritCreater.optionStrings["hireling behaviour choices"] = {"아무것도 안 함", "획득 후 삭제", "획득만"}
WritCreater.optionStrings["allReward"] = "모든 제작 공통"
WritCreater.optionStrings["allRewardTooltip"] = "모든 제작에 공통으로 적용할 동작입니다."
WritCreater.optionStrings["sameForALlCrafts"] = "모든 제작에 같은 옵션 사용"
WritCreater.optionStrings["sameForALlCraftsTooltip"] = "이 보상 종류에 대해 모든 제작에 동일한 옵션을 사용합니다."
WritCreater.optionStrings["1Reward"] = "대장기술"
WritCreater.optionStrings["2Reward"] = "재봉"
WritCreater.optionStrings["3Reward"] = "마법부여"
WritCreater.optionStrings["4Reward"] = "연금술"
WritCreater.optionStrings["5Reward"] = "요리"
WritCreater.optionStrings["6Reward"] = "목공"
WritCreater.optionStrings["7Reward"] = "장신구 제작"
WritCreater.optionStrings["matsReward"] = "재료 보상"
WritCreater.optionStrings["matsRewardTooltip"] = "제작 재료 보상을 어떻게 처리할지 정합니다."
WritCreater.optionStrings["surveyReward"] = "조사 보고서 보상"
WritCreater.optionStrings["surveyRewardTooltip"] = "조사 보고서 보상을 어떻게 처리할지 정합니다."
WritCreater.optionStrings["masterReward"] = "거장 의뢰 보상"
WritCreater.optionStrings["masterRewardTooltip"] = "거장 의뢰 보상을 어떻게 처리할지 정합니다."
WritCreater.optionStrings["repairReward"] = "수리 키트 보상"
WritCreater.optionStrings["repairRewardTooltip"] = "수리 키트 보상을 어떻게 처리할지 정합니다."
WritCreater.optionStrings["ornateReward"] = "장식 아이템 보상"
WritCreater.optionStrings["ornateRewardTooltip"] = "장식 특성 장비 보상을 어떻게 처리할지 정합니다."
WritCreater.optionStrings["intricateReward"] = "정교한 아이템 보상"
WritCreater.optionStrings["intricateRewardTooltip"] = "정교한 특성 장비 보상을 어떻게 처리할지 정합니다."
WritCreater.optionStrings["soulGemReward"] = "빈 영혼석"
WritCreater.optionStrings["soulGemTooltip"] = "빈 영혼석을 어떻게 처리할지 정합니다."
WritCreater.optionStrings["glyphReward"] = "글리프"
WritCreater.optionStrings["glyphRewardTooltip"] = "글리프를 어떻게 처리할지 정합니다."
WritCreater.optionStrings["recipeReward"] = "레시피"
WritCreater.optionStrings["recipeRewardTooltip"] = "레시피를 어떻게 처리할지 정합니다."
WritCreater.optionStrings["fragmentReward"] = "사이직 조각"
WritCreater.optionStrings["fragmentRewardTooltip"] = "사이직 조각을 어떻게 처리할지 정합니다."
WritCreater.optionStrings["currencyReward"] = "골드 보상"
WritCreater.optionStrings["currencyRewardTooltip"] = "퀘스트 골드 보상을 어떻게 처리할지 정합니다."
WritCreater.optionStrings["goldMatReward"] = "금색 재료 (비 ESO+)"
WritCreater.optionStrings["goldMatRewardTooltip"] = "의뢰 보상으로 얻는 금색 재료를 어떻게 처리할지 정합니다. ESO+ 구독자는 무시됩니다."
WritCreater.optionStrings["writRewards submenu"] = "의뢰 보상 처리"
WritCreater.optionStrings["writRewards submenu tooltip"] = "의뢰 보상을 어떻게 처리할지 설정합니다."
WritCreater.optionStrings["jubilee"] = "기념일/제니타르 상자 획득"
WritCreater.optionStrings["jubilee tooltip"] = "기념일 상자와 제니타르 상자를 자동으로 획득합니다."
WritCreater.optionStrings["skin"] = "Writ Crafter 스킨"
WritCreater.optionStrings["skinTooltip"] = "Writ Crafter UI에 사용할 스킨입니다."
WritCreater.optionStrings["skinOptions"] = {"기본", "치즈", "염소", "화려함"}
WritCreater.optionStrings["goatSkin"] = "염소"
WritCreater.optionStrings["cheeseSkin"] = "치즈"
WritCreater.optionStrings["fabulousSkin"] = "화려함"
WritCreater.optionStrings["defaultSkin"] = "기본"
WritCreater.optionStrings["rewardChoices"] = {"아무것도 안 함", "은행 보관", "잡동사니", "파괴", "해체"}
WritCreater.optionStrings["scan for unopened"] = "로그인 시 상자 열기"
WritCreater.optionStrings["scan for unopened tooltip"] = "로그인할 때 가방에서 미개봉 의뢰 상자를 찾아 자동으로 열기를 시도합니다."
WritCreater.optionStrings["smart style slot save"] = "적은 수량부터 사용"
WritCreater.optionStrings["smart style slot save tooltip"] = "ESO+가 아닐 때 작은 묶음의 스타일 재료부터 사용해 슬롯을 아끼려고 시도합니다."
WritCreater.optionStrings["abandon quest for item"] = "'<<1>> 배달' 의뢰"
WritCreater.optionStrings["abandon quest for item tooltip"] = "끔으로 두면 <<1>> 배달이 필요한 의뢰를 자동 포기합니다. 단, <<1>> 재료가 들어가는 제작 의뢰는 포기하지 않습니다."
WritCreater.optionStrings["status bar submenu"] = "상태 바"
WritCreater.optionStrings["status bar submenu tooltip"] = "의뢰 상태 바 옵션입니다."
WritCreater.optionStrings["showStatusBar"] = "상태 바 표시"
WritCreater.optionStrings["showStatusBarTooltip"] = "퀘스트 상태 바를 표시하거나 숨깁니다."
WritCreater.optionStrings["statusBarIcons"] = "아이콘 사용"
WritCreater.optionStrings["statusBarIconsTooltip"] = "각 의뢰 종류를 글자 대신 제작 아이콘으로 표시합니다."
WritCreater.optionStrings["transparentStatusBar"] = "투명 상태 바"
WritCreater.optionStrings["transparentStatusBarTooltip"] = "상태 바를 투명하게 만듭니다."
WritCreater.optionStrings["statusBarInventory"] = "인벤토리 추적"
WritCreater.optionStrings["statusBarInventoryTooltip"] = "상태 바에 인벤토리 여유 공간 표시를 추가합니다."
WritCreater.optionStrings["incompleteColour"] = "미완료 의뢰 색상"
WritCreater.optionStrings["completeColour"] = "완료 의뢰 색상"
WritCreater.optionStrings["smartMultiplier"] = "스마트 배수"
WritCreater.optionStrings["smartMultiplierTooltip"] = "활성화하면 3일 순환 전체 분량을 기준으로 제작하며, 이미 보유한 의뢰 아이템도 함께 계산합니다. 비활성화하면 오늘 의뢰 기준으로만 여러 개를 제작합니다."
WritCreater.optionStrings["craftHousePort"] = "제작 하우스로 이동"
WritCreater.optionStrings["craftHousePortTooltip"] = "공개된 제작 하우스로 이동합니다. 자주 쓴다면 LibRadialMenu 단축도 사용할 수 있습니다."
WritCreater.optionStrings["craftHousePortButton"] = "이동"
WritCreater.optionStrings["reportBug"] = "버그 제보"
WritCreater.optionStrings["reportBugTooltip"] = "특히 콘솔 버전 Writ Crafter 관련 버그를 제보하는 글을 엽니다. 이미 보고된 문제인지 먼저 확인해 주세요."
WritCreater.optionStrings["openUrlButtonText"] = "URL 열기"
WritCreater.optionStrings["donate"] = "후원"
WritCreater.optionStrings["donateTooltip"] = "Paypal로 Dolgubon에게 후원합니다."
WritCreater.optionStrings["writStats"] = "의뢰 통계"
WritCreater.optionStrings["writStatsTooltip"] = "애드온 설치 후 수행한 의뢰 보상 통계를 봅니다."
WritCreater.optionStrings["writStatsButton"] = "창 열기"
WritCreater.optionStrings["queueWrits"] = "봉인된 의뢰 모두 대기열 추가"
WritCreater.optionStrings["queueWritsTooltip"] = "인벤토리에 있는 봉인된 의뢰를 모두 대기열에 추가합니다."
WritCreater.optionStrings["queueWritsButton"] = "대기열"
WritCreater.optionStrings["mainSettings"] = "주요 설정"
WritCreater.optionStrings["statusBarHorizontal"] = "가로 위치"
WritCreater.optionStrings["statusBarHorizontalTooltip"] = "상태 바의 가로 위치입니다."
WritCreater.optionStrings["statusBarVertical"] = "세로 위치"
WritCreater.optionStrings["statusBarVerticalTooltip"] = "상태 바의 세로 위치입니다."
WritCreater.optionStrings["keepItemWritFormat"] = "<<1>> 유지"
WritCreater.optionStrings["npcStyleStoneReminder"] = "알림: 기본 종족 스타일 재료는 아무 제작 NPC 상인에게서 개당 15골드에 구매할 수 있습니다."
WritCreater.optionStrings["voucherCount"] = "미획득 의뢰 증서 수 세기"
WritCreater.optionStrings["voucherCountTooltip"] = "인벤토리와 은행에 있는 모든 봉인된 거장 의뢰의 의뢰 증서 총합을 출력합니다."
WritCreater.optionStrings["surveyCount"] = "조사 보고서 수 세기"
WritCreater.optionStrings["surveyCountTooltip"] = "인벤토리와 은행에 있는 조사 보고서 수를 분류해서 출력합니다."
WritCreater.optionStrings["mimicStoneUse"] = "거장 의뢰용 모방석 사용"
WritCreater.optionStrings["mimicStoneUseTooltip"] = "거장 의뢰에서 모방석 사용 방식을 정합니다. 현재 거장 의뢰 대기열은 초기화됩니다.\n모방석은 일일 의뢰에는 사용되지 않습니다."
WritCreater.optionStrings["mimicStoneUseChoices"] = {"사용 안 함", "항상 사용", "스타일 재료 없을 때 사용", "가격 1천 초과 시 사용", "가격 3천 초과 시 사용"}
