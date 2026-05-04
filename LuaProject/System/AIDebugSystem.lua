---@diagnostic disable: undefined-global, missing-return

local SystemBase = require("System.SystemBase")
local Utils = require("Lib.Utils")

local DebugPlayerId = 1
local DebugPlayer = Player(DebugPlayerId)
local SnapshotInterval = 15

local HeroIds = {
    [FourCC("Ekee")] = true,
    [FourCC("Emoo")] = true,
    [FourCC("Edem")] = true,
    [FourCC("Ewar")] = true,
}

local WatchIds = {
    FourCC("etol"),
    FourCC("eaom"),
    FourCC("emow"),
    FourCC("eate"),
    FourCC("ewsp"),
    FourCC("earc"),
    FourCC("esen"),
    FourCC("edry"),
    FourCC("edoc"),
    FourCC("ebal"),
    FourCC("Ekee"),
    FourCC("Emoo"),
    FourCC("Edem"),
    FourCC("Ewar"),
}

local WatchIdLookup = {}
for _, unitType in ipairs(WatchIds) do
    WatchIdLookup[unitType] = true
end

local function idName(id)
    if not id or id == 0 then
        return "none"
    end
    return Utils.CCFour(id)
end

local function samePlayer(unit)
    return unit and GetOwningPlayer(unit) == DebugPlayer
end

local function log(message)
    print("[AI DEBUG] " .. message)
end

local function raceName(race)
    if race == RACE_HUMAN then
        return "human"
    elseif race == RACE_ORC then
        return "orc"
    elseif race == RACE_UNDEAD then
        return "undead"
    elseif race == RACE_NIGHTELF then
        return "nightelf"
    end
    return tostring(race)
end

local function controllerName(controller)
    if controller == MAP_CONTROL_USER then
        return "user"
    elseif controller == MAP_CONTROL_COMPUTER then
        return "computer"
    elseif controller == MAP_CONTROL_RESCUABLE then
        return "rescuable"
    elseif controller == MAP_CONTROL_NEUTRAL then
        return "neutral"
    elseif controller == MAP_CONTROL_CREEP then
        return "creep"
    end
    return tostring(controller)
end

local function playerStateLine()
    return "player=" .. tostring(DebugPlayerId)
            .. " controller=" .. controllerName(GetPlayerController(DebugPlayer))
            .. " race=" .. raceName(GetPlayerRace(DebugPlayer))
            .. " slot=" .. tostring(GetPlayerSlotState(DebugPlayer))
            .. " aiDifficulty=" .. tostring(GetAIDifficulty(DebugPlayer))
            .. " gold=" .. tostring(GetPlayerState(DebugPlayer, PLAYER_STATE_RESOURCE_GOLD))
            .. " lumber=" .. tostring(GetPlayerState(DebugPlayer, PLAYER_STATE_RESOURCE_LUMBER))
            .. " food=" .. tostring(GetPlayerState(DebugPlayer, PLAYER_STATE_RESOURCE_FOOD_USED))
            .. "/" .. tostring(GetPlayerState(DebugPlayer, PLAYER_STATE_RESOURCE_FOOD_CAP))
end

local function describeUnit(unit)
    if not unit then
        return "nil"
    end
    return idName(GetUnitTypeId(unit))
            .. " name=" .. GetUnitName(unit)
            .. " order=" .. idName(GetUnitCurrentOrder(unit))
            .. " hp=" .. tostring(math.floor(GetWidgetLife(unit)))
            .. " xy=" .. tostring(math.floor(GetUnitX(unit))) .. "," .. tostring(math.floor(GetUnitY(unit)))
end

local function registerPlayerUnitEvent(eventId, callback)
    local trigger = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trigger, eventId)
    ExTriggerAddAction(trigger, callback)
end

---@class AIDebugSystem : SystemBase
local cls = class("AIDebugSystem", SystemBase)

function cls:ctor()
    self.time = 0
    self.lastHeroCount = -1
    self:_registerEvents()
    log("constructed before melee startup: " .. playerStateLine())
end

function cls:Awake()
    log("awake after melee startup: " .. playerStateLine())
    self:_snapshot("awake")
end

function cls:Update(dt)
    self.time = self.time + dt
    if self.time >= SnapshotInterval then
        self.time = self.time % SnapshotInterval
        self:_snapshot("periodic")
    end
end

function cls:_registerEvents()
    ExTriggerRegisterNewUnit(function(unit)
        if samePlayer(unit) then
            log("unit enters map: " .. describeUnit(unit))
        end
    end)

    ExTriggerRegisterUnitDeath(function(unit)
        if samePlayer(unit) then
            log("unit dies: " .. describeUnit(unit))
        end
    end)

    ExTriggerRegisterUnitLearn(0, function(unit, level, skill)
        if samePlayer(unit) then
            log("hero learns: " .. describeUnit(unit) .. " skill=" .. idName(skill) .. " level=" .. tostring(level))
        end
    end)

    registerPlayerUnitEvent(EVENT_PLAYER_UNIT_CONSTRUCT_START, function()
        local unit = GetConstructingStructure()
        if samePlayer(unit) then
            log("construct start: " .. describeUnit(unit))
        end
    end)

    registerPlayerUnitEvent(EVENT_PLAYER_UNIT_CONSTRUCT_FINISH, function()
        local unit = GetConstructingStructure()
        if samePlayer(unit) then
            log("construct finish: " .. describeUnit(unit))
        end
    end)

    registerPlayerUnitEvent(EVENT_PLAYER_UNIT_CONSTRUCT_CANCEL, function()
        local unit = GetConstructingStructure()
        if samePlayer(unit) then
            log("construct cancel: " .. describeUnit(unit))
        end
    end)

    registerPlayerUnitEvent(EVENT_PLAYER_UNIT_TRAIN_START, function()
        local trainer = GetTriggerUnit()
        if samePlayer(trainer) then
            log("train start: trainer=" .. describeUnit(trainer) .. " type=" .. idName(GetTrainedUnitType()))
        end
    end)

    registerPlayerUnitEvent(EVENT_PLAYER_UNIT_TRAIN_FINISH, function()
        local trained = GetTrainedUnit()
        if samePlayer(trained) then
            log("train finish: " .. describeUnit(trained))
        end
    end)

    registerPlayerUnitEvent(EVENT_PLAYER_UNIT_TRAIN_CANCEL, function()
        local trainer = GetTriggerUnit()
        if samePlayer(trainer) then
            log("train cancel: trainer=" .. describeUnit(trainer) .. " type=" .. idName(GetTrainedUnitType()))
        end
    end)

    registerPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_ORDER, function()
        local unit = GetTriggerUnit()
        if samePlayer(unit) then
            log("order immediate: " .. describeUnit(unit) .. " issued=" .. idName(GetIssuedOrderId()))
        end
    end)

    registerPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, function()
        local unit = GetTriggerUnit()
        if samePlayer(unit) then
            log("order point: " .. describeUnit(unit) .. " issued=" .. idName(GetIssuedOrderId()))
        end
    end)

    registerPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, function()
        local unit = GetTriggerUnit()
        if samePlayer(unit) then
            log("order target: " .. describeUnit(unit) .. " issued=" .. idName(GetIssuedOrderId())
                    .. " target=" .. describeUnit(GetOrderTargetUnit()))
        end
    end)

    registerPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_UNIT_ORDER, function()
        local unit = GetTriggerUnit()
        if samePlayer(unit) then
            log("order unit: " .. describeUnit(unit) .. " issued=" .. idName(GetIssuedOrderId())
                    .. " target=" .. describeUnit(GetOrderTargetUnit()))
        end
    end)
end

function cls:_snapshot(reason)
    local counts = {}
    local details = {}
    local heroes = 0
    ExGroupEnumUnitsInMap(function(unit)
        if samePlayer(unit) then
            local unitType = GetUnitTypeId(unit)
            counts[unitType] = (counts[unitType] or 0) + 1
            if WatchIdLookup[unitType] then
                table.insert(details, describeUnit(unit))
            end
            if HeroIds[unitType] then
                heroes = heroes + 1
            end
        end
    end)

    log("snapshot " .. reason .. ": " .. playerStateLine() .. " heroes=" .. tostring(heroes))
    if heroes ~= self.lastHeroCount then
        self.lastHeroCount = heroes
        log("hero count changed: " .. tostring(heroes))
    end

    for _, unitType in ipairs(WatchIds) do
        local count = counts[unitType] or 0
        if count > 0 then
            log("count " .. idName(unitType) .. "=" .. tostring(count))
        end
    end

    for _, detail in ipairs(details) do
        log("unit " .. detail)
    end
end

return cls