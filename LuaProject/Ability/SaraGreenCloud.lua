local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local BuffBase = require("Objects.BuffBase")
local ProjectileBase = require("Objects.ProjectileBase")
local FesteringWound = require("Ability.FesteringWound")
local Const = require("Config.Const")
local UnitAttribute = require("Objects.UnitAttribute")
local Vector2 = require("Lib.Vector2")
local Timer = require("Lib.Timer")

--region meta

local Meta = {
    ID = FourCC("A01N"),
    Duration = 9,
    Interval = 3,
    DOT = 200,
    Attack = 100,
    InstanceCount = 2,
    AngleSpeed = math.pi * 2 / 36,
    UTIDCloud = FourCC("u000"),
    UTIDFacelessOne = FourCC("u000"),
    AutoGenCD = 10,
    ActiveTriggerCD = 3,
    AOESpawn = 256,
    AOEDamage = 450,
    DamageAmount = 299,
}

Abilities.SaraGreenCloud = Meta

--endregion

---@class SaraGreenCloud
local cls = class("SaraGreenCloud")

cls.instances = {} ---@type SaraGreenCloud[]
cls.timer = nil ---@type Timer

function cls.update(dt)
    for _, v in ipairs(cls.instances) do
        v.dir:RotateSelf(Meta.AngleSpeed * dt)
        local pos = v.center + v.dir
        BlzSetSpecialEffectPosition(v.cloud, pos.x, pos.y, pos:GetTerrainZ())

        v.cdAutoGen = v.cdAutoGen - dt
        v.cdActiveTrigger = v.cdActiveTrigger - dt

        if v.cdAutoGen <= 0 then
            v.cdAutoGen = Meta.AutoGenCD
            v:spawn(pos)
        elseif v.cdActiveTrigger <= 0 then
            local casterFaction = GetOwningPlayer(v.caster)
            local units = ExGroupGetUnitsInRange(pos.x, pos.y, Meta.AOESpawn, function(unit)
                return not ExIsUnitDead(unit) and IsUnitEnemy(unit, casterFaction)
            end)
            if #units > 0 then
                v.cdAutoGen = Meta.AutoGenCD
                v.cdActiveTrigger = Meta.ActiveTriggerCD
                v:spawn(pos)
            end
        end
    end
end

---@param center Vector2
---@param dir Vector2
---@param caster unit
function cls:ctor(center, dir, caster)
    self.center = center
    self.dir = dir
    self.caster = caster

    local pos = self.center + self.dir
    self.cloud = AddSpecialEffect("Units/Undead/PlagueCloud/PlagueCloudtarget.mdl", pos.x, pos.y)

    self.cdActiveTrigger = 0
    self.cdAutoGen = Meta.AutoGenCD
end

function cls:spawn(pos)
    -- play sfx
    local casterPlayer = GetOwningPlayer(self.caster)
    local spawned = CreateUnit(casterPlayer, Meta.UTIDFacelessOne, pos.x, pos.y, math.random() * 360)
end

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        local vo = Vector2.FromUnit(data.caster)
        local v1 = Vector2.new(900, 0)
        for i = 1, Meta.InstanceCount do
            local dir = v1:Rotate((i - 1) * math.pi * 2 / Meta.InstanceCount)
            local inst = cls.new(vo, dir, data.caster)
            table.insert(cls.instances, inst)
        end
        if #cls.instances > 0 then
            if cls.timer == nil then
                cls.timer = Timer.new(cls.update, Time.Delta, -1)
                cls.timer:Start()
            end
        end
    end
})

ExTriggerRegisterUnitDeath(function(unit)
    local utid = GetUnitTypeId(unit)
    if utid == Meta.UTIDFacelessOne then
        local p = Vector2.FromUnit(unit)
        -- sfx

        ExGroupEnumUnitsInRange(p.x, p.y, Meta.AOEDamage, function(v)
            if not IsUnit(unit, v) then
                EventCenter.Damage:Emit({
                    whichUnit = unit,
                    target = v,
                    amount = Meta.DamageAmount,
                    attack = false,
                    ranged = true,
                    attackType = ATTACK_TYPE_CHAOS,
                    damageType = DAMAGE_TYPE_DIVINE,
                    weaponType = WEAPON_TYPE_WHOKNOWS,
                    outResult = {}
                })
            end
        end)
    end
end)

return cls
