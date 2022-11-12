local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local Const = require("Config.Const")
local Vector2 = require("Lib.Vector2")
local Utils = require("Lib.Utils")
local BuffBase = require("Objects.BuffBase")
local Timer = require("Lib.Timer")
local PlagueStrike = require("Ability.PlagueStrike")
local RootDebuff = require("Ability.RootDebuff")

--region meta

Abilities.DeathGrip = {
    ID = FourCC("A000"),
    Duration = { 9, 12, 15 },
    DurationHero = { 3, 4, 5 },
    PlagueLengthen = { 0.1, 0.2, 0.3 },
}

BlzSetAbilityResearchTooltip(Abilities.DeathGrip.ID, "学习死亡之握 - [|cffffcc00%d级|r]", 0)
BlzSetAbilityResearchExtendedTooltip(Abilities.DeathGrip.ID, string.format([[运用笼罩万物的邪恶能量，将目标拉到死亡骑士面前来，并让其无法移动，并根据目标身上的瘟疫数量，延长持续时间。

|cffffcc001级|r - 持续%s秒，英雄%s秒，每个瘟疫延长%s%%。
|cffffcc002级|r - 持续%s秒，英雄%s秒，每个瘟疫延长%s%%。
|cffffcc003级|r - 持续%s秒，英雄%s秒，每个瘟疫延长%s%%。]],
        Abilities.DeathGrip.Duration[1], Abilities.DeathGrip.DurationHero[1], math.round(Abilities.DeathGrip.PlagueLengthen[1] * 100),
        Abilities.DeathGrip.Duration[2], Abilities.DeathGrip.DurationHero[2], math.round(Abilities.DeathGrip.PlagueLengthen[2] * 100),
        Abilities.DeathGrip.Duration[3], Abilities.DeathGrip.DurationHero[3], math.round(Abilities.DeathGrip.PlagueLengthen[3] * 100)
), 0)

for i = 1, #Abilities.DeathGrip.Duration do
    BlzSetAbilityTooltip(Abilities.DeathGrip.ID, string.format("死亡之握 - [|cffffcc00%s级|r]", i), i - 1)
    BlzSetAbilityExtendedTooltip(Abilities.DeathGrip.ID, string.format("运用笼罩万物的邪恶能量，将目标拉到死亡骑士面前来，并让其无法移动，持续%s秒，英雄%s秒，目标身上的每个瘟疫可以延长%s%%的持续时间。", Abilities.DeathGrip.Duration[i], Abilities.DeathGrip.DurationHero[i], math.round(Abilities.DeathGrip.PlagueLengthen[i] * 100)), i - 1)
end

--endregion

local StepLen = 16

local cls = class("DeathGrip")

function cls:ctor(caster, target)
    IssueImmediateOrderById(target, Const.OrderId_Stop)
    PauseUnit(target, true)

    local v1 = Vector2.FromUnit(caster)
    local v2 = Vector2.FromUnit(target)
    local norm = v2 - v1
    local totalLen = norm:Magnitude()
    norm:SetNormalize()
    local travelled = 0
    local dest = (norm * 96):Add(v1)
    totalLen = totalLen - 96
    Utils.SetUnitFlyable(target)
    local originalHeight = GetUnitFlyHeight(target)
    local lightning = AddLightningEx("SPLK", false,
            v2.x, v2.y, BlzGetUnitZ(target) + originalHeight,
            v1.x, v1.y, 0)
    SetUnitPathing(target, false)
    SetLightningColor(lightning, 0.5, 0, 0.5, 1)

    local sfxPos = (norm * 150):Add(v1)
    local sfx = AddSpecialEffect("Abilities/Spells/Undead/UndeadMine/UndeadMineCircle.mdl", sfxPos.x, sfxPos.y)
    BlzSetSpecialEffectScale(sfx, 1.3)
    BlzSetSpecialEffectColor(sfx, 128, 0, 128)
    BlzSetSpecialEffectYaw(sfx, math.atan2(norm.y, norm.x))

    PlagueStrike.Spread(caster, target)

    coroutine.start(function()
        while true do
            coroutine.step()
            v2:MoveToUnit(target)
            local dir = dest - v2
            dir:SetMagnitude(StepLen):Add(v2):UnitMoveTo(target)
            travelled = travelled + StepLen
            local height = math.bezier3(math.clamp01(travelled / totalLen), 0, totalLen, 0)
            SetUnitFlyHeight(target, height, 0)
            MoveLightningEx(lightning, false,
                    dir.x, dir.y, BlzGetUnitZ(target) + GetUnitFlyHeight(target),
                    dest.x, dest.y, 0)
            if dir:Sub(dest):Magnitude() < 96 then
                break
            end
        end

        DestroyLightning(lightning)
        SetUnitFlyHeight(target, originalHeight, 0)
        PauseUnit(target, false)
        SetUnitPathing(target, true)

        local impact = AddSpecialEffectTarget("Abilities/Spells/Undead/DeathCoil/DeathCoilSpecialArt.mdl", target, "origin")
        local impactTimer = Timer.new(function()
            DestroyEffect(impact)
        end, 2, 1)
        impactTimer:Start()

        local level = GetUnitAbilityLevel(caster, Abilities.DeathGrip.ID)
        local count = PlagueStrike.GetPlagueCount(target)
        local duration = (IsUnitType(target, UNIT_TYPE_HERO) and Abilities.DeathGrip.DurationHero[level] or Abilities.DeathGrip.Duration[level]) * (1 + Abilities.DeathGrip.PlagueLengthen[level] * count)
        local debuff = BuffBase.FindBuffByClassName(target, RootDebuff.__cname)
        if debuff then
            debuff:ResetDuration(Time.Time + duration)
        else
            RootDebuff.new(caster, target, duration, 999)
        end

        coroutine.wait(duration - 1)
        DestroyEffect(sfx)

        PlagueStrike.Spread(caster, target)
    end)
end

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Abilities.DeathGrip.ID,
    ---@param data ISpellData
    handler = function(data)
        cls.new(data.caster, data.target)
    end
})

return cls
