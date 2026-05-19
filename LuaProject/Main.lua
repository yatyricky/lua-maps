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
    return SF__.StrConcat__("Effect ", SF__.Ternary__((self.eff == nil), "None", "Attached"))
end

function SF__.AttachEffectComponent:Update()
    if (self.eff == nil) then
        return
    end
    -- calculate global TRS from transform and ancestor transforms
    local globalPos__x, globalPos__y, globalPos__z = self.gameObject.transform.position.x, self.gameObject.transform.position.y, self.gameObject.transform.position.z
    local globalRot__x, globalRot__y, globalRot__z, globalRot__w = self.gameObject.transform.rotation.x, self.gameObject.transform.rotation.y, self.gameObject.transform.rotation.z, self.gameObject.transform.rotation.w
    local globalScale__x, globalScale__y, globalScale__z = self.gameObject.transform.localScale.x, self.gameObject.transform.localScale.y, self.gameObject.transform.localScale.z
    local parent = self.gameObject.transform.parent
    while (parent ~= nil) do
        globalPos__x, globalPos__y, globalPos__z = SF__.Vector3.op_Addition(parent.position.x, parent.position.y, parent.position.z, SF__.Quaternion.op_Multiply__quaternionvector3(parent.rotation.x, parent.rotation.y, parent.rotation.z, parent.rotation.w, SF__.Vector3.Scale(parent.localScale.x, parent.localScale.y, parent.localScale.z, globalPos__x, globalPos__y, globalPos__z)))
        globalRot__x, globalRot__y, globalRot__z, globalRot__w = SF__.Quaternion.op_Multiply__quaternionquaternion(parent.rotation.x, parent.rotation.y, parent.rotation.z, parent.rotation.w, globalRot__x, globalRot__y, globalRot__z, globalRot__w)
        globalScale__x, globalScale__y, globalScale__z = SF__.Vector3.Scale(parent.localScale.x, parent.localScale.y, parent.localScale.z, globalScale__x, globalScale__y, globalScale__z)
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
function SF__.BladeOfJustice.GetAbilityData(level206)
    return (75 * level206), 5, (10 * level206)
end

function SF__.BladeOfJustice.Init()
    local EventCenter = require("Lib.EventCenter")
    EventCenter.RegisterPlayerUnitSpellEffect:Emit({id = SF__.BladeOfJustice.ID, handler = SF__.BladeOfJustice.Start})
    ExTriggerRegisterNewUnit(function(u207)
        if (GetUnitTypeId(u207) == FourCC("Hpal")) then
            SF__.BladeOfJustice.UpdateAbilityMeta(u207)
        end
    end)
end

function SF__.BladeOfJustice.UpdateAbilityMeta(u208)
    local p209 = GetOwningPlayer(u208)
    local datas__Damage, datas__Duration, datas__DamagePerSecond = {}, {}, {}
    do
        local i210 = 0
        while (i210 < 3) do
            do
                local item__Damage, item__Duration, item__DamagePerSecond = SF__.BladeOfJustice.GetAbilityData((i210 + 1))
                table.insert(datas__Damage, item__Damage)
                table.insert(datas__Duration, item__Duration)
                table.insert(datas__DamagePerSecond, item__DamagePerSecond)
            end
            ::continue::
            i210 = (i210 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p209, SF__.BladeOfJustice.ID, "学习公正之剑 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p209, SF__.BladeOfJustice.ID, SF__.StrConcat__("用圣光的利刃刺穿目标，造成法术伤害，在一定时间内对附近敌人每秒造成光辉伤害。产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 10秒\n\n|cffffcc001级|r - 造成|cffff8c00", datas__Damage[(0 + 1)], "|r的直接法术伤害，|cffff8c00", datas__Duration[(0 + 1)], "|r秒内对附近敌人每秒造成|cffff8c00", datas__DamagePerSecond[(0 + 1)], "|r的光辉伤害。产生|cffff8c001|r点圣能。\n|cffffcc002级|r - 造成|cffff8c00", datas__Damage[(1 + 1)], "|r的直接法术伤害，|cffff8c00", datas__Duration[(1 + 1)], "|r秒内对附近敌人每秒造成|cffff8c00", datas__DamagePerSecond[(1 + 1)], "|r的光辉伤害。产生|cffff8c001|r点圣能。\n|cffffcc003级|r - 造成|cffff8c00", datas__Damage[(2 + 1)], "|r的直接法术伤害，|cffff8c00", datas__Duration[(2 + 1)], "|r秒内对附近敌人每秒造成|cffff8c00", datas__DamagePerSecond[(2 + 1)], "|r的光辉伤害。产生|cffff8c001|r点圣能。"), 0)
    do
        local i211 = 0
        while (i211 < 3) do
            local data__Damage, data__Duration, data__DamagePerSecond = datas__Damage[(i211 + 1)], datas__Duration[(i211 + 1)], datas__DamagePerSecond[(i211 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p209, SF__.BladeOfJustice.ID, SF__.StrConcat__("公正之剑 - [|cffffcc00", (i211 + 1), "级|r]"), i211)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p209, SF__.BladeOfJustice.ID, SF__.StrConcat__("用圣光的利刃刺穿目标，造成|cffff8c00", data__Damage, "|r的直接法术伤害，在|cffff8c00", data__Duration, "|r秒内对附近敌人每秒造成|cffff8c00", data__DamagePerSecond, "|r的光辉伤害。产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 10秒"), i211)
            ::continue::
            i211 = (i211 + 1)
        end
    end
end

function SF__.BladeOfJustice.Start(data)
    local level212 = GetUnitAbilityLevel(data.caster, SF__.BladeOfJustice.ID)
    local EventCenter213 = require("Lib.EventCenter")
    local ad__Damage, ad__Duration, ad__DamagePerSecond = SF__.BladeOfJustice.GetAbilityData(level212)
    EventCenter213.Damage:Emit({whichUnit = data.caster, target = data.target, amount = ad__Damage, attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
    SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(data.caster, 1)
    SF__.BladeOfJustice.New():StartGroudDamage(data.caster, data.target, ad__Damage, ad__Duration, ad__DamagePerSecond)
end

function SF__.BladeOfJustice:StartGroudDamage(caster, target, ad__Damage214, ad__Duration215, ad__DamagePerSecond216)
    return SF__.CorRun__(function()
        local pos__x, pos__y = SF__.Vector2.FromUnit(target)
        local UnitAttribute = require("Objects.UnitAttribute")
        local EventCenter220 = require("Lib.EventCenter")
        local eff = ExAddSpecialEffect("Abilities/Spells/Orc/LiquidFire/Liquidfire.mdl", pos__x, pos__y, ad__Duration215)
        local p217 = GetOwningPlayer(caster)
        do
            local i218 = 0
            while (i218 < ad__Duration215) do
                SF__.CorWait__(1000)
                ExGroupEnumUnitsInRange(pos__x, pos__y, 300, function(u219)
                    if (not IsUnitEnemy(u219, p217)) then
                        return
                    end
                    if ExIsUnitDead(u219) then
                        return
                    end
                    local tarAttr = UnitAttribute.GetAttr(u219)
                    local damage = (ad__DamagePerSecond216 * (1 - tarAttr.radiantResistance))
                    EventCenter220.Damage:Emit({whichUnit = caster, target = u219, amount = damage, attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
                end)
                ::continue::
                i218 = (i218 + 1)
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
function SF__.CrusaderStrike.GetAbilityData(level221)
    return (0.65 + (0.35 * level221)), (0.15 * (level221 - 1))
end

function SF__.CrusaderStrike.Init()
    local EventCenter222 = require("Lib.EventCenter")
    EventCenter222.RegisterPlayerUnitSpellEffect:Emit({id = SF__.CrusaderStrike.ID, handler = SF__.CrusaderStrike.Start})
    ExTriggerRegisterNewUnit(function(u223)
        if (GetUnitTypeId(u223) == FourCC("Hpal")) then
            SF__.CrusaderStrike.UpdateAbilityMeta(u223)
        end
    end)
end

function SF__.CrusaderStrike.UpdateAbilityMeta(u224)
    local p225 = GetOwningPlayer(u224)
    local datas__DamageScaling, datas__ArtOfWarChance = {}, {}
    do
        local i226 = 0
        while (i226 < 3) do
            do
                local item__DamageScaling, item__ArtOfWarChance = SF__.CrusaderStrike.GetAbilityData((i226 + 1))
                table.insert(datas__DamageScaling, item__DamageScaling)
                table.insert(datas__ArtOfWarChance, item__ArtOfWarChance)
            end
            ::continue::
            i226 = (i226 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p225, SF__.CrusaderStrike.ID, "学习十字军打击 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p225, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击造成一次攻击伤害，伤害系数随技能等级提升。产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 6秒\n\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling[(0 + 1)] * 100)), "%|r的攻击伤害。\n|cffffcc002级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling[(1 + 1)] * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas__ArtOfWarChance[(1 + 1)] * 100)), "%的战争艺术触发几率。\n|cffffcc003级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling[(2 + 1)] * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas__ArtOfWarChance[(2 + 1)] * 100)), "%的战争艺术触发几率。"), 0)
    do
        local i227 = 0
        while (i227 < 3) do
            local data__DamageScaling, data__ArtOfWarChance = datas__DamageScaling[(i227 + 1)], datas__ArtOfWarChance[(i227 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p225, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击 - [|cffffcc00", (i227 + 1), "级|r]"), i227)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p225, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击造成一次攻击伤害，造成|cffff8c00", string.format("%.0f", (data__DamageScaling * 100)), "%|r的攻击伤害", SF__.Ternary__((i227 > 0), SF__.StrConcat__("，", string.format("%.0f", (data__ArtOfWarChance * 100)), "%的战争艺术触发几率"), ""), "。产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 6秒"), i227)
            ::continue::
            i227 = (i227 + 1)
        end
    end
    -- datas.Remove(new IAbilityData { DamageScaling = 0.65f, ArtOfWarChance = 0 });
    do
        local index = 0
        table.remove(datas__DamageScaling, (index + 1))
        table.remove(datas__ArtOfWarChance, (index + 1))
    end
end

function SF__.CrusaderStrike.Start(data228)
    local level229 = GetUnitAbilityLevel(data228.caster, SF__.CrusaderStrike.ID)
    local UnitAttribute230 = require("Objects.UnitAttribute")
    local EventCenter232 = require("Lib.EventCenter")
    local ad__DamageScaling, ad__ArtOfWarChance = SF__.CrusaderStrike.GetAbilityData(level229)
    local attr = UnitAttribute230.GetAttr(data228.caster)
    local damage231 = (attr:SimAttack(UnitAttribute230.HeroAttributeType.Strength) * ad__DamageScaling)
    EventCenter232.Damage:Emit({whichUnit = data228.caster, target = data228.target, amount = damage231, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
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

function SF__.CrusaderStrike.IAbilityData.Equals(self__DamageScaling233, self__ArtOfWarChance234, other__DamageScaling, other__ArtOfWarChance)
    return ((math.abs((self__DamageScaling233 - other__DamageScaling)) < 0.0001) and (math.abs((self__ArtOfWarChance234 - other__ArtOfWarChance)) < 0.0001))
end

function SF__.CrusaderStrike.IAbilityData.GetHashValue(self__DamageScaling235, self__ArtOfWarChance236)
    return 0
end
-- DivineToll
SF__.DivineToll = SF__.DivineToll or {}
function SF__.DivineToll.GetAbilityData(level237)
    return (2 + level237), (50 * level237), 0.1, 10
end

function SF__.DivineToll.Init()
    local EventCenter239 = require("Lib.EventCenter")
    EventCenter239.RegisterPlayerUnitSpellEffect:Emit({id = SF__.DivineToll.ID, handler = function(data238)
        SF__.DivineToll.Start(data238)
    end})
    ExTriggerRegisterNewUnit(function(u240)
        if (GetUnitTypeId(u240) == FourCC("Hpal")) then
            SF__.DivineToll.UpdateAbilityMeta(u240)
        end
    end)
end

function SF__.DivineToll.UpdateAbilityMeta(u241)
    local p242 = GetOwningPlayer(u241)
    local datas__TargetCount, datas__Damage243, datas__RadiantDmgAmp, datas__Duration244 = {}, {}, {}, {}
    do
        local i245 = 0
        while (i245 < 3) do
            do
                local item__TargetCount, item__Damage246, item__RadiantDmgAmp, item__Duration247 = SF__.DivineToll.GetAbilityData((i245 + 1))
                table.insert(datas__TargetCount, item__TargetCount)
                table.insert(datas__Damage243, item__Damage246)
                table.insert(datas__RadiantDmgAmp, item__RadiantDmgAmp)
                table.insert(datas__Duration244, item__Duration247)
            end
            ::continue::
            i245 = (i245 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p242, SF__.DivineToll.ID, "学习圣洁鸣钟 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p242, SF__.DivineToll.ID, SF__.StrConcat__("对附近的多个目标施展审判，造成法术伤害，然后神圣之锤环绕圣殿骑士，每次命中敌人使其受到的光辉伤害提高。每个审判产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 30秒\n\n|cffffcc001级|r - 审判最多|cffff8c00", datas__TargetCount[(0 + 1)], "|r个目标，造成|cffff8c00", datas__Damage243[(0 + 1)], "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas__RadiantDmgAmp[(0 + 1)] * 100)), "%|r的光辉易伤，持续|cffff8c00", datas__Duration244[(0 + 1)], "|r秒。\n|cffffcc002级|r - 审判最多|cffff8c00", datas__TargetCount[(1 + 1)], "|r个目标，造成|cffff8c00", datas__Damage243[(1 + 1)], "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas__RadiantDmgAmp[(1 + 1)] * 100)), "%|r的光辉易伤，持续|cffff8c00", datas__Duration244[(1 + 1)], "|r秒。\n|cffffcc003级|r - 审判最多|cffff8c00", datas__TargetCount[(2 + 1)], "|r个目标，造成|cffff8c00", datas__Damage243[(2 + 1)], "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas__RadiantDmgAmp[(2 + 1)] * 100)), "%|r的光辉易伤，持续|cffff8c00", datas__Duration244[(2 + 1)], "|r秒。"), 0)
    do
        local i248 = 0
        while (i248 < 3) do
            local data__TargetCount, data__Damage249, data__RadiantDmgAmp, data__Duration250 = datas__TargetCount[(i248 + 1)], datas__Damage243[(i248 + 1)], datas__RadiantDmgAmp[(i248 + 1)], datas__Duration244[(i248 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p242, SF__.DivineToll.ID, SF__.StrConcat__("圣洁鸣钟 - [|cffffcc00", (i248 + 1), "级|r]"), i248)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p242, SF__.DivineToll.ID, SF__.StrConcat__("对附近的最多|cffff8c00", data__TargetCount, "|r个目标施展审判，造成|cffff8c00", data__Damage249, "|r点法术伤害，然后神圣之锤环绕圣殿骑士，每次命中敌人使其受到的光辉伤害提高|cffff8c00", string.format("%.0f", (data__RadiantDmgAmp * 100)), "%|r，持续|cffff8c00", data__Duration250, "|r秒。每个审判产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 30秒"), i248)
            ::continue::
            i248 = (i248 + 1)
        end
    end
end

function SF__.DivineToll.Start(data251)
    return SF__.CorRun__(function()
        local pos__x252, pos__y253 = SF__.Vector2.FromUnit(data251.caster)
        local eff254 = AddSpecialEffect("Abilities/Spells/Human/StormBolt/StormBoltMissile.mdl", pos__x252, pos__y253)
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
function SF__.DivineToll.IAbilityData.Equals(self__TargetCount, self__Damage255, self__RadiantDmgAmp, self__Duration256, other__TargetCount, other__Damage257, other__RadiantDmgAmp, other__Duration258)
    return (((math.abs((self__Damage255 - other__Damage257)) < 0.0001) and (math.abs((self__Duration256 - other__Duration258)) < 0.0001)) and (math.abs((self__RadiantDmgAmp - other__RadiantDmgAmp)) < 0.0001))
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

function SF__.GameObject.__Init__sgameobject(self, name3, parent4)
    self.__sf_type = SF__.GameObject
    self.name = nil
    self.transform = nil
    self._components = SF__.ListNew__({})
    self.transform:SetParent(parent4.transform)
end

function SF__.GameObject.New__sgameobject(name3, parent4)
    local self = setmetatable({}, { __index = SF__.GameObject })
    SF__.GameObject.__Init__sgameobject(self, name3, parent4)
    return self
end

function SF__.GameObject:GetComponent(T)
    do
        local collection4 = self._components
        for i5, comp5 in SF__.ListIterate__(collection4) do
            do
                local tComp = comp5
                if SF__.TypeIs__(tComp, T) then
                    return tComp
                end
            end
        end
    end
    return nil
end

function SF__.GameObject:AddComponent(T6)
    local comp7 = T6.New()
    SF__.ListAdd__(self._components, comp7)
    comp7:Awake()
    comp7:OnEnable()
    comp7:Start()
    return comp7
end

function SF__.GameObject:RemoveAllComponents(T8)
    do
        local i = (SF__.ListCount__(self._components) - 1)
        while (i >= 0) do
            if SF__.TypeIs__(SF__.ListGet__(self._components, i), T8) then
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
    do
        local collection6 = self._components
        for i7, comp9 in SF__.ListIterate__(collection6) do
            comp9:Update()
        end
    end
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
    SF__.ListAdd__(systems, InspectorSystem.new())
    SF__.ListAdd__(systems, require("System.BuffDisplaySystem").new())
    SF__.ListAdd__(systems, SF__.Systems.MeleeGameSystem.New())
    do
        local collection8 = systems
        for i9, system in SF__.ListIterate__(collection8) do
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
        local collection10 = systems
        for i11, system1 in SF__.ListIterate__(collection10) do
            system1:OnEnable()
        end
    end
    local game = FrameTimer.new(function(dt)
        local now = (MathRound((Time.Time * 100)) * 0.01)
        do
            local collection12 = systems
            for i13, system2 in SF__.ListIterate__(collection12) do
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
    local roll13 = math.atan2(sinr_cosp, cosr_cosp)
    local sinp = (2 * ((self__w * self__y) - (self__z * self__x)))
    local pitch14
    if (math.abs(sinp) >= 1) then
        pitch14 = ((math.sign(sinp) * math.pi) / 2)
        -- use 90 degrees if out of range
    else
        pitch14 = math.asin(sinp)
    end
    local siny_cosp = (2 * ((self__w * self__z) + (self__x * self__y)))
    local cosy_cosp = (1 - (2 * ((self__y * self__y) + (self__z * self__z))))
    local yaw15 = math.atan2(siny_cosp, cosy_cosp)
    return pitch14, yaw15, roll13
end

function SF__.Quaternion.Equals(self__x16, self__y17, self__z18, self__w19, other__x, other__y, other__z, other__w)
    return ((((math.abs((self__x16 - other__x)) < 0.0001) and (math.abs((self__y17 - other__y)) < 0.0001)) and (math.abs((self__z18 - other__z)) < 0.0001)) and (math.abs((self__w19 - other__w)) < 0.0001))
end

function SF__.Quaternion.ToString(self__x20, self__y21, self__z22, self__w23)
    return SF__.StrConcat__("(", self__x20, ", ", self__y21, ", ", self__z22, ", ", self__w23, ")")
end

function SF__.Quaternion.ApplyToEffect(self__x24, self__y25, self__z26, self__w27, e)
    local angles__x, angles__y, angles__z = SF__.Quaternion.get_EulerAngles(self__x24, self__y25, self__z26, self__w27)
    BlzSetSpecialEffectOrientation(e, angles__y, angles__x, angles__z)
end
-- RetributionPaladinGlobal
SF__.RetributionPaladinGlobal = SF__.RetributionPaladinGlobal or {}
function SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(u259, amount)
    local UnitAttribute261 = require("Objects.UnitAttribute")
    local attr260 = UnitAttribute261.GetAttr(u259)
    attr260.retPalHolyEnergy = math.min((attr260.retPalHolyEnergy + amount), 5)
end

function SF__.RetributionPaladinGlobal:Init()
    ExTriggerRegisterNewUnit(function(u262)
        if (GetUnitTypeId(u262) == FourCC("Hpal")) then
            SF__.ListAdd__(self._units, u262)
        end
    end)
    _ = self:Start()
end

function SF__.RetributionPaladinGlobal:Start()
    return SF__.CorRun__(function()
        local UnitAttribute265 = require("Objects.UnitAttribute")
        while true do
            do
                local collection14 = self._units
                for i15, u263 in SF__.ListIterate__(collection14) do
                    local attr264 = UnitAttribute265.GetAttr(u263)
                    ExSetUnitMana(u263, ((ExGetUnitMaxMana(u263) * attr264.retPalHolyEnergy) * 0.2))
                    if (attr264.retPalHolyEnergy >= 3) then
                        SF__.Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u263), FourCC("A006"), "ReplaceableTextures/CommandButtons/BTNinv_helmet_96.tga")
                    else
                        SF__.Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u263), FourCC("A006"), "ReplaceableTextures/PassiveButtons/PASBTNinv_helmet_96.tga")
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

function SF__.Scene:AddGameObject(obj10)
    SF__.ListAdd__(self.gameObjs, obj10)
end

function SF__.Scene:Run()
    return SF__.CorRun__(function()
        do
            local collection16 = self.gameObjs
            for i17, obj11 in SF__.ListIterate__(collection16) do
                SF__.CorWait__(20)
                obj11:Update()
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
    local item28 = SF__.ListGet__(self._items, (SF__.ListCount__(self._items) - 1))
    SF__.ListRemoveAt__(self._items, (SF__.ListCount__(self._items) - 1))
    return item28
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
SF__.Systems.InspectorSystem = SF__.Systems.InspectorSystem or {}
-- Systems.InspectorSystem.HierarchyRow
SF__.Systems.InspectorSystem.HierarchyRow = SF__.Systems.InspectorSystem.HierarchyRow or {}
function SF__.Systems.InspectorSystem.HierarchyRow.__Init(self, button, label)
    self.__sf_type = SF__.Systems.InspectorSystem.HierarchyRow
    self.button = nil
    self.label = nil
    self.gameObject = nil
    self.depth = 0
    self.button = button
    self.label = label
end

function SF__.Systems.InspectorSystem.HierarchyRow.New(button, label)
    local self = setmetatable({}, { __index = SF__.Systems.InspectorSystem.HierarchyRow })
    SF__.Systems.InspectorSystem.HierarchyRow.__Init(self, button, label)
    return self
end
-- Systems.MeleeGameSystem
local SystemBase12 = require("System.SystemBase")
SF__.Systems.MeleeGameSystem = SF__.Systems.MeleeGameSystem or class("MeleeGameSystem", SystemBase12)
SF__.Systems.MeleeGameSystem.__sf_base = SystemBase12
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
function SF__.TemplarStrikes.GetAbilityData(level266)
    return 2, (0.5 + (0.25 * level266)), (0.05 * level266)
end

function SF__.TemplarStrikes.Init()
    local EventCenter267 = require("Lib.EventCenter")
    EventCenter267.RegisterPlayerUnitSpellEffect:Emit({id = SF__.TemplarStrikes.ID, handler = SF__.TemplarStrikes.Start})
    ExTriggerRegisterNewUnit(function(u268)
        if (GetUnitTypeId(u268) == FourCC("Hpal")) then
            SF__.TemplarStrikes.UpdateAbilityMeta(u268)
            SetHeroLevel(u268, 10, true)
        end
    end)
    EventCenter267.RegisterPlayerUnitDamaged:Emit(function(caster269, target270, damage271, weapType, dmgType, isAttack)
        if (GetUnitAbilityLevel(caster269, SF__.TemplarStrikes.ID) <= 0) then
            return
        end
        if (not isAttack) then
            return
        end
        if (target270 == nil) then
            return
        end
        if ExIsUnitDead(target270) then
            return
        end
        SF__.TemplarStrikes.TryResetBOJ(caster269)
    end)
end

function SF__.TemplarStrikes.TryResetBOJ(caster272)
    local level273 = GetUnitAbilityLevel(caster272, SF__.TemplarStrikes.ID)
    local ad__AttackCount, ad__DamageScaling274, ad__ResetBOJChance = SF__.TemplarStrikes.GetAbilityData(level273)
    if (math.random() >= ad__ResetBOJChance) then
        return
    end
    BlzEndUnitAbilityCooldown(caster272, SF__.BladeOfJustice.ID)
    ExAddSpecialEffectTarget("Abilities/Spells/Items/AIam/AIamTarget.mdl", caster272, "origin", 0.3)
end

function SF__.TemplarStrikes.UpdateAbilityMeta(u275)
    local p276 = GetOwningPlayer(u275)
    local datas__AttackCount, datas__DamageScaling277, datas__ResetBOJChance = {}, {}, {}
    do
        local i278 = 0
        while (i278 < SF__.TemplarStrikes.MaxLevel) do
            do
                local item__AttackCount, item__DamageScaling279, item__ResetBOJChance = SF__.TemplarStrikes.GetAbilityData((i278 + 1))
                table.insert(datas__AttackCount, item__AttackCount)
                table.insert(datas__DamageScaling277, item__DamageScaling279)
                table.insert(datas__ResetBOJChance, item__ResetBOJChance)
            end
            ::continue::
            i278 = (i278 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p276, SF__.TemplarStrikes.ID, "学习圣殿骑士之击 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p276, SF__.TemplarStrikes.ID, SF__.StrConcat__("快速攻击目标|cffff8c00", datas__AttackCount[(0 + 1)], "|r次，第一次造成普通攻击伤害，第二次造成光辉伤害，有一定几率重置公正之剑的冷却时间，普通攻击也会触发。\n\n|cff99ccff冷却时间|r - 10秒\n\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling277[(0 + 1)] * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas__ResetBOJChance[(0 + 1)] * 100)), "%|r的几率重置公正之剑。\n|cffffcc002级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling277[(1 + 1)] * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas__ResetBOJChance[(1 + 1)] * 100)), "%|r的几率重置公正之剑。\n|cffffcc003级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling277[(2 + 1)] * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas__ResetBOJChance[(2 + 1)] * 100)), "%|r的几率重置公正之剑。"), 0)
    do
        local i280 = 0
        while (i280 < SF__.TemplarStrikes.MaxLevel) do
            local data__AttackCount, data__DamageScaling281, data__ResetBOJChance = datas__AttackCount[(i280 + 1)], datas__DamageScaling277[(i280 + 1)], datas__ResetBOJChance[(i280 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p276, SF__.TemplarStrikes.ID, SF__.StrConcat__("圣殿骑士之击 - [|cffffcc00", (i280 + 1), "级|r]"), i280)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p276, SF__.TemplarStrikes.ID, SF__.StrConcat__("快速攻击目标|cffff8c00", data__AttackCount, "|r次，第一次造成普通攻击伤害，第二次造成普通攻击|cffff8c00", string.format("%.0f", (data__DamageScaling281 * 100)), "%|r的光辉伤害，|cffff8c00", string.format("%.0f", (data__ResetBOJChance * 100)), "%|r几率重置公正之剑的冷却时间，普通攻击也会触发。\n\n|cff99ccff冷却时间|r - 10秒"), i280)
            ::continue::
            i280 = (i280 + 1)
        end
    end
end

function SF__.TemplarStrikes.Start(data282)
    return SF__.CorRun__(function()
        local level283 = GetUnitAbilityLevel(data282.caster, SF__.TemplarStrikes.ID)
        local UnitAttribute285 = require("Objects.UnitAttribute")
        local EventCenter286 = require("Lib.EventCenter")
        local attr284 = UnitAttribute285.GetAttr(data282.caster)
        local normalDamage = attr284:SimMeleeAttack()
        EventCenter286.Damage:Emit({whichUnit = data282.caster, target = data282.target, amount = normalDamage, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
        SF__.TemplarStrikes.TryResetBOJ(data282.caster)
        SetUnitTimeScale(data282.caster, 3)
        ResetUnitAnimation(data282.caster)
        SetUnitAnimation(data282.caster, "attack - 2")
        SF__.CorWait__(math.round(((1.166 * 0.33) * 1000)))
        local tarAttr287 = UnitAttribute285.GetAttr(data282.target)
        local ad__AttackCount288, ad__DamageScaling289, ad__ResetBOJChance290 = SF__.TemplarStrikes.GetAbilityData(level283)
        local radiantDamage = ((attr284:SimMeleeAttack() * ad__DamageScaling289) * (1 - tarAttr287.radiantResistance))
        EventCenter286.Damage:Emit({whichUnit = data282.caster, target = data282.target, amount = radiantDamage, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
        SF__.TemplarStrikes.TryResetBOJ(data282.caster)
        SetUnitTimeScale(data282.caster, 1)
        ResetUnitAnimation(data282.caster)
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
function SF__.TemplarStrikes.IAbilityData.Equals(self__AttackCount, self__DamageScaling291, self__ResetBOJChance, other__AttackCount, other__DamageScaling292, other__ResetBOJChance)
    return ((math.abs((self__DamageScaling291 - other__DamageScaling292)) < 0.0001) and (math.abs((self__ResetBOJChance - other__ResetBOJChance)) < 0.0001))
end
-- TemplarVerdict
SF__.TemplarVerdict = SF__.TemplarVerdict or {}
function SF__.TemplarVerdict.GetAbilityData(level293)
    return 2.25, 0.3, 0.15
end

function SF__.TemplarVerdict.Init()
    local EventCenter294 = require("Lib.EventCenter")
    EventCenter294.RegisterPlayerUnitSpellChannel:Emit({id = SF__.TemplarVerdict.ID, handler = SF__.TemplarVerdict.Check})
    EventCenter294.RegisterPlayerUnitSpellEffect:Emit({id = SF__.TemplarVerdict.ID, handler = SF__.TemplarVerdict.Start})
    ExTriggerRegisterNewUnit(function(u295)
        if (GetUnitTypeId(u295) == FourCC("Hpal")) then
            SF__.TemplarVerdict.UpdateAbilityMeta(u295)
        end
    end)
end

function SF__.TemplarVerdict.Check(data296)
    local UnitAttribute298 = require("Objects.UnitAttribute")
    local attr297 = UnitAttribute298.GetAttr(data296.caster)
    if (attr297.retPalHolyEnergy < 3) then
        IssueImmediateOrderById(data296.caster, SF__.ConstOrderId.Stop)
        ExTextState(data296.caster, "圣能不足")
    end
end

function SF__.TemplarVerdict.UpdateAbilityMeta(u299)
    local p300 = GetOwningPlayer(u299)
    local datas__DamageScaling301, datas__JudgementDamageScaling, datas__ChanceToResetJudgement = {}, {}, {}
    do
        local i302 = 0
        while (i302 < 1) do
            do
                local item__DamageScaling303, item__JudgementDamageScaling, item__ChanceToResetJudgement = SF__.TemplarVerdict.GetAbilityData((i302 + 1))
                table.insert(datas__DamageScaling301, item__DamageScaling303)
                table.insert(datas__JudgementDamageScaling, item__JudgementDamageScaling)
                table.insert(datas__ChanceToResetJudgement, item__ChanceToResetJudgement)
            end
            ::continue::
            i302 = (i302 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p300, SF__.TemplarVerdict.ID, "学习圣殿骑士的裁决 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p300, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决造成一次攻击伤害，如果目标被审判，造成30%的额外伤害，15%几率重置审判。消耗|cffff8c003|r点圣能。\n\n|cff99ccff冷却时间|r - 5秒\n\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas__JudgementDamageScaling[(0 + 1)] * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas__ChanceToResetJudgement[(0 + 1)] * 100)), "%的战争艺术触发几率。"), 0)
    do
        local i304 = 0
        while (i304 < 1) do
            local data__DamageScaling305, data__JudgementDamageScaling, data__ChanceToResetJudgement = datas__DamageScaling301[(i304 + 1)], datas__JudgementDamageScaling[(i304 + 1)], datas__ChanceToResetJudgement[(i304 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p300, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决 - [|cffffcc00", (i304 + 1), "级|r]"), i304)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p300, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决造成一次攻击伤害，造成|cffff8c00", string.format("%.0f", (data__DamageScaling305 * 100)), "%|r的攻击伤害。消耗|cffff8c003|r点圣能。\n\n|cff99ccff冷却时间|r - 5秒"), i304)
            ::continue::
            i304 = (i304 + 1)
        end
    end
end

function SF__.TemplarVerdict.Start(data306)
    local level307 = GetUnitAbilityLevel(data306.caster, SF__.TemplarVerdict.ID)
    local UnitAttribute310 = require("Objects.UnitAttribute")
    local EventCenter312 = require("Lib.EventCenter")
    local ad__DamageScaling308, ad__JudgementDamageScaling, ad__ChanceToResetJudgement = SF__.TemplarVerdict.GetAbilityData(level307)
    local attr309 = UnitAttribute310.GetAttr(data306.caster)
    local damage311 = (attr309:SimAttack(UnitAttribute310.HeroAttributeType.Strength) * ad__DamageScaling308)
    EventCenter312.Damage:Emit({whichUnit = data306.caster, target = data306.target, amount = damage311, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_SLICE, outResult = {}})
    attr309.retPalHolyEnergy = (attr309.retPalHolyEnergy - 3)
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
function SF__.TemplarVerdict.IAbilityData.Equals(self__DamageScaling313, self__JudgementDamageScaling, self__ChanceToResetJudgement, other__DamageScaling314, other__JudgementDamageScaling, other__ChanceToResetJudgement)
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
    self.position = {x = 0, y = 0, z = 0}
    self.rotation = SF__.Quaternion.Euler(0, 0, 0)
    self.localScale = {x = 1, y = 1, z = 1}
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
    return SF__.StrConcat__("Position ", self.position, "\n", "Rotation ", self.rotation, "\n", "Scale ", self.localScale, "\n", "Children ", SF__.ListCount__(self.children))
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

function SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p29, abilCode30, researchExtendedTooltip, level31)
    if (GetLocalPlayer() ~= p29) then
        return
    end
    BlzSetAbilityResearchExtendedTooltip(abilCode30, researchExtendedTooltip, level31)
end

function SF__.Utils.ExBlzSetAbilityTooltip(p32, abilCode33, tooltip, level34)
    if (GetLocalPlayer() ~= p32) then
        return
    end
    BlzSetAbilityTooltip(abilCode33, tooltip, level34)
end

function SF__.Utils.ExBlzSetAbilityExtendedTooltip(p35, abilCode36, extendedTooltip, level37)
    if (GetLocalPlayer() ~= p35) then
        return
    end
    BlzSetAbilityExtendedTooltip(abilCode36, extendedTooltip, level37)
end

function SF__.Utils.ExBlzSetAbilityIcon(p38, abilCode39, iconPath)
    if (GetLocalPlayer() ~= p38) then
        return
    end
    BlzSetAbilityIcon(abilCode39, iconPath)
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

function SF__.Vector2.Dot(a__x40, a__y41, b__x42, b__y43)
    return ((a__x40 * b__x42) + (a__y41 * b__y43))
end

function SF__.Vector2.Cross(a__x44, a__y45, b__x46, b__y47)
    return ((a__y45 * b__x46) - (a__x44 * b__y47))
end

function SF__.Vector2.op_UnaryNegation(a__x48, a__y49)
    return (-a__x48), (-a__y49)
end

function SF__.Vector2.op_Addition(a__x50, a__y51, b__x52, b__y53)
    return (a__x50 + b__x52), (a__y51 + b__y53)
end

function SF__.Vector2.op_Subtraction(a__x54, a__y55, b__x56, b__y57)
    return (a__x54 - b__x56), (a__y55 - b__y57)
end

function SF__.Vector2.op_Multiply__vector2f(v__x58, v__y59, f)
    return (v__x58 * f), (v__y59 * f)
end

function SF__.Vector2.op_Multiply__fvector2(f60, v__x61, v__y62)
    return (v__x61 * f60), (v__y62 * f60)
end

function SF__.Vector2.op_Division(v__x63, v__y64, f65)
    return (v__x63 / f65), (v__y64 / f65)
end

function SF__.Vector2.op_Equality(a__x66, a__y67, b__x68, b__y69)
    return ((math.abs((a__x66 - b__x68)) < 0.0001) and (math.abs((a__y67 - b__y69)) < 0.0001))
end

function SF__.Vector2.op_Inequality(a__x70, a__y71, b__x72, b__y73)
    return (not SF__.Vector2.op_Equality(a__x70, a__y71, b__x72, b__y73))
end

function SF__.Vector2.UnitDistance(a, b)
    local v1__x, v1__y = SF__.Vector2.FromUnit(a)
    local v2__x, v2__y = SF__.Vector2.FromUnit(b)
    return SF__.Vector2.get_Magnitude(SF__.Vector2.op_Subtraction(v1__x, v1__y, v2__x, v2__y))
end

function SF__.Vector2.SqrUnitDistance(a74, b75)
    local v1__x76, v1__y77 = SF__.Vector2.FromUnit(a74)
    local v2__x78, v2__y79 = SF__.Vector2.FromUnit(b75)
    return SF__.Vector2.get_SqrMagnitude(SF__.Vector2.op_Subtraction(v1__x76, v1__y77, v2__x78, v2__y79))
end

function SF__.Vector2.FromUnit(u)
    return GetUnitX(u), GetUnitY(u)
end

function SF__.Vector2.get_Magnitude(self__x80, self__y81)
    return math.sqrt(SF__.Vector2.get_SqrMagnitude(self__x80, self__y81))
end

function SF__.Vector2.get_SqrMagnitude(self__x82, self__y83)
    return ((self__x82 * self__x82) + (self__y83 * self__y83))
end

function SF__.Vector2.get_Normalized(self__x84, self__y85)
    local mag = SF__.Vector2.get_Magnitude(self__x84, self__y85)
    if (mag < 0.0001) then
        return SF__.Vector2.get_Zero()
    end
    return SF__.Vector2.op_Division(self__x84, self__y85, mag)
end

function SF__.Vector2.ClampMagnitude(self__x88, self__y89, mag90)
    return SF__.Vector2.op_Multiply__vector2f(SF__.Vector2.get_Normalized(self__x88, self__y89), mag90)
end

function SF__.Vector2.Equals(self__x91, self__y92, other__x93, other__y94)
    return SF__.Vector2.op_Equality(self__x91, self__y92, other__x93, other__y94)
end

function SF__.Vector2.ToString(self__x95, self__y96)
    return SF__.StrConcat__("(", self__x95, ", ", self__y96, ")")
end

function SF__.Vector2.Rotate(self__x97, self__y98, angle99)
    local cos = math.cos(angle99)
    local sin = math.sin(angle99)
    return ((self__x97 * cos) - (self__y98 * sin)), ((self__x97 * sin) + (self__y98 * cos))
end

function SF__.Vector2.UnitMoveTo(self__x100, self__y101, u102)
    SetUnitX(u102, self__x100)
    SetUnitY(u102, self__y101)
end

function SF__.Vector2.GetTerrainZ(self__x103, self__y104)
    MoveLocation(SF__.Vector2._loc, self__x103, self__y104)
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

function SF__.Vector3.op_Addition(a__x105, a__y106, a__z107, b__x108, b__y109, b__z110)
    return (a__x105 + b__x108), (a__y106 + b__y109), (a__z107 + b__z110)
end

function SF__.Vector3.op_UnaryNegation(a__x111, a__y112, a__z113)
    return (-a__x111), (-a__y112), (-a__z113)
end

function SF__.Vector3.op_Subtraction(a__x114, a__y115, a__z116, b__x117, b__y118, b__z119)
    return (a__x114 - b__x117), (a__y115 - b__y118), (a__z116 - b__z119)
end

function SF__.Vector3.op_Multiply__vector3f(v__x120, v__y121, v__z122, f123)
    return (v__x120 * f123), (v__y121 * f123), (v__z122 * f123)
end

function SF__.Vector3.op_Multiply__fvector3(f124, v__x125, v__y126, v__z127)
    return (v__x125 * f124), (v__y126 * f124), (v__z127 * f124)
end

function SF__.Vector3.op_Division(v__x128, v__y129, v__z130, f131)
    return (v__x128 / f131), (v__y129 / f131), (v__z130 / f131)
end

function SF__.Vector3.op_Equality(a__x132, a__y133, a__z134, b__x135, b__y136, b__z137)
    return (((math.abs((a__x132 - b__x135)) < 0.0001) and (math.abs((a__y133 - b__y136)) < 0.0001)) and (math.abs((a__z134 - b__z137)) < 0.0001))
end

function SF__.Vector3.op_Inequality(a__x138, a__y139, a__z140, b__x141, b__y142, b__z143)
    return (not SF__.Vector3.op_Equality(a__x138, a__y139, a__z140, b__x141, b__y142, b__z143))
end

function SF__.Vector3.Dot(a__x144, a__y145, a__z146, b__x147, b__y148, b__z149)
    return (((a__x144 * b__x147) + (a__y145 * b__y148)) + (a__z146 * b__z149))
end

function SF__.Vector3.Scale(a__x150, a__y151, a__z152, b__x153, b__y154, b__z155)
    return (a__x150 * b__x153), (a__y151 * b__y154), (a__z152 * b__z155)
end

-- <summary>
-- Warcraft III world space here is right-handed: +x points right, +y points away, +z points up.
-- That means Cross((1,0,0), (0,1,0)) == (0,0,1).
-- </summary>
--
function SF__.Vector3.Cross(a__x156, a__y157, a__z158, b__x159, b__y160, b__z161)
    return ((a__y157 * b__z161) - (a__z158 * b__y160)), ((a__z158 * b__x159) - (a__x156 * b__z161)), ((a__x156 * b__y160) - (a__y157 * b__x159))
end

function SF__.Vector3.Project(v__x162, v__y163, v__z164, onNormal__x, onNormal__y, onNormal__z)
    local sqrMag = SF__.Vector3.Dot(onNormal__x, onNormal__y, onNormal__z, onNormal__x, onNormal__y, onNormal__z)
    if (sqrMag < 0.0001) then
        return SF__.Vector3.get_Zero()
    end
    local dot = SF__.Vector3.Dot(v__x162, v__y163, v__z164, onNormal__x, onNormal__y, onNormal__z)
    return SF__.Vector3.op_Multiply__vector3f(onNormal__x, onNormal__y, onNormal__z, (dot / sqrMag))
end

function SF__.Vector3.ProjectOnPlane(v__x165, v__y166, v__z167, planeNormal__x, planeNormal__y, planeNormal__z)
    return SF__.Vector3.op_Subtraction(v__x165, v__y166, v__z167, SF__.Vector3.Project(v__x165, v__y166, v__z167, planeNormal__x, planeNormal__y, planeNormal__z))
end

function SF__.Vector3._getTerrainZ(x168, y169)
    MoveLocation(SF__.Vector3._loc, x168, y169)
    return GetLocationZ(SF__.Vector3._loc)
end

function SF__.Vector3.FromUnit(u170)
    local x171 = GetUnitX(u170)
    local y172 = GetUnitY(u170)
    return x171, y172, (SF__.Vector3._getTerrainZ(x171, y172) + GetUnitFlyHeight(u170))
end

function SF__.Vector3.get_SqrMagnitude(self__x173, self__y174, self__z175)
    return (((self__x173 * self__x173) + (self__y174 * self__y174)) + (self__z175 * self__z175))
end

function SF__.Vector3.get_Magnitude(self__x176, self__y177, self__z178)
    return math.sqrt(SF__.Vector3.get_SqrMagnitude(self__x176, self__y177, self__z178))
end

function SF__.Vector3.get_Normalized(self__x179, self__y180, self__z181)
    local mag182 = SF__.Vector3.get_Magnitude(self__x179, self__y180, self__z181)
    if (mag182 < 0.0001) then
        return SF__.Vector3.get_Zero()
    end
    return SF__.Vector3.op_Division(self__x179, self__y180, self__z181, mag182)
end

function SF__.Vector3.ClampMagnitude(self__x186, self__y187, self__z188, mag189)
    return SF__.Vector3.op_Multiply__vector3f(SF__.Vector3.get_Normalized(self__x186, self__y187, self__z188), mag189)
end

function SF__.Vector3.Equals(self__x190, self__y191, self__z192, other__x193, other__y194, other__z195)
    return SF__.Vector3.op_Equality(self__x190, self__y191, self__z192, other__x193, other__y194, other__z195)
end

function SF__.Vector3.ToString(self__x196, self__y197, self__z198)
    return SF__.StrConcat__("(", self__x196, ", ", self__y197, ", ", self__z198, ")")
end

function SF__.Vector3.UnitMoveTo(self__x199, self__y200, self__z201, u202, mode)
    if mode == nil then mode = SF__.UnitVec3Mode.Auto end
    local tz = SF__.Vector3._getTerrainZ(self__x199, self__y200)
    local LuaUtils = require("Lib.Utils")
    local defaultFlyHeight = GetUnitDefaultFlyHeight(u202)
    local minZ = (tz + defaultFlyHeight)
    SetUnitPosition(u202, self__x199, self__y200)
    repeat
        local switchValue = mode
        if (switchValue == SF__.UnitVec3Mode.ForceFlying) then
            LuaUtils.SetUnitFlyable(u202)
            SetUnitFlyHeight(u202, (math.max(minZ, self__z201) - minZ), 0)
            break
        elseif (switchValue == SF__.UnitVec3Mode.ForceGround) then
            SetUnitFlyHeight(u202, defaultFlyHeight, 0)
            break
        elseif (switchValue == SF__.UnitVec3Mode.Auto) then
            if IsUnitType(u202, UNIT_TYPE_FLYING) then
                SetUnitFlyHeight(u202, (math.max(minZ, self__z201) - minZ), 0)
            else
                SetUnitFlyHeight(u202, defaultFlyHeight, 0)
            end
            break
        end
    until true
end

function SF__.Vector3.GetTerrainZ(self__x203, self__y204, self__z205)
    return SF__.Vector3._getTerrainZ(self__x203, self__y204)
end

SF__.Vector3._loc = Location(0, 0)
-- WordOfGlory
SF__.WordOfGlory = SF__.WordOfGlory or {}
function SF__.WordOfGlory.Init()
    local EventCenter315 = require("Lib.EventCenter")
    EventCenter315.RegisterPlayerUnitSpellChannel:Emit({id = SF__.WordOfGlory.ID, handler = SF__.WordOfGlory.Check})
    EventCenter315.RegisterPlayerUnitSpellEffect:Emit({id = SF__.WordOfGlory.ID, handler = SF__.WordOfGlory.Start})
    ExTriggerRegisterNewUnit(function(u316)
        if (GetUnitTypeId(u316) == FourCC("Hpal")) then
            SF__.WordOfGlory.UpdateAbilityMeta(u316)
        end
    end)
end

function SF__.WordOfGlory.Check(data317)
    local UnitAttribute319 = require("Objects.UnitAttribute")
    local attr318 = UnitAttribute319.GetAttr(data317.caster)
    if (attr318.retPalHolyEnergy < 3) then
        IssueImmediateOrderById(data317.caster, SF__.ConstOrderId.Stop)
        ExTextState(data317.caster, "圣能不足")
    end
end

function SF__.WordOfGlory.UpdateAbilityMeta(u320)
    local p321 = GetOwningPlayer(u320)
    SF__.Utils.ExSetAbilityResearchTooltip(p321, SF__.WordOfGlory.ID, "学习圣殿骑士的裁决 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p321, SF__.WordOfGlory.ID, "圣殿骑士的裁决造成一次攻击伤害，如果目标被审判，造成30%的额外伤害，15%几率重置审判。消耗|cffff8c003|r点圣能。\n\n|cff99ccff冷却时间|r - 5秒\n\n|cffffcc001级|r - |cffff8c00100%|r的攻击伤害，100%的战争艺术触发几率。", 0)
    do
        local i322 = 0
        while (i322 < 1) do
            SF__.Utils.ExBlzSetAbilityTooltip(p321, SF__.WordOfGlory.ID, SF__.StrConcat__("圣殿骑士的裁决 - [|cffffcc00", (i322 + 1), "级|r]"), i322)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p321, SF__.WordOfGlory.ID, "圣殿骑士的裁决造成一次攻击伤害，造成|cffff8c00100%|r的攻击伤害。消耗|cffff8c003|r点圣能。\n\n|cff99ccff冷却时间|r - 5秒", i322)
            ::continue::
            i322 = (i322 + 1)
        end
    end
end

function SF__.WordOfGlory.Start(data323)
    local UnitAttribute325 = require("Objects.UnitAttribute")
    local EventCenter326 = require("Lib.EventCenter")
    local attr324 = UnitAttribute325.GetAttr(data323.caster)
    EventCenter326.Heal:Emit({caster = data323.caster, target = data323.target, amount = 300})
    attr324.retPalHolyEnergy = (attr324.retPalHolyEnergy - 3)
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
