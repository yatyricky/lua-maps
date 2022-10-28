-- 蹒跚冲锋

local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local BuffBase = require("Objects.BuffBase")
local Vector2 = require("Lib.Vector2")
local Const = require("Config.Const")
local RootDebuff = require("Ability.RootDebuff")

--region meta

Abilities.ShamblingRush = {
    ID = FourCC("A013"),
    Speed = 400,
    Duration = 6,
}

BlzSetAbilityTooltip(Abilities.ShamblingRush.ID, string.format("蹒跚冲锋"), 0)
BlzSetAbilityExtendedTooltip(Abilities.ShamblingRush.ID, string.format("向敌人冲锋，打断其正在施放的法术并使其不能移动，持续|cffff8c00%s|r秒。",
        Abilities.ShamblingRush.Duration), 0)

--endregion

local cls = class("ShamblingRush")

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Abilities.ShamblingRush.ID,
    ---@param data ISpellData
    handler = function(data)
        coroutine.start(function()
            coroutine.step()
            SetUnitPathing(data.caster, false)
            local defaultRange = GetUnitAcquireRange(data.caster)
            SetUnitAcquireRange(data.caster, 0)
            SetUnitTimeScale(data.caster, 3)
            SetUnitAnimationByIndex(data.caster, 1)
            local sfx = AddSpecialEffectTarget("Objects/Spawnmodels/Undead/ImpaleTargetDust/ImpaleTargetDust.mdl", data.caster, "origin")
            while true do
                local v1 = Vector2.FromUnit(data.caster)
                local v2 = Vector2.FromUnit(data.target)
                local v3 = v2 - v1
                local distance = math.max(v3:GetMagnitude() - 96, 0)
                local shouldMove = Abilities.ShamblingRush.Speed * Time.Delta
                local norm = v3:SetNormalize()
                SetUnitFacing(data.caster, math.atan2(norm.y, norm.x) * bj_RADTODEG)
                local move
                local hit
                if distance > shouldMove then
                    move = shouldMove
                    hit = false
                else
                    move = distance
                    hit = true
                end
                v1:Add(norm * move)
                v1:UnitMoveTo(data.caster)

                if hit then
                    break
                end

                coroutine.step()
            end

            DestroyEffect(sfx)
            SetUnitPathing(data.caster, true)
            IssueImmediateOrderById(data.target, Const.OrderId_Stop)
            SetUnitAcquireRange(data.caster, defaultRange)
            SetUnitTimeScale(data.caster, 1)
            local debuff = BuffBase.FindBuffByClassName(data.target, RootDebuff.__cname)
            if debuff then
                debuff:ResetDuration(Time.Time + Abilities.ShamblingRush.Duration)
            else
                RootDebuff.new(data.caster, data.target, Abilities.ShamblingRush.Duration, 999)
            end
        end)
    end
})

return cls
