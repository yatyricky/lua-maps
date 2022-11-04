--lua-bundler:000162889
local function RunBundle()
local __modules = {}
local require = function(path)
    local module = __modules[path]
    if module == nil then
        local dotPath = string.gsub(path, "/", "%.")
        module = __modules[dotPath]
        __modules[path] = module
    end
    if module ~= nil then
        if not module.inited then
            module.cached = module.loader()
            module.inited = true
        end
        return module.cached
    else
        error("module not found " .. path)
        return nil
    end
end

__modules["Ability.Apocalypse"]={loader=function()
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

end}

__modules["Ability.ArmyOfTheDead"]={loader=function()
local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local Vector2 = require("Lib.Vector2")
local Timer = require("Lib.Timer")
local Const = require("Config.Const")

--region meta

Abilities.ArmyOfTheDead = {
    ID = FourCC("A003")
}

BlzSetAbilityResearchTooltip(Abilities.ArmyOfTheDead.ID, "学习亡者大军 - [|cffffcc00%d级|r]", 0)
BlzSetAbilityResearchExtendedTooltip(Abilities.ArmyOfTheDead.ID, string.format([[召唤一支食尸鬼军团为你作战。食尸鬼会在你附近的区域横冲直撞，攻击一切它们可以攻击的目标。

|cffffcc001级|r - 召唤6个食尸鬼，每个具有660点生命值。]]
), 0)

for i = 1, 1 do
    BlzSetAbilityTooltip(Abilities.ArmyOfTheDead.ID, string.format("亡者大军 - [|cffffcc00%s级|r]", i), i - 1)
    BlzSetAbilityExtendedTooltip(Abilities.ArmyOfTheDead.ID, string.format("召唤一支食尸鬼军团为你作战。食尸鬼会在你附近的区域横冲直撞，攻击一切它们可以攻击的目标。召唤6个食尸鬼，每个具有660点生命值。"), i - 1)
end

--endregion

local instances = {} ---@type table<unit, ArmyOfTheDead>

local LesserColor = { r = 0.2, g = 0, b = 0.4, a = 1 }
local GreaterColor = { r = 0.6, g = 0.15, b = 0.4, a = 1 }

---@class ArmyOfTheDead
local cls = class("ArmyOfTheDead")

function cls:ctor(caster)
    local casterPos = Vector2.FromUnit(caster)
    local casterZ = casterPos:GetTerrainZ()
    self.sfxTimer = Timer.new(function()
        local pos = (Vector2.InsideUnitCircle() * math.random(200, 600)):Add(casterPos)
        ExAddLightningPosPos("CLSB", casterPos.x, casterPos.y, casterZ + 200, pos.x, pos.y, pos:GetTerrainZ(), math.random() * 0.4 + 0.2, LesserColor)
        ExAddSpecialEffect("Abilities/Spells/Undead/DeathandDecay/DeathandDecayTarget.mdl", pos.x, pos.y, 0.2)
    end, 0.2, -1)
    self.sfxTimer:Start()

    local player = GetOwningPlayer(caster)
    self.summonTimer = Timer.new(function()
        local pos = (Vector2.InsideUnitCircle() * math.random(200, 600)):Add(casterPos)
        local summoned = CreateUnit(player, FourCC("u000"), pos.x, pos.y, math.random(360))
        ExAddLightningPosUnit("CLPB", casterPos.x, casterPos.y, casterZ + 200, summoned, 1, GreaterColor)
        ExAddSpecialEffectTarget("Abilities/Spells/Undead/AnimateDead/AnimateDeadTarget.mdl", summoned, "origin", 0.1)
        UnitApplyTimedLife(summoned, FourCC("BUan"), 40)
        IssuePointOrderById(summoned, Const.OrderId_Attack, GetUnitX(caster), GetUnitY(caster))
    end, 1, -1)
    self.summonTimer:Start()
end

function cls:Stop()
    self.sfxTimer:Stop()
    self.summonTimer:Stop()
end

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Abilities.ArmyOfTheDead.ID,
    ---@param data ISpellData
    handler = function(data)
        instances[data.caster] = cls.new(data.caster, GetUnitAbilityLevel(data.caster, data.abilityId))
    end
})

EventCenter.RegisterPlayerUnitSpellEndCast:Emit({
    id = Abilities.ArmyOfTheDead.ID,
    ---@param data ISpellData
    handler = function(data)
        local inst = instances[data.caster]
        if inst then
            inst:Stop()
            instances[data.caster] = nil
        else
            print("army of the dead end but no instance")
        end
    end
})

return cls

end}

__modules["Ability.BladeStorm"]={loader=function()
-- 天神下凡-剑刃风暴

local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local Const = require("Config.Const")
local UnitAttribute = require("Objects.UnitAttribute")
local DeepWounds = require("Ability.DeepWounds")
local BuffBase = require("Objects.BuffBase")

--region meta

local Meta = {
    ID = FourCC("A01C"),
    Cost = 0.15,
    Interval = 1,
    Damage = 0.5,
    DeepWoundsStack = 1,
    DamageIncrease = 0.2,
    DamageReduction = 0.1,
    AOE = 397,
    Enlarge = 1.3,
    AvatarDurationMult = 2,
}

Abilities.BladeStorm = Meta

BlzSetAbilityResearchTooltip(Meta.ID, "学习天神剑刃风暴 - [|cffffcc00%d级|r]", 0)
BlzSetAbilityResearchExtendedTooltip(Meta.ID, string.format([[化作一股具有毁灭性力量的剑刃风暴，打击附近所有目标，每秒消耗|cffff8c00%s|r的怒气，造成|cffff8c00%s|r的攻击伤害并造成重伤效果，直到怒气耗尽。然后化身为巨人，使你造成的伤害提高|cffff8c00%s|r，受到的伤害降低|cffff8c00%s|r，普通攻击会附带重伤效果，持续时间等同于剑刃风暴的持续时间的|cffff8c00%s|r。

|cff99ccff冷却时间|r - 30秒]],
        string.formatPercentage(Meta.Cost), string.formatPercentage(Meta.Damage), string.formatPercentage(Meta.DamageIncrease), string.formatPercentage(Meta.DamageReduction), string.formatPercentage(Meta.AvatarDurationMult)
), 0)

for i = 1, 1 do
    BlzSetAbilityTooltip(Meta.ID, string.format("天神剑刃风暴 - [|cffffcc00%s级|r]", i), i - 1)
    BlzSetAbilityExtendedTooltip(Meta.ID, string.format(
            [[化作一股具有毁灭性力量的剑刃风暴，打击附近所有目标，每秒消耗|cffff8c00%s|r的怒气，造成|cffff8c00%s|r的攻击伤害并造成重伤效果，直到怒气耗尽。然后化身为巨人，使你造成的伤害提高|cffff8c00%s|r，受到的伤害降低|cffff8c00%s|r，普通攻击会附带重伤效果，持续时间等同于剑刃风暴的持续时间的|cffff8c00%s|r。

|cff99ccff冷却时间|r - 30秒]],
            string.formatPercentage(Meta.Cost), string.formatPercentage(Meta.Damage), string.formatPercentage(Meta.DamageIncrease), string.formatPercentage(Meta.DamageReduction), string.formatPercentage(Meta.AvatarDurationMult)),
            i - 1)
end

--endregion

---@class Avatar : BuffBase
local Avatar = class("Avatar", BuffBase)

function Avatar:OnEnable()
    --SetUnitScale(self.target, Meta.Enlarge, Meta.Enlarge, Meta.Enlarge)
    SetUnitVertexColor(self.target, 255, 255, 15, 255)
    local attr = UnitAttribute.GetAttr(self.target)
    attr.damageAmplification = attr.damageAmplification + Meta.DamageIncrease
    attr.damageReduction = attr.damageReduction + Meta.DamageReduction
end

function Avatar:OnDisable()
    --SetUnitScale(self.target, 1, 1, 1)
    SetUnitVertexColor(self.target, 255, 255, 255, 255)
    local attr = UnitAttribute.GetAttr(self.target)
    attr.damageAmplification = attr.damageAmplification - Meta.DamageIncrease
    attr.damageReduction = attr.damageReduction - Meta.DamageReduction
end

local cls = class("BladeStorm")

EventCenter.RegisterPlayerUnitSpellChannel:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        if ExGetUnitManaPortion(data.caster) < Meta.Cost then
            ExTextState(data.caster, "怒气不足")
            IssueImmediateOrderById(data.caster, Const.OrderId_Stop)
        end
    end
})

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        coroutine.start(function()
            local caster = data.caster

            AddUnitAnimationProperties(caster, "spin", true)
            local casterPlayer = GetOwningPlayer(caster)
            local attr = UnitAttribute.GetAttr(caster)
            local duration = 0
            while ExGetUnitManaPortion(caster) >= Meta.Cost do
                coroutine.wait(Meta.Interval)
                if ExIsUnitDead(caster) then
                    break
                end

                ExAddUnitMana(caster, ExGetUnitMaxMana(caster) * Meta.Cost * -1)
                duration = duration + Meta.Interval
                local damage = attr:SimAttack(UnitAttribute.HeroAttributeType.Strength) * Meta.Damage
                ExGroupEnumUnitsInRange(GetUnitX(caster), GetUnitY(caster), Meta.AOE, function(unit)
                    if IsUnitEnemy(unit, casterPlayer) and not ExIsUnitDead(unit) then
                        EventCenter.Damage:Emit({
                            whichUnit = caster,
                            target = unit,
                            amount = damage,
                            attack = false,
                            ranged = true,
                            attackType = ATTACK_TYPE_HERO,
                            damageType = DAMAGE_TYPE_DIVINE,
                            weaponType = WEAPON_TYPE_WHOKNOWS,
                            outResult = {},
                        })
                        if not ExIsUnitDead(unit) and not IsUnitType(unit, UNIT_TYPE_MECHANICAL) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE) then
                            DeepWounds.Cast(caster, unit)
                        end
                    end
                end)
            end
            AddUnitAnimationProperties(caster, "spin", false)

            if not ExIsUnitDead(caster) then
                ExAddSpecialEffectTarget("Abilities/Spells/Human/Avatar/AvatarCaster.mdl", caster, "overhead", 2)
                Avatar.new(caster, caster, duration, 999, {})
            end
        end)
    end
})

EventCenter.RegisterPlayerUnitDamaged:Emit(function(caster, target, _, _, _, isAttack)
    if not isAttack then
        return
    end

    if target == nil then
        return
    end

    if ExIsUnitDead(target) or IsUnitType(target, UNIT_TYPE_MECHANICAL) or IsUnitType(target, UNIT_TYPE_STRUCTURE) then
        return
    end

    local buff = BuffBase.FindBuffByClassName(caster, Avatar.__cname)

    if not buff then
        return
    end

    DeepWounds.Cast(caster, target)
end)

return cls

end}

__modules["Ability.BloodPlague"]={loader=function()
local EventCenter = require("Lib.EventCenter")
local BuffBase = require("Objects.BuffBase")
local Abilities = require("Config.Abilities")
local Timer = require("Lib.Timer")

---@class BloodPlague : BuffBase
local cls = class("BloodPlague", BuffBase)

function cls:Awake()
    self.level = self.awakeData.level
end

EventCenter.RegisterPlayerUnitDamaged:Emit(function(caster, target, _, _, _, isAttack)
    if not isAttack then
        return
    end

    local debuff = BuffBase.FindBuffByClassName(target, "BloodPlague")
    if not debuff then
        return
    end

    local maxHp = GetUnitState(target, UNIT_STATE_MAX_LIFE)
    local damage = maxHp * Abilities.PlagueStrike.BloodPlagueData[debuff.level]

    UnitDamageTarget(caster, target, damage, false, true, ATTACK_TYPE_MAGIC, DAMAGE_TYPE_POISON, WEAPON_TYPE_WHOKNOWS)

    local impact = AddSpecialEffectTarget("Objects/Spawnmodels/Human/HumanBlood/HeroBloodElfBlood.mdl", target, "origin")
    local impactTimer = Timer.new(function()
        DestroyEffect(impact)
    end, 2, 1)
    impactTimer:Start()
end)

return cls

end}

__modules["Ability.Charge"]={loader=function()
-- 蹒跚冲锋

local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local BuffBase = require("Objects.BuffBase")
local Vector2 = require("Lib.Vector2")
local Const = require("Config.Const")
local RootDebuff = require("Ability.RootDebuff")

--region meta

Abilities.Charge = {
    ID = FourCC("A018"),
    Damage = 0.2,
    MinDistance = 300,
    Speed = 800,
    DurationMinion = { 10, 20, 30 },
    DurationHero = { 2, 5, 10 },
    Rage = 0.2,
}

local Meta = Abilities.Charge

BlzSetAbilityResearchTooltip(Meta.ID, "学习冲锋 - [|cffffcc00%d级|r]", 0)
BlzSetAbilityResearchExtendedTooltip(Meta.ID, string.format([[向一名敌人冲锋，造成|cffff8c00%s|r的攻击伤害，使其定身，并生成|cffff8c00%s|r的怒气值。

|cff99ccff施法距离|r - %s-900
|cff99ccff冷却时间|r - 10秒

|cffffcc001级|r - 持续|cffff8c00%s|r秒，英雄|cffff8c00%s|r秒。
|cffffcc002级|r - 持续|cffff8c00%s|r秒，英雄|cffff8c00%s|r秒。
|cffffcc003级|r - 持续|cffff8c00%s|r秒，英雄|cffff8c00%s|r秒。]],
        string.formatPercentage(Meta.Damage), string.formatPercentage(Meta.Rage), Meta.MinDistance,
        Meta.DurationMinion[1], Meta.DurationHero[1],
        Meta.DurationMinion[2], Meta.DurationHero[2],
        Meta.DurationMinion[3], Meta.DurationHero[3]
), 0)

for i = 1, #Meta.DurationMinion do
    BlzSetAbilityTooltip(Meta.ID, string.format("冲锋 - [|cffffcc00%s级|r]", i), i - 1)
    BlzSetAbilityExtendedTooltip(Meta.ID, string.format(
            [[向一名敌人冲锋，造成|cffff8c00%s|r的攻击伤害，使其定身|cffff8c00%s|r秒，英雄|cffff8c00%s|r秒，并生成|cffff8c00%s|r的法力值。

|cff99ccff施法距离|r - %s-900
|cff99ccff冷却时间|r - 10秒]],
            string.formatPercentage(Meta.Damage), Meta.DurationMinion[i], Meta.DurationHero[i], string.formatPercentage(Meta.Rage), Meta.MinDistance),
            i - 1)
end

--endregion

local cls = class("Charge")

EventCenter.RegisterPlayerUnitSpellChannel:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        local v1 = Vector2.FromUnit(data.caster)
        local v2 = Vector2.FromUnit(data.target)
        if (v2 - v1):GetMagnitude() < Meta.MinDistance then
            IssueImmediateOrderById(data.caster, Const.OrderId_Stop)
            ExTextState(data.caster, "太近了")
        end
    end
})

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        coroutine.start(function()
            coroutine.step()
            SetUnitPathing(data.caster, false)
            local defaultRange = GetUnitAcquireRange(data.caster)
            SetUnitAcquireRange(data.caster, 0)
            SetUnitTimeScale(data.caster, 3)
            SetUnitAnimationByIndex(data.caster, 6)
            local sfx = AddSpecialEffectTarget("Abilities/Spells/Other/Tornado/Tornado_Target.mdl", data.caster, "origin")
            local sfx1 = AddSpecialEffectTarget("Abilities/Spells/Other/Tornado/Tornado_Target.mdl", data.caster, "weapon")
            local sfx2 = AddSpecialEffectTarget("Abilities/Spells/Other/Tornado/Tornado_Target.mdl", data.caster, "overhead")
            local sfx3 = AddSpecialEffectTarget("Abilities/Weapons/PhoenixMissile/Phoenix_Missile.mdl", data.caster, "origin")
            BlzSetSpecialEffectScale(sfx3, 0.2)
            local travelled = 10
            while true do
                local v1 = Vector2.FromUnit(data.caster)
                local v2 = Vector2.FromUnit(data.target)
                local v3 = v2 - v1
                local distance = math.max(v3:GetMagnitude() - 96, 0)
                local shouldMove = Meta.Speed * Time.Delta
                local norm = v3:SetNormalize()
                SetUnitFacing(data.caster, math.atan2(norm.y, norm.x) * bj_RADTODEG)
                local move
                local hit
                if distance > shouldMove then
                    move = shouldMove
                    hit = false
                else
                    move = distance
                    hit = true
                end
                v1:Add(norm * move)
                v1:UnitMoveTo(data.caster)

                travelled = travelled + distance
                if travelled > 96 then
                    travelled = 0
                    ExAddSpecialEffect("Environment/SmallBuildingFire/SmallBuildingFire0.mdl", v1.x,v1.y, 1.2)
                end

                if hit then
                    break
                end

                coroutine.step()
            end

            DestroyEffect(sfx)
            DestroyEffect(sfx1)
            DestroyEffect(sfx2)
            DestroyEffect(sfx3)
            SetUnitPathing(data.caster, true)
            IssueImmediateOrderById(data.target, Const.OrderId_Stop)
            SetUnitAcquireRange(data.caster, defaultRange)
            SetUnitTimeScale(data.caster, 1)

            local level = GetUnitAbilityLevel(data.caster, Meta.ID)
            local duration = IsUnitType(data.target, UNIT_TYPE_HERO) and Meta.DurationHero[level] or Meta.DurationMinion[level]
            local debuff = BuffBase.FindBuffByClassName(data.target, RootDebuff.__cname)
            if debuff then
                debuff:ResetDuration(Time.Time + duration)
            else
                RootDebuff.new(data.caster, data.target, duration, 999)
            end

            local mana = GetUnitState(data.caster, UNIT_STATE_MAX_MANA) * Meta.Rage
            SetUnitState(data.caster, UNIT_STATE_MANA, GetUnitState(data.caster, UNIT_STATE_MANA) + mana)
        end)
    end
})

return cls

end}

__modules["Ability.Condemn"]={loader=function()
-- 判罪

local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local Const = require("Config.Const")

--region meta

local Meta = {
    ID = FourCC("A01B"),
    ThresholdHigh = 0.8,
    ThresholdLow = 0.35,
    MissBackRage = 0.2,
    PerRagePercent = 0.01,
    Cost = 0.2,
    Damage = { 3, 5, 7 },
}

Abilities.Condemn = Meta

BlzSetAbilityResearchTooltip(Meta.ID, "学习判罪 - [|cffffcc00%d级|r]", 0)
BlzSetAbilityResearchExtendedTooltip(Meta.ID, string.format([[让敌人为自己罪孽而遭受折磨，消耗剩余所有怒气造成伤害。只可对生命值高于|cffff8c00%s|r或低于|cffff8c00%s|r的敌人使用。如果未命中，返还|cffff8c00%s|r的怒气。

|cff99ccff怒气消耗|r - %s

|cffffcc001级|r - 每|cffff8c00%s|r的怒气造成|cffff8c00%s|r点伤害。
|cffffcc002级|r - 每|cffff8c00%s|r的怒气造成|cffff8c00%s|r点伤害。
|cffffcc003级|r - 每|cffff8c00%s|r的怒气造成|cffff8c00%s|r点伤害。]],
        string.formatPercentage(Meta.ThresholdHigh), string.formatPercentage(Meta.ThresholdLow), string.formatPercentage(Meta.MissBackRage), string.formatPercentage(Meta.Cost),
        string.formatPercentage(Meta.PerRagePercent), Meta.Damage[1],
        string.formatPercentage(Meta.PerRagePercent), Meta.Damage[2],
        string.formatPercentage(Meta.PerRagePercent), Meta.Damage[3]
), 0)

for i = 1, #Meta.Damage do
    BlzSetAbilityTooltip(Meta.ID, string.format("判罪 - [|cffffcc00%s级|r]", i), i - 1)
    BlzSetAbilityExtendedTooltip(Meta.ID, string.format(
            [[让敌人为自己罪孽而遭受折磨，消耗剩余所有怒气造成伤害，每|cffff8c00%s|r的怒气造成|cffff8c00%s|r点伤害。只可对生命值高于|cffff8c00%s|r或低于|cffff8c00%s|r的敌人使用。如果未命中，返还|cffff8c00%s|r的怒气。

|cff99ccff怒气消耗|r - %s]],
            string.formatPercentage(Meta.PerRagePercent), Meta.Damage[i], string.formatPercentage(Meta.ThresholdHigh), string.formatPercentage(Meta.ThresholdLow), string.formatPercentage(Meta.MissBackRage), string.formatPercentage(Meta.Cost)),
            i - 1)
end

--endregion

local cls = class("Condemn")

local effects = {}

EventCenter.RegisterPlayerUnitSpellChannel:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        local targetHpp = ExGetUnitLifePortion(data.target)
        if targetHpp < Meta.ThresholdHigh and targetHpp > Meta.ThresholdLow then
            ExTextState(data.target, "无法使用")
            IssueImmediateOrderById(data.caster, Const.OrderId_Stop)
            return
        end

        if effects[data.caster] ~= nil then
            DestroyEffect(effects[data.caster])
        end
        -- Abilities/Spells/Undead/OrbOfDeath/AnnihilationMissile.mdl
        -- Abilities/Weapons/PhoenixMissile/Phoenix_Missile.mdl
        effects[data.caster] = AddSpecialEffectTarget("Abilities/Spells/Undead/OrbOfDeath/AnnihilationMissile.mdl", data.caster, "weapon,left")
    end
})

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        local level = GetUnitAbilityLevel(data.caster, Meta.ID)
        local damage = ExGetUnitManaPortion(data.caster) / Meta.PerRagePercent * Meta.Damage[level]

        local result = {}
        EventCenter.Damage:Emit({
            whichUnit = data.caster,
            target = data.target,
            amount = damage,
            attack = true,
            ranged = false,
            attackType = ATTACK_TYPE_HERO,
            damageType = DAMAGE_TYPE_MAGIC,
            weaponType = WEAPON_TYPE_WHOKNOWS,
            outResult = result,
        })

        if result.hitResult == Const.HitResult_Miss then
            SetUnitManaBJ(data.caster, Meta.MissBackRage * ExGetUnitMaxMana(data.caster))
            return
        end

        ExTextTag(data.target, damage, { r = 1, g = 0.1, b = 1, a = 1 })
        --ExAddSpecialEffectTarget("Abilities/Spells/Undead/OrbOfDeath/AnnihilationMissile.mdl", data.target, "origin", 0)
        SetUnitManaBJ(data.caster, 0)
    end
})

EventCenter.RegisterPlayerUnitSpellEndCast:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        if effects[data.caster] then
            --BlzSetSpecialEffectZ(effects[data.caster], -1000)
            DestroyEffect(effects[data.caster])
            effects[data.caster] = nil
            --coroutine.start(function()
            --    coroutine.wait(1.5)
            --end)
        end
    end
})

return cls

end}

__modules["Ability.DarkTransformation"]={loader=function()
-- 黑暗突变

local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local Vector2 = require("Lib.Vector2")

--region meta

Abilities.DarkTransformation = {
    ID = FourCC("A007"),
    TechID = FourCC("R000"),
    AbominationID = FourCC("u002"),
}

BlzSetAbilityResearchTooltip(Abilities.DarkTransformation.ID, "学习黑暗突变", 0)
BlzSetAbilityResearchExtendedTooltip(Abilities.DarkTransformation.ID, string.format([[学习此技能后，你的食尸鬼和石像鬼部队永久获得|cffff8c00+10|r攻击力和|cffff8c00+100|r生命值。

对一个食尸鬼施展，可以将其永久转化为一个拥有|cffff8c001800|r生命值的憎恶，并获得|cffff8c004个全新的强力技能|r。

|cff99ccff法力消耗|r - 1000点
|cff99ccff冷却时间|r - 60秒]]), 0)

for i = 1, 1 do
    BlzSetAbilityTooltip(Abilities.DarkTransformation.ID, string.format("黑暗突变", i), i - 1)
    BlzSetAbilityExtendedTooltip(Abilities.DarkTransformation.ID, string.format([[你的食尸鬼和石像鬼部队永久获得|cffff8c00+10|r攻击力和|cffff8c00+100|r生命值。

对一个食尸鬼施展，可以将其永久转化为一个拥有|cffff8c001800|r生命值的憎恶，并获得|cffff8c004个全新的强力技能|r。

|cff99ccff法力消耗|r - 1000点
|cff99ccff冷却时间|r - 60秒]]), i - 1)
end

--endregion

local cls = class("DarkTransformation")

local channelSfx = {}

EventCenter.RegisterPlayerUnitSpellChannel:Emit({
    id = Abilities.DarkTransformation.ID,
    ---@param data ISpellData
    handler = function(data)
        channelSfx[data.caster] = AddSpecialEffectTarget("Abilities/Spells/Undead/Unsummon/UnsummonTarget.mdl", data.target, "origin")
    end
})

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Abilities.DarkTransformation.ID,
    ---@param data ISpellData
    handler = function(data)
        local pos = Vector2.FromUnit(data.target)
        local facing = GetUnitFacing(data.target)
        KillUnit(data.target)
        ExAddSpecialEffect("Objects/Spawnmodels/Human/HumanBlood/HeroBloodElfBlood.mdl", pos.x, pos.y, 2.0)

        local constructAbomination = AddSpecialEffect("Units/Undead/Abomination/AbominationExplosion.mdl", pos.x, pos.y)
        BlzSetSpecialEffectTime(constructAbomination, 1.8)
        BlzSetSpecialEffectScale(constructAbomination, 1.2)
        BlzSetSpecialEffectColor(constructAbomination, 127, 255, 150)
        BlzSetSpecialEffectTimeScale(constructAbomination, -1)
        coroutine.start(function()
            coroutine.wait(1.6)
            BlzSetSpecialEffectPosition(constructAbomination, 0, 0, -1000)
            DestroyEffect(constructAbomination)
            local summoned = CreateUnit(GetOwningPlayer(data.caster), Abilities.DarkTransformation.AbominationID, pos.x, pos.y, facing)
            ExAddSpecialEffectTarget("Abilities/Spells/Undead/AnimateDead/AnimateDeadTarget.mdl", summoned, "origin", 1)
        end)
    end
})

EventCenter.RegisterPlayerUnitSpellEndCast:Emit({
    id = Abilities.DarkTransformation.ID,
    ---@param data ISpellData
    handler = function(data)
        if channelSfx[data.caster] then
            DestroyEffect(channelSfx[data.caster])
            channelSfx[data.caster] = nil
        end
    end
})

ExTriggerRegisterUnitLearn(Abilities.DarkTransformation.ID, function(unit, _)
    local p = GetOwningPlayer(unit)
    SetPlayerTechResearched(p, Abilities.DarkTransformation.TechID, 1)
end)

return cls

-- 蹒跚冲锋
-- 腐臭壁垒
end}

__modules["Ability.DeathCoil"]={loader=function()
local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local BuffBase = require("Objects.BuffBase")
local ProjectileBase = require("Objects.ProjectileBase")
local FesteringWound = require("Ability.FesteringWound")
local Const = require("Config.Const")

--region meta

Abilities.DeathCoil = {
    ID = FourCC("A015"),
    Heal = { 0.2, 0.25, 0.35 },
    Damage = { 70, 140, 210 },
    Wounds = { 3, 5, 7 },
    AmplificationPerStack = 0.05,
    ProcPerStack = 0.05,
    ManaCost = 300,
}

BlzSetAbilityResearchTooltip(Abilities.DeathCoil.ID, "学习死亡缠绕 - [|cffffcc00%d级|r]", 0)
BlzSetAbilityResearchExtendedTooltip(Abilities.DeathCoil.ID, string.format([[释放邪恶的能量，对一个敌对目标造成点伤害，或者为一个友方亡灵目标恢复生命值。目标身上的每层溃烂之伤会为死亡缠绕增幅|cffff8c005%%|r。并叠加溃烂之伤。普通攻击时，目标身上的每层溃烂之伤提供|cffff8c00%s%%|r的几率立即冷却死亡缠绕并且不消耗法力值。

|cff99ccff施法距离|r - 700
|cff99ccff法力消耗|r - %s点
|cff99ccff冷却时间|r - 8秒

|cffffcc001级|r - 恢复|cffff8c00%s%%|r生命值，造成|cffff8c00%s|r点伤害，叠加|cffff8c00%s|r层溃烂之伤。
|cffffcc002级|r - 恢复|cffff8c00%s%%|r生命值，造成|cffff8c00%s|r点伤害，叠加|cffff8c00%s|r层溃烂之伤。
|cffffcc003级|r - 恢复|cffff8c00%s%%|r生命值，造成|cffff8c00%s|r点伤害，叠加|cffff8c00%s|r层溃烂之伤。]],
        math.round(Abilities.DeathCoil.ProcPerStack * 100), Abilities.DeathCoil.ManaCost,
        math.round(Abilities.DeathCoil.Heal[1] * 100), Abilities.DeathCoil.Damage[1], Abilities.DeathCoil.Wounds[1],
        math.round(Abilities.DeathCoil.Heal[2] * 100), Abilities.DeathCoil.Damage[2], Abilities.DeathCoil.Wounds[2],
        math.round(Abilities.DeathCoil.Heal[3] * 100), Abilities.DeathCoil.Damage[3], Abilities.DeathCoil.Wounds[3]
), 0)

for i = 1, #Abilities.DeathCoil.Heal do
    BlzSetAbilityTooltip(Abilities.DeathCoil.ID, string.format("死亡缠绕 - [|cffffcc00%s级|r]", i), i - 1)
    BlzSetAbilityExtendedTooltip(Abilities.DeathCoil.ID, string.format(
            [[释放邪恶的能量，对一个敌对目标造成|cffff8c00%s|r点伤害，或者为一个友方亡灵目标恢复|cffff8c00%s%%|r生命值。目标身上的每层溃烂之伤会为死亡缠绕增幅|cffff8c005%%|r。并叠加|cffff8c00%s|r层溃烂之伤。普通攻击时，目标身上的每层溃烂之伤提供|cffff8c005%%|r的几率立即冷却死亡缠绕并且不消耗法力值。

|cff99ccff施法距离|r - 700
|cff99ccff法力消耗|r - 100点
|cff99ccff冷却时间|r - 8秒]],
            Abilities.DeathCoil.Damage[i], math.round(Abilities.DeathCoil.Heal[i] * 100), Abilities.DeathCoil.Wounds[i]),
            i - 1)
end

--endregion

local cls = class("DeathCoil")

local indicator = {}

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
                -- 并叠加溃烂之伤
                local debuff = BuffBase.FindBuffByClassName(data.target, FesteringWound.__cname)
                local stack = debuff and debuff.stack or 0
                if debuff then
                    debuff:IncreaseStack(Abilities.DeathCoil.Wounds[level])
                else
                    debuff = FesteringWound.new(data.caster, data.target, Abilities.FesteringWound.Duration, 9999, {})
                    debuff:IncreaseStack(Abilities.DeathCoil.Wounds[level] - 1)
                end

                -- 敌军，伤害+debuff
                local damage = Abilities.DeathCoil.Damage[level] * (1 + Abilities.DeathCoil.AmplificationPerStack * stack)
                UnitDamageTarget(data.caster, data.target, damage, false, true, ATTACK_TYPE_HERO, DAMAGE_TYPE_MAGIC, WEAPON_TYPE_WHOKNOWS)
            end

            -- sfx
            ExAddSpecialEffectTarget("Abilities/Spells/Undead/DeathCoil/DeathCoilSpecialArt.mdl", data.target, "origin", 2)
        end, nil)
    end
})

EventCenter.RegisterPlayerUnitSpellEndCast:Emit({
    id = Abilities.DeathCoil.ID,
    ---@param data ISpellData
    handler = function(data)
        local level = GetUnitAbilityLevel(data.caster, data.abilityId)
        BlzSetUnitAbilityManaCost(data.caster, Abilities.DeathCoil.ID, level - 1, Abilities.DeathCoil.ManaCost)

        if indicator[data.caster] ~= nil then
            DestroyEffect(indicator[data.caster])
            indicator[data.caster] = nil
        end
        --IssueImmediateOrder(data.caster, "weboff")
    end
})

-- 普通攻击时，目标身上的每层溃烂之伤提供5%%的几率立即冷却死亡缠绕并且不消耗法力值。
EventCenter.RegisterPlayerUnitDamaged:Emit(function(caster, target, _, _, _, isAttack)
    if not isAttack then
        return
    end

    local level = GetUnitAbilityLevel(caster, Abilities.DeathCoil.ID)
    if level <= 0 then
        return
    end

    local debuff = BuffBase.FindBuffByClassName(target, FesteringWound.__cname)
    if not debuff then
        return
    end

    local chance = math.random() < debuff.stack * Abilities.DeathCoil.ProcPerStack
    if chance then
        BlzEndUnitAbilityCooldown(caster, Abilities.DeathCoil.ID)
        BlzSetUnitAbilityManaCost(caster, Abilities.DeathCoil.ID, level - 1, 0)
        --IssueImmediateOrder(caster, "webon")
        IssueTargetOrderById(caster, Const.OrderId_Attack, target)

        if indicator[caster] ~= nil then
            DestroyEffect(indicator[caster])
        end
        indicator[caster] = AddSpecialEffectTarget("Abilities/Spells/Undead/DeathCoil/DeathCoilMissile.mdl", caster, "overhead")
    end
end)

return cls

end}

__modules["Ability.DeathGrip"]={loader=function()
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
            dir:SetMagnitude(StepLen):Add(v2):UnitMoveTo(target)
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

end}

__modules["Ability.DeathStrike"]={loader=function()
local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local Timer = require("Lib.Timer")
local BloodPlague = require("Ability.BloodPlague")
local FrostPlague = require("Ability.FrostPlague")
local UnholyPlague = require("Ability.UnholyPlague")
local PlagueStrike = require("Ability.PlagueStrike")

--region meta

Abilities.DeathStrike = {
    ID = FourCC("A001"),
    Damage = { 80, 120, 160 },
    Heal = { 0.08, 0.12, 0.16 },
}

BlzSetAbilityResearchTooltip(Abilities.DeathStrike.ID, "学习灵界打击 - [|cffffcc00%d级|r]", 0)
BlzSetAbilityResearchExtendedTooltip(Abilities.DeathStrike.ID, string.format([[致命的攻击，对目标造成一次伤害，并根据目标身上的瘟疫数量，每有一个便为死亡骑士恢复他最大生命值百分比的效果，并且会将目标身上的所有瘟疫传染给附近所有敌人。

|cffffcc001级|r - 造成%s点伤害，每个瘟疫恢复%s%%最大生命值。
|cffffcc002级|r - 造成%s点伤害，每个瘟疫恢复%s%%最大生命值。
|cffffcc003级|r - 造成%s点伤害，每个瘟疫恢复%s%%最大生命值。]],
        Abilities.DeathStrike.Damage[1], math.round(Abilities.DeathStrike.Heal[1] * 100),
        Abilities.DeathStrike.Damage[2], math.round(Abilities.DeathStrike.Heal[2] * 100),
        Abilities.DeathStrike.Damage[3], math.round(Abilities.DeathStrike.Heal[3] * 100)
), 0)

for i = 1, #Abilities.DeathStrike.Damage do
    BlzSetAbilityTooltip(Abilities.DeathStrike.ID, string.format("灵界打击 - [|cffffcc00%s级|r]", i), i - 1)
    BlzSetAbilityExtendedTooltip(Abilities.DeathStrike.ID, string.format("致命的攻击，对目标造成%s点伤害，并根据目标身上的瘟疫数量，每有一个便为死亡骑士恢复他最大生命值的%s%%，并且会将目标身上的所有瘟疫传染给附近范围内所有敌人。", Abilities.DeathStrike.Damage[i], math.round(Abilities.DeathStrike.Heal[i] * 100)), i - 1)
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
        -- damage
        local level = GetUnitAbilityLevel(data.caster, data.abilityId)
        UnitDamageTarget(data.caster, data.target, Abilities.DeathStrike.Damage[level], false, true, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_METAL_HEAVY_SLICE)

        -- spread
        PlagueStrike.Spread(data.caster, data.target)

        local count = PlagueStrike.GetPlagueCount(data.target)
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

end}

__modules["Ability.DeepWounds"]={loader=function()
local BuffBase = require("Objects.BuffBase")
local Abilities = require("Config.Abilities")
local UnitAttribute = require("Objects.UnitAttribute")

--region meta

Abilities.DeepWounds = {
    ID = FourCC("A017"),
    DamageScale = 0.1,
    Duration = 10,
    Interval = 1,
}

BlzSetAbilityTooltip(Abilities.DeepWounds.ID, string.format("重伤"), 0)
BlzSetAbilityExtendedTooltip(Abilities.DeepWounds.ID, string.format("你的压制、致死打击、或者天神下凡状态下的普通攻击，会对敌人造成重伤效果，每|cffff8c00%s|r秒造成|cffff8c00%s|r的攻击伤害，持续|cffff8c00%s|r秒。",
        Abilities.DeepWounds.Interval, string.formatPercentage(Abilities.DeepWounds.DamageScale), Abilities.DeepWounds.Duration), 0)

--endregion

---@class DeepWounds : BuffBase
local cls = class("DeepWounds", BuffBase)

function cls:Update()
    local attr = UnitAttribute.GetAttr(self.caster)
    local damage = attr:SimAttack(UnitAttribute.HeroAttributeType.Agility) * Abilities.DeepWounds.DamageScale * self.stack
    UnitDamageTarget(self.caster, self.target, damage, false, true, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS)
    ExAddSpecialEffectTarget("Objects/Spawnmodels/Human/HumanBlood/HeroBloodElfBlood.mdl", self.target, "origin", 0.5)
end

function cls.Cast(caster, target)
    local debuff = BuffBase.FindBuffByClassName(target, cls.__cname)
    if debuff then
        debuff:IncreaseStack()
    else
        cls.new(caster, target, Abilities.DeepWounds.Duration, Abilities.DeepWounds.Interval, {})
    end
end

return cls

end}

__modules["Ability.Defile"]={loader=function()
-- 亵渎

local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local BuffBase = require("Objects.BuffBase")
local FesteringWound = require("Ability.FesteringWound")
local Timer = require("Lib.Timer")
local Circle = require("Lib.Circle")
local Vector2 = require("Lib.Vector2")

--region meta

Abilities.Defile = {
    ID = FourCC("A008"),
    Interval = 1,
    Duration = 10,
    AOE = 256,
    AOEGrowth = 32, -- max = 256 + 32*10 = 576
    DamageGrowth = 0.1,
    Damage = { 5, 10, 15 },
    CleaveTargets = { 2, 4, 6 },
    FesteringWoundStackPerProc = 1,
}

BlzSetAbilityResearchTooltip(Abilities.Defile.ID, "学习亵渎 - [|cffffcc00%d级|r]", 0)
BlzSetAbilityResearchExtendedTooltip(Abilities.Defile.ID, string.format([[亵渎死亡骑士指定的一片土地，每秒对所有敌人造成伤害并叠加一层溃烂之伤，持续|cffff8c00%s|r秒。当你站在自己的亵渎范围内时，你的普通攻击会击中目标附近的其他敌人。如果有任意敌人站在被亵渎的土地上，亵渎面积会扩大，伤害每秒都会提高|cffff8c00%s%%|r。

|cff99ccff施法距离|r - 600
|cff99ccff影响范围|r - 250-550
|cff99ccff法力消耗|r - 600点
|cff99ccff冷却时间|r - 10秒

|cffffcc001级|r - 每秒造成|cffff8c00%s|r点伤害，击中|cffff8c00%s|r个敌人。
|cffffcc002级|r - 每秒造成|cffff8c00%s|r点伤害，击中|cffff8c00%s|r个敌人。
|cffffcc003级|r - 每秒造成|cffff8c00%s|r点伤害，击中|cffff8c00%s|r个敌人。]],
        Abilities.Defile.Duration, math.round(Abilities.Defile.DamageGrowth * 100),
        Abilities.Defile.Damage[1], Abilities.Defile.CleaveTargets[1],
        Abilities.Defile.Damage[2], Abilities.Defile.CleaveTargets[2],
        Abilities.Defile.Damage[3], Abilities.Defile.CleaveTargets[3]
), 0)

for i = 1, #Abilities.Defile.Damage do
    BlzSetAbilityTooltip(Abilities.Defile.ID, string.format("亵渎 - [|cffffcc00%s级|r]", i), i - 1)
    BlzSetAbilityExtendedTooltip(Abilities.Defile.ID, string.format([[亵渎死亡骑士指定的一片土地，每秒对所有敌人造成|cffff8c00%s|r点伤害并叠加一层溃烂之伤，持续|cffff8c00%s|r秒。当你站在自己的亵渎范围内时，你的普通攻击会击中目标附近的|cffff8c00%s|r个敌人。如果有任意敌人站在被亵渎的土地上，亵渎面积会扩大，伤害每秒都会提高|cffff8c00%s%%|r。

|cff99ccff施法距离|r - 600
|cff99ccff影响范围|r - 250-550
|cff99ccff法力消耗|r - 30点
|cff99ccff冷却时间|r - 10秒]],
            Abilities.Defile.Damage[i], Abilities.Defile.Duration, Abilities.Defile.CleaveTargets[i], math.round(Abilities.Defile.DamageGrowth * 100)), i - 1)
end

--endregion

local cls = class("Defile")

cls.instances = {}

---@param c Circle
local function drawRing(c)
    local tm = Timer.new(function()
        for i = 1, 36 do
            local x = math.cos(i * 10 * bj_DEGTORAD) * c.r + c.center.x
            local y = math.sin(i * 10 * bj_DEGTORAD) * c.r + c.center.y
            ExAddSpecialEffect("Abilities/Spells/Undead/DeathandDecay/DeathandDecayTarget.mdl", x, y, 0.5)
        end
    end, 0.5, 2)
    tm:Start()
end

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Abilities.Defile.ID,
    ---@param data ISpellData
    handler = function(data)
        local circle = Circle.new(Vector2.new(data.x, data.y), Abilities.Defile.AOE)
        local tab = table.getOrCreateTable(cls.instances, data.caster)
        table.insert(tab, circle)
        local casterPlayer = GetOwningPlayer(data.caster)
        local level = GetUnitAbilityLevel(data.caster, Abilities.Defile.ID)
        local bonus = 0

        drawRing(circle)
        local timer = Timer.new(function()
            local hasAnyUnit = false
            ExGroupEnumUnitsInRange(data.x, data.y, circle.r, function(e)
                if IsUnitEnemy(e, casterPlayer) and not IsUnitType(e, UNIT_TYPE_STRUCTURE) and not IsUnitType(e, UNIT_TYPE_MECHANICAL) and not ExIsUnitDead(e) then
                    hasAnyUnit = true
                    -- 并叠加溃烂之伤
                    local debuff = BuffBase.FindBuffByClassName(e, FesteringWound.__cname)
                    if debuff then
                        debuff:IncreaseStack(Abilities.Defile.FesteringWoundStackPerProc)
                    else
                        debuff = FesteringWound.new(data.caster, e, Abilities.FesteringWound.Duration, 9999, {})
                    end

                    -- 造成伤害
                    local damage = Abilities.Defile.Damage[level] * (1 + bonus)
                    UnitDamageTarget(data.caster, e, damage, false, true, ATTACK_TYPE_HERO, DAMAGE_TYPE_MAGIC, WEAPON_TYPE_WHOKNOWS)
                end
            end)

            local newR = circle.r
            -- 如果有任意敌人站在被亵渎的土地上
            -- 亵渎面积会扩大，伤害每秒都会提高
            if hasAnyUnit then
                newR = newR + Abilities.Defile.AOEGrowth
                bonus = bonus + Abilities.Defile.DamageGrowth
            end

            circle.r = newR
            drawRing(circle)
        end, Abilities.Defile.Interval, Abilities.Defile.Duration)
        timer:Start()

        timer.onStop = function()
            -- 移除黑水效果
            for i, _ in ipairs(tab) do
                tab[i] = nil
            end
        end
    end
})

-- 当你站在自己的亵渎范围内时，你的普通攻击会击中目标附近的其他敌人
EventCenter.RegisterPlayerUnitDamaged:Emit(function(caster, target, damage, _, _, isAttack)
    if not isAttack then
        return
    end

    if target == nil then
        return
    end

    -- 检查是否站在亵渎里面
    local tab = table.getOrCreateTable(cls.instances, caster)
    local standingOnDefiledGround = false
    local vec = Vector2.FromUnit(caster)
    local circle
    for i = #tab, 1, -1 do
        circle = tab[i]
        if circle:Contains(vec) then
            standingOnDefiledGround = true
            break
        end
    end

    if not standingOnDefiledGround then
        return
    end

    local candidates = {}
    local targetPlayer = GetOwningPlayer(target)
    local v1 = Vector2.FromUnit(target)
    local v2 = Vector2.new(0, 0)
    ExGroupEnumUnitsInRange(GetUnitX(target), GetUnitY(target), circle.r, function(e)
        if not IsUnit(e, target) and IsUnitAlly(e, targetPlayer) and not ExIsUnitDead(e) then
            v2:MoveToUnit(e):Sub(v1)
            table.insert(candidates, { unit = e, dist = v2:GetMagnitude() })
        end
    end)
    table.sort(candidates, function(a, b)
        return a.dist < b.dist
    end)

    local level = GetUnitAbilityLevel(caster, Abilities.Defile.ID)
    local victims = table.slice(candidates, 1, Abilities.Defile.CleaveTargets[level])
    for _, v in ipairs(victims) do
        UnitDamageTarget(caster, v.unit, damage, false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_DIVINE, WEAPON_TYPE_WHOKNOWS)
    end
end)

return cls

end}

__modules["Ability.Evasion"]={loader=function()
-- 闪避

local Abilities = require("Config.Abilities")
local UnitAttribute = require("Objects.UnitAttribute")

--region meta

local Meta = {
    ID = FourCC("A015"),
    Chance = { 0.15, 0.3, 0.45 },
    ChanceInc = { 0.15, 0.15, 0.15 },
    --Chance = { 1, 1, 1 },
    --ChanceInc = { 1, 0, 0 },
}

Abilities.Evasion = Meta

--BlzSetAbilityTooltip(Abilities.Evasion.ID, string.format("腐臭壁垒", 0), 0)
--BlzSetAbilityExtendedTooltip(Abilities.Evasion.ID, string.format("发出固守咆哮，受到的所有伤害降低|cffff8c00%s|r，持续|cffff8c00%s|r秒。",
--        string.formatPercentage(Abilities.Evasion.Reduction), Abilities.Evasion.Duration), 0)

--endregion

---@class Evasion
local cls = class("Evasion")

ExTriggerRegisterUnitLearn(Meta.ID, function(unit, level, _)
    local attr = UnitAttribute.GetAttr(unit)
    attr.dodge = attr.dodge + Meta.ChanceInc[level]
end)

ExTriggerRegisterNewUnit(function(unit)
    local level = GetUnitAbilityLevel(unit, Meta.ID)
    if level > 0 then
        local attr = UnitAttribute.GetAttr(unit)
        attr.dodge = attr.dodge + Meta.Chance[level]
    end
end)

return cls

end}

__modules["Ability.FesteringWound"]={loader=function()
-- 溃烂之伤

local EventCenter = require("Lib.EventCenter")
local BuffBase = require("Objects.BuffBase")
local Abilities = require("Config.Abilities")
local ProjectileBase = require("Objects.ProjectileBase")
local Vector2 = require("Lib.Vector2")

--region meta

Abilities.FesteringWound = {
    ID = FourCC("A00A"),
    Duration = 30,
    Damage = 15,
    ManaRegen = 50,
    ExtraMana = 30,
}

BlzSetAbilityTooltip(Abilities.FesteringWound.ID, "溃烂之伤", 0)
BlzSetAbilityExtendedTooltip(Abilities.FesteringWound.ID, string.format(
        [[死亡骑士的普通攻击会恢复|cffff8c00%s|r法力值，并导致目标身上的一层溃烂之伤爆发，造成|cffff8c00%s|r点额外伤害并为死亡骑士额外恢复|cffff8c00%s|r点法力值。溃烂之伤时间到时会直接爆发。如果目标死亡时仍携带溃烂之伤，剩余的溃烂之伤会转移到附近|cffff8c00600|r码范围内的随机敌人。

|cff99ccff持续时间|r - %s秒]],
        Abilities.FesteringWound.ManaRegen, Abilities.FesteringWound.Damage, Abilities.FesteringWound.ExtraMana, Abilities.FesteringWound.Duration),
        0)

--endregion

---@class FesteringWound : BuffBase
local cls = class("FesteringWound", BuffBase)

function cls:OnEnable()
    self.sfx = AddSpecialEffectTarget("Abilities/Spells/Other/Parasite/ParasiteTarget.mdl", self.target, "overhead")
    --BlzSetSpecialEffectColor(self.sfx, 255, 128, 0)
end

function cls:OnDisable()
    DestroyEffect(self.sfx)

    if self.stack < 0 then
        return
    end

    if ExIsUnitDead(self.target) then
        local pos = Vector2.FromUnit(self.target)
        local enemyPlayer = GetOwningPlayer(self.target)
        local candidates = {}
        ExGroupEnumUnitsInRange(pos.x, pos.y, 600, function(unit)
            if IsUnitAlly(unit, enemyPlayer) and not ExIsUnitDead(unit) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE) and not IsUnitType(unit, UNIT_TYPE_MECHANICAL) then
                table.insert(candidates, unit)
            end
        end)
        local target = table.iGetRandom(candidates)
        if target ~= nil then
            local transmittedStack = self.stack
            local caster = self.caster
            ProjectileBase.new(caster, target, "Abilities/Weapons/ChimaeraAcidMissile/ChimaeraAcidMissile.mdl", 300, function()
                -- 并叠加溃烂之伤
                local debuff = BuffBase.FindBuffByClassName(target, cls.__cname)
                if debuff then
                    debuff:IncreaseStack(transmittedStack)
                else
                    debuff = cls.new(caster, target, Abilities.FesteringWound.Duration, 9999, {})
                    debuff:IncreaseStack(transmittedStack - 1)
                end
            end, pos - Vector2.FromUnit(self.caster))
        end
    else
        self:Burst(self.stack)
    end
end

function cls:execBurst(stacks)
    local damage = Abilities.FesteringWound.Damage * stacks
    local mana = Abilities.FesteringWound.ExtraMana * stacks
    UnitDamageTarget(self.caster, self.target, damage, false, true, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS)
    SetUnitState(self.caster, UNIT_STATE_MANA, GetUnitState(self.caster, UNIT_STATE_MANA) + mana)

    ExAddSpecialEffectTarget("Abilities/Spells/Undead/ReplenishMana/ReplenishManaCaster.mdl", self.caster, "origin", 0.1)
end

function cls:Burst(stacks)
    stacks = stacks or 1
    stacks = math.min(self.stack, stacks)

    if stacks <= 0 then
        return
    end

    self:execBurst(stacks)
    self:DecreaseStack(stacks)
end

EventCenter.RegisterPlayerUnitDamaged:Emit(function(caster, target, _, _, _, isAttack)
    if not isAttack then
        return
    end

    local level = GetUnitAbilityLevel(caster, Abilities.FesteringWound.ID)
    if level <= 0 then
        return
    end

    SetUnitState(caster, UNIT_STATE_MANA, GetUnitState(caster, UNIT_STATE_MANA) + Abilities.FesteringWound.ManaRegen)

    local debuff = BuffBase.FindBuffByClassName(target, cls.__cname)
    if not debuff then
        return
    end

    debuff:Burst()
end)

return cls

end}

__modules["Ability.FrostPlague"]={loader=function()
local BuffBase = require("Objects.BuffBase")
local Abilities = require("Config.Abilities")
local Time = require("Lib.Time")

---@class FrostPlague : BuffBase
local cls = class("FrostPlague", BuffBase)

function cls:Awake()
    self.level = self.awakeData.level
end

function cls:OnEnable()
    ExAddSpecialEffectTarget("Abilities/Spells/Undead/FrostArmor/FrostArmorDamage.mdl", self.target, "origin", Time.Delta)
end

function cls:Update()
    ExAddSpecialEffectTarget("Abilities/Spells/Undead/FrostArmor/FrostArmorDamage.mdl", self.target, "origin", Time.Delta)
end

function cls:OnDisable()
    local speedLossPercent = math.clamp01(1 - GetUnitMoveSpeed(self.target) / 500)
    local damage = Abilities.PlagueStrike.FrostPlagueData[self.level] * (1 + speedLossPercent)
    UnitDamageTarget(self.caster, self.target, damage, false, true, ATTACK_TYPE_MAGIC, DAMAGE_TYPE_POISON, WEAPON_TYPE_WHOKNOWS)

    ExAddSpecialEffectTarget("Abilities/Weapons/ZigguratMissile/ZigguratMissile.mdl", self.target, "origin", Time.Delta)
end

return cls

end}

__modules["Ability.MonstrousBlow"]={loader=function()
-- 蛮兽打击

local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local Const = require("Config.Const")
local Timer = require("Lib.Timer")

--region meta

Abilities.MonstrousBlow = {
    ID = FourCC("A00B"),
    Duration = 2,
    Damage = 150,
}

BlzSetAbilityTooltip(Abilities.MonstrousBlow.ID, string.format("蛮兽打击"), 0)
BlzSetAbilityExtendedTooltip(Abilities.MonstrousBlow.ID, string.format("一次野蛮的攻击，对目标造成|cffff8c00%s|r点伤害并使其昏迷|cffff8c00%s|r秒。",
        Abilities.MonstrousBlow.Damage, Abilities.MonstrousBlow.Duration), 0)

--endregion

local cls = class("MonstrousBlow")

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Abilities.MonstrousBlow.ID,
    ---@param data ISpellData
    handler = function(data)
        UnitDamageTarget(data.caster, data.target, Abilities.MonstrousBlow.Damage, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WOOD_HEAVY_BASH)

        IssueImmediateOrderById(data.target, Const.OrderId_Stop)
        local sfx = AddSpecialEffectTarget("Abilities/Spells/Human/Thunderclap/ThunderclapTarget.mdl", data.target, "overhead")
        PauseUnit(data.target, true)
        local timer = Timer.new(function()
            PauseUnit(data.target, false)
            DestroyEffect(sfx)
        end, Abilities.MonstrousBlow.Duration, 1)
        timer:Start()
    end
})

return cls

end}

__modules["Ability.MoonWellHeal"]={loader=function()
-- 月亮井

local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local Vector2 = require("Lib.Vector2")

--region meta

local Meta = {
    ID = FourCC("Ambt"),
    MoonWell = FourCC("emow"),
    --ID = FourCC("A01B"),
    Life = 2,
    Mana = 0.5,
}

Abilities.MoonWellHeal = Meta

--endregion

local cls = class("MoonWellHeal")

local waterEffects = {}
local underConstruction = {}
local moonWells = {}

local function updateWaterLevel(unit)
    local v = Vector2.FromUnit(unit)
    if waterEffects[unit] == nil then
        waterEffects[unit] = AddSpecialEffect("Abilities/Spells/NightElf/MoonWell/MoonWellTarget.mdl", v.x, v.y)
    end
    local eff = waterEffects[unit]
    local level = math.clamp(GetUnitState(unit, UNIT_STATE_MANA) / 500, 0, 1)
    BlzSetSpecialEffectZ(eff, v:GetTerrainZ() + level * 20 + 1)
end

coroutine.start(function()
    while true do
        coroutine.step()
        for unit, _ in pairs(moonWells) do
            if ExIsUnitDead(unit) then
                moonWells[unit] = nil
            else
                if not underConstruction[unit] then
                    updateWaterLevel(unit)
                end
            end
        end
    end
end)

local function getMoonWellTargetWeight(unit)
    return ExGetUnitLifeLoss(unit) / Meta.Life + ExGetUnitManaLoss(unit) / Meta.Mana
end

coroutine.start(function()
    while true do
        coroutine.wait(0.5)
        for unit, _ in pairs(moonWells) do
            if not ExIsUnitDead(unit) and not underConstruction[unit] and ExGetUnitMana(unit) >= 10 then
                local v = Vector2.FromUnit(unit)
                local wellPlayer = GetOwningPlayer(unit)
                local units = table.iWhere(ExGroupGetUnitsInRange(v.x, v.y, 600), function(e)
                    local loss = getMoonWellTargetWeight(e)
                    return not ExIsUnitDead(e) and not IsUnitType(e, UNIT_TYPE_STRUCTURE)
                            and not IsUnitType(e, UNIT_TYPE_MECHANICAL) and not underConstruction[e] and loss > 1
                            and IsUnitAlly(e, wellPlayer)
                end)
                table.sort(units, function(a, b)
                    return getMoonWellTargetWeight(a) > getMoonWellTargetWeight(b)
                end)
                local target = units[1]
                if target then
                    local hpLoss = ExGetUnitLifeLoss(target)
                    local manaLoss = ExGetUnitManaLoss(target)
                    local oldMana = ExGetUnitMana(unit)
                    local wellMana = oldMana

                    local mana4Hp = hpLoss / Meta.Life
                    local cost = math.min(wellMana, mana4Hp)
                    wellMana = wellMana - cost
                    local heal = cost * Meta.Life
                    if heal > 0 then
                        EventCenter.Heal:Emit({
                            caster = unit,
                            target = target,
                            amount = heal,
                        })
                    end

                    local mana4Mp = manaLoss / Meta.Mana
                    cost = math.min(wellMana, mana4Mp)
                    wellMana = wellMana - cost
                    heal = cost * Meta.Mana
                    if heal > 0 then
                        EventCenter.HealMana:Emit({
                            caster = unit,
                            target = target,
                            amount = cost * Meta.Mana,
                        })
                    end

                    ExSetUnitMana(unit, wellMana)

                    if wellMana < oldMana then
                        ExAddSpecialEffectTarget("Abilities/Spells/Human/Heal/HealTarget.mdl", target, "origin", 1)
                        ExAddSpecialEffectTarget("Abilities/Spells/NightElf/MoonWell/MoonWellCasterArt.mdl", unit, "origin", 2)
                    end
                end
            end
        end
    end
end)

ExTriggerRegisterNewUnit(function(unit)
    if GetUnitTypeId(unit) ~= Meta.MoonWell then
        return
    end

    moonWells[unit] = true
end)

local startConstruction = CreateTrigger()
TriggerRegisterAnyUnitEventBJ(startConstruction, EVENT_PLAYER_UNIT_CONSTRUCT_START)
ExTriggerAddAction(startConstruction, function()
    underConstruction[GetTriggerUnit()] = true
end)

local finishConstruction = CreateTrigger()
TriggerRegisterAnyUnitEventBJ(finishConstruction, EVENT_PLAYER_UNIT_CONSTRUCT_FINISH)
ExTriggerAddAction(finishConstruction, function()
    underConstruction[GetTriggerUnit()] = nil
end)

local cancelConstruction = CreateTrigger()
TriggerRegisterAnyUnitEventBJ(cancelConstruction, EVENT_PLAYER_UNIT_CONSTRUCT_CANCEL)
ExTriggerAddAction(cancelConstruction, function()
    underConstruction[GetTriggerUnit()] = nil
end)

ExTriggerRegisterUnitDeath(function(unit)
    if waterEffects[unit] ~= nil then
        DestroyEffect(waterEffects[unit])
        waterEffects[unit] = nil
    end
end)

return cls

end}

__modules["Ability.MortalStrike"]={loader=function()
-- 致死打击

local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local UnitAttribute = require("Objects.UnitAttribute")
local DeepWounds = require("Ability.DeepWounds")
local BuffBase = require("Objects.BuffBase")
local Const = require("Config.Const")

--region meta

local Meta = {
    ID = FourCC("A01A"),
    HealingDecrease = 0.7,
    DamageScale = { 1.7, 2.6, 3.5 },
    Duration = { 10, 20, 30 },
    Rage = 0.2,
}

Abilities.MortalStrike = Meta

BlzSetAbilityResearchTooltip(Meta.ID, "学习致死打击 - [|cffffcc00%d级|r]", 0)
BlzSetAbilityResearchExtendedTooltip(Meta.ID, string.format([[一次残忍的突袭，对目标造成攻击伤害，并使其受到的治疗效果降低|cffff8c00%s|r，且造成一层|cffff8c00重伤|r效果。产生|cffff8c0020%%|r的怒气。

|cff99ccff冷却时间|r - 6秒

|cffffcc001级|r - |cffff8c00%s|r的攻击伤害，持续|cffff8c00%s|r秒。
|cffffcc002级|r - |cffff8c00%s|r的攻击伤害，持续|cffff8c00%s|r秒。
|cffffcc003级|r - |cffff8c00%s|r的攻击伤害，持续|cffff8c00%s|r秒。]],
        string.formatPercentage(Meta.HealingDecrease),
        string.formatPercentage(Meta.DamageScale[1]), Meta.Duration[1],
        string.formatPercentage(Meta.DamageScale[2]), Meta.Duration[2],
        string.formatPercentage(Meta.DamageScale[3]), Meta.Duration[3]
), 0)

for i = 1, #Meta.DamageScale do
    BlzSetAbilityTooltip(Meta.ID, string.format("致死打击 - [|cffffcc00%s级|r]", i), i - 1)
    BlzSetAbilityExtendedTooltip(Meta.ID, string.format(
            [[一次残忍的突袭，对目标造成|cffff8c00%s|r的攻击伤害，并使其受到的治疗效果降低|cffff8c00%s|r，且造成一层|cffff8c00重伤|r效果。产生20%%的怒气。

|cff99ccff冷却时间|r - 6秒
|cff99ccff持续时间|r - %s秒]],
            string.formatPercentage(Meta.DamageScale[i]), Meta.HealingDecrease, Meta.Duration[i]),
            i - 1)
end

--endregion

---@class MortalBuff : BuffBase
local MortalBuff = class("MortalBuff", BuffBase)

function MortalBuff:OnEnable()
    local attr = UnitAttribute.GetAttr(self.target)
    attr.healingTaken = attr.healingTaken - Meta.HealingDecrease
end

function MortalBuff:OnDisable()
    local attr = UnitAttribute.GetAttr(self.target)
    attr.healingTaken = attr.healingTaken + Meta.HealingDecrease
end

local cls = class("MortalStrike")

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        local level = GetUnitAbilityLevel(data.caster, Meta.ID)
        local attr = UnitAttribute.GetAttr(data.caster)
        local damage = attr:SimAttack(UnitAttribute.HeroAttributeType.Strength) * Meta.DamageScale[level]

        local result = {}
        EventCenter.Damage:Emit({
            whichUnit = data.caster,
            target = data.target,
            amount = damage,
            attack = true,
            ranged = false,
            attackType = ATTACK_TYPE_HERO,
            damageType = DAMAGE_TYPE_NORMAL,
            weaponType = WEAPON_TYPE_METAL_HEAVY_SLICE,
            outResult = result,
        })

        if result.hitResult == Const.HitResult_Miss then
            return
        end

        ExTextCriticalStrike(data.target, result.damage)
        ExAddSpecialEffectTarget("Abilities/Spells/Orc/Disenchant/DisenchantSpecialArt.mdl", data.target, "origin", 1)

        if ExIsUnitDead(data.target) then
            return
        end

        ExAddUnitMana(data.caster, ExGetUnitMaxMana(data.caster) * Meta.Rage)
        DeepWounds.Cast(data.caster, data.target)
        local debuff = BuffBase.FindBuffByClassName(data.target, MortalBuff.__cname)
        if debuff then
            debuff:ResetDuration()
        else
            debuff = MortalBuff.new(data.caster, data.target, Meta.Duration[level], 999, {})
        end
    end
})

return cls

end}

__modules["Ability.Outbreak"]={loader=function()
-- 传染
end}

__modules["Ability.Overpower"]={loader=function()
-- 压制

local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local Const = require("Config.Const")
local Timer = require("Lib.Timer")
local UnitAttribute = require("Objects.UnitAttribute")
local DeepWounds = require("Ability.DeepWounds")

--region meta

Abilities.Overpower = {
    ID = FourCC("A016"),
    TechUnitID = FourCC("e000"),
    DamageScale = 1.2,
}

BlzSetAbilityTooltip(Abilities.Overpower.ID, string.format("压制"), 0)
BlzSetAbilityExtendedTooltip(Abilities.Overpower.ID, string.format("敌人|cffff8c00躲闪后|r可以使用，压制敌人，造成|cffff8c00%s|r的攻击伤害并造成一层|cffff8c00重伤|r效果。",
        string.formatPercentage(Abilities.Overpower.DamageScale)), 0)

--endregion

local cls = class("Overpower")

cls.unitOverpowers = {}

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Abilities.Overpower.ID,
    ---@param data ISpellData
    handler = function(data)
        local attr = UnitAttribute.GetAttr(data.caster)
        local damage = attr:SimAttack(UnitAttribute.HeroAttributeType.Agility) * Abilities.Overpower.DamageScale
        local result = {}
        EventCenter.Damage:Emit({
            whichUnit = data.caster,
            target = data.target,
            amount = damage,
            attack = false,
            ranged = false,
            attackType = ATTACK_TYPE_HERO,
            damageType = DAMAGE_TYPE_NORMAL,
            weaponType = WEAPON_TYPE_WOOD_HEAVY_BASH,
            outResult = result,
        })

        if not ExIsUnitDead(data.target) then
            DeepWounds.Cast(data.caster, data.target)
        end

        ExTextCriticalStrike(data.target, result.damage)

        local tab = table.getOrCreateTable(cls.unitOverpowers, data.caster)
        for k, v in pairs(tab) do
            if not ExIsUnitDead(v) then
                KillUnit(v)
            end
            tab[k] = nil
        end
    end
})

EventCenter.PlayerUnitAttackMiss:On(cls, function(context, data)
    local level = GetUnitAbilityLevel(data.caster, Abilities.Overpower.ID)
    if level <= 0 then
        return
    end

    local tab = table.getOrCreateTable(cls.unitOverpowers, data.caster)
    table.insert(tab, CreateUnit(GetOwningPlayer(data.caster), Abilities.Overpower.TechUnitID, 0, 0, 0))
end)

return cls

end}

__modules["Ability.PlagueStrike"]={loader=function()
local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local BuffBase = require("Objects.BuffBase")
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
    AOE = { 500, 600, 700 },
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
邪恶瘟疫：受到持续的伤害，生命值越低，受到伤害越高，可叠加持续时间。

|cffffcc001级|r - 鲜血瘟疫持续%s秒，造成最大生命%s%%的伤害；冰霜瘟疫持续%s秒，造成%s伤害；邪恶瘟疫持续%s秒，每%s秒造成%s伤害。
|cffffcc002级|r - 鲜血瘟疫持续%s秒，造成最大生命%s%%的伤害；冰霜瘟疫持续%s秒，造成%s伤害；邪恶瘟疫持续%s秒，每%s秒造成%s伤害。
|cffffcc003级|r - 鲜血瘟疫持续%s秒，造成最大生命%s%%的伤害；冰霜瘟疫持续%s秒，造成%s伤害；邪恶瘟疫持续%s秒，每%s秒造成%s伤害。]],
        Abilities.PlagueStrike.BloodPlagueDuration[1], (Abilities.PlagueStrike.BloodPlagueData[1] * 100), Abilities.PlagueStrike.FrostPlagueDuration[1], Abilities.PlagueStrike.FrostPlagueData[1], Abilities.PlagueStrike.UnholyPlagueDuration[1], Abilities.PlagueStrike.UnholyPlagueInterval[1], Abilities.PlagueStrike.UnholyPlagueData[1],
        Abilities.PlagueStrike.BloodPlagueDuration[2], (Abilities.PlagueStrike.BloodPlagueData[2] * 100), Abilities.PlagueStrike.FrostPlagueDuration[2], Abilities.PlagueStrike.FrostPlagueData[2], Abilities.PlagueStrike.UnholyPlagueDuration[2], Abilities.PlagueStrike.UnholyPlagueInterval[2], Abilities.PlagueStrike.UnholyPlagueData[2],
        Abilities.PlagueStrike.BloodPlagueDuration[3], (Abilities.PlagueStrike.BloodPlagueData[3] * 100), Abilities.PlagueStrike.FrostPlagueDuration[3], Abilities.PlagueStrike.FrostPlagueData[3], Abilities.PlagueStrike.UnholyPlagueDuration[3], Abilities.PlagueStrike.UnholyPlagueInterval[3], Abilities.PlagueStrike.UnholyPlagueData[3]
), 0)

for i = 1, #Abilities.PlagueStrike.BloodPlagueDuration do
    local tooltip = string.format("瘟疫打击 - [|cffffcc00%s级|r]", i)
    local extTooltip = string.format([[每次攻击都会依次给敌人造成鲜血瘟疫、冰霜瘟疫、邪恶瘟疫的效果。

鲜血瘟疫：持续%s秒，目标受到攻击时，受到最大生命值%s%%的伤害。
冰霜瘟疫：%s秒后，受到%s点冰霜伤害，目标移动速度越低，受到伤害越高。
邪恶瘟疫：持续%s秒，每%s秒受到%s点伤害，生命值越低，受到伤害越高，可叠加持续时间。]], Abilities.PlagueStrike.BloodPlagueDuration[i], (Abilities.PlagueStrike.BloodPlagueData[i] * 100), Abilities.PlagueStrike.FrostPlagueDuration[i], Abilities.PlagueStrike.FrostPlagueData[i], Abilities.PlagueStrike.UnholyPlagueDuration[i], Abilities.PlagueStrike.UnholyPlagueInterval[i], Abilities.PlagueStrike.UnholyPlagueData[i])
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

function cls.Spread(caster, target)
    local existingPlagues = {} ---@type BuffBase[]
    for _, plagueDefine in ipairs(cls.Plagues) do
        local debuff = BuffBase.FindBuffByClassName(target, plagueDefine.class.__cname)
        if debuff then
            table.insert(existingPlagues, debuff)
        end
    end
    if table.any(existingPlagues) then
        local color = { r = 0.1, g = 0.7, b = 0.1, a = 1 }
        local targetPlayer = GetOwningPlayer(target)
        local level = GetUnitAbilityLevel(caster, Abilities.PlagueStrike.ID)
        ExGroupEnumUnitsInRange(GetUnitX(target), GetUnitY(target), Abilities.PlagueStrike.AOE[level], function(e)
            if not IsUnit(e, target) and IsUnitAlly(e, targetPlayer) and not IsUnitType(e, UNIT_TYPE_STRUCTURE) and not IsUnitType(e, UNIT_TYPE_MECHANICAL) and not ExIsUnitDead(e) then
                ExAddLightningUnitUnit("SPLK", target, e, 0.3, color, false)

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
end

function cls.GetPlagueCount(target)
    local count = 0
    for _, plagueDefine in ipairs(cls.Plagues) do
        local debuff = BuffBase.FindBuffByClassName(target, plagueDefine.class.__cname)
        if debuff then
            count = count + 1
        end
    end
    return count
end

return cls

end}

__modules["Ability.PutridBulwark"]={loader=function()
-- 腐臭壁垒

local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local BuffBase = require("Objects.BuffBase")

--region meta

Abilities.PutridBulwark = {
    ID = FourCC("A014"),
    Reduction = 0.5,
    Duration = 10,
}

BlzSetAbilityTooltip(Abilities.PutridBulwark.ID, string.format("腐臭壁垒", 0), 0)
BlzSetAbilityExtendedTooltip(Abilities.PutridBulwark.ID, string.format("发出固守咆哮，受到的所有伤害降低|cffff8c00%s|r，持续|cffff8c00%s|r秒。",
        string.formatPercentage(Abilities.PutridBulwark.Reduction), Abilities.PutridBulwark.Duration), 0)

--endregion

---@class PutridBulwark : BuffBase
local cls = class("PutridBulwark", BuffBase)

function cls:OnEnable()
    self.sfx = AddSpecialEffectTarget("Abilities/Spells/Items/AIda/AIdaTarget.mdl", self.target, "overhead")
    BlzSetSpecialEffectColor(self.sfx, 96, 255, 96)
end

function cls:OnDisable()
    DestroyEffect(self.sfx)
end

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Abilities.PutridBulwark.ID,
    ---@param data ISpellData
    handler = function(data)
        ExAddSpecialEffectTarget("Abilities/Spells/Other/HowlOfTerror/HowlCaster.mdl", data.caster, "overhead", 2)
        local buff = BuffBase.FindBuffByClassName(data.caster, cls.__cname)
        if buff then
            buff:ResetDuration()
        else
            buff = cls.new(data.caster, data.caster, Abilities.PutridBulwark.Duration, 999)
        end
    end
})

EventCenter.RegisterPlayerUnitDamaging:Emit(function(caster, target, damage, weaponType, damageType, isAttack)
    local buff = BuffBase.FindBuffByClassName(target, cls.__cname)
    if not buff then
        return
    end

    BlzSetEventDamage(damage * Abilities.PutridBulwark.Reduction)
end)

return cls

end}

__modules["Ability.RageGenerator"]={loader=function()
local Abilities = require("Config.Abilities")
local EventCenter = require("Lib.EventCenter")
local Timer = require("Lib.Timer")

--region meta

Abilities.RageGenerator = {
    ID = FourCC("A019"),
    RageGeneratorAutoGen = 0.02,
    RageGeneratorPerAttack = 0.05,
    RageGeneratorPerHit = 2,
    ExitCombatInterval = 6,
}

--endregion

---@class RageGenerator
local cls = class("RageGenerator")

local combatUnits = {}

local function isUnitRageGenerator(u)
    return GetUnitAbilityLevel(u, Abilities.RageGenerator.ID) > 0
end

local exitCombatTimer = {}

local function waitForExitCombat(unit)
    local timer = exitCombatTimer[unit]
    if timer then
        timer:Stop()
    end
    timer = Timer.new(function()
        combatUnits[unit] = -1
        ExTextState(unit, "离开战斗")
    end, Abilities.RageGenerator.ExitCombatInterval, 1)
    exitCombatTimer[unit] = timer
    timer:Start()
end

ExTriggerRegisterUnitAcquire(function(caster, target)
    if isUnitRageGenerator(caster) then
        if combatUnits[caster] ~= 1 then
            ExTextState(caster, "进入战斗")
        end
        combatUnits[caster] = 1
        waitForExitCombat(caster)
    end
    if isUnitRageGenerator(target) then
        if combatUnits[target] ~= 1 then
            ExTextState(target, "进入战斗")
        end
        combatUnits[target] = 1
        waitForExitCombat(target)
    end
end)

ExTriggerRegisterNewUnit(function(unit)
    if isUnitRageGenerator(unit) then
        SetUnitState(unit, UNIT_STATE_MANA, 0)
        combatUnits[unit] = -1
    end
end)

EventCenter.RegisterPlayerUnitDamaged:Emit(function(caster, target, damage, _, _, isAttack)
    if damage < 1 then
        return
    end

    if isUnitRageGenerator(caster) then
        if isAttack then
            local mana = GetUnitState(caster, UNIT_STATE_MAX_MANA) * Abilities.RageGenerator.RageGeneratorPerAttack
            SetUnitState(caster, UNIT_STATE_MANA, GetUnitState(caster, UNIT_STATE_MANA) + mana)
            waitForExitCombat(caster)
        end
    end
    if isUnitRageGenerator(target) then
        local percent = damage / GetUnitState(target, UNIT_STATE_MAX_LIFE)
        local mana = GetUnitState(target, UNIT_STATE_MAX_MANA) * percent * Abilities.RageGenerator.RageGeneratorPerHit
        SetUnitState(target, UNIT_STATE_MANA, GetUnitState(target, UNIT_STATE_MANA) + mana)
        waitForExitCombat(target)
    end
end)

coroutine.start(function()
    while true do
        coroutine.wait(1)
        for unit, flag in pairs(combatUnits) do
            if flag == -1 then
                local mana = GetUnitState(unit, UNIT_STATE_MAX_MANA) * Abilities.RageGenerator.RageGeneratorAutoGen * flag
                SetUnitState(unit, UNIT_STATE_MANA, GetUnitState(unit, UNIT_STATE_MANA) + mana)
            end
        end
    end
end)

return cls

end}

__modules["Ability.RootDebuff"]={loader=function()
local BuffBase = require("Objects.BuffBase")

---@class SlowDebuff : BuffBase
local cls = class("RootDebuff", BuffBase)

function cls:OnEnable()
    SetUnitMoveSpeed(self.target, 0)
end

function cls:OnDisable()
    SetUnitMoveSpeed(self.target, GetUnitDefaultMoveSpeed(self.target))
end

return cls

end}

__modules["Ability.ShamblingRush"]={loader=function()
-- 蹒跚冲锋

local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local BuffBase = require("Objects.BuffBase")
local Vector2 = require("Lib.Vector2")
local Const = require("Config.Const")
local RootDebuff = require("Ability.RootDebuff")

--region meta

Abilities.ShamblingRush = {
    ID = FourCC("A013"),
    Speed = 400,
    Duration = 6,
}

BlzSetAbilityTooltip(Abilities.ShamblingRush.ID, string.format("蹒跚冲锋"), 0)
BlzSetAbilityExtendedTooltip(Abilities.ShamblingRush.ID, string.format("向敌人冲锋，打断其正在施放的法术并使其不能移动，持续|cffff8c00%s|r秒。",
        Abilities.ShamblingRush.Duration), 0)

--endregion

local cls = class("ShamblingRush")

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Abilities.ShamblingRush.ID,
    ---@param data ISpellData
    handler = function(data)
        coroutine.start(function()
            coroutine.step()
            SetUnitPathing(data.caster, false)
            local defaultRange = GetUnitAcquireRange(data.caster)
            SetUnitAcquireRange(data.caster, 0)
            SetUnitTimeScale(data.caster, 3)
            SetUnitAnimationByIndex(data.caster, 1)
            local sfx = AddSpecialEffectTarget("Objects/Spawnmodels/Undead/ImpaleTargetDust/ImpaleTargetDust.mdl", data.caster, "origin")
            while true do
                local v1 = Vector2.FromUnit(data.caster)
                local v2 = Vector2.FromUnit(data.target)
                local v3 = v2 - v1
                local distance = math.max(v3:GetMagnitude() - 96, 0)
                local shouldMove = Abilities.ShamblingRush.Speed * Time.Delta
                local norm = v3:SetNormalize()
                SetUnitFacing(data.caster, math.atan2(norm.y, norm.x) * bj_RADTODEG)
                local move
                local hit
                if distance > shouldMove then
                    move = shouldMove
                    hit = false
                else
                    move = distance
                    hit = true
                end
                v1:Add(norm * move)
                v1:UnitMoveTo(data.caster)

                if hit then
                    break
                end

                coroutine.step()
            end

            DestroyEffect(sfx)
            SetUnitPathing(data.caster, true)
            IssueImmediateOrderById(data.target, Const.OrderId_Stop)
            SetUnitAcquireRange(data.caster, defaultRange)
            SetUnitTimeScale(data.caster, 1)
            local debuff = BuffBase.FindBuffByClassName(data.target, RootDebuff.__cname)
            if debuff then
                debuff:ResetDuration(Time.Time + Abilities.ShamblingRush.Duration)
            else
                RootDebuff.new(data.caster, data.target, Abilities.ShamblingRush.Duration, 999)
            end
        end)
    end
})

return cls

end}

__modules["Ability.UnholyPlague"]={loader=function()
local BuffBase = require("Objects.BuffBase")
local Abilities = require("Config.Abilities")

---@class UnholyPlague : BuffBase
local cls = class("UnholyPlague", BuffBase)

function cls:Awake()
    self.level = self.awakeData.level
end

function cls:OnEnable()
    self.sfx = AddSpecialEffectTarget("Units/Undead/PlagueCloud/PlagueCloudtarget.mdl", self.target, "overhead")
end

function cls:Update()
    local hpLossPercent = 1 - GetUnitState(self.target, UNIT_STATE_LIFE) / GetUnitState(self.target, UNIT_STATE_MAX_LIFE)
    local damage = Abilities.PlagueStrike.UnholyPlagueData[self.level] * (1 + hpLossPercent)
    UnitDamageTarget(self.caster, self.target, damage, false, true, ATTACK_TYPE_MAGIC, DAMAGE_TYPE_POISON, WEAPON_TYPE_WHOKNOWS)
end

function cls:OnDisable()
    DestroyEffect(self.sfx)
end

return cls

end}

__modules["AI.TwistedMeadows"]={loader=function()
local EventCenter = require("Lib.EventCenter")
local Const = require("Config.Const")
local Vector2 = require("Lib.Vector2")

local sequence = {
    FourCC("AEmb"),
    FourCC("A015"),
    FourCC("A015"),
    FourCC("AEmb"),
    FourCC("A015"),
    FourCC("AEme"),
    FourCC("AEmb"),
    FourCC("AEim"),
    FourCC("AEim"),
    FourCC("AEim"),
}

local DH = FourCC("Edem")
local camps = {}

local basePos = Vector2.new(-3571, 4437)

local Interval = 1.3

local cls = class("TwistedMeadows")

function cls:ctor()
    local trigger = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trigger, EVENT_PLAYER_HERO_LEVEL)
    ExTriggerAddAction(trigger, function()
        local unit = GetTriggerUnit()
        --local player = GetOwningPlayer(unit)
        if GetUnitTypeId(unit) == DH then
            local level = GetUnitLevel(unit)
            SelectHeroSkill(unit, sequence[level])
        end
    end)

    local finishConstruction = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(finishConstruction, EVENT_PLAYER_UNIT_CONSTRUCT_FINISH)
    ExTriggerAddAction(finishConstruction, function()
        local unit = GetTriggerUnit()
        if GetUnitTypeId(unit) == FourCC("eate") then
            DestroyTrigger(finishConstruction)
            self.altar = unit
        end
    end)

    self.time = 0

    self.done = false
    self.unitFarm = {}

    ExTriggerRegisterUnitAcquire(function(caster, target)
        if (ExGetUnitPlayerId(caster) == 0 and ExGetUnitPlayerId(target) == 1) or (ExGetUnitPlayerId(caster) == 1 and ExGetUnitPlayerId(target) == 0) then
            self.done = true
        end
    end)
end

local p1 = Player(1)
local p0 = Player(0)

function cls:Update(dt)
    if not self.done and self.altar ~= nil then
        IssueTrainOrderByIdBJ(self.altar, DH)
    end

    self.time = self.time + dt
    if self.time >= Interval then
        self.time = self.time % Interval
        SetPlayerState(p1, PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(p1, PLAYER_STATE_RESOURCE_GOLD) + 5)
        if not self.done then
            self:run()
        end
    end
end

function cls:run()
    local hp = 0
    local p2 = Player(1)
    local force = {}
    ExGroupEnumUnitsInMap(function(unit)
        if GetOwningPlayer(unit) == p2 and not ExIsUnitDead(unit) and not IsUnitType(unit, UNIT_TYPE_PEON) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE) then
            hp = hp + GetWidgetLife(unit)
            table.insert(force, unit)
        end
    end)

    local positions = {}
    EventCenter.InitCamp:Emit(positions)
    table.sort(positions, function(a, b)
        local distA = (basePos - a.p):GetMagnitude()
        local distB = (basePos - b.p):GetMagnitude()
        return a.hp + distA < b.hp + distB
    end)

    local firstCamp = positions[1]
    local vec = Vector2.new()
    if firstCamp.hp > 1 and firstCamp.hp < hp then
        for _, v in ipairs(force) do
            local dist = vec:MoveToUnit(v):Sub(firstCamp.p):GetMagnitude()
            if dist > 600 then
                IssuePointOrderById(v, Const.OrderId_Attack, firstCamp.p.x, firstCamp.p.y)
            end
        end
    end
end

return cls

end}

__modules["Config.Abilities"]={loader=function()
local data = {}

local cls = setmetatable({}, {
    __index = function(t, k)
        return data[k]
    end,
    __newindex = function(t, k, v)
        if data[k] then
            print("Error: duplicate ability name:", k)
        else
            data[k] = v
        end
    end
})

return cls

end}

__modules["Config.Const"]={loader=function()
local cls = {}

cls.OrderId_Stop = 851972
cls.OrderId_Smart = 851971
cls.OrderId_Attack = 851983

cls.HitResult_Hit = 1
cls.HitResult_Miss = 2
cls.HitResult_Critical = 4

return cls

end}

__modules["Lib.Circle"]={loader=function()
---@class Circle
local cls = class("Circle")

---@param center Vector2
---@param r real
function cls:ctor(center, r)
    self.center = center
    self.r = r
end

---@param v Vector2
function cls:Contains(v)
    local dir = v - self.center
    return dir:GetMagnitude() <= self.r
end

function cls:Clone()
    return cls.new(self.center:Clone(), self.r)
end

function cls:tostring()
    return string.format("(%s,%s,%s)", self.center.x, self.center.y, self.r)
end

return cls

end}

__modules["Lib.class"]={loader=function()
require("Lib.clone")

function class(classname, super)
    local superType = type(super)
    local cls
    if superType ~= "function" and superType ~= "table" then
        superType = nil
        super = nil
    end
    if superType == "function" or (super and super.__ctype == 1) then
        cls = {}
        if superType == "table" then
            for k, v in pairs(super) do cls[k] = v end
            cls.__create = super.__create
            cls.super    = super
        else
            cls.__create = super
        end
        cls.ctor = function() end
        cls.__cname = classname
        cls.__ctype = 1
        function cls.new(...)
            local instance = cls.__create(...)
            for k, v in pairs(cls) do instance[k] = v end
            instance.class = cls
            instance:ctor(...)
            return instance
        end
    else
        if super then
            cls = clone(super)
            cls.super = super
        else
            cls = { ctor = function() end }
        end

        cls.__cname = classname
        cls.__ctype = 2
        cls.__index = cls
        function cls.new(...)
            local instance = setmetatable({}, cls)
            instance.class = cls
            instance:ctor(...)
            return instance
        end
    end
    return cls
end

end}

__modules["Lib.clone"]={loader=function()
---@generic T
---@param object T
---@return T
function clone(object)
    local lookup_table = {}
    local function _copy(obj)
        if type(obj) ~= "table" then
            return obj
        elseif lookup_table[obj] then
            return lookup_table[obj]
        end
        local new_table = {}
        lookup_table[obj] = new_table
        for key, value in pairs(obj) do
            new_table[_copy(key)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(obj))
    end
    return _copy(object)
end

end}

__modules["Lib.CoroutineExt"]={loader=function()
local Timer = require("Lib.Timer")
local FrameTimer = require("Lib.FrameTimer")

local c_create = coroutine.create
local c_running = coroutine.running
local c_resume = coroutine.resume
local c_yield = coroutine.yield
local t_pack = table.pack
local t_unpack = table.unpack
local print = print

local c2t = setmetatable({}, { __mode = "kv" })

function coroutine.start(f, ...)
    local c = c_create(f)
    local r = c_running()

    if r == nil then
        local success, msg = c_resume(c, ...)
        if not success then
            print(msg)
        end
    else
        local args = t_pack(...)
        local timer
        timer = FrameTimer.new(function()
            c2t[c] = nil
            local success, msg = c_resume(c, t_unpack(args))
            if not success then
                timer:Stop()
                print(msg)
            end
        end, 1, 1)
        c2t[c] = timer
        timer:Start()
    end

    return c
end

function coroutine.wait(t)
    local c = c_running()
    local timer

    local function action()
        c2t[c] = nil

        local success, msg = c_resume(c)
        if not success then
            timer:Stop()
            print(msg)
        end
    end

    timer = Timer.new(action, t, 1)
    c2t[c] = timer
    timer:Start()
    c_yield()
end

function coroutine.step(t)
    local c = c_running()
    local timer

    local function action()
        c2t[c] = nil

        local success, msg = c_resume(c)
        if not success then
            timer:Stop()
            print(msg)
        end
    end

    timer = FrameTimer.new(action, t or 1, 1)
    c2t[c] = timer
    timer:Start()
    c_yield()
end

function coroutine.stop(c)
    local timer = c2t[c]
    if timer ~= nil then
        c2t[c] = nil
        timer:Stop()
    end
end

end}

__modules["Lib.Event"]={loader=function()
require("Lib.class")

local t_insert = table.insert
local t_concat = table.concat
local s_format = string.format
local next = next
local pairs = pairs
local tostring = tostring

---@class Event
local cls = class("Event")

function cls:ctor()
    self._handlers = {}
end

---@generic T, E
---@param context T
---@param listener fun(context: T, data: E)
function cls:On(context, listener)
    local map = self._handlers[context]
    if map == nil then
        map = {}
        self._handlers[context] = map
    end
    map[listener] = 1
end

---@generic T, E
---@param context T
---@param listener fun(context: T, data: E)
function cls:Off(context, listener)
    local map = self._handlers[context]
    if map == nil then
        return
    end
    map[listener] = nil
    if next(map) == nil then
        self._handlers[context] = nil
    end
end

---@generic E
---@param data E
function cls:Emit(data)
    for context, map in pairs(self._handlers) do
        for listener, _ in pairs(map) do
            listener(context, data)
        end
    end
end

function cls:ToString()
    local sb = {}
    for context, map in pairs(self._handlers) do
        for listener, _ in pairs(map) do
            t_insert(sb, s_format("%s -> %s", tostring(context), tostring(listener)))
        end
    end
    return t_concat(sb, ",")
end

return cls

end}

__modules["Lib.EventCenter"]={loader=function()
local Event = require("Lib.Event")

local cls = {}

cls.FrameBegin = Event.new()
cls.FrameUpdate = Event.new()

function cls.Report()
    print("--- FrameBegin ---")
    print(cls.FrameBegin:ToString())
    print("--- FrameUpdate ---")
    print(cls.FrameUpdate:ToString())
end

return cls

end}

__modules["Lib.FrameTimer"]={loader=function()
local FrameUpdate = require("Lib.EventCenter").FrameUpdate

local pcall = pcall
local print = print

local cls = class("FrameTimer")

function cls:ctor(func, count, loops)
    self.func = func
    self.count = count
    self.loops = loops

    self.frames = count
    self.running = false
end

function cls:Start()
    if self.running then
        return
    end

    if self.loops == 0 then
        return
    end

    self.running = true
    FrameUpdate:On(self, cls._update)
end

function cls:Stop()
    if not self.running then
        return
    end

    self.running = false
    FrameUpdate:Off(self, cls._update)
end

function cls:_update(dt)
    if not self.running then
        return
    end

    self.frames = self.frames - 1
    if self.frames <= 0 then
        local s, m = pcall(self.func, dt)
        if not s then
            print(m)
        end

        if self.loops > 0 then
            self.loops = self.loops - 1
            if self.loops == 0 then
                self:Stop()
                return
            end
        end

        self.frames = self.frames + self.count
    end
end

return cls

end}

__modules["Lib.MathExt"]={loader=function()
function math.fuzzyEquals(a, b, precision)
    precision = precision or 0.000001
    return (a == b) or math.abs(a - b) < precision
end

---@param t real ratio 0-1
---@param c1 real
---@param c2 real
---@param c3 real
---@return real
function math.bezier3(t, c1, c2, c3)
    local t1 = 1 - t
    return c1 * t1 * t1 + c2 * 2 * t1 * t + c3 * t * t
end

function math.clamp(value, min, max)
    return math.min(math.max(min, value), max)
end

function math.clamp01(value)
    return math.clamp(value, 0, 1)
end

math.atan2 = Atan2

local m_floor = math.floor
local MathRound = MathRound

function math.round(value)
    return MathRound(value)
end

end}

__modules["Lib.native"]={loader=function()
require("Lib.TableExt")
require("Lib.MathExt")
local Time = require("Lib.Time")

local ipairs = ipairs
local pcall = pcall
local print = print
local c_start = coroutine.start
local c_wait = coroutine.wait
local c_step = coroutine.step
local m_round = math.round
local t_insert = table.insert
local t_getOrCreateTable = table.getOrCreateTable

local AddLightningEx = AddLightningEx
local AddSpecialEffect = AddSpecialEffect
local AddSpecialEffectTarget = AddSpecialEffectTarget
local CreateGroup = CreateGroup
local CreateTrigger = CreateTrigger
local DestroyEffect = DestroyEffect
local DestroyLightning = DestroyLightning
local Filter = Filter
local GetFilterUnit = GetFilterUnit
local GetLearnedSkill = GetLearnedSkill
local GetLearnedSkillLevel = GetLearnedSkillLevel
local GetTriggerUnit = GetTriggerUnit
local GetUnitFlyHeight = GetUnitFlyHeight
local GetUnitX = GetUnitX
local GetUnitY = GetUnitY
local GroupClear = GroupClear
local BlzGetUnitZ = BlzGetUnitZ
local GetWidgetLife = GetWidgetLife
local GroupEnumUnitsInRange = GroupEnumUnitsInRange
local MoveLightningEx = MoveLightningEx
local SetLightningColor = SetLightningColor
local BlzSetSpecialEffectColor = BlzSetSpecialEffectColor
local TriggerAddAction = TriggerAddAction
local TriggerRegisterAnyUnitEventBJ = TriggerRegisterAnyUnitEventBJ

---@param trigger trigger
---@param action fun(): void
---@return void
function ExTriggerAddAction(trigger, action)
    TriggerAddAction(trigger, function()
        local s, m = pcall(action)
        if not s then
            print(m)
        end
    end)
end

local ExTriggerAddAction = ExTriggerAddAction

local group = CreateGroup()

---@param x real
---@param y real
---@param radius real
---@param callback fun(unit: unit): void
---@return void
function ExGroupEnumUnitsInRange(x, y, radius, callback)
    GroupClear(group)
    GroupEnumUnitsInRange(group, x, y, radius, Filter(function()
        local s, m = pcall(callback, GetFilterUnit())
        if not s then
            print(m)
        end
        return false
    end))
end

---@param callback fun(unit: unit): void
function ExGroupEnumUnitsInMap(callback)
    GroupClear(group)
    GroupEnumUnitsInRect(group, bj_mapInitialPlayableArea, Filter(function()
        local s, m = pcall(callback, GetFilterUnit())
        if not s then
            print(m)
        end
        return false
    end))
end

---@param x real
---@param y real
---@param radius real
---@return void
function ExGroupGetUnitsInRange(x, y, radius)
    GroupClear(group)
    local units = {}
    GroupEnumUnitsInRange(group, x, y, radius, Filter(function()
        t_insert(units, GetFilterUnit())
        return false
    end))
    return units
end

---@param modelName string
---@param target unit
---@param attachPoint string
---@param duration real
function ExAddSpecialEffectTarget(modelName, target, attachPoint, duration)
    c_start(function()
        local sfx = AddSpecialEffectTarget(modelName, target, attachPoint)
        c_wait(duration)
        DestroyEffect(sfx)
    end)
end

function ExAddSpecialEffect(modelName, x, y, duration, color)
    c_start(function()
        local sfx = AddSpecialEffect(modelName, x, y)
        if color then
            BlzSetSpecialEffectColor(sfx, m_round(color.r * 255), m_round(color.g * 255), m_round(color.b * 255))
        end
        c_wait(duration)
        DestroyEffect(sfx)
    end)
end

function ExAddLightningPosPos(modelName, x1, y1, z1, x2, y2, z2, duration, color, check)
    c_start(function()
        local lightning = AddLightningEx(modelName, check or false, x1, y1, z1, x2, y2, z2)
        if color then
            SetLightningColor(lightning, color.r, color.g, color.b, color.a)
        end
        c_wait(duration)
        DestroyLightning(lightning)
    end)
end

function ExAddLightningUnitUnit(modelName, unit1, unit2, duration, color, checkVisibility)
    c_start(function()
        checkVisibility = checkVisibility or false
        local expr = Time.Time + duration
        local lightning = AddLightningEx(modelName, checkVisibility,
                GetUnitX(unit1), GetUnitY(unit1), BlzGetUnitZ(unit1) + GetUnitFlyHeight(unit1),
                GetUnitX(unit2), GetUnitY(unit2), BlzGetUnitZ(unit2) + GetUnitFlyHeight(unit2))
        if color then
            SetLightningColor(lightning, color.r, color.g, color.b, color.a)
        end
        while true do
            c_step()
            MoveLightningEx(lightning, checkVisibility,
                    GetUnitX(unit1), GetUnitY(unit1), BlzGetUnitZ(unit1) + GetUnitFlyHeight(unit1),
                    GetUnitX(unit2), GetUnitY(unit2), BlzGetUnitZ(unit2) + GetUnitFlyHeight(unit2))
            if Time.Time >= expr then
                break
            end
        end
        DestroyLightning(lightning)
    end)
end

function ExAddLightningPosUnit(modelName, x1, y1, z1, unit2, duration, color, check)
    c_start(function()
        check = check or false
        local expr = Time.Time + duration
        local lightning = AddLightningEx(modelName, check,
                x1, y1, z1,
                GetUnitX(unit2), GetUnitY(unit2), BlzGetUnitZ(unit2) + GetUnitFlyHeight(unit2))
        if color then
            SetLightningColor(lightning, color.r, color.g, color.b, color.a)
        end
        while true do
            c_step()
            MoveLightningEx(lightning, check,
                    x1, y1, z1,
                    GetUnitX(unit2), GetUnitY(unit2), BlzGetUnitZ(unit2) + GetUnitFlyHeight(unit2))
            if Time.Time >= expr then
                break
            end
        end
        DestroyLightning(lightning)
    end)
end

local acquireTrigger = CreateTrigger()
local acquireCalls = {}
ExTriggerAddAction(acquireTrigger, function()
    local caster = GetTriggerUnit()
    local target = GetEventTargetUnit()
    for _, v in ipairs(acquireCalls) do
        v(caster, target)
    end
end)
function ExTriggerRegisterUnitAcquire(callback)
    table.insert(acquireCalls, callback)
end

local mapArea = CreateRegion()
RegionAddRect(mapArea, bj_mapInitialPlayableArea)
local enterTrigger = CreateTrigger()
local enterMapCalls = {}
TriggerRegisterEnterRegion(enterTrigger, mapArea, Filter(function() return true end))
function ExTriggerRegisterNewUnitExec(u)
    TriggerRegisterUnitEvent(acquireTrigger, u, EVENT_UNIT_ACQUIRED_TARGET)
    for _, v in ipairs(enterMapCalls) do
        v(u)
    end
end
local ExTriggerRegisterNewUnitExec = ExTriggerRegisterNewUnitExec
ExTriggerAddAction(enterTrigger, function()
    ExTriggerRegisterNewUnitExec(GetTriggerUnit())
end)

---@param callback fun(unit: unit): void
function ExTriggerRegisterNewUnit(callback)
    t_insert(enterMapCalls, callback)
end

function ExIsUnitDead(unit)
    return GetWidgetLife(unit) < 0.406
end

local deathTrigger = CreateTrigger()
local unitDeathCalls = {}
TriggerRegisterAnyUnitEventBJ(deathTrigger, EVENT_PLAYER_UNIT_DEATH)
ExTriggerAddAction(deathTrigger, function()
    local u = GetTriggerUnit()
    for _, v in ipairs(unitDeathCalls) do
        v(u)
    end
end)

---@param callback fun(unit: unit): void
function ExTriggerRegisterUnitDeath(callback)
    t_insert(unitDeathCalls, callback)
end

local learnTrigger = CreateTrigger()
local unitLearnCalls = {}
local anySkillLearnCalls = {}
TriggerRegisterAnyUnitEventBJ(learnTrigger, EVENT_PLAYER_HERO_SKILL)
ExTriggerAddAction(learnTrigger, function()
    local u = GetTriggerUnit()
    local s = GetLearnedSkill()
    local l = GetLearnedSkillLevel()
    local tab = t_getOrCreateTable(unitLearnCalls, s)
    for _, v in ipairs(tab) do
        v(u, l, s)
    end
    for _, v in ipairs(anySkillLearnCalls) do
        v(u, l, s)
    end
end)
---@param callback fun(unit: unit, level: integer, skill: integer): void
function ExTriggerRegisterUnitLearn(id, callback)
    if id == 0 then
        t_insert(anySkillLearnCalls, callback)
    else
        local tab = t_getOrCreateTable(unitLearnCalls, id)
        t_insert(tab, callback)
    end
end

function GetStackTrace(oneline_yn)
    local trace, lastMsg, i, separator = "", "", 5, (oneline_yn and "; ") or "\n"
    local store = function(msg) lastMsg = msg:sub(1, -3) end --Passed to xpcall to handle the error message. Message is being saved to lastMsg for further use, excluding trailing space and colon.
    xpcall(error, store, "", 4) --starting at position 4 ensures that the functions "error", "xpcall" and "GetStackTrace" are not included in the trace.
    while lastMsg:sub(1, 11) == "war3map.lua" or lastMsg:sub(1, 14) == "blizzard.j.lua" do
        trace = separator .. lastMsg .. trace
        xpcall(error, store, "", i)
        i = i + 1
    end
    return "Traceback (most recent call last)" .. trace
end

function PrintStackTrace()
    print(GetStackTrace())
end

function ExTextTag(whichUnit, dmg, color)
    local tt = CreateTextTag()
    local text = tostring(math.round(dmg)) .. "!"
    SetTextTagText(tt, text, 0.024)
    SetTextTagPos(tt, GetUnitX(whichUnit), GetUnitY(whichUnit), 0.0)
    color = color or { r = 1, g = 1, b = 1, a = 1 }
    SetTextTagColor(tt, math.round(color.r * 255), math.round(color.g * 255), math.round(color.b * 255), math.round(color.a * 255))
    SetTextTagVelocity(tt, 0.0, 0.04)
    SetTextTagVisibility(tt, true)
    SetTextTagFadepoint(tt, 2.0)
    SetTextTagLifespan(tt, 5.0)
    SetTextTagPermanent(tt, false)
end

function ExTextCriticalStrike(whichUnit, dmg)
    local tt = CreateTextTag()
    local text = tostring(math.round(dmg)) .. "!"
    SetTextTagText(tt, text, 0.024)
    SetTextTagPos(tt, GetUnitX(whichUnit), GetUnitY(whichUnit), 0.0)
    SetTextTagColor(tt, 255, 0, 0, 255)
    SetTextTagVelocity(tt, 0.0, 0.04)
    SetTextTagVisibility(tt, true)
    SetTextTagFadepoint(tt, 2.0)
    SetTextTagLifespan(tt, 5.0)
    SetTextTagPermanent(tt, false)
end

function ExTextMiss(whichUnit)
    local tt = CreateTextTag()
    SetTextTagText(tt, "未命中", 0.024)
    SetTextTagPos(tt, GetUnitX(whichUnit), GetUnitY(whichUnit), 0.0)
    SetTextTagColor(tt, 255, 0, 0, 255)
    SetTextTagVelocity(tt, 0.0, 0.03)
    SetTextTagVisibility(tt, true)
    SetTextTagFadepoint(tt, 1.0)
    SetTextTagLifespan(tt, 3.0)
    SetTextTagPermanent(tt, false)
end

function ExTextState(whichUnit, text)
    local tt = CreateTextTag()
    SetTextTagText(tt, text, 0.024)
    SetTextTagPos(tt, GetUnitX(whichUnit), GetUnitY(whichUnit), 0.0)
    SetTextTagColor(tt, 255, 192, 0, 255)
    SetTextTagVelocity(tt, 0.0, 0.03)
    SetTextTagVisibility(tt, true)
    SetTextTagFadepoint(tt, 1.0)
    SetTextTagLifespan(tt, 3.0)
    SetTextTagPermanent(tt, false)
end

function ExGetUnitMana(unit)
    return GetUnitState(unit, UNIT_STATE_MANA)
end

function ExGetUnitMaxMana(unit)
    return GetUnitState(unit, UNIT_STATE_MAX_MANA)
end

function ExGetUnitManaPortion(unit)
    return ExGetUnitMana(unit) / ExGetUnitMaxMana(unit)
end

function ExSetUnitMana(unit, amount)
    return SetUnitState(unit, UNIT_STATE_MANA, amount)
end

function ExAddUnitMana(unit, amount)
    ExSetUnitMana(unit, ExGetUnitMana(unit) + amount)
end

function ExGetUnitManaLoss(unit)
    return GetUnitState(unit, UNIT_STATE_MAX_MANA) - ExGetUnitMana(unit)
end

function ExGetUnitLifeLoss(unit)
    return GetUnitState(unit, UNIT_STATE_MAX_LIFE) - GetUnitState(unit, UNIT_STATE_LIFE)
end

function ExGetUnitLifePortion(unit)
    return GetWidgetLife(unit) / GetUnitState(unit, UNIT_STATE_MAX_LIFE)
end

function ExGetUnitPlayerId(unit)
    return GetPlayerId(GetOwningPlayer(unit))
end

end}

__modules["Lib.StringExt"]={loader=function()
function string.formatPercentage(number, digits)
    digits = digits or 0
    number = number * 100
    --local pow = 10 ^ digits
    --number = math.round(number * pow) / pow
    --return tostring(number) .. "%"
    if digits == 0 then
        return tostring(math.round(number)) .. "%"
    else
        return string.format("%0" .. tostring(digits) .. "d", number) .. "%"
    end
end

end}

__modules["Lib.TableExt"]={loader=function()
local ipairs = ipairs
local t_insert = table.insert
local m_floor = math.floor
local m_random = math.random
local m_clamp = math.clamp

---Add v to k of tab, in place. tab will be mutated.
---@generic K
---@param tab table<K, number>
---@param k K
---@param v number
---@return number result
function table.addNum(tab, k, v)
    local r = tab[k]
    if r == nil then
        r = v
    else
        r = r + v
    end
    tab[k] = r
    return r
end

function table.any(tab)
    return next(tab) ~= nil
end

function table.getOrCreateTable(tab, key)
    --print(GetStackTrace())
    local ret = tab[key]
    if not ret then
        ret = {}
        tab[key] = ret
    end
    return ret
end

---@generic T
---@param tab T[]
---@param n integer count
---@return T[]
function table.sample(tab, n)
    local result = {}
    local c = 0
    for _, item in ipairs(tab) do
        c = c + 1
        if #result < n then
            t_insert(result, item)
        else
            local s = m_floor(m_random() * c)
            if s < n then
                result[s + 1] = item
            end
        end
    end
    return result
end

---@generic T
---@param tab T[]
---@param item T
function table.removeItem(tab, item)
    local c = #tab
    local i = 1
    local d = 0
    local removed = false
    while i <= c do
        local it = tab[i]
        if it == item then
            d = d + 1
            removed = true
        else
            if d > 0 then
                tab[i - d] = it
            end
        end
        i = i + 1
    end
    for j = 0, d - 1 do
        tab[c - j] = nil
    end
    return removed
end

---@generic V
---@param t V[]
---@param func fun(i: integer, v: V): boolean
---@return V, integer
function table.iFind(t, func)
    for i, v in ipairs(t) do
        if func(i, v) == true then
            return v, i
        end
    end
    return nil, nil
end

---@generic T
---@param tab T[]
---@param from number Optional One-based index at which to begin extraction.
---@param to number Optional One-based index before which to end extraction.
---@return T[]
function table.slice(tab, from, to)
    from = from and m_clamp(from, 1, #tab + 1) or 1
    to = to and m_clamp(to, 1, #tab) or #tab
    local result = {}
    for i = from, to, 1 do
        if tab[i] then
            t_insert(result, tab[i])
        end
    end
    return result
end

---@generic K, V
---@param source table<K, V> | V[]
---@param copy table<K, V> | V[]
---@return table<K, V> | V[]
function table.shallow(source, copy)
    copy = copy or {}
    for k, v in pairs(source) do
        copy[k] = v
    end
    return copy
end

---@generic T
---@param t T[]
---@return T
function table.iGetRandom(t)
    return t[m_random(#t)]
end

---@generic T
---@param t T[]
---@param func fun(elem: T): boolean
---@return T[]
function table.iWhere(t, func)
    local tab = {}
    for _, v in ipairs(t) do
        if func(v) then
            t_insert(tab, v)
        end
    end
    return tab
end

end}

__modules["Lib.Time"]={loader=function()
local EventCenter = require("Lib.EventCenter")
local Timer = require("Lib.Timer")
local FrameBegin = EventCenter.FrameBegin
local FrameUpdate = EventCenter.FrameUpdate

local TimerGetElapsed = TimerGetElapsed

local TimeTimerInterval = 10

---@class Time
---@field Time real current time
local cls = {}

cls.Frame = 0
cls.Delta = 0.02
local delta = cls.Delta

local time = 0
local timeTimer = Timer.new(function()
    time = time + TimeTimerInterval
end, TimeTimerInterval, -1)
timeTimer:Start()
local tm = timeTimer.timer

FrameBegin:On(cls, function(_, _)
    local f = cls.Frame + 1
    cls.Frame = f
end)

-- main loop
local mainLoopTimer = Timer.new(function(dt)
    FrameBegin:Emit(dt)
    FrameUpdate:Emit(dt)
end, cls.Delta, -1)
mainLoopTimer:Start()

-- cls.Time
setmetatable(cls, {
    __index = function()
        return time + TimerGetElapsed(tm)
    end
})

local MathRound = MathRound
local m_ceil = math.ceil

function cls.CeilToNextUpdate(timestamp)
    return MathRound(m_ceil(timestamp / delta) * delta * 100) * 0.01
end

Time = cls

return cls

end}

__modules["Lib.Timer"]={loader=function()
require("Lib.MathExt")

local pcall = pcall
local t_insert = table.insert
local t_remove = table.remove

local PauseTimer = PauseTimer
local CreateTimer = CreateTimer
local TimerStart = TimerStart
local TimerGetElapsed = TimerGetElapsed

local pool = {}

local function getTimer()
    if #pool == 0 then
        return CreateTimer()
    else
        return t_remove(pool)
    end
end

local function cacheTimer(timer)
    PauseTimer(timer)
    t_insert(pool, timer)
end

local cls = class("Timer")

function cls:ctor(func, duration, loops)
    self.timer = getTimer()
    self.func = func
    self.duration = duration
    if loops == 0 then
        loops = 1
    end
    self.loops = loops
end

function cls:Start()
    TimerStart(self.timer, self.duration, self.loops ~= 1, function()
        local dt = TimerGetElapsed(self.timer)
        local s, m = pcall(self.func, dt)
        if not s then
            print(m)
            return
        end

        if self.loops > 0 then
            self.loops = self.loops - 1
            if self.loops == 0 then
                self:Stop()
                return
            end
        end
    end)
end

function cls:SetOnStop(onStop)
    self.onStop = onStop
end

function cls:Stop()
    if self.onStop then
        self.onStop()
    end
    cacheTimer(self.timer)
end

return cls

end}

__modules["Lib.Utils"]={loader=function()
local m_floor = math.floor
local s_sub = string.sub

local cls = {}

local ccMap = ""
        .. "................"
        .. "................"
        .. " !\"#$%&'()*+,-./"
        .. "0123456789:;<=>?"
        .. "@ABCDEFGHIJKLMNO"
        .. "PQRSTUVWXYZ[\\]^_"
        .. "`abcdefghijklmno"
        .. "pqrstuvwxyz{|}~."
        .. "................"
        .. "................"
        .. "................"
        .. "................"
        .. "................"
        .. "................"
        .. "................"
        .. "................"

function cls.CCFour(value)
    local d1 = m_floor(value / 16777216)
    value = value - d1 * 16777216
    d1 = d1 + 1
    local d2 = m_floor(value / 65536)
    value = value - d2 * 65536
    d2 = d2 + 1
    local d3 = m_floor(value / 256)
    value = value - d3 * 256
    d3 = d3 + 1
    value = value + 1
    return s_sub(ccMap, d1, d1) .. s_sub(ccMap, d2, d2) .. s_sub(ccMap, d3, d3) .. s_sub(ccMap, value, value)
end

local AbilIdAmrf = FourCC("Amrf")

function cls.SetUnitFlyable(unit)
    UnitAddAbility(unit, AbilIdAmrf);
    UnitRemoveAbility(unit, AbilIdAmrf);
end

return cls

end}

__modules["Lib.Vector2"]={loader=function()
local setmetatable = setmetatable
local type = type
local rawget = rawget
local m_sqrt = math.sqrt

local GetUnitX = GetUnitX
local GetUnitY = GetUnitY

---@class Vector2
local cls = {}

cls._loc = Location(0, 0)

---@return Vector2
function cls.new(x, y)
    return setmetatable({
        x = x or 0,
        y = y or 0,
    }, cls)
end

local new = cls.new

---@param unit unit
function cls.FromUnit(unit)
    return new(GetUnitX(unit), GetUnitY(unit))
end

function cls.InsideUnitCircle()
    local angle = math.random() * math.pi * 2
    return new(math.cos(angle), math.sin(angle))
end

---@param unit unit
function cls:MoveToUnit(unit)
    self.x = GetUnitX(unit)
    self.y = GetUnitY(unit)
    return self
end

---@param unit unit
function cls:UnitMoveTo(unit)
    SetUnitPosition(unit, self.x, self.y)
    return self
end

---@param other Vector2
function cls:SetTo(other)
    self.x = other.x
    self.y = other.y
    return
end

---@param other Vector2
function cls:Add(other)
    self.x = self.x + other.x
    self.y = self.y + other.y
    return self
end

---@param other Vector2
function cls:Sub(other)
    self.x = self.x - other.x
    self.y = self.y - other.y
    return self
end

---@param d real
function cls:Div(d)
    self.x = self.x / d
    self.y = self.y / d
    return self
end

---@param d real
function cls:Mul(d)
    self.x = self.x * d
    self.y = self.y * d
    return self
end

function cls:SetNormalize()
    local magnitude = self:GetMagnitude()

    if magnitude > 1e-05 then
        self.x = self.x / magnitude
        self.y = self.y / magnitude
    else
        self.x = 0
        self.y = 0
    end

    return self
end

function cls:SetMagnitude(len)
    self:SetNormalize():Mul(len)
    return self
end

function cls:Clone()
    return new(self.x, self.y)
end

function cls:GetTerrainZ()
    MoveLocation(cls._loc, self.x, self.y)
    return GetLocationZ(cls._loc)
end

function cls:GetMagnitude()
    return m_sqrt(self.x * self.x + self.y * self.y)
end

function cls:MagnitudeSqr()
    return self.x * self.x + self.y * self.y
end

---@return string
function cls:tostring()
    return string.format("(%f,%f)", self.x, self.y)
end

function cls.__index(_, k)
    return rawget(cls, k)
end

function cls.__add(a, b)
    return new(a.x + b.x, a.y + b.y)
end

---@return Vector2
function cls.__sub(a, b)
    return new(a.x - b.x, a.y - b.y)
end

function cls.__div(v, d)
    return new(v.x / d, v.y / d)
end

function cls.__mul(a, d)
    if type(d) == "number" then
        return new(a.x * d, a.y * d)
    else
        return new(a * d.x, a * d.y)
    end
end

function cls.__unm(v)
    return new(-v.x, -v.y)
end

function cls.__eq(a, b)
    return ((a.x - b.x) ^ 2 + (a.y - b.y) ^ 2) < 9.999999e-11
end

setmetatable(cls, cls)

return cls

end}

__modules["Lib.Vector3"]={loader=function()
local Utils = require("Lib.Utils")

local setmetatable = setmetatable
local type = type
local rawget = rawget
local m_sqrt = math.sqrt

local GetUnitX = GetUnitX
local GetUnitY = GetUnitY

---@class Vector3
local cls = {}

cls._loc = Location(0, 0)

local function getTerrainZ(x, y)
    MoveLocation(cls._loc, x, y)
    return GetLocationZ(cls._loc)
end

---@return Vector3
function cls.new(x, y, z)
    x = x or 0
    y = y or 0
    return setmetatable({
        x = x,
        y = y,
        z = z or getTerrainZ(x, y),
    }, cls)
end

local new = cls.new

---@param unit unit
function cls.FromUnit(unit)
    local x = GetUnitX(unit)
    local y = GetUnitY(unit)
    return new(x, y, getTerrainZ(x, y) + GetUnitFlyHeight(unit))
end

--function cls.InsideUnitCircle()
--    local angle = math.random() * math.pi * 2
--    return new(math.cos(angle), math.sin(angle))
--end

---@param unit unit
function cls:MoveToUnit(unit)
    self.x = GetUnitX(unit)
    self.y = GetUnitY(unit)
    self.z = getTerrainZ(self.x, self.y) + GetUnitFlyHeight(unit)
    return self
end

---@param unit unit
---@param mode integer modes. 1: force flying. 2: force to ground. other|Nil: flying units fly/ ground units grounded
function cls:UnitMoveTo(unit, mode)
    local tz = getTerrainZ(self.x, self.y)
    local defaultFlyHeight = GetUnitDefaultFlyHeight(unit)
    local minZ = tz + defaultFlyHeight
    SetUnitPosition(unit, self.x, self.y)
    if mode == 1 then
        Utils.SetUnitFlyable(unit)
        SetUnitFlyHeight(unit, math.max(minZ, self.z) - minZ, 0)
    elseif mode == 2 then
        SetUnitFlyHeight(unit, defaultFlyHeight, 0)
    else
        if IsUnitType(unit, UNIT_TYPE_FLYING) then
            SetUnitFlyHeight(unit, math.max(minZ, self.z) - minZ, 0)
        else
            SetUnitFlyHeight(unit, defaultFlyHeight, 0)
        end
    end
    return self
end

---@param other Vector3
function cls:SetTo(other)
    self.x = other.x
    self.y = other.y
    self.z = other.z
    return
end

---@param other Vector3
function cls:Add(other)
    self.x = self.x + other.x
    self.y = self.y + other.y
    self.z = self.z + other.z
    return self
end

---@param other Vector3
function cls:Sub(other)
    self.x = self.x - other.x
    self.y = self.y - other.y
    self.z = self.z - other.z
    return self
end

---@param d real
function cls:Div(d)
    self.x = self.x / d
    self.y = self.y / d
    self.z = self.z / d
    return self
end

---@param d real
function cls:Mul(d)
    self.x = self.x * d
    self.y = self.y * d
    self.z = self.z * d
    return self
end

function cls:SetNormalize()
    local magnitude = self:GetMagnitude()

    if magnitude > 1e-05 then
        self:Div(magnitude)
    else
        self.x = 0
        self.y = 0
        self.z = 0
    end

    return self
end

function cls:SetMagnitude(len)
    self:SetNormalize():Mul(len)
    return self
end

function cls:Clone()
    return new(self.x, self.y, self.z)
end

function cls:GetTerrainZ()
    return getTerrainZ(self.x, self.y)
end

function cls:GetMagnitude()
    return m_sqrt(self:SqrMagnitude())
end

function cls:SqrMagnitude()
    return self.x * self.x + self.y * self.y + self.z * self.z
end

function cls.Dot(lhs, rhs)
    return lhs.x * rhs.x + lhs.y * rhs.y + lhs.z * rhs.z
end

function cls.Scale(a, b)
    local x = a.x * b.x
    local y = a.y * b.y
    local z = a.z * b.z
    return new(x, y, z)
end

function cls.Cross(lhs, rhs)
    local x = lhs.y * rhs.z - lhs.z * rhs.y
    local y = lhs.z * rhs.x - lhs.x * rhs.z
    local z = lhs.x * rhs.y - lhs.y * rhs.x
    return new(x, y, z)
end

function cls.Project(v, onNormal)
    local num = onNormal:SqrMagnitude()

    if num < 0.0001 then
        return new(0, 0, 0)
    end

    local num2 = cls.Dot(v, onNormal)
    local v3 = onNormal:Clone()
    v3:Mul(num2 / num)
    return v3
end

function cls.ProjectOnPlane(v, planeNormal)
    local v3 = cls.Project(v, planeNormal)
    v3:Mul(-1)
    v3:Add(v)
    return v3
end

---@return string
function cls:tostring()
    return string.format("(%f,%f,%f)", self.x, self.y, self.z)
end

function cls.__index(_, k)
    return rawget(cls, k)
end

function cls.__add(a, b)
    return new(a.x + b.x, a.y + b.y, a.z + b.z)
end

---@return Vector3
function cls.__sub(a, b)
    return new(a.x - b.x, a.y - b.y, a.z - b.z)
end

function cls.__div(v, d)
    return new(v.x / d, v.y / d, v.y / d)
end

function cls.__mul(a, d)
    if type(d) == "number" then
        return new(a.x * d, a.y * d, a.z * d)
    else
        return a:Clone():MulQuaternion(d)
    end
end

function cls.__unm(v)
    return new(-v.x, -v.y, -v.z)
end

function cls.__eq(a, b)
    return ((a.x - b.x) ^ 2 + (a.y - b.y) ^ 2 + (a.z - b.z) ^ 2) < 9.999999e-11
end

function cls.up()
    return new(0, 0, 1)
end

function cls.down()
    return new(0, 0, -1)
end

function cls.right()
    return new(1, 0, 0)
end

function cls.left()
    return new(-1, 0, 0)
end

function cls.forward()
    return new(0, 1, 0)
end

function cls.back()
    return new(0, -1, 0)
end

function cls.zero()
    return new(0, 0, 0)
end

function cls.one()
    return new(1, 1, 1)
end

setmetatable(cls, cls)

return cls

end}

__modules["Main"]={loader=function()
local FrameTimer = require("Lib.FrameTimer")
local Time = require("Lib.Time")
require("Lib.CoroutineExt")
require("Lib.TableExt")
require("Lib.StringExt")
require("Lib.native")

local ipairs = ipairs

-- main logic

-- game machine

---@type SystemBase[]
local systems = {
    require("System.ItemSystem").new(),
    require("System.SpellSystem").new(),
    require("System.MeleeGameSystem").new(),
    require("System.BuffSystem").new(),
    require("System.DamageSystem").new(),
    require("System.ProjectileSystem").new(),
    --require("System.MoverSystem").new(),
    require("System.ManagedAISystem").new(),

    require("System.InitAbilitiesSystem").new(),
}

for _, system in ipairs(systems) do
    system:Awake()
end

local group = CreateGroup()
GroupEnumUnitsInRect(group, bj_mapInitialPlayableArea, Filter(function()
    local s, m = pcall(ExTriggerRegisterNewUnitExec, GetFilterUnit())
    if not s then
        print(m)
    end
end))
DestroyGroup(group)
group = nil

for _, system in ipairs(systems) do
    system:OnEnable()
end

local MathRound = MathRound

local game = FrameTimer.new(function(dt)
    local now = MathRound(Time.Time * 100) * 0.01
    for _, system in ipairs(systems) do
        system:Update(dt, now)
    end
end, 1, -1)
game:Start()

end}

__modules["Objects.BuffBase"]={loader=function()
local EventCenter = require("Lib.EventCenter")
local Time = require("Lib.Time")

---@class BuffBase
local cls = class("BuffBase")

cls.unitBuffs = {} ---@type table<unit, BuffBase[]>

---@param unit unit
---@param name string
---@return BuffBase | Nil, integer | Nil
function cls.FindBuffByClassName(unit, name)
    local arr = cls.unitBuffs[unit]
    if not arr then
        return nil
    end

    return table.iFind(arr, function(_, v)
        return v.__cname == name
    end)
end

---@param caster unit
---@param target unit
---@param duration real
---@param interval real
function cls:ctor(caster, target, duration, interval, awakeData)
    self.caster = caster
    self.target = target
    self.time = Time.CeilToNextUpdate(Time.Time)
    self.expire = self.time + duration
    self.duration = duration
    self.interval = interval
    self.nextUpdate = self.time + interval
    self.stack = 1

    local unitTab = table.getOrCreateTable(cls.unitBuffs, target)
    table.insert(unitTab, self)

    self.awakeData = awakeData
    EventCenter.NewBuff:Emit(self)
end

function cls:Awake()
end

function cls:OnEnable()
end

function cls:Update()
end

function cls:OnDisable()
end

function cls:OnDestroy()
    local unitTab = cls.unitBuffs[self.target]
    if not table.removeItem(unitTab, self) then
        --print("Remove buff unit failed") todo 我看不到报错就没有错误
    end
end

function cls:ResetDuration(exprTime)
    exprTime = exprTime or (Time.Time + self.duration)
    self.expire = Time.CeilToNextUpdate(exprTime)
end

function cls:GetTimeLeft()
    return self.expire - self.time
end

function cls:GetTimeNorm()
    return math.clamp01(self:GetTimeLeft() / self.duration)
end

---叠一层buff
function cls:IncreaseStack(stacks)
    stacks = stacks or 1
    if stacks < 0 then
        return
    end
    self.stack = self.stack + stacks
    self:ResetDuration()
end

function cls:DecreaseStack(stacks)
    stacks = stacks or 1
    self.stack = self.stack - stacks
    if self.stack <= 0 then
        EventCenter.KillBuff:Emit(self)
    end
end

return cls

end}

__modules["Objects.Mover"]={loader=function()
local EventCenter = require("Lib.EventCenter")
local Vector3 = require("Lib.Vector3")

---@class Mover
local cls = class("Mover")

cls.unitInstMap = {} ---@type table<unit, Mover>
cls.effectInstMap = {} ---@type table<effect, Mover>

---@param inst Mover
function cls.LinearMoveBehaviour(inst, dt)
    local dest = inst:GetTargetPos()
    local norm = (dest - inst.pos):SetNormalize()
    local dir = norm * ((inst.speed or 600) * dt)
    inst.pos:Add(dir)

    if inst.attachType == cls.AttachType.Effect then
        BlzSetSpecialEffectPosition(inst.effect, inst.pos.x, inst.pos.y, inst.pos.z)
        local p = Vector3.ProjectOnPlane(norm, Vector3.up()):SetNormalize()
        BlzSetSpecialEffectYaw(inst.effect, math.atan2(p.y, p.x)) -- todo use quaternion
    elseif inst.attachType == cls.AttachType.Unit then
        inst.pos:UnitMoveTo(inst.unit)
        local p = Vector3.ProjectOnPlane(norm, Vector3.up()):SetNormalize()
        SetUnitFacing(inst.unit, (math.atan2(p.y, p.x)) * bj_RADTODEG)
    end

    return dest:Sub(inst.pos):GetMagnitude()
end

function cls.GetOrCreateFromUnit(unit, onArrived, moveBehaviour)
    local inst = cls.unitInstMap[unit]
    if inst then
        inst.onArrived = onArrived
        inst.moveBehaviour = moveBehaviour or cls.LinearMoveBehaviour
        return inst
    end

    inst = cls.new(onArrived, moveBehaviour)
    inst:InitAttachUnit(unit)
    return inst
end

function cls.GetOrCreateFromEffect(effect, onArrived, moveBehaviour, x, y, z)
    local inst = cls.effectInstMap[effect]
    if inst then
        inst.onArrived = onArrived
        inst.moveBehaviour = moveBehaviour or cls.LinearMoveBehaviour
        return inst
    end

    inst = cls.new(onArrived, moveBehaviour)
    inst:InitAttachEffect(effect, x, y, z)
    return inst
end

function cls:ctor(onArrived, moveBehaviour)
    self.moveBehaviour = moveBehaviour or cls.LinearMoveBehaviour
    self.attachType = cls.AttachType.None
    self.destType = cls.DestinationType.None
    self.onArrived = onArrived
    EventCenter.NewMover:Emit(self)
end

function cls:InitAttachUnit(unit)
    self.pos = Vector3.FromUnit(unit)
    self.attachType = cls.AttachType.Unit
    self.unit = unit
    cls.unitInstMap[unit] = self
    return self
end

function cls:InitAttachEffect(effect, x, y, z)
    self.pos = Vector3.new(x, y, z)
    self.attachType = cls.AttachType.Effect
    self.effect = effect
    return self
end

---@param vec3 Vector3
function cls:InitDestinationPoint(vec3)
    self.destType = cls.DestinationType.Point
    self.targetPoint = vec3
    return self
end

function cls:InitDestinationUnit(unit)
    self.destType = cls.DestinationType.Unit
    self.targetUnit = unit
    return self
end

function cls:GetTargetPos()
    if self.destType == cls.DestinationType.Unit then
        return Vector3.FromUnit(self.targetUnit)
    elseif self.destType == cls.DestinationType.Point then
        return self.targetPoint:Clone()
    else
        return Vector3.zero()
    end
end

function cls:CheckArrived(distance)
    if self.attachType == cls.AttachType.Effect then
        return distance < 1
    elseif self.attachType == cls.AttachType.Unit then
        return distance < 96
    elseif self.attachType == cls.AttachType.None then
        return true
    else
        return true
    end
end

return cls

end}

__modules["Objects.ProjectileBase"]={loader=function()
local EventCenter = require("Lib.EventCenter")
local Timer = require("Lib.Timer")
local Vector2 = require("Lib.Vector2")

---@class ProjectileBase
local cls = class("ProjectileBase")

---@param caster unit
---@param target unit
---@param model string
---@param onHit fun(): void
---@param casterOffset Vector3 | Nil
function cls:ctor(caster, target, model, speed, onHit, casterOffset)
    local startPos = Vector2.FromUnit(caster)
    if casterOffset then
        startPos.x = startPos.x + casterOffset.x
        startPos.y = startPos.y + casterOffset.y
    end
    self.sfx = AddSpecialEffect(model, startPos.x, startPos.y)

    self.pos = startPos
    self.speed = speed
    self.targetType = "unit"
    self.target = target
    self.caster = caster
    self.onHit = onHit

    EventCenter.NewProjectile:Emit({ inst = self })
end

return cls

end}

__modules["Objects.UnitAttribute"]={loader=function()
local Power = { 1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048 }
local Temp = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }

local PositiveAtk = {
    FourCC("A00C"),
    FourCC("A00D"),
    FourCC("A00E"),
    FourCC("A00F"),
    FourCC("A00G"),
    FourCC("A00H"),
    FourCC("A00I"),
    FourCC("A00J"),
    FourCC("A00K"),
    FourCC("A00L"),
    FourCC("A00M"),
    FourCC("A00N"),
}

local PositiveHp = {
    FourCC("A00O"),
    FourCC("A00P"),
    FourCC("A00Q"),
    FourCC("A00R"),
    FourCC("A00S"),
    FourCC("A00T"),
    FourCC("A00U"),
    FourCC("A00V"),
    FourCC("A00W"),
    FourCC("A00X"),
    FourCC("A00Y"),
    FourCC("A00Z"),
}

local function i2b(v)
    local bin = table.shallow(Temp)
    for i = #Power, 1, -1 do
        local b = Power[i]
        if v >= b then
            v = v - b
            bin[i] = 1
        end
    end
    return bin
end

---@class UnitAttribute
local cls = class("UnitAttribute")

cls.HeroAttributeType = {
    Strength = 1,
    Agility = 2,
    Intelligent = 3,
}

cls.tab = {}---@type table<unit, UnitAttribute>

---@return UnitAttribute
function cls.GetAttr(unit)
    local inst = cls.tab[unit]
    if not inst then
        inst = cls.new(unit)
        cls.tab[unit] = inst
    end

    return inst
end

function cls:ctor(unit)
    self.owner = unit

    self.baseAtk = BlzGetUnitBaseDamage(unit, 0) + (BlzGetUnitDiceSides(unit, 0) + 1) / 2 * BlzGetUnitDiceNumber(unit, 0)
    self.baseHp = BlzGetUnitMaxHP(unit)
    self.baseMs = GetUnitDefaultMoveSpeed(unit)

    self._atk = table.shallow(Temp)
    self.atk = 0

    self._hp = table.shallow(Temp)
    self.hp = 0

    self.ms = 0
    self.msp = 0

    self.dodge = 0

    self.damageAmplification = 0
    self.damageReduction = 0
    self.healingTaken = 0
end

function cls:GetHeroMainAttr(type, ignoreBonus)
    if not IsUnitType(self.owner, UNIT_TYPE_HERO) then
        return 0
    end
    if type == cls.HeroAttributeType.Strength then
        return GetHeroStr(self.owner, not ignoreBonus)
    end
    if type == cls.HeroAttributeType.Agility then
        return GetHeroAgi(self.owner, not ignoreBonus)
    end
    if type == cls.HeroAttributeType.Intelligent then
        return GetHeroInt(self.owner, not ignoreBonus)
    end
    return 0
end

---@param type integer HeroAttributeType
function cls:SimAttack(type)
    return BlzGetUnitBaseDamage(self.owner, 0) + math.random(1, BlzGetUnitDiceSides(self.owner, 0)) * BlzGetUnitDiceNumber(self.owner, 0) + self:GetHeroMainAttr(type)
end

function cls:_reflect(targetValue, currentBits, lookup)
    local newBits = i2b(math.round(targetValue))
    for i, b in ipairs(newBits) do
        if b ~= currentBits[i] then
            if b == 1 then
                UnitAddAbility(self.owner, lookup[i])
                UnitMakeAbilityPermanent(self.owner, true, lookup[i])
            else
                UnitRemoveAbility(self.owner, lookup[i])
            end
            currentBits[i] = b
        end
    end
end

function cls:Commit()
    self:_reflect(self.atk, self._atk, PositiveAtk)
    self:_reflect(self.hp, self._hp, PositiveHp)

    local ms = self.baseMs * (1 + self.msp) + self.ms
    SetUnitMoveSpeed(self.owner, ms)
end

ExTriggerRegisterNewUnit(cls.GetAttr)

return cls

end}

__modules["System.AbilityEditorSystem"]={loader=function()
local EventCenter = require("Lib.EventCenter")
local Event = require("Lib.Event")
local SystemBase = require("System.SystemBase")

EventCenter.EditUnitAbility = Event.new()

---@class AbilityEditorSystem : SystemBase
local cls = class("AbilityEditorSystem", SystemBase)

function cls:Awake()
    self.map = {}
    EventCenter.EditUnitAbility:On(self, cls.onEditUnitAbility)

    ExTriggerRegisterNewUnit(function(u)
        local uid = GetUnitTypeId(u)
        local tab = table.getOrCreateTable(self.map, uid)
        for aid, handler in pairs(tab) do
            handler(BlzGetUnitAbility(u, aid))
        end
    end)
end

function cls:onEditUnitAbility(data)
    local tab = table.getOrCreateTable(self.map, data.unitId)
    tab[data.abilityId] = data.handler
end

return cls

end}

__modules["System.BuffSystem"]={loader=function()
local EventCenter = require("Lib.EventCenter")
local Event = require("Lib.Event")
local SystemBase = require("System.SystemBase")

EventCenter.NewBuff = Event.new()
EventCenter.KillBuff = Event.new()

---@class BuffSystem : SystemBase
local cls = class("BuffSystem", SystemBase)

function cls:ctor()
    self.buffs = {} ---@type BuffBase[]
end

function cls:Awake()
    EventCenter.NewBuff:On(self, cls.onNewBuff)
    EventCenter.KillBuff:On(self, cls.onKillBuff)
    ExTriggerRegisterUnitDeath(function(u)
        self:_onUnitDeath(u)
    end)
end

function cls:Update(_, now)
    local toRemove = {}
    for i, buff in ipairs(self.buffs) do
        buff.time = now
        if now > buff.expire then
            table.insert(toRemove, i)
        else
            if now >= buff.nextUpdate then
                buff:Update()
                buff.nextUpdate = now + buff.interval
            end
            if now == buff.expire then
                table.insert(toRemove, i)
            end
        end
    end

    local removedBuffs = {}
    for i = #toRemove, 1, -1 do
        local removed = table.remove(self.buffs, toRemove[i])
        removed:OnDisable()
        table.insert(removedBuffs, removed)
    end

    for _, buff in ipairs(removedBuffs) do
        buff:OnDestroy()
    end
end

---@param buff BuffBase
function cls:onNewBuff(buff)
    table.insert(self.buffs, buff)
    buff:Awake()
    buff:OnEnable()
end

function cls:_onUnitDeath(unit)
    local toDestroy = {}
    for i = #self.buffs, 1, -1 do
        local buff = self.buffs[i]
        if IsUnit(buff.target, unit) then
            buff:OnDisable()
            table.remove(self.buffs, i)
            table.insert(toDestroy, buff)
        end
    end
    for _, v in ipairs(toDestroy) do
        v:OnDestroy()
    end
end

function cls:onKillBuff(buff)
    for i = #self.buffs, 1, -1 do
        if buff == self.buffs[i] then
            buff:OnDisable()
            table.remove(self.buffs, i)
        end
    end
    buff:OnDestroy()
end

return cls

end}

__modules["System.DamageSystem"]={loader=function()
local EventCenter = require("Lib.EventCenter")
local Event = require("Lib.Event")
local UnitAttribute = require("Objects.UnitAttribute")
local Const = require("Config.Const")

EventCenter.RegisterPlayerUnitDamaging = Event.new()
EventCenter.RegisterPlayerUnitDamaged = Event.new()
---data {whichUnit, target, amount, attack, ranged, attackType, damageType, weaponType, outResult}
EventCenter.Damage = Event.new()
---data: {caster:unit,target:unit}
EventCenter.Heal = Event.new()
EventCenter.HealMana = Event.new()
EventCenter.PlayerUnitAttackMiss = Event.new()

local SystemBase = require("System.SystemBase")

---@class DamageSystem : SystemBase
local cls = class("DamageSystem", SystemBase)

function cls:ctor()
    cls.super.ctor(self)
    local damagingTrigger = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(damagingTrigger, EVENT_PLAYER_UNIT_DAMAGING)
    ExTriggerAddAction(damagingTrigger, function()
        self:_response(self._damagingHandlers)
    end)

    local damagedTrigger = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(damagedTrigger, EVENT_PLAYER_UNIT_DAMAGED)
    ExTriggerAddAction(damagedTrigger, function()
        self:_response(self._damagedHandlers)
    end)

    --local enterTrigger = CreateTrigger()
    --TriggerRegisterEnterRegion(enterTrigger, CreateRegion(), Filter(function() return true end))
    --TriggerAddAction(enterTrigger, function()
    --    TriggerRegisterUnitEvent(damageTrigger, GetTriggerUnit(), EVENT_UNIT_DAMAGED)
    --end)

    self._damagingHandlers = {}
    self._damagedHandlers = {}
end

function cls:Awake()
    EventCenter.RegisterPlayerUnitDamaging:On(self, cls._registerDamaging)
    EventCenter.RegisterPlayerUnitDamaged:On(self, cls._registerDamaged)
    EventCenter.Damage:On(self, cls._onDamage)
    EventCenter.Heal:On(self, cls._onHeal)
    EventCenter.HealMana:On(self, cls._onHealMana)
end

function cls:OnEnable()
    EventCenter.RegisterPlayerUnitDamaging:Emit(function(caster, target, damage, weaponType, damageType, isAttack)
        if not isAttack then
            return
        end

        local b = UnitAttribute.GetAttr(target)
        if b.dodge > 0 then
            if math.random() < b.dodge then
                BlzSetEventDamage(0)
                BlzSetEventWeaponType(WEAPON_TYPE_WHOKNOWS)
                ExTextMiss(target)

                EventCenter.PlayerUnitAttackMiss:Emit({
                    caster = caster,
                    target = target,
                })
                return
            end
        end

        local a = UnitAttribute.GetAttr(caster)
        damage = damage * (1 + a.damageAmplification - b.damageReduction)
        BlzSetEventDamage(damage)
    end)
end

function cls:_registerDamaging(handler)
    table.insert(self._damagingHandlers, handler)
end

function cls:_registerDamaged(handler)
    table.insert(self._damagedHandlers, handler)
end

function cls:_response(whichHandlers)
    local damage = GetEventDamage()
    local caster = GetEventDamageSource()
    local target = BlzGetEventDamageTarget()
    local damageType = BlzGetEventDamageType()
    local weaponType = BlzGetEventWeaponType()
    local isAttack = BlzGetEventIsAttack()
    for _, v in ipairs(whichHandlers) do
        v(caster, target, damage, weaponType, damageType, isAttack)
    end
end

-- whichUnit, target, amount, attack, ranged, attackType, damageType, weaponType, outResult
function cls:_onDamage(d)
    local a = UnitAttribute.GetAttr(d.whichUnit)
    local b = UnitAttribute.GetAttr(d.target)
    if d.attack then
        if math.random() < b.dodge then
            d.outResult.hitResult = Const.HitResult_Miss
            EventCenter.PlayerUnitAttackMiss:Emit({
                caster = d.whichUnit,
                target = d.target,
            })
            ExTextMiss(d.target)
            return
        end
    end

    local amount = d.amount * (1 + a.damageAmplification - b.damageReduction)
    UnitDamageTarget(d.whichUnit, d.target, amount, d.attack, d.ranged, d.attackType, d.damageType, d.weaponType)
    d.outResult.hitResult = Const.HitResult_Hit
    d.outResult.damage = amount
end

function cls:_onHeal(data)
    local current = GetUnitState(data.target, UNIT_STATE_LIFE)
    local attr = UnitAttribute.GetAttr(data.target)
    local healed = data.amount * (1 + attr.healingTaken)
    SetWidgetLife(data.target, current + healed)
end

function cls:_onHealMana(data)
    local current = GetUnitState(data.target, UNIT_STATE_MANA)
    local amount
    if data.isPercentage then
        amount = data.amount * GetUnitState(data.target, UNIT_STATE_MAX_MANA)
    else
        amount = data.amount
    end
    SetUnitState(data.target, UNIT_STATE_MANA, current + amount)
end

return cls

end}

__modules["System.InitAbilitiesSystem"]={loader=function()
local SystemBase = require("System.SystemBase")

---@class InitAbilitiesSystem : SystemBase
local cls = class("InitAbilitiesSystem", SystemBase)

function cls:Awake()
    -- 血DK
    require("Ability.DeathGrip")
    require("Ability.DeathStrike")
    require("Ability.PlagueStrike")
    require("Ability.ArmyOfTheDead")

    -- 邪DK
    require("Ability.FesteringWound")
    require("Ability.DeathCoil")
    require("Ability.Defile")
    require("Ability.Apocalypse")
    require("Ability.DarkTransformation")
    require("Ability.MonstrousBlow")
    require("Ability.ShamblingRush")
    require("Ability.PutridBulwark")

    -- 默认 恶魔猎手
    require("Ability.Evasion")
    require("Ability.MoonWellHeal")

    -- 武器战
    require("Ability.RageGenerator")
    require("Ability.DeepWounds")
    require("Ability.Overpower")
    require("Ability.Charge")
    require("Ability.MortalStrike")
    require("Ability.Condemn")
    require("Ability.BladeStorm")
end

return cls

end}

__modules["System.ItemSystem"]={loader=function()
---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Rick Sun.
--- DateTime: 9/17/2022 1:46 PM
---

local Event = require("Lib.Event")
local EventCenter = require("Lib.EventCenter")
local SystemBase = require("System.SystemBase")

EventCenter.PlayerUnitPickupItem = Event.new()

---@class EventRegisterItemRecipeData
---@field result item
---@field recipe table<item, integer>

---@class EventRegisterItemRecipe : Event
---@field data EventRegisterItemRecipeData
EventCenter.RegisterItemRecipe = Event.new()

---@class ItemSystem : SystemBase
local cls = class("ItemSystem", SystemBase)

function cls:ctor()
    local trigger = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trigger, EVENT_PLAYER_UNIT_PICKUP_ITEM)
    ExTriggerAddAction(trigger, function()
        local item = GetManipulatedItem()
        local unit = GetTriggerUnit()
        local player = GetTriggerPlayer()
        EventCenter.PlayerUnitPickupItem:Emit({
            item = item,
            unit = unit,
            player = player
        })
        self:_mergeItems(item, unit, player)
    end)

    self._recipes = {} ---@type table<item, table<item, integer>[]> key=result, key2=ingredient value2=ingredient count
    self._ingredients = {} ---@type table<item, table<item, integer>> key=ingredient key2=result value2=1
    EventCenter.RegisterItemRecipe:On(self, cls._registerItemRecipe)
end

function cls:_collectItemsInSlot(unit)
    local t = {}
    for i = 0, 5 do
        local item = UnitItemInSlot(unit, i)
        if item then
            table.addNum(t, item, 1)
        end
    end
    return t
end

function cls:_mergeItems(item, unit, player)
    local results = self._ingredients[item]
    if not results then
        return
    end

    local own = self:_collectItemsInSlot(unit)
    for result, _ in pairs(results) do

    end
end

---@param data EventRegisterItemRecipeData
function cls:_registerItemRecipe(data)
    local options = self._recipes[data.result]
    if not options then
        options = {}
        self._recipes[data.result] = options
    end
    table.insert(options, data.recipe)

    for k, _ in pairs(data.recipe) do
        local ingredient = self._ingredients[k]
        if not ingredient then
            ingredient = {}
            self._ingredients[k] = ingredient
        end
        ingredient[data.result] = 1
    end
end

return cls

end}

__modules["System.ManagedAISystem"]={loader=function()
local SystemBase = require("System.SystemBase")
local EventCenter = require("Lib.EventCenter")
local Event = require("Lib.Event")
local Vector2 = require("Lib.Vector2")

---positions: {x, y, out hp}[]
EventCenter.InitCamp = Event.new()

local CampFlag = FourCC("e001")

---@class ManagedAISystem : SystemBase
local cls = class("ManagedAISystem", SystemBase)

function cls:ctor()
    self.ais = {}
    self.campPositions = {}
end

function cls:Awake()
    EventCenter.InitCamp:On(self, cls.onInitCamp)

    ExGroupEnumUnitsInMap(function(unit)
        if GetUnitTypeId(unit) == CampFlag then
            table.insert(self.campPositions, Vector2.FromUnit(unit))
            RemoveUnit(unit)
        end
    end)

    table.insert(self.ais, require("AI.TwistedMeadows").new())
end

function cls:Update(dt)
    for _, v in ipairs(self.ais) do
        v:Update(dt)
    end
end

function cls:onInitCamp(data)
    for _, p in ipairs(self.campPositions) do
        local hp = 0
        ExGroupEnumUnitsInRange(p.x, p.y, 400, function(unit)
            if ExGetUnitPlayerId(unit) == 24 and not IsUnitType(unit, UNIT_TYPE_STRUCTURE) then
                hp = hp + GetWidgetLife(unit)
            end
        end)
        if hp > 5 then
            table.insert(data, {
                p = p,
                hp = hp,
            })
        end
    end
end

--ExTriggerRegisterUnitLearn(0, function(unit, level, skill)
--    local Utils = require("Lib.Utils")
--    print(GetUnitName(unit), "learn", Utils.CCFour(skill), level)
--end)

return cls

end}

__modules["System.MeleeGameSystem"]={loader=function()
local SystemBase = require("System.SystemBase")

---@class MeleeGameSystem : SystemBase
local cls = class("MeleeGameSystem", SystemBase)

function cls:ctor()
    MeleeStartingVisibility()
    MeleeStartingHeroLimit()
    MeleeGrantHeroItems()
    MeleeStartingResources()
    MeleeClearExcessUnits()
    MeleeStartingUnits()
    MeleeStartingAI()
    MeleeInitVictoryDefeat()
end

return cls

end}

__modules["System.MoverSystem"]={loader=function()
local Event = require("Lib.Event")
local EventCenter = require("Lib.EventCenter")
local SystemBase = require("System.SystemBase")
local Vector2 = require("Lib.Vector2")
local Mover = require("Objects.Mover")

EventCenter.NewMover = Event.new()

---@class MoverSystem : SystemBase
local cls = class("MoverSystem", SystemBase)

function cls:ctor()
    self.instances = {} ---@type Mover[]
end

function cls:Awake()
    EventCenter.NewMover:On(self, cls.onNewMover)
end

function cls:Update(dt)
    local toRemove = {}
    for idx, inst in ipairs(self.instances) do
        local dist = inst.moveBehaviour(inst, dt)
        if inst:CheckArrived(dist) then
            if inst.onArrived then
                inst.onArrived()
            end
            table.insert(toRemove, idx)
        end
    end

    for i = #toRemove, 1, -1 do
        table.remove(self.instances, toRemove[i])
    end
end

---@param inst Mover
function cls:onNewMover(inst)
    if inst.destType == Mover.DestinationType.None then
        if inst.onArrived then
            inst.onArrived()
        end
    else
        table.insert(self.instances, inst)
    end
end

return cls

end}

__modules["System.ProjectileSystem"]={loader=function()
local Event = require("Lib.Event")
local EventCenter = require("Lib.EventCenter")
local SystemBase = require("System.SystemBase")
local Vector2 = require("Lib.Vector2")

EventCenter.NewProjectile = Event.new()

---@class ProjectileSystem : SystemBase
local cls = class("ProjectileSystem", SystemBase)

function cls:ctor()
    self.projectiles = {} ---@type ProjectileBase[]
end

function cls:Awake()
    EventCenter.NewProjectile:On(self, cls.onNewProjectile)
end

function cls:Update(dt)
    local toRemove = {}
    for idx, proj in ipairs(self.projectiles) do
        if proj.targetType == "unit" then
            local curr = proj.pos
            local dest = Vector2.FromUnit(proj.target)
            local norm = (dest - curr):SetNormalize()
            local dir = norm * (proj.speed * dt)
            curr:Add(dir)
            BlzSetSpecialEffectX(proj.sfx, curr.x)
            BlzSetSpecialEffectY(proj.sfx, curr.y)
            BlzSetSpecialEffectZ(proj.sfx, curr:GetTerrainZ() + 60) -- todo, use vec3
            BlzSetSpecialEffectYaw(proj.sfx, math.atan2(norm.y, norm.x))

            if dest:Sub(curr):GetMagnitude() < 96 then
                DestroyEffect(proj.sfx)
                proj.onHit()

                table.insert(toRemove, idx)
            end
        end
    end

    for i = #toRemove, 1, -1 do
        table.remove(self.projectiles, toRemove[i])
    end
end

function cls:onNewProjectile(data)
    table.insert(self.projectiles, data.inst)
end

return cls

end}

__modules["System.SpellSystem"]={loader=function()
local Event = require("Lib.Event")
local EventCenter = require("Lib.EventCenter")
local SystemBase = require("System.SystemBase")

---@class ISpellData
---@field abilityId integer
---@field caster unit
---@field target unit
---@field x real
---@field y real
---@field item item
---@field destructable destructable
---@field finished boolean
---@field interrupted ISpellData
---@field _effectDone boolean

---@class IRegisterSpellEvent : Event
---@field Emit fun(arg: { id: integer, handler: (fun(data: ISpellData): void), ctx: table }): void

---@class SpellSystem : SystemBase
local cls = class("SpellSystem", SystemBase)

---@type IRegisterSpellEvent
EventCenter.RegisterPlayerUnitSpellChannel = Event.new()
---@type IRegisterSpellEvent
EventCenter.RegisterPlayerUnitSpellCast = Event.new()
---@type IRegisterSpellEvent
EventCenter.RegisterPlayerUnitSpellEffect = Event.new()
---@type IRegisterSpellEvent
EventCenter.RegisterPlayerUnitSpellFinish = Event.new()
---@type IRegisterSpellEvent
EventCenter.RegisterPlayerUnitSpellEndCast = Event.new()

function cls:ctor()
    self:_register(EVENT_PLAYER_UNIT_SPELL_CHANNEL, function()
        local data = self:_initSpellData()
        self:_invoke(self._channelHandlers, data)
    end)

    self:_register(EVENT_PLAYER_UNIT_SPELL_CAST, function()
        local data = self.castTab[GetTriggerUnit()]
        self:_invoke(self._castHandlers, data)
    end)

    self:_register(EVENT_PLAYER_UNIT_SPELL_EFFECT, function()
        local data = self.castTab[GetTriggerUnit()]
        if data and not data._effectDone then
            data._effectDone = true
            self:_invoke(self._effectHandlers, data)
        end
    end)

    self:_register(EVENT_PLAYER_UNIT_SPELL_FINISH, function()
        local data = self.castTab[GetTriggerUnit()]
        if data == nil then
            return
        end
        data.finished = true
        self:_invoke(self._finishHandlers, data)
    end)

    self:_register(EVENT_PLAYER_UNIT_SPELL_ENDCAST, function()
        local data = self.castTab[GetTriggerUnit()]
        self:_invoke(self._endCastHandlers, data)
        if data.interrupted then
            self.castTab[data.caster] = data.interrupted
        else
            self.castTab[data.caster] = nil
        end
    end)

    self.castTab = {} ---@type table<unit, ISpellData>

    self._channelHandlers = {}
    self._castHandlers = {}
    self._effectHandlers = {}
    self._finishHandlers = {}
    self._endCastHandlers = {}

    EventCenter.RegisterPlayerUnitSpellChannel:On(self, cls._registerSpellChannel)
    EventCenter.RegisterPlayerUnitSpellCast:On(self, cls._registerSpellCast)
    EventCenter.RegisterPlayerUnitSpellEffect:On(self, cls._registerSpellEffect)
    EventCenter.RegisterPlayerUnitSpellFinish:On(self, cls._registerSpellFinish)
    EventCenter.RegisterPlayerUnitSpellEndCast:On(self, cls._registerSpellEndCast)
end

---@param data ISpellData
function cls:_invoke(handlers, data)
    local tab = handlers[0]
    if tab then
        for _, listener in ipairs(tab) do
            if listener.ctx then
                listener.handler(listener.ctx, data)
            else
                listener.handler(data)
            end
        end
    end
    if not data then
        return
    end
    tab = handlers[data.abilityId]
    if tab then
        for _, listener in ipairs(tab) do
            if listener.ctx then
                listener.handler(listener.ctx, data)
            else
                listener.handler(data)
            end
        end
    end
end

function cls:_register(event, callback)
    local trigger = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trigger, event)
    ExTriggerAddAction(trigger, callback)
end

function cls:_initSpellData()
    local data = {} ---@type ISpellData
    data.abilityId = GetSpellAbilityId()
    data.caster = GetTriggerUnit()
    data.target = GetSpellTargetUnit()
    if data.target ~= nil then
        data.x = GetUnitX(data.target)
        data.y = GetUnitY(data.target)
    else
        data.destructable = GetSpellTargetDestructable()
        if data.destructable ~= nil then
            data.x = GetDestructableX(data.destructable)
            data.y = GetDestructableY(data.destructable)
        else
            data.item = GetSpellTargetItem()
            if data.item ~= nil then
                data.x = GetItemX(data.item)
                data.y = GetItemY(data.item)
            else
                data.x = GetSpellTargetX()
                data.y = GetSpellTargetY()
            end
        end
    end
    data.interrupted = self.castTab[data.caster]
    self.castTab[data.caster] = data
    return data
end

function cls:_registerSpell(data, tab)
    local listeners = tab[data.id]
    if listeners == nil then
        listeners = {}
        tab[data.id] = listeners
    end
    table.insert(listeners, data)
end

function cls:_registerSpellChannel(data)
    self:_registerSpell(data, self._channelHandlers)
end

function cls:_registerSpellCast(data)
    self:_registerSpell(data, self._castHandlers)
end

function cls:_registerSpellEffect(data)
    self:_registerSpell(data, self._effectHandlers)
end

function cls:_registerSpellFinish(data)
    self:_registerSpell(data, self._finishHandlers)
end

function cls:_registerSpellEndCast(data)
    self:_registerSpell(data, self._endCastHandlers)
end

return cls

end}

__modules["System.SystemBase"]={loader=function()
---@class SystemBase
local cls = class("SystemBase")

function cls:Awake()
end

function cls:OnEnable()
end

---@param dt real
function cls:Update(dt)
end

function cls:OnDisable()
end

function cls:OnDestroy()
end

return cls

end}

__modules["Main"].loader()
end
--lua-bundler:000162889

function InitGlobals()
end

function Unit000006_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 4), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 2), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000016_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 3), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000025_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000027_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000035_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000036_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 2), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000039_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 4), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000047_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 3), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000051_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 5), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 2), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000052_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 3), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 1), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000057_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 2), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000058_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 4), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000059_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 2), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000060_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 4), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 2), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000070_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000076_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 3), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000088_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 2), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000090_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000096_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 3), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000097_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 2), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000101_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 2), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000105_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000106_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 6), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000112_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 5), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 2), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000113_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 5), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 2), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000117_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000118_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 6), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000119_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000124_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000127_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 3), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 1), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000130_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000133_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000135_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 6), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000136_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 6), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000137_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000152_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 4), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 2), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000153_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 4), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 2), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000158_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 5), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 2), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function CreateUnitsForPlayer0()
local p = Player(0)
local u
local unitID
local t
local life

u = BlzCreateUnitWithSkin(p, FourCC("Obla"), 1342.6, -2835.4, 357.781, FourCC("Obla"))
end

function CreateNeutralHostile()
local p = Player(PLAYER_NEUTRAL_AGGRESSIVE)
local u
local unitID
local t
local life

u = BlzCreateUnitWithSkin(p, FourCC("nftt"), -6703.7, 7033.2, 328.079, FourCC("nftt"))
u = BlzCreateUnitWithSkin(p, FourCC("ngnv"), 514.0, 2235.1, 342.720, FourCC("ngnv"))
SetUnitAcquireRange(u, 200.0)
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000097_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nogr"), 6582.2, -2191.4, 95.850, FourCC("nogr"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000070_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("ngnw"), 640.2, 2313.4, 334.939, FourCC("ngnw"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("ngnw"), -552.0, -2498.1, 191.445, FourCC("ngnw"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("ngnw"), -608.2, -2828.2, 144.360, FourCC("ngnw"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("ngnv"), -463.7, -2700.8, 166.260, FourCC("ngnv"))
SetUnitAcquireRange(u, 200.0)
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000036_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("ngnv"), 2237.3, -790.1, 261.739, FourCC("ngnv"))
SetUnitAcquireRange(u, 200.0)
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000088_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("ngnw"), 497.8, 2103.1, 352.261, FourCC("ngnw"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("ngnw"), 2362.3, -904.0, 253.265, FourCC("ngnw"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("ngnw"), 2051.7, -866.6, 272.236, FourCC("ngnw"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nogr"), 2565.7, 222.5, 144.697, FourCC("nogr"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("ngst"), 418.0, -3201.1, 32.322, FourCC("ngst"))
SetUnitAcquireRange(u, 200.0)
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000127_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nftk"), -4954.0, -4130.2, 70.194, FourCC("nftk"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000135_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nfsh"), -5143.4, -4014.5, 31.644, FourCC("nfsh"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000133_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nomg"), -4981.8, -3927.0, 33.921, FourCC("nomg"))
u = BlzCreateUnitWithSkin(p, FourCC("nomg"), -4708.2, -4192.4, 74.338, FourCC("nomg"))
u = BlzCreateUnitWithSkin(p, FourCC("nfsh"), -4890.0, -4322.8, 86.164, FourCC("nfsh"))
u = BlzCreateUnitWithSkin(p, FourCC("nftk"), 3823.9, -5420.6, 131.507, FourCC("nftk"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000106_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("ngnb"), -4304.9, 2148.8, 295.750, FourCC("ngnb"))
SetUnitAcquireRange(u, 200.0)
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000130_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("ngno"), -4420.6, 1994.9, 334.373, FourCC("ngno"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("ngst"), -2476.1, 6488.9, 337.747, FourCC("ngst"))
SetUnitAcquireRange(u, 200.0)
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000060_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("ngrk"), -2371.0, 6681.8, 292.924, FourCC("ngrk"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("ngst"), 6996.0, 1868.3, 235.596, FourCC("ngst"))
SetUnitAcquireRange(u, 200.0)
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000153_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("ngrk"), 7150.0, 1711.6, 210.201, FourCC("ngrk"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nftt"), 6814.6, 1993.7, 259.508, FourCC("nftt"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nfsh"), 6934.0, 2033.5, 249.183, FourCC("nfsh"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("ngst"), 2550.7, -7288.0, 197.501, FourCC("ngst"))
SetUnitAcquireRange(u, 200.0)
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000152_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("ngrk"), 2469.5, -7492.2, 169.452, FourCC("ngrk"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nogr"), 2797.5, 501.4, 152.207, FourCC("nogr"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nftt"), 2702.9, 104.9, 82.717, FourCC("nftt"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nogr"), 591.0, -3181.6, 35.933, FourCC("nogr"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nogr"), 348.2, -2972.8, 9.116, FourCC("nogr"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nftt"), 2925.0, 404.5, 127.630, FourCC("nftt"))
SetUnitAcquireRange(u, 200.0)
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000059_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nftk"), 2735.9, 307.5, 132.100, FourCC("nftk"))
SetUnitAcquireRange(u, 200.0)
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000039_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("ngnb"), 2618.0, 4308.9, 215.980, FourCC("ngnb"))
SetUnitAcquireRange(u, 200.0)
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000119_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nftt"), -7322.8, -7241.9, 57.050, FourCC("nftt"))
u = BlzCreateUnitWithSkin(p, FourCC("ngst"), -7082.3, -2657.6, 50.458, FourCC("ngst"))
SetUnitAcquireRange(u, 200.0)
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000006_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nfsh"), -6986.4, -2805.7, 62.112, FourCC("nfsh"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nftt"), 2592.4, -7071.5, 197.583, FourCC("nftt"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nfsh"), 2677.0, -7164.7, 237.964, FourCC("nfsh"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nomg"), -6369.9, 2185.8, 306.618, FourCC("nomg"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000047_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nogr"), -6429.0, 1987.0, 278.428, FourCC("nogr"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000090_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nogr"), -6164.9, 2037.8, 278.430, FourCC("nogr"))
u = BlzCreateUnitWithSkin(p, FourCC("nftt"), -6271.3, 2337.5, 282.641, FourCC("nftt"))
u = BlzCreateUnitWithSkin(p, FourCC("nomg"), -2689.2, -6731.1, 35.731, FourCC("nomg"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000096_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nogr"), -2491.4, -6793.3, 7.541, FourCC("nogr"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000025_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nogr"), -2538.1, -6528.4, 7.542, FourCC("nogr"))
u = BlzCreateUnitWithSkin(p, FourCC("nftt"), -2839.5, -6630.2, 11.753, FourCC("nftt"))
u = BlzCreateUnitWithSkin(p, FourCC("nftt"), -6511.0, 2224.6, 282.641, FourCC("nftt"))
u = BlzCreateUnitWithSkin(p, FourCC("nftt"), -2730.3, -6871.6, 11.753, FourCC("nftt"))
u = BlzCreateUnitWithSkin(p, FourCC("ngnv"), -2314.3, 127.5, 91.379, FourCC("ngnv"))
SetUnitAcquireRange(u, 200.0)
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000101_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nftt"), 6653.5, -2432.5, 100.063, FourCC("nftt"))
u = BlzCreateUnitWithSkin(p, FourCC("ngnw"), -2444.8, 255.3, 77.934, FourCC("ngnw"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nftt"), 2665.1, -7419.7, 161.041, FourCC("nftt"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nftt"), 7162.6, 1919.9, 225.889, FourCC("nftt"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nfsh"), 3621.6, -5608.5, 92.957, FourCC("nfsh"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000105_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("ngno"), 2586.5, 4127.3, 179.128, FourCC("ngno"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("ngnb"), 3485.1, -2347.1, 99.200, FourCC("ngnb"))
SetUnitAcquireRange(u, 200.0)
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000035_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("ngno"), 3600.2, -2267.2, 124.326, FourCC("ngno"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("ngnb"), -2443.6, -4602.9, 8.790, FourCC("ngnb"))
SetUnitAcquireRange(u, 200.0)
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000027_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("ngno"), -2382.2, -4762.9, 19.687, FourCC("ngno"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nogr"), -356.8, 2634.7, 220.487, FourCC("nogr"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("ngnw"), -2193.5, 296.2, 105.450, FourCC("ngnw"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nftr"), 248.6, -3095.4, 16.435, FourCC("nftr"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nftk"), 4887.4, 3714.8, 244.250, FourCC("nftk"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000118_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nomg"), 3622.4, -5424.7, 95.234, FourCC("nomg"))
u = BlzCreateUnitWithSkin(p, FourCC("nomg"), 3986.6, -5312.1, 135.651, FourCC("nomg"))
u = BlzCreateUnitWithSkin(p, FourCC("nfsh"), 5138.9, 3600.8, 205.700, FourCC("nfsh"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000117_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nftk"), -3898.8, 4764.4, 340.550, FourCC("nftk"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000136_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nomg"), 6514.2, -2387.3, 124.040, FourCC("nomg"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000016_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nomg"), 2510.0, 6434.8, 225.690, FourCC("nomg"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000076_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nftt"), -2543.4, 6278.8, 21.871, FourCC("nftt"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nfsh"), -2616.3, 6381.6, 2.332, FourCC("nfsh"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nfsh"), 4054.4, -5456.7, 147.477, FourCC("nfsh"))
u = BlzCreateUnitWithSkin(p, FourCC("nrdk"), -6712.7, 6801.8, 283.364, FourCC("nrdk"))
u = BlzCreateUnitWithSkin(p, FourCC("nrdk"), -6920.5, 6628.6, 323.077, FourCC("nrdk"))
u = BlzCreateUnitWithSkin(p, FourCC("nomg"), 4969.2, 3530.5, 207.978, FourCC("nomg"))
u = BlzCreateUnitWithSkin(p, FourCC("nggr"), 7097.7, -7361.0, 122.970, FourCC("nggr"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000113_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nomg"), 4724.5, 3822.9, 248.394, FourCC("nomg"))
u = BlzCreateUnitWithSkin(p, FourCC("nfsh"), 4831.6, 3941.3, 260.221, FourCC("nfsh"))
u = BlzCreateUnitWithSkin(p, FourCC("nftb"), -7090.6, 6768.5, 337.618, FourCC("nftb"))
u = BlzCreateUnitWithSkin(p, FourCC("nfsh"), -3813.1, 5026.9, 302.000, FourCC("nfsh"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000137_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nomg"), -3724.6, 4865.9, 304.277, FourCC("nomg"))
u = BlzCreateUnitWithSkin(p, FourCC("nomg"), -3988.4, 4590.6, 344.694, FourCC("nomg"))
u = BlzCreateUnitWithSkin(p, FourCC("nfsh"), -4117.9, 4684.1, 356.520, FourCC("nfsh"))
u = BlzCreateUnitWithSkin(p, FourCC("nrdk"), 7263.1, 6562.1, 208.554, FourCC("nrdk"))
u = BlzCreateUnitWithSkin(p, FourCC("nrdk"), 7059.6, 6740.3, 235.738, FourCC("nrdk"))
u = BlzCreateUnitWithSkin(p, FourCC("nftt"), 7502.6, 6685.8, 249.348, FourCC("nftt"))
u = BlzCreateUnitWithSkin(p, FourCC("nggr"), 7336.9, 6860.6, 233.676, FourCC("nggr"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000051_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nrdk"), 6822.2, -7219.8, 118.505, FourCC("nrdk"))
u = BlzCreateUnitWithSkin(p, FourCC("nggr"), -7198.2, -7447.9, 41.378, FourCC("nggr"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000158_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nrdk"), 7043.1, -7063.7, 126.352, FourCC("nrdk"))
u = BlzCreateUnitWithSkin(p, FourCC("nrdk"), -7053.9, -7261.7, 20.986, FourCC("nrdk"))
u = BlzCreateUnitWithSkin(p, FourCC("nogr"), 6316.1, -2230.3, 95.852, FourCC("nogr"))
u = BlzCreateUnitWithSkin(p, FourCC("nogr"), 2304.4, 6461.8, 197.500, FourCC("nogr"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000124_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nrdk"), -6854.7, -7444.7, 60.699, FourCC("nrdk"))
u = BlzCreateUnitWithSkin(p, FourCC("nftt"), 6875.6, -7454.2, 138.642, FourCC("nftt"))
u = BlzCreateUnitWithSkin(p, FourCC("nogr"), 2396.3, 6209.1, 197.502, FourCC("nogr"))
u = BlzCreateUnitWithSkin(p, FourCC("nftt"), 2675.4, 6361.4, 201.713, FourCC("nftt"))
u = BlzCreateUnitWithSkin(p, FourCC("nftb"), 7070.1, 6979.8, 259.768, FourCC("nftb"))
u = BlzCreateUnitWithSkin(p, FourCC("nogr"), -628.4, 2910.2, 232.950, FourCC("nogr"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nftr"), -553.1, 2982.2, 224.860, FourCC("nftr"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nftt"), 6409.0, -2534.5, 100.063, FourCC("nftt"))
u = BlzCreateUnitWithSkin(p, FourCC("ngst"), -497.7, 2783.4, 232.456, FourCC("ngst"))
SetUnitAcquireRange(u, 200.0)
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000052_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nftr"), -222.2, 2672.3, 224.860, FourCC("nftr"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nftr"), 498.4, -3307.5, 46.285, FourCC("nftr"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nftt"), -7234.0, -2743.7, 46.616, FourCC("nftt"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nftt"), -6878.2, -2741.2, 67.266, FourCC("nftt"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nftb"), -6939.6, -7640.6, 69.877, FourCC("nftb"))
u = BlzCreateUnitWithSkin(p, FourCC("nggr"), -6907.5, 6904.9, 312.407, FourCC("nggr"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000112_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nftt"), 2526.2, 6580.3, 201.713, FourCC("nftt"))
u = BlzCreateUnitWithSkin(p, FourCC("ngno"), -2376.3, -4453.4, 327.520, FourCC("ngno"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("ngno"), -4129.9, 2163.3, 281.315, FourCC("ngno"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("ngrk"), -7266.3, -2537.6, 34.959, FourCC("ngrk"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nftt"), -2573.9, 6633.3, 323.803, FourCC("nftt"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("ngno"), 2495.9, 4416.5, 259.004, FourCC("ngno"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nftb"), 7278.5, -7143.8, 130.095, FourCC("nftb"))
u = BlzCreateUnitWithSkin(p, FourCC("nftk"), -2617.4, -890.8, 312.100, FourCC("nftk"))
SetUnitAcquireRange(u, 200.0)
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000058_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nftt"), -2806.5, -987.8, 307.630, FourCC("nftt"))
SetUnitAcquireRange(u, 200.0)
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000057_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nftt"), -2584.4, -688.1, 262.717, FourCC("nftt"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nogr"), -2679.0, -1084.6, 332.207, FourCC("nogr"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nogr"), -2447.2, -805.8, 324.697, FourCC("nogr"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("ngno"), 3344.8, -2304.7, 57.781, FourCC("ngno"))
SetUnitAcquireRange(u, 200.0)
end

function CreateNeutralPassiveBuildings()
local p = Player(PLAYER_NEUTRAL_PASSIVE)
local u
local unitID
local t
local life

u = BlzCreateUnitWithSkin(p, FourCC("nmer"), -320.0, 2944.0, 270.000, FourCC("nmer"))
SetUnitColor(u, ConvertPlayerColor(0))
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), -4096.0, 5056.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ngad"), -2816.0, 6656.0, 270.000, FourCC("ngad"))
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), -5952.0, 6016.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 10000)
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), -6528.0, 2432.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ngad"), 2944.0, -7360.0, 270.000, FourCC("ngad"))
u = BlzCreateUnitWithSkin(p, FourCC("ngme"), 2944.0, 128.0, 270.000, FourCC("ngme"))
u = BlzCreateUnitWithSkin(p, FourCC("ngme"), -2816.0, -704.0, 270.000, FourCC("ngme"))
u = BlzCreateUnitWithSkin(p, FourCC("nmer"), 192.0, -3392.0, 270.000, FourCC("nmer"))
SetUnitColor(u, ConvertPlayerColor(0))
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), 5184.0, 4032.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), 6656.0, -2688.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ngad"), 7168.0, 2240.0, 270.000, FourCC("ngad"))
u = BlzCreateUnitWithSkin(p, FourCC("ngad"), -7104.0, -3072.0, 270.000, FourCC("ngad"))
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), -2944.0, -6912.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), 2752.0, 6592.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), 3904.0, -5824.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), -5248.0, -4352.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), -6400.0, -6784.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 10000)
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), 6720.0, 5888.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 10000)
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), 6528.0, -6464.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 10000)
u = BlzCreateUnitWithSkin(p, FourCC("ntav"), -64.0, -512.0, 270.000, FourCC("ntav"))
SetUnitColor(u, ConvertPlayerColor(0))
end

function CreateNeutralPassive()
local p = Player(PLAYER_NEUTRAL_PASSIVE)
local u
local unitID
local t
local life

u = BlzCreateUnitWithSkin(p, FourCC("nshe"), -1725.6, 6444.3, 89.014, FourCC("nshe"))
u = BlzCreateUnitWithSkin(p, FourCC("nshe"), -6317.2, -275.5, 59.493, FourCC("nshe"))
u = BlzCreateUnitWithSkin(p, FourCC("npig"), 40.5, 5413.3, 126.731, FourCC("npig"))
u = BlzCreateUnitWithSkin(p, FourCC("npig"), 33.9, 5100.0, 69.073, FourCC("npig"))
u = BlzCreateUnitWithSkin(p, FourCC("npig"), 148.9, 5285.4, 78.016, FourCC("npig"))
u = BlzCreateUnitWithSkin(p, FourCC("npig"), 241.5, -5339.7, 345.608, FourCC("npig"))
u = BlzCreateUnitWithSkin(p, FourCC("npig"), -122.5, -5984.9, 314.208, FourCC("npig"))
u = BlzCreateUnitWithSkin(p, FourCC("npig"), 561.7, -6246.6, 260.296, FourCC("npig"))
u = BlzCreateUnitWithSkin(p, FourCC("npig"), -5106.6, -437.6, 55.340, FourCC("npig"))
u = BlzCreateUnitWithSkin(p, FourCC("nshe"), 2459.3, -2699.6, 325.205, FourCC("nshe"))
u = BlzCreateUnitWithSkin(p, FourCC("nshe"), 3281.4, -1502.5, 234.796, FourCC("nshe"))
u = BlzCreateUnitWithSkin(p, FourCC("nshe"), 4881.1, -1089.0, 210.603, FourCC("nshe"))
u = BlzCreateUnitWithSkin(p, FourCC("nshe"), -3065.6, 1440.8, 353.529, FourCC("nshe"))
u = BlzCreateUnitWithSkin(p, FourCC("nshe"), -1125.9, 2726.2, 240.960, FourCC("nshe"))
u = BlzCreateUnitWithSkin(p, FourCC("e001"), -2328.8, 186.8, 20.193, FourCC("e001"))
u = BlzCreateUnitWithSkin(p, FourCC("e001"), -522.4, -2671.6, 192.398, FourCC("e001"))
u = BlzCreateUnitWithSkin(p, FourCC("e001"), 2255.9, -820.8, 227.940, FourCC("e001"))
u = BlzCreateUnitWithSkin(p, FourCC("e001"), 539.1, 2240.9, 242.498, FourCC("e001"))
u = BlzCreateUnitWithSkin(p, FourCC("e001"), -480.1, 2739.7, 288.817, FourCC("e001"))
u = BlzCreateUnitWithSkin(p, FourCC("e001"), 2754.6, 308.6, 218.668, FourCC("e001"))
u = BlzCreateUnitWithSkin(p, FourCC("e001"), 382.5, -3206.2, 349.189, FourCC("e001"))
u = BlzCreateUnitWithSkin(p, FourCC("e001"), -2601.0, -910.8, 287.268, FourCC("e001"))
u = BlzCreateUnitWithSkin(p, FourCC("e001"), -4246.1, 2122.9, 82.477, FourCC("e001"))
u = BlzCreateUnitWithSkin(p, FourCC("e001"), -2378.6, -4601.3, 99.418, FourCC("e001"))
u = BlzCreateUnitWithSkin(p, FourCC("e001"), 3518.6, -2278.5, 82.664, FourCC("e001"))
u = BlzCreateUnitWithSkin(p, FourCC("e001"), 2578.9, 4334.1, 56.449, FourCC("e001"))
u = BlzCreateUnitWithSkin(p, FourCC("e001"), 2482.2, 6432.7, 335.489, FourCC("e001"))
u = BlzCreateUnitWithSkin(p, FourCC("e001"), 4910.9, 3730.4, 35.069, FourCC("e001"))
u = BlzCreateUnitWithSkin(p, FourCC("e001"), 6505.9, -2341.8, 161.768, FourCC("e001"))
u = BlzCreateUnitWithSkin(p, FourCC("e001"), 3816.0, -5398.5, 252.342, FourCC("e001"))
u = BlzCreateUnitWithSkin(p, FourCC("e001"), 2530.6, -7244.3, 181.774, FourCC("e001"))
u = BlzCreateUnitWithSkin(p, FourCC("e001"), -2700.9, -6689.5, 63.865, FourCC("e001"))
u = BlzCreateUnitWithSkin(p, FourCC("e001"), -7104.0, -2636.9, 24.764, FourCC("e001"))
u = BlzCreateUnitWithSkin(p, FourCC("e001"), -6387.0, 2170.9, 52.802, FourCC("e001"))
u = BlzCreateUnitWithSkin(p, FourCC("e001"), -2483.4, 6472.4, 73.688, FourCC("e001"))
end

function CreatePlayerBuildings()
end

function CreatePlayerUnits()
CreateUnitsForPlayer0()
end

function CreateAllUnits()
CreateNeutralPassiveBuildings()
CreatePlayerBuildings()
CreateNeutralHostile()
CreateNeutralPassive()
CreatePlayerUnits()
end

function InitCustomPlayerSlots()
SetPlayerStartLocation(Player(0), 0)
ForcePlayerStartLocation(Player(0), 0)
SetPlayerColor(Player(0), ConvertPlayerColor(0))
SetPlayerRacePreference(Player(0), RACE_PREF_ORC)
SetPlayerRaceSelectable(Player(0), false)
SetPlayerController(Player(0), MAP_CONTROL_USER)
SetPlayerStartLocation(Player(1), 1)
ForcePlayerStartLocation(Player(1), 1)
SetPlayerColor(Player(1), ConvertPlayerColor(1))
SetPlayerRacePreference(Player(1), RACE_PREF_NIGHTELF)
SetPlayerRaceSelectable(Player(1), false)
SetPlayerController(Player(1), MAP_CONTROL_COMPUTER)
end

function InitCustomTeams()
SetPlayerTeam(Player(0), 0)
SetPlayerTeam(Player(1), 1)
end

function main()
SetCameraBounds(-7936.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), -8192.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM), 7936.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), 7680.0 - GetCameraMargin(CAMERA_MARGIN_TOP), -7936.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), 7680.0 - GetCameraMargin(CAMERA_MARGIN_TOP), 7936.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), -8192.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM))
SetDayNightModels("Environment\\DNC\\DNCLordaeron\\DNCLordaeronTerrain\\DNCLordaeronTerrain.mdl", "Environment\\DNC\\DNCLordaeron\\DNCLordaeronUnit\\DNCLordaeronUnit.mdl")
NewSoundEnvironment("Default")
SetAmbientDaySound("LordaeronSummerDay")
SetAmbientNightSound("LordaeronSummerNight")
SetMapMusic("Music", true, 0)
CreateAllUnits()
InitBlizzard()
InitGlobals()
local s, m = pcall(RunBundle)
if not s then
    print(m)
end
end

function config()
SetMapName("TRIGSTR_001")
SetMapDescription("TRIGSTR_003")
SetPlayers(2)
SetTeams(2)
SetGamePlacement(MAP_PLACEMENT_USE_MAP_SETTINGS)
DefineStartLocation(0, -4608.0, -3904.0)
DefineStartLocation(1, -3584.0, 4480.0)
InitCustomPlayerSlots()
InitCustomTeams()
end

