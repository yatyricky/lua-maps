
---@param whichPlayer player
---@param abilid integer
---@param avail boolean
---@return nothing
function SetPlayerAbilityAvailable(whichPlayer, abilid, avail) end

---@param whichPlayer player
---@param whichPlayerState playerstate
---@param value integer
---@return nothing
function SetPlayerState(whichPlayer, whichPlayerState, value) end

---@param whichPlayer player
---@param gameResult playergameresult
---@return nothing
function RemovePlayer(whichPlayer, gameResult) end

---@param whichPlayer player
---@return nothing
function CachePlayerHeroData(whichPlayer) end

---@param forWhichPlayer player
---@param whichState fogstate
---@param where rect
---@param useSharedVision boolean
---@return nothing
function SetFogStateRect(forWhichPlayer, whichState, where, useSharedVision) end

---@param forWhichPlayer player
---@param whichState fogstate
---@param centerx real
---@param centerY real
---@param radius real
---@param useSharedVision boolean
---@return nothing
function SetFogStateRadius(forWhichPlayer, whichState, centerx, centerY, radius, useSharedVision) end

---@param forWhichPlayer player
---@param whichState fogstate
---@param center location
---@param radius real
---@param useSharedVision boolean
---@return nothing
function SetFogStateRadiusLoc(forWhichPlayer, whichState, center, radius, useSharedVision) end

---@param enable boolean
---@return nothing
function FogMaskEnable(enable) end

---@return boolean
function IsFogMaskEnabled() end

---@param enable boolean
---@return nothing
function FogEnable(enable) end

---@return boolean
function IsFogEnabled() end

---@param forWhichPlayer player
---@param whichState fogstate
---@param where rect
---@param useSharedVision boolean
---@param afterUnits boolean
---@return fogmodifier
function CreateFogModifierRect(forWhichPlayer, whichState, where, useSharedVision, afterUnits) end

---@param forWhichPlayer player
---@param whichState fogstate
---@param centerx real
---@param centerY real
---@param radius real
---@param useSharedVision boolean
---@param afterUnits boolean
---@return fogmodifier
function CreateFogModifierRadius(forWhichPlayer, whichState, centerx, centerY, radius, useSharedVision, afterUnits) end

---@param forWhichPlayer player
---@param whichState fogstate
---@param center location
---@param radius real
---@param useSharedVision boolean
---@param afterUnits boolean
---@return fogmodifier
function CreateFogModifierRadiusLoc(forWhichPlayer, whichState, center, radius, useSharedVision, afterUnits) end

---@param whichFogModifier fogmodifier
---@return nothing
function DestroyFogModifier(whichFogModifier) end

---@param whichFogModifier fogmodifier
---@return nothing
function FogModifierStart(whichFogModifier) end

---@param whichFogModifier fogmodifier
---@return nothing
function FogModifierStop(whichFogModifier) end

---@return version
function VersionGet() end

---@param whichVersion version
---@return boolean
function VersionCompatible(whichVersion) end

---@param whichVersion version
---@return boolean
function VersionSupported(whichVersion) end

---@param doScoreScreen boolean
---@return nothing
function EndGame(doScoreScreen) end

---@param newLevel string
---@param doScoreScreen boolean
---@return nothing
function ChangeLevel(newLevel, doScoreScreen) end

---@param doScoreScreen boolean
---@return nothing
function RestartGame(doScoreScreen) end

---@return nothing
function ReloadGame() end

---@param r race
---@return nothing
function SetCampaignMenuRace(r) end

---@param campaignIndex integer
---@return nothing
function SetCampaignMenuRaceEx(campaignIndex) end

---@return nothing
function ForceCampaignSelectScreen() end

---@param saveFileName string
---@param doScoreScreen boolean
---@return nothing
function LoadGame(saveFileName, doScoreScreen) end

---@param saveFileName string
---@return nothing
function SaveGame(saveFileName) end

---@param sourceDirName string
---@param destDirName string
---@return boolean
function RenameSaveDirectory(sourceDirName, destDirName) end

---@param sourceDirName string
---@return boolean
function RemoveSaveDirectory(sourceDirName) end

---@param sourceSaveName string
---@param destSaveName string
---@return boolean
function CopySaveGame(sourceSaveName, destSaveName) end

---@param saveName string
---@return boolean
function SaveGameExists(saveName) end

---@param maxCheckpointSaves integer
---@return nothing
function SetMaxCheckpointSaves(maxCheckpointSaves) end

---@param saveFileName string
---@param showWindow boolean
---@return nothing
function SaveGameCheckpoint(saveFileName, showWindow) end

---@return nothing
function SyncSelections() end

---@param whichFloatGameState fgamestate
---@param value real
---@return nothing
function SetFloatGameState(whichFloatGameState, value) end

---@param whichFloatGameState fgamestate
---@return real
function GetFloatGameState(whichFloatGameState) end

---@param whichIntegerGameState igamestate
---@param value integer
---@return nothing
function SetIntegerGameState(whichIntegerGameState, value) end

---@param whichIntegerGameState igamestate
---@return integer
function GetIntegerGameState(whichIntegerGameState) end

---@param cleared boolean
---@return nothing
function SetTutorialCleared(cleared) end

---@param campaignNumber integer
---@param missionNumber integer
---@param available boolean
---@return nothing
function SetMissionAvailable(campaignNumber, missionNumber, available) end

---@param campaignNumber integer
---@param available boolean
---@return nothing
function SetCampaignAvailable(campaignNumber, available) end

---@param campaignNumber integer
---@param available boolean
---@return nothing
function SetOpCinematicAvailable(campaignNumber, available) end

---@param campaignNumber integer
---@param available boolean
---@return nothing
function SetEdCinematicAvailable(campaignNumber, available) end

---@return gamedifficulty
function GetDefaultDifficulty() end

---@param g gamedifficulty
---@return nothing
function SetDefaultDifficulty(g) end

---@param whichButton integer
---@param visible boolean
---@return nothing
function SetCustomCampaignButtonVisible(whichButton, visible) end

---@param whichButton integer
---@return boolean
function GetCustomCampaignButtonVisible(whichButton) end

---@return nothing
function DoNotSaveReplay() end

---@return dialog
function DialogCreate() end

---@param whichDialog dialog
---@return nothing
function DialogDestroy(whichDialog) end

---@param whichDialog dialog
---@return nothing
function DialogClear(whichDialog) end

---@param whichDialog dialog
---@param messageText string
---@return nothing
function DialogSetMessage(whichDialog, messageText) end

---@param whichDialog dialog
---@param buttonText string
---@param hotkey integer
---@return button
function DialogAddButton(whichDialog, buttonText, hotkey) end

---@param whichDialog dialog
---@param doScoreScreen boolean
---@param buttonText string
---@param hotkey integer
---@return button
function DialogAddQuitButton(whichDialog, doScoreScreen, buttonText, hotkey) end

---@param whichPlayer player
---@param whichDialog dialog
---@param flag boolean
---@return nothing
function DialogDisplay(whichPlayer, whichDialog, flag) end

---@return boolean
function ReloadGameCachesFromDisk() end

---@param campaignFile string
---@return gamecache
function InitGameCache(campaignFile) end

---@param whichCache gamecache
---@return boolean
function SaveGameCache(whichCache) end

---@param cache gamecache
---@param missionKey string
---@param key string
---@param value integer
---@return nothing
function StoreInteger(cache, missionKey, key, value) end

---@param cache gamecache
---@param missionKey string
---@param key string
---@param value real
---@return nothing
function StoreReal(cache, missionKey, key, value) end

---@param cache gamecache
---@param missionKey string
---@param key string
---@param value boolean
---@return nothing
function StoreBoolean(cache, missionKey, key, value) end

---@param cache gamecache
---@param missionKey string
---@param key string
---@param whichUnit unit
---@return boolean
function StoreUnit(cache, missionKey, key, whichUnit) end

---@param cache gamecache
---@param missionKey string
---@param key string
---@param value string
---@return boolean
function StoreString(cache, missionKey, key, value) end

---@param cache gamecache
---@param missionKey string
---@param key string
---@return nothing
function SyncStoredInteger(cache, missionKey, key) end

---@param cache gamecache
---@param missionKey string
---@param key string
---@return nothing
function SyncStoredReal(cache, missionKey, key) end

---@param cache gamecache
---@param missionKey string
---@param key string
---@return nothing
function SyncStoredBoolean(cache, missionKey, key) end

---@param cache gamecache
---@param missionKey string
---@param key string
---@return nothing
function SyncStoredUnit(cache, missionKey, key) end

---@param cache gamecache
---@param missionKey string
---@param key string
---@return nothing
function SyncStoredString(cache, missionKey, key) end

---@param cache gamecache
---@param missionKey string
---@param key string
---@return boolean
function HaveStoredInteger(cache, missionKey, key) end

---@param cache gamecache
---@param missionKey string
---@param key string
---@return boolean
function HaveStoredReal(cache, missionKey, key) end

---@param cache gamecache
---@param missionKey string
---@param key string
---@return boolean
function HaveStoredBoolean(cache, missionKey, key) end

---@param cache gamecache
---@param missionKey string
---@param key string
---@return boolean
function HaveStoredUnit(cache, missionKey, key) end

---@param cache gamecache
---@param missionKey string
---@param key string
---@return boolean
function HaveStoredString(cache, missionKey, key) end

---@param cache gamecache
---@return nothing
function FlushGameCache(cache) end

---@param cache gamecache
---@param missionKey string
---@return nothing
function FlushStoredMission(cache, missionKey) end

---@param cache gamecache
---@param missionKey string
---@param key string
---@return nothing
function FlushStoredInteger(cache, missionKey, key) end

---@param cache gamecache
---@param missionKey string
---@param key string
---@return nothing
function FlushStoredReal(cache, missionKey, key) end

---@param cache gamecache
---@param missionKey string
---@param key string
---@return nothing
function FlushStoredBoolean(cache, missionKey, key) end

---@param cache gamecache
---@param missionKey string
---@param key string
---@return nothing
function FlushStoredUnit(cache, missionKey, key) end

---@param cache gamecache
---@param missionKey string
---@param key string
---@return nothing
function FlushStoredString(cache, missionKey, key) end

---@param cache gamecache
---@param missionKey string
---@param key string
---@return integer
function GetStoredInteger(cache, missionKey, key) end

---@param cache gamecache
---@param missionKey string
---@param key string
---@return real
function GetStoredReal(cache, missionKey, key) end

---@param cache gamecache
---@param missionKey string
---@param key string
---@return boolean
function GetStoredBoolean(cache, missionKey, key) end

---@param cache gamecache
---@param missionKey string
---@param key string
---@return string
function GetStoredString(cache, missionKey, key) end

---@param cache gamecache
---@param missionKey string
---@param key string
---@param forWhichPlayer player
---@param x real
---@param y real
---@param facing real
---@return unit
function RestoreUnit(cache, missionKey, key, forWhichPlayer, x, y, facing) end

---@return hashtable
function InitHashtable() end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@param value integer
---@return nothing
function SaveInteger(table, parentKey, childKey, value) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@param value real
---@return nothing
function SaveReal(table, parentKey, childKey, value) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@param value boolean
---@return nothing
function SaveBoolean(table, parentKey, childKey, value) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@param value string
---@return boolean
function SaveStr(table, parentKey, childKey, value) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@param whichPlayer player
---@return boolean
function SavePlayerHandle(table, parentKey, childKey, whichPlayer) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@param whichWidget widget
---@return boolean
function SaveWidgetHandle(table, parentKey, childKey, whichWidget) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@param whichDestructable destructable
---@return boolean
function SaveDestructableHandle(table, parentKey, childKey, whichDestructable) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@param whichItem item
---@return boolean
function SaveItemHandle(table, parentKey, childKey, whichItem) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@param whichUnit unit
---@return boolean
function SaveUnitHandle(table, parentKey, childKey, whichUnit) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@param whichAbility ability
---@return boolean
function SaveAbilityHandle(table, parentKey, childKey, whichAbility) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@param whichTimer timer
---@return boolean
function SaveTimerHandle(table, parentKey, childKey, whichTimer) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@param whichTrigger trigger
---@return boolean
function SaveTriggerHandle(table, parentKey, childKey, whichTrigger) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@param whichTriggercondition triggercondition
---@return boolean
function SaveTriggerConditionHandle(table, parentKey, childKey, whichTriggercondition) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@param whichTriggeraction triggeraction
---@return boolean
function SaveTriggerActionHandle(table, parentKey, childKey, whichTriggeraction) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@param whichEvent event
---@return boolean
function SaveTriggerEventHandle(table, parentKey, childKey, whichEvent) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@param whichForce force
---@return boolean
function SaveForceHandle(table, parentKey, childKey, whichForce) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@param whichGroup group
---@return boolean
function SaveGroupHandle(table, parentKey, childKey, whichGroup) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@param whichLocation location
---@return boolean
function SaveLocationHandle(table, parentKey, childKey, whichLocation) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@param whichRect rect
---@return boolean
function SaveRectHandle(table, parentKey, childKey, whichRect) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@param whichBoolexpr boolexpr
---@return boolean
function SaveBooleanExprHandle(table, parentKey, childKey, whichBoolexpr) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@param whichSound sound
---@return boolean
function SaveSoundHandle(table, parentKey, childKey, whichSound) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@param whichEffect effect
---@return boolean
function SaveEffectHandle(table, parentKey, childKey, whichEffect) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@param whichUnitpool unitpool
---@return boolean
function SaveUnitPoolHandle(table, parentKey, childKey, whichUnitpool) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@param whichItempool itempool
---@return boolean
function SaveItemPoolHandle(table, parentKey, childKey, whichItempool) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@param whichQuest quest
---@return boolean
function SaveQuestHandle(table, parentKey, childKey, whichQuest) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@param whichQuestitem questitem
---@return boolean
function SaveQuestItemHandle(table, parentKey, childKey, whichQuestitem) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@param whichDefeatcondition defeatcondition
---@return boolean
function SaveDefeatConditionHandle(table, parentKey, childKey, whichDefeatcondition) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@param whichTimerdialog timerdialog
---@return boolean
function SaveTimerDialogHandle(table, parentKey, childKey, whichTimerdialog) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@param whichLeaderboard leaderboard
---@return boolean
function SaveLeaderboardHandle(table, parentKey, childKey, whichLeaderboard) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@param whichMultiboard multiboard
---@return boolean
function SaveMultiboardHandle(table, parentKey, childKey, whichMultiboard) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@param whichMultiboarditem multiboarditem
---@return boolean
function SaveMultiboardItemHandle(table, parentKey, childKey, whichMultiboarditem) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@param whichTrackable trackable
---@return boolean
function SaveTrackableHandle(table, parentKey, childKey, whichTrackable) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@param whichDialog dialog
---@return boolean
function SaveDialogHandle(table, parentKey, childKey, whichDialog) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@param whichButton button
---@return boolean
function SaveButtonHandle(table, parentKey, childKey, whichButton) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@param whichTexttag texttag
---@return boolean
function SaveTextTagHandle(table, parentKey, childKey, whichTexttag) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@param whichLightning lightning
---@return boolean
function SaveLightningHandle(table, parentKey, childKey, whichLightning) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@param whichImage image
---@return boolean
function SaveImageHandle(table, parentKey, childKey, whichImage) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@param whichUbersplat ubersplat
---@return boolean
function SaveUbersplatHandle(table, parentKey, childKey, whichUbersplat) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@param whichRegion region
---@return boolean
function SaveRegionHandle(table, parentKey, childKey, whichRegion) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@param whichFogState fogstate
---@return boolean
function SaveFogStateHandle(table, parentKey, childKey, whichFogState) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@param whichFogModifier fogmodifier
---@return boolean
function SaveFogModifierHandle(table, parentKey, childKey, whichFogModifier) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@param whichAgent agent
---@return boolean
function SaveAgentHandle(table, parentKey, childKey, whichAgent) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@param whichHashtable hashtable
---@return boolean
function SaveHashtableHandle(table, parentKey, childKey, whichHashtable) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@param whichFrameHandle framehandle
---@return boolean
function SaveFrameHandle(table, parentKey, childKey, whichFrameHandle) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return integer
function LoadInteger(table, parentKey, childKey) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return real
function LoadReal(table, parentKey, childKey) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return boolean
function LoadBoolean(table, parentKey, childKey) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return string
function LoadStr(table, parentKey, childKey) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return player
function LoadPlayerHandle(table, parentKey, childKey) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return widget
function LoadWidgetHandle(table, parentKey, childKey) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return destructable
function LoadDestructableHandle(table, parentKey, childKey) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return item
function LoadItemHandle(table, parentKey, childKey) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return unit
function LoadUnitHandle(table, parentKey, childKey) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return ability
function LoadAbilityHandle(table, parentKey, childKey) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return timer
function LoadTimerHandle(table, parentKey, childKey) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return trigger
function LoadTriggerHandle(table, parentKey, childKey) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return triggercondition
function LoadTriggerConditionHandle(table, parentKey, childKey) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return triggeraction
function LoadTriggerActionHandle(table, parentKey, childKey) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return event
function LoadTriggerEventHandle(table, parentKey, childKey) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return force
function LoadForceHandle(table, parentKey, childKey) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return group
function LoadGroupHandle(table, parentKey, childKey) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return location
function LoadLocationHandle(table, parentKey, childKey) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return rect
function LoadRectHandle(table, parentKey, childKey) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return boolexpr
function LoadBooleanExprHandle(table, parentKey, childKey) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return sound
function LoadSoundHandle(table, parentKey, childKey) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return effect
function LoadEffectHandle(table, parentKey, childKey) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return unitpool
function LoadUnitPoolHandle(table, parentKey, childKey) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return itempool
function LoadItemPoolHandle(table, parentKey, childKey) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return quest
function LoadQuestHandle(table, parentKey, childKey) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return questitem
function LoadQuestItemHandle(table, parentKey, childKey) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return defeatcondition
function LoadDefeatConditionHandle(table, parentKey, childKey) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return timerdialog
function LoadTimerDialogHandle(table, parentKey, childKey) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return leaderboard
function LoadLeaderboardHandle(table, parentKey, childKey) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return multiboard
function LoadMultiboardHandle(table, parentKey, childKey) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return multiboarditem
function LoadMultiboardItemHandle(table, parentKey, childKey) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return trackable
function LoadTrackableHandle(table, parentKey, childKey) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return dialog
function LoadDialogHandle(table, parentKey, childKey) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return button
function LoadButtonHandle(table, parentKey, childKey) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return texttag
function LoadTextTagHandle(table, parentKey, childKey) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return lightning
function LoadLightningHandle(table, parentKey, childKey) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return image
function LoadImageHandle(table, parentKey, childKey) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return ubersplat
function LoadUbersplatHandle(table, parentKey, childKey) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return region
function LoadRegionHandle(table, parentKey, childKey) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return fogstate
function LoadFogStateHandle(table, parentKey, childKey) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return fogmodifier
function LoadFogModifierHandle(table, parentKey, childKey) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return hashtable
function LoadHashtableHandle(table, parentKey, childKey) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return framehandle
function LoadFrameHandle(table, parentKey, childKey) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return boolean
function HaveSavedInteger(table, parentKey, childKey) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return boolean
function HaveSavedReal(table, parentKey, childKey) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return boolean
function HaveSavedBoolean(table, parentKey, childKey) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return boolean
function HaveSavedString(table, parentKey, childKey) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return boolean
function HaveSavedHandle(table, parentKey, childKey) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return nothing
function RemoveSavedInteger(table, parentKey, childKey) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return nothing
function RemoveSavedReal(table, parentKey, childKey) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return nothing
function RemoveSavedBoolean(table, parentKey, childKey) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return nothing
function RemoveSavedString(table, parentKey, childKey) end

---@param table hashtable
---@param parentKey integer
---@param childKey integer
---@return nothing
function RemoveSavedHandle(table, parentKey, childKey) end

---@param table hashtable
---@return nothing
function FlushParentHashtable(table) end

---@param table hashtable
---@param parentKey integer
---@return nothing
function FlushChildHashtable(table, parentKey) end

---@param lowBound integer
---@param highBound integer
---@return integer
function GetRandomInt(lowBound, highBound) end

---@param lowBound real
---@param highBound real
---@return real
function GetRandomReal(lowBound, highBound) end

---@return unitpool
function CreateUnitPool() end

---@param whichPool unitpool
---@return nothing
function DestroyUnitPool(whichPool) end

---@param whichPool unitpool
---@param unitId integer
---@param weight real
---@return nothing
function UnitPoolAddUnitType(whichPool, unitId, weight) end

---@param whichPool unitpool
---@param unitId integer
---@return nothing
function UnitPoolRemoveUnitType(whichPool, unitId) end

---@param whichPool unitpool
---@param forWhichPlayer player
---@param x real
---@param y real
---@param facing real
---@return unit
function PlaceRandomUnit(whichPool, forWhichPlayer, x, y, facing) end

---@return itempool
function CreateItemPool() end

---@param whichItemPool itempool
---@return nothing
function DestroyItemPool(whichItemPool) end

---@param whichItemPool itempool
---@param itemId integer
---@param weight real
---@return nothing
function ItemPoolAddItemType(whichItemPool, itemId, weight) end

---@param whichItemPool itempool
---@param itemId integer
---@return nothing
function ItemPoolRemoveItemType(whichItemPool, itemId) end

---@param whichItemPool itempool
---@param x real
---@param y real
---@return item
function PlaceRandomItem(whichItemPool, x, y) end

---@param level integer
---@return integer
function ChooseRandomCreep(level) end

---@return integer
function ChooseRandomNPBuilding() end

---@param level integer
---@return integer
function ChooseRandomItem(level) end

---@param whichType itemtype
---@param level integer
---@return integer
function ChooseRandomItemEx(whichType, level) end

---@param seed integer
---@return nothing
function SetRandomSeed(seed) end

---@param a real
---@param b real
---@param c real
---@param d real
---@param e real
---@return nothing
function SetTerrainFog(a, b, c, d, e) end

---@return nothing
function ResetTerrainFog() end

---@param a real
---@param b real
---@param c real
---@param d real
---@param e real
---@return nothing
function SetUnitFog(a, b, c, d, e) end

---@param style integer
---@param zstart real
---@param zend real
---@param density real
---@param red real
---@param green real
---@param blue real
---@return nothing
function SetTerrainFogEx(style, zstart, zend, density, red, green, blue) end

---@param toPlayer player
---@param x real
---@param y real
---@param message string
---@return nothing
function DisplayTextToPlayer(toPlayer, x, y, message) end

---@param toPlayer player
---@param x real
---@param y real
---@param duration real
---@param message string
---@return nothing
function DisplayTimedTextToPlayer(toPlayer, x, y, duration, message) end

---@param toPlayer player
---@param x real
---@param y real
---@param duration real
---@param message string
---@return nothing
function DisplayTimedTextFromPlayer(toPlayer, x, y, duration, message) end

---@return nothing
function ClearTextMessages() end

---@param terrainDNCFile string
---@param unitDNCFile string
---@return nothing
function SetDayNightModels(terrainDNCFile, unitDNCFile) end

---@param portraitDNCFile string
---@return nothing
function SetPortraitLight(portraitDNCFile) end

---@param skyModelFile string
---@return nothing
function SetSkyModel(skyModelFile) end

---@param b boolean
---@return nothing
function EnableUserControl(b) end

---@param b boolean
---@return nothing
function EnableUserUI(b) end

---@param b boolean
---@return nothing
function SuspendTimeOfDay(b) end

---@param r real
---@return nothing
function SetTimeOfDayScale(r) end

---@return real
function GetTimeOfDayScale() end

---@param flag boolean
---@param fadeDuration real
---@return nothing
function ShowInterface(flag, fadeDuration) end

---@param flag boolean
---@return nothing
function PauseGame(flag) end

---@param whichUnit unit
---@param red integer
---@param green integer
---@param blue integer
---@param alpha integer
---@return nothing
function UnitAddIndicator(whichUnit, red, green, blue, alpha) end

---@param whichWidget widget
---@param red integer
---@param green integer
---@param blue integer
---@param alpha integer
---@return nothing
function AddIndicator(whichWidget, red, green, blue, alpha) end

---@param x real
---@param y real
---@param duration real
---@return nothing
function PingMinimap(x, y, duration) end

---@param x real
---@param y real
---@param duration real
---@param red integer
---@param green integer
---@param blue integer
---@param extraEffects boolean
---@return nothing
function PingMinimapEx(x, y, duration, red, green, blue, extraEffects) end

---@param whichUnit unit
---@param red integer
---@param green integer
---@param blue integer
---@param pingPath string
---@param fogVisibility fogstate
---@return minimapicon
function CreateMinimapIconOnUnit(whichUnit, red, green, blue, pingPath, fogVisibility) end

---@param where location
---@param red integer
---@param green integer
---@param blue integer
---@param pingPath string
---@param fogVisibility fogstate
---@return minimapicon
function CreateMinimapIconAtLoc(where, red, green, blue, pingPath, fogVisibility) end

---@param x real
---@param y real
---@param red integer
---@param green integer
---@param blue integer
---@param pingPath string
---@param fogVisibility fogstate
---@return minimapicon
function CreateMinimapIcon(x, y, red, green, blue, pingPath, fogVisibility) end

---@param key string
---@return string
function SkinManagerGetLocalPath(key) end

---@param pingId minimapicon
---@return nothing
function DestroyMinimapIcon(pingId) end

---@param whichMinimapIcon minimapicon
---@param visible boolean
---@return nothing
function SetMinimapIconVisible(whichMinimapIcon, visible) end

---@param whichMinimapIcon minimapicon
---@param doDestroy boolean
---@return nothing
function SetMinimapIconOrphanDestroy(whichMinimapIcon, doDestroy) end

---@param flag boolean
---@return nothing
function EnableOcclusion(flag) end

---@param introText string
---@return nothing
function SetIntroShotText(introText) end

---@param introModelPath string
---@return nothing
function SetIntroShotModel(introModelPath) end

---@param b boolean
---@return nothing
function EnableWorldFogBoundary(b) end

---@param modelName string
---@return nothing
function PlayModelCinematic(modelName) end

---@param movieName string
---@return nothing
function PlayCinematic(movieName) end

---@param key string
---@return nothing
function ForceUIKey(key) end

---@return nothing
function ForceUICancel() end

---@return nothing
function DisplayLoadDialog() end

---@param iconPath string
---@return nothing
function SetAltMinimapIcon(iconPath) end

---@param flag boolean
---@return nothing
function DisableRestartMission(flag) end

---@return texttag
function CreateTextTag() end

---@param t texttag
---@return nothing
function DestroyTextTag(t) end

---@param t texttag
---@param s string
---@param height real
---@return nothing
function SetTextTagText(t, s, height) end

---@param t texttag
---@param x real
---@param y real
---@param heightOffset real
---@return nothing
function SetTextTagPos(t, x, y, heightOffset) end

---@param t texttag
---@param whichUnit unit
---@param heightOffset real
---@return nothing
function SetTextTagPosUnit(t, whichUnit, heightOffset) end

---@param t texttag
---@param red integer
---@param green integer
---@param blue integer
---@param alpha integer
---@return nothing
function SetTextTagColor(t, red, green, blue, alpha) end

---@param t texttag
---@param xvel real
---@param yvel real
---@return nothing
function SetTextTagVelocity(t, xvel, yvel) end

---@param t texttag
---@param flag boolean
---@return nothing
function SetTextTagVisibility(t, flag) end

---@param t texttag
---@param flag boolean
---@return nothing
function SetTextTagSuspended(t, flag) end

---@param t texttag
---@param flag boolean
---@return nothing
function SetTextTagPermanent(t, flag) end

---@param t texttag
---@param age real
---@return nothing
function SetTextTagAge(t, age) end

---@param t texttag
---@param lifespan real
---@return nothing
function SetTextTagLifespan(t, lifespan) end

---@param t texttag
---@param fadepoint real
---@return nothing
function SetTextTagFadepoint(t, fadepoint) end

---@param reserved integer
---@return nothing
function SetReservedLocalHeroButtons(reserved) end

---@return integer
function GetAllyColorFilterState() end

---@param state integer
---@return nothing
function SetAllyColorFilterState(state) end

---@return boolean
function GetCreepCampFilterState() end

---@param state boolean
---@return nothing
function SetCreepCampFilterState(state) end

---@param enableAlly boolean
---@param enableCreep boolean
---@return nothing
function EnableMinimapFilterButtons(enableAlly, enableCreep) end

---@param state boolean
---@param ui boolean
---@return nothing
function EnableDragSelect(state, ui) end

---@param state boolean
---@param ui boolean
---@return nothing
function EnablePreSelect(state, ui) end

---@param state boolean
---@param ui boolean
---@return nothing
function EnableSelect(state, ui) end

---@param trackableModelPath string
---@param x real
---@param y real
---@param facing real
---@return trackable
function CreateTrackable(trackableModelPath, x, y, facing) end

---@return quest
function CreateQuest() end

---@param whichQuest quest
---@return nothing
function DestroyQuest(whichQuest) end

---@param whichQuest quest
---@param title string
---@return nothing
function QuestSetTitle(whichQuest, title) end

---@param whichQuest quest
---@param description string
---@return nothing
function QuestSetDescription(whichQuest, description) end

---@param whichQuest quest
---@param iconPath string
---@return nothing
function QuestSetIconPath(whichQuest, iconPath) end

---@param whichQuest quest
---@param required boolean
---@return nothing
function QuestSetRequired(whichQuest, required) end

---@param whichQuest quest
---@param completed boolean
---@return nothing
function QuestSetCompleted(whichQuest, completed) end

---@param whichQuest quest
---@param discovered boolean
---@return nothing
function QuestSetDiscovered(whichQuest, discovered) end

---@param whichQuest quest
---@param failed boolean
---@return nothing
function QuestSetFailed(whichQuest, failed) end

---@param whichQuest quest
---@param enabled boolean
---@return nothing
function QuestSetEnabled(whichQuest, enabled) end

---@param whichQuest quest
---@return boolean
function IsQuestRequired(whichQuest) end

---@param whichQuest quest
---@return boolean
function IsQuestCompleted(whichQuest) end

---@param whichQuest quest
---@return boolean
function IsQuestDiscovered(whichQuest) end

---@param whichQuest quest
---@return boolean
function IsQuestFailed(whichQuest) end

---@param whichQuest quest
---@return boolean
function IsQuestEnabled(whichQuest) end

---@param whichQuest quest
---@return questitem
function QuestCreateItem(whichQuest) end

---@param whichQuestItem questitem
---@param description string
---@return nothing
function QuestItemSetDescription(whichQuestItem, description) end

---@param whichQuestItem questitem
---@param completed boolean
---@return nothing
function QuestItemSetCompleted(whichQuestItem, completed) end

---@param whichQuestItem questitem
---@return boolean
function IsQuestItemCompleted(whichQuestItem) end

---@return defeatcondition
function CreateDefeatCondition() end

---@param whichCondition defeatcondition
---@return nothing
function DestroyDefeatCondition(whichCondition) end

---@param whichCondition defeatcondition
---@param description string
---@return nothing
function DefeatConditionSetDescription(whichCondition, description) end

---@return nothing
function FlashQuestDialogButton() end

---@return nothing
function ForceQuestDialogUpdate() end

---@param t timer
---@return timerdialog
function CreateTimerDialog(t) end

---@param whichDialog timerdialog
---@return nothing
function DestroyTimerDialog(whichDialog) end

---@param whichDialog timerdialog
---@param title string
---@return nothing
function TimerDialogSetTitle(whichDialog, title) end

---@param whichDialog timerdialog
---@param red integer
---@param green integer
---@param blue integer
---@param alpha integer
---@return nothing
function TimerDialogSetTitleColor(whichDialog, red, green, blue, alpha) end

---@param whichDialog timerdialog
---@param red integer
---@param green integer
---@param blue integer
---@param alpha integer
---@return nothing
function TimerDialogSetTimeColor(whichDialog, red, green, blue, alpha) end

---@param whichDialog timerdialog
---@param speedMultFactor real
---@return nothing
function TimerDialogSetSpeed(whichDialog, speedMultFactor) end

---@param whichDialog timerdialog
---@param display boolean
---@return nothing
function TimerDialogDisplay(whichDialog, display) end

---@param whichDialog timerdialog
---@return boolean
function IsTimerDialogDisplayed(whichDialog) end

---@param whichDialog timerdialog
---@param timeRemaining real
---@return nothing
function TimerDialogSetRealTimeRemaining(whichDialog, timeRemaining) end

---@return leaderboard
function CreateLeaderboard() end

---@param lb leaderboard
---@return nothing
function DestroyLeaderboard(lb) end

---@param lb leaderboard
---@param show boolean
---@return nothing
function LeaderboardDisplay(lb, show) end

---@param lb leaderboard
---@return boolean
function IsLeaderboardDisplayed(lb) end

---@param lb leaderboard
---@return integer
function LeaderboardGetItemCount(lb) end

---@param lb leaderboard
---@param count integer
---@return nothing
function LeaderboardSetSizeByItemCount(lb, count) end

---@param lb leaderboard
---@param label string
---@param value integer
---@param p player
---@return nothing
function LeaderboardAddItem(lb, label, value, p) end

---@param lb leaderboard
---@param index integer
---@return nothing
function LeaderboardRemoveItem(lb, index) end

---@param lb leaderboard
---@param p player
---@return nothing
function LeaderboardRemovePlayerItem(lb, p) end

---@param lb leaderboard
---@return nothing
function LeaderboardClear(lb) end

---@param lb leaderboard
---@param ascending boolean
---@return nothing
function LeaderboardSortItemsByValue(lb, ascending) end

---@param lb leaderboard
---@param ascending boolean
---@return nothing
function LeaderboardSortItemsByPlayer(lb, ascending) end

---@param lb leaderboard
---@param ascending boolean
---@return nothing
function LeaderboardSortItemsByLabel(lb, ascending) end

---@param lb leaderboard
---@param p player
---@return boolean
function LeaderboardHasPlayerItem(lb, p) end

---@param lb leaderboard
---@param p player
---@return integer
function LeaderboardGetPlayerIndex(lb, p) end

---@param lb leaderboard
---@param label string
---@return nothing
function LeaderboardSetLabel(lb, label) end

---@param lb leaderboard
---@return string
function LeaderboardGetLabelText(lb) end

---@param toPlayer player
---@param lb leaderboard
---@return nothing
function PlayerSetLeaderboard(toPlayer, lb) end

---@param toPlayer player
---@return leaderboard
function PlayerGetLeaderboard(toPlayer) end

---@param lb leaderboard
---@param red integer
---@param green integer
---@param blue integer
---@param alpha integer
---@return nothing
function LeaderboardSetLabelColor(lb, red, green, blue, alpha) end

---@param lb leaderboard
---@param red integer
---@param green integer
---@param blue integer
---@param alpha integer
---@return nothing
function LeaderboardSetValueColor(lb, red, green, blue, alpha) end

---@param lb leaderboard
---@param showLabel boolean
---@param showNames boolean
---@param showValues boolean
---@param showIcons boolean
---@return nothing
function LeaderboardSetStyle(lb, showLabel, showNames, showValues, showIcons) end

---@param lb leaderboard
---@param whichItem integer
---@param val integer
---@return nothing
function LeaderboardSetItemValue(lb, whichItem, val) end

---@param lb leaderboard
---@param whichItem integer
---@param val string
---@return nothing
function LeaderboardSetItemLabel(lb, whichItem, val) end

---@param lb leaderboard
---@param whichItem integer
---@param showLabel boolean
---@param showValue boolean
---@param showIcon boolean
---@return nothing
function LeaderboardSetItemStyle(lb, whichItem, showLabel, showValue, showIcon) end

---@param lb leaderboard
---@param whichItem integer
---@param red integer
---@param green integer
---@param blue integer
---@param alpha integer
---@return nothing
function LeaderboardSetItemLabelColor(lb, whichItem, red, green, blue, alpha) end

---@param lb leaderboard
---@param whichItem integer
---@param red integer
---@param green integer
---@param blue integer
---@param alpha integer
---@return nothing
function LeaderboardSetItemValueColor(lb, whichItem, red, green, blue, alpha) end

---@return multiboard
function CreateMultiboard() end

---@param lb multiboard
---@return nothing
function DestroyMultiboard(lb) end

---@param lb multiboard
---@param show boolean
---@return nothing
function MultiboardDisplay(lb, show) end

---@param lb multiboard
---@return boolean
function IsMultiboardDisplayed(lb) end

---@param lb multiboard
---@param minimize boolean
---@return nothing
function MultiboardMinimize(lb, minimize) end

---@param lb multiboard
---@return boolean
function IsMultiboardMinimized(lb) end

---@param lb multiboard
---@return nothing
function MultiboardClear(lb) end

---@param lb multiboard
---@param label string
---@return nothing
function MultiboardSetTitleText(lb, label) end

---@param lb multiboard
---@return string
function MultiboardGetTitleText(lb) end

---@param lb multiboard
---@param red integer
---@param green integer
---@param blue integer
---@param alpha integer
---@return nothing
function MultiboardSetTitleTextColor(lb, red, green, blue, alpha) end

---@param lb multiboard
---@return integer
function MultiboardGetRowCount(lb) end

---@param lb multiboard
---@return integer
function MultiboardGetColumnCount(lb) end

---@param lb multiboard
---@param count integer
---@return nothing
function MultiboardSetColumnCount(lb, count) end

---@param lb multiboard
---@param count integer
---@return nothing
function MultiboardSetRowCount(lb, count) end

---@param lb multiboard
---@param showValues boolean
---@param showIcons boolean
---@return nothing
function MultiboardSetItemsStyle(lb, showValues, showIcons) end

---@param lb multiboard
---@param value string
---@return nothing
function MultiboardSetItemsValue(lb, value) end

---@param lb multiboard
---@param red integer
---@param green integer
---@param blue integer
---@param alpha integer
---@return nothing
function MultiboardSetItemsValueColor(lb, red, green, blue, alpha) end

---@param lb multiboard
---@param width real
---@return nothing
function MultiboardSetItemsWidth(lb, width) end

---@param lb multiboard
---@param iconPath string
---@return nothing
function MultiboardSetItemsIcon(lb, iconPath) end

---@param lb multiboard
---@param row integer
---@param column integer
---@return multiboarditem
function MultiboardGetItem(lb, row, column) end

---@param mbi multiboarditem
---@return nothing
function MultiboardReleaseItem(mbi) end

---@param mbi multiboarditem
---@param showValue boolean
---@param showIcon boolean
---@return nothing
function MultiboardSetItemStyle(mbi, showValue, showIcon) end

---@param mbi multiboarditem
---@param val string
---@return nothing
function MultiboardSetItemValue(mbi, val) end

---@param mbi multiboarditem
---@param red integer
---@param green integer
---@param blue integer
---@param alpha integer
---@return nothing
function MultiboardSetItemValueColor(mbi, red, green, blue, alpha) end

---@param mbi multiboarditem
---@param width real
---@return nothing
function MultiboardSetItemWidth(mbi, width) end

---@param mbi multiboarditem
---@param iconFileName string
---@return nothing
function MultiboardSetItemIcon(mbi, iconFileName) end

---@param flag boolean
---@return nothing
function MultiboardSuppressDisplay(flag) end

---@param x real
---@param y real
---@return nothing
function SetCameraPosition(x, y) end

---@param x real
---@param y real
---@return nothing
function SetCameraQuickPosition(x, y) end

---@param x1 real
---@param y1 real
---@param x2 real
---@param y2 real
---@param x3 real
---@param y3 real
---@param x4 real
---@param y4 real
---@return nothing
function SetCameraBounds(x1, y1, x2, y2, x3, y3, x4, y4) end

---@return nothing
function StopCamera() end

---@param duration real
---@return nothing
function ResetToGameCamera(duration) end

---@param x real
---@param y real
---@return nothing
function PanCameraTo(x, y) end

---@param x real
---@param y real
---@param duration real
---@return nothing
function PanCameraToTimed(x, y, duration) end

---@param x real
---@param y real
---@param zOffsetDest real
---@return nothing
function PanCameraToWithZ(x, y, zOffsetDest) end

---@param x real
---@param y real
---@param zOffsetDest real
---@param duration real
---@return nothing
function PanCameraToTimedWithZ(x, y, zOffsetDest, duration) end

---@param cameraModelFile string
---@return nothing
function SetCinematicCamera(cameraModelFile) end

---@param x real
---@param y real
---@param radiansToSweep real
---@param duration real
---@return nothing
function SetCameraRotateMode(x, y, radiansToSweep, duration) end

---@param whichField camerafield
---@param value real
---@param duration real
---@return nothing
function SetCameraField(whichField, value, duration) end

---@param whichField camerafield
---@param offset real
---@param duration real
---@return nothing
function AdjustCameraField(whichField, offset, duration) end

---@param whichUnit unit
---@param xoffset real
---@param yoffset real
---@param inheritOrientation boolean
---@return nothing
function SetCameraTargetController(whichUnit, xoffset, yoffset, inheritOrientation) end

---@param whichUnit unit
---@param xoffset real
---@param yoffset real
---@return nothing
function SetCameraOrientController(whichUnit, xoffset, yoffset) end

---@return camerasetup
function CreateCameraSetup() end

---@param whichSetup camerasetup
---@param whichField camerafield
---@param value real
---@param duration real
---@return nothing
function CameraSetupSetField(whichSetup, whichField, value, duration) end

---@param whichSetup camerasetup
---@param whichField camerafield
---@return real
function CameraSetupGetField(whichSetup, whichField) end

---@param whichSetup camerasetup
---@param x real
---@param y real
---@param duration real
---@return nothing
function CameraSetupSetDestPosition(whichSetup, x, y, duration) end

---@param whichSetup camerasetup
---@return location
function CameraSetupGetDestPositionLoc(whichSetup) end

---@param whichSetup camerasetup
---@return real
function CameraSetupGetDestPositionX(whichSetup) end

---@param whichSetup camerasetup
---@return real
function CameraSetupGetDestPositionY(whichSetup) end

---@param whichSetup camerasetup
---@param doPan boolean
---@param panTimed boolean
---@return nothing
function CameraSetupApply(whichSetup, doPan, panTimed) end

---@param whichSetup camerasetup
---@param zDestOffset real
---@return nothing
function CameraSetupApplyWithZ(whichSetup, zDestOffset) end

---@param whichSetup camerasetup
---@param doPan boolean
---@param forceDuration real
---@return nothing
function CameraSetupApplyForceDuration(whichSetup, doPan, forceDuration) end

---@param whichSetup camerasetup
---@param zDestOffset real
---@param forceDuration real
---@return nothing
function CameraSetupApplyForceDurationWithZ(whichSetup, zDestOffset, forceDuration) end

---@param whichSetup camerasetup
---@param label string
---@return nothing
function BlzCameraSetupSetLabel(whichSetup, label) end

---@param whichSetup camerasetup
---@return string
function BlzCameraSetupGetLabel(whichSetup) end

---@param mag real
---@param velocity real
---@return nothing
function CameraSetTargetNoise(mag, velocity) end

---@param mag real
---@param velocity real
---@return nothing
function CameraSetSourceNoise(mag, velocity) end

---@param mag real
---@param velocity real
---@param vertOnly boolean
---@return nothing
function CameraSetTargetNoiseEx(mag, velocity, vertOnly) end

---@param mag real
---@param velocity real
---@param vertOnly boolean
---@return nothing
function CameraSetSourceNoiseEx(mag, velocity, vertOnly) end

---@param factor real
---@return nothing
function CameraSetSmoothingFactor(factor) end

---@param distance real
---@return nothing
function CameraSetFocalDistance(distance) end

---@param scale real
---@return nothing
function CameraSetDepthOfFieldScale(scale) end

---@param filename string
---@return nothing
function SetCineFilterTexture(filename) end

---@param whichMode blendmode
---@return nothing
function SetCineFilterBlendMode(whichMode) end

---@param whichFlags texmapflags
---@return nothing
function SetCineFilterTexMapFlags(whichFlags) end

---@param minu real
---@param minv real
---@param maxu real
---@param maxv real
---@return nothing
function SetCineFilterStartUV(minu, minv, maxu, maxv) end

---@param minu real
---@param minv real
---@param maxu real
---@param maxv real
---@return nothing
function SetCineFilterEndUV(minu, minv, maxu, maxv) end

---@param red integer
---@param green integer
---@param blue integer
---@param alpha integer
---@return nothing
function SetCineFilterStartColor(red, green, blue, alpha) end

---@param red integer
---@param green integer
---@param blue integer
---@param alpha integer
---@return nothing
function SetCineFilterEndColor(red, green, blue, alpha) end

---@param duration real
---@return nothing
function SetCineFilterDuration(duration) end

---@param flag boolean
---@return nothing
function DisplayCineFilter(flag) end

---@return boolean
function IsCineFilterDisplayed() end

---@param portraitUnitId integer
---@param color playercolor
---@param speakerTitle string
---@param text string
---@param sceneDuration real
---@param voiceoverDuration real
---@return nothing
function SetCinematicScene(portraitUnitId, color, speakerTitle, text, sceneDuration, voiceoverDuration) end

---@return nothing
function EndCinematicScene() end

---@param flag boolean
---@return nothing
function ForceCinematicSubtitles(flag) end

---@param cinematicAudio boolean
---@return nothing
function SetCinematicAudio(cinematicAudio) end

---@param whichMargin integer
---@return real
function GetCameraMargin(whichMargin) end

---@return real
function GetCameraBoundMinX() end

---@return real
function GetCameraBoundMinY() end

---@return real
function GetCameraBoundMaxX() end

---@return real
function GetCameraBoundMaxY() end

---@param whichField camerafield
---@return real
function GetCameraField(whichField) end

---@return real
function GetCameraTargetPositionX() end

---@return real
function GetCameraTargetPositionY() end

---@return real
function GetCameraTargetPositionZ() end

---@return location
function GetCameraTargetPositionLoc() end

---@return real
function GetCameraEyePositionX() end

---@return real
function GetCameraEyePositionY() end

---@return real
function GetCameraEyePositionZ() end

---@return location
function GetCameraEyePositionLoc() end

---@param environmentName string
---@return nothing
function NewSoundEnvironment(environmentName) end

---@param fileName string
---@param looping boolean
---@param is3D boolean
---@param stopwhenoutofrange boolean
---@param fadeInRate integer
---@param fadeOutRate integer
---@param eaxSetting string
---@return sound
function CreateSound(fileName, looping, is3D, stopwhenoutofrange, fadeInRate, fadeOutRate, eaxSetting) end

---@param fileName string
---@param looping boolean
---@param is3D boolean
---@param stopwhenoutofrange boolean
---@param fadeInRate integer
---@param fadeOutRate integer
---@param SLKEntryName string
---@return sound
function CreateSoundFilenameWithLabel(fileName, looping, is3D, stopwhenoutofrange, fadeInRate, fadeOutRate, SLKEntryName) end

---@param soundLabel string
---@param looping boolean
---@param is3D boolean
---@param stopwhenoutofrange boolean
---@param fadeInRate integer
---@param fadeOutRate integer
---@return sound
function CreateSoundFromLabel(soundLabel, looping, is3D, stopwhenoutofrange, fadeInRate, fadeOutRate) end

---@param soundLabel string
---@param fadeInRate integer
---@param fadeOutRate integer
---@return sound
function CreateMIDISound(soundLabel, fadeInRate, fadeOutRate) end

---@param soundHandle sound
---@param soundLabel string
---@return nothing
function SetSoundParamsFromLabel(soundHandle, soundLabel) end

---@param soundHandle sound
---@param cutoff real
---@return nothing
function SetSoundDistanceCutoff(soundHandle, cutoff) end

---@param soundHandle sound
---@param channel integer
---@return nothing
function SetSoundChannel(soundHandle, channel) end

---@param soundHandle sound
---@param volume integer
---@return nothing
function SetSoundVolume(soundHandle, volume) end

---@param soundHandle sound
---@param pitch real
---@return nothing
function SetSoundPitch(soundHandle, pitch) end

---@param soundHandle sound
---@param millisecs integer
---@return nothing
function SetSoundPlayPosition(soundHandle, millisecs) end

---@param soundHandle sound
---@param minDist real
---@param maxDist real
---@return nothing
function SetSoundDistances(soundHandle, minDist, maxDist) end

---@param soundHandle sound
---@param inside real
---@param outside real
---@param outsideVolume integer
---@return nothing
function SetSoundConeAngles(soundHandle, inside, outside, outsideVolume) end

---@param soundHandle sound
---@param x real
---@param y real
---@param z real
---@return nothing
function SetSoundConeOrientation(soundHandle, x, y, z) end

---@param soundHandle sound
---@param x real
---@param y real
---@param z real
---@return nothing
function SetSoundPosition(soundHandle, x, y, z) end

---@param soundHandle sound
---@param x real
---@param y real
---@param z real
---@return nothing
function SetSoundVelocity(soundHandle, x, y, z) end

---@param soundHandle sound
---@param whichUnit unit
---@return nothing
function AttachSoundToUnit(soundHandle, whichUnit) end

---@param soundHandle sound
---@return nothing
function StartSound(soundHandle) end

---@param soundHandle sound
---@param fadeIn boolean
---@return nothing
function StartSoundEx(soundHandle, fadeIn) end

---@param soundHandle sound
---@param killWhenDone boolean
---@param fadeOut boolean
---@return nothing
function StopSound(soundHandle, killWhenDone, fadeOut) end

---@param soundHandle sound
---@return nothing
function KillSoundWhenDone(soundHandle) end

---@param musicName string
---@param random boolean
---@param index integer
---@return nothing
function SetMapMusic(musicName, random, index) end

---@return nothing
function ClearMapMusic() end

---@param musicName string
---@return nothing
function PlayMusic(musicName) end

---@param musicName string
---@param frommsecs integer
---@param fadeinmsecs integer
---@return nothing
function PlayMusicEx(musicName, frommsecs, fadeinmsecs) end

---@param fadeOut boolean
---@return nothing
function StopMusic(fadeOut) end

---@return nothing
function ResumeMusic() end

---@param musicFileName string
---@return nothing
function PlayThematicMusic(musicFileName) end

---@param musicFileName string
---@param frommsecs integer
---@return nothing
function PlayThematicMusicEx(musicFileName, frommsecs) end

---@return nothing
function EndThematicMusic() end

---@param volume integer
---@return nothing
function SetMusicVolume(volume) end

---@param millisecs integer
---@return nothing
function SetMusicPlayPosition(millisecs) end

---@param volume integer
---@return nothing
function SetThematicMusicVolume(volume) end

---@param millisecs integer
---@return nothing
function SetThematicMusicPlayPosition(millisecs) end

---@param soundHandle sound
---@param duration integer
---@return nothing
function SetSoundDuration(soundHandle, duration) end

---@param soundHandle sound
---@return integer
function GetSoundDuration(soundHandle) end

---@param musicFileName string
---@return integer
function GetSoundFileDuration(musicFileName) end

---@param vgroup volumegroup
---@param scale real
---@return nothing
function VolumeGroupSetVolume(vgroup, scale) end

---@return nothing
function VolumeGroupReset() end

---@param soundHandle sound
---@return boolean
function GetSoundIsPlaying(soundHandle) end

---@param soundHandle sound
---@return boolean
function GetSoundIsLoading(soundHandle) end

---@param soundHandle sound
---@param byPosition boolean
---@param rectwidth real
---@param rectheight real
---@return nothing
function RegisterStackedSound(soundHandle, byPosition, rectwidth, rectheight) end

---@param soundHandle sound
---@param byPosition boolean
---@param rectwidth real
---@param rectheight real
---@return nothing
function UnregisterStackedSound(soundHandle, byPosition, rectwidth, rectheight) end

---@param soundHandle sound
---@param animationLabel string
---@return boolean
function SetSoundFacialAnimationLabel(soundHandle, animationLabel) end

---@param soundHandle sound
---@param groupLabel string
---@return boolean
function SetSoundFacialAnimationGroupLabel(soundHandle, groupLabel) end

---@param soundHandle sound
---@param animationSetFilepath string
---@return boolean
function SetSoundFacialAnimationSetFilepath(soundHandle, animationSetFilepath) end

---@param soundHandle sound
---@param speakerName string
---@return boolean
function SetDialogueSpeakerNameKey(soundHandle, speakerName) end

---@param soundHandle sound
---@return string
function GetDialogueSpeakerNameKey(soundHandle) end

---@param soundHandle sound
---@param dialogueText string
---@return boolean
function SetDialogueTextKey(soundHandle, dialogueText) end

---@param soundHandle sound
---@return string
function GetDialogueTextKey(soundHandle) end

---@param where rect
---@param effectID integer
---@return weathereffect
function AddWeatherEffect(where, effectID) end

---@param whichEffect weathereffect
---@return nothing
function RemoveWeatherEffect(whichEffect) end

---@param whichEffect weathereffect
---@param enable boolean
---@return nothing
function EnableWeatherEffect(whichEffect, enable) end

---@param x real
---@param y real
---@param radius real
---@param depth real
---@param duration integer
---@param permanent boolean
---@return terraindeformation
function TerrainDeformCrater(x, y, radius, depth, duration, permanent) end

---@param x real
---@param y real
---@param radius real
---@param depth real
---@param duration integer
---@param count integer
---@param spaceWaves real
---@param timeWaves real
---@param radiusStartPct real
---@param limitNeg boolean
---@return terraindeformation
function TerrainDeformRipple(x, y, radius, depth, duration, count, spaceWaves, timeWaves, radiusStartPct, limitNeg) end

---@param x real
---@param y real
---@param dirX real
---@param dirY real
---@param distance real
---@param speed real
---@param radius real
---@param depth real
---@param trailTime integer
---@param count integer
---@return terraindeformation
function TerrainDeformWave(x, y, dirX, dirY, distance, speed, radius, depth, trailTime, count) end

---@param x real
---@param y real
---@param radius real
---@param minDelta real
---@param maxDelta real
---@param duration integer
---@param updateInterval integer
---@return terraindeformation
function TerrainDeformRandom(x, y, radius, minDelta, maxDelta, duration, updateInterval) end

---@param deformation terraindeformation
---@param duration integer
---@return nothing
function TerrainDeformStop(deformation, duration) end

---@return nothing
function TerrainDeformStopAll() end

---@param modelName string
---@param x real
---@param y real
---@return effect
function AddSpecialEffect(modelName, x, y) end

---@param modelName string
---@param where location
---@return effect
function AddSpecialEffectLoc(modelName, where) end

---@param modelName string
---@param targetWidget widget
---@param attachPointName string
---@return effect
function AddSpecialEffectTarget(modelName, targetWidget, attachPointName) end

---@param whichEffect effect
---@return nothing
function DestroyEffect(whichEffect) end

---@param abilityString string
---@param t effecttype
---@param x real
---@param y real
---@return effect
function AddSpellEffect(abilityString, t, x, y) end

---@param abilityString string
---@param t effecttype
---@param where location
---@return effect
function AddSpellEffectLoc(abilityString, t, where) end

---@param abilityId integer
---@param t effecttype
---@param x real
---@param y real
---@return effect
function AddSpellEffectById(abilityId, t, x, y) end

---@param abilityId integer
---@param t effecttype
---@param where location
---@return effect
function AddSpellEffectByIdLoc(abilityId, t, where) end

---@param modelName string
---@param t effecttype
---@param targetWidget widget
---@param attachPoint string
---@return effect
function AddSpellEffectTarget(modelName, t, targetWidget, attachPoint) end

---@param abilityId integer
---@param t effecttype
---@param targetWidget widget
---@param attachPoint string
---@return effect
function AddSpellEffectTargetById(abilityId, t, targetWidget, attachPoint) end

---@param codeName string
---@param checkVisibility boolean
---@param x1 real
---@param y1 real
---@param x2 real
---@param y2 real
---@return lightning
function AddLightning(codeName, checkVisibility, x1, y1, x2, y2) end

---@param codeName string
---@param checkVisibility boolean
---@param x1 real
---@param y1 real
---@param z1 real
---@param x2 real
---@param y2 real
---@param z2 real
---@return lightning
function AddLightningEx(codeName, checkVisibility, x1, y1, z1, x2, y2, z2) end

---@param whichBolt lightning
---@return boolean
function DestroyLightning(whichBolt) end

---@param whichBolt lightning
---@param checkVisibility boolean
---@param x1 real
---@param y1 real
---@param x2 real
---@param y2 real
---@return boolean
function MoveLightning(whichBolt, checkVisibility, x1, y1, x2, y2) end

---@param whichBolt lightning
---@param checkVisibility boolean
---@param x1 real
---@param y1 real
---@param z1 real
---@param x2 real
---@param y2 real
---@param z2 real
---@return boolean
function MoveLightningEx(whichBolt, checkVisibility, x1, y1, z1, x2, y2, z2) end

---@param whichBolt lightning
---@return real
function GetLightningColorA(whichBolt) end

---@param whichBolt lightning
---@return real
function GetLightningColorR(whichBolt) end

---@param whichBolt lightning
---@return real
function GetLightningColorG(whichBolt) end

---@param whichBolt lightning
---@return real
function GetLightningColorB(whichBolt) end

---@param whichBolt lightning
---@param r real
---@param g real
---@param b real
---@param a real
---@return boolean
function SetLightningColor(whichBolt, r, g, b, a) end

---@param abilityString string
---@param t effecttype
---@param index integer
---@return string
function GetAbilityEffect(abilityString, t, index) end

---@param abilityId integer
---@param t effecttype
---@param index integer
---@return string
function GetAbilityEffectById(abilityId, t, index) end

---@param abilityString string
---@param t soundtype
---@return string
function GetAbilitySound(abilityString, t) end

---@param abilityId integer
---@param t soundtype
---@return string
function GetAbilitySoundById(abilityId, t) end

---@param x real
---@param y real
---@return integer
function GetTerrainCliffLevel(x, y) end

---@param red integer
---@param green integer
---@param blue integer
---@param alpha integer
---@return nothing
function SetWaterBaseColor(red, green, blue, alpha) end

---@param val boolean
---@return nothing
function SetWaterDeforms(val) end

---@param x real
---@param y real
---@return integer
function GetTerrainType(x, y) end

---@param x real
---@param y real
---@return integer
function GetTerrainVariance(x, y) end

---@param x real
---@param y real
---@param terrainType integer
---@param variation integer
---@param area integer
---@param shape integer
---@return nothing
function SetTerrainType(x, y, terrainType, variation, area, shape) end

---@param x real
---@param y real
---@param t pathingtype
---@return boolean
function IsTerrainPathable(x, y, t) end

---@param x real
---@param y real
---@param t pathingtype
---@param flag boolean
---@return nothing
function SetTerrainPathable(x, y, t, flag) end

---@param file string
---@param sizeX real
---@param sizeY real
---@param sizeZ real
---@param posX real
---@param posY real
---@param posZ real
---@param originX real
---@param originY real
---@param originZ real
---@param imageType integer
---@return image
function CreateImage(file, sizeX, sizeY, sizeZ, posX, posY, posZ, originX, originY, originZ, imageType) end

---@param whichImage image
---@return nothing
function DestroyImage(whichImage) end

---@param whichImage image
---@param flag boolean
---@return nothing
function ShowImage(whichImage, flag) end

---@param whichImage image
---@param flag boolean
---@param height real
---@return nothing
function SetImageConstantHeight(whichImage, flag, height) end

---@param whichImage image
---@param x real
---@param y real
---@param z real
---@return nothing
function SetImagePosition(whichImage, x, y, z) end

---@param whichImage image
---@param red integer
---@param green integer
---@param blue integer
---@param alpha integer
---@return nothing
function SetImageColor(whichImage, red, green, blue, alpha) end

---@param whichImage image
---@param flag boolean
---@return nothing
function SetImageRender(whichImage, flag) end

---@param whichImage image
---@param flag boolean
---@return nothing
function SetImageRenderAlways(whichImage, flag) end

---@param whichImage image
---@param flag boolean
---@param useWaterAlpha boolean
---@return nothing
function SetImageAboveWater(whichImage, flag, useWaterAlpha) end

---@param whichImage image
---@param imageType integer
---@return nothing
function SetImageType(whichImage, imageType) end

---@param x real
---@param y real
---@param name string
---@param red integer
---@param green integer
---@param blue integer
---@param alpha integer
---@param forcePaused boolean
---@param noBirthTime boolean
---@return ubersplat
function CreateUbersplat(x, y, name, red, green, blue, alpha, forcePaused, noBirthTime) end

---@param whichSplat ubersplat
---@return nothing
function DestroyUbersplat(whichSplat) end

---@param whichSplat ubersplat
---@return nothing
function ResetUbersplat(whichSplat) end

---@param whichSplat ubersplat
---@return nothing
function FinishUbersplat(whichSplat) end

---@param whichSplat ubersplat
---@param flag boolean
---@return nothing
function ShowUbersplat(whichSplat, flag) end

---@param whichSplat ubersplat
---@param flag boolean
---@return nothing
function SetUbersplatRender(whichSplat, flag) end

---@param whichSplat ubersplat
---@param flag boolean
---@return nothing
function SetUbersplatRenderAlways(whichSplat, flag) end

---@param whichPlayer player
---@param x real
---@param y real
---@param radius real
---@param addBlight boolean
---@return nothing
function SetBlight(whichPlayer, x, y, radius, addBlight) end

---@param whichPlayer player
---@param r rect
---@param addBlight boolean
---@return nothing
function SetBlightRect(whichPlayer, r, addBlight) end

---@param whichPlayer player
---@param x real
---@param y real
---@param addBlight boolean
---@return nothing
function SetBlightPoint(whichPlayer, x, y, addBlight) end

---@param whichPlayer player
---@param whichLocation location
---@param radius real
---@param addBlight boolean
---@return nothing
function SetBlightLoc(whichPlayer, whichLocation, radius, addBlight) end

---@param id player
---@param x real
---@param y real
---@param face real
---@return unit
function CreateBlightedGoldmine(id, x, y, face) end

---@param x real
---@param y real
---@return boolean
function IsPointBlighted(x, y) end

---@param x real
---@param y real
---@param radius real
---@param doodadID integer
---@param nearestOnly boolean
---@param animName string
---@param animRandom boolean
---@return nothing
function SetDoodadAnimation(x, y, radius, doodadID, nearestOnly, animName, animRandom) end

---@param r rect
---@param doodadID integer
---@param animName string
---@param animRandom boolean
---@return nothing
function SetDoodadAnimationRect(r, doodadID, animName, animRandom) end

---@param num player
---@param script string
---@return nothing
function StartMeleeAI(num, script) end

---@param num player
---@param script string
---@return nothing
function StartCampaignAI(num, script) end

---@param num player
---@param command integer
---@param data integer
---@return nothing
function CommandAI(num, command, data) end

---@param p player
---@param pause boolean
---@return nothing
function PauseCompAI(p, pause) end

---@param num player
---@return aidifficulty
function GetAIDifficulty(num) end

---@param hUnit unit
---@return nothing
function RemoveGuardPosition(hUnit) end

---@param hUnit unit
---@return nothing
function RecycleGuardPosition(hUnit) end

---@param num player
---@return nothing
function RemoveAllGuardPositions(num) end

---@param cheatStr string
---@return nothing
function Cheat(cheatStr) end

---@return boolean
function IsNoVictoryCheat() end

---@return boolean
function IsNoDefeatCheat() end

---@param filename string
---@return nothing
function Preload(filename) end

---@param timeout real
---@return nothing
function PreloadEnd(timeout) end

---@return nothing
function PreloadStart() end

---@return nothing
function PreloadRefresh() end

---@return nothing
function PreloadEndEx() end

---@return nothing
function PreloadGenClear() end

---@return nothing
function PreloadGenStart() end

---@param filename string
---@return nothing
function PreloadGenEnd(filename) end

---@param filename string
---@return nothing
function Preloader(filename) end

---@param enable boolean
---@return nothing
function BlzHideCinematicPanels(enable) end

---@param testType string
---@return nothing
function AutomationSetTestType(testType) end

---@param testName string
---@return nothing
function AutomationTestStart(testName) end

---@return nothing
function AutomationTestEnd() end

---@return nothing
function AutomationTestingFinished() end

---@return real
function BlzGetTriggerPlayerMouseX() end

---@return real
function BlzGetTriggerPlayerMouseY() end

---@return location
function BlzGetTriggerPlayerMousePosition() end

---@return mousebuttontype
function BlzGetTriggerPlayerMouseButton() end

---@param abilCode integer
---@param tooltip string
---@param level integer
---@return nothing
function BlzSetAbilityTooltip(abilCode, tooltip, level) end

---@param abilCode integer
---@param tooltip string
---@param level integer
---@return nothing
function BlzSetAbilityActivatedTooltip(abilCode, tooltip, level) end

---@param abilCode integer
---@param extendedTooltip string
---@param level integer
---@return nothing
function BlzSetAbilityExtendedTooltip(abilCode, extendedTooltip, level) end

---@param abilCode integer
---@param extendedTooltip string
---@param level integer
---@return nothing
function BlzSetAbilityActivatedExtendedTooltip(abilCode, extendedTooltip, level) end

---@param abilCode integer
---@param researchTooltip string
---@param level integer
---@return nothing
function BlzSetAbilityResearchTooltip(abilCode, researchTooltip, level) end

---@param abilCode integer
---@param researchExtendedTooltip string
---@param level integer
---@return nothing
function BlzSetAbilityResearchExtendedTooltip(abilCode, researchExtendedTooltip, level) end

---@param abilCode integer
---@param level integer
---@return string
function BlzGetAbilityTooltip(abilCode, level) end

---@param abilCode integer
---@param level integer
---@return string
function BlzGetAbilityActivatedTooltip(abilCode, level) end

---@param abilCode integer
---@param level integer
---@return string
function BlzGetAbilityExtendedTooltip(abilCode, level) end

---@param abilCode integer
---@param level integer
---@return string
function BlzGetAbilityActivatedExtendedTooltip(abilCode, level) end

---@param abilCode integer
---@param level integer
---@return string
function BlzGetAbilityResearchTooltip(abilCode, level) end

---@param abilCode integer
---@param level integer
---@return string
function BlzGetAbilityResearchExtendedTooltip(abilCode, level) end

---@param abilCode integer
---@param iconPath string
---@return nothing
function BlzSetAbilityIcon(abilCode, iconPath) end

---@param abilCode integer
---@return string
function BlzGetAbilityIcon(abilCode) end

---@param abilCode integer
---@param iconPath string
---@return nothing
function BlzSetAbilityActivatedIcon(abilCode, iconPath) end

---@param abilCode integer
---@return string
function BlzGetAbilityActivatedIcon(abilCode) end

---@param abilCode integer
---@return integer
function BlzGetAbilityPosX(abilCode) end

---@param abilCode integer
---@return integer
function BlzGetAbilityPosY(abilCode) end

---@param abilCode integer
---@param x integer
---@return nothing
function BlzSetAbilityPosX(abilCode, x) end

---@param abilCode integer
---@param y integer
---@return nothing
function BlzSetAbilityPosY(abilCode, y) end

---@param abilCode integer
---@return integer
function BlzGetAbilityActivatedPosX(abilCode) end

---@param abilCode integer
---@return integer
function BlzGetAbilityActivatedPosY(abilCode) end

---@param abilCode integer
---@param x integer
---@return nothing
function BlzSetAbilityActivatedPosX(abilCode, x) end

---@param abilCode integer
---@param y integer
---@return nothing
function BlzSetAbilityActivatedPosY(abilCode, y) end

---@param whichUnit unit
---@return integer
function BlzGetUnitMaxHP(whichUnit) end

---@param whichUnit unit
---@param hp integer
---@return nothing
function BlzSetUnitMaxHP(whichUnit, hp) end

---@param whichUnit unit
---@return integer
function BlzGetUnitMaxMana(whichUnit) end

---@param whichUnit unit
---@param mana integer
---@return nothing
function BlzSetUnitMaxMana(whichUnit, mana) end

---@param whichItem item
---@param name string
---@return nothing
function BlzSetItemName(whichItem, name) end

---@param whichItem item
---@param description string
---@return nothing
function BlzSetItemDescription(whichItem, description) end

---@param whichItem item
---@return string
function BlzGetItemDescription(whichItem) end

---@param whichItem item
---@param tooltip string
---@return nothing
function BlzSetItemTooltip(whichItem, tooltip) end

---@param whichItem item
---@return string
function BlzGetItemTooltip(whichItem) end

---@param whichItem item
---@param extendedTooltip string
---@return nothing
function BlzSetItemExtendedTooltip(whichItem, extendedTooltip) end

---@param whichItem item
---@return string
function BlzGetItemExtendedTooltip(whichItem) end

---@param whichItem item
---@param iconPath string
---@return nothing
function BlzSetItemIconPath(whichItem, iconPath) end

---@param whichItem item
---@return string
function BlzGetItemIconPath(whichItem) end

---@param whichUnit unit
---@param name string
---@return nothing
function BlzSetUnitName(whichUnit, name) end

---@param whichUnit unit
---@param heroProperName string
---@return nothing
function BlzSetHeroProperName(whichUnit, heroProperName) end

---@param whichUnit unit
---@param weaponIndex integer
---@return integer
function BlzGetUnitBaseDamage(whichUnit, weaponIndex) end

---@param whichUnit unit
---@param baseDamage integer
---@param weaponIndex integer
---@return nothing
function BlzSetUnitBaseDamage(whichUnit, baseDamage, weaponIndex) end

---@param whichUnit unit
---@param weaponIndex integer
---@return integer
function BlzGetUnitDiceNumber(whichUnit, weaponIndex) end

---@param whichUnit unit
---@param diceNumber integer
---@param weaponIndex integer
---@return nothing
function BlzSetUnitDiceNumber(whichUnit, diceNumber, weaponIndex) end

---@param whichUnit unit
---@param weaponIndex integer
---@return integer
function BlzGetUnitDiceSides(whichUnit, weaponIndex) end

---@param whichUnit unit
---@param diceSides integer
---@param weaponIndex integer
---@return nothing
function BlzSetUnitDiceSides(whichUnit, diceSides, weaponIndex) end

---@param whichUnit unit
---@param weaponIndex integer
---@return real
function BlzGetUnitAttackCooldown(whichUnit, weaponIndex) end

---@param whichUnit unit
---@param cooldown real
---@param weaponIndex integer
---@return nothing
function BlzSetUnitAttackCooldown(whichUnit, cooldown, weaponIndex) end

---@param whichEffect effect
---@param whichPlayer player
---@return nothing
function BlzSetSpecialEffectColorByPlayer(whichEffect, whichPlayer) end

---@param whichEffect effect
---@param r integer
---@param g integer
---@param b integer
---@return nothing
function BlzSetSpecialEffectColor(whichEffect, r, g, b) end

---@param whichEffect effect
---@param alpha integer
---@return nothing
function BlzSetSpecialEffectAlpha(whichEffect, alpha) end

---@param whichEffect effect
---@param scale real
---@return nothing
function BlzSetSpecialEffectScale(whichEffect, scale) end

---@param whichEffect effect
---@param x real
---@param y real
---@param z real
---@return nothing
function BlzSetSpecialEffectPosition(whichEffect, x, y, z) end

---@param whichEffect effect
---@param height real
---@return nothing
function BlzSetSpecialEffectHeight(whichEffect, height) end

---@param whichEffect effect
---@param timeScale real
---@return nothing
function BlzSetSpecialEffectTimeScale(whichEffect, timeScale) end

---@param whichEffect effect
---@param time real
---@return nothing
function BlzSetSpecialEffectTime(whichEffect, time) end

---@param whichEffect effect
---@param yaw real
---@param pitch real
---@param roll real
---@return nothing
function BlzSetSpecialEffectOrientation(whichEffect, yaw, pitch, roll) end

---@param whichEffect effect
---@param yaw real
---@return nothing
function BlzSetSpecialEffectYaw(whichEffect, yaw) end

---@param whichEffect effect
---@param pitch real
---@return nothing
function BlzSetSpecialEffectPitch(whichEffect, pitch) end

---@param whichEffect effect
---@param roll real
---@return nothing
function BlzSetSpecialEffectRoll(whichEffect, roll) end

---@param whichEffect effect
---@param x real
---@return nothing
function BlzSetSpecialEffectX(whichEffect, x) end

---@param whichEffect effect
---@param y real
---@return nothing
function BlzSetSpecialEffectY(whichEffect, y) end

---@param whichEffect effect
---@param z real
---@return nothing
function BlzSetSpecialEffectZ(whichEffect, z) end

---@param whichEffect effect
---@param loc location
---@return nothing
function BlzSetSpecialEffectPositionLoc(whichEffect, loc) end

---@param whichEffect effect
---@return real
function BlzGetLocalSpecialEffectX(whichEffect) end

---@param whichEffect effect
---@return real
function BlzGetLocalSpecialEffectY(whichEffect) end

---@param whichEffect effect
---@return real
function BlzGetLocalSpecialEffectZ(whichEffect) end

---@param whichEffect effect
---@return nothing
function BlzSpecialEffectClearSubAnimations(whichEffect) end

---@param whichEffect effect
---@param whichSubAnim subanimtype
---@return nothing
function BlzSpecialEffectRemoveSubAnimation(whichEffect, whichSubAnim) end

---@param whichEffect effect
---@param whichSubAnim subanimtype
---@return nothing
function BlzSpecialEffectAddSubAnimation(whichEffect, whichSubAnim) end

---@param whichEffect effect
---@param whichAnim animtype
---@return nothing
function BlzPlaySpecialEffect(whichEffect, whichAnim) end

---@param whichEffect effect
---@param whichAnim animtype
---@param timeScale real
---@return nothing
function BlzPlaySpecialEffectWithTimeScale(whichEffect, whichAnim, timeScale) end

---@param whichAnim animtype
---@return string
function BlzGetAnimName(whichAnim) end

---@param whichUnit unit
---@return real
function BlzGetUnitArmor(whichUnit) end

---@param whichUnit unit
---@param armorAmount real
---@return nothing
function BlzSetUnitArmor(whichUnit, armorAmount) end

---@param whichUnit unit
---@param abilId integer
---@param flag boolean
---@return nothing
function BlzUnitHideAbility(whichUnit, abilId, flag) end

---@param whichUnit unit
---@param abilId integer
---@param flag boolean
---@param hideUI boolean
---@return nothing
function BlzUnitDisableAbility(whichUnit, abilId, flag, hideUI) end

---@param whichUnit unit
---@return nothing
function BlzUnitCancelTimedLife(whichUnit) end

---@param whichUnit unit
---@return boolean
function BlzIsUnitSelectable(whichUnit) end

---@param whichUnit unit
---@return boolean
function BlzIsUnitInvulnerable(whichUnit) end

---@param whichUnit unit
---@return nothing
function BlzUnitInterruptAttack(whichUnit) end

---@param whichUnit unit
---@return real
function BlzGetUnitCollisionSize(whichUnit) end

---@param abilId integer
---@param level integer
---@return integer
function BlzGetAbilityManaCost(abilId, level) end

---@param abilId integer
---@param level integer
---@return real
function BlzGetAbilityCooldown(abilId, level) end

---@param whichUnit unit
---@param abilId integer
---@param level integer
---@param cooldown real
---@return nothing
function BlzSetUnitAbilityCooldown(whichUnit, abilId, level, cooldown) end

---@param whichUnit unit
---@param abilId integer
---@param level integer
---@return real
function BlzGetUnitAbilityCooldown(whichUnit, abilId, level) end

---@param whichUnit unit
---@param abilId integer
---@return real
function BlzGetUnitAbilityCooldownRemaining(whichUnit, abilId) end

---@param whichUnit unit
---@param abilCode integer
---@return nothing
function BlzEndUnitAbilityCooldown(whichUnit, abilCode) end

---@param whichUnit unit
---@param abilCode integer
---@param cooldown real
---@return nothing
function BlzStartUnitAbilityCooldown(whichUnit, abilCode, cooldown) end

---@param whichUnit unit
---@param abilId integer
---@param level integer
---@return integer
function BlzGetUnitAbilityManaCost(whichUnit, abilId, level) end

---@param whichUnit unit
---@param abilId integer
---@param level integer
---@param manaCost integer
---@return nothing
function BlzSetUnitAbilityManaCost(whichUnit, abilId, level, manaCost) end

---@param whichUnit unit
---@return real
function BlzGetLocalUnitZ(whichUnit) end

---@param whichPlayer player
---@param techid integer
---@param levels integer
---@return nothing
function BlzDecPlayerTechResearched(whichPlayer, techid, levels) end

---@param damage real
---@return nothing
function BlzSetEventDamage(damage) end

---@return unit
function BlzGetEventDamageTarget() end

---@return attacktype
function BlzGetEventAttackType() end

---@return damagetype
function BlzGetEventDamageType() end

---@return weapontype
function BlzGetEventWeaponType() end

---@param attackType attacktype
---@return boolean
function BlzSetEventAttackType(attackType) end

---@param damageType damagetype
---@return boolean
function BlzSetEventDamageType(damageType) end

---@param weaponType weapontype
---@return boolean
function BlzSetEventWeaponType(weaponType) end

---@return boolean
function BlzGetEventIsAttack() end

---@param dataType integer
---@param whichPlayer player
---@param param1 string
---@param param2 string
---@param param3 boolean
---@param param4 integer
---@param param5 integer
---@param param6 integer
---@return integer
function RequestExtraIntegerData(dataType, whichPlayer, param1, param2, param3, param4, param5, param6) end

---@param dataType integer
---@param whichPlayer player
---@param param1 string
---@param param2 string
---@param param3 boolean
---@param param4 integer
---@param param5 integer
---@param param6 integer
---@return boolean
function RequestExtraBooleanData(dataType, whichPlayer, param1, param2, param3, param4, param5, param6) end

---@param dataType integer
---@param whichPlayer player
---@param param1 string
---@param param2 string
---@param param3 boolean
---@param param4 integer
---@param param5 integer
---@param param6 integer
---@return string
function RequestExtraStringData(dataType, whichPlayer, param1, param2, param3, param4, param5, param6) end

---@param dataType integer
---@param whichPlayer player
---@param param1 string
---@param param2 string
---@param param3 boolean
---@param param4 integer
---@param param5 integer
---@param param6 integer
---@return real
function RequestExtraRealData(dataType, whichPlayer, param1, param2, param3, param4, param5, param6) end

---@param whichUnit unit
---@return real
function BlzGetUnitZ(whichUnit) end

---@param enableSelection boolean
---@param enableSelectionCircle boolean
---@return nothing
function BlzEnableSelections(enableSelection, enableSelectionCircle) end

---@return boolean
function BlzIsSelectionEnabled() end

---@return boolean
function BlzIsSelectionCircleEnabled() end

---@param whichSetup camerasetup
---@param doPan boolean
---@param forcedDuration real
---@param easeInDuration real
---@param easeOutDuration real
---@param smoothFactor real
---@return nothing
function BlzCameraSetupApplyForceDurationSmooth(whichSetup, doPan, forcedDuration, easeInDuration, easeOutDuration, smoothFactor) end

---@param enable boolean
---@return nothing
function BlzEnableTargetIndicator(enable) end

---@return boolean
function BlzIsTargetIndicatorEnabled() end

---@param show boolean
---@return nothing
function BlzShowTerrain(show) end

---@param show boolean
---@return nothing
function BlzShowSkyBox(show) end

---@param fps integer
---@return nothing
function BlzStartRecording(fps) end

---@return nothing
function BlzEndRecording() end

---@param whichUnit unit
---@param show boolean
---@return nothing
function BlzShowUnitTeamGlow(whichUnit, show) end

---@param frameType originframetype
---@param index integer
---@return framehandle
function BlzGetOriginFrame(frameType, index) end

---@param enable boolean
---@return nothing
function BlzEnableUIAutoPosition(enable) end

---@param enable boolean
---@return nothing
function BlzHideOriginFrames(enable) end

---@param a integer
---@param r integer
---@param g integer
---@param b integer
---@return integer
function BlzConvertColor(a, r, g, b) end

---@param TOCFile string
---@return boolean
function BlzLoadTOCFile(TOCFile) end

---@param name string
---@param owner framehandle
---@param priority integer
---@param createContext integer
---@return framehandle
function BlzCreateFrame(name, owner, priority, createContext) end

---@param name string
---@param owner framehandle
---@param createContext integer
---@return framehandle
function BlzCreateSimpleFrame(name, owner, createContext) end

---@param typeName string
---@param name string
---@param owner framehandle
---@param inherits string
---@param createContext integer
---@return framehandle
function BlzCreateFrameByType(typeName, name, owner, inherits, createContext) end

---@param frame framehandle
---@return nothing
function BlzDestroyFrame(frame) end

---@param frame framehandle
---@param point framepointtype
---@param relative framehandle
---@param relativePoint framepointtype
---@param x real
---@param y real
---@return nothing
function BlzFrameSetPoint(frame, point, relative, relativePoint, x, y) end

---@param frame framehandle
---@param point framepointtype
---@param x real
---@param y real
---@return nothing
function BlzFrameSetAbsPoint(frame, point, x, y) end

---@param frame framehandle
---@return nothing
function BlzFrameClearAllPoints(frame) end

---@param frame framehandle
---@param relative framehandle
---@return nothing
function BlzFrameSetAllPoints(frame, relative) end

---@param frame framehandle
---@param visible boolean
---@return nothing
function BlzFrameSetVisible(frame, visible) end

---@param frame framehandle
---@return boolean
function BlzFrameIsVisible(frame) end

---@param name string
---@param createContext integer
---@return framehandle
function BlzGetFrameByName(name, createContext) end

---@param frame framehandle
---@return string
function BlzFrameGetName(frame) end

---@param frame framehandle
---@return nothing
function BlzFrameClick(frame) end

---@param frame framehandle
---@param text string
---@return nothing
function BlzFrameSetText(frame, text) end

---@param frame framehandle
---@return string
function BlzFrameGetText(frame) end

---@param frame framehandle
---@param text string
---@return nothing
function BlzFrameAddText(frame, text) end

---@param frame framehandle
---@param size integer
---@return nothing
function BlzFrameSetTextSizeLimit(frame, size) end

---@param frame framehandle
---@return integer
function BlzFrameGetTextSizeLimit(frame) end

---@param frame framehandle
---@param color integer
---@return nothing
function BlzFrameSetTextColor(frame, color) end

---@param frame framehandle
---@param flag boolean
---@return nothing
function BlzFrameSetFocus(frame, flag) end

---@param frame framehandle
---@param modelFile string
---@param cameraIndex integer
---@return nothing
function BlzFrameSetModel(frame, modelFile, cameraIndex) end

---@param frame framehandle
---@param enabled boolean
---@return nothing
function BlzFrameSetEnable(frame, enabled) end

---@param frame framehandle
---@return boolean
function BlzFrameGetEnable(frame) end

---@param frame framehandle
---@param alpha integer
---@return nothing
function BlzFrameSetAlpha(frame, alpha) end

---@param frame framehandle
---@return integer
function BlzFrameGetAlpha(frame) end

---@param frame framehandle
---@param primaryProp integer
---@param flags integer
---@return nothing
function BlzFrameSetSpriteAnimate(frame, primaryProp, flags) end

---@param frame framehandle
---@param texFile string
---@param flag integer
---@param blend boolean
---@return nothing
function BlzFrameSetTexture(frame, texFile, flag, blend) end

---@param frame framehandle
---@param scale real
---@return nothing
function BlzFrameSetScale(frame, scale) end

---@param frame framehandle
---@param tooltip framehandle
---@return nothing
function BlzFrameSetTooltip(frame, tooltip) end

---@param frame framehandle
---@param enable boolean
---@return nothing
function BlzFrameCageMouse(frame, enable) end

---@param frame framehandle
---@param value real
---@return nothing
function BlzFrameSetValue(frame, value) end

---@param frame framehandle
---@return real
function BlzFrameGetValue(frame) end

---@param frame framehandle
---@param minValue real
---@param maxValue real
---@return nothing
function BlzFrameSetMinMaxValue(frame, minValue, maxValue) end

---@param frame framehandle
---@param stepSize real
---@return nothing
function BlzFrameSetStepSize(frame, stepSize) end

---@param frame framehandle
---@param width real
---@param height real
---@return nothing
function BlzFrameSetSize(frame, width, height) end

---@param frame framehandle
---@param color integer
---@return nothing
function BlzFrameSetVertexColor(frame, color) end

---@param frame framehandle
---@param level integer
---@return nothing
function BlzFrameSetLevel(frame, level) end

---@param frame framehandle
---@param parent framehandle
---@return nothing
function BlzFrameSetParent(frame, parent) end

---@param frame framehandle
---@return framehandle
function BlzFrameGetParent(frame) end

---@param frame framehandle
---@return real
function BlzFrameGetHeight(frame) end

---@param frame framehandle
---@return real
function BlzFrameGetWidth(frame) end

---@param frame framehandle
---@param fileName string
---@param height real
---@param flags integer
---@return nothing
function BlzFrameSetFont(frame, fileName, height, flags) end

---@param frame framehandle
---@param vert textaligntype
---@param horz textaligntype
---@return nothing
function BlzFrameSetTextAlignment(frame, vert, horz) end

---@param frame framehandle
---@return integer
function BlzFrameGetChildrenCount(frame) end

---@param frame framehandle
---@param index integer
---@return framehandle
function BlzFrameGetChild(frame, index) end

---@param whichTrigger trigger
---@param frame framehandle
---@param eventId frameeventtype
---@return event
function BlzTriggerRegisterFrameEvent(whichTrigger, frame, eventId) end

---@return framehandle
function BlzGetTriggerFrame() end

---@return frameeventtype
function BlzGetTriggerFrameEvent() end

---@return real
function BlzGetTriggerFrameValue() end

---@return string
function BlzGetTriggerFrameText() end

---@param whichTrigger trigger
---@param whichPlayer player
---@param prefix string
---@param fromServer boolean
---@return event
function BlzTriggerRegisterPlayerSyncEvent(whichTrigger, whichPlayer, prefix, fromServer) end

---@param prefix string
---@param data string
---@return boolean
function BlzSendSyncData(prefix, data) end

---@return string
function BlzGetTriggerSyncPrefix() end

---@return string
function BlzGetTriggerSyncData() end

---@param whichTrigger trigger
---@param whichPlayer player
---@param key oskeytype
---@param metaKey integer
---@param keyDown boolean
---@return event
function BlzTriggerRegisterPlayerKeyEvent(whichTrigger, whichPlayer, key, metaKey, keyDown) end

---@return oskeytype
function BlzGetTriggerPlayerKey() end

---@return integer
function BlzGetTriggerPlayerMetaKey() end

---@return boolean
function BlzGetTriggerPlayerIsKeyDown() end

---@param enable boolean
---@return nothing
function BlzEnableCursor(enable) end

---@param x integer
---@param y integer
---@return nothing
function BlzSetMousePos(x, y) end

---@return integer
function BlzGetLocalClientWidth() end

---@return integer
function BlzGetLocalClientHeight() end

---@return boolean
function BlzIsLocalClientActive() end

---@return unit
function BlzGetMouseFocusUnit() end

---@param texFile string
---@return boolean
function BlzChangeMinimapTerrainTex(texFile) end

---@return string
function BlzGetLocale() end

---@param whichEffect effect
---@return real
function BlzGetSpecialEffectScale(whichEffect) end

---@param whichEffect effect
---@param x real
---@param y real
---@param z real
---@return nothing
function BlzSetSpecialEffectMatrixScale(whichEffect, x, y, z) end

---@param whichEffect effect
---@return nothing
function BlzResetSpecialEffectMatrix(whichEffect) end

---@param whichUnit unit
---@param abilId integer
---@return ability
function BlzGetUnitAbility(whichUnit, abilId) end

---@param whichUnit unit
---@param index integer
---@return ability
function BlzGetUnitAbilityByIndex(whichUnit, index) end

---@param whichAbility ability
---@return integer
function BlzGetAbilityId(whichAbility) end

---@param whichPlayer player
---@param recipient integer
---@param message string
---@return nothing
function BlzDisplayChatMessage(whichPlayer, recipient, message) end

---@param whichUnit unit
---@param flag boolean
---@return nothing
function BlzPauseUnitEx(whichUnit, flag) end

---@param value integer
---@return string
function BlzFourCC2S(value) end

---@param value string
---@return integer
function BlzS2FourCC(value) end

---@param whichUnit unit
---@param facingAngle real
---@return nothing
function BlzSetUnitFacingEx(whichUnit, facingAngle) end

---@param abilityId integer
---@param order string
---@return commandbuttoneffect
function CreateCommandButtonEffect(abilityId, order) end

---@param whichUprgade integer
---@return commandbuttoneffect
function CreateUpgradeCommandButtonEffect(whichUprgade) end

---@param abilityId integer
---@return commandbuttoneffect
function CreateLearnCommandButtonEffect(abilityId) end

---@param whichEffect commandbuttoneffect
---@return nothing
function DestroyCommandButtonEffect(whichEffect) end

---@param x integer
---@param y integer
---@return integer
function BlzBitOr(x, y) end

---@param x integer
---@param y integer
---@return integer
function BlzBitAnd(x, y) end

---@param x integer
---@param y integer
---@return integer
function BlzBitXor(x, y) end

---@param whichAbility ability
---@param whichField abilitybooleanfield
---@return boolean
function BlzGetAbilityBooleanField(whichAbility, whichField) end

---@param whichAbility ability
---@param whichField abilityintegerfield
---@return integer
function BlzGetAbilityIntegerField(whichAbility, whichField) end

---@param whichAbility ability
---@param whichField abilityrealfield
---@return real
function BlzGetAbilityRealField(whichAbility, whichField) end

---@param whichAbility ability
---@param whichField abilitystringfield
---@return string
function BlzGetAbilityStringField(whichAbility, whichField) end

---@param whichAbility ability
---@param whichField abilitybooleanlevelfield
---@param level integer
---@return boolean
function BlzGetAbilityBooleanLevelField(whichAbility, whichField, level) end

---@param whichAbility ability
---@param whichField abilityintegerlevelfield
---@param level integer
---@return integer
function BlzGetAbilityIntegerLevelField(whichAbility, whichField, level) end

---@param whichAbility ability
---@param whichField abilityreallevelfield
---@param level integer
---@return real
function BlzGetAbilityRealLevelField(whichAbility, whichField, level) end

---@param whichAbility ability
---@param whichField abilitystringlevelfield
---@param level integer
---@return string
function BlzGetAbilityStringLevelField(whichAbility, whichField, level) end

---@param whichAbility ability
---@param whichField abilitybooleanlevelarrayfield
---@param level integer
---@param index integer
---@return boolean
function BlzGetAbilityBooleanLevelArrayField(whichAbility, whichField, level, index) end

---@param whichAbility ability
---@param whichField abilityintegerlevelarrayfield
---@param level integer
---@param index integer
---@return integer
function BlzGetAbilityIntegerLevelArrayField(whichAbility, whichField, level, index) end

---@param whichAbility ability
---@param whichField abilityreallevelarrayfield
---@param level integer
---@param index integer
---@return real
function BlzGetAbilityRealLevelArrayField(whichAbility, whichField, level, index) end

---@param whichAbility ability
---@param whichField abilitystringlevelarrayfield
---@param level integer
---@param index integer
---@return string
function BlzGetAbilityStringLevelArrayField(whichAbility, whichField, level, index) end

---@param whichAbility ability
---@param whichField abilitybooleanfield
---@param value boolean
---@return boolean
function BlzSetAbilityBooleanField(whichAbility, whichField, value) end

---@param whichAbility ability
---@param whichField abilityintegerfield
---@param value integer
---@return boolean
function BlzSetAbilityIntegerField(whichAbility, whichField, value) end

---@param whichAbility ability
---@param whichField abilityrealfield
---@param value real
---@return boolean
function BlzSetAbilityRealField(whichAbility, whichField, value) end

---@param whichAbility ability
---@param whichField abilitystringfield
---@param value string
---@return boolean
function BlzSetAbilityStringField(whichAbility, whichField, value) end

---@param whichAbility ability
---@param whichField abilitybooleanlevelfield
---@param level integer
---@param value boolean
---@return boolean
function BlzSetAbilityBooleanLevelField(whichAbility, whichField, level, value) end

---@param whichAbility ability
---@param whichField abilityintegerlevelfield
---@param level integer
---@param value integer
---@return boolean
function BlzSetAbilityIntegerLevelField(whichAbility, whichField, level, value) end

---@param whichAbility ability
---@param whichField abilityreallevelfield
---@param level integer
---@param value real
---@return boolean
function BlzSetAbilityRealLevelField(whichAbility, whichField, level, value) end

---@param whichAbility ability
---@param whichField abilitystringlevelfield
---@param level integer
---@param value string
---@return boolean
function BlzSetAbilityStringLevelField(whichAbility, whichField, level, value) end

---@param whichAbility ability
---@param whichField abilitybooleanlevelarrayfield
---@param level integer
---@param index integer
---@param value boolean
---@return boolean
function BlzSetAbilityBooleanLevelArrayField(whichAbility, whichField, level, index, value) end

---@param whichAbility ability
---@param whichField abilityintegerlevelarrayfield
---@param level integer
---@param index integer
---@param value integer
---@return boolean
function BlzSetAbilityIntegerLevelArrayField(whichAbility, whichField, level, index, value) end

---@param whichAbility ability
---@param whichField abilityreallevelarrayfield
---@param level integer
---@param index integer
---@param value real
---@return boolean
function BlzSetAbilityRealLevelArrayField(whichAbility, whichField, level, index, value) end

---@param whichAbility ability
---@param whichField abilitystringlevelarrayfield
---@param level integer
---@param index integer
---@param value string
---@return boolean
function BlzSetAbilityStringLevelArrayField(whichAbility, whichField, level, index, value) end

---@param whichAbility ability
---@param whichField abilitybooleanlevelarrayfield
---@param level integer
---@param value boolean
---@return boolean
function BlzAddAbilityBooleanLevelArrayField(whichAbility, whichField, level, value) end

---@param whichAbility ability
---@param whichField abilityintegerlevelarrayfield
---@param level integer
---@param value integer
---@return boolean
function BlzAddAbilityIntegerLevelArrayField(whichAbility, whichField, level, value) end

---@param whichAbility ability
---@param whichField abilityreallevelarrayfield
---@param level integer
---@param value real
---@return boolean
function BlzAddAbilityRealLevelArrayField(whichAbility, whichField, level, value) end

---@param whichAbility ability
---@param whichField abilitystringlevelarrayfield
---@param level integer
---@param value string
---@return boolean
function BlzAddAbilityStringLevelArrayField(whichAbility, whichField, level, value) end

---@param whichAbility ability
---@param whichField abilitybooleanlevelarrayfield
---@param level integer
---@param value boolean
---@return boolean
function BlzRemoveAbilityBooleanLevelArrayField(whichAbility, whichField, level, value) end

---@param whichAbility ability
---@param whichField abilityintegerlevelarrayfield
---@param level integer
---@param value integer
---@return boolean
function BlzRemoveAbilityIntegerLevelArrayField(whichAbility, whichField, level, value) end

---@param whichAbility ability
---@param whichField abilityreallevelarrayfield
---@param level integer
---@param value real
---@return boolean
function BlzRemoveAbilityRealLevelArrayField(whichAbility, whichField, level, value) end

---@param whichAbility ability
---@param whichField abilitystringlevelarrayfield
---@param level integer
---@param value string
---@return boolean
function BlzRemoveAbilityStringLevelArrayField(whichAbility, whichField, level, value) end

---@param whichItem item
---@param index integer
---@return ability
function BlzGetItemAbilityByIndex(whichItem, index) end

---@param whichItem item
---@param abilCode integer
---@return ability
function BlzGetItemAbility(whichItem, abilCode) end

---@param whichItem item
---@param abilCode integer
---@return boolean
function BlzItemAddAbility(whichItem, abilCode) end

---@param whichItem item
---@param whichField itembooleanfield
---@return boolean
function BlzGetItemBooleanField(whichItem, whichField) end

---@param whichItem item
---@param whichField itemintegerfield
---@return integer
function BlzGetItemIntegerField(whichItem, whichField) end

---@param whichItem item
---@param whichField itemrealfield
---@return real
function BlzGetItemRealField(whichItem, whichField) end

---@param whichItem item
---@param whichField itemstringfield
---@return string
function BlzGetItemStringField(whichItem, whichField) end

---@param whichItem item
---@param whichField itembooleanfield
---@param value boolean
---@return boolean
function BlzSetItemBooleanField(whichItem, whichField, value) end

---@param whichItem item
---@param whichField itemintegerfield
---@param value integer
---@return boolean
function BlzSetItemIntegerField(whichItem, whichField, value) end

---@param whichItem item
---@param whichField itemrealfield
---@param value real
---@return boolean
function BlzSetItemRealField(whichItem, whichField, value) end

---@param whichItem item
---@param whichField itemstringfield
---@param value string
---@return boolean
function BlzSetItemStringField(whichItem, whichField, value) end

---@param whichItem item
---@param abilCode integer
---@return boolean
function BlzItemRemoveAbility(whichItem, abilCode) end

---@param whichUnit unit
---@param whichField unitbooleanfield
---@return boolean
function BlzGetUnitBooleanField(whichUnit, whichField) end

---@param whichUnit unit
---@param whichField unitintegerfield
---@return integer
function BlzGetUnitIntegerField(whichUnit, whichField) end

---@param whichUnit unit
---@param whichField unitrealfield
---@return real
function BlzGetUnitRealField(whichUnit, whichField) end

---@param whichUnit unit
---@param whichField unitstringfield
---@return string
function BlzGetUnitStringField(whichUnit, whichField) end

---@param whichUnit unit
---@param whichField unitbooleanfield
---@param value boolean
---@return boolean
function BlzSetUnitBooleanField(whichUnit, whichField, value) end

---@param whichUnit unit
---@param whichField unitintegerfield
---@param value integer
---@return boolean
function BlzSetUnitIntegerField(whichUnit, whichField, value) end

---@param whichUnit unit
---@param whichField unitrealfield
---@param value real
---@return boolean
function BlzSetUnitRealField(whichUnit, whichField, value) end

---@param whichUnit unit
---@param whichField unitstringfield
---@param value string
---@return boolean
function BlzSetUnitStringField(whichUnit, whichField, value) end

---@param whichUnit unit
---@param whichField unitweaponbooleanfield
---@param index integer
---@return boolean
function BlzGetUnitWeaponBooleanField(whichUnit, whichField, index) end

---@param whichUnit unit
---@param whichField unitweaponintegerfield
---@param index integer
---@return integer
function BlzGetUnitWeaponIntegerField(whichUnit, whichField, index) end

---@param whichUnit unit
---@param whichField unitweaponrealfield
---@param index integer
---@return real
function BlzGetUnitWeaponRealField(whichUnit, whichField, index) end

---@param whichUnit unit
---@param whichField unitweaponstringfield
---@param index integer
---@return string
function BlzGetUnitWeaponStringField(whichUnit, whichField, index) end

---@param whichUnit unit
---@param whichField unitweaponbooleanfield
---@param index integer
---@param value boolean
---@return boolean
function BlzSetUnitWeaponBooleanField(whichUnit, whichField, index, value) end

---@param whichUnit unit
---@param whichField unitweaponintegerfield
---@param index integer
---@param value integer
---@return boolean
function BlzSetUnitWeaponIntegerField(whichUnit, whichField, index, value) end

---@param whichUnit unit
---@param whichField unitweaponrealfield
---@param index integer
---@param value real
---@return boolean
function BlzSetUnitWeaponRealField(whichUnit, whichField, index, value) end

---@param whichUnit unit
---@param whichField unitweaponstringfield
---@param index integer
---@param value string
---@return boolean
function BlzSetUnitWeaponStringField(whichUnit, whichField, index, value) end

---@param whichUnit unit
---@return integer
function BlzGetUnitSkin(whichUnit) end

---@param whichItem item
---@return integer
function BlzGetItemSkin(whichItem) end

---@param whichDestructable destructable
---@return integer
function BlzGetDestructableSkin(whichDestructable) end

---@param whichUnit unit
---@param skinId integer
---@return nothing
function BlzSetUnitSkin(whichUnit, skinId) end

---@param whichItem item
---@param skinId integer
---@return nothing
function BlzSetItemSkin(whichItem, skinId) end

---@param whichDestructable destructable
---@param skinId integer
---@return nothing
function BlzSetDestructableSkin(whichDestructable, skinId) end

---@param itemid integer
---@param x real
---@param y real
---@param skinId integer
---@return item
function BlzCreateItemWithSkin(itemid, x, y, skinId) end

---@param id player
---@param unitid integer
---@param x real
---@param y real
---@param face real
---@param skinId integer
---@return unit
function BlzCreateUnitWithSkin(id, unitid, x, y, face, skinId) end

---@param objectid integer
---@param x real
---@param y real
---@param face real
---@param scale real
---@param variation integer
---@param skinId integer
---@return destructable
function BlzCreateDestructableWithSkin(objectid, x, y, face, scale, variation, skinId) end

---@param objectid integer
---@param x real
---@param y real
---@param z real
---@param face real
---@param scale real
---@param variation integer
---@param skinId integer
---@return destructable
function BlzCreateDestructableZWithSkin(objectid, x, y, z, face, scale, variation, skinId) end

---@param objectid integer
---@param x real
---@param y real
---@param face real
---@param scale real
---@param variation integer
---@param skinId integer
---@return destructable
function BlzCreateDeadDestructableWithSkin(objectid, x, y, face, scale, variation, skinId) end

---@param objectid integer
---@param x real
---@param y real
---@param z real
---@param face real
---@param scale real
---@param variation integer
---@param skinId integer
---@return destructable
function BlzCreateDeadDestructableZWithSkin(objectid, x, y, z, face, scale, variation, skinId) end

---@param whichPlayer player
---@return integer
function BlzGetPlayerTownHallCount(whichPlayer) end

---@param whichUnit unit
---@param order integer
---@return boolean
function BlzQueueImmediateOrderById(whichUnit, order) end

---@param whichUnit unit
---@param order integer
---@param x real
---@param y real
---@return boolean
function BlzQueuePointOrderById(whichUnit, order, x, y) end

---@param whichUnit unit
---@param order integer
---@param targetWidget widget
---@return boolean
function BlzQueueTargetOrderById(whichUnit, order, targetWidget) end

---@param whichUnit unit
---@param order integer
---@param x real
---@param y real
---@param instantTargetWidget widget
---@return boolean
function BlzQueueInstantPointOrderById(whichUnit, order, x, y, instantTargetWidget) end

---@param whichUnit unit
---@param order integer
---@param targetWidget widget
---@param instantTargetWidget widget
---@return boolean
function BlzQueueInstantTargetOrderById(whichUnit, order, targetWidget, instantTargetWidget) end

---@param whichPeon unit
---@param unitId integer
---@param x real
---@param y real
---@return boolean
function BlzQueueBuildOrderById(whichPeon, unitId, x, y) end

---@param forWhichPlayer player
---@param neutralStructure unit
---@param unitId integer
---@return boolean
function BlzQueueNeutralImmediateOrderById(forWhichPlayer, neutralStructure, unitId) end

---@param forWhichPlayer player
---@param neutralStructure unit
---@param unitId integer
---@param x real
---@param y real
---@return boolean
function BlzQueueNeutralPointOrderById(forWhichPlayer, neutralStructure, unitId, x, y) end

---@param forWhichPlayer player
---@param neutralStructure unit
---@param unitId integer
---@param target widget
---@return boolean
function BlzQueueNeutralTargetOrderById(forWhichPlayer, neutralStructure, unitId, target) end

---@param whichUnit unit
---@return integer
function BlzGetUnitOrderCount(whichUnit) end

---@param whichUnit unit
---@param onlyQueued boolean
---@return nothing
function BlzUnitClearOrders(whichUnit, onlyQueued) end

---@param whichUnit unit
---@param clearQueue boolean
---@return nothing
function BlzUnitForceStopOrder(whichUnit, clearQueue) end

---@param code string
---@return integer
function FourCC(code) end
