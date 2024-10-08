local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local BuffBase = require("Objects.BuffBase")
local FesteringWound = require("Ability.FesteringWound")
local UnitAttribute = require("Objects.UnitAttribute")
local Vector2 = require("Lib.Vector2")

--region meta

local Meta = {
    Sanity = 100,
}

--endregion

local cls = class("ResetSanity")

function cls.Execute(caster)
    local casterPlayer = GetOwningPlayer(caster)
    ExGroupEnumUnitsInMap(function(unit)
        if IsUnitEnemy(unit, casterPlayer) and not ExIsUnitDead(unit) then
            local attr = UnitAttribute.GetAttr(unit)
            attr.sanity = Meta.Sanity
        end
    end)
end

return cls
