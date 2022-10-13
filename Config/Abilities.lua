local cls = {}

cls.DeathGrip = {
    ID = FourCC("A000"),
    Duration = { 4, 5, 6 },
    DurationHero = { 2, 3, 4 },
}

BlzSetAbilityResearchTooltip(cls.DeathGrip.ID, "学习死亡之握 - [|cffffcc00%d级|r]", 0)
BlzSetAbilityResearchExtendedTooltip(cls.DeathGrip.ID, string.format([[运用笼罩万物的邪恶能量，将目标拉到死亡骑士面前来，并让其无法移动。

|cffffcc001级|r - 持续%s秒，英雄%s秒。
|cffffcc002级|r - 持续%s秒，英雄%s秒。
|cffffcc003级|r - 持续%s秒，英雄%s秒。]],
        cls.DeathGrip.Duration[1], cls.DeathGrip.DurationHero[1],
        cls.DeathGrip.Duration[2], cls.DeathGrip.DurationHero[2],
        cls.DeathGrip.Duration[3], cls.DeathGrip.DurationHero[3]
), 0)

for i = 1, #cls.DeathGrip.Duration do
    BlzSetAbilityTooltip(cls.DeathGrip.ID, string.format("死亡之握 - [|cffffcc00%s级|r]", i), i - 1)
    BlzSetAbilityExtendedTooltip(cls.DeathGrip.ID, string.format("运用笼罩万物的邪恶能量，将目标拉到死亡骑士面前来，并让其无法移动，持续%s秒，英雄%s秒。", cls.DeathGrip.Duration[i], cls.DeathGrip.DurationHero[i]), i - 1)
end

cls.DeathStrike = {
    ID = FourCC("A001"),
    Damage = { 80, 120, 160 },
    Heal = { 0.08, 0.12, 0.16 },
    AOE = { 400, 500, 600 },
}

BlzSetAbilityResearchTooltip(cls.DeathStrike.ID, "学习灵界打击 - [|cffffcc00%d级|r]", 0)
BlzSetAbilityResearchExtendedTooltip(cls.DeathStrike.ID, string.format([[致命的攻击，对目标造成一次伤害，并根据目标身上的疾病数量，每有一个便为死亡骑士恢复他最大生命值百分比的效果，并且会将目标身上的所有疾病传染给附近所有敌人。

|cffffcc001级|r - 造成%s点伤害，每个疾病恢复%s%%最大生命值，%s传染范围。
|cffffcc002级|r - 造成%s点伤害，每个疾病恢复%s%%最大生命值，%s传染范围。
|cffffcc003级|r - 造成%s点伤害，每个疾病恢复%s%%最大生命值，%s传染范围。]],
        cls.DeathStrike.Damage[1], math.round(cls.DeathStrike.Heal[1] * 100), cls.DeathStrike.AOE[1],
        cls.DeathStrike.Damage[2], math.round(cls.DeathStrike.Heal[2] * 100), cls.DeathStrike.AOE[2],
        cls.DeathStrike.Damage[3], math.round(cls.DeathStrike.Heal[3] * 100), cls.DeathStrike.AOE[3]
), 0)

for i = 1, #cls.DeathStrike.Damage do
    BlzSetAbilityTooltip(cls.DeathStrike.ID, string.format("灵界打击 - [|cffffcc00%s级|r]", i), i - 1)
    BlzSetAbilityExtendedTooltip(cls.DeathStrike.ID, string.format("致命的攻击，对目标造成%s点伤害，并根据目标身上的疾病数量，每有一个便为死亡骑士恢复他最大生命值的%s%%，并且会将目标身上的所有疾病传染给附近%s范围内所有敌人。", cls.DeathStrike.Damage[i], math.round(cls.DeathStrike.Heal[i] * 100), cls.DeathStrike.AOE[i]), i - 1)
end

cls.PlagueStrike = {
    ID = FourCC("A002"),
    BloodPlagueDuration = { 12, 12, 12 },
    BloodPlagueData = { 0.005, 0.01, 0.015 },
    FrostPlagueDuration = { 6, 6, 6 },
    FrostPlagueData = { 30, 45, 60 },
    UnholyPlagueDuration = { 10.2, 10.2, 10.2 },
    UnholyPlagueInterval = { 2, 2, 2 },
    UnholyPlagueData = { 6, 11, 16 },
}

BlzSetAbilityResearchTooltip(cls.PlagueStrike.ID, "学习瘟疫打击 - [|cffffcc00%d级|r]", 0)
BlzSetAbilityResearchExtendedTooltip(cls.PlagueStrike.ID, string.format([[每次攻击都会依次给敌人造成鲜血疾病、冰霜疾病、邪恶疾病的效果。
鲜血疾病：目标受到攻击时，受到最大生命值百分比伤害。
冰霜疾病：一段时间后，受到一次冰霜伤害，目标移动速度越低，受到伤害越高。
邪恶疾病：受到持续的伤害，生命值越低，受到伤害越高。

|cffffcc001级|r - 鲜血疾病持续%s秒，造成最大生命%s%%的伤害；冰霜疾病持续%s秒，造成%s伤害；邪恶疾病持续%s秒，没%s秒造成%s伤害。
|cffffcc002级|r - 鲜血疾病持续%s秒，造成最大生命%s%%的伤害；冰霜疾病持续%s秒，造成%s伤害；邪恶疾病持续%s秒，没%s秒造成%s伤害。
|cffffcc003级|r - 鲜血疾病持续%s秒，造成最大生命%s%%的伤害；冰霜疾病持续%s秒，造成%s伤害；邪恶疾病持续%s秒，没%s秒造成%s伤害。]],
        cls.PlagueStrike.BloodPlagueDuration[1], (cls.PlagueStrike.BloodPlagueData[1] * 100), cls.PlagueStrike.FrostPlagueDuration[1], cls.PlagueStrike.FrostPlagueData[1], cls.PlagueStrike.UnholyPlagueDuration[1], cls.PlagueStrike.UnholyPlagueInterval[1], cls.PlagueStrike.UnholyPlagueData[1],
        cls.PlagueStrike.BloodPlagueDuration[2], (cls.PlagueStrike.BloodPlagueData[2] * 100), cls.PlagueStrike.FrostPlagueDuration[2], cls.PlagueStrike.FrostPlagueData[2], cls.PlagueStrike.UnholyPlagueDuration[2], cls.PlagueStrike.UnholyPlagueInterval[2], cls.PlagueStrike.UnholyPlagueData[2],
        cls.PlagueStrike.BloodPlagueDuration[3], (cls.PlagueStrike.BloodPlagueData[3] * 100), cls.PlagueStrike.FrostPlagueDuration[3], cls.PlagueStrike.FrostPlagueData[3], cls.PlagueStrike.UnholyPlagueDuration[3], cls.PlagueStrike.UnholyPlagueInterval[3], cls.PlagueStrike.UnholyPlagueData[3]
), 0)

for i = 1, #cls.PlagueStrike.BloodPlagueDuration do
    BlzSetAbilityTooltip(cls.PlagueStrike.ID, string.format("瘟疫打击 - [|cffffcc00%s级|r]", i), i - 1)
    BlzSetAbilityExtendedTooltip(cls.PlagueStrike.ID, string.format("每次攻击都会依次给敌人造成鲜血疾病、冰霜疾病、邪恶疾病的效果。鲜血疾病：持续%s秒，目标受到攻击时，受到最大生命值%s%%的伤害。冰霜疾病：%s秒后，受到%s点冰霜伤害，目标移动速度越低，受到伤害越高。邪恶疾病：持续%s秒，每%s秒受到%s点伤害，生命值越低，受到伤害越高。", cls.PlagueStrike.BloodPlagueDuration[i], (cls.PlagueStrike.BloodPlagueData[i] * 100), cls.PlagueStrike.FrostPlagueDuration[i], cls.PlagueStrike.FrostPlagueData[i], cls.PlagueStrike.UnholyPlagueDuration[i], cls.PlagueStrike.UnholyPlagueInterval[i], cls.PlagueStrike.UnholyPlagueData[i]), i - 1)
end

cls.ArmyOfTheDead = {
    ID = FourCC("A003")
}

BlzSetAbilityResearchTooltip(cls.ArmyOfTheDead.ID, "学习亡者大军 - [|cffffcc00%d级|r]", 0)
BlzSetAbilityResearchExtendedTooltip(cls.ArmyOfTheDead.ID, string.format([[召唤一支食尸鬼军团为你作战。食尸鬼会在你附近的区域横冲直撞，攻击一切它们可以攻击的目标。

|cffffcc001级|r - 召唤6个食尸鬼，每个具有660点生命值。]]
), 0)

for i = 1, 1 do
    BlzSetAbilityTooltip(cls.ArmyOfTheDead.ID, string.format("亡者大军 - [|cffffcc00%s级|r]", i), i - 1)
    BlzSetAbilityExtendedTooltip(cls.ArmyOfTheDead.ID, string.format("召唤一支食尸鬼军团为你作战。食尸鬼会在你附近的区域横冲直撞，攻击一切它们可以攻击的目标。召唤6个食尸鬼，每个具有660点生命值。"), i - 1)
end

return cls
