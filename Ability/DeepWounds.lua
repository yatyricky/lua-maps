local BuffBase = require("Objects.BuffBase")
local Abilities = require("Config.Abilities")
local UnitAttribute = require("Objects.UnitAttribute")

--region meta

Abilities.DeepWounds = {
    ID = FourCC("A017"),
    DamageScale = 0.1,
    Duration = 10,
    Interval = 1,
}

BlzSetAbilityTooltip(Abilities.DeepWounds.ID, string.format("重伤"), 0)
BlzSetAbilityExtendedTooltip(Abilities.DeepWounds.ID, string.format("你的压制、致死打击、或者天神下凡状态下的普通攻击，会对敌人造成重伤效果，每|cffff8c00%s|r秒造成|cffff8c00%s|r的攻击伤害，持续|cffff8c00%s|r秒。",
        Abilities.DeepWounds.Interval, string.formatPercentage(Abilities.DeepWounds.DamageScale), Abilities.DeepWounds.Duration), 0)

--endregion

---@class DeepWounds : BuffBase
local cls = class("DeepWounds", BuffBase)

function cls:Update()
    local attr = UnitAttribute.GetAttr(self.caster)
    local damage = attr:SimAttack(UnitAttribute.HeroAttributeType.Agility) * Abilities.DeepWounds.DamageScale * self.stack
    UnitDamageTarget(self.caster, self.target, damage, false, true, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS)
    ExAddSpecialEffectTarget("Objects/Spawnmodels/Human/HumanBlood/HeroBloodElfBlood.mdl", self.target, "origin", 0.5)
end

function cls.Cast(caster, target)
    local debuff = BuffBase.FindBuffByClassName(target, cls.__cname)
    if debuff then
        debuff:IncreaseStack()
    else
        cls.new(caster, target, Abilities.DeepWounds.Duration, Abilities.DeepWounds.Interval, {})
    end
end

return cls
