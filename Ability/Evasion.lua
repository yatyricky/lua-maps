-- 闪避

local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")

--region meta

Abilities.Evasion = {
    ID = FourCC("A015"),
    Chance = { 0.1, 0.2, 0.3 },
}

--BlzSetAbilityTooltip(Abilities.Evasion.ID, string.format("腐臭壁垒", 0), 0)
--BlzSetAbilityExtendedTooltip(Abilities.Evasion.ID, string.format("发出固守咆哮，受到的所有伤害降低|cffff8c00%s|r，持续|cffff8c00%s|r秒。",
--        string.formatPercentage(Abilities.Evasion.Reduction), Abilities.Evasion.Duration), 0)

--endregion

---@class Evasion
local cls = class("Evasion")

EventCenter.RegisterPlayerUnitDamaging:Emit(function(caster, target, damage, weaponType, damageType, isAttack)
    if not isAttack then
        return
    end

    local level = GetUnitAbilityLevel(target, Abilities.Evasion.ID)
    if level <= 0 then
        return
    end

    local chance = Abilities.Evasion.Chance[level]

    if math.random() < chance then
        BlzSetEventDamage(0)
        BlzSetEventWeaponType(WEAPON_TYPE_WHOKNOWS)
        ExTextMiss(target)

        EventCenter.RegisterPlayerUnitAttackMiss:Emit({
            caster = caster,
            target = target,
        })
    end
end)

return cls
