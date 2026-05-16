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
function SF__.CrusaderStrike.GetAbilityData(level15)
    return (0.65 + (0.35 * level15)), (0.15 * (level15 - 1))
end

function SF__.CrusaderStrike.Init()
    local EventCenter = require("Lib.EventCenter")
    EventCenter.RegisterPlayerUnitSpellEffect:Emit({id = SF__.CrusaderStrike.ID, handler = SF__.CrusaderStrike.Start})
    ExTriggerRegisterNewUnit(function(u)
        if (GetUnitTypeId(u) == FourCC("Hpal")) then
            SF__.CrusaderStrike.UpdateAbilityMeta(u)
        end
    end)
end

function SF__.CrusaderStrike.UpdateAbilityMeta(u16)
    local p17 = GetOwningPlayer(u16)
    local datas__DamageScaling, datas__ArtOfWarChance = {}, {}
    do
        local i = 0
        while (i < 3) do
            do
                local item__DamageScaling, item__ArtOfWarChance = SF__.CrusaderStrike.GetAbilityData((i + 1))
                table.insert(datas__DamageScaling, item__DamageScaling)
                table.insert(datas__ArtOfWarChance, item__ArtOfWarChance)
            end
            ::continue::
            i = (i + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p17, SF__.CrusaderStrike.ID, "学习十字军打击 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p17, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击造成一次攻击伤害，伤害系数随技能等级提升。产生|cffff8c001|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 6秒\r\n\r\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling[(0 + 1)] * 100)), "%|r的攻击伤害。\r\n|cffffcc002级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling[(1 + 1)] * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas__ArtOfWarChance[(1 + 1)] * 100)), "%的战争艺术触发几率。\r\n|cffffcc003级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling[(2 + 1)] * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas__ArtOfWarChance[(2 + 1)] * 100)), "%的战争艺术触发几率。"), 0)
    do
        local i18 = 0
        while (i18 < 3) do
            local data__DamageScaling, data__ArtOfWarChance = datas__DamageScaling[(i18 + 1)], datas__ArtOfWarChance[(i18 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p17, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击 - [|cffffcc00", (i18 + 1), "级|r]"), i18)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p17, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击造成一次攻击伤害，造成|cffff8c00", string.format("%.0f", (data__DamageScaling * 100)), "%|r的攻击伤害", SF__.Ternary__((i18 > 0), SF__.StrConcat__("，", string.format("%.0f", (data__ArtOfWarChance * 100)), "%的战争艺术触发几率"), ""), "。产生|cffff8c001|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 6秒"), i18)
            ::continue::
            i18 = (i18 + 1)
        end
    end
    -- datas.Remove(new IAbilityData { DamageScaling = 0.65f, ArtOfWarChance = 0 });
    do
        local index = 0
        table.remove(datas__DamageScaling, (index + 1))
        table.remove(datas__ArtOfWarChance, (index + 1))
    end
end

function SF__.CrusaderStrike.Start(data)
    local level19 = GetUnitAbilityLevel(data.caster, SF__.CrusaderStrike.ID)
    local UnitAttribute = require("Objects.UnitAttribute")
    local EventCenter20 = require("Lib.EventCenter")
    local ad__DamageScaling, ad__ArtOfWarChance = SF__.CrusaderStrike.GetAbilityData(level19)
    local attr = UnitAttribute.GetAttr(data.caster)
    local damage = (attr:SimAttack(UnitAttribute.HeroAttributeType.Strength) * ad__DamageScaling)
    EventCenter20.Damage:Emit({whichUnit = data.caster, target = data.target, amount = damage, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
    attr.retPalHolyEnergy = (attr.retPalHolyEnergy + 1)
end

function SF__.CrusaderStrike:OnInspector()
    local scaleX = (self._template__DamageScaling * 15)
    BJDebugMsg(SF__.StrConcat__("十字军打击伤害系数：", scaleX, " ", self._template__ArtOfWarChance))
end

function SF__.CrusaderStrike.__Init(self)
    self.__sf_type = SF__.CrusaderStrike
    self._template__DamageScaling = 0
    self._template__ArtOfWarChance = 0
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

function SF__.CrusaderStrike.IAbilityData.Equals(self__DamageScaling21, self__ArtOfWarChance22, other__DamageScaling, other__ArtOfWarChance)
    return ((math.abs((self__DamageScaling21 - other__DamageScaling)) < 0.0001) and (math.abs((self__ArtOfWarChance22 - other__ArtOfWarChance)) < 0.0001))
end

function SF__.CrusaderStrike.IAbilityData.GetHashValue(self__DamageScaling23, self__ArtOfWarChance24)
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
function SF__.RetributionPaladinGlobal:Init()
    ExTriggerRegisterNewUnit(function(u25)
        if (GetUnitTypeId(u25) == FourCC("Hpal")) then
            SF__.ListAdd__(self._units, u25)
        end
    end)
    _ = self:Start()
end

function SF__.RetributionPaladinGlobal:Start()
    return SF__.CorRun__(function()
        local UnitAttribute28 = require("Objects.UnitAttribute")
        while true do
            do
                local collection6 = self._units
                for i7, u26 in SF__.ListIterate__(collection6) do
                    local attr27 = UnitAttribute28.GetAttr(u26)
                    ExSetUnitMana(u26, ((ExGetUnitMaxMana(u26) * attr27.retPalHolyEnergy) * 0.2))
                    if (attr27.retPalHolyEnergy >= 3) then
                        SF__.Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u26), FourCC("A006"), "ReplaceableTextures/CommandButtons/BTNinv_helmet_96.tga")
                    else
                        SF__.Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u26), FourCC("A006"), "ReplaceableTextures/PassiveButtons/PASBTNinv_helmet_96.tga")
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
-- SwordOfJustice
SF__.SwordOfJustice = SF__.SwordOfJustice or {}
function SF__.SwordOfJustice.GetAbilityData(level29)
    return (75 * level29), 5, (10 * level29)
end

function SF__.SwordOfJustice.Init()
    local EventCenter30 = require("Lib.EventCenter")
    EventCenter30.RegisterPlayerUnitSpellEffect:Emit({id = SF__.SwordOfJustice.ID, handler = SF__.SwordOfJustice.Start})
    ExTriggerRegisterNewUnit(function(u31)
        if (GetUnitTypeId(u31) == FourCC("Hpal")) then
            SF__.SwordOfJustice.UpdateAbilityMeta(u31)
        end
    end)
end

function SF__.SwordOfJustice.UpdateAbilityMeta(u32)
    local p33 = GetOwningPlayer(u32)
    local datas__Damage, datas__Duration, datas__DamagePerSecond = {}, {}, {}
    do
        local i34 = 0
        while (i34 < 1) do
            do
                local item__Damage, item__Duration, item__DamagePerSecond = SF__.SwordOfJustice.GetAbilityData((i34 + 1))
                table.insert(datas__Damage, item__Damage)
                table.insert(datas__Duration, item__Duration)
                table.insert(datas__DamagePerSecond, item__DamagePerSecond)
            end
            ::continue::
            i34 = (i34 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p33, SF__.SwordOfJustice.ID, "学习公正之剑 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p33, SF__.SwordOfJustice.ID, SF__.StrConcat__("公正之剑造成一次攻击伤害，如果目标被审判，造成30%的额外伤害，15%几率重置审判。消耗|cffff8c003|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 5秒\r\n\r\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas__Damage[(0 + 1)] * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas__Damage[(0 + 1)] * 100)), "%的战争艺术触发几率。"), 0)
    do
        local i35 = 0
        while (i35 < 1) do
            local data__Damage, data__Duration, data__DamagePerSecond = datas__Damage[(i35 + 1)], datas__Duration[(i35 + 1)], datas__DamagePerSecond[(i35 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p33, SF__.SwordOfJustice.ID, SF__.StrConcat__("公正之剑 - [|cffffcc00", (i35 + 1), "级|r]"), i35)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p33, SF__.SwordOfJustice.ID, SF__.StrConcat__("公正之剑造成一次攻击伤害，造成|cffff8c00", string.format("%.0f", (data__Damage * 100)), "%|r的攻击伤害。消耗|cffff8c003|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 5秒"), i35)
            ::continue::
            i35 = (i35 + 1)
        end
    end
end

function SF__.SwordOfJustice.Start(data36)
    local level37 = GetUnitAbilityLevel(data36.caster, SF__.SwordOfJustice.ID)
    local UnitAttribute39 = require("Objects.UnitAttribute")
    local EventCenter40 = require("Lib.EventCenter")
    local ad__Damage, ad__Duration, ad__DamagePerSecond = SF__.SwordOfJustice.GetAbilityData(level37)
    local attr38 = UnitAttribute39.GetAttr(data36.caster)
    EventCenter40.Damage:Emit({whichUnit = data36.caster, target = data36.target, amount = ad__Damage, attack = false, ranged = true, attackType = ATTACK_TYPE_MAGIC, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
    attr38.retPalHolyEnergy = (attr38.retPalHolyEnergy + 1)
    SF__.SwordOfJustice.New():StartGroudDamage(data36.caster, data36.target, ad__Damage, ad__Duration, ad__DamagePerSecond)
end

function SF__.SwordOfJustice:StartGroudDamage(caster, target, ad__Damage41, ad__Duration42, ad__DamagePerSecond43)
    return SF__.CorRun__(function()
        self.x = GetUnitX(target)
        local EventCenter47 = require("Lib.EventCenter")
        self.y = GetUnitY(target)
        local eff = ExAddSpecialEffect("Abilities/Spells/Orc/LiquidFire/Liquidfire.mdl", self.x, self.y, ad__Duration42)
        local p44 = GetOwningPlayer(caster)
        do
            local i45 = 0
            while (i45 < ad__Duration42) do
                SF__.CorWait__(1000)
                ExGroupEnumUnitsInRange(self.x, self.y, 300, function(u46)
                    if (not IsUnitEnemy(u46, p44)) then
                        return
                    end
                    if ExIsUnitDead(u46) then
                        return
                    end
                    EventCenter47.Damage:Emit({whichUnit = caster, target = u46, amount = ad__DamagePerSecond43, attack = false, ranged = true, attackType = ATTACK_TYPE_MAGIC, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
                end)
                ::continue::
                i45 = (i45 + 1)
            end
        end
        DestroyEffect(eff)
    end)
end

function SF__.SwordOfJustice.__Init(self)
    self.__sf_type = SF__.SwordOfJustice
    self.x = 0
    self.y = 0
end

function SF__.SwordOfJustice.New()
    local self = setmetatable({}, { __index = SF__.SwordOfJustice })
    SF__.SwordOfJustice.__Init(self)
    return self
end

SF__.SwordOfJustice.ID = FourCC("A001")
SF__.SwordOfJustice = SF__.SwordOfJustice or {}
-- SwordOfJustice.IAbilityData
SF__.SwordOfJustice.IAbilityData = SF__.SwordOfJustice.IAbilityData or {}
function SF__.SwordOfJustice.IAbilityData.Equals(self__Damage, self__Duration, self__DamagePerSecond, other__Damage, other__Duration, other__DamagePerSecond)
    return (((math.abs((self__Damage - other__Damage)) < 0.0001) and (math.abs((self__Duration - other__Duration)) < 0.0001)) and (math.abs((self__DamagePerSecond - other__DamagePerSecond)) < 0.0001))
end
SF__.Systems = SF__.Systems or {}
-- Systems.InitAbilitiesSystem
local SystemBase = require("System.SystemBase")
SF__.Systems.InitAbilitiesSystem = SF__.Systems.InitAbilitiesSystem or class("InitAbilitiesSystem", SystemBase)
SF__.Systems.InitAbilitiesSystem.__sf_base = SystemBase
function SF__.Systems.InitAbilitiesSystem:Awake()
    SF__.RetributionPaladinGlobal.Instance:Init()
    SF__.CrusaderStrike.Init()
    SF__.SwordOfJustice.Init()
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
-- TemplarVerdict
SF__.TemplarVerdict = SF__.TemplarVerdict or {}
function SF__.TemplarVerdict.GetAbilityData(level48)
    return 2.25, 0.3, 0.15
end

function SF__.TemplarVerdict.Init()
    local EventCenter49 = require("Lib.EventCenter")
    EventCenter49.RegisterPlayerUnitSpellChannel:Emit({id = SF__.TemplarVerdict.ID, handler = SF__.TemplarVerdict.Check})
    EventCenter49.RegisterPlayerUnitSpellEffect:Emit({id = SF__.TemplarVerdict.ID, handler = SF__.TemplarVerdict.Start})
    ExTriggerRegisterNewUnit(function(u50)
        if (GetUnitTypeId(u50) == FourCC("Hpal")) then
            SF__.TemplarVerdict.UpdateAbilityMeta(u50)
        end
    end)
end

function SF__.TemplarVerdict.Check(data51)
    local UnitAttribute53 = require("Objects.UnitAttribute")
    local attr52 = UnitAttribute53.GetAttr(data51.caster)
    if (attr52.retPalHolyEnergy < 3) then
        IssueImmediateOrderById(data51.caster, SF__.ConstOrderId.Stop)
        ExTextState(data51.caster, "圣能不足")
    end
end

function SF__.TemplarVerdict.UpdateAbilityMeta(u54)
    local p55 = GetOwningPlayer(u54)
    local datas__DamageScaling56, datas__JudgementDamageScaling, datas__ChanceToResetJudgement = {}, {}, {}
    do
        local i57 = 0
        while (i57 < 1) do
            do
                local item__DamageScaling58, item__JudgementDamageScaling, item__ChanceToResetJudgement = SF__.TemplarVerdict.GetAbilityData((i57 + 1))
                table.insert(datas__DamageScaling56, item__DamageScaling58)
                table.insert(datas__JudgementDamageScaling, item__JudgementDamageScaling)
                table.insert(datas__ChanceToResetJudgement, item__ChanceToResetJudgement)
            end
            ::continue::
            i57 = (i57 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p55, SF__.TemplarVerdict.ID, "学习圣殿骑士的裁决 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p55, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决造成一次攻击伤害，如果目标被审判，造成30%的额外伤害，15%几率重置审判。消耗|cffff8c003|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 5秒\r\n\r\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas__JudgementDamageScaling[(0 + 1)] * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas__ChanceToResetJudgement[(0 + 1)] * 100)), "%的战争艺术触发几率。"), 0)
    do
        local i59 = 0
        while (i59 < 1) do
            local data__DamageScaling60, data__JudgementDamageScaling, data__ChanceToResetJudgement = datas__DamageScaling56[(i59 + 1)], datas__JudgementDamageScaling[(i59 + 1)], datas__ChanceToResetJudgement[(i59 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p55, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决 - [|cffffcc00", (i59 + 1), "级|r]"), i59)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p55, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决造成一次攻击伤害，造成|cffff8c00", string.format("%.0f", (data__DamageScaling60 * 100)), "%|r的攻击伤害。消耗|cffff8c003|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 5秒"), i59)
            ::continue::
            i59 = (i59 + 1)
        end
    end
end

function SF__.TemplarVerdict.Start(data61)
    local level62 = GetUnitAbilityLevel(data61.caster, SF__.TemplarVerdict.ID)
    local UnitAttribute65 = require("Objects.UnitAttribute")
    local EventCenter67 = require("Lib.EventCenter")
    local ad__DamageScaling63, ad__JudgementDamageScaling, ad__ChanceToResetJudgement = SF__.TemplarVerdict.GetAbilityData(level62)
    local attr64 = UnitAttribute65.GetAttr(data61.caster)
    local damage66 = (attr64:SimAttack(UnitAttribute65.HeroAttributeType.Strength) * ad__DamageScaling63)
    EventCenter67.Damage:Emit({whichUnit = data61.caster, target = data61.target, amount = damage66, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_SLICE, outResult = {}})
    attr64.retPalHolyEnergy = (attr64.retPalHolyEnergy - 3)
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
function SF__.TemplarVerdict.IAbilityData.Equals(self__DamageScaling68, self__JudgementDamageScaling, self__ChanceToResetJudgement, other__DamageScaling69, other__JudgementDamageScaling, other__ChanceToResetJudgement)
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
    local EventCenter70 = require("Lib.EventCenter")
    EventCenter70.RegisterPlayerUnitSpellChannel:Emit({id = SF__.WordOfGlory.ID, handler = SF__.WordOfGlory.Check})
    EventCenter70.RegisterPlayerUnitSpellEffect:Emit({id = SF__.WordOfGlory.ID, handler = SF__.WordOfGlory.Start})
    ExTriggerRegisterNewUnit(function(u71)
        if (GetUnitTypeId(u71) == FourCC("Hpal")) then
            SF__.WordOfGlory.UpdateAbilityMeta(u71)
        end
    end)
end

function SF__.WordOfGlory.Check(data72)
    local UnitAttribute74 = require("Objects.UnitAttribute")
    local attr73 = UnitAttribute74.GetAttr(data72.caster)
    if (attr73.retPalHolyEnergy < 3) then
        IssueImmediateOrderById(data72.caster, SF__.ConstOrderId.Stop)
        ExTextState(data72.caster, "圣能不足")
    end
end

function SF__.WordOfGlory.UpdateAbilityMeta(u75)
    local p76 = GetOwningPlayer(u75)
    SF__.Utils.ExSetAbilityResearchTooltip(p76, SF__.WordOfGlory.ID, "学习圣殿骑士的裁决 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p76, SF__.WordOfGlory.ID, "圣殿骑士的裁决造成一次攻击伤害，如果目标被审判，造成30%的额外伤害，15%几率重置审判。消耗|cffff8c003|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 5秒\r\n\r\n|cffffcc001级|r - |cffff8c00100%|r的攻击伤害，100%的战争艺术触发几率。", 0)
    do
        local i77 = 0
        while (i77 < 1) do
            SF__.Utils.ExBlzSetAbilityTooltip(p76, SF__.WordOfGlory.ID, SF__.StrConcat__("圣殿骑士的裁决 - [|cffffcc00", (i77 + 1), "级|r]"), i77)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p76, SF__.WordOfGlory.ID, "圣殿骑士的裁决造成一次攻击伤害，造成|cffff8c00100%|r的攻击伤害。消耗|cffff8c003|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 5秒", i77)
            ::continue::
            i77 = (i77 + 1)
        end
    end
end

function SF__.WordOfGlory.Start(data78)
    local UnitAttribute80 = require("Objects.UnitAttribute")
    local EventCenter81 = require("Lib.EventCenter")
    local attr79 = UnitAttribute80.GetAttr(data78.caster)
    EventCenter81.Heal:Emit({caster = data78.caster, target = data78.target, amount = 300})
    attr79.retPalHolyEnergy = (attr79.retPalHolyEnergy - 3)
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
