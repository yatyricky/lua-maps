-- 压制

local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local Const = require("Config.Const")
local Timer = require("Lib.Timer")
local UnitAttribute = require("Objects.UnitAttribute")
local DeepWounds = require("Ability.DeepWounds")

--region meta

Abilities.Overpower = {
    ID = FourCC("A016"),
    TechUnitID = FourCC("e000"),
    DamageScale = 2,
}

BlzSetAbilityTooltip(Abilities.Overpower.ID, string.format("压制"), 0)
BlzSetAbilityExtendedTooltip(Abilities.Overpower.ID, string.format("敌人|cffff8c00躲闪后|r可以使用，压制敌人，造成|cffff8c00%s|r的攻击伤害并造成一层|cffff8c00重伤|r效果。",
        string.formatPercentage(Abilities.Overpower.DamageScale)), 0)

--endregion

local cls = class("Overpower")

cls.unitOverpowers = {}

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Abilities.Overpower.ID,
    ---@param data ISpellData
    handler = function(data)
        local attr = UnitAttribute.GetAttr(data.caster)
        local damage = attr:SimAttack(UnitAttribute.HeroAttributeType.Agility) * Abilities.Overpower.DamageScale
        local result = {}
        EventCenter.Damage:Emit({
            whichUnit = data.caster,
            target = data.target,
            amount = damage,
            attack = false,
            ranged = false,
            attackType = ATTACK_TYPE_HERO,
            damageType = DAMAGE_TYPE_NORMAL,
            weaponType = WEAPON_TYPE_WOOD_HEAVY_BASH,
            outResult = result,
        })

        if not ExIsUnitDead(data.target) then
            DeepWounds.Cast(data.caster, data.target)
        end

        ExTextCriticalStrike(data.target, result.damage)

        local tab = table.getOrCreateTable(cls.unitOverpowers, data.caster)
        for k, v in pairs(tab) do
            if not ExIsUnitDead(v) then
                KillUnit(v)
            end
            tab[k] = nil
        end
    end
})

EventCenter.PlayerUnitAttackMiss:On(cls, function(context, data)
    local level = GetUnitAbilityLevel(data.caster, Abilities.Overpower.ID)
    if level <= 0 then
        return
    end

    local tab = table.getOrCreateTable(cls.unitOverpowers, data.caster)
    table.insert(tab, CreateUnit(GetOwningPlayer(data.caster), Abilities.Overpower.TechUnitID, 0, 0, 0))
end)

return cls
