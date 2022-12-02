local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local BuffBase = require("Objects.BuffBase")
local ProjectileBase = require("Objects.ProjectileBase")
local FesteringWound = require("Ability.FesteringWound")
local Const = require("Config.Const")
local UnitAttribute = require("Objects.UnitAttribute")
local Vector2 = require("Lib.Vector2")

--region meta

local Meta = {
    ID = FourCC("A01N"),
    Duration = 9,
    Interval = 3,
    DOT = 200,
    Attack = 100,
}

Abilities.SaraGreenCloud = Meta

--endregion

---@class SaraGreenCloud
local cls = class("SaraGreenCloud")

function cls:ctor(center, current)

end

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        local vo = Vector2.FromUnit(data.caster)
        local v1 = vo + Vector2.new(900, 0)

    end
})

return cls
