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
function SF__.BladeOfJustice.GetAbilityData(level316)
    return (75 * level316), 5, (10 * level316)
end

function SF__.BladeOfJustice.Init()
    local EventCenter = require("Lib.EventCenter")
    EventCenter.RegisterPlayerUnitSpellEffect:Emit({id = SF__.BladeOfJustice.ID, handler = SF__.BladeOfJustice.Start})
    ExTriggerRegisterNewUnit(function(u317)
        if (GetUnitTypeId(u317) == FourCC("Hpal")) then
            SF__.BladeOfJustice.UpdateAbilityMeta(u317)
        end
    end)
end

function SF__.BladeOfJustice.UpdateAbilityMeta(u318)
    local p319 = GetOwningPlayer(u318)
    local datas__Damage, datas__Duration, datas__DamagePerSecond = {}, {}, {}
    do
        local i320 = 0
        while (i320 < 3) do
            do
                local item__Damage, item__Duration, item__DamagePerSecond = SF__.BladeOfJustice.GetAbilityData((i320 + 1))
                table.insert(datas__Damage, item__Damage)
                table.insert(datas__Duration, item__Duration)
                table.insert(datas__DamagePerSecond, item__DamagePerSecond)
            end
            ::continue::
            i320 = (i320 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p319, SF__.BladeOfJustice.ID, "学习公正之剑 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p319, SF__.BladeOfJustice.ID, SF__.StrConcat__("用圣光的利刃刺穿目标，造成法术伤害，在一定时间内对附近敌人每秒造成光辉伤害。产生|cffff8c001|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 10秒\r\n\r\n|cffffcc001级|r - 造成|cffff8c00", datas__Damage[(0 + 1)], "|r的直接法术伤害，|cffff8c00", datas__Duration[(0 + 1)], "|r秒内对附近敌人每秒造成|cffff8c00", datas__DamagePerSecond[(0 + 1)], "|r的光辉伤害。产生|cffff8c001|r点圣能。\r\n|cffffcc002级|r - 造成|cffff8c00", datas__Damage[(1 + 1)], "|r的直接法术伤害，|cffff8c00", datas__Duration[(1 + 1)], "|r秒内对附近敌人每秒造成|cffff8c00", datas__DamagePerSecond[(1 + 1)], "|r的光辉伤害。产生|cffff8c001|r点圣能。\r\n|cffffcc003级|r - 造成|cffff8c00", datas__Damage[(2 + 1)], "|r的直接法术伤害，|cffff8c00", datas__Duration[(2 + 1)], "|r秒内对附近敌人每秒造成|cffff8c00", datas__DamagePerSecond[(2 + 1)], "|r的光辉伤害。产生|cffff8c001|r点圣能。"), 0)
    do
        local i321 = 0
        while (i321 < 3) do
            local data__Damage, data__Duration, data__DamagePerSecond = datas__Damage[(i321 + 1)], datas__Duration[(i321 + 1)], datas__DamagePerSecond[(i321 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p319, SF__.BladeOfJustice.ID, SF__.StrConcat__("公正之剑 - [|cffffcc00", (i321 + 1), "级|r]"), i321)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p319, SF__.BladeOfJustice.ID, SF__.StrConcat__("用圣光的利刃刺穿目标，造成|cffff8c00", data__Damage, "|r的直接法术伤害，在|cffff8c00", data__Duration, "|r秒内对附近敌人每秒造成|cffff8c00", data__DamagePerSecond, "|r的光辉伤害。产生|cffff8c001|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 10秒"), i321)
            ::continue::
            i321 = (i321 + 1)
        end
    end
end

function SF__.BladeOfJustice.Start(data)
    local level322 = GetUnitAbilityLevel(data.caster, SF__.BladeOfJustice.ID)
    local EventCenter323 = require("Lib.EventCenter")
    local ad__Damage, ad__Duration, ad__DamagePerSecond = SF__.BladeOfJustice.GetAbilityData(level322)
    EventCenter323.Damage:Emit({whichUnit = data.caster, target = data.target, amount = ad__Damage, attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
    SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(data.caster, 1)
    SF__.BladeOfJustice.New():StartGroudDamage(data.caster, data.target, ad__Damage, ad__Duration, ad__DamagePerSecond)
end

function SF__.BladeOfJustice:StartGroudDamage(caster, target, ad__Damage324, ad__Duration325, ad__DamagePerSecond326)
    return SF__.CorRun__(function()
        local pos__x, pos__y = SF__.Vector2.FromUnit(target)
        local UnitAttribute = require("Objects.UnitAttribute")
        local EventCenter330 = require("Lib.EventCenter")
        local eff = ExAddSpecialEffect("Abilities/Spells/Orc/LiquidFire/Liquidfire.mdl", pos__x, pos__y, ad__Duration325)
        local p327 = GetOwningPlayer(caster)
        do
            local i328 = 0
            while (i328 < ad__Duration325) do
                SF__.CorWait__(1000)
                ExGroupEnumUnitsInRange(pos__x, pos__y, 300, function(u329)
                    if (not IsUnitEnemy(u329, p327)) then
                        return
                    end
                    if ExIsUnitDead(u329) then
                        return
                    end
                    local tarAttr = UnitAttribute.GetAttr(u329)
                    local damage = (ad__DamagePerSecond326 * (1 - tarAttr.radiantResistance))
                    EventCenter330.Damage:Emit({whichUnit = caster, target = u329, amount = damage, attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
                end)
                ::continue::
                i328 = (i328 + 1)
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
function SF__.CrusaderStrike.GetAbilityData(level331)
    return (0.65 + (0.35 * level331)), (0.15 * (level331 - 1))
end

function SF__.CrusaderStrike.Init()
    local EventCenter332 = require("Lib.EventCenter")
    EventCenter332.RegisterPlayerUnitSpellEffect:Emit({id = SF__.CrusaderStrike.ID, handler = SF__.CrusaderStrike.Start})
    ExTriggerRegisterNewUnit(function(u333)
        if (GetUnitTypeId(u333) == FourCC("Hpal")) then
            SF__.CrusaderStrike.UpdateAbilityMeta(u333)
        end
    end)
end

function SF__.CrusaderStrike.UpdateAbilityMeta(u334)
    local p335 = GetOwningPlayer(u334)
    local datas__DamageScaling, datas__ArtOfWarChance = {}, {}
    do
        local i336 = 0
        while (i336 < 3) do
            do
                local item__DamageScaling, item__ArtOfWarChance = SF__.CrusaderStrike.GetAbilityData((i336 + 1))
                table.insert(datas__DamageScaling, item__DamageScaling)
                table.insert(datas__ArtOfWarChance, item__ArtOfWarChance)
            end
            ::continue::
            i336 = (i336 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p335, SF__.CrusaderStrike.ID, "学习十字军打击 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p335, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击造成一次攻击伤害，伤害系数随技能等级提升。产生|cffff8c001|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 6秒\r\n\r\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling[(0 + 1)] * 100)), "%|r的攻击伤害。\r\n|cffffcc002级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling[(1 + 1)] * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas__ArtOfWarChance[(1 + 1)] * 100)), "%的战争艺术触发几率。\r\n|cffffcc003级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling[(2 + 1)] * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas__ArtOfWarChance[(2 + 1)] * 100)), "%的战争艺术触发几率。"), 0)
    do
        local i337 = 0
        while (i337 < 3) do
            local data__DamageScaling, data__ArtOfWarChance = datas__DamageScaling[(i337 + 1)], datas__ArtOfWarChance[(i337 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p335, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击 - [|cffffcc00", (i337 + 1), "级|r]"), i337)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p335, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击造成一次攻击伤害，造成|cffff8c00", string.format("%.0f", (data__DamageScaling * 100)), "%|r的攻击伤害", SF__.Ternary__((i337 > 0), SF__.StrConcat__("，", string.format("%.0f", (data__ArtOfWarChance * 100)), "%的战争艺术触发几率"), ""), "。产生|cffff8c001|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 6秒"), i337)
            ::continue::
            i337 = (i337 + 1)
        end
    end
    -- datas.Remove(new IAbilityData { DamageScaling = 0.65f, ArtOfWarChance = 0 });
    do
        local index338 = 0
        table.remove(datas__DamageScaling, (index338 + 1))
        table.remove(datas__ArtOfWarChance, (index338 + 1))
    end
end

function SF__.CrusaderStrike.Start(data339)
    local level340 = GetUnitAbilityLevel(data339.caster, SF__.CrusaderStrike.ID)
    local UnitAttribute341 = require("Objects.UnitAttribute")
    local EventCenter343 = require("Lib.EventCenter")
    local ad__DamageScaling, ad__ArtOfWarChance = SF__.CrusaderStrike.GetAbilityData(level340)
    local attr = UnitAttribute341.GetAttr(data339.caster)
    local damage342 = (attr:SimAttack(UnitAttribute341.HeroAttributeType.Strength) * ad__DamageScaling)
    EventCenter343.Damage:Emit({whichUnit = data339.caster, target = data339.target, amount = damage342, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
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

function SF__.CrusaderStrike.IAbilityData.Equals(self__DamageScaling344, self__ArtOfWarChance345, other__DamageScaling, other__ArtOfWarChance)
    return ((math.abs((self__DamageScaling344 - other__DamageScaling)) < 0.0001) and (math.abs((self__ArtOfWarChance345 - other__ArtOfWarChance)) < 0.0001))
end

function SF__.CrusaderStrike.IAbilityData.GetHashValue(self__DamageScaling346, self__ArtOfWarChance347)
    return 0
end
-- DivineToll
SF__.DivineToll = SF__.DivineToll or {}
SF__.DivineToll.Name = "DivineToll"
SF__.DivineToll.FullName = "DivineToll"
function SF__.DivineToll.GetAbilityData(level348)
    return (2 + level348), (50 * level348), 0.1, 10
end

function SF__.DivineToll.Init()
    local EventCenter350 = require("Lib.EventCenter")
    EventCenter350.RegisterPlayerUnitSpellEffect:Emit({id = SF__.DivineToll.ID, handler = function(data349)
        SF__.DivineToll.Start(data349)
    end})
    ExTriggerRegisterNewUnit(function(u351)
        if (GetUnitTypeId(u351) == FourCC("Hpal")) then
            SF__.DivineToll.UpdateAbilityMeta(u351)
        end
    end)
end

function SF__.DivineToll.UpdateAbilityMeta(u352)
    local p353 = GetOwningPlayer(u352)
    local datas__TargetCount, datas__Damage354, datas__RadiantDmgAmp, datas__Duration355 = {}, {}, {}, {}
    do
        local i356 = 0
        while (i356 < 3) do
            do
                local item__TargetCount, item__Damage357, item__RadiantDmgAmp, item__Duration358 = SF__.DivineToll.GetAbilityData((i356 + 1))
                table.insert(datas__TargetCount, item__TargetCount)
                table.insert(datas__Damage354, item__Damage357)
                table.insert(datas__RadiantDmgAmp, item__RadiantDmgAmp)
                table.insert(datas__Duration355, item__Duration358)
            end
            ::continue::
            i356 = (i356 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p353, SF__.DivineToll.ID, "学习圣洁鸣钟 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p353, SF__.DivineToll.ID, SF__.StrConcat__("对附近的多个目标施展审判，造成法术伤害，然后神圣之锤环绕圣殿骑士，每次命中敌人使其受到的光辉伤害提高。每个审判产生|cffff8c001|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 30秒\r\n\r\n|cffffcc001级|r - 审判最多|cffff8c00", datas__TargetCount[(0 + 1)], "|r个目标，造成|cffff8c00", datas__Damage354[(0 + 1)], "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas__RadiantDmgAmp[(0 + 1)] * 100)), "%|r的光辉易伤，持续|cffff8c00", datas__Duration355[(0 + 1)], "|r秒。\r\n|cffffcc002级|r - 审判最多|cffff8c00", datas__TargetCount[(1 + 1)], "|r个目标，造成|cffff8c00", datas__Damage354[(1 + 1)], "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas__RadiantDmgAmp[(1 + 1)] * 100)), "%|r的光辉易伤，持续|cffff8c00", datas__Duration355[(1 + 1)], "|r秒。\r\n|cffffcc003级|r - 审判最多|cffff8c00", datas__TargetCount[(2 + 1)], "|r个目标，造成|cffff8c00", datas__Damage354[(2 + 1)], "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas__RadiantDmgAmp[(2 + 1)] * 100)), "%|r的光辉易伤，持续|cffff8c00", datas__Duration355[(2 + 1)], "|r秒。"), 0)
    do
        local i359 = 0
        while (i359 < 3) do
            local data__TargetCount, data__Damage360, data__RadiantDmgAmp, data__Duration361 = datas__TargetCount[(i359 + 1)], datas__Damage354[(i359 + 1)], datas__RadiantDmgAmp[(i359 + 1)], datas__Duration355[(i359 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p353, SF__.DivineToll.ID, SF__.StrConcat__("圣洁鸣钟 - [|cffffcc00", (i359 + 1), "级|r]"), i359)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p353, SF__.DivineToll.ID, SF__.StrConcat__("对附近的最多|cffff8c00", data__TargetCount, "|r个目标施展审判，造成|cffff8c00", data__Damage360, "|r点法术伤害，然后神圣之锤环绕圣殿骑士，每次命中敌人使其受到的光辉伤害提高|cffff8c00", string.format("%.0f", (data__RadiantDmgAmp * 100)), "%|r，持续|cffff8c00", data__Duration361, "|r秒。每个审判产生|cffff8c001|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 30秒"), i359)
            ::continue::
            i359 = (i359 + 1)
        end
    end
end

function SF__.DivineToll.HurlToTarget(caster362, target363, pos__x364, pos__y365, pos__z)
    local outer = SF__.GameObject.New__s("DivineToll_Outer")
    local EventCenter369 = require("Lib.EventCenter")
    outer.transform.localPosition__x, outer.transform.localPosition__y, outer.transform.localPosition__z = 0, 0, 80
    local moveLayer = SF__.GameObject.New__sgameobject("MoveLayer", outer)
    moveLayer.transform.localPosition__x, moveLayer.transform.localPosition__y, moveLayer.transform.localPosition__z = pos__x364, pos__y365, pos__z
    local mtc = moveLayer:AddComponent(SF__.MoveTowardsComponent)
    mtc.targetType = SF__.TargetType.Unit
    mtc.unitTarget = target363
    mtc.speed = 900
    mtc.lookAtTarget = true
    mtc.colliderSize = 32
    mtc.onArrived = function()
        local cPos__x, cPos__y, cPos__z = mtc.gameObject.transform:get_position()
        local eff366 = ExAddSpecialEffect("Abilities/Spells/Human/StormBolt/StormBoltCaster.mdl", cPos__x, cPos__y, 0.1)
        BlzSetSpecialEffectTimeScale(eff366, 0.5)
        BlzSetSpecialEffectColor(eff366, 255, 255, 0)
        local ad__TargetCount, ad__Damage367, ad__RadiantDmgAmp, ad__Duration368 = SF__.DivineToll.GetAbilityData(GetUnitAbilityLevel(caster362, SF__.DivineToll.ID))
        EventCenter369.Damage:Emit({whichUnit = caster362, target = target363, amount = ad__Damage367, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
        SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(caster362, 1)
        outer:Destroy()
    end
    local orientationFixLayer = SF__.GameObject.New__sgameobject("DivineToll_Bolt", moveLayer)
    orientationFixLayer.transform.localRotation__x, orientationFixLayer.transform.localRotation__y, orientationFixLayer.transform.localRotation__z, orientationFixLayer.transform.localRotation__w = SF__.Quaternion.Euler(0, 90, 0)
    local selfRotLayer = SF__.GameObject.New__sgameobject("dt_hand", orientationFixLayer)
    local receiver = selfRotLayer:AddComponent(SF__.AutoTRSComponent)
    receiver.rotation__x, receiver.rotation__y, receiver.rotation__z, receiver.rotation__w = SF__.Quaternion.Euler(((1800 * SF__.Scene.DT) / 1000), 0, 0)
    local boltMis = SF__.GameObject.New__sgameobject("dt_mis", selfRotLayer)
    boltMis.transform.localPosition__x, boltMis.transform.localPosition__y, boltMis.transform.localPosition__z = 15, 0, 0
    boltMis.transform.localScale__x, boltMis.transform.localScale__y, boltMis.transform.localScale__z = 0.5, 0.5, 0.5
    local eff370 = AddSpecialEffect("Abilities/Spells/Human/StormBolt/StormBoltMissile.mdl", pos__x364, pos__y365)
    boltMis:AddComponent(SF__.AttachEffectComponent).eff = eff370
    local attachedHoly = SF__.GameObject.New__sgameobject("DivineToll_Holy", boltMis)
    attachedHoly.transform.localPosition__x, attachedHoly.transform.localPosition__y, attachedHoly.transform.localPosition__z = 15, 0, 0
    local effHoly = AddSpecialEffect("Abilities/Weapons/FaerieDragonMissile/FaerieDragonMissile.mdl", pos__x364, pos__y365)
    attachedHoly:AddComponent(SF__.AttachEffectComponent).eff = effHoly
    BlzSetSpecialEffectColor(effHoly, 20, 20, 20)
end

function SF__.DivineToll.Start(data371)
    return SF__.CorRun__(function()
        local pos__x372, pos__y373, pos__z374 = SF__.Vector3.FromUnit(data371.caster)
        local targets = SF__.Utils.CsGroupGetUnitsInRange(pos__x372, pos__y373, 600, function(u375)
            if (not IsUnitEnemy(u375, GetOwningPlayer(data371.caster))) then
                return false
            end
            if IsUnitType(u375, UNIT_TYPE_STRUCTURE) then
                return false
            end
            if ExIsUnitDead(u375) then
                return false
            end
            return true
        end)
        if (SF__.ListCount__(targets) == 0) then
            return
        end
        SF__.ListSort__(targets, function(a376, b377)
            local distA = SF__.Vector3.Distance(pos__x372, pos__y373, pos__z374, SF__.Vector3.FromUnit(a376))
            local distB = SF__.Vector3.Distance(pos__x372, pos__y373, pos__z374, SF__.Vector3.FromUnit(b377))
            return SF__.Ternary__((distA == distB), 0, SF__.Ternary__((distA < distB), (-1), 1))
        end)
        do
            local i378 = 0
            while (i378 < (function()
                local field__TargetCount, field__Damage, field__RadiantDmgAmp, field__Duration = SF__.DivineToll.GetAbilityData(GetUnitAbilityLevel(data371.caster, SF__.DivineToll.ID))
                return math.min(SF__.ListCount__(targets), field__TargetCount)
            end)()) do
                SF__.DivineToll.HurlToTarget(data371.caster, SF__.ListGet__(targets, i378), pos__x372, pos__y373, pos__z374)
                SF__.CorWait__(200)
                ::continue::
                i378 = (i378 + 1)
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
function SF__.DivineToll.IAbilityData.Equals(self__TargetCount, self__Damage379, self__RadiantDmgAmp, self__Duration380, other__TargetCount, other__Damage381, other__RadiantDmgAmp, other__Duration382)
    return (((math.abs((self__Damage379 - other__Damage381)) < 0.0001) and (math.abs((self__Duration380 - other__Duration382)) < 0.0001)) and (math.abs((self__RadiantDmgAmp - other__RadiantDmgAmp)) < 0.0001))
end
-- GameObject
SF__.GameObject = SF__.GameObject or {}
SF__.GameObject.Name = "GameObject"
SF__.GameObject.FullName = "GameObject"
function SF__.GameObject.MarkDestroyQueuedDepthFirst(obj)
    if (obj.isDestroyQueued or obj.isDestroyed) then
        return
    end
    obj.isDestroyQueued = true
    do
        local collection = obj.transform.children
        for i1, child in SF__.ListIterate__(collection) do
            SF__.GameObject.MarkDestroyQueuedDepthFirst(child.gameObject)
        end
    end
end

function SF__.GameObject.DestroyDepthFirst(obj13)
    if obj13.isDestroyed then
        return
    end
    local children = obj13.transform.children
    do
        local i = (SF__.ListCount__(children) - 1)
        while (i >= 0) do
            SF__.GameObject.DestroyDepthFirst(SF__.ListGet__(children, i).gameObject)
            ::continue::
            i = (i - 1)
        end
    end
    obj13.transform:SetParent(nil)
    do
        local collection2 = obj13._components
        for i3, comp in SF__.ListIterate__(collection2) do
            comp:OnDisable()
            comp:OnDestroy()
        end
    end
    SF__.ListClear__(obj13._components)
    SF__.ListRemove__(SF__.Scene.get_Instance().gameObjs, obj13)
    obj13.isDestroyed = true
end

function SF__.GameObject.UpdateBFS(obj14)
    if (obj14.isDestroyQueued or obj14.isDestroyed) then
        return
    end
    do
        local collection4 = obj14._components
        for i5, comp15 in SF__.ListIterate__(collection4) do
            comp15:Update()
        end
    end
    do
        local collection6 = obj14.transform.children
        for i7, child16 in SF__.ListIterate__(collection6) do
            SF__.GameObject.UpdateBFS(child16.gameObject)
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
    self.isDestroyQueued = false
    self.isDestroyed = false
    self.name = name
    self.transform = self:AddComponent(SF__.Transform)
    SF__.Scene.get_Instance():AddGameObject(self)
end

function SF__.GameObject.New__s(name)
    local self = setmetatable({}, { __index = SF__.GameObject })
    SF__.GameObject.__Init__s(self, name)
    return self
end

function SF__.GameObject.__Init__sgameobject(self, name17, parent18)
    SF__.GameObject.__Init__s(self, name17)
    self.transform:SetParent(parent18.transform)
end

function SF__.GameObject.New__sgameobject(name17, parent18)
    local self = setmetatable({}, { __index = SF__.GameObject })
    SF__.GameObject.__Init__sgameobject(self, name17, parent18)
    return self
end

function SF__.GameObject:GetComponent(T)
    do
        local collection8 = self._components
        for i9, comp19 in SF__.ListIterate__(collection8) do
            do
                local tComp = comp19
                if SF__.TypeIs__(tComp, T) then
                    return tComp
                end
            end
        end
    end
    return nil
end

function SF__.GameObject:AddComponent(T20)
    local comp21 = (function()
        local obj22 = T20.New()
        obj22.gameObject = self
        return obj22
    end)()
    SF__.ListAdd__(self._components, comp21)
    comp21:Awake()
    comp21:OnEnable()
    comp21:Start()
    return comp21
end

function SF__.GameObject:RemoveAllComponents(T23)
    do
        local i24 = (SF__.ListCount__(self._components) - 1)
        while (i24 >= 0) do
            if SF__.TypeIs__(SF__.ListGet__(self._components, i24), T23) then
                SF__.ListGet__(self._components, i24):OnDisable()
                SF__.ListGet__(self._components, i24):OnDestroy()
                SF__.ListRemoveAt__(self._components, i24)
            end
            ::continue::
            i24 = (i24 - 1)
        end
    end
end

function SF__.GameObject:Update()
    SF__.GameObject.UpdateBFS(self)
end

function SF__.GameObject:Destroy()
    if (self.isDestroyQueued or self.isDestroyed) then
        return
    end
    SF__.GameObject.MarkDestroyQueuedDepthFirst(self)
    SF__.Scene.get_Instance():QueueDestroy(self)
end

function SF__.GameObject.DestroyQueued(obj25)
    SF__.GameObject.DestroyDepthFirst(obj25)
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
    return SF__.StrConcat__("targetType: ", self.targetType, "\r\nunitTarget: ", SF__.Ternary__((self.unitTarget == nil), "None", GetUnitName(self.unitTarget)), "\r\npointTarget: ", SF__.Vector3.ToString(self.pointTarget__x, self.pointTarget__y, self.pointTarget__z), "\r\nspeed: ", self.speed, "\r\nlookAtTarget: ", self.lookAtTarget, "\r\ncolliderSize: ", self.colliderSize, "\r\nonArrived: ", SF__.Ternary__((self.onArrived == nil), "None", "Set"), "\r\nhasArrived: ", self.hasArrived, "\r\n")
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
        local a__x58, a__y59, a__z60 = (function()
            local a__x55, a__y56, a__z57 = SF__.Vector3.op_Multiply__fvector3((2 * SF__.Vector3.Dot(u__x, u__y, u__z, v__x, v__y, v__z)), u__x, u__y, u__z)
            return SF__.Vector3.op_Addition(a__x55, a__y56, a__z57, SF__.Vector3.op_Multiply__fvector3(((s * s) - SF__.Vector3.Dot(u__x, u__y, u__z, u__x, u__y, u__z)), v__x, v__y, v__z))
        end)()
        return SF__.Vector3.op_Addition(a__x58, a__y59, a__z60, SF__.Vector3.op_Multiply__fvector3((2 * s), SF__.Vector3.Cross(u__x, u__y, u__z, v__x, v__y, v__z)))
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
    local x61
    local y62
    local z
    local w
    local trace = ((m00 + m11) + m22)
    if (trace > 0) then
        local s63 = (math.sqrt((trace + 1)) * 2)
        w = (0.25 * s63)
        x61 = ((m21 - m12) / s63)
        y62 = ((m02 - m20) / s63)
        z = ((m10 - m01) / s63)
    elseif ((m00 > m11) and (m00 > m22)) then
        local s64 = (math.sqrt((((1 + m00) - m11) - m22)) * 2)
        w = ((m21 - m12) / s64)
        x61 = (0.25 * s64)
        y62 = ((m01 + m10) / s64)
        z = ((m02 + m20) / s64)
    else
        if (m11 > m22) then
            local s65 = (math.sqrt((((1 + m11) - m00) - m22)) * 2)
            w = ((m02 - m20) / s65)
            x61 = ((m01 + m10) / s65)
            y62 = (0.25 * s65)
            z = ((m12 + m21) / s65)
        else
            local s66 = (math.sqrt((((1 + m22) - m00) - m11)) * 2)
            w = ((m10 - m01) / s66)
            x61 = ((m02 + m20) / s66)
            y62 = ((m12 + m21) / s66)
            z = (0.25 * s66)
        end
    end
    return SF__.Quaternion.Normalize(x61, y62, z, w)
end

function SF__.Quaternion.LookRotation__vector3(forward__x67, forward__y68, forward__z69)
    return SF__.Quaternion.LookRotation__vector3vector3(forward__x67, forward__y68, forward__z69, SF__.Vector3.get_up())
end

function SF__.Quaternion.Normalize(q__x70, q__y71, q__z72, q__w73)
    local magnitude = math.sqrt(((((q__x70 * q__x70) + (q__y71 * q__y71)) + (q__z72 * q__z72)) + (q__w73 * q__w73)))
    if (magnitude < 0.0001) then
        return SF__.Quaternion.get_identity()
    end
    return (q__x70 / magnitude), (q__y71 / magnitude), (q__z72 / magnitude), (q__w73 / magnitude)
end

function SF__.Quaternion.get_eulerAngles(self__x, self__y, self__z, self__w)
    -- https://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles#Source_Code_2
    local sinr_cosp = (2 * ((self__w * self__x) + (self__y * self__z)))
    local cosr_cosp = (1 - (2 * ((self__x * self__x) + (self__y * self__y))))
    local roll74 = math.atan2(sinr_cosp, cosr_cosp)
    local sinp = (2 * ((self__w * self__y) - (self__z * self__x)))
    local pitch75
    if (math.abs(sinp) >= 1) then
        pitch75 = ((math.sign(sinp) * math.pi) / 2)
        -- use 90 degrees if out of range
    else
        pitch75 = math.asin(sinp)
    end
    local siny_cosp = (2 * ((self__w * self__z) + (self__x * self__y)))
    local cosy_cosp = (1 - (2 * ((self__y * self__y) + (self__z * self__z))))
    local yaw76 = math.atan2(siny_cosp, cosy_cosp)
    return (pitch75 * bj_RADTODEG), (yaw76 * bj_RADTODEG), (roll74 * bj_RADTODEG)
end

function SF__.Quaternion.get_normalized(self__x77, self__y78, self__z79, self__w80)
    return SF__.Quaternion.Normalize(self__x77, self__y78, self__z79, self__w80)
end

function SF__.Quaternion.Equals(self__x85, self__y86, self__z87, self__w88, other__x, other__y, other__z, other__w)
    return ((((math.abs((self__x85 - other__x)) < 0.0001) and (math.abs((self__y86 - other__y)) < 0.0001)) and (math.abs((self__z87 - other__z)) < 0.0001)) and (math.abs((self__w88 - other__w)) < 0.0001))
end

function SF__.Quaternion.ToString(self__x89, self__y90, self__z91, self__w92)
    return SF__.StrConcat__("(", self__x89, ", ", self__y90, ", ", self__z91, ", ", self__w92, ")")
end

function SF__.Quaternion.ApplyToEffect(self__x93, self__y94, self__z95, self__w96, e)
    local angles__x, angles__y, angles__z = SF__.Quaternion.get_eulerAngles(self__x93, self__y94, self__z95, self__w96)
    BlzSetSpecialEffectOrientation(e, (angles__y * bj_DEGTORAD), (angles__x * bj_DEGTORAD), (angles__z * bj_DEGTORAD))
end
-- RetributionPaladinGlobal
SF__.RetributionPaladinGlobal = SF__.RetributionPaladinGlobal or {}
SF__.RetributionPaladinGlobal.Name = "RetributionPaladinGlobal"
SF__.RetributionPaladinGlobal.FullName = "RetributionPaladinGlobal"
function SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(u383, amount)
    local UnitAttribute385 = require("Objects.UnitAttribute")
    local attr384 = UnitAttribute385.GetAttr(u383)
    attr384.retPalHolyEnergy = math.min((attr384.retPalHolyEnergy + amount), 5)
end

function SF__.RetributionPaladinGlobal:Init()
    ExTriggerRegisterNewUnit(function(u386)
        if (GetUnitTypeId(u386) == FourCC("Hpal")) then
            SF__.ListAdd__(self._units, u386)
        end
    end)
    _ = self:Start()
end

function SF__.RetributionPaladinGlobal:Start()
    return SF__.CorRun__(function()
        local UnitAttribute389 = require("Objects.UnitAttribute")
        while true do
            do
                local collection16 = self._units
                for i17, u387 in SF__.ListIterate__(collection16) do
                    local attr388 = UnitAttribute389.GetAttr(u387)
                    ExSetUnitMana(u387, ((ExGetUnitMaxMana(u387) * attr388.retPalHolyEnergy) * 0.2))
                    if (attr388.retPalHolyEnergy >= 3) then
                        SF__.Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u387), FourCC("A006"), "ReplaceableTextures/CommandButtons/BTNinv_helmet_96.tga")
                    else
                        SF__.Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u387), FourCC("A006"), "ReplaceableTextures/PassiveButtons/PASBTNinv_helmet_96.tga")
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

function SF__.Scene:AddGameObject(obj26)
    SF__.ListAdd__(self.gameObjs, obj26)
end

function SF__.Scene:QueueDestroy(obj27)
    SF__.ListAdd__(self._destroyQueue, obj27)
end

function SF__.Scene:FlushDestroyQueue()
    do
        local i28 = 0
        while (i28 < SF__.ListCount__(self._destroyQueue)) do
            SF__.GameObject.DestroyQueued(SF__.ListGet__(self._destroyQueue, i28))
            ::continue::
            i28 = (i28 + 1)
        end
    end
    SF__.ListClear__(self._destroyQueue)
end

function SF__.Scene:Run()
    return SF__.CorRun__(function()
        while true do
            SF__.CorWait__(SF__.Scene.DT)
            local rootObjs = SF__.ListNew__({})
            do
                local collection18 = self.gameObjs
                for i19, obj29 in SF__.ListIterate__(collection18) do
                    if (obj29.transform.parent == nil) then
                        SF__.ListAdd__(rootObjs, obj29)
                    end
                end
            end
            do
                local collection20 = rootObjs
                for i21, obj30 in SF__.ListIterate__(collection20) do
                    obj30:Update()
                end
            end
            self:FlushDestroyQueue()
            ::continue::
        end
    end)
end

function SF__.Scene.__Init(self)
    self.__sf_type = SF__.Scene
    self.gameObjs = SF__.ListNew__({})
    self._destroyQueue = SF__.ListNew__({})
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
    local item97 = SF__.ListGet__(self._items, (SF__.ListCount__(self._items) - 1))
    SF__.ListRemoveAt__(self._items, (SF__.ListCount__(self._items) - 1))
    return item97
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
local SystemBase31 = require("System.SystemBase")
SF__.Systems.InspectorSystem = SF__.Systems.InspectorSystem or class("InspectorSystem", SystemBase31)
SF__.Systems.InspectorSystem.Name = "InspectorSystem"
SF__.Systems.InspectorSystem.FullName = "Systems.InspectorSystem"
SF__.Systems.InspectorSystem.__sf_base = SystemBase31
function SF__.Systems.InspectorSystem:Awake()
    self:CreateFrames()
    self:RefreshHierarchy()
    self:SelectFirstVisibleObject()
    self:SetPanelVisible(false)
end

function SF__.Systems.InspectorSystem:Update(dt32)
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
        local i33 = 0
        while (i33 < SF__.Systems.InspectorSystem.MaxHierarchyRows) do
            SF__.ListAdd__(self._hierarchyRows, self:CreateHierarchyRow(i33))
            ::continue::
            i33 = (i33 + 1)
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
    local y34 = ((-0.061) - (index * (SF__.Systems.InspectorSystem.RowHeight + SF__.Systems.InspectorSystem.RowGap)))
    local button = BlzCreateFrameByType("BUTTON", "FdfInspectorHierarchyRow", self._panel, "ScoreScreenTabButtonTemplate", index)
    BlzFrameSetPoint(button, FRAMEPOINT_TOPLEFT, self._panel, FRAMEPOINT_TOPLEFT, (SF__.Systems.InspectorSystem.Padding * 2), y34)
    BlzFrameSetSize(button, (SF__.Systems.InspectorSystem.LeftWidth - (SF__.Systems.InspectorSystem.Padding * 4)), SF__.Systems.InspectorSystem.RowHeight)
    local label35 = BlzCreateFrameByType("TEXT", "FdfInspectorHierarchyRowText", button, "", index)
    BlzFrameSetPoint(label35, FRAMEPOINT_TOPLEFT, button, FRAMEPOINT_TOPLEFT, 0.004, (-0.002))
    BlzFrameSetSize(label35, (SF__.Systems.InspectorSystem.LeftWidth - (SF__.Systems.InspectorSystem.Padding * 5)), (SF__.Systems.InspectorSystem.RowHeight - 0.003))
    BlzFrameSetEnable(label35, false)
    BlzFrameSetTextAlignment(label35, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_LEFT)
    BlzFrameSetText(label35, "")
    local row = SF__.Systems.InspectorSystem.HierarchyRow.New(button, label35)
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

function SF__.Systems.InspectorSystem:SelectRow(row36)
    if (row36.gameObject == nil) then
        return
    end
    self._selectedGameObject = row36.gameObject
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
        for i23, obj37 in SF__.ListIterate__(collection22) do
            if (obj37.transform.parent == nil) then
                self:AddHierarchyObject(obj37, 0)
            end
        end
    end
    do
        local i38 = 0
        while (i38 < SF__.ListCount__(self._hierarchyRows)) do
            local row39 = SF__.ListGet__(self._hierarchyRows, i38)
            if (i38 < SF__.ListCount__(self._visibleObjects)) then
                local obj40 = SF__.ListGet__(self._visibleObjects, i38)
                row39.gameObject = obj40
                row39.depth = self:GetDepth(obj40)
                self:SetRowLabel(row39, obj40.name, row39.depth)
                BlzFrameSetVisible(row39.button, self._isVisible)
            else
                row39.gameObject = nil
                BlzFrameSetVisible(row39.button, false)
            end
            ::continue::
            i38 = (i38 + 1)
        end
    end
    BlzFrameSetVisible(self._emptyText, (self._isVisible and (SF__.ListCount__(self._visibleObjects) == 0)))
    self._lastObjectCount = SF__.ListCount__(SF__.Scene.get_Instance().gameObjs)
    self:RefreshHierarchySelection()
end

function SF__.Systems.InspectorSystem:AddHierarchyObject(obj41, depth)
    if (SF__.ListCount__(self._visibleObjects) >= SF__.Systems.InspectorSystem.MaxHierarchyRows) then
        return
    end
    SF__.ListAdd__(self._visibleObjects, obj41)
    do
        local collection24 = obj41.transform.children
        for i25, child42 in SF__.ListIterate__(collection24) do
            self:AddHierarchyObject(child42.gameObject, (depth + 1))
        end
    end
end

function SF__.Systems.InspectorSystem:GetDepth(obj43)
    local depth44 = 0
    local parent45 = obj43.transform.parent
    while (parent45 ~= nil) do
        depth44 = (depth44 + 1)
        parent45 = parent45.parent
        ::continue::
    end
    return depth44
end

function SF__.Systems.InspectorSystem:SetRowLabel(row46, text47, depth48)
    BlzFrameClearAllPoints(row46.label)
    BlzFrameSetPoint(row46.label, FRAMEPOINT_TOPLEFT, row46.button, FRAMEPOINT_TOPLEFT, (0.004 + (depth48 * SF__.Systems.InspectorSystem.IndentWidth)), (-0.002))
    BlzFrameSetSize(row46.label, ((SF__.Systems.InspectorSystem.LeftWidth - (SF__.Systems.InspectorSystem.Padding * 5)) - (depth48 * SF__.Systems.InspectorSystem.IndentWidth)), (SF__.Systems.InspectorSystem.RowHeight - 0.003))
    BlzFrameSetText(row46.label, text47)
end

function SF__.Systems.InspectorSystem:RefreshHierarchySelection()
    do
        local collection26 = self._hierarchyRows
        for i27, row49 in SF__.ListIterate__(collection26) do
            local isSelected = ((row49.gameObject ~= nil) and (row49.gameObject == self._selectedGameObject))
            BlzFrameSetTextColor(row49.label, SF__.Ternary__(isSelected, BlzConvertColor(255, 255, 220, 80), BlzConvertColor(255, 230, 230, 230)))
        end
    end
end

function SF__.Systems.InspectorSystem:RefreshInspectorText()
    if (self._selectedGameObject == nil) then
        BlzFrameSetText(self._inspectorText, "")
        return
    end
    local text50 = SF__.StrConcat__(self._selectedGameObject.name, "\n")
    do
        local collection28 = self._selectedGameObject:get_components()
        for i29, component in SF__.ListIterate__(collection28) do
            text50 = SF__.StrConcat__(text50, "\n[", component.__sf_type.Name, "]")
            local inspectorText = component:GetInspectorText()
            if (inspectorText ~= "") then
                text50 = SF__.StrConcat__(text50, "\n", inspectorText)
            end
        end
    end
    BlzFrameSetText(self._inspectorText, text50)
end

function SF__.Systems.InspectorSystem:SceneContains(gameObject)
    do
        local collection30 = SF__.Scene.get_Instance().gameObjs
        for i31, obj51 in SF__.ListIterate__(collection30) do
            if (obj51 == gameObject) then
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
function SF__.Systems.InspectorSystem.HierarchyRow.__Init(self, button52, label53)
    self.__sf_type = SF__.Systems.InspectorSystem.HierarchyRow
    self.button = nil
    self.label = nil
    self.gameObject = nil
    self.depth = 0
    self.button = button52
    self.label = label53
end

function SF__.Systems.InspectorSystem.HierarchyRow.New(button52, label53)
    local self = setmetatable({}, { __index = SF__.Systems.InspectorSystem.HierarchyRow })
    SF__.Systems.InspectorSystem.HierarchyRow.__Init(self, button52, label53)
    return self
end
-- Systems.MeleeGameSystem
local SystemBase54 = require("System.SystemBase")
SF__.Systems.MeleeGameSystem = SF__.Systems.MeleeGameSystem or class("MeleeGameSystem", SystemBase54)
SF__.Systems.MeleeGameSystem.Name = "MeleeGameSystem"
SF__.Systems.MeleeGameSystem.FullName = "Systems.MeleeGameSystem"
SF__.Systems.MeleeGameSystem.__sf_base = SystemBase54
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
function SF__.TemplarStrikes.GetAbilityData(level390)
    return 2, (0.5 + (0.25 * level390)), (0.05 * level390)
end

function SF__.TemplarStrikes.Init()
    local EventCenter391 = require("Lib.EventCenter")
    EventCenter391.RegisterPlayerUnitSpellEffect:Emit({id = SF__.TemplarStrikes.ID, handler = SF__.TemplarStrikes.Start})
    ExTriggerRegisterNewUnit(function(u392)
        if (GetUnitTypeId(u392) == FourCC("Hpal")) then
            SF__.TemplarStrikes.UpdateAbilityMeta(u392)
            SetHeroLevel(u392, 10, true)
        end
    end)
    EventCenter391.RegisterPlayerUnitDamaged:Emit(function(caster393, target394, damage395, weapType, dmgType, isAttack)
        if (GetUnitAbilityLevel(caster393, SF__.TemplarStrikes.ID) <= 0) then
            return
        end
        if (not isAttack) then
            return
        end
        if (target394 == nil) then
            return
        end
        if ExIsUnitDead(target394) then
            return
        end
        SF__.TemplarStrikes.TryResetBOJ(caster393)
    end)
end

function SF__.TemplarStrikes.TryResetBOJ(caster396)
    local level397 = GetUnitAbilityLevel(caster396, SF__.TemplarStrikes.ID)
    local ad__AttackCount, ad__DamageScaling398, ad__ResetBOJChance = SF__.TemplarStrikes.GetAbilityData(level397)
    if (math.random() >= ad__ResetBOJChance) then
        return
    end
    BlzEndUnitAbilityCooldown(caster396, SF__.BladeOfJustice.ID)
    ExAddSpecialEffectTarget("Abilities/Spells/Items/AIam/AIamTarget.mdl", caster396, "origin", 0.3)
end

function SF__.TemplarStrikes.UpdateAbilityMeta(u399)
    local p400 = GetOwningPlayer(u399)
    local datas__AttackCount, datas__DamageScaling401, datas__ResetBOJChance = {}, {}, {}
    do
        local i402 = 0
        while (i402 < SF__.TemplarStrikes.MaxLevel) do
            do
                local item__AttackCount, item__DamageScaling403, item__ResetBOJChance = SF__.TemplarStrikes.GetAbilityData((i402 + 1))
                table.insert(datas__AttackCount, item__AttackCount)
                table.insert(datas__DamageScaling401, item__DamageScaling403)
                table.insert(datas__ResetBOJChance, item__ResetBOJChance)
            end
            ::continue::
            i402 = (i402 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p400, SF__.TemplarStrikes.ID, "学习圣殿骑士之击 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p400, SF__.TemplarStrikes.ID, SF__.StrConcat__("快速攻击目标|cffff8c00", datas__AttackCount[(0 + 1)], "|r次，第一次造成普通攻击伤害，第二次造成光辉伤害，有一定几率重置公正之剑的冷却时间，普通攻击也会触发。\r\n\r\n|cff99ccff冷却时间|r - 10秒\r\n\r\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling401[(0 + 1)] * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas__ResetBOJChance[(0 + 1)] * 100)), "%|r的几率重置公正之剑。\r\n|cffffcc002级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling401[(1 + 1)] * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas__ResetBOJChance[(1 + 1)] * 100)), "%|r的几率重置公正之剑。\r\n|cffffcc003级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling401[(2 + 1)] * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas__ResetBOJChance[(2 + 1)] * 100)), "%|r的几率重置公正之剑。"), 0)
    do
        local i404 = 0
        while (i404 < SF__.TemplarStrikes.MaxLevel) do
            local data__AttackCount, data__DamageScaling405, data__ResetBOJChance = datas__AttackCount[(i404 + 1)], datas__DamageScaling401[(i404 + 1)], datas__ResetBOJChance[(i404 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p400, SF__.TemplarStrikes.ID, SF__.StrConcat__("圣殿骑士之击 - [|cffffcc00", (i404 + 1), "级|r]"), i404)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p400, SF__.TemplarStrikes.ID, SF__.StrConcat__("快速攻击目标|cffff8c00", data__AttackCount, "|r次，第一次造成普通攻击伤害，第二次造成普通攻击|cffff8c00", string.format("%.0f", (data__DamageScaling405 * 100)), "%|r的光辉伤害，|cffff8c00", string.format("%.0f", (data__ResetBOJChance * 100)), "%|r几率重置公正之剑的冷却时间，普通攻击也会触发。\r\n\r\n|cff99ccff冷却时间|r - 10秒"), i404)
            ::continue::
            i404 = (i404 + 1)
        end
    end
end

function SF__.TemplarStrikes.Start(data406)
    return SF__.CorRun__(function()
        local level407 = GetUnitAbilityLevel(data406.caster, SF__.TemplarStrikes.ID)
        local UnitAttribute409 = require("Objects.UnitAttribute")
        local EventCenter410 = require("Lib.EventCenter")
        local attr408 = UnitAttribute409.GetAttr(data406.caster)
        local normalDamage = attr408:SimMeleeAttack()
        EventCenter410.Damage:Emit({whichUnit = data406.caster, target = data406.target, amount = normalDamage, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
        SF__.TemplarStrikes.TryResetBOJ(data406.caster)
        SetUnitTimeScale(data406.caster, 3)
        ResetUnitAnimation(data406.caster)
        SetUnitAnimation(data406.caster, "attack - 2")
        SF__.CorWait__(math.round(((1.166 * 0.33) * 1000)))
        local tarAttr411 = UnitAttribute409.GetAttr(data406.target)
        local ad__AttackCount412, ad__DamageScaling413, ad__ResetBOJChance414 = SF__.TemplarStrikes.GetAbilityData(level407)
        local radiantDamage = ((attr408:SimMeleeAttack() * ad__DamageScaling413) * (1 - tarAttr411.radiantResistance))
        EventCenter410.Damage:Emit({whichUnit = data406.caster, target = data406.target, amount = radiantDamage, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
        SF__.TemplarStrikes.TryResetBOJ(data406.caster)
        SetUnitTimeScale(data406.caster, 1)
        ResetUnitAnimation(data406.caster)
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
function SF__.TemplarStrikes.IAbilityData.Equals(self__AttackCount, self__DamageScaling415, self__ResetBOJChance, other__AttackCount, other__DamageScaling416, other__ResetBOJChance)
    return ((math.abs((self__DamageScaling415 - other__DamageScaling416)) < 0.0001) and (math.abs((self__ResetBOJChance - other__ResetBOJChance)) < 0.0001))
end
-- TemplarVerdict
SF__.TemplarVerdict = SF__.TemplarVerdict or {}
SF__.TemplarVerdict.Name = "TemplarVerdict"
SF__.TemplarVerdict.FullName = "TemplarVerdict"
function SF__.TemplarVerdict.GetAbilityData(level417)
    return 2.25, 0.3, 0.15
end

function SF__.TemplarVerdict.Init()
    local EventCenter418 = require("Lib.EventCenter")
    EventCenter418.RegisterPlayerUnitSpellChannel:Emit({id = SF__.TemplarVerdict.ID, handler = SF__.TemplarVerdict.Check})
    EventCenter418.RegisterPlayerUnitSpellEffect:Emit({id = SF__.TemplarVerdict.ID, handler = SF__.TemplarVerdict.Start})
    ExTriggerRegisterNewUnit(function(u419)
        if (GetUnitTypeId(u419) == FourCC("Hpal")) then
            SF__.TemplarVerdict.UpdateAbilityMeta(u419)
        end
    end)
end

function SF__.TemplarVerdict.Check(data420)
    local UnitAttribute422 = require("Objects.UnitAttribute")
    local attr421 = UnitAttribute422.GetAttr(data420.caster)
    if (attr421.retPalHolyEnergy < 3) then
        IssueImmediateOrderById(data420.caster, SF__.ConstOrderId.Stop)
        ExTextState(data420.caster, "圣能不足")
    end
end

function SF__.TemplarVerdict.UpdateAbilityMeta(u423)
    local p424 = GetOwningPlayer(u423)
    local datas__DamageScaling425, datas__JudgementDamageScaling, datas__ChanceToResetJudgement = {}, {}, {}
    do
        local i426 = 0
        while (i426 < 1) do
            do
                local item__DamageScaling427, item__JudgementDamageScaling, item__ChanceToResetJudgement = SF__.TemplarVerdict.GetAbilityData((i426 + 1))
                table.insert(datas__DamageScaling425, item__DamageScaling427)
                table.insert(datas__JudgementDamageScaling, item__JudgementDamageScaling)
                table.insert(datas__ChanceToResetJudgement, item__ChanceToResetJudgement)
            end
            ::continue::
            i426 = (i426 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p424, SF__.TemplarVerdict.ID, "学习圣殿骑士的裁决 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p424, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决造成一次攻击伤害，如果目标被审判，造成30%的额外伤害，15%几率重置审判。消耗|cffff8c003|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 5秒\r\n\r\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas__JudgementDamageScaling[(0 + 1)] * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas__ChanceToResetJudgement[(0 + 1)] * 100)), "%的战争艺术触发几率。"), 0)
    do
        local i428 = 0
        while (i428 < 1) do
            local data__DamageScaling429, data__JudgementDamageScaling, data__ChanceToResetJudgement = datas__DamageScaling425[(i428 + 1)], datas__JudgementDamageScaling[(i428 + 1)], datas__ChanceToResetJudgement[(i428 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p424, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决 - [|cffffcc00", (i428 + 1), "级|r]"), i428)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p424, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决造成一次攻击伤害，造成|cffff8c00", string.format("%.0f", (data__DamageScaling429 * 100)), "%|r的攻击伤害。消耗|cffff8c003|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 5秒"), i428)
            ::continue::
            i428 = (i428 + 1)
        end
    end
end

function SF__.TemplarVerdict.Start(data430)
    local level431 = GetUnitAbilityLevel(data430.caster, SF__.TemplarVerdict.ID)
    local UnitAttribute434 = require("Objects.UnitAttribute")
    local EventCenter436 = require("Lib.EventCenter")
    local ad__DamageScaling432, ad__JudgementDamageScaling, ad__ChanceToResetJudgement = SF__.TemplarVerdict.GetAbilityData(level431)
    local attr433 = UnitAttribute434.GetAttr(data430.caster)
    local damage435 = (attr433:SimAttack(UnitAttribute434.HeroAttributeType.Strength) * ad__DamageScaling432)
    EventCenter436.Damage:Emit({whichUnit = data430.caster, target = data430.target, amount = damage435, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_SLICE, outResult = {}})
    attr433.retPalHolyEnergy = (attr433.retPalHolyEnergy - 3)
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
function SF__.TemplarVerdict.IAbilityData.Equals(self__DamageScaling437, self__JudgementDamageScaling, self__ChanceToResetJudgement, other__DamageScaling438, other__JudgementDamageScaling, other__ChanceToResetJudgement)
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
    local globalPos__x3, globalPos__y4, globalPos__z5 = self.localPosition__x, self.localPosition__y, self.localPosition__z
    local globalRot__x6, globalRot__y7, globalRot__z8, globalRot__w9 = self.localRotation__x, self.localRotation__y, self.localRotation__z, self.localRotation__w
    local globalScale__x10, globalScale__y11, globalScale__z12 = self.localScale__x, self.localScale__y, self.localScale__z
    local myParent = self.parent
    while (myParent ~= nil) do
        globalPos__x3, globalPos__y4, globalPos__z5 = SF__.Vector3.op_Addition(myParent.localPosition__x, myParent.localPosition__y, myParent.localPosition__z, SF__.Quaternion.op_Multiply__quaternionvector3(myParent.localRotation__x, myParent.localRotation__y, myParent.localRotation__z, myParent.localRotation__w, SF__.Vector3.Scale(myParent.localScale__x, myParent.localScale__y, myParent.localScale__z, globalPos__x3, globalPos__y4, globalPos__z5)))
        globalRot__x6, globalRot__y7, globalRot__z8, globalRot__w9 = SF__.Quaternion.op_Multiply__quaternionquaternion(myParent.localRotation__x, myParent.localRotation__y, myParent.localRotation__z, myParent.localRotation__w, globalRot__x6, globalRot__y7, globalRot__z8, globalRot__w9)
        globalScale__x10, globalScale__y11, globalScale__z12 = SF__.Vector3.Scale(myParent.localScale__x, myParent.localScale__y, myParent.localScale__z, globalScale__x10, globalScale__y11, globalScale__z12)
        myParent = myParent.parent
        ::continue::
    end
    return globalPos__x3, globalPos__y4, globalPos__z5
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

function SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p98, abilCode99, researchExtendedTooltip, level100)
    if (GetLocalPlayer() ~= p98) then
        return
    end
    BlzSetAbilityResearchExtendedTooltip(abilCode99, researchExtendedTooltip, level100)
end

function SF__.Utils.ExBlzSetAbilityTooltip(p101, abilCode102, tooltip, level103)
    if (GetLocalPlayer() ~= p101) then
        return
    end
    BlzSetAbilityTooltip(abilCode102, tooltip, level103)
end

function SF__.Utils.ExBlzSetAbilityExtendedTooltip(p104, abilCode105, extendedTooltip, level106)
    if (GetLocalPlayer() ~= p104) then
        return
    end
    BlzSetAbilityExtendedTooltip(abilCode105, extendedTooltip, level106)
end

function SF__.Utils.ExBlzSetAbilityIcon(p107, abilCode108, iconPath)
    if (GetLocalPlayer() ~= p107) then
        return
    end
    BlzSetAbilityIcon(abilCode108, iconPath)
end

function SF__.Utils.CsGroupGetUnitsInRange(x109, y110, radius, filter)
    local result = SF__.ListNew__({})
    ExGroupEnumUnitsInRange(x109, y110, radius, function(u)
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

function SF__.Vector2.Dot(a__x111, a__y112, b__x113, b__y114)
    return ((a__x111 * b__x113) + (a__y112 * b__y114))
end

function SF__.Vector2.Cross(a__x115, a__y116, b__x117, b__y118)
    return ((a__y116 * b__x117) - (a__x115 * b__y118))
end

function SF__.Vector2.op_UnaryNegation(a__x119, a__y120)
    return (-a__x119), (-a__y120)
end

function SF__.Vector2.op_Addition(a__x121, a__y122, b__x123, b__y124)
    return (a__x121 + b__x123), (a__y122 + b__y124)
end

function SF__.Vector2.op_Subtraction(a__x125, a__y126, b__x127, b__y128)
    return (a__x125 - b__x127), (a__y126 - b__y128)
end

function SF__.Vector2.op_Multiply__vector2f(v__x129, v__y130, f)
    return (v__x129 * f), (v__y130 * f)
end

function SF__.Vector2.op_Multiply__fvector2(f131, v__x132, v__y133)
    return (v__x132 * f131), (v__y133 * f131)
end

function SF__.Vector2.op_Division(v__x134, v__y135, f136)
    return (v__x134 / f136), (v__y135 / f136)
end

function SF__.Vector2.op_Equality(a__x137, a__y138, b__x139, b__y140)
    return ((math.abs((a__x137 - b__x139)) < 0.0001) and (math.abs((a__y138 - b__y140)) < 0.0001))
end

function SF__.Vector2.op_Inequality(a__x141, a__y142, b__x143, b__y144)
    return (not SF__.Vector2.op_Equality(a__x141, a__y142, b__x143, b__y144))
end

function SF__.Vector2.UnitDistance(a, b)
    local v1__x, v1__y = SF__.Vector2.FromUnit(a)
    local v2__x, v2__y = SF__.Vector2.FromUnit(b)
    return SF__.Vector2.get_Magnitude(SF__.Vector2.op_Subtraction(v1__x, v1__y, v2__x, v2__y))
end

function SF__.Vector2.SqrUnitDistance(a145, b146)
    local v1__x147, v1__y148 = SF__.Vector2.FromUnit(a145)
    local v2__x149, v2__y150 = SF__.Vector2.FromUnit(b146)
    return SF__.Vector2.get_SqrMagnitude(SF__.Vector2.op_Subtraction(v1__x147, v1__y148, v2__x149, v2__y150))
end

function SF__.Vector2.FromUnit(u151)
    return GetUnitX(u151), GetUnitY(u151)
end

function SF__.Vector2.get_Magnitude(self__x152, self__y153)
    return math.sqrt(SF__.Vector2.get_SqrMagnitude(self__x152, self__y153))
end

function SF__.Vector2.get_SqrMagnitude(self__x154, self__y155)
    return ((self__x154 * self__x154) + (self__y155 * self__y155))
end

function SF__.Vector2.get_Normalized(self__x156, self__y157)
    local mag = SF__.Vector2.get_Magnitude(self__x156, self__y157)
    if (mag < 0.0001) then
        return SF__.Vector2.get_Zero()
    end
    return SF__.Vector2.op_Division(self__x156, self__y157, mag)
end

function SF__.Vector2.ClampMagnitude(self__x160, self__y161, mag162)
    return (function()
        local v__x163, v__y164 = SF__.Vector2.get_Normalized(self__x160, self__y161)
        return SF__.Vector2.op_Multiply__vector2f(v__x163, v__y164, mag162)
    end)()
end

function SF__.Vector2.Equals(self__x165, self__y166, other__x167, other__y168)
    return SF__.Vector2.op_Equality(self__x165, self__y166, other__x167, other__y168)
end

function SF__.Vector2.ToString(self__x169, self__y170)
    return SF__.StrConcat__("(", self__x169, ", ", self__y170, ")")
end

function SF__.Vector2.Rotate(self__x171, self__y172, angle173)
    local cos = math.cos(angle173)
    local sin = math.sin(angle173)
    return ((self__x171 * cos) - (self__y172 * sin)), ((self__x171 * sin) + (self__y172 * cos))
end

function SF__.Vector2.UnitMoveTo(self__x174, self__y175, u176)
    SetUnitX(u176, self__x174)
    SetUnitY(u176, self__y175)
end

function SF__.Vector2.GetTerrainZ(self__x177, self__y178)
    MoveLocation(SF__.Vector2._loc, self__x177, self__y178)
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

function SF__.Vector3.op_Addition(a__x179, a__y180, a__z181, b__x182, b__y183, b__z184)
    return (a__x179 + b__x182), (a__y180 + b__y183), (a__z181 + b__z184)
end

function SF__.Vector3.op_UnaryNegation(a__x185, a__y186, a__z187)
    return (-a__x185), (-a__y186), (-a__z187)
end

function SF__.Vector3.op_Subtraction(a__x188, a__y189, a__z190, b__x191, b__y192, b__z193)
    return (a__x188 - b__x191), (a__y189 - b__y192), (a__z190 - b__z193)
end

function SF__.Vector3.op_Multiply__vector3f(v__x194, v__y195, v__z196, f197)
    return (v__x194 * f197), (v__y195 * f197), (v__z196 * f197)
end

function SF__.Vector3.op_Multiply__fvector3(f198, v__x199, v__y200, v__z201)
    return (v__x199 * f198), (v__y200 * f198), (v__z201 * f198)
end

function SF__.Vector3.op_Division(v__x202, v__y203, v__z204, f205)
    return (v__x202 / f205), (v__y203 / f205), (v__z204 / f205)
end

function SF__.Vector3.op_Equality(a__x206, a__y207, a__z208, b__x209, b__y210, b__z211)
    return (((math.abs((a__x206 - b__x209)) < 0.0001) and (math.abs((a__y207 - b__y210)) < 0.0001)) and (math.abs((a__z208 - b__z211)) < 0.0001))
end

function SF__.Vector3.op_Inequality(a__x212, a__y213, a__z214, b__x215, b__y216, b__z217)
    return (not SF__.Vector3.op_Equality(a__x212, a__y213, a__z214, b__x215, b__y216, b__z217))
end

-- <summary>
-- Warcraft III world space here is right-handed: +x points right, +y points away, +z points up.
-- That means Cross((1,0,0), (0,1,0)) == (0,0,1).
-- </summary>
--
function SF__.Vector3.Cross(a__x218, a__y219, a__z220, b__x221, b__y222, b__z223)
    return ((a__y219 * b__z223) - (a__z220 * b__y222)), ((a__z220 * b__x221) - (a__x218 * b__z223)), ((a__x218 * b__y222) - (a__y219 * b__x221))
end

function SF__.Vector3.Distance(a__x224, a__y225, a__z226, b__x227, b__y228, b__z229)
    return SF__.Vector3.get_magnitude(SF__.Vector3.op_Subtraction(a__x224, a__y225, a__z226, b__x227, b__y228, b__z229))
end

function SF__.Vector3.Dot(a__x230, a__y231, a__z232, b__x233, b__y234, b__z235)
    return (((a__x230 * b__x233) + (a__y231 * b__y234)) + (a__z232 * b__z235))
end

function SF__.Vector3.MoveTowards(current__x, current__y, current__z, target__x, target__y, target__z, maxDistanceDelta)
    local toVector__x, toVector__y, toVector__z = SF__.Vector3.op_Subtraction(target__x, target__y, target__z, current__x, current__y, current__z)
    local dist = SF__.Vector3.get_magnitude(toVector__x, toVector__y, toVector__z)
    if ((dist <= maxDistanceDelta) or (dist == 0)) then
        return target__x, target__y, target__z
    end
    return SF__.Vector3.op_Addition(current__x, current__y, current__z, SF__.Vector3.op_Division(toVector__x, toVector__y, toVector__z, (dist / maxDistanceDelta)))
end

function SF__.Vector3.Project(v__x236, v__y237, v__z238, onNormal__x, onNormal__y, onNormal__z)
    local sqrMag = SF__.Vector3.Dot(onNormal__x, onNormal__y, onNormal__z, onNormal__x, onNormal__y, onNormal__z)
    if (sqrMag < 0.0001) then
        return SF__.Vector3.get_zero()
    end
    local dot = SF__.Vector3.Dot(v__x236, v__y237, v__z238, onNormal__x, onNormal__y, onNormal__z)
    return SF__.Vector3.op_Multiply__vector3f(onNormal__x, onNormal__y, onNormal__z, (dot / sqrMag))
end

function SF__.Vector3.ProjectOnPlane(v__x239, v__y240, v__z241, planeNormal__x, planeNormal__y, planeNormal__z)
    return SF__.Vector3.op_Subtraction(v__x239, v__y240, v__z241, SF__.Vector3.Project(v__x239, v__y240, v__z241, planeNormal__x, planeNormal__y, planeNormal__z))
end

function SF__.Vector3.Reflect(inDirection__x, inDirection__y, inDirection__z, inNormal__x, inNormal__y, inNormal__z)
    return SF__.Vector3.op_Subtraction(inDirection__x, inDirection__y, inDirection__z, SF__.Vector3.op_Multiply__fvector3((2 * SF__.Vector3.Dot(inDirection__x, inDirection__y, inDirection__z, inNormal__x, inNormal__y, inNormal__z)), inNormal__x, inNormal__y, inNormal__z))
end

function SF__.Vector3.RotateTowards(current__x242, current__y243, current__z244, target__x245, target__y246, target__z247, maxRadiansDelta, maxMagnitudeDelta)
    local currentMag = SF__.Vector3.get_magnitude(current__x242, current__y243, current__z244)
    local targetMag = SF__.Vector3.get_magnitude(target__x245, target__y246, target__z247)
    if ((currentMag == 0) or (targetMag == 0)) then
        return SF__.Vector3.MoveTowards(current__x242, current__y243, current__z244, target__x245, target__y246, target__z247, maxMagnitudeDelta)
    end
    local currentNorm__x, currentNorm__y, currentNorm__z = SF__.Vector3.op_Division(current__x242, current__y243, current__z244, currentMag)
    local targetNorm__x, targetNorm__y, targetNorm__z = SF__.Vector3.op_Division(target__x245, target__y246, target__z247, targetMag)
    local dot248 = math.clamp(SF__.Vector3.Dot(currentNorm__x, currentNorm__y, currentNorm__z, targetNorm__x, targetNorm__y, targetNorm__z), (-1), 1)
    local angle249 = math.acos(dot248)
    if (angle249 == 0) then
        return SF__.Vector3.MoveTowards(current__x242, current__y243, current__z244, target__x245, target__y246, target__z247, maxMagnitudeDelta)
    end
    local t = math.min(1, (maxRadiansDelta / angle249))
    local newDir__x, newDir__y, newDir__z = SF__.Vector3.Slerp(currentNorm__x, currentNorm__y, currentNorm__z, targetNorm__x, targetNorm__y, targetNorm__z, t)
    local newMag = math.moveTowards(currentMag, targetMag, maxMagnitudeDelta)
    return SF__.Vector3.op_Multiply__vector3f(newDir__x, newDir__y, newDir__z, newMag)
end

function SF__.Vector3.Scale(a__x250, a__y251, a__z252, b__x253, b__y254, b__z255)
    return (a__x250 * b__x253), (a__y251 * b__y254), (a__z252 * b__z255)
end

function SF__.Vector3.Slerp(a__x256, a__y257, a__z258, b__x259, b__y260, b__z261, t262)
    local magA = SF__.Vector3.get_magnitude(a__x256, a__y257, a__z258)
    local magB = SF__.Vector3.get_magnitude(b__x259, b__y260, b__z261)
    if ((magA == 0) or (magB == 0)) then
        return SF__.Vector3.MoveTowards(a__x256, a__y257, a__z258, b__x259, b__y260, b__z261, math.huge)
    end
    local normA__x, normA__y, normA__z = SF__.Vector3.op_Division(a__x256, a__y257, a__z258, magA)
    local normB__x, normB__y, normB__z = SF__.Vector3.op_Division(b__x259, b__y260, b__z261, magB)
    local dot263 = math.clamp(SF__.Vector3.Dot(normA__x, normA__y, normA__z, normB__x, normB__y, normB__z), (-1), 1)
    local angle264 = math.acos(dot263)
    local sinAngle = math.sin(angle264)
    if (sinAngle < 0.0001) then
        return SF__.Vector3.MoveTowards(a__x256, a__y257, a__z258, b__x259, b__y260, b__z261, math.huge)
    end
    local tAngle = (angle264 * t262)
    local sinTA = math.sin(tAngle)
    local sinTOneMinusA = math.sin((angle264 - tAngle))
    local newDir__x271, newDir__y272, newDir__z273 = (function()
        local v__x268, v__y269, v__z270 = (function()
            local a__x265, a__y266, a__z267 = SF__.Vector3.op_Multiply__vector3f(normA__x, normA__y, normA__z, sinTOneMinusA)
            return SF__.Vector3.op_Addition(a__x265, a__y266, a__z267, SF__.Vector3.op_Multiply__vector3f(normB__x, normB__y, normB__z, sinTA))
        end)()
        return SF__.Vector3.op_Division(v__x268, v__y269, v__z270, sinAngle)
    end)()
    local newMag274 = math.lerp(magA, magB, t262)
    return SF__.Vector3.op_Multiply__vector3f(newDir__x271, newDir__y272, newDir__z273, newMag274)
end

function SF__.Vector3._getTerrainZ(x275, y276)
    MoveLocation(SF__.Vector3._loc, x275, y276)
    return GetLocationZ(SF__.Vector3._loc)
end

function SF__.Vector3.FromUnit(u277)
    local x278 = GetUnitX(u277)
    local y279 = GetUnitY(u277)
    return x278, y279, (SF__.Vector3._getTerrainZ(x278, y279) + GetUnitFlyHeight(u277))
end

function SF__.Vector3.get_sqrMagnitude(self__x280, self__y281, self__z282)
    return (((self__x280 * self__x280) + (self__y281 * self__y281)) + (self__z282 * self__z282))
end

function SF__.Vector3.get_magnitude(self__x283, self__y284, self__z285)
    return math.sqrt(SF__.Vector3.get_sqrMagnitude(self__x283, self__y284, self__z285))
end

function SF__.Vector3.get_normalized(self__x286, self__y287, self__z288)
    local mag289 = SF__.Vector3.get_magnitude(self__x286, self__y287, self__z288)
    if (mag289 < 0.0001) then
        return SF__.Vector3.get_zero()
    end
    return SF__.Vector3.op_Division(self__x286, self__y287, self__z288, mag289)
end

function SF__.Vector3.ClampMagnitude(self__x293, self__y294, self__z295, mag296)
    return (function()
        local v__x297, v__y298, v__z299 = SF__.Vector3.get_normalized(self__x293, self__y294, self__z295)
        return SF__.Vector3.op_Multiply__vector3f(v__x297, v__y298, v__z299, mag296)
    end)()
end

function SF__.Vector3.Equals(self__x300, self__y301, self__z302, other__x303, other__y304, other__z305)
    return SF__.Vector3.op_Equality(self__x300, self__y301, self__z302, other__x303, other__y304, other__z305)
end

function SF__.Vector3.ToString(self__x306, self__y307, self__z308)
    return SF__.StrConcat__("(", self__x306, ", ", self__y307, ", ", self__z308, ")")
end

function SF__.Vector3.UnitMoveTo(self__x309, self__y310, self__z311, u312, mode)
    if mode == nil then mode = SF__.UnitVec3Mode.Auto end
    local tz = SF__.Vector3._getTerrainZ(self__x309, self__y310)
    local LuaUtils = require("Lib.Utils")
    local defaultFlyHeight = GetUnitDefaultFlyHeight(u312)
    local minZ = (tz + defaultFlyHeight)
    SetUnitPosition(u312, self__x309, self__y310)
    repeat
        local switchValue = mode
        if (switchValue == SF__.UnitVec3Mode.ForceFlying) then
            LuaUtils.SetUnitFlyable(u312)
            SetUnitFlyHeight(u312, (math.max(minZ, self__z311) - minZ), 0)
            break
        elseif (switchValue == SF__.UnitVec3Mode.ForceGround) then
            SetUnitFlyHeight(u312, defaultFlyHeight, 0)
            break
        elseif (switchValue == SF__.UnitVec3Mode.Auto) then
            if IsUnitType(u312, UNIT_TYPE_FLYING) then
                SetUnitFlyHeight(u312, (math.max(minZ, self__z311) - minZ), 0)
            else
                SetUnitFlyHeight(u312, defaultFlyHeight, 0)
            end
            break
        end
    until true
end

function SF__.Vector3.GetTerrainZ(self__x313, self__y314, self__z315)
    return SF__.Vector3._getTerrainZ(self__x313, self__y314)
end

SF__.Vector3._loc = Location(0, 0)
-- WordOfGlory
SF__.WordOfGlory = SF__.WordOfGlory or {}
SF__.WordOfGlory.Name = "WordOfGlory"
SF__.WordOfGlory.FullName = "WordOfGlory"
function SF__.WordOfGlory.Init()
    local EventCenter439 = require("Lib.EventCenter")
    EventCenter439.RegisterPlayerUnitSpellChannel:Emit({id = SF__.WordOfGlory.ID, handler = SF__.WordOfGlory.Check})
    EventCenter439.RegisterPlayerUnitSpellEffect:Emit({id = SF__.WordOfGlory.ID, handler = SF__.WordOfGlory.Start})
    ExTriggerRegisterNewUnit(function(u440)
        if (GetUnitTypeId(u440) == FourCC("Hpal")) then
            SF__.WordOfGlory.UpdateAbilityMeta(u440)
        end
    end)
end

function SF__.WordOfGlory.Check(data441)
    local UnitAttribute443 = require("Objects.UnitAttribute")
    local attr442 = UnitAttribute443.GetAttr(data441.caster)
    if (attr442.retPalHolyEnergy < 3) then
        IssueImmediateOrderById(data441.caster, SF__.ConstOrderId.Stop)
        ExTextState(data441.caster, "圣能不足")
    end
end

function SF__.WordOfGlory.UpdateAbilityMeta(u444)
    local p445 = GetOwningPlayer(u444)
    SF__.Utils.ExSetAbilityResearchTooltip(p445, SF__.WordOfGlory.ID, "学习圣殿骑士的裁决 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p445, SF__.WordOfGlory.ID, "圣殿骑士的裁决造成一次攻击伤害，如果目标被审判，造成30%的额外伤害，15%几率重置审判。消耗|cffff8c003|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 5秒\r\n\r\n|cffffcc001级|r - |cffff8c00100%|r的攻击伤害，100%的战争艺术触发几率。", 0)
    do
        local i446 = 0
        while (i446 < 1) do
            SF__.Utils.ExBlzSetAbilityTooltip(p445, SF__.WordOfGlory.ID, SF__.StrConcat__("圣殿骑士的裁决 - [|cffffcc00", (i446 + 1), "级|r]"), i446)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p445, SF__.WordOfGlory.ID, "圣殿骑士的裁决造成一次攻击伤害，造成|cffff8c00100%|r的攻击伤害。消耗|cffff8c003|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 5秒", i446)
            ::continue::
            i446 = (i446 + 1)
        end
    end
end

function SF__.WordOfGlory.Start(data447)
    local UnitAttribute449 = require("Objects.UnitAttribute")
    local EventCenter450 = require("Lib.EventCenter")
    local attr448 = UnitAttribute449.GetAttr(data447.caster)
    EventCenter450.Heal:Emit({caster = data447.caster, target = data447.target, amount = 300})
    attr448.retPalHolyEnergy = (attr448.retPalHolyEnergy - 3)
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
