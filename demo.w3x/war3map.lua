function InitGlobals()
end

function CreateAllItems()
local itemID

BlzCreateItemWithSkin(FourCC("rlif"), -883.4, -107.4, FourCC("rlif"))
end

function CreateUnitsForPlayer0()
local p = Player(0)
local u
local unitID
local t
local life

u = BlzCreateUnitWithSkin(p, FourCC("hdhw"), -1436.1, 535.8, 206.714, FourCC("hdhw"))
u = BlzCreateUnitWithSkin(p, FourCC("Hpal"), -1089.7, 0.0, 332.300, FourCC("Hpal"))
SetHeroLevel(u, 10, false)
u = BlzCreateUnitWithSkin(p, FourCC("hmpr"), -511.7, 680.3, 337.620, FourCC("hmpr"))
u = BlzCreateUnitWithSkin(p, FourCC("hmpr"), -465.2, 582.4, 79.038, FourCC("hmpr"))
u = BlzCreateUnitWithSkin(p, FourCC("hmpr"), -433.6, 492.1, 66.030, FourCC("hmpr"))
u = BlzCreateUnitWithSkin(p, FourCC("hmpr"), -417.7, 428.8, 124.600, FourCC("hmpr"))
u = BlzCreateUnitWithSkin(p, FourCC("hmpr"), -413.1, 380.9, 30.587, FourCC("hmpr"))
end

function CreateUnitsForPlayer1()
local p = Player(1)
local u
local unitID
local t
local life

u = BlzCreateUnitWithSkin(p, FourCC("hdhw"), -90.5, 430.9, 329.930, FourCC("hdhw"))
u = BlzCreateUnitWithSkin(p, FourCC("hdhw"), -54.9, 253.5, 329.930, FourCC("hdhw"))
u = BlzCreateUnitWithSkin(p, FourCC("hdhw"), -118.7, 682.6, 128.412, FourCC("hdhw"))
u = BlzCreateUnitWithSkin(p, FourCC("hdhw"), -197.9, 837.6, 254.418, FourCC("hdhw"))
u = BlzCreateUnitWithSkin(p, FourCC("hdhw"), -387.7, 920.9, 142.189, FourCC("hdhw"))
u = BlzCreateUnitWithSkin(p, FourCC("hdhw"), -72.9, 103.8, 79.313, FourCC("hdhw"))
u = BlzCreateUnitWithSkin(p, FourCC("hdhw"), -236.0, 15.1, 199.694, FourCC("hdhw"))
end

function CreateNeutralPassiveBuildings()
local p = Player(PLAYER_NEUTRAL_PASSIVE)
local u
local unitID
local t
local life

u = BlzCreateUnitWithSkin(p, FourCC("ngol"), -2560.0, 320.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), 2880.0, 640.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), -192.0, 2368.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), 512.0, -3264.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
end

function CreatePlayerBuildings()
end

function CreatePlayerUnits()
CreateUnitsForPlayer0()
CreateUnitsForPlayer1()
end

function CreateAllUnits()
CreateNeutralPassiveBuildings()
CreatePlayerBuildings()
CreatePlayerUnits()
end

function InitCustomPlayerSlots()
SetPlayerStartLocation(Player(0), 0)
SetPlayerColor(Player(0), ConvertPlayerColor(0))
SetPlayerRacePreference(Player(0), RACE_PREF_HUMAN)
SetPlayerRaceSelectable(Player(0), true)
SetPlayerController(Player(0), MAP_CONTROL_USER)
SetPlayerStartLocation(Player(1), 1)
SetPlayerColor(Player(1), ConvertPlayerColor(1))
SetPlayerRacePreference(Player(1), RACE_PREF_ORC)
SetPlayerRaceSelectable(Player(1), true)
SetPlayerController(Player(1), MAP_CONTROL_COMPUTER)
end

function InitCustomTeams()
SetPlayerTeam(Player(0), 0)
SetPlayerTeam(Player(1), 1)
end

function InitAllyPriorities()
SetStartLocPrioCount(1, 2)
SetStartLocPrio(1, 0, 0, MAP_LOC_PRIO_HIGH)
end

function main()
SetCameraBounds(-3328.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), -3584.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM), 3328.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), 3072.0 - GetCameraMargin(CAMERA_MARGIN_TOP), -3328.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), 3072.0 - GetCameraMargin(CAMERA_MARGIN_TOP), 3328.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), -3584.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM))
SetDayNightModels("Environment\\DNC\\DNCLordaeron\\DNCLordaeronTerrain\\DNCLordaeronTerrain.mdl", "Environment\\DNC\\DNCLordaeron\\DNCLordaeronUnit\\DNCLordaeronUnit.mdl")
NewSoundEnvironment("Default")
SetAmbientDaySound("LordaeronSummerDay")
SetAmbientNightSound("LordaeronSummerNight")
SetMapMusic("Music", true, 0)
CreateAllItems()
CreateAllUnits()
InitBlizzard()
InitGlobals()
end

function config()
SetMapName("TRIGSTR_001")
SetMapDescription("TRIGSTR_003")
SetPlayers(2)
SetTeams(2)
SetGamePlacement(MAP_PLACEMENT_USE_MAP_SETTINGS)
DefineStartLocation(0, -1984.0, -128.0)
DefineStartLocation(1, 2368.0, 320.0)
InitCustomPlayerSlots()
InitCustomTeams()
InitAllyPriorities()
end

