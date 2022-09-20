---@class agent : handle

---@class event : agent

---@class player : agent

---@class widget : agent

---@class unit : widget

---@class destructable : widget

---@class item : widget

---@class ability : agent

---@class buff : ability

---@class force : agent

---@class group : agent

---@class trigger : agent

---@class triggercondition : agent

---@class triggeraction : handle

---@class timer : agent

---@class location : agent

---@class region : agent

---@class rect : agent

---@class boolexpr : agent

---@class sound : agent

---@class conditionfunc : boolexpr

---@class filterfunc : boolexpr

---@class unitpool : handle

---@class itempool : handle

---@class race : handle

---@class alliancetype : handle

---@class racepreference : handle

---@class gamestate : handle

---@class igamestate : gamestate

---@class fgamestate : gamestate

---@class playerstate : handle

---@class playerscore : handle

---@class playergameresult : handle

---@class unitstate : handle

---@class aidifficulty : handle

---@class eventid : handle

---@class gameevent : eventid

---@class playerevent : eventid

---@class playerunitevent : eventid

---@class unitevent : eventid

---@class limitop : eventid

---@class widgetevent : eventid

---@class dialogevent : eventid

---@class unittype : handle

---@class gamespeed : handle

---@class gamedifficulty : handle

---@class gametype : handle

---@class mapflag : handle

---@class mapvisibility : handle

---@class mapsetting : handle

---@class mapdensity : handle

---@class mapcontrol : handle

---@class minimapicon : handle

---@class playerslotstate : handle

---@class volumegroup : handle

---@class camerafield : handle

---@class camerasetup : handle

---@class playercolor : handle

---@class placement : handle

---@class startlocprio : handle

---@class raritycontrol : handle

---@class blendmode : handle

---@class texmapflags : handle

---@class effect : agent

---@class effecttype : handle

---@class weathereffect : handle

---@class terraindeformation : handle

---@class fogstate : handle

---@class fogmodifier : agent

---@class dialog : agent

---@class button : agent

---@class quest : agent

---@class questitem : agent

---@class defeatcondition : agent

---@class timerdialog : agent

---@class leaderboard : agent

---@class multiboard : agent

---@class multiboarditem : agent

---@class trackable : agent

---@class gamecache : agent

---@class version : handle

---@class itemtype : handle

---@class texttag : handle

---@class attacktype : handle

---@class damagetype : handle

---@class weapontype : handle

---@class soundtype : handle

---@class lightning : handle

---@class pathingtype : handle

---@class mousebuttontype : handle

---@class animtype : handle

---@class subanimtype : handle

---@class image : handle

---@class ubersplat : handle

---@class hashtable : agent

---@class framehandle : handle

---@class originframetype : handle

---@class framepointtype : handle

---@class textaligntype : handle

---@class frameeventtype : handle

---@class oskeytype : handle

---@class abilityintegerfield : handle

---@class abilityrealfield : handle

---@class abilitybooleanfield : handle

---@class abilitystringfield : handle

---@class abilityintegerlevelfield : handle

---@class abilityreallevelfield : handle

---@class abilitybooleanlevelfield : handle

---@class abilitystringlevelfield : handle

---@class abilityintegerlevelarrayfield : handle

---@class abilityreallevelarrayfield : handle

---@class abilitybooleanlevelarrayfield : handle

---@class abilitystringlevelarrayfield : handle

---@class unitintegerfield : handle

---@class unitrealfield : handle

---@class unitbooleanfield : handle

---@class unitstringfield : handle

---@class unitweaponintegerfield : handle

---@class unitweaponrealfield : handle

---@class unitweaponbooleanfield : handle

---@class unitweaponstringfield : handle

---@class itemintegerfield : handle

---@class itemrealfield : handle

---@class itembooleanfield : handle

---@class itemstringfield : handle

---@class movetype : handle

---@class targetflag : handle

---@class armortype : handle

---@class heroattribute : handle

---@class defensetype : handle

---@class regentype : handle

---@class unitcategory : handle

---@class pathingflag : handle

---@class commandbuttoneffect : handle

---@param i integer
---@return race
function ConvertRace(i) end

---@param i integer
---@return alliancetype
function ConvertAllianceType(i) end

---@param i integer
---@return racepreference
function ConvertRacePref(i) end

---@param i integer
---@return igamestate
function ConvertIGameState(i) end

---@param i integer
---@return fgamestate
function ConvertFGameState(i) end

---@param i integer
---@return playerstate
function ConvertPlayerState(i) end

---@param i integer
---@return playerscore
function ConvertPlayerScore(i) end

---@param i integer
---@return playergameresult
function ConvertPlayerGameResult(i) end

---@param i integer
---@return unitstate
function ConvertUnitState(i) end

---@param i integer
---@return aidifficulty
function ConvertAIDifficulty(i) end

---@param i integer
---@return gameevent
function ConvertGameEvent(i) end

---@param i integer
---@return playerevent
function ConvertPlayerEvent(i) end

---@param i integer
---@return playerunitevent
function ConvertPlayerUnitEvent(i) end

---@param i integer
---@return widgetevent
function ConvertWidgetEvent(i) end

---@param i integer
---@return dialogevent
function ConvertDialogEvent(i) end

---@param i integer
---@return unitevent
function ConvertUnitEvent(i) end

---@param i integer
---@return limitop
function ConvertLimitOp(i) end

---@param i integer
---@return unittype
function ConvertUnitType(i) end

---@param i integer
---@return gamespeed
function ConvertGameSpeed(i) end

---@param i integer
---@return placement
function ConvertPlacement(i) end

---@param i integer
---@return startlocprio
function ConvertStartLocPrio(i) end

---@param i integer
---@return gamedifficulty
function ConvertGameDifficulty(i) end

---@param i integer
---@return gametype
function ConvertGameType(i) end

---@param i integer
---@return mapflag
function ConvertMapFlag(i) end

---@param i integer
---@return mapvisibility
function ConvertMapVisibility(i) end

---@param i integer
---@return mapsetting
function ConvertMapSetting(i) end

---@param i integer
---@return mapdensity
function ConvertMapDensity(i) end

---@param i integer
---@return mapcontrol
function ConvertMapControl(i) end

---@param i integer
---@return playercolor
function ConvertPlayerColor(i) end

---@param i integer
---@return playerslotstate
function ConvertPlayerSlotState(i) end

---@param i integer
---@return volumegroup
function ConvertVolumeGroup(i) end

---@param i integer
---@return camerafield
function ConvertCameraField(i) end

---@param i integer
---@return blendmode
function ConvertBlendMode(i) end

---@param i integer
---@return raritycontrol
function ConvertRarityControl(i) end

---@param i integer
---@return texmapflags
function ConvertTexMapFlags(i) end

---@param i integer
---@return fogstate
function ConvertFogState(i) end

---@param i integer
---@return effecttype
function ConvertEffectType(i) end

---@param i integer
---@return version
function ConvertVersion(i) end

---@param i integer
---@return itemtype
function ConvertItemType(i) end

---@param i integer
---@return attacktype
function ConvertAttackType(i) end

---@param i integer
---@return damagetype
function ConvertDamageType(i) end

---@param i integer
---@return weapontype
function ConvertWeaponType(i) end

---@param i integer
---@return soundtype
function ConvertSoundType(i) end

---@param i integer
---@return pathingtype
function ConvertPathingType(i) end

---@param i integer
---@return mousebuttontype
function ConvertMouseButtonType(i) end

---@param i integer
---@return animtype
function ConvertAnimType(i) end

---@param i integer
---@return subanimtype
function ConvertSubAnimType(i) end

---@param i integer
---@return originframetype
function ConvertOriginFrameType(i) end

---@param i integer
---@return framepointtype
function ConvertFramePointType(i) end

---@param i integer
---@return textaligntype
function ConvertTextAlignType(i) end

---@param i integer
---@return frameeventtype
function ConvertFrameEventType(i) end

---@param i integer
---@return oskeytype
function ConvertOsKeyType(i) end

---@param i integer
---@return abilityintegerfield
function ConvertAbilityIntegerField(i) end

---@param i integer
---@return abilityrealfield
function ConvertAbilityRealField(i) end

---@param i integer
---@return abilitybooleanfield
function ConvertAbilityBooleanField(i) end

---@param i integer
---@return abilitystringfield
function ConvertAbilityStringField(i) end

---@param i integer
---@return abilityintegerlevelfield
function ConvertAbilityIntegerLevelField(i) end

---@param i integer
---@return abilityreallevelfield
function ConvertAbilityRealLevelField(i) end

---@param i integer
---@return abilitybooleanlevelfield
function ConvertAbilityBooleanLevelField(i) end

---@param i integer
---@return abilitystringlevelfield
function ConvertAbilityStringLevelField(i) end

---@param i integer
---@return abilityintegerlevelarrayfield
function ConvertAbilityIntegerLevelArrayField(i) end

---@param i integer
---@return abilityreallevelarrayfield
function ConvertAbilityRealLevelArrayField(i) end

---@param i integer
---@return abilitybooleanlevelarrayfield
function ConvertAbilityBooleanLevelArrayField(i) end

---@param i integer
---@return abilitystringlevelarrayfield
function ConvertAbilityStringLevelArrayField(i) end

---@param i integer
---@return unitintegerfield
function ConvertUnitIntegerField(i) end

---@param i integer
---@return unitrealfield
function ConvertUnitRealField(i) end

---@param i integer
---@return unitbooleanfield
function ConvertUnitBooleanField(i) end

---@param i integer
---@return unitstringfield
function ConvertUnitStringField(i) end

---@param i integer
---@return unitweaponintegerfield
function ConvertUnitWeaponIntegerField(i) end

---@param i integer
---@return unitweaponrealfield
function ConvertUnitWeaponRealField(i) end

---@param i integer
---@return unitweaponbooleanfield
function ConvertUnitWeaponBooleanField(i) end

---@param i integer
---@return unitweaponstringfield
function ConvertUnitWeaponStringField(i) end

---@param i integer
---@return itemintegerfield
function ConvertItemIntegerField(i) end

---@param i integer
---@return itemrealfield
function ConvertItemRealField(i) end

---@param i integer
---@return itembooleanfield
function ConvertItemBooleanField(i) end

---@param i integer
---@return itemstringfield
function ConvertItemStringField(i) end

---@param i integer
---@return movetype
function ConvertMoveType(i) end

---@param i integer
---@return targetflag
function ConvertTargetFlag(i) end

---@param i integer
---@return armortype
function ConvertArmorType(i) end

---@param i integer
---@return heroattribute
function ConvertHeroAttribute(i) end

---@param i integer
---@return defensetype
function ConvertDefenseType(i) end

---@param i integer
---@return regentype
function ConvertRegenType(i) end

---@param i integer
---@return unitcategory
function ConvertUnitCategory(i) end

---@param i integer
---@return pathingflag
function ConvertPathingFlag(i) end

---@param orderIdString string
---@return integer
function OrderId(orderIdString) end

---@param orderId integer
---@return string
function OrderId2String(orderId) end

---@param unitIdString string
---@return integer
function UnitId(unitIdString) end

---@param unitId integer
---@return string
function UnitId2String(unitId) end

---@param abilityIdString string
---@return integer
function AbilityId(abilityIdString) end

---@param abilityId integer
---@return string
function AbilityId2String(abilityId) end

---@param objectId integer
---@return string
function GetObjectName(objectId) end

---@return integer
function GetBJMaxPlayers() end

---@return integer
function GetBJPlayerNeutralVictim() end

---@return integer
function GetBJPlayerNeutralExtra() end

---@return integer
function GetBJMaxPlayerSlots() end

---@return integer
function GetPlayerNeutralPassive() end

---@return integer
function GetPlayerNeutralAggressive() end

---false
---@type boolean
FALSE = nil

---true
---@type boolean
TRUE = nil

---32768
---@type integer
JASS_MAX_ARRAY_SIZE = nil

---GetPlayerNeutralPassive()
---@type integer
PLAYER_NEUTRAL_PASSIVE = nil

---GetPlayerNeutralAggressive()
---@type integer
PLAYER_NEUTRAL_AGGRESSIVE = nil

---ConvertPlayerColor(0)
---@type playercolor
PLAYER_COLOR_RED = nil

---ConvertPlayerColor(1)
---@type playercolor
PLAYER_COLOR_BLUE = nil

---ConvertPlayerColor(2)
---@type playercolor
PLAYER_COLOR_CYAN = nil

---ConvertPlayerColor(3)
---@type playercolor
PLAYER_COLOR_PURPLE = nil

---ConvertPlayerColor(4)
---@type playercolor
PLAYER_COLOR_YELLOW = nil

---ConvertPlayerColor(5)
---@type playercolor
PLAYER_COLOR_ORANGE = nil

---ConvertPlayerColor(6)
---@type playercolor
PLAYER_COLOR_GREEN = nil

---ConvertPlayerColor(7)
---@type playercolor
PLAYER_COLOR_PINK = nil

---ConvertPlayerColor(8)
---@type playercolor
PLAYER_COLOR_LIGHT_GRAY = nil

---ConvertPlayerColor(9)
---@type playercolor
PLAYER_COLOR_LIGHT_BLUE = nil

---ConvertPlayerColor(10)
---@type playercolor
PLAYER_COLOR_AQUA = nil

---ConvertPlayerColor(11)
---@type playercolor
PLAYER_COLOR_BROWN = nil

---ConvertPlayerColor(12)
---@type playercolor
PLAYER_COLOR_MAROON = nil

---ConvertPlayerColor(13)
---@type playercolor
PLAYER_COLOR_NAVY = nil

---ConvertPlayerColor(14)
---@type playercolor
PLAYER_COLOR_TURQUOISE = nil

---ConvertPlayerColor(15)
---@type playercolor
PLAYER_COLOR_VIOLET = nil

---ConvertPlayerColor(16)
---@type playercolor
PLAYER_COLOR_WHEAT = nil

---ConvertPlayerColor(17)
---@type playercolor
PLAYER_COLOR_PEACH = nil

---ConvertPlayerColor(18)
---@type playercolor
PLAYER_COLOR_MINT = nil

---ConvertPlayerColor(19)
---@type playercolor
PLAYER_COLOR_LAVENDER = nil

---ConvertPlayerColor(20)
---@type playercolor
PLAYER_COLOR_COAL = nil

---ConvertPlayerColor(21)
---@type playercolor
PLAYER_COLOR_SNOW = nil

---ConvertPlayerColor(22)
---@type playercolor
PLAYER_COLOR_EMERALD = nil

---ConvertPlayerColor(23)
---@type playercolor
PLAYER_COLOR_PEANUT = nil

---ConvertRace(1)
---@type race
RACE_HUMAN = nil

---ConvertRace(2)
---@type race
RACE_ORC = nil

---ConvertRace(3)
---@type race
RACE_UNDEAD = nil

---ConvertRace(4)
---@type race
RACE_NIGHTELF = nil

---ConvertRace(5)
---@type race
RACE_DEMON = nil

---ConvertRace(7)
---@type race
RACE_OTHER = nil

---ConvertPlayerGameResult(0)
---@type playergameresult
PLAYER_GAME_RESULT_VICTORY = nil

---ConvertPlayerGameResult(1)
---@type playergameresult
PLAYER_GAME_RESULT_DEFEAT = nil

---ConvertPlayerGameResult(2)
---@type playergameresult
PLAYER_GAME_RESULT_TIE = nil

---ConvertPlayerGameResult(3)
---@type playergameresult
PLAYER_GAME_RESULT_NEUTRAL = nil

---ConvertAllianceType(0)
---@type alliancetype
ALLIANCE_PASSIVE = nil

---ConvertAllianceType(1)
---@type alliancetype
ALLIANCE_HELP_REQUEST = nil

---ConvertAllianceType(2)
---@type alliancetype
ALLIANCE_HELP_RESPONSE = nil

---ConvertAllianceType(3)
---@type alliancetype
ALLIANCE_SHARED_XP = nil

---ConvertAllianceType(4)
---@type alliancetype
ALLIANCE_SHARED_SPELLS = nil

---ConvertAllianceType(5)
---@type alliancetype
ALLIANCE_SHARED_VISION = nil

---ConvertAllianceType(6)
---@type alliancetype
ALLIANCE_SHARED_CONTROL = nil

---ConvertAllianceType(7)
---@type alliancetype
ALLIANCE_SHARED_ADVANCED_CONTROL = nil

---ConvertAllianceType(8)
---@type alliancetype
ALLIANCE_RESCUABLE = nil

---ConvertAllianceType(9)
---@type alliancetype
ALLIANCE_SHARED_VISION_FORCED = nil

---ConvertVersion(0)
---@type version
VERSION_REIGN_OF_CHAOS = nil

---ConvertVersion(1)
---@type version
VERSION_FROZEN_THRONE = nil

---ConvertAttackType(0)
---@type attacktype
ATTACK_TYPE_NORMAL = nil

---ConvertAttackType(1)
---@type attacktype
ATTACK_TYPE_MELEE = nil

---ConvertAttackType(2)
---@type attacktype
ATTACK_TYPE_PIERCE = nil

---ConvertAttackType(3)
---@type attacktype
ATTACK_TYPE_SIEGE = nil

---ConvertAttackType(4)
---@type attacktype
ATTACK_TYPE_MAGIC = nil

---ConvertAttackType(5)
---@type attacktype
ATTACK_TYPE_CHAOS = nil

---ConvertAttackType(6)
---@type attacktype
ATTACK_TYPE_HERO = nil

---ConvertDamageType(0)
---@type damagetype
DAMAGE_TYPE_UNKNOWN = nil

---ConvertDamageType(4)
---@type damagetype
DAMAGE_TYPE_NORMAL = nil

---ConvertDamageType(5)
---@type damagetype
DAMAGE_TYPE_ENHANCED = nil

---ConvertDamageType(8)
---@type damagetype
DAMAGE_TYPE_FIRE = nil

---ConvertDamageType(9)
---@type damagetype
DAMAGE_TYPE_COLD = nil

---ConvertDamageType(10)
---@type damagetype
DAMAGE_TYPE_LIGHTNING = nil

---ConvertDamageType(11)
---@type damagetype
DAMAGE_TYPE_POISON = nil

---ConvertDamageType(12)
---@type damagetype
DAMAGE_TYPE_DISEASE = nil

---ConvertDamageType(13)
---@type damagetype
DAMAGE_TYPE_DIVINE = nil

---ConvertDamageType(14)
---@type damagetype
DAMAGE_TYPE_MAGIC = nil

---ConvertDamageType(15)
---@type damagetype
DAMAGE_TYPE_SONIC = nil

---ConvertDamageType(16)
---@type damagetype
DAMAGE_TYPE_ACID = nil

---ConvertDamageType(17)
---@type damagetype
DAMAGE_TYPE_FORCE = nil

---ConvertDamageType(18)
---@type damagetype
DAMAGE_TYPE_DEATH = nil

---ConvertDamageType(19)
---@type damagetype
DAMAGE_TYPE_MIND = nil

---ConvertDamageType(20)
---@type damagetype
DAMAGE_TYPE_PLANT = nil

---ConvertDamageType(21)
---@type damagetype
DAMAGE_TYPE_DEFENSIVE = nil

---ConvertDamageType(22)
---@type damagetype
DAMAGE_TYPE_DEMOLITION = nil

---ConvertDamageType(23)
---@type damagetype
DAMAGE_TYPE_SLOW_POISON = nil

---ConvertDamageType(24)
---@type damagetype
DAMAGE_TYPE_SPIRIT_LINK = nil

---ConvertDamageType(25)
---@type damagetype
DAMAGE_TYPE_SHADOW_STRIKE = nil

---ConvertDamageType(26)
---@type damagetype
DAMAGE_TYPE_UNIVERSAL = nil

---ConvertWeaponType(0)
---@type weapontype
WEAPON_TYPE_WHOKNOWS = nil

---ConvertWeaponType(1)
---@type weapontype
WEAPON_TYPE_METAL_LIGHT_CHOP = nil

---ConvertWeaponType(2)
---@type weapontype
WEAPON_TYPE_METAL_MEDIUM_CHOP = nil

---ConvertWeaponType(3)
---@type weapontype
WEAPON_TYPE_METAL_HEAVY_CHOP = nil

---ConvertWeaponType(4)
---@type weapontype
WEAPON_TYPE_METAL_LIGHT_SLICE = nil

---ConvertWeaponType(5)
---@type weapontype
WEAPON_TYPE_METAL_MEDIUM_SLICE = nil

---ConvertWeaponType(6)
---@type weapontype
WEAPON_TYPE_METAL_HEAVY_SLICE = nil

---ConvertWeaponType(7)
---@type weapontype
WEAPON_TYPE_METAL_MEDIUM_BASH = nil

---ConvertWeaponType(8)
---@type weapontype
WEAPON_TYPE_METAL_HEAVY_BASH = nil

---ConvertWeaponType(9)
---@type weapontype
WEAPON_TYPE_METAL_MEDIUM_STAB = nil

---ConvertWeaponType(10)
---@type weapontype
WEAPON_TYPE_METAL_HEAVY_STAB = nil

---ConvertWeaponType(11)
---@type weapontype
WEAPON_TYPE_WOOD_LIGHT_SLICE = nil

---ConvertWeaponType(12)
---@type weapontype
WEAPON_TYPE_WOOD_MEDIUM_SLICE = nil

---ConvertWeaponType(13)
---@type weapontype
WEAPON_TYPE_WOOD_HEAVY_SLICE = nil

---ConvertWeaponType(14)
---@type weapontype
WEAPON_TYPE_WOOD_LIGHT_BASH = nil

---ConvertWeaponType(15)
---@type weapontype
WEAPON_TYPE_WOOD_MEDIUM_BASH = nil

---ConvertWeaponType(16)
---@type weapontype
WEAPON_TYPE_WOOD_HEAVY_BASH = nil

---ConvertWeaponType(17)
---@type weapontype
WEAPON_TYPE_WOOD_LIGHT_STAB = nil

---ConvertWeaponType(18)
---@type weapontype
WEAPON_TYPE_WOOD_MEDIUM_STAB = nil

---ConvertWeaponType(19)
---@type weapontype
WEAPON_TYPE_CLAW_LIGHT_SLICE = nil

---ConvertWeaponType(20)
---@type weapontype
WEAPON_TYPE_CLAW_MEDIUM_SLICE = nil

---ConvertWeaponType(21)
---@type weapontype
WEAPON_TYPE_CLAW_HEAVY_SLICE = nil

---ConvertWeaponType(22)
---@type weapontype
WEAPON_TYPE_AXE_MEDIUM_CHOP = nil

---ConvertWeaponType(23)
---@type weapontype
WEAPON_TYPE_ROCK_HEAVY_BASH = nil

---ConvertPathingType(0)
---@type pathingtype
PATHING_TYPE_ANY = nil

---ConvertPathingType(1)
---@type pathingtype
PATHING_TYPE_WALKABILITY = nil

---ConvertPathingType(2)
---@type pathingtype
PATHING_TYPE_FLYABILITY = nil

---ConvertPathingType(3)
---@type pathingtype
PATHING_TYPE_BUILDABILITY = nil

---ConvertPathingType(4)
---@type pathingtype
PATHING_TYPE_PEONHARVESTPATHING = nil

---ConvertPathingType(5)
---@type pathingtype
PATHING_TYPE_BLIGHTPATHING = nil

---ConvertPathingType(6)
---@type pathingtype
PATHING_TYPE_FLOATABILITY = nil

---ConvertPathingType(7)
---@type pathingtype
PATHING_TYPE_AMPHIBIOUSPATHING = nil

---ConvertMouseButtonType(1)
---@type mousebuttontype
MOUSE_BUTTON_TYPE_LEFT = nil

---ConvertMouseButtonType(2)
---@type mousebuttontype
MOUSE_BUTTON_TYPE_MIDDLE = nil

---ConvertMouseButtonType(3)
---@type mousebuttontype
MOUSE_BUTTON_TYPE_RIGHT = nil

---ConvertAnimType(0)
---@type animtype
ANIM_TYPE_BIRTH = nil

---ConvertAnimType(1)
---@type animtype
ANIM_TYPE_DEATH = nil

---ConvertAnimType(2)
---@type animtype
ANIM_TYPE_DECAY = nil

---ConvertAnimType(3)
---@type animtype
ANIM_TYPE_DISSIPATE = nil

---ConvertAnimType(4)
---@type animtype
ANIM_TYPE_STAND = nil

---ConvertAnimType(5)
---@type animtype
ANIM_TYPE_WALK = nil

---ConvertAnimType(6)
---@type animtype
ANIM_TYPE_ATTACK = nil

---ConvertAnimType(7)
---@type animtype
ANIM_TYPE_MORPH = nil

---ConvertAnimType(8)
---@type animtype
ANIM_TYPE_SLEEP = nil

---ConvertAnimType(9)
---@type animtype
ANIM_TYPE_SPELL = nil

---ConvertAnimType(10)
---@type animtype
ANIM_TYPE_PORTRAIT = nil

---ConvertSubAnimType(11)
---@type subanimtype
SUBANIM_TYPE_ROOTED = nil

---ConvertSubAnimType(12)
---@type subanimtype
SUBANIM_TYPE_ALTERNATE_EX = nil

---ConvertSubAnimType(13)
---@type subanimtype
SUBANIM_TYPE_LOOPING = nil

---ConvertSubAnimType(14)
---@type subanimtype
SUBANIM_TYPE_SLAM = nil

---ConvertSubAnimType(15)
---@type subanimtype
SUBANIM_TYPE_THROW = nil

---ConvertSubAnimType(16)
---@type subanimtype
SUBANIM_TYPE_SPIKED = nil

---ConvertSubAnimType(17)
---@type subanimtype
SUBANIM_TYPE_FAST = nil

---ConvertSubAnimType(18)
---@type subanimtype
SUBANIM_TYPE_SPIN = nil

---ConvertSubAnimType(19)
---@type subanimtype
SUBANIM_TYPE_READY = nil

---ConvertSubAnimType(20)
---@type subanimtype
SUBANIM_TYPE_CHANNEL = nil

---ConvertSubAnimType(21)
---@type subanimtype
SUBANIM_TYPE_DEFEND = nil

---ConvertSubAnimType(22)
---@type subanimtype
SUBANIM_TYPE_VICTORY = nil

---ConvertSubAnimType(23)
---@type subanimtype
SUBANIM_TYPE_TURN = nil

---ConvertSubAnimType(24)
---@type subanimtype
SUBANIM_TYPE_LEFT = nil

---ConvertSubAnimType(25)
---@type subanimtype
SUBANIM_TYPE_RIGHT = nil

---ConvertSubAnimType(26)
---@type subanimtype
SUBANIM_TYPE_FIRE = nil

---ConvertSubAnimType(27)
---@type subanimtype
SUBANIM_TYPE_FLESH = nil

---ConvertSubAnimType(28)
---@type subanimtype
SUBANIM_TYPE_HIT = nil

---ConvertSubAnimType(29)
---@type subanimtype
SUBANIM_TYPE_WOUNDED = nil

---ConvertSubAnimType(30)
---@type subanimtype
SUBANIM_TYPE_LIGHT = nil

---ConvertSubAnimType(31)
---@type subanimtype
SUBANIM_TYPE_MODERATE = nil

---ConvertSubAnimType(32)
---@type subanimtype
SUBANIM_TYPE_SEVERE = nil

---ConvertSubAnimType(33)
---@type subanimtype
SUBANIM_TYPE_CRITICAL = nil

---ConvertSubAnimType(34)
---@type subanimtype
SUBANIM_TYPE_COMPLETE = nil

---ConvertSubAnimType(35)
---@type subanimtype
SUBANIM_TYPE_GOLD = nil

---ConvertSubAnimType(36)
---@type subanimtype
SUBANIM_TYPE_LUMBER = nil

---ConvertSubAnimType(37)
---@type subanimtype
SUBANIM_TYPE_WORK = nil

---ConvertSubAnimType(38)
---@type subanimtype
SUBANIM_TYPE_TALK = nil

---ConvertSubAnimType(39)
---@type subanimtype
SUBANIM_TYPE_FIRST = nil

---ConvertSubAnimType(40)
---@type subanimtype
SUBANIM_TYPE_SECOND = nil

---ConvertSubAnimType(41)
---@type subanimtype
SUBANIM_TYPE_THIRD = nil

---ConvertSubAnimType(42)
---@type subanimtype
SUBANIM_TYPE_FOURTH = nil

---ConvertSubAnimType(43)
---@type subanimtype
SUBANIM_TYPE_FIFTH = nil

---ConvertSubAnimType(44)
---@type subanimtype
SUBANIM_TYPE_ONE = nil

---ConvertSubAnimType(45)
---@type subanimtype
SUBANIM_TYPE_TWO = nil

---ConvertSubAnimType(46)
---@type subanimtype
SUBANIM_TYPE_THREE = nil

---ConvertSubAnimType(47)
---@type subanimtype
SUBANIM_TYPE_FOUR = nil

---ConvertSubAnimType(48)
---@type subanimtype
SUBANIM_TYPE_FIVE = nil

---ConvertSubAnimType(49)
---@type subanimtype
SUBANIM_TYPE_SMALL = nil

---ConvertSubAnimType(50)
---@type subanimtype
SUBANIM_TYPE_MEDIUM = nil

---ConvertSubAnimType(51)
---@type subanimtype
SUBANIM_TYPE_LARGE = nil

---ConvertSubAnimType(52)
---@type subanimtype
SUBANIM_TYPE_UPGRADE = nil

---ConvertSubAnimType(53)
---@type subanimtype
SUBANIM_TYPE_DRAIN = nil

---ConvertSubAnimType(54)
---@type subanimtype
SUBANIM_TYPE_FILL = nil

---ConvertSubAnimType(55)
---@type subanimtype
SUBANIM_TYPE_CHAINLIGHTNING = nil

---ConvertSubAnimType(56)
---@type subanimtype
SUBANIM_TYPE_EATTREE = nil

---ConvertSubAnimType(57)
---@type subanimtype
SUBANIM_TYPE_PUKE = nil

---ConvertSubAnimType(58)
---@type subanimtype
SUBANIM_TYPE_FLAIL = nil

---ConvertSubAnimType(59)
---@type subanimtype
SUBANIM_TYPE_OFF = nil

---ConvertSubAnimType(60)
---@type subanimtype
SUBANIM_TYPE_SWIM = nil

---ConvertSubAnimType(61)
---@type subanimtype
SUBANIM_TYPE_ENTANGLE = nil

---ConvertSubAnimType(62)
---@type subanimtype
SUBANIM_TYPE_BERSERK = nil

---ConvertRacePref(1)
---@type racepreference
RACE_PREF_HUMAN = nil

---ConvertRacePref(2)
---@type racepreference
RACE_PREF_ORC = nil

---ConvertRacePref(4)
---@type racepreference
RACE_PREF_NIGHTELF = nil

---ConvertRacePref(8)
---@type racepreference
RACE_PREF_UNDEAD = nil

---ConvertRacePref(16)
---@type racepreference
RACE_PREF_DEMON = nil

---ConvertRacePref(32)
---@type racepreference
RACE_PREF_RANDOM = nil

---ConvertRacePref(64)
---@type racepreference
RACE_PREF_USER_SELECTABLE = nil

---ConvertMapControl(0)
---@type mapcontrol
MAP_CONTROL_USER = nil

---ConvertMapControl(1)
---@type mapcontrol
MAP_CONTROL_COMPUTER = nil

---ConvertMapControl(2)
---@type mapcontrol
MAP_CONTROL_RESCUABLE = nil

---ConvertMapControl(3)
---@type mapcontrol
MAP_CONTROL_NEUTRAL = nil

---ConvertMapControl(4)
---@type mapcontrol
MAP_CONTROL_CREEP = nil

---ConvertMapControl(5)
---@type mapcontrol
MAP_CONTROL_NONE = nil

---ConvertGameType(1)
---@type gametype
GAME_TYPE_MELEE = nil

---ConvertGameType(2)
---@type gametype
GAME_TYPE_FFA = nil

---ConvertGameType(4)
---@type gametype
GAME_TYPE_USE_MAP_SETTINGS = nil

---ConvertGameType(8)
---@type gametype
GAME_TYPE_BLIZ = nil

---ConvertGameType(16)
---@type gametype
GAME_TYPE_ONE_ON_ONE = nil

---ConvertGameType(32)
---@type gametype
GAME_TYPE_TWO_TEAM_PLAY = nil

---ConvertGameType(64)
---@type gametype
GAME_TYPE_THREE_TEAM_PLAY = nil

---ConvertGameType(128)
---@type gametype
GAME_TYPE_FOUR_TEAM_PLAY = nil

---ConvertMapFlag(1)
---@type mapflag
MAP_FOG_HIDE_TERRAIN = nil

---ConvertMapFlag(2)
---@type mapflag
MAP_FOG_MAP_EXPLORED = nil

---ConvertMapFlag(4)
---@type mapflag
MAP_FOG_ALWAYS_VISIBLE = nil

---ConvertMapFlag(8)
---@type mapflag
MAP_USE_HANDICAPS = nil

---ConvertMapFlag(16)
---@type mapflag
MAP_OBSERVERS = nil

---ConvertMapFlag(32)
---@type mapflag
MAP_OBSERVERS_ON_DEATH = nil

---ConvertMapFlag(128)
---@type mapflag
MAP_FIXED_COLORS = nil

---ConvertMapFlag(256)
---@type mapflag
MAP_LOCK_RESOURCE_TRADING = nil

---ConvertMapFlag(512)
---@type mapflag
MAP_RESOURCE_TRADING_ALLIES_ONLY = nil

---ConvertMapFlag(1024)
---@type mapflag
MAP_LOCK_ALLIANCE_CHANGES = nil

---ConvertMapFlag(2048)
---@type mapflag
MAP_ALLIANCE_CHANGES_HIDDEN = nil

---ConvertMapFlag(4096)
---@type mapflag
MAP_CHEATS = nil

---ConvertMapFlag(8192)
---@type mapflag
MAP_CHEATS_HIDDEN = nil

---ConvertMapFlag(8192*2)
---@type mapflag
MAP_LOCK_SPEED = nil

---ConvertMapFlag(8192*4)
---@type mapflag
MAP_LOCK_RANDOM_SEED = nil

---ConvertMapFlag(8192*8)
---@type mapflag
MAP_SHARED_ADVANCED_CONTROL = nil

---ConvertMapFlag(8192*16)
---@type mapflag
MAP_RANDOM_HERO = nil

---ConvertMapFlag(8192*32)
---@type mapflag
MAP_RANDOM_RACES = nil

---ConvertMapFlag(8192*64)
---@type mapflag
MAP_RELOADED = nil

---ConvertPlacement(0)   // random among all slots
---@type placement
MAP_PLACEMENT_RANDOM = nil

---ConvertPlacement(1)   // player 0 in start loc 0...
---@type placement
MAP_PLACEMENT_FIXED = nil

---ConvertPlacement(2)   // whatever was specified by the script
---@type placement
MAP_PLACEMENT_USE_MAP_SETTINGS = nil

---ConvertPlacement(3)   // random with allies next to each other
---@type placement
MAP_PLACEMENT_TEAMS_TOGETHER = nil

---ConvertStartLocPrio(0)
---@type startlocprio
MAP_LOC_PRIO_LOW = nil

---ConvertStartLocPrio(1)
---@type startlocprio
MAP_LOC_PRIO_HIGH = nil

---ConvertStartLocPrio(2)
---@type startlocprio
MAP_LOC_PRIO_NOT = nil

---ConvertMapDensity(0)
---@type mapdensity
MAP_DENSITY_NONE = nil

---ConvertMapDensity(1)
---@type mapdensity
MAP_DENSITY_LIGHT = nil

---ConvertMapDensity(2)
---@type mapdensity
MAP_DENSITY_MEDIUM = nil

---ConvertMapDensity(3)
---@type mapdensity
MAP_DENSITY_HEAVY = nil

---ConvertGameDifficulty(0)
---@type gamedifficulty
MAP_DIFFICULTY_EASY = nil

---ConvertGameDifficulty(1)
---@type gamedifficulty
MAP_DIFFICULTY_NORMAL = nil

---ConvertGameDifficulty(2)
---@type gamedifficulty
MAP_DIFFICULTY_HARD = nil

---ConvertGameDifficulty(3)
---@type gamedifficulty
MAP_DIFFICULTY_INSANE = nil

---ConvertGameSpeed(0)
---@type gamespeed
MAP_SPEED_SLOWEST = nil

---ConvertGameSpeed(1)
---@type gamespeed
MAP_SPEED_SLOW = nil

---ConvertGameSpeed(2)
---@type gamespeed
MAP_SPEED_NORMAL = nil

---ConvertGameSpeed(3)
---@type gamespeed
MAP_SPEED_FAST = nil

---ConvertGameSpeed(4)
---@type gamespeed
MAP_SPEED_FASTEST = nil

---ConvertPlayerSlotState(0)
---@type playerslotstate
PLAYER_SLOT_STATE_EMPTY = nil

---ConvertPlayerSlotState(1)
---@type playerslotstate
PLAYER_SLOT_STATE_PLAYING = nil

---ConvertPlayerSlotState(2)
---@type playerslotstate
PLAYER_SLOT_STATE_LEFT = nil

---ConvertVolumeGroup(0)
---@type volumegroup
SOUND_VOLUMEGROUP_UNITMOVEMENT = nil

---ConvertVolumeGroup(1)
---@type volumegroup
SOUND_VOLUMEGROUP_UNITSOUNDS = nil

---ConvertVolumeGroup(2)
---@type volumegroup
SOUND_VOLUMEGROUP_COMBAT = nil

---ConvertVolumeGroup(3)
---@type volumegroup
SOUND_VOLUMEGROUP_SPELLS = nil

---ConvertVolumeGroup(4)
---@type volumegroup
SOUND_VOLUMEGROUP_UI = nil

---ConvertVolumeGroup(5)
---@type volumegroup
SOUND_VOLUMEGROUP_MUSIC = nil

---ConvertVolumeGroup(6)
---@type volumegroup
SOUND_VOLUMEGROUP_AMBIENTSOUNDS = nil

---ConvertVolumeGroup(7)
---@type volumegroup
SOUND_VOLUMEGROUP_FIRE = nil

---ConvertVolumeGroup(8)
---@type volumegroup
SOUND_VOLUMEGROUP_CINEMATIC_GENERAL = nil

---ConvertVolumeGroup(9)
---@type volumegroup
SOUND_VOLUMEGROUP_CINEMATIC_AMBIENT = nil

---ConvertVolumeGroup(10)
---@type volumegroup
SOUND_VOLUMEGROUP_CINEMATIC_MUSIC = nil

---ConvertVolumeGroup(11)
---@type volumegroup
SOUND_VOLUMEGROUP_CINEMATIC_DIALOGUE = nil

---ConvertVolumeGroup(12)
---@type volumegroup
SOUND_VOLUMEGROUP_CINEMATIC_SOUND_EFFECTS_1 = nil

---ConvertVolumeGroup(13)
---@type volumegroup
SOUND_VOLUMEGROUP_CINEMATIC_SOUND_EFFECTS_2 = nil

---ConvertVolumeGroup(14)
---@type volumegroup
SOUND_VOLUMEGROUP_CINEMATIC_SOUND_EFFECTS_3 = nil

---ConvertIGameState(0)
---@type igamestate
GAME_STATE_DIVINE_INTERVENTION = nil

---ConvertIGameState(1)
---@type igamestate
GAME_STATE_DISCONNECTED = nil

---ConvertFGameState(2)
---@type fgamestate
GAME_STATE_TIME_OF_DAY = nil

---ConvertPlayerState(0)
---@type playerstate
PLAYER_STATE_GAME_RESULT = nil

---ConvertPlayerState(1)
---@type playerstate
PLAYER_STATE_RESOURCE_GOLD = nil

---ConvertPlayerState(2)
---@type playerstate
PLAYER_STATE_RESOURCE_LUMBER = nil

---ConvertPlayerState(3)
---@type playerstate
PLAYER_STATE_RESOURCE_HERO_TOKENS = nil

---ConvertPlayerState(4)
---@type playerstate
PLAYER_STATE_RESOURCE_FOOD_CAP = nil

---ConvertPlayerState(5)
---@type playerstate
PLAYER_STATE_RESOURCE_FOOD_USED = nil

---ConvertPlayerState(6)
---@type playerstate
PLAYER_STATE_FOOD_CAP_CEILING = nil

---ConvertPlayerState(7)
---@type playerstate
PLAYER_STATE_GIVES_BOUNTY = nil

---ConvertPlayerState(8)
---@type playerstate
PLAYER_STATE_ALLIED_VICTORY = nil

---ConvertPlayerState(9)
---@type playerstate
PLAYER_STATE_PLACED = nil

---ConvertPlayerState(10)
---@type playerstate
PLAYER_STATE_OBSERVER_ON_DEATH = nil

---ConvertPlayerState(11)
---@type playerstate
PLAYER_STATE_OBSERVER = nil

---ConvertPlayerState(12)
---@type playerstate
PLAYER_STATE_UNFOLLOWABLE = nil

---ConvertPlayerState(13)
---@type playerstate
PLAYER_STATE_GOLD_UPKEEP_RATE = nil

---ConvertPlayerState(14)
---@type playerstate
PLAYER_STATE_LUMBER_UPKEEP_RATE = nil

---ConvertPlayerState(15)
---@type playerstate
PLAYER_STATE_GOLD_GATHERED = nil

---ConvertPlayerState(16)
---@type playerstate
PLAYER_STATE_LUMBER_GATHERED = nil

---ConvertPlayerState(25)
---@type playerstate
PLAYER_STATE_NO_CREEP_SLEEP = nil

---ConvertUnitState(0)
---@type unitstate
UNIT_STATE_LIFE = nil

---ConvertUnitState(1)
---@type unitstate
UNIT_STATE_MAX_LIFE = nil

---ConvertUnitState(2)
---@type unitstate
UNIT_STATE_MANA = nil

---ConvertUnitState(3)
---@type unitstate
UNIT_STATE_MAX_MANA = nil

---ConvertAIDifficulty(0)
---@type aidifficulty
AI_DIFFICULTY_NEWBIE = nil

---ConvertAIDifficulty(1)
---@type aidifficulty
AI_DIFFICULTY_NORMAL = nil

---ConvertAIDifficulty(2)
---@type aidifficulty
AI_DIFFICULTY_INSANE = nil

---ConvertPlayerScore(0)
---@type playerscore
PLAYER_SCORE_UNITS_TRAINED = nil

---ConvertPlayerScore(1)
---@type playerscore
PLAYER_SCORE_UNITS_KILLED = nil

---ConvertPlayerScore(2)
---@type playerscore
PLAYER_SCORE_STRUCT_BUILT = nil

---ConvertPlayerScore(3)
---@type playerscore
PLAYER_SCORE_STRUCT_RAZED = nil

---ConvertPlayerScore(4)
---@type playerscore
PLAYER_SCORE_TECH_PERCENT = nil

---ConvertPlayerScore(5)
---@type playerscore
PLAYER_SCORE_FOOD_MAXPROD = nil

---ConvertPlayerScore(6)
---@type playerscore
PLAYER_SCORE_FOOD_MAXUSED = nil

---ConvertPlayerScore(7)
---@type playerscore
PLAYER_SCORE_HEROES_KILLED = nil

---ConvertPlayerScore(8)
---@type playerscore
PLAYER_SCORE_ITEMS_GAINED = nil

---ConvertPlayerScore(9)
---@type playerscore
PLAYER_SCORE_MERCS_HIRED = nil

---ConvertPlayerScore(10)
---@type playerscore
PLAYER_SCORE_GOLD_MINED_TOTAL = nil

---ConvertPlayerScore(11)
---@type playerscore
PLAYER_SCORE_GOLD_MINED_UPKEEP = nil

---ConvertPlayerScore(12)
---@type playerscore
PLAYER_SCORE_GOLD_LOST_UPKEEP = nil

---ConvertPlayerScore(13)
---@type playerscore
PLAYER_SCORE_GOLD_LOST_TAX = nil

---ConvertPlayerScore(14)
---@type playerscore
PLAYER_SCORE_GOLD_GIVEN = nil

---ConvertPlayerScore(15)
---@type playerscore
PLAYER_SCORE_GOLD_RECEIVED = nil

---ConvertPlayerScore(16)
---@type playerscore
PLAYER_SCORE_LUMBER_TOTAL = nil

---ConvertPlayerScore(17)
---@type playerscore
PLAYER_SCORE_LUMBER_LOST_UPKEEP = nil

---ConvertPlayerScore(18)
---@type playerscore
PLAYER_SCORE_LUMBER_LOST_TAX = nil

---ConvertPlayerScore(19)
---@type playerscore
PLAYER_SCORE_LUMBER_GIVEN = nil

---ConvertPlayerScore(20)
---@type playerscore
PLAYER_SCORE_LUMBER_RECEIVED = nil

---ConvertPlayerScore(21)
---@type playerscore
PLAYER_SCORE_UNIT_TOTAL = nil

---ConvertPlayerScore(22)
---@type playerscore
PLAYER_SCORE_HERO_TOTAL = nil

---ConvertPlayerScore(23)
---@type playerscore
PLAYER_SCORE_RESOURCE_TOTAL = nil

---ConvertPlayerScore(24)
---@type playerscore
PLAYER_SCORE_TOTAL = nil

---ConvertGameEvent(0)
---@type gameevent
EVENT_GAME_VICTORY = nil

---ConvertGameEvent(1)
---@type gameevent
EVENT_GAME_END_LEVEL = nil

---ConvertGameEvent(2)
---@type gameevent
EVENT_GAME_VARIABLE_LIMIT = nil

---ConvertGameEvent(3)
---@type gameevent
EVENT_GAME_STATE_LIMIT = nil

---ConvertGameEvent(4)
---@type gameevent
EVENT_GAME_TIMER_EXPIRED = nil

---ConvertGameEvent(5)
---@type gameevent
EVENT_GAME_ENTER_REGION = nil

---ConvertGameEvent(6)
---@type gameevent
EVENT_GAME_LEAVE_REGION = nil

---ConvertGameEvent(7)
---@type gameevent
EVENT_GAME_TRACKABLE_HIT = nil

---ConvertGameEvent(8)
---@type gameevent
EVENT_GAME_TRACKABLE_TRACK = nil

---ConvertGameEvent(9)
---@type gameevent
EVENT_GAME_SHOW_SKILL = nil

---ConvertGameEvent(10)
---@type gameevent
EVENT_GAME_BUILD_SUBMENU = nil

---ConvertPlayerEvent(11)
---@type playerevent
EVENT_PLAYER_STATE_LIMIT = nil

---ConvertPlayerEvent(12)
---@type playerevent
EVENT_PLAYER_ALLIANCE_CHANGED = nil

---ConvertPlayerEvent(13)
---@type playerevent
EVENT_PLAYER_DEFEAT = nil

---ConvertPlayerEvent(14)
---@type playerevent
EVENT_PLAYER_VICTORY = nil

---ConvertPlayerEvent(15)
---@type playerevent
EVENT_PLAYER_LEAVE = nil

---ConvertPlayerEvent(16)
---@type playerevent
EVENT_PLAYER_CHAT = nil

---ConvertPlayerEvent(17)
---@type playerevent
EVENT_PLAYER_END_CINEMATIC = nil

---ConvertPlayerUnitEvent(18)
---@type playerunitevent
EVENT_PLAYER_UNIT_ATTACKED = nil

---ConvertPlayerUnitEvent(19)
---@type playerunitevent
EVENT_PLAYER_UNIT_RESCUED = nil

---ConvertPlayerUnitEvent(20)
---@type playerunitevent
EVENT_PLAYER_UNIT_DEATH = nil

---ConvertPlayerUnitEvent(21)
---@type playerunitevent
EVENT_PLAYER_UNIT_DECAY = nil

---ConvertPlayerUnitEvent(22)
---@type playerunitevent
EVENT_PLAYER_UNIT_DETECTED = nil

---ConvertPlayerUnitEvent(23)
---@type playerunitevent
EVENT_PLAYER_UNIT_HIDDEN = nil

---ConvertPlayerUnitEvent(24)
---@type playerunitevent
EVENT_PLAYER_UNIT_SELECTED = nil

---ConvertPlayerUnitEvent(25)
---@type playerunitevent
EVENT_PLAYER_UNIT_DESELECTED = nil

---ConvertPlayerUnitEvent(26)
---@type playerunitevent
EVENT_PLAYER_UNIT_CONSTRUCT_START = nil

---ConvertPlayerUnitEvent(27)
---@type playerunitevent
EVENT_PLAYER_UNIT_CONSTRUCT_CANCEL = nil

---ConvertPlayerUnitEvent(28)
---@type playerunitevent
EVENT_PLAYER_UNIT_CONSTRUCT_FINISH = nil

---ConvertPlayerUnitEvent(29)
---@type playerunitevent
EVENT_PLAYER_UNIT_UPGRADE_START = nil

---ConvertPlayerUnitEvent(30)
---@type playerunitevent
EVENT_PLAYER_UNIT_UPGRADE_CANCEL = nil

---ConvertPlayerUnitEvent(31)
---@type playerunitevent
EVENT_PLAYER_UNIT_UPGRADE_FINISH = nil

---ConvertPlayerUnitEvent(32)
---@type playerunitevent
EVENT_PLAYER_UNIT_TRAIN_START = nil

---ConvertPlayerUnitEvent(33)
---@type playerunitevent
EVENT_PLAYER_UNIT_TRAIN_CANCEL = nil

---ConvertPlayerUnitEvent(34)
---@type playerunitevent
EVENT_PLAYER_UNIT_TRAIN_FINISH = nil

---ConvertPlayerUnitEvent(35)
---@type playerunitevent
EVENT_PLAYER_UNIT_RESEARCH_START = nil

---ConvertPlayerUnitEvent(36)
---@type playerunitevent
EVENT_PLAYER_UNIT_RESEARCH_CANCEL = nil

---ConvertPlayerUnitEvent(37)
---@type playerunitevent
EVENT_PLAYER_UNIT_RESEARCH_FINISH = nil

---ConvertPlayerUnitEvent(38)
---@type playerunitevent
EVENT_PLAYER_UNIT_ISSUED_ORDER = nil

---ConvertPlayerUnitEvent(39)
---@type playerunitevent
EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER = nil

---ConvertPlayerUnitEvent(40)
---@type playerunitevent
EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER = nil

---ConvertPlayerUnitEvent(40)    // for compat
---@type playerunitevent
EVENT_PLAYER_UNIT_ISSUED_UNIT_ORDER = nil

---ConvertPlayerUnitEvent(41)
---@type playerunitevent
EVENT_PLAYER_HERO_LEVEL = nil

---ConvertPlayerUnitEvent(42)
---@type playerunitevent
EVENT_PLAYER_HERO_SKILL = nil

---ConvertPlayerUnitEvent(43)
---@type playerunitevent
EVENT_PLAYER_HERO_REVIVABLE = nil

---ConvertPlayerUnitEvent(44)
---@type playerunitevent
EVENT_PLAYER_HERO_REVIVE_START = nil

---ConvertPlayerUnitEvent(45)
---@type playerunitevent
EVENT_PLAYER_HERO_REVIVE_CANCEL = nil

---ConvertPlayerUnitEvent(46)
---@type playerunitevent
EVENT_PLAYER_HERO_REVIVE_FINISH = nil

---ConvertPlayerUnitEvent(47)
---@type playerunitevent
EVENT_PLAYER_UNIT_SUMMON = nil

---ConvertPlayerUnitEvent(48)
---@type playerunitevent
EVENT_PLAYER_UNIT_DROP_ITEM = nil

---ConvertPlayerUnitEvent(49)
---@type playerunitevent
EVENT_PLAYER_UNIT_PICKUP_ITEM = nil

---ConvertPlayerUnitEvent(50)
---@type playerunitevent
EVENT_PLAYER_UNIT_USE_ITEM = nil

---ConvertPlayerUnitEvent(51)
---@type playerunitevent
EVENT_PLAYER_UNIT_LOADED = nil

---ConvertPlayerUnitEvent(308)
---@type playerunitevent
EVENT_PLAYER_UNIT_DAMAGED = nil

---ConvertPlayerUnitEvent(315)
---@type playerunitevent
EVENT_PLAYER_UNIT_DAMAGING = nil

---ConvertUnitEvent(52)
---@type unitevent
EVENT_UNIT_DAMAGED = nil

---ConvertUnitEvent(314)
---@type unitevent
EVENT_UNIT_DAMAGING = nil

---ConvertUnitEvent(53)
---@type unitevent
EVENT_UNIT_DEATH = nil

---ConvertUnitEvent(54)
---@type unitevent
EVENT_UNIT_DECAY = nil

---ConvertUnitEvent(55)
---@type unitevent
EVENT_UNIT_DETECTED = nil

---ConvertUnitEvent(56)
---@type unitevent
EVENT_UNIT_HIDDEN = nil

---ConvertUnitEvent(57)
---@type unitevent
EVENT_UNIT_SELECTED = nil

---ConvertUnitEvent(58)
---@type unitevent
EVENT_UNIT_DESELECTED = nil

---ConvertUnitEvent(59)
---@type unitevent
EVENT_UNIT_STATE_LIMIT = nil

---ConvertUnitEvent(60)
---@type unitevent
EVENT_UNIT_ACQUIRED_TARGET = nil

---ConvertUnitEvent(61)
---@type unitevent
EVENT_UNIT_TARGET_IN_RANGE = nil

---ConvertUnitEvent(62)
---@type unitevent
EVENT_UNIT_ATTACKED = nil

---ConvertUnitEvent(63)
---@type unitevent
EVENT_UNIT_RESCUED = nil

---ConvertUnitEvent(64)
---@type unitevent
EVENT_UNIT_CONSTRUCT_CANCEL = nil

---ConvertUnitEvent(65)
---@type unitevent
EVENT_UNIT_CONSTRUCT_FINISH = nil

---ConvertUnitEvent(66)
---@type unitevent
EVENT_UNIT_UPGRADE_START = nil

---ConvertUnitEvent(67)
---@type unitevent
EVENT_UNIT_UPGRADE_CANCEL = nil

---ConvertUnitEvent(68)
---@type unitevent
EVENT_UNIT_UPGRADE_FINISH = nil

---ConvertUnitEvent(69)
---@type unitevent
EVENT_UNIT_TRAIN_START = nil

---ConvertUnitEvent(70)
---@type unitevent
EVENT_UNIT_TRAIN_CANCEL = nil

---ConvertUnitEvent(71)
---@type unitevent
EVENT_UNIT_TRAIN_FINISH = nil

---ConvertUnitEvent(72)
---@type unitevent
EVENT_UNIT_RESEARCH_START = nil

---ConvertUnitEvent(73)
---@type unitevent
EVENT_UNIT_RESEARCH_CANCEL = nil

---ConvertUnitEvent(74)
---@type unitevent
EVENT_UNIT_RESEARCH_FINISH = nil

---ConvertUnitEvent(75)
---@type unitevent
EVENT_UNIT_ISSUED_ORDER = nil

---ConvertUnitEvent(76)
---@type unitevent
EVENT_UNIT_ISSUED_POINT_ORDER = nil

---ConvertUnitEvent(77)
---@type unitevent
EVENT_UNIT_ISSUED_TARGET_ORDER = nil

---ConvertUnitEvent(78)
---@type unitevent
EVENT_UNIT_HERO_LEVEL = nil

---ConvertUnitEvent(79)
---@type unitevent
EVENT_UNIT_HERO_SKILL = nil

---ConvertUnitEvent(80)
---@type unitevent
EVENT_UNIT_HERO_REVIVABLE = nil

---ConvertUnitEvent(81)
---@type unitevent
EVENT_UNIT_HERO_REVIVE_START = nil

---ConvertUnitEvent(82)
---@type unitevent
EVENT_UNIT_HERO_REVIVE_CANCEL = nil

---ConvertUnitEvent(83)
---@type unitevent
EVENT_UNIT_HERO_REVIVE_FINISH = nil

---ConvertUnitEvent(84)
---@type unitevent
EVENT_UNIT_SUMMON = nil

---ConvertUnitEvent(85)
---@type unitevent
EVENT_UNIT_DROP_ITEM = nil

---ConvertUnitEvent(86)
---@type unitevent
EVENT_UNIT_PICKUP_ITEM = nil

---ConvertUnitEvent(87)
---@type unitevent
EVENT_UNIT_USE_ITEM = nil

---ConvertUnitEvent(88)
---@type unitevent
EVENT_UNIT_LOADED = nil

---ConvertWidgetEvent(89)
---@type widgetevent
EVENT_WIDGET_DEATH = nil

---ConvertDialogEvent(90)
---@type dialogevent
EVENT_DIALOG_BUTTON_CLICK = nil

---ConvertDialogEvent(91)
---@type dialogevent
EVENT_DIALOG_CLICK = nil

---ConvertGameEvent(256)
---@type gameevent
EVENT_GAME_LOADED = nil

---ConvertGameEvent(257)
---@type gameevent
EVENT_GAME_TOURNAMENT_FINISH_SOON = nil

---ConvertGameEvent(258)
---@type gameevent
EVENT_GAME_TOURNAMENT_FINISH_NOW = nil

---ConvertGameEvent(259)
---@type gameevent
EVENT_GAME_SAVE = nil

---ConvertGameEvent(310)
---@type gameevent
EVENT_GAME_CUSTOM_UI_FRAME = nil

---ConvertPlayerEvent(261)
---@type playerevent
EVENT_PLAYER_ARROW_LEFT_DOWN = nil

---ConvertPlayerEvent(262)
---@type playerevent
EVENT_PLAYER_ARROW_LEFT_UP = nil

---ConvertPlayerEvent(263)
---@type playerevent
EVENT_PLAYER_ARROW_RIGHT_DOWN = nil

---ConvertPlayerEvent(264)
---@type playerevent
EVENT_PLAYER_ARROW_RIGHT_UP = nil

---ConvertPlayerEvent(265)
---@type playerevent
EVENT_PLAYER_ARROW_DOWN_DOWN = nil

---ConvertPlayerEvent(266)
---@type playerevent
EVENT_PLAYER_ARROW_DOWN_UP = nil

---ConvertPlayerEvent(267)
---@type playerevent
EVENT_PLAYER_ARROW_UP_DOWN = nil

---ConvertPlayerEvent(268)
---@type playerevent
EVENT_PLAYER_ARROW_UP_UP = nil

---ConvertPlayerEvent(305)
---@type playerevent
EVENT_PLAYER_MOUSE_DOWN = nil

---ConvertPlayerEvent(306)
---@type playerevent
EVENT_PLAYER_MOUSE_UP = nil

---ConvertPlayerEvent(307)
---@type playerevent
EVENT_PLAYER_MOUSE_MOVE = nil

---ConvertPlayerEvent(309)
---@type playerevent
EVENT_PLAYER_SYNC_DATA = nil

---ConvertPlayerEvent(311)
---@type playerevent
EVENT_PLAYER_KEY = nil

---ConvertPlayerEvent(312)
---@type playerevent
EVENT_PLAYER_KEY_DOWN = nil

---ConvertPlayerEvent(313)
---@type playerevent
EVENT_PLAYER_KEY_UP = nil

---ConvertPlayerUnitEvent(269)
---@type playerunitevent
EVENT_PLAYER_UNIT_SELL = nil

---ConvertPlayerUnitEvent(270)
---@type playerunitevent
EVENT_PLAYER_UNIT_CHANGE_OWNER = nil

---ConvertPlayerUnitEvent(271)
---@type playerunitevent
EVENT_PLAYER_UNIT_SELL_ITEM = nil

---ConvertPlayerUnitEvent(272)
---@type playerunitevent
EVENT_PLAYER_UNIT_SPELL_CHANNEL = nil

---ConvertPlayerUnitEvent(273)
---@type playerunitevent
EVENT_PLAYER_UNIT_SPELL_CAST = nil

---ConvertPlayerUnitEvent(274)
---@type playerunitevent
EVENT_PLAYER_UNIT_SPELL_EFFECT = nil

---ConvertPlayerUnitEvent(275)
---@type playerunitevent
EVENT_PLAYER_UNIT_SPELL_FINISH = nil

---ConvertPlayerUnitEvent(276)
---@type playerunitevent
EVENT_PLAYER_UNIT_SPELL_ENDCAST = nil

---ConvertPlayerUnitEvent(277)
---@type playerunitevent
EVENT_PLAYER_UNIT_PAWN_ITEM = nil

---ConvertPlayerUnitEvent(319)
---@type playerunitevent
EVENT_PLAYER_UNIT_STACK_ITEM = nil

---ConvertUnitEvent(286)
---@type unitevent
EVENT_UNIT_SELL = nil

---ConvertUnitEvent(287)
---@type unitevent
EVENT_UNIT_CHANGE_OWNER = nil

---ConvertUnitEvent(288)
---@type unitevent
EVENT_UNIT_SELL_ITEM = nil

---ConvertUnitEvent(289)
---@type unitevent
EVENT_UNIT_SPELL_CHANNEL = nil

---ConvertUnitEvent(290)
---@type unitevent
EVENT_UNIT_SPELL_CAST = nil

---ConvertUnitEvent(291)
---@type unitevent
EVENT_UNIT_SPELL_EFFECT = nil

---ConvertUnitEvent(292)
---@type unitevent
EVENT_UNIT_SPELL_FINISH = nil

---ConvertUnitEvent(293)
---@type unitevent
EVENT_UNIT_SPELL_ENDCAST = nil

---ConvertUnitEvent(294)
---@type unitevent
EVENT_UNIT_PAWN_ITEM = nil

---ConvertUnitEvent(318)
---@type unitevent
EVENT_UNIT_STACK_ITEM = nil

---ConvertLimitOp(0)
---@type limitop
LESS_THAN = nil

---ConvertLimitOp(1)
---@type limitop
LESS_THAN_OR_EQUAL = nil

---ConvertLimitOp(2)
---@type limitop
EQUAL = nil

---ConvertLimitOp(3)
---@type limitop
GREATER_THAN_OR_EQUAL = nil

---ConvertLimitOp(4)
---@type limitop
GREATER_THAN = nil

---ConvertLimitOp(5)
---@type limitop
NOT_EQUAL = nil

---ConvertUnitType(0)
---@type unittype
UNIT_TYPE_HERO = nil

---ConvertUnitType(1)
---@type unittype
UNIT_TYPE_DEAD = nil

---ConvertUnitType(2)
---@type unittype
UNIT_TYPE_STRUCTURE = nil

---ConvertUnitType(3)
---@type unittype
UNIT_TYPE_FLYING = nil

---ConvertUnitType(4)
---@type unittype
UNIT_TYPE_GROUND = nil

---ConvertUnitType(5)
---@type unittype
UNIT_TYPE_ATTACKS_FLYING = nil

---ConvertUnitType(6)
---@type unittype
UNIT_TYPE_ATTACKS_GROUND = nil

---ConvertUnitType(7)
---@type unittype
UNIT_TYPE_MELEE_ATTACKER = nil

---ConvertUnitType(8)
---@type unittype
UNIT_TYPE_RANGED_ATTACKER = nil

---ConvertUnitType(9)
---@type unittype
UNIT_TYPE_GIANT = nil

---ConvertUnitType(10)
---@type unittype
UNIT_TYPE_SUMMONED = nil

---ConvertUnitType(11)
---@type unittype
UNIT_TYPE_STUNNED = nil

---ConvertUnitType(12)
---@type unittype
UNIT_TYPE_PLAGUED = nil

---ConvertUnitType(13)
---@type unittype
UNIT_TYPE_SNARED = nil

---ConvertUnitType(14)
---@type unittype
UNIT_TYPE_UNDEAD = nil

---ConvertUnitType(15)
---@type unittype
UNIT_TYPE_MECHANICAL = nil

---ConvertUnitType(16)
---@type unittype
UNIT_TYPE_PEON = nil

---ConvertUnitType(17)
---@type unittype
UNIT_TYPE_SAPPER = nil

---ConvertUnitType(18)
---@type unittype
UNIT_TYPE_TOWNHALL = nil

---ConvertUnitType(19)
---@type unittype
UNIT_TYPE_ANCIENT = nil

---ConvertUnitType(20)
---@type unittype
UNIT_TYPE_TAUREN = nil

---ConvertUnitType(21)
---@type unittype
UNIT_TYPE_POISONED = nil

---ConvertUnitType(22)
---@type unittype
UNIT_TYPE_POLYMORPHED = nil

---ConvertUnitType(23)
---@type unittype
UNIT_TYPE_SLEEPING = nil

---ConvertUnitType(24)
---@type unittype
UNIT_TYPE_RESISTANT = nil

---ConvertUnitType(25)
---@type unittype
UNIT_TYPE_ETHEREAL = nil

---ConvertUnitType(26)
---@type unittype
UNIT_TYPE_MAGIC_IMMUNE = nil

---ConvertItemType(0)
---@type itemtype
ITEM_TYPE_PERMANENT = nil

---ConvertItemType(1)
---@type itemtype
ITEM_TYPE_CHARGED = nil

---ConvertItemType(2)
---@type itemtype
ITEM_TYPE_POWERUP = nil

---ConvertItemType(3)
---@type itemtype
ITEM_TYPE_ARTIFACT = nil

---ConvertItemType(4)
---@type itemtype
ITEM_TYPE_PURCHASABLE = nil

---ConvertItemType(5)
---@type itemtype
ITEM_TYPE_CAMPAIGN = nil

---ConvertItemType(6)
---@type itemtype
ITEM_TYPE_MISCELLANEOUS = nil

---ConvertItemType(7)
---@type itemtype
ITEM_TYPE_UNKNOWN = nil

---ConvertItemType(8)
---@type itemtype
ITEM_TYPE_ANY = nil

---ConvertItemType(2)
---@type itemtype
ITEM_TYPE_TOME = nil

---ConvertCameraField(0)
---@type camerafield
CAMERA_FIELD_TARGET_DISTANCE = nil

---ConvertCameraField(1)
---@type camerafield
CAMERA_FIELD_FARZ = nil

---ConvertCameraField(2)
---@type camerafield
CAMERA_FIELD_ANGLE_OF_ATTACK = nil

---ConvertCameraField(3)
---@type camerafield
CAMERA_FIELD_FIELD_OF_VIEW = nil

---ConvertCameraField(4)
---@type camerafield
CAMERA_FIELD_ROLL = nil

---ConvertCameraField(5)
---@type camerafield
CAMERA_FIELD_ROTATION = nil

---ConvertCameraField(6)
---@type camerafield
CAMERA_FIELD_ZOFFSET = nil

---ConvertCameraField(7)
---@type camerafield
CAMERA_FIELD_NEARZ = nil

---ConvertCameraField(8)
---@type camerafield
CAMERA_FIELD_LOCAL_PITCH = nil

---ConvertCameraField(9)
---@type camerafield
CAMERA_FIELD_LOCAL_YAW = nil

---ConvertCameraField(10)
---@type camerafield
CAMERA_FIELD_LOCAL_ROLL = nil

---ConvertBlendMode(0)
---@type blendmode
BLEND_MODE_NONE = nil

---ConvertBlendMode(0)
---@type blendmode
BLEND_MODE_DONT_CARE = nil

---ConvertBlendMode(1)
---@type blendmode
BLEND_MODE_KEYALPHA = nil

---ConvertBlendMode(2)
---@type blendmode
BLEND_MODE_BLEND = nil

---ConvertBlendMode(3)
---@type blendmode
BLEND_MODE_ADDITIVE = nil

---ConvertBlendMode(4)
---@type blendmode
BLEND_MODE_MODULATE = nil

---ConvertBlendMode(5)
---@type blendmode
BLEND_MODE_MODULATE_2X = nil

---ConvertRarityControl(0)
---@type raritycontrol
RARITY_FREQUENT = nil

---ConvertRarityControl(1)
---@type raritycontrol
RARITY_RARE = nil

---ConvertTexMapFlags(0)
---@type texmapflags
TEXMAP_FLAG_NONE = nil

---ConvertTexMapFlags(1)
---@type texmapflags
TEXMAP_FLAG_WRAP_U = nil

---ConvertTexMapFlags(2)
---@type texmapflags
TEXMAP_FLAG_WRAP_V = nil

---ConvertTexMapFlags(3)
---@type texmapflags
TEXMAP_FLAG_WRAP_UV = nil

---ConvertFogState(1)
---@type fogstate
FOG_OF_WAR_MASKED = nil

---ConvertFogState(2)
---@type fogstate
FOG_OF_WAR_FOGGED = nil

---ConvertFogState(4)
---@type fogstate
FOG_OF_WAR_VISIBLE = nil

---0
---@type integer
CAMERA_MARGIN_LEFT = nil

---1
---@type integer
CAMERA_MARGIN_RIGHT = nil

---2
---@type integer
CAMERA_MARGIN_TOP = nil

---3
---@type integer
CAMERA_MARGIN_BOTTOM = nil

---ConvertEffectType(0)
---@type effecttype
EFFECT_TYPE_EFFECT = nil

---ConvertEffectType(1)
---@type effecttype
EFFECT_TYPE_TARGET = nil

---ConvertEffectType(2)
---@type effecttype
EFFECT_TYPE_CASTER = nil

---ConvertEffectType(3)
---@type effecttype
EFFECT_TYPE_SPECIAL = nil

---ConvertEffectType(4)
---@type effecttype
EFFECT_TYPE_AREA_EFFECT = nil

---ConvertEffectType(5)
---@type effecttype
EFFECT_TYPE_MISSILE = nil

---ConvertEffectType(6)
---@type effecttype
EFFECT_TYPE_LIGHTNING = nil

---ConvertSoundType(0)
---@type soundtype
SOUND_TYPE_EFFECT = nil

---ConvertSoundType(1)
---@type soundtype
SOUND_TYPE_EFFECT_LOOPED = nil

---ConvertOriginFrameType(0)
---@type originframetype
ORIGIN_FRAME_GAME_UI = nil

---ConvertOriginFrameType(1)
---@type originframetype
ORIGIN_FRAME_COMMAND_BUTTON = nil

---ConvertOriginFrameType(2)
---@type originframetype
ORIGIN_FRAME_HERO_BAR = nil

---ConvertOriginFrameType(3)
---@type originframetype
ORIGIN_FRAME_HERO_BUTTON = nil

---ConvertOriginFrameType(4)
---@type originframetype
ORIGIN_FRAME_HERO_HP_BAR = nil

---ConvertOriginFrameType(5)
---@type originframetype
ORIGIN_FRAME_HERO_MANA_BAR = nil

---ConvertOriginFrameType(6)
---@type originframetype
ORIGIN_FRAME_HERO_BUTTON_INDICATOR = nil

---ConvertOriginFrameType(7)
---@type originframetype
ORIGIN_FRAME_ITEM_BUTTON = nil

---ConvertOriginFrameType(8)
---@type originframetype
ORIGIN_FRAME_MINIMAP = nil

---ConvertOriginFrameType(9)
---@type originframetype
ORIGIN_FRAME_MINIMAP_BUTTON = nil

---ConvertOriginFrameType(10)
---@type originframetype
ORIGIN_FRAME_SYSTEM_BUTTON = nil

---ConvertOriginFrameType(11)
---@type originframetype
ORIGIN_FRAME_TOOLTIP = nil

---ConvertOriginFrameType(12)
---@type originframetype
ORIGIN_FRAME_UBERTOOLTIP = nil

---ConvertOriginFrameType(13)
---@type originframetype
ORIGIN_FRAME_CHAT_MSG = nil

---ConvertOriginFrameType(14)
---@type originframetype
ORIGIN_FRAME_UNIT_MSG = nil

---ConvertOriginFrameType(15)
---@type originframetype
ORIGIN_FRAME_TOP_MSG = nil

---ConvertOriginFrameType(16)
---@type originframetype
ORIGIN_FRAME_PORTRAIT = nil

---ConvertOriginFrameType(17)
---@type originframetype
ORIGIN_FRAME_WORLD_FRAME = nil

---ConvertOriginFrameType(18)
---@type originframetype
ORIGIN_FRAME_SIMPLE_UI_PARENT = nil

---ConvertOriginFrameType(19)
---@type originframetype
ORIGIN_FRAME_PORTRAIT_HP_TEXT = nil

---ConvertOriginFrameType(20)
---@type originframetype
ORIGIN_FRAME_PORTRAIT_MANA_TEXT = nil

---ConvertOriginFrameType(21)
---@type originframetype
ORIGIN_FRAME_UNIT_PANEL_BUFF_BAR = nil

---ConvertOriginFrameType(22)
---@type originframetype
ORIGIN_FRAME_UNIT_PANEL_BUFF_BAR_LABEL = nil

---ConvertFramePointType(0)
---@type framepointtype
FRAMEPOINT_TOPLEFT = nil

---ConvertFramePointType(1)
---@type framepointtype
FRAMEPOINT_TOP = nil

---ConvertFramePointType(2)
---@type framepointtype
FRAMEPOINT_TOPRIGHT = nil

---ConvertFramePointType(3)
---@type framepointtype
FRAMEPOINT_LEFT = nil

---ConvertFramePointType(4)
---@type framepointtype
FRAMEPOINT_CENTER = nil

---ConvertFramePointType(5)
---@type framepointtype
FRAMEPOINT_RIGHT = nil

---ConvertFramePointType(6)
---@type framepointtype
FRAMEPOINT_BOTTOMLEFT = nil

---ConvertFramePointType(7)
---@type framepointtype
FRAMEPOINT_BOTTOM = nil

---ConvertFramePointType(8)
---@type framepointtype
FRAMEPOINT_BOTTOMRIGHT = nil

---ConvertTextAlignType(0)
---@type textaligntype
TEXT_JUSTIFY_TOP = nil

---ConvertTextAlignType(1)
---@type textaligntype
TEXT_JUSTIFY_MIDDLE = nil

---ConvertTextAlignType(2)
---@type textaligntype
TEXT_JUSTIFY_BOTTOM = nil

---ConvertTextAlignType(3)
---@type textaligntype
TEXT_JUSTIFY_LEFT = nil

---ConvertTextAlignType(4)
---@type textaligntype
TEXT_JUSTIFY_CENTER = nil

---ConvertTextAlignType(5)
---@type textaligntype
TEXT_JUSTIFY_RIGHT = nil

---ConvertFrameEventType(1)
---@type frameeventtype
FRAMEEVENT_CONTROL_CLICK = nil

---ConvertFrameEventType(2)
---@type frameeventtype
FRAMEEVENT_MOUSE_ENTER = nil

---ConvertFrameEventType(3)
---@type frameeventtype
FRAMEEVENT_MOUSE_LEAVE = nil

---ConvertFrameEventType(4)
---@type frameeventtype
FRAMEEVENT_MOUSE_UP = nil

---ConvertFrameEventType(5)
---@type frameeventtype
FRAMEEVENT_MOUSE_DOWN = nil

---ConvertFrameEventType(6)
---@type frameeventtype
FRAMEEVENT_MOUSE_WHEEL = nil

---ConvertFrameEventType(7)
---@type frameeventtype
FRAMEEVENT_CHECKBOX_CHECKED = nil

---ConvertFrameEventType(8)
---@type frameeventtype
FRAMEEVENT_CHECKBOX_UNCHECKED = nil

---ConvertFrameEventType(9)
---@type frameeventtype
FRAMEEVENT_EDITBOX_TEXT_CHANGED = nil

---ConvertFrameEventType(10)
---@type frameeventtype
FRAMEEVENT_POPUPMENU_ITEM_CHANGED = nil

---ConvertFrameEventType(11)
---@type frameeventtype
FRAMEEVENT_MOUSE_DOUBLECLICK = nil

---ConvertFrameEventType(12)
---@type frameeventtype
FRAMEEVENT_SPRITE_ANIM_UPDATE = nil

---ConvertFrameEventType(13)
---@type frameeventtype
FRAMEEVENT_SLIDER_VALUE_CHANGED = nil

---ConvertFrameEventType(14)
---@type frameeventtype
FRAMEEVENT_DIALOG_CANCEL = nil

---ConvertFrameEventType(15)
---@type frameeventtype
FRAMEEVENT_DIALOG_ACCEPT = nil

---ConvertFrameEventType(16)
---@type frameeventtype
FRAMEEVENT_EDITBOX_ENTER = nil

---ConvertOsKeyType($08)
---@type oskeytype
OSKEY_BACKSPACE = nil

---ConvertOsKeyType($09)
---@type oskeytype
OSKEY_TAB = nil

---ConvertOsKeyType($0C)
---@type oskeytype
OSKEY_CLEAR = nil

---ConvertOsKeyType($0D)
---@type oskeytype
OSKEY_RETURN = nil

---ConvertOsKeyType($10)
---@type oskeytype
OSKEY_SHIFT = nil

---ConvertOsKeyType($11)
---@type oskeytype
OSKEY_CONTROL = nil

---ConvertOsKeyType($12)
---@type oskeytype
OSKEY_ALT = nil

---ConvertOsKeyType($13)
---@type oskeytype
OSKEY_PAUSE = nil

---ConvertOsKeyType($14)
---@type oskeytype
OSKEY_CAPSLOCK = nil

---ConvertOsKeyType($15)
---@type oskeytype
OSKEY_KANA = nil

---ConvertOsKeyType($15)
---@type oskeytype
OSKEY_HANGUL = nil

---ConvertOsKeyType($17)
---@type oskeytype
OSKEY_JUNJA = nil

---ConvertOsKeyType($18)
---@type oskeytype
OSKEY_FINAL = nil

---ConvertOsKeyType($19)
---@type oskeytype
OSKEY_HANJA = nil

---ConvertOsKeyType($19)
---@type oskeytype
OSKEY_KANJI = nil

---ConvertOsKeyType($1B)
---@type oskeytype
OSKEY_ESCAPE = nil

---ConvertOsKeyType($1C)
---@type oskeytype
OSKEY_CONVERT = nil

---ConvertOsKeyType($1D)
---@type oskeytype
OSKEY_NONCONVERT = nil

---ConvertOsKeyType($1E)
---@type oskeytype
OSKEY_ACCEPT = nil

---ConvertOsKeyType($1F)
---@type oskeytype
OSKEY_MODECHANGE = nil

---ConvertOsKeyType($20)
---@type oskeytype
OSKEY_SPACE = nil

---ConvertOsKeyType($21)
---@type oskeytype
OSKEY_PAGEUP = nil

---ConvertOsKeyType($22)
---@type oskeytype
OSKEY_PAGEDOWN = nil

---ConvertOsKeyType($23)
---@type oskeytype
OSKEY_END = nil

---ConvertOsKeyType($24)
---@type oskeytype
OSKEY_HOME = nil

---ConvertOsKeyType($25)
---@type oskeytype
OSKEY_LEFT = nil

---ConvertOsKeyType($26)
---@type oskeytype
OSKEY_UP = nil

---ConvertOsKeyType($27)
---@type oskeytype
OSKEY_RIGHT = nil

---ConvertOsKeyType($28)
---@type oskeytype
OSKEY_DOWN = nil

---ConvertOsKeyType($29)
---@type oskeytype
OSKEY_SELECT = nil

---ConvertOsKeyType($2A)
---@type oskeytype
OSKEY_PRINT = nil

---ConvertOsKeyType($2B)
---@type oskeytype
OSKEY_EXECUTE = nil

---ConvertOsKeyType($2C)
---@type oskeytype
OSKEY_PRINTSCREEN = nil

---ConvertOsKeyType($2D)
---@type oskeytype
OSKEY_INSERT = nil

---ConvertOsKeyType($2E)
---@type oskeytype
OSKEY_DELETE = nil

---ConvertOsKeyType($2F)
---@type oskeytype
OSKEY_HELP = nil

---ConvertOsKeyType($30)
---@type oskeytype
OSKEY_0 = nil

---ConvertOsKeyType($31)
---@type oskeytype
OSKEY_1 = nil

---ConvertOsKeyType($32)
---@type oskeytype
OSKEY_2 = nil

---ConvertOsKeyType($33)
---@type oskeytype
OSKEY_3 = nil

---ConvertOsKeyType($34)
---@type oskeytype
OSKEY_4 = nil

---ConvertOsKeyType($35)
---@type oskeytype
OSKEY_5 = nil

---ConvertOsKeyType($36)
---@type oskeytype
OSKEY_6 = nil

---ConvertOsKeyType($37)
---@type oskeytype
OSKEY_7 = nil

---ConvertOsKeyType($38)
---@type oskeytype
OSKEY_8 = nil

---ConvertOsKeyType($39)
---@type oskeytype
OSKEY_9 = nil

---ConvertOsKeyType($41)
---@type oskeytype
OSKEY_A = nil

---ConvertOsKeyType($42)
---@type oskeytype
OSKEY_B = nil

---ConvertOsKeyType($43)
---@type oskeytype
OSKEY_C = nil

---ConvertOsKeyType($44)
---@type oskeytype
OSKEY_D = nil

---ConvertOsKeyType($45)
---@type oskeytype
OSKEY_E = nil

---ConvertOsKeyType($46)
---@type oskeytype
OSKEY_F = nil

---ConvertOsKeyType($47)
---@type oskeytype
OSKEY_G = nil

---ConvertOsKeyType($48)
---@type oskeytype
OSKEY_H = nil

---ConvertOsKeyType($49)
---@type oskeytype
OSKEY_I = nil

---ConvertOsKeyType($4A)
---@type oskeytype
OSKEY_J = nil

---ConvertOsKeyType($4B)
---@type oskeytype
OSKEY_K = nil

---ConvertOsKeyType($4C)
---@type oskeytype
OSKEY_L = nil

---ConvertOsKeyType($4D)
---@type oskeytype
OSKEY_M = nil

---ConvertOsKeyType($4E)
---@type oskeytype
OSKEY_N = nil

---ConvertOsKeyType($4F)
---@type oskeytype
OSKEY_O = nil

---ConvertOsKeyType($50)
---@type oskeytype
OSKEY_P = nil

---ConvertOsKeyType($51)
---@type oskeytype
OSKEY_Q = nil

---ConvertOsKeyType($52)
---@type oskeytype
OSKEY_R = nil

---ConvertOsKeyType($53)
---@type oskeytype
OSKEY_S = nil

---ConvertOsKeyType($54)
---@type oskeytype
OSKEY_T = nil

---ConvertOsKeyType($55)
---@type oskeytype
OSKEY_U = nil

---ConvertOsKeyType($56)
---@type oskeytype
OSKEY_V = nil

---ConvertOsKeyType($57)
---@type oskeytype
OSKEY_W = nil

---ConvertOsKeyType($58)
---@type oskeytype
OSKEY_X = nil

---ConvertOsKeyType($59)
---@type oskeytype
OSKEY_Y = nil

---ConvertOsKeyType($5A)
---@type oskeytype
OSKEY_Z = nil

---ConvertOsKeyType($5B)
---@type oskeytype
OSKEY_LMETA = nil

---ConvertOsKeyType($5C)
---@type oskeytype
OSKEY_RMETA = nil

---ConvertOsKeyType($5D)
---@type oskeytype
OSKEY_APPS = nil

---ConvertOsKeyType($5F)
---@type oskeytype
OSKEY_SLEEP = nil

---ConvertOsKeyType($60)
---@type oskeytype
OSKEY_NUMPAD0 = nil

---ConvertOsKeyType($61)
---@type oskeytype
OSKEY_NUMPAD1 = nil

---ConvertOsKeyType($62)
---@type oskeytype
OSKEY_NUMPAD2 = nil

---ConvertOsKeyType($63)
---@type oskeytype
OSKEY_NUMPAD3 = nil

---ConvertOsKeyType($64)
---@type oskeytype
OSKEY_NUMPAD4 = nil

---ConvertOsKeyType($65)
---@type oskeytype
OSKEY_NUMPAD5 = nil

---ConvertOsKeyType($66)
---@type oskeytype
OSKEY_NUMPAD6 = nil

---ConvertOsKeyType($67)
---@type oskeytype
OSKEY_NUMPAD7 = nil

---ConvertOsKeyType($68)
---@type oskeytype
OSKEY_NUMPAD8 = nil

---ConvertOsKeyType($69)
---@type oskeytype
OSKEY_NUMPAD9 = nil

---ConvertOsKeyType($6A)
---@type oskeytype
OSKEY_MULTIPLY = nil

---ConvertOsKeyType($6B)
---@type oskeytype
OSKEY_ADD = nil

---ConvertOsKeyType($6C)
---@type oskeytype
OSKEY_SEPARATOR = nil

---ConvertOsKeyType($6D)
---@type oskeytype
OSKEY_SUBTRACT = nil

---ConvertOsKeyType($6E)
---@type oskeytype
OSKEY_DECIMAL = nil

---ConvertOsKeyType($6F)
---@type oskeytype
OSKEY_DIVIDE = nil

---ConvertOsKeyType($70)
---@type oskeytype
OSKEY_F1 = nil

---ConvertOsKeyType($71)
---@type oskeytype
OSKEY_F2 = nil

---ConvertOsKeyType($72)
---@type oskeytype
OSKEY_F3 = nil

---ConvertOsKeyType($73)
---@type oskeytype
OSKEY_F4 = nil

---ConvertOsKeyType($74)
---@type oskeytype
OSKEY_F5 = nil

---ConvertOsKeyType($75)
---@type oskeytype
OSKEY_F6 = nil

---ConvertOsKeyType($76)
---@type oskeytype
OSKEY_F7 = nil

---ConvertOsKeyType($77)
---@type oskeytype
OSKEY_F8 = nil

---ConvertOsKeyType($78)
---@type oskeytype
OSKEY_F9 = nil

---ConvertOsKeyType($79)
---@type oskeytype
OSKEY_F10 = nil

---ConvertOsKeyType($7A)
---@type oskeytype
OSKEY_F11 = nil

---ConvertOsKeyType($7B)
---@type oskeytype
OSKEY_F12 = nil

---ConvertOsKeyType($7C)
---@type oskeytype
OSKEY_F13 = nil

---ConvertOsKeyType($7D)
---@type oskeytype
OSKEY_F14 = nil

---ConvertOsKeyType($7E)
---@type oskeytype
OSKEY_F15 = nil

---ConvertOsKeyType($7F)
---@type oskeytype
OSKEY_F16 = nil

---ConvertOsKeyType($80)
---@type oskeytype
OSKEY_F17 = nil

---ConvertOsKeyType($81)
---@type oskeytype
OSKEY_F18 = nil

---ConvertOsKeyType($82)
---@type oskeytype
OSKEY_F19 = nil

---ConvertOsKeyType($83)
---@type oskeytype
OSKEY_F20 = nil

---ConvertOsKeyType($84)
---@type oskeytype
OSKEY_F21 = nil

---ConvertOsKeyType($85)
---@type oskeytype
OSKEY_F22 = nil

---ConvertOsKeyType($86)
---@type oskeytype
OSKEY_F23 = nil

---ConvertOsKeyType($87)
---@type oskeytype
OSKEY_F24 = nil

---ConvertOsKeyType($90)
---@type oskeytype
OSKEY_NUMLOCK = nil

---ConvertOsKeyType($91)
---@type oskeytype
OSKEY_SCROLLLOCK = nil

---ConvertOsKeyType($92)
---@type oskeytype
OSKEY_OEM_NEC_EQUAL = nil

---ConvertOsKeyType($92)
---@type oskeytype
OSKEY_OEM_FJ_JISHO = nil

---ConvertOsKeyType($93)
---@type oskeytype
OSKEY_OEM_FJ_MASSHOU = nil

---ConvertOsKeyType($94)
---@type oskeytype
OSKEY_OEM_FJ_TOUROKU = nil

---ConvertOsKeyType($95)
---@type oskeytype
OSKEY_OEM_FJ_LOYA = nil

---ConvertOsKeyType($96)
---@type oskeytype
OSKEY_OEM_FJ_ROYA = nil

---ConvertOsKeyType($A0)
---@type oskeytype
OSKEY_LSHIFT = nil

---ConvertOsKeyType($A1)
---@type oskeytype
OSKEY_RSHIFT = nil

---ConvertOsKeyType($A2)
---@type oskeytype
OSKEY_LCONTROL = nil

---ConvertOsKeyType($A3)
---@type oskeytype
OSKEY_RCONTROL = nil

---ConvertOsKeyType($A4)
---@type oskeytype
OSKEY_LALT = nil

---ConvertOsKeyType($A5)
---@type oskeytype
OSKEY_RALT = nil

---ConvertOsKeyType($A6)
---@type oskeytype
OSKEY_BROWSER_BACK = nil

---ConvertOsKeyType($A7)
---@type oskeytype
OSKEY_BROWSER_FORWARD = nil

---ConvertOsKeyType($A8)
---@type oskeytype
OSKEY_BROWSER_REFRESH = nil

---ConvertOsKeyType($A9)
---@type oskeytype
OSKEY_BROWSER_STOP = nil

---ConvertOsKeyType($AA)
---@type oskeytype
OSKEY_BROWSER_SEARCH = nil

---ConvertOsKeyType($AB)
---@type oskeytype
OSKEY_BROWSER_FAVORITES = nil

---ConvertOsKeyType($AC)
---@type oskeytype
OSKEY_BROWSER_HOME = nil

---ConvertOsKeyType($AD)
---@type oskeytype
OSKEY_VOLUME_MUTE = nil

---ConvertOsKeyType($AE)
---@type oskeytype
OSKEY_VOLUME_DOWN = nil

---ConvertOsKeyType($AF)
---@type oskeytype
OSKEY_VOLUME_UP = nil

---ConvertOsKeyType($B0)
---@type oskeytype
OSKEY_MEDIA_NEXT_TRACK = nil

---ConvertOsKeyType($B1)
---@type oskeytype
OSKEY_MEDIA_PREV_TRACK = nil

---ConvertOsKeyType($B2)
---@type oskeytype
OSKEY_MEDIA_STOP = nil

---ConvertOsKeyType($B3)
---@type oskeytype
OSKEY_MEDIA_PLAY_PAUSE = nil

---ConvertOsKeyType($B4)
---@type oskeytype
OSKEY_LAUNCH_MAIL = nil

---ConvertOsKeyType($B5)
---@type oskeytype
OSKEY_LAUNCH_MEDIA_SELECT = nil

---ConvertOsKeyType($B6)
---@type oskeytype
OSKEY_LAUNCH_APP1 = nil

---ConvertOsKeyType($B7)
---@type oskeytype
OSKEY_LAUNCH_APP2 = nil

---ConvertOsKeyType($BA)
---@type oskeytype
OSKEY_OEM_1 = nil

---ConvertOsKeyType($BB)
---@type oskeytype
OSKEY_OEM_PLUS = nil

---ConvertOsKeyType($BC)
---@type oskeytype
OSKEY_OEM_COMMA = nil

---ConvertOsKeyType($BD)
---@type oskeytype
OSKEY_OEM_MINUS = nil

---ConvertOsKeyType($BE)
---@type oskeytype
OSKEY_OEM_PERIOD = nil

---ConvertOsKeyType($BF)
---@type oskeytype
OSKEY_OEM_2 = nil

---ConvertOsKeyType($C0)
---@type oskeytype
OSKEY_OEM_3 = nil

---ConvertOsKeyType($DB)
---@type oskeytype
OSKEY_OEM_4 = nil

---ConvertOsKeyType($DC)
---@type oskeytype
OSKEY_OEM_5 = nil

---ConvertOsKeyType($DD)
---@type oskeytype
OSKEY_OEM_6 = nil

---ConvertOsKeyType($DE)
---@type oskeytype
OSKEY_OEM_7 = nil

---ConvertOsKeyType($DF)
---@type oskeytype
OSKEY_OEM_8 = nil

---ConvertOsKeyType($E1)
---@type oskeytype
OSKEY_OEM_AX = nil

---ConvertOsKeyType($E2)
---@type oskeytype
OSKEY_OEM_102 = nil

---ConvertOsKeyType($E3)
---@type oskeytype
OSKEY_ICO_HELP = nil

---ConvertOsKeyType($E4)
---@type oskeytype
OSKEY_ICO_00 = nil

---ConvertOsKeyType($E5)
---@type oskeytype
OSKEY_PROCESSKEY = nil

---ConvertOsKeyType($E6)
---@type oskeytype
OSKEY_ICO_CLEAR = nil

---ConvertOsKeyType($E7)
---@type oskeytype
OSKEY_PACKET = nil

---ConvertOsKeyType($E9)
---@type oskeytype
OSKEY_OEM_RESET = nil

---ConvertOsKeyType($EA)
---@type oskeytype
OSKEY_OEM_JUMP = nil

---ConvertOsKeyType($EB)
---@type oskeytype
OSKEY_OEM_PA1 = nil

---ConvertOsKeyType($EC)
---@type oskeytype
OSKEY_OEM_PA2 = nil

---ConvertOsKeyType($ED)
---@type oskeytype
OSKEY_OEM_PA3 = nil

---ConvertOsKeyType($EE)
---@type oskeytype
OSKEY_OEM_WSCTRL = nil

---ConvertOsKeyType($EF)
---@type oskeytype
OSKEY_OEM_CUSEL = nil

---ConvertOsKeyType($F0)
---@type oskeytype
OSKEY_OEM_ATTN = nil

---ConvertOsKeyType($F1)
---@type oskeytype
OSKEY_OEM_FINISH = nil

---ConvertOsKeyType($F2)
---@type oskeytype
OSKEY_OEM_COPY = nil

---ConvertOsKeyType($F3)
---@type oskeytype
OSKEY_OEM_AUTO = nil

---ConvertOsKeyType($F4)
---@type oskeytype
OSKEY_OEM_ENLW = nil

---ConvertOsKeyType($F5)
---@type oskeytype
OSKEY_OEM_BACKTAB = nil

---ConvertOsKeyType($F6)
---@type oskeytype
OSKEY_ATTN = nil

---ConvertOsKeyType($F7)
---@type oskeytype
OSKEY_CRSEL = nil

---ConvertOsKeyType($F8)
---@type oskeytype
OSKEY_EXSEL = nil

---ConvertOsKeyType($F9)
---@type oskeytype
OSKEY_EREOF = nil

---ConvertOsKeyType($FA)
---@type oskeytype
OSKEY_PLAY = nil

---ConvertOsKeyType($FB)
---@type oskeytype
OSKEY_ZOOM = nil

---ConvertOsKeyType($FC)
---@type oskeytype
OSKEY_NONAME = nil

---ConvertOsKeyType($FD)
---@type oskeytype
OSKEY_PA1 = nil

---ConvertOsKeyType($FE)
---@type oskeytype
OSKEY_OEM_CLEAR = nil

---ConvertAbilityIntegerField('abpx')
---@type abilityintegerfield
ABILITY_IF_BUTTON_POSITION_NORMAL_X = nil

---ConvertAbilityIntegerField('abpy')
---@type abilityintegerfield
ABILITY_IF_BUTTON_POSITION_NORMAL_Y = nil

---ConvertAbilityIntegerField('aubx')
---@type abilityintegerfield
ABILITY_IF_BUTTON_POSITION_ACTIVATED_X = nil

---ConvertAbilityIntegerField('auby')
---@type abilityintegerfield
ABILITY_IF_BUTTON_POSITION_ACTIVATED_Y = nil

---ConvertAbilityIntegerField('arpx')
---@type abilityintegerfield
ABILITY_IF_BUTTON_POSITION_RESEARCH_X = nil

---ConvertAbilityIntegerField('arpy')
---@type abilityintegerfield
ABILITY_IF_BUTTON_POSITION_RESEARCH_Y = nil

---ConvertAbilityIntegerField('amsp')
---@type abilityintegerfield
ABILITY_IF_MISSILE_SPEED = nil

---ConvertAbilityIntegerField('atac')
---@type abilityintegerfield
ABILITY_IF_TARGET_ATTACHMENTS = nil

---ConvertAbilityIntegerField('acac')
---@type abilityintegerfield
ABILITY_IF_CASTER_ATTACHMENTS = nil

---ConvertAbilityIntegerField('apri')
---@type abilityintegerfield
ABILITY_IF_PRIORITY = nil

---ConvertAbilityIntegerField('alev')
---@type abilityintegerfield
ABILITY_IF_LEVELS = nil

---ConvertAbilityIntegerField('arlv')
---@type abilityintegerfield
ABILITY_IF_REQUIRED_LEVEL = nil

---ConvertAbilityIntegerField('alsk')
---@type abilityintegerfield
ABILITY_IF_LEVEL_SKIP_REQUIREMENT = nil

---ConvertAbilityBooleanField('aher') // Get only
---@type abilitybooleanfield
ABILITY_BF_HERO_ABILITY = nil

---ConvertAbilityBooleanField('aite')
---@type abilitybooleanfield
ABILITY_BF_ITEM_ABILITY = nil

---ConvertAbilityBooleanField('achd')
---@type abilitybooleanfield
ABILITY_BF_CHECK_DEPENDENCIES = nil

---ConvertAbilityRealField('amac')
---@type abilityrealfield
ABILITY_RF_ARF_MISSILE_ARC = nil

---ConvertAbilityStringField('anam') // Get Only
---@type abilitystringfield
ABILITY_SF_NAME = nil

---ConvertAbilityStringField('auar')
---@type abilitystringfield
ABILITY_SF_ICON_ACTIVATED = nil

---ConvertAbilityStringField('arar')
---@type abilitystringfield
ABILITY_SF_ICON_RESEARCH = nil

---ConvertAbilityStringField('aefs')
---@type abilitystringfield
ABILITY_SF_EFFECT_SOUND = nil

---ConvertAbilityStringField('aefl')
---@type abilitystringfield
ABILITY_SF_EFFECT_SOUND_LOOPING = nil

---ConvertAbilityIntegerLevelField('amcs')
---@type abilityintegerlevelfield
ABILITY_ILF_MANA_COST = nil

---ConvertAbilityIntegerLevelField('Hbz1')
---@type abilityintegerlevelfield
ABILITY_ILF_NUMBER_OF_WAVES = nil

---ConvertAbilityIntegerLevelField('Hbz3')
---@type abilityintegerlevelfield
ABILITY_ILF_NUMBER_OF_SHARDS = nil

---ConvertAbilityIntegerLevelField('Hmt1')
---@type abilityintegerlevelfield
ABILITY_ILF_NUMBER_OF_UNITS_TELEPORTED = nil

---ConvertAbilityIntegerLevelField('Hwe2')
---@type abilityintegerlevelfield
ABILITY_ILF_SUMMONED_UNIT_COUNT_HWE2 = nil

---ConvertAbilityIntegerLevelField('Omi1')
---@type abilityintegerlevelfield
ABILITY_ILF_NUMBER_OF_IMAGES = nil

---ConvertAbilityIntegerLevelField('Uan1')
---@type abilityintegerlevelfield
ABILITY_ILF_NUMBER_OF_CORPSES_RAISED_UAN1 = nil

---ConvertAbilityIntegerLevelField('Eme2')
---@type abilityintegerlevelfield
ABILITY_ILF_MORPHING_FLAGS = nil

---ConvertAbilityIntegerLevelField('Nrg5')
---@type abilityintegerlevelfield
ABILITY_ILF_STRENGTH_BONUS_NRG5 = nil

---ConvertAbilityIntegerLevelField('Nrg6')
---@type abilityintegerlevelfield
ABILITY_ILF_DEFENSE_BONUS_NRG6 = nil

---ConvertAbilityIntegerLevelField('Ocl2')
---@type abilityintegerlevelfield
ABILITY_ILF_NUMBER_OF_TARGETS_HIT = nil

---ConvertAbilityIntegerLevelField('Ofs1')
---@type abilityintegerlevelfield
ABILITY_ILF_DETECTION_TYPE_OFS1 = nil

---ConvertAbilityIntegerLevelField('Osf2')
---@type abilityintegerlevelfield
ABILITY_ILF_NUMBER_OF_SUMMONED_UNITS_OSF2 = nil

---ConvertAbilityIntegerLevelField('Efn1')
---@type abilityintegerlevelfield
ABILITY_ILF_NUMBER_OF_SUMMONED_UNITS_EFN1 = nil

---ConvertAbilityIntegerLevelField('Hre1')
---@type abilityintegerlevelfield
ABILITY_ILF_NUMBER_OF_CORPSES_RAISED_HRE1 = nil

---ConvertAbilityIntegerLevelField('Hca4')
---@type abilityintegerlevelfield
ABILITY_ILF_STACK_FLAGS = nil

---ConvertAbilityIntegerLevelField('Ndp2')
---@type abilityintegerlevelfield
ABILITY_ILF_MINIMUM_NUMBER_OF_UNITS = nil

---ConvertAbilityIntegerLevelField('Ndp3')
---@type abilityintegerlevelfield
ABILITY_ILF_MAXIMUM_NUMBER_OF_UNITS_NDP3 = nil

---ConvertAbilityIntegerLevelField('Nrc2')
---@type abilityintegerlevelfield
ABILITY_ILF_NUMBER_OF_UNITS_CREATED_NRC2 = nil

---ConvertAbilityIntegerLevelField('Ams3')
---@type abilityintegerlevelfield
ABILITY_ILF_SHIELD_LIFE = nil

---ConvertAbilityIntegerLevelField('Ams4')
---@type abilityintegerlevelfield
ABILITY_ILF_MANA_LOSS_AMS4 = nil

---ConvertAbilityIntegerLevelField('Bgm1')
---@type abilityintegerlevelfield
ABILITY_ILF_GOLD_PER_INTERVAL_BGM1 = nil

---ConvertAbilityIntegerLevelField('Bgm3')
---@type abilityintegerlevelfield
ABILITY_ILF_MAX_NUMBER_OF_MINERS = nil

---ConvertAbilityIntegerLevelField('Car1')
---@type abilityintegerlevelfield
ABILITY_ILF_CARGO_CAPACITY = nil

---ConvertAbilityIntegerLevelField('Dev3')
---@type abilityintegerlevelfield
ABILITY_ILF_MAXIMUM_CREEP_LEVEL_DEV3 = nil

---ConvertAbilityIntegerLevelField('Dev1')
---@type abilityintegerlevelfield
ABILITY_ILF_MAX_CREEP_LEVEL_DEV1 = nil

---ConvertAbilityIntegerLevelField('Egm1')
---@type abilityintegerlevelfield
ABILITY_ILF_GOLD_PER_INTERVAL_EGM1 = nil

---ConvertAbilityIntegerLevelField('Fae1')
---@type abilityintegerlevelfield
ABILITY_ILF_DEFENSE_REDUCTION = nil

---ConvertAbilityIntegerLevelField('Fla1')
---@type abilityintegerlevelfield
ABILITY_ILF_DETECTION_TYPE_FLA1 = nil

---ConvertAbilityIntegerLevelField('Fla3')
---@type abilityintegerlevelfield
ABILITY_ILF_FLARE_COUNT = nil

---ConvertAbilityIntegerLevelField('Gld1')
---@type abilityintegerlevelfield
ABILITY_ILF_MAX_GOLD = nil

---ConvertAbilityIntegerLevelField('Gld3')
---@type abilityintegerlevelfield
ABILITY_ILF_MINING_CAPACITY = nil

---ConvertAbilityIntegerLevelField('Gyd1')
---@type abilityintegerlevelfield
ABILITY_ILF_MAXIMUM_NUMBER_OF_CORPSES_GYD1 = nil

---ConvertAbilityIntegerLevelField('Har1')
---@type abilityintegerlevelfield
ABILITY_ILF_DAMAGE_TO_TREE = nil

---ConvertAbilityIntegerLevelField('Har2')
---@type abilityintegerlevelfield
ABILITY_ILF_LUMBER_CAPACITY = nil

---ConvertAbilityIntegerLevelField('Har3')
---@type abilityintegerlevelfield
ABILITY_ILF_GOLD_CAPACITY = nil

---ConvertAbilityIntegerLevelField('Inf2')
---@type abilityintegerlevelfield
ABILITY_ILF_DEFENSE_INCREASE_INF2 = nil

---ConvertAbilityIntegerLevelField('Neu2')
---@type abilityintegerlevelfield
ABILITY_ILF_INTERACTION_TYPE = nil

---ConvertAbilityIntegerLevelField('Ndt1')
---@type abilityintegerlevelfield
ABILITY_ILF_GOLD_COST_NDT1 = nil

---ConvertAbilityIntegerLevelField('Ndt2')
---@type abilityintegerlevelfield
ABILITY_ILF_LUMBER_COST_NDT2 = nil

---ConvertAbilityIntegerLevelField('Ndt3')
---@type abilityintegerlevelfield
ABILITY_ILF_DETECTION_TYPE_NDT3 = nil

---ConvertAbilityIntegerLevelField('Poi4')
---@type abilityintegerlevelfield
ABILITY_ILF_STACKING_TYPE_POI4 = nil

---ConvertAbilityIntegerLevelField('Poa5')
---@type abilityintegerlevelfield
ABILITY_ILF_STACKING_TYPE_POA5 = nil

---ConvertAbilityIntegerLevelField('Ply1')
---@type abilityintegerlevelfield
ABILITY_ILF_MAXIMUM_CREEP_LEVEL_PLY1 = nil

---ConvertAbilityIntegerLevelField('Pos1')
---@type abilityintegerlevelfield
ABILITY_ILF_MAXIMUM_CREEP_LEVEL_POS1 = nil

---ConvertAbilityIntegerLevelField('Prg1')
---@type abilityintegerlevelfield
ABILITY_ILF_MOVEMENT_UPDATE_FREQUENCY_PRG1 = nil

---ConvertAbilityIntegerLevelField('Prg2')
---@type abilityintegerlevelfield
ABILITY_ILF_ATTACK_UPDATE_FREQUENCY_PRG2 = nil

---ConvertAbilityIntegerLevelField('Prg6')
---@type abilityintegerlevelfield
ABILITY_ILF_MANA_LOSS_PRG6 = nil

---ConvertAbilityIntegerLevelField('Rai1')
---@type abilityintegerlevelfield
ABILITY_ILF_UNITS_SUMMONED_TYPE_ONE = nil

---ConvertAbilityIntegerLevelField('Rai2')
---@type abilityintegerlevelfield
ABILITY_ILF_UNITS_SUMMONED_TYPE_TWO = nil

---ConvertAbilityIntegerLevelField('Ucb5')
---@type abilityintegerlevelfield
ABILITY_ILF_MAX_UNITS_SUMMONED = nil

---ConvertAbilityIntegerLevelField('Rej3')
---@type abilityintegerlevelfield
ABILITY_ILF_ALLOW_WHEN_FULL_REJ3 = nil

---ConvertAbilityIntegerLevelField('Rpb5')
---@type abilityintegerlevelfield
ABILITY_ILF_MAXIMUM_UNITS_CHARGED_TO_CASTER = nil

---ConvertAbilityIntegerLevelField('Rpb6')
---@type abilityintegerlevelfield
ABILITY_ILF_MAXIMUM_UNITS_AFFECTED = nil

---ConvertAbilityIntegerLevelField('Roa2')
---@type abilityintegerlevelfield
ABILITY_ILF_DEFENSE_INCREASE_ROA2 = nil

---ConvertAbilityIntegerLevelField('Roa7')
---@type abilityintegerlevelfield
ABILITY_ILF_MAX_UNITS_ROA7 = nil

---ConvertAbilityIntegerLevelField('Roo1')
---@type abilityintegerlevelfield
ABILITY_ILF_ROOTED_WEAPONS = nil

---ConvertAbilityIntegerLevelField('Roo2')
---@type abilityintegerlevelfield
ABILITY_ILF_UPROOTED_WEAPONS = nil

---ConvertAbilityIntegerLevelField('Roo4')
---@type abilityintegerlevelfield
ABILITY_ILF_UPROOTED_DEFENSE_TYPE = nil

---ConvertAbilityIntegerLevelField('Sal2')
---@type abilityintegerlevelfield
ABILITY_ILF_ACCUMULATION_STEP = nil

---ConvertAbilityIntegerLevelField('Esn4')
---@type abilityintegerlevelfield
ABILITY_ILF_NUMBER_OF_OWLS = nil

---ConvertAbilityIntegerLevelField('Spo4')
---@type abilityintegerlevelfield
ABILITY_ILF_STACKING_TYPE_SPO4 = nil

---ConvertAbilityIntegerLevelField('Sod1')
---@type abilityintegerlevelfield
ABILITY_ILF_NUMBER_OF_UNITS = nil

---ConvertAbilityIntegerLevelField('Spa1')
---@type abilityintegerlevelfield
ABILITY_ILF_SPIDER_CAPACITY = nil

---ConvertAbilityIntegerLevelField('Wha2')
---@type abilityintegerlevelfield
ABILITY_ILF_INTERVALS_BEFORE_CHANGING_TREES = nil

---ConvertAbilityIntegerLevelField('Iagi')
---@type abilityintegerlevelfield
ABILITY_ILF_AGILITY_BONUS = nil

---ConvertAbilityIntegerLevelField('Iint')
---@type abilityintegerlevelfield
ABILITY_ILF_INTELLIGENCE_BONUS = nil

---ConvertAbilityIntegerLevelField('Istr')
---@type abilityintegerlevelfield
ABILITY_ILF_STRENGTH_BONUS_ISTR = nil

---ConvertAbilityIntegerLevelField('Iatt')
---@type abilityintegerlevelfield
ABILITY_ILF_ATTACK_BONUS = nil

---ConvertAbilityIntegerLevelField('Idef')
---@type abilityintegerlevelfield
ABILITY_ILF_DEFENSE_BONUS_IDEF = nil

---ConvertAbilityIntegerLevelField('Isn1')
---@type abilityintegerlevelfield
ABILITY_ILF_SUMMON_1_AMOUNT = nil

---ConvertAbilityIntegerLevelField('Isn2')
---@type abilityintegerlevelfield
ABILITY_ILF_SUMMON_2_AMOUNT = nil

---ConvertAbilityIntegerLevelField('Ixpg')
---@type abilityintegerlevelfield
ABILITY_ILF_EXPERIENCE_GAINED = nil

---ConvertAbilityIntegerLevelField('Ihpg')
---@type abilityintegerlevelfield
ABILITY_ILF_HIT_POINTS_GAINED_IHPG = nil

---ConvertAbilityIntegerLevelField('Impg')
---@type abilityintegerlevelfield
ABILITY_ILF_MANA_POINTS_GAINED_IMPG = nil

---ConvertAbilityIntegerLevelField('Ihp2')
---@type abilityintegerlevelfield
ABILITY_ILF_HIT_POINTS_GAINED_IHP2 = nil

---ConvertAbilityIntegerLevelField('Imp2')
---@type abilityintegerlevelfield
ABILITY_ILF_MANA_POINTS_GAINED_IMP2 = nil

---ConvertAbilityIntegerLevelField('Idic')
---@type abilityintegerlevelfield
ABILITY_ILF_DAMAGE_BONUS_DICE = nil

---ConvertAbilityIntegerLevelField('Iarp')
---@type abilityintegerlevelfield
ABILITY_ILF_ARMOR_PENALTY_IARP = nil

---ConvertAbilityIntegerLevelField('Iob5')
---@type abilityintegerlevelfield
ABILITY_ILF_ENABLED_ATTACK_INDEX_IOB5 = nil

---ConvertAbilityIntegerLevelField('Ilev')
---@type abilityintegerlevelfield
ABILITY_ILF_LEVELS_GAINED = nil

---ConvertAbilityIntegerLevelField('Ilif')
---@type abilityintegerlevelfield
ABILITY_ILF_MAX_LIFE_GAINED = nil

---ConvertAbilityIntegerLevelField('Iman')
---@type abilityintegerlevelfield
ABILITY_ILF_MAX_MANA_GAINED = nil

---ConvertAbilityIntegerLevelField('Igol')
---@type abilityintegerlevelfield
ABILITY_ILF_GOLD_GIVEN = nil

---ConvertAbilityIntegerLevelField('Ilum')
---@type abilityintegerlevelfield
ABILITY_ILF_LUMBER_GIVEN = nil

---ConvertAbilityIntegerLevelField('Ifa1')
---@type abilityintegerlevelfield
ABILITY_ILF_DETECTION_TYPE_IFA1 = nil

---ConvertAbilityIntegerLevelField('Icre')
---@type abilityintegerlevelfield
ABILITY_ILF_MAXIMUM_CREEP_LEVEL_ICRE = nil

---ConvertAbilityIntegerLevelField('Imvb')
---@type abilityintegerlevelfield
ABILITY_ILF_MOVEMENT_SPEED_BONUS = nil

---ConvertAbilityIntegerLevelField('Ihpr')
---@type abilityintegerlevelfield
ABILITY_ILF_HIT_POINTS_REGENERATED_PER_SECOND = nil

---ConvertAbilityIntegerLevelField('Isib')
---@type abilityintegerlevelfield
ABILITY_ILF_SIGHT_RANGE_BONUS = nil

---ConvertAbilityIntegerLevelField('Icfd')
---@type abilityintegerlevelfield
ABILITY_ILF_DAMAGE_PER_DURATION = nil

---ConvertAbilityIntegerLevelField('Icfm')
---@type abilityintegerlevelfield
ABILITY_ILF_MANA_USED_PER_SECOND = nil

---ConvertAbilityIntegerLevelField('Icfx')
---@type abilityintegerlevelfield
ABILITY_ILF_EXTRA_MANA_REQUIRED = nil

---ConvertAbilityIntegerLevelField('Idet')
---@type abilityintegerlevelfield
ABILITY_ILF_DETECTION_RADIUS_IDET = nil

---ConvertAbilityIntegerLevelField('Idim')
---@type abilityintegerlevelfield
ABILITY_ILF_MANA_LOSS_PER_UNIT_IDIM = nil

---ConvertAbilityIntegerLevelField('Idid')
---@type abilityintegerlevelfield
ABILITY_ILF_DAMAGE_TO_SUMMONED_UNITS_IDID = nil

---ConvertAbilityIntegerLevelField('Irec')
---@type abilityintegerlevelfield
ABILITY_ILF_MAXIMUM_NUMBER_OF_UNITS_IREC = nil

---ConvertAbilityIntegerLevelField('Ircd')
---@type abilityintegerlevelfield
ABILITY_ILF_DELAY_AFTER_DEATH_SECONDS = nil

---ConvertAbilityIntegerLevelField('irc2')
---@type abilityintegerlevelfield
ABILITY_ILF_RESTORED_LIFE = nil

---ConvertAbilityIntegerLevelField('irc3')
---@type abilityintegerlevelfield
ABILITY_ILF_RESTORED_MANA__1_FOR_CURRENT = nil

---ConvertAbilityIntegerLevelField('Ihps')
---@type abilityintegerlevelfield
ABILITY_ILF_HIT_POINTS_RESTORED = nil

---ConvertAbilityIntegerLevelField('Imps')
---@type abilityintegerlevelfield
ABILITY_ILF_MANA_POINTS_RESTORED = nil

---ConvertAbilityIntegerLevelField('Itpm')
---@type abilityintegerlevelfield
ABILITY_ILF_MAXIMUM_NUMBER_OF_UNITS_ITPM = nil

---ConvertAbilityIntegerLevelField('Cad1')
---@type abilityintegerlevelfield
ABILITY_ILF_NUMBER_OF_CORPSES_RAISED_CAD1 = nil

---ConvertAbilityIntegerLevelField('Wrs3')
---@type abilityintegerlevelfield
ABILITY_ILF_TERRAIN_DEFORMATION_DURATION_MS = nil

---ConvertAbilityIntegerLevelField('Uds1')
---@type abilityintegerlevelfield
ABILITY_ILF_MAXIMUM_UNITS = nil

---ConvertAbilityIntegerLevelField('Det1')
---@type abilityintegerlevelfield
ABILITY_ILF_DETECTION_TYPE_DET1 = nil

---ConvertAbilityIntegerLevelField('Nsp1')
---@type abilityintegerlevelfield
ABILITY_ILF_GOLD_COST_PER_STRUCTURE = nil

---ConvertAbilityIntegerLevelField('Nsp2')
---@type abilityintegerlevelfield
ABILITY_ILF_LUMBER_COST_PER_USE = nil

---ConvertAbilityIntegerLevelField('Nsp3')
---@type abilityintegerlevelfield
ABILITY_ILF_DETECTION_TYPE_NSP3 = nil

---ConvertAbilityIntegerLevelField('Uls1')
---@type abilityintegerlevelfield
ABILITY_ILF_NUMBER_OF_SWARM_UNITS = nil

---ConvertAbilityIntegerLevelField('Uls3')
---@type abilityintegerlevelfield
ABILITY_ILF_MAX_SWARM_UNITS_PER_TARGET = nil

---ConvertAbilityIntegerLevelField('Nba2')
---@type abilityintegerlevelfield
ABILITY_ILF_NUMBER_OF_SUMMONED_UNITS_NBA2 = nil

---ConvertAbilityIntegerLevelField('Nch1')
---@type abilityintegerlevelfield
ABILITY_ILF_MAXIMUM_CREEP_LEVEL_NCH1 = nil

---ConvertAbilityIntegerLevelField('Nsi1')
---@type abilityintegerlevelfield
ABILITY_ILF_ATTACKS_PREVENTED = nil

---ConvertAbilityIntegerLevelField('Efk3')
---@type abilityintegerlevelfield
ABILITY_ILF_MAXIMUM_NUMBER_OF_TARGETS_EFK3 = nil

---ConvertAbilityIntegerLevelField('Esv1')
---@type abilityintegerlevelfield
ABILITY_ILF_NUMBER_OF_SUMMONED_UNITS_ESV1 = nil

---ConvertAbilityIntegerLevelField('exh1')
---@type abilityintegerlevelfield
ABILITY_ILF_MAXIMUM_NUMBER_OF_CORPSES_EXH1 = nil

---ConvertAbilityIntegerLevelField('inv1')
---@type abilityintegerlevelfield
ABILITY_ILF_ITEM_CAPACITY = nil

---ConvertAbilityIntegerLevelField('spl2')
---@type abilityintegerlevelfield
ABILITY_ILF_MAXIMUM_NUMBER_OF_TARGETS_SPL2 = nil

---ConvertAbilityIntegerLevelField('irl3')
---@type abilityintegerlevelfield
ABILITY_ILF_ALLOW_WHEN_FULL_IRL3 = nil

---ConvertAbilityIntegerLevelField('idc3')
---@type abilityintegerlevelfield
ABILITY_ILF_MAXIMUM_DISPELLED_UNITS = nil

---ConvertAbilityIntegerLevelField('imo1')
---@type abilityintegerlevelfield
ABILITY_ILF_NUMBER_OF_LURES = nil

---ConvertAbilityIntegerLevelField('ict1')
---@type abilityintegerlevelfield
ABILITY_ILF_NEW_TIME_OF_DAY_HOUR = nil

---ConvertAbilityIntegerLevelField('ict2')
---@type abilityintegerlevelfield
ABILITY_ILF_NEW_TIME_OF_DAY_MINUTE = nil

---ConvertAbilityIntegerLevelField('mec1')
---@type abilityintegerlevelfield
ABILITY_ILF_NUMBER_OF_UNITS_CREATED_MEC1 = nil

---ConvertAbilityIntegerLevelField('spb3')
---@type abilityintegerlevelfield
ABILITY_ILF_MINIMUM_SPELLS = nil

---ConvertAbilityIntegerLevelField('spb4')
---@type abilityintegerlevelfield
ABILITY_ILF_MAXIMUM_SPELLS = nil

---ConvertAbilityIntegerLevelField('gra3')
---@type abilityintegerlevelfield
ABILITY_ILF_DISABLED_ATTACK_INDEX = nil

---ConvertAbilityIntegerLevelField('gra4')
---@type abilityintegerlevelfield
ABILITY_ILF_ENABLED_ATTACK_INDEX_GRA4 = nil

---ConvertAbilityIntegerLevelField('gra5')
---@type abilityintegerlevelfield
ABILITY_ILF_MAXIMUM_ATTACKS = nil

---ConvertAbilityIntegerLevelField('Npr1')
---@type abilityintegerlevelfield
ABILITY_ILF_BUILDING_TYPES_ALLOWED_NPR1 = nil

---ConvertAbilityIntegerLevelField('Nsa1')
---@type abilityintegerlevelfield
ABILITY_ILF_BUILDING_TYPES_ALLOWED_NSA1 = nil

---ConvertAbilityIntegerLevelField('Iaa1')
---@type abilityintegerlevelfield
ABILITY_ILF_ATTACK_MODIFICATION = nil

---ConvertAbilityIntegerLevelField('Npa5')
---@type abilityintegerlevelfield
ABILITY_ILF_SUMMONED_UNIT_COUNT_NPA5 = nil

---ConvertAbilityIntegerLevelField('Igl1')
---@type abilityintegerlevelfield
ABILITY_ILF_UPGRADE_LEVELS = nil

---ConvertAbilityIntegerLevelField('Ndo2')
---@type abilityintegerlevelfield
ABILITY_ILF_NUMBER_OF_SUMMONED_UNITS_NDO2 = nil

---ConvertAbilityIntegerLevelField('Nst1')
---@type abilityintegerlevelfield
ABILITY_ILF_BEASTS_PER_SECOND = nil

---ConvertAbilityIntegerLevelField('Ncl2')
---@type abilityintegerlevelfield
ABILITY_ILF_TARGET_TYPE = nil

---ConvertAbilityIntegerLevelField('Ncl3')
---@type abilityintegerlevelfield
ABILITY_ILF_OPTIONS = nil

---ConvertAbilityIntegerLevelField('Nab3')
---@type abilityintegerlevelfield
ABILITY_ILF_ARMOR_PENALTY_NAB3 = nil

---ConvertAbilityIntegerLevelField('Nhs6')
---@type abilityintegerlevelfield
ABILITY_ILF_WAVE_COUNT_NHS6 = nil

---ConvertAbilityIntegerLevelField('Ntm3')
---@type abilityintegerlevelfield
ABILITY_ILF_MAX_CREEP_LEVEL_NTM3 = nil

---ConvertAbilityIntegerLevelField('Ncs3')
---@type abilityintegerlevelfield
ABILITY_ILF_MISSILE_COUNT = nil

---ConvertAbilityIntegerLevelField('Nlm3')
---@type abilityintegerlevelfield
ABILITY_ILF_SPLIT_ATTACK_COUNT = nil

---ConvertAbilityIntegerLevelField('Nlm6')
---@type abilityintegerlevelfield
ABILITY_ILF_GENERATION_COUNT = nil

---ConvertAbilityIntegerLevelField('Nvc1')
---@type abilityintegerlevelfield
ABILITY_ILF_ROCK_RING_COUNT = nil

---ConvertAbilityIntegerLevelField('Nvc2')
---@type abilityintegerlevelfield
ABILITY_ILF_WAVE_COUNT_NVC2 = nil

---ConvertAbilityIntegerLevelField('Tau1')
---@type abilityintegerlevelfield
ABILITY_ILF_PREFER_HOSTILES_TAU1 = nil

---ConvertAbilityIntegerLevelField('Tau2')
---@type abilityintegerlevelfield
ABILITY_ILF_PREFER_FRIENDLIES_TAU2 = nil

---ConvertAbilityIntegerLevelField('Tau3')
---@type abilityintegerlevelfield
ABILITY_ILF_MAX_UNITS_TAU3 = nil

---ConvertAbilityIntegerLevelField('Tau4')
---@type abilityintegerlevelfield
ABILITY_ILF_NUMBER_OF_PULSES = nil

---ConvertAbilityIntegerLevelField('Hwe1')
---@type abilityintegerlevelfield
ABILITY_ILF_SUMMONED_UNIT_TYPE_HWE1 = nil

---ConvertAbilityIntegerLevelField('Uin4')
---@type abilityintegerlevelfield
ABILITY_ILF_SUMMONED_UNIT_UIN4 = nil

---ConvertAbilityIntegerLevelField('Osf1')
---@type abilityintegerlevelfield
ABILITY_ILF_SUMMONED_UNIT_OSF1 = nil

---ConvertAbilityIntegerLevelField('Efnu')
---@type abilityintegerlevelfield
ABILITY_ILF_SUMMONED_UNIT_TYPE_EFNU = nil

---ConvertAbilityIntegerLevelField('Nbau')
---@type abilityintegerlevelfield
ABILITY_ILF_SUMMONED_UNIT_TYPE_NBAU = nil

---ConvertAbilityIntegerLevelField('Ntou')
---@type abilityintegerlevelfield
ABILITY_ILF_SUMMONED_UNIT_TYPE_NTOU = nil

---ConvertAbilityIntegerLevelField('Esvu')
---@type abilityintegerlevelfield
ABILITY_ILF_SUMMONED_UNIT_TYPE_ESVU = nil

---ConvertAbilityIntegerLevelField('Nef1')
---@type abilityintegerlevelfield
ABILITY_ILF_SUMMONED_UNIT_TYPES = nil

---ConvertAbilityIntegerLevelField('Ndou')
---@type abilityintegerlevelfield
ABILITY_ILF_SUMMONED_UNIT_TYPE_NDOU = nil

---ConvertAbilityIntegerLevelField('Emeu')
---@type abilityintegerlevelfield
ABILITY_ILF_ALTERNATE_FORM_UNIT_EMEU = nil

---ConvertAbilityIntegerLevelField('Aplu')
---@type abilityintegerlevelfield
ABILITY_ILF_PLAGUE_WARD_UNIT_TYPE = nil

---ConvertAbilityIntegerLevelField('Btl1')
---@type abilityintegerlevelfield
ABILITY_ILF_ALLOWED_UNIT_TYPE_BTL1 = nil

---ConvertAbilityIntegerLevelField('Cha1')
---@type abilityintegerlevelfield
ABILITY_ILF_NEW_UNIT_TYPE = nil

---ConvertAbilityIntegerLevelField('ent1')
---@type abilityintegerlevelfield
ABILITY_ILF_RESULTING_UNIT_TYPE_ENT1 = nil

---ConvertAbilityIntegerLevelField('Gydu')
---@type abilityintegerlevelfield
ABILITY_ILF_CORPSE_UNIT_TYPE = nil

---ConvertAbilityIntegerLevelField('Loa1')
---@type abilityintegerlevelfield
ABILITY_ILF_ALLOWED_UNIT_TYPE_LOA1 = nil

---ConvertAbilityIntegerLevelField('Raiu')
---@type abilityintegerlevelfield
ABILITY_ILF_UNIT_TYPE_FOR_LIMIT_CHECK = nil

---ConvertAbilityIntegerLevelField('Stau')
---@type abilityintegerlevelfield
ABILITY_ILF_WARD_UNIT_TYPE_STAU = nil

---ConvertAbilityIntegerLevelField('Iobu')
---@type abilityintegerlevelfield
ABILITY_ILF_EFFECT_ABILITY = nil

---ConvertAbilityIntegerLevelField('Ndc2')
---@type abilityintegerlevelfield
ABILITY_ILF_CONVERSION_UNIT = nil

---ConvertAbilityIntegerLevelField('Nsl1')
---@type abilityintegerlevelfield
ABILITY_ILF_UNIT_TO_PRESERVE = nil

---ConvertAbilityIntegerLevelField('Chl1')
---@type abilityintegerlevelfield
ABILITY_ILF_UNIT_TYPE_ALLOWED = nil

---ConvertAbilityIntegerLevelField('Ulsu')
---@type abilityintegerlevelfield
ABILITY_ILF_SWARM_UNIT_TYPE = nil

---ConvertAbilityIntegerLevelField('coau')
---@type abilityintegerlevelfield
ABILITY_ILF_RESULTING_UNIT_TYPE_COAU = nil

---ConvertAbilityIntegerLevelField('exhu')
---@type abilityintegerlevelfield
ABILITY_ILF_UNIT_TYPE_EXHU = nil

---ConvertAbilityIntegerLevelField('hwdu')
---@type abilityintegerlevelfield
ABILITY_ILF_WARD_UNIT_TYPE_HWDU = nil

---ConvertAbilityIntegerLevelField('imou')
---@type abilityintegerlevelfield
ABILITY_ILF_LURE_UNIT_TYPE = nil

---ConvertAbilityIntegerLevelField('ipmu')
---@type abilityintegerlevelfield
ABILITY_ILF_UNIT_TYPE_IPMU = nil

---ConvertAbilityIntegerLevelField('Nsyu')
---@type abilityintegerlevelfield
ABILITY_ILF_FACTORY_UNIT_ID = nil

---ConvertAbilityIntegerLevelField('Nfyu')
---@type abilityintegerlevelfield
ABILITY_ILF_SPAWN_UNIT_ID_NFYU = nil

---ConvertAbilityIntegerLevelField('Nvcu')
---@type abilityintegerlevelfield
ABILITY_ILF_DESTRUCTIBLE_ID = nil

---ConvertAbilityIntegerLevelField('Iglu')
---@type abilityintegerlevelfield
ABILITY_ILF_UPGRADE_TYPE = nil

---ConvertAbilityRealLevelField('acas')
---@type abilityreallevelfield
ABILITY_RLF_CASTING_TIME = nil

---ConvertAbilityRealLevelField('adur')
---@type abilityreallevelfield
ABILITY_RLF_DURATION_NORMAL = nil

---ConvertAbilityRealLevelField('ahdu')
---@type abilityreallevelfield
ABILITY_RLF_DURATION_HERO = nil

---ConvertAbilityRealLevelField('acdn')
---@type abilityreallevelfield
ABILITY_RLF_COOLDOWN = nil

---ConvertAbilityRealLevelField('aare')
---@type abilityreallevelfield
ABILITY_RLF_AREA_OF_EFFECT = nil

---ConvertAbilityRealLevelField('aran')
---@type abilityreallevelfield
ABILITY_RLF_CAST_RANGE = nil

---ConvertAbilityRealLevelField('Hbz2')
---@type abilityreallevelfield
ABILITY_RLF_DAMAGE_HBZ2 = nil

---ConvertAbilityRealLevelField('Hbz4')
---@type abilityreallevelfield
ABILITY_RLF_BUILDING_REDUCTION_HBZ4 = nil

---ConvertAbilityRealLevelField('Hbz5')
---@type abilityreallevelfield
ABILITY_RLF_DAMAGE_PER_SECOND_HBZ5 = nil

---ConvertAbilityRealLevelField('Hbz6')
---@type abilityreallevelfield
ABILITY_RLF_MAXIMUM_DAMAGE_PER_WAVE = nil

---ConvertAbilityRealLevelField('Hab1')
---@type abilityreallevelfield
ABILITY_RLF_MANA_REGENERATION_INCREASE = nil

---ConvertAbilityRealLevelField('Hmt2')
---@type abilityreallevelfield
ABILITY_RLF_CASTING_DELAY = nil

---ConvertAbilityRealLevelField('Oww1')
---@type abilityreallevelfield
ABILITY_RLF_DAMAGE_PER_SECOND_OWW1 = nil

---ConvertAbilityRealLevelField('Oww2')
---@type abilityreallevelfield
ABILITY_RLF_MAGIC_DAMAGE_REDUCTION_OWW2 = nil

---ConvertAbilityRealLevelField('Ocr1')
---@type abilityreallevelfield
ABILITY_RLF_CHANCE_TO_CRITICAL_STRIKE = nil

---ConvertAbilityRealLevelField('Ocr2')
---@type abilityreallevelfield
ABILITY_RLF_DAMAGE_MULTIPLIER_OCR2 = nil

---ConvertAbilityRealLevelField('Ocr3')
---@type abilityreallevelfield
ABILITY_RLF_DAMAGE_BONUS_OCR3 = nil

---ConvertAbilityRealLevelField('Ocr4')
---@type abilityreallevelfield
ABILITY_RLF_CHANCE_TO_EVADE_OCR4 = nil

---ConvertAbilityRealLevelField('Omi2')
---@type abilityreallevelfield
ABILITY_RLF_DAMAGE_DEALT_PERCENT_OMI2 = nil

---ConvertAbilityRealLevelField('Omi3')
---@type abilityreallevelfield
ABILITY_RLF_DAMAGE_TAKEN_PERCENT_OMI3 = nil

---ConvertAbilityRealLevelField('Omi4')
---@type abilityreallevelfield
ABILITY_RLF_ANIMATION_DELAY = nil

---ConvertAbilityRealLevelField('Owk1')
---@type abilityreallevelfield
ABILITY_RLF_TRANSITION_TIME = nil

---ConvertAbilityRealLevelField('Owk2')
---@type abilityreallevelfield
ABILITY_RLF_MOVEMENT_SPEED_INCREASE_PERCENT_OWK2 = nil

---ConvertAbilityRealLevelField('Owk3')
---@type abilityreallevelfield
ABILITY_RLF_BACKSTAB_DAMAGE = nil

---ConvertAbilityRealLevelField('Udc1')
---@type abilityreallevelfield
ABILITY_RLF_AMOUNT_HEALED_DAMAGED_UDC1 = nil

---ConvertAbilityRealLevelField('Udp1')
---@type abilityreallevelfield
ABILITY_RLF_LIFE_CONVERTED_TO_MANA = nil

---ConvertAbilityRealLevelField('Udp2')
---@type abilityreallevelfield
ABILITY_RLF_LIFE_CONVERTED_TO_LIFE = nil

---ConvertAbilityRealLevelField('Uau1')
---@type abilityreallevelfield
ABILITY_RLF_MOVEMENT_SPEED_INCREASE_PERCENT_UAU1 = nil

---ConvertAbilityRealLevelField('Uau2')
---@type abilityreallevelfield
ABILITY_RLF_LIFE_REGENERATION_INCREASE_PERCENT = nil

---ConvertAbilityRealLevelField('Eev1')
---@type abilityreallevelfield
ABILITY_RLF_CHANCE_TO_EVADE_EEV1 = nil

---ConvertAbilityRealLevelField('Eim1')
---@type abilityreallevelfield
ABILITY_RLF_DAMAGE_PER_INTERVAL = nil

---ConvertAbilityRealLevelField('Eim2')
---@type abilityreallevelfield
ABILITY_RLF_MANA_DRAINED_PER_SECOND_EIM2 = nil

---ConvertAbilityRealLevelField('Eim3')
---@type abilityreallevelfield
ABILITY_RLF_BUFFER_MANA_REQUIRED = nil

---ConvertAbilityRealLevelField('Emb1')
---@type abilityreallevelfield
ABILITY_RLF_MAX_MANA_DRAINED = nil

---ConvertAbilityRealLevelField('Emb2')
---@type abilityreallevelfield
ABILITY_RLF_BOLT_DELAY = nil

---ConvertAbilityRealLevelField('Emb3')
---@type abilityreallevelfield
ABILITY_RLF_BOLT_LIFETIME = nil

---ConvertAbilityRealLevelField('Eme3')
---@type abilityreallevelfield
ABILITY_RLF_ALTITUDE_ADJUSTMENT_DURATION = nil

---ConvertAbilityRealLevelField('Eme4')
---@type abilityreallevelfield
ABILITY_RLF_LANDING_DELAY_TIME = nil

---ConvertAbilityRealLevelField('Eme5')
---@type abilityreallevelfield
ABILITY_RLF_ALTERNATE_FORM_HIT_POINT_BONUS = nil

---ConvertAbilityRealLevelField('Ncr5')
---@type abilityreallevelfield
ABILITY_RLF_MOVE_SPEED_BONUS_INFO_PANEL_ONLY = nil

---ConvertAbilityRealLevelField('Ncr6')
---@type abilityreallevelfield
ABILITY_RLF_ATTACK_SPEED_BONUS_INFO_PANEL_ONLY = nil

---ConvertAbilityRealLevelField('ave5')
---@type abilityreallevelfield
ABILITY_RLF_LIFE_REGENERATION_RATE_PER_SECOND = nil

---ConvertAbilityRealLevelField('Usl1')
---@type abilityreallevelfield
ABILITY_RLF_STUN_DURATION_USL1 = nil

---ConvertAbilityRealLevelField('Uav1')
---@type abilityreallevelfield
ABILITY_RLF_ATTACK_DAMAGE_STOLEN_PERCENT = nil

---ConvertAbilityRealLevelField('Ucs1')
---@type abilityreallevelfield
ABILITY_RLF_DAMAGE_UCS1 = nil

---ConvertAbilityRealLevelField('Ucs2')
---@type abilityreallevelfield
ABILITY_RLF_MAX_DAMAGE_UCS2 = nil

---ConvertAbilityRealLevelField('Ucs3')
---@type abilityreallevelfield
ABILITY_RLF_DISTANCE_UCS3 = nil

---ConvertAbilityRealLevelField('Ucs4')
---@type abilityreallevelfield
ABILITY_RLF_FINAL_AREA_UCS4 = nil

---ConvertAbilityRealLevelField('Uin1')
---@type abilityreallevelfield
ABILITY_RLF_DAMAGE_UIN1 = nil

---ConvertAbilityRealLevelField('Uin2')
---@type abilityreallevelfield
ABILITY_RLF_DURATION = nil

---ConvertAbilityRealLevelField('Uin3')
---@type abilityreallevelfield
ABILITY_RLF_IMPACT_DELAY = nil

---ConvertAbilityRealLevelField('Ocl1')
---@type abilityreallevelfield
ABILITY_RLF_DAMAGE_PER_TARGET_OCL1 = nil

---ConvertAbilityRealLevelField('Ocl3')
---@type abilityreallevelfield
ABILITY_RLF_DAMAGE_REDUCTION_PER_TARGET = nil

---ConvertAbilityRealLevelField('Oeq1')
---@type abilityreallevelfield
ABILITY_RLF_EFFECT_DELAY_OEQ1 = nil

---ConvertAbilityRealLevelField('Oeq2')
---@type abilityreallevelfield
ABILITY_RLF_DAMAGE_PER_SECOND_TO_BUILDINGS = nil

---ConvertAbilityRealLevelField('Oeq3')
---@type abilityreallevelfield
ABILITY_RLF_UNITS_SLOWED_PERCENT = nil

---ConvertAbilityRealLevelField('Oeq4')
---@type abilityreallevelfield
ABILITY_RLF_FINAL_AREA_OEQ4 = nil

---ConvertAbilityRealLevelField('Eer1')
---@type abilityreallevelfield
ABILITY_RLF_DAMAGE_PER_SECOND_EER1 = nil

---ConvertAbilityRealLevelField('Eah1')
---@type abilityreallevelfield
ABILITY_RLF_DAMAGE_DEALT_TO_ATTACKERS = nil

---ConvertAbilityRealLevelField('Etq1')
---@type abilityreallevelfield
ABILITY_RLF_LIFE_HEALED = nil

---ConvertAbilityRealLevelField('Etq2')
---@type abilityreallevelfield
ABILITY_RLF_HEAL_INTERVAL = nil

---ConvertAbilityRealLevelField('Etq3')
---@type abilityreallevelfield
ABILITY_RLF_BUILDING_REDUCTION_ETQ3 = nil

---ConvertAbilityRealLevelField('Etq4')
---@type abilityreallevelfield
ABILITY_RLF_INITIAL_IMMUNITY_DURATION = nil

---ConvertAbilityRealLevelField('Udd1')
---@type abilityreallevelfield
ABILITY_RLF_MAX_LIFE_DRAINED_PER_SECOND_PERCENT = nil

---ConvertAbilityRealLevelField('Udd2')
---@type abilityreallevelfield
ABILITY_RLF_BUILDING_REDUCTION_UDD2 = nil

---ConvertAbilityRealLevelField('Ufa1')
---@type abilityreallevelfield
ABILITY_RLF_ARMOR_DURATION = nil

---ConvertAbilityRealLevelField('Ufa2')
---@type abilityreallevelfield
ABILITY_RLF_ARMOR_BONUS_UFA2 = nil

---ConvertAbilityRealLevelField('Ufn1')
---@type abilityreallevelfield
ABILITY_RLF_AREA_OF_EFFECT_DAMAGE = nil

---ConvertAbilityRealLevelField('Ufn2')
---@type abilityreallevelfield
ABILITY_RLF_SPECIFIC_TARGET_DAMAGE_UFN2 = nil

---ConvertAbilityRealLevelField('Hfa1')
---@type abilityreallevelfield
ABILITY_RLF_DAMAGE_BONUS_HFA1 = nil

---ConvertAbilityRealLevelField('Esf1')
---@type abilityreallevelfield
ABILITY_RLF_DAMAGE_DEALT_ESF1 = nil

---ConvertAbilityRealLevelField('Esf2')
---@type abilityreallevelfield
ABILITY_RLF_DAMAGE_INTERVAL_ESF2 = nil

---ConvertAbilityRealLevelField('Esf3')
---@type abilityreallevelfield
ABILITY_RLF_BUILDING_REDUCTION_ESF3 = nil

---ConvertAbilityRealLevelField('Ear1')
---@type abilityreallevelfield
ABILITY_RLF_DAMAGE_BONUS_PERCENT = nil

---ConvertAbilityRealLevelField('Hav1')
---@type abilityreallevelfield
ABILITY_RLF_DEFENSE_BONUS_HAV1 = nil

---ConvertAbilityRealLevelField('Hav2')
---@type abilityreallevelfield
ABILITY_RLF_HIT_POINT_BONUS = nil

---ConvertAbilityRealLevelField('Hav3')
---@type abilityreallevelfield
ABILITY_RLF_DAMAGE_BONUS_HAV3 = nil

---ConvertAbilityRealLevelField('Hav4')
---@type abilityreallevelfield
ABILITY_RLF_MAGIC_DAMAGE_REDUCTION_HAV4 = nil

---ConvertAbilityRealLevelField('Hbh1')
---@type abilityreallevelfield
ABILITY_RLF_CHANCE_TO_BASH = nil

---ConvertAbilityRealLevelField('Hbh2')
---@type abilityreallevelfield
ABILITY_RLF_DAMAGE_MULTIPLIER_HBH2 = nil

---ConvertAbilityRealLevelField('Hbh3')
---@type abilityreallevelfield
ABILITY_RLF_DAMAGE_BONUS_HBH3 = nil

---ConvertAbilityRealLevelField('Hbh4')
---@type abilityreallevelfield
ABILITY_RLF_CHANCE_TO_MISS_HBH4 = nil

---ConvertAbilityRealLevelField('Htb1')
---@type abilityreallevelfield
ABILITY_RLF_DAMAGE_HTB1 = nil

---ConvertAbilityRealLevelField('Htc1')
---@type abilityreallevelfield
ABILITY_RLF_AOE_DAMAGE = nil

---ConvertAbilityRealLevelField('Htc2')
---@type abilityreallevelfield
ABILITY_RLF_SPECIFIC_TARGET_DAMAGE_HTC2 = nil

---ConvertAbilityRealLevelField('Htc3')
---@type abilityreallevelfield
ABILITY_RLF_MOVEMENT_SPEED_REDUCTION_PERCENT_HTC3 = nil

---ConvertAbilityRealLevelField('Htc4')
---@type abilityreallevelfield
ABILITY_RLF_ATTACK_SPEED_REDUCTION_PERCENT_HTC4 = nil

---ConvertAbilityRealLevelField('Had1')
---@type abilityreallevelfield
ABILITY_RLF_ARMOR_BONUS_HAD1 = nil

---ConvertAbilityRealLevelField('Hhb1')
---@type abilityreallevelfield
ABILITY_RLF_AMOUNT_HEALED_DAMAGED_HHB1 = nil

---ConvertAbilityRealLevelField('Hca1')
---@type abilityreallevelfield
ABILITY_RLF_EXTRA_DAMAGE_HCA1 = nil

---ConvertAbilityRealLevelField('Hca2')
---@type abilityreallevelfield
ABILITY_RLF_MOVEMENT_SPEED_FACTOR_HCA2 = nil

---ConvertAbilityRealLevelField('Hca3')
---@type abilityreallevelfield
ABILITY_RLF_ATTACK_SPEED_FACTOR_HCA3 = nil

---ConvertAbilityRealLevelField('Oae1')
---@type abilityreallevelfield
ABILITY_RLF_MOVEMENT_SPEED_INCREASE_PERCENT_OAE1 = nil

---ConvertAbilityRealLevelField('Oae2')
---@type abilityreallevelfield
ABILITY_RLF_ATTACK_SPEED_INCREASE_PERCENT_OAE2 = nil

---ConvertAbilityRealLevelField('Ore1')
---@type abilityreallevelfield
ABILITY_RLF_REINCARNATION_DELAY = nil

---ConvertAbilityRealLevelField('Osh1')
---@type abilityreallevelfield
ABILITY_RLF_DAMAGE_OSH1 = nil

---ConvertAbilityRealLevelField('Osh2')
---@type abilityreallevelfield
ABILITY_RLF_MAXIMUM_DAMAGE_OSH2 = nil

---ConvertAbilityRealLevelField('Osh3')
---@type abilityreallevelfield
ABILITY_RLF_DISTANCE_OSH3 = nil

---ConvertAbilityRealLevelField('Osh4')
---@type abilityreallevelfield
ABILITY_RLF_FINAL_AREA_OSH4 = nil

---ConvertAbilityRealLevelField('Nfd1')
---@type abilityreallevelfield
ABILITY_RLF_GRAPHIC_DELAY_NFD1 = nil

---ConvertAbilityRealLevelField('Nfd2')
---@type abilityreallevelfield
ABILITY_RLF_GRAPHIC_DURATION_NFD2 = nil

---ConvertAbilityRealLevelField('Nfd3')
---@type abilityreallevelfield
ABILITY_RLF_DAMAGE_NFD3 = nil

---ConvertAbilityRealLevelField('Ams1')
---@type abilityreallevelfield
ABILITY_RLF_SUMMONED_UNIT_DAMAGE_AMS1 = nil

---ConvertAbilityRealLevelField('Ams2')
---@type abilityreallevelfield
ABILITY_RLF_MAGIC_DAMAGE_REDUCTION_AMS2 = nil

---ConvertAbilityRealLevelField('Apl1')
---@type abilityreallevelfield
ABILITY_RLF_AURA_DURATION = nil

---ConvertAbilityRealLevelField('Apl2')
---@type abilityreallevelfield
ABILITY_RLF_DAMAGE_PER_SECOND_APL2 = nil

---ConvertAbilityRealLevelField('Apl3')
---@type abilityreallevelfield
ABILITY_RLF_DURATION_OF_PLAGUE_WARD = nil

---ConvertAbilityRealLevelField('Oar1')
---@type abilityreallevelfield
ABILITY_RLF_AMOUNT_OF_HIT_POINTS_REGENERATED = nil

---ConvertAbilityRealLevelField('Akb1')
---@type abilityreallevelfield
ABILITY_RLF_ATTACK_DAMAGE_INCREASE_AKB1 = nil

---ConvertAbilityRealLevelField('Adm1')
---@type abilityreallevelfield
ABILITY_RLF_MANA_LOSS_ADM1 = nil

---ConvertAbilityRealLevelField('Adm2')
---@type abilityreallevelfield
ABILITY_RLF_SUMMONED_UNIT_DAMAGE_ADM2 = nil

---ConvertAbilityRealLevelField('Bli1')
---@type abilityreallevelfield
ABILITY_RLF_EXPANSION_AMOUNT = nil

---ConvertAbilityRealLevelField('Bgm2')
---@type abilityreallevelfield
ABILITY_RLF_INTERVAL_DURATION_BGM2 = nil

---ConvertAbilityRealLevelField('Bgm4')
---@type abilityreallevelfield
ABILITY_RLF_RADIUS_OF_MINING_RING = nil

---ConvertAbilityRealLevelField('Blo1')
---@type abilityreallevelfield
ABILITY_RLF_ATTACK_SPEED_INCREASE_PERCENT_BLO1 = nil

---ConvertAbilityRealLevelField('Blo2')
---@type abilityreallevelfield
ABILITY_RLF_MOVEMENT_SPEED_INCREASE_PERCENT_BLO2 = nil

---ConvertAbilityRealLevelField('Blo3')
---@type abilityreallevelfield
ABILITY_RLF_SCALING_FACTOR = nil

---ConvertAbilityRealLevelField('Can1')
---@type abilityreallevelfield
ABILITY_RLF_HIT_POINTS_PER_SECOND_CAN1 = nil

---ConvertAbilityRealLevelField('Can2')
---@type abilityreallevelfield
ABILITY_RLF_MAX_HIT_POINTS = nil

---ConvertAbilityRealLevelField('Dev2')
---@type abilityreallevelfield
ABILITY_RLF_DAMAGE_PER_SECOND_DEV2 = nil

---ConvertAbilityRealLevelField('Chd1')
---@type abilityreallevelfield
ABILITY_RLF_MOVEMENT_UPDATE_FREQUENCY_CHD1 = nil

---ConvertAbilityRealLevelField('Chd2')
---@type abilityreallevelfield
ABILITY_RLF_ATTACK_UPDATE_FREQUENCY_CHD2 = nil

---ConvertAbilityRealLevelField('Chd3')
---@type abilityreallevelfield
ABILITY_RLF_SUMMONED_UNIT_DAMAGE_CHD3 = nil

---ConvertAbilityRealLevelField('Cri1')
---@type abilityreallevelfield
ABILITY_RLF_MOVEMENT_SPEED_REDUCTION_PERCENT_CRI1 = nil
