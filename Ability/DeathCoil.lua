local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local Const = require("Config.Const")
local Vector2 = require("Lib.Vector2")
local Utils = require("Lib.Utils")
local BuffBase = require("Objects.BuffBase")
local Timer = require("Lib.Timer")
local PlagueStrike = require("Ability.PlagueStrike")
local ProjectileBase = require("Objects.ProjectileBase")

--region meta

Abilities.DeathCoil = {
    ID = FourCC("A007"),
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

function cls:ctor(caster, target)
    IssueImmediateOrderById(target, Const.OrderId_Stop)
    PauseUnit(target, true)

    local v1 = Vector2.FromUnit(caster)
    local v2 = Vector2.FromUnit(target)
    local norm = v2 - v1
    local totalLen = norm:GetMagnitude()
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
            dir:SetLength(StepLen):Add(v2):UnitMoveTo(target)
            travelled = travelled + StepLen
            local height = math.bezier3(math.clamp01(travelled / totalLen), 0, totalLen, 0)
            SetUnitFlyHeight(target, height, 0)
            MoveLightningEx(lightning, false,
                    dir.x, dir.y, BlzGetUnitZ(target) + GetUnitFlyHeight(target),
                    dest.x, dest.y, 0)
            if dir:Sub(dest):GetMagnitude() < 96 then
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

        local level = GetUnitAbilityLevel(caster, Abilities.DeathCoil.ID)
        local count = PlagueStrike.GetPlagueCount(target)
        local duration = (IsUnitType(target, UNIT_TYPE_HERO) and Abilities.DeathCoil.DurationHero[level] or Abilities.DeathCoil.Duration[level]) * (1 + Abilities.DeathCoil.PlagueLengthen[level] * count)
        local debuff = BuffBase.FindBuffByClassName(target, SlowDebuff.__cname)
        if debuff then
            debuff:ResetDuration(Time.Time + duration)
        else
            SlowDebuff.new(caster, target, duration, 999)
        end

        coroutine.wait(duration - 1)
        DestroyEffect(sfx)

        PlagueStrike.Spread(caster, target)
    end)
end

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Abilities.DeathCoil.ID,
    ---@param data ISpellData
    handler = function(data)
        local proj = ProjectileBase.new(data.caster, data.target, "Abilities/Spells/Undead/DeathCoil/DeathCoilMissile.mdl", 600, function()
            print("onhit!!!!!!")
        end, nil)
    end
})

return cls
