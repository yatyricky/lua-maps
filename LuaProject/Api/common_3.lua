---@diagnostic disable

---@param id player
---@param unitid integer
---@param whichLocation location
---@param face real
---@return unit
function CreateUnitAtLoc(id, unitid, whichLocation, face) end

---@param id player
---@param unitname string
---@param whichLocation location
---@param face real
---@return unit
function CreateUnitAtLocByName(id, unitname, whichLocation, face) end

---@param whichPlayer player
---@param unitid integer
---@param x real
---@param y real
---@param face real
---@return unit
function CreateCorpse(whichPlayer, unitid, x, y, face) end

---@param whichUnit unit
---@return nothing
function KillUnit(whichUnit) end

---@param whichUnit unit
---@return nothing
function RemoveUnit(whichUnit) end

---@param whichUnit unit
---@param show boolean
---@return nothing
function ShowUnit(whichUnit, show) end

---@param whichUnit unit
---@param whichUnitState unitstate
---@param newVal real
---@return nothing
function SetUnitState(whichUnit, whichUnitState, newVal) end

---@param whichUnit unit
---@param newX real
---@return nothing
function SetUnitX(whichUnit, newX) end

---@param whichUnit unit
---@param newY real
---@return nothing
function SetUnitY(whichUnit, newY) end

---@param whichUnit unit
---@param newX real
---@param newY real
---@return nothing
function SetUnitPosition(whichUnit, newX, newY) end

---@param whichUnit unit
---@param whichLocation location
---@return nothing
function SetUnitPositionLoc(whichUnit, whichLocation) end

---@param whichUnit unit
---@param facingAngle real
---@return nothing
function SetUnitFacing(whichUnit, facingAngle) end

---@param whichUnit unit
---@param facingAngle real
---@param duration real
---@return nothing
function SetUnitFacingTimed(whichUnit, facingAngle, duration) end

---@param whichUnit unit
---@param newSpeed real
---@return nothing
function SetUnitMoveSpeed(whichUnit, newSpeed) end

---@param whichUnit unit
---@param newHeight real
---@param rate real
---@return nothing
function SetUnitFlyHeight(whichUnit, newHeight, rate) end

---@param whichUnit unit
---@param newTurnSpeed real
---@return nothing
function SetUnitTurnSpeed(whichUnit, newTurnSpeed) end

---@param whichUnit unit
---@param newPropWindowAngle real
---@return nothing
function SetUnitPropWindow(whichUnit, newPropWindowAngle) end

---@param whichUnit unit
---@param newAcquireRange real
---@return nothing
function SetUnitAcquireRange(whichUnit, newAcquireRange) end

---@param whichUnit unit
---@param creepGuard boolean
---@return nothing
function SetUnitCreepGuard(whichUnit, creepGuard) end

---@param whichUnit unit
---@return real
function GetUnitAcquireRange(whichUnit) end

---@param whichUnit unit
---@return real
function GetUnitTurnSpeed(whichUnit) end

---@param whichUnit unit
---@return real
function GetUnitPropWindow(whichUnit) end

---@param whichUnit unit
---@return real
function GetUnitFlyHeight(whichUnit) end

---@param whichUnit unit
---@return real
function GetUnitDefaultAcquireRange(whichUnit) end

---@param whichUnit unit
---@return real
function GetUnitDefaultTurnSpeed(whichUnit) end

---@param whichUnit unit
---@return real
function GetUnitDefaultPropWindow(whichUnit) end

---@param whichUnit unit
---@return real
function GetUnitDefaultFlyHeight(whichUnit) end

---@param whichUnit unit
---@param whichPlayer player
---@param changeColor boolean
---@return nothing
function SetUnitOwner(whichUnit, whichPlayer, changeColor) end

---@param whichUnit unit
---@param whichColor playercolor
---@return nothing
function SetUnitColor(whichUnit, whichColor) end

---@param whichUnit unit
---@param scaleX real
---@param scaleY real
---@param scaleZ real
---@return nothing
function SetUnitScale(whichUnit, scaleX, scaleY, scaleZ) end

---@param whichUnit unit
---@param timeScale real
---@return nothing
function SetUnitTimeScale(whichUnit, timeScale) end

---@param whichUnit unit
---@param blendTime real
---@return nothing
function SetUnitBlendTime(whichUnit, blendTime) end

---@param whichUnit unit
---@param red integer
---@param green integer
---@param blue integer
---@param alpha integer
---@return nothing
function SetUnitVertexColor(whichUnit, red, green, blue, alpha) end

---@param whichUnit unit
---@param whichAnimation string
---@return nothing
function QueueUnitAnimation(whichUnit, whichAnimation) end

---@param whichUnit unit
---@param whichAnimation string
---@return nothing
function SetUnitAnimation(whichUnit, whichAnimation) end

---@param whichUnit unit
---@param whichAnimation integer
---@return nothing
function SetUnitAnimationByIndex(whichUnit, whichAnimation) end

---@param whichUnit unit
---@param whichAnimation string
---@param rarity raritycontrol
---@return nothing
function SetUnitAnimationWithRarity(whichUnit, whichAnimation, rarity) end

---@param whichUnit unit
---@param animProperties string
---@param add boolean
---@return nothing
function AddUnitAnimationProperties(whichUnit, animProperties, add) end

---@param whichUnit unit
---@param whichBone string
---@param lookAtTarget unit
---@param offsetX real
---@param offsetY real
---@param offsetZ real
---@return nothing
function SetUnitLookAt(whichUnit, whichBone, lookAtTarget, offsetX, offsetY, offsetZ) end

---@param whichUnit unit
---@return nothing
function ResetUnitLookAt(whichUnit) end

---@param whichUnit unit
---@param byWhichPlayer player
---@param flag boolean
---@return nothing
function SetUnitRescuable(whichUnit, byWhichPlayer, flag) end

---@param whichUnit unit
---@param range real
---@return nothing
function SetUnitRescueRange(whichUnit, range) end

---@param whichHero unit
---@param newStr integer
---@param permanent boolean
---@return nothing
function SetHeroStr(whichHero, newStr, permanent) end

---@param whichHero unit
---@param newAgi integer
---@param permanent boolean
---@return nothing
function SetHeroAgi(whichHero, newAgi, permanent) end

---@param whichHero unit
---@param newInt integer
---@param permanent boolean
---@return nothing
function SetHeroInt(whichHero, newInt, permanent) end

---@param whichHero unit
---@param includeBonuses boolean
---@return integer
function GetHeroStr(whichHero, includeBonuses) end

---@param whichHero unit
---@param includeBonuses boolean
---@return integer
function GetHeroAgi(whichHero, includeBonuses) end

---@param whichHero unit
---@param includeBonuses boolean
---@return integer
function GetHeroInt(whichHero, includeBonuses) end

---@param whichHero unit
---@param howManyLevels integer
---@return boolean
function UnitStripHeroLevel(whichHero, howManyLevels) end

---@param whichHero unit
---@return integer
function GetHeroXP(whichHero) end

---@param whichHero unit
---@param newXpVal integer
---@param showEyeCandy boolean
---@return nothing
function SetHeroXP(whichHero, newXpVal, showEyeCandy) end

---@param whichHero unit
---@return integer
function GetHeroSkillPoints(whichHero) end

---@param whichHero unit
---@param skillPointDelta integer
---@return boolean
function UnitModifySkillPoints(whichHero, skillPointDelta) end

---@param whichHero unit
---@param xpToAdd integer
---@param showEyeCandy boolean
---@return nothing
function AddHeroXP(whichHero, xpToAdd, showEyeCandy) end

---@param whichHero unit
---@param level integer
---@param showEyeCandy boolean
---@return nothing
function SetHeroLevel(whichHero, level, showEyeCandy) end

---@param whichHero unit
---@return integer
function GetHeroLevel(whichHero) end

---@param whichUnit unit
---@return integer
function GetUnitLevel(whichUnit) end

---@param whichHero unit
---@return string
function GetHeroProperName(whichHero) end

---@param whichHero unit
---@param flag boolean
---@return nothing
function SuspendHeroXP(whichHero, flag) end

---@param whichHero unit
---@return boolean
function IsSuspendedXP(whichHero) end

---@param whichHero unit
---@param abilcode integer
---@return nothing
function SelectHeroSkill(whichHero, abilcode) end

---@param whichUnit unit
---@param abilcode integer
---@return integer
function GetUnitAbilityLevel(whichUnit, abilcode) end

---@param whichUnit unit
---@param abilcode integer
---@return integer
function DecUnitAbilityLevel(whichUnit, abilcode) end

---@param whichUnit unit
---@param abilcode integer
---@return integer
function IncUnitAbilityLevel(whichUnit, abilcode) end

---@param whichUnit unit
---@param abilcode integer
---@param level integer
---@return integer
function SetUnitAbilityLevel(whichUnit, abilcode, level) end

---@param whichHero unit
---@param x real
---@param y real
---@param doEyecandy boolean
---@return boolean
function ReviveHero(whichHero, x, y, doEyecandy) end

---@param whichHero unit
---@param loc location
---@param doEyecandy boolean
---@return boolean
function ReviveHeroLoc(whichHero, loc, doEyecandy) end

---@param whichUnit unit
---@param exploded boolean
---@return nothing
function SetUnitExploded(whichUnit, exploded) end

---@param whichUnit unit
---@param flag boolean
---@return nothing
function SetUnitInvulnerable(whichUnit, flag) end

---@param whichUnit unit
---@param flag boolean
---@return nothing
function PauseUnit(whichUnit, flag) end

---@param whichHero unit
---@return boolean
function IsUnitPaused(whichHero) end

---@param whichUnit unit
---@param flag boolean
---@return nothing
function SetUnitPathing(whichUnit, flag) end

---@return nothing
function ClearSelection() end

---@param whichUnit unit
---@param flag boolean
---@return nothing
function SelectUnit(whichUnit, flag) end

---@param whichUnit unit
---@return integer
function GetUnitPointValue(whichUnit) end

---@param unitType integer
---@return integer
function GetUnitPointValueByType(unitType) end

---@param whichUnit unit
---@param whichItem item
---@return boolean
function UnitAddItem(whichUnit, whichItem) end

---@param whichUnit unit
---@param itemId integer
---@return item
function UnitAddItemById(whichUnit, itemId) end

---@param whichUnit unit
---@param itemId integer
---@param itemSlot integer
---@return boolean
function UnitAddItemToSlotById(whichUnit, itemId, itemSlot) end

---@param whichUnit unit
---@param whichItem item
---@return nothing
function UnitRemoveItem(whichUnit, whichItem) end

---@param whichUnit unit
---@param itemSlot integer
---@return item
function UnitRemoveItemFromSlot(whichUnit, itemSlot) end

---@param whichUnit unit
---@param whichItem item
---@return boolean
function UnitHasItem(whichUnit, whichItem) end

---@param whichUnit unit
---@param itemSlot integer
---@return item
function UnitItemInSlot(whichUnit, itemSlot) end

---@param whichUnit unit
---@return integer
function UnitInventorySize(whichUnit) end

---@param whichUnit unit
---@param whichItem item
---@param x real
---@param y real
---@return boolean
function UnitDropItemPoint(whichUnit, whichItem, x, y) end

---@param whichUnit unit
---@param whichItem item
---@param slot integer
---@return boolean
function UnitDropItemSlot(whichUnit, whichItem, slot) end

---@param whichUnit unit
---@param whichItem item
---@param target widget
---@return boolean
function UnitDropItemTarget(whichUnit, whichItem, target) end

---@param whichUnit unit
---@param whichItem item
---@return boolean
function UnitUseItem(whichUnit, whichItem) end

---@param whichUnit unit
---@param whichItem item
---@param x real
---@param y real
---@return boolean
function UnitUseItemPoint(whichUnit, whichItem, x, y) end

---@param whichUnit unit
---@param whichItem item
---@param target widget
---@return boolean
function UnitUseItemTarget(whichUnit, whichItem, target) end

---@param whichUnit unit
---@return real
function GetUnitX(whichUnit) end

---@param whichUnit unit
---@return real
function GetUnitY(whichUnit) end

---@param whichUnit unit
---@return location
function GetUnitLoc(whichUnit) end

---@param whichUnit unit
---@return real
function GetUnitFacing(whichUnit) end

---@param whichUnit unit
---@return real
function GetUnitMoveSpeed(whichUnit) end

---@param whichUnit unit
---@return real
function GetUnitDefaultMoveSpeed(whichUnit) end

---@param whichUnit unit
---@param whichUnitState unitstate
---@return real
function GetUnitState(whichUnit, whichUnitState) end

---@param whichUnit unit
---@return player
function GetOwningPlayer(whichUnit) end

---@param whichUnit unit
---@return integer
function GetUnitTypeId(whichUnit) end

---@param whichUnit unit
---@return race
function GetUnitRace(whichUnit) end

---@param whichUnit unit
---@return string
function GetUnitName(whichUnit) end

---@param whichUnit unit
---@return integer
function GetUnitFoodUsed(whichUnit) end

---@param whichUnit unit
---@return integer
function GetUnitFoodMade(whichUnit) end

---@param unitId integer
---@return integer
function GetFoodMade(unitId) end

---@param unitId integer
---@return integer
function GetFoodUsed(unitId) end

---@param whichUnit unit
---@param useFood boolean
---@return nothing
function SetUnitUseFood(whichUnit, useFood) end

---@param whichUnit unit
---@return location
function GetUnitRallyPoint(whichUnit) end

---@param whichUnit unit
---@return unit
function GetUnitRallyUnit(whichUnit) end

---@param whichUnit unit
---@return destructable
function GetUnitRallyDestructable(whichUnit) end

---@param whichUnit unit
---@param whichGroup group
---@return boolean
function IsUnitInGroup(whichUnit, whichGroup) end

---@param whichUnit unit
---@param whichForce force
---@return boolean
function IsUnitInForce(whichUnit, whichForce) end

---@param whichUnit unit
---@param whichPlayer player
---@return boolean
function IsUnitOwnedByPlayer(whichUnit, whichPlayer) end

---@param whichUnit unit
---@param whichPlayer player
---@return boolean
function IsUnitAlly(whichUnit, whichPlayer) end

---@param whichUnit unit
---@param whichPlayer player
---@return boolean
function IsUnitEnemy(whichUnit, whichPlayer) end

---@param whichUnit unit
---@param whichPlayer player
---@return boolean
function IsUnitVisible(whichUnit, whichPlayer) end

---@param whichUnit unit
---@param whichPlayer player
---@return boolean
function IsUnitDetected(whichUnit, whichPlayer) end

---@param whichUnit unit
---@param whichPlayer player
---@return boolean
function IsUnitInvisible(whichUnit, whichPlayer) end

---@param whichUnit unit
---@param whichPlayer player
---@return boolean
function IsUnitFogged(whichUnit, whichPlayer) end

---@param whichUnit unit
---@param whichPlayer player
---@return boolean
function IsUnitMasked(whichUnit, whichPlayer) end

---@param whichUnit unit
---@param whichPlayer player
---@return boolean
function IsUnitSelected(whichUnit, whichPlayer) end

---@param whichUnit unit
---@param whichRace race
---@return boolean
function IsUnitRace(whichUnit, whichRace) end

---@param whichUnit unit
---@param whichUnitType unittype
---@return boolean
function IsUnitType(whichUnit, whichUnitType) end

---@param whichUnit unit
---@param whichSpecifiedUnit unit
---@return boolean
function IsUnit(whichUnit, whichSpecifiedUnit) end

---@param whichUnit unit
---@param otherUnit unit
---@param distance real
---@return boolean
function IsUnitInRange(whichUnit, otherUnit, distance) end

---@param whichUnit unit
---@param x real
---@param y real
---@param distance real
---@return boolean
function IsUnitInRangeXY(whichUnit, x, y, distance) end

---@param whichUnit unit
---@param whichLocation location
---@param distance real
---@return boolean
function IsUnitInRangeLoc(whichUnit, whichLocation, distance) end

---@param whichUnit unit
---@return boolean
function IsUnitHidden(whichUnit) end

---@param whichUnit unit
---@return boolean
function IsUnitIllusion(whichUnit) end

---@param whichUnit unit
---@param whichTransport unit
---@return boolean
function IsUnitInTransport(whichUnit, whichTransport) end

---@param whichUnit unit
---@return boolean
function IsUnitLoaded(whichUnit) end

---@param unitId integer
---@return boolean
function IsHeroUnitId(unitId) end

---@param unitId integer
---@param whichUnitType unittype
---@return boolean
function IsUnitIdType(unitId, whichUnitType) end

---@param whichUnit unit
---@param whichPlayer player
---@param share boolean
---@return nothing
function UnitShareVision(whichUnit, whichPlayer, share) end

---@param whichUnit unit
---@param suspend boolean
---@return nothing
function UnitSuspendDecay(whichUnit, suspend) end

---@param whichUnit unit
---@param whichUnitType unittype
---@return boolean
function UnitAddType(whichUnit, whichUnitType) end

---@param whichUnit unit
---@param whichUnitType unittype
---@return boolean
function UnitRemoveType(whichUnit, whichUnitType) end

---@param whichUnit unit
---@param abilityId integer
---@return boolean
function UnitAddAbility(whichUnit, abilityId) end

---@param whichUnit unit
---@param abilityId integer
---@return boolean
function UnitRemoveAbility(whichUnit, abilityId) end

---@param whichUnit unit
---@param permanent boolean
---@param abilityId integer
---@return boolean
function UnitMakeAbilityPermanent(whichUnit, permanent, abilityId) end

---@param whichUnit unit
---@param removePositive boolean
---@param removeNegative boolean
---@return nothing
function UnitRemoveBuffs(whichUnit, removePositive, removeNegative) end

---@param whichUnit unit
---@param removePositive boolean
---@param removeNegative boolean
---@param magic boolean
---@param physical boolean
---@param timedLife boolean
---@param aura boolean
---@param autoDispel boolean
---@return nothing
function UnitRemoveBuffsEx(whichUnit, removePositive, removeNegative, magic, physical, timedLife, aura, autoDispel) end

---@param whichUnit unit
---@param removePositive boolean
---@param removeNegative boolean
---@param magic boolean
---@param physical boolean
---@param timedLife boolean
---@param aura boolean
---@param autoDispel boolean
---@return boolean
function UnitHasBuffsEx(whichUnit, removePositive, removeNegative, magic, physical, timedLife, aura, autoDispel) end

---@param whichUnit unit
---@param removePositive boolean
---@param removeNegative boolean
---@param magic boolean
---@param physical boolean
---@param timedLife boolean
---@param aura boolean
---@param autoDispel boolean
---@return integer
function UnitCountBuffsEx(whichUnit, removePositive, removeNegative, magic, physical, timedLife, aura, autoDispel) end

---@param whichUnit unit
---@param add boolean
---@return nothing
function UnitAddSleep(whichUnit, add) end

---@param whichUnit unit
---@return boolean
function UnitCanSleep(whichUnit) end

---@param whichUnit unit
---@param add boolean
---@return nothing
function UnitAddSleepPerm(whichUnit, add) end

---@param whichUnit unit
---@return boolean
function UnitCanSleepPerm(whichUnit) end

---@param whichUnit unit
---@return boolean
function UnitIsSleeping(whichUnit) end

---@param whichUnit unit
---@return nothing
function UnitWakeUp(whichUnit) end

---@param whichUnit unit
---@param buffId integer
---@param duration real
---@return nothing
function UnitApplyTimedLife(whichUnit, buffId, duration) end

---@param whichUnit unit
---@param flag boolean
---@return boolean
function UnitIgnoreAlarm(whichUnit, flag) end

---@param whichUnit unit
---@return boolean
function UnitIgnoreAlarmToggled(whichUnit) end

---@param whichUnit unit
---@return nothing
function UnitResetCooldown(whichUnit) end

---@param whichUnit unit
---@param constructionPercentage integer
---@return nothing
function UnitSetConstructionProgress(whichUnit, constructionPercentage) end

---@param whichUnit unit
---@param upgradePercentage integer
---@return nothing
function UnitSetUpgradeProgress(whichUnit, upgradePercentage) end

---@param whichUnit unit
---@param flag boolean
---@return nothing
function UnitPauseTimedLife(whichUnit, flag) end

---@param whichUnit unit
---@param flag boolean
---@return nothing
function UnitSetUsesAltIcon(whichUnit, flag) end

---@param whichUnit unit
---@param delay real
---@param radius real
---@param x real
---@param y real
---@param amount real
---@param attack boolean
---@param ranged boolean
---@param attackType attacktype
---@param damageType damagetype
---@param weaponType weapontype
---@return boolean
function UnitDamagePoint(whichUnit, delay, radius, x, y, amount, attack, ranged, attackType, damageType, weaponType) end

---@param whichUnit unit
---@param target widget
---@param amount real
---@param attack boolean
---@param ranged boolean
---@param attackType attacktype
---@param damageType damagetype
---@param weaponType weapontype
---@return boolean
function UnitDamageTarget(whichUnit, target, amount, attack, ranged, attackType, damageType, weaponType) end

---@param whichUnit unit
---@param order string
---@return boolean
function IssueImmediateOrder(whichUnit, order) end

---@param whichUnit unit
---@param order integer
---@return boolean
function IssueImmediateOrderById(whichUnit, order) end

---@param whichUnit unit
---@param order string
---@param x real
---@param y real
---@return boolean
function IssuePointOrder(whichUnit, order, x, y) end

---@param whichUnit unit
---@param order string
---@param whichLocation location
---@return boolean
function IssuePointOrderLoc(whichUnit, order, whichLocation) end

---@param whichUnit unit
---@param order integer
---@param x real
---@param y real
---@return boolean
function IssuePointOrderById(whichUnit, order, x, y) end

---@param whichUnit unit
---@param order integer
---@param whichLocation location
---@return boolean
function IssuePointOrderByIdLoc(whichUnit, order, whichLocation) end

---@param whichUnit unit
---@param order string
---@param targetWidget widget
---@return boolean
function IssueTargetOrder(whichUnit, order, targetWidget) end

---@param whichUnit unit
---@param order integer
---@param targetWidget widget
---@return boolean
function IssueTargetOrderById(whichUnit, order, targetWidget) end

---@param whichUnit unit
---@param order string
---@param x real
---@param y real
---@param instantTargetWidget widget
---@return boolean
function IssueInstantPointOrder(whichUnit, order, x, y, instantTargetWidget) end

---@param whichUnit unit
---@param order integer
---@param x real
---@param y real
---@param instantTargetWidget widget
---@return boolean
function IssueInstantPointOrderById(whichUnit, order, x, y, instantTargetWidget) end

---@param whichUnit unit
---@param order string
---@param targetWidget widget
---@param instantTargetWidget widget
---@return boolean
function IssueInstantTargetOrder(whichUnit, order, targetWidget, instantTargetWidget) end

---@param whichUnit unit
---@param order integer
---@param targetWidget widget
---@param instantTargetWidget widget
---@return boolean
function IssueInstantTargetOrderById(whichUnit, order, targetWidget, instantTargetWidget) end

---@param whichPeon unit
---@param unitToBuild string
---@param x real
---@param y real
---@return boolean
function IssueBuildOrder(whichPeon, unitToBuild, x, y) end

---@param whichPeon unit
---@param unitId integer
---@param x real
---@param y real
---@return boolean
function IssueBuildOrderById(whichPeon, unitId, x, y) end

---@param forWhichPlayer player
---@param neutralStructure unit
---@param unitToBuild string
---@return boolean
function IssueNeutralImmediateOrder(forWhichPlayer, neutralStructure, unitToBuild) end

---@param forWhichPlayer player
---@param neutralStructure unit
---@param unitId integer
---@return boolean
function IssueNeutralImmediateOrderById(forWhichPlayer, neutralStructure, unitId) end

---@param forWhichPlayer player
---@param neutralStructure unit
---@param unitToBuild string
---@param x real
---@param y real
---@return boolean
function IssueNeutralPointOrder(forWhichPlayer, neutralStructure, unitToBuild, x, y) end

---@param forWhichPlayer player
---@param neutralStructure unit
---@param unitId integer
---@param x real
---@param y real
---@return boolean
function IssueNeutralPointOrderById(forWhichPlayer, neutralStructure, unitId, x, y) end

---@param forWhichPlayer player
---@param neutralStructure unit
---@param unitToBuild string
---@param target widget
---@return boolean
function IssueNeutralTargetOrder(forWhichPlayer, neutralStructure, unitToBuild, target) end

---@param forWhichPlayer player
---@param neutralStructure unit
---@param unitId integer
---@param target widget
---@return boolean
function IssueNeutralTargetOrderById(forWhichPlayer, neutralStructure, unitId, target) end

---@param whichUnit unit
---@return integer
function GetUnitCurrentOrder(whichUnit) end

---@param whichUnit unit
---@param amount integer
---@return nothing
function SetResourceAmount(whichUnit, amount) end

---@param whichUnit unit
---@param amount integer
---@return nothing
function AddResourceAmount(whichUnit, amount) end

---@param whichUnit unit
---@return integer
function GetResourceAmount(whichUnit) end

---@param waygate unit
---@return real
function WaygateGetDestinationX(waygate) end

---@param waygate unit
---@return real
function WaygateGetDestinationY(waygate) end

---@param waygate unit
---@param x real
---@param y real
---@return nothing
function WaygateSetDestination(waygate, x, y) end

---@param waygate unit
---@param activate boolean
---@return nothing
function WaygateActivate(waygate, activate) end

---@param waygate unit
---@return boolean
function WaygateIsActive(waygate) end

---@param itemId integer
---@param currentStock integer
---@param stockMax integer
---@return nothing
function AddItemToAllStock(itemId, currentStock, stockMax) end

---@param whichUnit unit
---@param itemId integer
---@param currentStock integer
---@param stockMax integer
---@return nothing
function AddItemToStock(whichUnit, itemId, currentStock, stockMax) end

---@param unitId integer
---@param currentStock integer
---@param stockMax integer
---@return nothing
function AddUnitToAllStock(unitId, currentStock, stockMax) end

---@param whichUnit unit
---@param unitId integer
---@param currentStock integer
---@param stockMax integer
---@return nothing
function AddUnitToStock(whichUnit, unitId, currentStock, stockMax) end

---@param itemId integer
---@return nothing
function RemoveItemFromAllStock(itemId) end

---@param whichUnit unit
---@param itemId integer
---@return nothing
function RemoveItemFromStock(whichUnit, itemId) end

---@param unitId integer
---@return nothing
function RemoveUnitFromAllStock(unitId) end

---@param whichUnit unit
---@param unitId integer
---@return nothing
function RemoveUnitFromStock(whichUnit, unitId) end

---@param slots integer
---@return nothing
function SetAllItemTypeSlots(slots) end

---@param slots integer
---@return nothing
function SetAllUnitTypeSlots(slots) end

---@param whichUnit unit
---@param slots integer
---@return nothing
function SetItemTypeSlots(whichUnit, slots) end

---@param whichUnit unit
---@param slots integer
---@return nothing
function SetUnitTypeSlots(whichUnit, slots) end

---@param whichUnit unit
---@return integer
function GetUnitUserData(whichUnit) end

---@param whichUnit unit
---@param data integer
---@return nothing
function SetUnitUserData(whichUnit, data) end

---@param number integer
---@return player
function Player(number) end

---@return player
function GetLocalPlayer() end

---@param whichPlayer player
---@param otherPlayer player
---@return boolean
function IsPlayerAlly(whichPlayer, otherPlayer) end

---@param whichPlayer player
---@param otherPlayer player
---@return boolean
function IsPlayerEnemy(whichPlayer, otherPlayer) end

---@param whichPlayer player
---@param whichForce force
---@return boolean
function IsPlayerInForce(whichPlayer, whichForce) end

---@param whichPlayer player
---@return boolean
function IsPlayerObserver(whichPlayer) end

---@param x real
---@param y real
---@param whichPlayer player
---@return boolean
function IsVisibleToPlayer(x, y, whichPlayer) end

---@param whichLocation location
---@param whichPlayer player
---@return boolean
function IsLocationVisibleToPlayer(whichLocation, whichPlayer) end

---@param x real
---@param y real
---@param whichPlayer player
---@return boolean
function IsFoggedToPlayer(x, y, whichPlayer) end

---@param whichLocation location
---@param whichPlayer player
---@return boolean
function IsLocationFoggedToPlayer(whichLocation, whichPlayer) end

---@param x real
---@param y real
---@param whichPlayer player
---@return boolean
function IsMaskedToPlayer(x, y, whichPlayer) end

---@param whichLocation location
---@param whichPlayer player
---@return boolean
function IsLocationMaskedToPlayer(whichLocation, whichPlayer) end

---@param whichPlayer player
---@return race
function GetPlayerRace(whichPlayer) end

---@param whichPlayer player
---@return integer
function GetPlayerId(whichPlayer) end

---@param whichPlayer player
---@param includeIncomplete boolean
---@return integer
function GetPlayerUnitCount(whichPlayer, includeIncomplete) end

---@param whichPlayer player
---@param unitName string
---@param includeIncomplete boolean
---@param includeUpgrades boolean
---@return integer
function GetPlayerTypedUnitCount(whichPlayer, unitName, includeIncomplete, includeUpgrades) end

---@param whichPlayer player
---@param includeIncomplete boolean
---@return integer
function GetPlayerStructureCount(whichPlayer, includeIncomplete) end

---@param whichPlayer player
---@param whichPlayerState playerstate
---@return integer
function GetPlayerState(whichPlayer, whichPlayerState) end

---@param whichPlayer player
---@param whichPlayerScore playerscore
---@return integer
function GetPlayerScore(whichPlayer, whichPlayerScore) end

---@param sourcePlayer player
---@param otherPlayer player
---@param whichAllianceSetting alliancetype
---@return boolean
function GetPlayerAlliance(sourcePlayer, otherPlayer, whichAllianceSetting) end

---@param whichPlayer player
---@return real
function GetPlayerHandicap(whichPlayer) end

---@param whichPlayer player
---@return real
function GetPlayerHandicapXP(whichPlayer) end

---@param whichPlayer player
---@return real
function GetPlayerHandicapReviveTime(whichPlayer) end

---@param whichPlayer player
---@return real
function GetPlayerHandicapDamage(whichPlayer) end

---@param whichPlayer player
---@param handicap real
---@return nothing
function SetPlayerHandicap(whichPlayer, handicap) end

---@param whichPlayer player
---@param handicap real
---@return nothing
function SetPlayerHandicapXP(whichPlayer, handicap) end

---@param whichPlayer player
---@param handicap real
---@return nothing
function SetPlayerHandicapReviveTime(whichPlayer, handicap) end

---@param whichPlayer player
---@param handicap real
---@return nothing
function SetPlayerHandicapDamage(whichPlayer, handicap) end

---@param whichPlayer player
---@param techid integer
---@param maximum integer
---@return nothing
function SetPlayerTechMaxAllowed(whichPlayer, techid, maximum) end

---@param whichPlayer player
---@param techid integer
---@return integer
function GetPlayerTechMaxAllowed(whichPlayer, techid) end

---@param whichPlayer player
---@param techid integer
---@param levels integer
---@return nothing
function AddPlayerTechResearched(whichPlayer, techid, levels) end

---@param whichPlayer player
---@param techid integer
---@param setToLevel integer
---@return nothing
function SetPlayerTechResearched(whichPlayer, techid, setToLevel) end

---@param whichPlayer player
---@param techid integer
---@param specificonly boolean
---@return boolean
function GetPlayerTechResearched(whichPlayer, techid, specificonly) end

---@param whichPlayer player
---@param techid integer
---@param specificonly boolean
---@return integer
function GetPlayerTechCount(whichPlayer, techid, specificonly) end

---@param whichPlayer player
---@param newOwner integer
---@return nothing
function SetPlayerUnitsOwner(whichPlayer, newOwner) end

---@param whichPlayer player
---@param toWhichPlayers force
---@param flag boolean
---@return nothing
function CripplePlayer(whichPlayer, toWhichPlayers, flag) end

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

