local EventCenter = require("Lib.EventCenter")
local Timer = require("Lib.Timer")
local PILQueue = require("Lib.PILQueue")
local Abilities = require("Config.Abilities")

local cls = class("TimeWarp")

local Meta = {
    ID = FourCC("A01G"),
    ClockID = FourCC("e002"),
    Duration = 5,
    Radius = 600,
    ReverseSpeed = 5,
}

local queueSize = Meta.Duration / Time.Delta / Meta.ReverseSpeed
local reversing = {}
local recordingUnits = {}

Abilities.TimeWarp = Meta

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        local casterPlayer = GetOwningPlayer(data.caster)

        local clock = CreateUnit(casterPlayer, Meta.ClockID, data.x, data.y, 0)
        SetUnitAnimation(clock, "Stand Alternate")
        SetUnitTimeScale(clock, 10 / Meta.Duration)
        coroutine.start(function()
            coroutine.wait(Meta.Duration)
            SetUnitAnimation(clock, "Death")
            KillUnit(clock)
        end)

        reversing = {}
        coroutine.start(function()
            local units = ExGroupGetUnitsInRange(data.x, data.y, Meta.Radius)
            for i = #units, 1, -1 do
                local u = units[i]
                if IsUnit(u, data.caster) then
                    table.remove(units, i)
                else
                    reversing[u] = true
                end
            end
            local affectedUnits = {}
            while #units > 0 do
                coroutine.step()
                for i = #units, 1, -1 do
                    local u = units[i]
                    local q = recordingUnits[u]
                    if not q then
                        table.remove(units, i)
                    else
                        local d = q:peekright()
                        if d then
                            q:popright()
                            if IsUnitAlly(u, casterPlayer) then
                                local nowDead = ExIsUnitDead(u)
                                if nowDead and not d.dead then
                                    -- revive
                                    local revived = CreateUnit(GetOwningPlayer(u), GetUnitTypeId(u), d.x, d.y, d.f)
                                    SetWidgetLife(revived, d.hp)
                                    ExSetUnitMana(revived, d.mp)
                                    recordingUnits[revived] = q
                                    recordingUnits[u] = nil
                                    reversing[revived] = true
                                    units[i] = revived
                                elseif not nowDead and not d.dead then
                                    SetUnitPosition(u, d.x, d.y)
                                    affectedUnits[u] = true
                                    SetUnitFacing(u, d.f)
                                    SetWidgetLife(u, d.hp)
                                    ExSetUnitMana(u, d.mp)
                                end
                            else
                                if not ExIsUnitDead(u) then
                                    SetUnitPosition(u, d.x, d.y)
                                    affectedUnits[u] = true
                                    SetUnitFacing(u, d.f)
                                else
                                    table.remove(units, i)
                                end
                            end
                        else
                            table.remove(units, i)
                        end
                    end
                end
            end
            for u, _ in pairs(affectedUnits) do
                EventCenter.DefaultOrder:Emit(u)
            end
            reversing = {}
        end)
    end
})

ExTriggerRegisterNewUnit(function(unit)
    if (BlzBitAnd(GetUnitPointValue(unit), 1)) ~= 1 then
        recordingUnits[unit] = PILQueue.new(queueSize)
    end
end)

local decayTrigger = CreateTrigger()
TriggerRegisterAnyUnitEventBJ(decayTrigger, EVENT_PLAYER_UNIT_DECAY)
ExTriggerAddAction(decayTrigger, function()
    recordingUnits[GetDecayingUnit()] = nil
end)

local tm = Timer.new(function()
    for unit, q in pairs(recordingUnits) do
        if not reversing[unit] then
            q:pushright({
                x = GetUnitX(unit),
                y = GetUnitY(unit),
                f = GetUnitFacing(unit),
                hp = GetWidgetLife(unit),
                mp = ExGetUnitMana(unit),
                dead = ExIsUnitDead(unit),
            })
        end
    end
end, Time.Delta * Meta.ReverseSpeed, -1)
tm:Start()

return cls
