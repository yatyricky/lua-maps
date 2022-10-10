local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local Const = require("Config.Const")
local Vector2 = require("Lib.Vector2")
local Utils = require("Lib.Utils")
local BuffBase = require("Buff.BuffBase")

---@class SlowDebuff : BuffBase
local SlowDebuff = class("SlowDebuff", BuffBase)

function SlowDebuff:ctor(caster, target, duration, interval)
    SlowDebuff.super.ctor(self, caster, target, duration, interval)
end

function SlowDebuff:OnEnable()
    SetUnitMoveSpeed(self.target, 0)
end

function SlowDebuff:OnDisable()
    SetUnitMoveSpeed(self.target, GetUnitDefaultMoveSpeed(self.target))
end

local cls = class("DeathGrip")

function cls:ctor(caster, target)
    self.damage = GetDistance.units2d(caster, target) * 0.5
    self.count = 25

    IssueImmediateOrderById(target, Const.OrderId_Stop)
    PauseUnit(target, true)

    local v1 = Vector2.FromUnit(caster)
    local v2 = Vector2.FromUnit(target)
    local dest = v2 - v1
    local totalLen = dest:GetMagnitude()
    local travelled = 0
    dest:SetLength(96):Add(v1)
    Utils.SetUnitFlyable(target)
    local originalHeight = GetUnitFlyHeight(target)
    local lightning = AddLightningEx("SPLK", false,
            v2.x, v2.y, BlzGetUnitZ(target) + originalHeight,
            v1.x, v1.y, 0)

    coroutine.start(function()
        while true do
            coroutine.step()
            v2:MoveToUnit(target)
            local dir = dest - v2
            dir:SetLength(20):Add(v2):UnitMoveTo(target)
            travelled = travelled + 20
            local height = math.bezier3(math.clamp01(travelled / totalLen), 0, 600, 0)
            SetUnitFlyHeight(target, height, 0)
            MoveLightningEx(lightning, false,
                    dir.x, dir.y, BlzGetUnitZ(target) + GetUnitFlyHeight(target),
                    dest.x, dest.y, 0)
            if dir:Sub(dest):GetMagnitude() < 96 then
                break
            end
        end

        DestroyLightning(lightning)
        SetUnitFlyHeight(target, originalHeight, 0)
        PauseUnit(target, false)

        local sfx = AddSpecialEffect("Abilities\\Spells\\Undead\\DeathCoil\\DeathCoilSpecialArt.mdl", dest.x, dest.y)
        coroutine.wait(0.5)
        DestroyEffect(sfx)

        SlowDebuff.new(caster, target, IsUnitType(target, UNIT_TYPE_HERO) and 2 or 4, 999)
    end)
end

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Abilities.DeathGrip.ID,
    ---@param data ISpellData
    handler = function(data)
        cls.new(data.caster, data.target)
    end
})

return cls
