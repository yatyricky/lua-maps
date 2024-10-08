-- 月亮井

local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local Vector2 = require("Lib.Vector2")

--region meta

local Meta = {
    ID = FourCC("Ambt"),
    MoonWell = FourCC("emow"),
    --ID = FourCC("A01B"),
    Life = 2,
    Mana = 0.5,
}

Abilities.MoonWellHeal = Meta

--endregion

local cls = class("MoonWellHeal")

local waterEffects = {}
local underConstruction = {}
local moonWells = {}

local function updateWaterLevel(unit)
    local v = Vector2.FromUnit(unit)
    if waterEffects[unit] == nil then
        waterEffects[unit] = AddSpecialEffect("Abilities/Spells/NightElf/MoonWell/MoonWellTarget.mdl", v.x, v.y)
    end
    local eff = waterEffects[unit]
    local level = math.clamp(GetUnitState(unit, UNIT_STATE_MANA) / 500, 0, 1)
    BlzSetSpecialEffectZ(eff, v:GetTerrainZ() + level * 20 + 1)
end

coroutine.start(function()
    while true do
        coroutine.step()
        for unit, _ in pairs(moonWells) do
            if ExIsUnitDead(unit) then
                moonWells[unit] = nil
            else
                if not underConstruction[unit] then
                    updateWaterLevel(unit)
                end
            end
        end
    end
end)

local function getMoonWellTargetWeight(unit)
    return ExGetUnitLifeLoss(unit) / Meta.Life + ExGetUnitManaLoss(unit) / Meta.Mana
end

coroutine.start(function()
    while true do
        coroutine.wait(0.5)
        for unit, _ in pairs(moonWells) do
            if not ExIsUnitDead(unit) and not underConstruction[unit] and ExGetUnitMana(unit) >= 10 then
                local v = Vector2.FromUnit(unit)
                local wellPlayer = GetOwningPlayer(unit)
                local units = table.iWhere(ExGroupGetUnitsInRange(v.x, v.y, 600), function(e)
                    local loss = getMoonWellTargetWeight(e)
                    return not ExIsUnitDead(e) and not IsUnitType(e, UNIT_TYPE_STRUCTURE)
                            and not IsUnitType(e, UNIT_TYPE_MECHANICAL) and not underConstruction[e] and loss > 1
                            and IsUnitAlly(e, wellPlayer)
                end)
                table.sort(units, function(a, b)
                    return getMoonWellTargetWeight(a) > getMoonWellTargetWeight(b)
                end)
                local target = units[1]
                if target then
                    local hpLoss = ExGetUnitLifeLoss(target)
                    local manaLoss = ExGetUnitManaLoss(target)
                    local oldMana = ExGetUnitMana(unit)
                    local wellMana = oldMana

                    local mana4Hp = hpLoss / Meta.Life
                    local cost = math.min(wellMana, mana4Hp)
                    wellMana = wellMana - cost
                    local heal = cost * Meta.Life
                    if heal > 0 then
                        EventCenter.Heal:Emit({
                            caster = unit,
                            target = target,
                            amount = heal,
                        })
                    end

                    local mana4Mp = manaLoss / Meta.Mana
                    cost = math.min(wellMana, mana4Mp)
                    wellMana = wellMana - cost
                    heal = cost * Meta.Mana
                    if heal > 0 then
                        EventCenter.HealMana:Emit({
                            caster = unit,
                            target = target,
                            amount = cost * Meta.Mana,
                        })
                    end

                    ExSetUnitMana(unit, wellMana)

                    if wellMana < oldMana then
                        ExAddSpecialEffectTarget("Abilities/Spells/Human/Heal/HealTarget.mdl", target, "origin", 1)
                        ExAddSpecialEffectTarget("Abilities/Spells/NightElf/MoonWell/MoonWellCasterArt.mdl", unit, "origin", 2)
                    end
                end
            end
        end
    end
end)

ExTriggerRegisterNewUnit(function(unit)
    if GetUnitTypeId(unit) ~= Meta.MoonWell then
        return
    end

    moonWells[unit] = true
end)

local startConstruction = CreateTrigger()
TriggerRegisterAnyUnitEventBJ(startConstruction, EVENT_PLAYER_UNIT_CONSTRUCT_START)
ExTriggerAddAction(startConstruction, function()
    underConstruction[GetTriggerUnit()] = true
end)

local finishConstruction = CreateTrigger()
TriggerRegisterAnyUnitEventBJ(finishConstruction, EVENT_PLAYER_UNIT_CONSTRUCT_FINISH)
ExTriggerAddAction(finishConstruction, function()
    underConstruction[GetTriggerUnit()] = nil
end)

local cancelConstruction = CreateTrigger()
TriggerRegisterAnyUnitEventBJ(cancelConstruction, EVENT_PLAYER_UNIT_CONSTRUCT_CANCEL)
ExTriggerAddAction(cancelConstruction, function()
    underConstruction[GetTriggerUnit()] = nil
end)

ExTriggerRegisterUnitDeath(function(unit)
    if waterEffects[unit] ~= nil then
        DestroyEffect(waterEffects[unit])
        waterEffects[unit] = nil
    end
end)

return cls
