--sf-builder:000172034/ee2e8e0b9178ffaa
function SF__Bundle()
local __sf_modules = {}
local require = function(path)
    local module = __sf_modules[path]
    if module == nil then
        local dotPath = string.gsub(path, "/", ".")
        module = __sf_modules[dotPath]
        __sf_modules[path] = module
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

__sf_modules["Lib.clone"]={loader=function()
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

__sf_modules["Lib.class"]={loader=function()
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

__sf_modules["Lib.Event"]={loader=function()
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

__sf_modules["Lib.EventCenter"]={loader=function()
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

__sf_modules["Objects.UnitAttribute"]={loader=function()
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
    self.retPalHolyEnergy = 0
    self.radiantResistance = 0
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

function cls:SimMeleeAttack()
    return BlzGetUnitBaseDamage(self.owner, 0) + math.random(1, BlzGetUnitDiceSides(self.owner, 0)) * BlzGetUnitDiceNumber(self.owner, 0)
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

__sf_modules["Lib.MathExt"]={loader=function()
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

function math.sign(value)
    if value >= 0 then
        return 1
    else
        return -1
    end
end

function math.lerp(a, b, t)
    return a + (b - a) * math.clamp01(t)
end

function math.moveTowards(current, target, maxDelta)
    if math.abs(target - current) <= maxDelta then
        return target
    end
    return current + math.sign(target - current) * maxDelta
end
end}

__sf_modules["Lib.Timer"]={loader=function()
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

__sf_modules["Lib.Time"]={loader=function()
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

__sf_modules["Lib.FrameTimer"]={loader=function()
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

__sf_modules["Lib.CoroutineExt"]={loader=function()
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

__sf_modules["Lib.TableExt"]={loader=function()
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

__sf_modules["Lib.StringExt"]={loader=function()
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

__sf_modules["Lib.native"]={loader=function()
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
        local ok, msg = pcall(v, u)
        if not ok then
            print(msg)
        end
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

__sf_modules["System.SystemBase"]={loader=function()
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

__sf_modules["System.ItemSystem"]={loader=function()
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

__sf_modules["System.SpellSystem"]={loader=function()
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

__sf_modules["System.BuffSystem"]={loader=function()
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

__sf_modules["Config.Const"]={loader=function()
local cls = {}

cls.OrderId_Stop = 851972
cls.OrderId_Smart = 851971
cls.OrderId_Attack = 851983

cls.HitResult_Hit = 1
cls.HitResult_Miss = 2
cls.HitResult_Critical = 4

return cls
end}

__sf_modules["System.DamageSystem"]={loader=function()
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

__sf_modules["Lib.Vector2"]={loader=function()
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

__sf_modules["System.ProjectileSystem"]={loader=function()
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

__sf_modules["Objects.BuffBase"]={loader=function()
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

__sf_modules["System.BuffDisplaySystem"]={loader=function()
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

__sf_modules["Lib.Utils"]={loader=function()
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

__sf_modules["Main"]={loader=function()
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
end}

require("Main")
end
--sf-builder:000172034/ee2e8e0b9178ffaa
function InitGlobals()
end

function Unit000005_DropItems()
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
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 2), 100)
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

function Unit000014_DropItems()
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
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 2), 100)
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

function Unit000015_DropItems()
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
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 2), 100)
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

function Unit000018_DropItems()
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
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 4), 100)
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

function Unit000022_DropItems()
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
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
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
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
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

function Unit000027_DropItems()
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
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 4), 100)
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

function Unit000030_DropItems()
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
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 2), 100)
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
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 4), 100)
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
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 6), 100)
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

function Unit000038_DropItems()
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
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
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

function Unit000040_DropItems()
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
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 2), 100)
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

function Unit000041_DropItems()
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
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 6), 100)
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

function Unit000042_DropItems()
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
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
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

function Unit000043_DropItems()
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
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 2), 100)
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
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 2), 100)
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
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
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

function Unit000052_DropItems()
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
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 5), 100)
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
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 4), 100)
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

function Unit000055_DropItems()
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

function Unit000056_DropItems()
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
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 2), 100)
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

function Unit000059_DropItems()
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
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
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

function Unit000062_DropItems()
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
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 4), 100)
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

function Unit000065_DropItems()
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
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 5), 100)
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

function Unit000066_DropItems()
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
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 2), 100)
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

function Unit000073_DropItems()
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
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
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

function Unit000074_DropItems()
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
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 2), 100)
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

function Unit000085_DropItems()
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
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 2), 100)
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

function Unit000087_DropItems()
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
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 2), 100)
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

function Unit000091_DropItems()
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
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 2), 100)
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

function Unit000092_DropItems()
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
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 4), 100)
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

function Unit000100_DropItems()
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
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 2), 100)
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

function Unit000101_DropItems()
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
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 4), 100)
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

function Unit000107_DropItems()
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
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 2), 100)
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

function Unit000109_DropItems()
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
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
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

function Unit000113_DropItems()
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
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
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

function Unit000114_DropItems()
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
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 2), 100)
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

function Unit000120_DropItems()
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

function Unit000121_DropItems()
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
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
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

function CreateUnitsForPlayer0()
local p = Player(0)
local u
local unitID
local t
local life

u = BlzCreateUnitWithSkin(p, FourCC("Hpal"), -0.1, -3309.5, 266.921, FourCC("Hpal"))
end

function CreateNeutralHostile()
local p = Player(PLAYER_NEUTRAL_AGGRESSIVE)
local u
local unitID
local t
local life

u = BlzCreateUnitWithSkin(p, FourCC("ngst"), -722.2, 6581.3, 309.280, FourCC("ngst"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000027_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("ngnb"), -44.6, 2265.7, 99.763, FourCC("ngnb"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("ngna"), 75.9, 2168.8, 110.350, FourCC("ngna"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nfsh"), 5597.5, 3732.6, 196.170, FourCC("nfsh"))
SetUnitAcquireRange(u, 200.0)
IssueImmediateOrder(u, "autodispeloff")
IssueImmediateOrder(u, "healoff")
IssueImmediateOrder(u, "innerfireoff")
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000087_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("ngst"), -5008.2, -4286.2, 17.340, FourCC("ngst"))
SetUnitAcquireRange(u, 200.0)
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000101_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("ngna"), -154.9, 2157.6, 86.011, FourCC("ngna"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nftb"), -4856.1, -4530.3, 72.610, FourCC("nftb"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("ngnw"), -157.7, -269.9, 223.476, FourCC("ngnw"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("ngst"), 5237.5, 3415.4, 186.819, FourCC("ngst"))
SetUnitAcquireRange(u, 200.0)
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000054_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nftb"), -5115.5, -3999.7, 6.376, FourCC("nftb"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nomg"), 2819.3, -4536.2, 105.150, FourCC("nomg"))
SetUnitAcquireRange(u, 200.0)
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000015_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("ngst"), 7189.9, 6813.5, 250.760, FourCC("ngst"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000055_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nggr"), 7043.6, -7417.2, 132.130, FourCC("nggr"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000041_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nftb"), 4258.7, 7060.2, 222.270, FourCC("nftb"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000043_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nftb"), 7138.6, -2691.4, 96.490, FourCC("nftb"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000040_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nfsp"), -3638.9, -7715.4, 31.786, FourCC("nfsp"))
IssueImmediateOrder(u, "autodispeloff")
IssueImmediateOrder(u, "healoff")
u = BlzCreateUnitWithSkin(p, FourCC("nftb"), 6803.2, -2819.3, 108.336, FourCC("nftb"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000038_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("ngna"), -1234.6, -1379.0, 51.466, FourCC("ngna"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nftb"), 4407.8, 6658.1, 190.674, FourCC("nftb"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000042_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("ngns"), 121.4, -44.9, 355.331, FourCC("ngns"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nogr"), 4254.1, 6889.5, 207.569, FourCC("nogr"))
u = BlzCreateUnitWithSkin(p, FourCC("nftt"), 2510.4, -4909.7, 156.593, FourCC("nftt"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nftb"), -3694.3, -7250.1, 18.340, FourCC("nftb"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000109_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nrdr"), -7315.4, 6737.4, 337.980, FourCC("nrdr"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000073_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("ngns"), -251.6, -34.0, 183.125, FourCC("ngns"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nfsp"), -1243.4, 1125.1, 0.000, FourCC("nfsp"))
SetUnitAcquireRange(u, 200.0)
IssueImmediateOrder(u, "healoff")
IssueImmediateOrder(u, "autodispeloff")
IssueImmediateOrder(u, "healoff")
u = BlzCreateUnitWithSkin(p, FourCC("nfsp"), -7144.2, 2041.2, 301.786, FourCC("nfsp"))
IssueImmediateOrder(u, "autodispeloff")
IssueImmediateOrder(u, "healoff")
u = BlzCreateUnitWithSkin(p, FourCC("nogr"), -6816.1, 1904.3, 273.957, FourCC("nogr"))
u = BlzCreateUnitWithSkin(p, FourCC("nftt"), -1346.2, 1165.9, 316.891, FourCC("nftt"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nftb"), -1248.1, 1260.3, 300.500, FourCC("nftb"))
SetUnitAcquireRange(u, 200.0)
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000100_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("ngna"), -40.9, -308.3, 266.661, FourCC("ngna"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nogr"), 6895.0, -2677.1, 93.957, FourCC("nogr"))
u = BlzCreateUnitWithSkin(p, FourCC("nggr"), -7008.9, 6831.8, 314.950, FourCC("nggr"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000037_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("ngna"), 1208.8, 1094.7, 212.384, FourCC("ngna"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nrdr"), -6956.2, 7191.5, 293.312, FourCC("nrdr"))
u = BlzCreateUnitWithSkin(p, FourCC("ngna"), -77.6, 201.1, 90.006, FourCC("ngna"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nftb"), -6657.1, 2042.5, 288.340, FourCC("nftb"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000113_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nftt"), 1106.3, -1338.5, 113.719, FourCC("nftt"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nfsp"), 1209.2, -1379.4, 126.375, FourCC("nfsp"))
SetUnitAcquireRange(u, 200.0)
IssueImmediateOrder(u, "healoff")
IssueImmediateOrder(u, "autodispeloff")
IssueImmediateOrder(u, "healoff")
u = BlzCreateUnitWithSkin(p, FourCC("nftb"), 1196.5, -1247.1, 142.188, FourCC("nftb"))
SetUnitAcquireRange(u, 200.0)
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000085_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nogl"), -2586.6, 4287.2, 303.813, FourCC("nogl"))
SetUnitAcquireRange(u, 200.0)
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000052_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("ngnb"), -1228.2, -1249.8, 33.930, FourCC("ngnb"))
SetUnitAcquireRange(u, 200.0)
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000026_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nogm"), -1345.9, -1349.8, 36.380, FourCC("nogm"))
SetUnitAcquireRange(u, 200.0)
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000056_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nfsh"), -5170.5, -4485.1, 28.610, FourCC("nfsh"))
SetUnitAcquireRange(u, 200.0)
IssueImmediateOrder(u, "autodispeloff")
IssueImmediateOrder(u, "healoff")
IssueImmediateOrder(u, "innerfireoff")
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000066_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nftb"), 6974.8, 6787.5, 281.320, FourCC("nftb"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000060_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nfsp"), 7378.9, 6756.1, 286.610, FourCC("nfsp"))
IssueImmediateOrder(u, "healoff")
u = BlzCreateUnitWithSkin(p, FourCC("nrdr"), 6982.2, -7743.9, 127.341, FourCC("nrdr"))
u = BlzCreateUnitWithSkin(p, FourCC("ngst"), 7100.2, 2049.5, 235.680, FourCC("ngst"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000092_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("ngst"), 1538.6, -7059.2, 125.260, FourCC("ngst"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000033_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nrdr"), 7358.6, -7356.8, 119.460, FourCC("nrdr"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000050_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nomg"), -2370.0, 4322.6, 294.212, FourCC("nomg"))
SetUnitAcquireRange(u, 200.0)
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000074_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("ngnv"), 78.6, -230.4, 301.330, FourCC("ngnv"))
SetUnitAcquireRange(u, 200.0)
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000018_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nftb"), 6890.7, 1876.3, 240.299, FourCC("nftb"))
u = BlzCreateUnitWithSkin(p, FourCC("nftb"), 6928.2, 2378.6, 249.129, FourCC("nftb"))
u = BlzCreateUnitWithSkin(p, FourCC("nftb"), 7345.7, 1996.8, 225.470, FourCC("nftb"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000091_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nftb"), 1367.8, -6881.6, 123.685, FourCC("nftb"))
u = BlzCreateUnitWithSkin(p, FourCC("nftb"), 1755.7, -6980.6, 132.941, FourCC("nftb"))
u = BlzCreateUnitWithSkin(p, FourCC("nftb"), 1446.1, -7238.1, 119.190, FourCC("nftb"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000030_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nftb"), -7158.5, -2854.8, 28.926, FourCC("nftb"))
u = BlzCreateUnitWithSkin(p, FourCC("nftb"), -6787.6, -2779.7, 37.338, FourCC("nftb"))
u = BlzCreateUnitWithSkin(p, FourCC("ngnv"), -182.8, 122.4, 135.627, FourCC("ngnv"))
SetUnitAcquireRange(u, 200.0)
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000059_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nogr"), 2449.8, -4593.3, 107.784, FourCC("nogr"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nogl"), 2657.9, -4766.5, 115.230, FourCC("nogl"))
SetUnitAcquireRange(u, 200.0)
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000065_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("ngst"), -6933.4, -2967.1, 40.780, FourCC("ngst"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000062_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nftb"), -6925.8, -3218.1, 50.270, FourCC("nftb"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000005_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("ngnb"), -49.9, -2557.5, 0.000, FourCC("ngnb"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("ngna"), -169.0, -2459.0, 274.078, FourCC("ngna"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("ngna"), 62.0, -2451.1, 262.813, FourCC("ngna"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("ngnb"), -2482.9, -59.7, 272.830, FourCC("ngnb"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("ngna"), -2390.4, 64.1, 186.905, FourCC("ngna"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("ngna"), -2371.1, -166.2, 175.639, FourCC("ngna"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nogr"), -6931.2, -7016.4, 43.705, FourCC("nogr"))
u = BlzCreateUnitWithSkin(p, FourCC("ngnw"), 24.7, 157.4, 38.312, FourCC("ngnw"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nfsp"), 7265.0, -2810.8, 121.786, FourCC("nfsp"))
IssueImmediateOrder(u, "autodispeloff")
IssueImmediateOrder(u, "healoff")
u = BlzCreateUnitWithSkin(p, FourCC("ngnb"), 2526.7, -88.3, 90.140, FourCC("ngnb"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("ngna"), 2428.5, -207.7, 4.221, FourCC("ngna"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("ngna"), 2420.0, 23.3, 352.956, FourCC("ngna"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nftb"), -7001.5, 1917.9, 276.490, FourCC("nftb"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000114_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nfsp"), 4266.4, 6729.3, 199.304, FourCC("nfsp"))
IssueImmediateOrder(u, "autodispeloff")
IssueImmediateOrder(u, "healoff")
u = BlzCreateUnitWithSkin(p, FourCC("ngnb"), 1204.7, 1257.8, 229.690, FourCC("ngnb"))
SetUnitAcquireRange(u, 200.0)
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000022_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nftb"), -3535.9, -7587.1, 6.490, FourCC("nftb"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000107_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nftt"), 2898.1, -4730.8, 122.391, FourCC("nftt"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nftt"), -2808.0, 4186.2, 321.892, FourCC("nftt"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("ngst"), -7061.9, -7189.5, 45.883, FourCC("ngst"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000120_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nftb"), -6838.8, -7299.5, 56.228, FourCC("nftb"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000121_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nogm"), 1087.1, 1157.9, 234.203, FourCC("nogm"))
SetUnitAcquireRange(u, 200.0)
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000014_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nftt"), -2478.9, 4523.1, 288.954, FourCC("nftt"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nogr"), -3524.0, -7393.1, 3.957, FourCC("nogr"))
u = BlzCreateUnitWithSkin(p, FourCC("nftr"), 6807.0, -7475.7, 181.016, FourCC("nftr"))
u = BlzCreateUnitWithSkin(p, FourCC("nftr"), 7223.0, -7148.6, 72.270, FourCC("nftr"))
u = BlzCreateUnitWithSkin(p, FourCC("nfsp"), -7250.9, -7132.1, 35.984, FourCC("nfsp"))
IssueImmediateOrder(u, "healoff")
u = BlzCreateUnitWithSkin(p, FourCC("nftr"), -7219.9, 6706.2, 323.461, FourCC("nftr"))
u = BlzCreateUnitWithSkin(p, FourCC("nogr"), 7059.2, 6640.4, 305.438, FourCC("nogr"))
u = BlzCreateUnitWithSkin(p, FourCC("nftr"), -6784.4, 7018.5, 242.747, FourCC("nftr"))
u = BlzCreateUnitWithSkin(p, FourCC("nogr"), -2656.7, 4078.9, 293.837, FourCC("nogr"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nftb"), 5360.4, 3269.2, 173.932, FourCC("nftb"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nftb"), 5317.1, 3667.8, 240.167, FourCC("nftb"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nftb"), -952.1, 6480.4, 279.980, FourCC("nftb"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000047_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nftb"), -595.9, 6433.0, 282.935, FourCC("nftb"))
u = BlzCreateUnitWithSkin(p, FourCC("nftb"), -599.0, 6704.1, 258.501, FourCC("nftb"))
end

function CreateNeutralPassiveBuildings()
local p = Player(PLAYER_NEUTRAL_PASSIVE)
local u
local unitID
local t
local life

u = BlzCreateUnitWithSkin(p, FourCC("ngol"), -7296.0, 7104.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), 1856.0, -7360.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), -7296.0, -3328.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), -6912.0, 2176.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), 7296.0, -7616.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), 7296.0, 2432.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), 4480.0, 6912.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), 7040.0, -2944.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), -3776.0, -7488.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("nfoh"), -64.0, -64.0, 270.000, FourCC("nfoh"))
u = BlzCreateUnitWithSkin(p, FourCC("ngme"), -5376.0, -4288.0, 270.000, FourCC("ngme"))
u = BlzCreateUnitWithSkin(p, FourCC("ngme"), 5568.0, 3456.0, 270.000, FourCC("ngme"))
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), -7296.0, -7488.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), 7168.0, 7168.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ngad"), -2752.0, 4544.0, 270.000, FourCC("ngad"))
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), -1024.0, 6912.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ntav"), 2432.0, -1280.0, 270.000, FourCC("ntav"))
SetUnitColor(u, ConvertPlayerColor(0))
u = BlzCreateUnitWithSkin(p, FourCC("ntav"), -2560.0, 1152.0, 270.000, FourCC("ntav"))
SetUnitColor(u, ConvertPlayerColor(0))
u = BlzCreateUnitWithSkin(p, FourCC("ngad"), 2848.0, -4992.0, 270.000, FourCC("ngad"))
end

function CreateNeutralPassive()
local p = Player(PLAYER_NEUTRAL_PASSIVE)
local u
local unitID
local t
local life

u = BlzCreateUnitWithSkin(p, FourCC("nfro"), 4961.0, -5402.9, 107.691, FourCC("nfro"))
u = BlzCreateUnitWithSkin(p, FourCC("nfro"), -5086.6, 5228.5, 222.985, FourCC("nfro"))
u = BlzCreateUnitWithSkin(p, FourCC("nshe"), -2418.0, -6601.5, 331.468, FourCC("nshe"))
u = BlzCreateUnitWithSkin(p, FourCC("nshe"), 6329.9, -1529.6, 140.454, FourCC("nshe"))
u = BlzCreateUnitWithSkin(p, FourCC("nshe"), 1505.4, 5958.5, 239.718, FourCC("nshe"))
u = BlzCreateUnitWithSkin(p, FourCC("nshe"), -6599.9, 842.2, 204.385, FourCC("nshe"))
u = BlzCreateUnitWithSkin(p, FourCC("nshe"), 3557.7, 5727.3, 95.452, FourCC("nshe"))
u = BlzCreateUnitWithSkin(p, FourCC("necr"), 4079.7, -19.0, 98.397, FourCC("necr"))
u = BlzCreateUnitWithSkin(p, FourCC("necr"), -194.2, -3946.6, 74.468, FourCC("necr"))
u = BlzCreateUnitWithSkin(p, FourCC("necr"), -3798.4, -1509.1, 359.758, FourCC("necr"))
u = BlzCreateUnitWithSkin(p, FourCC("necr"), 443.3, 3501.1, 131.236, FourCC("necr"))
u = BlzCreateUnitWithSkin(p, FourCC("nrac"), -1963.6, -2382.7, 192.168, FourCC("nrac"))
u = BlzCreateUnitWithSkin(p, FourCC("nrac"), 2240.3, 1894.9, 312.252, FourCC("nrac"))
u = BlzCreateUnitWithSkin(p, FourCC("nshe"), -3010.2, 1443.4, 14.140, FourCC("nshe"))
u = BlzCreateUnitWithSkin(p, FourCC("nshe"), 2909.0, -1584.3, 76.390, FourCC("nshe"))
end

function CreatePlayerBuildings()
end

function CreatePlayerUnits()
CreateUnitsForPlayer0()
end

function CreateAllUnits()
CreateNeutralPassiveBuildings()
CreatePlayerBuildings()
CreateNeutralHostile()
CreateNeutralPassive()
CreatePlayerUnits()
end

function InitCustomPlayerSlots()
SetPlayerStartLocation(Player(0), 0)
SetPlayerColor(Player(0), ConvertPlayerColor(0))
SetPlayerRacePreference(Player(0), RACE_PREF_HUMAN)
SetPlayerRaceSelectable(Player(0), true)
SetPlayerController(Player(0), MAP_CONTROL_USER)
SetPlayerStartLocation(Player(1), 1)
SetPlayerColor(Player(1), ConvertPlayerColor(1))
SetPlayerRacePreference(Player(1), RACE_PREF_ORC)
SetPlayerRaceSelectable(Player(1), true)
SetPlayerController(Player(1), MAP_CONTROL_USER)
SetPlayerStartLocation(Player(2), 2)
SetPlayerColor(Player(2), ConvertPlayerColor(2))
SetPlayerRacePreference(Player(2), RACE_PREF_UNDEAD)
SetPlayerRaceSelectable(Player(2), true)
SetPlayerController(Player(2), MAP_CONTROL_USER)
SetPlayerStartLocation(Player(3), 3)
SetPlayerColor(Player(3), ConvertPlayerColor(3))
SetPlayerRacePreference(Player(3), RACE_PREF_NIGHTELF)
SetPlayerRaceSelectable(Player(3), true)
SetPlayerController(Player(3), MAP_CONTROL_USER)
end

function InitCustomTeams()
SetPlayerTeam(Player(0), 0)
SetPlayerTeam(Player(1), 0)
SetPlayerTeam(Player(2), 0)
SetPlayerTeam(Player(3), 0)
end

function InitAllyPriorities()
SetStartLocPrioCount(0, 2)
SetStartLocPrio(0, 0, 1, MAP_LOC_PRIO_HIGH)
SetStartLocPrio(0, 1, 3, MAP_LOC_PRIO_HIGH)
SetStartLocPrioCount(1, 2)
SetStartLocPrio(1, 0, 0, MAP_LOC_PRIO_HIGH)
SetStartLocPrio(1, 1, 2, MAP_LOC_PRIO_HIGH)
SetStartLocPrioCount(2, 2)
SetStartLocPrio(2, 0, 1, MAP_LOC_PRIO_HIGH)
SetStartLocPrio(2, 1, 3, MAP_LOC_PRIO_HIGH)
SetStartLocPrioCount(3, 2)
SetStartLocPrio(3, 0, 0, MAP_LOC_PRIO_HIGH)
SetStartLocPrio(3, 1, 2, MAP_LOC_PRIO_HIGH)
end

function main()
SetCameraBounds(-7936.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), -8192.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM), 7936.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), 7680.0 - GetCameraMargin(CAMERA_MARGIN_TOP), -7936.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), 7680.0 - GetCameraMargin(CAMERA_MARGIN_TOP), 7936.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), -8192.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM))
SetDayNightModels("Environment\\DNC\\DNCLordaeron\\DNCLordaeronTerrain\\DNCLordaeronTerrain.mdl", "Environment\\DNC\\DNCLordaeron\\DNCLordaeronUnit\\DNCLordaeronUnit.mdl")
NewSoundEnvironment("Default")
SetAmbientDaySound("LordaeronSummerDay")
SetAmbientNightSound("LordaeronSummerNight")
SetMapMusic("Music", true, 0)
CreateAllUnits()
InitBlizzard()
InitGlobals()
    local s, m = pcall(SF__Bundle)
    if not s then
        print(m)
    end
end

function config()
SetMapName("TRIGSTR_010")
SetMapDescription("TRIGSTR_012")
SetPlayers(4)
SetTeams(4)
SetGamePlacement(MAP_PLACEMENT_TEAMS_TOGETHER)
DefineStartLocation(0, 1280.0, -6848.0)
DefineStartLocation(1, -6848.0, -2688.0)
DefineStartLocation(2, -448.0, 6400.0)
DefineStartLocation(3, 6848.0, 1792.0)
InitCustomPlayerSlots()
SetPlayerSlotAvailable(Player(0), MAP_CONTROL_USER)
SetPlayerSlotAvailable(Player(1), MAP_CONTROL_USER)
SetPlayerSlotAvailable(Player(2), MAP_CONTROL_USER)
SetPlayerSlotAvailable(Player(3), MAP_CONTROL_USER)
InitGenericPlayerSlots()
InitAllyPriorities()
end

