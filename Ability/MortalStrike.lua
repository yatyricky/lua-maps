-- 致死打击

local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local UnitAttribute = require("Objects.UnitAttribute")
local DeepWounds = require("Ability.DeepWounds")
local BuffBase = require("Objects.BuffBase")
local Const = require("Config.Const")

--region meta

local Meta = {
    ID = FourCC("A01A"),
    HealingDecrease = 0.7,
    DamageScale = { 1.7, 2.6, 3.5 },
    Duration = { 10, 20, 30 }
}

Abilities.MortalStrike = Meta

BlzSetAbilityResearchTooltip(Meta.ID, "学习致死打击 - [|cffffcc00%d级|r]", 0)
BlzSetAbilityResearchExtendedTooltip(Meta.ID, string.format([[一次残忍的突袭，对目标造成攻击伤害，并使其受到的治疗效果降低|cffff8c00%s|r，且造成一层|cffff8c00重伤|r效果。

|cff99ccff冷却时间|r - 6秒
|cff99ccff怒气消耗|r - 50%%

|cffffcc001级|r - |cffff8c00%s|r的攻击伤害，持续|cffff8c00%s|r秒。
|cffffcc002级|r - |cffff8c00%s|r的攻击伤害，持续|cffff8c00%s|r秒。
|cffffcc003级|r - |cffff8c00%s|r的攻击伤害，持续|cffff8c00%s|r秒。]],
        string.formatPercentage(Meta.HealingDecrease),
        string.formatPercentage(Meta.DamageScale[1]), Meta.Duration[1],
        string.formatPercentage(Meta.DamageScale[2]), Meta.Duration[2],
        string.formatPercentage(Meta.DamageScale[3]), Meta.Duration[3]
), 0)

for i = 1, #Meta.DamageScale do
    BlzSetAbilityTooltip(Meta.ID, string.format("致死打击 - [|cffffcc00%s级|r]", i), i - 1)
    BlzSetAbilityExtendedTooltip(Meta.ID, string.format(
            [[一次残忍的突袭，对目标造成|cffff8c00%s|r的攻击伤害，并使其受到的治疗效果降低|cffff8c00%s|r，且造成一层|cffff8c00重伤|r效果。

|cff99ccff冷却时间|r - 6秒
|cff99ccff怒气消耗|r - 50%%
|cff99ccff持续时间|r - %s秒]],
            string.formatPercentage(Meta.DamageScale[i]), Meta.HealingDecrease, Meta.Duration[i]),
            i - 1)
end

--endregion

---@class MortalBuff : BuffBase
local MortalBuff = class("MortalBuff", BuffBase)

function MortalBuff:OnEnable()
    local attr = UnitAttribute.GetAttr(self.target)
    attr.healingTaken = attr.healingTaken - Meta.HealingDecrease
end

function MortalBuff:OnDisable()
    local attr = UnitAttribute.GetAttr(self.target)
    attr.healingTaken = attr.healingTaken + Meta.HealingDecrease
end

local cls = class("MortalStrike")

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        local level = GetUnitAbilityLevel(data.caster, Meta.ID)
        local attr = UnitAttribute.GetAttr(data.caster)
        local damage = attr:SimAttack(UnitAttribute.HeroAttributeType.Strength) * Meta.DamageScale[level]

        local result = {}
        EventCenter.Damage:Emit({
            whichUnit = data.caster,
            target = data.target,
            amount = damage,
            attack = true,
            ranged = false,
            attackType = ATTACK_TYPE_HERO,
            damageType = DAMAGE_TYPE_NORMAL,
            weaponType = WEAPON_TYPE_METAL_HEAVY_SLICE,
            outResult = result,
        })

        if result.hitResult == Const.HitResult_Miss then
            return
        end

        DeepWounds.Cast(data.caster, data.target)
        ExTextCriticalStrike(data.target, damage)
        ExAddSpecialEffectTarget("Abilities/Spells/Orc/Disenchant/DisenchantSpecialArt.mdl", data.target, "origin", 1)

        local debuff = BuffBase.FindBuffByClassName(data.target, MortalBuff.__cname)
        if debuff then
            debuff:ResetDuration()
        else
            debuff = MortalBuff.new(data.caster, data.target, Meta.Duration[level], 999, {})
        end
    end
})

return cls
