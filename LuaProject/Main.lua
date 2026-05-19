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
function SF__.BladeOfJustice.GetAbilityData(level247)
    return (75 * level247), 5, (10 * level247)
end

function SF__.BladeOfJustice.Init()
    local EventCenter = require("Lib.EventCenter")
    EventCenter.RegisterPlayerUnitSpellEffect:Emit({id = SF__.BladeOfJustice.ID, handler = SF__.BladeOfJustice.Start})
    ExTriggerRegisterNewUnit(function(u248)
        if (GetUnitTypeId(u248) == FourCC("Hpal")) then
            SF__.BladeOfJustice.UpdateAbilityMeta(u248)
        end
    end)
end

function SF__.BladeOfJustice.UpdateAbilityMeta(u249)
    local p250 = GetOwningPlayer(u249)
    local datas__Damage, datas__Duration, datas__DamagePerSecond = {}, {}, {}
    do
        local i251 = 0
        while (i251 < 3) do
            do
                local item__Damage, item__Duration, item__DamagePerSecond = SF__.BladeOfJustice.GetAbilityData((i251 + 1))
                table.insert(datas__Damage, item__Damage)
                table.insert(datas__Duration, item__Duration)
                table.insert(datas__DamagePerSecond, item__DamagePerSecond)
            end
            ::continue::
            i251 = (i251 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p250, SF__.BladeOfJustice.ID, "学习公正之剑 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p250, SF__.BladeOfJustice.ID, SF__.StrConcat__("用圣光的利刃刺穿目标，造成法术伤害，在一定时间内对附近敌人每秒造成光辉伤害。产生|cffff8c001|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 10秒\r\n\r\n|cffffcc001级|r - 造成|cffff8c00", datas__Damage[(0 + 1)], "|r的直接法术伤害，|cffff8c00", datas__Duration[(0 + 1)], "|r秒内对附近敌人每秒造成|cffff8c00", datas__DamagePerSecond[(0 + 1)], "|r的光辉伤害。产生|cffff8c001|r点圣能。\r\n|cffffcc002级|r - 造成|cffff8c00", datas__Damage[(1 + 1)], "|r的直接法术伤害，|cffff8c00", datas__Duration[(1 + 1)], "|r秒内对附近敌人每秒造成|cffff8c00", datas__DamagePerSecond[(1 + 1)], "|r的光辉伤害。产生|cffff8c001|r点圣能。\r\n|cffffcc003级|r - 造成|cffff8c00", datas__Damage[(2 + 1)], "|r的直接法术伤害，|cffff8c00", datas__Duration[(2 + 1)], "|r秒内对附近敌人每秒造成|cffff8c00", datas__DamagePerSecond[(2 + 1)], "|r的光辉伤害。产生|cffff8c001|r点圣能。"), 0)
    do
        local i252 = 0
        while (i252 < 3) do
            local data__Damage, data__Duration, data__DamagePerSecond = datas__Damage[(i252 + 1)], datas__Duration[(i252 + 1)], datas__DamagePerSecond[(i252 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p250, SF__.BladeOfJustice.ID, SF__.StrConcat__("公正之剑 - [|cffffcc00", (i252 + 1), "级|r]"), i252)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p250, SF__.BladeOfJustice.ID, SF__.StrConcat__("用圣光的利刃刺穿目标，造成|cffff8c00", data__Damage, "|r的直接法术伤害，在|cffff8c00", data__Duration, "|r秒内对附近敌人每秒造成|cffff8c00", data__DamagePerSecond, "|r的光辉伤害。产生|cffff8c001|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 10秒"), i252)
            ::continue::
            i252 = (i252 + 1)
        end
    end
end

function SF__.BladeOfJustice.Start(data)
    local level253 = GetUnitAbilityLevel(data.caster, SF__.BladeOfJustice.ID)
    local EventCenter254 = require("Lib.EventCenter")
    local ad__Damage, ad__Duration, ad__DamagePerSecond = SF__.BladeOfJustice.GetAbilityData(level253)
    EventCenter254.Damage:Emit({whichUnit = data.caster, target = data.target, amount = ad__Damage, attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
    SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(data.caster, 1)
    SF__.BladeOfJustice.New():StartGroudDamage(data.caster, data.target, ad__Damage, ad__Duration, ad__DamagePerSecond)
end

function SF__.BladeOfJustice:StartGroudDamage(caster, target, ad__Damage255, ad__Duration256, ad__DamagePerSecond257)
    return SF__.CorRun__(function()
        local pos__x, pos__y = SF__.Vector2.FromUnit(target)
        local UnitAttribute = require("Objects.UnitAttribute")
        local EventCenter261 = require("Lib.EventCenter")
        local eff = ExAddSpecialEffect("Abilities/Spells/Orc/LiquidFire/Liquidfire.mdl", pos__x, pos__y, ad__Duration256)
        local p258 = GetOwningPlayer(caster)
        do
            local i259 = 0
            while (i259 < ad__Duration256) do
                SF__.CorWait__(1000)
                ExGroupEnumUnitsInRange(pos__x, pos__y, 300, function(u260)
                    if (not IsUnitEnemy(u260, p258)) then
                        return
                    end
                    if ExIsUnitDead(u260) then
                        return
                    end
                    local tarAttr = UnitAttribute.GetAttr(u260)
                    local damage = (ad__DamagePerSecond257 * (1 - tarAttr.radiantResistance))
                    EventCenter261.Damage:Emit({whichUnit = caster, target = u260, amount = damage, attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
                end)
                ::continue::
                i259 = (i259 + 1)
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
function SF__.CrusaderStrike.GetAbilityData(level262)
    return (0.65 + (0.35 * level262)), (0.15 * (level262 - 1))
end

function SF__.CrusaderStrike.Init()
    local EventCenter263 = require("Lib.EventCenter")
    EventCenter263.RegisterPlayerUnitSpellEffect:Emit({id = SF__.CrusaderStrike.ID, handler = SF__.CrusaderStrike.Start})
    ExTriggerRegisterNewUnit(function(u264)
        if (GetUnitTypeId(u264) == FourCC("Hpal")) then
            SF__.CrusaderStrike.UpdateAbilityMeta(u264)
        end
    end)
end

function SF__.CrusaderStrike.UpdateAbilityMeta(u265)
    local p266 = GetOwningPlayer(u265)
    local datas__DamageScaling, datas__ArtOfWarChance = {}, {}
    do
        local i267 = 0
        while (i267 < 3) do
            do
                local item__DamageScaling, item__ArtOfWarChance = SF__.CrusaderStrike.GetAbilityData((i267 + 1))
                table.insert(datas__DamageScaling, item__DamageScaling)
                table.insert(datas__ArtOfWarChance, item__ArtOfWarChance)
            end
            ::continue::
            i267 = (i267 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p266, SF__.CrusaderStrike.ID, "学习十字军打击 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p266, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击造成一次攻击伤害，伤害系数随技能等级提升。产生|cffff8c001|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 6秒\r\n\r\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling[(0 + 1)] * 100)), "%|r的攻击伤害。\r\n|cffffcc002级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling[(1 + 1)] * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas__ArtOfWarChance[(1 + 1)] * 100)), "%的战争艺术触发几率。\r\n|cffffcc003级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling[(2 + 1)] * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas__ArtOfWarChance[(2 + 1)] * 100)), "%的战争艺术触发几率。"), 0)
    do
        local i268 = 0
        while (i268 < 3) do
            local data__DamageScaling, data__ArtOfWarChance = datas__DamageScaling[(i268 + 1)], datas__ArtOfWarChance[(i268 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p266, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击 - [|cffffcc00", (i268 + 1), "级|r]"), i268)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p266, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击造成一次攻击伤害，造成|cffff8c00", string.format("%.0f", (data__DamageScaling * 100)), "%|r的攻击伤害", SF__.Ternary__((i268 > 0), SF__.StrConcat__("，", string.format("%.0f", (data__ArtOfWarChance * 100)), "%的战争艺术触发几率"), ""), "。产生|cffff8c001|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 6秒"), i268)
            ::continue::
            i268 = (i268 + 1)
        end
    end
    -- datas.Remove(new IAbilityData { DamageScaling = 0.65f, ArtOfWarChance = 0 });
    do
        local index269 = 0
        table.remove(datas__DamageScaling, (index269 + 1))
        table.remove(datas__ArtOfWarChance, (index269 + 1))
    end
end

function SF__.CrusaderStrike.Start(data270)
    local level271 = GetUnitAbilityLevel(data270.caster, SF__.CrusaderStrike.ID)
    local UnitAttribute272 = require("Objects.UnitAttribute")
    local EventCenter274 = require("Lib.EventCenter")
    local ad__DamageScaling, ad__ArtOfWarChance = SF__.CrusaderStrike.GetAbilityData(level271)
    local attr = UnitAttribute272.GetAttr(data270.caster)
    local damage273 = (attr:SimAttack(UnitAttribute272.HeroAttributeType.Strength) * ad__DamageScaling)
    EventCenter274.Damage:Emit({whichUnit = data270.caster, target = data270.target, amount = damage273, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
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

function SF__.CrusaderStrike.IAbilityData.Equals(self__DamageScaling275, self__ArtOfWarChance276, other__DamageScaling, other__ArtOfWarChance)
    return ((math.abs((self__DamageScaling275 - other__DamageScaling)) < 0.0001) and (math.abs((self__ArtOfWarChance276 - other__ArtOfWarChance)) < 0.0001))
end

function SF__.CrusaderStrike.IAbilityData.GetHashValue(self__DamageScaling277, self__ArtOfWarChance278)
    return 0
end
-- DivineToll
SF__.DivineToll = SF__.DivineToll or {}
function SF__.DivineToll.GetAbilityData(level279)
    return (2 + level279), (50 * level279), 0.1, 10
end

function SF__.DivineToll.Init()
    local EventCenter281 = require("Lib.EventCenter")
    EventCenter281.RegisterPlayerUnitSpellEffect:Emit({id = SF__.DivineToll.ID, handler = function(data280)
        SF__.DivineToll.Start(data280)
    end})
    ExTriggerRegisterNewUnit(function(u282)
        if (GetUnitTypeId(u282) == FourCC("Hpal")) then
            SF__.DivineToll.UpdateAbilityMeta(u282)
        end
    end)
end

function SF__.DivineToll.UpdateAbilityMeta(u283)
    local p284 = GetOwningPlayer(u283)
    local datas__TargetCount, datas__Damage285, datas__RadiantDmgAmp, datas__Duration286 = {}, {}, {}, {}
    do
        local i287 = 0
        while (i287 < 3) do
            do
                local item__TargetCount, item__Damage288, item__RadiantDmgAmp, item__Duration289 = SF__.DivineToll.GetAbilityData((i287 + 1))
                table.insert(datas__TargetCount, item__TargetCount)
                table.insert(datas__Damage285, item__Damage288)
                table.insert(datas__RadiantDmgAmp, item__RadiantDmgAmp)
                table.insert(datas__Duration286, item__Duration289)
            end
            ::continue::
            i287 = (i287 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p284, SF__.DivineToll.ID, "学习圣洁鸣钟 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p284, SF__.DivineToll.ID, SF__.StrConcat__("对附近的多个目标施展审判，造成法术伤害，然后神圣之锤环绕圣殿骑士，每次命中敌人使其受到的光辉伤害提高。每个审判产生|cffff8c001|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 30秒\r\n\r\n|cffffcc001级|r - 审判最多|cffff8c00", datas__TargetCount[(0 + 1)], "|r个目标，造成|cffff8c00", datas__Damage285[(0 + 1)], "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas__RadiantDmgAmp[(0 + 1)] * 100)), "%|r的光辉易伤，持续|cffff8c00", datas__Duration286[(0 + 1)], "|r秒。\r\n|cffffcc002级|r - 审判最多|cffff8c00", datas__TargetCount[(1 + 1)], "|r个目标，造成|cffff8c00", datas__Damage285[(1 + 1)], "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas__RadiantDmgAmp[(1 + 1)] * 100)), "%|r的光辉易伤，持续|cffff8c00", datas__Duration286[(1 + 1)], "|r秒。\r\n|cffffcc003级|r - 审判最多|cffff8c00", datas__TargetCount[(2 + 1)], "|r个目标，造成|cffff8c00", datas__Damage285[(2 + 1)], "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas__RadiantDmgAmp[(2 + 1)] * 100)), "%|r的光辉易伤，持续|cffff8c00", datas__Duration286[(2 + 1)], "|r秒。"), 0)
    do
        local i290 = 0
        while (i290 < 3) do
            local data__TargetCount, data__Damage291, data__RadiantDmgAmp, data__Duration292 = datas__TargetCount[(i290 + 1)], datas__Damage285[(i290 + 1)], datas__RadiantDmgAmp[(i290 + 1)], datas__Duration286[(i290 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p284, SF__.DivineToll.ID, SF__.StrConcat__("圣洁鸣钟 - [|cffffcc00", (i290 + 1), "级|r]"), i290)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p284, SF__.DivineToll.ID, SF__.StrConcat__("对附近的最多|cffff8c00", data__TargetCount, "|r个目标施展审判，造成|cffff8c00", data__Damage291, "|r点法术伤害，然后神圣之锤环绕圣殿骑士，每次命中敌人使其受到的光辉伤害提高|cffff8c00", string.format("%.0f", (data__RadiantDmgAmp * 100)), "%|r，持续|cffff8c00", data__Duration292, "|r秒。每个审判产生|cffff8c001|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 30秒"), i290)
            ::continue::
            i290 = (i290 + 1)
        end
    end
end

function SF__.DivineToll.Start(data293)
    return SF__.CorRun__(function()
        local pos__x294, pos__y295, pos__z = SF__.Vector3.FromUnit(data293.caster)
        local eff296 = AddSpecialEffect("Abilities/Spells/Human/StormBolt/StormBoltMissile.mdl", pos__x294, pos__y295)
        local bolt = SF__.GameObject.New__s("DivineToll_Bolt")
        bolt.transform.position__x, bolt.transform.position__y, bolt.transform.position__z = SF__.Vector3.op_Addition(pos__x294, pos__y295, pos__z, 0, 0, 50)
        local hand = SF__.GameObject.New__sgameobject("dt_hand", bolt)
        local boltMis = SF__.GameObject.New__sgameobject("dt_mis", hand)
        boltMis.transform.position__x, boltMis.transform.position__y, boltMis.transform.position__z = 25, 0, 0
        boltMis:AddComponent(SF__.AttachEffectComponent).eff = eff296
        local trs = hand.transform
        local rot__x, rot__y, rot__z, rot__w = SF__.Quaternion.Euler((450 / 60), 0, 0)
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
function SF__.DivineToll.IAbilityData.Equals(self__TargetCount, self__Damage297, self__RadiantDmgAmp, self__Duration298, other__TargetCount, other__Damage299, other__RadiantDmgAmp, other__Duration300)
    return (((math.abs((self__Damage297 - other__Damage299)) < 0.0001) and (math.abs((self__Duration298 - other__Duration300)) < 0.0001)) and (math.abs((self__RadiantDmgAmp - other__RadiantDmgAmp)) < 0.0001))
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

function SF__.Quaternion.get_EulerAngles(self__x, self__y, self__z, self__w)
    -- https://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles#Source_Code_2
    local sinr_cosp = (2 * ((self__w * self__x) + (self__y * self__z)))
    local cosr_cosp = (1 - (2 * ((self__x * self__x) + (self__y * self__y))))
    local roll46 = math.atan2(sinr_cosp, cosr_cosp)
    local sinp = (2 * ((self__w * self__y) - (self__z * self__x)))
    local pitch47
    if (math.abs(sinp) >= 1) then
        pitch47 = ((math.sign(sinp) * math.pi) / 2)
        -- use 90 degrees if out of range
    else
        pitch47 = math.asin(sinp)
    end
    local siny_cosp = (2 * ((self__w * self__z) + (self__x * self__y)))
    local cosy_cosp = (1 - (2 * ((self__y * self__y) + (self__z * self__z))))
    local yaw48 = math.atan2(siny_cosp, cosy_cosp)
    return (pitch47 * bj_RADTODEG), (yaw48 * bj_RADTODEG), (roll46 * bj_RADTODEG)
end

function SF__.Quaternion.Equals(self__x51, self__y52, self__z53, self__w54, other__x, other__y, other__z, other__w)
    return ((((math.abs((self__x51 - other__x)) < 0.0001) and (math.abs((self__y52 - other__y)) < 0.0001)) and (math.abs((self__z53 - other__z)) < 0.0001)) and (math.abs((self__w54 - other__w)) < 0.0001))
end

function SF__.Quaternion.ToString(self__x55, self__y56, self__z57, self__w58)
    return SF__.StrConcat__("(", self__x55, ", ", self__y56, ", ", self__z57, ", ", self__w58, ")")
end

function SF__.Quaternion.ApplyToEffect(self__x59, self__y60, self__z61, self__w62, e63)
    local angles__x, angles__y, angles__z = SF__.Quaternion.get_EulerAngles(self__x59, self__y60, self__z61, self__w62)
    BlzSetSpecialEffectOrientation(e63, (angles__y * bj_DEGTORAD), (angles__x * bj_DEGTORAD), (angles__z * bj_DEGTORAD))
end
-- RetributionPaladinGlobal
SF__.RetributionPaladinGlobal = SF__.RetributionPaladinGlobal or {}
function SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(u301, amount)
    local UnitAttribute303 = require("Objects.UnitAttribute")
    local attr302 = UnitAttribute303.GetAttr(u301)
    attr302.retPalHolyEnergy = math.min((attr302.retPalHolyEnergy + amount), 5)
end

function SF__.RetributionPaladinGlobal:Init()
    ExTriggerRegisterNewUnit(function(u304)
        if (GetUnitTypeId(u304) == FourCC("Hpal")) then
            SF__.ListAdd__(self._units, u304)
        end
    end)
    _ = self:Start()
end

function SF__.RetributionPaladinGlobal:Start()
    return SF__.CorRun__(function()
        local UnitAttribute307 = require("Objects.UnitAttribute")
        while true do
            do
                local collection16 = self._units
                for i17, u305 in SF__.ListIterate__(collection16) do
                    local attr306 = UnitAttribute307.GetAttr(u305)
                    ExSetUnitMana(u305, ((ExGetUnitMaxMana(u305) * attr306.retPalHolyEnergy) * 0.2))
                    if (attr306.retPalHolyEnergy >= 3) then
                        SF__.Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u305), FourCC("A006"), "ReplaceableTextures/CommandButtons/BTNinv_helmet_96.tga")
                    else
                        SF__.Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u305), FourCC("A006"), "ReplaceableTextures/PassiveButtons/PASBTNinv_helmet_96.tga")
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
            if not __sf_ok then
                local e = __sf_err
                BJDebugMsg((function()
                    local strPart = e
                    if (strPart ~= nil) then
                        return strPart:ToString()
                    end
                    return nil
                end)())
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
    local item64 = SF__.ListGet__(self._items, (SF__.ListCount__(self._items) - 1))
    SF__.ListRemoveAt__(self._items, (SF__.ListCount__(self._items) - 1))
    return item64
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
local SystemBase16 = require("System.SystemBase")
SF__.Systems.InspectorSystem = SF__.Systems.InspectorSystem or class("InspectorSystem", SystemBase16)
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
            text35 = SF__.StrConcat__(text35, "\n[", component:GetInspectorName(), "]")
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
function SF__.TemplarStrikes.GetAbilityData(level308)
    return 2, (0.5 + (0.25 * level308)), (0.05 * level308)
end

function SF__.TemplarStrikes.Init()
    local EventCenter309 = require("Lib.EventCenter")
    EventCenter309.RegisterPlayerUnitSpellEffect:Emit({id = SF__.TemplarStrikes.ID, handler = SF__.TemplarStrikes.Start})
    ExTriggerRegisterNewUnit(function(u310)
        if (GetUnitTypeId(u310) == FourCC("Hpal")) then
            SF__.TemplarStrikes.UpdateAbilityMeta(u310)
            SetHeroLevel(u310, 10, true)
        end
    end)
    EventCenter309.RegisterPlayerUnitDamaged:Emit(function(caster311, target312, damage313, weapType, dmgType, isAttack)
        if (GetUnitAbilityLevel(caster311, SF__.TemplarStrikes.ID) <= 0) then
            return
        end
        if (not isAttack) then
            return
        end
        if (target312 == nil) then
            return
        end
        if ExIsUnitDead(target312) then
            return
        end
        SF__.TemplarStrikes.TryResetBOJ(caster311)
    end)
end

function SF__.TemplarStrikes.TryResetBOJ(caster314)
    local level315 = GetUnitAbilityLevel(caster314, SF__.TemplarStrikes.ID)
    local ad__AttackCount, ad__DamageScaling316, ad__ResetBOJChance = SF__.TemplarStrikes.GetAbilityData(level315)
    if (math.random() >= ad__ResetBOJChance) then
        return
    end
    BlzEndUnitAbilityCooldown(caster314, SF__.BladeOfJustice.ID)
    ExAddSpecialEffectTarget("Abilities/Spells/Items/AIam/AIamTarget.mdl", caster314, "origin", 0.3)
end

function SF__.TemplarStrikes.UpdateAbilityMeta(u317)
    local p318 = GetOwningPlayer(u317)
    local datas__AttackCount, datas__DamageScaling319, datas__ResetBOJChance = {}, {}, {}
    do
        local i320 = 0
        while (i320 < SF__.TemplarStrikes.MaxLevel) do
            do
                local item__AttackCount, item__DamageScaling321, item__ResetBOJChance = SF__.TemplarStrikes.GetAbilityData((i320 + 1))
                table.insert(datas__AttackCount, item__AttackCount)
                table.insert(datas__DamageScaling319, item__DamageScaling321)
                table.insert(datas__ResetBOJChance, item__ResetBOJChance)
            end
            ::continue::
            i320 = (i320 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p318, SF__.TemplarStrikes.ID, "学习圣殿骑士之击 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p318, SF__.TemplarStrikes.ID, SF__.StrConcat__("快速攻击目标|cffff8c00", datas__AttackCount[(0 + 1)], "|r次，第一次造成普通攻击伤害，第二次造成光辉伤害，有一定几率重置公正之剑的冷却时间，普通攻击也会触发。\r\n\r\n|cff99ccff冷却时间|r - 10秒\r\n\r\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling319[(0 + 1)] * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas__ResetBOJChance[(0 + 1)] * 100)), "%|r的几率重置公正之剑。\r\n|cffffcc002级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling319[(1 + 1)] * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas__ResetBOJChance[(1 + 1)] * 100)), "%|r的几率重置公正之剑。\r\n|cffffcc003级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling319[(2 + 1)] * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas__ResetBOJChance[(2 + 1)] * 100)), "%|r的几率重置公正之剑。"), 0)
    do
        local i322 = 0
        while (i322 < SF__.TemplarStrikes.MaxLevel) do
            local data__AttackCount, data__DamageScaling323, data__ResetBOJChance = datas__AttackCount[(i322 + 1)], datas__DamageScaling319[(i322 + 1)], datas__ResetBOJChance[(i322 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p318, SF__.TemplarStrikes.ID, SF__.StrConcat__("圣殿骑士之击 - [|cffffcc00", (i322 + 1), "级|r]"), i322)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p318, SF__.TemplarStrikes.ID, SF__.StrConcat__("快速攻击目标|cffff8c00", data__AttackCount, "|r次，第一次造成普通攻击伤害，第二次造成普通攻击|cffff8c00", string.format("%.0f", (data__DamageScaling323 * 100)), "%|r的光辉伤害，|cffff8c00", string.format("%.0f", (data__ResetBOJChance * 100)), "%|r几率重置公正之剑的冷却时间，普通攻击也会触发。\r\n\r\n|cff99ccff冷却时间|r - 10秒"), i322)
            ::continue::
            i322 = (i322 + 1)
        end
    end
end

function SF__.TemplarStrikes.Start(data324)
    return SF__.CorRun__(function()
        local level325 = GetUnitAbilityLevel(data324.caster, SF__.TemplarStrikes.ID)
        local UnitAttribute327 = require("Objects.UnitAttribute")
        local EventCenter328 = require("Lib.EventCenter")
        local attr326 = UnitAttribute327.GetAttr(data324.caster)
        local normalDamage = attr326:SimMeleeAttack()
        EventCenter328.Damage:Emit({whichUnit = data324.caster, target = data324.target, amount = normalDamage, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
        SF__.TemplarStrikes.TryResetBOJ(data324.caster)
        SetUnitTimeScale(data324.caster, 3)
        ResetUnitAnimation(data324.caster)
        SetUnitAnimation(data324.caster, "attack - 2")
        SF__.CorWait__(math.round(((1.166 * 0.33) * 1000)))
        local tarAttr329 = UnitAttribute327.GetAttr(data324.target)
        local ad__AttackCount330, ad__DamageScaling331, ad__ResetBOJChance332 = SF__.TemplarStrikes.GetAbilityData(level325)
        local radiantDamage = ((attr326:SimMeleeAttack() * ad__DamageScaling331) * (1 - tarAttr329.radiantResistance))
        EventCenter328.Damage:Emit({whichUnit = data324.caster, target = data324.target, amount = radiantDamage, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
        SF__.TemplarStrikes.TryResetBOJ(data324.caster)
        SetUnitTimeScale(data324.caster, 1)
        ResetUnitAnimation(data324.caster)
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
function SF__.TemplarStrikes.IAbilityData.Equals(self__AttackCount, self__DamageScaling333, self__ResetBOJChance, other__AttackCount, other__DamageScaling334, other__ResetBOJChance)
    return ((math.abs((self__DamageScaling333 - other__DamageScaling334)) < 0.0001) and (math.abs((self__ResetBOJChance - other__ResetBOJChance)) < 0.0001))
end
-- TemplarVerdict
SF__.TemplarVerdict = SF__.TemplarVerdict or {}
function SF__.TemplarVerdict.GetAbilityData(level335)
    return 2.25, 0.3, 0.15
end

function SF__.TemplarVerdict.Init()
    local EventCenter336 = require("Lib.EventCenter")
    EventCenter336.RegisterPlayerUnitSpellChannel:Emit({id = SF__.TemplarVerdict.ID, handler = SF__.TemplarVerdict.Check})
    EventCenter336.RegisterPlayerUnitSpellEffect:Emit({id = SF__.TemplarVerdict.ID, handler = SF__.TemplarVerdict.Start})
    ExTriggerRegisterNewUnit(function(u337)
        if (GetUnitTypeId(u337) == FourCC("Hpal")) then
            SF__.TemplarVerdict.UpdateAbilityMeta(u337)
        end
    end)
end

function SF__.TemplarVerdict.Check(data338)
    local UnitAttribute340 = require("Objects.UnitAttribute")
    local attr339 = UnitAttribute340.GetAttr(data338.caster)
    if (attr339.retPalHolyEnergy < 3) then
        IssueImmediateOrderById(data338.caster, SF__.ConstOrderId.Stop)
        ExTextState(data338.caster, "圣能不足")
    end
end

function SF__.TemplarVerdict.UpdateAbilityMeta(u341)
    local p342 = GetOwningPlayer(u341)
    local datas__DamageScaling343, datas__JudgementDamageScaling, datas__ChanceToResetJudgement = {}, {}, {}
    do
        local i344 = 0
        while (i344 < 1) do
            do
                local item__DamageScaling345, item__JudgementDamageScaling, item__ChanceToResetJudgement = SF__.TemplarVerdict.GetAbilityData((i344 + 1))
                table.insert(datas__DamageScaling343, item__DamageScaling345)
                table.insert(datas__JudgementDamageScaling, item__JudgementDamageScaling)
                table.insert(datas__ChanceToResetJudgement, item__ChanceToResetJudgement)
            end
            ::continue::
            i344 = (i344 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p342, SF__.TemplarVerdict.ID, "学习圣殿骑士的裁决 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p342, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决造成一次攻击伤害，如果目标被审判，造成30%的额外伤害，15%几率重置审判。消耗|cffff8c003|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 5秒\r\n\r\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas__JudgementDamageScaling[(0 + 1)] * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas__ChanceToResetJudgement[(0 + 1)] * 100)), "%的战争艺术触发几率。"), 0)
    do
        local i346 = 0
        while (i346 < 1) do
            local data__DamageScaling347, data__JudgementDamageScaling, data__ChanceToResetJudgement = datas__DamageScaling343[(i346 + 1)], datas__JudgementDamageScaling[(i346 + 1)], datas__ChanceToResetJudgement[(i346 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p342, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决 - [|cffffcc00", (i346 + 1), "级|r]"), i346)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p342, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决造成一次攻击伤害，造成|cffff8c00", string.format("%.0f", (data__DamageScaling347 * 100)), "%|r的攻击伤害。消耗|cffff8c003|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 5秒"), i346)
            ::continue::
            i346 = (i346 + 1)
        end
    end
end

function SF__.TemplarVerdict.Start(data348)
    local level349 = GetUnitAbilityLevel(data348.caster, SF__.TemplarVerdict.ID)
    local UnitAttribute352 = require("Objects.UnitAttribute")
    local EventCenter354 = require("Lib.EventCenter")
    local ad__DamageScaling350, ad__JudgementDamageScaling, ad__ChanceToResetJudgement = SF__.TemplarVerdict.GetAbilityData(level349)
    local attr351 = UnitAttribute352.GetAttr(data348.caster)
    local damage353 = (attr351:SimAttack(UnitAttribute352.HeroAttributeType.Strength) * ad__DamageScaling350)
    EventCenter354.Damage:Emit({whichUnit = data348.caster, target = data348.target, amount = damage353, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_SLICE, outResult = {}})
    attr351.retPalHolyEnergy = (attr351.retPalHolyEnergy - 3)
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
function SF__.TemplarVerdict.IAbilityData.Equals(self__DamageScaling355, self__JudgementDamageScaling, self__ChanceToResetJudgement, other__DamageScaling356, other__JudgementDamageScaling, other__ChanceToResetJudgement)
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

function SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p65, abilCode66, researchExtendedTooltip, level67)
    if (GetLocalPlayer() ~= p65) then
        return
    end
    BlzSetAbilityResearchExtendedTooltip(abilCode66, researchExtendedTooltip, level67)
end

function SF__.Utils.ExBlzSetAbilityTooltip(p68, abilCode69, tooltip, level70)
    if (GetLocalPlayer() ~= p68) then
        return
    end
    BlzSetAbilityTooltip(abilCode69, tooltip, level70)
end

function SF__.Utils.ExBlzSetAbilityExtendedTooltip(p71, abilCode72, extendedTooltip, level73)
    if (GetLocalPlayer() ~= p71) then
        return
    end
    BlzSetAbilityExtendedTooltip(abilCode72, extendedTooltip, level73)
end

function SF__.Utils.ExBlzSetAbilityIcon(p74, abilCode75, iconPath)
    if (GetLocalPlayer() ~= p74) then
        return
    end
    BlzSetAbilityIcon(abilCode75, iconPath)
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

function SF__.Vector2.Dot(a__x76, a__y77, b__x78, b__y79)
    return ((a__x76 * b__x78) + (a__y77 * b__y79))
end

function SF__.Vector2.Cross(a__x80, a__y81, b__x82, b__y83)
    return ((a__y81 * b__x82) - (a__x80 * b__y83))
end

function SF__.Vector2.op_UnaryNegation(a__x84, a__y85)
    return (-a__x84), (-a__y85)
end

function SF__.Vector2.op_Addition(a__x86, a__y87, b__x88, b__y89)
    return (a__x86 + b__x88), (a__y87 + b__y89)
end

function SF__.Vector2.op_Subtraction(a__x90, a__y91, b__x92, b__y93)
    return (a__x90 - b__x92), (a__y91 - b__y93)
end

function SF__.Vector2.op_Multiply__vector2f(v__x94, v__y95, f)
    return (v__x94 * f), (v__y95 * f)
end

function SF__.Vector2.op_Multiply__fvector2(f96, v__x97, v__y98)
    return (v__x97 * f96), (v__y98 * f96)
end

function SF__.Vector2.op_Division(v__x99, v__y100, f101)
    return (v__x99 / f101), (v__y100 / f101)
end

function SF__.Vector2.op_Equality(a__x102, a__y103, b__x104, b__y105)
    return ((math.abs((a__x102 - b__x104)) < 0.0001) and (math.abs((a__y103 - b__y105)) < 0.0001))
end

function SF__.Vector2.op_Inequality(a__x106, a__y107, b__x108, b__y109)
    return (not SF__.Vector2.op_Equality(a__x106, a__y107, b__x108, b__y109))
end

function SF__.Vector2.UnitDistance(a, b)
    local v1__x, v1__y = SF__.Vector2.FromUnit(a)
    local v2__x, v2__y = SF__.Vector2.FromUnit(b)
    return SF__.Vector2.get_Magnitude(SF__.Vector2.op_Subtraction(v1__x, v1__y, v2__x, v2__y))
end

function SF__.Vector2.SqrUnitDistance(a110, b111)
    local v1__x112, v1__y113 = SF__.Vector2.FromUnit(a110)
    local v2__x114, v2__y115 = SF__.Vector2.FromUnit(b111)
    return SF__.Vector2.get_SqrMagnitude(SF__.Vector2.op_Subtraction(v1__x112, v1__y113, v2__x114, v2__y115))
end

function SF__.Vector2.FromUnit(u)
    return GetUnitX(u), GetUnitY(u)
end

function SF__.Vector2.get_Magnitude(self__x116, self__y117)
    return math.sqrt(SF__.Vector2.get_SqrMagnitude(self__x116, self__y117))
end

function SF__.Vector2.get_SqrMagnitude(self__x118, self__y119)
    return ((self__x118 * self__x118) + (self__y119 * self__y119))
end

function SF__.Vector2.get_Normalized(self__x120, self__y121)
    local mag = SF__.Vector2.get_Magnitude(self__x120, self__y121)
    if (mag < 0.0001) then
        return SF__.Vector2.get_Zero()
    end
    return SF__.Vector2.op_Division(self__x120, self__y121, mag)
end

function SF__.Vector2.ClampMagnitude(self__x124, self__y125, mag126)
    return (function()
        local v__x127, v__y128 = SF__.Vector2.get_Normalized(self__x124, self__y125)
        return SF__.Vector2.op_Multiply__vector2f(v__x127, v__y128, mag126)
    end)()
end

function SF__.Vector2.Equals(self__x129, self__y130, other__x131, other__y132)
    return SF__.Vector2.op_Equality(self__x129, self__y130, other__x131, other__y132)
end

function SF__.Vector2.ToString(self__x133, self__y134)
    return SF__.StrConcat__("(", self__x133, ", ", self__y134, ")")
end

function SF__.Vector2.Rotate(self__x135, self__y136, angle137)
    local cos = math.cos(angle137)
    local sin = math.sin(angle137)
    return ((self__x135 * cos) - (self__y136 * sin)), ((self__x135 * sin) + (self__y136 * cos))
end

function SF__.Vector2.UnitMoveTo(self__x138, self__y139, u140)
    SetUnitX(u140, self__x138)
    SetUnitY(u140, self__y139)
end

function SF__.Vector2.GetTerrainZ(self__x141, self__y142)
    MoveLocation(SF__.Vector2._loc, self__x141, self__y142)
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

function SF__.Vector3.op_Addition(a__x143, a__y144, a__z145, b__x146, b__y147, b__z148)
    return (a__x143 + b__x146), (a__y144 + b__y147), (a__z145 + b__z148)
end

function SF__.Vector3.op_UnaryNegation(a__x149, a__y150, a__z151)
    return (-a__x149), (-a__y150), (-a__z151)
end

function SF__.Vector3.op_Subtraction(a__x152, a__y153, a__z154, b__x155, b__y156, b__z157)
    return (a__x152 - b__x155), (a__y153 - b__y156), (a__z154 - b__z157)
end

function SF__.Vector3.op_Multiply__vector3f(v__x158, v__y159, v__z160, f161)
    return (v__x158 * f161), (v__y159 * f161), (v__z160 * f161)
end

function SF__.Vector3.op_Multiply__fvector3(f162, v__x163, v__y164, v__z165)
    return (v__x163 * f162), (v__y164 * f162), (v__z165 * f162)
end

function SF__.Vector3.op_Division(v__x166, v__y167, v__z168, f169)
    return (v__x166 / f169), (v__y167 / f169), (v__z168 / f169)
end

function SF__.Vector3.op_Equality(a__x170, a__y171, a__z172, b__x173, b__y174, b__z175)
    return (((math.abs((a__x170 - b__x173)) < 0.0001) and (math.abs((a__y171 - b__y174)) < 0.0001)) and (math.abs((a__z172 - b__z175)) < 0.0001))
end

function SF__.Vector3.op_Inequality(a__x176, a__y177, a__z178, b__x179, b__y180, b__z181)
    return (not SF__.Vector3.op_Equality(a__x176, a__y177, a__z178, b__x179, b__y180, b__z181))
end

function SF__.Vector3.Dot(a__x182, a__y183, a__z184, b__x185, b__y186, b__z187)
    return (((a__x182 * b__x185) + (a__y183 * b__y186)) + (a__z184 * b__z187))
end

function SF__.Vector3.Scale(a__x188, a__y189, a__z190, b__x191, b__y192, b__z193)
    return (a__x188 * b__x191), (a__y189 * b__y192), (a__z190 * b__z193)
end

-- <summary>
-- Warcraft III world space here is right-handed: +x points right, +y points away, +z points up.
-- That means Cross((1,0,0), (0,1,0)) == (0,0,1).
-- </summary>
--
function SF__.Vector3.Cross(a__x194, a__y195, a__z196, b__x197, b__y198, b__z199)
    return ((a__y195 * b__z199) - (a__z196 * b__y198)), ((a__z196 * b__x197) - (a__x194 * b__z199)), ((a__x194 * b__y198) - (a__y195 * b__x197))
end

function SF__.Vector3.Project(v__x200, v__y201, v__z202, onNormal__x, onNormal__y, onNormal__z)
    local sqrMag = SF__.Vector3.Dot(onNormal__x, onNormal__y, onNormal__z, onNormal__x, onNormal__y, onNormal__z)
    if (sqrMag < 0.0001) then
        return SF__.Vector3.get_Zero()
    end
    local dot = SF__.Vector3.Dot(v__x200, v__y201, v__z202, onNormal__x, onNormal__y, onNormal__z)
    return SF__.Vector3.op_Multiply__vector3f(onNormal__x, onNormal__y, onNormal__z, (dot / sqrMag))
end

function SF__.Vector3.ProjectOnPlane(v__x203, v__y204, v__z205, planeNormal__x, planeNormal__y, planeNormal__z)
    return SF__.Vector3.op_Subtraction(v__x203, v__y204, v__z205, SF__.Vector3.Project(v__x203, v__y204, v__z205, planeNormal__x, planeNormal__y, planeNormal__z))
end

function SF__.Vector3._getTerrainZ(x206, y207)
    MoveLocation(SF__.Vector3._loc, x206, y207)
    return GetLocationZ(SF__.Vector3._loc)
end

function SF__.Vector3.FromUnit(u208)
    local x209 = GetUnitX(u208)
    local y210 = GetUnitY(u208)
    return x209, y210, (SF__.Vector3._getTerrainZ(x209, y210) + GetUnitFlyHeight(u208))
end

function SF__.Vector3.get_SqrMagnitude(self__x211, self__y212, self__z213)
    return (((self__x211 * self__x211) + (self__y212 * self__y212)) + (self__z213 * self__z213))
end

function SF__.Vector3.get_Magnitude(self__x214, self__y215, self__z216)
    return math.sqrt(SF__.Vector3.get_SqrMagnitude(self__x214, self__y215, self__z216))
end

function SF__.Vector3.get_Normalized(self__x217, self__y218, self__z219)
    local mag220 = SF__.Vector3.get_Magnitude(self__x217, self__y218, self__z219)
    if (mag220 < 0.0001) then
        return SF__.Vector3.get_Zero()
    end
    return SF__.Vector3.op_Division(self__x217, self__y218, self__z219, mag220)
end

function SF__.Vector3.ClampMagnitude(self__x224, self__y225, self__z226, mag227)
    return (function()
        local v__x228, v__y229, v__z230 = SF__.Vector3.get_Normalized(self__x224, self__y225, self__z226)
        return SF__.Vector3.op_Multiply__vector3f(v__x228, v__y229, v__z230, mag227)
    end)()
end

function SF__.Vector3.Equals(self__x231, self__y232, self__z233, other__x234, other__y235, other__z236)
    return SF__.Vector3.op_Equality(self__x231, self__y232, self__z233, other__x234, other__y235, other__z236)
end

function SF__.Vector3.ToString(self__x237, self__y238, self__z239)
    return SF__.StrConcat__("(", self__x237, ", ", self__y238, ", ", self__z239, ")")
end

function SF__.Vector3.UnitMoveTo(self__x240, self__y241, self__z242, u243, mode)
    if mode == nil then mode = SF__.UnitVec3Mode.Auto end
    local tz = SF__.Vector3._getTerrainZ(self__x240, self__y241)
    local LuaUtils = require("Lib.Utils")
    local defaultFlyHeight = GetUnitDefaultFlyHeight(u243)
    local minZ = (tz + defaultFlyHeight)
    SetUnitPosition(u243, self__x240, self__y241)
    repeat
        local switchValue = mode
        if (switchValue == SF__.UnitVec3Mode.ForceFlying) then
            LuaUtils.SetUnitFlyable(u243)
            SetUnitFlyHeight(u243, (math.max(minZ, self__z242) - minZ), 0)
            break
        elseif (switchValue == SF__.UnitVec3Mode.ForceGround) then
            SetUnitFlyHeight(u243, defaultFlyHeight, 0)
            break
        elseif (switchValue == SF__.UnitVec3Mode.Auto) then
            if IsUnitType(u243, UNIT_TYPE_FLYING) then
                SetUnitFlyHeight(u243, (math.max(minZ, self__z242) - minZ), 0)
            else
                SetUnitFlyHeight(u243, defaultFlyHeight, 0)
            end
            break
        end
    until true
end

function SF__.Vector3.GetTerrainZ(self__x244, self__y245, self__z246)
    return SF__.Vector3._getTerrainZ(self__x244, self__y245)
end

SF__.Vector3._loc = Location(0, 0)
-- WordOfGlory
SF__.WordOfGlory = SF__.WordOfGlory or {}
function SF__.WordOfGlory.Init()
    local EventCenter357 = require("Lib.EventCenter")
    EventCenter357.RegisterPlayerUnitSpellChannel:Emit({id = SF__.WordOfGlory.ID, handler = SF__.WordOfGlory.Check})
    EventCenter357.RegisterPlayerUnitSpellEffect:Emit({id = SF__.WordOfGlory.ID, handler = SF__.WordOfGlory.Start})
    ExTriggerRegisterNewUnit(function(u358)
        if (GetUnitTypeId(u358) == FourCC("Hpal")) then
            SF__.WordOfGlory.UpdateAbilityMeta(u358)
        end
    end)
end

function SF__.WordOfGlory.Check(data359)
    local UnitAttribute361 = require("Objects.UnitAttribute")
    local attr360 = UnitAttribute361.GetAttr(data359.caster)
    if (attr360.retPalHolyEnergy < 3) then
        IssueImmediateOrderById(data359.caster, SF__.ConstOrderId.Stop)
        ExTextState(data359.caster, "圣能不足")
    end
end

function SF__.WordOfGlory.UpdateAbilityMeta(u362)
    local p363 = GetOwningPlayer(u362)
    SF__.Utils.ExSetAbilityResearchTooltip(p363, SF__.WordOfGlory.ID, "学习圣殿骑士的裁决 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p363, SF__.WordOfGlory.ID, "圣殿骑士的裁决造成一次攻击伤害，如果目标被审判，造成30%的额外伤害，15%几率重置审判。消耗|cffff8c003|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 5秒\r\n\r\n|cffffcc001级|r - |cffff8c00100%|r的攻击伤害，100%的战争艺术触发几率。", 0)
    do
        local i364 = 0
        while (i364 < 1) do
            SF__.Utils.ExBlzSetAbilityTooltip(p363, SF__.WordOfGlory.ID, SF__.StrConcat__("圣殿骑士的裁决 - [|cffffcc00", (i364 + 1), "级|r]"), i364)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p363, SF__.WordOfGlory.ID, "圣殿骑士的裁决造成一次攻击伤害，造成|cffff8c00100%|r的攻击伤害。消耗|cffff8c003|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 5秒", i364)
            ::continue::
            i364 = (i364 + 1)
        end
    end
end

function SF__.WordOfGlory.Start(data365)
    local UnitAttribute367 = require("Objects.UnitAttribute")
    local EventCenter368 = require("Lib.EventCenter")
    local attr366 = UnitAttribute367.GetAttr(data365.caster)
    EventCenter368.Heal:Emit({caster = data365.caster, target = data365.target, amount = 300})
    attr366.retPalHolyEnergy = (attr366.retPalHolyEnergy - 3)
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
