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

-- BladeOfJustice
SF__.BladeOfJustice = SF__.BladeOfJustice or {}
function SF__.BladeOfJustice.GetAbilityData(level15)
    return (75 * level15), 5, (10 * level15)
end

function SF__.BladeOfJustice.Init()
    local EventCenter = require("Lib.EventCenter")
    EventCenter.RegisterPlayerUnitSpellEffect:Emit({id = SF__.BladeOfJustice.ID, handler = SF__.BladeOfJustice.Start})
    ExTriggerRegisterNewUnit(function(u)
        if (GetUnitTypeId(u) == FourCC("Hpal")) then
            SF__.BladeOfJustice.UpdateAbilityMeta(u)
        end
    end)
end

function SF__.BladeOfJustice.UpdateAbilityMeta(u16)
    local p17 = GetOwningPlayer(u16)
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
    SF__.Utils.ExSetAbilityResearchTooltip(p17, SF__.BladeOfJustice.ID, "学习公正之剑 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p17, SF__.BladeOfJustice.ID, SF__.StrConcat__("用圣光的利刃刺穿目标，造成法术伤害，在一定时间内对附近敌人每秒造成光辉伤害。产生|cffff8c001|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 10秒\r\n\r\n|cffffcc001级|r - 造成|cffff8c00", datas__Damage[(0 + 1)], "|r的直接法术伤害，|cffff8c00", datas__Duration[(0 + 1)], "|r秒内对附近敌人每秒造成|cffff8c00", datas__DamagePerSecond[(0 + 1)], "|r的光辉伤害。产生|cffff8c001|r点圣能。\r\n|cffffcc002级|r - 造成|cffff8c00", datas__Damage[(1 + 1)], "|r的直接法术伤害，|cffff8c00", datas__Duration[(1 + 1)], "|r秒内对附近敌人每秒造成|cffff8c00", datas__DamagePerSecond[(1 + 1)], "|r的光辉伤害。产生|cffff8c001|r点圣能。\r\n|cffffcc003级|r - 造成|cffff8c00", datas__Damage[(2 + 1)], "|r的直接法术伤害，|cffff8c00", datas__Duration[(2 + 1)], "|r秒内对附近敌人每秒造成|cffff8c00", datas__DamagePerSecond[(2 + 1)], "|r的光辉伤害。产生|cffff8c001|r点圣能。"), 0)
    do
        local i18 = 0
        while (i18 < 3) do
            local data__Damage, data__Duration, data__DamagePerSecond = datas__Damage[(i18 + 1)], datas__Duration[(i18 + 1)], datas__DamagePerSecond[(i18 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p17, SF__.BladeOfJustice.ID, SF__.StrConcat__("公正之剑 - [|cffffcc00", (i18 + 1), "级|r]"), i18)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p17, SF__.BladeOfJustice.ID, SF__.StrConcat__("用圣光的利刃刺穿目标，造成|cffff8c00", data__Damage, "|r的直接法术伤害，在|cffff8c00", data__Duration, "|r秒内对附近敌人每秒造成|cffff8c00", data__DamagePerSecond, "|r的光辉伤害。产生|cffff8c001|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 10秒"), i18)
            ::continue::
            i18 = (i18 + 1)
        end
    end
end

function SF__.BladeOfJustice.Start(data)
    local level19 = GetUnitAbilityLevel(data.caster, SF__.BladeOfJustice.ID)
    local EventCenter20 = require("Lib.EventCenter")
    local ad__Damage, ad__Duration, ad__DamagePerSecond = SF__.BladeOfJustice.GetAbilityData(level19)
    EventCenter20.Damage:Emit({whichUnit = data.caster, target = data.target, amount = ad__Damage, attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
    SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(data.caster, 1)
    SF__.BladeOfJustice.New():StartGroudDamage(data.caster, data.target, ad__Damage, ad__Duration, ad__DamagePerSecond)
end

function SF__.BladeOfJustice:StartGroudDamage(caster, target, ad__Damage21, ad__Duration22, ad__DamagePerSecond23)
    return SF__.CorRun__(function()
        self.x = GetUnitX(target)
        local UnitAttribute = require("Objects.UnitAttribute")
        local EventCenter27 = require("Lib.EventCenter")
        self.y = GetUnitY(target)
        local eff = ExAddSpecialEffect("Abilities/Spells/Orc/LiquidFire/Liquidfire.mdl", self.x, self.y, ad__Duration22)
        local p24 = GetOwningPlayer(caster)
        do
            local i25 = 0
            while (i25 < ad__Duration22) do
                SF__.CorWait__(1000)
                ExGroupEnumUnitsInRange(self.x, self.y, 300, function(u26)
                    if (not IsUnitEnemy(u26, p24)) then
                        return
                    end
                    if ExIsUnitDead(u26) then
                        return
                    end
                    local tarAttr = UnitAttribute.GetAttr(u26)
                    local damage = (ad__DamagePerSecond23 * (1 - tarAttr.radiantResistance))
                    EventCenter27.Damage:Emit({whichUnit = caster, target = u26, amount = damage, attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
                end)
                ::continue::
                i25 = (i25 + 1)
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
function SF__.CrusaderStrike.GetAbilityData(level28)
    return (0.65 + (0.35 * level28)), (0.15 * (level28 - 1))
end

function SF__.CrusaderStrike.Init()
    local EventCenter29 = require("Lib.EventCenter")
    EventCenter29.RegisterPlayerUnitSpellEffect:Emit({id = SF__.CrusaderStrike.ID, handler = SF__.CrusaderStrike.Start})
    ExTriggerRegisterNewUnit(function(u30)
        if (GetUnitTypeId(u30) == FourCC("Hpal")) then
            SF__.CrusaderStrike.UpdateAbilityMeta(u30)
        end
    end)
end

function SF__.CrusaderStrike.UpdateAbilityMeta(u31)
    local p32 = GetOwningPlayer(u31)
    local datas__DamageScaling, datas__ArtOfWarChance = {}, {}
    do
        local i33 = 0
        while (i33 < 3) do
            do
                local item__DamageScaling, item__ArtOfWarChance = SF__.CrusaderStrike.GetAbilityData((i33 + 1))
                table.insert(datas__DamageScaling, item__DamageScaling)
                table.insert(datas__ArtOfWarChance, item__ArtOfWarChance)
            end
            ::continue::
            i33 = (i33 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p32, SF__.CrusaderStrike.ID, "学习十字军打击 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p32, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击造成一次攻击伤害，伤害系数随技能等级提升。产生|cffff8c001|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 6秒\r\n\r\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling[(0 + 1)] * 100)), "%|r的攻击伤害。\r\n|cffffcc002级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling[(1 + 1)] * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas__ArtOfWarChance[(1 + 1)] * 100)), "%的战争艺术触发几率。\r\n|cffffcc003级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling[(2 + 1)] * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas__ArtOfWarChance[(2 + 1)] * 100)), "%的战争艺术触发几率。"), 0)
    do
        local i34 = 0
        while (i34 < 3) do
            local data__DamageScaling, data__ArtOfWarChance = datas__DamageScaling[(i34 + 1)], datas__ArtOfWarChance[(i34 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p32, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击 - [|cffffcc00", (i34 + 1), "级|r]"), i34)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p32, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击造成一次攻击伤害，造成|cffff8c00", string.format("%.0f", (data__DamageScaling * 100)), "%|r的攻击伤害", SF__.Ternary__((i34 > 0), SF__.StrConcat__("，", string.format("%.0f", (data__ArtOfWarChance * 100)), "%的战争艺术触发几率"), ""), "。产生|cffff8c001|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 6秒"), i34)
            ::continue::
            i34 = (i34 + 1)
        end
    end
    -- datas.Remove(new IAbilityData { DamageScaling = 0.65f, ArtOfWarChance = 0 });
    do
        local index = 0
        table.remove(datas__DamageScaling, (index + 1))
        table.remove(datas__ArtOfWarChance, (index + 1))
    end
end

function SF__.CrusaderStrike.Start(data35)
    local level36 = GetUnitAbilityLevel(data35.caster, SF__.CrusaderStrike.ID)
    local UnitAttribute37 = require("Objects.UnitAttribute")
    local EventCenter39 = require("Lib.EventCenter")
    local ad__DamageScaling, ad__ArtOfWarChance = SF__.CrusaderStrike.GetAbilityData(level36)
    local attr = UnitAttribute37.GetAttr(data35.caster)
    local damage38 = (attr:SimAttack(UnitAttribute37.HeroAttributeType.Strength) * ad__DamageScaling)
    EventCenter39.Damage:Emit({whichUnit = data35.caster, target = data35.target, amount = damage38, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
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

function SF__.CrusaderStrike.IAbilityData.Equals(self__DamageScaling40, self__ArtOfWarChance41, other__DamageScaling, other__ArtOfWarChance)
    return ((math.abs((self__DamageScaling40 - other__DamageScaling)) < 0.0001) and (math.abs((self__ArtOfWarChance41 - other__ArtOfWarChance)) < 0.0001))
end

function SF__.CrusaderStrike.IAbilityData.GetHashValue(self__DamageScaling42, self__ArtOfWarChance43)
    return 0
end
-- DivineToll
SF__.DivineToll = SF__.DivineToll or {}
function SF__.DivineToll.GetAbilityData(level44)
    return (2 + level44), (50 * level44), 0.1, 10
end

function SF__.DivineToll.Init()
    local EventCenter45 = require("Lib.EventCenter")
    EventCenter45.RegisterPlayerUnitSpellEffect:Emit({id = SF__.DivineToll.ID, handler = SF__.DivineToll.Start})
    ExTriggerRegisterNewUnit(function(u46)
        if (GetUnitTypeId(u46) == FourCC("Hpal")) then
            SF__.DivineToll.UpdateAbilityMeta(u46)
        end
    end)
end

function SF__.DivineToll.UpdateAbilityMeta(u47)
    local p48 = GetOwningPlayer(u47)
    local datas__TargetCount, datas__Damage49, datas__RadiantDmgAmp, datas__Duration50 = {}, {}, {}, {}
    do
        local i51 = 0
        while (i51 < 3) do
            do
                local item__TargetCount, item__Damage52, item__RadiantDmgAmp, item__Duration53 = SF__.DivineToll.GetAbilityData((i51 + 1))
                table.insert(datas__TargetCount, item__TargetCount)
                table.insert(datas__Damage49, item__Damage52)
                table.insert(datas__RadiantDmgAmp, item__RadiantDmgAmp)
                table.insert(datas__Duration50, item__Duration53)
            end
            ::continue::
            i51 = (i51 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p48, SF__.DivineToll.ID, "学习圣洁鸣钟 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p48, SF__.DivineToll.ID, SF__.StrConcat__("对附近的多个目标施展审判，造成法术伤害，然后神圣之锤环绕圣殿骑士，每次命中敌人使其受到的光辉伤害提高。每个审判产生|cffff8c001|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 30秒\r\n\r\n|cffffcc001级|r - 审判最多|cffff8c00", datas__TargetCount[(0 + 1)], "|r个目标，造成|cffff8c00", datas__Damage49[(0 + 1)], "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas__RadiantDmgAmp[(0 + 1)] * 100)), "%|r的光辉易伤，持续|cffff8c00", datas__Duration50[(0 + 1)], "|r秒。\r\n|cffffcc002级|r - 审判最多|cffff8c00", datas__TargetCount[(1 + 1)], "|r个目标，造成|cffff8c00", datas__Damage49[(1 + 1)], "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas__RadiantDmgAmp[(1 + 1)] * 100)), "%|r的光辉易伤，持续|cffff8c00", datas__Duration50[(1 + 1)], "|r秒。\r\n|cffffcc003级|r - 审判最多|cffff8c00", datas__TargetCount[(2 + 1)], "|r个目标，造成|cffff8c00", datas__Damage49[(2 + 1)], "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas__RadiantDmgAmp[(2 + 1)] * 100)), "%|r的光辉易伤，持续|cffff8c00", datas__Duration50[(2 + 1)], "|r秒。"), 0)
    do
        local i54 = 0
        while (i54 < 3) do
            local data__TargetCount, data__Damage55, data__RadiantDmgAmp, data__Duration56 = datas__TargetCount[(i54 + 1)], datas__Damage49[(i54 + 1)], datas__RadiantDmgAmp[(i54 + 1)], datas__Duration50[(i54 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p48, SF__.DivineToll.ID, SF__.StrConcat__("圣洁鸣钟 - [|cffffcc00", (i54 + 1), "级|r]"), i54)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p48, SF__.DivineToll.ID, SF__.StrConcat__("对附近的最多|cffff8c00", data__TargetCount, "|r个目标施展审判，造成|cffff8c00", data__Damage55, "|r点法术伤害，然后神圣之锤环绕圣殿骑士，每次命中敌人使其受到的光辉伤害提高|cffff8c00", string.format("%.0f", (data__RadiantDmgAmp * 100)), "%|r，持续|cffff8c00", data__Duration56, "|r秒。每个审判产生|cffff8c001|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 30秒"), i54)
            ::continue::
            i54 = (i54 + 1)
        end
    end
end

function SF__.DivineToll.Start(data57)
    local level58 = GetUnitAbilityLevel(data57.caster, SF__.DivineToll.ID)
    local EventCenter61 = require("Lib.EventCenter")
    local ad__TargetCount, ad__Damage59, ad__RadiantDmgAmp, ad__Duration60 = SF__.DivineToll.GetAbilityData(level58)
    EventCenter61.Damage:Emit({whichUnit = data57.caster, target = data57.target, amount = ad__Damage59, attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
    SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(data57.caster, 1)
    -- new BladeOfJustice().StartGroudDamage(data.caster, data.target, ad);
end

function SF__.DivineToll:StartGroudDamage(caster62, target63, ad__TargetCount64, ad__Damage65, ad__RadiantDmgAmp66, ad__Duration67)
    return SF__.CorRun__(function()
        self.x = GetUnitX(target63)
        local UnitAttribute73 = require("Objects.UnitAttribute")
        local EventCenter74 = require("Lib.EventCenter")
        self.y = GetUnitY(target63)
        local eff68 = ExAddSpecialEffect("Abilities/Spells/Orc/LiquidFire/Liquidfire.mdl", self.x, self.y, ad__Duration67)
        local p69 = GetOwningPlayer(caster62)
        do
            local i70 = 0
            while (i70 < ad__Duration67) do
                SF__.CorWait__(1000)
                ExGroupEnumUnitsInRange(self.x, self.y, 300, function(u71)
                    if (not IsUnitEnemy(u71, p69)) then
                        return
                    end
                    if ExIsUnitDead(u71) then
                        return
                    end
                    local tarAttr72 = UnitAttribute73.GetAttr(u71)
                    -- var damage = ad.DamagePerSecond * (1 - tarAttr.radiantResistance);
                    EventCenter74.Damage:Emit({whichUnit = caster62, target = u71, amount = 100, attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
                end)
                ::continue::
                i70 = (i70 + 1)
            end
        end
        DestroyEffect(eff68)
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
function SF__.DivineToll.IAbilityData.Equals(self__TargetCount, self__Damage75, self__RadiantDmgAmp, self__Duration76, other__TargetCount, other__Damage77, other__RadiantDmgAmp, other__Duration78)
    return (((math.abs((self__Damage75 - other__Damage77)) < 0.0001) and (math.abs((self__Duration76 - other__Duration78)) < 0.0001)) and (math.abs((self__RadiantDmgAmp - other__RadiantDmgAmp)) < 0.0001))
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
-- RetributionPaladinGlobal
SF__.RetributionPaladinGlobal = SF__.RetributionPaladinGlobal or {}
function SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(u79, amount)
    local UnitAttribute81 = require("Objects.UnitAttribute")
    local attr80 = UnitAttribute81.GetAttr(u79)
    attr80.retPalHolyEnergy = math.min((attr80.retPalHolyEnergy + amount), 5)
end

function SF__.RetributionPaladinGlobal:Init()
    ExTriggerRegisterNewUnit(function(u82)
        if (GetUnitTypeId(u82) == FourCC("Hpal")) then
            SF__.ListAdd__(self._units, u82)
        end
    end)
    _ = self:Start()
end

function SF__.RetributionPaladinGlobal:Start()
    return SF__.CorRun__(function()
        local UnitAttribute85 = require("Objects.UnitAttribute")
        while true do
            do
                local collection6 = self._units
                for i7, u83 in SF__.ListIterate__(collection6) do
                    local attr84 = UnitAttribute85.GetAttr(u83)
                    ExSetUnitMana(u83, ((ExGetUnitMaxMana(u83) * attr84.retPalHolyEnergy) * 0.2))
                    if (attr84.retPalHolyEnergy >= 3) then
                        SF__.Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u83), FourCC("A006"), "ReplaceableTextures/CommandButtons/BTNinv_helmet_96.tga")
                    else
                        SF__.Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u83), FourCC("A006"), "ReplaceableTextures/PassiveButtons/PASBTNinv_helmet_96.tga")
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
local SystemBase3 = require("System.SystemBase")
SF__.Systems.MeleeGameSystem = SF__.Systems.MeleeGameSystem or class("MeleeGameSystem", SystemBase3)
SF__.Systems.MeleeGameSystem.__sf_base = SystemBase3
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
function SF__.TemplarStrikes.GetAbilityData(level86)
    return 2, (0.5 + (0.25 * level86)), (0.05 * level86)
end

function SF__.TemplarStrikes.Init()
    local EventCenter87 = require("Lib.EventCenter")
    EventCenter87.RegisterPlayerUnitSpellEffect:Emit({id = SF__.TemplarStrikes.ID, handler = SF__.TemplarStrikes.Start})
    ExTriggerRegisterNewUnit(function(u88)
        if (GetUnitTypeId(u88) == FourCC("Hpal")) then
            SF__.TemplarStrikes.UpdateAbilityMeta(u88)
            SetHeroLevel(u88, 10, true)
        end
    end)
    EventCenter87.RegisterPlayerUnitDamaged:Emit(function(caster89, target90, damage91, weapType, dmgType, isAttack)
        if (GetUnitAbilityLevel(caster89, SF__.TemplarStrikes.ID) <= 0) then
            return
        end
        if (not isAttack) then
            return
        end
        if (target90 == nil) then
            return
        end
        if ExIsUnitDead(target90) then
            return
        end
        SF__.TemplarStrikes.TryResetBOJ(caster89)
    end)
end

function SF__.TemplarStrikes.TryResetBOJ(caster92)
    local level93 = GetUnitAbilityLevel(caster92, SF__.TemplarStrikes.ID)
    local ad__AttackCount, ad__DamageScaling94, ad__ResetBOJChance = SF__.TemplarStrikes.GetAbilityData(level93)
    if (math.random() >= ad__ResetBOJChance) then
        return
    end
    BlzEndUnitAbilityCooldown(caster92, SF__.BladeOfJustice.ID)
    ExAddSpecialEffectTarget("Abilities/Spells/Items/AIam/AIamTarget.mdl", caster92, "origin", 0.3)
end

function SF__.TemplarStrikes.UpdateAbilityMeta(u95)
    local p96 = GetOwningPlayer(u95)
    local datas__AttackCount, datas__DamageScaling97, datas__ResetBOJChance = {}, {}, {}
    do
        local i98 = 0
        while (i98 < SF__.TemplarStrikes.MaxLevel) do
            do
                local item__AttackCount, item__DamageScaling99, item__ResetBOJChance = SF__.TemplarStrikes.GetAbilityData((i98 + 1))
                table.insert(datas__AttackCount, item__AttackCount)
                table.insert(datas__DamageScaling97, item__DamageScaling99)
                table.insert(datas__ResetBOJChance, item__ResetBOJChance)
            end
            ::continue::
            i98 = (i98 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p96, SF__.TemplarStrikes.ID, "学习圣殿骑士之击 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p96, SF__.TemplarStrikes.ID, SF__.StrConcat__("快速攻击目标|cffff8c00", datas__AttackCount[(0 + 1)], "|r次，第一次造成普通攻击伤害，第二次造成光辉伤害，有一定几率重置公正之剑的冷却时间，普通攻击也会触发。\r\n\r\n|cff99ccff冷却时间|r - 10秒\r\n\r\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling97[(0 + 1)] * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas__ResetBOJChance[(0 + 1)] * 100)), "%|r的几率重置公正之剑。\r\n|cffffcc002级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling97[(1 + 1)] * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas__ResetBOJChance[(1 + 1)] * 100)), "%|r的几率重置公正之剑。\r\n|cffffcc003级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling97[(2 + 1)] * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas__ResetBOJChance[(2 + 1)] * 100)), "%|r的几率重置公正之剑。"), 0)
    do
        local i100 = 0
        while (i100 < SF__.TemplarStrikes.MaxLevel) do
            local data__AttackCount, data__DamageScaling101, data__ResetBOJChance = datas__AttackCount[(i100 + 1)], datas__DamageScaling97[(i100 + 1)], datas__ResetBOJChance[(i100 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p96, SF__.TemplarStrikes.ID, SF__.StrConcat__("圣殿骑士之击 - [|cffffcc00", (i100 + 1), "级|r]"), i100)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p96, SF__.TemplarStrikes.ID, SF__.StrConcat__("快速攻击目标|cffff8c00", data__AttackCount, "|r次，第一次造成普通攻击伤害，第二次造成普通攻击|cffff8c00", string.format("%.0f", (data__DamageScaling101 * 100)), "%|r的光辉伤害，|cffff8c00", string.format("%.0f", (data__ResetBOJChance * 100)), "%|r几率重置公正之剑的冷却时间，普通攻击也会触发。\r\n\r\n|cff99ccff冷却时间|r - 10秒"), i100)
            ::continue::
            i100 = (i100 + 1)
        end
    end
end

function SF__.TemplarStrikes.Start(data102)
    return SF__.CorRun__(function()
        local level103 = GetUnitAbilityLevel(data102.caster, SF__.TemplarStrikes.ID)
        local UnitAttribute105 = require("Objects.UnitAttribute")
        local EventCenter106 = require("Lib.EventCenter")
        local attr104 = UnitAttribute105.GetAttr(data102.caster)
        local normalDamage = attr104:SimMeleeAttack()
        EventCenter106.Damage:Emit({whichUnit = data102.caster, target = data102.target, amount = normalDamage, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
        SF__.TemplarStrikes.TryResetBOJ(data102.caster)
        SetUnitTimeScale(data102.caster, 3)
        ResetUnitAnimation(data102.caster)
        SetUnitAnimation(data102.caster, "attack - 2")
        SF__.CorWait__(math.round(((1.166 * 0.33) * 1000)))
        local tarAttr107 = UnitAttribute105.GetAttr(data102.target)
        local ad__AttackCount108, ad__DamageScaling109, ad__ResetBOJChance110 = SF__.TemplarStrikes.GetAbilityData(level103)
        local radiantDamage = ((attr104:SimMeleeAttack() * ad__DamageScaling109) * (1 - tarAttr107.radiantResistance))
        EventCenter106.Damage:Emit({whichUnit = data102.caster, target = data102.target, amount = radiantDamage, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
        SF__.TemplarStrikes.TryResetBOJ(data102.caster)
        SetUnitTimeScale(data102.caster, 1)
        ResetUnitAnimation(data102.caster)
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
function SF__.TemplarStrikes.IAbilityData.Equals(self__AttackCount, self__DamageScaling111, self__ResetBOJChance, other__AttackCount, other__DamageScaling112, other__ResetBOJChance)
    return ((math.abs((self__DamageScaling111 - other__DamageScaling112)) < 0.0001) and (math.abs((self__ResetBOJChance - other__ResetBOJChance)) < 0.0001))
end
-- TemplarVerdict
SF__.TemplarVerdict = SF__.TemplarVerdict or {}
function SF__.TemplarVerdict.GetAbilityData(level113)
    return 2.25, 0.3, 0.15
end

function SF__.TemplarVerdict.Init()
    local EventCenter114 = require("Lib.EventCenter")
    EventCenter114.RegisterPlayerUnitSpellChannel:Emit({id = SF__.TemplarVerdict.ID, handler = SF__.TemplarVerdict.Check})
    EventCenter114.RegisterPlayerUnitSpellEffect:Emit({id = SF__.TemplarVerdict.ID, handler = SF__.TemplarVerdict.Start})
    ExTriggerRegisterNewUnit(function(u115)
        if (GetUnitTypeId(u115) == FourCC("Hpal")) then
            SF__.TemplarVerdict.UpdateAbilityMeta(u115)
        end
    end)
end

function SF__.TemplarVerdict.Check(data116)
    local UnitAttribute118 = require("Objects.UnitAttribute")
    local attr117 = UnitAttribute118.GetAttr(data116.caster)
    if (attr117.retPalHolyEnergy < 3) then
        IssueImmediateOrderById(data116.caster, SF__.ConstOrderId.Stop)
        ExTextState(data116.caster, "圣能不足")
    end
end

function SF__.TemplarVerdict.UpdateAbilityMeta(u119)
    local p120 = GetOwningPlayer(u119)
    local datas__DamageScaling121, datas__JudgementDamageScaling, datas__ChanceToResetJudgement = {}, {}, {}
    do
        local i122 = 0
        while (i122 < 1) do
            do
                local item__DamageScaling123, item__JudgementDamageScaling, item__ChanceToResetJudgement = SF__.TemplarVerdict.GetAbilityData((i122 + 1))
                table.insert(datas__DamageScaling121, item__DamageScaling123)
                table.insert(datas__JudgementDamageScaling, item__JudgementDamageScaling)
                table.insert(datas__ChanceToResetJudgement, item__ChanceToResetJudgement)
            end
            ::continue::
            i122 = (i122 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p120, SF__.TemplarVerdict.ID, "学习圣殿骑士的裁决 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p120, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决造成一次攻击伤害，如果目标被审判，造成30%的额外伤害，15%几率重置审判。消耗|cffff8c003|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 5秒\r\n\r\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas__JudgementDamageScaling[(0 + 1)] * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas__ChanceToResetJudgement[(0 + 1)] * 100)), "%的战争艺术触发几率。"), 0)
    do
        local i124 = 0
        while (i124 < 1) do
            local data__DamageScaling125, data__JudgementDamageScaling, data__ChanceToResetJudgement = datas__DamageScaling121[(i124 + 1)], datas__JudgementDamageScaling[(i124 + 1)], datas__ChanceToResetJudgement[(i124 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p120, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决 - [|cffffcc00", (i124 + 1), "级|r]"), i124)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p120, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决造成一次攻击伤害，造成|cffff8c00", string.format("%.0f", (data__DamageScaling125 * 100)), "%|r的攻击伤害。消耗|cffff8c003|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 5秒"), i124)
            ::continue::
            i124 = (i124 + 1)
        end
    end
end

function SF__.TemplarVerdict.Start(data126)
    local level127 = GetUnitAbilityLevel(data126.caster, SF__.TemplarVerdict.ID)
    local UnitAttribute130 = require("Objects.UnitAttribute")
    local EventCenter132 = require("Lib.EventCenter")
    local ad__DamageScaling128, ad__JudgementDamageScaling, ad__ChanceToResetJudgement = SF__.TemplarVerdict.GetAbilityData(level127)
    local attr129 = UnitAttribute130.GetAttr(data126.caster)
    local damage131 = (attr129:SimAttack(UnitAttribute130.HeroAttributeType.Strength) * ad__DamageScaling128)
    EventCenter132.Damage:Emit({whichUnit = data126.caster, target = data126.target, amount = damage131, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_SLICE, outResult = {}})
    attr129.retPalHolyEnergy = (attr129.retPalHolyEnergy - 3)
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
function SF__.TemplarVerdict.IAbilityData.Equals(self__DamageScaling133, self__JudgementDamageScaling, self__ChanceToResetJudgement, other__DamageScaling134, other__JudgementDamageScaling, other__ChanceToResetJudgement)
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

function SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p4, abilCode5, researchExtendedTooltip, level6)
    if (GetLocalPlayer() ~= p4) then
        return
    end
    BlzSetAbilityResearchExtendedTooltip(abilCode5, researchExtendedTooltip, level6)
end

function SF__.Utils.ExBlzSetAbilityTooltip(p7, abilCode8, tooltip, level9)
    if (GetLocalPlayer() ~= p7) then
        return
    end
    BlzSetAbilityTooltip(abilCode8, tooltip, level9)
end

function SF__.Utils.ExBlzSetAbilityExtendedTooltip(p10, abilCode11, extendedTooltip, level12)
    if (GetLocalPlayer() ~= p10) then
        return
    end
    BlzSetAbilityExtendedTooltip(abilCode11, extendedTooltip, level12)
end

function SF__.Utils.ExBlzSetAbilityIcon(p13, abilCode14, iconPath)
    if (GetLocalPlayer() ~= p13) then
        return
    end
    BlzSetAbilityIcon(abilCode14, iconPath)
end

function SF__.Utils.__Init(self)
    self.__sf_type = SF__.Utils
end

function SF__.Utils.New()
    local self = setmetatable({}, { __index = SF__.Utils })
    SF__.Utils.__Init(self)
    return self
end
-- WordOfGlory
SF__.WordOfGlory = SF__.WordOfGlory or {}
function SF__.WordOfGlory.Init()
    local EventCenter135 = require("Lib.EventCenter")
    EventCenter135.RegisterPlayerUnitSpellChannel:Emit({id = SF__.WordOfGlory.ID, handler = SF__.WordOfGlory.Check})
    EventCenter135.RegisterPlayerUnitSpellEffect:Emit({id = SF__.WordOfGlory.ID, handler = SF__.WordOfGlory.Start})
    ExTriggerRegisterNewUnit(function(u136)
        if (GetUnitTypeId(u136) == FourCC("Hpal")) then
            SF__.WordOfGlory.UpdateAbilityMeta(u136)
        end
    end)
end

function SF__.WordOfGlory.Check(data137)
    local UnitAttribute139 = require("Objects.UnitAttribute")
    local attr138 = UnitAttribute139.GetAttr(data137.caster)
    if (attr138.retPalHolyEnergy < 3) then
        IssueImmediateOrderById(data137.caster, SF__.ConstOrderId.Stop)
        ExTextState(data137.caster, "圣能不足")
    end
end

function SF__.WordOfGlory.UpdateAbilityMeta(u140)
    local p141 = GetOwningPlayer(u140)
    SF__.Utils.ExSetAbilityResearchTooltip(p141, SF__.WordOfGlory.ID, "学习圣殿骑士的裁决 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p141, SF__.WordOfGlory.ID, "圣殿骑士的裁决造成一次攻击伤害，如果目标被审判，造成30%的额外伤害，15%几率重置审判。消耗|cffff8c003|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 5秒\r\n\r\n|cffffcc001级|r - |cffff8c00100%|r的攻击伤害，100%的战争艺术触发几率。", 0)
    do
        local i142 = 0
        while (i142 < 1) do
            SF__.Utils.ExBlzSetAbilityTooltip(p141, SF__.WordOfGlory.ID, SF__.StrConcat__("圣殿骑士的裁决 - [|cffffcc00", (i142 + 1), "级|r]"), i142)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p141, SF__.WordOfGlory.ID, "圣殿骑士的裁决造成一次攻击伤害，造成|cffff8c00100%|r的攻击伤害。消耗|cffff8c003|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 5秒", i142)
            ::continue::
            i142 = (i142 + 1)
        end
    end
end

function SF__.WordOfGlory.Start(data143)
    local UnitAttribute145 = require("Objects.UnitAttribute")
    local EventCenter146 = require("Lib.EventCenter")
    local attr144 = UnitAttribute145.GetAttr(data143.caster)
    EventCenter146.Heal:Emit({caster = data143.caster, target = data143.target, amount = 300})
    attr144.retPalHolyEnergy = (attr144.retPalHolyEnergy - 3)
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
