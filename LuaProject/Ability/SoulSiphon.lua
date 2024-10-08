local Vector2 = require("Lib.Vector2")
local EventCenter = require("Lib.EventCenter")
local Timer = require("Lib.Timer")
local Pill = require("Lib.Pill")
local Circle = require("Lib.Circle")
local UnitAttribute = require("Objects.UnitAttribute")
local Abilities = require("Config.Abilities")

local cls = class("SoulSiphon")

local Meta = {
    ID = FourCC("A01K"),
    Damage = 150,
}

Abilities.SoulSiphon = Meta

local instances = {}

function cls:ctor(caster, target)
    self.lightning, self.lightningCo = ExAddLightningUnitUnit("DRAM", caster, target, 9999, { r = 1, g = 0, b = 1, a = 1 }, false)
    local function exec()
        if ExIsUnitDead(target) then
            self:stop()
            return
        end

        EventCenter.Damage:Emit({
            whichUnit = caster,
            target = target,
            amount = Meta.Damage,
            attack = false,
            ranged = true,
            attackType = ATTACK_TYPE_HERO,
            damageType = DAMAGE_TYPE_DIVINE,
            weaponType = WEAPON_TYPE_WHOKNOWS,
            outResult = {},
        })
    end
    exec()
    self.timer = Timer.new(exec, 1, -1)
    self.timer:Start()
end

function cls:stop()
    self.timer:Stop()
    coroutine.stop(self.lightningCo)
    DestroyLightning(self.lightning)
end

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        if instances[data.caster] then
            instances[data.caster]:stop()
        end
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
            print("SoulSiphon end but no instance")
        end
    end
})

ExTriggerRegisterUnitDeath(function(unit)

end)

return cls
