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
        while (i < 1) do
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
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p17, SF__.BladeOfJustice.ID, SF__.StrConcat__("公正之剑造成一次攻击伤害，如果目标被审判，造成30%的额外伤害，15%几率重置审判。消耗|cffff8c003|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 5秒\r\n\r\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas__Damage[(0 + 1)] * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas__Damage[(0 + 1)] * 100)), "%的战争艺术触发几率。"), 0)
    do
        local i18 = 0
        while (i18 < 1) do
            local data__Damage, data__Duration, data__DamagePerSecond = datas__Damage[(i18 + 1)], datas__Duration[(i18 + 1)], datas__DamagePerSecond[(i18 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p17, SF__.BladeOfJustice.ID, SF__.StrConcat__("公正之剑 - [|cffffcc00", (i18 + 1), "级|r]"), i18)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p17, SF__.BladeOfJustice.ID, SF__.StrConcat__("公正之剑造成一次攻击伤害，造成|cffff8c00", string.format("%.0f", (data__Damage * 100)), "%|r的攻击伤害。消耗|cffff8c003|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 5秒"), i18)
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
function SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(u44, amount)
    local UnitAttribute46 = require("Objects.UnitAttribute")
    local attr45 = UnitAttribute46.GetAttr(u44)
    attr45.retPalHolyEnergy = math.min((attr45.retPalHolyEnergy + amount), 5)
end

function SF__.RetributionPaladinGlobal:Init()
    ExTriggerRegisterNewUnit(function(u47)
        if (GetUnitTypeId(u47) == FourCC("Hpal")) then
            SF__.ListAdd__(self._units, u47)
        end
    end)
    _ = self:Start()
end

function SF__.RetributionPaladinGlobal:Start()
    return SF__.CorRun__(function()
        local UnitAttribute50 = require("Objects.UnitAttribute")
        while true do
            do
                local collection6 = self._units
                for i7, u48 in SF__.ListIterate__(collection6) do
                    local attr49 = UnitAttribute50.GetAttr(u48)
                    ExSetUnitMana(u48, ((ExGetUnitMaxMana(u48) * attr49.retPalHolyEnergy) * 0.2))
                    if (attr49.retPalHolyEnergy >= 3) then
                        SF__.Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u48), FourCC("A006"), "ReplaceableTextures/CommandButtons/BTNinv_helmet_96.tga")
                    else
                        SF__.Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u48), FourCC("A006"), "ReplaceableTextures/PassiveButtons/PASBTNinv_helmet_96.tga")
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
function SF__.TemplarStrikes.GetAbilityData(level51)
    return 2, (0.5 + (0.25 * level51)), (0.05 * level51)
end

function SF__.TemplarStrikes.Init()
    local EventCenter52 = require("Lib.EventCenter")
    EventCenter52.RegisterPlayerUnitSpellEffect:Emit({id = SF__.TemplarStrikes.ID, handler = SF__.TemplarStrikes.Start})
    ExTriggerRegisterNewUnit(function(u53)
        if (GetUnitTypeId(u53) == FourCC("Hpal")) then
            SF__.TemplarStrikes.UpdateAbilityMeta(u53)
            SetHeroLevel(u53, 10, true)
        end
    end)
    EventCenter52.RegisterPlayerUnitDamaged:Emit(function(caster54, target55, damage56, weapType, dmgType, isAttack)
        if (GetUnitAbilityLevel(caster54, SF__.TemplarStrikes.ID) <= 0) then
            return
        end
        if (not isAttack) then
            return
        end
        if (target55 == nil) then
            return
        end
        if ExIsUnitDead(target55) then
            return
        end
        SF__.TemplarStrikes.TryResetBOJ(caster54)
    end)
end

function SF__.TemplarStrikes.TryResetBOJ(caster57)
    local level58 = GetUnitAbilityLevel(caster57, SF__.TemplarStrikes.ID)
    local ad__AttackCount, ad__DamageScaling59, ad__ResetBOJChance = SF__.TemplarStrikes.GetAbilityData(level58)
    if (math.random() >= ad__ResetBOJChance) then
        return
    end
    BlzEndUnitAbilityCooldown(caster57, SF__.BladeOfJustice.ID)
    ExAddSpecialEffectTarget("Abilities/Spells/Items/AIam/AIamTarget.mdl", caster57, "origin", 0.3)
end

function SF__.TemplarStrikes.UpdateAbilityMeta(u60)
    local p61 = GetOwningPlayer(u60)
    local datas__AttackCount, datas__DamageScaling62, datas__ResetBOJChance = {}, {}, {}
    do
        local i63 = 0
        while (i63 < SF__.TemplarStrikes.MaxLevel) do
            do
                local item__AttackCount, item__DamageScaling64, item__ResetBOJChance = SF__.TemplarStrikes.GetAbilityData((i63 + 1))
                table.insert(datas__AttackCount, item__AttackCount)
                table.insert(datas__DamageScaling62, item__DamageScaling64)
                table.insert(datas__ResetBOJChance, item__ResetBOJChance)
            end
            ::continue::
            i63 = (i63 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p61, SF__.TemplarStrikes.ID, "学习圣殿骑士之击 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p61, SF__.TemplarStrikes.ID, SF__.StrConcat__("快速攻击目标|cffff8c00", datas__AttackCount[(0 + 1)], "|r次，第一次造成普通攻击伤害，第二次造成光辉伤害，有一定几率重置公正之剑的冷却时间，普通攻击也会触发。\r\n\r\n|cff99ccff冷却时间|r - 10秒\r\n\r\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling62[(0 + 1)] * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas__ResetBOJChance[(0 + 1)] * 100)), "%|r的几率重置公正之剑。\r\n|cffffcc002级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling62[(1 + 1)] * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas__ResetBOJChance[(1 + 1)] * 100)), "%|r的几率重置公正之剑。\r\n|cffffcc003级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling62[(2 + 1)] * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas__ResetBOJChance[(2 + 1)] * 100)), "%|r的几率重置公正之剑。"), 0)
    do
        local i65 = 0
        while (i65 < SF__.TemplarStrikes.MaxLevel) do
            local data__AttackCount, data__DamageScaling66, data__ResetBOJChance = datas__AttackCount[(i65 + 1)], datas__DamageScaling62[(i65 + 1)], datas__ResetBOJChance[(i65 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p61, SF__.TemplarStrikes.ID, SF__.StrConcat__("圣殿骑士之击 - [|cffffcc00", (i65 + 1), "级|r]"), i65)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p61, SF__.TemplarStrikes.ID, SF__.StrConcat__("快速攻击目标|cffff8c00", data__AttackCount, "|r次，第一次造成普通攻击伤害，第二次造成普通攻击|cffff8c00", string.format("%.0f", (data__DamageScaling66 * 100)), "%|r的光辉伤害，|cffff8c00", string.format("%.0f", (data__ResetBOJChance * 100)), "%|r几率重置公正之剑的冷却时间，普通攻击也会触发。\r\n\r\n|cff99ccff冷却时间|r - 10秒"), i65)
            ::continue::
            i65 = (i65 + 1)
        end
    end
end

function SF__.TemplarStrikes.Start(data67)
    return SF__.CorRun__(function()
        local level68 = GetUnitAbilityLevel(data67.caster, SF__.TemplarStrikes.ID)
        local UnitAttribute70 = require("Objects.UnitAttribute")
        local EventCenter71 = require("Lib.EventCenter")
        local attr69 = UnitAttribute70.GetAttr(data67.caster)
        local normalDamage = attr69:SimMeleeAttack()
        EventCenter71.Damage:Emit({whichUnit = data67.caster, target = data67.target, amount = normalDamage, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
        SF__.TemplarStrikes.TryResetBOJ(data67.caster)
        SetUnitTimeScale(data67.caster, 3)
        ResetUnitAnimation(data67.caster)
        SetUnitAnimation(data67.caster, "attack - 2")
        SF__.CorWait__(math.round(((1.166 * 0.33) * 1000)))
        local tarAttr72 = UnitAttribute70.GetAttr(data67.target)
        local ad__AttackCount73, ad__DamageScaling74, ad__ResetBOJChance75 = SF__.TemplarStrikes.GetAbilityData(level68)
        local radiantDamage = ((attr69:SimMeleeAttack() * ad__DamageScaling74) * (1 - tarAttr72.radiantResistance))
        EventCenter71.Damage:Emit({whichUnit = data67.caster, target = data67.target, amount = radiantDamage, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
        SF__.TemplarStrikes.TryResetBOJ(data67.caster)
        SetUnitTimeScale(data67.caster, 1)
        ResetUnitAnimation(data67.caster)
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
function SF__.TemplarStrikes.IAbilityData.Equals(self__AttackCount, self__DamageScaling76, self__ResetBOJChance, other__AttackCount, other__DamageScaling77, other__ResetBOJChance)
    return ((math.abs((self__DamageScaling76 - other__DamageScaling77)) < 0.0001) and (math.abs((self__ResetBOJChance - other__ResetBOJChance)) < 0.0001))
end
-- TemplarVerdict
SF__.TemplarVerdict = SF__.TemplarVerdict or {}
function SF__.TemplarVerdict.GetAbilityData(level78)
    return 2.25, 0.3, 0.15
end

function SF__.TemplarVerdict.Init()
    local EventCenter79 = require("Lib.EventCenter")
    EventCenter79.RegisterPlayerUnitSpellChannel:Emit({id = SF__.TemplarVerdict.ID, handler = SF__.TemplarVerdict.Check})
    EventCenter79.RegisterPlayerUnitSpellEffect:Emit({id = SF__.TemplarVerdict.ID, handler = SF__.TemplarVerdict.Start})
    ExTriggerRegisterNewUnit(function(u80)
        if (GetUnitTypeId(u80) == FourCC("Hpal")) then
            SF__.TemplarVerdict.UpdateAbilityMeta(u80)
        end
    end)
end

function SF__.TemplarVerdict.Check(data81)
    local UnitAttribute83 = require("Objects.UnitAttribute")
    local attr82 = UnitAttribute83.GetAttr(data81.caster)
    if (attr82.retPalHolyEnergy < 3) then
        IssueImmediateOrderById(data81.caster, SF__.ConstOrderId.Stop)
        ExTextState(data81.caster, "圣能不足")
    end
end

function SF__.TemplarVerdict.UpdateAbilityMeta(u84)
    local p85 = GetOwningPlayer(u84)
    local datas__DamageScaling86, datas__JudgementDamageScaling, datas__ChanceToResetJudgement = {}, {}, {}
    do
        local i87 = 0
        while (i87 < 1) do
            do
                local item__DamageScaling88, item__JudgementDamageScaling, item__ChanceToResetJudgement = SF__.TemplarVerdict.GetAbilityData((i87 + 1))
                table.insert(datas__DamageScaling86, item__DamageScaling88)
                table.insert(datas__JudgementDamageScaling, item__JudgementDamageScaling)
                table.insert(datas__ChanceToResetJudgement, item__ChanceToResetJudgement)
            end
            ::continue::
            i87 = (i87 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p85, SF__.TemplarVerdict.ID, "学习圣殿骑士的裁决 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p85, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决造成一次攻击伤害，如果目标被审判，造成30%的额外伤害，15%几率重置审判。消耗|cffff8c003|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 5秒\r\n\r\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas__JudgementDamageScaling[(0 + 1)] * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas__ChanceToResetJudgement[(0 + 1)] * 100)), "%的战争艺术触发几率。"), 0)
    do
        local i89 = 0
        while (i89 < 1) do
            local data__DamageScaling90, data__JudgementDamageScaling, data__ChanceToResetJudgement = datas__DamageScaling86[(i89 + 1)], datas__JudgementDamageScaling[(i89 + 1)], datas__ChanceToResetJudgement[(i89 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p85, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决 - [|cffffcc00", (i89 + 1), "级|r]"), i89)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p85, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决造成一次攻击伤害，造成|cffff8c00", string.format("%.0f", (data__DamageScaling90 * 100)), "%|r的攻击伤害。消耗|cffff8c003|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 5秒"), i89)
            ::continue::
            i89 = (i89 + 1)
        end
    end
end

function SF__.TemplarVerdict.Start(data91)
    local level92 = GetUnitAbilityLevel(data91.caster, SF__.TemplarVerdict.ID)
    local UnitAttribute95 = require("Objects.UnitAttribute")
    local EventCenter97 = require("Lib.EventCenter")
    local ad__DamageScaling93, ad__JudgementDamageScaling, ad__ChanceToResetJudgement = SF__.TemplarVerdict.GetAbilityData(level92)
    local attr94 = UnitAttribute95.GetAttr(data91.caster)
    local damage96 = (attr94:SimAttack(UnitAttribute95.HeroAttributeType.Strength) * ad__DamageScaling93)
    EventCenter97.Damage:Emit({whichUnit = data91.caster, target = data91.target, amount = damage96, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_SLICE, outResult = {}})
    attr94.retPalHolyEnergy = (attr94.retPalHolyEnergy - 3)
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
function SF__.TemplarVerdict.IAbilityData.Equals(self__DamageScaling98, self__JudgementDamageScaling, self__ChanceToResetJudgement, other__DamageScaling99, other__JudgementDamageScaling, other__ChanceToResetJudgement)
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
    local EventCenter100 = require("Lib.EventCenter")
    EventCenter100.RegisterPlayerUnitSpellChannel:Emit({id = SF__.WordOfGlory.ID, handler = SF__.WordOfGlory.Check})
    EventCenter100.RegisterPlayerUnitSpellEffect:Emit({id = SF__.WordOfGlory.ID, handler = SF__.WordOfGlory.Start})
    ExTriggerRegisterNewUnit(function(u101)
        if (GetUnitTypeId(u101) == FourCC("Hpal")) then
            SF__.WordOfGlory.UpdateAbilityMeta(u101)
        end
    end)
end

function SF__.WordOfGlory.Check(data102)
    local UnitAttribute104 = require("Objects.UnitAttribute")
    local attr103 = UnitAttribute104.GetAttr(data102.caster)
    if (attr103.retPalHolyEnergy < 3) then
        IssueImmediateOrderById(data102.caster, SF__.ConstOrderId.Stop)
        ExTextState(data102.caster, "圣能不足")
    end
end

function SF__.WordOfGlory.UpdateAbilityMeta(u105)
    local p106 = GetOwningPlayer(u105)
    SF__.Utils.ExSetAbilityResearchTooltip(p106, SF__.WordOfGlory.ID, "学习圣殿骑士的裁决 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p106, SF__.WordOfGlory.ID, "圣殿骑士的裁决造成一次攻击伤害，如果目标被审判，造成30%的额外伤害，15%几率重置审判。消耗|cffff8c003|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 5秒\r\n\r\n|cffffcc001级|r - |cffff8c00100%|r的攻击伤害，100%的战争艺术触发几率。", 0)
    do
        local i107 = 0
        while (i107 < 1) do
            SF__.Utils.ExBlzSetAbilityTooltip(p106, SF__.WordOfGlory.ID, SF__.StrConcat__("圣殿骑士的裁决 - [|cffffcc00", (i107 + 1), "级|r]"), i107)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p106, SF__.WordOfGlory.ID, "圣殿骑士的裁决造成一次攻击伤害，造成|cffff8c00100%|r的攻击伤害。消耗|cffff8c003|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 5秒", i107)
            ::continue::
            i107 = (i107 + 1)
        end
    end
end

function SF__.WordOfGlory.Start(data108)
    local UnitAttribute110 = require("Objects.UnitAttribute")
    local EventCenter111 = require("Lib.EventCenter")
    local attr109 = UnitAttribute110.GetAttr(data108.caster)
    EventCenter111.Heal:Emit({caster = data108.caster, target = data108.target, amount = 300})
    attr109.retPalHolyEnergy = (attr109.retPalHolyEnergy - 3)
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
