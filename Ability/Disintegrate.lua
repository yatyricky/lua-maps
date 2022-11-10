local Vector2 = require("Lib.Vector2")
local EventCenter = require("Lib.EventCenter")
local Timer = require("Lib.Timer")
local Pill = require("Lib.Pill")
local Circle = require("Lib.Circle")
local UnitAttribute = require("Objects.UnitAttribute")

local cls = class("Disintegrate")

local Meta = {
    ID = FourCC("A000"),
}

local Width = 32
local BackOffset = 10
local Radius = Width / 2
local PointMoveForward = Radius - 10

Abilities.Disintegrate = Meta

local instances = {}

function cls:ctor(caster, target)
    self.lightning = ExAddLightningUnitUnit("espb", caster, target, 9999, { r = 1, g = 1, b = 1, a = 1 }, false)
    self.slowedUnits = {}
    local casterPlayer = GetOwningPlayer(caster)
    self.timer = Timer.new(function()
        local a = Vector2.FromUnit(caster)
        local b = Vector2.FromUnit(target)
        local dir = b - a
        local center = a + dir:Div(2)
        local realDist = dir:Magnitude()
        dir:SetNormalize()
        local moveForwardOffset = math.min(realDist / 2, PointMoveForward)
        local offset = dir * moveForwardOffset
        a:Add(offset)
        b:Sub(offset)
        local pill = Pill.new(a, b, Radius)

        local enumRange = realDist / 2 + BackOffset
        ExGroupEnumUnitsInRange(center.x, center.y, enumRange, function(unit)
            if not ExIsUnitDead(unit) and IsUnitAlly(unit, casterPlayer) then
                local circle = Circle.new(Vector2.FromUnit(unit), Radius)
                if Pill.PillCircle(pill, circle) then
                    if not self.slowedUnits[unit] then
                        local attr = UnitAttribute.GetAttr(unit)
                        attr.msp = attr.msp + Meta.MoveSpeedPercent
                        attr:Commit()
                    end

                    EventCenter.Damage:Emit({
                        whichUnit = caster,
                        target = unit,
                        amount = Meta.Damage,
                        attack = false,
                        ranged = true,
                        attackType = ATTACK_TYPE_HERO,
                        damageType = DAMAGE_TYPE_DIVINE,
                        weaponType = WEAPON_TYPE_WHOKNOWS,
                        outResult = {},
                    })
                end
            end
        end)
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
        instances[data.caster] = cls.new(data.caster, data.target)
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
