local Vector2 = require("Lib.Vector2")
local EventCenter = require("Lib.EventCenter")
local Timer = require("Lib.Timer")

local cls = class("Disintegrate")

local Meta = {
    ID = FourCC("A000")
}

Abilities.Disintegrate = Meta

local instances = {}

function cls:ctor(caster, target)
    self.lightning = ExAddLightningUnitUnit("espb", caster, target, 9999, { r = 1, g = 1, b = 1, a = 1 }, false)
    self.slowedUnits = {}
    self.timer = Timer.new(function ()
        
    end, 1, -1)
    self.timer:Start()
end

function cls:stop()
end

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        instances[data.caster] = cls.new(data.caster, data.target)
    end
})

EventCenter.RegisterPlayerUnitSpellEndCast:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        local inst = instances[data.caster]
        if inst then
            inst:Stop()
            instances[data.caster] = nil
        else
            print("Disintegrate end but no instance")
        end
    end
})

return cls
