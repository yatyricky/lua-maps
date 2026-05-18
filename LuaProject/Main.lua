SF__ = SF__ or {}
function SF__.StrConcat__(...)
    local result = ""
    for i = 1, select("#", ...) do
        local part = select(i, ...)
        if part ~= nil then
            result = result .. tostring(part)
        end
    end
    return result
end

SF__.CorTimerPool__ = SF__.CorTimerPool__ or {}
SF__.CorTimerPoolSize__ = SF__.CorTimerPoolSize__ or 0
SF__.CorMaxTimerPoolSize__ = SF__.CorMaxTimerPoolSize__ or 256

function SF__.CorAcquireTimer__()
    local size = SF__.CorTimerPoolSize__
    if size > 0 then
        local timer = SF__.CorTimerPool__[size]
        SF__.CorTimerPool__[size] = nil
        SF__.CorTimerPoolSize__ = size - 1
        return timer
    end
    return CreateTimer()
end

function SF__.CorReleaseTimer__(timer)
    PauseTimer(timer)
    local size = SF__.CorTimerPoolSize__
    if size < SF__.CorMaxTimerPoolSize__ then
        size = size + 1
        SF__.CorTimerPool__[size] = timer
        SF__.CorTimerPoolSize__ = size
    else
        DestroyTimer(timer)
    end
end

function SF__.CorRun__(fn)
    local thread = coroutine.create(fn)
    local ok, err = coroutine.resume(thread)
    if not ok then error(err) end
    return thread
end

function SF__.CorWait__(milliseconds)
    if milliseconds <= 0 then return end
    local thread = coroutine.running()
    if thread == nil then error("CorWait must be called from a coroutine") end
    if coroutine.isyieldable ~= nil and not coroutine.isyieldable() then error("CorWait cannot yield from this context") end
    local timer = SF__.CorAcquireTimer__()
    TimerStart(timer, milliseconds / 1000, false, function()
        local ok, err = coroutine.resume(thread)
        SF__.CorReleaseTimer__(timer)
        if not ok then error(err) end
    end)
    return coroutine.yield()
end

SF__.ListNil__ = SF__.ListNil__ or {}
function SF__.ListWrap__(value)
    return value == nil and SF__.ListNil__ or value
end

function SF__.ListUnwrap__(value)
    if value == SF__.ListNil__ then return nil end
    return value
end

function SF__.ListNew__(items)
    local list = { items = {}, version = 0 }
    if items ~= nil then
        for i = 1, #items do
            list.items[i] = SF__.ListWrap__(items[i])
        end
    end
    return list
end

function SF__.ListAdd__(list, value)
    table.insert(list.items, SF__.ListWrap__(value))
    list.version = list.version + 1
end

function SF__.ListIterate__(list)
    local version = list.version
    local i = 0
    return function()
        if list.version ~= version then error("collection was modified during iteration") end
        i = i + 1
        local value = list.items[i]
        if value ~= nil then return i, SF__.ListUnwrap__(value) end
    end
end

function SF__.Ternary__(cond, a, b)
    if cond then return a else return b end
end

-- UnitVec3Mode
SF__.UnitVec3Mode = SF__.UnitVec3Mode or {}
SF__.UnitVec3Mode.ForceFlying = 0
SF__.UnitVec3Mode.ForceGround = 1
-- <summary>
-- Flying units fly, ground units grounded.
-- </summary>
--
SF__.UnitVec3Mode.Auto = 2

-- BladeOfJustice
SF__.BladeOfJustice = SF__.BladeOfJustice or {}
function SF__.BladeOfJustice.GetAbilityData(level185)
    return (75 * level185), 5, (10 * level185)
end

function SF__.BladeOfJustice.Init()
    local EventCenter = require("Lib.EventCenter")
    EventCenter.RegisterPlayerUnitSpellEffect:Emit({id = SF__.BladeOfJustice.ID, handler = SF__.BladeOfJustice.Start})
    ExTriggerRegisterNewUnit(function(u186)
        if (GetUnitTypeId(u186) == FourCC("Hpal")) then
            SF__.BladeOfJustice.UpdateAbilityMeta(u186)
        end
    end)
end

function SF__.BladeOfJustice.UpdateAbilityMeta(u187)
    local p188 = GetOwningPlayer(u187)
    local datas__Damage, datas__Duration, datas__DamagePerSecond = {}, {}, {}
    do
        local i = 0
        while (i < 3) do
            do
                local item__Damage, item__Duration, item__DamagePerSecond = SF__.BladeOfJustice.GetAbilityData((i + 1))
                table.insert(datas__Damage, item__Damage)
                table.insert(datas__Duration, item__Duration)
                table.insert(datas__DamagePerSecond, item__DamagePerSecond)
            end
            ::continue::
            i = (i + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p188, SF__.BladeOfJustice.ID, "学习公正之剑 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p188, SF__.BladeOfJustice.ID, SF__.StrConcat__("用圣光的利刃刺穿目标，造成法术伤害，在一定时间内对附近敌人每秒造成光辉伤害。产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 10秒\n\n|cffffcc001级|r - 造成|cffff8c00", datas__Damage[(0 + 1)], "|r的直接法术伤害，|cffff8c00", datas__Duration[(0 + 1)], "|r秒内对附近敌人每秒造成|cffff8c00", datas__DamagePerSecond[(0 + 1)], "|r的光辉伤害。产生|cffff8c001|r点圣能。\n|cffffcc002级|r - 造成|cffff8c00", datas__Damage[(1 + 1)], "|r的直接法术伤害，|cffff8c00", datas__Duration[(1 + 1)], "|r秒内对附近敌人每秒造成|cffff8c00", datas__DamagePerSecond[(1 + 1)], "|r的光辉伤害。产生|cffff8c001|r点圣能。\n|cffffcc003级|r - 造成|cffff8c00", datas__Damage[(2 + 1)], "|r的直接法术伤害，|cffff8c00", datas__Duration[(2 + 1)], "|r秒内对附近敌人每秒造成|cffff8c00", datas__DamagePerSecond[(2 + 1)], "|r的光辉伤害。产生|cffff8c001|r点圣能。"), 0)
    do
        local i189 = 0
        while (i189 < 3) do
            local data__Damage, data__Duration, data__DamagePerSecond = datas__Damage[(i189 + 1)], datas__Duration[(i189 + 1)], datas__DamagePerSecond[(i189 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p188, SF__.BladeOfJustice.ID, SF__.StrConcat__("公正之剑 - [|cffffcc00", (i189 + 1), "级|r]"), i189)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p188, SF__.BladeOfJustice.ID, SF__.StrConcat__("用圣光的利刃刺穿目标，造成|cffff8c00", data__Damage, "|r的直接法术伤害，在|cffff8c00", data__Duration, "|r秒内对附近敌人每秒造成|cffff8c00", data__DamagePerSecond, "|r的光辉伤害。产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 10秒"), i189)
            ::continue::
            i189 = (i189 + 1)
        end
    end
end

function SF__.BladeOfJustice.Start(data)
    local level190 = GetUnitAbilityLevel(data.caster, SF__.BladeOfJustice.ID)
    local EventCenter191 = require("Lib.EventCenter")
    local ad__Damage, ad__Duration, ad__DamagePerSecond = SF__.BladeOfJustice.GetAbilityData(level190)
    EventCenter191.Damage:Emit({whichUnit = data.caster, target = data.target, amount = ad__Damage, attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
    SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(data.caster, 1)
    SF__.BladeOfJustice.New():StartGroudDamage(data.caster, data.target, ad__Damage, ad__Duration, ad__DamagePerSecond)
end

function SF__.BladeOfJustice:StartGroudDamage(caster192, target193, ad__Damage194, ad__Duration195, ad__DamagePerSecond196)
    return SF__.CorRun__(function()
        local pos__x, pos__y = SF__.Vector2.FromUnit(target193)
        local UnitAttribute = require("Objects.UnitAttribute")
        local EventCenter200 = require("Lib.EventCenter")
        local eff = ExAddSpecialEffect("Abilities/Spells/Orc/LiquidFire/Liquidfire.mdl", pos__x, pos__y, ad__Duration195)
        local p197 = GetOwningPlayer(caster192)
        do
            local i198 = 0
            while (i198 < ad__Duration195) do
                SF__.CorWait__(1000)
                ExGroupEnumUnitsInRange(pos__x, pos__y, 300, function(u199)
                    if (not IsUnitEnemy(u199, p197)) then
                        return
                    end
                    if ExIsUnitDead(u199) then
                        return
                    end
                    local tarAttr = UnitAttribute.GetAttr(u199)
                    local damage = (ad__DamagePerSecond196 * (1 - tarAttr.radiantResistance))
                    EventCenter200.Damage:Emit({whichUnit = caster192, target = u199, amount = damage, attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
                end)
                ::continue::
                i198 = (i198 + 1)
            end
        end
        DestroyEffect(eff)
    end)
end

function SF__.BladeOfJustice.__Init(self)
    self.__sf_type = SF__.BladeOfJustice
end

function SF__.BladeOfJustice.New()
    local self = setmetatable({}, { __index = SF__.BladeOfJustice })
    SF__.BladeOfJustice.__Init(self)
    return self
end

SF__.BladeOfJustice.ID = FourCC("A001")
SF__.BladeOfJustice = SF__.BladeOfJustice or {}
-- BladeOfJustice.IAbilityData
SF__.BladeOfJustice.IAbilityData = SF__.BladeOfJustice.IAbilityData or {}
function SF__.BladeOfJustice.IAbilityData.Equals(self__Damage, self__Duration, self__DamagePerSecond, other__Damage, other__Duration, other__DamagePerSecond)
    return (((math.abs((self__Damage - other__Damage)) < 0.0001) and (math.abs((self__Duration - other__Duration)) < 0.0001)) and (math.abs((self__DamagePerSecond - other__DamagePerSecond)) < 0.0001))
end
-- ConstOrderId
SF__.ConstOrderId = SF__.ConstOrderId or {}
function SF__.ConstOrderId.__Init(self)
    self.__sf_type = SF__.ConstOrderId
end

function SF__.ConstOrderId.New()
    local self = setmetatable({}, { __index = SF__.ConstOrderId })
    SF__.ConstOrderId.__Init(self)
    return self
end

SF__.ConstOrderId.Stop = 851972
SF__.ConstOrderId.Smart = 851971
SF__.ConstOrderId.Attack = 851983
-- CrusaderStrike
SF__.CrusaderStrike = SF__.CrusaderStrike or {}
function SF__.CrusaderStrike.GetAbilityData(level201)
    return (0.65 + (0.35 * level201)), (0.15 * (level201 - 1))
end

function SF__.CrusaderStrike.Init()
    local EventCenter202 = require("Lib.EventCenter")
    EventCenter202.RegisterPlayerUnitSpellEffect:Emit({id = SF__.CrusaderStrike.ID, handler = SF__.CrusaderStrike.Start})
    ExTriggerRegisterNewUnit(function(u203)
        if (GetUnitTypeId(u203) == FourCC("Hpal")) then
            SF__.CrusaderStrike.UpdateAbilityMeta(u203)
        end
    end)
end

function SF__.CrusaderStrike.UpdateAbilityMeta(u204)
    local p205 = GetOwningPlayer(u204)
    local datas__DamageScaling, datas__ArtOfWarChance = {}, {}
    do
        local i206 = 0
        while (i206 < 3) do
            do
                local item__DamageScaling, item__ArtOfWarChance = SF__.CrusaderStrike.GetAbilityData((i206 + 1))
                table.insert(datas__DamageScaling, item__DamageScaling)
                table.insert(datas__ArtOfWarChance, item__ArtOfWarChance)
            end
            ::continue::
            i206 = (i206 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p205, SF__.CrusaderStrike.ID, "学习十字军打击 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p205, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击造成一次攻击伤害，伤害系数随技能等级提升。产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 6秒\n\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling[(0 + 1)] * 100)), "%|r的攻击伤害。\n|cffffcc002级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling[(1 + 1)] * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas__ArtOfWarChance[(1 + 1)] * 100)), "%的战争艺术触发几率。\n|cffffcc003级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling[(2 + 1)] * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas__ArtOfWarChance[(2 + 1)] * 100)), "%的战争艺术触发几率。"), 0)
    do
        local i207 = 0
        while (i207 < 3) do
            local data__DamageScaling, data__ArtOfWarChance = datas__DamageScaling[(i207 + 1)], datas__ArtOfWarChance[(i207 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p205, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击 - [|cffffcc00", (i207 + 1), "级|r]"), i207)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p205, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击造成一次攻击伤害，造成|cffff8c00", string.format("%.0f", (data__DamageScaling * 100)), "%|r的攻击伤害", SF__.Ternary__((i207 > 0), SF__.StrConcat__("，", string.format("%.0f", (data__ArtOfWarChance * 100)), "%的战争艺术触发几率"), ""), "。产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 6秒"), i207)
            ::continue::
            i207 = (i207 + 1)
        end
    end
    -- datas.Remove(new IAbilityData { DamageScaling = 0.65f, ArtOfWarChance = 0 });
    do
        local index = 0
        table.remove(datas__DamageScaling, (index + 1))
        table.remove(datas__ArtOfWarChance, (index + 1))
    end
end

function SF__.CrusaderStrike.Start(data208)
    local level209 = GetUnitAbilityLevel(data208.caster, SF__.CrusaderStrike.ID)
    local UnitAttribute210 = require("Objects.UnitAttribute")
    local EventCenter212 = require("Lib.EventCenter")
    local ad__DamageScaling, ad__ArtOfWarChance = SF__.CrusaderStrike.GetAbilityData(level209)
    local attr = UnitAttribute210.GetAttr(data208.caster)
    local damage211 = (attr:SimAttack(UnitAttribute210.HeroAttributeType.Strength) * ad__DamageScaling)
    EventCenter212.Damage:Emit({whichUnit = data208.caster, target = data208.target, amount = damage211, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
    attr.retPalHolyEnergy = (attr.retPalHolyEnergy + 1)
end

function SF__.CrusaderStrike.__Init(self)
    self.__sf_type = SF__.CrusaderStrike
end

function SF__.CrusaderStrike.New()
    local self = setmetatable({}, { __index = SF__.CrusaderStrike })
    SF__.CrusaderStrike.__Init(self)
    return self
end

SF__.CrusaderStrike.ID = FourCC("A000")
SF__.CrusaderStrike = SF__.CrusaderStrike or {}
-- CrusaderStrike.IAbilityData
SF__.CrusaderStrike.IAbilityData = SF__.CrusaderStrike.IAbilityData or {}
function SF__.CrusaderStrike.IAbilityData.Scale(self__DamageScaling, self__ArtOfWarChance, scale)
    return (self__DamageScaling * scale), (self__ArtOfWarChance * scale)
end

function SF__.CrusaderStrike.IAbilityData.Equals(self__DamageScaling213, self__ArtOfWarChance214, other__DamageScaling, other__ArtOfWarChance)
    return ((math.abs((self__DamageScaling213 - other__DamageScaling)) < 0.0001) and (math.abs((self__ArtOfWarChance214 - other__ArtOfWarChance)) < 0.0001))
end

function SF__.CrusaderStrike.IAbilityData.GetHashValue(self__DamageScaling215, self__ArtOfWarChance216)
    return 0
end
-- DivineToll
SF__.DivineToll = SF__.DivineToll or {}
function SF__.DivineToll.GetAbilityData(level217)
    return (2 + level217), (50 * level217), 0.1, 10
end

function SF__.DivineToll.Init()
    local EventCenter218 = require("Lib.EventCenter")
    EventCenter218.RegisterPlayerUnitSpellEffect:Emit({id = SF__.DivineToll.ID, handler = SF__.DivineToll.Start})
    ExTriggerRegisterNewUnit(function(u219)
        if (GetUnitTypeId(u219) == FourCC("Hpal")) then
            SF__.DivineToll.UpdateAbilityMeta(u219)
        end
    end)
end

function SF__.DivineToll.UpdateAbilityMeta(u220)
    local p221 = GetOwningPlayer(u220)
    local datas__TargetCount, datas__Damage222, datas__RadiantDmgAmp, datas__Duration223 = {}, {}, {}, {}
    do
        local i224 = 0
        while (i224 < 3) do
            do
                local item__TargetCount, item__Damage225, item__RadiantDmgAmp, item__Duration226 = SF__.DivineToll.GetAbilityData((i224 + 1))
                table.insert(datas__TargetCount, item__TargetCount)
                table.insert(datas__Damage222, item__Damage225)
                table.insert(datas__RadiantDmgAmp, item__RadiantDmgAmp)
                table.insert(datas__Duration223, item__Duration226)
            end
            ::continue::
            i224 = (i224 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p221, SF__.DivineToll.ID, "学习圣洁鸣钟 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p221, SF__.DivineToll.ID, SF__.StrConcat__("对附近的多个目标施展审判，造成法术伤害，然后神圣之锤环绕圣殿骑士，每次命中敌人使其受到的光辉伤害提高。每个审判产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 30秒\n\n|cffffcc001级|r - 审判最多|cffff8c00", datas__TargetCount[(0 + 1)], "|r个目标，造成|cffff8c00", datas__Damage222[(0 + 1)], "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas__RadiantDmgAmp[(0 + 1)] * 100)), "%|r的光辉易伤，持续|cffff8c00", datas__Duration223[(0 + 1)], "|r秒。\n|cffffcc002级|r - 审判最多|cffff8c00", datas__TargetCount[(1 + 1)], "|r个目标，造成|cffff8c00", datas__Damage222[(1 + 1)], "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas__RadiantDmgAmp[(1 + 1)] * 100)), "%|r的光辉易伤，持续|cffff8c00", datas__Duration223[(1 + 1)], "|r秒。\n|cffffcc003级|r - 审判最多|cffff8c00", datas__TargetCount[(2 + 1)], "|r个目标，造成|cffff8c00", datas__Damage222[(2 + 1)], "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas__RadiantDmgAmp[(2 + 1)] * 100)), "%|r的光辉易伤，持续|cffff8c00", datas__Duration223[(2 + 1)], "|r秒。"), 0)
    do
        local i227 = 0
        while (i227 < 3) do
            local data__TargetCount, data__Damage228, data__RadiantDmgAmp, data__Duration229 = datas__TargetCount[(i227 + 1)], datas__Damage222[(i227 + 1)], datas__RadiantDmgAmp[(i227 + 1)], datas__Duration223[(i227 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p221, SF__.DivineToll.ID, SF__.StrConcat__("圣洁鸣钟 - [|cffffcc00", (i227 + 1), "级|r]"), i227)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p221, SF__.DivineToll.ID, SF__.StrConcat__("对附近的最多|cffff8c00", data__TargetCount, "|r个目标施展审判，造成|cffff8c00", data__Damage228, "|r点法术伤害，然后神圣之锤环绕圣殿骑士，每次命中敌人使其受到的光辉伤害提高|cffff8c00", string.format("%.0f", (data__RadiantDmgAmp * 100)), "%|r，持续|cffff8c00", data__Duration229, "|r秒。每个审判产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 30秒"), i227)
            ::continue::
            i227 = (i227 + 1)
        end
    end
end

function SF__.DivineToll.Start(data230)
    local level231 = GetUnitAbilityLevel(data230.caster, SF__.DivineToll.ID)
    local EventCenter234 = require("Lib.EventCenter")
    local ad__TargetCount, ad__Damage232, ad__RadiantDmgAmp, ad__Duration233 = SF__.DivineToll.GetAbilityData(level231)
    EventCenter234.Damage:Emit({whichUnit = data230.caster, target = data230.target, amount = ad__Damage232, attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
    SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(data230.caster, 1)
    -- new BladeOfJustice().StartGroudDamage(data.caster, data.target, ad);
end

function SF__.DivineToll.__Init(self)
    self.__sf_type = SF__.DivineToll
end

function SF__.DivineToll.New()
    local self = setmetatable({}, { __index = SF__.DivineToll })
    SF__.DivineToll.__Init(self)
    return self
end

SF__.DivineToll.ID = FourCC("A008")
SF__.DivineToll = SF__.DivineToll or {}
-- DivineToll.IAbilityData
SF__.DivineToll.IAbilityData = SF__.DivineToll.IAbilityData or {}
function SF__.DivineToll.IAbilityData.Equals(self__TargetCount, self__Damage235, self__RadiantDmgAmp, self__Duration236, other__TargetCount, other__Damage237, other__RadiantDmgAmp, other__Duration238)
    return (((math.abs((self__Damage235 - other__Damage237)) < 0.0001) and (math.abs((self__Duration236 - other__Duration238)) < 0.0001)) and (math.abs((self__RadiantDmgAmp - other__RadiantDmgAmp)) < 0.0001))
end
-- Program
require("Lib.class")
SF__.Program = SF__.Program or {}
function SF__.Program.Main(args)
    CLI = {}
    local Time = require("Lib.Time")
    local FrameTimer = require("Lib.FrameTimer")
    require("Lib.CoroutineExt")
    require("Lib.TableExt")
    require("Lib.StringExt")
    require("Lib.native")
    local systems = SF__.ListNew__({})
    SF__.ListAdd__(systems, require("System.ItemSystem").new())
    SF__.ListAdd__(systems, require("System.SpellSystem").new())
    SF__.ListAdd__(systems, require("System.BuffSystem").new())
    SF__.ListAdd__(systems, require("System.DamageSystem").new())
    SF__.ListAdd__(systems, require("System.ProjectileSystem").new())
    SF__.ListAdd__(systems, SF__.Systems.InitAbilitiesSystem.New())
    SF__.ListAdd__(systems, require("System.BuffDisplaySystem").new())
    SF__.ListAdd__(systems, SF__.Systems.MeleeGameSystem.New())
    do
        local collection = systems
        for i1, system in SF__.ListIterate__(collection) do
            system:Awake()
        end
    end
    local group = CreateGroup()
    GroupEnumUnitsInRect(group, bj_mapInitialPlayableArea, Filter(function()
        ExTriggerRegisterNewUnitExec(GetFilterUnit())
        return false
    end))
    DestroyGroup(group)
    do
        local collection2 = systems
        for i3, system1 in SF__.ListIterate__(collection2) do
            system1:OnEnable()
        end
    end
    local game = FrameTimer.new(function(dt)
        local now = (MathRound((Time.Time * 100)) * 0.01)
        do
            local collection4 = systems
            for i5, system2 in SF__.ListIterate__(collection4) do
                system2:Update(dt, now)
            end
        end
    end, 1, (-1))
    game:Start()
end

function SF__.Program.__Init(self)
    self.__sf_type = SF__.Program
end

function SF__.Program.New()
    local self = setmetatable({}, { __index = SF__.Program })
    SF__.Program.__Init(self)
    return self
end
-- Projectile
SF__.Projectile = SF__.Projectile or {}
function SF__.Projectile.__Init__unitunitsfactionvector2(self, caster, target, model, speed, onHit, casterOffset__x, casterOffset__y)
    self.__sf_type = SF__.Projectile
end

function SF__.Projectile.New__unitunitsfactionvector2(caster, target, model, speed, onHit, casterOffset__x, casterOffset__y)
    local self = setmetatable({}, { __index = SF__.Projectile })
    SF__.Projectile.__Init__unitunitsfactionvector2(self, caster, target, model, speed, onHit, casterOffset__x, casterOffset__y)
    return self
end

function SF__.Projectile.__Init__unitvector2sfactionvector2(self, caster3, target__x, target__y, model4, speed5, onHit6, casterOffset__x7, casterOffset__y8)
    self.__sf_type = SF__.Projectile
end

function SF__.Projectile.New__unitvector2sfactionvector2(caster3, target__x, target__y, model4, speed5, onHit6, casterOffset__x7, casterOffset__y8)
    local self = setmetatable({}, { __index = SF__.Projectile })
    SF__.Projectile.__Init__unitvector2sfactionvector2(self, caster3, target__x, target__y, model4, speed5, onHit6, casterOffset__x7, casterOffset__y8)
    return self
end
-- Quaternion
SF__.Quaternion = SF__.Quaternion or {}
function SF__.Quaternion.op_Multiply(q__x, q__y, q__z, q__w, v__x, v__y, v__z)
    -- https://en.wikipedia.org/wiki/Quaternions_and_spatial_rotation#Using_quaternion_as_rotations
    local u__x, u__y, u__z = q__x, q__y, q__z
    local s = q__w
    return SF__.Vector3.op_Addition(SF__.Vector3.op_Addition(SF__.Vector3.op_Multiply__fvector3((2 * SF__.Vector3.Dot(u__x, u__y, u__z, v__x, v__y, v__z)), u__x, u__y, u__z), SF__.Vector3.op_Multiply__fvector3(((s * s) - SF__.Vector3.Dot(u__x, u__y, u__z, u__x, u__y, u__z)), v__x, v__y, v__z)), SF__.Vector3.op_Multiply__fvector3((2 * s), SF__.Vector3.Cross(u__x, u__y, u__z, v__x, v__y, v__z)))
end

function SF__.Quaternion.Euler(pitch, yaw, roll)
    -- https://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles#Source_Code_2
    local cy = math.cos((yaw * 0.5))
    local sy = math.sin((yaw * 0.5))
    local cp = math.cos((pitch * 0.5))
    local sp = math.sin((pitch * 0.5))
    local cr = math.cos((roll * 0.5))
    local sr = math.sin((roll * 0.5))
    return (((sr * cp) * cy) - ((cr * sp) * sy)), (((cr * sp) * cy) + ((sr * cp) * sy)), (((cr * cp) * sy) - ((sr * sp) * cy)), (((cr * cp) * cy) + ((sr * sp) * sy))
end

function SF__.Quaternion.Equals(self__x, self__y, self__z, self__w, other__x, other__y, other__z, other__w)
    return ((((math.abs((self__x - other__x)) < 0.0001) and (math.abs((self__y - other__y)) < 0.0001)) and (math.abs((self__z - other__z)) < 0.0001)) and (math.abs((self__w - other__w)) < 0.0001))
end

function SF__.Quaternion.ToString(self__x10, self__y11, self__z12, self__w13)
    return SF__.StrConcat__("(", self__x10, ", ", self__y11, ", ", self__z12, ", ", self__w13, ")")
end
-- RetributionPaladinGlobal
SF__.RetributionPaladinGlobal = SF__.RetributionPaladinGlobal or {}
function SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(u239, amount)
    local UnitAttribute241 = require("Objects.UnitAttribute")
    local attr240 = UnitAttribute241.GetAttr(u239)
    attr240.retPalHolyEnergy = math.min((attr240.retPalHolyEnergy + amount), 5)
end

function SF__.RetributionPaladinGlobal:Init()
    ExTriggerRegisterNewUnit(function(u242)
        if (GetUnitTypeId(u242) == FourCC("Hpal")) then
            SF__.ListAdd__(self._units, u242)
        end
    end)
    _ = self:Start()
end

function SF__.RetributionPaladinGlobal:Start()
    return SF__.CorRun__(function()
        local UnitAttribute245 = require("Objects.UnitAttribute")
        while true do
            do
                local collection6 = self._units
                for i7, u243 in SF__.ListIterate__(collection6) do
                    local attr244 = UnitAttribute245.GetAttr(u243)
                    ExSetUnitMana(u243, ((ExGetUnitMaxMana(u243) * attr244.retPalHolyEnergy) * 0.2))
                    if (attr244.retPalHolyEnergy >= 3) then
                        SF__.Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u243), FourCC("A006"), "ReplaceableTextures/CommandButtons/BTNinv_helmet_96.tga")
                    else
                        SF__.Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u243), FourCC("A006"), "ReplaceableTextures/PassiveButtons/PASBTNinv_helmet_96.tga")
                    end
                end
            end
            SF__.CorWait__(100)
            ::continue::
        end
    end)
end

function SF__.RetributionPaladinGlobal.__Init(self)
    self.__sf_type = SF__.RetributionPaladinGlobal
    self._units = SF__.ListNew__({})
end

function SF__.RetributionPaladinGlobal.New()
    local self = setmetatable({}, { __index = SF__.RetributionPaladinGlobal })
    SF__.RetributionPaladinGlobal.__Init(self)
    return self
end

SF__.RetributionPaladinGlobal.Instance = SF__.RetributionPaladinGlobal.New()
SF__.Systems = SF__.Systems or {}
-- Systems.InitAbilitiesSystem
local SystemBase = require("System.SystemBase")
SF__.Systems.InitAbilitiesSystem = SF__.Systems.InitAbilitiesSystem or class("InitAbilitiesSystem", SystemBase)
SF__.Systems.InitAbilitiesSystem.__sf_base = SystemBase
function SF__.Systems.InitAbilitiesSystem:Awake()
    SF__.RetributionPaladinGlobal.Instance:Init()
    SF__.TemplarStrikes.Init()
    SF__.BladeOfJustice.Init()
    SF__.DivineToll.Init()
    SF__.WordOfGlory.Init()
end

function SF__.Systems.InitAbilitiesSystem.__Init(self)
    self.__sf_type = SF__.Systems.InitAbilitiesSystem
end

function SF__.Systems.InitAbilitiesSystem.New()
    local self = SF__.Systems.InitAbilitiesSystem.new()
    SF__.Systems.InitAbilitiesSystem.__Init(self)
    return self
end
-- Systems.MeleeGameSystem
local SystemBase9 = require("System.SystemBase")
SF__.Systems.MeleeGameSystem = SF__.Systems.MeleeGameSystem or class("MeleeGameSystem", SystemBase9)
SF__.Systems.MeleeGameSystem.__sf_base = SystemBase9
function SF__.Systems.MeleeGameSystem.__Init(self)
    self.__sf_type = SF__.Systems.MeleeGameSystem
    MeleeStartingVisibility()
    MeleeStartingHeroLimit()
    MeleeGrantHeroItems()
    MeleeStartingResources()
    MeleeClearExcessUnits()
    MeleeStartingUnits()
    MeleeStartingAI()
    MeleeInitVictoryDefeat()
end

function SF__.Systems.MeleeGameSystem.New()
    local self = SF__.Systems.MeleeGameSystem.new()
    SF__.Systems.MeleeGameSystem.__Init(self)
    return self
end
-- TemplarStrikes
SF__.TemplarStrikes = SF__.TemplarStrikes or {}
function SF__.TemplarStrikes.GetAbilityData(level246)
    return 2, (0.5 + (0.25 * level246)), (0.05 * level246)
end

function SF__.TemplarStrikes.Init()
    local EventCenter247 = require("Lib.EventCenter")
    EventCenter247.RegisterPlayerUnitSpellEffect:Emit({id = SF__.TemplarStrikes.ID, handler = SF__.TemplarStrikes.Start})
    ExTriggerRegisterNewUnit(function(u248)
        if (GetUnitTypeId(u248) == FourCC("Hpal")) then
            SF__.TemplarStrikes.UpdateAbilityMeta(u248)
            SetHeroLevel(u248, 10, true)
        end
    end)
    EventCenter247.RegisterPlayerUnitDamaged:Emit(function(caster249, target250, damage251, weapType, dmgType, isAttack)
        if (GetUnitAbilityLevel(caster249, SF__.TemplarStrikes.ID) <= 0) then
            return
        end
        if (not isAttack) then
            return
        end
        if (target250 == nil) then
            return
        end
        if ExIsUnitDead(target250) then
            return
        end
        SF__.TemplarStrikes.TryResetBOJ(caster249)
    end)
end

function SF__.TemplarStrikes.TryResetBOJ(caster252)
    local level253 = GetUnitAbilityLevel(caster252, SF__.TemplarStrikes.ID)
    local ad__AttackCount, ad__DamageScaling254, ad__ResetBOJChance = SF__.TemplarStrikes.GetAbilityData(level253)
    if (math.random() >= ad__ResetBOJChance) then
        return
    end
    BlzEndUnitAbilityCooldown(caster252, SF__.BladeOfJustice.ID)
    ExAddSpecialEffectTarget("Abilities/Spells/Items/AIam/AIamTarget.mdl", caster252, "origin", 0.3)
end

function SF__.TemplarStrikes.UpdateAbilityMeta(u255)
    local p256 = GetOwningPlayer(u255)
    local datas__AttackCount, datas__DamageScaling257, datas__ResetBOJChance = {}, {}, {}
    do
        local i258 = 0
        while (i258 < SF__.TemplarStrikes.MaxLevel) do
            do
                local item__AttackCount, item__DamageScaling259, item__ResetBOJChance = SF__.TemplarStrikes.GetAbilityData((i258 + 1))
                table.insert(datas__AttackCount, item__AttackCount)
                table.insert(datas__DamageScaling257, item__DamageScaling259)
                table.insert(datas__ResetBOJChance, item__ResetBOJChance)
            end
            ::continue::
            i258 = (i258 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p256, SF__.TemplarStrikes.ID, "学习圣殿骑士之击 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p256, SF__.TemplarStrikes.ID, SF__.StrConcat__("快速攻击目标|cffff8c00", datas__AttackCount[(0 + 1)], "|r次，第一次造成普通攻击伤害，第二次造成光辉伤害，有一定几率重置公正之剑的冷却时间，普通攻击也会触发。\n\n|cff99ccff冷却时间|r - 10秒\n\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling257[(0 + 1)] * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas__ResetBOJChance[(0 + 1)] * 100)), "%|r的几率重置公正之剑。\n|cffffcc002级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling257[(1 + 1)] * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas__ResetBOJChance[(1 + 1)] * 100)), "%|r的几率重置公正之剑。\n|cffffcc003级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling257[(2 + 1)] * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas__ResetBOJChance[(2 + 1)] * 100)), "%|r的几率重置公正之剑。"), 0)
    do
        local i260 = 0
        while (i260 < SF__.TemplarStrikes.MaxLevel) do
            local data__AttackCount, data__DamageScaling261, data__ResetBOJChance = datas__AttackCount[(i260 + 1)], datas__DamageScaling257[(i260 + 1)], datas__ResetBOJChance[(i260 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p256, SF__.TemplarStrikes.ID, SF__.StrConcat__("圣殿骑士之击 - [|cffffcc00", (i260 + 1), "级|r]"), i260)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p256, SF__.TemplarStrikes.ID, SF__.StrConcat__("快速攻击目标|cffff8c00", data__AttackCount, "|r次，第一次造成普通攻击伤害，第二次造成普通攻击|cffff8c00", string.format("%.0f", (data__DamageScaling261 * 100)), "%|r的光辉伤害，|cffff8c00", string.format("%.0f", (data__ResetBOJChance * 100)), "%|r几率重置公正之剑的冷却时间，普通攻击也会触发。\n\n|cff99ccff冷却时间|r - 10秒"), i260)
            ::continue::
            i260 = (i260 + 1)
        end
    end
end

function SF__.TemplarStrikes.Start(data262)
    return SF__.CorRun__(function()
        local level263 = GetUnitAbilityLevel(data262.caster, SF__.TemplarStrikes.ID)
        local UnitAttribute265 = require("Objects.UnitAttribute")
        local EventCenter266 = require("Lib.EventCenter")
        local attr264 = UnitAttribute265.GetAttr(data262.caster)
        local normalDamage = attr264:SimMeleeAttack()
        EventCenter266.Damage:Emit({whichUnit = data262.caster, target = data262.target, amount = normalDamage, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
        SF__.TemplarStrikes.TryResetBOJ(data262.caster)
        SetUnitTimeScale(data262.caster, 3)
        ResetUnitAnimation(data262.caster)
        SetUnitAnimation(data262.caster, "attack - 2")
        SF__.CorWait__(math.round(((1.166 * 0.33) * 1000)))
        local tarAttr267 = UnitAttribute265.GetAttr(data262.target)
        local ad__AttackCount268, ad__DamageScaling269, ad__ResetBOJChance270 = SF__.TemplarStrikes.GetAbilityData(level263)
        local radiantDamage = ((attr264:SimMeleeAttack() * ad__DamageScaling269) * (1 - tarAttr267.radiantResistance))
        EventCenter266.Damage:Emit({whichUnit = data262.caster, target = data262.target, amount = radiantDamage, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
        SF__.TemplarStrikes.TryResetBOJ(data262.caster)
        SetUnitTimeScale(data262.caster, 1)
        ResetUnitAnimation(data262.caster)
    end)
end

function SF__.TemplarStrikes.__Init(self)
    self.__sf_type = SF__.TemplarStrikes
end

function SF__.TemplarStrikes.New()
    local self = setmetatable({}, { __index = SF__.TemplarStrikes })
    SF__.TemplarStrikes.__Init(self)
    return self
end

SF__.TemplarStrikes.ID = FourCC("A007")
SF__.TemplarStrikes.MaxLevel = 3
SF__.TemplarStrikes = SF__.TemplarStrikes or {}
-- TemplarStrikes.IAbilityData
SF__.TemplarStrikes.IAbilityData = SF__.TemplarStrikes.IAbilityData or {}
function SF__.TemplarStrikes.IAbilityData.Equals(self__AttackCount, self__DamageScaling271, self__ResetBOJChance, other__AttackCount, other__DamageScaling272, other__ResetBOJChance)
    return ((math.abs((self__DamageScaling271 - other__DamageScaling272)) < 0.0001) and (math.abs((self__ResetBOJChance - other__ResetBOJChance)) < 0.0001))
end
-- TemplarVerdict
SF__.TemplarVerdict = SF__.TemplarVerdict or {}
function SF__.TemplarVerdict.GetAbilityData(level273)
    return 2.25, 0.3, 0.15
end

function SF__.TemplarVerdict.Init()
    local EventCenter274 = require("Lib.EventCenter")
    EventCenter274.RegisterPlayerUnitSpellChannel:Emit({id = SF__.TemplarVerdict.ID, handler = SF__.TemplarVerdict.Check})
    EventCenter274.RegisterPlayerUnitSpellEffect:Emit({id = SF__.TemplarVerdict.ID, handler = SF__.TemplarVerdict.Start})
    ExTriggerRegisterNewUnit(function(u275)
        if (GetUnitTypeId(u275) == FourCC("Hpal")) then
            SF__.TemplarVerdict.UpdateAbilityMeta(u275)
        end
    end)
end

function SF__.TemplarVerdict.Check(data276)
    local UnitAttribute278 = require("Objects.UnitAttribute")
    local attr277 = UnitAttribute278.GetAttr(data276.caster)
    if (attr277.retPalHolyEnergy < 3) then
        IssueImmediateOrderById(data276.caster, SF__.ConstOrderId.Stop)
        ExTextState(data276.caster, "圣能不足")
    end
end

function SF__.TemplarVerdict.UpdateAbilityMeta(u279)
    local p280 = GetOwningPlayer(u279)
    local datas__DamageScaling281, datas__JudgementDamageScaling, datas__ChanceToResetJudgement = {}, {}, {}
    do
        local i282 = 0
        while (i282 < 1) do
            do
                local item__DamageScaling283, item__JudgementDamageScaling, item__ChanceToResetJudgement = SF__.TemplarVerdict.GetAbilityData((i282 + 1))
                table.insert(datas__DamageScaling281, item__DamageScaling283)
                table.insert(datas__JudgementDamageScaling, item__JudgementDamageScaling)
                table.insert(datas__ChanceToResetJudgement, item__ChanceToResetJudgement)
            end
            ::continue::
            i282 = (i282 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p280, SF__.TemplarVerdict.ID, "学习圣殿骑士的裁决 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p280, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决造成一次攻击伤害，如果目标被审判，造成30%的额外伤害，15%几率重置审判。消耗|cffff8c003|r点圣能。\n\n|cff99ccff冷却时间|r - 5秒\n\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas__JudgementDamageScaling[(0 + 1)] * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas__ChanceToResetJudgement[(0 + 1)] * 100)), "%的战争艺术触发几率。"), 0)
    do
        local i284 = 0
        while (i284 < 1) do
            local data__DamageScaling285, data__JudgementDamageScaling, data__ChanceToResetJudgement = datas__DamageScaling281[(i284 + 1)], datas__JudgementDamageScaling[(i284 + 1)], datas__ChanceToResetJudgement[(i284 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p280, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决 - [|cffffcc00", (i284 + 1), "级|r]"), i284)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p280, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决造成一次攻击伤害，造成|cffff8c00", string.format("%.0f", (data__DamageScaling285 * 100)), "%|r的攻击伤害。消耗|cffff8c003|r点圣能。\n\n|cff99ccff冷却时间|r - 5秒"), i284)
            ::continue::
            i284 = (i284 + 1)
        end
    end
end

function SF__.TemplarVerdict.Start(data286)
    local level287 = GetUnitAbilityLevel(data286.caster, SF__.TemplarVerdict.ID)
    local UnitAttribute290 = require("Objects.UnitAttribute")
    local EventCenter292 = require("Lib.EventCenter")
    local ad__DamageScaling288, ad__JudgementDamageScaling, ad__ChanceToResetJudgement = SF__.TemplarVerdict.GetAbilityData(level287)
    local attr289 = UnitAttribute290.GetAttr(data286.caster)
    local damage291 = (attr289:SimAttack(UnitAttribute290.HeroAttributeType.Strength) * ad__DamageScaling288)
    EventCenter292.Damage:Emit({whichUnit = data286.caster, target = data286.target, amount = damage291, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_SLICE, outResult = {}})
    attr289.retPalHolyEnergy = (attr289.retPalHolyEnergy - 3)
end

function SF__.TemplarVerdict.__Init(self)
    self.__sf_type = SF__.TemplarVerdict
end

function SF__.TemplarVerdict.New()
    local self = setmetatable({}, { __index = SF__.TemplarVerdict })
    SF__.TemplarVerdict.__Init(self)
    return self
end

SF__.TemplarVerdict.ID = FourCC("A004")
SF__.TemplarVerdict = SF__.TemplarVerdict or {}
-- TemplarVerdict.IAbilityData
SF__.TemplarVerdict.IAbilityData = SF__.TemplarVerdict.IAbilityData or {}
function SF__.TemplarVerdict.IAbilityData.Equals(self__DamageScaling293, self__JudgementDamageScaling, self__ChanceToResetJudgement, other__DamageScaling294, other__JudgementDamageScaling, other__ChanceToResetJudgement)
    return ((math.abs((self__JudgementDamageScaling - other__JudgementDamageScaling)) < 0.0001) and (math.abs((self__ChanceToResetJudgement - other__ChanceToResetJudgement)) < 0.0001))
end
-- Utils
SF__.Utils = SF__.Utils or {}
function SF__.Utils.ExSetAbilityResearchTooltip(p, abilCode, researchTooltip, level)
    if (GetLocalPlayer() ~= p) then
        return
    end
    BlzSetAbilityResearchTooltip(abilCode, researchTooltip, level)
end

function SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p14, abilCode15, researchExtendedTooltip, level16)
    if (GetLocalPlayer() ~= p14) then
        return
    end
    BlzSetAbilityResearchExtendedTooltip(abilCode15, researchExtendedTooltip, level16)
end

function SF__.Utils.ExBlzSetAbilityTooltip(p17, abilCode18, tooltip, level19)
    if (GetLocalPlayer() ~= p17) then
        return
    end
    BlzSetAbilityTooltip(abilCode18, tooltip, level19)
end

function SF__.Utils.ExBlzSetAbilityExtendedTooltip(p20, abilCode21, extendedTooltip, level22)
    if (GetLocalPlayer() ~= p20) then
        return
    end
    BlzSetAbilityExtendedTooltip(abilCode21, extendedTooltip, level22)
end

function SF__.Utils.ExBlzSetAbilityIcon(p23, abilCode24, iconPath)
    if (GetLocalPlayer() ~= p23) then
        return
    end
    BlzSetAbilityIcon(abilCode24, iconPath)
end

function SF__.Utils.__Init(self)
    self.__sf_type = SF__.Utils
end

function SF__.Utils.New()
    local self = setmetatable({}, { __index = SF__.Utils })
    SF__.Utils.__Init(self)
    return self
end
-- Vector2
SF__.Vector2 = SF__.Vector2 or {}
function SF__.Vector2.get_Zero()
    return 0, 0
end

function SF__.Vector2.InsideUnitCircle()
    local angle = ((math.random() * 2) * math.pi)
    return math.cos(angle), math.sin(angle)
end

function SF__.Vector2.Dot(a__x, a__y, b__x, b__y)
    return ((a__x * b__x) + (a__y * b__y))
end

function SF__.Vector2.Cross(a__x25, a__y26, b__x27, b__y28)
    return ((a__y26 * b__x27) - (a__x25 * b__y28))
end

function SF__.Vector2.op_UnaryNegation(a__x29, a__y30)
    return (-a__x29), (-a__y30)
end

function SF__.Vector2.op_Addition(a__x31, a__y32, b__x33, b__y34)
    return (a__x31 + b__x33), (a__y32 + b__y34)
end

function SF__.Vector2.op_Subtraction(a__x35, a__y36, b__x37, b__y38)
    return (a__x35 - b__x37), (a__y36 - b__y38)
end

function SF__.Vector2.op_Multiply__vector2f(v__x39, v__y40, f)
    return (v__x39 * f), (v__y40 * f)
end

function SF__.Vector2.op_Multiply__fvector2(f41, v__x42, v__y43)
    return (v__x42 * f41), (v__y43 * f41)
end

function SF__.Vector2.op_Division(v__x44, v__y45, f46)
    return (v__x44 / f46), (v__y45 / f46)
end

function SF__.Vector2.op_Equality(a__x47, a__y48, b__x49, b__y50)
    return ((math.abs((a__x47 - b__x49)) < 0.0001) and (math.abs((a__y48 - b__y50)) < 0.0001))
end

function SF__.Vector2.op_Inequality(a__x51, a__y52, b__x53, b__y54)
    return (not SF__.Vector2.op_Equality(a__x51, a__y52, b__x53, b__y54))
end

function SF__.Vector2.UnitDistance(a, b)
    local v1__x, v1__y = SF__.Vector2.FromUnit(a)
    local v2__x, v2__y = SF__.Vector2.FromUnit(b)
    return SF__.Vector2.get_Magnitude(SF__.Vector2.op_Subtraction(v1__x, v1__y, v2__x, v2__y))
end

function SF__.Vector2.SqrUnitDistance(a55, b56)
    local v1__x57, v1__y58 = SF__.Vector2.FromUnit(a55)
    local v2__x59, v2__y60 = SF__.Vector2.FromUnit(b56)
    return SF__.Vector2.get_SqrMagnitude(SF__.Vector2.op_Subtraction(v1__x57, v1__y58, v2__x59, v2__y60))
end

function SF__.Vector2.FromUnit(u)
    return GetUnitX(u), GetUnitY(u)
end

function SF__.Vector2.get_Magnitude(self__x61, self__y62)
    return math.sqrt(SF__.Vector2.get_SqrMagnitude(self__x61, self__y62))
end

function SF__.Vector2.get_SqrMagnitude(self__x63, self__y64)
    return ((self__x63 * self__x63) + (self__y64 * self__y64))
end

function SF__.Vector2.get_Normalized(self__x65, self__y66)
    local mag = SF__.Vector2.get_Magnitude(self__x65, self__y66)
    if (mag < 0.0001) then
        return SF__.Vector2.get_Zero()
    end
    return SF__.Vector2.op_Division(self__x65, self__y66, mag)
end

function SF__.Vector2.ClampMagnitude(self__x69, self__y70, mag71)
    return SF__.Vector2.op_Multiply__vector2f(SF__.Vector2.get_Normalized(self__x69, self__y70), mag71)
end

function SF__.Vector2.Equals(self__x72, self__y73, other__x74, other__y75)
    return SF__.Vector2.op_Equality(self__x72, self__y73, other__x74, other__y75)
end

function SF__.Vector2.ToString(self__x76, self__y77)
    return SF__.StrConcat__("(", self__x76, ", ", self__y77, ")")
end

function SF__.Vector2.Rotate(self__x78, self__y79, angle80)
    local cos = math.cos(angle80)
    local sin = math.sin(angle80)
    return ((self__x78 * cos) - (self__y79 * sin)), ((self__x78 * sin) + (self__y79 * cos))
end

function SF__.Vector2.UnitMoveTo(self__x81, self__y82, u83)
    SetUnitX(u83, self__x81)
    SetUnitY(u83, self__y82)
end

function SF__.Vector2.GetTerrainZ(self__x84, self__y85)
    MoveLocation(SF__.Vector2._loc, self__x84, self__y85)
    return GetLocationZ(SF__.Vector2._loc)
end

SF__.Vector2._loc = Location(0, 0)
-- Vector3
SF__.Vector3 = SF__.Vector3 or {}
function SF__.Vector3.get_Zero()
    return 0, 0, 0
end

function SF__.Vector3.get_Up()
    return 0, 0, 1
end

function SF__.Vector3.get_Down()
    return 0, 0, (-1)
end

function SF__.Vector3.get_Right()
    return 1, 0, 0
end

function SF__.Vector3.get_Left()
    return (-1), 0, 0
end

function SF__.Vector3.get_Forward()
    return 0, 1, 0
end

function SF__.Vector3.get_Back()
    return 0, (-1), 0
end

function SF__.Vector3.get_One()
    return 1, 1, 1
end

function SF__.Vector3.op_Addition(a__x86, a__y87, a__z, b__x88, b__y89, b__z)
    return (a__x86 + b__x88), (a__y87 + b__y89), (a__z + b__z)
end

function SF__.Vector3.op_UnaryNegation(a__x90, a__y91, a__z92)
    return (-a__x90), (-a__y91), (-a__z92)
end

function SF__.Vector3.op_Subtraction(a__x93, a__y94, a__z95, b__x96, b__y97, b__z98)
    return (a__x93 - b__x96), (a__y94 - b__y97), (a__z95 - b__z98)
end

function SF__.Vector3.op_Multiply__vector3f(v__x99, v__y100, v__z101, f102)
    return (v__x99 * f102), (v__y100 * f102), (v__z101 * f102)
end

function SF__.Vector3.op_Multiply__fvector3(f103, v__x104, v__y105, v__z106)
    return (v__x104 * f103), (v__y105 * f103), (v__z106 * f103)
end

function SF__.Vector3.op_Division(v__x107, v__y108, v__z109, f110)
    return (v__x107 / f110), (v__y108 / f110), (v__z109 / f110)
end

function SF__.Vector3.op_Equality(a__x111, a__y112, a__z113, b__x114, b__y115, b__z116)
    return (((math.abs((a__x111 - b__x114)) < 0.0001) and (math.abs((a__y112 - b__y115)) < 0.0001)) and (math.abs((a__z113 - b__z116)) < 0.0001))
end

function SF__.Vector3.op_Inequality(a__x117, a__y118, a__z119, b__x120, b__y121, b__z122)
    return (not SF__.Vector3.op_Equality(a__x117, a__y118, a__z119, b__x120, b__y121, b__z122))
end

function SF__.Vector3.Dot(a__x123, a__y124, a__z125, b__x126, b__y127, b__z128)
    return (((a__x123 * b__x126) + (a__y124 * b__y127)) + (a__z125 * b__z128))
end

function SF__.Vector3.Scale(a__x129, a__y130, a__z131, b__x132, b__y133, b__z134)
    return (a__x129 * b__x132), (a__y130 * b__y133), (a__z131 * b__z134)
end

-- <summary>
-- Warcraft III world space here is right-handed: +x points right, +y points away, +z points up.
-- That means Cross((1,0,0), (0,1,0)) == (0,0,1).
-- </summary>
--
function SF__.Vector3.Cross(a__x135, a__y136, a__z137, b__x138, b__y139, b__z140)
    return ((a__y136 * b__z140) - (a__z137 * b__y139)), ((a__z137 * b__x138) - (a__x135 * b__z140)), ((a__x135 * b__y139) - (a__y136 * b__x138))
end

function SF__.Vector3.Project(v__x141, v__y142, v__z143, onNormal__x, onNormal__y, onNormal__z)
    local sqrMag = SF__.Vector3.Dot(onNormal__x, onNormal__y, onNormal__z, onNormal__x, onNormal__y, onNormal__z)
    if (sqrMag < 0.0001) then
        return SF__.Vector3.get_Zero()
    end
    local dot = SF__.Vector3.Dot(v__x141, v__y142, v__z143, onNormal__x, onNormal__y, onNormal__z)
    return SF__.Vector3.op_Multiply__vector3f(onNormal__x, onNormal__y, onNormal__z, (dot / sqrMag))
end

function SF__.Vector3.ProjectOnPlane(v__x144, v__y145, v__z146, planeNormal__x, planeNormal__y, planeNormal__z)
    return SF__.Vector3.op_Subtraction(v__x144, v__y145, v__z146, SF__.Vector3.Project(v__x144, v__y145, v__z146, planeNormal__x, planeNormal__y, planeNormal__z))
end

function SF__.Vector3._getTerrainZ(x147, y148)
    MoveLocation(SF__.Vector3._loc, x147, y148)
    return GetLocationZ(SF__.Vector3._loc)
end

function SF__.Vector3.FromUnit(u149)
    local x150 = GetUnitX(u149)
    local y151 = GetUnitY(u149)
    return x150, y151, (SF__.Vector3._getTerrainZ(x150, y151) + GetUnitFlyHeight(u149))
end

function SF__.Vector3.get_SqrMagnitude(self__x152, self__y153, self__z154)
    return (((self__x152 * self__x152) + (self__y153 * self__y153)) + (self__z154 * self__z154))
end

function SF__.Vector3.get_Magnitude(self__x155, self__y156, self__z157)
    return math.sqrt(SF__.Vector3.get_SqrMagnitude(self__x155, self__y156, self__z157))
end

function SF__.Vector3.get_Normalized(self__x158, self__y159, self__z160)
    local mag161 = SF__.Vector3.get_Magnitude(self__x158, self__y159, self__z160)
    if (mag161 < 0.0001) then
        return SF__.Vector3.get_Zero()
    end
    return SF__.Vector3.op_Division(self__x158, self__y159, self__z160, mag161)
end

function SF__.Vector3.ClampMagnitude(self__x165, self__y166, self__z167, mag168)
    return SF__.Vector3.op_Multiply__vector3f(SF__.Vector3.get_Normalized(self__x165, self__y166, self__z167), mag168)
end

function SF__.Vector3.Equals(self__x169, self__y170, self__z171, other__x172, other__y173, other__z174)
    return SF__.Vector3.op_Equality(self__x169, self__y170, self__z171, other__x172, other__y173, other__z174)
end

function SF__.Vector3.ToString(self__x175, self__y176, self__z177)
    return SF__.StrConcat__("(", self__x175, ", ", self__y176, ", ", self__z177, ")")
end

function SF__.Vector3.UnitMoveTo(self__x178, self__y179, self__z180, u181, mode)
    if mode == nil then mode = SF__.UnitVec3Mode.Auto end
    local tz = SF__.Vector3._getTerrainZ(self__x178, self__y179)
    local LuaUtils = require("Lib.Utils")
    local defaultFlyHeight = GetUnitDefaultFlyHeight(u181)
    local minZ = (tz + defaultFlyHeight)
    SetUnitPosition(u181, self__x178, self__y179)
    repeat
        local switchValue = mode
        if (switchValue == SF__.UnitVec3Mode.ForceFlying) then
            LuaUtils.SetUnitFlyable(u181)
            SetUnitFlyHeight(u181, (math.max(minZ, self__z180) - minZ), 0)
            break
        elseif (switchValue == SF__.UnitVec3Mode.ForceGround) then
            SetUnitFlyHeight(u181, defaultFlyHeight, 0)
            break
        elseif (switchValue == SF__.UnitVec3Mode.Auto) then
            if IsUnitType(u181, UNIT_TYPE_FLYING) then
                SetUnitFlyHeight(u181, (math.max(minZ, self__z180) - minZ), 0)
            else
                SetUnitFlyHeight(u181, defaultFlyHeight, 0)
            end
            break
        end
    until true
end

function SF__.Vector3.GetTerrainZ(self__x182, self__y183, self__z184)
    return SF__.Vector3._getTerrainZ(self__x182, self__y183)
end

SF__.Vector3._loc = Location(0, 0)
-- WordOfGlory
SF__.WordOfGlory = SF__.WordOfGlory or {}
function SF__.WordOfGlory.Init()
    local EventCenter295 = require("Lib.EventCenter")
    EventCenter295.RegisterPlayerUnitSpellChannel:Emit({id = SF__.WordOfGlory.ID, handler = SF__.WordOfGlory.Check})
    EventCenter295.RegisterPlayerUnitSpellEffect:Emit({id = SF__.WordOfGlory.ID, handler = SF__.WordOfGlory.Start})
    ExTriggerRegisterNewUnit(function(u296)
        if (GetUnitTypeId(u296) == FourCC("Hpal")) then
            SF__.WordOfGlory.UpdateAbilityMeta(u296)
        end
    end)
end

function SF__.WordOfGlory.Check(data297)
    local UnitAttribute299 = require("Objects.UnitAttribute")
    local attr298 = UnitAttribute299.GetAttr(data297.caster)
    if (attr298.retPalHolyEnergy < 3) then
        IssueImmediateOrderById(data297.caster, SF__.ConstOrderId.Stop)
        ExTextState(data297.caster, "圣能不足")
    end
end

function SF__.WordOfGlory.UpdateAbilityMeta(u300)
    local p301 = GetOwningPlayer(u300)
    SF__.Utils.ExSetAbilityResearchTooltip(p301, SF__.WordOfGlory.ID, "学习圣殿骑士的裁决 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p301, SF__.WordOfGlory.ID, "圣殿骑士的裁决造成一次攻击伤害，如果目标被审判，造成30%的额外伤害，15%几率重置审判。消耗|cffff8c003|r点圣能。\n\n|cff99ccff冷却时间|r - 5秒\n\n|cffffcc001级|r - |cffff8c00100%|r的攻击伤害，100%的战争艺术触发几率。", 0)
    do
        local i302 = 0
        while (i302 < 1) do
            SF__.Utils.ExBlzSetAbilityTooltip(p301, SF__.WordOfGlory.ID, SF__.StrConcat__("圣殿骑士的裁决 - [|cffffcc00", (i302 + 1), "级|r]"), i302)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p301, SF__.WordOfGlory.ID, "圣殿骑士的裁决造成一次攻击伤害，造成|cffff8c00100%|r的攻击伤害。消耗|cffff8c003|r点圣能。\n\n|cff99ccff冷却时间|r - 5秒", i302)
            ::continue::
            i302 = (i302 + 1)
        end
    end
end

function SF__.WordOfGlory.Start(data303)
    local UnitAttribute305 = require("Objects.UnitAttribute")
    local EventCenter306 = require("Lib.EventCenter")
    local attr304 = UnitAttribute305.GetAttr(data303.caster)
    EventCenter306.Heal:Emit({caster = data303.caster, target = data303.target, amount = 300})
    attr304.retPalHolyEnergy = (attr304.retPalHolyEnergy - 3)
end

function SF__.WordOfGlory.__Init(self)
    self.__sf_type = SF__.WordOfGlory
end

function SF__.WordOfGlory.New()
    local self = setmetatable({}, { __index = SF__.WordOfGlory })
    SF__.WordOfGlory.__Init(self)
    return self
end

SF__.WordOfGlory.ID = FourCC("A006")

SF__.Program.Main()
