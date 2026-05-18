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
function SF__.BladeOfJustice.GetAbilityData(level89)
    return (75 * level89), 5, (10 * level89)
end

function SF__.BladeOfJustice.Init()
    local EventCenter = require("Lib.EventCenter")
    EventCenter.RegisterPlayerUnitSpellEffect:Emit({id = SF__.BladeOfJustice.ID, handler = SF__.BladeOfJustice.Start})
    ExTriggerRegisterNewUnit(function(u90)
        if (GetUnitTypeId(u90) == FourCC("Hpal")) then
            SF__.BladeOfJustice.UpdateAbilityMeta(u90)
        end
    end)
end

function SF__.BladeOfJustice.UpdateAbilityMeta(u91)
    local p92 = GetOwningPlayer(u91)
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
    SF__.Utils.ExSetAbilityResearchTooltip(p92, SF__.BladeOfJustice.ID, "学习公正之剑 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p92, SF__.BladeOfJustice.ID, SF__.StrConcat__("用圣光的利刃刺穿目标，造成法术伤害，在一定时间内对附近敌人每秒造成光辉伤害。产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 10秒\n\n|cffffcc001级|r - 造成|cffff8c00", datas__Damage[(0 + 1)], "|r的直接法术伤害，|cffff8c00", datas__Duration[(0 + 1)], "|r秒内对附近敌人每秒造成|cffff8c00", datas__DamagePerSecond[(0 + 1)], "|r的光辉伤害。产生|cffff8c001|r点圣能。\n|cffffcc002级|r - 造成|cffff8c00", datas__Damage[(1 + 1)], "|r的直接法术伤害，|cffff8c00", datas__Duration[(1 + 1)], "|r秒内对附近敌人每秒造成|cffff8c00", datas__DamagePerSecond[(1 + 1)], "|r的光辉伤害。产生|cffff8c001|r点圣能。\n|cffffcc003级|r - 造成|cffff8c00", datas__Damage[(2 + 1)], "|r的直接法术伤害，|cffff8c00", datas__Duration[(2 + 1)], "|r秒内对附近敌人每秒造成|cffff8c00", datas__DamagePerSecond[(2 + 1)], "|r的光辉伤害。产生|cffff8c001|r点圣能。"), 0)
    do
        local i93 = 0
        while (i93 < 3) do
            local data__Damage, data__Duration, data__DamagePerSecond = datas__Damage[(i93 + 1)], datas__Duration[(i93 + 1)], datas__DamagePerSecond[(i93 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p92, SF__.BladeOfJustice.ID, SF__.StrConcat__("公正之剑 - [|cffffcc00", (i93 + 1), "级|r]"), i93)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p92, SF__.BladeOfJustice.ID, SF__.StrConcat__("用圣光的利刃刺穿目标，造成|cffff8c00", data__Damage, "|r的直接法术伤害，在|cffff8c00", data__Duration, "|r秒内对附近敌人每秒造成|cffff8c00", data__DamagePerSecond, "|r的光辉伤害。产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 10秒"), i93)
            ::continue::
            i93 = (i93 + 1)
        end
    end
end

function SF__.BladeOfJustice.Start(data)
    local level94 = GetUnitAbilityLevel(data.caster, SF__.BladeOfJustice.ID)
    local EventCenter95 = require("Lib.EventCenter")
    local ad__Damage, ad__Duration, ad__DamagePerSecond = SF__.BladeOfJustice.GetAbilityData(level94)
    EventCenter95.Damage:Emit({whichUnit = data.caster, target = data.target, amount = ad__Damage, attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
    SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(data.caster, 1)
    SF__.BladeOfJustice.New():StartGroudDamage(data.caster, data.target, ad__Damage, ad__Duration, ad__DamagePerSecond)
end

function SF__.BladeOfJustice:StartGroudDamage(caster96, target97, ad__Damage98, ad__Duration99, ad__DamagePerSecond100)
    return SF__.CorRun__(function()
        self.x = GetUnitX(target97)
        local UnitAttribute = require("Objects.UnitAttribute")
        local EventCenter104 = require("Lib.EventCenter")
        self.y = GetUnitY(target97)
        local eff = ExAddSpecialEffect("Abilities/Spells/Orc/LiquidFire/Liquidfire.mdl", self.x, self.y, ad__Duration99)
        local p101 = GetOwningPlayer(caster96)
        do
            local i102 = 0
            while (i102 < ad__Duration99) do
                SF__.CorWait__(1000)
                ExGroupEnumUnitsInRange(self.x, self.y, 300, function(u103)
                    if (not IsUnitEnemy(u103, p101)) then
                        return
                    end
                    if ExIsUnitDead(u103) then
                        return
                    end
                    local tarAttr = UnitAttribute.GetAttr(u103)
                    local damage = (ad__DamagePerSecond100 * (1 - tarAttr.radiantResistance))
                    EventCenter104.Damage:Emit({whichUnit = caster96, target = u103, amount = damage, attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
                end)
                ::continue::
                i102 = (i102 + 1)
            end
        end
        DestroyEffect(eff)
    end)
end

function SF__.BladeOfJustice.__Init(self)
    self.__sf_type = SF__.BladeOfJustice
    self.x = 0
    self.y = 0
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
function SF__.CrusaderStrike.GetAbilityData(level105)
    return (0.65 + (0.35 * level105)), (0.15 * (level105 - 1))
end

function SF__.CrusaderStrike.Init()
    local EventCenter106 = require("Lib.EventCenter")
    EventCenter106.RegisterPlayerUnitSpellEffect:Emit({id = SF__.CrusaderStrike.ID, handler = SF__.CrusaderStrike.Start})
    ExTriggerRegisterNewUnit(function(u107)
        if (GetUnitTypeId(u107) == FourCC("Hpal")) then
            SF__.CrusaderStrike.UpdateAbilityMeta(u107)
        end
    end)
end

function SF__.CrusaderStrike.UpdateAbilityMeta(u108)
    local p109 = GetOwningPlayer(u108)
    local datas__DamageScaling, datas__ArtOfWarChance = {}, {}
    do
        local i110 = 0
        while (i110 < 3) do
            do
                local item__DamageScaling, item__ArtOfWarChance = SF__.CrusaderStrike.GetAbilityData((i110 + 1))
                table.insert(datas__DamageScaling, item__DamageScaling)
                table.insert(datas__ArtOfWarChance, item__ArtOfWarChance)
            end
            ::continue::
            i110 = (i110 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p109, SF__.CrusaderStrike.ID, "学习十字军打击 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p109, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击造成一次攻击伤害，伤害系数随技能等级提升。产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 6秒\n\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling[(0 + 1)] * 100)), "%|r的攻击伤害。\n|cffffcc002级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling[(1 + 1)] * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas__ArtOfWarChance[(1 + 1)] * 100)), "%的战争艺术触发几率。\n|cffffcc003级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling[(2 + 1)] * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas__ArtOfWarChance[(2 + 1)] * 100)), "%的战争艺术触发几率。"), 0)
    do
        local i111 = 0
        while (i111 < 3) do
            local data__DamageScaling, data__ArtOfWarChance = datas__DamageScaling[(i111 + 1)], datas__ArtOfWarChance[(i111 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p109, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击 - [|cffffcc00", (i111 + 1), "级|r]"), i111)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p109, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击造成一次攻击伤害，造成|cffff8c00", string.format("%.0f", (data__DamageScaling * 100)), "%|r的攻击伤害", SF__.Ternary__((i111 > 0), SF__.StrConcat__("，", string.format("%.0f", (data__ArtOfWarChance * 100)), "%的战争艺术触发几率"), ""), "。产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 6秒"), i111)
            ::continue::
            i111 = (i111 + 1)
        end
    end
    -- datas.Remove(new IAbilityData { DamageScaling = 0.65f, ArtOfWarChance = 0 });
    do
        local index = 0
        table.remove(datas__DamageScaling, (index + 1))
        table.remove(datas__ArtOfWarChance, (index + 1))
    end
end

function SF__.CrusaderStrike.Start(data112)
    local level113 = GetUnitAbilityLevel(data112.caster, SF__.CrusaderStrike.ID)
    local UnitAttribute114 = require("Objects.UnitAttribute")
    local EventCenter116 = require("Lib.EventCenter")
    local ad__DamageScaling, ad__ArtOfWarChance = SF__.CrusaderStrike.GetAbilityData(level113)
    local attr = UnitAttribute114.GetAttr(data112.caster)
    local damage115 = (attr:SimAttack(UnitAttribute114.HeroAttributeType.Strength) * ad__DamageScaling)
    EventCenter116.Damage:Emit({whichUnit = data112.caster, target = data112.target, amount = damage115, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
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

function SF__.CrusaderStrike.IAbilityData.Equals(self__DamageScaling117, self__ArtOfWarChance118, other__DamageScaling, other__ArtOfWarChance)
    return ((math.abs((self__DamageScaling117 - other__DamageScaling)) < 0.0001) and (math.abs((self__ArtOfWarChance118 - other__ArtOfWarChance)) < 0.0001))
end

function SF__.CrusaderStrike.IAbilityData.GetHashValue(self__DamageScaling119, self__ArtOfWarChance120)
    return 0
end
-- DivineToll
SF__.DivineToll = SF__.DivineToll or {}
function SF__.DivineToll.GetAbilityData(level121)
    return (2 + level121), (50 * level121), 0.1, 10
end

function SF__.DivineToll.Init()
    local EventCenter122 = require("Lib.EventCenter")
    EventCenter122.RegisterPlayerUnitSpellEffect:Emit({id = SF__.DivineToll.ID, handler = SF__.DivineToll.Start})
    ExTriggerRegisterNewUnit(function(u123)
        if (GetUnitTypeId(u123) == FourCC("Hpal")) then
            SF__.DivineToll.UpdateAbilityMeta(u123)
        end
    end)
end

function SF__.DivineToll.UpdateAbilityMeta(u124)
    local p125 = GetOwningPlayer(u124)
    local datas__TargetCount, datas__Damage126, datas__RadiantDmgAmp, datas__Duration127 = {}, {}, {}, {}
    do
        local i128 = 0
        while (i128 < 3) do
            do
                local item__TargetCount, item__Damage129, item__RadiantDmgAmp, item__Duration130 = SF__.DivineToll.GetAbilityData((i128 + 1))
                table.insert(datas__TargetCount, item__TargetCount)
                table.insert(datas__Damage126, item__Damage129)
                table.insert(datas__RadiantDmgAmp, item__RadiantDmgAmp)
                table.insert(datas__Duration127, item__Duration130)
            end
            ::continue::
            i128 = (i128 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p125, SF__.DivineToll.ID, "学习圣洁鸣钟 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p125, SF__.DivineToll.ID, SF__.StrConcat__("对附近的多个目标施展审判，造成法术伤害，然后神圣之锤环绕圣殿骑士，每次命中敌人使其受到的光辉伤害提高。每个审判产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 30秒\n\n|cffffcc001级|r - 审判最多|cffff8c00", datas__TargetCount[(0 + 1)], "|r个目标，造成|cffff8c00", datas__Damage126[(0 + 1)], "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas__RadiantDmgAmp[(0 + 1)] * 100)), "%|r的光辉易伤，持续|cffff8c00", datas__Duration127[(0 + 1)], "|r秒。\n|cffffcc002级|r - 审判最多|cffff8c00", datas__TargetCount[(1 + 1)], "|r个目标，造成|cffff8c00", datas__Damage126[(1 + 1)], "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas__RadiantDmgAmp[(1 + 1)] * 100)), "%|r的光辉易伤，持续|cffff8c00", datas__Duration127[(1 + 1)], "|r秒。\n|cffffcc003级|r - 审判最多|cffff8c00", datas__TargetCount[(2 + 1)], "|r个目标，造成|cffff8c00", datas__Damage126[(2 + 1)], "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas__RadiantDmgAmp[(2 + 1)] * 100)), "%|r的光辉易伤，持续|cffff8c00", datas__Duration127[(2 + 1)], "|r秒。"), 0)
    do
        local i131 = 0
        while (i131 < 3) do
            local data__TargetCount, data__Damage132, data__RadiantDmgAmp, data__Duration133 = datas__TargetCount[(i131 + 1)], datas__Damage126[(i131 + 1)], datas__RadiantDmgAmp[(i131 + 1)], datas__Duration127[(i131 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p125, SF__.DivineToll.ID, SF__.StrConcat__("圣洁鸣钟 - [|cffffcc00", (i131 + 1), "级|r]"), i131)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p125, SF__.DivineToll.ID, SF__.StrConcat__("对附近的最多|cffff8c00", data__TargetCount, "|r个目标施展审判，造成|cffff8c00", data__Damage132, "|r点法术伤害，然后神圣之锤环绕圣殿骑士，每次命中敌人使其受到的光辉伤害提高|cffff8c00", string.format("%.0f", (data__RadiantDmgAmp * 100)), "%|r，持续|cffff8c00", data__Duration133, "|r秒。每个审判产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 30秒"), i131)
            ::continue::
            i131 = (i131 + 1)
        end
    end
end

function SF__.DivineToll.Start(data134)
    local level135 = GetUnitAbilityLevel(data134.caster, SF__.DivineToll.ID)
    local EventCenter138 = require("Lib.EventCenter")
    local ad__TargetCount, ad__Damage136, ad__RadiantDmgAmp, ad__Duration137 = SF__.DivineToll.GetAbilityData(level135)
    EventCenter138.Damage:Emit({whichUnit = data134.caster, target = data134.target, amount = ad__Damage136, attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
    SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(data134.caster, 1)
    -- new BladeOfJustice().StartGroudDamage(data.caster, data.target, ad);
end

function SF__.DivineToll:StartGroudDamage(caster139, target140, ad__TargetCount141, ad__Damage142, ad__RadiantDmgAmp143, ad__Duration144)
    return SF__.CorRun__(function()
        self.x = GetUnitX(target140)
        local UnitAttribute150 = require("Objects.UnitAttribute")
        local EventCenter151 = require("Lib.EventCenter")
        self.y = GetUnitY(target140)
        local eff145 = ExAddSpecialEffect("Abilities/Spells/Orc/LiquidFire/Liquidfire.mdl", self.x, self.y, ad__Duration144)
        local p146 = GetOwningPlayer(caster139)
        do
            local i147 = 0
            while (i147 < ad__Duration144) do
                SF__.CorWait__(1000)
                ExGroupEnumUnitsInRange(self.x, self.y, 300, function(u148)
                    if (not IsUnitEnemy(u148, p146)) then
                        return
                    end
                    if ExIsUnitDead(u148) then
                        return
                    end
                    local tarAttr149 = UnitAttribute150.GetAttr(u148)
                    -- var damage = ad.DamagePerSecond * (1 - tarAttr.radiantResistance);
                    EventCenter151.Damage:Emit({whichUnit = caster139, target = u148, amount = 100, attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
                end)
                ::continue::
                i147 = (i147 + 1)
            end
        end
        DestroyEffect(eff145)
    end)
end

function SF__.DivineToll.__Init(self)
    self.__sf_type = SF__.DivineToll
    self.x = 0
    self.y = 0
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
function SF__.DivineToll.IAbilityData.Equals(self__TargetCount, self__Damage152, self__RadiantDmgAmp, self__Duration153, other__TargetCount, other__Damage154, other__RadiantDmgAmp, other__Duration155)
    return (((math.abs((self__Damage152 - other__Damage154)) < 0.0001) and (math.abs((self__Duration153 - other__Duration155)) < 0.0001)) and (math.abs((self__RadiantDmgAmp - other__RadiantDmgAmp)) < 0.0001))
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
function SF__.Projectile.__Init_6(self, caster, target, model, speed, onHit, casterOffset__x, casterOffset__y)
    self.__sf_type = SF__.Projectile
end

function SF__.Projectile.New_6(caster, target, model, speed, onHit, casterOffset__x, casterOffset__y)
    local self = setmetatable({}, { __index = SF__.Projectile })
    SF__.Projectile.__Init_6(self, caster, target, model, speed, onHit, casterOffset__x, casterOffset__y)
    return self
end

function SF__.Projectile.__Init_6(self, caster3, target__x, target__y, model4, speed5, onHit6, casterOffset__x7, casterOffset__y8)
    self.__sf_type = SF__.Projectile
end

function SF__.Projectile.New_6(caster3, target__x, target__y, model4, speed5, onHit6, casterOffset__x7, casterOffset__y8)
    local self = setmetatable({}, { __index = SF__.Projectile })
    SF__.Projectile.__Init_6(self, caster3, target__x, target__y, model4, speed5, onHit6, casterOffset__x7, casterOffset__y8)
    return self
end
-- RetributionPaladinGlobal
SF__.RetributionPaladinGlobal = SF__.RetributionPaladinGlobal or {}
function SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(u156, amount)
    local UnitAttribute158 = require("Objects.UnitAttribute")
    local attr157 = UnitAttribute158.GetAttr(u156)
    attr157.retPalHolyEnergy = math.min((attr157.retPalHolyEnergy + amount), 5)
end

function SF__.RetributionPaladinGlobal:Init()
    ExTriggerRegisterNewUnit(function(u159)
        if (GetUnitTypeId(u159) == FourCC("Hpal")) then
            SF__.ListAdd__(self._units, u159)
        end
    end)
    _ = self:Start()
end

function SF__.RetributionPaladinGlobal:Start()
    return SF__.CorRun__(function()
        local UnitAttribute162 = require("Objects.UnitAttribute")
        while true do
            do
                local collection6 = self._units
                for i7, u160 in SF__.ListIterate__(collection6) do
                    local attr161 = UnitAttribute162.GetAttr(u160)
                    ExSetUnitMana(u160, ((ExGetUnitMaxMana(u160) * attr161.retPalHolyEnergy) * 0.2))
                    if (attr161.retPalHolyEnergy >= 3) then
                        SF__.Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u160), FourCC("A006"), "ReplaceableTextures/CommandButtons/BTNinv_helmet_96.tga")
                    else
                        SF__.Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u160), FourCC("A006"), "ReplaceableTextures/PassiveButtons/PASBTNinv_helmet_96.tga")
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
function SF__.TemplarStrikes.GetAbilityData(level163)
    return 2, (0.5 + (0.25 * level163)), (0.05 * level163)
end

function SF__.TemplarStrikes.Init()
    local EventCenter164 = require("Lib.EventCenter")
    EventCenter164.RegisterPlayerUnitSpellEffect:Emit({id = SF__.TemplarStrikes.ID, handler = SF__.TemplarStrikes.Start})
    ExTriggerRegisterNewUnit(function(u165)
        if (GetUnitTypeId(u165) == FourCC("Hpal")) then
            SF__.TemplarStrikes.UpdateAbilityMeta(u165)
            SetHeroLevel(u165, 10, true)
        end
    end)
    EventCenter164.RegisterPlayerUnitDamaged:Emit(function(caster166, target167, damage168, weapType, dmgType, isAttack)
        if (GetUnitAbilityLevel(caster166, SF__.TemplarStrikes.ID) <= 0) then
            return
        end
        if (not isAttack) then
            return
        end
        if (target167 == nil) then
            return
        end
        if ExIsUnitDead(target167) then
            return
        end
        SF__.TemplarStrikes.TryResetBOJ(caster166)
    end)
end

function SF__.TemplarStrikes.TryResetBOJ(caster169)
    local level170 = GetUnitAbilityLevel(caster169, SF__.TemplarStrikes.ID)
    local ad__AttackCount, ad__DamageScaling171, ad__ResetBOJChance = SF__.TemplarStrikes.GetAbilityData(level170)
    if (math.random() >= ad__ResetBOJChance) then
        return
    end
    BlzEndUnitAbilityCooldown(caster169, SF__.BladeOfJustice.ID)
    ExAddSpecialEffectTarget("Abilities/Spells/Items/AIam/AIamTarget.mdl", caster169, "origin", 0.3)
end

function SF__.TemplarStrikes.UpdateAbilityMeta(u172)
    local p173 = GetOwningPlayer(u172)
    local datas__AttackCount, datas__DamageScaling174, datas__ResetBOJChance = {}, {}, {}
    do
        local i175 = 0
        while (i175 < SF__.TemplarStrikes.MaxLevel) do
            do
                local item__AttackCount, item__DamageScaling176, item__ResetBOJChance = SF__.TemplarStrikes.GetAbilityData((i175 + 1))
                table.insert(datas__AttackCount, item__AttackCount)
                table.insert(datas__DamageScaling174, item__DamageScaling176)
                table.insert(datas__ResetBOJChance, item__ResetBOJChance)
            end
            ::continue::
            i175 = (i175 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p173, SF__.TemplarStrikes.ID, "学习圣殿骑士之击 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p173, SF__.TemplarStrikes.ID, SF__.StrConcat__("快速攻击目标|cffff8c00", datas__AttackCount[(0 + 1)], "|r次，第一次造成普通攻击伤害，第二次造成光辉伤害，有一定几率重置公正之剑的冷却时间，普通攻击也会触发。\n\n|cff99ccff冷却时间|r - 10秒\n\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling174[(0 + 1)] * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas__ResetBOJChance[(0 + 1)] * 100)), "%|r的几率重置公正之剑。\n|cffffcc002级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling174[(1 + 1)] * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas__ResetBOJChance[(1 + 1)] * 100)), "%|r的几率重置公正之剑。\n|cffffcc003级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling174[(2 + 1)] * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas__ResetBOJChance[(2 + 1)] * 100)), "%|r的几率重置公正之剑。"), 0)
    do
        local i177 = 0
        while (i177 < SF__.TemplarStrikes.MaxLevel) do
            local data__AttackCount, data__DamageScaling178, data__ResetBOJChance = datas__AttackCount[(i177 + 1)], datas__DamageScaling174[(i177 + 1)], datas__ResetBOJChance[(i177 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p173, SF__.TemplarStrikes.ID, SF__.StrConcat__("圣殿骑士之击 - [|cffffcc00", (i177 + 1), "级|r]"), i177)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p173, SF__.TemplarStrikes.ID, SF__.StrConcat__("快速攻击目标|cffff8c00", data__AttackCount, "|r次，第一次造成普通攻击伤害，第二次造成普通攻击|cffff8c00", string.format("%.0f", (data__DamageScaling178 * 100)), "%|r的光辉伤害，|cffff8c00", string.format("%.0f", (data__ResetBOJChance * 100)), "%|r几率重置公正之剑的冷却时间，普通攻击也会触发。\n\n|cff99ccff冷却时间|r - 10秒"), i177)
            ::continue::
            i177 = (i177 + 1)
        end
    end
end

function SF__.TemplarStrikes.Start(data179)
    return SF__.CorRun__(function()
        local level180 = GetUnitAbilityLevel(data179.caster, SF__.TemplarStrikes.ID)
        local UnitAttribute182 = require("Objects.UnitAttribute")
        local EventCenter183 = require("Lib.EventCenter")
        local attr181 = UnitAttribute182.GetAttr(data179.caster)
        local normalDamage = attr181:SimMeleeAttack()
        EventCenter183.Damage:Emit({whichUnit = data179.caster, target = data179.target, amount = normalDamage, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
        SF__.TemplarStrikes.TryResetBOJ(data179.caster)
        SetUnitTimeScale(data179.caster, 3)
        ResetUnitAnimation(data179.caster)
        SetUnitAnimation(data179.caster, "attack - 2")
        SF__.CorWait__(math.round(((1.166 * 0.33) * 1000)))
        local tarAttr184 = UnitAttribute182.GetAttr(data179.target)
        local ad__AttackCount185, ad__DamageScaling186, ad__ResetBOJChance187 = SF__.TemplarStrikes.GetAbilityData(level180)
        local radiantDamage = ((attr181:SimMeleeAttack() * ad__DamageScaling186) * (1 - tarAttr184.radiantResistance))
        EventCenter183.Damage:Emit({whichUnit = data179.caster, target = data179.target, amount = radiantDamage, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
        SF__.TemplarStrikes.TryResetBOJ(data179.caster)
        SetUnitTimeScale(data179.caster, 1)
        ResetUnitAnimation(data179.caster)
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
function SF__.TemplarStrikes.IAbilityData.Equals(self__AttackCount, self__DamageScaling188, self__ResetBOJChance, other__AttackCount, other__DamageScaling189, other__ResetBOJChance)
    return ((math.abs((self__DamageScaling188 - other__DamageScaling189)) < 0.0001) and (math.abs((self__ResetBOJChance - other__ResetBOJChance)) < 0.0001))
end
-- TemplarVerdict
SF__.TemplarVerdict = SF__.TemplarVerdict or {}
function SF__.TemplarVerdict.GetAbilityData(level190)
    return 2.25, 0.3, 0.15
end

function SF__.TemplarVerdict.Init()
    local EventCenter191 = require("Lib.EventCenter")
    EventCenter191.RegisterPlayerUnitSpellChannel:Emit({id = SF__.TemplarVerdict.ID, handler = SF__.TemplarVerdict.Check})
    EventCenter191.RegisterPlayerUnitSpellEffect:Emit({id = SF__.TemplarVerdict.ID, handler = SF__.TemplarVerdict.Start})
    ExTriggerRegisterNewUnit(function(u192)
        if (GetUnitTypeId(u192) == FourCC("Hpal")) then
            SF__.TemplarVerdict.UpdateAbilityMeta(u192)
        end
    end)
end

function SF__.TemplarVerdict.Check(data193)
    local UnitAttribute195 = require("Objects.UnitAttribute")
    local attr194 = UnitAttribute195.GetAttr(data193.caster)
    if (attr194.retPalHolyEnergy < 3) then
        IssueImmediateOrderById(data193.caster, SF__.ConstOrderId.Stop)
        ExTextState(data193.caster, "圣能不足")
    end
end

function SF__.TemplarVerdict.UpdateAbilityMeta(u196)
    local p197 = GetOwningPlayer(u196)
    local datas__DamageScaling198, datas__JudgementDamageScaling, datas__ChanceToResetJudgement = {}, {}, {}
    do
        local i199 = 0
        while (i199 < 1) do
            do
                local item__DamageScaling200, item__JudgementDamageScaling, item__ChanceToResetJudgement = SF__.TemplarVerdict.GetAbilityData((i199 + 1))
                table.insert(datas__DamageScaling198, item__DamageScaling200)
                table.insert(datas__JudgementDamageScaling, item__JudgementDamageScaling)
                table.insert(datas__ChanceToResetJudgement, item__ChanceToResetJudgement)
            end
            ::continue::
            i199 = (i199 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p197, SF__.TemplarVerdict.ID, "学习圣殿骑士的裁决 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p197, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决造成一次攻击伤害，如果目标被审判，造成30%的额外伤害，15%几率重置审判。消耗|cffff8c003|r点圣能。\n\n|cff99ccff冷却时间|r - 5秒\n\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas__JudgementDamageScaling[(0 + 1)] * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas__ChanceToResetJudgement[(0 + 1)] * 100)), "%的战争艺术触发几率。"), 0)
    do
        local i201 = 0
        while (i201 < 1) do
            local data__DamageScaling202, data__JudgementDamageScaling, data__ChanceToResetJudgement = datas__DamageScaling198[(i201 + 1)], datas__JudgementDamageScaling[(i201 + 1)], datas__ChanceToResetJudgement[(i201 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p197, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决 - [|cffffcc00", (i201 + 1), "级|r]"), i201)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p197, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决造成一次攻击伤害，造成|cffff8c00", string.format("%.0f", (data__DamageScaling202 * 100)), "%|r的攻击伤害。消耗|cffff8c003|r点圣能。\n\n|cff99ccff冷却时间|r - 5秒"), i201)
            ::continue::
            i201 = (i201 + 1)
        end
    end
end

function SF__.TemplarVerdict.Start(data203)
    local level204 = GetUnitAbilityLevel(data203.caster, SF__.TemplarVerdict.ID)
    local UnitAttribute207 = require("Objects.UnitAttribute")
    local EventCenter209 = require("Lib.EventCenter")
    local ad__DamageScaling205, ad__JudgementDamageScaling, ad__ChanceToResetJudgement = SF__.TemplarVerdict.GetAbilityData(level204)
    local attr206 = UnitAttribute207.GetAttr(data203.caster)
    local damage208 = (attr206:SimAttack(UnitAttribute207.HeroAttributeType.Strength) * ad__DamageScaling205)
    EventCenter209.Damage:Emit({whichUnit = data203.caster, target = data203.target, amount = damage208, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_SLICE, outResult = {}})
    attr206.retPalHolyEnergy = (attr206.retPalHolyEnergy - 3)
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
function SF__.TemplarVerdict.IAbilityData.Equals(self__DamageScaling210, self__JudgementDamageScaling, self__ChanceToResetJudgement, other__DamageScaling211, other__JudgementDamageScaling, other__ChanceToResetJudgement)
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

function SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p10, abilCode11, researchExtendedTooltip, level12)
    if (GetLocalPlayer() ~= p10) then
        return
    end
    BlzSetAbilityResearchExtendedTooltip(abilCode11, researchExtendedTooltip, level12)
end

function SF__.Utils.ExBlzSetAbilityTooltip(p13, abilCode14, tooltip, level15)
    if (GetLocalPlayer() ~= p13) then
        return
    end
    BlzSetAbilityTooltip(abilCode14, tooltip, level15)
end

function SF__.Utils.ExBlzSetAbilityExtendedTooltip(p16, abilCode17, extendedTooltip, level18)
    if (GetLocalPlayer() ~= p16) then
        return
    end
    BlzSetAbilityExtendedTooltip(abilCode17, extendedTooltip, level18)
end

function SF__.Utils.ExBlzSetAbilityIcon(p19, abilCode20, iconPath)
    if (GetLocalPlayer() ~= p19) then
        return
    end
    BlzSetAbilityIcon(abilCode20, iconPath)
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
    return {x = 0, y = 0}
end

function SF__.Vector2.InsideUnitCircle()
    local angle = ((math.random() * 2) * math.pi)
    return math.cos(angle), math.sin(angle)
end

function SF__.Vector2.Dot(a__x, a__y, b__x, b__y)
    return ((a__x * b__x) + (a__y * b__y))
end

function SF__.Vector2.Cross(a__x21, a__y22, b__x23, b__y24)
    return ((a__y22 * b__x23) - (a__x21 * b__y24))
end

function SF__.Vector2.op_UnaryNegation(a__x25, a__y26)
    return (-a__x25), (-a__y26)
end

function SF__.Vector2.op_Addition(a__x27, a__y28, b__x29, b__y30)
    return (a__x27 + b__x29), (a__y28 + b__y30)
end

function SF__.Vector2.op_Subtraction(a__x31, a__y32, b__x33, b__y34)
    return (a__x31 - b__x33), (a__y32 - b__y34)
end

function SF__.Vector2.op_Multiply(v__x, v__y, f)
    return (v__x * f), (v__y * f)
end

function SF__.Vector2.op_Multiply(f35, v__x36, v__y37)
    return (v__x36 * f35), (v__y37 * f35)
end

function SF__.Vector2.op_Division(v__x38, v__y39, f40)
    return (v__x38 / f40), (v__y39 / f40)
end

function SF__.Vector2.op_Equality(a__x41, a__y42, b__x43, b__y44)
    return ((math.abs((a__x41 - b__x43)) < 0.0001) and (math.abs((a__y42 - b__y44)) < 0.0001))
end

function SF__.Vector2.op_Inequality(a__x45, a__y46, b__x47, b__y48)
    return (not SF__.Vector2.op_Equality(a__x45, a__y46, b__x47, b__y48))
end

function SF__.Vector2.UnitDistance(a, b)
    local v1__x, v1__y = SF__.Vector2.FromUnit(a)
    local v2__x, v2__y = SF__.Vector2.FromUnit(b)
    return SF__.Vector2.get_Magnitude(SF__.Vector2.op_Subtraction(v1__x, v1__y, v2__x, v2__y))
end

function SF__.Vector2.SqrUnitDistance(a49, b50)
    local v1__x51, v1__y52 = SF__.Vector2.FromUnit(a49)
    local v2__x53, v2__y54 = SF__.Vector2.FromUnit(b50)
    return SF__.Vector2.get_SqrMagnitude(SF__.Vector2.op_Subtraction(v1__x51, v1__y52, v2__x53, v2__y54))
end

function SF__.Vector2.FromUnit(u)
    return GetUnitX(u), GetUnitY(u)
end

function SF__.Vector2.get_Magnitude(self__x, self__y)
    return math.sqrt(SF__.Vector2.get_SqrMagnitude(self__x, self__y))
end

function SF__.Vector2.get_SqrMagnitude(self__x55, self__y56)
    return ((self__x55 * self__x55) + (self__y56 * self__y56))
end

function SF__.Vector2.get_Normalized(self__x57, self__y58)
    local mag = SF__.Vector2.get_Magnitude(self__x57, self__y58)
    if (mag < 0.0001) then
        return SF__.Vector2.get_Zero()
    end
    return SF__.Vector2.op_Division(self__x57, self__y58, mag)
end

function SF__.Vector2.SetMagnitude(self__x59, self__y60, mag61)
    return SF__.Vector2.op_Multiply(SF__.Vector2.get_Normalized(self__x59, self__y60).x, SF__.Vector2.get_Normalized(self__x59, self__y60).y, mag61)
end

function SF__.Vector2.Equals(self__x62, self__y63, other__x, other__y)
    return SF__.Vector2.op_Equality(self__x62, self__y63, other__x, other__y)
end

function SF__.Vector2.ToString(self__x64, self__y65)
    return SF__.StrConcat__("(", self__x64, ", ", self__y65, ")")
end

function SF__.Vector2.Rotate(self__x66, self__y67, angle68)
    local cos = math.cos(angle68)
    local sin = math.sin(angle68)
    return ((self__x66 * cos) - (self__y67 * sin)), ((self__x66 * sin) + (self__y67 * cos))
end

function SF__.Vector2.UnitMoveTo(self__x69, self__y70, u71)
    SetUnitX(u71, self__x69)
    SetUnitY(u71, self__y70)
end

function SF__.Vector2.GetTerrainZ(self__x72, self__y73)
    MoveLocation(SF__.Vector2._loc, self__x72, self__y73)
    return GetLocationZ(SF__.Vector2._loc)
end

SF__.Vector2._loc = Location(0, 0)
-- Vector3
SF__.Vector3 = SF__.Vector3 or {}
function SF__.Vector3.GetTerrainZ(x74, y75)
    MoveLocation(SF__.Vector3._loc, x74, y75)
    return GetLocationZ(SF__.Vector3._loc)
end

function SF__.Vector3.FromUnit(u76)
    local x77 = GetUnitX(u76)
    local y78 = GetUnitY(u76)
    return x77, y78, (SF__.Vector3.GetTerrainZ(x77, y78) + GetUnitFlyHeight(u76))
end

function SF__.Vector3.UnitMoveTo(self__x81, self__y82, self__z, u83, mode)
    local tz = SF__.Vector3.GetTerrainZ(self__x81, self__y82)
    local LuaUtils = require("Lib.Utils")
    local defaultFlyHeight = GetUnitDefaultFlyHeight(u83)
    local minZ = (tz + defaultFlyHeight)
    SetUnitPosition(u83, self__x81, self__y82)
    repeat
        local switchValue = mode
        if (switchValue == SF__.UnitVec3Mode.ForceFlying) then
            LuaUtils.SetUnitFlyable(u83)
            SetUnitFlyHeight(u83, (math.max(minZ, self__z) - minZ), 0)
            break
        elseif (switchValue == SF__.UnitVec3Mode.ForceGround) then
            SetUnitFlyHeight(u83, defaultFlyHeight, 0)
            break
        elseif (switchValue == SF__.UnitVec3Mode.Auto) then
            if IsUnitType(u83, UNIT_TYPE_FLYING) then
                SetUnitFlyHeight(u83, (math.max(minZ, self__z) - minZ), 0)
            else
                SetUnitFlyHeight(u83, defaultFlyHeight, 0)
            end
            break
        end
    until true
end

function SF__.Vector3.Equals(self__x84, self__y85, self__z86, other__x87, other__y88, other__z)
    return true
end

SF__.Vector3._loc = Location(0, 0)
-- WordOfGlory
SF__.WordOfGlory = SF__.WordOfGlory or {}
function SF__.WordOfGlory.Init()
    local EventCenter212 = require("Lib.EventCenter")
    EventCenter212.RegisterPlayerUnitSpellChannel:Emit({id = SF__.WordOfGlory.ID, handler = SF__.WordOfGlory.Check})
    EventCenter212.RegisterPlayerUnitSpellEffect:Emit({id = SF__.WordOfGlory.ID, handler = SF__.WordOfGlory.Start})
    ExTriggerRegisterNewUnit(function(u213)
        if (GetUnitTypeId(u213) == FourCC("Hpal")) then
            SF__.WordOfGlory.UpdateAbilityMeta(u213)
        end
    end)
end

function SF__.WordOfGlory.Check(data214)
    local UnitAttribute216 = require("Objects.UnitAttribute")
    local attr215 = UnitAttribute216.GetAttr(data214.caster)
    if (attr215.retPalHolyEnergy < 3) then
        IssueImmediateOrderById(data214.caster, SF__.ConstOrderId.Stop)
        ExTextState(data214.caster, "圣能不足")
    end
end

function SF__.WordOfGlory.UpdateAbilityMeta(u217)
    local p218 = GetOwningPlayer(u217)
    SF__.Utils.ExSetAbilityResearchTooltip(p218, SF__.WordOfGlory.ID, "学习圣殿骑士的裁决 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p218, SF__.WordOfGlory.ID, "圣殿骑士的裁决造成一次攻击伤害，如果目标被审判，造成30%的额外伤害，15%几率重置审判。消耗|cffff8c003|r点圣能。\n\n|cff99ccff冷却时间|r - 5秒\n\n|cffffcc001级|r - |cffff8c00100%|r的攻击伤害，100%的战争艺术触发几率。", 0)
    do
        local i219 = 0
        while (i219 < 1) do
            SF__.Utils.ExBlzSetAbilityTooltip(p218, SF__.WordOfGlory.ID, SF__.StrConcat__("圣殿骑士的裁决 - [|cffffcc00", (i219 + 1), "级|r]"), i219)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p218, SF__.WordOfGlory.ID, "圣殿骑士的裁决造成一次攻击伤害，造成|cffff8c00100%|r的攻击伤害。消耗|cffff8c003|r点圣能。\n\n|cff99ccff冷却时间|r - 5秒", i219)
            ::continue::
            i219 = (i219 + 1)
        end
    end
end

function SF__.WordOfGlory.Start(data220)
    local UnitAttribute222 = require("Objects.UnitAttribute")
    local EventCenter223 = require("Lib.EventCenter")
    local attr221 = UnitAttribute222.GetAttr(data220.caster)
    EventCenter223.Heal:Emit({caster = data220.caster, target = data220.target, amount = 300})
    attr221.retPalHolyEnergy = (attr221.retPalHolyEnergy - 3)
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
