-- 蹒跚冲锋

local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local BuffBase = require("Objects.BuffBase")
local Vector2 = require("Lib.Vector2")
local Const = require("Config.Const")
local RootDebuff = require("Ability.RootDebuff")

--region meta

Abilities.Charge = {
    ID = FourCC("A018"),
    Damage = 0.2,
    MinDistance = 300,
    Speed = 400,
    DurationMinion = { 10, 20, 30 },
    DurationHero = { 2, 5, 10 },
    Rage = 0.2,
}

local Meta = Abilities.Charge

BlzSetAbilityResearchTooltip(Abilities.Charge.ID, "学习冲锋 - [|cffffcc00%d级|r]", 0)
BlzSetAbilityResearchExtendedTooltip(Abilities.Charge.ID, string.format([[向一名敌人冲锋，造成|cffff8c00%s|r的攻击伤害，使其定身，并生成|cffff8c00%s|r的法力值。

|cff99ccff施法距离|r - %s-900
|cff99ccff冷却时间|r - 10秒

|cffffcc001级|r - 持续|cffff8c00%s|r秒，英雄|cffff8c00%s|r秒。
|cffffcc002级|r - 持续|cffff8c00%s|r秒，英雄|cffff8c00%s|r秒。
|cffffcc003级|r - 持续|cffff8c00%s|r秒，英雄|cffff8c00%s|r秒。]],
        string.formatPercentage(Meta.Damage), string.formatPercentage(Meta.Rage), Meta.MinDistance,
        Meta.DurationMinion[1], Meta.DurationHero[1],
        Meta.DurationMinion[2], Meta.DurationHero[2],
        Meta.DurationMinion[3], Meta.DurationHero[3]
), 0)

for i = 1, #Meta.DurationMinion do
    BlzSetAbilityTooltip(Meta.ID, string.format("冲锋 - [|cffffcc00%s级|r]", i), i - 1)
    BlzSetAbilityExtendedTooltip(Meta.ID, string.format(
            [[向一名敌人冲锋，造成|cffff8c00%s|r的攻击伤害，使其定身|cffff8c00%s|r秒，英雄|cffff8c00%s|r秒，并生成|cffff8c00%s|r的法力值。

|cff99ccff施法距离|r - %s-900
|cff99ccff冷却时间|r - 10秒]],
            string.formatPercentage(Meta.Damage), Meta.DurationMinion[i], Meta.DurationHero[i], string.formatPercentage(Meta.Rage), Meta.MinDistance),
            i - 1)
end

--endregion

local cls = class("Charge")

EventCenter.RegisterPlayerUnitSpellChannel:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        local v1 = Vector2.FromUnit(data.caster)
        local v2 = Vector2.FromUnit(data.target)
        if (v2 - v1):GetMagnitude() < Meta.MinDistance then
            IssueImmediateOrderById(data.caster, Const.OrderId_Stop)
            ExTextState(data.caster, "太近了")
        end
    end
})

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Meta.ID,
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
                local shouldMove = Abilities.Charge.Speed * Time.Delta
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
                debuff:ResetDuration(Time.Time + Abilities.Charge.Duration)
            else
                RootDebuff.new(data.caster, data.target, Abilities.Charge.Duration, 999)
            end
        end)
    end
})

return cls
