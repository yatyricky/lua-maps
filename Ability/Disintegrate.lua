local Vector2 = require("Lib.Vector2")
local EventCenter = require("Lib.EventCenter")
local Timer = require("Lib.Timer")
local Pill = require("Lib.Pill")
local Circle = require("Lib.Circle")
local UnitAttribute = require("Objects.UnitAttribute")
local Abilities = require("Config.Abilities")

local cls = class("Disintegrate")

local Meta = {
    ID = FourCC("A01E"),
    MoveSpeedPercent = -0.30,
    Damage = 150,
}

local Width = 64
local BackOffset = 10
local Radius = Width / 2
local PointMoveForward = Radius - 10

Abilities.Disintegrate = Meta

local instances = {}

function cls:ctor(caster, target)
    self.lightning, self.lightningCo = ExAddLightningUnitUnit("DRAM", target, caster, 9999, { r = 1, g = 1, b = 1, a = 1 }, false)
    self.slowedUnits = {}
    local casterPlayer = GetOwningPlayer(caster)
    local function exec()
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
        ExAddSpecialEffectTarget("Abilities/Spells/NightElf/MoonWell/MoonWellCasterArt.mdl", caster, "origin", 1)
        ExGroupEnumUnitsInRange(center.x, center.y, enumRange + 197, function(unit)
            if not ExIsUnitDead(unit) and IsUnitEnemy(unit, casterPlayer) then
                local circle = Circle.new(Vector2.FromUnit(unit), Radius)
                if Pill.PillCircle(pill, circle) then
                    if not self.slowedUnits[unit] then
                        local attr = UnitAttribute.GetAttr(unit)
                        attr.msp = attr.msp + Meta.MoveSpeedPercent
                        attr:Commit()
                        self.slowedUnits[unit] = true
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
                    ExAddSpecialEffectTarget("Abilities/Spells/Human/ManaFlare/ManaFlareBoltImpact.mdl", unit, "origin", 0.5)
                end
            end
        end)
    end
    exec()
    self.timer = Timer.new(exec, 1, -1)
    self.timer:Start()
end

function cls:stop()
    self.timer:Stop()
    coroutine.stop(self.lightningCo)
    DestroyLightning(self.lightning)
    for unit, _ in pairs(self.slowedUnits) do
        local attr = UnitAttribute.GetAttr(unit)
        attr.msp = attr.msp - Meta.MoveSpeedPercent
        attr:Commit()
    end
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
