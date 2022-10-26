-- 黑暗突变

local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local BuffBase = require("Objects.BuffBase")
local ProjectileBase = require("Objects.ProjectileBase")
local FesteringWound = require("Ability.FesteringWound")
local UnitAttribute = require("Objects.UnitAttribute")
local Vector2 = require("Lib.Vector2")

--region meta

Abilities.DarkTransformation = {
    ID = FourCC("A007"),
    TechID = FourCC("aaaa"),
    AbominationID = FourCC("aaaa")
}

--BlzSetAbilityResearchTooltip(Abilities.DarkTransformation.ID, "学习死亡之握 - [|cffffcc00%d级|r]", 0)
--BlzSetAbilityResearchExtendedTooltip(Abilities.DarkTransformation.ID, string.format([[运用笼罩万物的邪恶能量，将目标拉到死亡骑士面前来，并让其无法移动，并根据目标身上的瘟疫数量，延长持续时间。
--
--|cffffcc001级|r - 持续%s秒，英雄%s秒，每个瘟疫延长%s%%。
--|cffffcc002级|r - 持续%s秒，英雄%s秒，每个瘟疫延长%s%%。
--|cffffcc003级|r - 持续%s秒，英雄%s秒，每个瘟疫延长%s%%。]],
--        Abilities.DarkTransformation.Duration[1], Abilities.DarkTransformation.DurationHero[1], math.round(Abilities.DarkTransformation.PlagueLengthen[1] * 100),
--        Abilities.DarkTransformation.Duration[2], Abilities.DarkTransformation.DurationHero[2], math.round(Abilities.DarkTransformation.PlagueLengthen[2] * 100),
--        Abilities.DarkTransformation.Duration[3], Abilities.DarkTransformation.DurationHero[3], math.round(Abilities.DarkTransformation.PlagueLengthen[3] * 100)
--), 0)
--
--for i = 1, #Abilities.DarkTransformation.Duration do
--    BlzSetAbilityTooltip(Abilities.DarkTransformation.ID, string.format("死亡之握 - [|cffffcc00%s级|r]", i), i - 1)
--    BlzSetAbilityExtendedTooltip(Abilities.DarkTransformation.ID, string.format("运用笼罩万物的邪恶能量，将目标拉到死亡骑士面前来，并让其无法移动，持续%s秒，英雄%s秒，目标身上的每个瘟疫可以延长%s%%的持续时间。", Abilities.DarkTransformation.Duration[i], Abilities.DarkTransformation.DurationHero[i], math.round(Abilities.DarkTransformation.PlagueLengthen[i] * 100)), i - 1)
--end

--endregion

local cls = class("DarkTransformation")

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Abilities.DarkTransformation.ID,
    ---@param data ISpellData
    handler = function(data)
        local pos = Vector2.FromUnit(data.target)
        local facing = GetUnitFacing(data.target)
        KillUnit(data.target)

        local summoned = CreateUnit(GetOwningPlayer(data.caster), Abilities.DarkTransformation.AbominationID, pos.x, pos.y, facing)
    end
})

ExTriggerRegisterUnitLearn(Abilities.DarkTransformation.ID, function(unit, level)
    AddPlayerTechResearched()
    SetPlayerTechResearched()
end)

return cls

-- 蹒跚冲锋
-- 腐臭壁垒