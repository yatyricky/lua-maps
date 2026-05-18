SF__ = SF__ or {}
function SF__.TypeIs__(obj, target)
    if obj == nil then return false end
    local type = obj.__sf_type
    while type ~= nil do
        if type == target then return true end
        if type.__sf_interfaces ~= nil and type.__sf_interfaces[target] then return true end
        type = type.__sf_base
    end
    return false
end

function SF__.TypeAs__(obj, target)
    if SF__.TypeIs__(obj, target) then return obj end
    return nil
end

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

function SF__.ListIndexOf__(list, value, equals)
    local stored = SF__.ListWrap__(value)
    for i, item in ipairs(list.items) do
        if equals ~= nil then
            if equals(SF__.ListUnwrap__(item), value) then return i - 1 end
        else
            if item == stored then return i - 1 end
        end
    end
    return -1
end

function SF__.ListRemoveAt__(list, index)
    table.remove(list.items, index + 1)
    list.version = list.version + 1
end

function SF__.ListRemove__(list, value, equals)
    local index = SF__.ListIndexOf__(list, value, equals)
    if index >= 0 then
        SF__.ListRemoveAt__(list, index)
        return true
    end
    return false
end

function SF__.ListRemoveAll__(list, match)
    local removed = 0
    for i = #list.items, 1, -1 do
        if match(SF__.ListUnwrap__(list.items[i])) then
            table.remove(list.items, i)
            removed = removed + 1
        end
    end
    if removed > 0 then list.version = list.version + 1 end
    return removed
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
function SF__.BladeOfJustice.GetAbilityData(level193)
    return (75 * level193), 5, (10 * level193)
end

function SF__.BladeOfJustice.Init()
    local EventCenter = require("Lib.EventCenter")
    EventCenter.RegisterPlayerUnitSpellEffect:Emit({id = SF__.BladeOfJustice.ID, handler = SF__.BladeOfJustice.Start})
    ExTriggerRegisterNewUnit(function(u194)
        if (GetUnitTypeId(u194) == FourCC("Hpal")) then
            SF__.BladeOfJustice.UpdateAbilityMeta(u194)
        end
    end)
end

function SF__.BladeOfJustice.UpdateAbilityMeta(u195)
    local p196 = GetOwningPlayer(u195)
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
    SF__.Utils.ExSetAbilityResearchTooltip(p196, SF__.BladeOfJustice.ID, "学习公正之剑 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p196, SF__.BladeOfJustice.ID, SF__.StrConcat__("用圣光的利刃刺穿目标，造成法术伤害，在一定时间内对附近敌人每秒造成光辉伤害。产生|cffff8c001|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 10秒\r\n\r\n|cffffcc001级|r - 造成|cffff8c00", datas__Damage[(0 + 1)], "|r的直接法术伤害，|cffff8c00", datas__Duration[(0 + 1)], "|r秒内对附近敌人每秒造成|cffff8c00", datas__DamagePerSecond[(0 + 1)], "|r的光辉伤害。产生|cffff8c001|r点圣能。\r\n|cffffcc002级|r - 造成|cffff8c00", datas__Damage[(1 + 1)], "|r的直接法术伤害，|cffff8c00", datas__Duration[(1 + 1)], "|r秒内对附近敌人每秒造成|cffff8c00", datas__DamagePerSecond[(1 + 1)], "|r的光辉伤害。产生|cffff8c001|r点圣能。\r\n|cffffcc003级|r - 造成|cffff8c00", datas__Damage[(2 + 1)], "|r的直接法术伤害，|cffff8c00", datas__Duration[(2 + 1)], "|r秒内对附近敌人每秒造成|cffff8c00", datas__DamagePerSecond[(2 + 1)], "|r的光辉伤害。产生|cffff8c001|r点圣能。"), 0)
    do
        local i197 = 0
        while (i197 < 3) do
            local data__Damage, data__Duration, data__DamagePerSecond = datas__Damage[(i197 + 1)], datas__Duration[(i197 + 1)], datas__DamagePerSecond[(i197 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p196, SF__.BladeOfJustice.ID, SF__.StrConcat__("公正之剑 - [|cffffcc00", (i197 + 1), "级|r]"), i197)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p196, SF__.BladeOfJustice.ID, SF__.StrConcat__("用圣光的利刃刺穿目标，造成|cffff8c00", data__Damage, "|r的直接法术伤害，在|cffff8c00", data__Duration, "|r秒内对附近敌人每秒造成|cffff8c00", data__DamagePerSecond, "|r的光辉伤害。产生|cffff8c001|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 10秒"), i197)
            ::continue::
            i197 = (i197 + 1)
        end
    end
end

function SF__.BladeOfJustice.Start(data)
    local level198 = GetUnitAbilityLevel(data.caster, SF__.BladeOfJustice.ID)
    local EventCenter199 = require("Lib.EventCenter")
    local ad__Damage, ad__Duration, ad__DamagePerSecond = SF__.BladeOfJustice.GetAbilityData(level198)
    EventCenter199.Damage:Emit({whichUnit = data.caster, target = data.target, amount = ad__Damage, attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
    SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(data.caster, 1)
    SF__.BladeOfJustice.New():StartGroudDamage(data.caster, data.target, ad__Damage, ad__Duration, ad__DamagePerSecond)
end

function SF__.BladeOfJustice:StartGroudDamage(caster, target, ad__Damage200, ad__Duration201, ad__DamagePerSecond202)
    return SF__.CorRun__(function()
        local pos__x, pos__y = SF__.Vector2.FromUnit(target)
        local UnitAttribute = require("Objects.UnitAttribute")
        local EventCenter206 = require("Lib.EventCenter")
        local eff = ExAddSpecialEffect("Abilities/Spells/Orc/LiquidFire/Liquidfire.mdl", pos__x, pos__y, ad__Duration201)
        local p203 = GetOwningPlayer(caster)
        do
            local i204 = 0
            while (i204 < ad__Duration201) do
                SF__.CorWait__(1000)
                ExGroupEnumUnitsInRange(pos__x, pos__y, 300, function(u205)
                    if (not IsUnitEnemy(u205, p203)) then
                        return
                    end
                    if ExIsUnitDead(u205) then
                        return
                    end
                    local tarAttr = UnitAttribute.GetAttr(u205)
                    local damage = (ad__DamagePerSecond202 * (1 - tarAttr.radiantResistance))
                    EventCenter206.Damage:Emit({whichUnit = caster, target = u205, amount = damage, attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
                end)
                ::continue::
                i204 = (i204 + 1)
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
-- Component
SF__.Component = SF__.Component or {}
function SF__.Component.__Init(self)
    self.__sf_type = SF__.Component
end

function SF__.Component.New()
    local self = setmetatable({}, { __index = SF__.Component })
    SF__.Component.__Init(self)
    return self
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
function SF__.CrusaderStrike.GetAbilityData(level207)
    return (0.65 + (0.35 * level207)), (0.15 * (level207 - 1))
end

function SF__.CrusaderStrike.Init()
    local EventCenter208 = require("Lib.EventCenter")
    EventCenter208.RegisterPlayerUnitSpellEffect:Emit({id = SF__.CrusaderStrike.ID, handler = SF__.CrusaderStrike.Start})
    ExTriggerRegisterNewUnit(function(u209)
        if (GetUnitTypeId(u209) == FourCC("Hpal")) then
            SF__.CrusaderStrike.UpdateAbilityMeta(u209)
        end
    end)
end

function SF__.CrusaderStrike.UpdateAbilityMeta(u210)
    local p211 = GetOwningPlayer(u210)
    local datas__DamageScaling, datas__ArtOfWarChance = {}, {}
    do
        local i212 = 0
        while (i212 < 3) do
            do
                local item__DamageScaling, item__ArtOfWarChance = SF__.CrusaderStrike.GetAbilityData((i212 + 1))
                table.insert(datas__DamageScaling, item__DamageScaling)
                table.insert(datas__ArtOfWarChance, item__ArtOfWarChance)
            end
            ::continue::
            i212 = (i212 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p211, SF__.CrusaderStrike.ID, "学习十字军打击 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p211, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击造成一次攻击伤害，伤害系数随技能等级提升。产生|cffff8c001|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 6秒\r\n\r\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling[(0 + 1)] * 100)), "%|r的攻击伤害。\r\n|cffffcc002级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling[(1 + 1)] * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas__ArtOfWarChance[(1 + 1)] * 100)), "%的战争艺术触发几率。\r\n|cffffcc003级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling[(2 + 1)] * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas__ArtOfWarChance[(2 + 1)] * 100)), "%的战争艺术触发几率。"), 0)
    do
        local i213 = 0
        while (i213 < 3) do
            local data__DamageScaling, data__ArtOfWarChance = datas__DamageScaling[(i213 + 1)], datas__ArtOfWarChance[(i213 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p211, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击 - [|cffffcc00", (i213 + 1), "级|r]"), i213)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p211, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击造成一次攻击伤害，造成|cffff8c00", string.format("%.0f", (data__DamageScaling * 100)), "%|r的攻击伤害", SF__.Ternary__((i213 > 0), SF__.StrConcat__("，", string.format("%.0f", (data__ArtOfWarChance * 100)), "%的战争艺术触发几率"), ""), "。产生|cffff8c001|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 6秒"), i213)
            ::continue::
            i213 = (i213 + 1)
        end
    end
    -- datas.Remove(new IAbilityData { DamageScaling = 0.65f, ArtOfWarChance = 0 });
    do
        local index = 0
        table.remove(datas__DamageScaling, (index + 1))
        table.remove(datas__ArtOfWarChance, (index + 1))
    end
end

function SF__.CrusaderStrike.Start(data214)
    local level215 = GetUnitAbilityLevel(data214.caster, SF__.CrusaderStrike.ID)
    local UnitAttribute216 = require("Objects.UnitAttribute")
    local EventCenter218 = require("Lib.EventCenter")
    local ad__DamageScaling, ad__ArtOfWarChance = SF__.CrusaderStrike.GetAbilityData(level215)
    local attr = UnitAttribute216.GetAttr(data214.caster)
    local damage217 = (attr:SimAttack(UnitAttribute216.HeroAttributeType.Strength) * ad__DamageScaling)
    EventCenter218.Damage:Emit({whichUnit = data214.caster, target = data214.target, amount = damage217, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
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

function SF__.CrusaderStrike.IAbilityData.Equals(self__DamageScaling219, self__ArtOfWarChance220, other__DamageScaling, other__ArtOfWarChance)
    return ((math.abs((self__DamageScaling219 - other__DamageScaling)) < 0.0001) and (math.abs((self__ArtOfWarChance220 - other__ArtOfWarChance)) < 0.0001))
end

function SF__.CrusaderStrike.IAbilityData.GetHashValue(self__DamageScaling221, self__ArtOfWarChance222)
    return 0
end
-- DivineToll
SF__.DivineToll = SF__.DivineToll or {}
function SF__.DivineToll.GetAbilityData(level223)
    return (2 + level223), (50 * level223), 0.1, 10
end

function SF__.DivineToll.Init()
    local EventCenter225 = require("Lib.EventCenter")
    EventCenter225.RegisterPlayerUnitSpellEffect:Emit({id = SF__.DivineToll.ID, handler = function(data224)
        SF__.DivineToll.Start(data224)
    end})
    ExTriggerRegisterNewUnit(function(u226)
        if (GetUnitTypeId(u226) == FourCC("Hpal")) then
            SF__.DivineToll.UpdateAbilityMeta(u226)
        end
    end)
end

function SF__.DivineToll.UpdateAbilityMeta(u227)
    local p228 = GetOwningPlayer(u227)
    local datas__TargetCount, datas__Damage229, datas__RadiantDmgAmp, datas__Duration230 = {}, {}, {}, {}
    do
        local i231 = 0
        while (i231 < 3) do
            do
                local item__TargetCount, item__Damage232, item__RadiantDmgAmp, item__Duration233 = SF__.DivineToll.GetAbilityData((i231 + 1))
                table.insert(datas__TargetCount, item__TargetCount)
                table.insert(datas__Damage229, item__Damage232)
                table.insert(datas__RadiantDmgAmp, item__RadiantDmgAmp)
                table.insert(datas__Duration230, item__Duration233)
            end
            ::continue::
            i231 = (i231 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p228, SF__.DivineToll.ID, "学习圣洁鸣钟 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p228, SF__.DivineToll.ID, SF__.StrConcat__("对附近的多个目标施展审判，造成法术伤害，然后神圣之锤环绕圣殿骑士，每次命中敌人使其受到的光辉伤害提高。每个审判产生|cffff8c001|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 30秒\r\n\r\n|cffffcc001级|r - 审判最多|cffff8c00", datas__TargetCount[(0 + 1)], "|r个目标，造成|cffff8c00", datas__Damage229[(0 + 1)], "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas__RadiantDmgAmp[(0 + 1)] * 100)), "%|r的光辉易伤，持续|cffff8c00", datas__Duration230[(0 + 1)], "|r秒。\r\n|cffffcc002级|r - 审判最多|cffff8c00", datas__TargetCount[(1 + 1)], "|r个目标，造成|cffff8c00", datas__Damage229[(1 + 1)], "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas__RadiantDmgAmp[(1 + 1)] * 100)), "%|r的光辉易伤，持续|cffff8c00", datas__Duration230[(1 + 1)], "|r秒。\r\n|cffffcc003级|r - 审判最多|cffff8c00", datas__TargetCount[(2 + 1)], "|r个目标，造成|cffff8c00", datas__Damage229[(2 + 1)], "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas__RadiantDmgAmp[(2 + 1)] * 100)), "%|r的光辉易伤，持续|cffff8c00", datas__Duration230[(2 + 1)], "|r秒。"), 0)
    do
        local i234 = 0
        while (i234 < 3) do
            local data__TargetCount, data__Damage235, data__RadiantDmgAmp, data__Duration236 = datas__TargetCount[(i234 + 1)], datas__Damage229[(i234 + 1)], datas__RadiantDmgAmp[(i234 + 1)], datas__Duration230[(i234 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p228, SF__.DivineToll.ID, SF__.StrConcat__("圣洁鸣钟 - [|cffffcc00", (i234 + 1), "级|r]"), i234)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p228, SF__.DivineToll.ID, SF__.StrConcat__("对附近的最多|cffff8c00", data__TargetCount, "|r个目标施展审判，造成|cffff8c00", data__Damage235, "|r点法术伤害，然后神圣之锤环绕圣殿骑士，每次命中敌人使其受到的光辉伤害提高|cffff8c00", string.format("%.0f", (data__RadiantDmgAmp * 100)), "%|r，持续|cffff8c00", data__Duration236, "|r秒。每个审判产生|cffff8c001|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 30秒"), i234)
            ::continue::
            i234 = (i234 + 1)
        end
    end
end

function SF__.DivineToll.Start(data237)
    return SF__.CorRun__(function()
        local pos__x238, pos__y239 = SF__.Vector2.FromUnit(data237.caster)
        local eff240 = AddSpecialEffect("Abilities/Spells/Human/StormBolt/StormBoltMissile.mdl", pos__x238, pos__y239)
        while true do
            SF__.CorWait__(16)
            local rotation__x, rotation__y, rotation__z, rotation__w = SF__.Quaternion.Euler(0, 90, 0)
            ::continue::
        end
    end)
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
function SF__.DivineToll.IAbilityData.Equals(self__TargetCount, self__Damage241, self__RadiantDmgAmp, self__Duration242, other__TargetCount, other__Damage243, other__RadiantDmgAmp, other__Duration244)
    return (((math.abs((self__Damage241 - other__Damage243)) < 0.0001) and (math.abs((self__Duration242 - other__Duration244)) < 0.0001)) and (math.abs((self__RadiantDmgAmp - other__RadiantDmgAmp)) < 0.0001))
end
-- GameObject
SF__.GameObject = SF__.GameObject or {}
function SF__.GameObject.__Init(self, name)
    self.__sf_type = SF__.GameObject
    self.name = nil
    self.transform = nil
    self._components = SF__.ListNew__({})
    self.name = name
    self.transform = self:AddComponent(SF__.Transform)
end

function SF__.GameObject.New(name)
    local self = setmetatable({}, { __index = SF__.GameObject })
    SF__.GameObject.__Init(self, name)
    return self
end

function SF__.GameObject:GetComponent(T)
    do
        local collection = self._components
        for i1, comp in SF__.ListIterate__(collection) do
            do
                local tComp = comp
                if SF__.TypeIs__(tComp, T) then
                    return tComp
                end
            end
        end
    end
    return nil
end

function SF__.GameObject:AddComponent(T3)
    local comp4 = T3.New()
    SF__.ListAdd__(self._components, comp4)
    return comp4
end

function SF__.GameObject:RemoveComponent(T5)
    SF__.ListRemoveAll__(self._components, function(c)
        return SF__.TypeIs__(c, T5)
    end)
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
        local collection2 = systems
        for i3, system in SF__.ListIterate__(collection2) do
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
        local collection4 = systems
        for i5, system1 in SF__.ListIterate__(collection4) do
            system1:OnEnable()
        end
    end
    local game = FrameTimer.new(function(dt)
        local now = (MathRound((Time.Time * 100)) * 0.01)
        do
            local collection6 = systems
            for i7, system2 in SF__.ListIterate__(collection6) do
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
-- Quaternion
SF__.Quaternion = SF__.Quaternion or {}
function SF__.Quaternion.get_Identity()
    return 0, 0, 0, 1
end

function SF__.Quaternion.op_Multiply(q__x, q__y, q__z, q__w, v__x, v__y, v__z)
    -- https://en.wikipedia.org/wiki/Quaternions_and_spatial_rotation#Using_quaternion_as_rotations
    local u__x, u__y, u__z = q__x, q__y, q__z
    local s = q__w
    return SF__.Vector3.op_Addition(SF__.Vector3.op_Addition(SF__.Vector3.op_Multiply__fvector3((2 * SF__.Vector3.Dot(u__x, u__y, u__z, v__x, v__y, v__z)), u__x, u__y, u__z), SF__.Vector3.op_Multiply__fvector3(((s * s) - SF__.Vector3.Dot(u__x, u__y, u__z, u__x, u__y, u__z)), v__x, v__y, v__z)), SF__.Vector3.op_Multiply__fvector3((2 * s), SF__.Vector3.Cross(u__x, u__y, u__z, v__x, v__y, v__z)))
end

function SF__.Quaternion.Euler(pitch, yaw, roll)
    pitch = (pitch * bj_DEGTORAD)
    yaw = (yaw * bj_DEGTORAD)
    roll = (roll * bj_DEGTORAD)
    -- https://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles#Source_Code_2
    local cy = math.cos((yaw * 0.5))
    local sy = math.sin((yaw * 0.5))
    local cp = math.cos((pitch * 0.5))
    local sp = math.sin((pitch * 0.5))
    local cr = math.cos((roll * 0.5))
    local sr = math.sin((roll * 0.5))
    return (((sr * cp) * cy) - ((cr * sp) * sy)), (((cr * sp) * cy) + ((sr * cp) * sy)), (((cr * cp) * sy) - ((sr * sp) * cy)), (((cr * cp) * cy) + ((sr * sp) * sy))
end

function SF__.Quaternion.get_EulerAngles(self__x, self__y, self__z, self__w)
    -- https://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles#Source_Code_2
    local sinr_cosp = (2 * ((self__w * self__x) + (self__y * self__z)))
    local cosr_cosp = (1 - (2 * ((self__x * self__x) + (self__y * self__y))))
    local roll7 = math.atan2(sinr_cosp, cosr_cosp)
    local sinp = (2 * ((self__w * self__y) - (self__z * self__x)))
    local pitch8
    if (math.abs(sinp) >= 1) then
        pitch8 = ((math.sign(sinp) * math.pi) / 2)
        -- use 90 degrees if out of range
    else
        pitch8 = math.asin(sinp)
    end
    local siny_cosp = (2 * ((self__w * self__z) + (self__x * self__y)))
    local cosy_cosp = (1 - (2 * ((self__y * self__y) + (self__z * self__z))))
    local yaw9 = math.atan2(siny_cosp, cosy_cosp)
    return pitch8, yaw9, roll7
end

function SF__.Quaternion.Equals(self__x10, self__y11, self__z12, self__w13, other__x, other__y, other__z, other__w)
    return ((((math.abs((self__x10 - other__x)) < 0.0001) and (math.abs((self__y11 - other__y)) < 0.0001)) and (math.abs((self__z12 - other__z)) < 0.0001)) and (math.abs((self__w13 - other__w)) < 0.0001))
end

function SF__.Quaternion.ToString(self__x14, self__y15, self__z16, self__w17)
    return SF__.StrConcat__("(", self__x14, ", ", self__y15, ", ", self__z16, ", ", self__w17, ")")
end

function SF__.Quaternion.ApplyToEffect(self__x18, self__y19, self__z20, self__w21, e)
    local angles__x, angles__y, angles__z = SF__.Quaternion.get_EulerAngles(self__x18, self__y19, self__z20, self__w21)
    BlzSetSpecialEffectOrientation(e, angles__x, angles__y, angles__z)
end
-- RetributionPaladinGlobal
SF__.RetributionPaladinGlobal = SF__.RetributionPaladinGlobal or {}
function SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(u245, amount)
    local UnitAttribute247 = require("Objects.UnitAttribute")
    local attr246 = UnitAttribute247.GetAttr(u245)
    attr246.retPalHolyEnergy = math.min((attr246.retPalHolyEnergy + amount), 5)
end

function SF__.RetributionPaladinGlobal:Init()
    ExTriggerRegisterNewUnit(function(u248)
        if (GetUnitTypeId(u248) == FourCC("Hpal")) then
            SF__.ListAdd__(self._units, u248)
        end
    end)
    _ = self:Start()
end

function SF__.RetributionPaladinGlobal:Start()
    return SF__.CorRun__(function()
        local UnitAttribute251 = require("Objects.UnitAttribute")
        while true do
            do
                local collection8 = self._units
                for i9, u249 in SF__.ListIterate__(collection8) do
                    local attr250 = UnitAttribute251.GetAttr(u249)
                    ExSetUnitMana(u249, ((ExGetUnitMaxMana(u249) * attr250.retPalHolyEnergy) * 0.2))
                    if (attr250.retPalHolyEnergy >= 3) then
                        SF__.Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u249), FourCC("A006"), "ReplaceableTextures/CommandButtons/BTNinv_helmet_96.tga")
                    else
                        SF__.Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u249), FourCC("A006"), "ReplaceableTextures/PassiveButtons/PASBTNinv_helmet_96.tga")
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
local SystemBase6 = require("System.SystemBase")
SF__.Systems.MeleeGameSystem = SF__.Systems.MeleeGameSystem or class("MeleeGameSystem", SystemBase6)
SF__.Systems.MeleeGameSystem.__sf_base = SystemBase6
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
function SF__.TemplarStrikes.GetAbilityData(level252)
    return 2, (0.5 + (0.25 * level252)), (0.05 * level252)
end

function SF__.TemplarStrikes.Init()
    local EventCenter253 = require("Lib.EventCenter")
    EventCenter253.RegisterPlayerUnitSpellEffect:Emit({id = SF__.TemplarStrikes.ID, handler = SF__.TemplarStrikes.Start})
    ExTriggerRegisterNewUnit(function(u254)
        if (GetUnitTypeId(u254) == FourCC("Hpal")) then
            SF__.TemplarStrikes.UpdateAbilityMeta(u254)
            SetHeroLevel(u254, 10, true)
        end
    end)
    EventCenter253.RegisterPlayerUnitDamaged:Emit(function(caster255, target256, damage257, weapType, dmgType, isAttack)
        if (GetUnitAbilityLevel(caster255, SF__.TemplarStrikes.ID) <= 0) then
            return
        end
        if (not isAttack) then
            return
        end
        if (target256 == nil) then
            return
        end
        if ExIsUnitDead(target256) then
            return
        end
        SF__.TemplarStrikes.TryResetBOJ(caster255)
    end)
end

function SF__.TemplarStrikes.TryResetBOJ(caster258)
    local level259 = GetUnitAbilityLevel(caster258, SF__.TemplarStrikes.ID)
    local ad__AttackCount, ad__DamageScaling260, ad__ResetBOJChance = SF__.TemplarStrikes.GetAbilityData(level259)
    if (math.random() >= ad__ResetBOJChance) then
        return
    end
    BlzEndUnitAbilityCooldown(caster258, SF__.BladeOfJustice.ID)
    ExAddSpecialEffectTarget("Abilities/Spells/Items/AIam/AIamTarget.mdl", caster258, "origin", 0.3)
end

function SF__.TemplarStrikes.UpdateAbilityMeta(u261)
    local p262 = GetOwningPlayer(u261)
    local datas__AttackCount, datas__DamageScaling263, datas__ResetBOJChance = {}, {}, {}
    do
        local i264 = 0
        while (i264 < SF__.TemplarStrikes.MaxLevel) do
            do
                local item__AttackCount, item__DamageScaling265, item__ResetBOJChance = SF__.TemplarStrikes.GetAbilityData((i264 + 1))
                table.insert(datas__AttackCount, item__AttackCount)
                table.insert(datas__DamageScaling263, item__DamageScaling265)
                table.insert(datas__ResetBOJChance, item__ResetBOJChance)
            end
            ::continue::
            i264 = (i264 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p262, SF__.TemplarStrikes.ID, "学习圣殿骑士之击 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p262, SF__.TemplarStrikes.ID, SF__.StrConcat__("快速攻击目标|cffff8c00", datas__AttackCount[(0 + 1)], "|r次，第一次造成普通攻击伤害，第二次造成光辉伤害，有一定几率重置公正之剑的冷却时间，普通攻击也会触发。\r\n\r\n|cff99ccff冷却时间|r - 10秒\r\n\r\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling263[(0 + 1)] * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas__ResetBOJChance[(0 + 1)] * 100)), "%|r的几率重置公正之剑。\r\n|cffffcc002级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling263[(1 + 1)] * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas__ResetBOJChance[(1 + 1)] * 100)), "%|r的几率重置公正之剑。\r\n|cffffcc003级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling263[(2 + 1)] * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas__ResetBOJChance[(2 + 1)] * 100)), "%|r的几率重置公正之剑。"), 0)
    do
        local i266 = 0
        while (i266 < SF__.TemplarStrikes.MaxLevel) do
            local data__AttackCount, data__DamageScaling267, data__ResetBOJChance = datas__AttackCount[(i266 + 1)], datas__DamageScaling263[(i266 + 1)], datas__ResetBOJChance[(i266 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p262, SF__.TemplarStrikes.ID, SF__.StrConcat__("圣殿骑士之击 - [|cffffcc00", (i266 + 1), "级|r]"), i266)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p262, SF__.TemplarStrikes.ID, SF__.StrConcat__("快速攻击目标|cffff8c00", data__AttackCount, "|r次，第一次造成普通攻击伤害，第二次造成普通攻击|cffff8c00", string.format("%.0f", (data__DamageScaling267 * 100)), "%|r的光辉伤害，|cffff8c00", string.format("%.0f", (data__ResetBOJChance * 100)), "%|r几率重置公正之剑的冷却时间，普通攻击也会触发。\r\n\r\n|cff99ccff冷却时间|r - 10秒"), i266)
            ::continue::
            i266 = (i266 + 1)
        end
    end
end

function SF__.TemplarStrikes.Start(data268)
    return SF__.CorRun__(function()
        local level269 = GetUnitAbilityLevel(data268.caster, SF__.TemplarStrikes.ID)
        local UnitAttribute271 = require("Objects.UnitAttribute")
        local EventCenter272 = require("Lib.EventCenter")
        local attr270 = UnitAttribute271.GetAttr(data268.caster)
        local normalDamage = attr270:SimMeleeAttack()
        EventCenter272.Damage:Emit({whichUnit = data268.caster, target = data268.target, amount = normalDamage, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
        SF__.TemplarStrikes.TryResetBOJ(data268.caster)
        SetUnitTimeScale(data268.caster, 3)
        ResetUnitAnimation(data268.caster)
        SetUnitAnimation(data268.caster, "attack - 2")
        SF__.CorWait__(math.round(((1.166 * 0.33) * 1000)))
        local tarAttr273 = UnitAttribute271.GetAttr(data268.target)
        local ad__AttackCount274, ad__DamageScaling275, ad__ResetBOJChance276 = SF__.TemplarStrikes.GetAbilityData(level269)
        local radiantDamage = ((attr270:SimMeleeAttack() * ad__DamageScaling275) * (1 - tarAttr273.radiantResistance))
        EventCenter272.Damage:Emit({whichUnit = data268.caster, target = data268.target, amount = radiantDamage, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
        SF__.TemplarStrikes.TryResetBOJ(data268.caster)
        SetUnitTimeScale(data268.caster, 1)
        ResetUnitAnimation(data268.caster)
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
function SF__.TemplarStrikes.IAbilityData.Equals(self__AttackCount, self__DamageScaling277, self__ResetBOJChance, other__AttackCount, other__DamageScaling278, other__ResetBOJChance)
    return ((math.abs((self__DamageScaling277 - other__DamageScaling278)) < 0.0001) and (math.abs((self__ResetBOJChance - other__ResetBOJChance)) < 0.0001))
end
-- TemplarVerdict
SF__.TemplarVerdict = SF__.TemplarVerdict or {}
function SF__.TemplarVerdict.GetAbilityData(level279)
    return 2.25, 0.3, 0.15
end

function SF__.TemplarVerdict.Init()
    local EventCenter280 = require("Lib.EventCenter")
    EventCenter280.RegisterPlayerUnitSpellChannel:Emit({id = SF__.TemplarVerdict.ID, handler = SF__.TemplarVerdict.Check})
    EventCenter280.RegisterPlayerUnitSpellEffect:Emit({id = SF__.TemplarVerdict.ID, handler = SF__.TemplarVerdict.Start})
    ExTriggerRegisterNewUnit(function(u281)
        if (GetUnitTypeId(u281) == FourCC("Hpal")) then
            SF__.TemplarVerdict.UpdateAbilityMeta(u281)
        end
    end)
end

function SF__.TemplarVerdict.Check(data282)
    local UnitAttribute284 = require("Objects.UnitAttribute")
    local attr283 = UnitAttribute284.GetAttr(data282.caster)
    if (attr283.retPalHolyEnergy < 3) then
        IssueImmediateOrderById(data282.caster, SF__.ConstOrderId.Stop)
        ExTextState(data282.caster, "圣能不足")
    end
end

function SF__.TemplarVerdict.UpdateAbilityMeta(u285)
    local p286 = GetOwningPlayer(u285)
    local datas__DamageScaling287, datas__JudgementDamageScaling, datas__ChanceToResetJudgement = {}, {}, {}
    do
        local i288 = 0
        while (i288 < 1) do
            do
                local item__DamageScaling289, item__JudgementDamageScaling, item__ChanceToResetJudgement = SF__.TemplarVerdict.GetAbilityData((i288 + 1))
                table.insert(datas__DamageScaling287, item__DamageScaling289)
                table.insert(datas__JudgementDamageScaling, item__JudgementDamageScaling)
                table.insert(datas__ChanceToResetJudgement, item__ChanceToResetJudgement)
            end
            ::continue::
            i288 = (i288 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p286, SF__.TemplarVerdict.ID, "学习圣殿骑士的裁决 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p286, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决造成一次攻击伤害，如果目标被审判，造成30%的额外伤害，15%几率重置审判。消耗|cffff8c003|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 5秒\r\n\r\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas__JudgementDamageScaling[(0 + 1)] * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas__ChanceToResetJudgement[(0 + 1)] * 100)), "%的战争艺术触发几率。"), 0)
    do
        local i290 = 0
        while (i290 < 1) do
            local data__DamageScaling291, data__JudgementDamageScaling, data__ChanceToResetJudgement = datas__DamageScaling287[(i290 + 1)], datas__JudgementDamageScaling[(i290 + 1)], datas__ChanceToResetJudgement[(i290 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p286, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决 - [|cffffcc00", (i290 + 1), "级|r]"), i290)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p286, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决造成一次攻击伤害，造成|cffff8c00", string.format("%.0f", (data__DamageScaling291 * 100)), "%|r的攻击伤害。消耗|cffff8c003|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 5秒"), i290)
            ::continue::
            i290 = (i290 + 1)
        end
    end
end

function SF__.TemplarVerdict.Start(data292)
    local level293 = GetUnitAbilityLevel(data292.caster, SF__.TemplarVerdict.ID)
    local UnitAttribute296 = require("Objects.UnitAttribute")
    local EventCenter298 = require("Lib.EventCenter")
    local ad__DamageScaling294, ad__JudgementDamageScaling, ad__ChanceToResetJudgement = SF__.TemplarVerdict.GetAbilityData(level293)
    local attr295 = UnitAttribute296.GetAttr(data292.caster)
    local damage297 = (attr295:SimAttack(UnitAttribute296.HeroAttributeType.Strength) * ad__DamageScaling294)
    EventCenter298.Damage:Emit({whichUnit = data292.caster, target = data292.target, amount = damage297, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_SLICE, outResult = {}})
    attr295.retPalHolyEnergy = (attr295.retPalHolyEnergy - 3)
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
function SF__.TemplarVerdict.IAbilityData.Equals(self__DamageScaling299, self__JudgementDamageScaling, self__ChanceToResetJudgement, other__DamageScaling300, other__JudgementDamageScaling, other__ChanceToResetJudgement)
    return ((math.abs((self__JudgementDamageScaling - other__JudgementDamageScaling)) < 0.0001) and (math.abs((self__ChanceToResetJudgement - other__ChanceToResetJudgement)) < 0.0001))
end
-- Transform
SF__.Transform = SF__.Transform or {}
setmetatable(SF__.Transform, { __index = SF__.Component })
SF__.Transform.__sf_base = SF__.Component
function SF__.Transform.__Init(self)
    SF__.Component.__Init(self)
    self.__sf_type = SF__.Transform
    self.position__x = 0
    self.position__y = 0
    self.position__z = 0
    self.rotation__x = 0
    self.rotation__y = 0
    self.rotation__z = 0
    self.rotation__w = 0
    self.scale__x = 0
    self.scale__y = 0
    self.scale__z = 0
    self.children = SF__.ListNew__({})
    self.parent = nil
    self.position = {x = 0, y = 0, z = 0}
    self.rotation = SF__.Quaternion.Euler(0, 0, 0)
    self.scale = {x = 1, y = 1, z = 1}
end

function SF__.Transform.New()
    local self = setmetatable({}, { __index = SF__.Transform })
    SF__.Transform.__Init(self)
    return self
end

function SF__.Transform:SetParent(newParent)
    if (self.parent ~= nil) then
        SF__.ListRemove__(self.parent.children, self)
    end
    self.parent = newParent
    if (self.parent ~= nil) then
        SF__.ListAdd__(self.parent.children, self)
    end
end
-- Utils
SF__.Utils = SF__.Utils or {}
function SF__.Utils.ExSetAbilityResearchTooltip(p, abilCode, researchTooltip, level)
    if (GetLocalPlayer() ~= p) then
        return
    end
    BlzSetAbilityResearchTooltip(abilCode, researchTooltip, level)
end

function SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p22, abilCode23, researchExtendedTooltip, level24)
    if (GetLocalPlayer() ~= p22) then
        return
    end
    BlzSetAbilityResearchExtendedTooltip(abilCode23, researchExtendedTooltip, level24)
end

function SF__.Utils.ExBlzSetAbilityTooltip(p25, abilCode26, tooltip, level27)
    if (GetLocalPlayer() ~= p25) then
        return
    end
    BlzSetAbilityTooltip(abilCode26, tooltip, level27)
end

function SF__.Utils.ExBlzSetAbilityExtendedTooltip(p28, abilCode29, extendedTooltip, level30)
    if (GetLocalPlayer() ~= p28) then
        return
    end
    BlzSetAbilityExtendedTooltip(abilCode29, extendedTooltip, level30)
end

function SF__.Utils.ExBlzSetAbilityIcon(p31, abilCode32, iconPath)
    if (GetLocalPlayer() ~= p31) then
        return
    end
    BlzSetAbilityIcon(abilCode32, iconPath)
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

function SF__.Vector2.Cross(a__x33, a__y34, b__x35, b__y36)
    return ((a__y34 * b__x35) - (a__x33 * b__y36))
end

function SF__.Vector2.op_UnaryNegation(a__x37, a__y38)
    return (-a__x37), (-a__y38)
end

function SF__.Vector2.op_Addition(a__x39, a__y40, b__x41, b__y42)
    return (a__x39 + b__x41), (a__y40 + b__y42)
end

function SF__.Vector2.op_Subtraction(a__x43, a__y44, b__x45, b__y46)
    return (a__x43 - b__x45), (a__y44 - b__y46)
end

function SF__.Vector2.op_Multiply__vector2f(v__x47, v__y48, f)
    return (v__x47 * f), (v__y48 * f)
end

function SF__.Vector2.op_Multiply__fvector2(f49, v__x50, v__y51)
    return (v__x50 * f49), (v__y51 * f49)
end

function SF__.Vector2.op_Division(v__x52, v__y53, f54)
    return (v__x52 / f54), (v__y53 / f54)
end

function SF__.Vector2.op_Equality(a__x55, a__y56, b__x57, b__y58)
    return ((math.abs((a__x55 - b__x57)) < 0.0001) and (math.abs((a__y56 - b__y58)) < 0.0001))
end

function SF__.Vector2.op_Inequality(a__x59, a__y60, b__x61, b__y62)
    return (not SF__.Vector2.op_Equality(a__x59, a__y60, b__x61, b__y62))
end

function SF__.Vector2.UnitDistance(a, b)
    local v1__x, v1__y = SF__.Vector2.FromUnit(a)
    local v2__x, v2__y = SF__.Vector2.FromUnit(b)
    return SF__.Vector2.get_Magnitude(SF__.Vector2.op_Subtraction(v1__x, v1__y, v2__x, v2__y))
end

function SF__.Vector2.SqrUnitDistance(a63, b64)
    local v1__x65, v1__y66 = SF__.Vector2.FromUnit(a63)
    local v2__x67, v2__y68 = SF__.Vector2.FromUnit(b64)
    return SF__.Vector2.get_SqrMagnitude(SF__.Vector2.op_Subtraction(v1__x65, v1__y66, v2__x67, v2__y68))
end

function SF__.Vector2.FromUnit(u)
    return GetUnitX(u), GetUnitY(u)
end

function SF__.Vector2.get_Magnitude(self__x69, self__y70)
    return math.sqrt(SF__.Vector2.get_SqrMagnitude(self__x69, self__y70))
end

function SF__.Vector2.get_SqrMagnitude(self__x71, self__y72)
    return ((self__x71 * self__x71) + (self__y72 * self__y72))
end

function SF__.Vector2.get_Normalized(self__x73, self__y74)
    local mag = SF__.Vector2.get_Magnitude(self__x73, self__y74)
    if (mag < 0.0001) then
        return SF__.Vector2.get_Zero()
    end
    return SF__.Vector2.op_Division(self__x73, self__y74, mag)
end

function SF__.Vector2.ClampMagnitude(self__x77, self__y78, mag79)
    return SF__.Vector2.op_Multiply__vector2f(SF__.Vector2.get_Normalized(self__x77, self__y78), mag79)
end

function SF__.Vector2.Equals(self__x80, self__y81, other__x82, other__y83)
    return SF__.Vector2.op_Equality(self__x80, self__y81, other__x82, other__y83)
end

function SF__.Vector2.ToString(self__x84, self__y85)
    return SF__.StrConcat__("(", self__x84, ", ", self__y85, ")")
end

function SF__.Vector2.Rotate(self__x86, self__y87, angle88)
    local cos = math.cos(angle88)
    local sin = math.sin(angle88)
    return ((self__x86 * cos) - (self__y87 * sin)), ((self__x86 * sin) + (self__y87 * cos))
end

function SF__.Vector2.UnitMoveTo(self__x89, self__y90, u91)
    SetUnitX(u91, self__x89)
    SetUnitY(u91, self__y90)
end

function SF__.Vector2.GetTerrainZ(self__x92, self__y93)
    MoveLocation(SF__.Vector2._loc, self__x92, self__y93)
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

function SF__.Vector3.op_Addition(a__x94, a__y95, a__z, b__x96, b__y97, b__z)
    return (a__x94 + b__x96), (a__y95 + b__y97), (a__z + b__z)
end

function SF__.Vector3.op_UnaryNegation(a__x98, a__y99, a__z100)
    return (-a__x98), (-a__y99), (-a__z100)
end

function SF__.Vector3.op_Subtraction(a__x101, a__y102, a__z103, b__x104, b__y105, b__z106)
    return (a__x101 - b__x104), (a__y102 - b__y105), (a__z103 - b__z106)
end

function SF__.Vector3.op_Multiply__vector3f(v__x107, v__y108, v__z109, f110)
    return (v__x107 * f110), (v__y108 * f110), (v__z109 * f110)
end

function SF__.Vector3.op_Multiply__fvector3(f111, v__x112, v__y113, v__z114)
    return (v__x112 * f111), (v__y113 * f111), (v__z114 * f111)
end

function SF__.Vector3.op_Division(v__x115, v__y116, v__z117, f118)
    return (v__x115 / f118), (v__y116 / f118), (v__z117 / f118)
end

function SF__.Vector3.op_Equality(a__x119, a__y120, a__z121, b__x122, b__y123, b__z124)
    return (((math.abs((a__x119 - b__x122)) < 0.0001) and (math.abs((a__y120 - b__y123)) < 0.0001)) and (math.abs((a__z121 - b__z124)) < 0.0001))
end

function SF__.Vector3.op_Inequality(a__x125, a__y126, a__z127, b__x128, b__y129, b__z130)
    return (not SF__.Vector3.op_Equality(a__x125, a__y126, a__z127, b__x128, b__y129, b__z130))
end

function SF__.Vector3.Dot(a__x131, a__y132, a__z133, b__x134, b__y135, b__z136)
    return (((a__x131 * b__x134) + (a__y132 * b__y135)) + (a__z133 * b__z136))
end

function SF__.Vector3.Scale(a__x137, a__y138, a__z139, b__x140, b__y141, b__z142)
    return (a__x137 * b__x140), (a__y138 * b__y141), (a__z139 * b__z142)
end

-- <summary>
-- Warcraft III world space here is right-handed: +x points right, +y points away, +z points up.
-- That means Cross((1,0,0), (0,1,0)) == (0,0,1).
-- </summary>
--
function SF__.Vector3.Cross(a__x143, a__y144, a__z145, b__x146, b__y147, b__z148)
    return ((a__y144 * b__z148) - (a__z145 * b__y147)), ((a__z145 * b__x146) - (a__x143 * b__z148)), ((a__x143 * b__y147) - (a__y144 * b__x146))
end

function SF__.Vector3.Project(v__x149, v__y150, v__z151, onNormal__x, onNormal__y, onNormal__z)
    local sqrMag = SF__.Vector3.Dot(onNormal__x, onNormal__y, onNormal__z, onNormal__x, onNormal__y, onNormal__z)
    if (sqrMag < 0.0001) then
        return SF__.Vector3.get_Zero()
    end
    local dot = SF__.Vector3.Dot(v__x149, v__y150, v__z151, onNormal__x, onNormal__y, onNormal__z)
    return SF__.Vector3.op_Multiply__vector3f(onNormal__x, onNormal__y, onNormal__z, (dot / sqrMag))
end

function SF__.Vector3.ProjectOnPlane(v__x152, v__y153, v__z154, planeNormal__x, planeNormal__y, planeNormal__z)
    return SF__.Vector3.op_Subtraction(v__x152, v__y153, v__z154, SF__.Vector3.Project(v__x152, v__y153, v__z154, planeNormal__x, planeNormal__y, planeNormal__z))
end

function SF__.Vector3._getTerrainZ(x155, y156)
    MoveLocation(SF__.Vector3._loc, x155, y156)
    return GetLocationZ(SF__.Vector3._loc)
end

function SF__.Vector3.FromUnit(u157)
    local x158 = GetUnitX(u157)
    local y159 = GetUnitY(u157)
    return x158, y159, (SF__.Vector3._getTerrainZ(x158, y159) + GetUnitFlyHeight(u157))
end

function SF__.Vector3.get_SqrMagnitude(self__x160, self__y161, self__z162)
    return (((self__x160 * self__x160) + (self__y161 * self__y161)) + (self__z162 * self__z162))
end

function SF__.Vector3.get_Magnitude(self__x163, self__y164, self__z165)
    return math.sqrt(SF__.Vector3.get_SqrMagnitude(self__x163, self__y164, self__z165))
end

function SF__.Vector3.get_Normalized(self__x166, self__y167, self__z168)
    local mag169 = SF__.Vector3.get_Magnitude(self__x166, self__y167, self__z168)
    if (mag169 < 0.0001) then
        return SF__.Vector3.get_Zero()
    end
    return SF__.Vector3.op_Division(self__x166, self__y167, self__z168, mag169)
end

function SF__.Vector3.ClampMagnitude(self__x173, self__y174, self__z175, mag176)
    return SF__.Vector3.op_Multiply__vector3f(SF__.Vector3.get_Normalized(self__x173, self__y174, self__z175), mag176)
end

function SF__.Vector3.Equals(self__x177, self__y178, self__z179, other__x180, other__y181, other__z182)
    return SF__.Vector3.op_Equality(self__x177, self__y178, self__z179, other__x180, other__y181, other__z182)
end

function SF__.Vector3.ToString(self__x183, self__y184, self__z185)
    return SF__.StrConcat__("(", self__x183, ", ", self__y184, ", ", self__z185, ")")
end

function SF__.Vector3.UnitMoveTo(self__x186, self__y187, self__z188, u189, mode)
    if mode == nil then mode = SF__.UnitVec3Mode.Auto end
    local tz = SF__.Vector3._getTerrainZ(self__x186, self__y187)
    local LuaUtils = require("Lib.Utils")
    local defaultFlyHeight = GetUnitDefaultFlyHeight(u189)
    local minZ = (tz + defaultFlyHeight)
    SetUnitPosition(u189, self__x186, self__y187)
    repeat
        local switchValue = mode
        if (switchValue == SF__.UnitVec3Mode.ForceFlying) then
            LuaUtils.SetUnitFlyable(u189)
            SetUnitFlyHeight(u189, (math.max(minZ, self__z188) - minZ), 0)
            break
        elseif (switchValue == SF__.UnitVec3Mode.ForceGround) then
            SetUnitFlyHeight(u189, defaultFlyHeight, 0)
            break
        elseif (switchValue == SF__.UnitVec3Mode.Auto) then
            if IsUnitType(u189, UNIT_TYPE_FLYING) then
                SetUnitFlyHeight(u189, (math.max(minZ, self__z188) - minZ), 0)
            else
                SetUnitFlyHeight(u189, defaultFlyHeight, 0)
            end
            break
        end
    until true
end

function SF__.Vector3.GetTerrainZ(self__x190, self__y191, self__z192)
    return SF__.Vector3._getTerrainZ(self__x190, self__y191)
end

SF__.Vector3._loc = Location(0, 0)
-- WordOfGlory
SF__.WordOfGlory = SF__.WordOfGlory or {}
function SF__.WordOfGlory.Init()
    local EventCenter301 = require("Lib.EventCenter")
    EventCenter301.RegisterPlayerUnitSpellChannel:Emit({id = SF__.WordOfGlory.ID, handler = SF__.WordOfGlory.Check})
    EventCenter301.RegisterPlayerUnitSpellEffect:Emit({id = SF__.WordOfGlory.ID, handler = SF__.WordOfGlory.Start})
    ExTriggerRegisterNewUnit(function(u302)
        if (GetUnitTypeId(u302) == FourCC("Hpal")) then
            SF__.WordOfGlory.UpdateAbilityMeta(u302)
        end
    end)
end

function SF__.WordOfGlory.Check(data303)
    local UnitAttribute305 = require("Objects.UnitAttribute")
    local attr304 = UnitAttribute305.GetAttr(data303.caster)
    if (attr304.retPalHolyEnergy < 3) then
        IssueImmediateOrderById(data303.caster, SF__.ConstOrderId.Stop)
        ExTextState(data303.caster, "圣能不足")
    end
end

function SF__.WordOfGlory.UpdateAbilityMeta(u306)
    local p307 = GetOwningPlayer(u306)
    SF__.Utils.ExSetAbilityResearchTooltip(p307, SF__.WordOfGlory.ID, "学习圣殿骑士的裁决 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p307, SF__.WordOfGlory.ID, "圣殿骑士的裁决造成一次攻击伤害，如果目标被审判，造成30%的额外伤害，15%几率重置审判。消耗|cffff8c003|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 5秒\r\n\r\n|cffffcc001级|r - |cffff8c00100%|r的攻击伤害，100%的战争艺术触发几率。", 0)
    do
        local i308 = 0
        while (i308 < 1) do
            SF__.Utils.ExBlzSetAbilityTooltip(p307, SF__.WordOfGlory.ID, SF__.StrConcat__("圣殿骑士的裁决 - [|cffffcc00", (i308 + 1), "级|r]"), i308)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p307, SF__.WordOfGlory.ID, "圣殿骑士的裁决造成一次攻击伤害，造成|cffff8c00100%|r的攻击伤害。消耗|cffff8c003|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 5秒", i308)
            ::continue::
            i308 = (i308 + 1)
        end
    end
end

function SF__.WordOfGlory.Start(data309)
    local UnitAttribute311 = require("Objects.UnitAttribute")
    local EventCenter312 = require("Lib.EventCenter")
    local attr310 = UnitAttribute311.GetAttr(data309.caster)
    EventCenter312.Heal:Emit({caster = data309.caster, target = data309.target, amount = 300})
    attr310.retPalHolyEnergy = (attr310.retPalHolyEnergy - 3)
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
