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

Abilities.PutridBulwark = {
    ID = FourCC("A007"),
    Reduction = 0.5,
    Duration = 10,
}

--BlzSetAbilityResearchTooltip(Abilities.PutridBulwark.ID, "学习死亡之握 - [|cffffcc00%d级|r]", 0)
--BlzSetAbilityResearchExtendedTooltip(Abilities.PutridBulwark.ID, string.format([[运用笼罩万物的邪恶能量，将目标拉到死亡骑士面前来，并让其无法移动，并根据目标身上的瘟疫数量，延长持续时间。
--
--|cffffcc001级|r - 持续%s秒，英雄%s秒，每个瘟疫延长%s%%。
--|cffffcc002级|r - 持续%s秒，英雄%s秒，每个瘟疫延长%s%%。
--|cffffcc003级|r - 持续%s秒，英雄%s秒，每个瘟疫延长%s%%。]],
--        Abilities.PutridBulwark.Duration[1], Abilities.PutridBulwark.DurationHero[1], math.round(Abilities.PutridBulwark.PlagueLengthen[1] * 100),
--        Abilities.PutridBulwark.Duration[2], Abilities.PutridBulwark.DurationHero[2], math.round(Abilities.PutridBulwark.PlagueLengthen[2] * 100),
--        Abilities.PutridBulwark.Duration[3], Abilities.PutridBulwark.DurationHero[3], math.round(Abilities.PutridBulwark.PlagueLengthen[3] * 100)
--), 0)
--
--for i = 1, #Abilities.PutridBulwark.Duration do
--    BlzSetAbilityTooltip(Abilities.PutridBulwark.ID, string.format("死亡之握 - [|cffffcc00%s级|r]", i), i - 1)
--    BlzSetAbilityExtendedTooltip(Abilities.PutridBulwark.ID, string.format("运用笼罩万物的邪恶能量，将目标拉到死亡骑士面前来，并让其无法移动，持续%s秒，英雄%s秒，目标身上的每个瘟疫可以延长%s%%的持续时间。", Abilities.PutridBulwark.Duration[i], Abilities.PutridBulwark.DurationHero[i], math.round(Abilities.PutridBulwark.PlagueLengthen[i] * 100)), i - 1)
--end

--endregion

---@class PutridBulwark : BuffBase
local cls = class("PutridBulwark", BuffBase)

function cls:OnEnable()
end

function cls:OnDisable()
end

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Abilities.PutridBulwark.ID,
    ---@param data ISpellData
    handler = function(data)
        local buff = BuffBase.FindBuffByClassName(data.caster, cls.__cname)
        if buff then
            buff:ResetDuration()
        else
            buff = cls.new(data.caster, data.caster, Abilities.PutridBulwark.Duration, 999)
        end
    end
})

EventCenter.RegisterPlayerUnitDamaging:Emit(function(caster, target, damage, weaponType, damageType, isAttack)
    local buff = BuffBase.FindBuffByClassName(target, cls.__cname)
    if not buff then
        return
    end

    BlzSetEventDamage(damage * Abilities.PutridBulwark.Reduction)
end)

return cls


-- 横扫爪击
-- 蛮兽打击
-- 蹒跚冲锋
-- 腐臭壁垒