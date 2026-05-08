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

function SF__.ListNew__(items)
    return { items = items or {}, version = 0 }
end

function SF__.ListCount__(list)
    return #list.items
end

function SF__.ListGet__(list, index)
    return list.items[index + 1]
end

function SF__.ListSet__(list, index, value)
    list.items[index + 1] = value
    list.version = list.version + 1
end

function SF__.ListAdd__(list, value)
    table.insert(list.items, value)
    list.version = list.version + 1
end

function SF__.ListIterate__(list)
    local version = list.version
    local i = 0
    return function()
        if list.version ~= version then error("collection was modified during iteration") end
        i = i + 1
        local value = list.items[i]
        if value ~= nil then return i, value end
    end
end

function SF__.ListSort__(list, less)
    local compare = less or function(a, b) return a < b end
    local items = list.items
    for i = 2, #items do
        local value = items[i]
        local j = i - 1
        while j >= 1 and compare(value, items[j]) do
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

-- CrusaderStrike
SF__.CrusaderStrike = SF__.CrusaderStrike or {}
SF__.CrusaderStrike.ID = FourCC("A000")
SF__.CrusaderStrike.thePlayer = Player(0)
function SF__.CrusaderStrike.GetAbilityData(level13)
    return (0.65 + (0.35 * level13)), (0.15 * (level13 - 1))
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

function SF__.CrusaderStrike.UpdateAbilityMeta(u14)
    local p15 = GetOwningPlayer(u14)
    local datas = SF__.ListNew__({})
    do
        local i = 0
        while (i < 3) do
            SF__.ListAdd__(datas, SF__.CrusaderStrike.GetAbilityData((i + 1)))
            ::continue::
            i = (i + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p15, SF__.CrusaderStrike.ID, "学习十字军打击 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p15, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击造成一次攻击伤害，伤害系数随技能等级提升。产生|cffff8c001|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 6秒\r\n\r\n|cffffcc001级|r - |cffff8c00", (SF__.ListGet__(datas, 0).DamageScaling * 100), "%|r的攻击伤害。\r\n|cffffcc002级|r - |cffff8c00", (SF__.ListGet__(datas, 1).DamageScaling * 100), "%|r的攻击伤害，", (SF__.ListGet__(datas, 1).ArtOfWarChance * 100), "%的战争艺术触发几率。\r\n|cffffcc003级|r - |cffff8c00", (SF__.ListGet__(datas, 2).DamageScaling * 100), "%|r的攻击伤害，", (SF__.ListGet__(datas, 2).ArtOfWarChance * 100), "%的战争艺术触发几率。"), 0)
    do
        local i16 = 0
        while (i16 < 3) do
            local data__DamageScaling, data__ArtOfWarChance = SF__.ListGet__(datas, i16)
            SF__.Utils.ExBlzSetAbilityTooltip(p15, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击 - [|cffffcc00", (i16 + 1), "级|r]"), i16)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p15, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击造成一次攻击伤害，造成|cffff8c00", (data__DamageScaling * 100), "%|r的攻击伤害", SF__.Ternary__((i16 > 0), SF__.StrConcat__("，", (data__ArtOfWarChance * 100), "%的战争艺术触发几率"), ""), "。产生|cffff8c001|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 6秒"), i16)
            ::continue::
            i16 = (i16 + 1)
        end
    end
end

function SF__.CrusaderStrike.Start(data)
    local level17 = GetUnitAbilityLevel(data.caster, SF__.CrusaderStrike.ID)
    local UnitAttribute = require("Objects.UnitAttribute")
    local ad__DamageScaling, ad__ArtOfWarChance = SF__.CrusaderStrike.GetAbilityData(level17)
    local attr = UnitAttribute.GetAttr(data.caster)
    local damage = (attr:SimAttack(UnitAttribute.HeroAttributeType.Strength) * ad__DamageScaling)
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
SF__.SFLib = SF__.SFLib or {}
-- SFLib.IEquatable
SF__.SFLib.IEquatable = SF__.SFLib.IEquatable or {}
SF__.CrusaderStrike = SF__.CrusaderStrike or {}
-- CrusaderStrike.BluntData
SF__.CrusaderStrike.BluntData = SF__.CrusaderStrike.BluntData or {}
SF__.CrusaderStrike.BluntData.__sf_interfaces = {[SF__.SFLib.IEquatable] = true}
function SF__.CrusaderStrike.BluntData:Equals(other)
    return (math.abs((self.BluntDamage - other.BluntDamage)) < 0.0001)
end

function SF__.CrusaderStrike.BluntData:GetHashValue()
    return 0
end

function SF__.CrusaderStrike.BluntData.__Init(self)
    self.__sf_type = SF__.CrusaderStrike.BluntData
    self.BluntDamage = 0
end

function SF__.CrusaderStrike.BluntData.New()
    local self = setmetatable({}, { __index = SF__.CrusaderStrike.BluntData })
    SF__.CrusaderStrike.BluntData.__Init(self)
    return self
end
-- CrusaderStrike.IAbilityData
SF__.CrusaderStrike.IAbilityData = SF__.CrusaderStrike.IAbilityData or {}
function SF__.CrusaderStrike.IAbilityData.Scale(self__DamageScaling, self__ArtOfWarChance, scale)
    return (self__DamageScaling * scale), (self__ArtOfWarChance * scale)
end

function SF__.CrusaderStrike.IAbilityData.Equals(self__DamageScaling18, self__ArtOfWarChance19, other__DamageScaling, other__ArtOfWarChance)
    return ((math.abs((self__DamageScaling18 - other__DamageScaling)) < 0.0001) and (math.abs((self__ArtOfWarChance19 - other__ArtOfWarChance)) < 0.0001))
end

function SF__.CrusaderStrike.IAbilityData.GetHashValue(self__DamageScaling20, self__ArtOfWarChance21)
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
SF__.Systems = SF__.Systems or {}
-- Systems.InitAbilitiesSystem
local SystemBase = require("System.SystemBase")
SF__.Systems.InitAbilitiesSystem = SF__.Systems.InitAbilitiesSystem or class("InitAbilitiesSystem", SystemBase)
SF__.Systems.InitAbilitiesSystem.__sf_base = SystemBase
function SF__.Systems.InitAbilitiesSystem:Awake()
    SF__.CrusaderStrike.Init()
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

function SF__.Utils.__Init(self)
    self.__sf_type = SF__.Utils
end

function SF__.Utils.New()
    local self = setmetatable({}, { __index = SF__.Utils })
    SF__.Utils.__Init(self)
    return self
end

SF__.Program.Main()
