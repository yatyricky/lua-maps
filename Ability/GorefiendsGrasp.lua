local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local Const = require("Config.Const")
local Vector2 = require("Lib.Vector2")
local Utils = require("Lib.Utils")
local BuffBase = require("Objects.BuffBase")
local Timer = require("Lib.Timer")
local PlagueStrike = require("Ability.PlagueStrike")
local RootDebuff = require("Ability.RootDebuff")
local UnitAttribute = require("Objects.UnitAttribute")
local DeathGrip = require("Ability.DeathGrip")

--region meta

local Meta = {
    ID = FourCC("A01I"),
    AOE = 600,
}

Abilities.GorefiendsGrasp = Meta

--endregion

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        local v = Vector2.FromUnit(data.caster)
        local p = GetOwningPlayer(data.caster)
        local level = GetUnitAbilityLevel(data.caster, Meta.ID)
        ExGroupEnumUnitsInRange(v.x, v.y, Meta.AOE, function(unit)
            if not ExIsUnitDead(unit) and IsUnitEnemy(unit, p) and not IsUnit(unit, data.caster) then
                DeathGrip.new(data.caster, unit, level)
            end
        end)
    end
})
