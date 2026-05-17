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
function SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(u25, amount)
    local UnitAttribute27 = require("Objects.UnitAttribute")
    local attr26 = UnitAttribute27.GetAttr(u25)
    attr26.retPalHolyEnergy = math.min((attr26.retPalHolyEnergy + amount), 5)
end

function SF__.RetributionPaladinGlobal:Init()
    ExTriggerRegisterNewUnit(function(u28)
        if (GetUnitTypeId(u28) == FourCC("Hpal")) then
            SF__.ListAdd__(self._units, u28)
        end
    end)
    _ = self:Start()
end

function SF__.RetributionPaladinGlobal:Start()
    return SF__.CorRun__(function()
        local UnitAttribute31 = require("Objects.UnitAttribute")
        while true do
            do
                local collection6 = self._units
                for i7, u29 in SF__.ListIterate__(collection6) do
                    local attr30 = UnitAttribute31.GetAttr(u29)
                    ExSetUnitMana(u29, ((ExGetUnitMaxMana(u29) * attr30.retPalHolyEnergy) * 0.2))
                    if (attr30.retPalHolyEnergy >= 3) then
                        SF__.Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u29), FourCC("A006"), "ReplaceableTextures/CommandButtons/BTNinv_helmet_96.tga")
                    else
                        SF__.Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u29), FourCC("A006"), "ReplaceableTextures/PassiveButtons/PASBTNinv_helmet_96.tga")
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
function SF__.SwordOfJustice.GetAbilityData(level32)
    return (75 * level32), 5, (10 * level32)
end

function SF__.SwordOfJustice.Init()
    local EventCenter33 = require("Lib.EventCenter")
    EventCenter33.RegisterPlayerUnitSpellEffect:Emit({id = SF__.SwordOfJustice.ID, handler = SF__.SwordOfJustice.Start})
    ExTriggerRegisterNewUnit(function(u34)
        if (GetUnitTypeId(u34) == FourCC("Hpal")) then
            SF__.SwordOfJustice.UpdateAbilityMeta(u34)
        end
    end)
end

function SF__.SwordOfJustice.UpdateAbilityMeta(u35)
    local p36 = GetOwningPlayer(u35)
    local datas__Damage, datas__Duration, datas__DamagePerSecond = {}, {}, {}
    do
        local i37 = 0
        while (i37 < 1) do
            do
                local item__Damage, item__Duration, item__DamagePerSecond = SF__.SwordOfJustice.GetAbilityData((i37 + 1))
                table.insert(datas__Damage, item__Damage)
                table.insert(datas__Duration, item__Duration)
                table.insert(datas__DamagePerSecond, item__DamagePerSecond)
            end
            ::continue::
            i37 = (i37 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p36, SF__.SwordOfJustice.ID, "学习公正之剑 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p36, SF__.SwordOfJustice.ID, SF__.StrConcat__("公正之剑造成一次攻击伤害，如果目标被审判，造成30%的额外伤害，15%几率重置审判。消耗|cffff8c003|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 5秒\r\n\r\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas__Damage[(0 + 1)] * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas__Damage[(0 + 1)] * 100)), "%的战争艺术触发几率。"), 0)
    do
        local i38 = 0
        while (i38 < 1) do
            local data__Damage, data__Duration, data__DamagePerSecond = datas__Damage[(i38 + 1)], datas__Duration[(i38 + 1)], datas__DamagePerSecond[(i38 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p36, SF__.SwordOfJustice.ID, SF__.StrConcat__("公正之剑 - [|cffffcc00", (i38 + 1), "级|r]"), i38)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p36, SF__.SwordOfJustice.ID, SF__.StrConcat__("公正之剑造成一次攻击伤害，造成|cffff8c00", string.format("%.0f", (data__Damage * 100)), "%|r的攻击伤害。消耗|cffff8c003|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 5秒"), i38)
            ::continue::
            i38 = (i38 + 1)
        end
    end
end

function SF__.SwordOfJustice.Start(data39)
    local level40 = GetUnitAbilityLevel(data39.caster, SF__.SwordOfJustice.ID)
    local UnitAttribute42 = require("Objects.UnitAttribute")
    local EventCenter43 = require("Lib.EventCenter")
    local ad__Damage, ad__Duration, ad__DamagePerSecond = SF__.SwordOfJustice.GetAbilityData(level40)
    local attr41 = UnitAttribute42.GetAttr(data39.caster)
    EventCenter43.Damage:Emit({whichUnit = data39.caster, target = data39.target, amount = ad__Damage, attack = false, ranged = true, attackType = ATTACK_TYPE_MAGIC, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
    attr41.retPalHolyEnergy = (attr41.retPalHolyEnergy + 1)
    SF__.SwordOfJustice.New():StartGroudDamage(data39.caster, data39.target, ad__Damage, ad__Duration, ad__DamagePerSecond)
end

function SF__.SwordOfJustice:StartGroudDamage(caster, target, ad__Damage44, ad__Duration45, ad__DamagePerSecond46)
    return SF__.CorRun__(function()
        self.x = GetUnitX(target)
        local EventCenter50 = require("Lib.EventCenter")
        self.y = GetUnitY(target)
        local eff = ExAddSpecialEffect("Abilities/Spells/Orc/LiquidFire/Liquidfire.mdl", self.x, self.y, ad__Duration45)
        local p47 = GetOwningPlayer(caster)
        do
            local i48 = 0
            while (i48 < ad__Duration45) do
                SF__.CorWait__(1000)
                ExGroupEnumUnitsInRange(self.x, self.y, 300, function(u49)
                    if (not IsUnitEnemy(u49, p47)) then
                        return
                    end
                    if ExIsUnitDead(u49) then
                        return
                    end
                    EventCenter50.Damage:Emit({whichUnit = caster, target = u49, amount = ad__DamagePerSecond46, attack = false, ranged = true, attackType = ATTACK_TYPE_MAGIC, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
                end)
                ::continue::
                i48 = (i48 + 1)
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
    SF__.TemplarStrikes.Init()
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
end

function SF__.TemplarStrikes.UpdateAbilityMeta(u54)
    local p55 = GetOwningPlayer(u54)
    local datas__AttackCount, datas__DamageScaling56, datas__ResetBOJChance = {}, {}, {}
    do
        local i57 = 0
        while (i57 < SF__.TemplarStrikes.MaxLevel) do
            do
                local item__AttackCount, item__DamageScaling58, item__ResetBOJChance = SF__.TemplarStrikes.GetAbilityData((i57 + 1))
                table.insert(datas__AttackCount, item__AttackCount)
                table.insert(datas__DamageScaling56, item__DamageScaling58)
                table.insert(datas__ResetBOJChance, item__ResetBOJChance)
            end
            ::continue::
            i57 = (i57 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p55, SF__.TemplarStrikes.ID, "学习圣殿骑士之击 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p55, SF__.TemplarStrikes.ID, SF__.StrConcat__("快速攻击目标|cffff8c00", datas__AttackCount[(0 + 1)], "|r次，第一次造成普通攻击伤害，第二次造成光辉伤害，有一定几率重置公正之剑的冷却时间，普通攻击也会触发。\r\n\r\n|cff99ccff冷却时间|r - 10秒\r\n\r\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling56[(0 + 1)] * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas__ResetBOJChance[(0 + 1)] * 100)), "%|r的几率重置公正之剑。\r\n|cffffcc002级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling56[(1 + 1)] * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas__ResetBOJChance[(1 + 1)] * 100)), "%|r的几率重置公正之剑。\r\n|cffffcc003级|r - |cffff8c00", string.format("%.0f", (datas__DamageScaling56[(2 + 1)] * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas__ResetBOJChance[(2 + 1)] * 100)), "%|r的几率重置公正之剑。"), 0)
    do
        local i59 = 0
        while (i59 < SF__.TemplarStrikes.MaxLevel) do
            local data__AttackCount, data__DamageScaling60, data__ResetBOJChance = datas__AttackCount[(i59 + 1)], datas__DamageScaling56[(i59 + 1)], datas__ResetBOJChance[(i59 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p55, SF__.TemplarStrikes.ID, SF__.StrConcat__("圣殿骑士之击 - [|cffffcc00", (i59 + 1), "级|r]"), i59)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p55, SF__.TemplarStrikes.ID, SF__.StrConcat__("快速攻击目标|cffff8c00", data__AttackCount, "|r次，第一次造成普通攻击伤害，第二次造成普通攻击|cffff8c00", string.format("%.0f", (data__DamageScaling60 * 100)), "%|r的光辉伤害，|cffff8c00", string.format("%.0f", (data__ResetBOJChance * 100)), "%|r几率重置公正之剑的冷却时间，普通攻击也会触发。\r\n\r\n|cff99ccff冷却时间|r - 10秒"), i59)
            ::continue::
            i59 = (i59 + 1)
        end
    end
end

function SF__.TemplarStrikes.Start(data61)
    return SF__.CorRun__(function()
        local level62 = GetUnitAbilityLevel(data61.caster, SF__.TemplarStrikes.ID)
        local UnitAttribute64 = require("Objects.UnitAttribute")
        local EventCenter65 = require("Lib.EventCenter")
        local attr63 = UnitAttribute64.GetAttr(data61.caster)
        local normalDamage = attr63:SimAttack(UnitAttribute64.HeroAttributeType.Strength)
        SetUnitTimeScale(data61.caster, 2)
        EventCenter65.Damage:Emit({whichUnit = data61.caster, target = data61.target, amount = normalDamage, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
        SF__.CorWait__(math.round(((1.166 * 0.5) * 1000)))
        SetUnitAnimationByIndex(data61.caster, 11)
        local ad__AttackCount, ad__DamageScaling66, ad__ResetBOJChance = SF__.TemplarStrikes.GetAbilityData(level62)
        local radiantDamage = (attr63:SimAttack(UnitAttribute64.HeroAttributeType.Strength) * ad__DamageScaling66)
        EventCenter65.Damage:Emit({whichUnit = data61.caster, target = data61.target, amount = radiantDamage, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
        SetUnitTimeScale(data61.caster, 1)
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
function SF__.TemplarStrikes.IAbilityData.Equals(self__AttackCount, self__DamageScaling67, self__ResetBOJChance, other__AttackCount, other__DamageScaling68, other__ResetBOJChance)
    return ((math.abs((self__DamageScaling67 - other__DamageScaling68)) < 0.0001) and (math.abs((self__ResetBOJChance - other__ResetBOJChance)) < 0.0001))
end
-- TemplarVerdict
SF__.TemplarVerdict = SF__.TemplarVerdict or {}
function SF__.TemplarVerdict.GetAbilityData(level69)
    return 2.25, 0.3, 0.15
end

function SF__.TemplarVerdict.Init()
    local EventCenter70 = require("Lib.EventCenter")
    EventCenter70.RegisterPlayerUnitSpellChannel:Emit({id = SF__.TemplarVerdict.ID, handler = SF__.TemplarVerdict.Check})
    EventCenter70.RegisterPlayerUnitSpellEffect:Emit({id = SF__.TemplarVerdict.ID, handler = SF__.TemplarVerdict.Start})
    ExTriggerRegisterNewUnit(function(u71)
        if (GetUnitTypeId(u71) == FourCC("Hpal")) then
            SF__.TemplarVerdict.UpdateAbilityMeta(u71)
        end
    end)
end

function SF__.TemplarVerdict.Check(data72)
    local UnitAttribute74 = require("Objects.UnitAttribute")
    local attr73 = UnitAttribute74.GetAttr(data72.caster)
    if (attr73.retPalHolyEnergy < 3) then
        IssueImmediateOrderById(data72.caster, SF__.ConstOrderId.Stop)
        ExTextState(data72.caster, "圣能不足")
    end
end

function SF__.TemplarVerdict.UpdateAbilityMeta(u75)
    local p76 = GetOwningPlayer(u75)
    local datas__DamageScaling77, datas__JudgementDamageScaling, datas__ChanceToResetJudgement = {}, {}, {}
    do
        local i78 = 0
        while (i78 < 1) do
            do
                local item__DamageScaling79, item__JudgementDamageScaling, item__ChanceToResetJudgement = SF__.TemplarVerdict.GetAbilityData((i78 + 1))
                table.insert(datas__DamageScaling77, item__DamageScaling79)
                table.insert(datas__JudgementDamageScaling, item__JudgementDamageScaling)
                table.insert(datas__ChanceToResetJudgement, item__ChanceToResetJudgement)
            end
            ::continue::
            i78 = (i78 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p76, SF__.TemplarVerdict.ID, "学习圣殿骑士的裁决 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p76, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决造成一次攻击伤害，如果目标被审判，造成30%的额外伤害，15%几率重置审判。消耗|cffff8c003|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 5秒\r\n\r\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas__JudgementDamageScaling[(0 + 1)] * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas__ChanceToResetJudgement[(0 + 1)] * 100)), "%的战争艺术触发几率。"), 0)
    do
        local i80 = 0
        while (i80 < 1) do
            local data__DamageScaling81, data__JudgementDamageScaling, data__ChanceToResetJudgement = datas__DamageScaling77[(i80 + 1)], datas__JudgementDamageScaling[(i80 + 1)], datas__ChanceToResetJudgement[(i80 + 1)]
            SF__.Utils.ExBlzSetAbilityTooltip(p76, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决 - [|cffffcc00", (i80 + 1), "级|r]"), i80)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p76, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决造成一次攻击伤害，造成|cffff8c00", string.format("%.0f", (data__DamageScaling81 * 100)), "%|r的攻击伤害。消耗|cffff8c003|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 5秒"), i80)
            ::continue::
            i80 = (i80 + 1)
        end
    end
end

function SF__.TemplarVerdict.Start(data82)
    local level83 = GetUnitAbilityLevel(data82.caster, SF__.TemplarVerdict.ID)
    local UnitAttribute86 = require("Objects.UnitAttribute")
    local EventCenter88 = require("Lib.EventCenter")
    local ad__DamageScaling84, ad__JudgementDamageScaling, ad__ChanceToResetJudgement = SF__.TemplarVerdict.GetAbilityData(level83)
    local attr85 = UnitAttribute86.GetAttr(data82.caster)
    local damage87 = (attr85:SimAttack(UnitAttribute86.HeroAttributeType.Strength) * ad__DamageScaling84)
    EventCenter88.Damage:Emit({whichUnit = data82.caster, target = data82.target, amount = damage87, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_SLICE, outResult = {}})
    attr85.retPalHolyEnergy = (attr85.retPalHolyEnergy - 3)
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
function SF__.TemplarVerdict.IAbilityData.Equals(self__DamageScaling89, self__JudgementDamageScaling, self__ChanceToResetJudgement, other__DamageScaling90, other__JudgementDamageScaling, other__ChanceToResetJudgement)
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
    local EventCenter91 = require("Lib.EventCenter")
    EventCenter91.RegisterPlayerUnitSpellChannel:Emit({id = SF__.WordOfGlory.ID, handler = SF__.WordOfGlory.Check})
    EventCenter91.RegisterPlayerUnitSpellEffect:Emit({id = SF__.WordOfGlory.ID, handler = SF__.WordOfGlory.Start})
    ExTriggerRegisterNewUnit(function(u92)
        if (GetUnitTypeId(u92) == FourCC("Hpal")) then
            SF__.WordOfGlory.UpdateAbilityMeta(u92)
        end
    end)
end

function SF__.WordOfGlory.Check(data93)
    local UnitAttribute95 = require("Objects.UnitAttribute")
    local attr94 = UnitAttribute95.GetAttr(data93.caster)
    if (attr94.retPalHolyEnergy < 3) then
        IssueImmediateOrderById(data93.caster, SF__.ConstOrderId.Stop)
        ExTextState(data93.caster, "圣能不足")
    end
end

function SF__.WordOfGlory.UpdateAbilityMeta(u96)
    local p97 = GetOwningPlayer(u96)
    SF__.Utils.ExSetAbilityResearchTooltip(p97, SF__.WordOfGlory.ID, "学习圣殿骑士的裁决 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p97, SF__.WordOfGlory.ID, "圣殿骑士的裁决造成一次攻击伤害，如果目标被审判，造成30%的额外伤害，15%几率重置审判。消耗|cffff8c003|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 5秒\r\n\r\n|cffffcc001级|r - |cffff8c00100%|r的攻击伤害，100%的战争艺术触发几率。", 0)
    do
        local i98 = 0
        while (i98 < 1) do
            SF__.Utils.ExBlzSetAbilityTooltip(p97, SF__.WordOfGlory.ID, SF__.StrConcat__("圣殿骑士的裁决 - [|cffffcc00", (i98 + 1), "级|r]"), i98)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p97, SF__.WordOfGlory.ID, "圣殿骑士的裁决造成一次攻击伤害，造成|cffff8c00100%|r的攻击伤害。消耗|cffff8c003|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 5秒", i98)
            ::continue::
            i98 = (i98 + 1)
        end
    end
end

function SF__.WordOfGlory.Start(data99)
    local UnitAttribute101 = require("Objects.UnitAttribute")
    local EventCenter102 = require("Lib.EventCenter")
    local attr100 = UnitAttribute101.GetAttr(data99.caster)
    EventCenter102.Heal:Emit({caster = data99.caster, target = data99.target, amount = 300})
    attr100.retPalHolyEnergy = (attr100.retPalHolyEnergy - 3)
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
