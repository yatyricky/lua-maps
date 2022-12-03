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
    AutoGenCD = 10,
    ActiveTriggerCD = 3,
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
    self.cd = 10
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
            end
            cls.timer:Start()
        end
    end
})

return cls
