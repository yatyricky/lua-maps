local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local BuffBase = require("Buff.BuffBase")
local BloodPlague = require("Ability.BloodPlague")
local FrostPlague = require("Ability.FrostPlague")
local UnholyPlague = require("Ability.UnholyPlague")

--region meta

Abilities.PlagueStrike = {
    ID = FourCC("A002"),
    BloodDummyAbilityID = FourCC("A005"),
    BloodPlagueDuration = { 12, 12, 12 },
    BloodPlagueData = { 0.005, 0.01, 0.015 },
    FrostDummyAbilityID = FourCC("A006"),
    FrostPlagueDuration = { 6, 6, 6 },
    FrostPlagueData = { 30, 45, 60 },
    UnholyDummyAbilityID = FourCC("A004"),
    UnholyPlagueDuration = { 10, 10, 10 },
    UnholyPlagueInterval = { 2, 2, 2 },
    UnholyPlagueData = { 6, 11, 16 },
}

local DummyAbilityIds = {
    Abilities.PlagueStrike.BloodDummyAbilityID,
    Abilities.PlagueStrike.FrostDummyAbilityID,
    Abilities.PlagueStrike.UnholyDummyAbilityID,
}

BlzSetAbilityResearchTooltip(Abilities.PlagueStrike.ID, "学习瘟疫打击 - [|cffffcc00%d级|r]", 0)
BlzSetAbilityResearchExtendedTooltip(Abilities.PlagueStrike.ID, string.format([[每次攻击都会依次给敌人造成鲜血瘟疫、冰霜瘟疫、邪恶瘟疫的效果。
鲜血瘟疫：目标受到攻击时，受到最大生命值百分比伤害。
冰霜瘟疫：一段时间后，受到一次冰霜伤害，目标移动速度越低，受到伤害越高。
邪恶瘟疫：受到持续的伤害，生命值越低，受到伤害越高。

|cffffcc001级|r - 鲜血瘟疫持续%s秒，造成最大生命%s%%的伤害；冰霜瘟疫持续%s秒，造成%s伤害；邪恶瘟疫持续%s秒，每%s秒造成%s伤害。
|cffffcc002级|r - 鲜血瘟疫持续%s秒，造成最大生命%s%%的伤害；冰霜瘟疫持续%s秒，造成%s伤害；邪恶瘟疫持续%s秒，每%s秒造成%s伤害。
|cffffcc003级|r - 鲜血瘟疫持续%s秒，造成最大生命%s%%的伤害；冰霜瘟疫持续%s秒，造成%s伤害；邪恶瘟疫持续%s秒，每%s秒造成%s伤害。]],
        Abilities.PlagueStrike.BloodPlagueDuration[1], (Abilities.PlagueStrike.BloodPlagueData[1] * 100), Abilities.PlagueStrike.FrostPlagueDuration[1], Abilities.PlagueStrike.FrostPlagueData[1], Abilities.PlagueStrike.UnholyPlagueDuration[1], Abilities.PlagueStrike.UnholyPlagueInterval[1], Abilities.PlagueStrike.UnholyPlagueData[1],
        Abilities.PlagueStrike.BloodPlagueDuration[2], (Abilities.PlagueStrike.BloodPlagueData[2] * 100), Abilities.PlagueStrike.FrostPlagueDuration[2], Abilities.PlagueStrike.FrostPlagueData[2], Abilities.PlagueStrike.UnholyPlagueDuration[2], Abilities.PlagueStrike.UnholyPlagueInterval[2], Abilities.PlagueStrike.UnholyPlagueData[2],
        Abilities.PlagueStrike.BloodPlagueDuration[3], (Abilities.PlagueStrike.BloodPlagueData[3] * 100), Abilities.PlagueStrike.FrostPlagueDuration[3], Abilities.PlagueStrike.FrostPlagueData[3], Abilities.PlagueStrike.UnholyPlagueDuration[3], Abilities.PlagueStrike.UnholyPlagueInterval[3], Abilities.PlagueStrike.UnholyPlagueData[3]
), 0)

for i = 1, #Abilities.PlagueStrike.BloodPlagueDuration do
    local tooltip = string.format("瘟疫打击 - [|cffffcc00%s级|r]", i)
    local extTooltip = string.format("每次攻击都会依次给敌人造成鲜血瘟疫、冰霜瘟疫、邪恶瘟疫的效果。鲜血瘟疫：持续%s秒，目标受到攻击时，受到最大生命值%s%%的伤害。冰霜瘟疫：%s秒后，受到%s点冰霜伤害，目标移动速度越低，受到伤害越高。邪恶瘟疫：持续%s秒，每%s秒受到%s点伤害，生命值越低，受到伤害越高。", Abilities.PlagueStrike.BloodPlagueDuration[i], (Abilities.PlagueStrike.BloodPlagueData[i] * 100), Abilities.PlagueStrike.FrostPlagueDuration[i], Abilities.PlagueStrike.FrostPlagueData[i], Abilities.PlagueStrike.UnholyPlagueDuration[i], Abilities.PlagueStrike.UnholyPlagueInterval[i], Abilities.PlagueStrike.UnholyPlagueData[i])
    for _, id in ipairs(DummyAbilityIds) do
        BlzSetAbilityTooltip(id, tooltip, i - 1)
        BlzSetAbilityExtendedTooltip(id, extTooltip, i - 1)
    end
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
    { class = BloodPlague, invoker = cls.applyBloodPlague, id = Abilities.PlagueStrike.BloodDummyAbilityID },
    { class = FrostPlague, invoker = cls.applyFrostPlague, id = Abilities.PlagueStrike.FrostDummyAbilityID },
    { class = UnholyPlague, invoker = cls.applyUnholyPlague, id = Abilities.PlagueStrike.UnholyDummyAbilityID },
}

cls.sequence = {}

function cls.updateDummyAbilities(unit)
    local seq = cls.sequence[unit]
    local index = (seq - 1) % #cls.Plagues + 1
    local p = GetOwningPlayer(unit)
    for i, config in ipairs(cls.Plagues) do
        SetPlayerAbilityAvailable(p, config.id, i == index)
    end
end

ExTriggerRegisterUnitLearn(Abilities.PlagueStrike.ID, function(unit, level)
    for _, id in ipairs(DummyAbilityIds) do
        if GetUnitAbilityLevel(unit, id) == 0 then
            UnitAddAbility(unit, id)
            UnitMakeAbilityPermanent(unit, true, id)
        end
        SetUnitAbilityLevel(unit, id, level)
    end
    if not cls.sequence[unit] then
        cls.sequence[unit] = 1
    end

    cls.updateDummyAbilities(unit)
end)

EventCenter.RegisterPlayerUnitDamaged:Emit(function(caster, target, _, _, _, isAttack)
    if not isAttack then
        return
    end

    if target == nil then
        return
    end

    if IsUnitType(target, UNIT_TYPE_MECHANICAL) or IsUnitType(target, UNIT_TYPE_STRUCTURE) then
        return
    end

    local abilityLevel = GetUnitAbilityLevel(caster, Abilities.PlagueStrike.ID)
    if abilityLevel < 1 then
        return
    end

    local seq = cls.sequence[caster]
    local config = cls.Plagues[(seq - 1) % #cls.Plagues + 1]

    local debuff = BuffBase.FindBuffByClassName(target, config.class.__cname)

    if not debuff then
        config.invoker(caster, target, abilityLevel)
    else
        if debuff.class == BloodPlague then
            debuff.level = abilityLevel
            debuff:ResetDuration()
        elseif debuff.class == UnholyPlague then
            debuff.level = abilityLevel
            debuff:ResetDuration(debuff.expire + Abilities.PlagueStrike.UnholyPlagueDuration[abilityLevel])
        end
    end

    cls.sequence[caster] = seq + 1
    cls.updateDummyAbilities(caster)
end)

return cls
