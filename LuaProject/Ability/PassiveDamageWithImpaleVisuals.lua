local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local BuffBase = require("Objects.BuffBase")
local BloodPlague = require("Ability.BloodPlague")
local FrostPlague = require("Ability.FrostPlague")
local UnholyPlague = require("Ability.UnholyPlague")

--region meta

local Meta = {
    ID = FourCC("A01J"),
    Chance = 0.2,
    Damage = 400,
}

Abilities.PassiveDamageWithImpaleVisuals = Meta

--endregion

local cls = class("PassiveDamageWithImpaleVisuals")

EventCenter.RegisterPlayerUnitDamaged:Emit(function(caster, target, _, _, _, isAttack)
    if not isAttack then
        return
    end

    if target == nil or IsUnitType(target, UNIT_TYPE_MECHANICAL) or IsUnitType(target, UNIT_TYPE_STRUCTURE) then
        return
    end

    local abilityLevel = GetUnitAbilityLevel(caster, Meta.ID)
    if abilityLevel < 1 then
        return
    end

    if math.random() >= Meta.Chance then
        return
    end

    EventCenter.Damage:Emit({
        whichUnit = caster,
        target = target,
        amount = Meta.Damage,
        attack = false,
        ranged = false,
        attackType = ATTACK_TYPE_HERO,
        damageType = DAMAGE_TYPE_NORMAL,
        weaponType = WEAPON_TYPE_WHOKNOWS,
        outResult = {}
    })

    local v = Vector2.FromUnit(target)
    local sfx = ExAddSpecialEffect("Abilities/Spells/Undead/Impale/ImpaleMissTarget.mdl", v.x, v.y, 1)
    BlzSetSpecialEffectScale(sfx, 2)
end)

return cls
