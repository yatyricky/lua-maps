local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local Const = require("Config.Const")
local Vector2 = require("Lib.Vector2")
local Utils = require("Lib.Utils")
local BuffBase = require("Buff.BuffBase")
local Timer = require("Lib.Timer")

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

local StepLen = 16

local cls = class("DeathGrip")

function cls:ctor(caster, target)
    IssueImmediateOrderById(target, Const.OrderId_Stop)
    PauseUnit(target, true)

    local v1 = Vector2.FromUnit(caster)
    local v2 = Vector2.FromUnit(target)
    local norm = v2 - v1
    local totalLen = norm:GetMagnitude()
    norm:SetNormalize()
    local travelled = 0
    local dest = (norm * 96):Add(v1)
    totalLen = totalLen - 96
    Utils.SetUnitFlyable(target)
    local originalHeight = GetUnitFlyHeight(target)
    local lightning = AddLightningEx("SPLK", false,
            v2.x, v2.y, BlzGetUnitZ(target) + originalHeight,
            v1.x, v1.y, 0)
    SetUnitPathing(target, false)
    SetLightningColor(lightning, 0.5, 0, 0.5, 1)

    local sfxPos = (norm * 150):Add(v1)
    local sfx = AddSpecialEffect("Abilities/Spells/Undead/UndeadMine/UndeadMineCircle.mdl", sfxPos.x, sfxPos.y)
    BlzSetSpecialEffectScale(sfx, 1.3)
    BlzSetSpecialEffectColor(sfx, 128, 0, 128)
    BlzSetSpecialEffectYaw(sfx, math.atan2(norm.y, norm.x))

    coroutine.start(function()
        while true do
            coroutine.step()
            v2:MoveToUnit(target)
            local dir = dest - v2
            dir:SetLength(StepLen):Add(v2):UnitMoveTo(target)
            travelled = travelled + StepLen
            local height = math.bezier3(math.clamp01(travelled / totalLen), 0, totalLen, 0)
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
        SetUnitPathing(target, true)

        local impact = AddSpecialEffectTarget("Abilities/Spells/Undead/DeathCoil/DeathCoilSpecialArt.mdl", target, "origin")
        local impactTimer = Timer.new(function()
            DestroyEffect(impact)
        end, 2, 1)
        impactTimer:Start()

        local duration = IsUnitType(target, UNIT_TYPE_HERO) and 2 or 4
        SlowDebuff.new(caster, target, duration, 999)

        coroutine.wait(duration - 1)
        DestroyEffect(sfx)
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
