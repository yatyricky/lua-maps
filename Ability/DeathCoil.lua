local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local BuffBase = require("Objects.BuffBase")
local ProjectileBase = require("Objects.ProjectileBase")
local FesteringWound = require("Ability.FesteringWound")

--region meta

Abilities.DeathCoil = {
    ID = FourCC("A007"),
    Heal = { 0.4, 0.6, 0.8 },
    Damage = { 100, 200, 300 },
    Wounds = { 3, 5, 7 },
    AmplificationPerStack = 0.05,
}

--BlzSetAbilityResearchTooltip(Abilities.DeathCoil.ID, "学习死亡之握 - [|cffffcc00%d级|r]", 0)
--BlzSetAbilityResearchExtendedTooltip(Abilities.DeathCoil.ID, string.format([[运用笼罩万物的邪恶能量，将目标拉到死亡骑士面前来，并让其无法移动，并根据目标身上的瘟疫数量，延长持续时间。
--
--|cffffcc001级|r - 持续%s秒，英雄%s秒，每个瘟疫延长%s%%。
--|cffffcc002级|r - 持续%s秒，英雄%s秒，每个瘟疫延长%s%%。
--|cffffcc003级|r - 持续%s秒，英雄%s秒，每个瘟疫延长%s%%。]],
--        Abilities.DeathCoil.Duration[1], Abilities.DeathCoil.DurationHero[1], math.round(Abilities.DeathCoil.PlagueLengthen[1] * 100),
--        Abilities.DeathCoil.Duration[2], Abilities.DeathCoil.DurationHero[2], math.round(Abilities.DeathCoil.PlagueLengthen[2] * 100),
--        Abilities.DeathCoil.Duration[3], Abilities.DeathCoil.DurationHero[3], math.round(Abilities.DeathCoil.PlagueLengthen[3] * 100)
--), 0)
--
--for i = 1, #Abilities.DeathCoil.Duration do
--    BlzSetAbilityTooltip(Abilities.DeathCoil.ID, string.format("死亡之握 - [|cffffcc00%s级|r]", i), i - 1)
--    BlzSetAbilityExtendedTooltip(Abilities.DeathCoil.ID, string.format("运用笼罩万物的邪恶能量，将目标拉到死亡骑士面前来，并让其无法移动，持续%s秒，英雄%s秒，目标身上的每个瘟疫可以延长%s%%的持续时间。", Abilities.DeathCoil.Duration[i], Abilities.DeathCoil.DurationHero[i], math.round(Abilities.DeathCoil.PlagueLengthen[i] * 100)), i - 1)
--end

--endregion

local cls = class("DeathCoil")

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Abilities.DeathCoil.ID,
    ---@param data ISpellData
    handler = function(data)
        ProjectileBase.new(data.caster, data.target, "Abilities/Spells/Undead/DeathCoil/DeathCoilMissile.mdl", 600, function()
            local level = GetUnitAbilityLevel(data.caster, data.abilityId)
            if IsUnitAlly(data.target, GetOwningPlayer(data.caster)) then
                -- 友军，治疗
                EventCenter.Heal:Emit({
                    caster = data.caster,
                    target = data.target,
                    amount = Abilities.DeathCoil.Heal[level] * GetUnitState(data.target, UNIT_STATE_MAX_LIFE),
                })
            else
                -- 敌军，伤害+debuff
                local debuff = BuffBase.FindBuffByClassName(data.target, FesteringWound.__cname)
                local stack = debuff and debuff.stack or 0
                local damage = Abilities.DeathCoil.Damage[level] * (1 + Abilities.DeathCoil.AmplificationPerStack * stack)
                UnitDamageTarget(data.caster, data.target, damage, false, true, ATTACK_TYPE_HERO, DAMAGE_TYPE_MAGIC, WEAPON_TYPE_WHOKNOWS)
            end

            -- sfx
            ExAddSpecialEffectTarget("Abilities/Spells/Undead/DeathCoil/DeathCoilSpecialArt.mdl", data.target, "origin", 2)
        end, nil)
    end
})

return cls
