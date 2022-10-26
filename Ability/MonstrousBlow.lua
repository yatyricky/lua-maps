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

--region meta

Abilities.MonstrousBlow = {
    ID = FourCC("A007"),
    Duration = 2,
    Damage = 150,
}

--BlzSetAbilityResearchTooltip(Abilities.MonstrousBlow.ID, "学习死亡之握 - [|cffffcc00%d级|r]", 0)
--BlzSetAbilityResearchExtendedTooltip(Abilities.MonstrousBlow.ID, string.format([[运用笼罩万物的邪恶能量，将目标拉到死亡骑士面前来，并让其无法移动，并根据目标身上的瘟疫数量，延长持续时间。
--
--|cffffcc001级|r - 持续%s秒，英雄%s秒，每个瘟疫延长%s%%。
--|cffffcc002级|r - 持续%s秒，英雄%s秒，每个瘟疫延长%s%%。
--|cffffcc003级|r - 持续%s秒，英雄%s秒，每个瘟疫延长%s%%。]],
--        Abilities.MonstrousBlow.Duration[1], Abilities.MonstrousBlow.DurationHero[1], math.round(Abilities.MonstrousBlow.PlagueLengthen[1] * 100),
--        Abilities.MonstrousBlow.Duration[2], Abilities.MonstrousBlow.DurationHero[2], math.round(Abilities.MonstrousBlow.PlagueLengthen[2] * 100),
--        Abilities.MonstrousBlow.Duration[3], Abilities.MonstrousBlow.DurationHero[3], math.round(Abilities.MonstrousBlow.PlagueLengthen[3] * 100)
--), 0)
--
--for i = 1, #Abilities.MonstrousBlow.Duration do
--    BlzSetAbilityTooltip(Abilities.MonstrousBlow.ID, string.format("死亡之握 - [|cffffcc00%s级|r]", i), i - 1)
--    BlzSetAbilityExtendedTooltip(Abilities.MonstrousBlow.ID, string.format("运用笼罩万物的邪恶能量，将目标拉到死亡骑士面前来，并让其无法移动，持续%s秒，英雄%s秒，目标身上的每个瘟疫可以延长%s%%的持续时间。", Abilities.MonstrousBlow.Duration[i], Abilities.MonstrousBlow.DurationHero[i], math.round(Abilities.MonstrousBlow.PlagueLengthen[i] * 100)), i - 1)
--end

--endregion

local cls = class("MonstrousBlow")

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Abilities.MonstrousBlow.ID,
    ---@param data ISpellData
    handler = function(data)
        UnitDamageTarget(data.caster, data.target, Abilities.MonstrousBlow.Damage, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WOOD_HEAVY_BASH)

        IssueImmediateOrderById(data.target, Const.OrderId_Stop)
        PauseUnit(data.target, true)
        local timer = Timer.new(function()
            PauseUnit(data.target, false)
        end)
        timer:Start()
    end
})

return cls


-- 横扫爪击
-- 蛮兽打击
-- 蹒跚冲锋
-- 腐臭壁垒