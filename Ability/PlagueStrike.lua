local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local BuffBase = require("Buff.BuffBase")
local BloodPlague = require("Ability.BloodPlague")
local FrostPlague = require("Ability.FrostPlague")
local UnholyPlague = require("Ability.UnholyPlague")

--region meta

Abilities.PlagueStrike = {
    ID = FourCC("A002"),
    BloodPlagueDuration = { 12, 12, 12 },
    BloodPlagueData = { 0.005, 0.01, 0.015 },
    FrostPlagueDuration = { 6, 6, 6 },
    FrostPlagueData = { 30, 45, 60 },
    UnholyPlagueDuration = { 10, 10, 10 },
    UnholyPlagueInterval = { 2, 2, 2 },
    UnholyPlagueData = { 6, 11, 16 },
}

BlzSetAbilityResearchTooltip(Abilities.PlagueStrike.ID, "学习瘟疫打击 - [|cffffcc00%d级|r]", 0)
BlzSetAbilityResearchExtendedTooltip(Abilities.PlagueStrike.ID, string.format([[每次攻击都会依次给敌人造成鲜血疾病、冰霜疾病、邪恶疾病的效果。
鲜血疾病：目标受到攻击时，受到最大生命值百分比伤害。
冰霜疾病：一段时间后，受到一次冰霜伤害，目标移动速度越低，受到伤害越高。
邪恶疾病：受到持续的伤害，生命值越低，受到伤害越高。

|cffffcc001级|r - 鲜血疾病持续%s秒，造成最大生命%s%%的伤害；冰霜疾病持续%s秒，造成%s伤害；邪恶疾病持续%s秒，没%s秒造成%s伤害。
|cffffcc002级|r - 鲜血疾病持续%s秒，造成最大生命%s%%的伤害；冰霜疾病持续%s秒，造成%s伤害；邪恶疾病持续%s秒，没%s秒造成%s伤害。
|cffffcc003级|r - 鲜血疾病持续%s秒，造成最大生命%s%%的伤害；冰霜疾病持续%s秒，造成%s伤害；邪恶疾病持续%s秒，没%s秒造成%s伤害。]],
        Abilities.PlagueStrike.BloodPlagueDuration[1], (Abilities.PlagueStrike.BloodPlagueData[1] * 100), Abilities.PlagueStrike.FrostPlagueDuration[1], Abilities.PlagueStrike.FrostPlagueData[1], Abilities.PlagueStrike.UnholyPlagueDuration[1], Abilities.PlagueStrike.UnholyPlagueInterval[1], Abilities.PlagueStrike.UnholyPlagueData[1],
        Abilities.PlagueStrike.BloodPlagueDuration[2], (Abilities.PlagueStrike.BloodPlagueData[2] * 100), Abilities.PlagueStrike.FrostPlagueDuration[2], Abilities.PlagueStrike.FrostPlagueData[2], Abilities.PlagueStrike.UnholyPlagueDuration[2], Abilities.PlagueStrike.UnholyPlagueInterval[2], Abilities.PlagueStrike.UnholyPlagueData[2],
        Abilities.PlagueStrike.BloodPlagueDuration[3], (Abilities.PlagueStrike.BloodPlagueData[3] * 100), Abilities.PlagueStrike.FrostPlagueDuration[3], Abilities.PlagueStrike.FrostPlagueData[3], Abilities.PlagueStrike.UnholyPlagueDuration[3], Abilities.PlagueStrike.UnholyPlagueInterval[3], Abilities.PlagueStrike.UnholyPlagueData[3]
), 0)

for i = 1, #Abilities.PlagueStrike.BloodPlagueDuration do
    BlzSetAbilityTooltip(Abilities.PlagueStrike.ID, string.format("瘟疫打击 - [|cffffcc00%s级|r]", i), i - 1)
    BlzSetAbilityExtendedTooltip(Abilities.PlagueStrike.ID, string.format("每次攻击都会依次给敌人造成鲜血疾病、冰霜疾病、邪恶疾病的效果。鲜血疾病：持续%s秒，目标受到攻击时，受到最大生命值%s%%的伤害。冰霜疾病：%s秒后，受到%s点冰霜伤害，目标移动速度越低，受到伤害越高。邪恶疾病：持续%s秒，每%s秒受到%s点伤害，生命值越低，受到伤害越高。", Abilities.PlagueStrike.BloodPlagueDuration[i], (Abilities.PlagueStrike.BloodPlagueData[i] * 100), Abilities.PlagueStrike.FrostPlagueDuration[i], Abilities.PlagueStrike.FrostPlagueData[i], Abilities.PlagueStrike.UnholyPlagueDuration[i], Abilities.PlagueStrike.UnholyPlagueInterval[i], Abilities.PlagueStrike.UnholyPlagueData[i]), i - 1)
end

--endregion

local cls = class("PlagueStrike")

function cls.applyBloodPlague(caster, target, level)
    return BloodPlague.new(caster, target, Abilities.PlagueStrike.BloodPlagueDuration[level], 999, { level = level })
end

function cls.applyFrostPlague(caster, target, level)
    return FrostPlague.new(caster, target, Abilities.PlagueStrike.FrostPlagueDuration[level], 1, { level = level })
end

function cls.applyUnholyPlague(caster, target, level)
    return UnholyPlague.new(caster, target, Abilities.PlagueStrike.UnholyPlagueDuration[level], Abilities.PlagueStrike.UnholyPlagueInterval[level], { level = level })
end

cls.Plagues = {
    { class = BloodPlague, invoker = cls.applyBloodPlague },
    { class = FrostPlague, invoker = cls.applyFrostPlague },
    { class = UnholyPlague, invoker = cls.applyUnholyPlague },
}

EventCenter.RegisterPlayerUnitDamaged:Emit(function(caster, target, _, _, _, isAttack)
    if not isAttack then
        return
    end

    if target == nil then
        return
    end

    local abilityLevel = GetUnitAbilityLevel(caster, Abilities.PlagueStrike.ID)
    if abilityLevel < 1 then
        return
    end

    local existingPlagues = {} ---@type BuffBase[]
    local missingDebuff
    for _, plagueDefine in ipairs(cls.Plagues) do
        local debuff = BuffBase.FindBuffByClassName(target, plagueDefine.class.__cname)
        if not debuff then
            missingDebuff = plagueDefine
            break
        else
            if debuff.class.__cname ~= FrostPlague.__cname then
                table.insert(existingPlagues, debuff)
            end
        end
    end

    if missingDebuff then
        missingDebuff.invoker(caster, target, abilityLevel)
    else
        ---@param a BuffBase
        ---@param b BuffBase
        table.sort(existingPlagues, function(a, b)
            local lta = a.level < abilityLevel
            local ltb = b.level < abilityLevel
            if lta ~= ltb then
                return lta
            end
            return a:GetTimeLeft() < b:GetTimeLeft()
        end)

        local first = existingPlagues[1]
        first.level = abilityLevel
        first:ResetDuration()
    end
end)

return cls
