-- 判罪

local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local Const = require("Config.Const")

--region meta

local Meta = {
    ID = FourCC("A01B"),
    ThresholdHigh = 0.8,
    ThresholdLow = 0.35,
    MissBackRage = 0.2,
    PerRagePercent = 0.01,
    Cost = 0.2,
    Damage = { 3, 5, 7 },
}

Abilities.Condemn = Meta

BlzSetAbilityResearchTooltip(Meta.ID, "学习判罪 - [|cffffcc00%d级|r]", 0)
BlzSetAbilityResearchExtendedTooltip(Meta.ID, string.format([[让敌人为自己罪孽而遭受折磨，消耗剩余所有怒气造成伤害。只可对生命值高于|cffff8c00%s|r或低于|cffff8c00%s|r的敌人使用。如果未命中，返还|cffff8c00%s|r的怒气。

|cff99ccff怒气消耗|r - %s

|cffffcc001级|r - 每|cffff8c00%s|r的怒气造成|cffff8c00%s|r点伤害。
|cffffcc002级|r - 每|cffff8c00%s|r的怒气造成|cffff8c00%s|r点伤害。
|cffffcc003级|r - 每|cffff8c00%s|r的怒气造成|cffff8c00%s|r点伤害。]],
        string.formatPercentage(Meta.ThresholdHigh), string.formatPercentage(Meta.ThresholdLow), string.formatPercentage(Meta.MissBackRage), string.formatPercentage(Meta.Cost),
        string.formatPercentage(Meta.PerRagePercent), Meta.Damage[1],
        string.formatPercentage(Meta.PerRagePercent), Meta.Damage[2],
        string.formatPercentage(Meta.PerRagePercent), Meta.Damage[3]
), 0)

for i = 1, #Meta.Damage do
    BlzSetAbilityTooltip(Meta.ID, string.format("判罪 - [|cffffcc00%s级|r]", i), i - 1)
    BlzSetAbilityExtendedTooltip(Meta.ID, string.format(
            [[让敌人为自己罪孽而遭受折磨，消耗剩余所有怒气造成伤害，每|cffff8c00%s|r的怒气造成|cffff8c00%s|r点伤害。只可对生命值高于|cffff8c00%s|r或低于|cffff8c00%s|r的敌人使用。如果未命中，返还|cffff8c00%s|r的怒气。

|cff99ccff怒气消耗|r - %s]],
            string.formatPercentage(Meta.PerRagePercent), Meta.Damage[i], string.formatPercentage(Meta.ThresholdHigh), string.formatPercentage(Meta.ThresholdLow), string.formatPercentage(Meta.MissBackRage), string.formatPercentage(Meta.Cost)),
            i - 1)
end

--endregion

local cls = class("Condemn")

local effects = {}

EventCenter.RegisterPlayerUnitSpellChannel:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        local targetHpp = ExGetUnitLifePortion(data.target)
        if targetHpp < Meta.ThresholdHigh and targetHpp > Meta.ThresholdLow then
            ExTextState(data.target, "无法使用")
            return
        end

        if effects[data.caster] ~= nil then
            DestroyEffect(effects[data.caster])
        end
        -- Abilities/Spells/Undead/OrbOfDeath/AnnihilationMissile.mdl
        -- Abilities/Weapons/PhoenixMissile/Phoenix_Missile.mdl
        effects[data.caster] = AddSpecialEffectTarget("Abilities/Spells/Undead/OrbOfDeath/AnnihilationMissile.mdl", data.caster, "weapon,left")
    end
})

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        local level = GetUnitAbilityLevel(data.caster, Meta.ID)
        local damage = ExGetUnitManaPortion(data.caster) / Meta.PerRagePercent * Meta.Damage[level]

        local result = {}
        EventCenter.Damage:Emit({
            whichUnit = data.caster,
            target = data.target,
            amount = damage,
            attack = true,
            ranged = false,
            attackType = ATTACK_TYPE_HERO,
            damageType = DAMAGE_TYPE_MAGIC,
            weaponType = WEAPON_TYPE_WHOKNOWS,
            outResult = result,
        })

        if result.hitResult == Const.HitResult_Miss then
            SetUnitManaBJ(data.caster, Meta.MissBackRage * ExGetUnitMaxMana(data.caster))
            return
        end

        ExTextTag(data.target, damage, { r = 1, g = 0.1, b = 1, a = 1 })
        --ExAddSpecialEffectTarget("Abilities/Spells/Undead/OrbOfDeath/AnnihilationMissile.mdl", data.target, "origin", 0)
        SetUnitManaBJ(data.caster, 0)
    end
})

EventCenter.RegisterPlayerUnitSpellEndCast:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        if effects[data.caster] then
            --BlzSetSpecialEffectZ(effects[data.caster], -1000)
            DestroyEffect(effects[data.caster])
            effects[data.caster] = nil
            --coroutine.start(function()
            --    coroutine.wait(1.5)
            --end)
        end
    end
})

return cls
