--lua-bundler:000219269
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
                if (v2 - v1):Magnitude() < 96 then
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
local UnitAttribute = require("Objects.UnitAttribute")

--region meta

local Meta = {
    ID = FourCC("A003"),
    DamageReduction = 0,
}

Abilities.ArmyOfTheDead = Meta

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

function cls:ctor(caster, level, meta)
    self.meta = meta
    self.caster = caster
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

    local attr = UnitAttribute.GetAttr(caster)
    attr.damageReduction = attr.damageReduction + meta.DamageReduction
end

function cls:Stop()
    self.sfxTimer:Stop()
    self.summonTimer:Stop()

    local attr = UnitAttribute.GetAttr(self.caster)
    attr.damageReduction = attr.damageReduction + self.meta.DamageReduction
end

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Abilities.ArmyOfTheDead.ID,
    ---@param data ISpellData
    handler = function(data)
        instances[data.caster] = cls.new(data.caster, GetUnitAbilityLevel(data.caster, data.abilityId), Meta)
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

__modules["Ability.BrainConnection"]={loader=function()
local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local BuffBase = require("Objects.BuffBase")
local FesteringWound = require("Ability.FesteringWound")
local UnitAttribute = require("Objects.UnitAttribute")
local Vector2 = require("Lib.Vector2")
local Timer = require("Lib.Timer")

--region meta

local Meta = {
    SanityCost = 2,
    Damage = 50,
    SearchRange = 2400,
    ClearRange = 256,
}

Abilities.BrainConnection = Meta

--endregion

---@class BrainConnection
local cls = class("BrainConnection")

cls.instances = {} ---@type table<unit, BrainConnection>

function cls:ctor(caster, target1, target2)
    self.caster = caster
    self.tar1 = target1
    self.tar2 = target2

    self.lightning, self.lightningCo = ExAddLightningUnitUnit("ESPB", self.tar1, self.tar2, 999, { r = 1, g = 1, b = 1, a = 1 }, false)

    self.timer = Timer.new(function()
        if Vector2.UnitDistance(self.tar1, self.tar2) <= Meta.ClearRange then
            self:stop()
        else
            for _, v in ipairs({ self.tar1, self.tar2 }) do
                local attr = UnitAttribute.GetAttr(v)
                attr.sanity = attr.sanity - Meta.SanityCost
                EventCenter.Damage:Emit({
                    whichUnit = self.caster,
                    target = v,
                    amount = Meta.Damage,
                    attack = false,
                    ranged = true,
                    attackType = ATTACK_TYPE_CHAOS,
                    damageType = DAMAGE_TYPE_DIVINE,
                    weaponType = WEAPON_TYPE_WHOKNOWS,
                    outResult = {}
                })
            end
        end
    end, 1, -1)
    self.timer:Start()
end

function cls:stop()
    cls.instances[self.tar1] = nil
    cls.instances[self.tar2] = nil
    self.timer:Stop()
    coroutine.stop(self.lightningCo)
    DestroyLightning(self.lightning)
end

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Abilities.Apocalypse.ID,
    ---@param data ISpellData
    handler = function(data)
        local target = data.target
        local inst = cls.instances[target]
        if inst then
            return
        end

        local tPos = Vector2.FromUnit(target)
        local targetPlayer = GetOwningPlayer(target)
        local nearby = ExGroupGetUnitsInRange(tPos.x, tPos.y, Meta.SearchRange, function(unit)
            return not ExIsUnitDead(unit) and IsUnitAlly(unit, targetPlayer) and not IsUnit(unit, target)
        end)

        if not table.any(nearby) then
            return
        end

        table.sort(nearby, function(a, b)
            return Vector2.UnitDistanceSqr(target, b) < Vector2.UnitDistanceSqr(target, a)
        end)

        local connector = nearby[1]
        inst = cls.new(data.caster, target, connector)
        cls.instances[target] = inst
        cls.instances[connector] = inst
    end
})

ExTriggerRegisterUnitDeath(function(unit)
    local inst = cls.instances[unit]
    if inst then
        inst:stop()
    end
end)

return cls

end}

__modules["Ability.BrainPortal"]={loader=function()
local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local BuffBase = require("Objects.BuffBase")
local FesteringWound = require("Ability.FesteringWound")
local UnitAttribute = require("Objects.UnitAttribute")
local Vector2 = require("Lib.Vector2")
local Timer = require("Lib.Timer")

--region meta

local Meta = {
    Range = 600,
    AllowedPeople = 2,
    PortalRange = 256,
}

Abilities.BrainConnection = Meta

--endregion

---@class BrainPortal
local cls = class("BrainPortal")

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Abilities.Apocalypse.ID,
    ---@param data ISpellData
    handler = function(data)
        local v = Vector2.new(1, 0):RotateSelf(math.random() * 2 * math.pi):Mul(Meta.Range)
        local portalPos = Vector2.FromUnit(data.caster):Add(v)
        local sfx = AddSpecialEffect("dark_portal", portalPos.x, portalPos.y)

        local allowedPeople = Meta.AllowedPeople

        coroutine.start(function()
            while true do
                coroutine.wait(0.1)
                local nearby = ExGroupGetUnitsInRange(portalPos.x, portalPos.y, Meta.PortalRange, function(unit)
                    if IsUnitAlly(unit, Player(1)) and not ExIsUnitDead(unit) then
                        return true
                    else
                        return false
                    end
                end)
                if table.any(nearby) then
                    -- teleport unit
                    allowedPeople = allowedPeople - 1
                end

                if allowedPeople <= 0 then
                    DestroyEffect(sfx)
                    break
                end
            end
        end)

    end
})

return cls

end}

__modules["Ability.Charge"]={loader=function()
-- 冲锋

local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local BuffBase = require("Objects.BuffBase")
local Vector2 = require("Lib.Vector2")
local Const = require("Config.Const")
local RootDebuff = require("Ability.RootDebuff")
local UnitAttribute = require("Objects.UnitAttribute")

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

|cff99ccff施法距离|r - %s-1200
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
        if (v2 - v1):Magnitude() < Meta.MinDistance then
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
                local distance = math.max(v3:Magnitude() - 96, 0)
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
                    ExAddSpecialEffect("Environment/SmallBuildingFire/SmallBuildingFire0.mdl", v1.x, v1.y, 1.2)
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

            if not ExIsUnitDead(data.target) then
                local attr = UnitAttribute.GetAttr(data.caster)
                local damage = attr:SimAttack(UnitAttribute.HeroAttributeType.Strength) * Meta.Damage
                EventCenter.Damage:Emit({
                    whichUnit = data.caster,
                    target = data.target,
                    amount = damage,
                    attack = false,
                    ranged = true,
                    attackType = ATTACK_TYPE_HERO,
                    damageType = DAMAGE_TYPE_NORMAL,
                    weaponType = WEAPON_TYPE_WHOKNOWS,
                    outResult = {},
                })

                local level = GetUnitAbilityLevel(data.caster, Meta.ID)
                local duration = IsUnitType(data.target, UNIT_TYPE_HERO) and Meta.DurationHero[level] or Meta.DurationMinion[level]
                local debuff = BuffBase.FindBuffByClassName(data.target, RootDebuff.__cname)
                if debuff then
                    debuff:ResetDuration(Time.Time + duration)
                else
                    RootDebuff.new(data.caster, data.target, duration, 999)
                end
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

__modules["Ability.DarkHeal"]={loader=function()
local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local BuffBase = require("Objects.BuffBase")
local ProjectileBase = require("Objects.ProjectileBase")
local FesteringWound = require("Ability.FesteringWound")
local Const = require("Config.Const")

--region meta

local Meta = {
    ID = FourCC("A01M"),
    Heal = 400,
}

Abilities.DarkHeal = Meta

--endregion

local cls = class("DarkHeal")

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        EventCenter.Heal:Emit({
            caster = data.caster,
            target = data.target,
            amount = Meta.Heal,
        })
        ExAddSpecialEffectTarget("Abilities/Spells/Undead/RaiseSkeletonWarrior/RaiseSkeleton.mdl", data.target, "origin", 1)
    end
})

return cls

end}

__modules["Ability.DarkShield"]={loader=function()
local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local BuffBase = require("Objects.BuffBase")
local ProjectileBase = require("Objects.ProjectileBase")
local FesteringWound = require("Ability.FesteringWound")
local Const = require("Config.Const")
local UnitAttribute = require("Objects.UnitAttribute")

--region meta

local Meta = {
    ID = FourCC("A01N"),
    Shield = 100,
    Duration = 15,
}

Abilities.DarkShield = Meta

--endregion

---@class DarkShield : BuffBase
local cls = class("DarkShield", BuffBase)

function cls:OnEnable()
    self.sfx = AddSpecialEffectTarget("Abilities/Spells/Items/StaffOfSanctuary/Staff_Sanctuary_Target.mdl", self.target, "overhead")
    local attr = UnitAttribute.GetAttr(self.target)
    table.insert(attr.absorbShields, self)
end

function cls:OnDisable()
    DestroyEffect(self.sfx)
end

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        local buff = BuffBase.FindBuffByClassName(data.target, cls.__cname)
        if buff then
            buff:ResetDuration()
        else
            buff = cls.new(data.caster, data.target, Meta.Duration, 9999, {})
        end
        buff.shield = Meta.Shield
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
local UnitAttribute = require("Objects.UnitAttribute")

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

function cls:ctor(caster, target, level)
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

        if not ExIsUnitDead(target) then
            local impact = AddSpecialEffectTarget("Abilities/Spells/Undead/DeathCoil/DeathCoilSpecialArt.mdl", target, "origin")
            local impactTimer = Timer.new(function()
                DestroyEffect(impact)
            end, 2, 1)
            impactTimer:Start()

            local count = PlagueStrike.GetPlagueCount(target)
            local duration
            if IsUnitType(target, UNIT_TYPE_HERO) then
                duration = Abilities.DeathGrip.DurationHero[level]
            else
                duration = Abilities.DeathGrip.Duration[level]
            end
            duration = duration * (1 + Abilities.DeathGrip.PlagueLengthen[level] * count)
            local debuff = BuffBase.FindBuffByClassName(target, RootDebuff.__cname)
            if debuff then
                debuff:ResetDuration(Time.Time + duration)
            else
                RootDebuff.new(caster, target, duration, 999)
            end

            local attr = UnitAttribute.GetAttr(target)
            attr:TauntedBy(caster, duration)

            coroutine.wait(duration - 1)
            DestroyEffect(sfx)

            PlagueStrike.Spread(caster, target)
        end
    end)
end

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Abilities.DeathGrip.ID,
    ---@param data ISpellData
    handler = function(data)
        cls.new(data.caster, data.target, GetUnitAbilityLevel(data.caster, Abilities.DeathGrip.ID))
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
            table.insert(candidates, { unit = e, dist = v2:Magnitude() })
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

__modules["Ability.Disintegrate"]={loader=function()
local Vector2 = require("Lib.Vector2")
local EventCenter = require("Lib.EventCenter")
local Timer = require("Lib.Timer")
local Pill = require("Lib.Pill")
local Circle = require("Lib.Circle")
local UnitAttribute = require("Objects.UnitAttribute")
local Abilities = require("Config.Abilities")

local cls = class("Disintegrate")

local Meta = {
    ID = FourCC("A01E"),
    MoveSpeedPercent = -0.30,
    Damage = 150,
}

local Width = 64
local BackOffset = 10
local Radius = Width / 2
local PointMoveForward = Radius - 10

Abilities.Disintegrate = Meta

local instances = {}

function cls:ctor(caster, target)
    self.lightning, self.lightningCo = ExAddLightningUnitUnit("DRAM", target, caster, 9999, { r = 1, g = 1, b = 1, a = 1 }, false)
    self.slowedUnits = {}
    local casterPlayer = GetOwningPlayer(caster)
    local function exec()
        local a = Vector2.FromUnit(caster)
        local b = Vector2.FromUnit(target)
        local dir = b - a
        local center = a + dir:Div(2)
        local realDist = dir:Magnitude()
        dir:SetNormalize()
        local moveForwardOffset = math.min(realDist / 2, PointMoveForward)
        local offset = dir * moveForwardOffset
        a:Add(offset)
        b:Sub(offset)
        local pill = Pill.new(a, b, Radius)

        local enumRange = realDist / 2 + BackOffset
        ExAddSpecialEffectTarget("Abilities/Spells/NightElf/MoonWell/MoonWellCasterArt.mdl", caster, "origin", 1)
        ExGroupEnumUnitsInRange(center.x, center.y, enumRange + 197, function(unit)
            if not ExIsUnitDead(unit) and IsUnitEnemy(unit, casterPlayer) then
                local circle = Circle.new(Vector2.FromUnit(unit), Radius)
                if Pill.PillCircle(pill, circle) then
                    if not self.slowedUnits[unit] then
                        local attr = UnitAttribute.GetAttr(unit)
                        attr.msp = attr.msp + Meta.MoveSpeedPercent
                        attr:Commit()
                        self.slowedUnits[unit] = true
                    end

                    EventCenter.Damage:Emit({
                        whichUnit = caster,
                        target = unit,
                        amount = Meta.Damage,
                        attack = false,
                        ranged = true,
                        attackType = ATTACK_TYPE_HERO,
                        damageType = DAMAGE_TYPE_DIVINE,
                        weaponType = WEAPON_TYPE_WHOKNOWS,
                        outResult = {},
                    })
                    ExAddSpecialEffectTarget("Abilities/Spells/Human/ManaFlare/ManaFlareBoltImpact.mdl", unit, "origin", 0.5)
                end
            end
        end)
    end
    exec()
    self.timer = Timer.new(exec, 1, -1)
    self.timer:Start()
end

function cls:stop()
    self.timer:Stop()
    coroutine.stop(self.lightningCo)
    DestroyLightning(self.lightning)
    for unit, _ in pairs(self.slowedUnits) do
        local attr = UnitAttribute.GetAttr(unit)
        attr.msp = attr.msp - Meta.MoveSpeedPercent
        attr:Commit()
    end
    self.slowedUnits = {}
end

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        instances[data.caster] = cls.new(data.caster, data.target)
    end
})

EventCenter.RegisterPlayerUnitSpellEndCast:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        local inst = instances[data.caster]
        if inst then
            inst:stop()
            instances[data.caster] = nil
        else
            print("Disintegrate end but no instance")
        end
    end
})

return cls

end}

__modules["Ability.Evasion"]={loader=function()
-- 闪避

local Abilities = require("Config.Abilities")
local UnitAttribute = require("Objects.UnitAttribute")

--region meta

local Meta = {
    ID = FourCC("A015"),
    Chance = { 0.1, 0.2, 0.3 },
    ChanceInc = { 0.1, 0.1, 0.1 },
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

__modules["Ability.FireBreath"]={loader=function()
local Vector2 = require("Lib.Vector2")
local EventCenter = require("Lib.EventCenter")
local Timer = require("Lib.Timer")
local Abilities = require("Config.Abilities")
local Tween = require("Lib.Tween")
local BuffBase = require("Objects.BuffBase")

local cls = class("FireBreath")

local Meta = {
    ID = FourCC("A01D"),
    Duration = 6,
    Interval = 2,
    ChargeInterval = 1,
    ChargeAmp = 0.15,
    ChannelDuration = 3,
    Damage = 80,
    DOT = 10,
    Heal = 160,
    AOE = 600,
}

BlzSetAbilityResearchTooltip(Meta.ID, "学习火焰吐息 - [|cffffcc00%d级|r]", 0)
BlzSetAbilityResearchExtendedTooltip(Meta.ID, string.format([[深吸一口气然后喷出，造成前方锥形龙息并击飞的效果，对敌军造成伤害并在接下来的|cffff8c00%s|r秒内每|cffff8c00%s|r秒灼烧目标，或者治疗友军单位。每蓄力|cffff8c00%s|r秒可以使效果增幅|cffff8c00%s|r，最多|cffff8c00%s|r秒。

|cff99ccff冷却时间|r - 10秒

|cffffcc001级|r - 造成|cffff8c00%s|r点基础伤害，|cffff8c00%s|r点持续伤害，|cffff8c00%s|r点治疗。]],
        Meta.Duration, Meta.Interval, Meta.ChargeInterval, string.formatPercentage(Meta.ChargeAmp), Meta.ChannelDuration,
        Meta.Damage, Meta.DOT, Meta.Heal
), 0)

for i = 1, 1 do
    BlzSetAbilityTooltip(Meta.ID, string.format("火焰吐息 - [|cffffcc00%s级|r]", i), i - 1)
    BlzSetAbilityExtendedTooltip(Meta.ID, string.format(
            [[深吸一口气然后喷出，造成前方锥形龙息并击飞的效果，对敌军造成|cffff8c00%s|r点伤害并在接下来的|cffff8c00%s|r秒内每|cffff8c00%s|r秒灼烧目标，造成|cffff8c00%s|r点伤害，或者治疗友军单位|cffff8c00%s|r点生命。每蓄力|cffff8c00%s|r秒可以使效果增幅|cffff8c00%s|r，最多|cffff8c00%s|r秒。

|cff99ccff冷却时间|r - 10秒]],
            Meta.Damage, Meta.Duration, Meta.Interval, Meta.DOT, Meta.Heal, Meta.ChargeInterval, string.formatPercentage(Meta.ChargeAmp), Meta.ChannelDuration
    ), i - 1)
end

Abilities.FireBreath = Meta

---@class FireBreathBurn : BuffBase
local FireBreathBurn = class("FireBreathBurn", BuffBase)

function FireBreathBurn:Awake()
    self.charged = self.awakeData.charged
end

function FireBreathBurn:OnEnable()
    self.sfx = AddSpecialEffectTarget("Abilities/Spells/Other/BreathOfFire/BreathOfFireDamage.mdl", self.target, "overhead")
end

function FireBreathBurn:Update()
    EventCenter.Damage:Emit({
        whichUnit = self.caster,
        target = self.target,
        amount = Meta.DOT * (1 + Meta.ChargeAmp * self.charged),
        attack = false,
        ranged = true,
        attackType = ATTACK_TYPE_HERO,
        damageType = DAMAGE_TYPE_FIRE,
        weaponType = WEAPON_TYPE_WHOKNOWS,
        outResult = {}
    })
end

function FireBreathBurn:OnDisable()
    DestroyEffect(self.sfx)
end

function FireBreathBurn.Cast(caster, target, charged)
    local debuff = BuffBase.FindBuffByClassName(target, FireBreathBurn.__cname)
    if debuff then
        debuff:ResetDuration()
    else
        FireBreathBurn.new(caster, target, Meta.Duration, Meta.Interval, { charged = charged })
    end
end

local instances = {}

function cls:ctor(caster, x, y)
    self.charging = AddSpecialEffectTarget("Abilities/Weapons/RedDragonBreath/RedDragonMissile.mdl", caster, "weapon")
    BlzSetSpecialEffectScale(self.charging, 0.1)
    self.charged = 0
    self.caster = caster
    self.targetPos = Vector2.new(x, y)

    self.timer = Timer.new(function()
        self.charged = self.charged + 1
        BlzSetSpecialEffectScale(self.charging, 0.1 + self.charged * 0.3)
    end, 1, -1)
    self.timer:Start()
end

function cls:stop()
    self.timer:Stop()
    DestroyEffect(self.charging)

    local casterPos = Vector2.FromUnit(self.caster)
    local dir = (self.targetPos - casterPos):SetNormalize()
    local offset = dir * 270
    local v = casterPos + offset
    local sfx = AddSpecialEffect("Abilities/Spells/Other/BreathOfFire/BreathOfFireMissile.mdl", v.x, v.y)
    BlzSetSpecialEffectYaw(sfx, math.atan2(dir.y, dir.x))
    local travelled = 0
    Tween.To(function()
        return travelled
    end, function(value)
        travelled = value
        local now = v + dir * travelled
        BlzSetSpecialEffectX(sfx, now.x)
        BlzSetSpecialEffectY(sfx, now.y)
    end, 600, 1)

    if self.charged < 1 then
        return
    end

    local casterPlayer = GetOwningPlayer(self.caster)
    local enumPos = casterPos - dir * 10
    ExGroupEnumUnitsInRange(enumPos.x, enumPos.y, 750, function(unit)
        if Vector2.Dot(dir, Vector2.FromUnit(unit):Sub(enumPos):SetNormalize()) > 0.28 and not ExIsUnitDead(unit) then
            if IsUnitEnemy(unit, casterPlayer) then
                EventCenter.Damage:Emit({
                    whichUnit = self.caster,
                    target = unit,
                    amount = Meta.Damage * (1 + Meta.ChargeAmp * self.charged),
                    attack = false,
                    ranged = true,
                    attackType = ATTACK_TYPE_HERO,
                    damageType = DAMAGE_TYPE_FIRE,
                    weaponType = WEAPON_TYPE_WHOKNOWS,
                    outResult = {}
                })
                FireBreathBurn.Cast(self.caster, unit, self.charged)
            else
                EventCenter.Heal:Emit({ caster = self.caster, target = unit, amount = Meta.Heal * (1 + Meta.ChargeAmp * self.charged) })
                ExAddSpecialEffectTarget("Abilities/Spells/Human/Heal/HealTarget.mdl", unit, "origin", 1)
            end
        end
    end)
end

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        instances[data.caster] = cls.new(data.caster, data.x, data.y)
    end
})

EventCenter.RegisterPlayerUnitSpellEndCast:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        local inst = instances[data.caster]
        if inst then
            inst:stop()
            instances[data.caster] = nil
        end
    end
})

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

__modules["Ability.GorefiendsGrasp"]={loader=function()
local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local Const = require("Config.Const")
local Vector2 = require("Lib.Vector2")
local Utils = require("Lib.Utils")
local BuffBase = require("Objects.BuffBase")
local Timer = require("Lib.Timer")
local PlagueStrike = require("Ability.PlagueStrike")
local RootDebuff = require("Ability.RootDebuff")
local UnitAttribute = require("Objects.UnitAttribute")
local DeathGrip = require("Ability.DeathGrip")

--region meta

local Meta = {
    ID = FourCC("A01I"),
    AOE = 600,
}

Abilities.GorefiendsGrasp = Meta

--endregion

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        local v = Vector2.FromUnit(data.caster)
        local p = GetOwningPlayer(data.caster)
        local level = GetUnitAbilityLevel(data.caster, Meta.ID)
        ExGroupEnumUnitsInRange(v.x, v.y, Meta.AOE, function(unit)
            if not ExIsUnitDead(unit) and IsUnitEnemy(unit, p) and not IsUnit(unit, data.caster) then
                DeathGrip.new(data.caster, unit, level)
            end
        end)
    end
})

end}

__modules["Ability.MagmaBreath"]={loader=function()
local EventCenter = require("Lib.EventCenter")
local Timer = require("Lib.Timer")
local Abilities = require("Config.Abilities")
local Tween = require("Lib.Tween")
local Vector3 = require("Lib.Vector3")
local Vector2 = require("Lib.Vector2")

local cls = class("MagmaBreath")

local Meta = {
    ID = FourCC("A01H"),
}

Abilities.MagmaBreath = Meta

local function aoeDamage(caster, x, y, damage, checkMap)
    local casterPlayer = GetOwningPlayer(caster)
    ExGroupEnumUnitsInRange(x, y, 120, function(unit)
        if IsUnitEnemy(unit, casterPlayer) and not ExIsUnitDead(unit) and not checkMap[unit] then
            EventCenter.Damage:Emit({
                whichUnit = caster,
                target = unit,
                amount = damage,
                attack = false,
                ranged = true,
                attackType = ATTACK_TYPE_HERO,
                damageType = DAMAGE_TYPE_FIRE,
                weaponType = WEAPON_TYPE_WHOKNOWS,
                outResult = {}
            })
            checkMap[unit] = true
        end
    end)
end

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        local myPos = Vector3.FromUnit(data.caster)
        local damaged1 = {}
        local damaged2 = {}
        myPos.z = myPos.z + 100
        local emitter = AddSpecialEffect("Abilities/Weapons/VengeanceMissile/VengeanceMissile.mdl", myPos.x, myPos.y)
        BlzSetSpecialEffectZ(emitter, myPos.z)
        BlzSetSpecialEffectScale(emitter, 3)
        local tarPos = Vector3.new(data.x, data.y)
        local dir = (tarPos - myPos):SetNormalize()
        local curr = myPos + dir
        local lightning = AddLightningEx("SPLK", false, myPos.x, myPos.y, myPos.z, curr.x, curr.y, curr:GetTerrainZ())
        SetLightningColor(lightning, 1, 0.5, 0.5, 1)
        local travelled = 0
        local i = 0
        local p1 = myPos:Clone()
        local casterPlayer = GetOwningPlayer(data.caster)

        local function run(value)
            curr = p1 + dir * value
            MoveLightningEx(lightning, false, myPos.x, myPos.y, myPos.z, curr.x, curr.y, curr:GetTerrainZ())
            ExAddSpecialEffect("Abilities/Weapons/FireBallMissile/FireBallMissile.mdl", curr.x, curr.y, 0.0)
            aoeDamage(data.caster, curr.x, curr.y, 100, damaged1)

            local currIndex = math.floor(value / 50)
            while i <= currIndex do
                local cx, cy = curr.x, curr.y
                local tm = Timer.new(function()
                    ExAddSpecialEffect("Abilities/Weapons/Mortar/MortarMissile.mdl", cx, cy, 0.0)
                    aoeDamage(data.caster, cx, cy, 500, damaged2)
                end, 0.7, 1)
                tm:Start()
                i = i + 1
            end
        end

        local tween = Tween.To(function()
            return travelled
        end, run, 2400, 2, Tween.Type.InQuint)
        local nearTargets = ExGroupGetUnitsInRange(myPos.x, myPos.y, 1500)
        table.iFilterInPlace(nearTargets, function(item)
            if ExIsUnitDead(item) then
                return false
            end
            if IsUnitAlly(item, casterPlayer) then
                return false
            end
            if IsUnit(item, data.caster) then
                return false
            end
            return true
        end)
        if #nearTargets > 0 then
            local refPos = Vector2.FromUnit(data.caster)
            local v2Dir = (Vector2.new(data.x, data.y) - refPos):SetNormalize()
            table.sort(nearTargets, function(a, b)
                local da = (Vector2.FromUnit(a) - refPos):SetNormalize()
                local db = (Vector2.FromUnit(b) - refPos):SetNormalize()
                return math.abs(Vector2.Dot(v2Dir, da)) < math.abs(Vector2.Dot(v2Dir, db))
            end)
            local firstTarget = nearTargets[1]
            tween:AppendCallback(function()
                travelled = 0
                p1 = curr:Clone()
                dir = (Vector3.FromUnit(firstTarget) - p1):SetNormalize()
                damaged1 = {}
                damaged2 = {}
                i = 0
            end)
            tween = tween:Append(Tween.To(function()
                return travelled
            end, run, 2400, 2, Tween.Type.InQuint, true))
        end
        tween:AppendCallback(function()
            DestroyEffect(emitter)
            DestroyLightning(lightning)
        end)
    end
})

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
            string.formatPercentage(Meta.DamageScale[i]), string.formatPercentage(Meta.HealingDecrease), Meta.Duration[i]),
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

__modules["Ability.NativeRejuvenation"]={loader=function()
local EventCenter = require("Lib.EventCenter")

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = FourCC("Arej"),
    ---@param data ISpellData
    handler = function(data)
        coroutine.start(function()
            for _ = 1, 12 do
                coroutine.wait(1)
                if not ExIsUnitDead(data.target) then
                    EventCenter.Heal:Emit({
                        caster = data.caster,
                        target = data.target,
                        amount = 33.333,
                    })
                else
                    break
                end
            end
        end)
    end
})

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
    DamageScale = 2,
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

__modules["Ability.PassiveDamageWithImpaleVisuals"]={loader=function()
local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local BuffBase = require("Objects.BuffBase")
local BloodPlague = require("Ability.BloodPlague")
local FrostPlague = require("Ability.FrostPlague")
local UnholyPlague = require("Ability.UnholyPlague")

--region meta

local Meta = {
    ID = FourCC("A01J"),
    Chance = 0.2,
    Damage = 400,
}

Abilities.PassiveDamageWithImpaleVisuals = Meta

--endregion

local cls = class("PassiveDamageWithImpaleVisuals")

EventCenter.RegisterPlayerUnitDamaged:Emit(function(caster, target, _, _, _, isAttack)
    if not isAttack then
        return
    end

    if target == nil or IsUnitType(target, UNIT_TYPE_MECHANICAL) or IsUnitType(target, UNIT_TYPE_STRUCTURE) then
        return
    end

    local abilityLevel = GetUnitAbilityLevel(caster, Meta.ID)
    if abilityLevel < 1 then
        return
    end

    if math.random() >= Meta.Chance then
        return
    end

    EventCenter.Damage:Emit({
        whichUnit = caster,
        target = target,
        amount = Meta.Damage,
        attack = false,
        ranged = false,
        attackType = ATTACK_TYPE_HERO,
        damageType = DAMAGE_TYPE_NORMAL,
        weaponType = WEAPON_TYPE_WHOKNOWS,
        outResult = {}
    })

    local v = Vector2.FromUnit(target)
    local sfx = ExAddSpecialEffect("Abilities/Spells/Undead/Impale/ImpaleMissTarget.mdl", v.x, v.y, 1)
    BlzSetSpecialEffectScale(sfx, 2)
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

__modules["Ability.ResetSanity"]={loader=function()
local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local BuffBase = require("Objects.BuffBase")
local FesteringWound = require("Ability.FesteringWound")
local UnitAttribute = require("Objects.UnitAttribute")
local Vector2 = require("Lib.Vector2")

--region meta

local Meta = {
    Sanity = 100,
}

--endregion

local cls = class("ResetSanity")

function cls.Execute(caster)
    local casterPlayer = GetOwningPlayer(caster)
    ExGroupEnumUnitsInMap(function(unit)
        if IsUnitEnemy(unit, casterPlayer) and not ExIsUnitDead(unit) then
            local attr = UnitAttribute.GetAttr(unit)
            attr.sanity = Meta.Sanity
        end
    end)
end

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

__modules["Ability.SaraAnger"]={loader=function()
local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local BuffBase = require("Objects.BuffBase")
local ProjectileBase = require("Objects.ProjectileBase")
local FesteringWound = require("Ability.FesteringWound")
local Const = require("Config.Const")
local UnitAttribute = require("Objects.UnitAttribute")

--region meta

local Meta = {
    ID = FourCC("A01N"),
    Duration = 9,
    Interval = 3,
    DOT = 200,
    Attack = 100,
}

Abilities.SaraAnger = Meta

--endregion

---@class SaraAnger : BuffBase
local cls = class("SaraAnger", BuffBase)

function cls:OnEnable()
    --self.sfx = AddSpecialEffectTarget("Abilities/Spells/Items/StaffOfSanctuary/Staff_Sanctuary_Target.mdl", self.target, "overhead")
    local attr = UnitAttribute.GetAttr(self.target)
    attr.atk = attr.atk + Meta.Attack
    attr:Commit()
    --table.insert(attr.absorbShields, self)
end

function cls:Update()
    EventCenter.Damage:Emit({
        whichUnit = self.caster,
        target = self.target,
        amount = Meta.DOT,
        attack = false,
        ranged = true,
        attackType = ATTACK_TYPE_HERO,
        damageType = DAMAGE_TYPE_NORMAL,
        weaponType = WEAPON_TYPE_WHOKNOWS,
        outResult = {}
    })
end

function cls:OnDisable()
    --DestroyEffect(self.sfx)
    local attr = UnitAttribute.GetAttr(self.target)
    attr.atk = attr.atk - Meta.Attack
    attr:Commit()
end

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        local debuff = BuffBase.FindBuffByClassName(data.target, cls.__cname)
        if debuff then
            debuff:ResetDuration()
        else
            debuff = cls.new(data.caster, data.target, Meta.Duration, Meta.Interval, {})
        end
    end
})

return cls

end}

__modules["Ability.SaraBlessings"]={loader=function()
local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local BuffBase = require("Objects.BuffBase")
local ProjectileBase = require("Objects.ProjectileBase")
local FesteringWound = require("Ability.FesteringWound")
local Const = require("Config.Const")
local UnitAttribute = require("Objects.UnitAttribute")

--region meta

local Meta = {
    ID = FourCC("A01N"),
    Heal = 300,
    Duration = 6,
    Interval = 1,
    DOT = 100,
}

Abilities.SaraBlessings = Meta

--endregion

---@class SaraBlessings : BuffBase
local cls = class("SaraBlessings", BuffBase)

function cls:OnEnable()
    --self.sfx = AddSpecialEffectTarget("Abilities/Spells/Items/StaffOfSanctuary/Staff_Sanctuary_Target.mdl", self.target, "overhead")
    --local attr = UnitAttribute.GetAttr(self.target)
    --table.insert(attr.absorbShields, self)
end

function cls:Update()
    EventCenter.Damage:Emit({
        whichUnit = self.caster,
        target = self.target,
        amount = Meta.DOT,
        attack = false,
        ranged = true,
        attackType = ATTACK_TYPE_HERO,
        damageType = DAMAGE_TYPE_NORMAL,
        weaponType = WEAPON_TYPE_WHOKNOWS,
        outResult = {}
    })
end

function cls:OnDisable()
    --DestroyEffect(self.sfx)
end

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        EventCenter.Heal:Emit({
            caster = data.caster,
            target = data.target,
            amount = Meta.Heal,
        })
        local debuff = BuffBase.FindBuffByClassName(data.target, cls.__cname)
        if debuff then
            debuff:ResetDuration()
        else
            debuff = cls.new(data.caster, data.target, Meta.Duration, Meta.Interval, {})
        end
    end
})

return cls

end}

__modules["Ability.SaraFever"]={loader=function()
local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local BuffBase = require("Objects.BuffBase")
local ProjectileBase = require("Objects.ProjectileBase")
local FesteringWound = require("Ability.FesteringWound")
local Const = require("Config.Const")
local UnitAttribute = require("Objects.UnitAttribute")

--region meta

local Meta = {
    ID = FourCC("A01N"),
    Duration = 10,
    DamageDealt = 0.2,
    DamageReduction = -1,
}

Abilities.SaraFever = Meta

--endregion

---@class SaraFever : BuffBase
local cls = class("SaraFever", BuffBase)

function cls:OnEnable()
    --self.sfx = AddSpecialEffectTarget("Abilities/Spells/Items/StaffOfSanctuary/Staff_Sanctuary_Target.mdl", self.target, "overhead")
    local attr = UnitAttribute.GetAttr(self.target)
    attr.damageAmplification = attr.damageAmplification + Meta.DamageDealt
    attr.damageReduction = attr.damageReduction + Meta.DamageReduction
    --table.insert(attr.absorbShields, self)
end

function cls:Update()
    --EventCenter.Damage:Emit({
    --    whichUnit = self.caster,
    --    target = self.target,
    --    amount = Meta.DOT,
    --    attack = false,
    --    ranged = true,
    --    attackType = ATTACK_TYPE_HERO,
    --    damageType = DAMAGE_TYPE_NORMAL,
    --    weaponType = WEAPON_TYPE_WHOKNOWS,
    --    outResult = {}
    --})
end

function cls:OnDisable()
    --DestroyEffect(self.sfx)
    local attr = UnitAttribute.GetAttr(self.target)
    attr.damageAmplification = attr.damageAmplification - Meta.DamageDealt
    attr.damageReduction = attr.damageReduction - Meta.DamageReduction
end

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        local debuff = BuffBase.FindBuffByClassName(data.target, cls.__cname)
        if debuff then
            debuff:ResetDuration()
        else
            debuff = cls.new(data.caster, data.target, Meta.Duration, 9999, {})
        end
    end
})

return cls

end}

__modules["Ability.SaraGreenCloud"]={loader=function()
local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local BuffBase = require("Objects.BuffBase")
local ProjectileBase = require("Objects.ProjectileBase")
local FesteringWound = require("Ability.FesteringWound")
local Const = require("Config.Const")
local UnitAttribute = require("Objects.UnitAttribute")
local Vector2 = require("Lib.Vector2")
local Timer = require("Lib.Timer")

--region meta

local Meta = {
    ID = FourCC("A01N"),
    Duration = 9,
    Interval = 3,
    DOT = 200,
    Attack = 100,
    InstanceCount = 2,
    AngleSpeed = math.pi * 2 / 36,
    UTIDCloud = FourCC("u000"),
    UTIDFacelessOne = FourCC("u000"),
    AutoGenCD = 10,
    ActiveTriggerCD = 3,
    AOESpawn = 256,
    AOEDamage = 450,
    DamageAmount = 299,
}

Abilities.SaraGreenCloud = Meta

--endregion

---@class SaraGreenCloud
local cls = class("SaraGreenCloud")

cls.instances = {} ---@type SaraGreenCloud[]
cls.timer = nil ---@type Timer

function cls.update(dt)
    for _, v in ipairs(cls.instances) do
        v.dir:RotateSelf(Meta.AngleSpeed * dt)
        local pos = v.center + v.dir
        BlzSetSpecialEffectPosition(v.cloud, pos.x, pos.y, pos:GetTerrainZ())

        v.cdAutoGen = v.cdAutoGen - dt
        v.cdActiveTrigger = v.cdActiveTrigger - dt

        if v.cdAutoGen <= 0 then
            v.cdAutoGen = Meta.AutoGenCD
            v:spawn(pos)
        elseif v.cdActiveTrigger <= 0 then
            local casterFaction = GetOwningPlayer(v.caster)
            local units = ExGroupGetUnitsInRange(pos.x, pos.y, Meta.AOESpawn, function(unit)
                return not ExIsUnitDead(unit) and IsUnitEnemy(unit, casterFaction)
            end)
            if #units > 0 then
                v.cdAutoGen = Meta.AutoGenCD
                v.cdActiveTrigger = Meta.ActiveTriggerCD
                v:spawn(pos)
            end
        end
    end
end

---@param center Vector2
---@param dir Vector2
---@param caster unit
function cls:ctor(center, dir, caster)
    self.center = center
    self.dir = dir
    self.caster = caster

    local pos = self.center + self.dir
    self.cloud = AddSpecialEffect("Units/Undead/PlagueCloud/PlagueCloudtarget.mdl", pos.x, pos.y)

    self.cdActiveTrigger = 0
    self.cdAutoGen = Meta.AutoGenCD
end

function cls:spawn(pos)
    -- play sfx
    local casterPlayer = GetOwningPlayer(self.caster)
    local spawned = CreateUnit(casterPlayer, Meta.UTIDFacelessOne, pos.x, pos.y, math.random() * 360)
end

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        local vo = Vector2.FromUnit(data.caster)
        local v1 = Vector2.new(900, 0)
        for i = 1, Meta.InstanceCount do
            local dir = v1:Rotate((i - 1) * math.pi * 2 / Meta.InstanceCount)
            local inst = cls.new(vo, dir, data.caster)
            table.insert(cls.instances, inst)
        end
        if #cls.instances > 0 then
            if cls.timer == nil then
                cls.timer = Timer.new(cls.update, Time.Delta, -1)
                cls.timer:Start()
            end
        end
    end
})

ExTriggerRegisterUnitDeath(function(unit)
    local utid = GetUnitTypeId(unit)
    if utid == Meta.UTIDFacelessOne then
        local p = Vector2.FromUnit(unit)
        -- sfx

        ExGroupEnumUnitsInRange(p.x, p.y, Meta.AOEDamage, function(v)
            if not IsUnit(unit, v) then
                EventCenter.Damage:Emit({
                    whichUnit = unit,
                    target = v,
                    amount = Meta.DamageAmount,
                    attack = false,
                    ranged = true,
                    attackType = ATTACK_TYPE_CHAOS,
                    damageType = DAMAGE_TYPE_DIVINE,
                    weaponType = WEAPON_TYPE_WHOKNOWS,
                    outResult = {}
                })
            end
        end)
    end
end)

return cls

end}

__modules["Ability.ShadowBolt"]={loader=function()
local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local BuffBase = require("Objects.BuffBase")
local ProjectileBase = require("Objects.ProjectileBase")
local FesteringWound = require("Ability.FesteringWound")
local Const = require("Config.Const")

--region meta

local Meta = {
    ID = FourCC("A01L"),
    Damage = 400,
    HitRange = 20,
}

Abilities.ShadowBolt = Meta

--endregion

local cls = class("ShadowBolt")

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        ProjectileBase.new(data.caster, data.target, "Abilities/Weapons/AvengerMissile/AvengerMissile.mdl", 600, function()
            EventCenter.Damage:Emit({
                whichUnit = data.caster,
                target = data.target,
                amount = Meta.Damage,
                attack = false,
                ranged = true,
                attackType = ATTACK_TYPE_HERO,
                damageType = DAMAGE_TYPE_NORMAL,
                weaponType = WEAPON_TYPE_WHOKNOWS,
                outResult = {}
            })
        end, nil)
    end
})

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
                local distance = math.max(v3:Magnitude() - 96, 0)
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

__modules["Ability.SleepWalk"]={loader=function()
local Vector2 = require("Lib.Vector2")
local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
--local Tween = require("Lib.Tween")
local Utils = require("Lib.Utils")
local Tween = require("Lib.Tween")

local cls = class("SleepWalk")

local Meta = {
    ID = FourCC("A01F"),
    EveryYards = 100,
    ManaRestore = 350,
    Speed = 50,
    MaxDuration = 10,
}

Abilities.SleepWalk = Meta

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        coroutine.start(function()
            PauseUnit(data.target, true)
            SetUnitPathing(data.target, false)
            --SetUnitAnimationByIndex(data.target, 0)

            ExAddSpecialEffectTarget("Abilities/Spells/Undead/Sleep/SleepSpecialArt.mdl", data.target, "overhead", 0.1)
            local sfx = AddSpecialEffectTarget("Abilities/Spells/Undead/Sleep/SleepTarget.mdl", data.target, "overhead")
            Utils.SetUnitFlyable(data.target)
            local originalHeight = GetUnitFlyHeight(data.target)
            local newHeight = originalHeight + 100
            Tween.To(function() return originalHeight end, function(value) SetUnitFlyHeight(data.target, value, 0) end, newHeight, 0.3)
            local sfx2 = AddSpecialEffectTarget("Abilities/Spells/NightElf/TargetArtLumber/TargetArtLumber.mdl", data.target, "foot")

            local travelled = 0
            local timeStart = Time.Time
            local frames = 0
            while true do
                coroutine.step()
                frames = frames + 1
                local dest = Vector2.FromUnit(data.caster)
                local curr = Vector2.FromUnit(data.target)
                local dir = (dest - curr):SetNormalize()
                local stepLen = Meta.Speed * Time.Delta

                --if frames % 9 == 0 then
                --    local shade = AddSpecialEffect("units/nightelf/MountainGiant/MountainGiant.mdl", curr.x, curr.y)
                --    BlzSetSpecialEffectYaw(shade, GetUnitFacing(data.target) * bj_DEGTORAD)
                --    local alpha = 1
                --    Tween.To(function()
                --        return alpha
                --    end, function(value)
                --        BlzSetSpecialEffectAlpha(shade, math.floor(value * 255))
                --    end, 0, 1)
                --end

                curr:Add(dir * stepLen):UnitMoveTo(data.target)
                SetUnitFacing(data.target, math.atan2(dir.y, dir.x) * bj_RADTODEG)
                travelled = travelled + stepLen
                if travelled >= Meta.EveryYards then
                    travelled = travelled - Meta.EveryYards
                    EventCenter.HealMana:Emit({
                        caster = data.caster,
                        target = data.caster,
                        amount = Meta.ManaRestore,
                        isPercentage = false
                    })
                    ExAddSpecialEffectTarget("Abilities/Spells/Items/AIma/AImaTarget.mdl", data.caster, "origin", 1)
                end
                if curr:Sub(dest):Magnitude() < 96 or (Time.Time - timeStart) > Meta.MaxDuration then
                    break
                end
            end

            Tween.To(function() return newHeight end, function(value) SetUnitFlyHeight(data.target, value, 0) end, originalHeight, 0.3)
            DestroyEffect(sfx)
            DestroyEffect(sfx2)
            PauseUnit(data.target, false)
            SetUnitPathing(data.target, true)
        end)
    end
})

return cls

end}

__modules["Ability.SoulSiphon"]={loader=function()
local Vector2 = require("Lib.Vector2")
local EventCenter = require("Lib.EventCenter")
local Timer = require("Lib.Timer")
local Pill = require("Lib.Pill")
local Circle = require("Lib.Circle")
local UnitAttribute = require("Objects.UnitAttribute")
local Abilities = require("Config.Abilities")

local cls = class("SoulSiphon")

local Meta = {
    ID = FourCC("A01K"),
    Damage = 150,
}

Abilities.SoulSiphon = Meta

local instances = {}

function cls:ctor(caster, target)
    self.lightning, self.lightningCo = ExAddLightningUnitUnit("DRAM", caster, target, 9999, { r = 1, g = 0, b = 1, a = 1 }, false)
    local function exec()
        if ExIsUnitDead(target) then
            self:stop()
            return
        end

        EventCenter.Damage:Emit({
            whichUnit = caster,
            target = target,
            amount = Meta.Damage,
            attack = false,
            ranged = true,
            attackType = ATTACK_TYPE_HERO,
            damageType = DAMAGE_TYPE_DIVINE,
            weaponType = WEAPON_TYPE_WHOKNOWS,
            outResult = {},
        })
    end
    exec()
    self.timer = Timer.new(exec, 1, -1)
    self.timer:Start()
end

function cls:stop()
    self.timer:Stop()
    coroutine.stop(self.lightningCo)
    DestroyLightning(self.lightning)
end

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        if instances[data.caster] then
            instances[data.caster]:stop()
        end
        instances[data.caster] = cls.new(data.caster, data.target)
    end
})

EventCenter.RegisterPlayerUnitSpellEndCast:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        local inst = instances[data.caster]
        if inst then
            inst:stop()
            instances[data.caster] = nil
        else
            print("SoulSiphon end but no instance")
        end
    end
})

ExTriggerRegisterUnitDeath(function(unit)

end)

return cls

end}

__modules["Ability.TimeWarp"]={loader=function()
local EventCenter = require("Lib.EventCenter")
local Timer = require("Lib.Timer")
local PILQueue = require("Lib.PILQueue")
local Abilities = require("Config.Abilities")

local cls = class("TimeWarp")

local Meta = {
    ID = FourCC("A01G"),
    ClockID = FourCC("e002"),
    Duration = 5,
    Radius = 600,
    ReverseSpeed = 5,
}

local queueSize = Meta.Duration / Time.Delta / Meta.ReverseSpeed
local reversing = {}
local recordingUnits = {}

Abilities.TimeWarp = Meta

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        local casterPlayer = GetOwningPlayer(data.caster)

        local clock = CreateUnit(casterPlayer, Meta.ClockID, data.x, data.y, 0)
        SetUnitAnimation(clock, "Stand Alternate")
        SetUnitTimeScale(clock, 10 / Meta.Duration)
        coroutine.start(function()
            coroutine.wait(Meta.Duration)
            SetUnitAnimation(clock, "Death")
            KillUnit(clock)
        end)

        reversing = {}
        coroutine.start(function()
            local units = ExGroupGetUnitsInRange(data.x, data.y, Meta.Radius)
            for i = #units, 1, -1 do
                local u = units[i]
                if IsUnit(u, data.caster) then
                    table.remove(units, i)
                else
                    reversing[u] = true
                end
            end
            local affectedUnits = {}
            while #units > 0 do
                coroutine.step()
                for i = #units, 1, -1 do
                    local u = units[i]
                    local q = recordingUnits[u]
                    if not q then
                        table.remove(units, i)
                    else
                        local d = q:peekright()
                        if d then
                            q:popright()
                            if IsUnitAlly(u, casterPlayer) then
                                local nowDead = ExIsUnitDead(u)
                                if nowDead and not d.dead then
                                    -- revive
                                    local revived = CreateUnit(GetOwningPlayer(u), GetUnitTypeId(u), d.x, d.y, d.f)
                                    SetWidgetLife(revived, d.hp)
                                    ExSetUnitMana(revived, d.mp)
                                    recordingUnits[revived] = q
                                    recordingUnits[u] = nil
                                    reversing[revived] = true
                                    units[i] = revived
                                elseif not nowDead and not d.dead then
                                    SetUnitPosition(u, d.x, d.y)
                                    affectedUnits[u] = true
                                    SetUnitFacing(u, d.f)
                                    SetWidgetLife(u, d.hp)
                                    ExSetUnitMana(u, d.mp)
                                end
                            else
                                if not ExIsUnitDead(u) then
                                    SetUnitPosition(u, d.x, d.y)
                                    affectedUnits[u] = true
                                    SetUnitFacing(u, d.f)
                                else
                                    table.remove(units, i)
                                end
                            end
                        else
                            table.remove(units, i)
                        end
                    end
                end
            end
            for u, _ in pairs(affectedUnits) do
                EventCenter.DefaultOrder:Emit(u)
            end
            reversing = {}
        end)
    end
})

ExTriggerRegisterNewUnit(function(unit)
    if (BlzBitAnd(GetUnitPointValue(unit), 1)) ~= 1 then
        recordingUnits[unit] = PILQueue.new(queueSize)
    end
end)

local decayTrigger = CreateTrigger()
TriggerRegisterAnyUnitEventBJ(decayTrigger, EVENT_PLAYER_UNIT_DECAY)
ExTriggerAddAction(decayTrigger, function()
    recordingUnits[GetDecayingUnit()] = nil
end)

local tm = Timer.new(function()
    for unit, q in pairs(recordingUnits) do
        if not reversing[unit] then
            q:pushright({
                x = GetUnitX(unit),
                y = GetUnitY(unit),
                f = GetUnitFacing(unit),
                hp = GetWidgetLife(unit),
                mp = ExGetUnitMana(unit),
                dead = ExIsUnitDead(unit),
            })
        end
    end
end, Time.Delta * Meta.ReverseSpeed, -1)
tm:Start()

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

__modules["AI.DBM.YoggSaron"]={loader=function()
---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by nef.
--- DateTime: 12/8/2022 11:15 PM
---

local cls = {}

return cls

end}

__modules["AI.MoonGlade"]={loader=function()
local Vector2 = require("Lib.Vector2")
local Timer = require("Lib.Timer")
local Const = require("Config.Const")
local EventCenter = require("Lib.EventCenter")
local Event = require("Lib.Event")

EventCenter.DefaultOrder = Event.new()

local MyBase = Vector2.new(4022, 4110)
local EnemyBase = Vector2.new(-4248, -5806)
local MyPlayer = Player(0)
local EnemyPlayer = Player(3)

local Interval = 30
local DefaultOrder = {}

local MyArmy = {
    { [FourCC("earc")] = 4 },
    { [FourCC("esen")] = 4 },
    { [FourCC("earc")] = 4, [FourCC("esen")] = 2 },
    { [FourCC("esen")] = 2, [FourCC("ebal")] = 2 },
    { [FourCC("earc")] = 2, [FourCC("esen")] = 4 },
    { [FourCC("edry")] = 4 },
    { [FourCC("edoc")] = 4 },
    { [FourCC("earc")] = 4, [FourCC("edoc")] = 2 },
    { [FourCC("earc")] = 6 },
}

local EnemyArmy = {
    { [FourCC("nfel")] = 4 },
    { [FourCC("nfel")] = 4, [FourCC("nbal")] = 1 },
    { [FourCC("nfel")] = 4, [FourCC("nvde")] = 1 },
    { [FourCC("nfel")] = 6, [FourCC("nbal")] = 1 },
    { [FourCC("nfel")] = 6, [FourCC("ninf")] = 1 },
    { [FourCC("nfel")] = 6, [FourCC("nbal")] = 1 },
    { [FourCC("nfel")] = 8, [FourCC("ndqs")] = 1 },
    { [FourCC("nfel")] = 8, [FourCC("nbal")] = 1 },
    { [FourCC("nfel")] = 8, [FourCC("nerw")] = 1 },
}

local cls = class("MoonGlade")

function cls:ctor()
    local index = 1
    local function spawn()
        local myArmy = MyArmy[math.clamp(index, 1, #MyArmy)]
        for utid, count in pairs(myArmy) do
            for _ = 1, count do
                local u = CreateUnit(MyPlayer, utid, MyBase.x, MyBase.y, 0)
                IssuePointOrderById(u, Const.OrderId_Attack, EnemyBase.x, EnemyBase.y)
                DefaultOrder[u] = { Const.OrderId_Attack, EnemyBase.x, EnemyBase.y }
            end
        end
        local enemyArmy = EnemyArmy[math.clamp(index, 1, #EnemyArmy)]
        for utid, count in pairs(enemyArmy) do
            for _ = 1, count do
                local u = CreateUnit(EnemyPlayer, utid, EnemyBase.x, EnemyBase.y, 0)
                IssuePointOrderById(u, Const.OrderId_Attack, MyBase.x, MyBase.y)
                DefaultOrder[u] = { Const.OrderId_Attack, MyBase.x, MyBase.y }
            end
        end
        index = index + 1
    end
    spawn()
    Timer.new(spawn, Interval, -1):Start()

    local hero = CreateUnit(MyPlayer, FourCC("E001"), MyBase.x, MyBase.y, 0)
    --ExTriggerRegisterUnitDeath(function(unit)
    --    if GetUnitTypeId(unit) == FourCC("nbal") then
    --        SetHeroLevel(hero, GetHeroLevel(hero) + 1, true)
    --    end
    --end)

    EventCenter.DefaultOrder:On(self, cls.onDefaultOrder)
end

function cls:Update()
end

function cls:onDefaultOrder(unit)
    local order = DefaultOrder[unit]
    if not order then
        return
    end
    IssuePointOrderById(unit, order[1], order[2], order[3])
end

return cls

end}

__modules["AI.TwistedMeadows"]={loader=function()
local Vector2 = require("Lib.Vector2")

local basePos = Vector2.new(-3202, 4121)
local Interval = 10
local p1 = Player(1)
local TrainCount = 3

local UTID_Archer = FourCC("earc")
local UTID_Huntress = FourCC("esen")
local UTID_Dryad = FourCC("edry")
local UTID_Ballista = FourCC("ebal")
local UTID_Chimaera = FourCC("echm")
local UTID_Druid = FourCC("edoc")

local Army = {
    [UTID_Druid] = 4, -- 16
    [UTID_Ballista] = 2, -- 6
    [UTID_Huntress] = 3, -- 15
    [UTID_Archer] = 7, -- 8
}

local cls = class("TwistedMeadows")

function cls:ctor()
    self.time = 0
    self.army = {}

    ExTriggerRegisterNewUnit(function(unit)
        if ExGetUnitPlayerId(unit) == 1 then
            table.addNum(self.army, GetUnitTypeId(unit), 1)
        end
    end)

    ExTriggerRegisterUnitDeath(function(unit)
        if ExGetUnitPlayerId(unit) == 1 then
            table.addNum(self.army, GetUnitTypeId(unit), -1)
        end
    end)
end

function cls:Update(dt)
    self.time = self.time + dt
    if self.time >= Interval then
        self.time = self.time % Interval
        self:run()
    end
end

function cls:run()
    if Time.Time < 360 then
        return
    end
    local trained = TrainCount
    for utid, maxSize in pairs(Army) do
        local current = self.army[utid] or 0
        local diff = maxSize - current
        if diff > 0 then
            local train = math.min(diff, trained)
            for _ = 1, train do
                CreateUnit(p1, utid, basePos.x, basePos.y, 0)
            end
            trained = trained - train
        end

        if trained <= 0 then
            break
        end
    end

    if Time.Time > 300 and trained <= 0 then
        Interval = Interval + 0.4
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
    return dir:Magnitude() <= self.r
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

local function trueFilter()
    return true
end

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
---@param filter fun(unit: unit): boolean
---@return unit[]
function ExGroupGetUnitsInRange(x, y, radius, filter)
    filter = filter or trueFilter
    GroupClear(group)
    local units = {}
    GroupEnumUnitsInRange(group, x, y, radius, Filter(function()
        local f = GetFilterUnit()
        local s, m = pcall(filter, f)
        if not s then
            print(m)
            return false
        end
        if m then
            t_insert(units, f)
        end
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
    local sfx = AddSpecialEffect(modelName, x, y)
    c_start(function()
        if color then
            BlzSetSpecialEffectColor(sfx, m_round(color.r * 255), m_round(color.g * 255), m_round(color.b * 255))
        end
        c_wait(duration)
        DestroyEffect(sfx)
    end)
    return sfx
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
    checkVisibility = checkVisibility or false
    local lightning = AddLightningEx(modelName, checkVisibility,
            GetUnitX(unit1), GetUnitY(unit1), BlzGetUnitZ(unit1) + GetUnitFlyHeight(unit1),
            GetUnitX(unit2), GetUnitY(unit2), BlzGetUnitZ(unit2) + GetUnitFlyHeight(unit2))
    if color then
        SetLightningColor(lightning, color.r, color.g, color.b, color.a)
    end
    local co = c_start(function()
        local expr = Time.Time + duration
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
    return lightning, co
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

__modules["Lib.Pill"]={loader=function()
---@class Pill
local cls = class("Pill")

---@param p1 Vector2
---@param p2 Vector2
---@param r real
function cls:ctor(p1, p2, r)
    self.p1 = p1
    self.p2 = p2
    self.r = r
end

---胶囊碰撞
---@param c1 Pill
---@param c2 Pill
---@return boolean
function cls.PillPill(c1, c2)
    local _caps = { c1, c2 }
    local rs = (c1.r + c2.r) * (c1.r + c2.r)
    for i = 1, 2 do
        local ii = i + 1
        if ii == 3 then
            ii = 1
        end
        local _vw = _caps[ii].p2 - _caps[ii].p1
        local vws2 = _vw:MagnitudeSqr()
        local _ps = { _caps[i].p1, _caps[i].p2 }
        for _, p in ipairs(_ps) do
            local t = math.clamp01(Vector2.Dot(p - _caps[ii].p1, _vw) / vws2)
            local _proj = _vw * t + _caps[ii].p1
            local dist = (_proj - p):MagnitudeSqr()
            if dist <= rs then
                return true
            end
        end
    end
    local _v1 = c1.p2 - c1.p1
    local _v2 = c2.p2 - c2.p1
    local _vw = c2.p1 - c1.p1
    local d = Vector2.Cross(_v1, _v2)
    local v = Vector2.Cross(_vw, _v1) / d
    local n = Vector2.Cross(_vw, _v2) / d
    if n >= 0 and n <= 1 and v >= 0 and v <= 1 then
        return true
    end
    return false
end

---@param capsule Pill
---@param circle Circle
function cls.PillCircle(capsule, circle)
    local rs = (capsule.r + circle.r) * (capsule.r + circle.r)
    local _vw = capsule.p2 - capsule.p1
    local vws2 = _vw:MagnitudeSqr()
    local t = math.clamp01(Vector2.Dot(circle.center - capsule.p1, _vw) / vws2)
    local _proj = _vw * t + capsule.p1
    if (_proj - circle.center):MagnitudeSqr() <= rs then
        return true
    else
        return false
    end
end

return cls

end}

__modules["Lib.PILQueue"]={loader=function()
-- https://www.lua.org/pil/11.4.html
local cls = class("PILQueue")

function cls:ctor(cap)
    self.cap = cap
    self.first = 0
    self.last = -1
end

function cls:pushleft(value)
    local first = self.first - 1
    self.first = first
    self[first] = value
    if self.cap and self:size() > self.cap then
        self:popright()
    end
end

function cls:pushright(value)
    local last = self.last + 1
    self.last = last
    self[last] = value
    if self.cap and self:size() > self.cap then
        self:popleft()
    end
end

function cls:popleft()
    local first = self.first
    if first > self.last then
        error("queue is empty")
    end
    local value = self[first]
    self[first] = nil -- to allow garbage collection
    self.first = first + 1
    return value
end

function cls:popright()
    local last = self.last
    if self.first > last then
        error("self is empty")
    end
    local value = self[last]
    self[last] = nil -- to allow garbage collection
    self.last = last - 1
    return value
end

function cls:peekleft()
    return self[self.first]
end

function cls:peekright()
    return self[self.last]
end

function cls:size()
    return self.last - self.first + 1
end

function cls:tostring()
    local sb = ""
    for i = self.first, self.last do
        sb = sb .. tostring(self[i]) .. " "
    end
    sb = sb .. "size:" .. self:size()
    return sb
end

return cls

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
    return tab ~= nil and next(tab) ~= nil
end

function table.getOrCreateTable(tab, key)
    if key == nil then
        print(GetStackTrace())
    end
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

---@generic V
---@param tab V[]
---@param filter fun(item: V): boolean
---@return V[] removed items
function table.iFilterInPlace(tab, filter)
    local ret = {}
    local c = #tab
    local i = 1
    local d = 0
    while i <= c do
        local it = tab[i]
        if filter(it) then
            if d > 0 then
                tab[i - d] = it
            end
        else
            t_insert(ret, it)
            d = d + 1
        end
        i = i + 1
    end
    for j = 0, d - 1 do
        tab[c - j] = nil
    end
    return ret
end

function table.iRemoveOneRight(tab, item)
    for i = #tab, 1, -1 do
        if tab[i] == item then
            table.remove(tab, i)
            return true
        end
    end
    return false
end

function table.iRemoveOneLeft(tab, item)
    for i = 1, #tab do
        if tab[i] == item then
            table.remove(tab, i)
            return true
        end
    end
    return false
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

---@class Timer
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

__modules["Lib.Tween"]={loader=function()
local Timer = require("Lib.Timer")
local Time = require("Lib.Time")

local cls = class("Tween")

cls.Type = {
    Linear = 1,
    InQuint = 2,
}

cls.NextType = {
    Function = 1,
    Tween = 2,
}

local funcMap = {
    [cls.Type.Linear] = function(t)
        return t
    end,
    [cls.Type.InQuint] = function(t)
        return t * t * t * t
    end,
}

function cls:ctor()
    self.next = {}
end

function cls:AppendCallback(func)
    table.insert(self.next, {
        type = cls.NextType.Function,
        func = func,
    })
end

function cls:Append(tween)
    table.insert(self.next, {
        type = cls.NextType.Tween,
        tween = tween,
    })
    return tween
end

function cls:runOnStopCalls()
    for _, v in ipairs(self.next) do
        if v.type == cls.NextType.Function then
            v.func()
        elseif v.type == cls.NextType.Tween then
            v.tween.timer:Start()
        end
    end
end

---@param getter fun(): real
---@param setter fun(value: real): void
---@param target real
---@param duration real
---@param ease integer | Nil Tween.Type.*
function cls.To(getter, setter, target, duration, ease, dontStart)
    ease = ease or cls.Type.Linear
    local func = funcMap[ease]
    local frames = math.ceil(duration / Time.Delta)
    local t = 0
    local inst = cls.new()
    inst.timer = Timer.new(function()
        t = t + 1
        local c1 = getter()
        local value = c1 + (target - c1) * func(t / frames)
        setter(value)
    end, Time.Delta, frames)
    inst.timer:SetOnStop(function()
        inst:runOnStopCalls()
    end)
    if not dontStart then
        inst.timer:Start()
    end
    return inst
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
Vector2 = cls

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

function cls.Dot(a, b)
    return a.x * b.x + a.y * b.y
end

function cls.Cross(a, b)
    return a.y * b.x - a.x * b.y
end

function cls.UnitDistance(u1, u2)
    local v1 = cls.FromUnit(u1)
    local v2 = cls.FromUnit(u2)
    return v1:Sub(v2):Magnitude()
end

function cls.UnitDistanceSqr(u1, u2)
    local v1 = cls.FromUnit(u1)
    local v2 = cls.FromUnit(u2)
    return v1:Sub(v2):MagnitudeSqr()
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
    local magnitude = self:Magnitude()

    if magnitude > 1e-05 then
        self.x = self.x / magnitude
        self.y = self.y / magnitude
    else
        self.x = 0
        self.y = 0
    end

    return self
end

function cls:Normalized()
    return self:Clone():SetNormalize()
end

function cls:SetMagnitude(len)
    self:SetNormalize():Mul(len)
    return self
end

---@param angle real radians
function cls:RotateSelf(angle)
    local cos = math.cos(angle)
    local sin = math.sin(angle)
    local x = cos * self.x - sin * self.y
    local y = sin * self.x + cos * self.y
    self.x = x
    self.y = y
    return self
end

---@param angle real radians
function cls:Rotate(angle)
    return self:Clone():RotateSelf(angle)
end

function cls:Clone()
    return new(self.x, self.y)
end

function cls:GetTerrainZ()
    MoveLocation(cls._loc, self.x, self.y)
    return GetLocationZ(cls._loc)
end

function cls:Magnitude()
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

function cls:Set(x, y, z)
    self.x = x
    self.y = y
    self.z = z or getTerrainZ(x, y)
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
    local magnitude = self:Magnitude()

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

function cls:Magnitude()
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
        if unit == nil then
            print(GetStackTrace())
        end
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

    self.taunted = {} ---被嘲讽的目标
    self.absorbShields = {} ---吸收盾

    self.sanity = 0
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

function cls:TauntedBy(caster, duration)
    table.insert(self.taunted, caster)
    coroutine.start(function()
        coroutine.wait(duration)
        table.iRemoveOneLeft(self.taunted, caster)
    end)
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
---data {whichUnit=unit,target=unit,amount=real,attack=boolean,ranged=boolean,attackType=attacktype,damageType=damagetype,weaponType=weapontype,outResult=table}
EventCenter.Damage = Event.new()
---data: {caster=unit,target=unit,amount=real}
EventCenter.Heal = Event.new()
---{caster=caster,target=target,amount=amount,isPercentage=isPercentage}
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
        --print("Damage from native")
        if not isAttack then
            --print("not attack, skip")
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
        damage = damage * math.max(1 + a.damageAmplification - b.damageReduction, 0)

        -- shield
        local bas = b.absorbShields
        if table.any(bas) then
            while #bas > 0 and damage > 0 do
                local shieldBuff = bas[1]
                if shieldBuff.shield >= damage then
                    shieldBuff.shield = shieldBuff.shield - damage
                    damage = 0
                else
                    damage = damage - shieldBuff.shield
                    shieldBuff.shield = 0
                end
                if shieldBuff.shield <= 0 then
                    EventCenter.KillBuff:Emit(shieldBuff)
                    table.remove(bas, 1)
                end
            end
        end

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
    --print("DamageEvent:", GetUnitName(d.whichUnit), GetUnitName(d.target), d.amount, d.attack, d.ranged, d.attackType, d.damageType, d.weaponType)
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
    --print("DamageEvent-Native:", GetUnitName(d.whichUnit), GetUnitName(d.target), amount, d.attack, d.ranged, d.attackType, d.damageType, d.weaponType)
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
    require("Ability.GorefiendsGrasp")
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

    -- 默认 技能
    require("Ability.Evasion")
    require("Ability.MoonWellHeal")
    require("Ability.NativeRejuvenation")

    -- 武器战
    require("Ability.RageGenerator")
    require("Ability.DeepWounds")
    require("Ability.Overpower")
    require("Ability.Charge")
    require("Ability.MortalStrike")
    require("Ability.Condemn")
    require("Ability.BladeStorm")

    -- 唤魔师
    require("Ability.FireBreath")
    require("Ability.Disintegrate")
    require("Ability.SleepWalk")
    require("Ability.TimeWarp")
    require("Ability.MagmaBreath")

    -- 地穴领主
    require("Ability.PassiveDamageWithImpaleVisuals")

    -- 术士-克尔苏加德
    require("Ability.SoulSiphon")
    require("Ability.ShadowBolt")

    -- 牧师-希尔盖
    require("Ability.DarkHeal")
    require("Ability.DarkShield")
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
    -- table.insert(self.ais, require("AI.MoonGlade").new())
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

            if dest:Sub(curr):Magnitude() < 20 then
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
--lua-bundler:000219269

function InitGlobals()
end

function Unit000023_DropItems()
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
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000024_DropItems()
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

function Unit000026_DropItems()
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
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000028_DropItems()
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

function Unit000033_DropItems()
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

function Unit000037_DropItems()
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
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000044_DropItems()
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

function Unit000046_DropItems()
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

function Unit000049_DropItems()
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

function Unit000050_DropItems()
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
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000053_DropItems()
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

function Unit000054_DropItems()
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

function Unit000067_DropItems()
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
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 3), 100)
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

function CreateBuildingsForPlayer0()
local p = Player(0)
local u
local unitID
local t
local life

u = BlzCreateUnitWithSkin(p, FourCC("etoe"), 4032.0, 4096.0, 270.000, FourCC("etoe"))
u = BlzCreateUnitWithSkin(p, FourCC("emow"), 3168.0, 5344.0, 270.000, FourCC("emow"))
u = BlzCreateUnitWithSkin(p, FourCC("emow"), 3360.0, 5088.0, 270.000, FourCC("emow"))
u = BlzCreateUnitWithSkin(p, FourCC("emow"), 3488.0, 3616.0, 270.000, FourCC("emow"))
u = BlzCreateUnitWithSkin(p, FourCC("emow"), 3680.0, 3552.0, 270.000, FourCC("emow"))
u = BlzCreateUnitWithSkin(p, FourCC("emow"), 3936.0, 3488.0, 270.000, FourCC("emow"))
u = BlzCreateUnitWithSkin(p, FourCC("emow"), 2720.0, 4256.0, 270.000, FourCC("emow"))
u = BlzCreateUnitWithSkin(p, FourCC("emow"), 2720.0, 4512.0, 270.000, FourCC("emow"))
u = BlzCreateUnitWithSkin(p, FourCC("emow"), 3936.0, 5024.0, 270.000, FourCC("emow"))
u = BlzCreateUnitWithSkin(p, FourCC("emow"), 4512.0, 4640.0, 270.000, FourCC("emow"))
u = BlzCreateUnitWithSkin(p, FourCC("emow"), 4640.0, 4384.0, 270.000, FourCC("emow"))
u = BlzCreateUnitWithSkin(p, FourCC("eaom"), 2816.0, 4800.0, 270.000, FourCC("eaom"))
u = BlzCreateUnitWithSkin(p, FourCC("eate"), 4256.0, 4704.0, 270.000, FourCC("eate"))
u = BlzCreateUnitWithSkin(p, FourCC("eaoe"), 3200.0, 4800.0, 270.000, FourCC("eaoe"))
u = BlzCreateUnitWithSkin(p, FourCC("eaow"), 3904.0, 4736.0, 270.000, FourCC("eaow"))
u = BlzCreateUnitWithSkin(p, FourCC("edob"), 4544.0, 3968.0, 270.000, FourCC("edob"))
u = BlzCreateUnitWithSkin(p, FourCC("etrp"), 3296.0, 3488.0, 270.000, FourCC("etrp"))
u = BlzCreateUnitWithSkin(p, FourCC("etrp"), 3104.0, 3296.0, 270.000, FourCC("etrp"))
u = BlzCreateUnitWithSkin(p, FourCC("etrp"), 2720.0, 3936.0, 270.000, FourCC("etrp"))
u = BlzCreateUnitWithSkin(p, FourCC("etrp"), 2528.0, 3744.0, 270.000, FourCC("etrp"))
u = BlzCreateUnitWithSkin(p, FourCC("edos"), 3584.0, 4736.0, 270.000, FourCC("edos"))
u = BlzCreateUnitWithSkin(p, FourCC("eden"), 3072.0, 4416.0, 270.000, FourCC("eden"))
end

function CreateBuildingsForPlayer3()
local p = Player(3)
local u
local unitID
local t
local life

u = BlzCreateUnitWithSkin(p, FourCC("ndkw"), -4224.0, -5824.0, 270.000, FourCC("ndkw"))
end

function CreateNeutralHostile()
local p = Player(PLAYER_NEUTRAL_AGGRESSIVE)
local u
local unitID
local t
local life

u = BlzCreateUnitWithSkin(p, FourCC("nfra"), -1222.5, 6180.6, 258.517, FourCC("nfra"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000028_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nfrl"), -1430.5, 6233.6, 296.405, FourCC("nfrl"))
u = BlzCreateUnitWithSkin(p, FourCC("nfrl"), -1009.5, 6089.3, 251.862, FourCC("nfrl"))
u = BlzCreateUnitWithSkin(p, FourCC("nfrb"), -4636.6, -2743.9, 312.620, FourCC("nfrb"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000054_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nfra"), 4341.5, -1883.2, 162.021, FourCC("nfra"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000033_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nfrl"), 4170.2, -1637.8, 173.917, FourCC("nfrl"))
u = BlzCreateUnitWithSkin(p, FourCC("nfrl"), 4150.9, -1920.9, 156.182, FourCC("nfrl"))
u = BlzCreateUnitWithSkin(p, FourCC("nfrl"), 913.3, -6775.3, 84.229, FourCC("nfrl"))
u = BlzCreateUnitWithSkin(p, FourCC("nfra"), 1014.9, -6952.9, 90.081, FourCC("nfra"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000046_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nfrl"), 1196.5, -6793.6, 100.316, FourCC("nfrl"))
u = BlzCreateUnitWithSkin(p, FourCC("nfrl"), -1548.7, -6937.7, 150.604, FourCC("nfrl"))
u = BlzCreateUnitWithSkin(p, FourCC("nfrl"), -1146.2, -6949.6, 73.800, FourCC("nfrl"))
u = BlzCreateUnitWithSkin(p, FourCC("nfrb"), -1344.9, -6851.7, 89.180, FourCC("nfrb"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000037_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nfrl"), 4331.1, -5664.8, 126.756, FourCC("nfrl"))
u = BlzCreateUnitWithSkin(p, FourCC("nfrl"), 2006.7, 6262.8, 267.963, FourCC("nfrl"))
u = BlzCreateUnitWithSkin(p, FourCC("nfrl"), 4371.7, -5153.2, 200.770, FourCC("nfrl"))
u = BlzCreateUnitWithSkin(p, FourCC("nfra"), -4228.4, 600.8, 344.551, FourCC("nfra"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000067_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nfrl"), -4133.6, 320.9, 358.829, FourCC("nfrl"))
u = BlzCreateUnitWithSkin(p, FourCC("nfrl"), -4081.1, 815.5, 331.262, FourCC("nfrl"))
u = BlzCreateUnitWithSkin(p, FourCC("nfrb"), 4346.5, -5397.0, 164.929, FourCC("nfrb"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000050_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nfrb"), 4388.9, 1442.5, 173.151, FourCC("nfrb"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000070_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nfrl"), 1601.4, 6236.1, 232.490, FourCC("nfrl"))
u = BlzCreateUnitWithSkin(p, FourCC("nfrb"), 1809.1, 6169.4, 267.682, FourCC("nfrb"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000023_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nfrb"), -4114.3, 3808.1, 340.470, FourCC("nfrb"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000026_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nfrl"), -4131.0, 3529.1, 0.000, FourCC("nfrl"))
u = BlzCreateUnitWithSkin(p, FourCC("nfrl"), -4088.3, 4021.5, 0.000, FourCC("nfrl"))
u = BlzCreateUnitWithSkin(p, FourCC("nfrl"), -4857.9, -2828.3, 354.590, FourCC("nfrl"))
u = BlzCreateUnitWithSkin(p, FourCC("nfrl"), -4638.7, -2463.3, 0.000, FourCC("nfrl"))
u = BlzCreateUnitWithSkin(p, FourCC("nsgt"), 4827.5, -3725.8, 195.073, FourCC("nsgt"))
SetUnitAcquireRange(u, 200.0)
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000049_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nspr"), 4767.0, -3937.9, 181.208, FourCC("nspr"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nspr"), 4594.8, -3725.2, 231.067, FourCC("nspr"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nsgt"), 3927.6, -6906.7, 116.145, FourCC("nsgt"))
SetUnitAcquireRange(u, 200.0)
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000024_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nfrl"), 4454.9, 1690.5, 218.050, FourCC("nfrl"))
u = BlzCreateUnitWithSkin(p, FourCC("nfrl"), 4414.2, 1178.9, 150.604, FourCC("nfrl"))
u = BlzCreateUnitWithSkin(p, FourCC("nsgt"), -3858.8, 5610.2, 312.801, FourCC("nsgt"))
SetUnitAcquireRange(u, 200.0)
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000060_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nspr"), 3736.6, -6929.6, 112.208, FourCC("nspr"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nspr"), 3873.4, -6692.6, 162.067, FourCC("nspr"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nsgt"), 1916.6, 2731.9, 312.930, FourCC("nsgt"))
SetUnitAcquireRange(u, 200.0)
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000044_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nspr"), -3648.2, 5621.1, 291.284, FourCC("nspr"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nspr"), -3788.9, 5386.3, 341.143, FourCC("nspr"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nsgt"), -2369.6, -5884.4, 91.051, FourCC("nsgt"))
SetUnitAcquireRange(u, 200.0)
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000047_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nsgt"), -4993.9, 2604.3, 318.290, FourCC("nsgt"))
SetUnitAcquireRange(u, 200.0)
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000053_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nspr"), -4779.8, 2626.3, 291.284, FourCC("nspr"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nspr"), -4920.4, 2391.6, 341.143, FourCC("nspr"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nspr"), -2511.4, -5788.8, 90.050, FourCC("nspr"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nspr"), -2255.2, -5692.6, 113.741, FourCC("nspr"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nspr"), 2127.4, 2740.4, 291.284, FourCC("nspr"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nspr"), 1986.8, 2505.6, 341.143, FourCC("nspr"))
SetUnitAcquireRange(u, 200.0)
end

function CreateNeutralPassiveBuildings()
local p = Player(PLAYER_NEUTRAL_PASSIVE)
local u
local unitID
local t
local life

u = BlzCreateUnitWithSkin(p, FourCC("ngol"), 4480.0, 3456.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), 4544.0, -2368.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), 576.0, -7168.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), -4480.0, -4992.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), -4416.0, 1024.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), -896.0, 6656.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), 4608.0, -5504.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), 4672.0, 1408.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), 1792.0, 6528.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), -4416.0, 3904.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), -4992.0, -2496.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), -1344.0, -7168.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ntav"), -256.0, -3008.0, 270.000, FourCC("ntav"))
SetUnitColor(u, ConvertPlayerColor(0))
u = BlzCreateUnitWithSkin(p, FourCC("ntav"), -768.0, 2176.0, 270.000, FourCC("ntav"))
SetUnitColor(u, ConvertPlayerColor(0))
end

function CreateNeutralPassive()
local p = Player(PLAYER_NEUTRAL_PASSIVE)
local u
local unitID
local t
local life

u = BlzCreateUnitWithSkin(p, FourCC("nder"), -1248.8, -5317.8, 286.708, FourCC("nder"))
u = BlzCreateUnitWithSkin(p, FourCC("nder"), 2650.1, -3039.6, 21.995, FourCC("nder"))
u = BlzCreateUnitWithSkin(p, FourCC("nder"), 2649.5, 2106.7, 123.754, FourCC("nder"))
u = BlzCreateUnitWithSkin(p, FourCC("nder"), 460.6, 5272.9, 334.599, FourCC("nder"))
u = BlzCreateUnitWithSkin(p, FourCC("nder"), -3939.0, 2752.4, 73.644, FourCC("nder"))
u = BlzCreateUnitWithSkin(p, FourCC("nder"), -2242.3, -1230.6, 149.188, FourCC("nder"))
u = BlzCreateUnitWithSkin(p, FourCC("nder"), -3819.9, -2528.2, 8.345, FourCC("nder"))
end

function CreatePlayerBuildings()
CreateBuildingsForPlayer0()
CreateBuildingsForPlayer3()
end

function CreatePlayerUnits()
end

function CreateAllUnits()
CreateNeutralPassiveBuildings()
CreatePlayerBuildings()
CreateNeutralHostile()
CreateNeutralPassive()
CreatePlayerUnits()
end

function InitUpgrades_Player0()
SetPlayerTechResearched(Player(0), FourCC("Redc"), 2)
end

function InitUpgrades()
InitUpgrades_Player0()
end

function InitCustomPlayerSlots()
SetPlayerStartLocation(Player(0), 0)
ForcePlayerStartLocation(Player(0), 0)
SetPlayerColor(Player(0), ConvertPlayerColor(0))
SetPlayerRacePreference(Player(0), RACE_PREF_NIGHTELF)
SetPlayerRaceSelectable(Player(0), false)
SetPlayerController(Player(0), MAP_CONTROL_USER)
SetPlayerStartLocation(Player(3), 1)
ForcePlayerStartLocation(Player(3), 1)
SetPlayerColor(Player(3), ConvertPlayerColor(3))
SetPlayerRacePreference(Player(3), RACE_PREF_UNDEAD)
SetPlayerRaceSelectable(Player(3), false)
SetPlayerController(Player(3), MAP_CONTROL_COMPUTER)
end

function InitCustomTeams()
SetPlayerTeam(Player(0), 0)
SetPlayerTeam(Player(3), 1)
end

function main()
SetCameraBounds(-5376.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), -7680.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM), 5376.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), 7168.0 - GetCameraMargin(CAMERA_MARGIN_TOP), -5376.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), 7168.0 - GetCameraMargin(CAMERA_MARGIN_TOP), 5376.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), -7680.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM))
SetDayNightModels("Environment\\DNC\\DNCAshenvale\\DNCAshenvaleTerrain\\DNCAshenvaleTerrain.mdl", "Environment\\DNC\\DNCAshenvale\\DNCAshenvaleUnit\\DNCAshenvaleUnit.mdl")
NewSoundEnvironment("Default")
SetAmbientDaySound("AshenvaleDay")
SetAmbientNightSound("AshenvaleNight")
SetMapMusic("Music", true, 0)
InitUpgrades()
CreateAllUnits()
InitBlizzard()
InitGlobals()
local s, m = pcall(RunBundle)
if not s then
    print(m)
end
end

function config()
SetMapName("TRIGSTR_406")
SetMapDescription("TRIGSTR_002")
SetPlayers(2)
SetTeams(2)
SetGamePlacement(MAP_PLACEMENT_USE_MAP_SETTINGS)
DefineStartLocation(0, 4032.0, 4096.0)
DefineStartLocation(1, -4224.0, -5760.0)
InitCustomPlayerSlots()
InitCustomTeams()
end

