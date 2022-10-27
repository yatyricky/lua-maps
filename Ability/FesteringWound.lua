-- 溃烂之伤

local EventCenter = require("Lib.EventCenter")
local BuffBase = require("Objects.BuffBase")
local Abilities = require("Config.Abilities")
local Timer = require("Lib.Timer")

--region meta

Abilities.FesteringWound = {
    ID = FourCC("A00A"),
    Duration = 30,
    Damage = 15,
    ManaRegen = 50,
    ExtraMana = 30,
}

BlzSetAbilityTooltip(Abilities.FesteringWound.ID, "溃烂之伤", 0)
BlzSetAbilityExtendedTooltip(Abilities.FesteringWound.ID, string.format(
        [[死亡骑士的普通攻击会恢复|cffff8c00%s|r法力值，并导致目标身上的一层溃烂之伤爆发，造成|cffff8c00%s|r点额外伤害并为死亡骑士额外恢复|cffff8c00%s|r点法力值。

|cff99ccff持续时间|r - %s秒]],
        Abilities.FesteringWound.ManaRegen, Abilities.FesteringWound.Damage, Abilities.FesteringWound.ExtraMana, Abilities.FesteringWound.Duration),
        0)

--endregion

---@class FesteringWound : BuffBase
local cls = class("FesteringWound", BuffBase)

function cls:OnEnable()
    print("apply:", self.stack, self.target)
    self.sfx = AddSpecialEffectTarget("Abilities/Spells/Other/Parasite/ParasiteTarget.mdl", self.target, "overhead")
    --BlzSetSpecialEffectColor(self.sfx, 255, 128, 0)
end

function cls:OnDisable()
    print("removed", self.target)
    DestroyEffect(self.sfx)
end

function cls:Burst(stacks)
    stacks = stacks or 1
    stacks = math.min(self.stack, stacks)

    if stacks <= 0 then
        return
    end

    local damage = Abilities.FesteringWound.Damage * stacks
    local mana = Abilities.FesteringWound.ExtraMana * stacks
    UnitDamageTarget(self.caster, self.target, damage, false, true, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS)
    SetUnitState(self.caster, UNIT_STATE_MANA, GetUnitState(self.caster, UNIT_STATE_MANA) + mana)

    ExAddSpecialEffectTarget("Abilities/Spells/Undead/ReplenishMana/ReplenishManaCaster.mdl", self.caster, "origin", 0.1)

    self:DecreaseStack(stacks)
end

EventCenter.RegisterPlayerUnitDamaged:Emit(function(caster, target, _, _, _, isAttack)
    if not isAttack then
        return
    end

    local level = GetUnitAbilityLevel(caster, Abilities.FesteringWound.ID)
    if level <= 0 then
        return
    end

    SetUnitState(caster, UNIT_STATE_MANA, GetUnitState(caster, UNIT_STATE_MANA) + Abilities.FesteringWound.ManaRegen)

    local debuff = BuffBase.FindBuffByClassName(target, cls.__cname)
    if not debuff then
        return
    end

    debuff:Burst()
end)

return cls
