local Abilities = require("Config.Abilities")
local EventCenter = require("Lib.EventCenter")
local Timer = require("Lib.Timer")

--region meta

Abilities.RageGenerator = {
    ID = FourCC("A019"),
    RageGeneratorAutoGen = 0.02,
    RageGeneratorPerAttack = 0.05,
    RageGeneratorPerHit = 2,
    ExitCombatInterval = 6,
}

--endregion

---@class RageGenerator
local cls = class("RageGenerator")

local combatUnits = {}

local function isUnitRageGenerator(u)
    return GetUnitAbilityLevel(u, Abilities.RageGenerator.ID) > 0
end

local exitCombatTimer = {}

local function waitForExitCombat(unit)
    local timer = exitCombatTimer[unit]
    if timer then
        timer:Stop()
    end
    timer = Timer.new(function()
        combatUnits[unit] = -1
        ExTextState(unit, "离开战斗")
    end, Abilities.RageGenerator.ExitCombatInterval, 1)
    exitCombatTimer[unit] = timer
    timer:Start()
end

ExTriggerRegisterUnitAcquire(function(caster, target)
    if isUnitRageGenerator(caster) then
        if combatUnits[caster] ~= 1 then
            ExTextState(caster, "进入战斗")
        end
        combatUnits[caster] = 1
        waitForExitCombat(caster)
    end
    if isUnitRageGenerator(target) then
        if combatUnits[target] ~= 1 then
            ExTextState(target, "进入战斗")
        end
        combatUnits[target] = 1
        waitForExitCombat(target)
    end
end)

ExTriggerRegisterNewUnit(function(unit)
    if isUnitRageGenerator(unit) then
        SetUnitState(unit, UNIT_STATE_MANA, 0)
        combatUnits[unit] = -1
    end
end)

EventCenter.RegisterPlayerUnitDamaged:Emit(function(caster, target, damage, _, _, isAttack)
    if damage < 1 then
        return
    end

    if isUnitRageGenerator(caster) then
        if isAttack then
            local mana = GetUnitState(caster, UNIT_STATE_MAX_MANA) * Abilities.RageGenerator.RageGeneratorPerAttack
            SetUnitState(caster, UNIT_STATE_MANA, GetUnitState(caster, UNIT_STATE_MANA) + mana)
            waitForExitCombat(caster)
        end
    end
    if isUnitRageGenerator(target) then
        local percent = damage / GetUnitState(target, UNIT_STATE_MAX_LIFE)
        local mana = GetUnitState(target, UNIT_STATE_MAX_MANA) * percent * Abilities.RageGenerator.RageGeneratorPerHit
        SetUnitState(target, UNIT_STATE_MANA, GetUnitState(target, UNIT_STATE_MANA) + mana)
        waitForExitCombat(target)
    end
end)

coroutine.start(function()
    while true do
        coroutine.wait(1)
        for unit, flag in pairs(combatUnits) do
            if flag == -1 then
                local mana = GetUnitState(unit, UNIT_STATE_MAX_MANA) * Abilities.RageGenerator.RageGeneratorAutoGen * flag
                SetUnitState(unit, UNIT_STATE_MANA, GetUnitState(unit, UNIT_STATE_MANA) + mana)
            end
        end
    end
end)

return cls
