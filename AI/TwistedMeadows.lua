local EventCenter = require("Lib.EventCenter")
local Const = require("Config.Const")
local Vector2 = require("Lib.Vector2")

local sequence = {
    FourCC("AEmb"),
    FourCC("A015"),
    FourCC("A015"),
    FourCC("AEmb"),
    FourCC("A015"),
    FourCC("AEme"),
    FourCC("AEmb"),
    FourCC("AEim"),
    FourCC("AEim"),
    FourCC("AEim"),
}

local DH = FourCC("Edem")
local camps = {}

local basePos = Vector2.new(-3571, 4437)

local Interval = 1.3

local cls = class("TwistedMeadows")

function cls:ctor()
    local trigger = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trigger, EVENT_PLAYER_HERO_LEVEL)
    ExTriggerAddAction(trigger, function()
        local unit = GetTriggerUnit()
        --local player = GetOwningPlayer(unit)
        if GetUnitTypeId(unit) == DH then
            local level = GetUnitLevel(unit)
            SelectHeroSkill(unit, sequence[level])
        end
    end)

    local finishConstruction = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(finishConstruction, EVENT_PLAYER_UNIT_CONSTRUCT_FINISH)
    ExTriggerAddAction(finishConstruction, function()
        local unit = GetTriggerUnit()
        if GetUnitTypeId(unit) == FourCC("eate") then
            DestroyTrigger(finishConstruction)
            self.altar = unit
        end
    end)

    self.time = 0

    self.done = false
    self.unitFarm = {}

    ExTriggerRegisterUnitAcquire(function(caster, target)
        if (ExGetUnitPlayerId(caster) == 0 and ExGetUnitPlayerId(target) == 1) or (ExGetUnitPlayerId(caster) == 1 and ExGetUnitPlayerId(target) == 0) then
            self.done = true
        end
    end)
end

local p1 = Player(1)
local p0 = Player(0)

function cls:Update(dt)
    if not self.done and self.altar ~= nil then
        IssueTrainOrderByIdBJ(self.altar, DH)
    end

    self.time = self.time + dt
    if self.time >= Interval then
        self.time = self.time % Interval
        SetPlayerState(p1, PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(p1, PLAYER_STATE_RESOURCE_GOLD) + 5)
        if not self.done then
            self:run()
        end
    end
end

function cls:run()
    local hp = 0
    local p2 = Player(1)
    local force = {}
    ExGroupEnumUnitsInMap(function(unit)
        if GetOwningPlayer(unit) == p2 and not ExIsUnitDead(unit) and not IsUnitType(unit, UNIT_TYPE_PEON) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE) then
            hp = hp + GetWidgetLife(unit)
            table.insert(force, unit)
        end
    end)

    local positions = {}
    EventCenter.InitCamp:Emit(positions)
    table.sort(positions, function(a, b)
        local distA = (basePos - a.p):GetMagnitude()
        local distB = (basePos - b.p):GetMagnitude()
        return a.hp + distA < b.hp + distB
    end)

    local firstCamp = positions[1]
    local vec = Vector2.new()
    if firstCamp.hp > 1 and firstCamp.hp < hp then
        for _, v in ipairs(force) do
            local dist = vec:MoveToUnit(v):Sub(firstCamp.p):GetMagnitude()
            if dist > 600 then
                IssuePointOrderById(v, Const.OrderId_Attack, firstCamp.p.x, firstCamp.p.y)
            end
        end
    end
end

return cls
