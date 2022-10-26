-- 溃烂之伤

local EventCenter = require("Lib.EventCenter")
local BuffBase = require("Objects.BuffBase")
local Abilities = require("Config.Abilities")
local Timer = require("Lib.Timer")

Abilities.FesteringWound = {
    ID = FourCC("xxxx"),
    Duration = 30,
    Damage = 15,
    Mana = 3,
}

---@class FesteringWound : BuffBase
local cls = class("FesteringWound", BuffBase)

function cls:Burst(stacks)
    stacks = stacks or 1
    stacks = math.min(self.stack, stacks)

    if stacks <= 0 then
        return
    end

    local damage = Abilities.FesteringWound.Damage * stacks
    local mana = Abilities.FesteringWound.Mana * stacks
    UnitDamageTarget(self.caster, self.target, damage, false, true, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS)
    SetUnitState(self.caster, UNIT_STATE_MANA, GetUnitState(self.caster, UNIT_STATE_MANA) + mana)

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

    local debuff = BuffBase.FindBuffByClassName(target, cls.__cname)
    if not debuff then
        return
    end

    debuff:Burst()
end)

return cls
