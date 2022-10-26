local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local BuffBase = require("Objects.BuffBase")
local ProjectileBase = require("Objects.ProjectileBase")
local FesteringWound = require("Ability.FesteringWound")
local UnitAttribute = require("Objects.UnitAttribute")

--region meta

Abilities.Apocalypse = {
    ID = FourCC("A007"),
    AtkMultiplier = { 1.2, 1.8, 2.5 },
    ExtraHpPerStack = { 30, 40, 50 },
    ExtraAtkPerStack = { 1, 2, 3 },
}

--BlzSetAbilityResearchTooltip(Abilities.Apocalypse.ID, "学习死亡之握 - [|cffffcc00%d级|r]", 0)
--BlzSetAbilityResearchExtendedTooltip(Abilities.Apocalypse.ID, string.format([[运用笼罩万物的邪恶能量，将目标拉到死亡骑士面前来，并让其无法移动，并根据目标身上的瘟疫数量，延长持续时间。
--
--|cffffcc001级|r - 持续%s秒，英雄%s秒，每个瘟疫延长%s%%。
--|cffffcc002级|r - 持续%s秒，英雄%s秒，每个瘟疫延长%s%%。
--|cffffcc003级|r - 持续%s秒，英雄%s秒，每个瘟疫延长%s%%。]],
--        Abilities.Apocalypse.Duration[1], Abilities.Apocalypse.DurationHero[1], math.round(Abilities.Apocalypse.PlagueLengthen[1] * 100),
--        Abilities.Apocalypse.Duration[2], Abilities.Apocalypse.DurationHero[2], math.round(Abilities.Apocalypse.PlagueLengthen[2] * 100),
--        Abilities.Apocalypse.Duration[3], Abilities.Apocalypse.DurationHero[3], math.round(Abilities.Apocalypse.PlagueLengthen[3] * 100)
--), 0)
--
--for i = 1, #Abilities.Apocalypse.Duration do
--    BlzSetAbilityTooltip(Abilities.Apocalypse.ID, string.format("死亡之握 - [|cffffcc00%s级|r]", i), i - 1)
--    BlzSetAbilityExtendedTooltip(Abilities.Apocalypse.ID, string.format("运用笼罩万物的邪恶能量，将目标拉到死亡骑士面前来，并让其无法移动，持续%s秒，英雄%s秒，目标身上的每个瘟疫可以延长%s%%的持续时间。", Abilities.Apocalypse.Duration[i], Abilities.Apocalypse.DurationHero[i], math.round(Abilities.Apocalypse.PlagueLengthen[i] * 100)), i - 1)
--end

--endregion

local cls = class("Apocalypse")

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Abilities.Apocalypse.ID,
    ---@param data ISpellData
    handler = function(data)
        local level = GetUnitAbilityLevel(data.caster, Abilities.Apocalypse.ID)
        local attr = UnitAttribute.GetAttr(data.caster)
        local damage = attr:SimAttack(UnitAttribute.HeroAttributeType.Strength) * Abilities.Apocalypse.AtkMultiplier[level]
        UnitDamageTarget(data.caster, data.target, damage, true, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_METAL_HEAVY_SLICE)

        local count = 0
        -- festering wound burst

        local summoned = CreateUnit(GetOwningPlayer(data.caster), FourCC("ugar"), backx, backy, GetUnitFacing(data.caster))
        local summonedAttr = UnitAttribute.GetAttr(summoned)
        summonedAttr.hp = summonedAttr.hp + count * Abilities.Apocalypse.ExtraHpPerStack[level]
        summonedAttr.atk = summonedAttr.atk + count * Abilities.Apocalypse.ExtraAtkPerStack[level]
        summonedAttr:Commit()
    end
})

return cls
