-- 天神下凡-剑刃风暴

local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local Const = require("Config.Const")
local UnitAttribute = require("Objects.UnitAttribute")
local DeepWounds = require("Ability.DeepWounds")
local BuffBase = require("Objects.BuffBase")

--region meta

local Meta = {
    ID = FourCC("A01C"),
    Cost = 0.15,
    Interval = 1,
    Damage = 0.5,
    DeepWoundsStack = 1,
    DamageIncrease = 0.2,
    DamageReduction = 0.1,
    AOE = 397,
    Enlarge = 1.3,
    AvatarDurationMult = 2,
}

Abilities.BladeStorm = Meta

BlzSetAbilityResearchTooltip(Meta.ID, "学习天神剑刃风暴 - [|cffffcc00%d级|r]", 0)
BlzSetAbilityResearchExtendedTooltip(Meta.ID, string.format([[化作一股具有毁灭性力量的剑刃风暴，打击附近所有目标，每秒消耗|cffff8c00%s|r的怒气，造成|cffff8c00%s|r的攻击伤害并造成重伤效果，直到怒气耗尽。然后化身为巨人，使你造成的伤害提高|cffff8c00%s|r，受到的伤害降低|cffff8c00%s|r，普通攻击会附带重伤效果，持续时间等同于剑刃风暴的持续时间的|cffff8c00%s|r。

|cff99ccff冷却时间|r - 30秒]],
        string.formatPercentage(Meta.Cost), string.formatPercentage(Meta.Damage), string.formatPercentage(Meta.DamageIncrease), string.formatPercentage(Meta.DamageReduction), string.formatPercentage(Meta.AvatarDurationMult)
), 0)

for i = 1, 1 do
    BlzSetAbilityTooltip(Meta.ID, string.format("天神剑刃风暴 - [|cffffcc00%s级|r]", i), i - 1)
    BlzSetAbilityExtendedTooltip(Meta.ID, string.format(
            [[化作一股具有毁灭性力量的剑刃风暴，打击附近所有目标，每秒消耗|cffff8c00%s|r的怒气，造成|cffff8c00%s|r的攻击伤害并造成重伤效果，直到怒气耗尽。然后化身为巨人，使你造成的伤害提高|cffff8c00%s|r，受到的伤害降低|cffff8c00%s|r，普通攻击会附带重伤效果，持续时间等同于剑刃风暴的持续时间的|cffff8c00%s|r。

|cff99ccff冷却时间|r - 30秒]],
            string.formatPercentage(Meta.Cost), string.formatPercentage(Meta.Damage), string.formatPercentage(Meta.DamageIncrease), string.formatPercentage(Meta.DamageReduction), string.formatPercentage(Meta.AvatarDurationMult)),
            i - 1)
end

--endregion

---@class Avatar : BuffBase
local Avatar = class("Avatar", BuffBase)

function Avatar:OnEnable()
    --SetUnitScale(self.target, Meta.Enlarge, Meta.Enlarge, Meta.Enlarge)
    SetUnitVertexColor(self.target, 255, 255, 15, 255)
    local attr = UnitAttribute.GetAttr(self.target)
    attr.damageAmplification = attr.damageAmplification + Meta.DamageIncrease
    attr.damageReduction = attr.damageReduction + Meta.DamageReduction
end

function Avatar:OnDisable()
    --SetUnitScale(self.target, 1, 1, 1)
    SetUnitVertexColor(self.target, 255, 255, 255, 255)
    local attr = UnitAttribute.GetAttr(self.target)
    attr.damageAmplification = attr.damageAmplification - Meta.DamageIncrease
    attr.damageReduction = attr.damageReduction - Meta.DamageReduction
end

local cls = class("BladeStorm")

EventCenter.RegisterPlayerUnitSpellChannel:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        if ExGetUnitManaPortion(data.caster) < Meta.Cost then
            ExTextState(data.caster, "怒气不足")
            IssueImmediateOrderById(data.caster, Const.OrderId_Stop)
        end
    end
})

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        coroutine.start(function()
            local caster = data.caster

            AddUnitAnimationProperties(caster, "spin", true)
            local casterPlayer = GetOwningPlayer(caster)
            local attr = UnitAttribute.GetAttr(caster)
            local duration = 0
            while ExGetUnitManaPortion(caster) >= Meta.Cost do
                coroutine.wait(Meta.Interval)
                if ExIsUnitDead(caster) then
                    break
                end

                ExAddUnitMana(caster, ExGetUnitMaxMana(caster) * Meta.Cost * -1)
                duration = duration + Meta.Interval
                local damage = attr:SimAttack(UnitAttribute.HeroAttributeType.Strength) * Meta.Damage
                ExGroupEnumUnitsInRange(GetUnitX(caster), GetUnitY(caster), Meta.AOE, function(unit)
                    if IsUnitEnemy(unit, casterPlayer) and not ExIsUnitDead(unit) then
                        EventCenter.Damage:Emit({
                            whichUnit = caster,
                            target = unit,
                            amount = damage,
                            attack = false,
                            ranged = true,
                            attackType = ATTACK_TYPE_HERO,
                            damageType = DAMAGE_TYPE_DIVINE,
                            weaponType = WEAPON_TYPE_WHOKNOWS,
                            outResult = {},
                        })
                        if not ExIsUnitDead(unit) and not IsUnitType(unit, UNIT_TYPE_MECHANICAL) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE) then
                            DeepWounds.Cast(caster, unit)
                        end
                    end
                end)
            end
            AddUnitAnimationProperties(caster, "spin", false)

            if not ExIsUnitDead(caster) then
                ExAddSpecialEffectTarget("Abilities/Spells/Human/Avatar/AvatarCaster.mdl", caster, "overhead", 2)
                Avatar.new(caster, caster, duration, 999, {})
            end
        end)
    end
})

EventCenter.RegisterPlayerUnitDamaged:Emit(function(caster, target, _, _, _, isAttack)
    if not isAttack then
        return
    end

    if target == nil then
        return
    end

    if ExIsUnitDead(target) or IsUnitType(target, UNIT_TYPE_MECHANICAL) or IsUnitType(target, UNIT_TYPE_STRUCTURE) then
        return
    end

    local buff = BuffBase.FindBuffByClassName(caster, Avatar.__cname)

    if not buff then
        return
    end

    DeepWounds.Cast(caster, target)
end)

return cls
