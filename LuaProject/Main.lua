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
    local globalPos__x, globalPos__y, globalPos__z = self.gameObject.transform.position__x, self.gameObject.transform.position__y, self.gameObject.transform.position__z
    local globalRot__x, globalRot__y, globalRot__z, globalRot__w = self.gameObject.transform.rotation__x, self.gameObject.transform.rotation__y, self.gameObject.transform.rotation__z, self.gameObject.transform.rotation__w
    local globalScale__x, globalScale__y, globalScale__z = self.gameObject.transform.localScale__x, self.gameObject.transform.localScale__y, self.gameObject.transform.localScale__z
    local parent = self.gameObject.transform.parent
    while (parent ~= nil) do
        globalPos__x, globalPos__y, globalPos__z = SF__.Vector3.op_Addition(parent.position__x, parent.position__y, parent.position__z, SF__.Quaternion.op_Multiply__quaternionvector3(parent.rotation__x, parent.rotation__y, parent.rotation__z, parent.rotation__w, SF__.Vector3.Scale(parent.localScale__x, parent.localScale__y, parent.localScale__z, globalPos__x, globalPos__y, globalPos__z)))
        globalRot__x, globalRot__y, globalRot__z, globalRot__w = SF__.Quaternion.op_Multiply__quaternionquaternion(parent.rotation__x, parent.rotation__y, parent.rotation__z, parent.rotation__w, globalRot__x, globalRot__y, globalRot__z, globalRot__w)
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
-- BladeOfJustice
SF__.BladeOfJustice = SF__.BladeOfJustice or {}
SF__.BladeOfJustice.Name = "BladeOfJustice"
SF__.BladeOfJustice.FullName = "BladeOfJustice"
function SF__.BladeOfJustice.GetAbilityData(level301)
    return (75 * level301), 5, (10 * level301)
end

function SF__.BladeOfJustice.Init()
    local EventCenter = require("Lib.EventCenter")
    EventCenter.RegisterPlayerUnitSpellEffect:Emit({id = SF__.BladeOfJustice.ID, handler = SF__.BladeOfJustice.Start})
    ExTriggerRegisterNewUnit(function(u302)
        if (GetUnitTypeId(u302) == FourCC("Hpal")) then
            SF__.BladeOfJustice.UpdateAbilityMeta(u302)
        end
    end)
end

function SF__.BladeOfJustice.UpdateAbilityMeta(u303)
    local p304 = GetOwningPlayer(u303)
    local datas__Damage, datas__Duration, datas__DamagePerSecond = {}, {}, {}
    do
        local i305 = 0
        while (i305 < 3) do
            do
                local item__Damage, item__Duration, item__DamagePerSecond = SF__.BladeOfJustice.GetAbilityData((i305 + 1))
                table.insert(datas__Damage, item__Damage)
                table.insert(datas__Duration, item__Duration)
                table.insert(datas__DamagePerSecond, item__DamagePerSecond)
            end
            ::continue::
            i305 = (i305 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p304, SF__.BladeOfJustice.ID, "学习公正之剑 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p304, SF__.BladeOfJustice.ID, SF__.StrConcat__("用圣光的利刃刺穿目标，造成法术伤害，在一定时间内对附近敌人每秒造成光辉伤害。产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 10秒\n\n|cffffcc001级|r - 造成|cffff8c00", datas__Damage[(0 + 1)], "|r的直接法术伤害，|cffff8c00", datas__Duration[(0 + 1)], "|r秒内对附近敌人每秒造成|cffff8c00", datas__DamagePerSecond[(0 + 1)], "|r的光辉伤害。产生|cffff8c001|r点圣能。\n|cffffcc002级|r - 造成|cffff8c00", datas__Damage[(1 + 1)], "|r的直接法术伤害，|cffff8c00", datas__Duration[(1 + 1)], "|r秒内对附近敌人每秒造成|cffff8c00", datas__DamagePerSecond[(1 + 1)], "|r的光辉伤害。产生|cffff8c001|r点圣能。\n|cffffcc003级|r - 造成|cffff8c00", datas__Damage[(2 + 1)], "|r的直接法术伤害，|cffff8c00", datas__Duration[(2 + 1)], "|r秒内对附近敌人每秒造成|cffff8c00", datas__DamagePerSecond[(2 + 1)], "|r的光辉伤害。产生|cffff8c001|r点圣能。"), 0)
    do
        local i306 = 0
        while (i306 < 3) do
            local data__Damage, data__Duration, data__DamagePerSecond = datas__Damage[(i306 + 1)], datas__Duration[(i306 + 1)], datas__DamagePerSecond[(i306 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p304, SF__.BladeOfJustice.ID, SF__.StrConcat__("公正之剑 - [|cffffcc00", (i306 + 1), "级|r]"), i306)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p304, SF__.BladeOfJustice.ID, SF__.StrConcat__("用圣光的利刃刺穿目标，造成|cffff8c00", data__Damage, "|r的直接法术伤害，在|cffff8c00", data__Duration, "|r秒内对附近敌人每秒造成|cffff8c00", data__DamagePerSecond, "|r的光辉伤害。产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 10秒"), i306)
            ::continue::
            i306 = (i306 + 1)
        end
    end
end

function SF__.BladeOfJustice.Start(data)
    local level307 = GetUnitAbilityLevel(data.caster, SF__.BladeOfJustice.ID)
    local EventCenter308 = require("Lib.EventCenter")
    local ad__Damage, ad__Duration, ad__DamagePerSecond = SF__.BladeOfJustice.GetAbilityData(level307)
    EventCenter308.Damage:Emit({whichUnit = data.caster, target = data.target, amount = ad__Damage, attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
    SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(data.caster, 1)
    SF__.BladeOfJustice.New():StartGroudDamage(data.caster, data.target, ad__Damage, ad__Duration, ad__DamagePerSecond)
end

function SF__.BladeOfJustice:StartGroudDamage(caster, target, ad__Damage309, ad__Duration310, ad__DamagePerSecond311)
    return SF__.CorRun__(function()
        local pos__x, pos__y = SF__.Vector2.FromUnit(target)
        local UnitAttribute = require("Objects.UnitAttribute")
        local EventCenter315 = require("Lib.EventCenter")
        local eff = ExAddSpecialEffect("Abilities/Spells/Orc/LiquidFire/Liquidfire.mdl", pos__x, pos__y, ad__Duration310)
        local p312 = GetOwningPlayer(caster)
        do
            local i313 = 0
            while (i313 < ad__Duration310) do
                SF__.CorWait__(1000)
                ExGroupEnumUnitsInRange(pos__x, pos__y, 300, function(u314)
                    if (not IsUnitEnemy(u314, p312)) then
                        return
                    end
                    if ExIsUnitDead(u314) then
                        return
                    end
                    local tarAttr = UnitAttribute.GetAttr(u314)
                    local damage = (ad__DamagePerSecond311 * (1 - tarAttr.radiantResistance))
                    EventCenter315.Damage:Emit({whichUnit = caster, target = u314, amount = damage, attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
                end)
                ::continue::
                i313 = (i313 + 1)
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
function SF__.CrusaderStrike.GetAbilityData(level316)
    return (0.65 + (0.35 * level316)), (0.15 * (level316 - 1))
end

function SF__.CrusaderStrike.Init()
    local EventCenter317 = require("Lib.EventCenter")
    EventCenter317.RegisterPlayerUnitSpellEffect:Emit({id = SF__.CrusaderStrike.ID, handler = SF__.CrusaderStrike.Start})
    ExTriggerRegisterNewUnit(function(u318)
        if (GetUnitTypeId(u318) == FourCC("Hpal")) then
            SF__.CrusaderStrike.UpdateAbilityMeta(u318)
        end
    end)
end

function SF__.CrusaderStrike.UpdateAbilityMeta(u319)
    local p320 = GetOwningPlayer(u319)
    local datas__DamageScaling, datas__ArtOfWarChance = {}, {}
    do
        local i321 = 0
        while (i321 < 3) do
            do
                local item__DamageScaling, item__ArtOfWarChance = SF__.CrusaderStrike.GetAbilityData((i321 + 1))
                table.insert(datas__DamageScaling, item__DamageScaling)
                table.insert(datas__ArtOfWarChance, item__ArtOfWarChance)
            end
            ::continue::
            i321 = (i321 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p320, SF__.CrusaderStrike.ID, "学习十字军打击 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p320, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击造成一次攻击伤害，伤害系数随技能等级提升。产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 6秒\n\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling[(0 + 1)] * 100)), "%|r的攻击伤害。\n|cffffcc002级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling[(1 + 1)] * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas__ArtOfWarChance[(1 + 1)] * 100)), "%的战争艺术触发几率。\n|cffffcc003级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling[(2 + 1)] * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas__ArtOfWarChance[(2 + 1)] * 100)), "%的战争艺术触发几率。"), 0)
    do
        local i322 = 0
        while (i322 < 3) do
            local data__DamageScaling, data__ArtOfWarChance = datas__DamageScaling[(i322 + 1)], datas__ArtOfWarChance[(i322 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p320, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击 - [|cffffcc00", (i322 + 1), "级|r]"), i322)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p320, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击造成一次攻击伤害，造成|cffff8c00", string.format("%.0f", (data__DamageScaling * 100)), "%|r的攻击伤害", SF__.Ternary__((i322 > 0), SF__.StrConcat__("，", string.format("%.0f", (data__ArtOfWarChance * 100)), "%的战争艺术触发几率"), ""), "。产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 6秒"), i322)
            ::continue::
            i322 = (i322 + 1)
        end
    end
    -- datas.Remove(new IAbilityData { DamageScaling = 0.65f, ArtOfWarChance = 0 });
    do
        local index323 = 0
        table.remove(datas__DamageScaling, (index323 + 1))
        table.remove(datas__ArtOfWarChance, (index323 + 1))
    end
end

function SF__.CrusaderStrike.Start(data324)
    local level325 = GetUnitAbilityLevel(data324.caster, SF__.CrusaderStrike.ID)
    local UnitAttribute326 = require("Objects.UnitAttribute")
    local EventCenter328 = require("Lib.EventCenter")
    local ad__DamageScaling, ad__ArtOfWarChance = SF__.CrusaderStrike.GetAbilityData(level325)
    local attr = UnitAttribute326.GetAttr(data324.caster)
    local damage327 = (attr:SimAttack(UnitAttribute326.HeroAttributeType.Strength) * ad__DamageScaling)
    EventCenter328.Damage:Emit({whichUnit = data324.caster, target = data324.target, amount = damage327, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
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

function SF__.CrusaderStrike.IAbilityData.Equals(self__DamageScaling329, self__ArtOfWarChance330, other__DamageScaling, other__ArtOfWarChance)
    return ((math.abs((self__DamageScaling329 - other__DamageScaling)) < 0.0001) and (math.abs((self__ArtOfWarChance330 - other__ArtOfWarChance)) < 0.0001))
end

function SF__.CrusaderStrike.IAbilityData.GetHashValue(self__DamageScaling331, self__ArtOfWarChance332)
    return 0
end
-- DivineToll
SF__.DivineToll = SF__.DivineToll or {}
SF__.DivineToll.Name = "DivineToll"
SF__.DivineToll.FullName = "DivineToll"
function SF__.DivineToll.GetAbilityData(level333)
    return (2 + level333), (50 * level333), 0.1, 10
end

function SF__.DivineToll.Init()
    local EventCenter335 = require("Lib.EventCenter")
    EventCenter335.RegisterPlayerUnitSpellEffect:Emit({id = SF__.DivineToll.ID, handler = function(data334)
        SF__.DivineToll.Start(data334)
    end})
    ExTriggerRegisterNewUnit(function(u336)
        if (GetUnitTypeId(u336) == FourCC("Hpal")) then
            SF__.DivineToll.UpdateAbilityMeta(u336)
        end
    end)
end

function SF__.DivineToll.UpdateAbilityMeta(u337)
    local p338 = GetOwningPlayer(u337)
    local datas__TargetCount, datas__Damage339, datas__RadiantDmgAmp, datas__Duration340 = {}, {}, {}, {}
    do
        local i341 = 0
        while (i341 < 3) do
            do
                local item__TargetCount, item__Damage342, item__RadiantDmgAmp, item__Duration343 = SF__.DivineToll.GetAbilityData((i341 + 1))
                table.insert(datas__TargetCount, item__TargetCount)
                table.insert(datas__Damage339, item__Damage342)
                table.insert(datas__RadiantDmgAmp, item__RadiantDmgAmp)
                table.insert(datas__Duration340, item__Duration343)
            end
            ::continue::
            i341 = (i341 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p338, SF__.DivineToll.ID, "学习圣洁鸣钟 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p338, SF__.DivineToll.ID, SF__.StrConcat__("对附近的多个目标施展审判，造成法术伤害，然后神圣之锤环绕圣殿骑士，每次命中敌人使其受到的光辉伤害提高。每个审判产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 30秒\n\n|cffffcc001级|r - 审判最多|cffff8c00", datas__TargetCount[(0 + 1)], "|r个目标，造成|cffff8c00", datas__Damage339[(0 + 1)], "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas__RadiantDmgAmp[(0 + 1)] * 100)), "%|r的光辉易伤，持续|cffff8c00", datas__Duration340[(0 + 1)], "|r秒。\n|cffffcc002级|r - 审判最多|cffff8c00", datas__TargetCount[(1 + 1)], "|r个目标，造成|cffff8c00", datas__Damage339[(1 + 1)], "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas__RadiantDmgAmp[(1 + 1)] * 100)), "%|r的光辉易伤，持续|cffff8c00", datas__Duration340[(1 + 1)], "|r秒。\n|cffffcc003级|r - 审判最多|cffff8c00", datas__TargetCount[(2 + 1)], "|r个目标，造成|cffff8c00", datas__Damage339[(2 + 1)], "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas__RadiantDmgAmp[(2 + 1)] * 100)), "%|r的光辉易伤，持续|cffff8c00", datas__Duration340[(2 + 1)], "|r秒。"), 0)
    do
        local i344 = 0
        while (i344 < 3) do
            local data__TargetCount, data__Damage345, data__RadiantDmgAmp, data__Duration346 = datas__TargetCount[(i344 + 1)], datas__Damage339[(i344 + 1)], datas__RadiantDmgAmp[(i344 + 1)], datas__Duration340[(i344 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p338, SF__.DivineToll.ID, SF__.StrConcat__("圣洁鸣钟 - [|cffffcc00", (i344 + 1), "级|r]"), i344)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p338, SF__.DivineToll.ID, SF__.StrConcat__("对附近的最多|cffff8c00", data__TargetCount, "|r个目标施展审判，造成|cffff8c00", data__Damage345, "|r点法术伤害，然后神圣之锤环绕圣殿骑士，每次命中敌人使其受到的光辉伤害提高|cffff8c00", string.format("%.0f", (data__RadiantDmgAmp * 100)), "%|r，持续|cffff8c00", data__Duration346, "|r秒。每个审判产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 30秒"), i344)
            ::continue::
            i344 = (i344 + 1)
        end
    end
end

function SF__.DivineToll.Start(data347)
    return SF__.CorRun__(function()
        local pos__x348, pos__y349, pos__z = SF__.Vector3.FromUnit(data347.caster)
        local targets = SF__.Utils.CsGroupGetUnitsInRange(pos__x348, pos__y349, 600, function(u350)
            if (not IsUnitEnemy(u350, GetOwningPlayer(data347.caster))) then
                return false
            end
            if IsUnitType(u350, UNIT_TYPE_STRUCTURE) then
                return false
            end
            if ExIsUnitDead(u350) then
                return false
            end
            return true
        end)
        if (SF__.ListCount__(targets) == 0) then
            return
        end
        SF__.ListSort__(targets, function(a351, b352)
            local distA = SF__.Vector3.Distance(pos__x348, pos__y349, pos__z, SF__.Vector3.FromUnit(a351))
            local distB = SF__.Vector3.Distance(pos__x348, pos__y349, pos__z, SF__.Vector3.FromUnit(b352))
            return SF__.Ternary__((distA == distB), 0, SF__.Ternary__((distA < distB), (-1), 1))
        end)
        local outer = SF__.GameObject.New__s("DivineToll_Outer")
        outer.transform.position__x, outer.transform.position__y, outer.transform.position__z = 0, 0, 80
        local moveLayer353 = SF__.GameObject.New__sgameobject("MoveLayer", outer)
        moveLayer353.transform.position__x, moveLayer353.transform.position__y, moveLayer353.transform.position__z = pos__x348, pos__y349, pos__z
        local mtc = moveLayer353:AddComponent(SF__.MoveTowardsComponent)
        mtc.targetType = SF__.TargetType.Unit
        mtc.unitTarget = SF__.ListGet__(targets, 0)
        mtc.speed = 900
        mtc.lookAtTarget = true
        -- var attachedHoly2 = new GameObject("DivineToll_Holy", moveLayer);
        -- attachedHoly2.transform.position = new Vector3(20, 0, 0);
        -- var effHoly2 = AddSpecialEffect("Abilities/Weapons/FaerieDragonMissile/FaerieDragonMissile.mdl", pos.x, pos.y);
        -- attachedHoly2.AddComponent<AttachEffectComponent>().eff = effHoly2;
        local orientationFixLayer = SF__.GameObject.New__sgameobject("DivineToll_Bolt", moveLayer353)
        orientationFixLayer.transform.rotation__x, orientationFixLayer.transform.rotation__y, orientationFixLayer.transform.rotation__z, orientationFixLayer.transform.rotation__w = SF__.Quaternion.Euler(0, 90, 0)
        local selfRotLayer = SF__.GameObject.New__sgameobject("dt_hand", orientationFixLayer)
        local trs = selfRotLayer.transform
        local rot__x, rot__y, rot__z, rot__w = SF__.Quaternion.Euler((450 / 60), 0, 0)
        local boltMis = SF__.GameObject.New__sgameobject("dt_mis", selfRotLayer)
        boltMis.transform.position__x, boltMis.transform.position__y, boltMis.transform.position__z = 30, 0, 0
        boltMis.transform.localScale__x, boltMis.transform.localScale__y, boltMis.transform.localScale__z = 0.5, 0.5, 0.5
        local eff354 = AddSpecialEffect("Abilities/Spells/Human/StormBolt/StormBoltMissile.mdl", pos__x348, pos__y349)
        boltMis:AddComponent(SF__.AttachEffectComponent).eff = eff354
        local attachedHoly = SF__.GameObject.New__sgameobject("DivineToll_Holy", boltMis)
        attachedHoly.transform.position__x, attachedHoly.transform.position__y, attachedHoly.transform.position__z = 0, 0, 0
        local effHoly = AddSpecialEffect("Abilities/Weapons/FaerieDragonMissile/FaerieDragonMissile.mdl", pos__x348, pos__y349)
        attachedHoly:AddComponent(SF__.AttachEffectComponent).eff = effHoly
        while true do
            SF__.CorWait__(SF__.Scene.DT)
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
SF__.DivineToll.IAbilityData.Name = "IAbilityData"
SF__.DivineToll.IAbilityData.FullName = "DivineToll.IAbilityData"
function SF__.DivineToll.IAbilityData.Equals(self__TargetCount, self__Damage355, self__RadiantDmgAmp, self__Duration356, other__TargetCount, other__Damage357, other__RadiantDmgAmp, other__Duration358)
    return (((math.abs((self__Damage355 - other__Damage357)) < 0.0001) and (math.abs((self__Duration356 - other__Duration358)) < 0.0001)) and (math.abs((self__RadiantDmgAmp - other__RadiantDmgAmp)) < 0.0001))
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
    local currentPosition__x, currentPosition__y, currentPosition__z = self.gameObject.transform.position__x, self.gameObject.transform.position__y, self.gameObject.transform.position__z
    local targetPosition__x, targetPosition__y, targetPosition__z
    do
        if (self.targetType == SF__.TargetType.Unit) then
            targetPosition__x, targetPosition__y, targetPosition__z = SF__.Vector3.FromUnit(self.unitTarget)
        else
            targetPosition__x, targetPosition__y, targetPosition__z = self.pointTarget__x, self.pointTarget__y, self.pointTarget__z
        end
    end
    local moved__x, moved__y, moved__z = SF__.Vector3.MoveTowards(currentPosition__x, currentPosition__y, currentPosition__z, targetPosition__x, targetPosition__y, targetPosition__z, ((self.speed * SF__.Scene.DT) / 1000))
    self.gameObject.transform.position__x, self.gameObject.transform.position__y, self.gameObject.transform.position__z = moved__x, moved__y, moved__z
    if self.lookAtTarget then
        self.gameObject.transform.rotation__x, self.gameObject.transform.rotation__y, self.gameObject.transform.rotation__z, self.gameObject.transform.rotation__w = SF__.Quaternion.LookRotation__vector3(SF__.Vector3.op_Subtraction(targetPosition__x, targetPosition__y, targetPosition__z, currentPosition__x, currentPosition__y, currentPosition__z))
    end
    if (SF__.Vector3.op_Equality(moved__x, moved__y, moved__z, targetPosition__x, targetPosition__y, targetPosition__z) and (not self.hasArrived)) then
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
    return (function()
        local a__x43, a__y44, a__z45 = (function()
            local a__x40, a__y41, a__z42 = SF__.Vector3.op_Multiply__fvector3((2 * SF__.Vector3.Dot(u__x, u__y, u__z, v__x, v__y, v__z)), u__x, u__y, u__z)
            return SF__.Vector3.op_Addition(a__x40, a__y41, a__z42, SF__.Vector3.op_Multiply__fvector3(((s * s) - SF__.Vector3.Dot(u__x, u__y, u__z, u__x, u__y, u__z)), v__x, v__y, v__z))
        end)()
        return SF__.Vector3.op_Addition(a__x43, a__y44, a__z45, SF__.Vector3.op_Multiply__fvector3((2 * s), SF__.Vector3.Cross(u__x, u__y, u__z, v__x, v__y, v__z)))
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
        return SF__.Quaternion.get_Identity()
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
    local x46
    local y47
    local z
    local w
    local trace = ((m00 + m11) + m22)
    if (trace > 0) then
        local s48 = (math.sqrt((trace + 1)) * 2)
        w = (0.25 * s48)
        x46 = ((m21 - m12) / s48)
        y47 = ((m02 - m20) / s48)
        z = ((m10 - m01) / s48)
    elseif ((m00 > m11) and (m00 > m22)) then
        local s49 = (math.sqrt((((1 + m00) - m11) - m22)) * 2)
        w = ((m21 - m12) / s49)
        x46 = (0.25 * s49)
        y47 = ((m01 + m10) / s49)
        z = ((m02 + m20) / s49)
    else
        if (m11 > m22) then
            local s50 = (math.sqrt((((1 + m11) - m00) - m22)) * 2)
            w = ((m02 - m20) / s50)
            x46 = ((m01 + m10) / s50)
            y47 = (0.25 * s50)
            z = ((m12 + m21) / s50)
        else
            local s51 = (math.sqrt((((1 + m22) - m00) - m11)) * 2)
            w = ((m10 - m01) / s51)
            x46 = ((m02 + m20) / s51)
            y47 = ((m12 + m21) / s51)
            z = (0.25 * s51)
        end
    end
    return SF__.Quaternion.Normalize(x46, y47, z, w)
end

function SF__.Quaternion.LookRotation__vector3(forward__x52, forward__y53, forward__z54)
    return SF__.Quaternion.LookRotation__vector3vector3(forward__x52, forward__y53, forward__z54, SF__.Vector3.get_up())
end

function SF__.Quaternion.Normalize(q__x55, q__y56, q__z57, q__w58)
    local magnitude = math.sqrt(((((q__x55 * q__x55) + (q__y56 * q__y56)) + (q__z57 * q__z57)) + (q__w58 * q__w58)))
    if (magnitude < 0.0001) then
        return SF__.Quaternion.get_Identity()
    end
    return (q__x55 / magnitude), (q__y56 / magnitude), (q__z57 / magnitude), (q__w58 / magnitude)
end

function SF__.Quaternion.get_eulerAngles(self__x, self__y, self__z, self__w)
    -- https://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles#Source_Code_2
    local sinr_cosp = (2 * ((self__w * self__x) + (self__y * self__z)))
    local cosr_cosp = (1 - (2 * ((self__x * self__x) + (self__y * self__y))))
    local roll59 = math.atan2(sinr_cosp, cosr_cosp)
    local sinp = (2 * ((self__w * self__y) - (self__z * self__x)))
    local pitch60
    if (math.abs(sinp) >= 1) then
        pitch60 = ((math.sign(sinp) * math.pi) / 2)
        -- use 90 degrees if out of range
    else
        pitch60 = math.asin(sinp)
    end
    local siny_cosp = (2 * ((self__w * self__z) + (self__x * self__y)))
    local cosy_cosp = (1 - (2 * ((self__y * self__y) + (self__z * self__z))))
    local yaw61 = math.atan2(siny_cosp, cosy_cosp)
    return (pitch60 * bj_RADTODEG), (yaw61 * bj_RADTODEG), (roll59 * bj_RADTODEG)
end

function SF__.Quaternion.get_normalized(self__x62, self__y63, self__z64, self__w65)
    return SF__.Quaternion.Normalize(self__x62, self__y63, self__z64, self__w65)
end

function SF__.Quaternion.Equals(self__x70, self__y71, self__z72, self__w73, other__x, other__y, other__z, other__w)
    return ((((math.abs((self__x70 - other__x)) < 0.0001) and (math.abs((self__y71 - other__y)) < 0.0001)) and (math.abs((self__z72 - other__z)) < 0.0001)) and (math.abs((self__w73 - other__w)) < 0.0001))
end

function SF__.Quaternion.ToString(self__x74, self__y75, self__z76, self__w77)
    return SF__.StrConcat__("(", self__x74, ", ", self__y75, ", ", self__z76, ", ", self__w77, ")")
end

function SF__.Quaternion.ApplyToEffect(self__x78, self__y79, self__z80, self__w81, e)
    local angles__x, angles__y, angles__z = SF__.Quaternion.get_eulerAngles(self__x78, self__y79, self__z80, self__w81)
    BlzSetSpecialEffectOrientation(e, (angles__y * bj_DEGTORAD), (angles__x * bj_DEGTORAD), (angles__z * bj_DEGTORAD))
end
-- RetributionPaladinGlobal
SF__.RetributionPaladinGlobal = SF__.RetributionPaladinGlobal or {}
SF__.RetributionPaladinGlobal.Name = "RetributionPaladinGlobal"
SF__.RetributionPaladinGlobal.FullName = "RetributionPaladinGlobal"
function SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(u359, amount)
    local UnitAttribute361 = require("Objects.UnitAttribute")
    local attr360 = UnitAttribute361.GetAttr(u359)
    attr360.retPalHolyEnergy = math.min((attr360.retPalHolyEnergy + amount), 5)
end

function SF__.RetributionPaladinGlobal:Init()
    ExTriggerRegisterNewUnit(function(u362)
        if (GetUnitTypeId(u362) == FourCC("Hpal")) then
            SF__.ListAdd__(self._units, u362)
        end
    end)
    _ = self:Start()
end

function SF__.RetributionPaladinGlobal:Start()
    return SF__.CorRun__(function()
        local UnitAttribute365 = require("Objects.UnitAttribute")
        while true do
            do
                local collection16 = self._units
                for i17, u363 in SF__.ListIterate__(collection16) do
                    local attr364 = UnitAttribute365.GetAttr(u363)
                    ExSetUnitMana(u363, ((ExGetUnitMaxMana(u363) * attr364.retPalHolyEnergy) * 0.2))
                    if (attr364.retPalHolyEnergy >= 3) then
                        SF__.Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u363), FourCC("A006"), "ReplaceableTextures/CommandButtons/BTNinv_helmet_96.tga")
                    else
                        SF__.Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u363), FourCC("A006"), "ReplaceableTextures/PassiveButtons/PASBTNinv_helmet_96.tga")
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

function SF__.Scene:AddGameObject(obj13)
    SF__.ListAdd__(self.gameObjs, obj13)
end

function SF__.Scene:Run()
    return SF__.CorRun__(function()
        while true do
            SF__.CorWait__(SF__.Scene.DT)
            local rootObjs = SF__.ListNew__({})
            do
                local collection18 = self.gameObjs
                for i19, obj14 in SF__.ListIterate__(collection18) do
                    if (obj14.transform.parent == nil) then
                        SF__.ListAdd__(rootObjs, obj14)
                    end
                end
            end
            do
                local collection20 = rootObjs
                for i21, obj15 in SF__.ListIterate__(collection20) do
                    obj15:Update()
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
    local item82 = SF__.ListGet__(self._items, (SF__.ListCount__(self._items) - 1))
    SF__.ListRemoveAt__(self._items, (SF__.ListCount__(self._items) - 1))
    return item82
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
local SystemBase16 = require("System.SystemBase")
SF__.Systems.InspectorSystem = SF__.Systems.InspectorSystem or class("InspectorSystem", SystemBase16)
SF__.Systems.InspectorSystem.Name = "InspectorSystem"
SF__.Systems.InspectorSystem.FullName = "Systems.InspectorSystem"
SF__.Systems.InspectorSystem.__sf_base = SystemBase16
function SF__.Systems.InspectorSystem:Awake()
    self:CreateFrames()
    self:RefreshHierarchy()
    self:SelectFirstVisibleObject()
    self:SetPanelVisible(false)
end

function SF__.Systems.InspectorSystem:Update(dt17)
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
        local i18 = 0
        while (i18 < SF__.Systems.InspectorSystem.MaxHierarchyRows) do
            SF__.ListAdd__(self._hierarchyRows, self:CreateHierarchyRow(i18))
            ::continue::
            i18 = (i18 + 1)
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
    local y19 = ((-0.061) - (index * (SF__.Systems.InspectorSystem.RowHeight + SF__.Systems.InspectorSystem.RowGap)))
    local button = BlzCreateFrameByType("BUTTON", "FdfInspectorHierarchyRow", self._panel, "ScoreScreenTabButtonTemplate", index)
    BlzFrameSetPoint(button, FRAMEPOINT_TOPLEFT, self._panel, FRAMEPOINT_TOPLEFT, (SF__.Systems.InspectorSystem.Padding * 2), y19)
    BlzFrameSetSize(button, (SF__.Systems.InspectorSystem.LeftWidth - (SF__.Systems.InspectorSystem.Padding * 4)), SF__.Systems.InspectorSystem.RowHeight)
    local label20 = BlzCreateFrameByType("TEXT", "FdfInspectorHierarchyRowText", button, "", index)
    BlzFrameSetPoint(label20, FRAMEPOINT_TOPLEFT, button, FRAMEPOINT_TOPLEFT, 0.004, (-0.002))
    BlzFrameSetSize(label20, (SF__.Systems.InspectorSystem.LeftWidth - (SF__.Systems.InspectorSystem.Padding * 5)), (SF__.Systems.InspectorSystem.RowHeight - 0.003))
    BlzFrameSetEnable(label20, false)
    BlzFrameSetTextAlignment(label20, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_LEFT)
    BlzFrameSetText(label20, "")
    local row = SF__.Systems.InspectorSystem.HierarchyRow.New(button, label20)
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

function SF__.Systems.InspectorSystem:SelectRow(row21)
    if (row21.gameObject == nil) then
        return
    end
    self._selectedGameObject = row21.gameObject
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
        for i24, obj22 in SF__.ListIterate__(collection22) do
            if (obj22.transform.parent == nil) then
                self:AddHierarchyObject(obj22, 0)
            end
        end
    end
    do
        local i23 = 0
        while (i23 < SF__.ListCount__(self._hierarchyRows)) do
            local row24 = SF__.ListGet__(self._hierarchyRows, i23)
            if (i23 < SF__.ListCount__(self._visibleObjects)) then
                local obj25 = SF__.ListGet__(self._visibleObjects, i23)
                row24.gameObject = obj25
                row24.depth = self:GetDepth(obj25)
                self:SetRowLabel(row24, obj25.name, row24.depth)
                BlzFrameSetVisible(row24.button, self._isVisible)
            else
                row24.gameObject = nil
                BlzFrameSetVisible(row24.button, false)
            end
            ::continue::
            i23 = (i23 + 1)
        end
    end
    BlzFrameSetVisible(self._emptyText, (self._isVisible and (SF__.ListCount__(self._visibleObjects) == 0)))
    self._lastObjectCount = SF__.ListCount__(SF__.Scene.get_Instance().gameObjs)
    self:RefreshHierarchySelection()
end

function SF__.Systems.InspectorSystem:AddHierarchyObject(obj26, depth)
    if (SF__.ListCount__(self._visibleObjects) >= SF__.Systems.InspectorSystem.MaxHierarchyRows) then
        return
    end
    SF__.ListAdd__(self._visibleObjects, obj26)
    do
        local collection25 = obj26.transform.children
        for i26, child27 in SF__.ListIterate__(collection25) do
            self:AddHierarchyObject(child27.gameObject, (depth + 1))
        end
    end
end

function SF__.Systems.InspectorSystem:GetDepth(obj28)
    local depth29 = 0
    local parent30 = obj28.transform.parent
    while (parent30 ~= nil) do
        depth29 = (depth29 + 1)
        parent30 = parent30.parent
        ::continue::
    end
    return depth29
end

function SF__.Systems.InspectorSystem:SetRowLabel(row31, text32, depth33)
    BlzFrameClearAllPoints(row31.label)
    BlzFrameSetPoint(row31.label, FRAMEPOINT_TOPLEFT, row31.button, FRAMEPOINT_TOPLEFT, (0.004 + (depth33 * SF__.Systems.InspectorSystem.IndentWidth)), (-0.002))
    BlzFrameSetSize(row31.label, ((SF__.Systems.InspectorSystem.LeftWidth - (SF__.Systems.InspectorSystem.Padding * 5)) - (depth33 * SF__.Systems.InspectorSystem.IndentWidth)), (SF__.Systems.InspectorSystem.RowHeight - 0.003))
    BlzFrameSetText(row31.label, text32)
end

function SF__.Systems.InspectorSystem:RefreshHierarchySelection()
    do
        local collection27 = self._hierarchyRows
        for i28, row34 in SF__.ListIterate__(collection27) do
            local isSelected = ((row34.gameObject ~= nil) and (row34.gameObject == self._selectedGameObject))
            BlzFrameSetTextColor(row34.label, SF__.Ternary__(isSelected, BlzConvertColor(255, 255, 220, 80), BlzConvertColor(255, 230, 230, 230)))
        end
    end
end

function SF__.Systems.InspectorSystem:RefreshInspectorText()
    if (self._selectedGameObject == nil) then
        BlzFrameSetText(self._inspectorText, "")
        return
    end
    local text35 = SF__.StrConcat__(self._selectedGameObject.name, "\n")
    do
        local collection29 = self._selectedGameObject:get_components()
        for i30, component in SF__.ListIterate__(collection29) do
            text35 = SF__.StrConcat__(text35, "\n[", component.__sf_type.Name, "]")
            local inspectorText = component:GetInspectorText()
            if (inspectorText ~= "") then
                text35 = SF__.StrConcat__(text35, "\n", inspectorText)
            end
        end
    end
    BlzFrameSetText(self._inspectorText, text35)
end

function SF__.Systems.InspectorSystem:SceneContains(gameObject)
    do
        local collection31 = SF__.Scene.get_Instance().gameObjs
        for i32, obj36 in SF__.ListIterate__(collection31) do
            if (obj36 == gameObject) then
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
function SF__.Systems.InspectorSystem.HierarchyRow.__Init(self, button37, label38)
    self.__sf_type = SF__.Systems.InspectorSystem.HierarchyRow
    self.button = nil
    self.label = nil
    self.gameObject = nil
    self.depth = 0
    self.button = button37
    self.label = label38
end

function SF__.Systems.InspectorSystem.HierarchyRow.New(button37, label38)
    local self = setmetatable({}, { __index = SF__.Systems.InspectorSystem.HierarchyRow })
    SF__.Systems.InspectorSystem.HierarchyRow.__Init(self, button37, label38)
    return self
end
-- Systems.MeleeGameSystem
local SystemBase39 = require("System.SystemBase")
SF__.Systems.MeleeGameSystem = SF__.Systems.MeleeGameSystem or class("MeleeGameSystem", SystemBase39)
SF__.Systems.MeleeGameSystem.Name = "MeleeGameSystem"
SF__.Systems.MeleeGameSystem.FullName = "Systems.MeleeGameSystem"
SF__.Systems.MeleeGameSystem.__sf_base = SystemBase39
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
function SF__.TemplarStrikes.GetAbilityData(level366)
    return 2, (0.5 + (0.25 * level366)), (0.05 * level366)
end

function SF__.TemplarStrikes.Init()
    local EventCenter367 = require("Lib.EventCenter")
    EventCenter367.RegisterPlayerUnitSpellEffect:Emit({id = SF__.TemplarStrikes.ID, handler = SF__.TemplarStrikes.Start})
    ExTriggerRegisterNewUnit(function(u368)
        if (GetUnitTypeId(u368) == FourCC("Hpal")) then
            SF__.TemplarStrikes.UpdateAbilityMeta(u368)
            SetHeroLevel(u368, 10, true)
        end
    end)
    EventCenter367.RegisterPlayerUnitDamaged:Emit(function(caster369, target370, damage371, weapType, dmgType, isAttack)
        if (GetUnitAbilityLevel(caster369, SF__.TemplarStrikes.ID) <= 0) then
            return
        end
        if (not isAttack) then
            return
        end
        if (target370 == nil) then
            return
        end
        if ExIsUnitDead(target370) then
            return
        end
        SF__.TemplarStrikes.TryResetBOJ(caster369)
    end)
end

function SF__.TemplarStrikes.TryResetBOJ(caster372)
    local level373 = GetUnitAbilityLevel(caster372, SF__.TemplarStrikes.ID)
    local ad__AttackCount, ad__DamageScaling374, ad__ResetBOJChance = SF__.TemplarStrikes.GetAbilityData(level373)
    if (math.random() >= ad__ResetBOJChance) then
        return
    end
    BlzEndUnitAbilityCooldown(caster372, SF__.BladeOfJustice.ID)
    ExAddSpecialEffectTarget("Abilities/Spells/Items/AIam/AIamTarget.mdl", caster372, "origin", 0.3)
end

function SF__.TemplarStrikes.UpdateAbilityMeta(u375)
    local p376 = GetOwningPlayer(u375)
    local datas__AttackCount, datas__DamageScaling377, datas__ResetBOJChance = {}, {}, {}
    do
        local i378 = 0
        while (i378 < SF__.TemplarStrikes.MaxLevel) do
            do
                local item__AttackCount, item__DamageScaling379, item__ResetBOJChance = SF__.TemplarStrikes.GetAbilityData((i378 + 1))
                table.insert(datas__AttackCount, item__AttackCount)
                table.insert(datas__DamageScaling377, item__DamageScaling379)
                table.insert(datas__ResetBOJChance, item__ResetBOJChance)
            end
            ::continue::
            i378 = (i378 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p376, SF__.TemplarStrikes.ID, "学习圣殿骑士之击 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p376, SF__.TemplarStrikes.ID, SF__.StrConcat__("快速攻击目标|cffff8c00", datas__AttackCount[(0 + 1)], "|r次，第一次造成普通攻击伤害，第二次造成光辉伤害，有一定几率重置公正之剑的冷却时间，普通攻击也会触发。\n\n|cff99ccff冷却时间|r - 10秒\n\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling377[(0 + 1)] * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas__ResetBOJChance[(0 + 1)] * 100)), "%|r的几率重置公正之剑。\n|cffffcc002级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling377[(1 + 1)] * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas__ResetBOJChance[(1 + 1)] * 100)), "%|r的几率重置公正之剑。\n|cffffcc003级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling377[(2 + 1)] * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas__ResetBOJChance[(2 + 1)] * 100)), "%|r的几率重置公正之剑。"), 0)
    do
        local i380 = 0
        while (i380 < SF__.TemplarStrikes.MaxLevel) do
            local data__AttackCount, data__DamageScaling381, data__ResetBOJChance = datas__AttackCount[(i380 + 1)], datas__DamageScaling377[(i380 + 1)], datas__ResetBOJChance[(i380 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p376, SF__.TemplarStrikes.ID, SF__.StrConcat__("圣殿骑士之击 - [|cffffcc00", (i380 + 1), "级|r]"), i380)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p376, SF__.TemplarStrikes.ID, SF__.StrConcat__("快速攻击目标|cffff8c00", data__AttackCount, "|r次，第一次造成普通攻击伤害，第二次造成普通攻击|cffff8c00", string.format("%.0f", (data__DamageScaling381 * 100)), "%|r的光辉伤害，|cffff8c00", string.format("%.0f", (data__ResetBOJChance * 100)), "%|r几率重置公正之剑的冷却时间，普通攻击也会触发。\n\n|cff99ccff冷却时间|r - 10秒"), i380)
            ::continue::
            i380 = (i380 + 1)
        end
    end
end

function SF__.TemplarStrikes.Start(data382)
    return SF__.CorRun__(function()
        local level383 = GetUnitAbilityLevel(data382.caster, SF__.TemplarStrikes.ID)
        local UnitAttribute385 = require("Objects.UnitAttribute")
        local EventCenter386 = require("Lib.EventCenter")
        local attr384 = UnitAttribute385.GetAttr(data382.caster)
        local normalDamage = attr384:SimMeleeAttack()
        EventCenter386.Damage:Emit({whichUnit = data382.caster, target = data382.target, amount = normalDamage, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
        SF__.TemplarStrikes.TryResetBOJ(data382.caster)
        SetUnitTimeScale(data382.caster, 3)
        ResetUnitAnimation(data382.caster)
        SetUnitAnimation(data382.caster, "attack - 2")
        SF__.CorWait__(math.round(((1.166 * 0.33) * 1000)))
        local tarAttr387 = UnitAttribute385.GetAttr(data382.target)
        local ad__AttackCount388, ad__DamageScaling389, ad__ResetBOJChance390 = SF__.TemplarStrikes.GetAbilityData(level383)
        local radiantDamage = ((attr384:SimMeleeAttack() * ad__DamageScaling389) * (1 - tarAttr387.radiantResistance))
        EventCenter386.Damage:Emit({whichUnit = data382.caster, target = data382.target, amount = radiantDamage, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
        SF__.TemplarStrikes.TryResetBOJ(data382.caster)
        SetUnitTimeScale(data382.caster, 1)
        ResetUnitAnimation(data382.caster)
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
function SF__.TemplarStrikes.IAbilityData.Equals(self__AttackCount, self__DamageScaling391, self__ResetBOJChance, other__AttackCount, other__DamageScaling392, other__ResetBOJChance)
    return ((math.abs((self__DamageScaling391 - other__DamageScaling392)) < 0.0001) and (math.abs((self__ResetBOJChance - other__ResetBOJChance)) < 0.0001))
end
-- TemplarVerdict
SF__.TemplarVerdict = SF__.TemplarVerdict or {}
SF__.TemplarVerdict.Name = "TemplarVerdict"
SF__.TemplarVerdict.FullName = "TemplarVerdict"
function SF__.TemplarVerdict.GetAbilityData(level393)
    return 2.25, 0.3, 0.15
end

function SF__.TemplarVerdict.Init()
    local EventCenter394 = require("Lib.EventCenter")
    EventCenter394.RegisterPlayerUnitSpellChannel:Emit({id = SF__.TemplarVerdict.ID, handler = SF__.TemplarVerdict.Check})
    EventCenter394.RegisterPlayerUnitSpellEffect:Emit({id = SF__.TemplarVerdict.ID, handler = SF__.TemplarVerdict.Start})
    ExTriggerRegisterNewUnit(function(u395)
        if (GetUnitTypeId(u395) == FourCC("Hpal")) then
            SF__.TemplarVerdict.UpdateAbilityMeta(u395)
        end
    end)
end

function SF__.TemplarVerdict.Check(data396)
    local UnitAttribute398 = require("Objects.UnitAttribute")
    local attr397 = UnitAttribute398.GetAttr(data396.caster)
    if (attr397.retPalHolyEnergy < 3) then
        IssueImmediateOrderById(data396.caster, SF__.ConstOrderId.Stop)
        ExTextState(data396.caster, "圣能不足")
    end
end

function SF__.TemplarVerdict.UpdateAbilityMeta(u399)
    local p400 = GetOwningPlayer(u399)
    local datas__DamageScaling401, datas__JudgementDamageScaling, datas__ChanceToResetJudgement = {}, {}, {}
    do
        local i402 = 0
        while (i402 < 1) do
            do
                local item__DamageScaling403, item__JudgementDamageScaling, item__ChanceToResetJudgement = SF__.TemplarVerdict.GetAbilityData((i402 + 1))
                table.insert(datas__DamageScaling401, item__DamageScaling403)
                table.insert(datas__JudgementDamageScaling, item__JudgementDamageScaling)
                table.insert(datas__ChanceToResetJudgement, item__ChanceToResetJudgement)
            end
            ::continue::
            i402 = (i402 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p400, SF__.TemplarVerdict.ID, "学习圣殿骑士的裁决 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p400, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决造成一次攻击伤害，如果目标被审判，造成30%的额外伤害，15%几率重置审判。消耗|cffff8c003|r点圣能。\n\n|cff99ccff冷却时间|r - 5秒\n\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas__JudgementDamageScaling[(0 + 1)] * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas__ChanceToResetJudgement[(0 + 1)] * 100)), "%的战争艺术触发几率。"), 0)
    do
        local i404 = 0
        while (i404 < 1) do
            local data__DamageScaling405, data__JudgementDamageScaling, data__ChanceToResetJudgement = datas__DamageScaling401[(i404 + 1)], datas__JudgementDamageScaling[(i404 + 1)], datas__ChanceToResetJudgement[(i404 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p400, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决 - [|cffffcc00", (i404 + 1), "级|r]"), i404)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p400, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决造成一次攻击伤害，造成|cffff8c00", string.format("%.0f", (data__DamageScaling405 * 100)), "%|r的攻击伤害。消耗|cffff8c003|r点圣能。\n\n|cff99ccff冷却时间|r - 5秒"), i404)
            ::continue::
            i404 = (i404 + 1)
        end
    end
end

function SF__.TemplarVerdict.Start(data406)
    local level407 = GetUnitAbilityLevel(data406.caster, SF__.TemplarVerdict.ID)
    local UnitAttribute410 = require("Objects.UnitAttribute")
    local EventCenter412 = require("Lib.EventCenter")
    local ad__DamageScaling408, ad__JudgementDamageScaling, ad__ChanceToResetJudgement = SF__.TemplarVerdict.GetAbilityData(level407)
    local attr409 = UnitAttribute410.GetAttr(data406.caster)
    local damage411 = (attr409:SimAttack(UnitAttribute410.HeroAttributeType.Strength) * ad__DamageScaling408)
    EventCenter412.Damage:Emit({whichUnit = data406.caster, target = data406.target, amount = damage411, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_SLICE, outResult = {}})
    attr409.retPalHolyEnergy = (attr409.retPalHolyEnergy - 3)
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
function SF__.TemplarVerdict.IAbilityData.Equals(self__DamageScaling413, self__JudgementDamageScaling, self__ChanceToResetJudgement, other__DamageScaling414, other__JudgementDamageScaling, other__ChanceToResetJudgement)
    return ((math.abs((self__JudgementDamageScaling - other__JudgementDamageScaling)) < 0.0001) and (math.abs((self__ChanceToResetJudgement - other__ChanceToResetJudgement)) < 0.0001))
end
-- Transform
SF__.Transform = SF__.Transform or {}
SF__.Transform.Name = "Transform"
SF__.Transform.FullName = "Transform"
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

function SF__.Transform:GetInspectorText()
    return SF__.StrConcat__("Position: ", SF__.Vector3.ToString(self.position__x, self.position__y, self.position__z), "\n", "Rotation: ", SF__.Vector3.ToString(SF__.Quaternion.get_eulerAngles(self.rotation__x, self.rotation__y, self.rotation__z, self.rotation__w)), "\n", "Scale: ", SF__.Vector3.ToString(self.localScale__x, self.localScale__y, self.localScale__z), "\n", "Children: ", SF__.ListCount__(self.children))
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

function SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p83, abilCode84, researchExtendedTooltip, level85)
    if (GetLocalPlayer() ~= p83) then
        return
    end
    BlzSetAbilityResearchExtendedTooltip(abilCode84, researchExtendedTooltip, level85)
end

function SF__.Utils.ExBlzSetAbilityTooltip(p86, abilCode87, tooltip, level88)
    if (GetLocalPlayer() ~= p86) then
        return
    end
    BlzSetAbilityTooltip(abilCode87, tooltip, level88)
end

function SF__.Utils.ExBlzSetAbilityExtendedTooltip(p89, abilCode90, extendedTooltip, level91)
    if (GetLocalPlayer() ~= p89) then
        return
    end
    BlzSetAbilityExtendedTooltip(abilCode90, extendedTooltip, level91)
end

function SF__.Utils.ExBlzSetAbilityIcon(p92, abilCode93, iconPath)
    if (GetLocalPlayer() ~= p92) then
        return
    end
    BlzSetAbilityIcon(abilCode93, iconPath)
end

function SF__.Utils.CsGroupGetUnitsInRange(x94, y95, radius, filter)
    local result = SF__.ListNew__({})
    ExGroupEnumUnitsInRange(x94, y95, radius, function(u)
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

function SF__.Vector2.Dot(a__x96, a__y97, b__x98, b__y99)
    return ((a__x96 * b__x98) + (a__y97 * b__y99))
end

function SF__.Vector2.Cross(a__x100, a__y101, b__x102, b__y103)
    return ((a__y101 * b__x102) - (a__x100 * b__y103))
end

function SF__.Vector2.op_UnaryNegation(a__x104, a__y105)
    return (-a__x104), (-a__y105)
end

function SF__.Vector2.op_Addition(a__x106, a__y107, b__x108, b__y109)
    return (a__x106 + b__x108), (a__y107 + b__y109)
end

function SF__.Vector2.op_Subtraction(a__x110, a__y111, b__x112, b__y113)
    return (a__x110 - b__x112), (a__y111 - b__y113)
end

function SF__.Vector2.op_Multiply__vector2f(v__x114, v__y115, f)
    return (v__x114 * f), (v__y115 * f)
end

function SF__.Vector2.op_Multiply__fvector2(f116, v__x117, v__y118)
    return (v__x117 * f116), (v__y118 * f116)
end

function SF__.Vector2.op_Division(v__x119, v__y120, f121)
    return (v__x119 / f121), (v__y120 / f121)
end

function SF__.Vector2.op_Equality(a__x122, a__y123, b__x124, b__y125)
    return ((math.abs((a__x122 - b__x124)) < 0.0001) and (math.abs((a__y123 - b__y125)) < 0.0001))
end

function SF__.Vector2.op_Inequality(a__x126, a__y127, b__x128, b__y129)
    return (not SF__.Vector2.op_Equality(a__x126, a__y127, b__x128, b__y129))
end

function SF__.Vector2.UnitDistance(a, b)
    local v1__x, v1__y = SF__.Vector2.FromUnit(a)
    local v2__x, v2__y = SF__.Vector2.FromUnit(b)
    return SF__.Vector2.get_Magnitude(SF__.Vector2.op_Subtraction(v1__x, v1__y, v2__x, v2__y))
end

function SF__.Vector2.SqrUnitDistance(a130, b131)
    local v1__x132, v1__y133 = SF__.Vector2.FromUnit(a130)
    local v2__x134, v2__y135 = SF__.Vector2.FromUnit(b131)
    return SF__.Vector2.get_SqrMagnitude(SF__.Vector2.op_Subtraction(v1__x132, v1__y133, v2__x134, v2__y135))
end

function SF__.Vector2.FromUnit(u136)
    return GetUnitX(u136), GetUnitY(u136)
end

function SF__.Vector2.get_Magnitude(self__x137, self__y138)
    return math.sqrt(SF__.Vector2.get_SqrMagnitude(self__x137, self__y138))
end

function SF__.Vector2.get_SqrMagnitude(self__x139, self__y140)
    return ((self__x139 * self__x139) + (self__y140 * self__y140))
end

function SF__.Vector2.get_Normalized(self__x141, self__y142)
    local mag = SF__.Vector2.get_Magnitude(self__x141, self__y142)
    if (mag < 0.0001) then
        return SF__.Vector2.get_Zero()
    end
    return SF__.Vector2.op_Division(self__x141, self__y142, mag)
end

function SF__.Vector2.ClampMagnitude(self__x145, self__y146, mag147)
    return (function()
        local v__x148, v__y149 = SF__.Vector2.get_Normalized(self__x145, self__y146)
        return SF__.Vector2.op_Multiply__vector2f(v__x148, v__y149, mag147)
    end)()
end

function SF__.Vector2.Equals(self__x150, self__y151, other__x152, other__y153)
    return SF__.Vector2.op_Equality(self__x150, self__y151, other__x152, other__y153)
end

function SF__.Vector2.ToString(self__x154, self__y155)
    return SF__.StrConcat__("(", self__x154, ", ", self__y155, ")")
end

function SF__.Vector2.Rotate(self__x156, self__y157, angle158)
    local cos = math.cos(angle158)
    local sin = math.sin(angle158)
    return ((self__x156 * cos) - (self__y157 * sin)), ((self__x156 * sin) + (self__y157 * cos))
end

function SF__.Vector2.UnitMoveTo(self__x159, self__y160, u161)
    SetUnitX(u161, self__x159)
    SetUnitY(u161, self__y160)
end

function SF__.Vector2.GetTerrainZ(self__x162, self__y163)
    MoveLocation(SF__.Vector2._loc, self__x162, self__y163)
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

function SF__.Vector3.op_Addition(a__x164, a__y165, a__z166, b__x167, b__y168, b__z169)
    return (a__x164 + b__x167), (a__y165 + b__y168), (a__z166 + b__z169)
end

function SF__.Vector3.op_UnaryNegation(a__x170, a__y171, a__z172)
    return (-a__x170), (-a__y171), (-a__z172)
end

function SF__.Vector3.op_Subtraction(a__x173, a__y174, a__z175, b__x176, b__y177, b__z178)
    return (a__x173 - b__x176), (a__y174 - b__y177), (a__z175 - b__z178)
end

function SF__.Vector3.op_Multiply__vector3f(v__x179, v__y180, v__z181, f182)
    return (v__x179 * f182), (v__y180 * f182), (v__z181 * f182)
end

function SF__.Vector3.op_Multiply__fvector3(f183, v__x184, v__y185, v__z186)
    return (v__x184 * f183), (v__y185 * f183), (v__z186 * f183)
end

function SF__.Vector3.op_Division(v__x187, v__y188, v__z189, f190)
    return (v__x187 / f190), (v__y188 / f190), (v__z189 / f190)
end

function SF__.Vector3.op_Equality(a__x191, a__y192, a__z193, b__x194, b__y195, b__z196)
    return (((math.abs((a__x191 - b__x194)) < 0.0001) and (math.abs((a__y192 - b__y195)) < 0.0001)) and (math.abs((a__z193 - b__z196)) < 0.0001))
end

function SF__.Vector3.op_Inequality(a__x197, a__y198, a__z199, b__x200, b__y201, b__z202)
    return (not SF__.Vector3.op_Equality(a__x197, a__y198, a__z199, b__x200, b__y201, b__z202))
end

-- <summary>
-- Warcraft III world space here is right-handed: +x points right, +y points away, +z points up.
-- That means Cross((1,0,0), (0,1,0)) == (0,0,1).
-- </summary>
--
function SF__.Vector3.Cross(a__x203, a__y204, a__z205, b__x206, b__y207, b__z208)
    return ((a__y204 * b__z208) - (a__z205 * b__y207)), ((a__z205 * b__x206) - (a__x203 * b__z208)), ((a__x203 * b__y207) - (a__y204 * b__x206))
end

function SF__.Vector3.Distance(a__x209, a__y210, a__z211, b__x212, b__y213, b__z214)
    return SF__.Vector3.get_magnitude(SF__.Vector3.op_Subtraction(a__x209, a__y210, a__z211, b__x212, b__y213, b__z214))
end

function SF__.Vector3.Dot(a__x215, a__y216, a__z217, b__x218, b__y219, b__z220)
    return (((a__x215 * b__x218) + (a__y216 * b__y219)) + (a__z217 * b__z220))
end

function SF__.Vector3.MoveTowards(current__x, current__y, current__z, target__x, target__y, target__z, maxDistanceDelta)
    local toVector__x, toVector__y, toVector__z = SF__.Vector3.op_Subtraction(target__x, target__y, target__z, current__x, current__y, current__z)
    local dist = SF__.Vector3.get_magnitude(toVector__x, toVector__y, toVector__z)
    if ((dist <= maxDistanceDelta) or (dist == 0)) then
        return target__x, target__y, target__z
    end
    return SF__.Vector3.op_Addition(current__x, current__y, current__z, SF__.Vector3.op_Division(toVector__x, toVector__y, toVector__z, (dist / maxDistanceDelta)))
end

function SF__.Vector3.Project(v__x221, v__y222, v__z223, onNormal__x, onNormal__y, onNormal__z)
    local sqrMag = SF__.Vector3.Dot(onNormal__x, onNormal__y, onNormal__z, onNormal__x, onNormal__y, onNormal__z)
    if (sqrMag < 0.0001) then
        return SF__.Vector3.get_zero()
    end
    local dot = SF__.Vector3.Dot(v__x221, v__y222, v__z223, onNormal__x, onNormal__y, onNormal__z)
    return SF__.Vector3.op_Multiply__vector3f(onNormal__x, onNormal__y, onNormal__z, (dot / sqrMag))
end

function SF__.Vector3.ProjectOnPlane(v__x224, v__y225, v__z226, planeNormal__x, planeNormal__y, planeNormal__z)
    return SF__.Vector3.op_Subtraction(v__x224, v__y225, v__z226, SF__.Vector3.Project(v__x224, v__y225, v__z226, planeNormal__x, planeNormal__y, planeNormal__z))
end

function SF__.Vector3.Reflect(inDirection__x, inDirection__y, inDirection__z, inNormal__x, inNormal__y, inNormal__z)
    return SF__.Vector3.op_Subtraction(inDirection__x, inDirection__y, inDirection__z, SF__.Vector3.op_Multiply__fvector3((2 * SF__.Vector3.Dot(inDirection__x, inDirection__y, inDirection__z, inNormal__x, inNormal__y, inNormal__z)), inNormal__x, inNormal__y, inNormal__z))
end

function SF__.Vector3.RotateTowards(current__x227, current__y228, current__z229, target__x230, target__y231, target__z232, maxRadiansDelta, maxMagnitudeDelta)
    local currentMag = SF__.Vector3.get_magnitude(current__x227, current__y228, current__z229)
    local targetMag = SF__.Vector3.get_magnitude(target__x230, target__y231, target__z232)
    if ((currentMag == 0) or (targetMag == 0)) then
        return SF__.Vector3.MoveTowards(current__x227, current__y228, current__z229, target__x230, target__y231, target__z232, maxMagnitudeDelta)
    end
    local currentNorm__x, currentNorm__y, currentNorm__z = SF__.Vector3.op_Division(current__x227, current__y228, current__z229, currentMag)
    local targetNorm__x, targetNorm__y, targetNorm__z = SF__.Vector3.op_Division(target__x230, target__y231, target__z232, targetMag)
    local dot233 = math.clamp(SF__.Vector3.Dot(currentNorm__x, currentNorm__y, currentNorm__z, targetNorm__x, targetNorm__y, targetNorm__z), (-1), 1)
    local angle234 = math.acos(dot233)
    if (angle234 == 0) then
        return SF__.Vector3.MoveTowards(current__x227, current__y228, current__z229, target__x230, target__y231, target__z232, maxMagnitudeDelta)
    end
    local t = math.min(1, (maxRadiansDelta / angle234))
    local newDir__x, newDir__y, newDir__z = SF__.Vector3.Slerp(currentNorm__x, currentNorm__y, currentNorm__z, targetNorm__x, targetNorm__y, targetNorm__z, t)
    local newMag = math.moveTowards(currentMag, targetMag, maxMagnitudeDelta)
    return SF__.Vector3.op_Multiply__vector3f(newDir__x, newDir__y, newDir__z, newMag)
end

function SF__.Vector3.Scale(a__x235, a__y236, a__z237, b__x238, b__y239, b__z240)
    return (a__x235 * b__x238), (a__y236 * b__y239), (a__z237 * b__z240)
end

function SF__.Vector3.Slerp(a__x241, a__y242, a__z243, b__x244, b__y245, b__z246, t247)
    local magA = SF__.Vector3.get_magnitude(a__x241, a__y242, a__z243)
    local magB = SF__.Vector3.get_magnitude(b__x244, b__y245, b__z246)
    if ((magA == 0) or (magB == 0)) then
        return SF__.Vector3.MoveTowards(a__x241, a__y242, a__z243, b__x244, b__y245, b__z246, math.huge)
    end
    local normA__x, normA__y, normA__z = SF__.Vector3.op_Division(a__x241, a__y242, a__z243, magA)
    local normB__x, normB__y, normB__z = SF__.Vector3.op_Division(b__x244, b__y245, b__z246, magB)
    local dot248 = math.clamp(SF__.Vector3.Dot(normA__x, normA__y, normA__z, normB__x, normB__y, normB__z), (-1), 1)
    local angle249 = math.acos(dot248)
    local sinAngle = math.sin(angle249)
    if (sinAngle < 0.0001) then
        return SF__.Vector3.MoveTowards(a__x241, a__y242, a__z243, b__x244, b__y245, b__z246, math.huge)
    end
    local tAngle = (angle249 * t247)
    local sinTA = math.sin(tAngle)
    local sinTOneMinusA = math.sin((angle249 - tAngle))
    local newDir__x256, newDir__y257, newDir__z258 = (function()
        local v__x253, v__y254, v__z255 = (function()
            local a__x250, a__y251, a__z252 = SF__.Vector3.op_Multiply__vector3f(normA__x, normA__y, normA__z, sinTOneMinusA)
            return SF__.Vector3.op_Addition(a__x250, a__y251, a__z252, SF__.Vector3.op_Multiply__vector3f(normB__x, normB__y, normB__z, sinTA))
        end)()
        return SF__.Vector3.op_Division(v__x253, v__y254, v__z255, sinAngle)
    end)()
    local newMag259 = math.lerp(magA, magB, t247)
    return SF__.Vector3.op_Multiply__vector3f(newDir__x256, newDir__y257, newDir__z258, newMag259)
end

function SF__.Vector3._getTerrainZ(x260, y261)
    MoveLocation(SF__.Vector3._loc, x260, y261)
    return GetLocationZ(SF__.Vector3._loc)
end

function SF__.Vector3.FromUnit(u262)
    local x263 = GetUnitX(u262)
    local y264 = GetUnitY(u262)
    return x263, y264, (SF__.Vector3._getTerrainZ(x263, y264) + GetUnitFlyHeight(u262))
end

function SF__.Vector3.get_sqrMagnitude(self__x265, self__y266, self__z267)
    return (((self__x265 * self__x265) + (self__y266 * self__y266)) + (self__z267 * self__z267))
end

function SF__.Vector3.get_magnitude(self__x268, self__y269, self__z270)
    return math.sqrt(SF__.Vector3.get_sqrMagnitude(self__x268, self__y269, self__z270))
end

function SF__.Vector3.get_normalized(self__x271, self__y272, self__z273)
    local mag274 = SF__.Vector3.get_magnitude(self__x271, self__y272, self__z273)
    if (mag274 < 0.0001) then
        return SF__.Vector3.get_zero()
    end
    return SF__.Vector3.op_Division(self__x271, self__y272, self__z273, mag274)
end

function SF__.Vector3.ClampMagnitude(self__x278, self__y279, self__z280, mag281)
    return (function()
        local v__x282, v__y283, v__z284 = SF__.Vector3.get_normalized(self__x278, self__y279, self__z280)
        return SF__.Vector3.op_Multiply__vector3f(v__x282, v__y283, v__z284, mag281)
    end)()
end

function SF__.Vector3.Equals(self__x285, self__y286, self__z287, other__x288, other__y289, other__z290)
    return SF__.Vector3.op_Equality(self__x285, self__y286, self__z287, other__x288, other__y289, other__z290)
end

function SF__.Vector3.ToString(self__x291, self__y292, self__z293)
    return SF__.StrConcat__("(", self__x291, ", ", self__y292, ", ", self__z293, ")")
end

function SF__.Vector3.UnitMoveTo(self__x294, self__y295, self__z296, u297, mode)
    if mode == nil then mode = SF__.UnitVec3Mode.Auto end
    local tz = SF__.Vector3._getTerrainZ(self__x294, self__y295)
    local LuaUtils = require("Lib.Utils")
    local defaultFlyHeight = GetUnitDefaultFlyHeight(u297)
    local minZ = (tz + defaultFlyHeight)
    SetUnitPosition(u297, self__x294, self__y295)
    repeat
        local switchValue = mode
        if (switchValue == SF__.UnitVec3Mode.ForceFlying) then
            LuaUtils.SetUnitFlyable(u297)
            SetUnitFlyHeight(u297, (math.max(minZ, self__z296) - minZ), 0)
            break
        elseif (switchValue == SF__.UnitVec3Mode.ForceGround) then
            SetUnitFlyHeight(u297, defaultFlyHeight, 0)
            break
        elseif (switchValue == SF__.UnitVec3Mode.Auto) then
            if IsUnitType(u297, UNIT_TYPE_FLYING) then
                SetUnitFlyHeight(u297, (math.max(minZ, self__z296) - minZ), 0)
            else
                SetUnitFlyHeight(u297, defaultFlyHeight, 0)
            end
            break
        end
    until true
end

function SF__.Vector3.GetTerrainZ(self__x298, self__y299, self__z300)
    return SF__.Vector3._getTerrainZ(self__x298, self__y299)
end

SF__.Vector3._loc = Location(0, 0)
-- WordOfGlory
SF__.WordOfGlory = SF__.WordOfGlory or {}
SF__.WordOfGlory.Name = "WordOfGlory"
SF__.WordOfGlory.FullName = "WordOfGlory"
function SF__.WordOfGlory.Init()
    local EventCenter415 = require("Lib.EventCenter")
    EventCenter415.RegisterPlayerUnitSpellChannel:Emit({id = SF__.WordOfGlory.ID, handler = SF__.WordOfGlory.Check})
    EventCenter415.RegisterPlayerUnitSpellEffect:Emit({id = SF__.WordOfGlory.ID, handler = SF__.WordOfGlory.Start})
    ExTriggerRegisterNewUnit(function(u416)
        if (GetUnitTypeId(u416) == FourCC("Hpal")) then
            SF__.WordOfGlory.UpdateAbilityMeta(u416)
        end
    end)
end

function SF__.WordOfGlory.Check(data417)
    local UnitAttribute419 = require("Objects.UnitAttribute")
    local attr418 = UnitAttribute419.GetAttr(data417.caster)
    if (attr418.retPalHolyEnergy < 3) then
        IssueImmediateOrderById(data417.caster, SF__.ConstOrderId.Stop)
        ExTextState(data417.caster, "圣能不足")
    end
end

function SF__.WordOfGlory.UpdateAbilityMeta(u420)
    local p421 = GetOwningPlayer(u420)
    SF__.Utils.ExSetAbilityResearchTooltip(p421, SF__.WordOfGlory.ID, "学习圣殿骑士的裁决 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p421, SF__.WordOfGlory.ID, "圣殿骑士的裁决造成一次攻击伤害，如果目标被审判，造成30%的额外伤害，15%几率重置审判。消耗|cffff8c003|r点圣能。\n\n|cff99ccff冷却时间|r - 5秒\n\n|cffffcc001级|r - |cffff8c00100%|r的攻击伤害，100%的战争艺术触发几率。", 0)
    do
        local i422 = 0
        while (i422 < 1) do
            SF__.Utils.ExBlzSetAbilityTooltip(p421, SF__.WordOfGlory.ID, SF__.StrConcat__("圣殿骑士的裁决 - [|cffffcc00", (i422 + 1), "级|r]"), i422)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p421, SF__.WordOfGlory.ID, "圣殿骑士的裁决造成一次攻击伤害，造成|cffff8c00100%|r的攻击伤害。消耗|cffff8c003|r点圣能。\n\n|cff99ccff冷却时间|r - 5秒", i422)
            ::continue::
            i422 = (i422 + 1)
        end
    end
end

function SF__.WordOfGlory.Start(data423)
    local UnitAttribute425 = require("Objects.UnitAttribute")
    local EventCenter426 = require("Lib.EventCenter")
    local attr424 = UnitAttribute425.GetAttr(data423.caster)
    EventCenter426.Heal:Emit({caster = data423.caster, target = data423.target, amount = 300})
    attr424.retPalHolyEnergy = (attr424.retPalHolyEnergy - 3)
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
