local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local BuffBase = require("Objects.BuffBase")
local ProjectileBase = require("Objects.ProjectileBase")
local FesteringWound = require("Ability.FesteringWound")
local Const = require("Config.Const")
local UnitAttribute = require("Objects.UnitAttribute")

--region meta

local Meta = {
    ID = FourCC("A01N"),
    Heal = 300,
    Duration = 6,
    Interval = 1,
    DOT = 100,
}

Abilities.SaraBlessings = Meta

--endregion

---@class SaraBlessings : BuffBase
local cls = class("SaraBlessings", BuffBase)

function cls:OnEnable()
    --self.sfx = AddSpecialEffectTarget("Abilities/Spells/Items/StaffOfSanctuary/Staff_Sanctuary_Target.mdl", self.target, "overhead")
    --local attr = UnitAttribute.GetAttr(self.target)
    --table.insert(attr.absorbShields, self)
end

function cls:Update()
    EventCenter.Damage:Emit({
        whichUnit = self.caster,
        target = self.target,
        amount = Meta.DOT,
        attack = false,
        ranged = true,
        attackType = ATTACK_TYPE_HERO,
        damageType = DAMAGE_TYPE_NORMAL,
        weaponType = WEAPON_TYPE_WHOKNOWS,
        outResult = {}
    })
end

function cls:OnDisable()
    --DestroyEffect(self.sfx)
end

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        EventCenter.Heal:Emit({
            caster = data.caster,
            target = data.target,
            amount = Meta.Heal,
        })
        local debuff = BuffBase.FindBuffByClassName(data.target, cls.__cname)
        if debuff then
            debuff:ResetDuration()
        else
            debuff = cls.new(data.caster, data.target, Meta.Duration, Meta.Interval, {})
        end
    end
})

return cls
