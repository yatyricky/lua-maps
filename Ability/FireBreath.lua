local Vector2 = require("Lib.Vector2")
local EventCenter = require("Lib.EventCenter")
local Timer = require("Lib.Timer")
local Pill = require("Lib.Pill")
local Circle = require("Lib.Circle")
local UnitAttribute = require("Objects.UnitAttribute")

local cls = class("FireBreath")

local Meta = {
    ID = FourCC("A000"),
}

Abilities.FireBreath = Meta

local instances = {}

function cls:ctor(caster, x, y)
    local v = Vector2.FromUnit(caster)
    self.charging = AddSpecialEffect("fire_ball", GetUnitX(caster), GetUnitY(caster))

    self.timer = Timer.new(function()
    end, 1, -1)
    self.timer:Start()
end

function cls:stop()
    self.timer:Stop()
    for unit, _ in pairs(self.slowedUnits) do
        local attr = UnitAttribute.GetAttr(unit)
        attr.msp = attr.msp - Meta.MoveSpeedPercent
        attr:Commit()
    end
    DestroyLightning(self.lightning)
    self.slowedUnits = {}
end

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        instances[data.caster] = cls.new(data.caster, data.x, data.y)
    end
})

EventCenter.RegisterPlayerUnitSpellEndCast:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        local inst = instances[data.caster]
        if inst then
            inst:stop()
            instances[data.caster] = nil
        else
            print("Disintegrate end but no instance")
        end
    end
})

return cls
