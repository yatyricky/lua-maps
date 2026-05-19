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

function SF__.ListCount__(list)
    return #list.items
end

function SF__.ListGet__(list, index)
    return SF__.ListUnwrap__(list.items[index + 1])
end

function SF__.ListAdd__(list, value)
    table.insert(list.items, SF__.ListWrap__(value))
    list.version = list.version + 1
end

function SF__.ListClear__(list)
    list.items = {}
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

-- Component
SF__.Component = SF__.Component or {}
function SF__.Component:GetInspectorName()
    return "Component"
end

function SF__.Component:GetInspectorText()
    return ""
end

function SF__.Component:Awake()
end

function SF__.Component:OnEnable()
end

function SF__.Component:Start()
end

function SF__.Component:Update()
end

function SF__.Component:OnDisable()
end

function SF__.Component:OnDestroy()
end

function SF__.Component.__Init(self)
    self.__sf_type = SF__.Component
    self.gameObject = nil
end

function SF__.Component.New()
    local self = setmetatable({}, { __index = SF__.Component })
    SF__.Component.__Init(self)
    return self
end
-- AttachEffectComponent
SF__.AttachEffectComponent = SF__.AttachEffectComponent or {}
setmetatable(SF__.AttachEffectComponent, { __index = SF__.Component })
SF__.AttachEffectComponent.__sf_base = SF__.Component
function SF__.AttachEffectComponent:GetInspectorName()
    return "AttachEffectComponent"
end

function SF__.AttachEffectComponent:GetInspectorText()
    return SF__.StrConcat__("Effect: ", SF__.Ternary__((self.eff == nil), "None", "Attached"))
end

function SF__.AttachEffectComponent:Update()
    if (self.eff == nil) then
        return
    end
    -- calculate global TRS from transform and ancestor transforms
    local globalPos__x, globalPos__y, globalPos__z = self.gameObject.transform.position__x, self.gameObject.transform.position__y, self.gameObject.transform.position__z
    local globalRot__x, globalRot__y, globalRot__z, globalRot__w = self.gameObject.transform.rotation__x, self.gameObject.transform.rotation__y, self.gameObject.transform.rotation__z, self.gameObject.transform.rotation__w
    local globalScale__x, globalScale__y, globalScale__z = self.gameObject.transform.localScale__x, self.gameObject.transform.localScale__y, self.gameObject.transform.localScale__z
    local parent = self.gameObject.transform.parent
    while (parent ~= nil) do
        -- globalPos = parent.position + parent.rotation * Vector3.Scale(parent.localScale, globalPos);
        globalRot__x, globalRot__y, globalRot__z, globalRot__w = SF__.Quaternion.op_Multiply__quaternionquaternion(parent.rotation__x, parent.rotation__y, parent.rotation__z, parent.rotation__w, globalRot__x, globalRot__y, globalRot__z, globalRot__w)
        globalScale__x, globalScale__y, globalScale__z = SF__.Vector3.Scale(parent.localScale__x, parent.localScale__y, parent.localScale__z, globalScale__x, globalScale__y, globalScale__z)
        parent = parent.parent
        ::continue::
    end
    -- BlzSetSpecialEffectPosition(eff, globalPos.x, globalPos.y, globalPos.z);
    SF__.Quaternion.ApplyToEffect(globalRot__x, globalRot__y, globalRot__z, globalRot__w, self.eff)
    BlzSetSpecialEffectMatrixScale(self.eff, globalScale__x, globalScale__y, globalScale__z)
end

function SF__.AttachEffectComponent.__Init(self)
    SF__.Component.__Init(self)
    self.__sf_type = SF__.AttachEffectComponent
    self.eff = nil
end

function SF__.AttachEffectComponent.New()
    local self = setmetatable({}, { __index = SF__.AttachEffectComponent })
    SF__.AttachEffectComponent.__Init(self)
    return self
end
-- BladeOfJustice
SF__.BladeOfJustice = SF__.BladeOfJustice or {}
function SF__.BladeOfJustice.GetAbilityData(level237)
    return (75 * level237), 5, (10 * level237)
end

function SF__.BladeOfJustice.Init()
    local EventCenter = require("Lib.EventCenter")
    EventCenter.RegisterPlayerUnitSpellEffect:Emit({id = SF__.BladeOfJustice.ID, handler = SF__.BladeOfJustice.Start})
    ExTriggerRegisterNewUnit(function(u238)
        if (GetUnitTypeId(u238) == FourCC("Hpal")) then
            SF__.BladeOfJustice.UpdateAbilityMeta(u238)
        end
    end)
end

function SF__.BladeOfJustice.UpdateAbilityMeta(u239)
    local p240 = GetOwningPlayer(u239)
    local datas__Damage, datas__Duration, datas__DamagePerSecond = {}, {}, {}
    do
        local i241 = 0
        while (i241 < 3) do
            do
                local item__Damage, item__Duration, item__DamagePerSecond = SF__.BladeOfJustice.GetAbilityData((i241 + 1))
                table.insert(datas__Damage, item__Damage)
                table.insert(datas__Duration, item__Duration)
                table.insert(datas__DamagePerSecond, item__DamagePerSecond)
            end
            ::continue::
            i241 = (i241 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p240, SF__.BladeOfJustice.ID, "学习公正之剑 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p240, SF__.BladeOfJustice.ID, SF__.StrConcat__("用圣光的利刃刺穿目标，造成法术伤害，在一定时间内对附近敌人每秒造成光辉伤害。产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 10秒\n\n|cffffcc001级|r - 造成|cffff8c00", datas__Damage[(0 + 1)], "|r的直接法术伤害，|cffff8c00", datas__Duration[(0 + 1)], "|r秒内对附近敌人每秒造成|cffff8c00", datas__DamagePerSecond[(0 + 1)], "|r的光辉伤害。产生|cffff8c001|r点圣能。\n|cffffcc002级|r - 造成|cffff8c00", datas__Damage[(1 + 1)], "|r的直接法术伤害，|cffff8c00", datas__Duration[(1 + 1)], "|r秒内对附近敌人每秒造成|cffff8c00", datas__DamagePerSecond[(1 + 1)], "|r的光辉伤害。产生|cffff8c001|r点圣能。\n|cffffcc003级|r - 造成|cffff8c00", datas__Damage[(2 + 1)], "|r的直接法术伤害，|cffff8c00", datas__Duration[(2 + 1)], "|r秒内对附近敌人每秒造成|cffff8c00", datas__DamagePerSecond[(2 + 1)], "|r的光辉伤害。产生|cffff8c001|r点圣能。"), 0)
    do
        local i242 = 0
        while (i242 < 3) do
            local data__Damage, data__Duration, data__DamagePerSecond = datas__Damage[(i242 + 1)], datas__Duration[(i242 + 1)], datas__DamagePerSecond[(i242 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p240, SF__.BladeOfJustice.ID, SF__.StrConcat__("公正之剑 - [|cffffcc00", (i242 + 1), "级|r]"), i242)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p240, SF__.BladeOfJustice.ID, SF__.StrConcat__("用圣光的利刃刺穿目标，造成|cffff8c00", data__Damage, "|r的直接法术伤害，在|cffff8c00", data__Duration, "|r秒内对附近敌人每秒造成|cffff8c00", data__DamagePerSecond, "|r的光辉伤害。产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 10秒"), i242)
            ::continue::
            i242 = (i242 + 1)
        end
    end
end

function SF__.BladeOfJustice.Start(data)
    local level243 = GetUnitAbilityLevel(data.caster, SF__.BladeOfJustice.ID)
    local EventCenter244 = require("Lib.EventCenter")
    local ad__Damage, ad__Duration, ad__DamagePerSecond = SF__.BladeOfJustice.GetAbilityData(level243)
    EventCenter244.Damage:Emit({whichUnit = data.caster, target = data.target, amount = ad__Damage, attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
    SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(data.caster, 1)
    SF__.BladeOfJustice.New():StartGroudDamage(data.caster, data.target, ad__Damage, ad__Duration, ad__DamagePerSecond)
end

function SF__.BladeOfJustice:StartGroudDamage(caster, target, ad__Damage245, ad__Duration246, ad__DamagePerSecond247)
    return SF__.CorRun__(function()
        local pos__x, pos__y = SF__.Vector2.FromUnit(target)
        local UnitAttribute = require("Objects.UnitAttribute")
        local EventCenter251 = require("Lib.EventCenter")
        local eff = ExAddSpecialEffect("Abilities/Spells/Orc/LiquidFire/Liquidfire.mdl", pos__x, pos__y, ad__Duration246)
        local p248 = GetOwningPlayer(caster)
        do
            local i249 = 0
            while (i249 < ad__Duration246) do
                SF__.CorWait__(1000)
                ExGroupEnumUnitsInRange(pos__x, pos__y, 300, function(u250)
                    if (not IsUnitEnemy(u250, p248)) then
                        return
                    end
                    if ExIsUnitDead(u250) then
                        return
                    end
                    local tarAttr = UnitAttribute.GetAttr(u250)
                    local damage = (ad__DamagePerSecond247 * (1 - tarAttr.radiantResistance))
                    EventCenter251.Damage:Emit({whichUnit = caster, target = u250, amount = damage, attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
                end)
                ::continue::
                i249 = (i249 + 1)
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
function SF__.CrusaderStrike.GetAbilityData(level252)
    return (0.65 + (0.35 * level252)), (0.15 * (level252 - 1))
end

function SF__.CrusaderStrike.Init()
    local EventCenter253 = require("Lib.EventCenter")
    EventCenter253.RegisterPlayerUnitSpellEffect:Emit({id = SF__.CrusaderStrike.ID, handler = SF__.CrusaderStrike.Start})
    ExTriggerRegisterNewUnit(function(u254)
        if (GetUnitTypeId(u254) == FourCC("Hpal")) then
            SF__.CrusaderStrike.UpdateAbilityMeta(u254)
        end
    end)
end

function SF__.CrusaderStrike.UpdateAbilityMeta(u255)
    local p256 = GetOwningPlayer(u255)
    local datas__DamageScaling, datas__ArtOfWarChance = {}, {}
    do
        local i257 = 0
        while (i257 < 3) do
            do
                local item__DamageScaling, item__ArtOfWarChance = SF__.CrusaderStrike.GetAbilityData((i257 + 1))
                table.insert(datas__DamageScaling, item__DamageScaling)
                table.insert(datas__ArtOfWarChance, item__ArtOfWarChance)
            end
            ::continue::
            i257 = (i257 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p256, SF__.CrusaderStrike.ID, "学习十字军打击 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p256, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击造成一次攻击伤害，伤害系数随技能等级提升。产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 6秒\n\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling[(0 + 1)] * 100)), "%|r的攻击伤害。\n|cffffcc002级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling[(1 + 1)] * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas__ArtOfWarChance[(1 + 1)] * 100)), "%的战争艺术触发几率。\n|cffffcc003级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling[(2 + 1)] * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas__ArtOfWarChance[(2 + 1)] * 100)), "%的战争艺术触发几率。"), 0)
    do
        local i258 = 0
        while (i258 < 3) do
            local data__DamageScaling, data__ArtOfWarChance = datas__DamageScaling[(i258 + 1)], datas__ArtOfWarChance[(i258 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p256, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击 - [|cffffcc00", (i258 + 1), "级|r]"), i258)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p256, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击造成一次攻击伤害，造成|cffff8c00", string.format("%.0f", (data__DamageScaling * 100)), "%|r的攻击伤害", SF__.Ternary__((i258 > 0), SF__.StrConcat__("，", string.format("%.0f", (data__ArtOfWarChance * 100)), "%的战争艺术触发几率"), ""), "。产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 6秒"), i258)
            ::continue::
            i258 = (i258 + 1)
        end
    end
    -- datas.Remove(new IAbilityData { DamageScaling = 0.65f, ArtOfWarChance = 0 });
    do
        local index259 = 0
        table.remove(datas__DamageScaling, (index259 + 1))
        table.remove(datas__ArtOfWarChance, (index259 + 1))
    end
end

function SF__.CrusaderStrike.Start(data260)
    local level261 = GetUnitAbilityLevel(data260.caster, SF__.CrusaderStrike.ID)
    local UnitAttribute262 = require("Objects.UnitAttribute")
    local EventCenter264 = require("Lib.EventCenter")
    local ad__DamageScaling, ad__ArtOfWarChance = SF__.CrusaderStrike.GetAbilityData(level261)
    local attr = UnitAttribute262.GetAttr(data260.caster)
    local damage263 = (attr:SimAttack(UnitAttribute262.HeroAttributeType.Strength) * ad__DamageScaling)
    EventCenter264.Damage:Emit({whichUnit = data260.caster, target = data260.target, amount = damage263, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
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

function SF__.CrusaderStrike.IAbilityData.Equals(self__DamageScaling265, self__ArtOfWarChance266, other__DamageScaling, other__ArtOfWarChance)
    return ((math.abs((self__DamageScaling265 - other__DamageScaling)) < 0.0001) and (math.abs((self__ArtOfWarChance266 - other__ArtOfWarChance)) < 0.0001))
end

function SF__.CrusaderStrike.IAbilityData.GetHashValue(self__DamageScaling267, self__ArtOfWarChance268)
    return 0
end
-- DivineToll
SF__.DivineToll = SF__.DivineToll or {}
function SF__.DivineToll.GetAbilityData(level269)
    return (2 + level269), (50 * level269), 0.1, 10
end

function SF__.DivineToll.Init()
    local EventCenter271 = require("Lib.EventCenter")
    EventCenter271.RegisterPlayerUnitSpellEffect:Emit({id = SF__.DivineToll.ID, handler = function(data270)
        SF__.DivineToll.Start(data270)
    end})
    ExTriggerRegisterNewUnit(function(u272)
        if (GetUnitTypeId(u272) == FourCC("Hpal")) then
            SF__.DivineToll.UpdateAbilityMeta(u272)
        end
    end)
end

function SF__.DivineToll.UpdateAbilityMeta(u273)
    local p274 = GetOwningPlayer(u273)
    local datas__TargetCount, datas__Damage275, datas__RadiantDmgAmp, datas__Duration276 = {}, {}, {}, {}
    do
        local i277 = 0
        while (i277 < 3) do
            do
                local item__TargetCount, item__Damage278, item__RadiantDmgAmp, item__Duration279 = SF__.DivineToll.GetAbilityData((i277 + 1))
                table.insert(datas__TargetCount, item__TargetCount)
                table.insert(datas__Damage275, item__Damage278)
                table.insert(datas__RadiantDmgAmp, item__RadiantDmgAmp)
                table.insert(datas__Duration276, item__Duration279)
            end
            ::continue::
            i277 = (i277 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p274, SF__.DivineToll.ID, "学习圣洁鸣钟 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p274, SF__.DivineToll.ID, SF__.StrConcat__("对附近的多个目标施展审判，造成法术伤害，然后神圣之锤环绕圣殿骑士，每次命中敌人使其受到的光辉伤害提高。每个审判产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 30秒\n\n|cffffcc001级|r - 审判最多|cffff8c00", datas__TargetCount[(0 + 1)], "|r个目标，造成|cffff8c00", datas__Damage275[(0 + 1)], "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas__RadiantDmgAmp[(0 + 1)] * 100)), "%|r的光辉易伤，持续|cffff8c00", datas__Duration276[(0 + 1)], "|r秒。\n|cffffcc002级|r - 审判最多|cffff8c00", datas__TargetCount[(1 + 1)], "|r个目标，造成|cffff8c00", datas__Damage275[(1 + 1)], "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas__RadiantDmgAmp[(1 + 1)] * 100)), "%|r的光辉易伤，持续|cffff8c00", datas__Duration276[(1 + 1)], "|r秒。\n|cffffcc003级|r - 审判最多|cffff8c00", datas__TargetCount[(2 + 1)], "|r个目标，造成|cffff8c00", datas__Damage275[(2 + 1)], "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas__RadiantDmgAmp[(2 + 1)] * 100)), "%|r的光辉易伤，持续|cffff8c00", datas__Duration276[(2 + 1)], "|r秒。"), 0)
    do
        local i280 = 0
        while (i280 < 3) do
            local data__TargetCount, data__Damage281, data__RadiantDmgAmp, data__Duration282 = datas__TargetCount[(i280 + 1)], datas__Damage275[(i280 + 1)], datas__RadiantDmgAmp[(i280 + 1)], datas__Duration276[(i280 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p274, SF__.DivineToll.ID, SF__.StrConcat__("圣洁鸣钟 - [|cffffcc00", (i280 + 1), "级|r]"), i280)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p274, SF__.DivineToll.ID, SF__.StrConcat__("对附近的最多|cffff8c00", data__TargetCount, "|r个目标施展审判，造成|cffff8c00", data__Damage281, "|r点法术伤害，然后神圣之锤环绕圣殿骑士，每次命中敌人使其受到的光辉伤害提高|cffff8c00", string.format("%.0f", (data__RadiantDmgAmp * 100)), "%|r，持续|cffff8c00", data__Duration282, "|r秒。每个审判产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 30秒"), i280)
            ::continue::
            i280 = (i280 + 1)
        end
    end
end

function SF__.DivineToll.Start(data283)
    return SF__.CorRun__(function()
        local pos__x284, pos__y285 = SF__.Vector2.FromUnit(data283.caster)
        local eff286 = AddSpecialEffect("Abilities/Spells/Human/StormBolt/StormBoltMissile.mdl", pos__x284, pos__y285)
        local bolt = SF__.GameObject.New__s("DivineToll_Bolt")
        local boltMis = SF__.GameObject.New__sgameobject("dt_mis", bolt)
        boltMis:AddComponent(SF__.AttachEffectComponent).eff = eff286
        local trs = boltMis.transform
        local rot__x, rot__y, rot__z, rot__w = SF__.Quaternion.Euler((60 / 60), 0, 0)
        while true do
            SF__.CorWait__(16)
            trs.rotation__x, trs.rotation__y, trs.rotation__z, trs.rotation__w = SF__.Quaternion.op_Multiply__quaternionquaternion(rot__x, rot__y, rot__z, rot__w, trs.rotation__x, trs.rotation__y, trs.rotation__z, trs.rotation__w)
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
function SF__.DivineToll.IAbilityData.Equals(self__TargetCount, self__Damage287, self__RadiantDmgAmp, self__Duration288, other__TargetCount, other__Damage289, other__RadiantDmgAmp, other__Duration290)
    return (((math.abs((self__Damage287 - other__Damage289)) < 0.0001) and (math.abs((self__Duration288 - other__Duration290)) < 0.0001)) and (math.abs((self__RadiantDmgAmp - other__RadiantDmgAmp)) < 0.0001))
end
-- GameObject
SF__.GameObject = SF__.GameObject or {}
function SF__.GameObject.DestroyDepthFirst(obj)
    do
        local collection = obj.transform.children
        for i1, child in SF__.ListIterate__(collection) do
            SF__.GameObject.DestroyDepthFirst(child.gameObject)
        end
    end
    do
        local collection2 = obj._components
        for i3, comp in SF__.ListIterate__(collection2) do
            comp:OnDisable()
            comp:OnDestroy()
        end
    end
    SF__.ListClear__(obj._components)
    obj.transform:SetParent(nil)
    SF__.ListRemove__(SF__.Scene.get_Instance().gameObjs, obj)
end

function SF__.GameObject.UpdateBFS(obj3)
    do
        local collection4 = obj3._components
        for i5, comp4 in SF__.ListIterate__(collection4) do
            comp4:Update()
        end
    end
    do
        local collection6 = obj3.transform.children
        for i7, child5 in SF__.ListIterate__(collection6) do
            SF__.GameObject.UpdateBFS(child5.gameObject)
        end
    end
end

function SF__.GameObject:get_components()
    return self._components
end

function SF__.GameObject.__Init__s(self, name)
    self.__sf_type = SF__.GameObject
    self.name = nil
    self.transform = nil
    self._components = SF__.ListNew__({})
    self.name = name
    self.transform = self:AddComponent(SF__.Transform)
    SF__.Scene.get_Instance():AddGameObject(self)
end

function SF__.GameObject.New__s(name)
    local self = setmetatable({}, { __index = SF__.GameObject })
    SF__.GameObject.__Init__s(self, name)
    return self
end

function SF__.GameObject.__Init__sgameobject(self, name6, parent7)
    SF__.GameObject.__Init__s(self, name6)
    self.transform:SetParent(parent7.transform)
end

function SF__.GameObject.New__sgameobject(name6, parent7)
    local self = setmetatable({}, { __index = SF__.GameObject })
    SF__.GameObject.__Init__sgameobject(self, name6, parent7)
    return self
end

function SF__.GameObject:GetComponent(T)
    do
        local collection8 = self._components
        for i9, comp8 in SF__.ListIterate__(collection8) do
            do
                local tComp = comp8
                if SF__.TypeIs__(tComp, T) then
                    return tComp
                end
            end
        end
    end
    return nil
end

function SF__.GameObject:AddComponent(T9)
    local comp10 = (function()
        local obj11 = T9.New()
        obj11.gameObject = self
        return obj11
    end)()
    SF__.ListAdd__(self._components, comp10)
    comp10:Awake()
    comp10:OnEnable()
    comp10:Start()
    return comp10
end

function SF__.GameObject:RemoveAllComponents(T12)
    do
        local i = (SF__.ListCount__(self._components) - 1)
        while (i >= 0) do
            if SF__.TypeIs__(SF__.ListGet__(self._components, i), T12) then
                SF__.ListGet__(self._components, i):OnDisable()
                SF__.ListGet__(self._components, i):OnDestroy()
                SF__.ListRemoveAt__(self._components, i)
            end
            ::continue::
            i = (i - 1)
        end
    end
end

function SF__.GameObject:Update()
    SF__.GameObject.UpdateBFS(self)
end

function SF__.GameObject:Destroy()
    SF__.GameObject.DestroyDepthFirst(self)
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
    SF__.ListAdd__(systems, SF__.Systems.InspectorSystem.New())
    SF__.ListAdd__(systems, require("System.BuffDisplaySystem").new())
    SF__.ListAdd__(systems, SF__.Systems.MeleeGameSystem.New())
    do
        local collection10 = systems
        for i11, system in SF__.ListIterate__(collection10) do
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
        local collection12 = systems
        for i13, system1 in SF__.ListIterate__(collection12) do
            system1:OnEnable()
        end
    end
    local game = FrameTimer.new(function(dt)
        local now = (MathRound((Time.Time * 100)) * 0.01)
        do
            local collection14 = systems
            for i15, system2 in SF__.ListIterate__(collection14) do
                system2:Update(dt, now)
            end
        end
    end, 1, (-1))
    game:Start()
    do
        local __sf_ok, __sf_err = pcall(function()
            SF__.Scene.get_Instance():Run()
        end)
        if not __sf_ok then
            local e = __sf_err
            BJDebugMsg(SF__.StrConcat__("Scene err: ", e))
        end
    end
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

function SF__.Quaternion.op_Multiply__quaternionquaternion(a__x, a__y, a__z, a__w, b__x, b__y, b__z, b__w)
    return ((((a__w * b__x) + (a__x * b__w)) + (a__y * b__z)) - (a__z * b__y)), ((((a__w * b__y) - (a__x * b__z)) + (a__y * b__w)) + (a__z * b__x)), ((((a__w * b__z) + (a__x * b__y)) - (a__y * b__x)) + (a__z * b__w)), ((((a__w * b__w) - (a__x * b__x)) - (a__y * b__y)) - (a__z * b__z))
end

function SF__.Quaternion.op_Multiply__quaternionvector3(q__x, q__y, q__z, q__w, v__x, v__y, v__z)
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
    local roll41 = math.atan2(sinr_cosp, cosr_cosp)
    local sinp = (2 * ((self__w * self__y) - (self__z * self__x)))
    local pitch42
    if (math.abs(sinp) >= 1) then
        pitch42 = ((math.sign(sinp) * math.pi) / 2)
        -- use 90 degrees if out of range
    else
        pitch42 = math.asin(sinp)
    end
    local siny_cosp = (2 * ((self__w * self__z) + (self__x * self__y)))
    local cosy_cosp = (1 - (2 * ((self__y * self__y) + (self__z * self__z))))
    local yaw43 = math.atan2(siny_cosp, cosy_cosp)
    return (pitch42 * bj_RADTODEG), (yaw43 * bj_RADTODEG), (roll41 * bj_RADTODEG)
end

function SF__.Quaternion.Equals(self__x46, self__y47, self__z48, self__w49, other__x, other__y, other__z, other__w)
    return ((((math.abs((self__x46 - other__x)) < 0.0001) and (math.abs((self__y47 - other__y)) < 0.0001)) and (math.abs((self__z48 - other__z)) < 0.0001)) and (math.abs((self__w49 - other__w)) < 0.0001))
end

function SF__.Quaternion.ToString(self__x50, self__y51, self__z52, self__w53)
    return SF__.StrConcat__("(", self__x50, ", ", self__y51, ", ", self__z52, ", ", self__w53, ")")
end

function SF__.Quaternion.ApplyToEffect(self__x54, self__y55, self__z56, self__w57, e58)
    local angles__x, angles__y, angles__z = SF__.Quaternion.get_EulerAngles(self__x54, self__y55, self__z56, self__w57)
    BlzSetSpecialEffectOrientation(e58, angles__y, angles__x, angles__z)
end
-- RetributionPaladinGlobal
SF__.RetributionPaladinGlobal = SF__.RetributionPaladinGlobal or {}
function SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(u291, amount)
    local UnitAttribute293 = require("Objects.UnitAttribute")
    local attr292 = UnitAttribute293.GetAttr(u291)
    attr292.retPalHolyEnergy = math.min((attr292.retPalHolyEnergy + amount), 5)
end

function SF__.RetributionPaladinGlobal:Init()
    ExTriggerRegisterNewUnit(function(u294)
        if (GetUnitTypeId(u294) == FourCC("Hpal")) then
            SF__.ListAdd__(self._units, u294)
        end
    end)
    _ = self:Start()
end

function SF__.RetributionPaladinGlobal:Start()
    return SF__.CorRun__(function()
        local UnitAttribute297 = require("Objects.UnitAttribute")
        while true do
            do
                local collection16 = self._units
                for i17, u295 in SF__.ListIterate__(collection16) do
                    local attr296 = UnitAttribute297.GetAttr(u295)
                    ExSetUnitMana(u295, ((ExGetUnitMaxMana(u295) * attr296.retPalHolyEnergy) * 0.2))
                    if (attr296.retPalHolyEnergy >= 3) then
                        SF__.Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u295), FourCC("A006"), "ReplaceableTextures/CommandButtons/BTNinv_helmet_96.tga")
                    else
                        SF__.Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u295), FourCC("A006"), "ReplaceableTextures/PassiveButtons/PASBTNinv_helmet_96.tga")
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
-- Scene
SF__.Scene = SF__.Scene or {}
function SF__.Scene.get_Instance()
    return (function()
        if SF__.Scene._instance ~= nil then
            return SF__.Scene._instance
        end
        SF__.Scene._instance = SF__.Scene.New()
        return SF__.Scene._instance
    end)()
end

function SF__.Scene:AddGameObject(obj13)
    SF__.ListAdd__(self.gameObjs, obj13)
end

function SF__.Scene:Run()
    return SF__.CorRun__(function()
        do
            local __sf_ok, __sf_err = pcall(function()
                while true do
                    SF__.CorWait__(100)
                    local rootObjs = SF__.ListNew__({})
                    do
                        local collection18 = self.gameObjs
                        for i20, obj14 in SF__.ListIterate__(collection18) do
                            if (obj14.transform.parent == nil) then
                                SF__.ListAdd__(rootObjs, obj14)
                            end
                        end
                    end
                    do
                        local collection21 = rootObjs
                        for i22, obj15 in SF__.ListIterate__(collection21) do
                            obj15:Update()
                        end
                    end
                    ::continue::
                end
            end)
            if not __sf_ok then
                local e16 = __sf_err
                BJDebugMsg(e16)
                PrintStackTrace()
            end
        end
    end)
end

function SF__.Scene.__Init(self)
    self.__sf_type = SF__.Scene
    self.gameObjs = SF__.ListNew__({})
end

function SF__.Scene.New()
    local self = setmetatable({}, { __index = SF__.Scene })
    SF__.Scene.__Init(self)
    return self
end

SF__.Scene._instance = nil
-- Stack
SF__.Stack = SF__.Stack or {}
function SF__.Stack:Push(item)
    SF__.ListAdd__(self._items, item)
end

function SF__.Stack:Pop()
    if (SF__.ListCount__(self._items) == 0) then
        BJDebugMsg("Stack is empty.")
    end
    local item59 = SF__.ListGet__(self._items, (SF__.ListCount__(self._items) - 1))
    SF__.ListRemoveAt__(self._items, (SF__.ListCount__(self._items) - 1))
    return item59
end

function SF__.Stack:Peek()
    if (SF__.ListCount__(self._items) == 0) then
        BJDebugMsg("Stack is empty.")
    end
    return SF__.ListGet__(self._items, (SF__.ListCount__(self._items) - 1))
end

function SF__.Stack:get_Count()
    return SF__.ListCount__(self._items)
end

function SF__.Stack.__Init(self)
    self.__sf_type = SF__.Stack
    self._items = SF__.ListNew__({})
end

function SF__.Stack.New()
    local self = setmetatable({}, { __index = SF__.Stack })
    SF__.Stack.__Init(self)
    return self
end
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
-- Systems.InspectorSystem
local SystemBase17 = require("System.SystemBase")
SF__.Systems.InspectorSystem = SF__.Systems.InspectorSystem or class("InspectorSystem", SystemBase17)
SF__.Systems.InspectorSystem.__sf_base = SystemBase17
function SF__.Systems.InspectorSystem:Awake()
    self:CreateFrames()
    self:RefreshHierarchy()
    self:SelectFirstVisibleObject()
    self:SetPanelVisible(false)
end

function SF__.Systems.InspectorSystem:Update(dt18)
    if (not self._isVisible) then
        return
    end
    if (self._lastObjectCount ~= SF__.ListCount__(SF__.Scene.get_Instance().gameObjs)) then
        self:RefreshHierarchy()
    end
    if ((self._selectedGameObject == nil) or (not self:SceneContains(self._selectedGameObject))) then
        self:SelectFirstVisibleObject()
    end
    self:RefreshInspectorText()
end

function SF__.Systems.InspectorSystem:CreateFrames()
    self._root = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
    self._toggleButton = BlzCreateFrameByType("BUTTON", "FdfInspectorToggle", self._root, "ScoreScreenTabButtonTemplate", 0)
    BlzFrameSetAbsPoint(self._toggleButton, FRAMEPOINT_BOTTOMLEFT, 0.006, 0.006)
    BlzFrameSetSize(self._toggleButton, SF__.Systems.InspectorSystem.ToggleSize, SF__.Systems.InspectorSystem.ToggleSize)
    self._toggleText = BlzCreateFrameByType("TEXT", "FdfInspectorToggleText", self._toggleButton, "", 0)
    BlzFrameSetAllPoints(self._toggleText, self._toggleButton)
    BlzFrameSetEnable(self._toggleText, false)
    BlzFrameSetTextAlignment(self._toggleText, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_CENTER)
    BlzFrameSetText(self._toggleText, "IN")
    local toggleTrigger = CreateTrigger()
    BlzTriggerRegisterFrameEvent(toggleTrigger, self._toggleButton, FRAMEEVENT_CONTROL_CLICK)
    TriggerAddAction(toggleTrigger, function()
        self:TogglePanel()
    end)
    self._panel = BlzCreateFrameByType("FRAME", "FdfInspectorPanel", self._root, "", 0)
    BlzFrameSetAbsPoint(self._panel, FRAMEPOINT_BOTTOMLEFT, 0.006, 0.048)
    BlzFrameSetSize(self._panel, SF__.Systems.InspectorSystem.PanelWidth, SF__.Systems.InspectorSystem.PanelHeight)
    local panelBackdrop = BlzCreateFrame("EscMenuBackdrop", self._panel, 0, 0)
    BlzFrameSetAllPoints(panelBackdrop, self._panel)
    self:CreatePanelText("FDF Inspector", 0.012, (-0.012), 0.14, 0.016, TEXT_JUSTIFY_LEFT)
    self:CreatePanelText("Hierarchy", SF__.Systems.InspectorSystem.Padding, (-0.034), (SF__.Systems.InspectorSystem.LeftWidth - (SF__.Systems.InspectorSystem.Padding * 2)), 0.014, TEXT_JUSTIFY_LEFT)
    self:CreatePanelText("Components", (SF__.Systems.InspectorSystem.LeftWidth + (SF__.Systems.InspectorSystem.Padding * 2)), (-0.034), ((SF__.Systems.InspectorSystem.PanelWidth - SF__.Systems.InspectorSystem.LeftWidth) - (SF__.Systems.InspectorSystem.Padding * 3)), 0.014, TEXT_JUSTIFY_LEFT)
    local leftBackdrop = BlzCreateFrame("QuestButtonBaseTemplate", self._panel, 0, 0)
    BlzFrameSetPoint(leftBackdrop, FRAMEPOINT_TOPLEFT, self._panel, FRAMEPOINT_TOPLEFT, SF__.Systems.InspectorSystem.Padding, (-0.052))
    BlzFrameSetSize(leftBackdrop, (SF__.Systems.InspectorSystem.LeftWidth - (SF__.Systems.InspectorSystem.Padding * 2)), (SF__.Systems.InspectorSystem.PanelHeight - 0.066))
    local rightBackdrop = BlzCreateFrame("QuestButtonBaseTemplate", self._panel, 0, 0)
    BlzFrameSetPoint(rightBackdrop, FRAMEPOINT_TOPLEFT, self._panel, FRAMEPOINT_TOPLEFT, (SF__.Systems.InspectorSystem.LeftWidth + SF__.Systems.InspectorSystem.Padding), (-0.052))
    BlzFrameSetSize(rightBackdrop, ((SF__.Systems.InspectorSystem.PanelWidth - SF__.Systems.InspectorSystem.LeftWidth) - (SF__.Systems.InspectorSystem.Padding * 2)), (SF__.Systems.InspectorSystem.PanelHeight - 0.066))
    do
        local i19 = 0
        while (i19 < SF__.Systems.InspectorSystem.MaxHierarchyRows) do
            SF__.ListAdd__(self._hierarchyRows, self:CreateHierarchyRow(i19))
            ::continue::
            i19 = (i19 + 1)
        end
    end
    self._inspectorText = BlzCreateFrameByType("TEXT", "FdfInspectorDetailsText", self._panel, "", 0)
    BlzFrameSetPoint(self._inspectorText, FRAMEPOINT_TOPLEFT, self._panel, FRAMEPOINT_TOPLEFT, (SF__.Systems.InspectorSystem.LeftWidth + (SF__.Systems.InspectorSystem.Padding * 2)), (-0.061))
    BlzFrameSetSize(self._inspectorText, ((SF__.Systems.InspectorSystem.PanelWidth - SF__.Systems.InspectorSystem.LeftWidth) - (SF__.Systems.InspectorSystem.Padding * 4)), (SF__.Systems.InspectorSystem.PanelHeight - 0.082))
    BlzFrameSetEnable(self._inspectorText, false)
    BlzFrameSetTextAlignment(self._inspectorText, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_LEFT)
    BlzFrameSetText(self._inspectorText, "")
    self._emptyText = BlzCreateFrameByType("TEXT", "FdfInspectorEmptyText", self._panel, "", 0)
    BlzFrameSetPoint(self._emptyText, FRAMEPOINT_TOPLEFT, self._panel, FRAMEPOINT_TOPLEFT, (SF__.Systems.InspectorSystem.Padding * 2), (-0.066))
    BlzFrameSetSize(self._emptyText, (SF__.Systems.InspectorSystem.LeftWidth - (SF__.Systems.InspectorSystem.Padding * 4)), 0.04)
    BlzFrameSetEnable(self._emptyText, false)
    BlzFrameSetTextAlignment(self._emptyText, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_LEFT)
    BlzFrameSetText(self._emptyText, "No GameObjects")
end

function SF__.Systems.InspectorSystem:CreatePanelText(text, x, y, width, height, horizontalAlign)
    local label = BlzCreateFrameByType("TEXT", "FdfInspectorLabel", self._panel, "", 0)
    BlzFrameSetPoint(label, FRAMEPOINT_TOPLEFT, self._panel, FRAMEPOINT_TOPLEFT, x, y)
    BlzFrameSetSize(label, width, height)
    BlzFrameSetEnable(label, false)
    BlzFrameSetTextAlignment(label, TEXT_JUSTIFY_TOP, horizontalAlign)
    BlzFrameSetText(label, text)
end

function SF__.Systems.InspectorSystem:CreateHierarchyRow(index)
    local y20 = ((-0.061) - (index * (SF__.Systems.InspectorSystem.RowHeight + SF__.Systems.InspectorSystem.RowGap)))
    local button = BlzCreateFrameByType("BUTTON", "FdfInspectorHierarchyRow", self._panel, "ScoreScreenTabButtonTemplate", index)
    BlzFrameSetPoint(button, FRAMEPOINT_TOPLEFT, self._panel, FRAMEPOINT_TOPLEFT, (SF__.Systems.InspectorSystem.Padding * 2), y20)
    BlzFrameSetSize(button, (SF__.Systems.InspectorSystem.LeftWidth - (SF__.Systems.InspectorSystem.Padding * 4)), SF__.Systems.InspectorSystem.RowHeight)
    local label21 = BlzCreateFrameByType("TEXT", "FdfInspectorHierarchyRowText", button, "", index)
    BlzFrameSetPoint(label21, FRAMEPOINT_TOPLEFT, button, FRAMEPOINT_TOPLEFT, 0.004, (-0.002))
    BlzFrameSetSize(label21, (SF__.Systems.InspectorSystem.LeftWidth - (SF__.Systems.InspectorSystem.Padding * 5)), (SF__.Systems.InspectorSystem.RowHeight - 0.003))
    BlzFrameSetEnable(label21, false)
    BlzFrameSetTextAlignment(label21, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_LEFT)
    BlzFrameSetText(label21, "")
    local row = SF__.Systems.InspectorSystem.HierarchyRow.New(button, label21)
    local trigger = CreateTrigger()
    BlzTriggerRegisterFrameEvent(trigger, button, FRAMEEVENT_CONTROL_CLICK)
    TriggerAddAction(trigger, function()
        self:SelectRow(row)
    end)
    BlzFrameSetVisible(button, false)
    return row
end

function SF__.Systems.InspectorSystem:TogglePanel()
    self:SetPanelVisible((not self._isVisible))
end

function SF__.Systems.InspectorSystem:SetPanelVisible(visible)
    self._isVisible = visible
    BlzFrameSetVisible(self._panel, visible)
    BlzFrameSetText(self._toggleText, SF__.Ternary__(visible, "X", "IN"))
    if visible then
        self:RefreshHierarchy()
        if (self._selectedGameObject == nil) then
            self:SelectFirstVisibleObject()
        end
        self:RefreshInspectorText()
    end
end

function SF__.Systems.InspectorSystem:SelectRow(row22)
    if (row22.gameObject == nil) then
        return
    end
    self._selectedGameObject = row22.gameObject
    self:RefreshHierarchySelection()
    self:RefreshInspectorText()
end

function SF__.Systems.InspectorSystem:SelectFirstVisibleObject()
    self._selectedGameObject = SF__.Ternary__((SF__.ListCount__(self._visibleObjects) > 0), SF__.ListGet__(self._visibleObjects, 0), nil)
    self:RefreshHierarchySelection()
    self:RefreshInspectorText()
end

function SF__.Systems.InspectorSystem:RefreshHierarchy()
    SF__.ListClear__(self._visibleObjects)
    do
        local collection23 = SF__.Scene.get_Instance().gameObjs
        for i25, obj23 in SF__.ListIterate__(collection23) do
            if (obj23.transform.parent == nil) then
                self:AddHierarchyObject(obj23, 0)
            end
        end
    end
    do
        local i24 = 0
        while (i24 < SF__.ListCount__(self._hierarchyRows)) do
            local row25 = SF__.ListGet__(self._hierarchyRows, i24)
            if (i24 < SF__.ListCount__(self._visibleObjects)) then
                local obj26 = SF__.ListGet__(self._visibleObjects, i24)
                row25.gameObject = obj26
                row25.depth = self:GetDepth(obj26)
                self:SetRowLabel(row25, obj26.name, row25.depth)
                BlzFrameSetVisible(row25.button, self._isVisible)
            else
                row25.gameObject = nil
                BlzFrameSetVisible(row25.button, false)
            end
            ::continue::
            i24 = (i24 + 1)
        end
    end
    BlzFrameSetVisible(self._emptyText, (self._isVisible and (SF__.ListCount__(self._visibleObjects) == 0)))
    self._lastObjectCount = SF__.ListCount__(SF__.Scene.get_Instance().gameObjs)
    self:RefreshHierarchySelection()
end

function SF__.Systems.InspectorSystem:AddHierarchyObject(obj27, depth)
    if (SF__.ListCount__(self._visibleObjects) >= SF__.Systems.InspectorSystem.MaxHierarchyRows) then
        return
    end
    SF__.ListAdd__(self._visibleObjects, obj27)
    do
        local collection26 = obj27.transform.children
        for i27, child28 in SF__.ListIterate__(collection26) do
            self:AddHierarchyObject(child28.gameObject, (depth + 1))
        end
    end
end

function SF__.Systems.InspectorSystem:GetDepth(obj29)
    local depth30 = 0
    local parent31 = obj29.transform.parent
    while (parent31 ~= nil) do
        depth30 = (depth30 + 1)
        parent31 = parent31.parent
        ::continue::
    end
    return depth30
end

function SF__.Systems.InspectorSystem:SetRowLabel(row32, text33, depth34)
    BlzFrameClearAllPoints(row32.label)
    BlzFrameSetPoint(row32.label, FRAMEPOINT_TOPLEFT, row32.button, FRAMEPOINT_TOPLEFT, (0.004 + (depth34 * SF__.Systems.InspectorSystem.IndentWidth)), (-0.002))
    BlzFrameSetSize(row32.label, ((SF__.Systems.InspectorSystem.LeftWidth - (SF__.Systems.InspectorSystem.Padding * 5)) - (depth34 * SF__.Systems.InspectorSystem.IndentWidth)), (SF__.Systems.InspectorSystem.RowHeight - 0.003))
    BlzFrameSetText(row32.label, text33)
end

function SF__.Systems.InspectorSystem:RefreshHierarchySelection()
    do
        local collection28 = self._hierarchyRows
        for i29, row35 in SF__.ListIterate__(collection28) do
            local isSelected = ((row35.gameObject ~= nil) and (row35.gameObject == self._selectedGameObject))
            BlzFrameSetTextColor(row35.label, SF__.Ternary__(isSelected, BlzConvertColor(255, 255, 220, 80), BlzConvertColor(255, 230, 230, 230)))
        end
    end
end

function SF__.Systems.InspectorSystem:RefreshInspectorText()
    if (self._selectedGameObject == nil) then
        BlzFrameSetText(self._inspectorText, "")
        return
    end
    local text36 = SF__.StrConcat__(self._selectedGameObject.name, "\n")
    do
        local collection30 = self._selectedGameObject:get_components()
        for i31, component in SF__.ListIterate__(collection30) do
            text36 = SF__.StrConcat__(text36, "\n[", component:GetInspectorName(), "]")
            local inspectorText = component:GetInspectorText()
            if (inspectorText ~= "") then
                text36 = SF__.StrConcat__(text36, "\n", inspectorText)
            end
        end
    end
    BlzFrameSetText(self._inspectorText, text36)
end

function SF__.Systems.InspectorSystem:SceneContains(gameObject)
    do
        local collection32 = SF__.Scene.get_Instance().gameObjs
        for i33, obj37 in SF__.ListIterate__(collection32) do
            if (obj37 == gameObject) then
                return true
            end
        end
    end
    return false
end

function SF__.Systems.InspectorSystem.__Init(self)
    self.__sf_type = SF__.Systems.InspectorSystem
    self._hierarchyRows = SF__.ListNew__({})
    self._visibleObjects = SF__.ListNew__({})
    self._isVisible = false
    self._selectedGameObject = nil
    self._root = nil
    self._toggleButton = nil
    self._toggleText = nil
    self._panel = nil
    self._inspectorText = nil
    self._emptyText = nil
    self._lastObjectCount = (-1)
end

function SF__.Systems.InspectorSystem.New()
    local self = SF__.Systems.InspectorSystem.new()
    SF__.Systems.InspectorSystem.__Init(self)
    return self
end

SF__.Systems.InspectorSystem.MaxHierarchyRows = 18
SF__.Systems.InspectorSystem.ToggleSize = 0.036
SF__.Systems.InspectorSystem.PanelWidth = 0.48
SF__.Systems.InspectorSystem.PanelHeight = 0.34
SF__.Systems.InspectorSystem.RowHeight = 0.016
SF__.Systems.InspectorSystem.RowGap = 0.002
SF__.Systems.InspectorSystem.LeftWidth = 0.18
SF__.Systems.InspectorSystem.Padding = 0.008
SF__.Systems.InspectorSystem.IndentWidth = 0.012
SF__.Systems.InspectorSystem = SF__.Systems.InspectorSystem or {}
-- Systems.InspectorSystem.HierarchyRow
SF__.Systems.InspectorSystem.HierarchyRow = SF__.Systems.InspectorSystem.HierarchyRow or {}
function SF__.Systems.InspectorSystem.HierarchyRow.__Init(self, button38, label39)
    self.__sf_type = SF__.Systems.InspectorSystem.HierarchyRow
    self.button = nil
    self.label = nil
    self.gameObject = nil
    self.depth = 0
    self.button = button38
    self.label = label39
end

function SF__.Systems.InspectorSystem.HierarchyRow.New(button38, label39)
    local self = setmetatable({}, { __index = SF__.Systems.InspectorSystem.HierarchyRow })
    SF__.Systems.InspectorSystem.HierarchyRow.__Init(self, button38, label39)
    return self
end
-- Systems.MeleeGameSystem
local SystemBase40 = require("System.SystemBase")
SF__.Systems.MeleeGameSystem = SF__.Systems.MeleeGameSystem or class("MeleeGameSystem", SystemBase40)
SF__.Systems.MeleeGameSystem.__sf_base = SystemBase40
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
function SF__.TemplarStrikes.GetAbilityData(level298)
    return 2, (0.5 + (0.25 * level298)), (0.05 * level298)
end

function SF__.TemplarStrikes.Init()
    local EventCenter299 = require("Lib.EventCenter")
    EventCenter299.RegisterPlayerUnitSpellEffect:Emit({id = SF__.TemplarStrikes.ID, handler = SF__.TemplarStrikes.Start})
    ExTriggerRegisterNewUnit(function(u300)
        if (GetUnitTypeId(u300) == FourCC("Hpal")) then
            SF__.TemplarStrikes.UpdateAbilityMeta(u300)
            SetHeroLevel(u300, 10, true)
        end
    end)
    EventCenter299.RegisterPlayerUnitDamaged:Emit(function(caster301, target302, damage303, weapType, dmgType, isAttack)
        if (GetUnitAbilityLevel(caster301, SF__.TemplarStrikes.ID) <= 0) then
            return
        end
        if (not isAttack) then
            return
        end
        if (target302 == nil) then
            return
        end
        if ExIsUnitDead(target302) then
            return
        end
        SF__.TemplarStrikes.TryResetBOJ(caster301)
    end)
end

function SF__.TemplarStrikes.TryResetBOJ(caster304)
    local level305 = GetUnitAbilityLevel(caster304, SF__.TemplarStrikes.ID)
    local ad__AttackCount, ad__DamageScaling306, ad__ResetBOJChance = SF__.TemplarStrikes.GetAbilityData(level305)
    if (math.random() >= ad__ResetBOJChance) then
        return
    end
    BlzEndUnitAbilityCooldown(caster304, SF__.BladeOfJustice.ID)
    ExAddSpecialEffectTarget("Abilities/Spells/Items/AIam/AIamTarget.mdl", caster304, "origin", 0.3)
end

function SF__.TemplarStrikes.UpdateAbilityMeta(u307)
    local p308 = GetOwningPlayer(u307)
    local datas__AttackCount, datas__DamageScaling309, datas__ResetBOJChance = {}, {}, {}
    do
        local i310 = 0
        while (i310 < SF__.TemplarStrikes.MaxLevel) do
            do
                local item__AttackCount, item__DamageScaling311, item__ResetBOJChance = SF__.TemplarStrikes.GetAbilityData((i310 + 1))
                table.insert(datas__AttackCount, item__AttackCount)
                table.insert(datas__DamageScaling309, item__DamageScaling311)
                table.insert(datas__ResetBOJChance, item__ResetBOJChance)
            end
            ::continue::
            i310 = (i310 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p308, SF__.TemplarStrikes.ID, "学习圣殿骑士之击 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p308, SF__.TemplarStrikes.ID, SF__.StrConcat__("快速攻击目标|cffff8c00", datas__AttackCount[(0 + 1)], "|r次，第一次造成普通攻击伤害，第二次造成光辉伤害，有一定几率重置公正之剑的冷却时间，普通攻击也会触发。\n\n|cff99ccff冷却时间|r - 10秒\n\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling309[(0 + 1)] * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas__ResetBOJChance[(0 + 1)] * 100)), "%|r的几率重置公正之剑。\n|cffffcc002级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling309[(1 + 1)] * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas__ResetBOJChance[(1 + 1)] * 100)), "%|r的几率重置公正之剑。\n|cffffcc003级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling309[(2 + 1)] * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas__ResetBOJChance[(2 + 1)] * 100)), "%|r的几率重置公正之剑。"), 0)
    do
        local i312 = 0
        while (i312 < SF__.TemplarStrikes.MaxLevel) do
            local data__AttackCount, data__DamageScaling313, data__ResetBOJChance = datas__AttackCount[(i312 + 1)], datas__DamageScaling309[(i312 + 1)], datas__ResetBOJChance[(i312 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p308, SF__.TemplarStrikes.ID, SF__.StrConcat__("圣殿骑士之击 - [|cffffcc00", (i312 + 1), "级|r]"), i312)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p308, SF__.TemplarStrikes.ID, SF__.StrConcat__("快速攻击目标|cffff8c00", data__AttackCount, "|r次，第一次造成普通攻击伤害，第二次造成普通攻击|cffff8c00", string.format("%.0f", (data__DamageScaling313 * 100)), "%|r的光辉伤害，|cffff8c00", string.format("%.0f", (data__ResetBOJChance * 100)), "%|r几率重置公正之剑的冷却时间，普通攻击也会触发。\n\n|cff99ccff冷却时间|r - 10秒"), i312)
            ::continue::
            i312 = (i312 + 1)
        end
    end
end

function SF__.TemplarStrikes.Start(data314)
    return SF__.CorRun__(function()
        local level315 = GetUnitAbilityLevel(data314.caster, SF__.TemplarStrikes.ID)
        local UnitAttribute317 = require("Objects.UnitAttribute")
        local EventCenter318 = require("Lib.EventCenter")
        local attr316 = UnitAttribute317.GetAttr(data314.caster)
        local normalDamage = attr316:SimMeleeAttack()
        EventCenter318.Damage:Emit({whichUnit = data314.caster, target = data314.target, amount = normalDamage, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
        SF__.TemplarStrikes.TryResetBOJ(data314.caster)
        SetUnitTimeScale(data314.caster, 3)
        ResetUnitAnimation(data314.caster)
        SetUnitAnimation(data314.caster, "attack - 2")
        SF__.CorWait__(math.round(((1.166 * 0.33) * 1000)))
        local tarAttr319 = UnitAttribute317.GetAttr(data314.target)
        local ad__AttackCount320, ad__DamageScaling321, ad__ResetBOJChance322 = SF__.TemplarStrikes.GetAbilityData(level315)
        local radiantDamage = ((attr316:SimMeleeAttack() * ad__DamageScaling321) * (1 - tarAttr319.radiantResistance))
        EventCenter318.Damage:Emit({whichUnit = data314.caster, target = data314.target, amount = radiantDamage, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
        SF__.TemplarStrikes.TryResetBOJ(data314.caster)
        SetUnitTimeScale(data314.caster, 1)
        ResetUnitAnimation(data314.caster)
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
function SF__.TemplarStrikes.IAbilityData.Equals(self__AttackCount, self__DamageScaling323, self__ResetBOJChance, other__AttackCount, other__DamageScaling324, other__ResetBOJChance)
    return ((math.abs((self__DamageScaling323 - other__DamageScaling324)) < 0.0001) and (math.abs((self__ResetBOJChance - other__ResetBOJChance)) < 0.0001))
end
-- TemplarVerdict
SF__.TemplarVerdict = SF__.TemplarVerdict or {}
function SF__.TemplarVerdict.GetAbilityData(level325)
    return 2.25, 0.3, 0.15
end

function SF__.TemplarVerdict.Init()
    local EventCenter326 = require("Lib.EventCenter")
    EventCenter326.RegisterPlayerUnitSpellChannel:Emit({id = SF__.TemplarVerdict.ID, handler = SF__.TemplarVerdict.Check})
    EventCenter326.RegisterPlayerUnitSpellEffect:Emit({id = SF__.TemplarVerdict.ID, handler = SF__.TemplarVerdict.Start})
    ExTriggerRegisterNewUnit(function(u327)
        if (GetUnitTypeId(u327) == FourCC("Hpal")) then
            SF__.TemplarVerdict.UpdateAbilityMeta(u327)
        end
    end)
end

function SF__.TemplarVerdict.Check(data328)
    local UnitAttribute330 = require("Objects.UnitAttribute")
    local attr329 = UnitAttribute330.GetAttr(data328.caster)
    if (attr329.retPalHolyEnergy < 3) then
        IssueImmediateOrderById(data328.caster, SF__.ConstOrderId.Stop)
        ExTextState(data328.caster, "圣能不足")
    end
end

function SF__.TemplarVerdict.UpdateAbilityMeta(u331)
    local p332 = GetOwningPlayer(u331)
    local datas__DamageScaling333, datas__JudgementDamageScaling, datas__ChanceToResetJudgement = {}, {}, {}
    do
        local i334 = 0
        while (i334 < 1) do
            do
                local item__DamageScaling335, item__JudgementDamageScaling, item__ChanceToResetJudgement = SF__.TemplarVerdict.GetAbilityData((i334 + 1))
                table.insert(datas__DamageScaling333, item__DamageScaling335)
                table.insert(datas__JudgementDamageScaling, item__JudgementDamageScaling)
                table.insert(datas__ChanceToResetJudgement, item__ChanceToResetJudgement)
            end
            ::continue::
            i334 = (i334 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p332, SF__.TemplarVerdict.ID, "学习圣殿骑士的裁决 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p332, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决造成一次攻击伤害，如果目标被审判，造成30%的额外伤害，15%几率重置审判。消耗|cffff8c003|r点圣能。\n\n|cff99ccff冷却时间|r - 5秒\n\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas__JudgementDamageScaling[(0 + 1)] * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas__ChanceToResetJudgement[(0 + 1)] * 100)), "%的战争艺术触发几率。"), 0)
    do
        local i336 = 0
        while (i336 < 1) do
            local data__DamageScaling337, data__JudgementDamageScaling, data__ChanceToResetJudgement = datas__DamageScaling333[(i336 + 1)], datas__JudgementDamageScaling[(i336 + 1)], datas__ChanceToResetJudgement[(i336 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p332, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决 - [|cffffcc00", (i336 + 1), "级|r]"), i336)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p332, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决造成一次攻击伤害，造成|cffff8c00", string.format("%.0f", (data__DamageScaling337 * 100)), "%|r的攻击伤害。消耗|cffff8c003|r点圣能。\n\n|cff99ccff冷却时间|r - 5秒"), i336)
            ::continue::
            i336 = (i336 + 1)
        end
    end
end

function SF__.TemplarVerdict.Start(data338)
    local level339 = GetUnitAbilityLevel(data338.caster, SF__.TemplarVerdict.ID)
    local UnitAttribute342 = require("Objects.UnitAttribute")
    local EventCenter344 = require("Lib.EventCenter")
    local ad__DamageScaling340, ad__JudgementDamageScaling, ad__ChanceToResetJudgement = SF__.TemplarVerdict.GetAbilityData(level339)
    local attr341 = UnitAttribute342.GetAttr(data338.caster)
    local damage343 = (attr341:SimAttack(UnitAttribute342.HeroAttributeType.Strength) * ad__DamageScaling340)
    EventCenter344.Damage:Emit({whichUnit = data338.caster, target = data338.target, amount = damage343, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_SLICE, outResult = {}})
    attr341.retPalHolyEnergy = (attr341.retPalHolyEnergy - 3)
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
function SF__.TemplarVerdict.IAbilityData.Equals(self__DamageScaling345, self__JudgementDamageScaling, self__ChanceToResetJudgement, other__DamageScaling346, other__JudgementDamageScaling, other__ChanceToResetJudgement)
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
    self.localScale__x = 0
    self.localScale__y = 0
    self.localScale__z = 0
    self.children = SF__.ListNew__({})
    self.parent = nil
    self.position__x, self.position__y, self.position__z = 0, 0, 0
    self.rotation__x, self.rotation__y, self.rotation__z, self.rotation__w = SF__.Quaternion.Euler(0, 0, 0)
    self.localScale__x, self.localScale__y, self.localScale__z = 1, 1, 1
end

function SF__.Transform.New()
    local self = setmetatable({}, { __index = SF__.Transform })
    SF__.Transform.__Init(self)
    return self
end

function SF__.Transform:GetInspectorName()
    return "Transform"
end

function SF__.Transform:GetInspectorText()
    return SF__.StrConcat__("Position: ", SF__.Vector3.ToString(self.position__x, self.position__y, self.position__z), "\n", "Rotation: ", SF__.Vector3.ToString(SF__.Quaternion.get_EulerAngles(self.rotation__x, self.rotation__y, self.rotation__z, self.rotation__w)), "\n", "Scale: ", SF__.Vector3.ToString(self.localScale__x, self.localScale__y, self.localScale__z), "\n", "Children: ", SF__.ListCount__(self.children))
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

function SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p60, abilCode61, researchExtendedTooltip, level62)
    if (GetLocalPlayer() ~= p60) then
        return
    end
    BlzSetAbilityResearchExtendedTooltip(abilCode61, researchExtendedTooltip, level62)
end

function SF__.Utils.ExBlzSetAbilityTooltip(p63, abilCode64, tooltip, level65)
    if (GetLocalPlayer() ~= p63) then
        return
    end
    BlzSetAbilityTooltip(abilCode64, tooltip, level65)
end

function SF__.Utils.ExBlzSetAbilityExtendedTooltip(p66, abilCode67, extendedTooltip, level68)
    if (GetLocalPlayer() ~= p66) then
        return
    end
    BlzSetAbilityExtendedTooltip(abilCode67, extendedTooltip, level68)
end

function SF__.Utils.ExBlzSetAbilityIcon(p69, abilCode70, iconPath)
    if (GetLocalPlayer() ~= p69) then
        return
    end
    BlzSetAbilityIcon(abilCode70, iconPath)
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

function SF__.Vector2.Dot(a__x71, a__y72, b__x73, b__y74)
    return ((a__x71 * b__x73) + (a__y72 * b__y74))
end

function SF__.Vector2.Cross(a__x75, a__y76, b__x77, b__y78)
    return ((a__y76 * b__x77) - (a__x75 * b__y78))
end

function SF__.Vector2.op_UnaryNegation(a__x79, a__y80)
    return (-a__x79), (-a__y80)
end

function SF__.Vector2.op_Addition(a__x81, a__y82, b__x83, b__y84)
    return (a__x81 + b__x83), (a__y82 + b__y84)
end

function SF__.Vector2.op_Subtraction(a__x85, a__y86, b__x87, b__y88)
    return (a__x85 - b__x87), (a__y86 - b__y88)
end

function SF__.Vector2.op_Multiply__vector2f(v__x89, v__y90, f)
    return (v__x89 * f), (v__y90 * f)
end

function SF__.Vector2.op_Multiply__fvector2(f91, v__x92, v__y93)
    return (v__x92 * f91), (v__y93 * f91)
end

function SF__.Vector2.op_Division(v__x94, v__y95, f96)
    return (v__x94 / f96), (v__y95 / f96)
end

function SF__.Vector2.op_Equality(a__x97, a__y98, b__x99, b__y100)
    return ((math.abs((a__x97 - b__x99)) < 0.0001) and (math.abs((a__y98 - b__y100)) < 0.0001))
end

function SF__.Vector2.op_Inequality(a__x101, a__y102, b__x103, b__y104)
    return (not SF__.Vector2.op_Equality(a__x101, a__y102, b__x103, b__y104))
end

function SF__.Vector2.UnitDistance(a, b)
    local v1__x, v1__y = SF__.Vector2.FromUnit(a)
    local v2__x, v2__y = SF__.Vector2.FromUnit(b)
    return SF__.Vector2.get_Magnitude(SF__.Vector2.op_Subtraction(v1__x, v1__y, v2__x, v2__y))
end

function SF__.Vector2.SqrUnitDistance(a105, b106)
    local v1__x107, v1__y108 = SF__.Vector2.FromUnit(a105)
    local v2__x109, v2__y110 = SF__.Vector2.FromUnit(b106)
    return SF__.Vector2.get_SqrMagnitude(SF__.Vector2.op_Subtraction(v1__x107, v1__y108, v2__x109, v2__y110))
end

function SF__.Vector2.FromUnit(u)
    return GetUnitX(u), GetUnitY(u)
end

function SF__.Vector2.get_Magnitude(self__x111, self__y112)
    return math.sqrt(SF__.Vector2.get_SqrMagnitude(self__x111, self__y112))
end

function SF__.Vector2.get_SqrMagnitude(self__x113, self__y114)
    return ((self__x113 * self__x113) + (self__y114 * self__y114))
end

function SF__.Vector2.get_Normalized(self__x115, self__y116)
    local mag = SF__.Vector2.get_Magnitude(self__x115, self__y116)
    if (mag < 0.0001) then
        return SF__.Vector2.get_Zero()
    end
    return SF__.Vector2.op_Division(self__x115, self__y116, mag)
end

function SF__.Vector2.ClampMagnitude(self__x119, self__y120, mag121)
    return SF__.Vector2.op_Multiply__vector2f(SF__.Vector2.get_Normalized(self__x119, self__y120), mag121)
end

function SF__.Vector2.Equals(self__x122, self__y123, other__x124, other__y125)
    return SF__.Vector2.op_Equality(self__x122, self__y123, other__x124, other__y125)
end

function SF__.Vector2.ToString(self__x126, self__y127)
    return SF__.StrConcat__("(", self__x126, ", ", self__y127, ")")
end

function SF__.Vector2.Rotate(self__x128, self__y129, angle130)
    local cos = math.cos(angle130)
    local sin = math.sin(angle130)
    return ((self__x128 * cos) - (self__y129 * sin)), ((self__x128 * sin) + (self__y129 * cos))
end

function SF__.Vector2.UnitMoveTo(self__x131, self__y132, u133)
    SetUnitX(u133, self__x131)
    SetUnitY(u133, self__y132)
end

function SF__.Vector2.GetTerrainZ(self__x134, self__y135)
    MoveLocation(SF__.Vector2._loc, self__x134, self__y135)
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

function SF__.Vector3.op_Addition(a__x136, a__y137, a__z138, b__x139, b__y140, b__z141)
    return (a__x136 + b__x139), (a__y137 + b__y140), (a__z138 + b__z141)
end

function SF__.Vector3.op_UnaryNegation(a__x142, a__y143, a__z144)
    return (-a__x142), (-a__y143), (-a__z144)
end

function SF__.Vector3.op_Subtraction(a__x145, a__y146, a__z147, b__x148, b__y149, b__z150)
    return (a__x145 - b__x148), (a__y146 - b__y149), (a__z147 - b__z150)
end

function SF__.Vector3.op_Multiply__vector3f(v__x151, v__y152, v__z153, f154)
    return (v__x151 * f154), (v__y152 * f154), (v__z153 * f154)
end

function SF__.Vector3.op_Multiply__fvector3(f155, v__x156, v__y157, v__z158)
    return (v__x156 * f155), (v__y157 * f155), (v__z158 * f155)
end

function SF__.Vector3.op_Division(v__x159, v__y160, v__z161, f162)
    return (v__x159 / f162), (v__y160 / f162), (v__z161 / f162)
end

function SF__.Vector3.op_Equality(a__x163, a__y164, a__z165, b__x166, b__y167, b__z168)
    return (((math.abs((a__x163 - b__x166)) < 0.0001) and (math.abs((a__y164 - b__y167)) < 0.0001)) and (math.abs((a__z165 - b__z168)) < 0.0001))
end

function SF__.Vector3.op_Inequality(a__x169, a__y170, a__z171, b__x172, b__y173, b__z174)
    return (not SF__.Vector3.op_Equality(a__x169, a__y170, a__z171, b__x172, b__y173, b__z174))
end

function SF__.Vector3.Dot(a__x175, a__y176, a__z177, b__x178, b__y179, b__z180)
    return (((a__x175 * b__x178) + (a__y176 * b__y179)) + (a__z177 * b__z180))
end

function SF__.Vector3.Scale(a__x181, a__y182, a__z183, b__x184, b__y185, b__z186)
    return (a__x181 * b__x184), (a__y182 * b__y185), (a__z183 * b__z186)
end

-- <summary>
-- Warcraft III world space here is right-handed: +x points right, +y points away, +z points up.
-- That means Cross((1,0,0), (0,1,0)) == (0,0,1).
-- </summary>
--
function SF__.Vector3.Cross(a__x187, a__y188, a__z189, b__x190, b__y191, b__z192)
    return ((a__y188 * b__z192) - (a__z189 * b__y191)), ((a__z189 * b__x190) - (a__x187 * b__z192)), ((a__x187 * b__y191) - (a__y188 * b__x190))
end

function SF__.Vector3.Project(v__x193, v__y194, v__z195, onNormal__x, onNormal__y, onNormal__z)
    local sqrMag = SF__.Vector3.Dot(onNormal__x, onNormal__y, onNormal__z, onNormal__x, onNormal__y, onNormal__z)
    if (sqrMag < 0.0001) then
        return SF__.Vector3.get_Zero()
    end
    local dot = SF__.Vector3.Dot(v__x193, v__y194, v__z195, onNormal__x, onNormal__y, onNormal__z)
    return SF__.Vector3.op_Multiply__vector3f(onNormal__x, onNormal__y, onNormal__z, (dot / sqrMag))
end

function SF__.Vector3.ProjectOnPlane(v__x196, v__y197, v__z198, planeNormal__x, planeNormal__y, planeNormal__z)
    return SF__.Vector3.op_Subtraction(v__x196, v__y197, v__z198, SF__.Vector3.Project(v__x196, v__y197, v__z198, planeNormal__x, planeNormal__y, planeNormal__z))
end

function SF__.Vector3._getTerrainZ(x199, y200)
    MoveLocation(SF__.Vector3._loc, x199, y200)
    return GetLocationZ(SF__.Vector3._loc)
end

function SF__.Vector3.FromUnit(u201)
    local x202 = GetUnitX(u201)
    local y203 = GetUnitY(u201)
    return x202, y203, (SF__.Vector3._getTerrainZ(x202, y203) + GetUnitFlyHeight(u201))
end

function SF__.Vector3.get_SqrMagnitude(self__x204, self__y205, self__z206)
    return (((self__x204 * self__x204) + (self__y205 * self__y205)) + (self__z206 * self__z206))
end

function SF__.Vector3.get_Magnitude(self__x207, self__y208, self__z209)
    return math.sqrt(SF__.Vector3.get_SqrMagnitude(self__x207, self__y208, self__z209))
end

function SF__.Vector3.get_Normalized(self__x210, self__y211, self__z212)
    local mag213 = SF__.Vector3.get_Magnitude(self__x210, self__y211, self__z212)
    if (mag213 < 0.0001) then
        return SF__.Vector3.get_Zero()
    end
    return SF__.Vector3.op_Division(self__x210, self__y211, self__z212, mag213)
end

function SF__.Vector3.ClampMagnitude(self__x217, self__y218, self__z219, mag220)
    return SF__.Vector3.op_Multiply__vector3f(SF__.Vector3.get_Normalized(self__x217, self__y218, self__z219), mag220)
end

function SF__.Vector3.Equals(self__x221, self__y222, self__z223, other__x224, other__y225, other__z226)
    return SF__.Vector3.op_Equality(self__x221, self__y222, self__z223, other__x224, other__y225, other__z226)
end

function SF__.Vector3.ToString(self__x227, self__y228, self__z229)
    return SF__.StrConcat__("(", self__x227, ", ", self__y228, ", ", self__z229, ")")
end

function SF__.Vector3.UnitMoveTo(self__x230, self__y231, self__z232, u233, mode)
    if mode == nil then mode = SF__.UnitVec3Mode.Auto end
    local tz = SF__.Vector3._getTerrainZ(self__x230, self__y231)
    local LuaUtils = require("Lib.Utils")
    local defaultFlyHeight = GetUnitDefaultFlyHeight(u233)
    local minZ = (tz + defaultFlyHeight)
    SetUnitPosition(u233, self__x230, self__y231)
    repeat
        local switchValue = mode
        if (switchValue == SF__.UnitVec3Mode.ForceFlying) then
            LuaUtils.SetUnitFlyable(u233)
            SetUnitFlyHeight(u233, (math.max(minZ, self__z232) - minZ), 0)
            break
        elseif (switchValue == SF__.UnitVec3Mode.ForceGround) then
            SetUnitFlyHeight(u233, defaultFlyHeight, 0)
            break
        elseif (switchValue == SF__.UnitVec3Mode.Auto) then
            if IsUnitType(u233, UNIT_TYPE_FLYING) then
                SetUnitFlyHeight(u233, (math.max(minZ, self__z232) - minZ), 0)
            else
                SetUnitFlyHeight(u233, defaultFlyHeight, 0)
            end
            break
        end
    until true
end

function SF__.Vector3.GetTerrainZ(self__x234, self__y235, self__z236)
    return SF__.Vector3._getTerrainZ(self__x234, self__y235)
end

SF__.Vector3._loc = Location(0, 0)
-- WordOfGlory
SF__.WordOfGlory = SF__.WordOfGlory or {}
function SF__.WordOfGlory.Init()
    local EventCenter347 = require("Lib.EventCenter")
    EventCenter347.RegisterPlayerUnitSpellChannel:Emit({id = SF__.WordOfGlory.ID, handler = SF__.WordOfGlory.Check})
    EventCenter347.RegisterPlayerUnitSpellEffect:Emit({id = SF__.WordOfGlory.ID, handler = SF__.WordOfGlory.Start})
    ExTriggerRegisterNewUnit(function(u348)
        if (GetUnitTypeId(u348) == FourCC("Hpal")) then
            SF__.WordOfGlory.UpdateAbilityMeta(u348)
        end
    end)
end

function SF__.WordOfGlory.Check(data349)
    local UnitAttribute351 = require("Objects.UnitAttribute")
    local attr350 = UnitAttribute351.GetAttr(data349.caster)
    if (attr350.retPalHolyEnergy < 3) then
        IssueImmediateOrderById(data349.caster, SF__.ConstOrderId.Stop)
        ExTextState(data349.caster, "圣能不足")
    end
end

function SF__.WordOfGlory.UpdateAbilityMeta(u352)
    local p353 = GetOwningPlayer(u352)
    SF__.Utils.ExSetAbilityResearchTooltip(p353, SF__.WordOfGlory.ID, "学习圣殿骑士的裁决 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p353, SF__.WordOfGlory.ID, "圣殿骑士的裁决造成一次攻击伤害，如果目标被审判，造成30%的额外伤害，15%几率重置审判。消耗|cffff8c003|r点圣能。\n\n|cff99ccff冷却时间|r - 5秒\n\n|cffffcc001级|r - |cffff8c00100%|r的攻击伤害，100%的战争艺术触发几率。", 0)
    do
        local i354 = 0
        while (i354 < 1) do
            SF__.Utils.ExBlzSetAbilityTooltip(p353, SF__.WordOfGlory.ID, SF__.StrConcat__("圣殿骑士的裁决 - [|cffffcc00", (i354 + 1), "级|r]"), i354)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p353, SF__.WordOfGlory.ID, "圣殿骑士的裁决造成一次攻击伤害，造成|cffff8c00100%|r的攻击伤害。消耗|cffff8c003|r点圣能。\n\n|cff99ccff冷却时间|r - 5秒", i354)
            ::continue::
            i354 = (i354 + 1)
        end
    end
end

function SF__.WordOfGlory.Start(data355)
    local UnitAttribute357 = require("Objects.UnitAttribute")
    local EventCenter358 = require("Lib.EventCenter")
    local attr356 = UnitAttribute357.GetAttr(data355.caster)
    EventCenter358.Heal:Emit({caster = data355.caster, target = data355.target, amount = 300})
    attr356.retPalHolyEnergy = (attr356.retPalHolyEnergy - 3)
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
