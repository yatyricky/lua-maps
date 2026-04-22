--lua-bundler:000108297
local function RunBundle()
local __modules = {}
local require = function(path)
    local module = __modules[path]
    if module == nil then
        local dotPath = string.gsub(path, "/", "%.")
        module = __modules[dotPath]
        __modules[path] = module
    end
    if module ~= nil then
        if not module.inited then
            module.cached = module.loader()
            module.inited = true
        end
        return module.cached
    else
        error("module not found " .. path)
        return nil
    end
end

__modules["Main"]={loader=function()
local FrameTimer = require("Lib.FrameTimer")
local Time = require("Lib.Time")
require("Lib.CoroutineExt")
require("Lib.TableExt")
require("Lib.StringExt")
require("Lib.native")

local ipairs = ipairs

-- main logic

-- game machine

---@type SystemBase[]
local systems = {
    require("System.ItemSystem").new(),
    require("System.SpellSystem").new(),
    require("System.BuffSystem").new(),
    require("System.DamageSystem").new(),
    require("System.ProjectileSystem").new(),
    require("System.ManagedAISystem").new(),

    require("System.InitAbilitiesSystem").new(),
    require("System.BuffDisplaySystem").new(),
}



table.insert(systems, require("System.MoonGladeSystem").new())



for _, system in ipairs(systems) do
    system:Awake()
end

local group = CreateGroup()
GroupEnumUnitsInRect(group, bj_mapInitialPlayableArea, Filter(function()
    local s, m = pcall(ExTriggerRegisterNewUnitExec, GetFilterUnit())
    if not s then
        print(m)
    end
end))
DestroyGroup(group)
group = nil

for _, system in ipairs(systems) do
    system:OnEnable()
end

local MathRound = MathRound

local game = FrameTimer.new(function(dt)
    local now = MathRound(Time.Time * 100) * 0.01
    for _, system in ipairs(systems) do
        system:Update(dt, now)
    end
end, 1, -1)
game:Start()

end}

__modules["Lib.FrameTimer"]={loader=function()
local FrameUpdate = require("Lib.EventCenter").FrameUpdate

local pcall = pcall
local print = print

local cls = class("FrameTimer")

function cls:ctor(func, count, loops)
    self.func = func
    self.count = count
    self.loops = loops

    self.frames = count
    self.running = false
end

function cls:Start()
    if self.running then
        return
    end

    if self.loops == 0 then
        return
    end

    self.running = true
    FrameUpdate:On(self, cls._update)
end

function cls:Stop()
    if not self.running then
        return
    end

    self.running = false
    FrameUpdate:Off(self, cls._update)
end

function cls:_update(dt)
    if not self.running then
        return
    end

    self.frames = self.frames - 1
    if self.frames <= 0 then
        local s, m = pcall(self.func, dt)
        if not s then
            print(m)
        end

        if self.loops > 0 then
            self.loops = self.loops - 1
            if self.loops == 0 then
                self:Stop()
                return
            end
        end

        self.frames = self.frames + self.count
    end
end

return cls

end}

__modules["Lib.Time"]={loader=function()
local EventCenter = require("Lib.EventCenter")
local Timer = require("Lib.Timer")
local FrameBegin = EventCenter.FrameBegin
local FrameUpdate = EventCenter.FrameUpdate

local TimerGetElapsed = TimerGetElapsed

local TimeTimerInterval = 10

---@class Time
---@field Time real current time
local cls = {}

cls.Frame = 0
cls.Delta = 0.02
local delta = cls.Delta

local time = 0
local timeTimer = Timer.new(function()
    time = time + TimeTimerInterval
end, TimeTimerInterval, -1)
timeTimer:Start()
local tm = timeTimer.timer

FrameBegin:On(cls, function(_, _)
    local f = cls.Frame + 1
    cls.Frame = f
end)

-- main loop
local mainLoopTimer = Timer.new(function(dt)
    FrameBegin:Emit(dt)
    FrameUpdate:Emit(dt)
end, cls.Delta, -1)
mainLoopTimer:Start()

-- cls.Time
setmetatable(cls, {
    __index = function()
        return time + TimerGetElapsed(tm)
    end
})

local MathRound = MathRound
local m_ceil = math.ceil

function cls.CeilToNextUpdate(timestamp)
    return MathRound(m_ceil(timestamp / delta) * delta * 100) * 0.01
end

Time = cls

return cls

end}

__modules["Lib.CoroutineExt"]={loader=function()
local Timer = require("Lib.Timer")
local FrameTimer = require("Lib.FrameTimer")

local c_create = coroutine.create
local c_running = coroutine.running
local c_resume = coroutine.resume
local c_yield = coroutine.yield
local t_pack = table.pack
local t_unpack = table.unpack
local print = print

local c2t = setmetatable({}, { __mode = "kv" })

function coroutine.start(f, ...)
    local c = c_create(f)
    local r = c_running()

    if r == nil then
        local success, msg = c_resume(c, ...)
        if not success then
            print(msg)
        end
    else
        local args = t_pack(...)
        local timer
        timer = FrameTimer.new(function()
            c2t[c] = nil
            local success, msg = c_resume(c, t_unpack(args))
            if not success then
                print(msg)
            end
        end, 1, 1)
        c2t[c] = timer
        timer:Start()
    end

    return c
end

function coroutine.wait(t)
    local c = c_running()
    local timer

    local function action()
        c2t[c] = nil

        local success, msg = c_resume(c)
        if not success then
            print(msg)
        end
    end

    timer = Timer.new(action, t, 1)
    c2t[c] = timer
    timer:Start()
    c_yield()
end

---@param t number?
function coroutine.step(t)
    local c = c_running()
    local timer

    local function action()
        c2t[c] = nil

        local success, msg = c_resume(c)
        if not success then
            print(msg)
        end
    end

    timer = FrameTimer.new(action, t or 1, 1)
    c2t[c] = timer
    timer:Start()
    c_yield()
end

function coroutine.stop(c)
    local timer = c2t[c]
    if timer ~= nil then
        c2t[c] = nil
        timer:Stop()
    end
end

end}

__modules["Lib.TableExt"]={loader=function()
local ipairs = ipairs
local t_insert = table.insert
local m_floor = math.floor
local m_random = math.random
local m_clamp = math.clamp

---Add v to k of tab, in place. tab will be mutated.
---@generic K
---@param tab table<K, number>
---@param k K
---@param v number
---@return number result
function table.addNum(tab, k, v)
    local r = tab[k]
    if r == nil then
        r = v
    else
        r = r + v
    end
    tab[k] = r
    return r
end

function table.any(tab)
    return tab ~= nil and next(tab) ~= nil
end

function table.getOrCreateTable(tab, key)
    if key == nil then
        print(GetStackTrace())
    end
    local ret = tab[key]
    if not ret then
        ret = {}
        tab[key] = ret
    end
    return ret
end

---@generic T
---@param tab T[]
---@param n integer count
---@return T[]
function table.sample(tab, n)
    local result = {}
    local c = 0
    for _, item in ipairs(tab) do
        c = c + 1
        if #result < n then
            t_insert(result, item)
        else
            local s = m_floor(m_random() * c)
            if s < n then
                result[s + 1] = item
            end
        end
    end
    return result
end

---@generic T
---@param tab T[]
---@param item T
function table.removeItem(tab, item)
    local c = #tab
    local i = 1
    local d = 0
    local removed = false
    while i <= c do
        local it = tab[i]
        if it == item then
            d = d + 1
            removed = true
        else
            if d > 0 then
                tab[i - d] = it
            end
        end
        i = i + 1
    end
    for j = 0, d - 1 do
        tab[c - j] = nil
    end
    return removed
end

---@generic V
---@param t V[]
---@param func fun(i: integer, v: V): boolean
---@return V, integer
function table.iFind(t, func)
    for i, v in ipairs(t) do
        if func(i, v) == true then
            return v, i
        end
    end
    return nil, nil
end

---@generic T
---@param tab T[]
---@param from number Optional One-based index at which to begin extraction.
---@param to number Optional One-based index before which to end extraction.
---@return T[]
function table.slice(tab, from, to)
    from = from and m_clamp(from, 1, #tab + 1) or 1
    to = to and m_clamp(to, 1, #tab) or #tab
    local result = {}
    for i = from, to, 1 do
        if tab[i] then
            t_insert(result, tab[i])
        end
    end
    return result
end

---@generic K, V
---@param source table<K, V> | V[]
---@param copy table<K, V> | V[]
---@return table<K, V> | V[]
function table.shallow(source, copy)
    copy = copy or {}
    for k, v in pairs(source) do
        copy[k] = v
    end
    return copy
end

---@generic T
---@param t T[]
---@return T
function table.iGetRandom(t)
    return t[m_random(#t)]
end

---@generic T
---@param t T[]
---@param func fun(elem: T): boolean
---@return T[]
function table.iWhere(t, func)
    local tab = {}
    for _, v in ipairs(t) do
        if func(v) then
            t_insert(tab, v)
        end
    end
    return tab
end

---@generic V
---@param tab V[]
---@param filter fun(item: V): boolean
---@return V[] removed items
function table.iFilterInPlace(tab, filter)
    local ret = {}
    local c = #tab
    local i = 1
    local d = 0
    while i <= c do
        local it = tab[i]
        if filter(it) then
            if d > 0 then
                tab[i - d] = it
            end
        else
            t_insert(ret, it)
            d = d + 1
        end
        i = i + 1
    end
    for j = 0, d - 1 do
        tab[c - j] = nil
    end
    return ret
end

function table.iRemoveOneRight(tab, item)
    for i = #tab, 1, -1 do
        if tab[i] == item then
            table.remove(tab, i)
            return true
        end
    end
    return false
end

function table.iRemoveOneLeft(tab, item)
    for i = 1, #tab do
        if tab[i] == item then
            table.remove(tab, i)
            return true
        end
    end
    return false
end

end}

__modules["Lib.StringExt"]={loader=function()
function string.formatPercentage(number, digits)
    digits = digits or 0
    number = number * 100
    --local pow = 10 ^ digits
    --number = math.round(number * pow) / pow
    --return tostring(number) .. "%"
    if digits == 0 then
        return tostring(math.round(number)) .. "%"
    else
        return string.format("%0" .. tostring(digits) .. "d", number) .. "%"
    end
end

end}

__modules["Lib.native"]={loader=function()
require("Lib.TableExt")
require("Lib.MathExt")
local Time = require("Lib.Time")

local ipairs = ipairs
local pcall = pcall
local print = print
local c_start = coroutine.start
local c_wait = coroutine.wait
local c_step = coroutine.step
local m_round = math.round
local t_insert = table.insert
local t_getOrCreateTable = table.getOrCreateTable

local AddLightningEx = AddLightningEx
local AddSpecialEffect = AddSpecialEffect
local AddSpecialEffectTarget = AddSpecialEffectTarget
local CreateGroup = CreateGroup
local CreateTrigger = CreateTrigger
local DestroyEffect = DestroyEffect
local DestroyLightning = DestroyLightning
local Filter = Filter
local GetFilterUnit = GetFilterUnit
local GetLearnedSkill = GetLearnedSkill
local GetLearnedSkillLevel = GetLearnedSkillLevel
local GetTriggerUnit = GetTriggerUnit
local GetUnitFlyHeight = GetUnitFlyHeight
local GetUnitX = GetUnitX
local GetUnitY = GetUnitY
local GroupClear = GroupClear
local BlzGetUnitZ = BlzGetUnitZ
local GetWidgetLife = GetWidgetLife
local GroupEnumUnitsInRange = GroupEnumUnitsInRange
local MoveLightningEx = MoveLightningEx
local SetLightningColor = SetLightningColor
local BlzSetSpecialEffectColor = BlzSetSpecialEffectColor
local TriggerAddAction = TriggerAddAction
local TriggerRegisterAnyUnitEventBJ = TriggerRegisterAnyUnitEventBJ

local function trueFilter()
    return true
end

---@param trigger trigger
---@param action fun(): void
---@return void
function ExTriggerAddAction(trigger, action)
    TriggerAddAction(trigger, function()
        local s, m = pcall(action)
        if not s then
            print(m)
        end
    end)
end

local ExTriggerAddAction = ExTriggerAddAction

local group = CreateGroup()

---@param x real
---@param y real
---@param radius real
---@param callback fun(unit: unit): void
---@return void
function ExGroupEnumUnitsInRange(x, y, radius, callback)
    GroupClear(group)
    GroupEnumUnitsInRange(group, x, y, radius, Filter(function()
        local s, m = pcall(callback, GetFilterUnit())
        if not s then
            print(m)
        end
        return false
    end))
end

---@param callback fun(unit: unit): void
function ExGroupEnumUnitsInMap(callback)
    GroupClear(group)
    GroupEnumUnitsInRect(group, bj_mapInitialPlayableArea, Filter(function()
        local s, m = pcall(callback, GetFilterUnit())
        if not s then
            print(m)
        end
        return false
    end))
end

---@param x real
---@param y real
---@param radius real
---@param filter fun(unit: unit): boolean
---@return unit[]
function ExGroupGetUnitsInRange(x, y, radius, filter)
    filter = filter or trueFilter
    GroupClear(group)
    local units = {}
    GroupEnumUnitsInRange(group, x, y, radius, Filter(function()
        local f = GetFilterUnit()
        local s, m = pcall(filter, f)
        if not s then
            print(m)
            return false
        end
        if m then
            t_insert(units, f)
        end
        return false
    end))
    return units
end

---@param modelName string
---@param target unit
---@param attachPoint string
---@param duration real
function ExAddSpecialEffectTarget(modelName, target, attachPoint, duration)
    c_start(function()
        local sfx = AddSpecialEffectTarget(modelName, target, attachPoint)
        c_wait(duration)
        DestroyEffect(sfx)
    end)
end

function ExAddSpecialEffect(modelName, x, y, duration, color)
    local sfx = AddSpecialEffect(modelName, x, y)
    c_start(function()
        if color then
            BlzSetSpecialEffectColor(sfx, m_round(color.r * 255), m_round(color.g * 255), m_round(color.b * 255))
        end
        c_wait(duration)
        DestroyEffect(sfx)
    end)
    return sfx
end

function ExAddLightningPosPos(modelName, x1, y1, z1, x2, y2, z2, duration, color, check)
    c_start(function()
        local lightning = AddLightningEx(modelName, check or false, x1, y1, z1, x2, y2, z2)
        if color then
            SetLightningColor(lightning, color.r, color.g, color.b, color.a)
        end
        c_wait(duration)
        DestroyLightning(lightning)
    end)
end

function ExAddLightningUnitUnit(modelName, unit1, unit2, duration, color, checkVisibility)
    checkVisibility = checkVisibility or false
    local lightning = AddLightningEx(modelName, checkVisibility,
            GetUnitX(unit1), GetUnitY(unit1), BlzGetUnitZ(unit1) + GetUnitFlyHeight(unit1),
            GetUnitX(unit2), GetUnitY(unit2), BlzGetUnitZ(unit2) + GetUnitFlyHeight(unit2))
    if color then
        SetLightningColor(lightning, color.r, color.g, color.b, color.a)
    end
    local co = c_start(function()
        local expr = Time.Time + duration
        while true do
            c_step()
            MoveLightningEx(lightning, checkVisibility,
                    GetUnitX(unit1), GetUnitY(unit1), BlzGetUnitZ(unit1) + GetUnitFlyHeight(unit1),
                    GetUnitX(unit2), GetUnitY(unit2), BlzGetUnitZ(unit2) + GetUnitFlyHeight(unit2))
            if Time.Time >= expr then
                break
            end
        end
        DestroyLightning(lightning)
    end)
    return lightning, co
end

function ExAddLightningPosUnit(modelName, x1, y1, z1, unit2, duration, color, check)
    c_start(function()
        check = check or false
        local expr = Time.Time + duration
        local lightning = AddLightningEx(modelName, check,
                x1, y1, z1,
                GetUnitX(unit2), GetUnitY(unit2), BlzGetUnitZ(unit2) + GetUnitFlyHeight(unit2))
        if color then
            SetLightningColor(lightning, color.r, color.g, color.b, color.a)
        end
        while true do
            c_step()
            MoveLightningEx(lightning, check,
                    x1, y1, z1,
                    GetUnitX(unit2), GetUnitY(unit2), BlzGetUnitZ(unit2) + GetUnitFlyHeight(unit2))
            if Time.Time >= expr then
                break
            end
        end
        DestroyLightning(lightning)
    end)
end

local acquireTrigger = CreateTrigger()
local acquireCalls = {}
ExTriggerAddAction(acquireTrigger, function()
    local caster = GetTriggerUnit()
    local target = GetEventTargetUnit()
    for _, v in ipairs(acquireCalls) do
        v(caster, target)
    end
end)

function ExTriggerRegisterUnitAcquire(callback)
    table.insert(acquireCalls, callback)
end

local mapArea = CreateRegion()
RegionAddRect(mapArea, bj_mapInitialPlayableArea)
local enterTrigger = CreateTrigger()
local enterMapCalls = {}
TriggerRegisterEnterRegion(enterTrigger, mapArea, Filter(function() return true end))
function ExTriggerRegisterNewUnitExec(u)
    TriggerRegisterUnitEvent(acquireTrigger, u, EVENT_UNIT_ACQUIRED_TARGET)
    for _, v in ipairs(enterMapCalls) do
        v(u)
    end
end
local ExTriggerRegisterNewUnitExec = ExTriggerRegisterNewUnitExec
ExTriggerAddAction(enterTrigger, function()
    ExTriggerRegisterNewUnitExec(GetTriggerUnit())
end)

---@param callback fun(unit: unit): void
function ExTriggerRegisterNewUnit(callback)
    t_insert(enterMapCalls, callback)
end

function ExIsUnitDead(unit)
    return GetWidgetLife(unit) < 0.406
end

local deathTrigger = CreateTrigger()
local unitDeathCalls = {}
TriggerRegisterAnyUnitEventBJ(deathTrigger, EVENT_PLAYER_UNIT_DEATH)
ExTriggerAddAction(deathTrigger, function()
    local u = GetTriggerUnit()
    for _, v in ipairs(unitDeathCalls) do
        v(u)
    end
end)

---@param callback fun(unit: unit): void
function ExTriggerRegisterUnitDeath(callback)
    t_insert(unitDeathCalls, callback)
end

local learnTrigger = CreateTrigger()
local unitLearnCalls = {}
local anySkillLearnCalls = {}
TriggerRegisterAnyUnitEventBJ(learnTrigger, EVENT_PLAYER_HERO_SKILL)
ExTriggerAddAction(learnTrigger, function()
    local u = GetTriggerUnit()
    local s = GetLearnedSkill()
    local l = GetLearnedSkillLevel()
    local tab = t_getOrCreateTable(unitLearnCalls, s)
    for _, v in ipairs(tab) do
        v(u, l, s)
    end
    for _, v in ipairs(anySkillLearnCalls) do
        v(u, l, s)
    end
end)
---@param callback fun(unit: unit, level: integer, skill: integer): void
function ExTriggerRegisterUnitLearn(id, callback)
    if id == 0 then
        t_insert(anySkillLearnCalls, callback)
    else
        local tab = t_getOrCreateTable(unitLearnCalls, id)
        t_insert(tab, callback)
    end
end

function GetStackTrace(oneline_yn)
    local trace, lastMsg, i, separator = "", "", 5, (oneline_yn and "; ") or "\n"
    local store = function(msg) lastMsg = msg:sub(1, -3) end --Passed to xpcall to handle the error message. Message is being saved to lastMsg for further use, excluding trailing space and colon.
    xpcall(error, store, "", 4) --starting at position 4 ensures that the functions "error", "xpcall" and "GetStackTrace" are not included in the trace.
    while lastMsg:sub(1, 11) == "war3map.lua" or lastMsg:sub(1, 14) == "blizzard.j.lua" do
        trace = separator .. lastMsg .. trace
        xpcall(error, store, "", i)
        i = i + 1
    end
    return "Traceback (most recent call last)" .. trace
end

function PrintStackTrace()
    print(GetStackTrace())
end

function ExTextTag(whichUnit, dmg, color)
    local tt = CreateTextTag()
    local text = tostring(math.round(dmg)) .. "!"
    SetTextTagText(tt, text, 0.024)
    SetTextTagPos(tt, GetUnitX(whichUnit), GetUnitY(whichUnit), 0.0)
    color = color or { r = 1, g = 1, b = 1, a = 1 }
    SetTextTagColor(tt, math.round(color.r * 255), math.round(color.g * 255), math.round(color.b * 255), math.round(color.a * 255))
    SetTextTagVelocity(tt, 0.0, 0.04)
    SetTextTagVisibility(tt, true)
    SetTextTagFadepoint(tt, 2.0)
    SetTextTagLifespan(tt, 5.0)
    SetTextTagPermanent(tt, false)
end

function ExTextCriticalStrike(whichUnit, dmg)
    local tt = CreateTextTag()
    local text = tostring(math.round(dmg)) .. "!"
    SetTextTagText(tt, text, 0.024)
    SetTextTagPos(tt, GetUnitX(whichUnit), GetUnitY(whichUnit), 0.0)
    SetTextTagColor(tt, 255, 0, 0, 255)
    SetTextTagVelocity(tt, 0.0, 0.04)
    SetTextTagVisibility(tt, true)
    SetTextTagFadepoint(tt, 2.0)
    SetTextTagLifespan(tt, 5.0)
    SetTextTagPermanent(tt, false)
end

function ExTextMiss(whichUnit)
    local tt = CreateTextTag()
    SetTextTagText(tt, "未命中", 0.024)
    SetTextTagPos(tt, GetUnitX(whichUnit), GetUnitY(whichUnit), 0.0)
    SetTextTagColor(tt, 255, 0, 0, 255)
    SetTextTagVelocity(tt, 0.0, 0.03)
    SetTextTagVisibility(tt, true)
    SetTextTagFadepoint(tt, 1.0)
    SetTextTagLifespan(tt, 3.0)
    SetTextTagPermanent(tt, false)
end

function ExTextState(whichUnit, text)
    local tt = CreateTextTag()
    SetTextTagText(tt, text, 0.024)
    SetTextTagPos(tt, GetUnitX(whichUnit), GetUnitY(whichUnit), 0.0)
    SetTextTagColor(tt, 255, 192, 0, 255)
    SetTextTagVelocity(tt, 0.0, 0.03)
    SetTextTagVisibility(tt, true)
    SetTextTagFadepoint(tt, 1.0)
    SetTextTagLifespan(tt, 3.0)
    SetTextTagPermanent(tt, false)
end

function ExGetUnitMana(unit)
    return GetUnitState(unit, UNIT_STATE_MANA)
end

function ExGetUnitMaxMana(unit)
    return GetUnitState(unit, UNIT_STATE_MAX_MANA)
end

function ExGetUnitManaPortion(unit)
    return ExGetUnitMana(unit) / ExGetUnitMaxMana(unit)
end

function ExSetUnitMana(unit, amount)
    return SetUnitState(unit, UNIT_STATE_MANA, amount)
end

function ExAddUnitMana(unit, amount)
    ExSetUnitMana(unit, ExGetUnitMana(unit) + amount)
end

function ExGetUnitManaLoss(unit)
    return GetUnitState(unit, UNIT_STATE_MAX_MANA) - ExGetUnitMana(unit)
end

function ExGetUnitLifeLoss(unit)
    return GetUnitState(unit, UNIT_STATE_MAX_LIFE) - GetUnitState(unit, UNIT_STATE_LIFE)
end

function ExGetUnitLifePortion(unit)
    return GetWidgetLife(unit) / GetUnitState(unit, UNIT_STATE_MAX_LIFE)
end

function ExGetUnitPlayerId(unit)
    return GetPlayerId(GetOwningPlayer(unit))
end

end}

__modules["System.ItemSystem"]={loader=function()
---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Rick Sun.
--- DateTime: 9/17/2022 1:46 PM
---

local Event = require("Lib.Event")
local EventCenter = require("Lib.EventCenter")
local SystemBase = require("System.SystemBase")

EventCenter.PlayerUnitPickupItem = Event.new()

---@class EventRegisterItemRecipeData
---@field result item
---@field recipe table<item, integer>

---@class EventRegisterItemRecipe : Event
---@field data EventRegisterItemRecipeData
EventCenter.RegisterItemRecipe = Event.new()

---@class ItemSystem : SystemBase
local cls = class("ItemSystem", SystemBase)

function cls:ctor()
    local trigger = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trigger, EVENT_PLAYER_UNIT_PICKUP_ITEM)
    ExTriggerAddAction(trigger, function()
        local item = GetManipulatedItem()
        local unit = GetTriggerUnit()
        local player = GetTriggerPlayer()
        EventCenter.PlayerUnitPickupItem:Emit({
            item = item,
            unit = unit,
            player = player
        })
        self:_mergeItems(item, unit, player)
    end)

    self._recipes = {} ---@type table<item, list<table<item, integer>>> key=result, key2=ingredient value2=ingredient count
    self._ingredients = {} ---@type table<item, table<item, integer>> key=ingredient key2=result value2=1
    EventCenter.RegisterItemRecipe:On(self, cls._registerItemRecipe)
end

function cls:_collectItemsInSlot(unit)
    local t = {}
    for i = 0, 5 do
        local item = UnitItemInSlot(unit, i)
        if item then
            table.addNum(t, item, 1)
        end
    end
    return t
end

function cls:_mergeItems(item, unit, player)
    local results = self._ingredients[item]
    if not results then
        return
    end

    local own = self:_collectItemsInSlot(unit)
    for result, _ in pairs(results) do

    end
end

---@param data EventRegisterItemRecipeData
function cls:_registerItemRecipe(data)
    local options = self._recipes[data.result]
    if not options then
        options = {}
        self._recipes[data.result] = options
    end
    table.insert(options, data.recipe)

    for k, _ in pairs(data.recipe) do
        local ingredient = self._ingredients[k]
        if not ingredient then
            ingredient = {}
            self._ingredients[k] = ingredient
        end
        ingredient[data.result] = 1
    end
end

return cls

end}

__modules["System.SpellSystem"]={loader=function()
local Event = require("Lib.Event")
local EventCenter = require("Lib.EventCenter")
local SystemBase = require("System.SystemBase")

---@class ISpellData
---@field abilityId integer
---@field caster unit
---@field target unit
---@field x real
---@field y real
---@field item item
---@field destructable destructable
---@field finished boolean
---@field interrupted ISpellData
---@field _effectDone boolean

---@class IRegisterSpellEvent : Event
---@field Emit fun(arg: { id: integer, handler: (fun(data: ISpellData): void), ctx: table }): void

---@class SpellSystem : SystemBase
local cls = class("SpellSystem", SystemBase)

---@type IRegisterSpellEvent
EventCenter.RegisterPlayerUnitSpellChannel = Event.new()
---@type IRegisterSpellEvent
EventCenter.RegisterPlayerUnitSpellCast = Event.new()
---@type IRegisterSpellEvent
EventCenter.RegisterPlayerUnitSpellEffect = Event.new()
---@type IRegisterSpellEvent
EventCenter.RegisterPlayerUnitSpellFinish = Event.new()
---@type IRegisterSpellEvent
EventCenter.RegisterPlayerUnitSpellEndCast = Event.new()

function cls:ctor()
    self:_register(EVENT_PLAYER_UNIT_SPELL_CHANNEL, function()
        local data = self:_initSpellData()
        self:_invoke(self._channelHandlers, data)
    end)

    self:_register(EVENT_PLAYER_UNIT_SPELL_CAST, function()
        local data = self.castTab[GetTriggerUnit()]
        self:_invoke(self._castHandlers, data)
    end)

    self:_register(EVENT_PLAYER_UNIT_SPELL_EFFECT, function()
        local data = self.castTab[GetTriggerUnit()]
        if data and not data._effectDone then
            data._effectDone = true
            self:_invoke(self._effectHandlers, data)
        end
    end)

    self:_register(EVENT_PLAYER_UNIT_SPELL_FINISH, function()
        local data = self.castTab[GetTriggerUnit()]
        if data == nil then
            return
        end
        data.finished = true
        self:_invoke(self._finishHandlers, data)
    end)

    self:_register(EVENT_PLAYER_UNIT_SPELL_ENDCAST, function()
        local data = self.castTab[GetTriggerUnit()]
        self:_invoke(self._endCastHandlers, data)
        if data.interrupted then
            self.castTab[data.caster] = data.interrupted
        else
            self.castTab[data.caster] = nil
        end
    end)

    self.castTab = {} ---@type table<unit, ISpellData>

    self._channelHandlers = {}
    self._castHandlers = {}
    self._effectHandlers = {}
    self._finishHandlers = {}
    self._endCastHandlers = {}

    EventCenter.RegisterPlayerUnitSpellChannel:On(self, cls._registerSpellChannel)
    EventCenter.RegisterPlayerUnitSpellCast:On(self, cls._registerSpellCast)
    EventCenter.RegisterPlayerUnitSpellEffect:On(self, cls._registerSpellEffect)
    EventCenter.RegisterPlayerUnitSpellFinish:On(self, cls._registerSpellFinish)
    EventCenter.RegisterPlayerUnitSpellEndCast:On(self, cls._registerSpellEndCast)
end

---@param data ISpellData
function cls:_invoke(handlers, data)
    local tab = handlers[0]
    if tab then
        for _, listener in ipairs(tab) do
            if listener.ctx then
                listener.handler(listener.ctx, data)
            else
                listener.handler(data)
            end
        end
    end
    if not data then
        return
    end
    tab = handlers[data.abilityId]
    if tab then
        for _, listener in ipairs(tab) do
            if listener.ctx then
                listener.handler(listener.ctx, data)
            else
                listener.handler(data)
            end
        end
    end
end

function cls:_register(event, callback)
    local trigger = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trigger, event)
    ExTriggerAddAction(trigger, callback)
end

function cls:_initSpellData()
    local data = {} ---@type ISpellData
    data.abilityId = GetSpellAbilityId()
    data.caster = GetTriggerUnit()
    data.target = GetSpellTargetUnit()
    if data.target ~= nil then
        data.x = GetUnitX(data.target)
        data.y = GetUnitY(data.target)
    else
        data.destructable = GetSpellTargetDestructable()
        if data.destructable ~= nil then
            data.x = GetDestructableX(data.destructable)
            data.y = GetDestructableY(data.destructable)
        else
            data.item = GetSpellTargetItem()
            if data.item ~= nil then
                data.x = GetItemX(data.item)
                data.y = GetItemY(data.item)
            else
                data.x = GetSpellTargetX()
                data.y = GetSpellTargetY()
            end
        end
    end
    data.interrupted = self.castTab[data.caster]
    self.castTab[data.caster] = data
    return data
end

function cls:_registerSpell(data, tab)
    local listeners = tab[data.id]
    if listeners == nil then
        listeners = {}
        tab[data.id] = listeners
    end
    table.insert(listeners, data)
end

function cls:_registerSpellChannel(data)
    self:_registerSpell(data, self._channelHandlers)
end

function cls:_registerSpellCast(data)
    self:_registerSpell(data, self._castHandlers)
end

function cls:_registerSpellEffect(data)
    self:_registerSpell(data, self._effectHandlers)
end

function cls:_registerSpellFinish(data)
    self:_registerSpell(data, self._finishHandlers)
end

function cls:_registerSpellEndCast(data)
    self:_registerSpell(data, self._endCastHandlers)
end

return cls

end}

__modules["System.BuffSystem"]={loader=function()
local EventCenter = require("Lib.EventCenter")
local Event = require("Lib.Event")
local SystemBase = require("System.SystemBase")

EventCenter.NewBuff = Event.new()
EventCenter.KillBuff = Event.new()

---@class BuffSystem : SystemBase
local cls = class("BuffSystem", SystemBase)

function cls:ctor()
    self.buffs = {} ---@type BuffBase[]
end

function cls:Awake()
    EventCenter.NewBuff:On(self, cls.onNewBuff)
    EventCenter.KillBuff:On(self, cls.onKillBuff)
    ExTriggerRegisterUnitDeath(function(u)
        self:_onUnitDeath(u)
    end)
end

function cls:Update(_, now)
    local toRemove = {}
    for i, buff in ipairs(self.buffs) do
        buff.time = now
        if now > buff.expire then
            table.insert(toRemove, i)
        else
            if now >= buff.nextUpdate then
                buff:Update()
                buff.nextUpdate = now + buff.interval
            end
            if now == buff.expire then
                table.insert(toRemove, i)
            end
        end
    end

    local removedBuffs = {}
    for i = #toRemove, 1, -1 do
        local removed = table.remove(self.buffs, toRemove[i])
        removed:OnDisable()
        table.insert(removedBuffs, removed)
    end

    for _, buff in ipairs(removedBuffs) do
        buff:OnDestroy()
    end
end

---@param buff BuffBase
function cls:onNewBuff(buff)
    table.insert(self.buffs, buff)
    buff:Awake()
    buff:OnEnable()
end

function cls:_onUnitDeath(unit)
    local toDestroy = {}
    for i = #self.buffs, 1, -1 do
        local buff = self.buffs[i]
        if IsUnit(buff.target, unit) then
            buff:OnDisable()
            table.remove(self.buffs, i)
            table.insert(toDestroy, buff)
        end
    end
    for _, v in ipairs(toDestroy) do
        v:OnDestroy()
    end
end

function cls:onKillBuff(buff)
    for i = #self.buffs, 1, -1 do
        if buff == self.buffs[i] then
            buff:OnDisable()
            table.remove(self.buffs, i)
        end
    end
    buff:OnDestroy()
end

return cls

end}

__modules["System.DamageSystem"]={loader=function()
local EventCenter = require("Lib.EventCenter")
local Event = require("Lib.Event")
local UnitAttribute = require("Objects.UnitAttribute")
local Const = require("Config.Const")

EventCenter.RegisterPlayerUnitDamaging = Event.new()
EventCenter.RegisterPlayerUnitDamaged = Event.new()
---data {whichUnit=unit,target=unit,amount=real,attack=boolean,ranged=boolean,attackType=attacktype,damageType=damagetype,weaponType=weapontype,outResult=table}
EventCenter.Damage = Event.new()
---data: {caster=unit,target=unit,amount=real}
EventCenter.Heal = Event.new()
---{caster=caster,target=target,amount=amount,isPercentage=isPercentage}
EventCenter.HealMana = Event.new()
EventCenter.PlayerUnitAttackMiss = Event.new()

local SystemBase = require("System.SystemBase")

---@class DamageSystem : SystemBase
local cls = class("DamageSystem", SystemBase)

function cls:ctor()
    cls.super.ctor(self)
    local damagingTrigger = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(damagingTrigger, EVENT_PLAYER_UNIT_DAMAGING)
    ExTriggerAddAction(damagingTrigger, function()
        self:_response(self._damagingHandlers)
    end)

    local damagedTrigger = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(damagedTrigger, EVENT_PLAYER_UNIT_DAMAGED)
    ExTriggerAddAction(damagedTrigger, function()
        self:_response(self._damagedHandlers)
    end)

    --local enterTrigger = CreateTrigger()
    --TriggerRegisterEnterRegion(enterTrigger, CreateRegion(), Filter(function() return true end))
    --TriggerAddAction(enterTrigger, function()
    --    TriggerRegisterUnitEvent(damageTrigger, GetTriggerUnit(), EVENT_UNIT_DAMAGED)
    --end)

    self._damagingHandlers = {}
    self._damagedHandlers = {}
end

function cls:Awake()
    EventCenter.RegisterPlayerUnitDamaging:On(self, cls._registerDamaging)
    EventCenter.RegisterPlayerUnitDamaged:On(self, cls._registerDamaged)
    EventCenter.Damage:On(self, cls._onDamage)
    EventCenter.Heal:On(self, cls._onHeal)
    EventCenter.HealMana:On(self, cls._onHealMana)
end

function cls:OnEnable()
    EventCenter.RegisterPlayerUnitDamaging:Emit(function(caster, target, damage, weaponType, damageType, isAttack)
        --print("Damage from native")
        if not isAttack then
            --print("not attack, skip")
            return
        end

        if caster == nil or target == nil then
            return
        end

        local b = UnitAttribute.GetAttr(target)
        if b.dodge > 0 then
            if math.random() < b.dodge then
                BlzSetEventDamage(0)
                BlzSetEventWeaponType(WEAPON_TYPE_WHOKNOWS)
                ExTextMiss(target)

                EventCenter.PlayerUnitAttackMiss:Emit({
                    caster = caster,
                    target = target,
                })
                return
            end
        end

        local a = UnitAttribute.GetAttr(caster)
        damage = damage * math.max(1 + a.damageAmplification - b.damageReduction, 0)

        -- shield
        local bas = b.absorbShields
        if table.any(bas) then
            while #bas > 0 and damage > 0 do
                local shieldBuff = bas[1]
                if shieldBuff.shield >= damage then
                    shieldBuff.shield = shieldBuff.shield - damage
                    damage = 0
                else
                    damage = damage - shieldBuff.shield
                    shieldBuff.shield = 0
                end
                if shieldBuff.shield <= 0 then
                    EventCenter.KillBuff:Emit(shieldBuff)
                    table.remove(bas, 1)
                end
            end
        end

        BlzSetEventDamage(damage)
    end)
end

function cls:_registerDamaging(handler)
    table.insert(self._damagingHandlers, handler)
end

function cls:_registerDamaged(handler)
    table.insert(self._damagedHandlers, handler)
end

function cls:_response(whichHandlers)
    local damage = GetEventDamage()
    local caster = GetEventDamageSource()
    local target = BlzGetEventDamageTarget()
    local damageType = BlzGetEventDamageType()
    local weaponType = BlzGetEventWeaponType()
    local isAttack = BlzGetEventIsAttack()
    for _, v in ipairs(whichHandlers) do
        v(caster, target, damage, weaponType, damageType, isAttack)
    end
end

-- whichUnit, target, amount, attack, ranged, attackType, damageType, weaponType, outResult
function cls:_onDamage(d)
    --print("DamageEvent:", GetUnitName(d.whichUnit), GetUnitName(d.target), d.amount, d.attack, d.ranged, d.attackType, d.damageType, d.weaponType)
    local a = UnitAttribute.GetAttr(d.whichUnit)
    local b = UnitAttribute.GetAttr(d.target)
    if d.attack then
        if math.random() < b.dodge then
            d.outResult.hitResult = Const.HitResult_Miss
            EventCenter.PlayerUnitAttackMiss:Emit({
                caster = d.whichUnit,
                target = d.target,
            })
            ExTextMiss(d.target)
            return
        end
    end

    local amount = d.amount * (1 + a.damageAmplification - b.damageReduction)
    --print("DamageEvent-Native:", GetUnitName(d.whichUnit), GetUnitName(d.target), amount, d.attack, d.ranged, d.attackType, d.damageType, d.weaponType)
    UnitDamageTarget(d.whichUnit, d.target, amount, d.attack, d.ranged, d.attackType, d.damageType, d.weaponType)
    d.outResult.hitResult = Const.HitResult_Hit
    d.outResult.damage = amount
end

function cls:_onHeal(data)
    local current = GetUnitState(data.target, UNIT_STATE_LIFE)
    local attr = UnitAttribute.GetAttr(data.target)
    local healed = data.amount * (1 + attr.healingTaken)
    SetWidgetLife(data.target, current + healed)
end

function cls:_onHealMana(data)
    local current = GetUnitState(data.target, UNIT_STATE_MANA)
    local amount
    if data.isPercentage then
        amount = data.amount * GetUnitState(data.target, UNIT_STATE_MAX_MANA)
    else
        amount = data.amount
    end
    SetUnitState(data.target, UNIT_STATE_MANA, current + amount)
end

return cls

end}

__modules["System.ProjectileSystem"]={loader=function()
local Event = require("Lib.Event")
local EventCenter = require("Lib.EventCenter")
local SystemBase = require("System.SystemBase")
local Vector2 = require("Lib.Vector2")

EventCenter.NewProjectile = Event.new()

---@class ProjectileSystem : SystemBase
local cls = class("ProjectileSystem", SystemBase)

function cls:ctor()
    self.projectiles = {} ---@type ProjectileBase[]
end

function cls:Awake()
    EventCenter.NewProjectile:On(self, cls.onNewProjectile)
end

function cls:Update(dt)
    local toRemove = {}
    for idx, proj in ipairs(self.projectiles) do
        if proj.targetType == "unit" then
            -- Target unit was removed (RemoveUnit / handle invalidated).
            -- GetUnitTypeId returns 0 for a destroyed/removed unit handle.
            -- Without this guard the sfx would chase (0,0) and could be left orphaned on the ground.
            if GetUnitTypeId(proj.target) == 0 then
                DestroyEffect(proj.sfx)
                table.insert(toRemove, idx)
            else
                local curr = proj.pos
                local dest = Vector2.FromUnit(proj.target)
                local norm = (dest - curr):SetNormalize()
                local dir = norm * (proj.speed * dt)
                curr:Add(dir)
                BlzSetSpecialEffectX(proj.sfx, curr.x)
                BlzSetSpecialEffectY(proj.sfx, curr.y)
                BlzSetSpecialEffectZ(proj.sfx, curr:GetTerrainZ() + 60) -- todo, use vec3
                BlzSetSpecialEffectYaw(proj.sfx, math.atan2(norm.y, norm.x))

                if dest:Sub(curr):Magnitude() < 20 then
                    DestroyEffect(proj.sfx)
                    -- Guard onHit so an error in the callback can't leave other projectiles unprocessed.
                    local ok, err = pcall(proj.onHit)
                    if not ok then
                        print("ProjectileSystem onHit error: " .. tostring(err))
                    end

                    table.insert(toRemove, idx)
                end
            end
        end
    end

    for i = #toRemove, 1, -1 do
        table.remove(self.projectiles, toRemove[i])
    end
end

function cls:onNewProjectile(data)
    table.insert(self.projectiles, data.inst)
end

return cls

end}

__modules["System.ManagedAISystem"]={loader=function()
local SystemBase = require("System.SystemBase")
local EventCenter = require("Lib.EventCenter")
local Event = require("Lib.Event")
local Vector2 = require("Lib.Vector2")

---positions: {x, y, out hp}[]
EventCenter.InitCamp = Event.new()

local CampFlag = FourCC("e001")

---@class ManagedAISystem : SystemBase
local cls = class("ManagedAISystem", SystemBase)

function cls:ctor()
    self.ais = {}
    self.campPositions = {}
end

function cls:Awake()
    EventCenter.InitCamp:On(self, cls.onInitCamp)

    ExGroupEnumUnitsInMap(function(unit)
        if GetUnitTypeId(unit) == CampFlag then
            table.insert(self.campPositions, Vector2.FromUnit(unit))
            RemoveUnit(unit)
        end
    end)


end

function cls:Update(dt)
    for _, v in ipairs(self.ais) do
        v:Update(dt)
    end
end

function cls:onInitCamp(data)
    for _, p in ipairs(self.campPositions) do
        local hp = 0
        ExGroupEnumUnitsInRange(p.x, p.y, 400, function(unit)
            if ExGetUnitPlayerId(unit) == 24 and not IsUnitType(unit, UNIT_TYPE_STRUCTURE) then
                hp = hp + GetWidgetLife(unit)
            end
        end)
        if hp > 5 then
            table.insert(data, {
                p = p,
                hp = hp,
            })
        end
    end
end

--ExTriggerRegisterUnitLearn(0, function(unit, level, skill)
--    local Utils = require("Lib.Utils")
--    print(GetUnitName(unit), "learn", Utils.CCFour(skill), level)
--end)

return cls

end}

__modules["System.InitAbilitiesSystem"]={loader=function()
local SystemBase = require("System.SystemBase")

---@class InitAbilitiesSystem : SystemBase
local cls = class("InitAbilitiesSystem", SystemBase)

function cls:Awake()






    -- 唤魔师
    require("Ability.FireBreath")
    require("Ability.Disintegrate")
    require("Ability.SleepWalk")
    require("Ability.TimeWarp")
    require("Ability.MagmaBreath")



end

return cls

end}

__modules["System.BuffDisplaySystem"]={loader=function()
local SystemBase = require("System.SystemBase")
local BuffBase = require("Objects.BuffBase")

---@class BuffDisplaySystem : SystemBase
local cls = class("BuffDisplaySystem", SystemBase)

local MAX_HERO_BUFFS   = 8
local MAX_SELECT_BUFFS = 8
local ICON_SIZE        = 0.030
local ICON_GAP         = 0.003
local ICON_STEP        = ICON_SIZE + ICON_GAP

local PORTRAIT_SIZE    = 0.050

-- Top-right corner of the 4:3 play area.
local PORTRAIT_TR_X    = 0.795
local PORTRAIT_TR_Y    = 0.585

local FALLBACK_ICON    = "ReplaceableTextures\\CommandButtons\\BTNSelectHeroOn.blp"

local TT_W = 0.220
local TT_H = 0.060

-- ──────────────────────────────────────────────────────────────────────────────
-- Helpers
-- ──────────────────────────────────────────────────────────────────────────────

---Icon for a unit, from its unit-type rawcode (avoids picking up hidden item abilities).
---@param unit unit
---@return string
local function getUnitIcon(unit)
    local icon = BlzGetAbilityIcon(GetUnitTypeId(unit))
    if icon and icon ~= "" then return icon end
    return FALLBACK_ICON
end

---Best-effort icon for a buff: use the buff's own `icon`, otherwise a fallback.
---@param buff BuffBase
---@return string
local function getBuffIcon(buff)
    if buff.icon and buff.icon ~= "" then
        return buff.icon
    end
    -- If the buff carries an ability rawcode, try that.
    if buff.abilityId then
        local i = BlzGetAbilityIcon(buff.abilityId)
        if i and i ~= "" then return i end
    end
    return FALLBACK_ICON
end

---Build one hoverable icon slot: BUTTON + child BACKDROP icon + child boxed tooltip.
---BACKDROP frames cannot receive mouse events — the BUTTON is what the cursor hits.
---@param parent framehandle
---@param ctx integer
---@return table  { button, icon, tipBox, tipTitle, tipDesc }
local function newIconSlot(parent, ctx)
    -- Plain BUTTON without an inherits template => no yellow/blue hover highlight,
    -- but BUTTON still receives MOUSE_ENTER/LEAVE so the tooltip still works.
    local btn = BlzCreateFrameByType("BUTTON", "BuffSlotBtn", parent, "", ctx)
    BlzFrameSetSize(btn, ICON_SIZE, ICON_SIZE)
    BlzFrameSetVisible(btn, false)

    local icon = BlzCreateFrameByType("BACKDROP", "BuffSlotIcon", btn, "", ctx)
    BlzFrameSetAllPoints(icon, btn)

    -- Per-slot tooltip (sharing one tooltip across many buttons renders text bold/wrong).
    local tipBox = BlzCreateFrameByType("BACKDROP", "BuffSlotTipBox", btn, "", ctx)
    BlzFrameSetSize(tipBox, TT_W, TT_H)
    BlzFrameSetTexture(tipBox, "UI\\Widgets\\EscMenu\\Human\\blank-background.blp", 0, true)
    -- Tooltip sits BELOW the icon (top edge of tooltip touches bottom edge of icon).
    BlzFrameSetPoint(tipBox, FRAMEPOINT_TOPLEFT, btn, FRAMEPOINT_BOTTOMLEFT, 0.0, -0.004)

    local tipTitle = BlzCreateFrameByType("TEXT", "BuffSlotTipTitle", tipBox, "", ctx)
    BlzFrameSetPoint(tipTitle, FRAMEPOINT_TOPLEFT, tipBox, FRAMEPOINT_TOPLEFT, 0.006, -0.006)
    BlzFrameSetPoint(tipTitle, FRAMEPOINT_TOPRIGHT, tipBox, FRAMEPOINT_TOPRIGHT, -0.006, -0.006)
    BlzFrameSetEnable(tipTitle, false)
    BlzFrameSetTextAlignment(tipTitle, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_LEFT)

    local tipDesc = BlzCreateFrameByType("TEXT", "BuffSlotTipDesc", tipBox, "", ctx)
    BlzFrameSetPoint(tipDesc, FRAMEPOINT_TOPLEFT, tipTitle, FRAMEPOINT_BOTTOMLEFT, 0.0, -0.004)
    BlzFrameSetPoint(tipDesc, FRAMEPOINT_BOTTOMRIGHT, tipBox, FRAMEPOINT_BOTTOMRIGHT, -0.006, 0.006)
    BlzFrameSetEnable(tipDesc, false)
    BlzFrameSetTextAlignment(tipDesc, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_LEFT)

    -- Engine drives tooltip visibility on hover. Set it AFTER positioning the box.
    BlzFrameSetTooltip(btn, tipBox)

    return {
        button   = btn,
        icon     = icon,
        tipBox   = tipBox,
        tipTitle = tipTitle,
        tipDesc  = tipDesc,
        buff     = nil,
    }
end

-- ──────────────────────────────────────────────────────────────────────────────
-- System
-- ──────────────────────────────────────────────────────────────────────────────

function cls:ctor()
    self.heroBuffSlots   = {}
    self.selectBuffSlots = {}
    self.selectedUnit    = nil
    self.localHero       = nil
    self.portraitFrame   = nil
end

function cls:Awake()
    local gameUI = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)

    -- ── Hero buff row (right of the hero icon) ────────────────────────────────
    local heroButton = BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON, 0)
    for i = 1, MAX_HERO_BUFFS do
        local slot = newIconSlot(gameUI, i)
        local xOff = (i - 1) * ICON_STEP + ICON_GAP
        BlzFrameSetPoint(slot.button, FRAMEPOINT_LEFT, heroButton, FRAMEPOINT_RIGHT, xOff, 0)
        self.heroBuffSlots[i] = slot
    end

    -- ── Selected unit portrait (top-right corner) ─────────────────────────────
    self.portraitFrame = BlzCreateFrameByType("BACKDROP", "SelUnitPortrait", gameUI, "", 100)
    BlzFrameSetSize(self.portraitFrame, PORTRAIT_SIZE, PORTRAIT_SIZE)
    BlzFrameSetAbsPoint(self.portraitFrame, FRAMEPOINT_TOPRIGHT, PORTRAIT_TR_X, PORTRAIT_TR_Y)
    BlzFrameSetVisible(self.portraitFrame, false)

    -- ── Selected unit buff row (left of the portrait) ─────────────────────────
    for i = 1, MAX_SELECT_BUFFS do
        local slot = newIconSlot(gameUI, 100 + i)
        local xOff = -((i - 1) * ICON_STEP + ICON_GAP)
        BlzFrameSetPoint(slot.button, FRAMEPOINT_RIGHT, self.portraitFrame, FRAMEPOINT_LEFT, xOff, 0)
        self.selectBuffSlots[i] = slot
    end

    -- ── Track local hero ──────────────────────────────────────────────────────
    ExTriggerRegisterNewUnit(function(unit)
        if IsUnitType(unit, UNIT_TYPE_HERO) and GetOwningPlayer(unit) == GetLocalPlayer() then
            self.localHero = unit
        end
    end)
    ExTriggerRegisterUnitDeath(function(unit)
        if unit == self.localHero then
            self.localHero = nil
        end
    end)

    -- ── Track selection ───────────────────────────────────────────────────────
    local selTrig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(selTrig, EVENT_PLAYER_UNIT_SELECTED)
    TriggerAddAction(selTrig, function()
        if GetTriggerPlayer() == GetLocalPlayer() then
            self.selectedUnit = GetTriggerUnit()
        end
    end)

    local deselTrig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(deselTrig, EVENT_PLAYER_UNIT_DESELECTED)
    TriggerAddAction(deselTrig, function()
        if GetTriggerPlayer() == GetLocalPlayer() then
            self.selectedUnit = nil
        end
    end)
end

-- ──────────────────────────────────────────────────────────────────────────────
-- Per-frame refresh
-- ──────────────────────────────────────────────────────────────────────────────

---Sync one row of buff slots with the live buff list for `unit`.
---@param slots table[]
---@param unit unit|nil
function cls:_syncSlots(slots, unit)
    local buffs = (unit and BuffBase.unitBuffs[unit]) or {}
    for i, slot in ipairs(slots) do
        local buff = buffs[i]
        if buff then
            BlzFrameSetTexture(slot.icon, getBuffIcon(buff), 0, true)
            BlzFrameSetVisible(slot.button, true)

            local name = (buff.buffName ~= "" and buff.buffName) or buff.__cname or "Buff"
            local body = buff.description
            if not body or body == "" then
                body = string.format("|cffffd700剩余:|r %.1fs  |cffffd700层数:|r %d",
                    buff:GetTimeLeft(), buff.stack or 1)
            end
            BlzFrameSetText(slot.tipTitle, "|cffffd700" .. name .. "|r")
            BlzFrameSetText(slot.tipDesc, body)
            slot.buff = buff
        else
            BlzFrameSetVisible(slot.button, false)
            slot.buff = nil
        end
    end
end

function cls:Update(_, _)
    -- Hero buff bar
    self:_syncSlots(self.heroBuffSlots, self.localHero)

    -- Selected unit portrait + buff bar
    local sel = self.selectedUnit
    if sel and GetUnitTypeId(sel) ~= 0 then
        BlzFrameSetTexture(self.portraitFrame, getUnitIcon(sel), 0, true)
        BlzFrameSetVisible(self.portraitFrame, true)
        self:_syncSlots(self.selectBuffSlots, sel)
    else
        BlzFrameSetVisible(self.portraitFrame, false)
        self:_syncSlots(self.selectBuffSlots, nil)
    end
end

return cls

end}

__modules["System.MoonGladeSystem"]={loader=function()
local SystemBase = require("System.SystemBase")
local Vector2 = require("Lib.Vector2")
local Timer = require("Lib.Timer")
local Const = require("Config.Const")
local EventCenter = require("Lib.EventCenter")
local Event = require("Lib.Event")

EventCenter.DefaultOrder = Event.new()

local MyBase = Vector2.new(4022, 4110)
local EnemyBase = Vector2.new(-4248, -5806)
local MyPlayer = Player(0)
local EnemyPlayer = Player(3)

local Interval = 30
local DefaultOrder = {}

local MyArmy = {
    { [FourCC("earc")] = 4 },
    { [FourCC("esen")] = 4 },
    { [FourCC("earc")] = 4, [FourCC("esen")] = 2 },
    { [FourCC("esen")] = 2, [FourCC("ebal")] = 2 },
    { [FourCC("earc")] = 2, [FourCC("esen")] = 4 },
    { [FourCC("edry")] = 4 },
    { [FourCC("edoc")] = 4 },
    { [FourCC("earc")] = 4, [FourCC("edoc")] = 2 },
    { [FourCC("earc")] = 6 },
}

local EnemyArmy = {
    { [FourCC("nfel")] = 4 },
    { [FourCC("nfel")] = 4, [FourCC("nbal")] = 1 },
    { [FourCC("nfel")] = 4, [FourCC("nvde")] = 1 },
    { [FourCC("nfel")] = 6, [FourCC("nbal")] = 1 },
    { [FourCC("nfel")] = 6, [FourCC("ninf")] = 1 },
    { [FourCC("nfel")] = 6, [FourCC("nbal")] = 1 },
    { [FourCC("nfel")] = 8, [FourCC("ndqs")] = 1 },
    { [FourCC("nfel")] = 8, [FourCC("nbal")] = 1 },
    { [FourCC("nfel")] = 8, [FourCC("nerw")] = 1 },
}

---@class MoonGladeSystem : SystemBase
local cls = class("MoonGladeSystem", SystemBase)

function cls:Awake()
    local index = 1
    local function spawn()
        local myArmy = MyArmy[math.clamp(index, 1, #MyArmy)]
        for utid, count in pairs(myArmy) do
            for _ = 1, count do
                local u = CreateUnit(MyPlayer, utid, MyBase.x, MyBase.y, 0)
                IssuePointOrderById(u, Const.OrderId_Attack, EnemyBase.x, EnemyBase.y)
                DefaultOrder[u] = { Const.OrderId_Attack, EnemyBase.x, EnemyBase.y }
            end
        end
        local enemyArmy = EnemyArmy[math.clamp(index, 1, #EnemyArmy)]
        for utid, count in pairs(enemyArmy) do
            for _ = 1, count do
                local u = CreateUnit(EnemyPlayer, utid, EnemyBase.x, EnemyBase.y, 0)
                IssuePointOrderById(u, Const.OrderId_Attack, MyBase.x, MyBase.y)
                DefaultOrder[u] = { Const.OrderId_Attack, MyBase.x, MyBase.y }
            end
        end
        index = index + 1
    end
    spawn()
    Timer.new(spawn, Interval, -1):Start()

    CreateUnit(MyPlayer, FourCC("E001"), MyBase.x, MyBase.y, 0)

    EventCenter.DefaultOrder:On(self, cls._onDefaultOrder)
end

function cls:_onDefaultOrder(unit)
    local order = DefaultOrder[unit]
    if not order then
        return
    end
    IssuePointOrderById(unit, order[1], order[2], order[3])
end

return cls

end}

__modules["Lib.EventCenter"]={loader=function()
local Event = require("Lib.Event")

local cls = {}

cls.FrameBegin = Event.new()
cls.FrameUpdate = Event.new()

function cls.Report()
    print("--- FrameBegin ---")
    print(cls.FrameBegin:ToString())
    print("--- FrameUpdate ---")
    print(cls.FrameUpdate:ToString())
end

return cls

end}

__modules["Lib.Timer"]={loader=function()
require("Lib.MathExt")

local pcall = pcall
local t_insert = table.insert
local t_remove = table.remove

local PauseTimer = PauseTimer
local CreateTimer = CreateTimer
local TimerStart = TimerStart
local TimerGetElapsed = TimerGetElapsed

local pool = {}

local function getTimer()
    if #pool == 0 then
        return CreateTimer()
    else
        return t_remove(pool)
    end
end

local function cacheTimer(timer)
    PauseTimer(timer)
    t_insert(pool, timer)
end

---@class Timer
local cls = class("Timer")

function cls:ctor(func, duration, loops)
    self.timer = getTimer()
    self.func = func
    self.duration = duration
    if loops == 0 then
        loops = 1
    end
    self.loops = loops
end

function cls:Start()
    TimerStart(self.timer, self.duration, self.loops ~= 1, function()
        local dt = TimerGetElapsed(self.timer)
        local s, m = pcall(self.func, dt)
        if not s then
            print(m)
            return
        end

        if self.loops > 0 then
            self.loops = self.loops - 1
            if self.loops == 0 then
                self:Stop()
                return
            end
        end
    end)
end

function cls:SetOnStop(onStop)
    self.onStop = onStop
end

function cls:Stop()
    if self.stopped then
        return
    end
    self.stopped = true
    if self.onStop then
        self.onStop()
    end
    cacheTimer(self.timer)
end

return cls

end}

__modules["Lib.MathExt"]={loader=function()
function math.fuzzyEquals(a, b, precision)
    precision = precision or 0.000001
    return (a == b) or math.abs(a - b) < precision
end

---@param t real ratio 0-1
---@param c1 real
---@param c2 real
---@param c3 real
---@return real
function math.bezier3(t, c1, c2, c3)
    local t1 = 1 - t
    return c1 * t1 * t1 + c2 * 2 * t1 * t + c3 * t * t
end

function math.clamp(value, min, max)
    return math.min(math.max(min, value), max)
end

function math.clamp01(value)
    return math.clamp(value, 0, 1)
end

math.atan2 = Atan2

local m_floor = math.floor
local MathRound = MathRound

function math.round(value)
    return MathRound(value)
end

end}

__modules["Lib.Event"]={loader=function()
require("Lib.class")

local t_insert = table.insert
local t_concat = table.concat
local s_format = string.format
local next = next
local pairs = pairs
local tostring = tostring

---@class Event
local cls = class("Event")

function cls:ctor()
    self._handlers = {}
end

---@generic T, E
---@param context T
---@param listener fun(context: T, data: E)
function cls:On(context, listener)
    local map = self._handlers[context]
    if map == nil then
        map = {}
        self._handlers[context] = map
    end
    map[listener] = 1
end

---@generic T, E
---@param context T
---@param listener fun(context: T, data: E)
function cls:Off(context, listener)
    local map = self._handlers[context]
    if map == nil then
        return
    end
    map[listener] = nil
    if next(map) == nil then
        self._handlers[context] = nil
    end
end

---@generic E
---@param data E
function cls:Emit(data)
    for context, map in pairs(self._handlers) do
        for listener, _ in pairs(map) do
            listener(context, data)
        end
    end
end

function cls:ToString()
    local sb = {}
    for context, map in pairs(self._handlers) do
        for listener, _ in pairs(map) do
            t_insert(sb, s_format("%s -> %s", tostring(context), tostring(listener)))
        end
    end
    return t_concat(sb, ",")
end

return cls

end}

__modules["System.SystemBase"]={loader=function()
---@class SystemBase
local cls = class("SystemBase")

function cls:Awake()
end

function cls:OnEnable()
end

---@param dt real
function cls:Update(dt)
end

function cls:OnDisable()
end

function cls:OnDestroy()
end

return cls

end}

__modules["Objects.UnitAttribute"]={loader=function()
local Power = { 1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048 }
local Temp = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }

local PositiveAtk = {
    FourCC("A00C"),
    FourCC("A00D"),
    FourCC("A00E"),
    FourCC("A00F"),
    FourCC("A00G"),
    FourCC("A00H"),
    FourCC("A00I"),
    FourCC("A00J"),
    FourCC("A00K"),
    FourCC("A00L"),
    FourCC("A00M"),
    FourCC("A00N"),
}

local PositiveHp = {
    FourCC("A00O"),
    FourCC("A00P"),
    FourCC("A00Q"),
    FourCC("A00R"),
    FourCC("A00S"),
    FourCC("A00T"),
    FourCC("A00U"),
    FourCC("A00V"),
    FourCC("A00W"),
    FourCC("A00X"),
    FourCC("A00Y"),
    FourCC("A00Z"),
}

local function i2b(v)
    local bin = table.shallow(Temp)
    for i = #Power, 1, -1 do
        local b = Power[i]
        if v >= b then
            v = v - b
            bin[i] = 1
        end
    end
    return bin
end

---@class UnitAttribute
local cls = class("UnitAttribute")

cls.HeroAttributeType = {
    Strength = 1,
    Agility = 2,
    Intelligent = 3,
}

cls.tab = {}---@type table<unit, UnitAttribute>

---@return UnitAttribute
function cls.GetAttr(unit)
    local inst = cls.tab[unit]
    if not inst then
        inst = cls.new(unit)
        if unit == nil then
            print(GetStackTrace())
        end
        cls.tab[unit] = inst
    end

    return inst
end

function cls:ctor(unit)
    self.owner = unit

    self.baseAtk = BlzGetUnitBaseDamage(unit, 0) + (BlzGetUnitDiceSides(unit, 0) + 1) / 2 * BlzGetUnitDiceNumber(unit, 0)
    self.baseHp = BlzGetUnitMaxHP(unit)
    self.baseMs = GetUnitDefaultMoveSpeed(unit)

    self._atk = table.shallow(Temp)
    self.atk = 0

    self._hp = table.shallow(Temp)
    self.hp = 0

    self.ms = 0
    self.msp = 0

    self.dodge = 0

    self.damageAmplification = 0
    self.damageReduction = 0
    self.healingTaken = 0

    self.taunted = {} ---被嘲讽的目标
    self.absorbShields = {} ---吸收盾

    self.sanity = 0
end

function cls:GetHeroMainAttr(type, ignoreBonus)
    if not IsUnitType(self.owner, UNIT_TYPE_HERO) then
        return 0
    end
    if type == cls.HeroAttributeType.Strength then
        return GetHeroStr(self.owner, not ignoreBonus)
    end
    if type == cls.HeroAttributeType.Agility then
        return GetHeroAgi(self.owner, not ignoreBonus)
    end
    if type == cls.HeroAttributeType.Intelligent then
        return GetHeroInt(self.owner, not ignoreBonus)
    end
    return 0
end

---@param type integer HeroAttributeType
function cls:SimAttack(type)
    return BlzGetUnitBaseDamage(self.owner, 0) + math.random(1, BlzGetUnitDiceSides(self.owner, 0)) * BlzGetUnitDiceNumber(self.owner, 0) + self:GetHeroMainAttr(type)
end

function cls:_reflect(targetValue, currentBits, lookup)
    local newBits = i2b(math.round(targetValue))
    for i, b in ipairs(newBits) do
        if b ~= currentBits[i] then
            if b == 1 then
                UnitAddAbility(self.owner, lookup[i])
                UnitMakeAbilityPermanent(self.owner, true, lookup[i])
            else
                UnitRemoveAbility(self.owner, lookup[i])
            end
            currentBits[i] = b
        end
    end
end

function cls:Commit()
    self:_reflect(self.atk, self._atk, PositiveAtk)
    self:_reflect(self.hp, self._hp, PositiveHp)

    local ms = self.baseMs * (1 + self.msp) + self.ms
    SetUnitMoveSpeed(self.owner, ms)
end

function cls:TauntedBy(caster, duration)
    table.insert(self.taunted, caster)
    coroutine.start(function()
        coroutine.wait(duration)
        table.iRemoveOneLeft(self.taunted, caster)
    end)
end

ExTriggerRegisterNewUnit(cls.GetAttr)

return cls

end}

__modules["Config.Const"]={loader=function()
local cls = {}

cls.OrderId_Stop = 851972
cls.OrderId_Smart = 851971
cls.OrderId_Attack = 851983

cls.HitResult_Hit = 1
cls.HitResult_Miss = 2
cls.HitResult_Critical = 4

return cls

end}

__modules["Lib.Vector2"]={loader=function()
local setmetatable = setmetatable
local type = type
local rawget = rawget
local m_sqrt = math.sqrt

local GetUnitX = GetUnitX
local GetUnitY = GetUnitY

---@class Vector2
local cls = {}
Vector2 = cls

cls._loc = Location(0, 0)

---@return Vector2
function cls.new(x, y)
    return setmetatable({
        x = x or 0,
        y = y or 0,
    }, cls)
end

local new = cls.new

---@param unit unit
function cls.FromUnit(unit)
    return new(GetUnitX(unit), GetUnitY(unit))
end

function cls.InsideUnitCircle()
    local angle = math.random() * math.pi * 2
    return new(math.cos(angle), math.sin(angle))
end

function cls.Dot(a, b)
    return a.x * b.x + a.y * b.y
end

function cls.Cross(a, b)
    return a.y * b.x - a.x * b.y
end

function cls.UnitDistance(u1, u2)
    local v1 = cls.FromUnit(u1)
    local v2 = cls.FromUnit(u2)
    return v1:Sub(v2):Magnitude()
end

function cls.UnitDistanceSqr(u1, u2)
    local v1 = cls.FromUnit(u1)
    local v2 = cls.FromUnit(u2)
    return v1:Sub(v2):MagnitudeSqr()
end

---@param unit unit
function cls:MoveToUnit(unit)
    self.x = GetUnitX(unit)
    self.y = GetUnitY(unit)
    return self
end

---@param unit unit
function cls:UnitMoveTo(unit)
    SetUnitPosition(unit, self.x, self.y)
    return self
end

---@param other Vector2
function cls:SetTo(other)
    self.x = other.x
    self.y = other.y
    return
end

---@param other Vector2
function cls:Add(other)
    self.x = self.x + other.x
    self.y = self.y + other.y
    return self
end

---@param other Vector2
function cls:Sub(other)
    self.x = self.x - other.x
    self.y = self.y - other.y
    return self
end

---@param d real
function cls:Div(d)
    self.x = self.x / d
    self.y = self.y / d
    return self
end

---@param d real
function cls:Mul(d)
    self.x = self.x * d
    self.y = self.y * d
    return self
end

function cls:SetNormalize()
    local magnitude = self:Magnitude()

    if magnitude > 1e-05 then
        self.x = self.x / magnitude
        self.y = self.y / magnitude
    else
        self.x = 0
        self.y = 0
    end

    return self
end

function cls:Normalized()
    return self:Clone():SetNormalize()
end

function cls:SetMagnitude(len)
    self:SetNormalize():Mul(len)
    return self
end

---@param angle real radians
function cls:RotateSelf(angle)
    local cos = math.cos(angle)
    local sin = math.sin(angle)
    local x = cos * self.x - sin * self.y
    local y = sin * self.x + cos * self.y
    self.x = x
    self.y = y
    return self
end

---@param angle real radians
function cls:Rotate(angle)
    return self:Clone():RotateSelf(angle)
end

function cls:Clone()
    return new(self.x, self.y)
end

function cls:GetTerrainZ()
    MoveLocation(cls._loc, self.x, self.y)
    return GetLocationZ(cls._loc)
end

function cls:Magnitude()
    return m_sqrt(self.x * self.x + self.y * self.y)
end

function cls:MagnitudeSqr()
    return self.x * self.x + self.y * self.y
end

---@return string
function cls:tostring()
    return string.format("(%f,%f)", self.x, self.y)
end

function cls.__index(_, k)
    return rawget(cls, k)
end

function cls.__add(a, b)
    return new(a.x + b.x, a.y + b.y)
end

---@return Vector2
function cls.__sub(a, b)
    return new(a.x - b.x, a.y - b.y)
end

function cls.__div(v, d)
    return new(v.x / d, v.y / d)
end

function cls.__mul(a, d)
    if type(d) == "number" then
        return new(a.x * d, a.y * d)
    else
        return new(a * d.x, a * d.y)
    end
end

function cls.__unm(v)
    return new(-v.x, -v.y)
end

function cls.__eq(a, b)
    return ((a.x - b.x) ^ 2 + (a.y - b.y) ^ 2) < 9.999999e-11
end

setmetatable(cls, cls)

return cls

end}

__modules["Lib.Utils"]={loader=function()
local m_floor = math.floor
local s_sub = string.sub

local cls = {}

local ccMap = ""
        .. "................"
        .. "................"
        .. " !\"#$%&'()*+,-./"
        .. "0123456789:;<=>?"
        .. "@ABCDEFGHIJKLMNO"
        .. "PQRSTUVWXYZ[\\]^_"
        .. "`abcdefghijklmno"
        .. "pqrstuvwxyz{|}~."
        .. "................"
        .. "................"
        .. "................"
        .. "................"
        .. "................"
        .. "................"
        .. "................"
        .. "................"

function cls.CCFour(value)
    local d1 = m_floor(value / 16777216)
    value = value - d1 * 16777216
    d1 = d1 + 1
    local d2 = m_floor(value / 65536)
    value = value - d2 * 65536
    d2 = d2 + 1
    local d3 = m_floor(value / 256)
    value = value - d3 * 256
    d3 = d3 + 1
    value = value + 1
    return s_sub(ccMap, d1, d1) .. s_sub(ccMap, d2, d2) .. s_sub(ccMap, d3, d3) .. s_sub(ccMap, value, value)
end

local AbilIdAmrf = FourCC("Amrf")

function cls.SetUnitFlyable(unit)
    UnitAddAbility(unit, AbilIdAmrf);
    UnitRemoveAbility(unit, AbilIdAmrf);
end

return cls

end}

__modules["Ability.FireBreath"]={loader=function()
local Vector2 = require("Lib.Vector2")
local EventCenter = require("Lib.EventCenter")
local Timer = require("Lib.Timer")
local Abilities = require("Config.Abilities")
local Tween = require("Lib.Tween")
local BuffBase = require("Objects.BuffBase")

local cls = class("FireBreath")

local Meta = {
    ID = FourCC("A01D"),
    Duration = 6,
    Interval = 2,
    ChargeInterval = 1,
    ChargeAmp = 0.15,
    ChannelDuration = 3,
    Damage = 80,
    DOT = 10,
    Heal = 160,
    AOE = 600,
}

BlzSetAbilityResearchTooltip(Meta.ID, "学习火焰吐息 - [|cffffcc00%d级|r]", 0)
BlzSetAbilityResearchExtendedTooltip(Meta.ID, string.format([[深吸一口气然后喷出，造成前方锥形龙息并击飞的效果，对敌军造成伤害并在接下来的|cffff8c00%s|r秒内每|cffff8c00%s|r秒灼烧目标，或者治疗友军单位。每蓄力|cffff8c00%s|r秒可以使效果增幅|cffff8c00%s|r，最多|cffff8c00%s|r秒。

|cff99ccff冷却时间|r - 10秒

|cffffcc001级|r - 造成|cffff8c00%s|r点基础伤害，|cffff8c00%s|r点持续伤害，|cffff8c00%s|r点治疗。]],
        Meta.Duration, Meta.Interval, Meta.ChargeInterval, string.formatPercentage(Meta.ChargeAmp), Meta.ChannelDuration,
        Meta.Damage, Meta.DOT, Meta.Heal
), 0)

for i = 1, 1 do
    BlzSetAbilityTooltip(Meta.ID, string.format("火焰吐息 - [|cffffcc00%s级|r]", i), i - 1)
    BlzSetAbilityExtendedTooltip(Meta.ID, string.format(
            [[深吸一口气然后喷出，造成前方锥形龙息并击飞的效果，对敌军造成|cffff8c00%s|r点伤害并在接下来的|cffff8c00%s|r秒内每|cffff8c00%s|r秒灼烧目标，造成|cffff8c00%s|r点伤害，或者治疗友军单位|cffff8c00%s|r点生命。每蓄力|cffff8c00%s|r秒可以使效果增幅|cffff8c00%s|r，最多|cffff8c00%s|r秒。

|cff99ccff冷却时间|r - 10秒]],
            Meta.Damage, Meta.Duration, Meta.Interval, Meta.DOT, Meta.Heal, Meta.ChargeInterval, string.formatPercentage(Meta.ChargeAmp), Meta.ChannelDuration
    ), i - 1)
end

Abilities.FireBreath = Meta

---@class FireBreathBurn : BuffBase
local FireBreathBurn = class("FireBreathBurn", BuffBase)

function FireBreathBurn:Awake()
    self.charged = self.awakeData.charged
end

function FireBreathBurn:OnEnable()
    self.sfx = AddSpecialEffectTarget("Abilities/Spells/Other/BreathOfFire/BreathOfFireDamage.mdl", self.target, "overhead")
end

function FireBreathBurn:Update()
    EventCenter.Damage:Emit({
        whichUnit = self.caster,
        target = self.target,
        amount = Meta.DOT * (1 + Meta.ChargeAmp * self.charged),
        attack = false,
        ranged = true,
        attackType = ATTACK_TYPE_HERO,
        damageType = DAMAGE_TYPE_FIRE,
        weaponType = WEAPON_TYPE_WHOKNOWS,
        outResult = {}
    })
end

function FireBreathBurn:OnDisable()
    DestroyEffect(self.sfx)
end

function FireBreathBurn.Cast(caster, target, charged)
    local debuff = BuffBase.FindBuffByClassName(target, FireBreathBurn.__cname)
    if debuff then
        debuff:ResetDuration()
    else
        FireBreathBurn.new(caster, target, Meta.Duration, Meta.Interval, { charged = charged })
    end
end

local instances = {}

function cls:ctor(caster, x, y)
    self.charging = AddSpecialEffectTarget("Abilities/Weapons/RedDragonBreath/RedDragonMissile.mdl", caster, "weapon")
    BlzSetSpecialEffectScale(self.charging, 0.1)
    self.charged = 0
    self.caster = caster
    self.targetPos = Vector2.new(x, y)

    self.timer = Timer.new(function()
        self.charged = self.charged + 1
        BlzSetSpecialEffectScale(self.charging, 0.1 + self.charged * 0.3)
    end, 1, -1)
    self.timer:Start()
end

function cls:stop()
    self.timer:Stop()
    DestroyEffect(self.charging)

    local casterPos = Vector2.FromUnit(self.caster)
    local dir = (self.targetPos - casterPos):SetNormalize()
    local offset = dir * 270
    local v = casterPos + offset
    local sfx = AddSpecialEffect("Abilities/Spells/Other/BreathOfFire/BreathOfFireMissile.mdl", v.x, v.y)
    BlzSetSpecialEffectYaw(sfx, math.atan2(dir.y, dir.x))
    local travelled = 0
    Tween.To(function()
        return travelled
    end, function(value)
        travelled = value
        local now = v + dir * travelled
        BlzSetSpecialEffectX(sfx, now.x)
        BlzSetSpecialEffectY(sfx, now.y)
    end, 600, 1)

    if self.charged < 1 then
        return
    end

    local casterPlayer = GetOwningPlayer(self.caster)
    local enumPos = casterPos - dir * 10
    ExGroupEnumUnitsInRange(enumPos.x, enumPos.y, 750, function(unit)
        if Vector2.Dot(dir, Vector2.FromUnit(unit):Sub(enumPos):SetNormalize()) > 0.28 and not ExIsUnitDead(unit) then
            if IsUnitEnemy(unit, casterPlayer) then
                EventCenter.Damage:Emit({
                    whichUnit = self.caster,
                    target = unit,
                    amount = Meta.Damage * (1 + Meta.ChargeAmp * self.charged),
                    attack = false,
                    ranged = true,
                    attackType = ATTACK_TYPE_HERO,
                    damageType = DAMAGE_TYPE_FIRE,
                    weaponType = WEAPON_TYPE_WHOKNOWS,
                    outResult = {}
                })
                FireBreathBurn.Cast(self.caster, unit, self.charged)
            else
                EventCenter.Heal:Emit({ caster = self.caster, target = unit, amount = Meta.Heal * (1 + Meta.ChargeAmp * self.charged) })
                ExAddSpecialEffectTarget("Abilities/Spells/Human/Heal/HealTarget.mdl", unit, "origin", 1)
            end
        end
    end)
end

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        instances[data.caster] = cls.new(data.caster, data.x, data.y)
    end
})

EventCenter.RegisterPlayerUnitSpellEndCast:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        local inst = instances[data.caster]
        if inst then
            inst:stop()
            instances[data.caster] = nil
        end
    end
})

return cls

end}

__modules["Ability.Disintegrate"]={loader=function()
local Vector2 = require("Lib.Vector2")
local EventCenter = require("Lib.EventCenter")
local Timer = require("Lib.Timer")
local Pill = require("Lib.Pill")
local Circle = require("Lib.Circle")
local UnitAttribute = require("Objects.UnitAttribute")
local Abilities = require("Config.Abilities")

local cls = class("Disintegrate")

local Meta = {
    ID = FourCC("A01E"),
    MoveSpeedPercent = -0.30,
    Damage = 150,
}

local Width = 64
local BackOffset = 10
local Radius = Width / 2
local PointMoveForward = Radius - 10

Abilities.Disintegrate = Meta

local instances = {}

function cls:ctor(caster, target)
    self.lightning, self.lightningCo = ExAddLightningUnitUnit("DRAM", target, caster, 9999, { r = 1, g = 1, b = 1, a = 1 }, false)
    self.slowedUnits = {}
    local casterPlayer = GetOwningPlayer(caster)
    local function exec()
        local a = Vector2.FromUnit(caster)
        local b = Vector2.FromUnit(target)
        local dir = b - a
        local center = a + dir:Div(2)
        local realDist = dir:Magnitude()
        dir:SetNormalize()
        local moveForwardOffset = math.min(realDist / 2, PointMoveForward)
        local offset = dir * moveForwardOffset
        a:Add(offset)
        b:Sub(offset)
        local pill = Pill.new(a, b, Radius)

        local enumRange = realDist / 2 + BackOffset
        ExAddSpecialEffectTarget("Abilities/Spells/NightElf/MoonWell/MoonWellCasterArt.mdl", caster, "origin", 1)
        ExGroupEnumUnitsInRange(center.x, center.y, enumRange + 197, function(unit)
            if not ExIsUnitDead(unit) and IsUnitEnemy(unit, casterPlayer) then
                local circle = Circle.new(Vector2.FromUnit(unit), Radius)
                if Pill.PillCircle(pill, circle) then
                    if not self.slowedUnits[unit] then
                        local attr = UnitAttribute.GetAttr(unit)
                        attr.msp = attr.msp + Meta.MoveSpeedPercent
                        attr:Commit()
                        self.slowedUnits[unit] = true
                    end

                    EventCenter.Damage:Emit({
                        whichUnit = caster,
                        target = unit,
                        amount = Meta.Damage,
                        attack = false,
                        ranged = true,
                        attackType = ATTACK_TYPE_HERO,
                        damageType = DAMAGE_TYPE_DIVINE,
                        weaponType = WEAPON_TYPE_WHOKNOWS,
                        outResult = {},
                    })
                    ExAddSpecialEffectTarget("Abilities/Spells/Human/ManaFlare/ManaFlareBoltImpact.mdl", unit, "origin", 0.5)
                end
            end
        end)
    end
    exec()
    self.timer = Timer.new(exec, 1, -1)
    self.timer:Start()
end

function cls:stop()
    self.timer:Stop()
    coroutine.stop(self.lightningCo)
    DestroyLightning(self.lightning)
    for unit, _ in pairs(self.slowedUnits) do
        local attr = UnitAttribute.GetAttr(unit)
        attr.msp = attr.msp - Meta.MoveSpeedPercent
        attr:Commit()
    end
    self.slowedUnits = {}
end

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        instances[data.caster] = cls.new(data.caster, data.target)
    end
})

EventCenter.RegisterPlayerUnitSpellEndCast:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        local inst = instances[data.caster]
        if inst then
            inst:stop()
            instances[data.caster] = nil
        else
            print("Disintegrate end but no instance")
        end
    end
})

return cls

end}

__modules["Ability.SleepWalk"]={loader=function()
local Vector2 = require("Lib.Vector2")
local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
--local Tween = require("Lib.Tween")
local Utils = require("Lib.Utils")
local Tween = require("Lib.Tween")

local cls = class("SleepWalk")

local Meta = {
    ID = FourCC("A01F"),
    EveryYards = 100,
    ManaRestore = 350,
    Speed = 50,
    MaxDuration = 10,
}

Abilities.SleepWalk = Meta

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        coroutine.start(function()
            PauseUnit(data.target, true)
            SetUnitPathing(data.target, false)
            --SetUnitAnimationByIndex(data.target, 0)

            ExAddSpecialEffectTarget("Abilities/Spells/Undead/Sleep/SleepSpecialArt.mdl", data.target, "overhead", 0.1)
            local sfx = AddSpecialEffectTarget("Abilities/Spells/Undead/Sleep/SleepTarget.mdl", data.target, "overhead")
            Utils.SetUnitFlyable(data.target)
            local originalHeight = GetUnitFlyHeight(data.target)
            local newHeight = originalHeight + 100
            Tween.To(function() return originalHeight end, function(value) SetUnitFlyHeight(data.target, value, 0) end, newHeight, 0.3)
            local sfx2 = AddSpecialEffectTarget("Abilities/Spells/NightElf/TargetArtLumber/TargetArtLumber.mdl", data.target, "foot")

            local travelled = 0
            local timeStart = Time.Time
            local frames = 0
            while true do
                coroutine.step()
                frames = frames + 1
                local dest = Vector2.FromUnit(data.caster)
                local curr = Vector2.FromUnit(data.target)
                local dir = (dest - curr):SetNormalize()
                local stepLen = Meta.Speed * Time.Delta

                --if frames % 9 == 0 then
                --    local shade = AddSpecialEffect("units/nightelf/MountainGiant/MountainGiant.mdl", curr.x, curr.y)
                --    BlzSetSpecialEffectYaw(shade, GetUnitFacing(data.target) * bj_DEGTORAD)
                --    local alpha = 1
                --    Tween.To(function()
                --        return alpha
                --    end, function(value)
                --        BlzSetSpecialEffectAlpha(shade, math.floor(value * 255))
                --    end, 0, 1)
                --end

                curr:Add(dir * stepLen):UnitMoveTo(data.target)
                SetUnitFacing(data.target, math.atan2(dir.y, dir.x) * bj_RADTODEG)
                travelled = travelled + stepLen
                if travelled >= Meta.EveryYards then
                    travelled = travelled - Meta.EveryYards
                    EventCenter.HealMana:Emit({
                        caster = data.caster,
                        target = data.caster,
                        amount = Meta.ManaRestore,
                        isPercentage = false
                    })
                    ExAddSpecialEffectTarget("Abilities/Spells/Items/AIma/AImaTarget.mdl", data.caster, "origin", 1)
                end
                if curr:Sub(dest):Magnitude() < 96 or (Time.Time - timeStart) > Meta.MaxDuration then
                    break
                end
            end

            Tween.To(function() return newHeight end, function(value) SetUnitFlyHeight(data.target, value, 0) end, originalHeight, 0.3)
            DestroyEffect(sfx)
            DestroyEffect(sfx2)
            PauseUnit(data.target, false)
            SetUnitPathing(data.target, true)
        end)
    end
})

return cls

end}

__modules["Ability.TimeWarp"]={loader=function()
local EventCenter = require("Lib.EventCenter")
local Timer = require("Lib.Timer")
local PILQueue = require("Lib.PILQueue")
local Abilities = require("Config.Abilities")

local cls = class("TimeWarp")

local Meta = {
    ID = FourCC("A01G"),
    ClockID = FourCC("e002"),
    Duration = 5,
    Radius = 600,
    ReverseSpeed = 5,
}

local queueSize = Meta.Duration / Time.Delta / Meta.ReverseSpeed
local reversing = {}
local recordingUnits = {}

Abilities.TimeWarp = Meta

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        local casterPlayer = GetOwningPlayer(data.caster)

        local clock = CreateUnit(casterPlayer, Meta.ClockID, data.x, data.y, 0)
        SetUnitAnimation(clock, "Stand Alternate")
        SetUnitTimeScale(clock, 10 / Meta.Duration)
        coroutine.start(function()
            coroutine.wait(Meta.Duration)
            SetUnitAnimation(clock, "Death")
            KillUnit(clock)
        end)

        reversing = {}
        coroutine.start(function()
            local units = ExGroupGetUnitsInRange(data.x, data.y, Meta.Radius)
            for i = #units, 1, -1 do
                local u = units[i]
                if IsUnit(u, data.caster) then
                    table.remove(units, i)
                else
                    reversing[u] = true
                end
            end
            local affectedUnits = {}
            while #units > 0 do
                coroutine.step()
                for i = #units, 1, -1 do
                    local u = units[i]
                    local q = recordingUnits[u]
                    if not q then
                        table.remove(units, i)
                    else
                        local d = q:peekright()
                        if d then
                            q:popright()
                            if IsUnitAlly(u, casterPlayer) then
                                local nowDead = ExIsUnitDead(u)
                                if nowDead and not d.dead then
                                    -- revive
                                    local revived = CreateUnit(GetOwningPlayer(u), GetUnitTypeId(u), d.x, d.y, d.f)
                                    SetWidgetLife(revived, d.hp)
                                    ExSetUnitMana(revived, d.mp)
                                    recordingUnits[revived] = q
                                    recordingUnits[u] = nil
                                    reversing[revived] = true
                                    units[i] = revived
                                elseif not nowDead and not d.dead then
                                    SetUnitPosition(u, d.x, d.y)
                                    affectedUnits[u] = true
                                    SetUnitFacing(u, d.f)
                                    SetWidgetLife(u, d.hp)
                                    ExSetUnitMana(u, d.mp)
                                end
                            else
                                if not ExIsUnitDead(u) then
                                    SetUnitPosition(u, d.x, d.y)
                                    affectedUnits[u] = true
                                    SetUnitFacing(u, d.f)
                                else
                                    table.remove(units, i)
                                end
                            end
                        else
                            table.remove(units, i)
                        end
                    end
                end
            end
            for u, _ in pairs(affectedUnits) do
                EventCenter.DefaultOrder:Emit(u)
            end
            reversing = {}
        end)
    end
})

ExTriggerRegisterNewUnit(function(unit)
    if (BlzBitAnd(GetUnitPointValue(unit), 1)) ~= 1 then
        recordingUnits[unit] = PILQueue.new(queueSize)
    end
end)

local decayTrigger = CreateTrigger()
TriggerRegisterAnyUnitEventBJ(decayTrigger, EVENT_PLAYER_UNIT_DECAY)
ExTriggerAddAction(decayTrigger, function()
    recordingUnits[GetDecayingUnit()] = nil
end)

local tm = Timer.new(function()
    for unit, q in pairs(recordingUnits) do
        if not reversing[unit] then
            q:pushright({
                x = GetUnitX(unit),
                y = GetUnitY(unit),
                f = GetUnitFacing(unit),
                hp = GetWidgetLife(unit),
                mp = ExGetUnitMana(unit),
                dead = ExIsUnitDead(unit),
            })
        end
    end
end, Time.Delta * Meta.ReverseSpeed, -1)
tm:Start()

return cls

end}

__modules["Ability.MagmaBreath"]={loader=function()
local EventCenter = require("Lib.EventCenter")
local Timer = require("Lib.Timer")
local Abilities = require("Config.Abilities")
local Tween = require("Lib.Tween")
local Vector3 = require("Lib.Vector3")
local Vector2 = require("Lib.Vector2")

local cls = class("MagmaBreath")

local Meta = {
    ID = FourCC("A01H"),
}

Abilities.MagmaBreath = Meta

local function aoeDamage(caster, x, y, damage, checkMap)
    local casterPlayer = GetOwningPlayer(caster)
    ExGroupEnumUnitsInRange(x, y, 120, function(unit)
        if IsUnitEnemy(unit, casterPlayer) and not ExIsUnitDead(unit) and not checkMap[unit] then
            EventCenter.Damage:Emit({
                whichUnit = caster,
                target = unit,
                amount = damage,
                attack = false,
                ranged = true,
                attackType = ATTACK_TYPE_HERO,
                damageType = DAMAGE_TYPE_FIRE,
                weaponType = WEAPON_TYPE_WHOKNOWS,
                outResult = {}
            })
            checkMap[unit] = true
        end
    end)
end

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        local myPos = Vector3.FromUnit(data.caster)
        local damaged1 = {}
        local damaged2 = {}
        myPos.z = myPos.z + 100
        local emitter = AddSpecialEffect("Abilities/Weapons/VengeanceMissile/VengeanceMissile.mdl", myPos.x, myPos.y)
        BlzSetSpecialEffectZ(emitter, myPos.z)
        BlzSetSpecialEffectScale(emitter, 3)
        local tarPos = Vector3.new(data.x, data.y)
        local dir = (tarPos - myPos):SetNormalize()
        local curr = myPos + dir
        local lightning = AddLightningEx("SPLK", false, myPos.x, myPos.y, myPos.z, curr.x, curr.y, curr:GetTerrainZ())
        SetLightningColor(lightning, 1, 0.5, 0.5, 1)
        local travelled = 0
        local i = 0
        local p1 = myPos:Clone()
        local casterPlayer = GetOwningPlayer(data.caster)

        local function run(value)
            curr = p1 + dir * value
            MoveLightningEx(lightning, false, myPos.x, myPos.y, myPos.z, curr.x, curr.y, curr:GetTerrainZ())
            ExAddSpecialEffect("Abilities/Weapons/FireBallMissile/FireBallMissile.mdl", curr.x, curr.y, 0.0)
            aoeDamage(data.caster, curr.x, curr.y, 100, damaged1)

            local currIndex = math.floor(value / 50)
            while i <= currIndex do
                local cx, cy = curr.x, curr.y
                local tm = Timer.new(function()
                    ExAddSpecialEffect("Abilities/Weapons/Mortar/MortarMissile.mdl", cx, cy, 0.0)
                    aoeDamage(data.caster, cx, cy, 500, damaged2)
                end, 0.7, 1)
                tm:Start()
                i = i + 1
            end
        end

        local tween = Tween.To(function()
            return travelled
        end, run, 2400, 2, Tween.Type.InQuint)
        local nearTargets = ExGroupGetUnitsInRange(myPos.x, myPos.y, 1500)
        table.iFilterInPlace(nearTargets, function(item)
            if ExIsUnitDead(item) then
                return false
            end
            if IsUnitAlly(item, casterPlayer) then
                return false
            end
            if IsUnit(item, data.caster) then
                return false
            end
            return true
        end)
        if #nearTargets > 0 then
            local refPos = Vector2.FromUnit(data.caster)
            local v2Dir = (Vector2.new(data.x, data.y) - refPos):SetNormalize()
            table.sort(nearTargets, function(a, b)
                local da = (Vector2.FromUnit(a) - refPos):SetNormalize()
                local db = (Vector2.FromUnit(b) - refPos):SetNormalize()
                return math.abs(Vector2.Dot(v2Dir, da)) < math.abs(Vector2.Dot(v2Dir, db))
            end)
            local firstTarget = nearTargets[1]
            tween:AppendCallback(function()
                travelled = 0
                p1 = curr:Clone()
                dir = (Vector3.FromUnit(firstTarget) - p1):SetNormalize()
                damaged1 = {}
                damaged2 = {}
                i = 0
            end)
            tween = tween:Append(Tween.To(function()
                return travelled
            end, run, 2400, 2, Tween.Type.InQuint, true))
        end
        tween:AppendCallback(function()
            DestroyEffect(emitter)
            DestroyLightning(lightning)
        end)
    end
})

return cls

end}

__modules["Objects.BuffBase"]={loader=function()
local EventCenter = require("Lib.EventCenter")
local Time = require("Lib.Time")

---@class BuffBase
local cls = class("BuffBase")

cls.unitBuffs = {} ---@type table<unit, BuffBase[]>

---@param unit unit
---@param name string
---@return BuffBase | Nil, integer | Nil
function cls.FindBuffByClassName(unit, name)
    local arr = cls.unitBuffs[unit]
    if not arr then
        return nil
    end

    return table.iFind(arr, function(_, v)
        return v.__cname == name
    end)
end

---@param caster unit
---@param target unit
---@param duration real
---@param interval real
function cls:ctor(caster, target, duration, interval, awakeData)
    self.caster = caster
    self.target = target
    self.time = Time.CeilToNextUpdate(Time.Time)
    self.expire = self.time + duration
    self.duration = duration
    self.interval = interval
    self.nextUpdate = self.time + interval
    self.stack = 1

    -- Display fields – subclasses should override these for the buff UI.
    ---@type string   icon path shown in the buff bar, e.g. "ReplaceableTextures\\CommandButtons\\BTNxxx.blp"
    self.icon        = self.icon        or ""
    ---@type string   short localised name displayed in the tooltip title
    self.buffName    = self.buffName    or ""
    ---@type string   tooltip body text; leave empty to use the default time/stack display
    self.description = self.description or ""

    local unitTab = table.getOrCreateTable(cls.unitBuffs, target)
    table.insert(unitTab, self)

    self.awakeData = awakeData
    EventCenter.NewBuff:Emit(self)
end

function cls:Awake()
end

function cls:OnEnable()
end

function cls:Update()
end

function cls:OnDisable()
end

function cls:OnDestroy()
    local unitTab = cls.unitBuffs[self.target]
    if not table.removeItem(unitTab, self) then
        --print("Remove buff unit failed") todo 我看不到报错就没有错误
    end
end

function cls:ResetDuration(exprTime)
    exprTime = exprTime or (Time.Time + self.duration)
    self.expire = Time.CeilToNextUpdate(exprTime)
end

function cls:GetTimeLeft()
    return self.expire - self.time
end

function cls:GetTimeNorm()
    return math.clamp01(self:GetTimeLeft() / self.duration)
end

---叠一层buff
function cls:IncreaseStack(stacks)
    stacks = stacks or 1
    if stacks < 0 then
        return
    end
    self.stack = self.stack + stacks
    self:ResetDuration()
end

function cls:DecreaseStack(stacks)
    stacks = stacks or 1
    self.stack = self.stack - stacks
    if self.stack <= 0 then
        EventCenter.KillBuff:Emit(self)
    end
end

return cls

end}

__modules["Lib.class"]={loader=function()
require("Lib.clone")

---@param classname string
---@param super table?
function class(classname, super)
    local superType = type(super)
    local cls
    if superType ~= "function" and superType ~= "table" then
        superType = nil
        super = nil
    end
    if superType == "function" or (super and super.__ctype == 1) then
        cls = {}
        if superType == "table" then
            for k, v in pairs(super) do cls[k] = v end
            cls.__create = super.__create
            cls.super    = super
        else
            cls.__create = super
        end
        cls.ctor = function() end
        cls.__cname = classname
        cls.__ctype = 1
        function cls.new(...)
            local instance = cls.__create(...)
            for k, v in pairs(cls) do instance[k] = v end
            instance.class = cls
            instance:ctor(...)
            return instance
        end
    else
        if super then
            cls = clone(super)
            cls.super = super
        else
            cls = { ctor = function() end }
        end

        cls.__cname = classname
        cls.__ctype = 2
        cls.__index = cls
        function cls.new(...)
            local instance = setmetatable({}, cls)
            instance.class = cls
            instance:ctor(...)
            return instance
        end
    end
    return cls
end

end}

__modules["Config.Abilities"]={loader=function()
local data = {}

local cls = setmetatable({}, {
    __index = function(t, k)
        return data[k]
    end,
    __newindex = function(t, k, v)
        if data[k] then
            print("Error: duplicate ability name:", k)
        else
            data[k] = v
        end
    end
})

return cls

end}

__modules["Lib.Tween"]={loader=function()
local Timer = require("Lib.Timer")
local Time = require("Lib.Time")

local cls = class("Tween")

cls.Type = {
    Linear = 1,
    InQuint = 2,
}

cls.NextType = {
    Function = 1,
    Tween = 2,
}

local funcMap = {
    [cls.Type.Linear] = function(t)
        return t
    end,
    [cls.Type.InQuint] = function(t)
        return t * t * t * t
    end,
}

function cls:ctor()
    self.next = {}
end

function cls:AppendCallback(func)
    table.insert(self.next, {
        type = cls.NextType.Function,
        func = func,
    })
end

function cls:Append(tween)
    table.insert(self.next, {
        type = cls.NextType.Tween,
        tween = tween,
    })
    return tween
end

function cls:runOnStopCalls()
    for _, v in ipairs(self.next) do
        if v.type == cls.NextType.Function then
            v.func()
        elseif v.type == cls.NextType.Tween then
            v.tween.timer:Start()
        end
    end
end

---@param getter fun(): real
---@param setter fun(value: real): void
---@param target real
---@param duration real
---@param ease integer | Nil Tween.Type.*
function cls.To(getter, setter, target, duration, ease, dontStart)
    ease = ease or cls.Type.Linear
    local func = funcMap[ease]
    local frames = math.ceil(duration / Time.Delta)
    local t = 0
    local inst = cls.new()
    inst.timer = Timer.new(function()
        t = t + 1
        local c1 = getter()
        local value = c1 + (target - c1) * func(t / frames)
        setter(value)
    end, Time.Delta, frames)
    inst.timer:SetOnStop(function()
        inst:runOnStopCalls()
    end)
    if not dontStart then
        inst.timer:Start()
    end
    return inst
end

return cls

end}

__modules["Lib.Pill"]={loader=function()
---@class Pill
local cls = class("Pill")

---@param p1 Vector2
---@param p2 Vector2
---@param r real
function cls:ctor(p1, p2, r)
    self.p1 = p1
    self.p2 = p2
    self.r = r
end

---胶囊碰撞
---@param c1 Pill
---@param c2 Pill
---@return boolean
function cls.PillPill(c1, c2)
    local _caps = { c1, c2 }
    local rs = (c1.r + c2.r) * (c1.r + c2.r)
    for i = 1, 2 do
        local ii = i + 1
        if ii == 3 then
            ii = 1
        end
        local _vw = _caps[ii].p2 - _caps[ii].p1
        local vws2 = _vw:MagnitudeSqr()
        local _ps = { _caps[i].p1, _caps[i].p2 }
        for _, p in ipairs(_ps) do
            local t = math.clamp01(Vector2.Dot(p - _caps[ii].p1, _vw) / vws2)
            local _proj = _vw * t + _caps[ii].p1
            local dist = (_proj - p):MagnitudeSqr()
            if dist <= rs then
                return true
            end
        end
    end
    local _v1 = c1.p2 - c1.p1
    local _v2 = c2.p2 - c2.p1
    local _vw = c2.p1 - c1.p1
    local d = Vector2.Cross(_v1, _v2)
    local v = Vector2.Cross(_vw, _v1) / d
    local n = Vector2.Cross(_vw, _v2) / d
    if n >= 0 and n <= 1 and v >= 0 and v <= 1 then
        return true
    end
    return false
end

---@param capsule Pill
---@param circle Circle
function cls.PillCircle(capsule, circle)
    local rs = (capsule.r + circle.r) * (capsule.r + circle.r)
    local _vw = capsule.p2 - capsule.p1
    local vws2 = _vw:MagnitudeSqr()
    local t = math.clamp01(Vector2.Dot(circle.center - capsule.p1, _vw) / vws2)
    local _proj = _vw * t + capsule.p1
    if (_proj - circle.center):MagnitudeSqr() <= rs then
        return true
    else
        return false
    end
end

return cls

end}

__modules["Lib.Circle"]={loader=function()
---@class Circle
local cls = class("Circle")

---@param center Vector2
---@param r real
function cls:ctor(center, r)
    self.center = center
    self.r = r
end

---@param v Vector2
function cls:Contains(v)
    local dir = v - self.center
    return dir:Magnitude() <= self.r
end

function cls:Clone()
    return cls.new(self.center:Clone(), self.r)
end

function cls:tostring()
    return string.format("(%s,%s,%s)", self.center.x, self.center.y, self.r)
end

return cls

end}

__modules["Lib.PILQueue"]={loader=function()
-- https://www.lua.org/pil/11.4.html
local cls = class("PILQueue")

function cls:ctor(cap)
    self.cap = cap
    self.first = 0
    self.last = -1
end

function cls:pushleft(value)
    local first = self.first - 1
    self.first = first
    self[first] = value
    if self.cap and self:size() > self.cap then
        self:popright()
    end
end

function cls:pushright(value)
    local last = self.last + 1
    self.last = last
    self[last] = value
    if self.cap and self:size() > self.cap then
        self:popleft()
    end
end

function cls:popleft()
    local first = self.first
    if first > self.last then
        error("queue is empty")
    end
    local value = self[first]
    self[first] = nil -- to allow garbage collection
    self.first = first + 1
    return value
end

function cls:popright()
    local last = self.last
    if self.first > last then
        error("self is empty")
    end
    local value = self[last]
    self[last] = nil -- to allow garbage collection
    self.last = last - 1
    return value
end

function cls:peekleft()
    return self[self.first]
end

function cls:peekright()
    return self[self.last]
end

function cls:size()
    return self.last - self.first + 1
end

function cls:tostring()
    local sb = ""
    for i = self.first, self.last do
        sb = sb .. tostring(self[i]) .. " "
    end
    sb = sb .. "size:" .. self:size()
    return sb
end

return cls

end}

__modules["Lib.Vector3"]={loader=function()
local Utils = require("Lib.Utils")

local setmetatable = setmetatable
local type = type
local rawget = rawget
local m_sqrt = math.sqrt

local GetUnitX = GetUnitX
local GetUnitY = GetUnitY

---@class Vector3
local cls = {}

cls._loc = Location(0, 0)

local function getTerrainZ(x, y)
    MoveLocation(cls._loc, x, y)
    return GetLocationZ(cls._loc)
end

---@return Vector3
function cls.new(x, y, z)
    x = x or 0
    y = y or 0
    return setmetatable({
        x = x,
        y = y,
        z = z or getTerrainZ(x, y),
    }, cls)
end

local new = cls.new

---@param unit unit
function cls.FromUnit(unit)
    local x = GetUnitX(unit)
    local y = GetUnitY(unit)
    return new(x, y, getTerrainZ(x, y) + GetUnitFlyHeight(unit))
end

--function cls.InsideUnitCircle()
--    local angle = math.random() * math.pi * 2
--    return new(math.cos(angle), math.sin(angle))
--end

---@param unit unit
function cls:MoveToUnit(unit)
    self.x = GetUnitX(unit)
    self.y = GetUnitY(unit)
    self.z = getTerrainZ(self.x, self.y) + GetUnitFlyHeight(unit)
    return self
end

---@param unit unit
---@param mode integer modes. 1: force flying. 2: force to ground. other|Nil: flying units fly/ ground units grounded
function cls:UnitMoveTo(unit, mode)
    local tz = getTerrainZ(self.x, self.y)
    local defaultFlyHeight = GetUnitDefaultFlyHeight(unit)
    local minZ = tz + defaultFlyHeight
    SetUnitPosition(unit, self.x, self.y)
    if mode == 1 then
        Utils.SetUnitFlyable(unit)
        SetUnitFlyHeight(unit, math.max(minZ, self.z) - minZ, 0)
    elseif mode == 2 then
        SetUnitFlyHeight(unit, defaultFlyHeight, 0)
    else
        if IsUnitType(unit, UNIT_TYPE_FLYING) then
            SetUnitFlyHeight(unit, math.max(minZ, self.z) - minZ, 0)
        else
            SetUnitFlyHeight(unit, defaultFlyHeight, 0)
        end
    end
    return self
end

---@param other Vector3
function cls:SetTo(other)
    self.x = other.x
    self.y = other.y
    self.z = other.z
    return
end

function cls:Set(x, y, z)
    self.x = x
    self.y = y
    self.z = z or getTerrainZ(x, y)
end

---@param other Vector3
function cls:Add(other)
    self.x = self.x + other.x
    self.y = self.y + other.y
    self.z = self.z + other.z
    return self
end

---@param other Vector3
function cls:Sub(other)
    self.x = self.x - other.x
    self.y = self.y - other.y
    self.z = self.z - other.z
    return self
end

---@param d real
function cls:Div(d)
    self.x = self.x / d
    self.y = self.y / d
    self.z = self.z / d
    return self
end

---@param d real
function cls:Mul(d)
    self.x = self.x * d
    self.y = self.y * d
    self.z = self.z * d
    return self
end

function cls:SetNormalize()
    local magnitude = self:Magnitude()

    if magnitude > 1e-05 then
        self:Div(magnitude)
    else
        self.x = 0
        self.y = 0
        self.z = 0
    end

    return self
end

function cls:SetMagnitude(len)
    self:SetNormalize():Mul(len)
    return self
end

function cls:Clone()
    return new(self.x, self.y, self.z)
end

function cls:GetTerrainZ()
    return getTerrainZ(self.x, self.y)
end

function cls:Magnitude()
    return m_sqrt(self:SqrMagnitude())
end

function cls:SqrMagnitude()
    return self.x * self.x + self.y * self.y + self.z * self.z
end

function cls.Dot(lhs, rhs)
    return lhs.x * rhs.x + lhs.y * rhs.y + lhs.z * rhs.z
end

function cls.Scale(a, b)
    local x = a.x * b.x
    local y = a.y * b.y
    local z = a.z * b.z
    return new(x, y, z)
end

function cls.Cross(lhs, rhs)
    local x = lhs.y * rhs.z - lhs.z * rhs.y
    local y = lhs.z * rhs.x - lhs.x * rhs.z
    local z = lhs.x * rhs.y - lhs.y * rhs.x
    return new(x, y, z)
end

function cls.Project(v, onNormal)
    local num = onNormal:SqrMagnitude()

    if num < 0.0001 then
        return new(0, 0, 0)
    end

    local num2 = cls.Dot(v, onNormal)
    local v3 = onNormal:Clone()
    v3:Mul(num2 / num)
    return v3
end

function cls.ProjectOnPlane(v, planeNormal)
    local v3 = cls.Project(v, planeNormal)
    v3:Mul(-1)
    v3:Add(v)
    return v3
end

---@return string
function cls:tostring()
    return string.format("(%f,%f,%f)", self.x, self.y, self.z)
end

function cls.__index(_, k)
    return rawget(cls, k)
end

function cls.__add(a, b)
    return new(a.x + b.x, a.y + b.y, a.z + b.z)
end

---@return Vector3
function cls.__sub(a, b)
    return new(a.x - b.x, a.y - b.y, a.z - b.z)
end

function cls.__div(v, d)
    return new(v.x / d, v.y / d, v.y / d)
end

function cls.__mul(a, d)
    if type(d) == "number" then
        return new(a.x * d, a.y * d, a.z * d)
    else
        return a:Clone():MulQuaternion(d)
    end
end

function cls.__unm(v)
    return new(-v.x, -v.y, -v.z)
end

function cls.__eq(a, b)
    return ((a.x - b.x) ^ 2 + (a.y - b.y) ^ 2 + (a.z - b.z) ^ 2) < 9.999999e-11
end

function cls.up()
    return new(0, 0, 1)
end

function cls.down()
    return new(0, 0, -1)
end

function cls.right()
    return new(1, 0, 0)
end

function cls.left()
    return new(-1, 0, 0)
end

function cls.forward()
    return new(0, 1, 0)
end

function cls.back()
    return new(0, -1, 0)
end

function cls.zero()
    return new(0, 0, 0)
end

function cls.one()
    return new(1, 1, 1)
end

setmetatable(cls, cls)

return cls

end}

__modules["Lib.clone"]={loader=function()
---@generic T
---@param object T
---@return T
function clone(object)
    local lookup_table = {}
    local function _copy(obj)
        if type(obj) ~= "table" then
            return obj
        elseif lookup_table[obj] then
            return lookup_table[obj]
        end
        local new_table = {}
        lookup_table[obj] = new_table
        for key, value in pairs(obj) do
            new_table[_copy(key)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(obj))
    end
    return _copy(object)
end

end}

__modules["Main"].loader()
end
--lua-bundler:000108297

function InitGlobals()
end

function Unit000023_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 3), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000024_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 1), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000026_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 3), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000028_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 3), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000033_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 3), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000037_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 3), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000044_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 1), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000046_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 3), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000047_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 1), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000049_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 1), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000050_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 3), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000053_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 1), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000054_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 3), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000060_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 1), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000067_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 3), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000070_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 3), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function CreateBuildingsForPlayer0()
local p = Player(0)
local u
local unitID
local t
local life

u = BlzCreateUnitWithSkin(p, FourCC("etoe"), 4032.0, 4096.0, 270.000, FourCC("etoe"))
u = BlzCreateUnitWithSkin(p, FourCC("emow"), 3168.0, 5344.0, 270.000, FourCC("emow"))
u = BlzCreateUnitWithSkin(p, FourCC("emow"), 3360.0, 5088.0, 270.000, FourCC("emow"))
u = BlzCreateUnitWithSkin(p, FourCC("emow"), 3488.0, 3616.0, 270.000, FourCC("emow"))
u = BlzCreateUnitWithSkin(p, FourCC("emow"), 3680.0, 3552.0, 270.000, FourCC("emow"))
u = BlzCreateUnitWithSkin(p, FourCC("emow"), 3936.0, 3488.0, 270.000, FourCC("emow"))
u = BlzCreateUnitWithSkin(p, FourCC("emow"), 2720.0, 4256.0, 270.000, FourCC("emow"))
u = BlzCreateUnitWithSkin(p, FourCC("emow"), 2720.0, 4512.0, 270.000, FourCC("emow"))
u = BlzCreateUnitWithSkin(p, FourCC("emow"), 3936.0, 5024.0, 270.000, FourCC("emow"))
u = BlzCreateUnitWithSkin(p, FourCC("emow"), 4512.0, 4640.0, 270.000, FourCC("emow"))
u = BlzCreateUnitWithSkin(p, FourCC("emow"), 4640.0, 4384.0, 270.000, FourCC("emow"))
u = BlzCreateUnitWithSkin(p, FourCC("eaom"), 2816.0, 4800.0, 270.000, FourCC("eaom"))
u = BlzCreateUnitWithSkin(p, FourCC("eate"), 4256.0, 4704.0, 270.000, FourCC("eate"))
u = BlzCreateUnitWithSkin(p, FourCC("eaoe"), 3200.0, 4800.0, 270.000, FourCC("eaoe"))
u = BlzCreateUnitWithSkin(p, FourCC("eaow"), 3904.0, 4736.0, 270.000, FourCC("eaow"))
u = BlzCreateUnitWithSkin(p, FourCC("edob"), 4544.0, 3968.0, 270.000, FourCC("edob"))
u = BlzCreateUnitWithSkin(p, FourCC("etrp"), 3296.0, 3488.0, 270.000, FourCC("etrp"))
u = BlzCreateUnitWithSkin(p, FourCC("etrp"), 3104.0, 3296.0, 270.000, FourCC("etrp"))
u = BlzCreateUnitWithSkin(p, FourCC("etrp"), 2720.0, 3936.0, 270.000, FourCC("etrp"))
u = BlzCreateUnitWithSkin(p, FourCC("etrp"), 2528.0, 3744.0, 270.000, FourCC("etrp"))
u = BlzCreateUnitWithSkin(p, FourCC("edos"), 3584.0, 4736.0, 270.000, FourCC("edos"))
u = BlzCreateUnitWithSkin(p, FourCC("eden"), 3072.0, 4416.0, 270.000, FourCC("eden"))
end

function CreateBuildingsForPlayer3()
local p = Player(3)
local u
local unitID
local t
local life

u = BlzCreateUnitWithSkin(p, FourCC("ndkw"), -4224.0, -5824.0, 270.000, FourCC("ndkw"))
end

function CreateNeutralHostile()
local p = Player(PLAYER_NEUTRAL_AGGRESSIVE)
local u
local unitID
local t
local life

u = BlzCreateUnitWithSkin(p, FourCC("nfra"), -1222.5, 6180.6, 258.517, FourCC("nfra"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000028_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nfrl"), -1430.5, 6233.6, 296.405, FourCC("nfrl"))
u = BlzCreateUnitWithSkin(p, FourCC("nfrl"), -1009.5, 6089.3, 251.862, FourCC("nfrl"))
u = BlzCreateUnitWithSkin(p, FourCC("nfrb"), -4636.6, -2743.9, 312.620, FourCC("nfrb"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000054_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nfra"), 4341.5, -1883.2, 162.021, FourCC("nfra"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000033_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nfrl"), 4170.2, -1637.8, 173.917, FourCC("nfrl"))
u = BlzCreateUnitWithSkin(p, FourCC("nfrl"), 4150.9, -1920.9, 156.182, FourCC("nfrl"))
u = BlzCreateUnitWithSkin(p, FourCC("nfrl"), 913.3, -6775.3, 84.229, FourCC("nfrl"))
u = BlzCreateUnitWithSkin(p, FourCC("nfra"), 1014.9, -6952.9, 90.081, FourCC("nfra"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000046_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nfrl"), 1196.5, -6793.6, 100.316, FourCC("nfrl"))
u = BlzCreateUnitWithSkin(p, FourCC("nfrl"), -1548.7, -6937.7, 150.604, FourCC("nfrl"))
u = BlzCreateUnitWithSkin(p, FourCC("nfrl"), -1146.2, -6949.6, 73.800, FourCC("nfrl"))
u = BlzCreateUnitWithSkin(p, FourCC("nfrb"), -1344.9, -6851.7, 89.180, FourCC("nfrb"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000037_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nfrl"), 4331.1, -5664.8, 126.756, FourCC("nfrl"))
u = BlzCreateUnitWithSkin(p, FourCC("nfrl"), 2006.7, 6262.8, 267.963, FourCC("nfrl"))
u = BlzCreateUnitWithSkin(p, FourCC("nfrl"), 4371.7, -5153.2, 200.770, FourCC("nfrl"))
u = BlzCreateUnitWithSkin(p, FourCC("nfra"), -4228.4, 600.8, 344.551, FourCC("nfra"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000067_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nfrl"), -4133.6, 320.9, 358.829, FourCC("nfrl"))
u = BlzCreateUnitWithSkin(p, FourCC("nfrl"), -4081.1, 815.5, 331.262, FourCC("nfrl"))
u = BlzCreateUnitWithSkin(p, FourCC("nfrb"), 4346.5, -5397.0, 164.929, FourCC("nfrb"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000050_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nfrb"), 4388.9, 1442.5, 173.151, FourCC("nfrb"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000070_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nfrl"), 1601.4, 6236.1, 232.490, FourCC("nfrl"))
u = BlzCreateUnitWithSkin(p, FourCC("nfrb"), 1809.1, 6169.4, 267.682, FourCC("nfrb"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000023_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nfrb"), -4114.3, 3808.1, 340.470, FourCC("nfrb"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000026_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nfrl"), -4131.0, 3529.1, 0.000, FourCC("nfrl"))
u = BlzCreateUnitWithSkin(p, FourCC("nfrl"), -4088.3, 4021.5, 0.000, FourCC("nfrl"))
u = BlzCreateUnitWithSkin(p, FourCC("nfrl"), -4857.9, -2828.3, 354.590, FourCC("nfrl"))
u = BlzCreateUnitWithSkin(p, FourCC("nfrl"), -4638.7, -2463.3, 0.000, FourCC("nfrl"))
u = BlzCreateUnitWithSkin(p, FourCC("nsgt"), 4827.5, -3725.8, 195.073, FourCC("nsgt"))
SetUnitAcquireRange(u, 200.0)
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000049_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nspr"), 4767.0, -3937.9, 181.208, FourCC("nspr"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nspr"), 4594.8, -3725.2, 231.067, FourCC("nspr"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nsgt"), 3927.6, -6906.7, 116.145, FourCC("nsgt"))
SetUnitAcquireRange(u, 200.0)
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000024_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nfrl"), 4454.9, 1690.5, 218.050, FourCC("nfrl"))
u = BlzCreateUnitWithSkin(p, FourCC("nfrl"), 4414.2, 1178.9, 150.604, FourCC("nfrl"))
u = BlzCreateUnitWithSkin(p, FourCC("nsgt"), -3858.8, 5610.2, 312.801, FourCC("nsgt"))
SetUnitAcquireRange(u, 200.0)
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000060_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nspr"), 3736.6, -6929.6, 112.208, FourCC("nspr"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nspr"), 3873.4, -6692.6, 162.067, FourCC("nspr"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nsgt"), 1916.6, 2731.9, 312.930, FourCC("nsgt"))
SetUnitAcquireRange(u, 200.0)
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000044_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nspr"), -3648.2, 5621.1, 291.284, FourCC("nspr"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nspr"), -3788.9, 5386.3, 341.143, FourCC("nspr"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nsgt"), -2369.6, -5884.4, 91.051, FourCC("nsgt"))
SetUnitAcquireRange(u, 200.0)
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000047_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nsgt"), -4993.9, 2604.3, 318.290, FourCC("nsgt"))
SetUnitAcquireRange(u, 200.0)
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000053_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nspr"), -4779.8, 2626.3, 291.284, FourCC("nspr"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nspr"), -4920.4, 2391.6, 341.143, FourCC("nspr"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nspr"), -2511.4, -5788.8, 90.050, FourCC("nspr"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nspr"), -2255.2, -5692.6, 113.741, FourCC("nspr"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nspr"), 2127.4, 2740.4, 291.284, FourCC("nspr"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nspr"), 1986.8, 2505.6, 341.143, FourCC("nspr"))
SetUnitAcquireRange(u, 200.0)
end

function CreateNeutralPassiveBuildings()
local p = Player(PLAYER_NEUTRAL_PASSIVE)
local u
local unitID
local t
local life

u = BlzCreateUnitWithSkin(p, FourCC("ngol"), 4480.0, 3456.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), 4544.0, -2368.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), 576.0, -7168.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), -4480.0, -4992.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), -4416.0, 1024.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), -896.0, 6656.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), 4608.0, -5504.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), 4672.0, 1408.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), 1792.0, 6528.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), -4416.0, 3904.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), -4992.0, -2496.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), -1344.0, -7168.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ntav"), -256.0, -3008.0, 270.000, FourCC("ntav"))
SetUnitColor(u, ConvertPlayerColor(0))
u = BlzCreateUnitWithSkin(p, FourCC("ntav"), -768.0, 2176.0, 270.000, FourCC("ntav"))
SetUnitColor(u, ConvertPlayerColor(0))
end

function CreateNeutralPassive()
local p = Player(PLAYER_NEUTRAL_PASSIVE)
local u
local unitID
local t
local life

u = BlzCreateUnitWithSkin(p, FourCC("nder"), -1248.8, -5317.8, 286.708, FourCC("nder"))
u = BlzCreateUnitWithSkin(p, FourCC("nder"), 2650.1, -3039.6, 21.995, FourCC("nder"))
u = BlzCreateUnitWithSkin(p, FourCC("nder"), 2649.5, 2106.7, 123.754, FourCC("nder"))
u = BlzCreateUnitWithSkin(p, FourCC("nder"), 460.6, 5272.9, 334.599, FourCC("nder"))
u = BlzCreateUnitWithSkin(p, FourCC("nder"), -3939.0, 2752.4, 73.644, FourCC("nder"))
u = BlzCreateUnitWithSkin(p, FourCC("nder"), -2242.3, -1230.6, 149.188, FourCC("nder"))
u = BlzCreateUnitWithSkin(p, FourCC("nder"), -3819.9, -2528.2, 8.345, FourCC("nder"))
end

function CreatePlayerBuildings()
CreateBuildingsForPlayer0()
CreateBuildingsForPlayer3()
end

function CreatePlayerUnits()
end

function CreateAllUnits()
CreateNeutralPassiveBuildings()
CreatePlayerBuildings()
CreateNeutralHostile()
CreateNeutralPassive()
CreatePlayerUnits()
end

function InitUpgrades_Player0()
SetPlayerTechResearched(Player(0), FourCC("Redc"), 2)
end

function InitUpgrades()
InitUpgrades_Player0()
end

function InitCustomPlayerSlots()
SetPlayerStartLocation(Player(0), 0)
ForcePlayerStartLocation(Player(0), 0)
SetPlayerColor(Player(0), ConvertPlayerColor(0))
SetPlayerRacePreference(Player(0), RACE_PREF_NIGHTELF)
SetPlayerRaceSelectable(Player(0), false)
SetPlayerController(Player(0), MAP_CONTROL_USER)
SetPlayerStartLocation(Player(3), 1)
ForcePlayerStartLocation(Player(3), 1)
SetPlayerColor(Player(3), ConvertPlayerColor(3))
SetPlayerRacePreference(Player(3), RACE_PREF_UNDEAD)
SetPlayerRaceSelectable(Player(3), false)
SetPlayerController(Player(3), MAP_CONTROL_COMPUTER)
end

function InitCustomTeams()
SetPlayerTeam(Player(0), 0)
SetPlayerTeam(Player(3), 1)
end

function main()
SetCameraBounds(-5376.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), -7680.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM), 5376.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), 7168.0 - GetCameraMargin(CAMERA_MARGIN_TOP), -5376.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), 7168.0 - GetCameraMargin(CAMERA_MARGIN_TOP), 5376.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), -7680.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM))
SetDayNightModels("Environment\\DNC\\DNCAshenvale\\DNCAshenvaleTerrain\\DNCAshenvaleTerrain.mdl", "Environment\\DNC\\DNCAshenvale\\DNCAshenvaleUnit\\DNCAshenvaleUnit.mdl")
NewSoundEnvironment("Default")
SetAmbientDaySound("AshenvaleDay")
SetAmbientNightSound("AshenvaleNight")
SetMapMusic("Music", true, 0)
InitUpgrades()
CreateAllUnits()
InitBlizzard()
InitGlobals()
local s, m = pcall(RunBundle)
if not s then
    print(m)
end
end

function config()
SetMapName("TRIGSTR_406")
SetMapDescription("TRIGSTR_002")
SetPlayers(2)
SetTeams(2)
SetGamePlacement(MAP_PLACEMENT_USE_MAP_SETTINGS)
DefineStartLocation(0, 4032.0, 4096.0)
DefineStartLocation(1, -4224.0, -5760.0)
InitCustomPlayerSlots()
InitCustomTeams()
end

