Harvest.localizedStrings = {
	-- top level description
	esouidescription = "애드온 설명과 FAQ는 esoui.com의 애드온 페이지를 참고하세요.",
	openesoui = "ESOUI 열기",
	exchangedescription2 = "HarvestMap-Data 애드온을 설치하면 최신 HarvestMap 데이터(자원 위치)를 내려받을 수 있습니다. 자세한 내용은 ESOUI의 애드온 설명을 참고하세요.",

	notifications = "알림 및 경고",
	notificationstooltip = "화면 오른쪽 위에 알림과 경고를 표시합니다.",
	moduleerrorload = "애드온 <<1>>이 비활성화되어 있습니다.\n이 지역의 데이터를 사용할 수 없습니다.",
	moduleerrorsave = "애드온 <<1>>이 비활성화되어 있습니다.\n노드 위치가 저장되지 않았습니다.",

	-- outdated data settings
	outdateddata = "오래된 데이터 설정",
	outdateddatainfo = "이 데이터 관련 설정은 이 컴퓨터의 모든 계정과 캐릭터에 공유됩니다.",
	timedifference = "최근 데이터만 유지",
	timedifferencetooltip = "HarvestMap은 최근 X일의 데이터만 유지합니다.\n이미 오래되어 부정확할 수 있는 데이터를 표시하지 않도록 합니다.\n0으로 설정하면 오래된 데이터도 모두 유지합니다.",
	applywarning = "오래된 데이터를 삭제하면 복구할 수 없습니다!",

	-- account wide settings
	account = "계정 공용 설정",
	accounttooltip = "아래 설정이 모든 캐릭터에 동일하게 적용됩니다.",
	accountwarning = "이 설정을 바꾸면 UI가 새로고침됩니다.",

	-- map pin settings
	mapheader = "지도 핀 설정",
	mappins = "메인 지도에 핀 표시",
	minimappins = "미니맵에 핀 표시",
	minimappinstooltip = "지원 미니맵: Votan, Fyrakin, AUI.",
	level = "POI 핀 위에 지도 핀 표시",
	hasdrawdistance = "근처 지도 핀만 표시",
	hasdrawdistancetooltip = "활성화하면 플레이어 근처의 채집 위치에 대해서만 지도 핀을 생성합니다.\n이 설정은 메인 지도에만 적용됩니다. 미니맵에서는 자동으로 활성화됩니다.",
	hasdrawdistancewarning = "이 설정은 인게임 지도에만 적용됩니다. 미니맵에서는 자동으로 활성화됩니다!",
	drawdistance = "지도 핀 거리",
	drawdistancetooltip = "지도 핀을 그릴 거리 기준입니다. 이 설정은 미니맵에도 영향을 줍니다!",
	drawdistancewarning = "이 설정은 미니맵에도 영향을 줍니다!",

	visiblepintypes = "표시할 핀 종류",
	custom = "사용자 지정",
	same_as_map = "지도와 동일",

	-- compass settings
	compassheader = "나침반 설정",
	compass = "나침반에 핀 표시",
	compassdistance = "최대 핀 거리",
	compassdistancetooltip = "나침반에 표시할 핀의 최대 거리(미터)입니다.",

	-- 3d pin settings
	worldpinsheader = "3D 핀 설정",
	worldpins = "3D 세계에 핀 표시",
	worlddistance = "최대 3D 핀 거리",
	worlddistancetooltip = "채집 위치까지의 최대 거리(미터)입니다. 더 멀면 3D 핀이 표시되지 않습니다.",
	worldpinwidth = "3D 핀 너비",
	worldpinwidthtooltip = "3D 핀의 너비(센티미터)입니다.",
	worldpinheight = "3D 핀 높이",
	worldpinheighttooltip = "3D 핀의 높이(센티미터)입니다.",
	worldpinsdepth = "벽 너머로 보기",
	worldpinsdepthtooltip = "활성화하면 벽이나 다른 오브젝트 너머에서도 3D 핀이 보입니다.",
	worldpinsdepthtext = "\"벽 너머로 보기\"를 끄는 기능은 다음 조건에서만 제대로 동작합니다.\n1) 게임 해상도가 모니터 해상도와 같고,\n2) 게임 비디오 설정의 서브샘플링 품질이 높음일 때입니다.",

	-- respawn timer settings
	visitednodes = "방문한 노드와 파밍 도우미",
	rangemultiplier = "방문 노드 범위",
	rangemultipliertooltip = "X미터 이내의 노드는 파밍 도우미와 숨김 타이머에서 방문한 것으로 간주됩니다.",
	usehiddentime = "최근 방문한 노드 숨기기",
	usehiddentimetooltip = "최근 방문한 위치의 핀을 숨깁니다.",
	hiddentime = "숨김 시간",
	hiddentimetooltip = "최근 방문한 노드를 X분 동안 숨깁니다.",
	hiddenonharvest = "채집 후에만 노드 숨기기",
	hiddenonharvesttooltip = "활성화하면 실제로 채집했을 때만 핀을 숨깁니다. 비활성화하면 방문만 해도 숨깁니다.",

	-- spawn filter
	spawnfilter = "리젠 자원 필터",
	nodedetectionmissing = "'NodeDetection' 라이브러리가 활성화되어 있어야 이 옵션을 사용할 수 있습니다.",
	spawnfilterdescription = [[활성화하면 아직 다시 나타나지 않은 자원의 핀을 숨깁니다. 예를 들어 다른 플레이어가 이미 채집했다면 자원이 다시 생성될 때까지 해당 핀이 숨겨집니다.
- 이 기능은 채집 가능한 제작 재료에만 적용됩니다.
- 보물상자, 무거운 자루, 사이직 포털 같은 컨테이너에는 적용되지 않습니다.
- 다른 애드온이 나침반을 숨기거나 크기를 바꾸면 필터가 제대로 동작하지 않을 수 있습니다.
- 맵 반대편에서 자원이 리젠되었는지는 알 수 없으므로, 지도에는 근처 자원만 표시됩니다.]],
	spawnfilter_map = "메인 지도에 필터 적용",
	spawnfilter_minimap = "미니맵에 필터 적용",
	spawnfilter_compass = "나침반 핀에 필터 적용",
	spawnfilter_world = "3D 핀에 필터 적용",
	spawnfilter_pintype = "필터를 적용할 핀 종류:",

	-- pin type options
	pinoptions = "핀 종류 옵션",
	pinsize = "핀 크기",
	pinsizetooltip = "지도에 표시되는 핀 크기를 설정합니다.",
	pincolor = "핀 색상",
	pincolortooltip = "지도와 나침반에 표시되는 핀 색상을 설정합니다.",
	savepin = "<<1>> 위치 저장",
	savetooltip = "이 자원을 발견했을 때 위치를 저장합니다.",
	pintexture = "핀 아이콘",

	-- pin type names
	pintype1 = "대장/장신구",
	pintype2 = "재봉",
	pintype3 = "룬석 및 사이직 포털",
	pintype4 = "버섯",
	pintype13 = "약초/꽃",
	pintype14 = "수생 약초",
	pintype5 = "목재",
	pintype6 = "보물상자",
	pintype7 = "용매",
	pintype8 = "낚시터",
	pintype9 = "무거운 자루",
	pintype10 = "도둑의 보관함",
	pintype11 = "정의 컨테이너",
	pintype12 = "숨겨진 은닉처",
	pintype15 = "거대 조개",
	pintype18 = "알 수 없는 노드",
	pintype19 = "진홍빛 너른뿌리",
	pintype20 = "약초학자의 가방",

	-- extra map filter buttons
	deletepinfilter = "HarvestMap 핀 삭제",
	filterheatmap = "히트맵 모드",

	-- localization for the farming helper
	goldperminute = "분당 골드:",
	farmresult = "HarvestFarm 결과",
	farmnotour = "지정한 최소 경로 길이로는 적절한 파밍 경로를 계산하지 못했습니다.",
	farmerror = "HarvestFarm 오류",
	farmnoresources = "자원을 찾지 못했습니다.\n이 지도에 자원이 없거나 선택한 자원 종류가 없습니다.",
	farmsuccess = "HarvestFarm이 킬로미터당 <<1>>개 노드가 있는 파밍 경로를 계산했습니다.\n\n경로의 시작 지점을 정하려면 경로 핀 중 하나를 클릭하세요.",
	farmdescription = "HarvestFarm이 시간 대비 자원 효율이 매우 높은 경로를 계산합니다.\n경로 생성 후 선택된 자원 중 하나를 클릭해 시작 지점을 지정하세요.",
	farmminlength = "최소 길이",
	farmminlengthdescription = "경로가 길수록 다음 순환을 시작할 때 자원이 리젠되어 있을 가능성이 높습니다.\n하지만 경로가 짧을수록 시간 대비 자원 효율은 더 좋습니다.\n(최소 길이 단위는 킬로미터입니다.)",
	tourpin = "다음 경로 목표",
	calculatetour = "경로 계산",
	showtourinterface = "경로 UI 표시",
	canceltour = "경로 취소",
	reverttour = "경로 방향 반전",
	resourcetypes = "자원 종류",
	skiptarget = "현재 목표 건너뛰기",
	removetarget = "현재 목표 제거",
	nodesperminute = "분당 노드 수",
	distancetotarget = "다음 자원까지 거리",
	showarrow = "방향 표시",
	removetour = "경로 제거",
	undo = "마지막 변경 취소",
	tourname = "경로 이름: ",
	defaultname = "이름 없는 경로",
	savedtours = "이 지도에 저장된 경로:",
	notourformap = "이 지도에 저장된 경로가 없습니다.",
	load = "불러오기",
	delete = "삭제",
	saveexiststitle = "확인 필요",
	saveexists = "이 지도에 <<1>> 이름의 경로가 이미 있습니다. 덮어쓰시겠습니까?",
	savenotour = "저장할 수 있는 경로가 없습니다.",
	loaderror = "경로를 불러오지 못했습니다.",
	removepintype = "경로에서 <<1>>을(를) 제거하시겠습니까?",
	removepintypetitle = "제거 확인",

	-- extra harvestmap menu
	farmmenu = "파밍 경로 편집기",
	editordescription = [[이 메뉴에서 경로를 만들고 편집할 수 있습니다.
현재 다른 경로가 활성화되어 있지 않다면 지도 핀을 클릭해서 새 경로를 만들 수 있습니다.
활성화된 경로가 있다면 일부 구간을 교체하는 방식으로 편집할 수 있습니다.
- 먼저 현재 (빨간색) 경로의 핀 하나를 클릭합니다.
- 그다음 경로에 추가할 핀들을 클릭합니다. (초록색 경로가 나타납니다)
- 마지막으로 빨간 경로의 다른 핀을 다시 클릭합니다.
그러면 초록 경로가 빨간 경로 안에 삽입됩니다.]],
	editorstats = [[노드 수: <<1>>
길이: <<2>> m
킬로미터당 노드 수: <<3>>]],

	-- filter profiles
	filterprofilebutton = "필터 프로필 메뉴 열기",
	filtertitle = "필터 프로필 메뉴",
	filtermap = "지도 핀 필터 프로필",
	filtercompass = "나침반 핀 필터 프로필",
	filterworld = "3D 핀 필터 프로필",
	unnamedfilterprofile = "이름 없는 프로필",
	defaultprofilename = "기본 필터 프로필",

	-- SI names to fit with ZOS api
	SI_BINDING_NAME_SKIP_TARGET = "목표 건너뛰기",
	SI_BINDING_NAME_TOGGLE_WORLDPINS = "3D 핀 전환",
	SI_BINDING_NAME_TOGGLE_MAPPINS = "지도 핀 전환",
	SI_BINDING_NAME_TOGGLE_MINIMAPPINS = "미니맵 핀 전환",
	SI_BINDING_NAME_HARVEST_SHOW_PANEL = "HarvestMap 경로 편집기 열기",
	SI_BINDING_NAME_HARVEST_SHOW_FILTER = "HarvestMap 필터 메뉴 열기",
	HARVESTFARM_GENERATOR = "새 경로 생성",
	HARVESTFARM_EDITOR = "경로 편집",
	HARVESTFARM_SAVE = "경로 저장/불러오기",
}
