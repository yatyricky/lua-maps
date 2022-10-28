local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local BuffBase = require("Objects.BuffBase")
local FesteringWound = require("Ability.FesteringWound")
local UnitAttribute = require("Objects.UnitAttribute")
local Vector2 = require("Lib.Vector2")

--region meta

Abilities.Apocalypse = {
    ID = FourCC("A011"),
    AtkMultiplier = { 1.2, 1.8, 2.5 },
    ExtraHpPerStack = { 30, 40, 50 },
    ExtraAtkPerStack = { 1, 2, 3 },
    GargoyleID = FourCC("u001"),
}

BlzSetAbilityResearchTooltip(Abilities.Apocalypse.ID, "学习天启 - [|cffffcc00%d级|r]", 0)
BlzSetAbilityResearchExtendedTooltip(Abilities.Apocalypse.ID, string.format([[引爆目标身上的所有溃烂之伤，造成一次攻击伤害，并召唤|cffff8c00一只永久|r的具有|cffff8c00100|r点生命值、|cffff8c0010|r点攻击力、|cffff8c00麻痹毒液|r攻击的邪恶石像鬼进入战场，每层溃烂之伤可以为石像鬼提供额外属性。

|cff99ccff冷却时间|r - 20秒

|cffffcc001级|r - 造成|cffff8c00%s|r倍的基础攻击伤害，每层溃烂之伤提供|cffff8c00%s|r点生命值和|cffff8c00%s|r点攻击力。
|cffffcc002级|r - 造成|cffff8c00%s|r倍的基础攻击伤害，每层溃烂之伤提供|cffff8c00%s|r点生命值和|cffff8c00%s|r点攻击力。
|cffffcc003级|r - 造成|cffff8c00%s|r倍的基础攻击伤害，每层溃烂之伤提供|cffff8c00%s|r点生命值和|cffff8c00%s|r点攻击力。]],
        Abilities.Apocalypse.AtkMultiplier[1], Abilities.Apocalypse.ExtraHpPerStack[1], Abilities.Apocalypse.ExtraAtkPerStack[1],
        Abilities.Apocalypse.AtkMultiplier[2], Abilities.Apocalypse.ExtraHpPerStack[2], Abilities.Apocalypse.ExtraAtkPerStack[2],
        Abilities.Apocalypse.AtkMultiplier[3], Abilities.Apocalypse.ExtraHpPerStack[3], Abilities.Apocalypse.ExtraAtkPerStack[3]
), 0)

for i = 1, #Abilities.Apocalypse.AtkMultiplier do
    BlzSetAbilityTooltip(Abilities.Apocalypse.ID, string.format("天启 - [|cffffcc00%s级|r]", i), i - 1)
    BlzSetAbilityExtendedTooltip(Abilities.Apocalypse.ID, string.format([[引爆目标身上的所有溃烂之伤，造成一次|cffff8c00%s|r倍的攻击伤害，并召唤|cffff8c00一只永久|r的具有|cffff8c00100|r点生命值、|cffff8c0010|r点攻击力、|cffff8c00麻痹毒液|r攻击的邪恶石像鬼进入战场，每层溃烂之伤可以为石像鬼提供额外|cffff8c00%s|r点生命值和|cffff8c00%s|r点攻击力。

|cff99ccff法力消耗|r - 600点
|cff99ccff冷却时间|r - 20秒]], Abilities.Apocalypse.AtkMultiplier[i], Abilities.Apocalypse.ExtraHpPerStack[i], Abilities.Apocalypse.ExtraAtkPerStack[i]), i - 1)
end

--endregion

local cls = class("Apocalypse")

local channelMap = {}

EventCenter.RegisterPlayerUnitSpellChannel:Emit({
    id = Abilities.Apocalypse.ID,
    ---@param data ISpellData
    handler = function(data)
        if channelMap[data.caster] ~= nil then
            DestroyEffect(channelMap[data.caster])
        end
        channelMap[data.caster] = AddSpecialEffectTarget("Abilities/Spells/NightElf/TargetArtLumber/TargetArtLumber.mdl", data.caster, "weapon,left")
    end
})

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Abilities.Apocalypse.ID,
    ---@param data ISpellData
    handler = function(data)
        -- festering wound burst
        local debuff = BuffBase.FindBuffByClassName(data.target, FesteringWound.__cname)
        local count = 0
        if debuff then
            count = debuff.stack
            debuff:Burst(count)
        end

        local level = GetUnitAbilityLevel(data.caster, Abilities.Apocalypse.ID)
        local attr = UnitAttribute.GetAttr(data.caster)
        if not ExIsUnitDead(data.target) then
            local damage = attr:SimAttack(UnitAttribute.HeroAttributeType.Strength) * Abilities.Apocalypse.AtkMultiplier[level]
            UnitDamageTarget(data.caster, data.target, damage, true, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_METAL_HEAVY_SLICE)
            ExTextCriticalStrike(data.target, damage)
        end

        local v1 = Vector2.FromUnit(data.caster)
        local v2 = Vector2.FromUnit(data.target)
        local dir = (v2 - v1):SetNormalize()
        v1:Sub(dir * 600)
        local summoned = CreateUnit(GetOwningPlayer(data.caster), Abilities.Apocalypse.GargoyleID, v1.x, v1.y, GetUnitFacing(data.caster))
        local summonedAttr = UnitAttribute.GetAttr(summoned)
        summonedAttr.hp = summonedAttr.hp + count * Abilities.Apocalypse.ExtraHpPerStack[level]
        summonedAttr.atk = summonedAttr.atk + count * Abilities.Apocalypse.ExtraAtkPerStack[level]
        summonedAttr:Commit()

        local sfx = AddSpecialEffectTarget("Abilities/Spells/Other/BreathOfFire/BreathOfFireDamage.mdl", summoned, "origin")
        local sfx2 = AddSpecialEffectTarget("Objects/Spawnmodels/Undead/ImpaleTargetDust/ImpaleTargetDust.mdl", summoned, "origin")
        BlzSetSpecialEffectColor(sfx, 128, 255, 96)

        -- move gargoyle
        local targetHeight = GetUnitDefaultFlyHeight(summoned)
        local currentHeight = 600
        SetUnitFlyHeight(summoned, targetHeight + currentHeight, 0)

        SetUnitPathing(summoned, false)
        PauseUnit(summoned, true)
        local velocity = (v2 - v1):SetNormalize():Mul(600 * Time.Delta)
        coroutine.start(function()
            while true do
                currentHeight = currentHeight * 0.8
                SetUnitFlyHeight(summoned, currentHeight + targetHeight, 0)
                v1:Add(velocity)
                v1:UnitMoveTo(summoned)
                if (v2 - v1):GetMagnitude() < 96 then
                    break
                end
                coroutine.step()
            end
            SetUnitPathing(summoned, true)
            PauseUnit(summoned, false)
            SetUnitFlyHeight(summoned, targetHeight, 0)
            ExAddSpecialEffect("Objects/Spawnmodels/Undead/ImpaleTargetDust/ImpaleTargetDust.mdl", v2.x, v2.y, 2)
            ExAddSpecialEffect("Abilities/Spells/Orc/EarthQuake/EarthQuakeTarget.mdl", v2.x, v2.y, 2)

            DestroyEffect(sfx)
            DestroyEffect(sfx2)

            local soundEfx = AddSpecialEffect("Objects/Spawnmodels/Human/HCancelDeath/HCancelDeath.mdl", v2.x, v2.y)
            BlzSetSpecialEffectScale(soundEfx, 0.01)
            coroutine.wait(1)
            DestroyEffect(soundEfx)
        end)
    end
})

EventCenter.RegisterPlayerUnitSpellEndCast:Emit({
    id = Abilities.Apocalypse.ID,
    ---@param data ISpellData
    handler = function(data)
        coroutine.start(function()
            coroutine.wait(1.5)
            if channelMap[data.caster] then
                DestroyEffect(channelMap[data.caster])
                channelMap[data.caster] = nil
            end
        end)
    end
})

return cls
