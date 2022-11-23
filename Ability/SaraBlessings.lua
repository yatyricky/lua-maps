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
    Shield = 100,
    Duration = 15,
}

Abilities.SaraBlessings = Meta

--endregion

---@class SaraBlessings : BuffBase
local cls = class("SaraBlessings", BuffBase)

function cls:OnEnable()
    self.sfx = AddSpecialEffectTarget("Abilities/Spells/Items/StaffOfSanctuary/Staff_Sanctuary_Target.mdl", self.target, "overhead")
    local attr = UnitAttribute.GetAttr(self.target)
    table.insert(attr.absorbShields, self)
end

function cls:OnDisable()
    DestroyEffect(self.sfx)
end

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        EventCenter.Heal:Emit({
            caster=unit,
            target=unit,
            amount=real
        })
        local buff = BuffBase.FindBuffByClassName(data.target, cls.__cname)
        if buff then
            buff:ResetDuration()
        else
            buff = cls.new(data.caster, data.target, Meta.Duration, 9999, {})
        end
        buff.shield = Meta.Shield
    end
})

return cls
