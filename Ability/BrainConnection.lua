local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local BuffBase = require("Objects.BuffBase")
local FesteringWound = require("Ability.FesteringWound")
local UnitAttribute = require("Objects.UnitAttribute")
local Vector2 = require("Lib.Vector2")
local Timer = require("Lib.Timer")

--region meta

local Meta = {
    SanityCost = 2,
    Damage = 50,
    SearchRange = 2400,
    ClearRange = 256,
}

Abilities.BrainConnection = Meta

--endregion

---@class BrainConnection
local cls = class("BrainConnection")

cls.instances = {} ---@type table<unit, BrainConnection>

function cls:ctor(caster, target1, target2)
    self.caster = caster
    self.tar1 = target1
    self.tar2 = target2

    self.lightning, self.lightningCo = ExAddLightningUnitUnit("ESPB", self.tar1, self.tar2, 999, { r = 1, g = 1, b = 1, a = 1 }, false)

    self.timer = Timer.new(function()
        if Vector2.UnitDistance(self.tar1, self.tar2) <= Meta.ClearRange then
            self:stop()
        else
            for _, v in ipairs({ self.tar1, self.tar2 }) do
                local attr = UnitAttribute.GetAttr(v)
                attr.sanity = attr.sanity - Meta.SanityCost
                EventCenter.Damage:Emit({
                    whichUnit = self.caster,
                    target = v,
                    amount = Meta.Damage,
                    attack = false,
                    ranged = true,
                    attackType = ATTACK_TYPE_CHAOS,
                    damageType = DAMAGE_TYPE_DIVINE,
                    weaponType = WEAPON_TYPE_WHOKNOWS,
                    outResult = {}
                })
            end
        end
    end, 1, -1)
    self.timer:Start()
end

function cls:stop()
    cls.instances[self.tar1] = nil
    cls.instances[self.tar2] = nil
    self.timer:Stop()
    coroutine.stop(self.lightningCo)
    DestroyLightning(self.lightning)
end

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Abilities.Apocalypse.ID,
    ---@param data ISpellData
    handler = function(data)
        local target = data.target
        local inst = cls.instances[target]
        if inst then
            return
        end

        local tPos = Vector2.FromUnit(target)
        local targetPlayer = GetOwningPlayer(target)
        local nearby = ExGroupGetUnitsInRange(tPos.x, tPos.y, Meta.SearchRange, function(unit)
            return not ExIsUnitDead(unit) and IsUnitAlly(unit, targetPlayer) and not IsUnit(unit, target)
        end)

        if not table.any(nearby) then
            return
        end

        table.sort(nearby, function(a, b)
            return Vector2.UnitDistanceSqr(target, b) < Vector2.UnitDistanceSqr(target, a)
        end)

        local connector = nearby[1]
        inst = cls.new(data.caster, target, connector)
        cls.instances[target] = inst
        cls.instances[connector] = inst
    end
})

ExTriggerRegisterUnitDeath(function(unit)
    local inst = cls.instances[unit]
    if inst then
        inst:stop()
    end
end)

return cls
