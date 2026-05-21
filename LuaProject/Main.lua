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

function SF__.ListSort__(list, comparison)
    local compare = comparison or function(a, b)
        if a < b then return -1 end
        if a > b then return 1 end
        return 0
    end
    local items = list.items
    for i = 2, #items do
        local value = items[i]
        local j = i - 1
        while j >= 1 and compare(SF__.ListUnwrap__(value), SF__.ListUnwrap__(items[j])) < 0 do
            items[j + 1] = items[j]
            j = j - 1
        end
        items[j + 1] = value
    end
    list.version = list.version + 1
    return list
end

function SF__.Ternary__(cond, a, b)
    if cond then return a else return b end
end

-- TargetType
SF__.TargetType = SF__.TargetType or {}
SF__.TargetType.Unit = 0
SF__.TargetType.Point = 1

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
SF__.Component.Name = "Component"
SF__.Component.FullName = "Component"
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
SF__.AttachEffectComponent.Name = "AttachEffectComponent"
SF__.AttachEffectComponent.FullName = "AttachEffectComponent"
setmetatable(SF__.AttachEffectComponent, { __index = SF__.Component })
SF__.AttachEffectComponent.__sf_base = SF__.Component
function SF__.AttachEffectComponent:GetInspectorText()
    return SF__.StrConcat__("Effect: ", SF__.Ternary__((self.eff == nil), "None", "Attached"))
end

function SF__.AttachEffectComponent:Update()
    if (self.eff == nil) then
        return
    end
    -- calculate global TRS from transform and ancestor transforms
    local globalPos__x, globalPos__y, globalPos__z = self.gameObject.transform.localPosition__x, self.gameObject.transform.localPosition__y, self.gameObject.transform.localPosition__z
    local globalRot__x, globalRot__y, globalRot__z, globalRot__w = self.gameObject.transform.localRotation__x, self.gameObject.transform.localRotation__y, self.gameObject.transform.localRotation__z, self.gameObject.transform.localRotation__w
    local globalScale__x, globalScale__y, globalScale__z = self.gameObject.transform.localScale__x, self.gameObject.transform.localScale__y, self.gameObject.transform.localScale__z
    local parent = self.gameObject.transform.parent
    while (parent ~= nil) do
        globalPos__x, globalPos__y, globalPos__z = SF__.Vector3.op_Addition(parent.localPosition__x, parent.localPosition__y, parent.localPosition__z, SF__.Quaternion.op_Multiply__quaternionvector3(parent.localRotation__x, parent.localRotation__y, parent.localRotation__z, parent.localRotation__w, SF__.Vector3.Scale(parent.localScale__x, parent.localScale__y, parent.localScale__z, globalPos__x, globalPos__y, globalPos__z)))
        globalRot__x, globalRot__y, globalRot__z, globalRot__w = SF__.Quaternion.op_Multiply__quaternionquaternion(parent.localRotation__x, parent.localRotation__y, parent.localRotation__z, parent.localRotation__w, globalRot__x, globalRot__y, globalRot__z, globalRot__w)
        globalScale__x, globalScale__y, globalScale__z = SF__.Vector3.Scale(parent.localScale__x, parent.localScale__y, parent.localScale__z, globalScale__x, globalScale__y, globalScale__z)
        parent = parent.parent
        ::continue::
    end
    BlzSetSpecialEffectPosition(self.eff, globalPos__x, globalPos__y, globalPos__z)
    SF__.Quaternion.ApplyToEffect(globalRot__x, globalRot__y, globalRot__z, globalRot__w, self.eff)
    BlzSetSpecialEffectMatrixScale(self.eff, globalScale__x, globalScale__y, globalScale__z)
end

function SF__.AttachEffectComponent:OnDestroy()
    if (self.eff ~= nil) then
        DestroyEffect(self.eff)
        self.eff = nil
    end
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
-- AutoTRSComponent
SF__.AutoTRSComponent = SF__.AutoTRSComponent or {}
SF__.AutoTRSComponent.Name = "AutoTRSComponent"
SF__.AutoTRSComponent.FullName = "AutoTRSComponent"
setmetatable(SF__.AutoTRSComponent, { __index = SF__.Component })
SF__.AutoTRSComponent.__sf_base = SF__.Component
function SF__.AutoTRSComponent:Update()
    local trs = self.gameObject.transform
    trs.localRotation__x, trs.localRotation__y, trs.localRotation__z, trs.localRotation__w = SF__.Quaternion.op_Multiply__quaternionquaternion(self.rotation__x, self.rotation__y, self.rotation__z, self.rotation__w, trs.localRotation__x, trs.localRotation__y, trs.localRotation__z, trs.localRotation__w)
end

function SF__.AutoTRSComponent.__Init(self)
    SF__.Component.__Init(self)
    self.__sf_type = SF__.AutoTRSComponent
    self.rotation = SF__.Quaternion.get_identity()
end

function SF__.AutoTRSComponent.New()
    local self = setmetatable({}, { __index = SF__.AutoTRSComponent })
    SF__.AutoTRSComponent.__Init(self)
    return self
end
-- BladeOfJustice
SF__.BladeOfJustice = SF__.BladeOfJustice or {}
SF__.BladeOfJustice.Name = "BladeOfJustice"
SF__.BladeOfJustice.FullName = "BladeOfJustice"
function SF__.BladeOfJustice.GetAbilityData(level308)
    return (75 * level308), 5, (10 * level308)
end

function SF__.BladeOfJustice.Init()
    local EventCenter = require("Lib.EventCenter")
    EventCenter.RegisterPlayerUnitSpellEffect:Emit({id = SF__.BladeOfJustice.ID, handler = SF__.BladeOfJustice.Start})
    ExTriggerRegisterNewUnit(function(u309)
        if (GetUnitTypeId(u309) == FourCC("Hpal")) then
            SF__.BladeOfJustice.UpdateAbilityMeta(u309)
        end
    end)
end

function SF__.BladeOfJustice.UpdateAbilityMeta(u310)
    local p311 = GetOwningPlayer(u310)
    local datas__Damage, datas__Duration, datas__DamagePerSecond = {}, {}, {}
    do
        local i312 = 0
        while (i312 < 3) do
            do
                local item__Damage, item__Duration, item__DamagePerSecond = SF__.BladeOfJustice.GetAbilityData((i312 + 1))
                table.insert(datas__Damage, item__Damage)
                table.insert(datas__Duration, item__Duration)
                table.insert(datas__DamagePerSecond, item__DamagePerSecond)
            end
            ::continue::
            i312 = (i312 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p311, SF__.BladeOfJustice.ID, "学习公正之剑 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p311, SF__.BladeOfJustice.ID, SF__.StrConcat__("用圣光的利刃刺穿目标，造成法术伤害，在一定时间内对附近敌人每秒造成光辉伤害。产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 10秒\n\n|cffffcc001级|r - 造成|cffff8c00", datas__Damage[(0 + 1)], "|r的直接法术伤害，|cffff8c00", datas__Duration[(0 + 1)], "|r秒内对附近敌人每秒造成|cffff8c00", datas__DamagePerSecond[(0 + 1)], "|r的光辉伤害。产生|cffff8c001|r点圣能。\n|cffffcc002级|r - 造成|cffff8c00", datas__Damage[(1 + 1)], "|r的直接法术伤害，|cffff8c00", datas__Duration[(1 + 1)], "|r秒内对附近敌人每秒造成|cffff8c00", datas__DamagePerSecond[(1 + 1)], "|r的光辉伤害。产生|cffff8c001|r点圣能。\n|cffffcc003级|r - 造成|cffff8c00", datas__Damage[(2 + 1)], "|r的直接法术伤害，|cffff8c00", datas__Duration[(2 + 1)], "|r秒内对附近敌人每秒造成|cffff8c00", datas__DamagePerSecond[(2 + 1)], "|r的光辉伤害。产生|cffff8c001|r点圣能。"), 0)
    do
        local i313 = 0
        while (i313 < 3) do
            local data__Damage, data__Duration, data__DamagePerSecond = datas__Damage[(i313 + 1)], datas__Duration[(i313 + 1)], datas__DamagePerSecond[(i313 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p311, SF__.BladeOfJustice.ID, SF__.StrConcat__("公正之剑 - [|cffffcc00", (i313 + 1), "级|r]"), i313)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p311, SF__.BladeOfJustice.ID, SF__.StrConcat__("用圣光的利刃刺穿目标，造成|cffff8c00", data__Damage, "|r的直接法术伤害，在|cffff8c00", data__Duration, "|r秒内对附近敌人每秒造成|cffff8c00", data__DamagePerSecond, "|r的光辉伤害。产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 10秒"), i313)
            ::continue::
            i313 = (i313 + 1)
        end
    end
end

function SF__.BladeOfJustice.Start(data)
    local level314 = GetUnitAbilityLevel(data.caster, SF__.BladeOfJustice.ID)
    local EventCenter315 = require("Lib.EventCenter")
    local ad__Damage, ad__Duration, ad__DamagePerSecond = SF__.BladeOfJustice.GetAbilityData(level314)
    EventCenter315.Damage:Emit({whichUnit = data.caster, target = data.target, amount = ad__Damage, attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
    SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(data.caster, 1)
    SF__.BladeOfJustice.New():StartGroudDamage(data.caster, data.target, ad__Damage, ad__Duration, ad__DamagePerSecond)
end

function SF__.BladeOfJustice:StartGroudDamage(caster, target, ad__Damage316, ad__Duration317, ad__DamagePerSecond318)
    return SF__.CorRun__(function()
        local pos__x, pos__y = SF__.Vector2.FromUnit(target)
        local UnitAttribute = require("Objects.UnitAttribute")
        local EventCenter322 = require("Lib.EventCenter")
        local eff = ExAddSpecialEffect("Abilities/Spells/Orc/LiquidFire/Liquidfire.mdl", pos__x, pos__y, ad__Duration317)
        local p319 = GetOwningPlayer(caster)
        do
            local i320 = 0
            while (i320 < ad__Duration317) do
                SF__.CorWait__(1000)
                ExGroupEnumUnitsInRange(pos__x, pos__y, 300, function(u321)
                    if (not IsUnitEnemy(u321, p319)) then
                        return
                    end
                    if ExIsUnitDead(u321) then
                        return
                    end
                    local tarAttr = UnitAttribute.GetAttr(u321)
                    local damage = (ad__DamagePerSecond318 * (1 - tarAttr.radiantResistance))
                    EventCenter322.Damage:Emit({whichUnit = caster, target = u321, amount = damage, attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
                end)
                ::continue::
                i320 = (i320 + 1)
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
SF__.BladeOfJustice.IAbilityData.Name = "IAbilityData"
SF__.BladeOfJustice.IAbilityData.FullName = "BladeOfJustice.IAbilityData"
function SF__.BladeOfJustice.IAbilityData.Equals(self__Damage, self__Duration, self__DamagePerSecond, other__Damage, other__Duration, other__DamagePerSecond)
    return (((math.abs((self__Damage - other__Damage)) < 0.0001) and (math.abs((self__Duration - other__Duration)) < 0.0001)) and (math.abs((self__DamagePerSecond - other__DamagePerSecond)) < 0.0001))
end
-- ConstOrderId
SF__.ConstOrderId = SF__.ConstOrderId or {}
SF__.ConstOrderId.Name = "ConstOrderId"
SF__.ConstOrderId.FullName = "ConstOrderId"
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
SF__.CrusaderStrike.Name = "CrusaderStrike"
SF__.CrusaderStrike.FullName = "CrusaderStrike"
function SF__.CrusaderStrike.GetAbilityData(level323)
    return (0.65 + (0.35 * level323)), (0.15 * (level323 - 1))
end

function SF__.CrusaderStrike.Init()
    local EventCenter324 = require("Lib.EventCenter")
    EventCenter324.RegisterPlayerUnitSpellEffect:Emit({id = SF__.CrusaderStrike.ID, handler = SF__.CrusaderStrike.Start})
    ExTriggerRegisterNewUnit(function(u325)
        if (GetUnitTypeId(u325) == FourCC("Hpal")) then
            SF__.CrusaderStrike.UpdateAbilityMeta(u325)
        end
    end)
end

function SF__.CrusaderStrike.UpdateAbilityMeta(u326)
    local p327 = GetOwningPlayer(u326)
    local datas__DamageScaling, datas__ArtOfWarChance = {}, {}
    do
        local i328 = 0
        while (i328 < 3) do
            do
                local item__DamageScaling, item__ArtOfWarChance = SF__.CrusaderStrike.GetAbilityData((i328 + 1))
                table.insert(datas__DamageScaling, item__DamageScaling)
                table.insert(datas__ArtOfWarChance, item__ArtOfWarChance)
            end
            ::continue::
            i328 = (i328 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p327, SF__.CrusaderStrike.ID, "学习十字军打击 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p327, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击造成一次攻击伤害，伤害系数随技能等级提升。产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 6秒\n\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling[(0 + 1)] * 100)), "%|r的攻击伤害。\n|cffffcc002级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling[(1 + 1)] * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas__ArtOfWarChance[(1 + 1)] * 100)), "%的战争艺术触发几率。\n|cffffcc003级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling[(2 + 1)] * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas__ArtOfWarChance[(2 + 1)] * 100)), "%的战争艺术触发几率。"), 0)
    do
        local i329 = 0
        while (i329 < 3) do
            local data__DamageScaling, data__ArtOfWarChance = datas__DamageScaling[(i329 + 1)], datas__ArtOfWarChance[(i329 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p327, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击 - [|cffffcc00", (i329 + 1), "级|r]"), i329)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p327, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击造成一次攻击伤害，造成|cffff8c00", string.format("%.0f", (data__DamageScaling * 100)), "%|r的攻击伤害", SF__.Ternary__((i329 > 0), SF__.StrConcat__("，", string.format("%.0f", (data__ArtOfWarChance * 100)), "%的战争艺术触发几率"), ""), "。产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 6秒"), i329)
            ::continue::
            i329 = (i329 + 1)
        end
    end
    -- datas.Remove(new IAbilityData { DamageScaling = 0.65f, ArtOfWarChance = 0 });
    do
        local index330 = 0
        table.remove(datas__DamageScaling, (index330 + 1))
        table.remove(datas__ArtOfWarChance, (index330 + 1))
    end
end

function SF__.CrusaderStrike.Start(data331)
    local level332 = GetUnitAbilityLevel(data331.caster, SF__.CrusaderStrike.ID)
    local UnitAttribute333 = require("Objects.UnitAttribute")
    local EventCenter335 = require("Lib.EventCenter")
    local ad__DamageScaling, ad__ArtOfWarChance = SF__.CrusaderStrike.GetAbilityData(level332)
    local attr = UnitAttribute333.GetAttr(data331.caster)
    local damage334 = (attr:SimAttack(UnitAttribute333.HeroAttributeType.Strength) * ad__DamageScaling)
    EventCenter335.Damage:Emit({whichUnit = data331.caster, target = data331.target, amount = damage334, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
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
SF__.CrusaderStrike.IAbilityData.Name = "IAbilityData"
SF__.CrusaderStrike.IAbilityData.FullName = "CrusaderStrike.IAbilityData"
function SF__.CrusaderStrike.IAbilityData.Scale(self__DamageScaling, self__ArtOfWarChance, scale)
    return (self__DamageScaling * scale), (self__ArtOfWarChance * scale)
end

function SF__.CrusaderStrike.IAbilityData.Equals(self__DamageScaling336, self__ArtOfWarChance337, other__DamageScaling, other__ArtOfWarChance)
    return ((math.abs((self__DamageScaling336 - other__DamageScaling)) < 0.0001) and (math.abs((self__ArtOfWarChance337 - other__ArtOfWarChance)) < 0.0001))
end

function SF__.CrusaderStrike.IAbilityData.GetHashValue(self__DamageScaling338, self__ArtOfWarChance339)
    return 0
end
-- DivineToll
SF__.DivineToll = SF__.DivineToll or {}
SF__.DivineToll.Name = "DivineToll"
SF__.DivineToll.FullName = "DivineToll"
function SF__.DivineToll.GetAbilityData(level340)
    return (2 + level340), (50 * level340), 0.1, 10
end

function SF__.DivineToll.Init()
    local EventCenter342 = require("Lib.EventCenter")
    EventCenter342.RegisterPlayerUnitSpellEffect:Emit({id = SF__.DivineToll.ID, handler = function(data341)
        SF__.DivineToll.Start(data341)
    end})
    ExTriggerRegisterNewUnit(function(u343)
        if (GetUnitTypeId(u343) == FourCC("Hpal")) then
            SF__.DivineToll.UpdateAbilityMeta(u343)
        end
    end)
end

function SF__.DivineToll.UpdateAbilityMeta(u344)
    local p345 = GetOwningPlayer(u344)
    local datas__TargetCount, datas__Damage346, datas__RadiantDmgAmp, datas__Duration347 = {}, {}, {}, {}
    do
        local i348 = 0
        while (i348 < 3) do
            do
                local item__TargetCount, item__Damage349, item__RadiantDmgAmp, item__Duration350 = SF__.DivineToll.GetAbilityData((i348 + 1))
                table.insert(datas__TargetCount, item__TargetCount)
                table.insert(datas__Damage346, item__Damage349)
                table.insert(datas__RadiantDmgAmp, item__RadiantDmgAmp)
                table.insert(datas__Duration347, item__Duration350)
            end
            ::continue::
            i348 = (i348 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p345, SF__.DivineToll.ID, "学习圣洁鸣钟 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p345, SF__.DivineToll.ID, SF__.StrConcat__("对附近的多个目标施展审判，造成法术伤害，然后神圣之锤环绕圣殿骑士，每次命中敌人使其受到的光辉伤害提高。每个审判产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 30秒\n\n|cffffcc001级|r - 审判最多|cffff8c00", datas__TargetCount[(0 + 1)], "|r个目标，造成|cffff8c00", datas__Damage346[(0 + 1)], "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas__RadiantDmgAmp[(0 + 1)] * 100)), "%|r的光辉易伤，持续|cffff8c00", datas__Duration347[(0 + 1)], "|r秒。\n|cffffcc002级|r - 审判最多|cffff8c00", datas__TargetCount[(1 + 1)], "|r个目标，造成|cffff8c00", datas__Damage346[(1 + 1)], "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas__RadiantDmgAmp[(1 + 1)] * 100)), "%|r的光辉易伤，持续|cffff8c00", datas__Duration347[(1 + 1)], "|r秒。\n|cffffcc003级|r - 审判最多|cffff8c00", datas__TargetCount[(2 + 1)], "|r个目标，造成|cffff8c00", datas__Damage346[(2 + 1)], "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas__RadiantDmgAmp[(2 + 1)] * 100)), "%|r的光辉易伤，持续|cffff8c00", datas__Duration347[(2 + 1)], "|r秒。"), 0)
    do
        local i351 = 0
        while (i351 < 3) do
            local data__TargetCount, data__Damage352, data__RadiantDmgAmp, data__Duration353 = datas__TargetCount[(i351 + 1)], datas__Damage346[(i351 + 1)], datas__RadiantDmgAmp[(i351 + 1)], datas__Duration347[(i351 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p345, SF__.DivineToll.ID, SF__.StrConcat__("圣洁鸣钟 - [|cffffcc00", (i351 + 1), "级|r]"), i351)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p345, SF__.DivineToll.ID, SF__.StrConcat__("对附近的最多|cffff8c00", data__TargetCount, "|r个目标施展审判，造成|cffff8c00", data__Damage352, "|r点法术伤害，然后神圣之锤环绕圣殿骑士，每次命中敌人使其受到的光辉伤害提高|cffff8c00", string.format("%.0f", (data__RadiantDmgAmp * 100)), "%|r，持续|cffff8c00", data__Duration353, "|r秒。每个审判产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 30秒"), i351)
            ::continue::
            i351 = (i351 + 1)
        end
    end
end

function SF__.DivineToll.HurlToTarget(caster354, target355, pos__x356, pos__y357, pos__z)
    local outer = SF__.GameObject.New__s("DivineToll_Outer")
    local EventCenter361 = require("Lib.EventCenter")
    outer.transform.localPosition__x, outer.transform.localPosition__y, outer.transform.localPosition__z = 0, 0, 80
    local moveLayer = SF__.GameObject.New__sgameobject("MoveLayer", outer)
    moveLayer.transform.localPosition__x, moveLayer.transform.localPosition__y, moveLayer.transform.localPosition__z = pos__x356, pos__y357, pos__z
    local mtc = moveLayer:AddComponent(SF__.MoveTowardsComponent)
    mtc.targetType = SF__.TargetType.Unit
    mtc.unitTarget = target355
    mtc.speed = 900
    mtc.lookAtTarget = true
    mtc.colliderSize = 32
    mtc.onArrived = function()
        local cPos__x, cPos__y, cPos__z = mtc.gameObject.transform:get_position()
        local eff358 = ExAddSpecialEffect("Abilities/Spells/Human/StormBolt/StormBoltCaster.mdl", cPos__x, cPos__y, 0.1)
        BlzSetSpecialEffectTimeScale(eff358, 0.5)
        BlzSetSpecialEffectColor(eff358, 255, 255, 0)
        local ad__TargetCount, ad__Damage359, ad__RadiantDmgAmp, ad__Duration360 = SF__.DivineToll.GetAbilityData(GetUnitAbilityLevel(caster354, SF__.DivineToll.ID))
        EventCenter361.Damage:Emit({whichUnit = caster354, target = target355, amount = ad__Damage359, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
        SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(caster354, 1)
        outer:Destroy()
    end
    local orientationFixLayer = SF__.GameObject.New__sgameobject("DivineToll_Bolt", moveLayer)
    orientationFixLayer.transform.localRotation__x, orientationFixLayer.transform.localRotation__y, orientationFixLayer.transform.localRotation__z, orientationFixLayer.transform.localRotation__w = SF__.Quaternion.Euler(0, 90, 0)
    local selfRotLayer = SF__.GameObject.New__sgameobject("dt_hand", orientationFixLayer)
    local receiver = selfRotLayer:AddComponent(SF__.AutoTRSComponent)
    receiver.rotation__x, receiver.rotation__y, receiver.rotation__z, receiver.rotation__w = SF__.Quaternion.Euler(((450 * SF__.Scene.DT) / 1000), 0, 0)
    local boltMis = SF__.GameObject.New__sgameobject("dt_mis", selfRotLayer)
    boltMis.transform.localPosition__x, boltMis.transform.localPosition__y, boltMis.transform.localPosition__z = 30, 0, 0
    boltMis.transform.localScale__x, boltMis.transform.localScale__y, boltMis.transform.localScale__z = 0.5, 0.5, 0.5
    local eff362 = AddSpecialEffect("Abilities/Spells/Human/StormBolt/StormBoltMissile.mdl", pos__x356, pos__y357)
    boltMis:AddComponent(SF__.AttachEffectComponent).eff = eff362
    local attachedHoly = SF__.GameObject.New__sgameobject("DivineToll_Holy", boltMis)
    attachedHoly.transform.localPosition__x, attachedHoly.transform.localPosition__y, attachedHoly.transform.localPosition__z = 0, 0, 0
    local effHoly = AddSpecialEffect("Abilities/Weapons/FaerieDragonMissile/FaerieDragonMissile.mdl", pos__x356, pos__y357)
    attachedHoly:AddComponent(SF__.AttachEffectComponent).eff = effHoly
end

function SF__.DivineToll.Start(data363)
    return SF__.CorRun__(function()
        local pos__x364, pos__y365, pos__z366 = SF__.Vector3.FromUnit(data363.caster)
        local targets = SF__.Utils.CsGroupGetUnitsInRange(pos__x364, pos__y365, 600, function(u367)
            if (not IsUnitEnemy(u367, GetOwningPlayer(data363.caster))) then
                return false
            end
            if IsUnitType(u367, UNIT_TYPE_STRUCTURE) then
                return false
            end
            if ExIsUnitDead(u367) then
                return false
            end
            return true
        end)
        if (SF__.ListCount__(targets) == 0) then
            return
        end
        SF__.ListSort__(targets, function(a368, b369)
            local distA = SF__.Vector3.Distance(pos__x364, pos__y365, pos__z366, SF__.Vector3.FromUnit(a368))
            local distB = SF__.Vector3.Distance(pos__x364, pos__y365, pos__z366, SF__.Vector3.FromUnit(b369))
            return SF__.Ternary__((distA == distB), 0, SF__.Ternary__((distA < distB), (-1), 1))
        end)
        do
            local i370 = 0
            while (i370 < (function()
                local field__TargetCount, field__Damage, field__RadiantDmgAmp, field__Duration = SF__.DivineToll.GetAbilityData(GetUnitAbilityLevel(data363.caster, SF__.DivineToll.ID))
                return math.min(SF__.ListCount__(targets), field__TargetCount)
            end)()) do
                SF__.DivineToll.HurlToTarget(data363.caster, SF__.ListGet__(targets, i370), pos__x364, pos__y365, pos__z366)
                SF__.CorWait__(200)
                ::continue::
                i370 = (i370 + 1)
            end
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
SF__.DivineToll.IAbilityData.Name = "IAbilityData"
SF__.DivineToll.IAbilityData.FullName = "DivineToll.IAbilityData"
function SF__.DivineToll.IAbilityData.Equals(self__TargetCount, self__Damage371, self__RadiantDmgAmp, self__Duration372, other__TargetCount, other__Damage373, other__RadiantDmgAmp, other__Duration374)
    return (((math.abs((self__Damage371 - other__Damage373)) < 0.0001) and (math.abs((self__Duration372 - other__Duration374)) < 0.0001)) and (math.abs((self__RadiantDmgAmp - other__RadiantDmgAmp)) < 0.0001))
end
-- GameObject
SF__.GameObject = SF__.GameObject or {}
SF__.GameObject.Name = "GameObject"
SF__.GameObject.FullName = "GameObject"
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

function SF__.GameObject.UpdateBFS(obj10)
    do
        local collection4 = obj10._components
        for i5, comp11 in SF__.ListIterate__(collection4) do
            comp11:Update()
        end
    end
    do
        local collection6 = obj10.transform.children
        for i7, child12 in SF__.ListIterate__(collection6) do
            SF__.GameObject.UpdateBFS(child12.gameObject)
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

function SF__.GameObject.__Init__sgameobject(self, name13, parent14)
    SF__.GameObject.__Init__s(self, name13)
    self.transform:SetParent(parent14.transform)
end

function SF__.GameObject.New__sgameobject(name13, parent14)
    local self = setmetatable({}, { __index = SF__.GameObject })
    SF__.GameObject.__Init__sgameobject(self, name13, parent14)
    return self
end

function SF__.GameObject:GetComponent(T)
    do
        local collection8 = self._components
        for i9, comp15 in SF__.ListIterate__(collection8) do
            do
                local tComp = comp15
                if SF__.TypeIs__(tComp, T) then
                    return tComp
                end
            end
        end
    end
    return nil
end

function SF__.GameObject:AddComponent(T16)
    local comp17 = (function()
        local obj18 = T16.New()
        obj18.gameObject = self
        return obj18
    end)()
    SF__.ListAdd__(self._components, comp17)
    comp17:Awake()
    comp17:OnEnable()
    comp17:Start()
    return comp17
end

function SF__.GameObject:RemoveAllComponents(T19)
    do
        local i = (SF__.ListCount__(self._components) - 1)
        while (i >= 0) do
            if SF__.TypeIs__(SF__.ListGet__(self._components, i), T19) then
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
-- MoveTowardsComponent
SF__.MoveTowardsComponent = SF__.MoveTowardsComponent or {}
SF__.MoveTowardsComponent.Name = "MoveTowardsComponent"
SF__.MoveTowardsComponent.FullName = "MoveTowardsComponent"
setmetatable(SF__.MoveTowardsComponent, { __index = SF__.Component })
SF__.MoveTowardsComponent.__sf_base = SF__.Component
function SF__.MoveTowardsComponent:Update()
    if self.hasArrived then
        return
    end
    local currentPosition__x, currentPosition__y, currentPosition__z = self.gameObject.transform.localPosition__x, self.gameObject.transform.localPosition__y, self.gameObject.transform.localPosition__z
    local targetPosition__x, targetPosition__y, targetPosition__z
    do
        if (self.targetType == SF__.TargetType.Unit) then
            targetPosition__x, targetPosition__y, targetPosition__z = SF__.Vector3.FromUnit(self.unitTarget)
        else
            targetPosition__x, targetPosition__y, targetPosition__z = self.pointTarget__x, self.pointTarget__y, self.pointTarget__z
        end
    end
    local moved__x, moved__y, moved__z = SF__.Vector3.MoveTowards(currentPosition__x, currentPosition__y, currentPosition__z, targetPosition__x, targetPosition__y, targetPosition__z, ((self.speed * SF__.Scene.DT) / 1000))
    self.gameObject.transform.localPosition__x, self.gameObject.transform.localPosition__y, self.gameObject.transform.localPosition__z = moved__x, moved__y, moved__z
    if self.lookAtTarget then
        self.gameObject.transform.localRotation__x, self.gameObject.transform.localRotation__y, self.gameObject.transform.localRotation__z, self.gameObject.transform.localRotation__w = SF__.Quaternion.LookRotation__vector3(SF__.Vector3.op_Subtraction(targetPosition__x, targetPosition__y, targetPosition__z, currentPosition__x, currentPosition__y, currentPosition__z))
    end
    if ((SF__.Vector3.Distance(moved__x, moved__y, moved__z, targetPosition__x, targetPosition__y, targetPosition__z) <= self.colliderSize) and (not self.hasArrived)) then
        self.hasArrived = true
        local delegate = self.onArrived
        if (delegate ~= nil) then
            delegate()
        end
        self.onArrived = nil
    end
end

function SF__.MoveTowardsComponent:GetInspectorText()
    return SF__.StrConcat__("targetType: ", self.targetType, "\nunitTarget: ", SF__.Ternary__((self.unitTarget == nil), "None", GetUnitName(self.unitTarget)), "\npointTarget: ", SF__.Vector3.ToString(self.pointTarget__x, self.pointTarget__y, self.pointTarget__z), "\nspeed: ", self.speed, "\n")
end

function SF__.MoveTowardsComponent.__Init(self)
    SF__.Component.__Init(self)
    self.__sf_type = SF__.MoveTowardsComponent
    self.targetType = 0
    self.unitTarget = nil
    self.pointTarget__x = 0
    self.pointTarget__y = 0
    self.pointTarget__z = 0
    self.speed = 0
    self.lookAtTarget = false
    self.onArrived = nil
    self.colliderSize = 0
    self.hasArrived = false
end

function SF__.MoveTowardsComponent.New()
    local self = setmetatable({}, { __index = SF__.MoveTowardsComponent })
    SF__.MoveTowardsComponent.__Init(self)
    return self
end
-- Program
require("Lib.class")
SF__.Program = SF__.Program or {}
SF__.Program.Name = "Program"
SF__.Program.FullName = "Program"
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
    SF__.Scene.get_Instance():Run()
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
SF__.Quaternion.Name = "Quaternion"
SF__.Quaternion.FullName = "Quaternion"
function SF__.Quaternion.get_identity()
    return 0, 0, 0, 1
end

function SF__.Quaternion.op_Multiply__quaternionquaternion(a__x, a__y, a__z, a__w, b__x, b__y, b__z, b__w)
    return ((((a__w * b__x) + (a__x * b__w)) + (a__y * b__z)) - (a__z * b__y)), ((((a__w * b__y) - (a__x * b__z)) + (a__y * b__w)) + (a__z * b__x)), ((((a__w * b__z) + (a__x * b__y)) - (a__y * b__x)) + (a__z * b__w)), ((((a__w * b__w) - (a__x * b__x)) - (a__y * b__y)) - (a__z * b__z))
end

function SF__.Quaternion.op_Multiply__quaternionvector3(q__x, q__y, q__z, q__w, v__x, v__y, v__z)
    -- https://en.wikipedia.org/wiki/Quaternions_and_spatial_rotation#Using_quaternion_as_rotations
    local u__x, u__y, u__z = q__x, q__y, q__z
    local s = q__w
    return (function()
        local a__x50, a__y51, a__z52 = (function()
            local a__x47, a__y48, a__z49 = SF__.Vector3.op_Multiply__fvector3((2 * SF__.Vector3.Dot(u__x, u__y, u__z, v__x, v__y, v__z)), u__x, u__y, u__z)
            return SF__.Vector3.op_Addition(a__x47, a__y48, a__z49, SF__.Vector3.op_Multiply__fvector3(((s * s) - SF__.Vector3.Dot(u__x, u__y, u__z, u__x, u__y, u__z)), v__x, v__y, v__z))
        end)()
        return SF__.Vector3.op_Addition(a__x50, a__y51, a__z52, SF__.Vector3.op_Multiply__fvector3((2 * s), SF__.Vector3.Cross(u__x, u__y, u__z, v__x, v__y, v__z)))
    end)()
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

function SF__.Quaternion.LookRotation__vector3vector3(forward__x, forward__y, forward__z, upwards__x, upwards__y, upwards__z)
    local worldForward__x, worldForward__y, worldForward__z = SF__.Vector3.get_normalized(forward__x, forward__y, forward__z)
    if (SF__.Vector3.get_sqrMagnitude(worldForward__x, worldForward__y, worldForward__z) < 0.0001) then
        return SF__.Quaternion.get_identity()
    end
    local worldUp__x, worldUp__y, worldUp__z = SF__.Vector3.get_normalized(SF__.Vector3.ProjectOnPlane(upwards__x, upwards__y, upwards__z, worldForward__x, worldForward__y, worldForward__z))
    if (SF__.Vector3.get_sqrMagnitude(worldUp__x, worldUp__y, worldUp__z) < 0.0001) then
        local fallbackUp__x, fallbackUp__y, fallbackUp__z
        do
            if (math.abs(worldForward__z) < 0.999) then
                fallbackUp__x, fallbackUp__y, fallbackUp__z = SF__.Vector3.get_up()
            else
                fallbackUp__x, fallbackUp__y, fallbackUp__z = SF__.Vector3.get_right()
            end
        end
        worldUp__x, worldUp__y, worldUp__z = SF__.Vector3.get_normalized(SF__.Vector3.ProjectOnPlane(fallbackUp__x, fallbackUp__y, fallbackUp__z, worldForward__x, worldForward__y, worldForward__z))
    end
    local worldRight__x, worldRight__y, worldRight__z = SF__.Vector3.get_normalized(SF__.Vector3.Cross(worldForward__x, worldForward__y, worldForward__z, worldUp__x, worldUp__y, worldUp__z))
    worldUp__x, worldUp__y, worldUp__z = SF__.Vector3.Cross(worldRight__x, worldRight__y, worldRight__z, worldForward__x, worldForward__y, worldForward__z)
    local m00 = worldRight__x
    local m01 = worldForward__x
    local m02 = worldUp__x
    local m10 = worldRight__y
    local m11 = worldForward__y
    local m12 = worldUp__y
    local m20 = worldRight__z
    local m21 = worldForward__z
    local m22 = worldUp__z
    local x53
    local y54
    local z
    local w
    local trace = ((m00 + m11) + m22)
    if (trace > 0) then
        local s55 = (math.sqrt((trace + 1)) * 2)
        w = (0.25 * s55)
        x53 = ((m21 - m12) / s55)
        y54 = ((m02 - m20) / s55)
        z = ((m10 - m01) / s55)
    elseif ((m00 > m11) and (m00 > m22)) then
        local s56 = (math.sqrt((((1 + m00) - m11) - m22)) * 2)
        w = ((m21 - m12) / s56)
        x53 = (0.25 * s56)
        y54 = ((m01 + m10) / s56)
        z = ((m02 + m20) / s56)
    else
        if (m11 > m22) then
            local s57 = (math.sqrt((((1 + m11) - m00) - m22)) * 2)
            w = ((m02 - m20) / s57)
            x53 = ((m01 + m10) / s57)
            y54 = (0.25 * s57)
            z = ((m12 + m21) / s57)
        else
            local s58 = (math.sqrt((((1 + m22) - m00) - m11)) * 2)
            w = ((m10 - m01) / s58)
            x53 = ((m02 + m20) / s58)
            y54 = ((m12 + m21) / s58)
            z = (0.25 * s58)
        end
    end
    return SF__.Quaternion.Normalize(x53, y54, z, w)
end

function SF__.Quaternion.LookRotation__vector3(forward__x59, forward__y60, forward__z61)
    return SF__.Quaternion.LookRotation__vector3vector3(forward__x59, forward__y60, forward__z61, SF__.Vector3.get_up())
end

function SF__.Quaternion.Normalize(q__x62, q__y63, q__z64, q__w65)
    local magnitude = math.sqrt(((((q__x62 * q__x62) + (q__y63 * q__y63)) + (q__z64 * q__z64)) + (q__w65 * q__w65)))
    if (magnitude < 0.0001) then
        return SF__.Quaternion.get_identity()
    end
    return (q__x62 / magnitude), (q__y63 / magnitude), (q__z64 / magnitude), (q__w65 / magnitude)
end

function SF__.Quaternion.get_eulerAngles(self__x, self__y, self__z, self__w)
    -- https://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles#Source_Code_2
    local sinr_cosp = (2 * ((self__w * self__x) + (self__y * self__z)))
    local cosr_cosp = (1 - (2 * ((self__x * self__x) + (self__y * self__y))))
    local roll66 = math.atan2(sinr_cosp, cosr_cosp)
    local sinp = (2 * ((self__w * self__y) - (self__z * self__x)))
    local pitch67
    if (math.abs(sinp) >= 1) then
        pitch67 = ((math.sign(sinp) * math.pi) / 2)
        -- use 90 degrees if out of range
    else
        pitch67 = math.asin(sinp)
    end
    local siny_cosp = (2 * ((self__w * self__z) + (self__x * self__y)))
    local cosy_cosp = (1 - (2 * ((self__y * self__y) + (self__z * self__z))))
    local yaw68 = math.atan2(siny_cosp, cosy_cosp)
    return (pitch67 * bj_RADTODEG), (yaw68 * bj_RADTODEG), (roll66 * bj_RADTODEG)
end

function SF__.Quaternion.get_normalized(self__x69, self__y70, self__z71, self__w72)
    return SF__.Quaternion.Normalize(self__x69, self__y70, self__z71, self__w72)
end

function SF__.Quaternion.Equals(self__x77, self__y78, self__z79, self__w80, other__x, other__y, other__z, other__w)
    return ((((math.abs((self__x77 - other__x)) < 0.0001) and (math.abs((self__y78 - other__y)) < 0.0001)) and (math.abs((self__z79 - other__z)) < 0.0001)) and (math.abs((self__w80 - other__w)) < 0.0001))
end

function SF__.Quaternion.ToString(self__x81, self__y82, self__z83, self__w84)
    return SF__.StrConcat__("(", self__x81, ", ", self__y82, ", ", self__z83, ", ", self__w84, ")")
end

function SF__.Quaternion.ApplyToEffect(self__x85, self__y86, self__z87, self__w88, e)
    local angles__x, angles__y, angles__z = SF__.Quaternion.get_eulerAngles(self__x85, self__y86, self__z87, self__w88)
    BlzSetSpecialEffectOrientation(e, (angles__y * bj_DEGTORAD), (angles__x * bj_DEGTORAD), (angles__z * bj_DEGTORAD))
end
-- RetributionPaladinGlobal
SF__.RetributionPaladinGlobal = SF__.RetributionPaladinGlobal or {}
SF__.RetributionPaladinGlobal.Name = "RetributionPaladinGlobal"
SF__.RetributionPaladinGlobal.FullName = "RetributionPaladinGlobal"
function SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(u375, amount)
    local UnitAttribute377 = require("Objects.UnitAttribute")
    local attr376 = UnitAttribute377.GetAttr(u375)
    attr376.retPalHolyEnergy = math.min((attr376.retPalHolyEnergy + amount), 5)
end

function SF__.RetributionPaladinGlobal:Init()
    ExTriggerRegisterNewUnit(function(u378)
        if (GetUnitTypeId(u378) == FourCC("Hpal")) then
            SF__.ListAdd__(self._units, u378)
        end
    end)
    _ = self:Start()
end

function SF__.RetributionPaladinGlobal:Start()
    return SF__.CorRun__(function()
        local UnitAttribute381 = require("Objects.UnitAttribute")
        while true do
            do
                local collection16 = self._units
                for i17, u379 in SF__.ListIterate__(collection16) do
                    local attr380 = UnitAttribute381.GetAttr(u379)
                    ExSetUnitMana(u379, ((ExGetUnitMaxMana(u379) * attr380.retPalHolyEnergy) * 0.2))
                    if (attr380.retPalHolyEnergy >= 3) then
                        SF__.Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u379), FourCC("A006"), "ReplaceableTextures/CommandButtons/BTNinv_helmet_96.tga")
                    else
                        SF__.Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u379), FourCC("A006"), "ReplaceableTextures/PassiveButtons/PASBTNinv_helmet_96.tga")
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
SF__.Scene.Name = "Scene"
SF__.Scene.FullName = "Scene"
function SF__.Scene.get_Instance()
    return (function()
        if SF__.Scene._instance ~= nil then
            return SF__.Scene._instance
        end
        SF__.Scene._instance = SF__.Scene.New()
        return SF__.Scene._instance
    end)()
end

function SF__.Scene:AddGameObject(obj20)
    SF__.ListAdd__(self.gameObjs, obj20)
end

function SF__.Scene:Run()
    return SF__.CorRun__(function()
        while true do
            SF__.CorWait__(SF__.Scene.DT)
            local rootObjs = SF__.ListNew__({})
            do
                local collection18 = self.gameObjs
                for i19, obj21 in SF__.ListIterate__(collection18) do
                    if (obj21.transform.parent == nil) then
                        SF__.ListAdd__(rootObjs, obj21)
                    end
                end
            end
            do
                local collection20 = rootObjs
                for i21, obj22 in SF__.ListIterate__(collection20) do
                    obj22:Update()
                end
            end
            ::continue::
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

SF__.Scene.DT = 20
SF__.Scene._instance = nil
-- Stack
SF__.Stack = SF__.Stack or {}
SF__.Stack.Name = "Stack"
SF__.Stack.FullName = "Stack"
function SF__.Stack:Push(item)
    SF__.ListAdd__(self._items, item)
end

function SF__.Stack:Pop()
    if (SF__.ListCount__(self._items) == 0) then
        BJDebugMsg("Stack is empty.")
    end
    local item89 = SF__.ListGet__(self._items, (SF__.ListCount__(self._items) - 1))
    SF__.ListRemoveAt__(self._items, (SF__.ListCount__(self._items) - 1))
    return item89
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
SF__.Systems.InitAbilitiesSystem.Name = "InitAbilitiesSystem"
SF__.Systems.InitAbilitiesSystem.FullName = "Systems.InitAbilitiesSystem"
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
local SystemBase23 = require("System.SystemBase")
SF__.Systems.InspectorSystem = SF__.Systems.InspectorSystem or class("InspectorSystem", SystemBase23)
SF__.Systems.InspectorSystem.Name = "InspectorSystem"
SF__.Systems.InspectorSystem.FullName = "Systems.InspectorSystem"
SF__.Systems.InspectorSystem.__sf_base = SystemBase23
function SF__.Systems.InspectorSystem:Awake()
    self:CreateFrames()
    self:RefreshHierarchy()
    self:SelectFirstVisibleObject()
    self:SetPanelVisible(false)
end

function SF__.Systems.InspectorSystem:Update(dt24)
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
        local i25 = 0
        while (i25 < SF__.Systems.InspectorSystem.MaxHierarchyRows) do
            SF__.ListAdd__(self._hierarchyRows, self:CreateHierarchyRow(i25))
            ::continue::
            i25 = (i25 + 1)
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
    local y26 = ((-0.061) - (index * (SF__.Systems.InspectorSystem.RowHeight + SF__.Systems.InspectorSystem.RowGap)))
    local button = BlzCreateFrameByType("BUTTON", "FdfInspectorHierarchyRow", self._panel, "ScoreScreenTabButtonTemplate", index)
    BlzFrameSetPoint(button, FRAMEPOINT_TOPLEFT, self._panel, FRAMEPOINT_TOPLEFT, (SF__.Systems.InspectorSystem.Padding * 2), y26)
    BlzFrameSetSize(button, (SF__.Systems.InspectorSystem.LeftWidth - (SF__.Systems.InspectorSystem.Padding * 4)), SF__.Systems.InspectorSystem.RowHeight)
    local label27 = BlzCreateFrameByType("TEXT", "FdfInspectorHierarchyRowText", button, "", index)
    BlzFrameSetPoint(label27, FRAMEPOINT_TOPLEFT, button, FRAMEPOINT_TOPLEFT, 0.004, (-0.002))
    BlzFrameSetSize(label27, (SF__.Systems.InspectorSystem.LeftWidth - (SF__.Systems.InspectorSystem.Padding * 5)), (SF__.Systems.InspectorSystem.RowHeight - 0.003))
    BlzFrameSetEnable(label27, false)
    BlzFrameSetTextAlignment(label27, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_LEFT)
    BlzFrameSetText(label27, "")
    local row = SF__.Systems.InspectorSystem.HierarchyRow.New(button, label27)
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

function SF__.Systems.InspectorSystem:SelectRow(row28)
    if (row28.gameObject == nil) then
        return
    end
    self._selectedGameObject = row28.gameObject
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
        local collection22 = SF__.Scene.get_Instance().gameObjs
        for i23, obj29 in SF__.ListIterate__(collection22) do
            if (obj29.transform.parent == nil) then
                self:AddHierarchyObject(obj29, 0)
            end
        end
    end
    do
        local i30 = 0
        while (i30 < SF__.ListCount__(self._hierarchyRows)) do
            local row31 = SF__.ListGet__(self._hierarchyRows, i30)
            if (i30 < SF__.ListCount__(self._visibleObjects)) then
                local obj32 = SF__.ListGet__(self._visibleObjects, i30)
                row31.gameObject = obj32
                row31.depth = self:GetDepth(obj32)
                self:SetRowLabel(row31, obj32.name, row31.depth)
                BlzFrameSetVisible(row31.button, self._isVisible)
            else
                row31.gameObject = nil
                BlzFrameSetVisible(row31.button, false)
            end
            ::continue::
            i30 = (i30 + 1)
        end
    end
    BlzFrameSetVisible(self._emptyText, (self._isVisible and (SF__.ListCount__(self._visibleObjects) == 0)))
    self._lastObjectCount = SF__.ListCount__(SF__.Scene.get_Instance().gameObjs)
    self:RefreshHierarchySelection()
end

function SF__.Systems.InspectorSystem:AddHierarchyObject(obj33, depth)
    if (SF__.ListCount__(self._visibleObjects) >= SF__.Systems.InspectorSystem.MaxHierarchyRows) then
        return
    end
    SF__.ListAdd__(self._visibleObjects, obj33)
    do
        local collection24 = obj33.transform.children
        for i26, child34 in SF__.ListIterate__(collection24) do
            self:AddHierarchyObject(child34.gameObject, (depth + 1))
        end
    end
end

function SF__.Systems.InspectorSystem:GetDepth(obj35)
    local depth36 = 0
    local parent37 = obj35.transform.parent
    while (parent37 ~= nil) do
        depth36 = (depth36 + 1)
        parent37 = parent37.parent
        ::continue::
    end
    return depth36
end

function SF__.Systems.InspectorSystem:SetRowLabel(row38, text39, depth40)
    BlzFrameClearAllPoints(row38.label)
    BlzFrameSetPoint(row38.label, FRAMEPOINT_TOPLEFT, row38.button, FRAMEPOINT_TOPLEFT, (0.004 + (depth40 * SF__.Systems.InspectorSystem.IndentWidth)), (-0.002))
    BlzFrameSetSize(row38.label, ((SF__.Systems.InspectorSystem.LeftWidth - (SF__.Systems.InspectorSystem.Padding * 5)) - (depth40 * SF__.Systems.InspectorSystem.IndentWidth)), (SF__.Systems.InspectorSystem.RowHeight - 0.003))
    BlzFrameSetText(row38.label, text39)
end

function SF__.Systems.InspectorSystem:RefreshHierarchySelection()
    do
        local collection27 = self._hierarchyRows
        for i28, row41 in SF__.ListIterate__(collection27) do
            local isSelected = ((row41.gameObject ~= nil) and (row41.gameObject == self._selectedGameObject))
            BlzFrameSetTextColor(row41.label, SF__.Ternary__(isSelected, BlzConvertColor(255, 255, 220, 80), BlzConvertColor(255, 230, 230, 230)))
        end
    end
end

function SF__.Systems.InspectorSystem:RefreshInspectorText()
    if (self._selectedGameObject == nil) then
        BlzFrameSetText(self._inspectorText, "")
        return
    end
    local text42 = SF__.StrConcat__(self._selectedGameObject.name, "\n")
    do
        local collection29 = self._selectedGameObject:get_components()
        for i31, component in SF__.ListIterate__(collection29) do
            text42 = SF__.StrConcat__(text42, "\n[", component.__sf_type.Name, "]")
            local inspectorText = component:GetInspectorText()
            if (inspectorText ~= "") then
                text42 = SF__.StrConcat__(text42, "\n", inspectorText)
            end
        end
    end
    BlzFrameSetText(self._inspectorText, text42)
end

function SF__.Systems.InspectorSystem:SceneContains(gameObject)
    do
        local collection32 = SF__.Scene.get_Instance().gameObjs
        for i33, obj43 in SF__.ListIterate__(collection32) do
            if (obj43 == gameObject) then
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
SF__.Systems.InspectorSystem.HierarchyRow.Name = "HierarchyRow"
SF__.Systems.InspectorSystem.HierarchyRow.FullName = "Systems.InspectorSystem.HierarchyRow"
function SF__.Systems.InspectorSystem.HierarchyRow.__Init(self, button44, label45)
    self.__sf_type = SF__.Systems.InspectorSystem.HierarchyRow
    self.button = nil
    self.label = nil
    self.gameObject = nil
    self.depth = 0
    self.button = button44
    self.label = label45
end

function SF__.Systems.InspectorSystem.HierarchyRow.New(button44, label45)
    local self = setmetatable({}, { __index = SF__.Systems.InspectorSystem.HierarchyRow })
    SF__.Systems.InspectorSystem.HierarchyRow.__Init(self, button44, label45)
    return self
end
-- Systems.MeleeGameSystem
local SystemBase46 = require("System.SystemBase")
SF__.Systems.MeleeGameSystem = SF__.Systems.MeleeGameSystem or class("MeleeGameSystem", SystemBase46)
SF__.Systems.MeleeGameSystem.Name = "MeleeGameSystem"
SF__.Systems.MeleeGameSystem.FullName = "Systems.MeleeGameSystem"
SF__.Systems.MeleeGameSystem.__sf_base = SystemBase46
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
SF__.TemplarStrikes.Name = "TemplarStrikes"
SF__.TemplarStrikes.FullName = "TemplarStrikes"
function SF__.TemplarStrikes.GetAbilityData(level382)
    return 2, (0.5 + (0.25 * level382)), (0.05 * level382)
end

function SF__.TemplarStrikes.Init()
    local EventCenter383 = require("Lib.EventCenter")
    EventCenter383.RegisterPlayerUnitSpellEffect:Emit({id = SF__.TemplarStrikes.ID, handler = SF__.TemplarStrikes.Start})
    ExTriggerRegisterNewUnit(function(u384)
        if (GetUnitTypeId(u384) == FourCC("Hpal")) then
            SF__.TemplarStrikes.UpdateAbilityMeta(u384)
            SetHeroLevel(u384, 10, true)
        end
    end)
    EventCenter383.RegisterPlayerUnitDamaged:Emit(function(caster385, target386, damage387, weapType, dmgType, isAttack)
        if (GetUnitAbilityLevel(caster385, SF__.TemplarStrikes.ID) <= 0) then
            return
        end
        if (not isAttack) then
            return
        end
        if (target386 == nil) then
            return
        end
        if ExIsUnitDead(target386) then
            return
        end
        SF__.TemplarStrikes.TryResetBOJ(caster385)
    end)
end

function SF__.TemplarStrikes.TryResetBOJ(caster388)
    local level389 = GetUnitAbilityLevel(caster388, SF__.TemplarStrikes.ID)
    local ad__AttackCount, ad__DamageScaling390, ad__ResetBOJChance = SF__.TemplarStrikes.GetAbilityData(level389)
    if (math.random() >= ad__ResetBOJChance) then
        return
    end
    BlzEndUnitAbilityCooldown(caster388, SF__.BladeOfJustice.ID)
    ExAddSpecialEffectTarget("Abilities/Spells/Items/AIam/AIamTarget.mdl", caster388, "origin", 0.3)
end

function SF__.TemplarStrikes.UpdateAbilityMeta(u391)
    local p392 = GetOwningPlayer(u391)
    local datas__AttackCount, datas__DamageScaling393, datas__ResetBOJChance = {}, {}, {}
    do
        local i394 = 0
        while (i394 < SF__.TemplarStrikes.MaxLevel) do
            do
                local item__AttackCount, item__DamageScaling395, item__ResetBOJChance = SF__.TemplarStrikes.GetAbilityData((i394 + 1))
                table.insert(datas__AttackCount, item__AttackCount)
                table.insert(datas__DamageScaling393, item__DamageScaling395)
                table.insert(datas__ResetBOJChance, item__ResetBOJChance)
            end
            ::continue::
            i394 = (i394 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p392, SF__.TemplarStrikes.ID, "学习圣殿骑士之击 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p392, SF__.TemplarStrikes.ID, SF__.StrConcat__("快速攻击目标|cffff8c00", datas__AttackCount[(0 + 1)], "|r次，第一次造成普通攻击伤害，第二次造成光辉伤害，有一定几率重置公正之剑的冷却时间，普通攻击也会触发。\n\n|cff99ccff冷却时间|r - 10秒\n\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling393[(0 + 1)] * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas__ResetBOJChance[(0 + 1)] * 100)), "%|r的几率重置公正之剑。\n|cffffcc002级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling393[(1 + 1)] * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas__ResetBOJChance[(1 + 1)] * 100)), "%|r的几率重置公正之剑。\n|cffffcc003级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling393[(2 + 1)] * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas__ResetBOJChance[(2 + 1)] * 100)), "%|r的几率重置公正之剑。"), 0)
    do
        local i396 = 0
        while (i396 < SF__.TemplarStrikes.MaxLevel) do
            local data__AttackCount, data__DamageScaling397, data__ResetBOJChance = datas__AttackCount[(i396 + 1)], datas__DamageScaling393[(i396 + 1)], datas__ResetBOJChance[(i396 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p392, SF__.TemplarStrikes.ID, SF__.StrConcat__("圣殿骑士之击 - [|cffffcc00", (i396 + 1), "级|r]"), i396)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p392, SF__.TemplarStrikes.ID, SF__.StrConcat__("快速攻击目标|cffff8c00", data__AttackCount, "|r次，第一次造成普通攻击伤害，第二次造成普通攻击|cffff8c00", string.format("%.0f", (data__DamageScaling397 * 100)), "%|r的光辉伤害，|cffff8c00", string.format("%.0f", (data__ResetBOJChance * 100)), "%|r几率重置公正之剑的冷却时间，普通攻击也会触发。\n\n|cff99ccff冷却时间|r - 10秒"), i396)
            ::continue::
            i396 = (i396 + 1)
        end
    end
end

function SF__.TemplarStrikes.Start(data398)
    return SF__.CorRun__(function()
        local level399 = GetUnitAbilityLevel(data398.caster, SF__.TemplarStrikes.ID)
        local UnitAttribute401 = require("Objects.UnitAttribute")
        local EventCenter402 = require("Lib.EventCenter")
        local attr400 = UnitAttribute401.GetAttr(data398.caster)
        local normalDamage = attr400:SimMeleeAttack()
        EventCenter402.Damage:Emit({whichUnit = data398.caster, target = data398.target, amount = normalDamage, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
        SF__.TemplarStrikes.TryResetBOJ(data398.caster)
        SetUnitTimeScale(data398.caster, 3)
        ResetUnitAnimation(data398.caster)
        SetUnitAnimation(data398.caster, "attack - 2")
        SF__.CorWait__(math.round(((1.166 * 0.33) * 1000)))
        local tarAttr403 = UnitAttribute401.GetAttr(data398.target)
        local ad__AttackCount404, ad__DamageScaling405, ad__ResetBOJChance406 = SF__.TemplarStrikes.GetAbilityData(level399)
        local radiantDamage = ((attr400:SimMeleeAttack() * ad__DamageScaling405) * (1 - tarAttr403.radiantResistance))
        EventCenter402.Damage:Emit({whichUnit = data398.caster, target = data398.target, amount = radiantDamage, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
        SF__.TemplarStrikes.TryResetBOJ(data398.caster)
        SetUnitTimeScale(data398.caster, 1)
        ResetUnitAnimation(data398.caster)
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
SF__.TemplarStrikes.IAbilityData.Name = "IAbilityData"
SF__.TemplarStrikes.IAbilityData.FullName = "TemplarStrikes.IAbilityData"
function SF__.TemplarStrikes.IAbilityData.Equals(self__AttackCount, self__DamageScaling407, self__ResetBOJChance, other__AttackCount, other__DamageScaling408, other__ResetBOJChance)
    return ((math.abs((self__DamageScaling407 - other__DamageScaling408)) < 0.0001) and (math.abs((self__ResetBOJChance - other__ResetBOJChance)) < 0.0001))
end
-- TemplarVerdict
SF__.TemplarVerdict = SF__.TemplarVerdict or {}
SF__.TemplarVerdict.Name = "TemplarVerdict"
SF__.TemplarVerdict.FullName = "TemplarVerdict"
function SF__.TemplarVerdict.GetAbilityData(level409)
    return 2.25, 0.3, 0.15
end

function SF__.TemplarVerdict.Init()
    local EventCenter410 = require("Lib.EventCenter")
    EventCenter410.RegisterPlayerUnitSpellChannel:Emit({id = SF__.TemplarVerdict.ID, handler = SF__.TemplarVerdict.Check})
    EventCenter410.RegisterPlayerUnitSpellEffect:Emit({id = SF__.TemplarVerdict.ID, handler = SF__.TemplarVerdict.Start})
    ExTriggerRegisterNewUnit(function(u411)
        if (GetUnitTypeId(u411) == FourCC("Hpal")) then
            SF__.TemplarVerdict.UpdateAbilityMeta(u411)
        end
    end)
end

function SF__.TemplarVerdict.Check(data412)
    local UnitAttribute414 = require("Objects.UnitAttribute")
    local attr413 = UnitAttribute414.GetAttr(data412.caster)
    if (attr413.retPalHolyEnergy < 3) then
        IssueImmediateOrderById(data412.caster, SF__.ConstOrderId.Stop)
        ExTextState(data412.caster, "圣能不足")
    end
end

function SF__.TemplarVerdict.UpdateAbilityMeta(u415)
    local p416 = GetOwningPlayer(u415)
    local datas__DamageScaling417, datas__JudgementDamageScaling, datas__ChanceToResetJudgement = {}, {}, {}
    do
        local i418 = 0
        while (i418 < 1) do
            do
                local item__DamageScaling419, item__JudgementDamageScaling, item__ChanceToResetJudgement = SF__.TemplarVerdict.GetAbilityData((i418 + 1))
                table.insert(datas__DamageScaling417, item__DamageScaling419)
                table.insert(datas__JudgementDamageScaling, item__JudgementDamageScaling)
                table.insert(datas__ChanceToResetJudgement, item__ChanceToResetJudgement)
            end
            ::continue::
            i418 = (i418 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p416, SF__.TemplarVerdict.ID, "学习圣殿骑士的裁决 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p416, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决造成一次攻击伤害，如果目标被审判，造成30%的额外伤害，15%几率重置审判。消耗|cffff8c003|r点圣能。\n\n|cff99ccff冷却时间|r - 5秒\n\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas__JudgementDamageScaling[(0 + 1)] * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas__ChanceToResetJudgement[(0 + 1)] * 100)), "%的战争艺术触发几率。"), 0)
    do
        local i420 = 0
        while (i420 < 1) do
            local data__DamageScaling421, data__JudgementDamageScaling, data__ChanceToResetJudgement = datas__DamageScaling417[(i420 + 1)], datas__JudgementDamageScaling[(i420 + 1)], datas__ChanceToResetJudgement[(i420 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p416, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决 - [|cffffcc00", (i420 + 1), "级|r]"), i420)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p416, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决造成一次攻击伤害，造成|cffff8c00", string.format("%.0f", (data__DamageScaling421 * 100)), "%|r的攻击伤害。消耗|cffff8c003|r点圣能。\n\n|cff99ccff冷却时间|r - 5秒"), i420)
            ::continue::
            i420 = (i420 + 1)
        end
    end
end

function SF__.TemplarVerdict.Start(data422)
    local level423 = GetUnitAbilityLevel(data422.caster, SF__.TemplarVerdict.ID)
    local UnitAttribute426 = require("Objects.UnitAttribute")
    local EventCenter428 = require("Lib.EventCenter")
    local ad__DamageScaling424, ad__JudgementDamageScaling, ad__ChanceToResetJudgement = SF__.TemplarVerdict.GetAbilityData(level423)
    local attr425 = UnitAttribute426.GetAttr(data422.caster)
    local damage427 = (attr425:SimAttack(UnitAttribute426.HeroAttributeType.Strength) * ad__DamageScaling424)
    EventCenter428.Damage:Emit({whichUnit = data422.caster, target = data422.target, amount = damage427, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_SLICE, outResult = {}})
    attr425.retPalHolyEnergy = (attr425.retPalHolyEnergy - 3)
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
SF__.TemplarVerdict.IAbilityData.Name = "IAbilityData"
SF__.TemplarVerdict.IAbilityData.FullName = "TemplarVerdict.IAbilityData"
function SF__.TemplarVerdict.IAbilityData.Equals(self__DamageScaling429, self__JudgementDamageScaling, self__ChanceToResetJudgement, other__DamageScaling430, other__JudgementDamageScaling, other__ChanceToResetJudgement)
    return ((math.abs((self__JudgementDamageScaling - other__JudgementDamageScaling)) < 0.0001) and (math.abs((self__ChanceToResetJudgement - other__ChanceToResetJudgement)) < 0.0001))
end
-- Transform
SF__.Transform = SF__.Transform or {}
SF__.Transform.Name = "Transform"
SF__.Transform.FullName = "Transform"
setmetatable(SF__.Transform, { __index = SF__.Component })
SF__.Transform.__sf_base = SF__.Component
function SF__.Transform:get_position()
    if (self.parent == nil) then
        return self.localPosition__x, self.localPosition__y, self.localPosition__z
    end
    local globalPos = self.localPosition
    local globalRot__x3, globalRot__y4, globalRot__z5, globalRot__w6 = self.localRotation__x, self.localRotation__y, self.localRotation__z, self.localRotation__w
    local globalScale__x7, globalScale__y8, globalScale__z9 = self.localScale__x, self.localScale__y, self.localScale__z
    local myParent = self.parent
    while (myParent ~= nil) do
        globalPos = SF__.Vector3.op_Addition(myParent.localPosition__x, myParent.localPosition__y, myParent.localPosition__z, SF__.Quaternion.op_Multiply__quaternionvector3(myParent.localRotation__x, myParent.localRotation__y, myParent.localRotation__z, myParent.localRotation__w, SF__.Vector3.Scale(myParent.localScale__x, myParent.localScale__y, myParent.localScale__z, globalPos.x, globalPos.y, globalPos.z)))
        globalRot__x3, globalRot__y4, globalRot__z5, globalRot__w6 = SF__.Quaternion.op_Multiply__quaternionquaternion(myParent.localRotation__x, myParent.localRotation__y, myParent.localRotation__z, myParent.localRotation__w, globalRot__x3, globalRot__y4, globalRot__z5, globalRot__w6)
        globalScale__x7, globalScale__y8, globalScale__z9 = SF__.Vector3.Scale(myParent.localScale__x, myParent.localScale__y, myParent.localScale__z, globalScale__x7, globalScale__y8, globalScale__z9)
        myParent = myParent.parent
        ::continue::
    end
    return globalPos.x, globalPos.y, globalPos.z
end

function SF__.Transform.__Init(self)
    SF__.Component.__Init(self)
    self.__sf_type = SF__.Transform
    self.localPosition__x = 0
    self.localPosition__y = 0
    self.localPosition__z = 0
    self.localRotation__x = 0
    self.localRotation__y = 0
    self.localRotation__z = 0
    self.localRotation__w = 0
    self.localScale__x = 0
    self.localScale__y = 0
    self.localScale__z = 0
    self.children = SF__.ListNew__({})
    self.parent = nil
    self.localPosition__x, self.localPosition__y, self.localPosition__z = 0, 0, 0
    self.localRotation__x, self.localRotation__y, self.localRotation__z, self.localRotation__w = SF__.Quaternion.Euler(0, 0, 0)
    self.localScale__x, self.localScale__y, self.localScale__z = 1, 1, 1
end

function SF__.Transform.New()
    local self = setmetatable({}, { __index = SF__.Transform })
    SF__.Transform.__Init(self)
    return self
end

function SF__.Transform:GetInspectorText()
    return SF__.StrConcat__("Position: ", SF__.Vector3.ToString(self.localPosition__x, self.localPosition__y, self.localPosition__z), "\n", "Rotation: ", SF__.Vector3.ToString(SF__.Quaternion.get_eulerAngles(self.localRotation__x, self.localRotation__y, self.localRotation__z, self.localRotation__w)), "\n", "Scale: ", SF__.Vector3.ToString(self.localScale__x, self.localScale__y, self.localScale__z), "\n", "Children: ", SF__.ListCount__(self.children))
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
SF__.Utils.Name = "Utils"
SF__.Utils.FullName = "Utils"
function SF__.Utils.ExSetAbilityResearchTooltip(p, abilCode, researchTooltip, level)
    if (GetLocalPlayer() ~= p) then
        return
    end
    BlzSetAbilityResearchTooltip(abilCode, researchTooltip, level)
end

function SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p90, abilCode91, researchExtendedTooltip, level92)
    if (GetLocalPlayer() ~= p90) then
        return
    end
    BlzSetAbilityResearchExtendedTooltip(abilCode91, researchExtendedTooltip, level92)
end

function SF__.Utils.ExBlzSetAbilityTooltip(p93, abilCode94, tooltip, level95)
    if (GetLocalPlayer() ~= p93) then
        return
    end
    BlzSetAbilityTooltip(abilCode94, tooltip, level95)
end

function SF__.Utils.ExBlzSetAbilityExtendedTooltip(p96, abilCode97, extendedTooltip, level98)
    if (GetLocalPlayer() ~= p96) then
        return
    end
    BlzSetAbilityExtendedTooltip(abilCode97, extendedTooltip, level98)
end

function SF__.Utils.ExBlzSetAbilityIcon(p99, abilCode100, iconPath)
    if (GetLocalPlayer() ~= p99) then
        return
    end
    BlzSetAbilityIcon(abilCode100, iconPath)
end

function SF__.Utils.CsGroupGetUnitsInRange(x101, y102, radius, filter)
    local result = SF__.ListNew__({})
    ExGroupEnumUnitsInRange(x101, y102, radius, function(u)
        if filter(u) then
            SF__.ListAdd__(result, u)
        end
    end)
    return result
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
SF__.Vector2.Name = "Vector2"
SF__.Vector2.FullName = "Vector2"
function SF__.Vector2.get_Zero()
    return 0, 0
end

function SF__.Vector2.InsideUnitCircle()
    local angle = ((math.random() * 2) * math.pi)
    return math.cos(angle), math.sin(angle)
end

function SF__.Vector2.Dot(a__x103, a__y104, b__x105, b__y106)
    return ((a__x103 * b__x105) + (a__y104 * b__y106))
end

function SF__.Vector2.Cross(a__x107, a__y108, b__x109, b__y110)
    return ((a__y108 * b__x109) - (a__x107 * b__y110))
end

function SF__.Vector2.op_UnaryNegation(a__x111, a__y112)
    return (-a__x111), (-a__y112)
end

function SF__.Vector2.op_Addition(a__x113, a__y114, b__x115, b__y116)
    return (a__x113 + b__x115), (a__y114 + b__y116)
end

function SF__.Vector2.op_Subtraction(a__x117, a__y118, b__x119, b__y120)
    return (a__x117 - b__x119), (a__y118 - b__y120)
end

function SF__.Vector2.op_Multiply__vector2f(v__x121, v__y122, f)
    return (v__x121 * f), (v__y122 * f)
end

function SF__.Vector2.op_Multiply__fvector2(f123, v__x124, v__y125)
    return (v__x124 * f123), (v__y125 * f123)
end

function SF__.Vector2.op_Division(v__x126, v__y127, f128)
    return (v__x126 / f128), (v__y127 / f128)
end

function SF__.Vector2.op_Equality(a__x129, a__y130, b__x131, b__y132)
    return ((math.abs((a__x129 - b__x131)) < 0.0001) and (math.abs((a__y130 - b__y132)) < 0.0001))
end

function SF__.Vector2.op_Inequality(a__x133, a__y134, b__x135, b__y136)
    return (not SF__.Vector2.op_Equality(a__x133, a__y134, b__x135, b__y136))
end

function SF__.Vector2.UnitDistance(a, b)
    local v1__x, v1__y = SF__.Vector2.FromUnit(a)
    local v2__x, v2__y = SF__.Vector2.FromUnit(b)
    return SF__.Vector2.get_Magnitude(SF__.Vector2.op_Subtraction(v1__x, v1__y, v2__x, v2__y))
end

function SF__.Vector2.SqrUnitDistance(a137, b138)
    local v1__x139, v1__y140 = SF__.Vector2.FromUnit(a137)
    local v2__x141, v2__y142 = SF__.Vector2.FromUnit(b138)
    return SF__.Vector2.get_SqrMagnitude(SF__.Vector2.op_Subtraction(v1__x139, v1__y140, v2__x141, v2__y142))
end

function SF__.Vector2.FromUnit(u143)
    return GetUnitX(u143), GetUnitY(u143)
end

function SF__.Vector2.get_Magnitude(self__x144, self__y145)
    return math.sqrt(SF__.Vector2.get_SqrMagnitude(self__x144, self__y145))
end

function SF__.Vector2.get_SqrMagnitude(self__x146, self__y147)
    return ((self__x146 * self__x146) + (self__y147 * self__y147))
end

function SF__.Vector2.get_Normalized(self__x148, self__y149)
    local mag = SF__.Vector2.get_Magnitude(self__x148, self__y149)
    if (mag < 0.0001) then
        return SF__.Vector2.get_Zero()
    end
    return SF__.Vector2.op_Division(self__x148, self__y149, mag)
end

function SF__.Vector2.ClampMagnitude(self__x152, self__y153, mag154)
    return (function()
        local v__x155, v__y156 = SF__.Vector2.get_Normalized(self__x152, self__y153)
        return SF__.Vector2.op_Multiply__vector2f(v__x155, v__y156, mag154)
    end)()
end

function SF__.Vector2.Equals(self__x157, self__y158, other__x159, other__y160)
    return SF__.Vector2.op_Equality(self__x157, self__y158, other__x159, other__y160)
end

function SF__.Vector2.ToString(self__x161, self__y162)
    return SF__.StrConcat__("(", self__x161, ", ", self__y162, ")")
end

function SF__.Vector2.Rotate(self__x163, self__y164, angle165)
    local cos = math.cos(angle165)
    local sin = math.sin(angle165)
    return ((self__x163 * cos) - (self__y164 * sin)), ((self__x163 * sin) + (self__y164 * cos))
end

function SF__.Vector2.UnitMoveTo(self__x166, self__y167, u168)
    SetUnitX(u168, self__x166)
    SetUnitY(u168, self__y167)
end

function SF__.Vector2.GetTerrainZ(self__x169, self__y170)
    MoveLocation(SF__.Vector2._loc, self__x169, self__y170)
    return GetLocationZ(SF__.Vector2._loc)
end

SF__.Vector2._loc = Location(0, 0)
-- Vector3
SF__.Vector3 = SF__.Vector3 or {}
SF__.Vector3.Name = "Vector3"
SF__.Vector3.FullName = "Vector3"
function SF__.Vector3.get_zero()
    return 0, 0, 0
end

function SF__.Vector3.get_up()
    return 0, 0, 1
end

function SF__.Vector3.get_down()
    return 0, 0, (-1)
end

function SF__.Vector3.get_right()
    return 1, 0, 0
end

function SF__.Vector3.get_left()
    return (-1), 0, 0
end

function SF__.Vector3.get_forward()
    return 0, 1, 0
end

function SF__.Vector3.get_back()
    return 0, (-1), 0
end

function SF__.Vector3.get_one()
    return 1, 1, 1
end

function SF__.Vector3.op_Addition(a__x171, a__y172, a__z173, b__x174, b__y175, b__z176)
    return (a__x171 + b__x174), (a__y172 + b__y175), (a__z173 + b__z176)
end

function SF__.Vector3.op_UnaryNegation(a__x177, a__y178, a__z179)
    return (-a__x177), (-a__y178), (-a__z179)
end

function SF__.Vector3.op_Subtraction(a__x180, a__y181, a__z182, b__x183, b__y184, b__z185)
    return (a__x180 - b__x183), (a__y181 - b__y184), (a__z182 - b__z185)
end

function SF__.Vector3.op_Multiply__vector3f(v__x186, v__y187, v__z188, f189)
    return (v__x186 * f189), (v__y187 * f189), (v__z188 * f189)
end

function SF__.Vector3.op_Multiply__fvector3(f190, v__x191, v__y192, v__z193)
    return (v__x191 * f190), (v__y192 * f190), (v__z193 * f190)
end

function SF__.Vector3.op_Division(v__x194, v__y195, v__z196, f197)
    return (v__x194 / f197), (v__y195 / f197), (v__z196 / f197)
end

function SF__.Vector3.op_Equality(a__x198, a__y199, a__z200, b__x201, b__y202, b__z203)
    return (((math.abs((a__x198 - b__x201)) < 0.0001) and (math.abs((a__y199 - b__y202)) < 0.0001)) and (math.abs((a__z200 - b__z203)) < 0.0001))
end

function SF__.Vector3.op_Inequality(a__x204, a__y205, a__z206, b__x207, b__y208, b__z209)
    return (not SF__.Vector3.op_Equality(a__x204, a__y205, a__z206, b__x207, b__y208, b__z209))
end

-- <summary>
-- Warcraft III world space here is right-handed: +x points right, +y points away, +z points up.
-- That means Cross((1,0,0), (0,1,0)) == (0,0,1).
-- </summary>
--
function SF__.Vector3.Cross(a__x210, a__y211, a__z212, b__x213, b__y214, b__z215)
    return ((a__y211 * b__z215) - (a__z212 * b__y214)), ((a__z212 * b__x213) - (a__x210 * b__z215)), ((a__x210 * b__y214) - (a__y211 * b__x213))
end

function SF__.Vector3.Distance(a__x216, a__y217, a__z218, b__x219, b__y220, b__z221)
    return SF__.Vector3.get_magnitude(SF__.Vector3.op_Subtraction(a__x216, a__y217, a__z218, b__x219, b__y220, b__z221))
end

function SF__.Vector3.Dot(a__x222, a__y223, a__z224, b__x225, b__y226, b__z227)
    return (((a__x222 * b__x225) + (a__y223 * b__y226)) + (a__z224 * b__z227))
end

function SF__.Vector3.MoveTowards(current__x, current__y, current__z, target__x, target__y, target__z, maxDistanceDelta)
    local toVector__x, toVector__y, toVector__z = SF__.Vector3.op_Subtraction(target__x, target__y, target__z, current__x, current__y, current__z)
    local dist = SF__.Vector3.get_magnitude(toVector__x, toVector__y, toVector__z)
    if ((dist <= maxDistanceDelta) or (dist == 0)) then
        return target__x, target__y, target__z
    end
    return SF__.Vector3.op_Addition(current__x, current__y, current__z, SF__.Vector3.op_Division(toVector__x, toVector__y, toVector__z, (dist / maxDistanceDelta)))
end

function SF__.Vector3.Project(v__x228, v__y229, v__z230, onNormal__x, onNormal__y, onNormal__z)
    local sqrMag = SF__.Vector3.Dot(onNormal__x, onNormal__y, onNormal__z, onNormal__x, onNormal__y, onNormal__z)
    if (sqrMag < 0.0001) then
        return SF__.Vector3.get_zero()
    end
    local dot = SF__.Vector3.Dot(v__x228, v__y229, v__z230, onNormal__x, onNormal__y, onNormal__z)
    return SF__.Vector3.op_Multiply__vector3f(onNormal__x, onNormal__y, onNormal__z, (dot / sqrMag))
end

function SF__.Vector3.ProjectOnPlane(v__x231, v__y232, v__z233, planeNormal__x, planeNormal__y, planeNormal__z)
    return SF__.Vector3.op_Subtraction(v__x231, v__y232, v__z233, SF__.Vector3.Project(v__x231, v__y232, v__z233, planeNormal__x, planeNormal__y, planeNormal__z))
end

function SF__.Vector3.Reflect(inDirection__x, inDirection__y, inDirection__z, inNormal__x, inNormal__y, inNormal__z)
    return SF__.Vector3.op_Subtraction(inDirection__x, inDirection__y, inDirection__z, SF__.Vector3.op_Multiply__fvector3((2 * SF__.Vector3.Dot(inDirection__x, inDirection__y, inDirection__z, inNormal__x, inNormal__y, inNormal__z)), inNormal__x, inNormal__y, inNormal__z))
end

function SF__.Vector3.RotateTowards(current__x234, current__y235, current__z236, target__x237, target__y238, target__z239, maxRadiansDelta, maxMagnitudeDelta)
    local currentMag = SF__.Vector3.get_magnitude(current__x234, current__y235, current__z236)
    local targetMag = SF__.Vector3.get_magnitude(target__x237, target__y238, target__z239)
    if ((currentMag == 0) or (targetMag == 0)) then
        return SF__.Vector3.MoveTowards(current__x234, current__y235, current__z236, target__x237, target__y238, target__z239, maxMagnitudeDelta)
    end
    local currentNorm__x, currentNorm__y, currentNorm__z = SF__.Vector3.op_Division(current__x234, current__y235, current__z236, currentMag)
    local targetNorm__x, targetNorm__y, targetNorm__z = SF__.Vector3.op_Division(target__x237, target__y238, target__z239, targetMag)
    local dot240 = math.clamp(SF__.Vector3.Dot(currentNorm__x, currentNorm__y, currentNorm__z, targetNorm__x, targetNorm__y, targetNorm__z), (-1), 1)
    local angle241 = math.acos(dot240)
    if (angle241 == 0) then
        return SF__.Vector3.MoveTowards(current__x234, current__y235, current__z236, target__x237, target__y238, target__z239, maxMagnitudeDelta)
    end
    local t = math.min(1, (maxRadiansDelta / angle241))
    local newDir__x, newDir__y, newDir__z = SF__.Vector3.Slerp(currentNorm__x, currentNorm__y, currentNorm__z, targetNorm__x, targetNorm__y, targetNorm__z, t)
    local newMag = math.moveTowards(currentMag, targetMag, maxMagnitudeDelta)
    return SF__.Vector3.op_Multiply__vector3f(newDir__x, newDir__y, newDir__z, newMag)
end

function SF__.Vector3.Scale(a__x242, a__y243, a__z244, b__x245, b__y246, b__z247)
    return (a__x242 * b__x245), (a__y243 * b__y246), (a__z244 * b__z247)
end

function SF__.Vector3.Slerp(a__x248, a__y249, a__z250, b__x251, b__y252, b__z253, t254)
    local magA = SF__.Vector3.get_magnitude(a__x248, a__y249, a__z250)
    local magB = SF__.Vector3.get_magnitude(b__x251, b__y252, b__z253)
    if ((magA == 0) or (magB == 0)) then
        return SF__.Vector3.MoveTowards(a__x248, a__y249, a__z250, b__x251, b__y252, b__z253, math.huge)
    end
    local normA__x, normA__y, normA__z = SF__.Vector3.op_Division(a__x248, a__y249, a__z250, magA)
    local normB__x, normB__y, normB__z = SF__.Vector3.op_Division(b__x251, b__y252, b__z253, magB)
    local dot255 = math.clamp(SF__.Vector3.Dot(normA__x, normA__y, normA__z, normB__x, normB__y, normB__z), (-1), 1)
    local angle256 = math.acos(dot255)
    local sinAngle = math.sin(angle256)
    if (sinAngle < 0.0001) then
        return SF__.Vector3.MoveTowards(a__x248, a__y249, a__z250, b__x251, b__y252, b__z253, math.huge)
    end
    local tAngle = (angle256 * t254)
    local sinTA = math.sin(tAngle)
    local sinTOneMinusA = math.sin((angle256 - tAngle))
    local newDir__x263, newDir__y264, newDir__z265 = (function()
        local v__x260, v__y261, v__z262 = (function()
            local a__x257, a__y258, a__z259 = SF__.Vector3.op_Multiply__vector3f(normA__x, normA__y, normA__z, sinTOneMinusA)
            return SF__.Vector3.op_Addition(a__x257, a__y258, a__z259, SF__.Vector3.op_Multiply__vector3f(normB__x, normB__y, normB__z, sinTA))
        end)()
        return SF__.Vector3.op_Division(v__x260, v__y261, v__z262, sinAngle)
    end)()
    local newMag266 = math.lerp(magA, magB, t254)
    return SF__.Vector3.op_Multiply__vector3f(newDir__x263, newDir__y264, newDir__z265, newMag266)
end

function SF__.Vector3._getTerrainZ(x267, y268)
    MoveLocation(SF__.Vector3._loc, x267, y268)
    return GetLocationZ(SF__.Vector3._loc)
end

function SF__.Vector3.FromUnit(u269)
    local x270 = GetUnitX(u269)
    local y271 = GetUnitY(u269)
    return x270, y271, (SF__.Vector3._getTerrainZ(x270, y271) + GetUnitFlyHeight(u269))
end

function SF__.Vector3.get_sqrMagnitude(self__x272, self__y273, self__z274)
    return (((self__x272 * self__x272) + (self__y273 * self__y273)) + (self__z274 * self__z274))
end

function SF__.Vector3.get_magnitude(self__x275, self__y276, self__z277)
    return math.sqrt(SF__.Vector3.get_sqrMagnitude(self__x275, self__y276, self__z277))
end

function SF__.Vector3.get_normalized(self__x278, self__y279, self__z280)
    local mag281 = SF__.Vector3.get_magnitude(self__x278, self__y279, self__z280)
    if (mag281 < 0.0001) then
        return SF__.Vector3.get_zero()
    end
    return SF__.Vector3.op_Division(self__x278, self__y279, self__z280, mag281)
end

function SF__.Vector3.ClampMagnitude(self__x285, self__y286, self__z287, mag288)
    return (function()
        local v__x289, v__y290, v__z291 = SF__.Vector3.get_normalized(self__x285, self__y286, self__z287)
        return SF__.Vector3.op_Multiply__vector3f(v__x289, v__y290, v__z291, mag288)
    end)()
end

function SF__.Vector3.Equals(self__x292, self__y293, self__z294, other__x295, other__y296, other__z297)
    return SF__.Vector3.op_Equality(self__x292, self__y293, self__z294, other__x295, other__y296, other__z297)
end

function SF__.Vector3.ToString(self__x298, self__y299, self__z300)
    return SF__.StrConcat__("(", self__x298, ", ", self__y299, ", ", self__z300, ")")
end

function SF__.Vector3.UnitMoveTo(self__x301, self__y302, self__z303, u304, mode)
    if mode == nil then mode = SF__.UnitVec3Mode.Auto end
    local tz = SF__.Vector3._getTerrainZ(self__x301, self__y302)
    local LuaUtils = require("Lib.Utils")
    local defaultFlyHeight = GetUnitDefaultFlyHeight(u304)
    local minZ = (tz + defaultFlyHeight)
    SetUnitPosition(u304, self__x301, self__y302)
    repeat
        local switchValue = mode
        if (switchValue == SF__.UnitVec3Mode.ForceFlying) then
            LuaUtils.SetUnitFlyable(u304)
            SetUnitFlyHeight(u304, (math.max(minZ, self__z303) - minZ), 0)
            break
        elseif (switchValue == SF__.UnitVec3Mode.ForceGround) then
            SetUnitFlyHeight(u304, defaultFlyHeight, 0)
            break
        elseif (switchValue == SF__.UnitVec3Mode.Auto) then
            if IsUnitType(u304, UNIT_TYPE_FLYING) then
                SetUnitFlyHeight(u304, (math.max(minZ, self__z303) - minZ), 0)
            else
                SetUnitFlyHeight(u304, defaultFlyHeight, 0)
            end
            break
        end
    until true
end

function SF__.Vector3.GetTerrainZ(self__x305, self__y306, self__z307)
    return SF__.Vector3._getTerrainZ(self__x305, self__y306)
end

SF__.Vector3._loc = Location(0, 0)
-- WordOfGlory
SF__.WordOfGlory = SF__.WordOfGlory or {}
SF__.WordOfGlory.Name = "WordOfGlory"
SF__.WordOfGlory.FullName = "WordOfGlory"
function SF__.WordOfGlory.Init()
    local EventCenter431 = require("Lib.EventCenter")
    EventCenter431.RegisterPlayerUnitSpellChannel:Emit({id = SF__.WordOfGlory.ID, handler = SF__.WordOfGlory.Check})
    EventCenter431.RegisterPlayerUnitSpellEffect:Emit({id = SF__.WordOfGlory.ID, handler = SF__.WordOfGlory.Start})
    ExTriggerRegisterNewUnit(function(u432)
        if (GetUnitTypeId(u432) == FourCC("Hpal")) then
            SF__.WordOfGlory.UpdateAbilityMeta(u432)
        end
    end)
end

function SF__.WordOfGlory.Check(data433)
    local UnitAttribute435 = require("Objects.UnitAttribute")
    local attr434 = UnitAttribute435.GetAttr(data433.caster)
    if (attr434.retPalHolyEnergy < 3) then
        IssueImmediateOrderById(data433.caster, SF__.ConstOrderId.Stop)
        ExTextState(data433.caster, "圣能不足")
    end
end

function SF__.WordOfGlory.UpdateAbilityMeta(u436)
    local p437 = GetOwningPlayer(u436)
    SF__.Utils.ExSetAbilityResearchTooltip(p437, SF__.WordOfGlory.ID, "学习圣殿骑士的裁决 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p437, SF__.WordOfGlory.ID, "圣殿骑士的裁决造成一次攻击伤害，如果目标被审判，造成30%的额外伤害，15%几率重置审判。消耗|cffff8c003|r点圣能。\n\n|cff99ccff冷却时间|r - 5秒\n\n|cffffcc001级|r - |cffff8c00100%|r的攻击伤害，100%的战争艺术触发几率。", 0)
    do
        local i438 = 0
        while (i438 < 1) do
            SF__.Utils.ExBlzSetAbilityTooltip(p437, SF__.WordOfGlory.ID, SF__.StrConcat__("圣殿骑士的裁决 - [|cffffcc00", (i438 + 1), "级|r]"), i438)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p437, SF__.WordOfGlory.ID, "圣殿骑士的裁决造成一次攻击伤害，造成|cffff8c00100%|r的攻击伤害。消耗|cffff8c003|r点圣能。\n\n|cff99ccff冷却时间|r - 5秒", i438)
            ::continue::
            i438 = (i438 + 1)
        end
    end
end

function SF__.WordOfGlory.Start(data439)
    local UnitAttribute441 = require("Objects.UnitAttribute")
    local EventCenter442 = require("Lib.EventCenter")
    local attr440 = UnitAttribute441.GetAttr(data439.caster)
    EventCenter442.Heal:Emit({caster = data439.caster, target = data439.target, amount = 300})
    attr440.retPalHolyEnergy = (attr440.retPalHolyEnergy - 3)
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
