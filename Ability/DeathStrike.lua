local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local BuffBase = require("Buff.BuffBase")
local Timer = require("Lib.Timer")
local BloodPlague = require("Ability.BloodPlague")
local FrostPlague = require("Ability.FrostPlague")
local UnholyPlague = require("Ability.UnholyPlague")

--region meta

Abilities.DeathStrike = {
    ID = FourCC("A001"),
    Damage = { 80, 120, 160 },
    Heal = { 0.08, 0.12, 0.16 },
    AOE = { 400, 500, 600 },
}

BlzSetAbilityResearchTooltip(Abilities.DeathStrike.ID, "学习灵界打击 - [|cffffcc00%d级|r]", 0)
BlzSetAbilityResearchExtendedTooltip(Abilities.DeathStrike.ID, string.format([[致命的攻击，对目标造成一次伤害，并根据目标身上的疾病数量，每有一个便为死亡骑士恢复他最大生命值百分比的效果，并且会将目标身上的所有疾病传染给附近所有敌人。

|cffffcc001级|r - 造成%s点伤害，每个疾病恢复%s%%最大生命值，%s传染范围。
|cffffcc002级|r - 造成%s点伤害，每个疾病恢复%s%%最大生命值，%s传染范围。
|cffffcc003级|r - 造成%s点伤害，每个疾病恢复%s%%最大生命值，%s传染范围。]],
        Abilities.DeathStrike.Damage[1], math.round(Abilities.DeathStrike.Heal[1] * 100), Abilities.DeathStrike.AOE[1],
        Abilities.DeathStrike.Damage[2], math.round(Abilities.DeathStrike.Heal[2] * 100), Abilities.DeathStrike.AOE[2],
        Abilities.DeathStrike.Damage[3], math.round(Abilities.DeathStrike.Heal[3] * 100), Abilities.DeathStrike.AOE[3]
), 0)

for i = 1, #Abilities.DeathStrike.Damage do
    BlzSetAbilityTooltip(Abilities.DeathStrike.ID, string.format("灵界打击 - [|cffffcc00%s级|r]", i), i - 1)
    BlzSetAbilityExtendedTooltip(Abilities.DeathStrike.ID, string.format("致命的攻击，对目标造成%s点伤害，并根据目标身上的疾病数量，每有一个便为死亡骑士恢复他最大生命值的%s%%，并且会将目标身上的所有疾病传染给附近%s范围内所有敌人。", Abilities.DeathStrike.Damage[i], math.round(Abilities.DeathStrike.Heal[i] * 100), Abilities.DeathStrike.AOE[i]), i - 1)
end

--endregion

local cls = class("DeathStrike")

cls.Plagues = {
    BloodPlague,
    FrostPlague,
    UnholyPlague,
}

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Abilities.DeathStrike.ID,
    ---@param data ISpellData
    handler = function(data)
        local count = 0
        local existingPlagues = {} ---@type BuffBase[]
        for _, plagueDefine in ipairs(cls.Plagues) do
            local debuff = BuffBase.FindBuffByClassName(data.target, plagueDefine.__cname)
            if debuff then
                table.insert(existingPlagues, debuff)
                count = count + 1
            end
        end

        -- damage
        local level = GetUnitAbilityLevel(data.caster, data.abilityId)
        UnitDamageTarget(data.caster, data.target, Abilities.DeathStrike.Damage[level], false, true, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_METAL_HEAVY_SLICE)

        -- spread
        if table.any(existingPlagues) then
            local color = { r = 0.1, g = 0.7, b = 0.1, a = 1 }
            local targetPlayer = GetOwningPlayer(data.target)
            ExGroupEnumUnitsInRange(GetUnitX(data.target), GetUnitY(data.target), Abilities.DeathStrike.AOE[level], function(e)
                if not IsUnit(e, data.target) and IsUnitAlly(e, targetPlayer) and not IsUnitType(e, UNIT_TYPE_STRUCTURE) and not IsUnitType(e, UNIT_TYPE_MECHANICAL) and not IsUnitDeadBJ(e) then
                    ExAddLightningUnitUnit("SPLK", data.caster, e, 0.3, color, false)

                    for _, debuff in ipairs(existingPlagues) do
                        local current = BuffBase.FindBuffByClassName(e, debuff.__cname)
                        if current then
                            current.level = debuff.level
                            if current.__cname ~= "FrostPlague" then
                                current.duration = math.max(debuff.duration, current.duration)
                            end
                        else
                            debuff.class.new(debuff.caster, e, debuff:GetTimeLeft(), debuff.interval, debuff.awakeData)
                        end
                    end
                end
            end)
        end

        -- heal
        if count > 0 then
            EventCenter.Heal:Emit({
                caster = data.caster,
                target = data.caster,
                amount = Abilities.DeathStrike.Heal[level] * count * GetUnitState(data.caster, UNIT_STATE_MAX_LIFE),
            })

            local healEffect = AddSpecialEffectTarget("Abilities/Spells/Items/AIhe/AIheTarget.mdl", data.caster, "origin")
            local healEffectTimer = Timer.new(function()
                DestroyEffect(healEffect)
            end, 2, 1)
            healEffectTimer:Start()
        end

        local impact = AddSpecialEffectTarget("Objects/Spawnmodels/Human/HumanBlood/HeroBloodElfBlood.mdl", data.target, "origin")
        local impactTimer = Timer.new(function()
            DestroyEffect(impact)
        end, 2, 1)
        impactTimer:Start()
    end
})

return cls
