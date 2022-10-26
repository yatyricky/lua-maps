-- 蛮兽打击

local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local BuffBase = require("Objects.BuffBase")
local ProjectileBase = require("Objects.ProjectileBase")
local FesteringWound = require("Ability.FesteringWound")
local UnitAttribute = require("Objects.UnitAttribute")
local Vector2 = require("Lib.Vector2")
local Const = require("Config.Const")
local Timer = require("Lib.Timer")
local RootDebuff = require("Ability.RootDebuff")

--region meta

Abilities.ShamblingRush = {
    ID = FourCC("A007"),
    Speed = 600,
    Duration = 6,
}

--BlzSetAbilityResearchTooltip(Abilities.ShamblingRush.ID, "学习死亡之握 - [|cffffcc00%d级|r]", 0)
--BlzSetAbilityResearchExtendedTooltip(Abilities.ShamblingRush.ID, string.format([[运用笼罩万物的邪恶能量，将目标拉到死亡骑士面前来，并让其无法移动，并根据目标身上的瘟疫数量，延长持续时间。
--
--|cffffcc001级|r - 持续%s秒，英雄%s秒，每个瘟疫延长%s%%。
--|cffffcc002级|r - 持续%s秒，英雄%s秒，每个瘟疫延长%s%%。
--|cffffcc003级|r - 持续%s秒，英雄%s秒，每个瘟疫延长%s%%。]],
--        Abilities.ShamblingRush.Duration[1], Abilities.ShamblingRush.DurationHero[1], math.round(Abilities.ShamblingRush.PlagueLengthen[1] * 100),
--        Abilities.ShamblingRush.Duration[2], Abilities.ShamblingRush.DurationHero[2], math.round(Abilities.ShamblingRush.PlagueLengthen[2] * 100),
--        Abilities.ShamblingRush.Duration[3], Abilities.ShamblingRush.DurationHero[3], math.round(Abilities.ShamblingRush.PlagueLengthen[3] * 100)
--), 0)
--
--for i = 1, #Abilities.ShamblingRush.Duration do
--    BlzSetAbilityTooltip(Abilities.ShamblingRush.ID, string.format("死亡之握 - [|cffffcc00%s级|r]", i), i - 1)
--    BlzSetAbilityExtendedTooltip(Abilities.ShamblingRush.ID, string.format("运用笼罩万物的邪恶能量，将目标拉到死亡骑士面前来，并让其无法移动，持续%s秒，英雄%s秒，目标身上的每个瘟疫可以延长%s%%的持续时间。", Abilities.ShamblingRush.Duration[i], Abilities.ShamblingRush.DurationHero[i], math.round(Abilities.ShamblingRush.PlagueLengthen[i] * 100)), i - 1)
--end

--endregion

local cls = class("ShamblingRush")

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Abilities.ShamblingRush.ID,
    ---@param data ISpellData
    handler = function(data)
        coroutine.start(function()
            SetUnitPathing(data.caster, false)
            while true do
                local v1 = Vector2.FromUnit(data.caster)
                local v2 = Vector2.FromUnit(data.target)
                local v3 = v2 - v1
                local distance = math.max(v3:GetMagnitude() - 96, 0)
                local shouldMove = Abilities.ShamblingRush.Speed * Time.Delta
                local norm = v3:SetNormalize()
                SetUnitFacing(data.caster, math.atan2(norm.y, norm.x))
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

            SetUnitPathing(data.caster, true)
            IssueImmediateOrderById(data.target, Const.OrderId_Stop)
            local debuff = BuffBase.FindBuffByClassName(data.target, RootDebuff.__cname)
            if debuff then
                debuff:ResetDuration(Time.Time + Abilities.ShamblingRush.Duration)
            else
                RootDebuff.new(data.caster, data. target, Abilities.ShamblingRush.Duration, 999)
            end
        end)
    end
})

return cls


-- 横扫爪击
-- 蛮兽打击
-- 蹒跚冲锋
-- 腐臭壁垒