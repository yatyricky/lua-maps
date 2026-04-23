---@diagnostic disable

---@param whichTrigger trigger
---@param key integer
---@param missionKey integer
---@param table hashtable
---@return boolean
function SaveTriggerHandleBJ(whichTrigger, key, missionKey, table) end

---@param whichTriggercondition triggercondition
---@param key integer
---@param missionKey integer
---@param table hashtable
---@return boolean
function SaveTriggerConditionHandleBJ(whichTriggercondition, key, missionKey, table) end

---@param whichTriggeraction triggeraction
---@param key integer
---@param missionKey integer
---@param table hashtable
---@return boolean
function SaveTriggerActionHandleBJ(whichTriggeraction, key, missionKey, table) end

---@param whichEvent event
---@param key integer
---@param missionKey integer
---@param table hashtable
---@return boolean
function SaveTriggerEventHandleBJ(whichEvent, key, missionKey, table) end

---@param whichForce force
---@param key integer
---@param missionKey integer
---@param table hashtable
---@return boolean
function SaveForceHandleBJ(whichForce, key, missionKey, table) end

---@param whichGroup group
---@param key integer
---@param missionKey integer
---@param table hashtable
---@return boolean
function SaveGroupHandleBJ(whichGroup, key, missionKey, table) end

---@param whichLocation location
---@param key integer
---@param missionKey integer
---@param table hashtable
---@return boolean
function SaveLocationHandleBJ(whichLocation, key, missionKey, table) end

---@param whichRect rect
---@param key integer
---@param missionKey integer
---@param table hashtable
---@return boolean
function SaveRectHandleBJ(whichRect, key, missionKey, table) end

---@param whichBoolexpr boolexpr
---@param key integer
---@param missionKey integer
---@param table hashtable
---@return boolean
function SaveBooleanExprHandleBJ(whichBoolexpr, key, missionKey, table) end

---@param whichSound sound
---@param key integer
---@param missionKey integer
---@param table hashtable
---@return boolean
function SaveSoundHandleBJ(whichSound, key, missionKey, table) end

---@param whichEffect effect
---@param key integer
---@param missionKey integer
---@param table hashtable
---@return boolean
function SaveEffectHandleBJ(whichEffect, key, missionKey, table) end

---@param whichUnitpool unitpool
---@param key integer
---@param missionKey integer
---@param table hashtable
---@return boolean
function SaveUnitPoolHandleBJ(whichUnitpool, key, missionKey, table) end

---@param whichItempool itempool
---@param key integer
---@param missionKey integer
---@param table hashtable
---@return boolean
function SaveItemPoolHandleBJ(whichItempool, key, missionKey, table) end

---@param whichQuest quest
---@param key integer
---@param missionKey integer
---@param table hashtable
---@return boolean
function SaveQuestHandleBJ(whichQuest, key, missionKey, table) end

---@param whichQuestitem questitem
---@param key integer
---@param missionKey integer
---@param table hashtable
---@return boolean
function SaveQuestItemHandleBJ(whichQuestitem, key, missionKey, table) end

---@param whichDefeatcondition defeatcondition
---@param key integer
---@param missionKey integer
---@param table hashtable
---@return boolean
function SaveDefeatConditionHandleBJ(whichDefeatcondition, key, missionKey, table) end

---@param whichTimerdialog timerdialog
---@param key integer
---@param missionKey integer
---@param table hashtable
---@return boolean
function SaveTimerDialogHandleBJ(whichTimerdialog, key, missionKey, table) end

---@param whichLeaderboard leaderboard
---@param key integer
---@param missionKey integer
---@param table hashtable
---@return boolean
function SaveLeaderboardHandleBJ(whichLeaderboard, key, missionKey, table) end

---@param whichMultiboard multiboard
---@param key integer
---@param missionKey integer
---@param table hashtable
---@return boolean
function SaveMultiboardHandleBJ(whichMultiboard, key, missionKey, table) end

---@param whichMultiboarditem multiboarditem
---@param key integer
---@param missionKey integer
---@param table hashtable
---@return boolean
function SaveMultiboardItemHandleBJ(whichMultiboarditem, key, missionKey, table) end

---@param whichTrackable trackable
---@param key integer
---@param missionKey integer
---@param table hashtable
---@return boolean
function SaveTrackableHandleBJ(whichTrackable, key, missionKey, table) end

---@param whichDialog dialog
---@param key integer
---@param missionKey integer
---@param table hashtable
---@return boolean
function SaveDialogHandleBJ(whichDialog, key, missionKey, table) end

---@param whichButton button
---@param key integer
---@param missionKey integer
---@param table hashtable
---@return boolean
function SaveButtonHandleBJ(whichButton, key, missionKey, table) end

---@param whichTexttag texttag
---@param key integer
---@param missionKey integer
---@param table hashtable
---@return boolean
function SaveTextTagHandleBJ(whichTexttag, key, missionKey, table) end

---@param whichLightning lightning
---@param key integer
---@param missionKey integer
---@param table hashtable
---@return boolean
function SaveLightningHandleBJ(whichLightning, key, missionKey, table) end

---@param whichImage image
---@param key integer
---@param missionKey integer
---@param table hashtable
---@return boolean
function SaveImageHandleBJ(whichImage, key, missionKey, table) end

---@param whichUbersplat ubersplat
---@param key integer
---@param missionKey integer
---@param table hashtable
---@return boolean
function SaveUbersplatHandleBJ(whichUbersplat, key, missionKey, table) end

---@param whichRegion region
---@param key integer
---@param missionKey integer
---@param table hashtable
---@return boolean
function SaveRegionHandleBJ(whichRegion, key, missionKey, table) end

---@param whichFogState fogstate
---@param key integer
---@param missionKey integer
---@param table hashtable
---@return boolean
function SaveFogStateHandleBJ(whichFogState, key, missionKey, table) end

---@param whichFogModifier fogmodifier
---@param key integer
---@param missionKey integer
---@param table hashtable
---@return boolean
function SaveFogModifierHandleBJ(whichFogModifier, key, missionKey, table) end

---@param whichAgent agent
---@param key integer
---@param missionKey integer
---@param table hashtable
---@return boolean
function SaveAgentHandleBJ(whichAgent, key, missionKey, table) end

---@param whichHashtable hashtable
---@param key integer
---@param missionKey integer
---@param table hashtable
---@return boolean
function SaveHashtableHandleBJ(whichHashtable, key, missionKey, table) end

---@param key string
---@param missionKey string
---@param cache gamecache
---@return real
function GetStoredRealBJ(key, missionKey, cache) end

---@param key string
---@param missionKey string
---@param cache gamecache
---@return integer
function GetStoredIntegerBJ(key, missionKey, cache) end

---@param key string
---@param missionKey string
---@param cache gamecache
---@return boolean
function GetStoredBooleanBJ(key, missionKey, cache) end

---@param key string
---@param missionKey string
---@param cache gamecache
---@return string
function GetStoredStringBJ(key, missionKey, cache) end

---@param key integer
---@param missionKey integer
---@param table hashtable
---@return real
function LoadRealBJ(key, missionKey, table) end

---@param key integer
---@param missionKey integer
---@param table hashtable
---@return integer
function LoadIntegerBJ(key, missionKey, table) end

---@param key integer
---@param missionKey integer
---@param table hashtable
---@return boolean
function LoadBooleanBJ(key, missionKey, table) end

---@param key integer
---@param missionKey integer
---@param table hashtable
---@return string
function LoadStringBJ(key, missionKey, table) end

---@param key integer
---@param missionKey integer
---@param table hashtable
---@return player
function LoadPlayerHandleBJ(key, missionKey, table) end

---@param key integer
---@param missionKey integer
---@param table hashtable
---@return widget
function LoadWidgetHandleBJ(key, missionKey, table) end

---@param key integer
---@param missionKey integer
---@param table hashtable
---@return destructable
function LoadDestructableHandleBJ(key, missionKey, table) end

---@param key integer
---@param missionKey integer
---@param table hashtable
---@return item
function LoadItemHandleBJ(key, missionKey, table) end

---@param key integer
---@param missionKey integer
---@param table hashtable
---@return unit
function LoadUnitHandleBJ(key, missionKey, table) end

---@param key integer
---@param missionKey integer
---@param table hashtable
---@return ability
function LoadAbilityHandleBJ(key, missionKey, table) end

---@param key integer
---@param missionKey integer
---@param table hashtable
---@return timer
function LoadTimerHandleBJ(key, missionKey, table) end

---@param key integer
---@param missionKey integer
---@param table hashtable
---@return trigger
function LoadTriggerHandleBJ(key, missionKey, table) end

---@param key integer
---@param missionKey integer
---@param table hashtable
---@return triggercondition
function LoadTriggerConditionHandleBJ(key, missionKey, table) end

---@param key integer
---@param missionKey integer
---@param table hashtable
---@return triggeraction
function LoadTriggerActionHandleBJ(key, missionKey, table) end

---@param key integer
---@param missionKey integer
---@param table hashtable
---@return event
function LoadTriggerEventHandleBJ(key, missionKey, table) end

---@param key integer
---@param missionKey integer
---@param table hashtable
---@return force
function LoadForceHandleBJ(key, missionKey, table) end

---@param key integer
---@param missionKey integer
---@param table hashtable
---@return group
function LoadGroupHandleBJ(key, missionKey, table) end

---@param key integer
---@param missionKey integer
---@param table hashtable
---@return location
function LoadLocationHandleBJ(key, missionKey, table) end

---@param key integer
---@param missionKey integer
---@param table hashtable
---@return rect
function LoadRectHandleBJ(key, missionKey, table) end

---@param key integer
---@param missionKey integer
---@param table hashtable
---@return boolexpr
function LoadBooleanExprHandleBJ(key, missionKey, table) end

---@param key integer
---@param missionKey integer
---@param table hashtable
---@return sound
function LoadSoundHandleBJ(key, missionKey, table) end

---@param key integer
---@param missionKey integer
---@param table hashtable
---@return effect
function LoadEffectHandleBJ(key, missionKey, table) end

---@param key integer
---@param missionKey integer
---@param table hashtable
---@return unitpool
function LoadUnitPoolHandleBJ(key, missionKey, table) end

---@param key integer
---@param missionKey integer
---@param table hashtable
---@return itempool
function LoadItemPoolHandleBJ(key, missionKey, table) end

---@param key integer
---@param missionKey integer
---@param table hashtable
---@return quest
function LoadQuestHandleBJ(key, missionKey, table) end

---@param key integer
---@param missionKey integer
---@param table hashtable
---@return questitem
function LoadQuestItemHandleBJ(key, missionKey, table) end

---@param key integer
---@param missionKey integer
---@param table hashtable
---@return defeatcondition
function LoadDefeatConditionHandleBJ(key, missionKey, table) end

---@param key integer
---@param missionKey integer
---@param table hashtable
---@return timerdialog
function LoadTimerDialogHandleBJ(key, missionKey, table) end

---@param key integer
---@param missionKey integer
---@param table hashtable
---@return leaderboard
function LoadLeaderboardHandleBJ(key, missionKey, table) end

---@param key integer
---@param missionKey integer
---@param table hashtable
---@return multiboard
function LoadMultiboardHandleBJ(key, missionKey, table) end

---@param key integer
---@param missionKey integer
---@param table hashtable
---@return multiboarditem
function LoadMultiboardItemHandleBJ(key, missionKey, table) end

---@param key integer
---@param missionKey integer
---@param table hashtable
---@return trackable
function LoadTrackableHandleBJ(key, missionKey, table) end

---@param key integer
---@param missionKey integer
---@param table hashtable
---@return dialog
function LoadDialogHandleBJ(key, missionKey, table) end

---@param key integer
---@param missionKey integer
---@param table hashtable
---@return button
function LoadButtonHandleBJ(key, missionKey, table) end

---@param key integer
---@param missionKey integer
---@param table hashtable
---@return texttag
function LoadTextTagHandleBJ(key, missionKey, table) end

---@param key integer
---@param missionKey integer
---@param table hashtable
---@return lightning
function LoadLightningHandleBJ(key, missionKey, table) end

---@param key integer
---@param missionKey integer
---@param table hashtable
---@return image
function LoadImageHandleBJ(key, missionKey, table) end

---@param key integer
---@param missionKey integer
---@param table hashtable
---@return ubersplat
function LoadUbersplatHandleBJ(key, missionKey, table) end

---@param key integer
---@param missionKey integer
---@param table hashtable
---@return region
function LoadRegionHandleBJ(key, missionKey, table) end

---@param key integer
---@param missionKey integer
---@param table hashtable
---@return fogstate
function LoadFogStateHandleBJ(key, missionKey, table) end

---@param key integer
---@param missionKey integer
---@param table hashtable
---@return fogmodifier
function LoadFogModifierHandleBJ(key, missionKey, table) end

---@param key integer
---@param missionKey integer
---@param table hashtable
---@return hashtable
function LoadHashtableHandleBJ(key, missionKey, table) end

---@param key string
---@param missionKey string
---@param cache gamecache
---@param forWhichPlayer player
---@param loc location
---@param facing real
---@return unit
function RestoreUnitLocFacingAngleBJ(key, missionKey, cache, forWhichPlayer, loc, facing) end

---@param key string
---@param missionKey string
---@param cache gamecache
---@param forWhichPlayer player
---@param loc location
---@param lookAt location
---@return unit
function RestoreUnitLocFacingPointBJ(key, missionKey, cache, forWhichPlayer, loc, lookAt) end

---@return unit
function GetLastRestoredUnitBJ() end

---@param cache gamecache
function FlushGameCacheBJ(cache) end

---@param missionKey string
---@param cache gamecache
function FlushStoredMissionBJ(missionKey, cache) end

---@param table hashtable
function FlushParentHashtableBJ(table) end

---@param missionKey integer
---@param table hashtable
function FlushChildHashtableBJ(missionKey, table) end

---@param key string
---@param valueType integer
---@param missionKey string
---@param cache gamecache
---@return boolean
function HaveStoredValue(key, valueType, missionKey, cache) end

---@param key integer
---@param valueType integer
---@param missionKey integer
---@param table hashtable
---@return boolean
function HaveSavedValue(key, valueType, missionKey, table) end

---@param show boolean
---@param whichButton integer
function ShowCustomCampaignButton(show, whichButton) end

---@param whichButton integer
---@return boolean
function IsCustomCampaignButtonVisibile(whichButton) end

---@param mapSaveName string
---@param doCheckpointHint boolean
function SaveGameCheckPointBJ(mapSaveName, doCheckpointHint) end

---@param loadFileName string
---@param doScoreScreen boolean
function LoadGameBJ(loadFileName, doScoreScreen) end

---@param saveFileName string
---@param newLevel string
---@param doScoreScreen boolean
function SaveAndChangeLevelBJ(saveFileName, newLevel, doScoreScreen) end

---@param saveFileName string
---@param loadFileName string
---@param doScoreScreen boolean
function SaveAndLoadGameBJ(saveFileName, loadFileName, doScoreScreen) end

---@param sourceDirName string
---@param destDirName string
---@return boolean
function RenameSaveDirectoryBJ(sourceDirName, destDirName) end

---@param sourceDirName string
---@return boolean
function RemoveSaveDirectoryBJ(sourceDirName) end

---@param sourceSaveName string
---@param destSaveName string
---@return boolean
function CopySaveGameBJ(sourceSaveName, destSaveName) end

---@param whichPlayer player
---@return real
function GetPlayerStartLocationX(whichPlayer) end

---@param whichPlayer player
---@return real
function GetPlayerStartLocationY(whichPlayer) end

---@param whichPlayer player
---@return location
function GetPlayerStartLocationLoc(whichPlayer) end

---@param whichRect rect
---@return location
function GetRectCenter(whichRect) end

---@param whichPlayer player
---@param whichState playerslotstate
---@return boolean
function IsPlayerSlotState(whichPlayer, whichState) end

---@param seconds real
---@return integer
function GetFadeFromSeconds(seconds) end

---@param seconds real
---@return real
function GetFadeFromSecondsAsReal(seconds) end

---@param whichPlayer player
---@param whichPlayerState playerstate
---@param delta integer
function AdjustPlayerStateSimpleBJ(whichPlayer, whichPlayerState, delta) end

---@param delta integer
---@param whichPlayer player
---@param whichPlayerState playerstate
function AdjustPlayerStateBJ(delta, whichPlayer, whichPlayerState) end

---@param whichPlayer player
---@param whichPlayerState playerstate
---@param value integer
function SetPlayerStateBJ(whichPlayer, whichPlayerState, value) end

---@param whichPlayerFlag playerstate
---@param flag boolean
---@param whichPlayer player
function SetPlayerFlagBJ(whichPlayerFlag, flag, whichPlayer) end

---@param rate integer
---@param whichResource playerstate
---@param sourcePlayer player
---@param otherPlayer player
function SetPlayerTaxRateBJ(rate, whichResource, sourcePlayer, otherPlayer) end

---@param whichResource playerstate
---@param sourcePlayer player
---@param otherPlayer player
---@return integer
function GetPlayerTaxRateBJ(whichResource, sourcePlayer, otherPlayer) end

---@param whichPlayerFlag playerstate
---@param whichPlayer player
---@return boolean
function IsPlayerFlagSetBJ(whichPlayerFlag, whichPlayer) end

---@param delta integer
---@param whichUnit unit
function AddResourceAmountBJ(delta, whichUnit) end

---@param whichPlayer player
---@return integer
function GetConvertedPlayerId(whichPlayer) end

---@param convertedPlayerId integer
---@return player
function ConvertedPlayer(convertedPlayerId) end

---@param r rect
---@return real
function GetRectWidthBJ(r) end

---@param r rect
---@return real
function GetRectHeightBJ(r) end

---@param goldMine unit
---@param whichPlayer player
---@return unit
function BlightGoldMineForPlayerBJ(goldMine, whichPlayer) end

---@param goldMine unit
---@param whichPlayer player
---@return unit
function BlightGoldMineForPlayer(goldMine, whichPlayer) end

---@return unit
function GetLastHauntedGoldMine() end

---@param where location
---@return boolean
function IsPointBlightedBJ(where) end

function SetPlayerColorBJEnum() end

---@param whichPlayer player
---@param color playercolor
---@param changeExisting boolean
function SetPlayerColorBJ(whichPlayer, color, changeExisting) end

---@param unitId integer
---@param allowed boolean
---@param whichPlayer player
function SetPlayerUnitAvailableBJ(unitId, allowed, whichPlayer) end

function LockGameSpeedBJ() end

function UnlockGameSpeedBJ() end

---@param whichUnit unit
---@param order string
---@param targetWidget widget
---@return boolean
function IssueTargetOrderBJ(whichUnit, order, targetWidget) end

---@param whichUnit unit
---@param order string
---@param whichLocation location
---@return boolean
function IssuePointOrderLocBJ(whichUnit, order, whichLocation) end

---@param whichUnit unit
---@param order string
---@param targetWidget widget
---@return boolean
function IssueTargetDestructableOrder(whichUnit, order, targetWidget) end

---@param whichUnit unit
---@param order string
---@param targetWidget widget
---@return boolean
function IssueTargetItemOrder(whichUnit, order, targetWidget) end

---@param whichUnit unit
---@param order string
---@return boolean
function IssueImmediateOrderBJ(whichUnit, order) end

---@param whichGroup group
---@param order string
---@param targetWidget widget
---@return boolean
function GroupTargetOrderBJ(whichGroup, order, targetWidget) end

---@param whichGroup group
---@param order string
---@param whichLocation location
---@return boolean
function GroupPointOrderLocBJ(whichGroup, order, whichLocation) end

---@param whichGroup group
---@param order string
---@return boolean
function GroupImmediateOrderBJ(whichGroup, order) end

---@param whichGroup group
---@param order string
---@param targetWidget widget
---@return boolean
function GroupTargetDestructableOrder(whichGroup, order, targetWidget) end

---@param whichGroup group
---@param order string
---@param targetWidget widget
---@return boolean
function GroupTargetItemOrder(whichGroup, order, targetWidget) end

---@return destructable
function GetDyingDestructable() end

---@param whichUnit unit
---@param targPos location
function SetUnitRallyPoint(whichUnit, targPos) end

---@param whichUnit unit
---@param targUnit unit
function SetUnitRallyUnit(whichUnit, targUnit) end

---@param whichUnit unit
---@param targDest destructable
function SetUnitRallyDestructable(whichUnit, targDest) end

function SaveDyingWidget() end

---@param addBlight boolean
---@param whichPlayer player
---@param r rect
function SetBlightRectBJ(addBlight, whichPlayer, r) end

---@param addBlight boolean
---@param whichPlayer player
---@param loc location
---@param radius real
function SetBlightRadiusLocBJ(addBlight, whichPlayer, loc, radius) end

---@param abilcode integer
---@return string
function GetAbilityName(abilcode) end

function MeleeStartingVisibility() end

function MeleeStartingResources() end

---@param whichPlayer player
---@param techId integer
---@param limit integer
function ReducePlayerTechMaxAllowed(whichPlayer, techId, limit) end

function MeleeStartingHeroLimit() end

---@return boolean
function MeleeTrainedUnitIsHeroBJFilter() end

---@param whichUnit unit
function MeleeGrantItemsToHero(whichUnit) end

function MeleeGrantItemsToTrainedHero() end

function MeleeGrantItemsToHiredHero() end

function MeleeGrantHeroItems() end

function MeleeClearExcessUnit() end

---@param x real
---@param y real
---@param range real
function MeleeClearNearbyUnits(x, y, range) end

function MeleeClearExcessUnits() end

function MeleeEnumFindNearestMine() end

---@param src location
---@param range real
---@return unit
function MeleeFindNearestMine(src, range) end

---@param p player
---@param id1 integer
---@param id2 integer
---@param id3 integer
---@param id4 integer
---@param loc location
---@return unit
function MeleeRandomHeroLoc(p, id1, id2, id3, id4, loc) end

---@param src location
---@param targ location
---@param distance real
---@param deltaAngle real
---@return location
function MeleeGetProjectedLoc(src, targ, distance, deltaAngle) end

---@param val real
---@param minVal real
---@param maxVal real
---@return real
function MeleeGetNearestValueWithin(val, minVal, maxVal) end

---@param src location
---@param r rect
---@return location
function MeleeGetLocWithinRect(src, r) end

---@param whichPlayer player
---@param startLoc location
---@param doHeroes boolean
---@param doCamera boolean
---@param doPreload boolean
function MeleeStartingUnitsHuman(whichPlayer, startLoc, doHeroes, doCamera, doPreload) end

---@param whichPlayer player
---@param startLoc location
---@param doHeroes boolean
---@param doCamera boolean
---@param doPreload boolean
function MeleeStartingUnitsOrc(whichPlayer, startLoc, doHeroes, doCamera, doPreload) end

---@param whichPlayer player
---@param startLoc location
---@param doHeroes boolean
---@param doCamera boolean
---@param doPreload boolean
function MeleeStartingUnitsUndead(whichPlayer, startLoc, doHeroes, doCamera, doPreload) end

---@param whichPlayer player
---@param startLoc location
---@param doHeroes boolean
---@param doCamera boolean
---@param doPreload boolean
function MeleeStartingUnitsNightElf(whichPlayer, startLoc, doHeroes, doCamera, doPreload) end

---@param whichPlayer player
---@param startLoc location
---@param doHeroes boolean
---@param doCamera boolean
---@param doPreload boolean
function MeleeStartingUnitsUnknownRace(whichPlayer, startLoc, doHeroes, doCamera, doPreload) end

function MeleeStartingUnits() end

---@param whichRace race
---@param whichPlayer player
---@param loc location
---@param doHeroes boolean
function MeleeStartingUnitsForPlayer(whichRace, whichPlayer, loc, doHeroes) end

---@param num player
---@param s1 string
---@param s2 string
---@param s3 string
function PickMeleeAI(num, s1, s2, s3) end

function MeleeStartingAI() end

---@param targ unit
function LockGuardPosition(targ) end

---@param playerIndex integer
---@param opponentIndex integer
---@return boolean
function MeleePlayerIsOpponent(playerIndex, opponentIndex) end

---@param whichPlayer player
---@return integer
function MeleeGetAllyStructureCount(whichPlayer) end

---@param whichPlayer player
---@return integer
function MeleeGetAllyCount(whichPlayer) end

---@param whichPlayer player
---@return integer
function MeleeGetAllyKeyStructureCount(whichPlayer) end

function MeleeDoDrawEnum() end

function MeleeDoVictoryEnum() end

---@param whichPlayer player
function MeleeDoDefeat(whichPlayer) end

function MeleeDoDefeatEnum() end

---@param whichPlayer player
function MeleeDoLeave(whichPlayer) end

function MeleeRemoveObservers() end

---@return force
function MeleeCheckForVictors() end

function MeleeCheckForLosersAndVictors() end

---@param whichPlayer player
---@return string
function MeleeGetCrippledWarningMessage(whichPlayer) end

---@param whichPlayer player
---@return string
function MeleeGetCrippledTimerMessage(whichPlayer) end

---@param whichPlayer player
---@return string
function MeleeGetCrippledRevealedMessage(whichPlayer) end

---@param whichPlayer player
---@param expose boolean
function MeleeExposePlayer(whichPlayer, expose) end

function MeleeExposeAllPlayers() end

function MeleeCrippledPlayerTimeout() end

---@param whichPlayer player
---@return boolean
function MeleePlayerIsCrippled(whichPlayer) end

function MeleeCheckForCrippledPlayers() end

---@param lostUnit unit
function MeleeCheckLostUnit(lostUnit) end

---@param addedUnit unit
function MeleeCheckAddedUnit(addedUnit) end

function MeleeTriggerActionConstructCancel() end

function MeleeTriggerActionUnitDeath() end

function MeleeTriggerActionUnitConstructionStart() end

function MeleeTriggerActionPlayerDefeated() end

function MeleeTriggerActionPlayerLeft() end

function MeleeTriggerActionAllianceChange() end

function MeleeTriggerTournamentFinishSoon() end

---@param whichPlayer player
---@return boolean
function MeleeWasUserPlayer(whichPlayer) end

---@param multiplier integer
function MeleeTournamentFinishNowRuleA(multiplier) end

function MeleeTriggerTournamentFinishNow() end

function MeleeInitVictoryDefeat() end

function CheckInitPlayerSlotAvailability() end

---@param whichPlayer player
---@param control mapcontrol
function SetPlayerSlotAvailable(whichPlayer, control) end

---@param teamCount integer
function TeamInitPlayerSlots(teamCount) end

function MeleeInitPlayerSlots() end

function FFAInitPlayerSlots() end

function OneOnOneInitPlayerSlots() end

function InitGenericPlayerSlots() end

function SetDNCSoundsDawn() end

function SetDNCSoundsDusk() end

function SetDNCSoundsDay() end

function SetDNCSoundsNight() end

function InitDNCSounds() end

function InitBlizzardGlobals() end

function InitQueuedTriggers() end

function InitMapRects() end

function InitSummonableCaps() end

---@param whichItem item
function UpdateStockAvailability(whichItem) end

function UpdateEachStockBuildingEnum() end

---@param iType itemtype
---@param iLevel integer
function UpdateEachStockBuilding(iType, iLevel) end

function PerformStockUpdates() end

function StartStockUpdates() end

function RemovePurchasedItem() end

function InitNeutralBuildings() end

function MarkGameStarted() end

function DetectGameStarted() end

function InitBlizzard() end

function RandomDistReset() end

---@param inID integer
---@param inChance integer
function RandomDistAddItem(inID, inChance) end

---@return integer
function RandomDistChoose() end

---@param inUnit unit
---@param inItemID integer
---@return item
function UnitDropItem(inUnit, inItemID) end

---@param inWidget widget
---@param inItemID integer
---@return item
function WidgetDropItem(inWidget, inItemID) end

---@return boolean
function BlzIsLastInstanceObjectFunctionSuccessful() end

---@param whichAbility ability
---@param whichField abilitybooleanfield
---@param value boolean
function BlzSetAbilityBooleanFieldBJ(whichAbility, whichField, value) end

---@param whichAbility ability
---@param whichField abilityintegerfield
---@param value integer
function BlzSetAbilityIntegerFieldBJ(whichAbility, whichField, value) end

---@param whichAbility ability
---@param whichField abilityrealfield
---@param value real
function BlzSetAbilityRealFieldBJ(whichAbility, whichField, value) end

---@param whichAbility ability
---@param whichField abilitystringfield
---@param value string
function BlzSetAbilityStringFieldBJ(whichAbility, whichField, value) end

---@param whichAbility ability
---@param whichField abilitybooleanlevelfield
---@param level integer
---@param value boolean
function BlzSetAbilityBooleanLevelFieldBJ(whichAbility, whichField, level, value) end

---@param whichAbility ability
---@param whichField abilityintegerlevelfield
---@param level integer
---@param value integer
function BlzSetAbilityIntegerLevelFieldBJ(whichAbility, whichField, level, value) end

---@param whichAbility ability
---@param whichField abilityreallevelfield
---@param level integer
---@param value real
function BlzSetAbilityRealLevelFieldBJ(whichAbility, whichField, level, value) end

---@param whichAbility ability
---@param whichField abilitystringlevelfield
---@param level integer
---@param value string
function BlzSetAbilityStringLevelFieldBJ(whichAbility, whichField, level, value) end

---@param whichAbility ability
---@param whichField abilitybooleanlevelarrayfield
---@param level integer
---@param index integer
---@param value boolean
function BlzSetAbilityBooleanLevelArrayFieldBJ(whichAbility, whichField, level, index, value) end

---@param whichAbility ability
---@param whichField abilityintegerlevelarrayfield
---@param level integer
---@param index integer
---@param value integer
function BlzSetAbilityIntegerLevelArrayFieldBJ(whichAbility, whichField, level, index, value) end

---@param whichAbility ability
---@param whichField abilityreallevelarrayfield
---@param level integer
---@param index integer
---@param value real
function BlzSetAbilityRealLevelArrayFieldBJ(whichAbility, whichField, level, index, value) end

---@param whichAbility ability
---@param whichField abilitystringlevelarrayfield
---@param level integer
---@param index integer
---@param value string
function BlzSetAbilityStringLevelArrayFieldBJ(whichAbility, whichField, level, index, value) end

---@param whichAbility ability
---@param whichField abilitybooleanlevelarrayfield
---@param level integer
---@param value boolean
function BlzAddAbilityBooleanLevelArrayFieldBJ(whichAbility, whichField, level, value) end

---@param whichAbility ability
---@param whichField abilityintegerlevelarrayfield
---@param level integer
---@param value integer
function BlzAddAbilityIntegerLevelArrayFieldBJ(whichAbility, whichField, level, value) end

---@param whichAbility ability
---@param whichField abilityreallevelarrayfield
---@param level integer
---@param value real
function BlzAddAbilityRealLevelArrayFieldBJ(whichAbility, whichField, level, value) end

---@param whichAbility ability
---@param whichField abilitystringlevelarrayfield
---@param level integer
---@param value string
function BlzAddAbilityStringLevelArrayFieldBJ(whichAbility, whichField, level, value) end

---@param whichAbility ability
---@param whichField abilitybooleanlevelarrayfield
---@param level integer
---@param value boolean
function BlzRemoveAbilityBooleanLevelArrayFieldBJ(whichAbility, whichField, level, value) end

---@param whichAbility ability
---@param whichField abilityintegerlevelarrayfield
---@param level integer
---@param value integer
function BlzRemoveAbilityIntegerLevelArrayFieldBJ(whichAbility, whichField, level, value) end

---@param whichAbility ability
---@param whichField abilityreallevelarrayfield
---@param level integer
---@param value real
function BlzRemoveAbilityRealLevelArrayFieldBJ(whichAbility, whichField, level, value) end

---@param whichAbility ability
---@param whichField abilitystringlevelarrayfield
---@param level integer
---@param value string
function BlzRemoveAbilityStringLevelArrayFieldBJ(whichAbility, whichField, level, value) end

---@param whichItem item
---@param abilCode integer
function BlzItemAddAbilityBJ(whichItem, abilCode) end

---@param whichItem item
---@param abilCode integer
function BlzItemRemoveAbilityBJ(whichItem, abilCode) end

---@param whichItem item
---@param whichField itembooleanfield
---@param value boolean
function BlzSetItemBooleanFieldBJ(whichItem, whichField, value) end

---@param whichItem item
---@param whichField itemintegerfield
---@param value integer
function BlzSetItemIntegerFieldBJ(whichItem, whichField, value) end

---@param whichItem item
---@param whichField itemrealfield
---@param value real
function BlzSetItemRealFieldBJ(whichItem, whichField, value) end

---@param whichItem item
---@param whichField itemstringfield
---@param value string
function BlzSetItemStringFieldBJ(whichItem, whichField, value) end

---@param whichUnit unit
---@param whichField unitbooleanfield
---@param value boolean
function BlzSetUnitBooleanFieldBJ(whichUnit, whichField, value) end

---@param whichUnit unit
---@param whichField unitintegerfield
---@param value integer
function BlzSetUnitIntegerFieldBJ(whichUnit, whichField, value) end

---@param whichUnit unit
---@param whichField unitrealfield
---@param value real
function BlzSetUnitRealFieldBJ(whichUnit, whichField, value) end

---@param whichUnit unit
---@param whichField unitstringfield
---@param value string
function BlzSetUnitStringFieldBJ(whichUnit, whichField, value) end

---@param whichUnit unit
---@param whichField unitweaponbooleanfield
---@param index integer
---@param value boolean
function BlzSetUnitWeaponBooleanFieldBJ(whichUnit, whichField, index, value) end

---@param whichUnit unit
---@param whichField unitweaponintegerfield
---@param index integer
---@param value integer
function BlzSetUnitWeaponIntegerFieldBJ(whichUnit, whichField, index, value) end

---@param whichUnit unit
---@param whichField unitweaponrealfield
---@param index integer
---@param value real
function BlzSetUnitWeaponRealFieldBJ(whichUnit, whichField, index, value) end

---@param whichUnit unit
---@param whichField unitweaponstringfield
---@param index integer
---@param value string
function BlzSetUnitWeaponStringFieldBJ(whichUnit, whichField, index, value) end

