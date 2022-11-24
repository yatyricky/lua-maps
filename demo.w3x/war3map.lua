function InitGlobals()
end

function CreateUnitsForPlayer0()
local p = Player(0)
local u
local unitID
local t
local life

u = BlzCreateUnitWithSkin(p, FourCC("ugho"), -1064.7, 1466.8, 240.564, FourCC("ugho"))
u = BlzCreateUnitWithSkin(p, FourCC("ugho"), -1059.7, 1388.2, 235.543, FourCC("ugho"))
u = BlzCreateUnitWithSkin(p, FourCC("ugho"), -1222.9, 1484.4, 314.581, FourCC("ugho"))
u = BlzCreateUnitWithSkin(p, FourCC("ugho"), -1023.2, 1232.9, 123.007, FourCC("ugho"))
u = BlzCreateUnitWithSkin(p, FourCC("ugho"), -1090.7, 1094.0, 67.008, FourCC("ugho"))
u = BlzCreateUnitWithSkin(p, FourCC("U005"), -1439.0, 5.9, 138.080, FourCC("U005"))
u = BlzCreateUnitWithSkin(p, FourCC("U004"), -1467.6, 940.7, 31.872, FourCC("U004"))
u = BlzCreateUnitWithSkin(p, FourCC("U006"), -1437.0, 188.6, 53.829, FourCC("U006"))
u = BlzCreateUnitWithSkin(p, FourCC("U003"), -1551.0, 467.7, 184.071, FourCC("U003"))
end

function CreateUnitsForPlayer1()
local p = Player(1)
local u
local unitID
local t
local life

u = BlzCreateUnitWithSkin(p, FourCC("otau"), 387.9, 739.5, 275.007, FourCC("otau"))
u = BlzCreateUnitWithSkin(p, FourCC("otau"), 407.1, 475.1, 210.790, FourCC("otau"))
u = BlzCreateUnitWithSkin(p, FourCC("otau"), 354.9, 67.3, 76.401, FourCC("otau"))
u = BlzCreateUnitWithSkin(p, FourCC("ohun"), 553.5, 391.4, 144.046, FourCC("ohun"))
u = BlzCreateUnitWithSkin(p, FourCC("ohun"), 551.8, 326.7, 11.217, FourCC("ohun"))
u = BlzCreateUnitWithSkin(p, FourCC("ohun"), 568.7, 222.2, 339.422, FourCC("ohun"))
u = BlzCreateUnitWithSkin(p, FourCC("ohun"), 574.7, 146.6, 61.976, FourCC("ohun"))
u = BlzCreateUnitWithSkin(p, FourCC("ohun"), 572.8, -22.7, 296.849, FourCC("ohun"))
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
ForcePlayerStartLocation(Player(0), 0)
SetPlayerColor(Player(0), ConvertPlayerColor(0))
SetPlayerRacePreference(Player(0), RACE_PREF_ORC)
SetPlayerRaceSelectable(Player(0), false)
SetPlayerController(Player(0), MAP_CONTROL_USER)
SetPlayerStartLocation(Player(1), 1)
ForcePlayerStartLocation(Player(1), 1)
SetPlayerColor(Player(1), ConvertPlayerColor(1))
SetPlayerRacePreference(Player(1), RACE_PREF_NIGHTELF)
SetPlayerRaceSelectable(Player(1), false)
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

