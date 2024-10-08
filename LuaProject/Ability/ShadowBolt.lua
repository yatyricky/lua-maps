local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local BuffBase = require("Objects.BuffBase")
local ProjectileBase = require("Objects.ProjectileBase")
local FesteringWound = require("Ability.FesteringWound")
local Const = require("Config.Const")

--region meta

local Meta = {
    ID = FourCC("A01L"),
    Damage = 400,
    HitRange = 20,
}

Abilities.ShadowBolt = Meta

--endregion

local cls = class("ShadowBolt")

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        ProjectileBase.new(data.caster, data.target, "Abilities/Weapons/AvengerMissile/AvengerMissile.mdl", 600, function()
            EventCenter.Damage:Emit({
                whichUnit = data.caster,
                target = data.target,
                amount = Meta.Damage,
                attack = false,
                ranged = true,
                attackType = ATTACK_TYPE_HERO,
                damageType = DAMAGE_TYPE_NORMAL,
                weaponType = WEAPON_TYPE_WHOKNOWS,
                outResult = {}
            })
        end, nil)
    end
})

return cls
