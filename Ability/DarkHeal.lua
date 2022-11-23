local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local BuffBase = require("Objects.BuffBase")
local ProjectileBase = require("Objects.ProjectileBase")
local FesteringWound = require("Ability.FesteringWound")
local Const = require("Config.Const")

--region meta

local Meta = {
    ID = FourCC("A01M"),
    Heal = 400,
}

Abilities.DarkHeal = Meta

--endregion

local cls = class("DarkHeal")

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        EventCenter.Heal:Emit({
            caster = data.caster,
            target = data.target,
            amount = Meta.Heal,
        })
        ExAddSpecialEffectTarget("Abilities/Spells/Undead/RaiseSkeletonWarrior/RaiseSkeleton.mdl", data.target, "origin", 1)
    end
})

return cls
