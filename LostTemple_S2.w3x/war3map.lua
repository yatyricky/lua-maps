--sf-builder:000215604/74ca05744daa0fa6
function SF__BundleError__(m)
    print(tostring(m))
    return m
end

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
    self.cdrTemplarVerdict = 0
    self.cdrBladeJustice = 0
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
    local sfx = AddSpecialEffectTarget(modelName, target, attachPoint)
    c_start(function()
        c_wait(duration)
        DestroyEffect(sfx)
    end)
    return sfx
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
        if not ok then print(tostring(err)) end
    end)
    return coroutine.yield()
end

function SF__.StrSplit__(str, sep)
    local result = {}
    if str == nil or str == "" then return result end
    if sep == nil or sep == "" then
        for i = 1, #str do
            result[i] = str:sub(i, i)
        end
        return result
    end
    local pos = 1
    while true do
        local start, finish = string.find(str, sep, pos, true)
        if start == nil then
            table.insert(result, string.sub(str, pos))
            break
        end
        table.insert(result, string.sub(str, pos, start - 1))
        pos = finish + 1
    end
    return result
end

require("Lib.class")
SF__.LuaWrapper = SF__.LuaWrapper or {}
-- LuaWrapper.HitResult
SF__.LuaWrapper.HitResult = SF__.LuaWrapper.HitResult or {}
SF__.LuaWrapper.HitResult.Hit = 1
SF__.LuaWrapper.HitResult.Miss = 2
SF__.LuaWrapper.HitResult.Critical = 4

-- TargetType
SF__.TargetType = SF__.TargetType or {}
-- <summary>
-- Move towards a unit.
-- </summary>
--
SF__.TargetType.Unit = 0
-- <summary>
-- Move towards a point.
-- </summary>
--
SF__.TargetType.Point = 1
SF__.TargetType.None = 2

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

function SF__.Component:LateUpdate()
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

function SF__.Vector3.op_Addition(a__x194, a__y195, a__z196, b__x197, b__y198, b__z199)
    return (a__x194 + b__x197), (a__y195 + b__y198), (a__z196 + b__z199)
end

function SF__.Vector3.op_UnaryNegation(a__x200, a__y201, a__z202)
    return (-a__x200), (-a__y201), (-a__z202)
end

function SF__.Vector3.op_Subtraction(a__x203, a__y204, a__z205, b__x206, b__y207, b__z208)
    return (a__x203 - b__x206), (a__y204 - b__y207), (a__z205 - b__z208)
end

function SF__.Vector3.op_Multiply__osef(v__x209, v__y210, v__z211, f212)
    return (v__x209 * f212), (v__y210 * f212), (v__z211 * f212)
end

function SF__.Vector3.op_Multiply__fose(f213, v__x214, v__y215, v__z216)
    return (v__x214 * f213), (v__y215 * f213), (v__z216 * f213)
end

function SF__.Vector3.op_Division(v__x217, v__y218, v__z219, f220)
    return (v__x217 / f220), (v__y218 / f220), (v__z219 / f220)
end

-- <summary>
-- Warcraft III world space here is right-handed: +x points right, +y points away, +z points up.
-- That means Cross((1,0,0), (0,1,0)) == (0,0,1).
-- </summary>
--
function SF__.Vector3.Cross(a__x221, a__y222, a__z223, b__x224, b__y225, b__z226)
    return ((a__y222 * b__z226) - (a__z223 * b__y225)), ((a__z223 * b__x224) - (a__x221 * b__z226)), ((a__x221 * b__y225) - (a__y222 * b__x224))
end

function SF__.Vector3.Distance(a__x227, a__y228, a__z229, b__x230, b__y231, b__z232)
    return SF__.Vector3.get_magnitude(SF__.Vector3.op_Subtraction(a__x227, a__y228, a__z229, b__x230, b__y231, b__z232))
end

function SF__.Vector3.Dot(a__x233, a__y234, a__z235, b__x236, b__y237, b__z238)
    return (((a__x233 * b__x236) + (a__y234 * b__y237)) + (a__z235 * b__z238))
end

function SF__.Vector3.Lerp(a__x239, a__y240, a__z241, b__x242, b__y243, b__z244, t245)
    t245 = math.clamp01(t245)
    return SF__.Vector3.op_Addition(a__x239, a__y240, a__z241, (function()
        local v__x246, v__y247, v__z248 = SF__.Vector3.op_Subtraction(b__x242, b__y243, b__z244, a__x239, a__y240, a__z241)
        return SF__.Vector3.op_Multiply__osef(v__x246, v__y247, v__z248, t245)
    end)())
end

function SF__.Vector3.MoveTowards(current__x, current__y, current__z, target__x249, target__y250, target__z251, maxDistanceDelta)
    local toVector__x, toVector__y, toVector__z = SF__.Vector3.op_Subtraction(target__x249, target__y250, target__z251, current__x, current__y, current__z)
    local dist = SF__.Vector3.get_magnitude(toVector__x, toVector__y, toVector__z)
    if ((dist <= maxDistanceDelta) or (dist == 0)) then
        return target__x249, target__y250, target__z251
    end
    return SF__.Vector3.op_Addition(current__x, current__y, current__z, SF__.Vector3.op_Division(toVector__x, toVector__y, toVector__z, (dist / maxDistanceDelta)))
end

function SF__.Vector3.Project(v__x252, v__y253, v__z254, onNormal__x, onNormal__y, onNormal__z)
    local sqrMag = SF__.Vector3.Dot(onNormal__x, onNormal__y, onNormal__z, onNormal__x, onNormal__y, onNormal__z)
    if (sqrMag < 0.0001) then
        return SF__.Vector3.get_zero()
    end
    local dot = SF__.Vector3.Dot(v__x252, v__y253, v__z254, onNormal__x, onNormal__y, onNormal__z)
    return SF__.Vector3.op_Multiply__osef(onNormal__x, onNormal__y, onNormal__z, (dot / sqrMag))
end

function SF__.Vector3.ProjectOnPlane(v__x255, v__y256, v__z257, planeNormal__x, planeNormal__y, planeNormal__z)
    return SF__.Vector3.op_Subtraction(v__x255, v__y256, v__z257, SF__.Vector3.Project(v__x255, v__y256, v__z257, planeNormal__x, planeNormal__y, planeNormal__z))
end

function SF__.Vector3.Reflect(inDirection__x, inDirection__y, inDirection__z, inNormal__x, inNormal__y, inNormal__z)
    return SF__.Vector3.op_Subtraction(inDirection__x, inDirection__y, inDirection__z, SF__.Vector3.op_Multiply__fose((2 * SF__.Vector3.Dot(inDirection__x, inDirection__y, inDirection__z, inNormal__x, inNormal__y, inNormal__z)), inNormal__x, inNormal__y, inNormal__z))
end

function SF__.Vector3.RotateTowards(current__x258, current__y259, current__z260, target__x261, target__y262, target__z263, maxRadiansDelta, maxMagnitudeDelta)
    local currentMag = SF__.Vector3.get_magnitude(current__x258, current__y259, current__z260)
    local targetMag = SF__.Vector3.get_magnitude(target__x261, target__y262, target__z263)
    if ((currentMag == 0) or (targetMag == 0)) then
        return SF__.Vector3.MoveTowards(current__x258, current__y259, current__z260, target__x261, target__y262, target__z263, maxMagnitudeDelta)
    end
    local currentNorm__x, currentNorm__y, currentNorm__z = SF__.Vector3.op_Division(current__x258, current__y259, current__z260, currentMag)
    local targetNorm__x, targetNorm__y, targetNorm__z = SF__.Vector3.op_Division(target__x261, target__y262, target__z263, targetMag)
    local dot264 = math.clamp(SF__.Vector3.Dot(currentNorm__x, currentNorm__y, currentNorm__z, targetNorm__x, targetNorm__y, targetNorm__z), (-1), 1)
    local angle265 = math.acos(dot264)
    if (angle265 == 0) then
        return SF__.Vector3.MoveTowards(current__x258, current__y259, current__z260, target__x261, target__y262, target__z263, maxMagnitudeDelta)
    end
    local t266 = math.min(1, (maxRadiansDelta / angle265))
    local newDir__x, newDir__y, newDir__z = SF__.Vector3.Slerp(currentNorm__x, currentNorm__y, currentNorm__z, targetNorm__x, targetNorm__y, targetNorm__z, t266)
    local newMag = math.moveTowards(currentMag, targetMag, maxMagnitudeDelta)
    return SF__.Vector3.op_Multiply__osef(newDir__x, newDir__y, newDir__z, newMag)
end

function SF__.Vector3.Scale(a__x267, a__y268, a__z269, b__x270, b__y271, b__z272)
    return (a__x267 * b__x270), (a__y268 * b__y271), (a__z269 * b__z272)
end

function SF__.Vector3.Slerp(a__x273, a__y274, a__z275, b__x276, b__y277, b__z278, t279)
    local magA = SF__.Vector3.get_magnitude(a__x273, a__y274, a__z275)
    local magB = SF__.Vector3.get_magnitude(b__x276, b__y277, b__z278)
    if ((magA == 0) or (magB == 0)) then
        return SF__.Vector3.MoveTowards(a__x273, a__y274, a__z275, b__x276, b__y277, b__z278, math.huge)
    end
    local normA__x, normA__y, normA__z = SF__.Vector3.op_Division(a__x273, a__y274, a__z275, magA)
    local normB__x, normB__y, normB__z = SF__.Vector3.op_Division(b__x276, b__y277, b__z278, magB)
    local dot280 = math.clamp(SF__.Vector3.Dot(normA__x, normA__y, normA__z, normB__x, normB__y, normB__z), (-1), 1)
    local angle281 = math.acos(dot280)
    local sinAngle = math.sin(angle281)
    if (sinAngle < 0.0001) then
        return SF__.Vector3.MoveTowards(a__x273, a__y274, a__z275, b__x276, b__y277, b__z278, math.huge)
    end
    local tAngle = (angle281 * t279)
    local sinTA = math.sin(tAngle)
    local sinTOneMinusA = math.sin((angle281 - tAngle))
    local newDir__x288, newDir__y289, newDir__z290 = (function()
        local v__x285, v__y286, v__z287 = (function()
            local a__x282, a__y283, a__z284 = SF__.Vector3.op_Multiply__osef(normA__x, normA__y, normA__z, sinTOneMinusA)
            return SF__.Vector3.op_Addition(a__x282, a__y283, a__z284, SF__.Vector3.op_Multiply__osef(normB__x, normB__y, normB__z, sinTA))
        end)()
        return SF__.Vector3.op_Division(v__x285, v__y286, v__z287, sinAngle)
    end)()
    local newMag291 = math.lerp(magA, magB, t279)
    return SF__.Vector3.op_Multiply__osef(newDir__x288, newDir__y289, newDir__z290, newMag291)
end

function SF__.Vector3._getTerrainZ(x292, y293)
    MoveLocation(SF__.Vector3._loc, x292, y293)
    return GetLocationZ(SF__.Vector3._loc)
end

function SF__.Vector3.FromUnit(u294)
    local x295 = GetUnitX(u294)
    local y296 = GetUnitY(u294)
    return x295, y296, (SF__.Vector3._getTerrainZ(x295, y296) + GetUnitFlyHeight(u294))
end

function SF__.Vector3.get_sqrMagnitude(self__x297, self__y298, self__z299)
    return (((self__x297 * self__x297) + (self__y298 * self__y298)) + (self__z299 * self__z299))
end

function SF__.Vector3.get_magnitude(self__x300, self__y301, self__z302)
    return math.sqrt(SF__.Vector3.get_sqrMagnitude(self__x300, self__y301, self__z302))
end

function SF__.Vector3.get_normalized(self__x303, self__y304, self__z305)
    local mag306 = SF__.Vector3.get_magnitude(self__x303, self__y304, self__z305)
    if (mag306 < 0.0001) then
        return SF__.Vector3.get_zero()
    end
    return SF__.Vector3.op_Division(self__x303, self__y304, self__z305, mag306)
end

function SF__.Vector3.ClampMagnitude(self__x310, self__y311, self__z312, mag313)
    return (function()
        local v__x314, v__y315, v__z316 = SF__.Vector3.get_normalized(self__x310, self__y311, self__z312)
        return SF__.Vector3.op_Multiply__osef(v__x314, v__y315, v__z316, mag313)
    end)()
end

function SF__.Vector3.ToString(self__x317, self__y318, self__z319)
    return SF__.StrConcat__("(", self__x317, ", ", self__y318, ", ", self__z319, ")")
end

function SF__.Vector3.UnitMoveTo(self__x320, self__y321, self__z322, u323, mode)
    if mode == nil then mode = SF__.UnitVec3Mode.Auto end
    local tz = SF__.Vector3._getTerrainZ(self__x320, self__y321)
    local LuaUtils = require("Lib.Utils")
    local defaultFlyHeight = GetUnitDefaultFlyHeight(u323)
    local minZ = (tz + defaultFlyHeight)
    SetUnitPosition(u323, self__x320, self__y321)
    repeat
        local switchValue = mode
        if (switchValue == SF__.UnitVec3Mode.ForceFlying) then
            LuaUtils.SetUnitFlyable(u323)
            SetUnitFlyHeight(u323, (math.max(minZ, self__z322) - minZ), 0)
            break
        elseif (switchValue == SF__.UnitVec3Mode.ForceGround) then
            SetUnitFlyHeight(u323, defaultFlyHeight, 0)
            break
        elseif (switchValue == SF__.UnitVec3Mode.Auto) then
            if IsUnitType(u323, UNIT_TYPE_FLYING) then
                SetUnitFlyHeight(u323, (math.max(minZ, self__z322) - minZ), 0)
            else
                SetUnitFlyHeight(u323, defaultFlyHeight, 0)
            end
            break
        end
    until true
end

function SF__.Vector3.GetTerrainZ(self__x324, self__y325, self__z326)
    return SF__.Vector3._getTerrainZ(self__x324, self__y325)
end

SF__.Vector3._loc = Location(0, 0)
-- Quaternion
SF__.Quaternion = SF__.Quaternion or {}
SF__.Quaternion.Name = "Quaternion"
SF__.Quaternion.FullName = "Quaternion"
function SF__.Quaternion.get_identity()
    return 0, 0, 0, 1
end

function SF__.Quaternion.op_Multiply__iyiiyi(a__x, a__y, a__z, a__w, b__x, b__y, b__z, b__w)
    return ((((a__w * b__x) + (a__x * b__w)) + (a__y * b__z)) - (a__z * b__y)), ((((a__w * b__y) - (a__x * b__z)) + (a__y * b__w)) + (a__z * b__x)), ((((a__w * b__z) + (a__x * b__y)) - (a__y * b__x)) + (a__z * b__w)), ((((a__w * b__w) - (a__x * b__x)) - (a__y * b__y)) - (a__z * b__z))
end

function SF__.Quaternion.op_Multiply__iyiose(q__x80, q__y81, q__z82, q__w83, v__x, v__y, v__z)
    -- https://en.wikipedia.org/wiki/Quaternions_and_spatial_rotation#Using_quaternion_as_rotations
    local u__x, u__y, u__z = q__x80, q__y81, q__z82
    local s = q__w83
    return (function()
        local a__x87, a__y88, a__z89 = (function()
            local a__x84, a__y85, a__z86 = SF__.Vector3.op_Multiply__fose((2 * SF__.Vector3.Dot(u__x, u__y, u__z, v__x, v__y, v__z)), u__x, u__y, u__z)
            return SF__.Vector3.op_Addition(a__x84, a__y85, a__z86, SF__.Vector3.op_Multiply__fose(((s * s) - SF__.Vector3.Dot(u__x, u__y, u__z, u__x, u__y, u__z)), v__x, v__y, v__z))
        end)()
        return SF__.Vector3.op_Addition(a__x87, a__y88, a__z89, SF__.Vector3.op_Multiply__fose((2 * s), SF__.Vector3.Cross(u__x, u__y, u__z, v__x, v__y, v__z)))
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

function SF__.Quaternion.LookRotation__oseose(forward__x, forward__y, forward__z, upwards__x, upwards__y, upwards__z)
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
    local x90
    local y91
    local z
    local w
    local trace = ((m00 + m11) + m22)
    if (trace > 0) then
        local s92 = (math.sqrt((trace + 1)) * 2)
        w = (0.25 * s92)
        x90 = ((m21 - m12) / s92)
        y91 = ((m02 - m20) / s92)
        z = ((m10 - m01) / s92)
    elseif ((m00 > m11) and (m00 > m22)) then
        local s93 = (math.sqrt((((1 + m00) - m11) - m22)) * 2)
        w = ((m21 - m12) / s93)
        x90 = (0.25 * s93)
        y91 = ((m01 + m10) / s93)
        z = ((m02 + m20) / s93)
    else
        if (m11 > m22) then
            local s94 = (math.sqrt((((1 + m11) - m00) - m22)) * 2)
            w = ((m02 - m20) / s94)
            x90 = ((m01 + m10) / s94)
            y91 = (0.25 * s94)
            z = ((m12 + m21) / s94)
        else
            local s95 = (math.sqrt((((1 + m22) - m00) - m11)) * 2)
            w = ((m10 - m01) / s95)
            x90 = ((m02 + m20) / s95)
            y91 = ((m12 + m21) / s95)
            z = (0.25 * s95)
        end
    end
    return SF__.Quaternion.Normalize(x90, y91, z, w)
end

function SF__.Quaternion.LookRotation__ose(forward__x96, forward__y97, forward__z98)
    return SF__.Quaternion.LookRotation__oseose(forward__x96, forward__y97, forward__z98, SF__.Vector3.get_up())
end

function SF__.Quaternion.Normalize(q__x99, q__y100, q__z101, q__w102)
    local magnitude = math.sqrt(((((q__x99 * q__x99) + (q__y100 * q__y100)) + (q__z101 * q__z101)) + (q__w102 * q__w102)))
    if (magnitude < 0.0001) then
        return SF__.Quaternion.get_identity()
    end
    return (q__x99 / magnitude), (q__y100 / magnitude), (q__z101 / magnitude), (q__w102 / magnitude)
end

function SF__.Quaternion.get_eulerAngles(self__x, self__y, self__z, self__w)
    -- https://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles#Source_Code_2
    local sinr_cosp = (2 * ((self__w * self__x) + (self__y * self__z)))
    local cosr_cosp = (1 - (2 * ((self__x * self__x) + (self__y * self__y))))
    local roll103 = math.atan(sinr_cosp, cosr_cosp)
    local sinp = (2 * ((self__w * self__y) - (self__z * self__x)))
    local pitch104
    if (math.abs(sinp) >= 1) then
        pitch104 = ((math.sign(sinp) * math.pi) / 2)
        -- use 90 degrees if out of range
    else
        pitch104 = math.asin(sinp)
    end
    local siny_cosp = (2 * ((self__w * self__z) + (self__x * self__y)))
    local cosy_cosp = (1 - (2 * ((self__y * self__y) + (self__z * self__z))))
    local yaw105 = math.atan(siny_cosp, cosy_cosp)
    return (pitch104 * bj_RADTODEG), (yaw105 * bj_RADTODEG), (roll103 * bj_RADTODEG)
end

function SF__.Quaternion.get_normalized(self__x106, self__y107, self__z108, self__w109)
    return SF__.Quaternion.Normalize(self__x106, self__y107, self__z108, self__w109)
end

function SF__.Quaternion.Inverse(rotation__x, rotation__y, rotation__z, rotation__w)
    return (-rotation__x), (-rotation__y), (-rotation__z), rotation__w
end

function SF__.Quaternion.ToString(self__x114, self__y115, self__z116, self__w117)
    return SF__.StrConcat__("(", self__x114, ", ", self__y115, ", ", self__z116, ", ", self__w117, ")")
end

function SF__.Quaternion.ApplyToEffect(self__x118, self__y119, self__z120, self__w121, e)
    local angles__x, angles__y, angles__z = SF__.Quaternion.get_eulerAngles(self__x118, self__y119, self__z120, self__w121)
    BlzSetSpecialEffectOrientation(e, (angles__y * bj_DEGTORAD), (angles__x * bj_DEGTORAD), (angles__z * bj_DEGTORAD))
end
-- <summary>
-- A basic list backed by a Lua sequential table.
-- Uses table.insert/table.remove for array operations.
-- C# indexer (0-based) maps to Lua table (1-based) via get_Item/set_Item.
-- </summary>
--
SF__.StdLib = SF__.StdLib or {}
-- StdLib.List
SF__.StdLib.List = SF__.StdLib.List or {}
SF__.StdLib.List.Name = "List"
SF__.StdLib.List.FullName = "StdLib.List"
function SF__.StdLib.List.__Init__0(self)
    self.__sf_type = SF__.StdLib.List
    self._items = nil
    self._version = 0
    self.Count = 0
    self._items = {}
    self._version = 0
    self.Count = 0
end

function SF__.StdLib.List.New__0()
    local self = setmetatable({}, { __index = SF__.StdLib.List })
    SF__.StdLib.List.__Init__0(self)
    return self
end

function SF__.StdLib.List.__Init__xqm20z(self, collection)
    SF__.StdLib.List.__Init__0(self)
    do
        local collection1 = collection
        for _, item659 in (SF__.StdLib.List.IpairsNext)(collection1) do
            repeat
                table.insert(self._items, item659)
                self.Count = (self.Count + 1)
            until true
        end
    end
end

function SF__.StdLib.List.New__xqm20z(collection)
    local self = setmetatable({}, { __index = SF__.StdLib.List })
    SF__.StdLib.List.__Init__xqm20z(self, collection)
    return self
end

function SF__.StdLib.List:get_Item(index660)
    if ((index660 < 0) or (index660 >= self.Count)) then
        error(SF__.StrConcat__("SF__E2e5944b8", "Index out of range"))
    end
    return self._items[(index660 + 1)]
end

function SF__.StdLib.List:set_Item(index661, value662)
    if ((index661 < 0) or (index661 >= self.Count)) then
        error(SF__.StrConcat__("SF__E2e5944b8", "Index out of range"))
    end
    self._items[(index661 + 1)] = value662
end

function SF__.StdLib.List:AddRange(collection663)
    do
        local collection2 = collection663
        for _, item664 in (SF__.StdLib.List.IpairsNext)(collection2) do
            repeat
                table.insert(self._items, item664)
                self.Count = (self.Count + 1)
            until true
        end
    end
    self._version = (self._version + 1)
end

function SF__.StdLib.List:Add(item665)
    table.insert(self._items, item665)
    self.Count = (self.Count + 1)
    self._version = (self._version + 1)
end

function SF__.StdLib.List:Clear()
    self._items = {}
    self.Count = 0
    self._version = (self._version + 1)
end

function SF__.StdLib.List:Remove(item666)
    local index667 = self:IndexOf(item666)
    if (index667 < 0) then
        return false
    end
    self:RemoveAt(index667)
    return true
end

function SF__.StdLib.List:RemoveAt(index668)
    table.remove(self._items, (index668 + 1))
    self.Count = (self.Count - 1)
    self._version = (self._version + 1)
end

function SF__.StdLib.List:IndexOf(item669)
    do
        local i670 = 0
        while (i670 < self.Count) do
            repeat
                local current671 = self._items[(i670 + 1)]
                if (current671 == item669) then
                    return i670
                end
            until true
            i670 = (i670 + 1)
        end
    end
    return (-1)
end

function SF__.StdLib.List.DefaultCompare(a672, b673)
    if (a672 == b673) then
        return 0
    end
    if (a672 < b673) then
        return (-1)
    end
    return 1
end

function SF__.StdLib.List:Sort(comparison)
    if (comparison == nil) then
        comparison = SF__.StdLib.List.DefaultCompare
    end
    local version674 = self._version
    table.sort(self._items, function(a677, b678)
        return (comparison(a677, b678) < 0)
    end)
    if (version674 ~= self._version) then
        error(SF__.StrConcat__("SF__E2e5944b8", "Collection was modified"))
    end
    self._version = (self._version + 1)
end

function SF__.StdLib.List:IpairsNext()
    local version679 = self._version
    local index680 = 0
    return function()
        if (version679 ~= self._version) then
            error(SF__.StrConcat__("SF__E2e5944b8", "Collection was modified"))
        end
        index680 = (index680 + 1)
        local value681 = self._items[index680]
        if (value681 == nil) then
            return nil
        end
        return index680, value681
    end
end

function SF__.StdLib.List:GetEnumerator()
    return nil
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
    local globalPos__x16, globalPos__y17, globalPos__z18 = self.localPosition__x, self.localPosition__y, self.localPosition__z
    local globalRot__x19, globalRot__y20, globalRot__z21, globalRot__w22 = self.localRotation__x, self.localRotation__y, self.localRotation__z, self.localRotation__w
    local globalScale__x23, globalScale__y24, globalScale__z25 = self.localScale__x, self.localScale__y, self.localScale__z
    local myParent = self.parent
    while (myParent ~= nil) do
        repeat
            globalPos__x16, globalPos__y17, globalPos__z18 = SF__.Vector3.op_Addition(myParent.localPosition__x, myParent.localPosition__y, myParent.localPosition__z, SF__.Quaternion.op_Multiply__iyiose(myParent.localRotation__x, myParent.localRotation__y, myParent.localRotation__z, myParent.localRotation__w, SF__.Vector3.Scale(myParent.localScale__x, myParent.localScale__y, myParent.localScale__z, globalPos__x16, globalPos__y17, globalPos__z18)))
            globalRot__x19, globalRot__y20, globalRot__z21, globalRot__w22 = SF__.Quaternion.op_Multiply__iyiiyi(myParent.localRotation__x, myParent.localRotation__y, myParent.localRotation__z, myParent.localRotation__w, globalRot__x19, globalRot__y20, globalRot__z21, globalRot__w22)
            globalScale__x23, globalScale__y24, globalScale__z25 = SF__.Vector3.Scale(myParent.localScale__x, myParent.localScale__y, myParent.localScale__z, globalScale__x23, globalScale__y24, globalScale__z25)
            myParent = myParent.parent
        until true
    end
    return globalPos__x16, globalPos__y17, globalPos__z18
end

function SF__.Transform:set_position(value__x, value__y, value__z)
    if (self.parent == nil) then
        self.localPosition__x, self.localPosition__y, self.localPosition__z = value__x, value__y, value__z
        return
    end
    local pos__x, pos__y, pos__z = value__x, value__y, value__z
    local myParent26 = self.parent
    while (myParent26 ~= nil) do
        repeat
            pos__x, pos__y, pos__z = SF__.Vector3.op_Subtraction(pos__x, pos__y, pos__z, myParent26.localPosition__x, myParent26.localPosition__y, myParent26.localPosition__z)
            pos__x, pos__y, pos__z = SF__.Vector3.Scale((1 / myParent26.localScale__x), (1 / myParent26.localScale__y), (1 / myParent26.localScale__z), pos__x, pos__y, pos__z)
            pos__x, pos__y, pos__z = (function()
                local q__x, q__y, q__z, q__w = SF__.Quaternion.Inverse(myParent26.localRotation__x, myParent26.localRotation__y, myParent26.localRotation__z, myParent26.localRotation__w)
                return SF__.Quaternion.op_Multiply__iyiose(q__x, q__y, q__z, q__w, pos__x, pos__y, pos__z)
            end)()
            myParent26 = myParent26.parent
        until true
    end
    self.localPosition__x, self.localPosition__y, self.localPosition__z = pos__x, pos__y, pos__z
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
    self.children = SF__.StdLib.List.New__0()
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
    return SF__.StrConcat__("Position: ", SF__.Vector3.ToString(self.localPosition__x, self.localPosition__y, self.localPosition__z), "\n", "Rotation: ", SF__.Vector3.ToString(SF__.Quaternion.get_eulerAngles(self.localRotation__x, self.localRotation__y, self.localRotation__z, self.localRotation__w)), "\n", "Scale: ", SF__.Vector3.ToString(self.localScale__x, self.localScale__y, self.localScale__z), "\n", "Children: ", self.children.Count)
end

function SF__.Transform:SetParent(newParent)
    if (self.parent ~= nil) then
        self.parent.children:Remove(self)
    end
    self.parent = newParent
    if (self.parent ~= nil) then
        self.parent.children:Add(self)
    end
end

function SF__.Transform._Find(current, parts, index)
    if (index >= #parts) then
        return current
    end
    do
        local collection3 = current.children
        for _, child in (SF__.StdLib.List.IpairsNext)(collection3) do
            repeat
                if (child.gameObject.name == parts[(index + 1)]) then
                    local found = SF__.Transform._Find(child, parts, (index + 1))
                    if (found ~= nil) then
                        return found
                    end
                end
            until true
        end
    end
    return nil
end

-- <summary>
-- Finds a child by name n and returns it.
-- If no child with name n can be found, null is returned. If n contains a '/' character it will access the Transform in the hierarchy like a path name.
-- </summary>
-- <param name="name"></param>
-- <returns></returns>
--
function SF__.Transform:Find(name)
    local parts27 = SF__.StrSplit__(name, "/")
    return SF__.Transform._Find(self, parts27, 0)
end
-- GameObject
SF__.GameObject = SF__.GameObject or {}
SF__.GameObject.Name = "GameObject"
SF__.GameObject.FullName = "GameObject"
function SF__.GameObject.MarkDestroyQueuedDepthFirst(obj30)
    if (obj30.isDestroyQueued or obj30.isDestroyed) then
        return
    end
    obj30.isDestroyQueued = true
    do
        local collection4 = obj30.transform.children
        for _, child31 in (SF__.StdLib.List.IpairsNext)(collection4) do
            repeat
                SF__.GameObject.MarkDestroyQueuedDepthFirst(child31.gameObject)
            until true
        end
    end
end

function SF__.GameObject.DestroyDepthFirst(obj32)
    if obj32.isDestroyed then
        return
    end
    local children = obj32.transform.children
    do
        local i = (children.Count - 1)
        while (i >= 0) do
            repeat
                SF__.GameObject.DestroyDepthFirst(children:get_Item(i).gameObject)
            until true
            i = (i - 1)
        end
    end
    obj32.transform:SetParent(nil)
    do
        local collection5 = obj32._components
        for _, comp in (SF__.StdLib.List.IpairsNext)(collection5) do
            repeat
                comp:OnDisable()
                comp:OnDestroy()
            until true
        end
    end
    obj32._components:Clear()
    SF__.Scene.get_Instance().gameObjs:Remove(obj32)
    obj32.isDestroyed = true
end

function SF__.GameObject:get_components()
    return self._components
end

function SF__.GameObject.__Init__s(self, name33)
    self.__sf_type = SF__.GameObject
    self.name = nil
    self.transform = nil
    self._components = SF__.StdLib.List.New__0()
    self.isDestroyQueued = false
    self.isDestroyed = false
    self.name = name33
    self.transform = self:AddComponent(SF__.Transform)
    SF__.Scene.get_Instance():AddGameObject(self)
end

function SF__.GameObject.New__s(name33)
    local self = setmetatable({}, { __index = SF__.GameObject })
    SF__.GameObject.__Init__s(self, name33)
    return self
end

function SF__.GameObject.__Init__sx13(self, name34, parent35)
    SF__.GameObject.__Init__s(self, name34)
    self.transform:SetParent(parent35.transform)
end

function SF__.GameObject.New__sx13(name34, parent35)
    local self = setmetatable({}, { __index = SF__.GameObject })
    SF__.GameObject.__Init__sx13(self, name34, parent35)
    return self
end

function SF__.GameObject:GetComponent(T)
    do
        local collection6 = self._components
        for _, comp36 in (SF__.StdLib.List.IpairsNext)(collection6) do
            repeat
                do
                    local tComp = comp36
                    if SF__.TypeIs__(tComp, T) then
                        return tComp
                    end
                end
            until true
        end
    end
    return nil
end

function SF__.GameObject:AddComponent(T37)
    local comp38 = (function()
        local obj39 = T37.New()
        obj39.gameObject = self
        return obj39
    end)()
    self._components:Add(comp38)
    comp38:Awake()
    comp38:OnEnable()
    comp38:Start()
    return comp38
end

function SF__.GameObject:RemoveAllComponents(T40)
    do
        local i41 = (self._components.Count - 1)
        while (i41 >= 0) do
            repeat
                if SF__.TypeIs__(self._components:get_Item(i41), T40) then
                    self._components:get_Item(i41):OnDisable()
                    self._components:get_Item(i41):OnDestroy()
                    self._components:RemoveAt(i41)
                end
            until true
            i41 = (i41 - 1)
        end
    end
end

function SF__.GameObject:Update()
    if (self.isDestroyQueued or self.isDestroyed) then
        return
    end
    local snapshot = SF__.StdLib.List.New__xqm20z(self._components)
    do
        local collection7 = snapshot
        for _, comp42 in (SF__.StdLib.List.IpairsNext)(collection7) do
            repeat
                comp42:Update()
            until true
        end
    end
end

function SF__.GameObject:LateUpdate()
    if (self.isDestroyQueued or self.isDestroyed) then
        return
    end
    local snapshot43 = SF__.StdLib.List.New__xqm20z(self._components)
    do
        local collection8 = snapshot43
        for _, comp44 in (SF__.StdLib.List.IpairsNext)(collection8) do
            repeat
                comp44:LateUpdate()
            until true
        end
    end
end

function SF__.GameObject:Destroy()
    if (self.isDestroyQueued or self.isDestroyed) then
        return
    end
    SF__.GameObject.MarkDestroyQueuedDepthFirst(self)
    SF__.Scene.get_Instance():QueueDestroy(self)
end

function SF__.GameObject.DestroyQueued(obj45)
    SF__.GameObject.DestroyDepthFirst(obj45)
end

function SF__.GameObject:GetComponentInChildren(T46)
    do
        local collection9 = self.transform.children
        for _, child47 in (SF__.StdLib.List.IpairsNext)(collection9) do
            repeat
                local comp48 = child47.gameObject:GetComponent(T46)
                if (comp48 ~= nil) then
                    return comp48
                end
                comp48 = child47.gameObject:GetComponentInChildren(T46)
                if (comp48 ~= nil) then
                    return comp48
                end
            until true
        end
    end
    return nil
end
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

function SF__.Scene:AddGameObject(obj49)
    self.gameObjs:Add(obj49)
end

function SF__.Scene:QueueDestroy(obj50)
    self._destroyQueue:Add(obj50)
end

function SF__.Scene:FlushDestroyQueue()
    do
        local i51 = 0
        while (i51 < self._destroyQueue.Count) do
            repeat
                SF__.GameObject.DestroyQueued(self._destroyQueue:get_Item(i51))
            until true
            i51 = (i51 + 1)
        end
    end
    self._destroyQueue:Clear()
end

function SF__.Scene:Run()
    return SF__.CorRun__(function()
        while true do
            repeat
                SF__.CorWait__(SF__.Scene.DT)
                local count = self.gameObjs.Count
                do
                    local i52 = 0
                    while (i52 < count) do
                        repeat
                            self.gameObjs:get_Item(i52):Update()
                        until true
                        i52 = (i52 + 1)
                    end
                end
                do
                    local i53 = 0
                    while (i53 < count) do
                        repeat
                            self.gameObjs:get_Item(i53):LateUpdate()
                        until true
                        i53 = (i53 + 1)
                    end
                end
                self:FlushDestroyQueue()
            until true
        end
    end)
end

function SF__.Scene.__Init(self)
    self.__sf_type = SF__.Scene
    self.gameObjs = SF__.StdLib.List.New__0()
    self._destroyQueue = SF__.StdLib.List.New__0()
end

function SF__.Scene.New()
    local self = setmetatable({}, { __index = SF__.Scene })
    SF__.Scene.__Init(self)
    return self
end

SF__.Scene.DT = 20
SF__.Scene._instance = nil
-- AttachEffectComponent
SF__.AttachEffectComponent = SF__.AttachEffectComponent or {}
SF__.AttachEffectComponent.Name = "AttachEffectComponent"
SF__.AttachEffectComponent.FullName = "AttachEffectComponent"
setmetatable(SF__.AttachEffectComponent, { __index = SF__.Component })
SF__.AttachEffectComponent.__sf_base = SF__.Component
function SF__.AttachEffectComponent:GetInspectorText()
    return SF__.StrConcat__("Effect: ", (function() if (self.eff == nil) then return "None" else return "Attached" end end)(), "\r\n_tarPos: ", SF__.Vector3.ToString(self._tarPos__x, self._tarPos__y, self._tarPos__z))
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
        repeat
            globalPos__x, globalPos__y, globalPos__z = SF__.Vector3.op_Addition(parent.localPosition__x, parent.localPosition__y, parent.localPosition__z, SF__.Quaternion.op_Multiply__iyiose(parent.localRotation__x, parent.localRotation__y, parent.localRotation__z, parent.localRotation__w, SF__.Vector3.Scale(parent.localScale__x, parent.localScale__y, parent.localScale__z, globalPos__x, globalPos__y, globalPos__z)))
            globalRot__x, globalRot__y, globalRot__z, globalRot__w = SF__.Quaternion.op_Multiply__iyiiyi(parent.localRotation__x, parent.localRotation__y, parent.localRotation__z, parent.localRotation__w, globalRot__x, globalRot__y, globalRot__z, globalRot__w)
            globalScale__x, globalScale__y, globalScale__z = SF__.Vector3.Scale(parent.localScale__x, parent.localScale__y, parent.localScale__z, globalScale__x, globalScale__y, globalScale__z)
            parent = parent.parent
        until true
    end
    self._lerpElapsed = (self._lerpElapsed + SF__.Scene.DT)
    self._tarPos__x, self._tarPos__y, self._tarPos__z = globalPos__x, globalPos__y, globalPos__z
    if (self._lerpElapsed < self._lerpDuration) then
        self._tarPos__x, self._tarPos__y, self._tarPos__z = SF__.Vector3.Lerp(self._lastPos__x, self._lastPos__y, self._lastPos__z, globalPos__x, globalPos__y, globalPos__z, (self._lerpElapsed / self._lerpDuration))
    end
    BlzSetSpecialEffectPosition(self.eff, self._tarPos__x, self._tarPos__y, self._tarPos__z)
    self._lastPos__x, self._lastPos__y, self._lastPos__z = self._tarPos__x, self._tarPos__y, self._tarPos__z
    SF__.Quaternion.ApplyToEffect(globalRot__x, globalRot__y, globalRot__z, globalRot__w, self.eff)
    BlzSetSpecialEffectMatrixScale(self.eff, globalScale__x, globalScale__y, globalScale__z)
end

function SF__.AttachEffectComponent:OnDestroy()
    if (self.eff ~= nil) then
        DestroyEffect(self.eff)
        self.eff = nil
    end
end

function SF__.AttachEffectComponent:AttachEffect(eff)
    self.eff = eff
    self._lastPos__x, self._lastPos__y, self._lastPos__z = BlzGetLocalSpecialEffectX(eff), BlzGetLocalSpecialEffectY(eff), BlzGetLocalSpecialEffectZ(eff)
end

-- <summary>
--
-- </summary>
-- <param name="duration">ms</param>
--
function SF__.AttachEffectComponent:LerpIn(duration)
    if (self.eff == nil) then
        return
    end
    self._lerpDuration = duration
    self._lerpElapsed = 0
end

function SF__.AttachEffectComponent.__Init(self)
    SF__.Component.__Init(self)
    self.__sf_type = SF__.AttachEffectComponent
    self._lastPos__x = 0
    self._lastPos__y = 0
    self._lastPos__z = 0
    self._lerpDuration = 0
    self._lerpElapsed = 0
    self._tarPos__x = 0
    self._tarPos__y = 0
    self._tarPos__z = 0
    self.eff = nil
end

function SF__.AttachEffectComponent.New()
    local self = setmetatable({}, { __index = SF__.AttachEffectComponent })
    SF__.AttachEffectComponent.__Init(self)
    return self
end
-- AttachUnitComponent
SF__.AttachUnitComponent = SF__.AttachUnitComponent or {}
SF__.AttachUnitComponent.Name = "AttachUnitComponent"
SF__.AttachUnitComponent.FullName = "AttachUnitComponent"
setmetatable(SF__.AttachUnitComponent, { __index = SF__.Component })
SF__.AttachUnitComponent.__sf_base = SF__.Component
function SF__.AttachUnitComponent:SetUnit(target)
    self.target = target
end

function SF__.AttachUnitComponent.__Init(self)
    SF__.Component.__Init(self)
    self.__sf_type = SF__.AttachUnitComponent
    self.target = nil
end

function SF__.AttachUnitComponent.New()
    local self = setmetatable({}, { __index = SF__.AttachUnitComponent })
    SF__.AttachUnitComponent.__Init(self)
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
    trs.localRotation__x, trs.localRotation__y, trs.localRotation__z, trs.localRotation__w = SF__.Quaternion.op_Multiply__iyiiyi(self.rotation__x, self.rotation__y, self.rotation__z, self.rotation__w, trs.localRotation__x, trs.localRotation__y, trs.localRotation__z, trs.localRotation__w)
    if (self.followUnit ~= nil) then
        trs.localPosition__x, trs.localPosition__y, trs.localPosition__z = SF__.Vector3.FromUnit(self.followUnit)
    end
end

function SF__.AutoTRSComponent.__Init(self)
    SF__.Component.__Init(self)
    self.__sf_type = SF__.AutoTRSComponent
    self.rotation = SF__.Quaternion.get_identity()
    self.followUnit = nil
end

function SF__.AutoTRSComponent.New()
    local self = setmetatable({}, { __index = SF__.AutoTRSComponent })
    SF__.AutoTRSComponent.__Init(self)
    return self
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

function SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p123, abilCode124, researchExtendedTooltip, level125)
    if (GetLocalPlayer() ~= p123) then
        return
    end
    BlzSetAbilityResearchExtendedTooltip(abilCode124, researchExtendedTooltip, level125)
end

function SF__.Utils.ExBlzSetAbilityTooltip(p126, abilCode127, tooltip, level128)
    if (GetLocalPlayer() ~= p126) then
        return
    end
    BlzSetAbilityTooltip(abilCode127, tooltip, level128)
end

function SF__.Utils.ExBlzSetAbilityExtendedTooltip(p129, abilCode130, extendedTooltip, level131)
    if (GetLocalPlayer() ~= p129) then
        return
    end
    BlzSetAbilityExtendedTooltip(abilCode130, extendedTooltip, level131)
end

function SF__.Utils.ExBlzSetAbilityIcon(p132, abilCode133, iconPath)
    if (GetLocalPlayer() ~= p132) then
        return
    end
    BlzSetAbilityIcon(abilCode133, iconPath)
end

function SF__.Utils.CsGroupGetUnitsInRange(x134, y135, radius, filter)
    local result = SF__.StdLib.List.New__0()
    ExGroupEnumUnitsInRange(x134, y135, radius, function(u137)
        if filter(u137) then
            result:Add(u137)
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
-- TemplarStrikes
SF__.TemplarStrikes = SF__.TemplarStrikes or {}
SF__.TemplarStrikes.Name = "TemplarStrikes"
SF__.TemplarStrikes.FullName = "TemplarStrikes"
function SF__.TemplarStrikes.GetAbilityData(level521)
    return 2, (0.5 + (0.25 * level521)), (0.05 * level521)
end

function SF__.TemplarStrikes.Init()
    local EventCenter522 = require("Lib.EventCenter")
    EventCenter522.RegisterPlayerUnitSpellEffect:Emit({id = SF__.TemplarStrikes.ID, handler = SF__.TemplarStrikes.Start})
    ExTriggerRegisterNewUnit(function(u524)
        if (GetUnitTypeId(u524) == FourCC("Hpal")) then
            SF__.TemplarStrikes.UpdateAbilityMeta(u524)
            SetHeroLevel(u524, 10, true)
        end
    end)
    EventCenter522.RegisterPlayerUnitDamaged:Emit(function(caster528, target529, damage530, weapType531, dmgType532, isAttack533)
        if (GetUnitAbilityLevel(caster528, SF__.TemplarStrikes.ID) <= 0) then
            return
        end
        if (not isAttack533) then
            return
        end
        if (target529 == nil) then
            return
        end
        if ExIsUnitDead(target529) then
            return
        end
        SF__.TemplarStrikes.TryResetBOJ(caster528)
    end)
end

function SF__.TemplarStrikes.TryResetBOJ(caster534)
    local level535 = GetUnitAbilityLevel(caster534, SF__.TemplarStrikes.ID)
    local ad__AttackCount, ad__DamageScaling536, ad__ResetBOJChance = SF__.TemplarStrikes.GetAbilityData(level535)
    if (math.random() >= ad__ResetBOJChance) then
        return
    end
    BlzEndUnitAbilityCooldown(caster534, SF__.BladeOfJustice.ID)
    ExAddSpecialEffectTarget("Abilities/Spells/Items/AIam/AIamTarget.mdl", caster534, "origin", 0.3)
end

function SF__.TemplarStrikes.UpdateAbilityMeta(u537)
    local p538 = GetOwningPlayer(u537)
    local datas539 = SF__.StdLib.List.New__0()
    do
        local i540 = 0
        while (i540 < SF__.TemplarStrikes.MaxLevel) do
            repeat
                local __pack_AttackCount, __pack_DamageScaling541, __pack_ResetBOJChance = SF__.TemplarStrikes.GetAbilityData((i540 + 1))
                datas539:Add({AttackCount = __pack_AttackCount, DamageScaling = __pack_DamageScaling541, ResetBOJChance = __pack_ResetBOJChance})
            until true
            i540 = (i540 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p538, SF__.TemplarStrikes.ID, "学习圣殿骑士之击 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p538, SF__.TemplarStrikes.ID, SF__.StrConcat__("快速攻击目标|cffff8c00", datas539:get_Item(0).AttackCount, "|r次，第一次造成普通攻击伤害，第二次造成光辉伤害，有一定几率重置公正之剑的冷却时间，普通攻击也会触发。\n\n|cff99ccff冷却时间|r - 10秒\n\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas539:get_Item(0).DamageScaling * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas539:get_Item(0).ResetBOJChance * 100)), "%|r的几率重置公正之剑。\n|cffffcc002级|r - |cffff8c00", string.format("%.0f", (datas539:get_Item(1).DamageScaling * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas539:get_Item(1).ResetBOJChance * 100)), "%|r的几率重置公正之剑。\n|cffffcc003级|r - |cffff8c00", string.format("%.0f", (datas539:get_Item(2).DamageScaling * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas539:get_Item(2).ResetBOJChance * 100)), "%|r的几率重置公正之剑。"), 0)
    do
        local i542 = 0
        while (i542 < SF__.TemplarStrikes.MaxLevel) do
            repeat
                local __unpack_tmp544 = datas539:get_Item(i542)
                local data__AttackCount, data__DamageScaling543, data__ResetBOJChance = __unpack_tmp544.AttackCount, __unpack_tmp544.DamageScaling, __unpack_tmp544.ResetBOJChance
                SF__.Utils.ExBlzSetAbilityTooltip(p538, SF__.TemplarStrikes.ID, SF__.StrConcat__("圣殿骑士之击 - [|cffffcc00", (i542 + 1), "级|r]"), i542)
                SF__.Utils.ExBlzSetAbilityExtendedTooltip(p538, SF__.TemplarStrikes.ID, SF__.StrConcat__("快速攻击目标|cffff8c00", data__AttackCount, "|r次，第一次造成普通攻击伤害，第二次造成普通攻击|cffff8c00", string.format("%.0f", (data__DamageScaling543 * 100)), "%|r的光辉伤害，|cffff8c00", string.format("%.0f", (data__ResetBOJChance * 100)), "%|r几率重置公正之剑的冷却时间，普通攻击也会触发。\n\n|cff99ccff冷却时间|r - 10秒"), i542)
            until true
            i542 = (i542 + 1)
        end
    end
end

function SF__.TemplarStrikes.Start(data545)
    return SF__.CorRun__(function()
        local level546 = GetUnitAbilityLevel(data545.caster, SF__.TemplarStrikes.ID)
        local UnitAttribute548 = require("Objects.UnitAttribute")
        local BuffBase549 = require("Objects.BuffBase")
        local EventCenter550 = require("Lib.EventCenter")
        local attr547 = UnitAttribute548.GetAttr(data545.caster)
        local normalDamage = attr547:SimMeleeAttack()
        local hasWoa = (BuffBase549.FindBuffByClassName(data545.caster, "WakeOfAshesBuff") ~= nil)
        EventCenter550.Damage:Emit({whichUnit = data545.caster, target = data545.target, amount = normalDamage, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
        SF__.TemplarStrikes.TryResetBOJ(data545.caster)
        if hasWoa then
            SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(data545.caster, 1)
        end
        SetUnitTimeScale(data545.caster, 3)
        ResetUnitAnimation(data545.caster)
        SetUnitAnimation(data545.caster, "attack - 2")
        SF__.CorWait__(math.round(((1.166 * 0.33) * 1000)))
        local tarAttr551 = UnitAttribute548.GetAttr(data545.target)
        local ad__AttackCount552, ad__DamageScaling553, ad__ResetBOJChance554 = SF__.TemplarStrikes.GetAbilityData(level546)
        local radiantDamage = ((attr547:SimMeleeAttack() * ad__DamageScaling553) * (1 - tarAttr551.radiantResistance))
        EventCenter550.Damage:Emit({whichUnit = data545.caster, target = data545.target, amount = radiantDamage, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
        SF__.TemplarStrikes.TryResetBOJ(data545.caster)
        if hasWoa then
            SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(data545.caster, 1)
        end
        SetUnitTimeScale(data545.caster, 1)
        ResetUnitAnimation(data545.caster)
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
-- WakeOfAshes
SF__.WakeOfAshes = SF__.WakeOfAshes or {}
SF__.WakeOfAshes.Name = "WakeOfAshes"
SF__.WakeOfAshes.FullName = "WakeOfAshes"
function SF__.WakeOfAshes.Init()
    local EventCenter577 = require("Lib.EventCenter")
    EventCenter577.RegisterPlayerUnitSpellEffect:Emit({id = SF__.WakeOfAshes.ID, handler = SF__.WakeOfAshes.Start})
    ExTriggerRegisterNewUnit(function(u579)
        if (GetUnitTypeId(u579) == FourCC("Hpal")) then
            SF__.WakeOfAshes.UpdateAbilityMeta(u579)
        end
    end)
end

function SF__.WakeOfAshes.UpdateAbilityMeta(u580)
    local p581 = GetOwningPlayer(u580)
    SF__.Utils.ExSetAbilityResearchTooltip(p581, SF__.WakeOfAshes.ID, "学习灰烬觉醒 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p581, SF__.WakeOfAshes.ID, "对你前方敌人造成|cffff8c00300|r点光辉伤害，并激活复仇之怒效果，在复仇之怒效果期间：\r\n· 每消耗|cffff8c001|r点神圣能量，圣殿骑士之击与公正之剑的冷却时间缩短|cffff8c0010%|r。\r\n· 圣殿骑士之击的攻击会获得神圣能量。\r\n· 荣耀圣令的治疗效果提高|cffff8c00100%|r。\r\n· 神圣风暴被替换为圣光之锤。\r\n\r\n|cffffcc00圣光之锤|r\r\n对当前目标造成|cffff8c00450|r点光辉伤害，另外对附近所有目标造成|cffff8c00350|r点光辉伤害。使神圣之锤的持续时间延长|cffff8c004|r秒。消耗|cffff8c005|r神圣能量", 0)
    do
        local i582 = 0
        while (i582 < 1) do
            repeat
                SF__.Utils.ExBlzSetAbilityTooltip(p581, SF__.WakeOfAshes.ID, SF__.StrConcat__("灰烬觉醒 - [|cffffcc00", (i582 + 1), "级|r]"), i582)
                SF__.Utils.ExBlzSetAbilityExtendedTooltip(p581, SF__.WakeOfAshes.ID, "对你前方敌人造成|cffff8c00300|r点光辉伤害，并激活复仇之怒效果，在复仇之怒效果期间：\r\n· 每消耗|cffff8c001|r点神圣能量，圣殿骑士之击与公正之剑的冷却时间缩短|cffff8c0010%|r。\r\n· 圣殿骑士之击的攻击会获得神圣能量。\r\n· 荣耀圣令的治疗效果提高|cffff8c00100%|r。\r\n· 神圣风暴被替换为圣光之锤。\r\n\r\n|cffffcc00圣光之锤|r\r\n对当前目标造成|cffff8c00450|r点光辉伤害，另外对附近所有目标造成|cffff8c00350|r点光辉伤害。使神圣之锤的持续时间延长|cffff8c004|r秒。消耗|cffff8c005|r神圣能量", i582)
            until true
            i582 = (i582 + 1)
        end
    end
end

function SF__.WakeOfAshes.Start(data583)
    local pos__x584, pos__y585, pos__z586 = SF__.Vector3.FromUnit(data583.caster)
    local UnitAttribute595 = require("Objects.UnitAttribute")
    local EventCenter596 = require("Lib.EventCenter")
    local BuffBase622 = require("Objects.BuffBase")
    local facing = GetUnitFacing(data583.caster)
    local forward__x587, forward__y588, forward__z589 = math.cos((facing * bj_DEGTORAD)), math.sin((facing * bj_DEGTORAD)), 0
    ExGroupEnumUnitsInRange(pos__x584, pos__y585, 400, function(u597)
        if (not IsUnitEnemy(u597, GetOwningPlayer(data583.caster))) then
            return
        end
        if ExIsUnitDead(u597) then
            return
        end
        local direction__x601, direction__y602, direction__z603 = SF__.Vector3.get_normalized((function()
            local a__x598, a__y599, a__z600 = SF__.Vector3.FromUnit(u597)
            return SF__.Vector3.op_Subtraction(a__x598, a__y599, a__z600, pos__x584, pos__y585, pos__z586)
        end)())
        if (SF__.Vector3.Dot(forward__x587, forward__y588, forward__z589, direction__x601, direction__y602, direction__z603) < 0.5) then
            return
        end
        local attr604 = UnitAttribute595.GetAttr(u597)
        EventCenter596.Damage:Emit({whichUnit = data583.caster, target = u597, amount = (200 * (1 - attr604.radiantResistance)), attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
    end)
    -- fire breath visual
    local eff605 = AddSpecialEffect("Abilities/Spells/Other/BreathOfFire/BreathOfFireMissile.mdl", pos__x584, pos__y585)
    local rotation__x606, rotation__y607, rotation__z608, rotation__w609 = SF__.Quaternion.Euler(0, facing, 0)
    local effPos__x, effPos__y, effPos__z = pos__x584, pos__y585, 0
    local effStart__x, effStart__y, effStart__z = SF__.Vector3.op_Addition(effPos__x, effPos__y, effPos__z, (function()
        local v__x610, v__y611, v__z612 = SF__.Quaternion.op_Multiply__iyiose(rotation__x606, rotation__y607, rotation__z608, rotation__w609, SF__.Vector3.get_right())
        return SF__.Vector3.op_Multiply__osef(v__x610, v__y611, v__z612, 200)
    end)())
    local dest__x, dest__y, dest__z = SF__.Vector3.op_Addition(effPos__x, effPos__y, effPos__z, (function()
        local v__x613, v__y614, v__z615 = SF__.Quaternion.op_Multiply__iyiose(rotation__x606, rotation__y607, rotation__z608, rotation__w609, SF__.Vector3.get_right())
        return SF__.Vector3.op_Multiply__osef(v__x613, v__y614, v__z615, 800)
    end)())
    local fireRoot = SF__.GameObject.New__s("fire_breath")
    fireRoot.transform.localPosition__x, fireRoot.transform.localPosition__y, fireRoot.transform.localPosition__z = effStart__x, effStart__y, pos__z586
    fireRoot:AddComponent(SF__.Missile):SetupPointTarget(dest__x, dest__y, pos__z586, 900, function(mis617, arrivedAt__x618, arrivedAt__y619, arrivedAt__z620)
        mis617.gameObject:Destroy()
    end)
    local rotOffset = SF__.GameObject.New__sx13("rot_offset", fireRoot)
    rotOffset.transform.localRotation__x, rotOffset.transform.localRotation__y, rotOffset.transform.localRotation__z, rotOffset.transform.localRotation__w = SF__.Quaternion.Euler(0, 90, 0)
    rotOffset:AddComponent(SF__.AttachEffectComponent):AttachEffect(eff605)
    -- buffs
    local buff621 = BuffBase622.FindBuffByClassName(data583.caster, "WakeOfAshesBuff")
    if (buff621 ~= nil) then
        buff621:ResetDuration()
    else
        SF__.WakeOfAshes.WakeOfAshesBuff.New(data583.caster, data583.caster, 30, 0.5, {level = 0, charged = 0})
    end
end

function SF__.WakeOfAshes.__Init(self)
    self.__sf_type = SF__.WakeOfAshes
end

function SF__.WakeOfAshes.New()
    local self = setmetatable({}, { __index = SF__.WakeOfAshes })
    SF__.WakeOfAshes.__Init(self)
    return self
end

SF__.WakeOfAshes.ID = FourCC("A009")
SF__.WakeOfAshes = SF__.WakeOfAshes or {}
-- WakeOfAshes.QuicknessBuff
local BuffBase631 = require("Objects.BuffBase")
SF__.WakeOfAshes.QuicknessBuff = SF__.WakeOfAshes.QuicknessBuff or class("QuicknessBuff", BuffBase631)
SF__.WakeOfAshes.QuicknessBuff.Name = "QuicknessBuff"
SF__.WakeOfAshes.QuicknessBuff.FullName = "WakeOfAshes.QuicknessBuff"
SF__.WakeOfAshes.QuicknessBuff.__sf_base = BuffBase631
function SF__.WakeOfAshes.QuicknessBuff.__Init(self, caster632, target633, duration634, interval635, awakeData636)
    self.__sf_type = SF__.WakeOfAshes.QuicknessBuff
end

function SF__.WakeOfAshes.QuicknessBuff.New(caster632, target633, duration634, interval635, awakeData636)
    local self = SF__.WakeOfAshes.QuicknessBuff.new(caster632, target633, duration634, interval635, awakeData636)
    SF__.WakeOfAshes.QuicknessBuff.__Init(self, caster632, target633, duration634, interval635, awakeData636)
    return self
end

function SF__.WakeOfAshes.QuicknessBuff:OnDisable()
    do
        local i637 = 0
        while (i637 < 3) do
            repeat
                BlzSetUnitAbilityCooldown(self.target, SF__.BladeOfJustice.ID, i637, 10)
                BlzSetUnitAbilityCooldown(self.target, SF__.TemplarStrikes.ID, i637, 10)
            until true
            i637 = (i637 + 1)
        end
    end
end
-- RetributionPaladinGlobal
SF__.RetributionPaladinGlobal = SF__.RetributionPaladinGlobal or {}
SF__.RetributionPaladinGlobal.Name = "RetributionPaladinGlobal"
SF__.RetributionPaladinGlobal.FullName = "RetributionPaladinGlobal"
function SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(u506, amount)
    local UnitAttribute508 = require("Objects.UnitAttribute")
    local attr507 = UnitAttribute508.GetAttr(u506)
    attr507.retPalHolyEnergy = math.min((attr507.retPalHolyEnergy + amount), 5)
end

function SF__.RetributionPaladinGlobal.ConsumeHolyEnergy(u509, amount510)
    local UnitAttribute512 = require("Objects.UnitAttribute")
    local BuffBase514 = require("Objects.BuffBase")
    local attr511 = UnitAttribute512.GetAttr(u509)
    local before = attr511.retPalHolyEnergy
    attr511.retPalHolyEnergy = math.max((attr511.retPalHolyEnergy - amount510), 0)
    local consumed = (before - attr511.retPalHolyEnergy)
    -- wake of ashes
    local buff513 = BuffBase514.FindBuffByClassName(u509, "WakeOfAshesBuff")
    if (buff513 ~= nil) then
        local quickness = BuffBase514.FindBuffByClassName(u509, "QuicknessBuff")
        if (quickness == nil) then
            quickness = SF__.WakeOfAshes.QuicknessBuff.New(u509, u509, 9999, 9999, {})
        end
        quickness:IncreaseStack(consumed)
        local cd = math.max((10 * (1 - (0.05 * quickness.stack))), 1)
        do
            local i515 = 0
            while (i515 < 3) do
                repeat
                    BlzSetUnitAbilityCooldown(u509, SF__.BladeOfJustice.ID, i515, cd)
                    BlzSetUnitAbilityCooldown(u509, SF__.TemplarStrikes.ID, i515, cd)
                until true
                i515 = (i515 + 1)
            end
        end
    end
end

function SF__.RetributionPaladinGlobal:Init()
    ExTriggerRegisterNewUnit(function(u517)
        if (GetUnitTypeId(u517) == FourCC("Hpal")) then
            self._units:Add(u517)
        end
    end)
    _ = self:Start()
end

function SF__.RetributionPaladinGlobal:Start()
    return SF__.CorRun__(function()
        local UnitAttribute520 = require("Objects.UnitAttribute")
        while true do
            repeat
                do
                    local collection10 = self._units
                    for _, u518 in (SF__.StdLib.List.IpairsNext)(collection10) do
                        repeat
                            local attr519 = UnitAttribute520.GetAttr(u518)
                            ExSetUnitMana(u518, ((ExGetUnitMaxMana(u518) * attr519.retPalHolyEnergy) * 0.2))
                            if (attr519.retPalHolyEnergy >= 3) then
                                SF__.Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u518), FourCC("A006"), "ReplaceableTextures/CommandButtons/BTNinv_helmet_96.tga")
                                SF__.Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u518), FourCC("A005"), "ReplaceableTextures/CommandButtons/BTNability_paladin_divinestorm.tga")
                            else
                                SF__.Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u518), FourCC("A006"), "ReplaceableTextures/PassiveButtons/PASBTNinv_helmet_96.tga")
                                SF__.Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u518), FourCC("A005"), "ReplaceableTextures/PassiveButtons/PASBTNability_paladin_divinestorm.tga")
                            end
                        until true
                    end
                end
                SF__.CorWait__(100)
            until true
        end
    end)
end

function SF__.RetributionPaladinGlobal.__Init(self)
    self.__sf_type = SF__.RetributionPaladinGlobal
    self._units = SF__.StdLib.List.New__0()
end

function SF__.RetributionPaladinGlobal.New()
    local self = setmetatable({}, { __index = SF__.RetributionPaladinGlobal })
    SF__.RetributionPaladinGlobal.__Init(self)
    return self
end

SF__.RetributionPaladinGlobal.Instance = SF__.RetributionPaladinGlobal.New()
-- BladeOfJustice
SF__.BladeOfJustice = SF__.BladeOfJustice or {}
SF__.BladeOfJustice.Name = "BladeOfJustice"
SF__.BladeOfJustice.FullName = "BladeOfJustice"
function SF__.BladeOfJustice.GetAbilityData(level327)
    return (75 * level327), 5, (10 * level327)
end

function SF__.BladeOfJustice.Init()
    local EventCenter = require("Lib.EventCenter")
    EventCenter.RegisterPlayerUnitSpellEffect:Emit({id = SF__.BladeOfJustice.ID, handler = SF__.BladeOfJustice.Start})
    ExTriggerRegisterNewUnit(function(u329)
        if (GetUnitTypeId(u329) == FourCC("Hpal")) then
            SF__.BladeOfJustice.UpdateAbilityMeta(u329)
        end
    end)
end

function SF__.BladeOfJustice.UpdateAbilityMeta(u330)
    local p331 = GetOwningPlayer(u330)
    local datas = SF__.StdLib.List.New__0()
    do
        local i332 = 0
        while (i332 < 3) do
            repeat
                local __pack_Damage, __pack_Duration, __pack_DamagePerSecond = SF__.BladeOfJustice.GetAbilityData((i332 + 1))
                datas:Add({Damage = __pack_Damage, Duration = __pack_Duration, DamagePerSecond = __pack_DamagePerSecond})
            until true
            i332 = (i332 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p331, SF__.BladeOfJustice.ID, "学习公正之剑 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p331, SF__.BladeOfJustice.ID, SF__.StrConcat__("用圣光的利刃刺穿目标，造成法术伤害，在一定时间内对附近敌人每秒造成光辉伤害。产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 10秒\n\n|cffffcc001级|r - 造成|cffff8c00", datas:get_Item(0).Damage, "|r的直接法术伤害，|cffff8c00", datas:get_Item(0).Duration, "|r秒内对附近敌人每秒造成|cffff8c00", datas:get_Item(0).DamagePerSecond, "|r的光辉伤害。产生|cffff8c001|r点圣能。\n|cffffcc002级|r - 造成|cffff8c00", datas:get_Item(1).Damage, "|r的直接法术伤害，|cffff8c00", datas:get_Item(1).Duration, "|r秒内对附近敌人每秒造成|cffff8c00", datas:get_Item(1).DamagePerSecond, "|r的光辉伤害。产生|cffff8c001|r点圣能。\n|cffffcc003级|r - 造成|cffff8c00", datas:get_Item(2).Damage, "|r的直接法术伤害，|cffff8c00", datas:get_Item(2).Duration, "|r秒内对附近敌人每秒造成|cffff8c00", datas:get_Item(2).DamagePerSecond, "|r的光辉伤害。产生|cffff8c001|r点圣能。"), 0)
    do
        local i333 = 0
        while (i333 < 3) do
            repeat
                local __unpack_tmp = datas:get_Item(i333)
                local data__Damage, data__Duration, data__DamagePerSecond = __unpack_tmp.Damage, __unpack_tmp.Duration, __unpack_tmp.DamagePerSecond
                SF__.Utils.ExBlzSetAbilityTooltip(p331, SF__.BladeOfJustice.ID, SF__.StrConcat__("公正之剑 - [|cffffcc00", (i333 + 1), "级|r]"), i333)
                SF__.Utils.ExBlzSetAbilityExtendedTooltip(p331, SF__.BladeOfJustice.ID, SF__.StrConcat__("用圣光的利刃刺穿目标，造成|cffff8c00", data__Damage, "|r的直接法术伤害，在|cffff8c00", data__Duration, "|r秒内对附近敌人每秒造成|cffff8c00", data__DamagePerSecond, "|r的光辉伤害。产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 10秒"), i333)
            until true
            i333 = (i333 + 1)
        end
    end
end

function SF__.BladeOfJustice.Start(data)
    local level334 = GetUnitAbilityLevel(data.caster, SF__.BladeOfJustice.ID)
    local EventCenter335 = require("Lib.EventCenter")
    local ad__Damage, ad__Duration, ad__DamagePerSecond = SF__.BladeOfJustice.GetAbilityData(level334)
    EventCenter335.Damage:Emit({whichUnit = data.caster, target = data.target, amount = ad__Damage, attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
    SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(data.caster, 1)
    SF__.BladeOfJustice.New():StartGroudDamage(data.caster, data.target, ad__Damage, ad__Duration, ad__DamagePerSecond)
end

function SF__.BladeOfJustice:StartGroudDamage(caster, target336, ad__Damage337, ad__Duration338, ad__DamagePerSecond339)
    return SF__.CorRun__(function()
        local pos__x340, pos__y341 = SF__.Vector2.FromUnit(target336)
        local UnitAttribute = require("Objects.UnitAttribute")
        local EventCenter346 = require("Lib.EventCenter")
        local eff342 = ExAddSpecialEffect("Abilities/Spells/Orc/LiquidFire/Liquidfire.mdl", pos__x340, pos__y341, ad__Duration338)
        local p343 = GetOwningPlayer(caster)
        do
            local i344 = 0
            while (i344 < ad__Duration338) do
                repeat
                    SF__.CorWait__(1000)
                    ExGroupEnumUnitsInRange(pos__x340, pos__y341, 300, function(u347)
                        if (not IsUnitEnemy(u347, p343)) then
                            return
                        end
                        if ExIsUnitDead(u347) then
                            return
                        end
                        local tarAttr348 = UnitAttribute.GetAttr(u347)
                        local damage349 = (ad__DamagePerSecond339 * (1 - tarAttr348.radiantResistance))
                        EventCenter346.Damage:Emit({whichUnit = caster, target = u347, amount = damage349, attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
                    end)
                until true
                i344 = (i344 + 1)
            end
        end
        DestroyEffect(eff342)
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
function SF__.CrusaderStrike.GetAbilityData(level350)
    return (0.65 + (0.35 * level350)), (0.15 * (level350 - 1))
end

function SF__.CrusaderStrike.Init()
    local EventCenter351 = require("Lib.EventCenter")
    EventCenter351.RegisterPlayerUnitSpellEffect:Emit({id = SF__.CrusaderStrike.ID, handler = SF__.CrusaderStrike.Start})
    ExTriggerRegisterNewUnit(function(u353)
        if (GetUnitTypeId(u353) == FourCC("Hpal")) then
            SF__.CrusaderStrike.UpdateAbilityMeta(u353)
        end
    end)
end

function SF__.CrusaderStrike.UpdateAbilityMeta(u354)
    local p355 = GetOwningPlayer(u354)
    local datas356 = SF__.StdLib.List.New__0()
    do
        local i357 = 0
        while (i357 < 3) do
            repeat
                local __pack_DamageScaling, __pack_ArtOfWarChance = SF__.CrusaderStrike.GetAbilityData((i357 + 1))
                datas356:Add({DamageScaling = __pack_DamageScaling, ArtOfWarChance = __pack_ArtOfWarChance})
            until true
            i357 = (i357 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p355, SF__.CrusaderStrike.ID, "学习十字军打击 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p355, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击造成一次攻击伤害，伤害系数随技能等级提升。产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 6秒\n\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas356:get_Item(0).DamageScaling * 100)), "%|r的攻击伤害。\n|cffffcc002级|r - |cffff8c00", string.format("%.0f", (datas356:get_Item(1).DamageScaling * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas356:get_Item(1).ArtOfWarChance * 100)), "%的战争艺术触发几率。\n|cffffcc003级|r - |cffff8c00", string.format("%.0f", (datas356:get_Item(2).DamageScaling * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas356:get_Item(2).ArtOfWarChance * 100)), "%的战争艺术触发几率。"), 0)
    do
        local i358 = 0
        while (i358 < 3) do
            repeat
                local __unpack_tmp359 = datas356:get_Item(i358)
                local data__DamageScaling, data__ArtOfWarChance = __unpack_tmp359.DamageScaling, __unpack_tmp359.ArtOfWarChance
                SF__.Utils.ExBlzSetAbilityTooltip(p355, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击 - [|cffffcc00", (i358 + 1), "级|r]"), i358)
                SF__.Utils.ExBlzSetAbilityExtendedTooltip(p355, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击造成一次攻击伤害，造成|cffff8c00", string.format("%.0f", (data__DamageScaling * 100)), "%|r的攻击伤害", (function() if (i358 > 0) then return SF__.StrConcat__("，", string.format("%.0f", (data__ArtOfWarChance * 100)), "%的战争艺术触发几率") else return "" end end)(), "。产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 6秒"), i358)
            until true
            i358 = (i358 + 1)
        end
    end
    -- datas.Remove(new IAbilityData { DamageScaling = 0.65f, ArtOfWarChance = 0 });
    datas356:RemoveAt(0)
end

function SF__.CrusaderStrike.Start(data360)
    local level361 = GetUnitAbilityLevel(data360.caster, SF__.CrusaderStrike.ID)
    local UnitAttribute362 = require("Objects.UnitAttribute")
    local EventCenter364 = require("Lib.EventCenter")
    local ad__DamageScaling, ad__ArtOfWarChance = SF__.CrusaderStrike.GetAbilityData(level361)
    local attr = UnitAttribute362.GetAttr(data360.caster)
    local damage363 = (attr:SimAttack(UnitAttribute362.HeroAttributeType.Strength) * ad__DamageScaling)
    EventCenter364.Damage:Emit({whichUnit = data360.caster, target = data360.target, amount = damage363, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
    SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(data360.caster, 1)
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
-- TimerComponent
SF__.TimerComponent = SF__.TimerComponent or {}
SF__.TimerComponent.Name = "TimerComponent"
SF__.TimerComponent.FullName = "TimerComponent"
setmetatable(SF__.TimerComponent, { __index = SF__.Component })
SF__.TimerComponent.__sf_base = SF__.Component
-- <summary>
--
-- </summary>
-- <param name="duration">seconds</param>
-- <param name="onComplete"></param>
--
function SF__.TimerComponent:StartTimer(duration14, onComplete)
    self.duration = (duration14 * 1000)
    self.elapsed = 0
    self.onComplete = onComplete
    self._running = true
end

function SF__.TimerComponent:Update()
    if (not self._running) then
        return
    end
    self.elapsed = (self.elapsed + SF__.Scene.DT)
    if (self.elapsed >= self.duration) then
        -- Timer has completed, trigger an event or callback here
        local delegate15 = self.onComplete
        if (delegate15 ~= nil) then
            delegate15()
        end
        self._running = false
    end
end

function SF__.TimerComponent.__Init(self)
    SF__.Component.__Init(self)
    self.__sf_type = SF__.TimerComponent
    self.duration = (-1)
    self.elapsed = 0
    self.onComplete = nil
    self._running = false
end

function SF__.TimerComponent.New()
    local self = setmetatable({}, { __index = SF__.TimerComponent })
    SF__.TimerComponent.__Init(self)
    return self
end
-- DivineStorm
SF__.DivineStorm = SF__.DivineStorm or {}
SF__.DivineStorm.Name = "DivineStorm"
SF__.DivineStorm.FullName = "DivineStorm"
function SF__.DivineStorm.Init()
    local EventCenter365 = require("Lib.EventCenter")
    EventCenter365.RegisterPlayerUnitSpellChannel:Emit({id = SF__.DivineStorm.ID, handler = SF__.DivineStorm.Check})
    EventCenter365.RegisterPlayerUnitSpellEffect:Emit({id = SF__.DivineStorm.ID, handler = SF__.DivineStorm.Start})
    ExTriggerRegisterNewUnit(function(u367)
        if (GetUnitTypeId(u367) == FourCC("Hpal")) then
            SF__.DivineStorm.UpdateAbilityMeta(u367)
        end
    end)
end

function SF__.DivineStorm.Check(data368)
    local UnitAttribute370 = require("Objects.UnitAttribute")
    local attr369 = UnitAttribute370.GetAttr(data368.caster)
    if (attr369.retPalHolyEnergy < 3) then
        IssueImmediateOrderById(data368.caster, SF__.ConstOrderId.Stop)
        ExTextState(data368.caster, "圣能不足")
    end
end

function SF__.DivineStorm.UpdateAbilityMeta(u371)
    local p372 = GetOwningPlayer(u371)
    SF__.Utils.ExSetAbilityResearchTooltip(p372, SF__.DivineStorm.ID, "学习神圣风暴 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p372, SF__.DivineStorm.ID, "对周围敌人造成200点光辉伤害。消耗|cffff8c003|r点圣能。", 0)
    do
        local i373 = 0
        while (i373 < 1) do
            repeat
                SF__.Utils.ExBlzSetAbilityTooltip(p372, SF__.DivineStorm.ID, SF__.StrConcat__("神圣风暴 - [|cffffcc00", (i373 + 1), "级|r]"), i373)
                SF__.Utils.ExBlzSetAbilityExtendedTooltip(p372, SF__.DivineStorm.ID, "神圣风暴对周围敌人造成200点光辉伤害。消耗|cffff8c003|r点圣能。", i373)
            until true
            i373 = (i373 + 1)
        end
    end
end

function SF__.DivineStorm.Start(data374)
    local pos__x375, pos__y376, pos__z377 = SF__.Vector3.FromUnit(data374.caster)
    local UnitAttribute380 = require("Objects.UnitAttribute")
    local EventCenter381 = require("Lib.EventCenter")
    ExGroupEnumUnitsInRange(pos__x375, pos__y376, 250, function(u382)
        if (not IsUnitEnemy(u382, GetOwningPlayer(data374.caster))) then
            return
        end
        if ExIsUnitDead(u382) then
            return
        end
        local attr383 = UnitAttribute380.GetAttr(u382)
        EventCenter381.Damage:Emit({whichUnit = data374.caster, target = u382, amount = (200 * (1 - attr383.radiantResistance)), attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
    end)
    SF__.RetributionPaladinGlobal.ConsumeHolyEnergy(data374.caster, 3)
    local leviation = SF__.GameObject.New__s("ds_leviation")
    leviation.transform.localPosition__x, leviation.transform.localPosition__y, leviation.transform.localPosition__z = 0, 0, 50
    leviation:AddComponent(SF__.TimerComponent):StartTimer(0.6, function()
        leviation:Destroy()
    end)
    do
        local i384 = (-5)
        while (i384 <= 5) do
            repeat
                if (i384 == 0) then
                    break
                end
                local attach = SF__.GameObject.New__sx13("ds_visual", leviation)
                attach.transform.localPosition__x, attach.transform.localPosition__y, attach.transform.localPosition__z = pos__x375, pos__y376, pos__z377
                attach.transform.localRotation__x, attach.transform.localRotation__y, attach.transform.localRotation__z, attach.transform.localRotation__w = SF__.Quaternion.Euler(0, ((((360 / 5) * math.abs(i384)) - 10) + (20 * math.random())), 0)
                local att = attach:AddComponent(SF__.AutoTRSComponent)
                att.followUnit = data374.caster
                att.rotation__x, att.rotation__y, att.rotation__z, att.rotation__w = SF__.Quaternion.Euler(0, (((math.sign(i384) * ((math.random() * 200) + 700)) * SF__.Scene.DT) / 1000), 0)
                local arm = SF__.GameObject.New__sx13("ds_arm", attach)
                arm.transform.localPosition__x, arm.transform.localPosition__y, arm.transform.localPosition__z = 250, 0, 0
                local effHoly = AddSpecialEffect("Abilities/Weapons/FaerieDragonMissile/FaerieDragonMissile.mdl", pos__x375, pos__y376)
                local effC = arm:AddComponent(SF__.AttachEffectComponent)
                effC:AttachEffect(effHoly)
                effC:LerpIn(700)
            until true
            i384 = (i384 + 1)
        end
    end
end

function SF__.DivineStorm.__Init(self)
    self.__sf_type = SF__.DivineStorm
end

function SF__.DivineStorm.New()
    local self = setmetatable({}, { __index = SF__.DivineStorm })
    SF__.DivineStorm.__Init(self)
    return self
end

SF__.DivineStorm.ID = FourCC("A005")
-- DivineToll
SF__.DivineToll = SF__.DivineToll or {}
SF__.DivineToll.Name = "DivineToll"
SF__.DivineToll.FullName = "DivineToll"
function SF__.DivineToll.GetAbilityData(level385)
    return (2 + level385), (50 * level385), 0.1, 10, (5 + (5 * level385)), 10
end

function SF__.DivineToll.Init()
    local EventCenter388 = require("Lib.EventCenter")
    EventCenter388.RegisterPlayerUnitSpellEffect:Emit({id = SF__.DivineToll.ID, handler = function(data387)
        SF__.DivineToll.Start(data387)
    end})
    ExTriggerRegisterNewUnit(function(u390)
        if (GetUnitTypeId(u390) == FourCC("Hpal")) then
            SF__.DivineToll.UpdateAbilityMeta(u390)
        end
    end)
end

function SF__.DivineToll.UpdateAbilityMeta(u391)
    local p392 = GetOwningPlayer(u391)
    local datas393 = SF__.StdLib.List.New__0()
    do
        local i394 = 0
        while (i394 < 3) do
            repeat
                local __pack_TargetCount, __pack_Damage395, __pack_RadiantDmgAmp, __pack_Duration396, __pack_BHDamage, __pack_DebuffDuration = SF__.DivineToll.GetAbilityData((i394 + 1))
                datas393:Add({TargetCount = __pack_TargetCount, Damage = __pack_Damage395, RadiantDmgAmp = __pack_RadiantDmgAmp, Duration = __pack_Duration396, BHDamage = __pack_BHDamage, DebuffDuration = __pack_DebuffDuration})
            until true
            i394 = (i394 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p392, SF__.DivineToll.ID, "学习圣洁鸣钟 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p392, SF__.DivineToll.ID, SF__.StrConcat__("对附近的多个目标施展审判，造成法术伤害，然后神圣之锤环绕圣殿骑士，每次命中敌人使其受到的光辉伤害提高。每个审判产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 30秒\n\n|cffffcc001级|r - 审判最多|cffff8c00", datas393:get_Item(0).TargetCount, "|r个目标，造成|cffff8c00", datas393:get_Item(0).Damage, "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas393:get_Item(0).RadiantDmgAmp * 100)), "%|r的光辉易伤，持续|cffff8c00", datas393:get_Item(0).Duration, "|r秒。\n|cffffcc002级|r - 审判最多|cffff8c00", datas393:get_Item(1).TargetCount, "|r个目标，造成|cffff8c00", datas393:get_Item(1).Damage, "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas393:get_Item(1).RadiantDmgAmp * 100)), "%|r的光辉易伤，持续|cffff8c00", datas393:get_Item(1).Duration, "|r秒。\n|cffffcc003级|r - 审判最多|cffff8c00", datas393:get_Item(2).TargetCount, "|r个目标，造成|cffff8c00", datas393:get_Item(2).Damage, "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas393:get_Item(2).RadiantDmgAmp * 100)), "%|r的光辉易伤，持续|cffff8c00", datas393:get_Item(2).Duration, "|r秒。"), 0)
    do
        local i397 = 0
        while (i397 < 3) do
            repeat
                local __unpack_tmp400 = datas393:get_Item(i397)
                local data__TargetCount, data__Damage398, data__RadiantDmgAmp, data__Duration399, data__BHDamage, data__DebuffDuration = __unpack_tmp400.TargetCount, __unpack_tmp400.Damage, __unpack_tmp400.RadiantDmgAmp, __unpack_tmp400.Duration, __unpack_tmp400.BHDamage, __unpack_tmp400.DebuffDuration
                SF__.Utils.ExBlzSetAbilityTooltip(p392, SF__.DivineToll.ID, SF__.StrConcat__("圣洁鸣钟 - [|cffffcc00", (i397 + 1), "级|r]"), i397)
                SF__.Utils.ExBlzSetAbilityExtendedTooltip(p392, SF__.DivineToll.ID, SF__.StrConcat__("对附近的最多|cffff8c00", data__TargetCount, "|r个目标施展审判，造成|cffff8c00", data__Damage398, "|r点法术伤害，然后神圣之锤环绕圣殿骑士，每次命中敌人使其受到的光辉伤害提高|cffff8c00", string.format("%.0f", (data__RadiantDmgAmp * 100)), "%|r，持续|cffff8c00", data__Duration399, "|r秒。每个审判产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 30秒"), i397)
            until true
            i397 = (i397 + 1)
        end
    end
end

function SF__.DivineToll.HurlToTarget(caster401, target402, pos__x403, pos__y404, pos__z405)
    local outer = SF__.GameObject.New__s("DivineToll_Outer")
    local EventCenter412 = require("Lib.EventCenter")
    local UnitAttribute418 = require("Objects.UnitAttribute")
    outer.transform.localPosition__x, outer.transform.localPosition__y, outer.transform.localPosition__z = 0, 0, 80
    local moveLayer = SF__.GameObject.New__sx13("MoveLayer", outer)
    moveLayer.transform.localPosition__x, moveLayer.transform.localPosition__y, moveLayer.transform.localPosition__z = pos__x403, pos__y404, pos__z405
    local missile = moveLayer:AddComponent(SF__.Missile)
    missile:SetupUnitTarget(target402, 900, function(mis429, tar430)
        local cPos__x431, cPos__y432, cPos__z433 = mis429.gameObject.transform:get_position()
        local eff434 = ExAddSpecialEffect("Abilities/Spells/Human/StormBolt/StormBoltMissile.mdl", cPos__x431, cPos__y432, 0.1)
        BlzSetSpecialEffectColor(eff434, 255, 255, 0)
        local ad__TargetCount435, ad__Damage436, ad__RadiantDmgAmp437, ad__Duration438, ad__BHDamage439, ad__DebuffDuration440 = SF__.DivineToll.GetAbilityData(GetUnitAbilityLevel(caster401, SF__.DivineToll.ID))
        EventCenter412.Damage:Emit({whichUnit = caster401, target = tar430, amount = ad__Damage436, attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
        SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(caster401, 1)
        -- setup new missile
        mis429:SetupPiercer(function(m449, u450)
            local cPos__x451, cPos__y452, cPos__z453 = m449.gameObject.transform:get_position()
            ExAddSpecialEffectTarget("Abilities/Weapons/FaerieDragonMissile/FaerieDragonMissile.mdl", u450, "origin", 0.1)
            local tarAttr454 = UnitAttribute418.GetAttr(u450)
            local damage455 = (ad__BHDamage439 * (1 - tarAttr454.radiantResistance))
            EventCenter412.Damage:Emit({whichUnit = caster401, target = u450, amount = damage455, attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
            SF__.DivineToll.ApplyDebuff(caster401, u450)
        end, function(u456)
            if (not IsUnitEnemy(u456, GetOwningPlayer(caster401))) then
                return false
            end
            if IsUnitType(u456, UNIT_TYPE_STRUCTURE) then
                return false
            end
            if ExIsUnitDead(u456) then
                return false
            end
            return true
        end, 50, 9999, 0.3)
        -- change movement behaviour
        local aec1457 = moveLayer.transform:Find("DivineToll_Bolt/dt_hand/dt_mis").gameObject:GetComponent(SF__.AttachEffectComponent)
        aec1457:LerpIn(1300)
        local aec2458 = aec1457.gameObject.transform:Find("DivineToll_Holy").gameObject:GetComponent(SF__.AttachEffectComponent)
        aec2458:LerpIn(1300)
        local casterPos__x459, casterPos__y460, casterPos__z461 = SF__.Vector3.FromUnit(caster401)
        local circulator462 = SF__.GameObject.New__sx13("Circulator", outer)
        circulator462.transform.localPosition__x, circulator462.transform.localPosition__y, circulator462.transform.localPosition__z = casterPos__x459, casterPos__y460, casterPos__z461
        local rot463 = circulator462:AddComponent(SF__.AutoTRSComponent)
        rot463.rotation__x, rot463.rotation__y, rot463.rotation__z, rot463.rotation__w = SF__.Quaternion.Euler(0, ((300 * SF__.Scene.DT) / 1000), 0)
        rot463.followUnit = caster401
        moveLayer.transform:SetParent(circulator462.transform)
        moveLayer.transform.localPosition__x, moveLayer.transform.localPosition__y, moveLayer.transform.localPosition__z = 200, 0, 0
        -- set timeout
        local umo464 = SF__.UnitManager.GetGameObjectByUnit(caster401)
        local dtData465 = umo464:GetComponentInChildren(SF__.DivineToll.DivineTollUnitData)
        local dtTimer466
        if (dtData465 == nil) then
            local dtObj467 = SF__.GameObject.New__sx13("DivineTollData", umo464)
            dtData465 = dtObj467:AddComponent(SF__.DivineToll.DivineTollUnitData)
            dtTimer466 = dtObj467:AddComponent(SF__.TimerComponent)
        else
            dtTimer466 = dtData465.gameObject:GetComponent(SF__.TimerComponent)
        end
        dtData465:SetData(outer)
        dtTimer466:StartTimer(ad__Duration438, function()
            dtData465:TimesUp()
        end)
    end)
    missile.onLostTarget = function()
        outer:Destroy()
    end
    local orientationFixLayer = SF__.GameObject.New__sx13("DivineToll_Bolt", moveLayer)
    orientationFixLayer.transform.localRotation__x, orientationFixLayer.transform.localRotation__y, orientationFixLayer.transform.localRotation__z, orientationFixLayer.transform.localRotation__w = SF__.Quaternion.Euler(0, 90, 0)
    local selfRotLayer = SF__.GameObject.New__sx13("dt_hand", orientationFixLayer)
    local receiver = selfRotLayer:AddComponent(SF__.AutoTRSComponent)
    receiver.rotation__x, receiver.rotation__y, receiver.rotation__z, receiver.rotation__w = SF__.Quaternion.Euler(((1800 * SF__.Scene.DT) / 1000), 0, 0)
    local boltMis = SF__.GameObject.New__sx13("dt_mis", selfRotLayer)
    boltMis.transform.localPosition__x, boltMis.transform.localPosition__y, boltMis.transform.localPosition__z = 15, 0, 0
    boltMis.transform.localScale__x, boltMis.transform.localScale__y, boltMis.transform.localScale__z = 0.5, 0.5, 0.5
    local eff468 = AddSpecialEffect("Abilities/Spells/Human/StormBolt/StormBoltMissile.mdl", pos__x403, pos__y404)
    boltMis:AddComponent(SF__.AttachEffectComponent):AttachEffect(eff468)
    local attachedHoly = SF__.GameObject.New__sx13("DivineToll_Holy", boltMis)
    attachedHoly.transform.localPosition__x, attachedHoly.transform.localPosition__y, attachedHoly.transform.localPosition__z = 15, 0, 0
    local effHoly469 = AddSpecialEffect("Abilities/Weapons/FaerieDragonMissile/FaerieDragonMissile.mdl", pos__x403, pos__y404)
    attachedHoly:AddComponent(SF__.AttachEffectComponent):AttachEffect(effHoly469)
    BlzSetSpecialEffectColor(effHoly469, 20, 20, 20)
end

function SF__.DivineToll.Start(data470)
    return SF__.CorRun__(function()
        local pos__x471, pos__y472, pos__z473 = SF__.Vector3.FromUnit(data470.caster)
        local targets = SF__.Utils.CsGroupGetUnitsInRange(pos__x471, pos__y472, 600, function(u474)
            if (not IsUnitEnemy(u474, GetOwningPlayer(data470.caster))) then
                return false
            end
            if IsUnitType(u474, UNIT_TYPE_STRUCTURE) then
                return false
            end
            if ExIsUnitDead(u474) then
                return false
            end
            return true
        end)
        if (targets.Count == 0) then
            return
        end
        targets:Sort(function(a477, b478)
            local distA479 = SF__.Vector3.Distance(pos__x471, pos__y472, pos__z473, SF__.Vector3.FromUnit(a477))
            local distB480 = SF__.Vector3.Distance(pos__x471, pos__y472, pos__z473, SF__.Vector3.FromUnit(b478))
            return (function() if (distA479 == distB480) then return 0 else return (function() if (distA479 < distB480) then return (-1) else return 1 end end)() end end)()
        end)
        do
            local i481 = 0
            while (i481 < (function()
                local field__TargetCount, field__Damage, field__RadiantDmgAmp, field__Duration, field__BHDamage, field__DebuffDuration = SF__.DivineToll.GetAbilityData(GetUnitAbilityLevel(data470.caster, SF__.DivineToll.ID))
                return math.min(targets.Count, field__TargetCount)
            end)()) do
                repeat
                    SF__.DivineToll.HurlToTarget(data470.caster, targets:get_Item(i481), pos__x471, pos__y472, pos__z473)
                    SF__.CorWait__(200)
                until true
                i481 = (i481 + 1)
            end
        end
    end)
end

function SF__.DivineToll.ApplyDebuff(caster482, target483)
    local BuffBase = require("Objects.BuffBase")
    local buff = BuffBase.FindBuffByClassName(target483, "RadiantVulnerability")
    if (buff ~= nil) then
        buff:ResetDuration()
    else
        local ad__TargetCount484, ad__Damage485, ad__RadiantDmgAmp486, ad__Duration487, ad__BHDamage488, ad__DebuffDuration489 = SF__.DivineToll.GetAbilityData(GetUnitAbilityLevel(caster482, SF__.DivineToll.ID))
        SF__.DivineToll.RadiantVulnerability.New(caster482, target483, ad__DebuffDuration489, 99999, {level = 0, charged = 0})
    end
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
-- DivineToll.RadiantVulnerability
local BuffBase490 = require("Objects.BuffBase")
SF__.DivineToll.RadiantVulnerability = SF__.DivineToll.RadiantVulnerability or class("RadiantVulnerability", BuffBase490)
SF__.DivineToll.RadiantVulnerability.Name = "RadiantVulnerability"
SF__.DivineToll.RadiantVulnerability.FullName = "DivineToll.RadiantVulnerability"
SF__.DivineToll.RadiantVulnerability.__sf_base = BuffBase490
function SF__.DivineToll.RadiantVulnerability.__Init(self, caster491, target492, duration493, interval, awakeData)
    self.__sf_type = SF__.DivineToll.RadiantVulnerability
    self._vulVal = 0
end

function SF__.DivineToll.RadiantVulnerability.New(caster491, target492, duration493, interval, awakeData)
    local self = SF__.DivineToll.RadiantVulnerability.new(caster491, target492, duration493, interval, awakeData)
    SF__.DivineToll.RadiantVulnerability.__Init(self, caster491, target492, duration493, interval, awakeData)
    return self
end

function SF__.DivineToll.RadiantVulnerability:Awake()
    local ad__TargetCount494, ad__Damage495, ad__RadiantDmgAmp496, ad__Duration497, ad__BHDamage498, ad__DebuffDuration499 = SF__.DivineToll.GetAbilityData(GetUnitAbilityLevel(self.caster, SF__.DivineToll.ID))
    self._vulVal = ad__RadiantDmgAmp496
end

function SF__.DivineToll.RadiantVulnerability:OnEnable()
    local UnitAttribute501 = require("Objects.UnitAttribute")
    local attr500 = UnitAttribute501.GetAttr(self.target)
    attr500.radiantResistance = (attr500.radiantResistance - self._vulVal)
end

function SF__.DivineToll.RadiantVulnerability:OnDisable()
    local UnitAttribute503 = require("Objects.UnitAttribute")
    local attr502 = UnitAttribute503.GetAttr(self.target)
    attr502.radiantResistance = (attr502.radiantResistance + self._vulVal)
end
-- Missile
SF__.Missile = SF__.Missile or {}
SF__.Missile.Name = "Missile"
SF__.Missile.FullName = "Missile"
setmetatable(SF__.Missile, { __index = SF__.Component })
SF__.Missile.__sf_base = SF__.Component
function SF__.Missile:Update()
    if self.hasArrived then
        return
    end
    -- Move
    local cPos__x, cPos__y, cPos__z = self.gameObject.transform:get_position()
    local tPos__x, tPos__y, tPos__z = self.pointTarget__x, self.pointTarget__y, self.pointTarget__z
    if ((self.targetType == SF__.TargetType.Unit) or (self.targetType == SF__.TargetType.Point)) then
        if (self.targetType == SF__.TargetType.Unit) then
            if ((self.unitTarget == nil) or ExIsUnitDead(self.unitTarget)) then
                self:OnDisappear()
                return
            end
            tPos__x, tPos__y, tPos__z = SF__.Vector3.FromUnit(self.unitTarget)
        end
        if self.lookAtTarget then
            self.gameObject.transform.localRotation__x, self.gameObject.transform.localRotation__y, self.gameObject.transform.localRotation__z, self.gameObject.transform.localRotation__w = SF__.Quaternion.LookRotation__ose(SF__.Vector3.op_Subtraction(tPos__x, tPos__y, tPos__z, cPos__x, cPos__y, cPos__z))
        end
        cPos__x, cPos__y, cPos__z = SF__.Vector3.MoveTowards(cPos__x, cPos__y, cPos__z, tPos__x, tPos__y, tPos__z, ((self.speed * SF__.Scene.DT) / 1000))
        self.gameObject.transform:set_position(cPos__x, cPos__y, cPos__z)
    end
    -- Collision
    local now3 = os.clock()
    if (self.onThrough ~= nil) then
        ExGroupEnumUnitsInRange(cPos__x, cPos__y, self.colliderSize, function(u4)
            if ((self.onThroughFilter ~= nil) and (not self.onThroughFilter(u4))) then
                return
            end
            if (self.collisionCount <= 0) then
                return
            end
            local nhdPass5
            local __ret7, lastHitTime6 = self._hitUnits:TryGetValue(u4)
            if __ret7 then
                nhdPass5 = ((now3 - lastHitTime6) >= self.nextHitDelay)
            else
                nhdPass5 = true
            end
            if (not nhdPass5) then
                return
            end
            self._hitUnits:set_Item(u4, now3)
            self.collisionCount = (self.collisionCount - 1)
            self.onThrough(self, u4)
        end)
    end
    if (self.targetType ~= SF__.TargetType.None) then
        if (SF__.Vector3.Distance(cPos__x, cPos__y, cPos__z, tPos__x, tPos__y, tPos__z) <= 0.001) then
            self.hasArrived = true
            if ((self.onArrivedUnit ~= nil) and (self.targetType == SF__.TargetType.Unit)) then
                self._hitUnits:set_Item(self.unitTarget, now3)
                self.collisionCount = (self.collisionCount - 1)
                self.onArrivedUnit(self, self.unitTarget)
            end
            if ((self.onArrivedPoint ~= nil) and (self.targetType == SF__.TargetType.Point)) then
                self.onArrivedPoint(self, self.pointTarget__x, self.pointTarget__y, self.pointTarget__z)
            end
        end
    end
end

function SF__.Missile:GetInspectorText()
    return SF__.StrConcat__("targetType: ", self.targetType, "\nunitTarget: ", (function() if (self.unitTarget == nil) then return "None" else return GetUnitName(self.unitTarget) end end)(), "\npointTarget: ", SF__.Vector3.ToString(self.pointTarget__x, self.pointTarget__y, self.pointTarget__z), "\nspeed: ", self.speed, "\nlookAtTarget: ", self.lookAtTarget, "\ncolliderSize: ", self.colliderSize, "\nonArrived: ", (function() if (self.onArrivedUnit == nil) then return "None" else return "Set" end end)(), "\nhasArrived: ", self.hasArrived, "\n")
end

function SF__.Missile:SetupUnitTarget(target8, speed, onArrived, colliderSize, lookAtTarget)
    if colliderSize == nil then colliderSize = 32 end
    if lookAtTarget == nil then lookAtTarget = true end
    self.targetType = SF__.TargetType.Unit
    self.unitTarget = target8
    self.speed = speed
    self.lookAtTarget = lookAtTarget
    self.colliderSize = colliderSize
    self.onArrivedUnit = onArrived
    self.hasArrived = false
end

function SF__.Missile:SetupPointTarget(target__x, target__y, target__z, speed9, onArrived10, colliderSize11, lookAtTarget12)
    if colliderSize11 == nil then colliderSize11 = 32 end
    if lookAtTarget12 == nil then lookAtTarget12 = true end
    self.targetType = SF__.TargetType.Point
    self.pointTarget__x, self.pointTarget__y, self.pointTarget__z = target__x, target__y, target__z
    self.speed = speed9
    self.lookAtTarget = lookAtTarget12
    self.colliderSize = colliderSize11
    self.onArrivedPoint = onArrived10
    self.hasArrived = false
end

function SF__.Missile:SetupPiercer(onThrough, onThroughFilter, colliderSize13, collisionCount, nextHitDelay)
    self.targetType = SF__.TargetType.None
    self.unitTarget = nil
    self.colliderSize = colliderSize13
    self.onThrough = onThrough
    self.onThroughFilter = onThroughFilter
    self.collisionCount = collisionCount
    self.nextHitDelay = nextHitDelay
    self.hasArrived = false
end

function SF__.Missile:OnDisappear()
    self.hasArrived = true
    local delegate = self.onLostTarget
    if (delegate ~= nil) then
        delegate()
    end
end

function SF__.Missile.__Init(self)
    SF__.Component.__Init(self)
    self.__sf_type = SF__.Missile
    self.targetType = 0
    self.unitTarget = nil
    self.pointTarget__x = 0
    self.pointTarget__y = 0
    self.pointTarget__z = 0
    self.speed = 0
    self.lookAtTarget = false
    self.colliderSize = 0
    self.onArrivedUnit = nil
    self.onArrivedPoint = nil
    self.onThrough = nil
    self.onThroughFilter = nil
    self.onLostTarget = nil
    self.collisionCount = 1
    -- <summary>
    -- unit: s
    -- The delay between each hit when colliding with the same unit.
    -- Lower this value to hit the same unit multiple times in a short period.
    -- </summary>
    --
    self.nextHitDelay = 9999
    self._hitUnits = SF__.StdLib.Dictionary.New()
    self.hasArrived = true
end

function SF__.Missile.New()
    local self = setmetatable({}, { __index = SF__.Missile })
    SF__.Missile.__Init(self)
    return self
end
-- DivineToll.DivineTollUnitData
SF__.DivineToll.DivineTollUnitData = SF__.DivineToll.DivineTollUnitData or {}
SF__.DivineToll.DivineTollUnitData.Name = "DivineTollUnitData"
SF__.DivineToll.DivineTollUnitData.FullName = "DivineToll.DivineTollUnitData"
setmetatable(SF__.DivineToll.DivineTollUnitData, { __index = SF__.Component })
SF__.DivineToll.DivineTollUnitData.__sf_base = SF__.Component
function SF__.DivineToll.DivineTollUnitData:SetData(missile504)
    self._missiles:Add(missile504)
end

function SF__.DivineToll.DivineTollUnitData:TimesUp()
    do
        local collection11 = self._missiles
        for _, mis505 in (SF__.StdLib.List.IpairsNext)(collection11) do
            repeat
                mis505:Destroy()
            until true
        end
    end
    self._missiles:Clear()
end

function SF__.DivineToll.DivineTollUnitData.__Init(self)
    SF__.Component.__Init(self)
    self.__sf_type = SF__.DivineToll.DivineTollUnitData
    self._missiles = SF__.StdLib.List.New__0()
end

function SF__.DivineToll.DivineTollUnitData.New()
    local self = setmetatable({}, { __index = SF__.DivineToll.DivineTollUnitData })
    SF__.DivineToll.DivineTollUnitData.__Init(self)
    return self
end
-- Easing
SF__.Easing = SF__.Easing or {}
SF__.Easing.Name = "Easing"
SF__.Easing.FullName = "Easing"
function SF__.Easing.Linear(t)
    return t
end

function SF__.Easing.OutQubic(t79)
    return (1 - ((1 - t79) ^ 3))
end

function SF__.Easing.__Init(self)
    self.__sf_type = SF__.Easing
end

function SF__.Easing.New()
    local self = setmetatable({}, { __index = SF__.Easing })
    SF__.Easing.__Init(self)
    return self
end
-- LuaWrapper.CHeroAttributeType
SF__.LuaWrapper.CHeroAttributeType = SF__.LuaWrapper.CHeroAttributeType or {}
SF__.LuaWrapper.CHeroAttributeType.Name = "CHeroAttributeType"
SF__.LuaWrapper.CHeroAttributeType.FullName = "LuaWrapper.CHeroAttributeType"
function SF__.LuaWrapper.CHeroAttributeType.__Init(self)
    self.__sf_type = SF__.LuaWrapper.CHeroAttributeType
    self.Strength = 0
    self.Agility = 0
    self.Intelligent = 0
end

function SF__.LuaWrapper.CHeroAttributeType.New()
    local self = setmetatable({}, { __index = SF__.LuaWrapper.CHeroAttributeType })
    SF__.LuaWrapper.CHeroAttributeType.__Init(self)
    return self
end
-- LuaWrapper.ISpellData
SF__.LuaWrapper.ISpellData = SF__.LuaWrapper.ISpellData or {}
SF__.LuaWrapper.ISpellData.Name = "ISpellData"
SF__.LuaWrapper.ISpellData.FullName = "LuaWrapper.ISpellData"
function SF__.LuaWrapper.ISpellData.__Init(self)
    self.__sf_type = SF__.LuaWrapper.ISpellData
    self.abilityId = 0
    self.caster = nil
    self.target = nil
    self.x = 0
    self.y = 0
    self.item = nil
    self.destructable = nil
    self.finished = false
    self.interrupted = nil
    self._effectDone = false
end

function SF__.LuaWrapper.ISpellData.New()
    local self = setmetatable({}, { __index = SF__.LuaWrapper.ISpellData })
    SF__.LuaWrapper.ISpellData.__Init(self)
    return self
end
-- WakeOfAshes.WakeOfAshesBuff
local BuffBase623 = require("Objects.BuffBase")
SF__.WakeOfAshes.WakeOfAshesBuff = SF__.WakeOfAshes.WakeOfAshesBuff or class("WakeOfAshesBuff", BuffBase623)
SF__.WakeOfAshes.WakeOfAshesBuff.Name = "WakeOfAshesBuff"
SF__.WakeOfAshes.WakeOfAshesBuff.FullName = "WakeOfAshes.WakeOfAshesBuff"
SF__.WakeOfAshes.WakeOfAshesBuff.__sf_base = BuffBase623
function SF__.WakeOfAshes.WakeOfAshesBuff.__Init(self, caster624, target625, duration626, interval627, awakeData628)
    self.__sf_type = SF__.WakeOfAshes.WakeOfAshesBuff
    self._eff = nil
    self._kf = 0
    self._effLooping = false
end

function SF__.WakeOfAshes.WakeOfAshesBuff.New(caster624, target625, duration626, interval627, awakeData628)
    local self = SF__.WakeOfAshes.WakeOfAshesBuff.new(caster624, target625, duration626, interval627, awakeData628)
    SF__.WakeOfAshes.WakeOfAshesBuff.__Init(self, caster624, target625, duration626, interval627, awakeData628)
    return self
end

function SF__.WakeOfAshes.WakeOfAshesBuff:OnEnable()
    return SF__.CorRun__(function()
        SF__.CorWait__(1)
        self._eff = AddSpecialEffectTarget("Abilities/Spells/Human/Resurrect/ResurrectCaster.mdl", self.caster, "origin")
        self._kf = 0
        self._effLooping = true
    end)
end

function SF__.WakeOfAshes.WakeOfAshesBuff:Update()
    self._kf = (self._kf + self.interval)
    if ((self._kf > 0.9) and self._effLooping) then
        BlzSetSpecialEffectTime(self._eff, 0.9)
    end
end

function SF__.WakeOfAshes.WakeOfAshesBuff:OnDisable()
    return SF__.CorRun__(function()
        local BuffBase630 = require("Objects.BuffBase")
        local quickness629 = BuffBase630.FindBuffByClassName(self.target, "QuicknessBuff")
        if (quickness629 ~= nil) then
            quickness629:DecreaseStack(quickness629.stack)
        end
        if (self._eff ~= nil) then
            self._effLooping = false
            SF__.CorWait__(3000)
            DestroyEffect(self._eff)
            self._eff = nil
        end
    end)
end
-- WordOfGlory
SF__.WordOfGlory = SF__.WordOfGlory or {}
SF__.WordOfGlory.Name = "WordOfGlory"
SF__.WordOfGlory.FullName = "WordOfGlory"
function SF__.WordOfGlory.Init()
    local EventCenter638 = require("Lib.EventCenter")
    EventCenter638.RegisterPlayerUnitSpellChannel:Emit({id = SF__.WordOfGlory.ID, handler = SF__.WordOfGlory.Check})
    EventCenter638.RegisterPlayerUnitSpellEffect:Emit({id = SF__.WordOfGlory.ID, handler = SF__.WordOfGlory.Start})
    ExTriggerRegisterNewUnit(function(u640)
        if (GetUnitTypeId(u640) == FourCC("Hpal")) then
            SF__.WordOfGlory.UpdateAbilityMeta(u640)
        end
    end)
end

function SF__.WordOfGlory.Check(data641)
    local UnitAttribute643 = require("Objects.UnitAttribute")
    local attr642 = UnitAttribute643.GetAttr(data641.caster)
    if (attr642.retPalHolyEnergy < 3) then
        IssueImmediateOrderById(data641.caster, SF__.ConstOrderId.Stop)
        ExTextState(data641.caster, "圣能不足")
    end
end

function SF__.WordOfGlory.UpdateAbilityMeta(u644)
    local p645 = GetOwningPlayer(u644)
    SF__.Utils.ExSetAbilityResearchTooltip(p645, SF__.WordOfGlory.ID, "学习荣耀圣令 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p645, SF__.WordOfGlory.ID, "治疗目标300生命。消耗|cffff8c003|r点圣能。", 0)
    do
        local i646 = 0
        while (i646 < 1) do
            repeat
                SF__.Utils.ExBlzSetAbilityTooltip(p645, SF__.WordOfGlory.ID, SF__.StrConcat__("荣耀圣令 - [|cffffcc00", (i646 + 1), "级|r]"), i646)
                SF__.Utils.ExBlzSetAbilityExtendedTooltip(p645, SF__.WordOfGlory.ID, "荣耀圣令治疗目标300生命。消耗|cffff8c003|r点圣能。", i646)
            until true
            i646 = (i646 + 1)
        end
    end
end

function SF__.WordOfGlory.Start(data647)
    local BuffBase649 = require("Objects.BuffBase")
    local EventCenter650 = require("Lib.EventCenter")
    local hasWoa648 = (BuffBase649.FindBuffByClassName(data647.caster, "WakeOfAshesBuff") ~= nil)
    EventCenter650.Heal:Emit({caster = data647.caster, target = data647.target, amount = (300 * (function() if hasWoa648 then return 2 else return 1 end end)())})
    SF__.RetributionPaladinGlobal.ConsumeHolyEnergy(data647.caster, 3)
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
    SF__.DivineStorm.Init()
    SF__.WakeOfAshes.Init()
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
local SystemBase54 = require("System.SystemBase")
SF__.Systems.InspectorSystem = SF__.Systems.InspectorSystem or class("InspectorSystem", SystemBase54)
SF__.Systems.InspectorSystem.Name = "InspectorSystem"
SF__.Systems.InspectorSystem.FullName = "Systems.InspectorSystem"
SF__.Systems.InspectorSystem.__sf_base = SystemBase54
function SF__.Systems.InspectorSystem:Awake()
    self:CreateFrames()
    self:RefreshHierarchy()
    self:SelectFirstVisibleObject()
    self:SetPanelVisible(false)
end

function SF__.Systems.InspectorSystem:Update(dt55)
    if (not self._isVisible) then
        return
    end
    if (self._lastObjectCount ~= SF__.Scene.get_Instance().gameObjs.Count) then
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
        local i56 = 0
        while (i56 < SF__.Systems.InspectorSystem.MaxHierarchyRows) do
            repeat
                self._hierarchyRows:Add(self:CreateHierarchyRow(i56))
            until true
            i56 = (i56 + 1)
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

function SF__.Systems.InspectorSystem:CreateHierarchyRow(index57)
    local y58 = ((-0.061) - (index57 * (SF__.Systems.InspectorSystem.RowHeight + SF__.Systems.InspectorSystem.RowGap)))
    local button = BlzCreateFrameByType("BUTTON", "FdfInspectorHierarchyRow", self._panel, "ScoreScreenTabButtonTemplate", index57)
    BlzFrameSetPoint(button, FRAMEPOINT_TOPLEFT, self._panel, FRAMEPOINT_TOPLEFT, (SF__.Systems.InspectorSystem.Padding * 2), y58)
    BlzFrameSetSize(button, (SF__.Systems.InspectorSystem.LeftWidth - (SF__.Systems.InspectorSystem.Padding * 4)), SF__.Systems.InspectorSystem.RowHeight)
    local label59 = BlzCreateFrameByType("TEXT", "FdfInspectorHierarchyRowText", button, "", index57)
    BlzFrameSetPoint(label59, FRAMEPOINT_TOPLEFT, button, FRAMEPOINT_TOPLEFT, 0.004, (-0.002))
    BlzFrameSetSize(label59, (SF__.Systems.InspectorSystem.LeftWidth - (SF__.Systems.InspectorSystem.Padding * 5)), (SF__.Systems.InspectorSystem.RowHeight - 0.003))
    BlzFrameSetEnable(label59, false)
    BlzFrameSetTextAlignment(label59, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_LEFT)
    BlzFrameSetText(label59, "")
    local row = SF__.Systems.InspectorSystem.HierarchyRow.New(button, label59)
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
    BlzFrameSetText(self._toggleText, (function() if visible then return "X" else return "IN" end end)())
    if visible then
        self:RefreshHierarchy()
        if (self._selectedGameObject == nil) then
            self:SelectFirstVisibleObject()
        end
        self:RefreshInspectorText()
    end
end

function SF__.Systems.InspectorSystem:SelectRow(row60)
    if (row60.gameObject == nil) then
        return
    end
    self._selectedGameObject = row60.gameObject
    self:RefreshHierarchySelection()
    self:RefreshInspectorText()
end

function SF__.Systems.InspectorSystem:SelectFirstVisibleObject()
    self._selectedGameObject = (function() if (self._visibleObjects.Count > 0) then return self._visibleObjects:get_Item(0) else return nil end end)()
    self:RefreshHierarchySelection()
    self:RefreshInspectorText()
end

function SF__.Systems.InspectorSystem:RefreshHierarchy()
    self._visibleObjects:Clear()
    do
        local collection12 = SF__.Scene.get_Instance().gameObjs
        for _, obj61 in (SF__.StdLib.List.IpairsNext)(collection12) do
            repeat
                if (obj61.transform.parent == nil) then
                    self:AddHierarchyObject(obj61, 0)
                end
            until true
        end
    end
    do
        local i62 = 0
        while (i62 < self._hierarchyRows.Count) do
            repeat
                local row63 = self._hierarchyRows:get_Item(i62)
                if (i62 < self._visibleObjects.Count) then
                    local obj64 = self._visibleObjects:get_Item(i62)
                    row63.gameObject = obj64
                    row63.depth = self:GetDepth(obj64)
                    self:SetRowLabel(row63, obj64.name, row63.depth)
                    BlzFrameSetVisible(row63.button, self._isVisible)
                else
                    row63.gameObject = nil
                    BlzFrameSetVisible(row63.button, false)
                end
            until true
            i62 = (i62 + 1)
        end
    end
    BlzFrameSetVisible(self._emptyText, (self._isVisible and (self._visibleObjects.Count == 0)))
    self._lastObjectCount = SF__.Scene.get_Instance().gameObjs.Count
    self:RefreshHierarchySelection()
end

function SF__.Systems.InspectorSystem:AddHierarchyObject(obj65, depth)
    if (self._visibleObjects.Count >= SF__.Systems.InspectorSystem.MaxHierarchyRows) then
        return
    end
    self._visibleObjects:Add(obj65)
    do
        local collection13 = obj65.transform.children
        for _, child66 in (SF__.StdLib.List.IpairsNext)(collection13) do
            repeat
                self:AddHierarchyObject(child66.gameObject, (depth + 1))
            until true
        end
    end
end

function SF__.Systems.InspectorSystem:GetDepth(obj67)
    local depth68 = 0
    local parent69 = obj67.transform.parent
    while (parent69 ~= nil) do
        repeat
            depth68 = (depth68 + 1)
            parent69 = parent69.parent
        until true
    end
    return depth68
end

function SF__.Systems.InspectorSystem:SetRowLabel(row70, text71, depth72)
    BlzFrameClearAllPoints(row70.label)
    BlzFrameSetPoint(row70.label, FRAMEPOINT_TOPLEFT, row70.button, FRAMEPOINT_TOPLEFT, (0.004 + (depth72 * SF__.Systems.InspectorSystem.IndentWidth)), (-0.002))
    BlzFrameSetSize(row70.label, ((SF__.Systems.InspectorSystem.LeftWidth - (SF__.Systems.InspectorSystem.Padding * 5)) - (depth72 * SF__.Systems.InspectorSystem.IndentWidth)), (SF__.Systems.InspectorSystem.RowHeight - 0.003))
    BlzFrameSetText(row70.label, text71)
end

function SF__.Systems.InspectorSystem:RefreshHierarchySelection()
    do
        local collection14 = self._hierarchyRows
        for _, row73 in (SF__.StdLib.List.IpairsNext)(collection14) do
            repeat
                local isSelected = ((row73.gameObject ~= nil) and (row73.gameObject == self._selectedGameObject))
                BlzFrameSetTextColor(row73.label, (function() if isSelected then return BlzConvertColor(255, 255, 220, 80) else return BlzConvertColor(255, 230, 230, 230) end end)())
            until true
        end
    end
end

function SF__.Systems.InspectorSystem:RefreshInspectorText()
    if (self._selectedGameObject == nil) then
        BlzFrameSetText(self._inspectorText, "")
        return
    end
    local text74 = SF__.StrConcat__(self._selectedGameObject.name, "\n")
    do
        local collection15 = self._selectedGameObject:get_components()
        for _, component in (SF__.StdLib.List.IpairsNext)(collection15) do
            repeat
                text74 = SF__.StrConcat__(text74, "\n[", component.__sf_type.Name, "]")
                local inspectorText = component:GetInspectorText()
                if (inspectorText ~= "") then
                    text74 = SF__.StrConcat__(text74, "\n", inspectorText)
                end
            until true
        end
    end
    BlzFrameSetText(self._inspectorText, text74)
end

function SF__.Systems.InspectorSystem:SceneContains(gameObject)
    do
        local collection16 = SF__.Scene.get_Instance().gameObjs
        for _, obj75 in (SF__.StdLib.List.IpairsNext)(collection16) do
            repeat
                if (obj75 == gameObject) then
                    return true
                end
            until true
        end
    end
    return false
end

function SF__.Systems.InspectorSystem.__Init(self)
    self.__sf_type = SF__.Systems.InspectorSystem
    self._hierarchyRows = SF__.StdLib.List.New__0()
    self._visibleObjects = SF__.StdLib.List.New__0()
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
-- Systems.InspectorSystem.HierarchyRow
SF__.Systems.InspectorSystem.HierarchyRow = SF__.Systems.InspectorSystem.HierarchyRow or {}
SF__.Systems.InspectorSystem.HierarchyRow.Name = "HierarchyRow"
SF__.Systems.InspectorSystem.HierarchyRow.FullName = "Systems.InspectorSystem.HierarchyRow"
function SF__.Systems.InspectorSystem.HierarchyRow.__Init(self, button76, label77)
    self.__sf_type = SF__.Systems.InspectorSystem.HierarchyRow
    self.button = nil
    self.label = nil
    self.gameObject = nil
    self.depth = 0
    self.button = button76
    self.label = label77
end

function SF__.Systems.InspectorSystem.HierarchyRow.New(button76, label77)
    local self = setmetatable({}, { __index = SF__.Systems.InspectorSystem.HierarchyRow })
    SF__.Systems.InspectorSystem.HierarchyRow.__Init(self, button76, label77)
    return self
end
-- Systems.MeleeGameSystem
local SystemBase78 = require("System.SystemBase")
SF__.Systems.MeleeGameSystem = SF__.Systems.MeleeGameSystem or class("MeleeGameSystem", SystemBase78)
SF__.Systems.MeleeGameSystem.Name = "MeleeGameSystem"
SF__.Systems.MeleeGameSystem.FullName = "Systems.MeleeGameSystem"
SF__.Systems.MeleeGameSystem.__sf_base = SystemBase78
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
-- UnitManager
SF__.UnitManager = SF__.UnitManager or {}
SF__.UnitManager.Name = "UnitManager"
SF__.UnitManager.FullName = "UnitManager"
setmetatable(SF__.UnitManager, { __index = SF__.Component })
SF__.UnitManager.__sf_base = SF__.Component
function SF__.UnitManager:Awake()
    if (SF__.UnitManager.Instance ~= nil) then
        SF__.UnitManager.Instance.gameObject:Destroy()
    end
    SF__.UnitManager.Instance = self
end

function SF__.UnitManager.GetGameObjectByUnit(u28)
    if (SF__.UnitManager.Instance == nil) then
        error(SF__.StrConcat__("SF__E2e5944b8", "This is weird"))
    end
    local __ret29, obj = SF__.UnitManager.Instance._map:TryGetValue(u28)
    if __ret29 then
        return obj
    end
    local __inc = SF__.UnitManager.unitCounter
    SF__.UnitManager.unitCounter = (SF__.UnitManager.unitCounter + 1)
    obj = SF__.GameObject.New__sx13(SF__.StrConcat__("Unit_", GetUnitName(u28), "_", __inc), SF__.UnitManager.Instance.gameObject)
    SF__.UnitManager.Instance._map:set_Item(u28, obj)
    obj:AddComponent(SF__.AttachUnitComponent):SetUnit(u28)
    return obj
end

function SF__.UnitManager.__Init(self)
    SF__.Component.__Init(self)
    self.__sf_type = SF__.UnitManager
    self._map = SF__.StdLib.Dictionary.New()
end

function SF__.UnitManager.New()
    local self = setmetatable({}, { __index = SF__.UnitManager })
    SF__.UnitManager.__Init(self)
    return self
end

SF__.UnitManager.Instance = nil
SF__.UnitManager.unitCounter = 0
-- Program
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
    local systems = SF__.StdLib.List.New__0()
    systems:Add(require("System.ItemSystem").new())
    systems:Add(require("System.SpellSystem").new())
    systems:Add(require("System.BuffSystem").new())
    systems:Add(require("System.DamageSystem").new())
    systems:Add(require("System.ProjectileSystem").new())
    systems:Add(SF__.Systems.InitAbilitiesSystem.New())
    systems:Add(SF__.Systems.InspectorSystem.New())
    systems:Add(require("System.BuffDisplaySystem").new())
    systems:Add(SF__.Systems.MeleeGameSystem.New())
    do
        local collection17 = systems
        for _, system in (SF__.StdLib.List.IpairsNext)(collection17) do
            repeat
                system:Awake()
            until true
        end
    end
    local group = CreateGroup()
    GroupEnumUnitsInRect(group, bj_mapInitialPlayableArea, Filter(function()
        ExTriggerRegisterNewUnitExec(GetFilterUnit())
        return false
    end))
    DestroyGroup(group)
    do
        local collection18 = systems
        for _, system1 in (SF__.StdLib.List.IpairsNext)(collection18) do
            repeat
                system1:OnEnable()
            until true
        end
    end
    local game = FrameTimer.new(function(dt)
        local now = (MathRound((Time.Time * 100)) * 0.01)
        do
            local collection19 = systems
            for _, system2 in (SF__.StdLib.List.IpairsNext)(collection19) do
                repeat
                    system2:Update(dt, now)
                until true
            end
        end
    end, 1, (-1))
    game:Start()
    SF__.Scene.get_Instance():Run()
    SF__.GameObject.New__s("UnitManager"):AddComponent(SF__.UnitManager)
end

function SF__.Program.__Init(self)
    self.__sf_type = SF__.Program
end

function SF__.Program.New()
    local self = setmetatable({}, { __index = SF__.Program })
    SF__.Program.__Init(self)
    return self
end
-- Stack
SF__.Stack = SF__.Stack or {}
SF__.Stack.Name = "Stack"
SF__.Stack.FullName = "Stack"
function SF__.Stack:Push(item)
    self._items:Add(item)
end

function SF__.Stack:Pop()
    if (self._items.Count == 0) then
        BJDebugMsg("Stack is empty.")
    end
    local item122 = self._items:get_Item((self._items.Count - 1))
    self._items:RemoveAt((self._items.Count - 1))
    return item122
end

function SF__.Stack:Peek()
    if (self._items.Count == 0) then
        BJDebugMsg("Stack is empty.")
    end
    return self._items:get_Item((self._items.Count - 1))
end

function SF__.Stack:get_Count()
    return self._items.Count
end

function SF__.Stack.__Init(self)
    self.__sf_type = SF__.Stack
    self._items = SF__.StdLib.List.New__0()
end

function SF__.Stack.New()
    local self = setmetatable({}, { __index = SF__.Stack })
    SF__.Stack.__Init(self)
    return self
end
-- <summary>
-- A basic dictionary backed by a Lua table with direct key access.
-- C# indexer (dict[key]) maps to direct table field access via get_Item/set_Item.
-- </summary>
--
-- StdLib.Dictionary
SF__.StdLib.Dictionary = SF__.StdLib.Dictionary or {}
SF__.StdLib.Dictionary.Name = "Dictionary"
SF__.StdLib.Dictionary.FullName = "StdLib.Dictionary"
function SF__.StdLib.Dictionary.__Init(self)
    self.__sf_type = SF__.StdLib.Dictionary
    self._table = nil
    self._version = 0
    self._keys = nil
    self.Count = 0
    self._table = {}
    self._keys = SF__.StdLib.List.New__0()
    self._version = 0
    self.Count = 0
end

function SF__.StdLib.Dictionary.New()
    local self = setmetatable({}, { __index = SF__.StdLib.Dictionary })
    SF__.StdLib.Dictionary.__Init(self)
    return self
end

function SF__.StdLib.Dictionary:get_Item(key)
    if (key == nil) then
        error(SF__.StrConcat__("SF__E2e5944b8", "Key cannot be null"))
    end
    return (function()
        local __coalesce = self._table[key]
        if (__coalesce == nil) then
            error(SF__.StrConcat__("SF__E2e5944b8", "Key not found"))
        end
        return __coalesce
    end)()
end

function SF__.StdLib.Dictionary:set_Item(key651, value)
    if (key651 == nil) then
        error(SF__.StrConcat__("SF__E2e5944b8", "Key cannot be null"))
    end
    local existing = self._table[key651]
    self._table[key651] = value
    if (existing == nil) then
        self.Count = (self.Count + 1)
        self._keys:Add(key651)
    end
    self._version = (self._version + 1)
end

function SF__.StdLib.Dictionary:PairsNext()
    local version = self._version
    local index652 = 0
    return function()
        if (version ~= self._version) then
            error(SF__.StrConcat__("SF__E2e5944b8", "Collection was modified"))
        end
        index652 = (index652 + 1)
        if (index652 > self._keys.Count) then
            return nil
        end
        local key653 = self._keys:get_Item((index652 - 1))
        local value654 = self._table[key653]
        return key653, value654
    end
end

function SF__.StdLib.Dictionary:ContainsKey(key655)
    if (key655 == nil) then
        error(SF__.StrConcat__("SF__E2e5944b8", "Key cannot be null"))
    end
    return (self._table[key655] ~= nil)
end

function SF__.StdLib.Dictionary:TryGetValue(key656)
    if (key656 == nil) then
        error(SF__.StrConcat__("SF__E2e5944b8", "Key cannot be null"))
    end
    local result658 = self._table[key656]
    if (result658 ~= nil) then
        value657 = result658
        return true, value657
    end
    value657 = nil
    return false, value657
end

function SF__.StdLib.Dictionary:GetEnumerator()
    return nil
end
SF__.StdLib.Dictionary = SF__.StdLib.Dictionary or {}
-- StdLib.Dictionary.Enumerator
SF__.StdLib.Dictionary.Enumerator = SF__.StdLib.Dictionary.Enumerator or {}
SF__.StdLib.Dictionary.Enumerator.Name = "Enumerator"
SF__.StdLib.Dictionary.Enumerator.FullName = "StdLib.Dictionary.Enumerator"
function SF__.StdLib.Dictionary.Enumerator:get_Current()
    return nil
end

function SF__.StdLib.Dictionary.Enumerator:MoveNext()
    return nil
end

function SF__.StdLib.Dictionary.Enumerator.__Init(self)
    self.__sf_type = SF__.StdLib.Dictionary.Enumerator
end

function SF__.StdLib.Dictionary.Enumerator.New()
    local self = setmetatable({}, { __index = SF__.StdLib.Dictionary.Enumerator })
    SF__.StdLib.Dictionary.Enumerator.__Init(self)
    return self
end
SF__.StdLib.List = SF__.StdLib.List or {}
-- StdLib.List.Enumerator
SF__.StdLib.List.Enumerator = SF__.StdLib.List.Enumerator or {}
SF__.StdLib.List.Enumerator.Name = "Enumerator"
SF__.StdLib.List.Enumerator.FullName = "StdLib.List.Enumerator"
function SF__.StdLib.List.Enumerator:get_Current()
    return nil
end

function SF__.StdLib.List.Enumerator:MoveNext()
    return nil
end

function SF__.StdLib.List.Enumerator.__Init(self)
    self.__sf_type = SF__.StdLib.List.Enumerator
end

function SF__.StdLib.List.Enumerator.New()
    local self = setmetatable({}, { __index = SF__.StdLib.List.Enumerator })
    SF__.StdLib.List.Enumerator.__Init(self)
    return self
end
-- TemplarVerdict
SF__.TemplarVerdict = SF__.TemplarVerdict or {}
SF__.TemplarVerdict.Name = "TemplarVerdict"
SF__.TemplarVerdict.FullName = "TemplarVerdict"
function SF__.TemplarVerdict.GetAbilityData(level555)
    return 2.25, 0.3, 0.15
end

function SF__.TemplarVerdict.Init()
    local EventCenter556 = require("Lib.EventCenter")
    EventCenter556.RegisterPlayerUnitSpellChannel:Emit({id = SF__.TemplarVerdict.ID, handler = SF__.TemplarVerdict.Check})
    EventCenter556.RegisterPlayerUnitSpellEffect:Emit({id = SF__.TemplarVerdict.ID, handler = SF__.TemplarVerdict.Start})
    ExTriggerRegisterNewUnit(function(u558)
        if (GetUnitTypeId(u558) == FourCC("Hpal")) then
            SF__.TemplarVerdict.UpdateAbilityMeta(u558)
        end
    end)
end

function SF__.TemplarVerdict.Check(data559)
    local UnitAttribute561 = require("Objects.UnitAttribute")
    local attr560 = UnitAttribute561.GetAttr(data559.caster)
    if (attr560.retPalHolyEnergy < 3) then
        IssueImmediateOrderById(data559.caster, SF__.ConstOrderId.Stop)
        ExTextState(data559.caster, "圣能不足")
    end
end

function SF__.TemplarVerdict.UpdateAbilityMeta(u562)
    local p563 = GetOwningPlayer(u562)
    local datas564 = SF__.StdLib.List.New__0()
    do
        local i565 = 0
        while (i565 < 1) do
            repeat
                local __pack_DamageScaling566, __pack_JudgementDamageScaling, __pack_ChanceToResetJudgement = SF__.TemplarVerdict.GetAbilityData((i565 + 1))
                datas564:Add({DamageScaling = __pack_DamageScaling566, JudgementDamageScaling = __pack_JudgementDamageScaling, ChanceToResetJudgement = __pack_ChanceToResetJudgement})
            until true
            i565 = (i565 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p563, SF__.TemplarVerdict.ID, "学习圣殿骑士的裁决 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p563, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决造成一次攻击伤害，如果目标被审判，造成30%的额外伤害，15%几率重置审判。消耗|cffff8c003|r点圣能。\n\n|cff99ccff冷却时间|r - 5秒\n\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas564:get_Item(0).JudgementDamageScaling * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas564:get_Item(0).ChanceToResetJudgement * 100)), "%的战争艺术触发几率。"), 0)
    do
        local i567 = 0
        while (i567 < 1) do
            repeat
                local __unpack_tmp569 = datas564:get_Item(i567)
                local data__DamageScaling568, data__JudgementDamageScaling, data__ChanceToResetJudgement = __unpack_tmp569.DamageScaling, __unpack_tmp569.JudgementDamageScaling, __unpack_tmp569.ChanceToResetJudgement
                SF__.Utils.ExBlzSetAbilityTooltip(p563, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决 - [|cffffcc00", (i567 + 1), "级|r]"), i567)
                SF__.Utils.ExBlzSetAbilityExtendedTooltip(p563, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决造成一次攻击伤害，造成|cffff8c00", string.format("%.0f", (data__DamageScaling568 * 100)), "%|r的攻击伤害。消耗|cffff8c003|r点圣能。\n\n|cff99ccff冷却时间|r - 5秒"), i567)
            until true
            i567 = (i567 + 1)
        end
    end
end

function SF__.TemplarVerdict.Start(data570)
    local level571 = GetUnitAbilityLevel(data570.caster, SF__.TemplarVerdict.ID)
    local UnitAttribute574 = require("Objects.UnitAttribute")
    local EventCenter576 = require("Lib.EventCenter")
    local ad__DamageScaling572, ad__JudgementDamageScaling, ad__ChanceToResetJudgement = SF__.TemplarVerdict.GetAbilityData(level571)
    local attr573 = UnitAttribute574.GetAttr(data570.caster)
    local damage575 = (attr573:SimAttack(UnitAttribute574.HeroAttributeType.Strength) * ad__DamageScaling572)
    EventCenter576.Damage:Emit({whichUnit = data570.caster, target = data570.target, amount = damage575, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_SLICE, outResult = {}})
    SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(data570.caster, 1)
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

function SF__.Vector2.Dot(a__x138, a__y139, b__x140, b__y141)
    return ((a__x138 * b__x140) + (a__y139 * b__y141))
end

function SF__.Vector2.Cross(a__x142, a__y143, b__x144, b__y145)
    return ((a__y143 * b__x144) - (a__x142 * b__y145))
end

function SF__.Vector2.op_UnaryNegation(a__x146, a__y147)
    return (-a__x146), (-a__y147)
end

function SF__.Vector2.op_Addition(a__x148, a__y149, b__x150, b__y151)
    return (a__x148 + b__x150), (a__y149 + b__y151)
end

function SF__.Vector2.op_Subtraction(a__x152, a__y153, b__x154, b__y155)
    return (a__x152 - b__x154), (a__y153 - b__y155)
end

function SF__.Vector2.op_Multiply__ahdf(v__x156, v__y157, f)
    return (v__x156 * f), (v__y157 * f)
end

function SF__.Vector2.op_Multiply__fahd(f158, v__x159, v__y160)
    return (v__x159 * f158), (v__y160 * f158)
end

function SF__.Vector2.op_Division(v__x161, v__y162, f163)
    return (v__x161 / f163), (v__y162 / f163)
end

function SF__.Vector2.UnitDistance(a, b)
    local v1__x, v1__y = SF__.Vector2.FromUnit(a)
    local v2__x, v2__y = SF__.Vector2.FromUnit(b)
    return SF__.Vector2.get_Magnitude(SF__.Vector2.op_Subtraction(v1__x, v1__y, v2__x, v2__y))
end

function SF__.Vector2.SqrUnitDistance(a164, b165)
    local v1__x166, v1__y167 = SF__.Vector2.FromUnit(a164)
    local v2__x168, v2__y169 = SF__.Vector2.FromUnit(b165)
    return SF__.Vector2.get_SqrMagnitude(SF__.Vector2.op_Subtraction(v1__x166, v1__y167, v2__x168, v2__y169))
end

function SF__.Vector2.FromUnit(u170)
    return GetUnitX(u170), GetUnitY(u170)
end

function SF__.Vector2.get_Magnitude(self__x171, self__y172)
    return math.sqrt(SF__.Vector2.get_SqrMagnitude(self__x171, self__y172))
end

function SF__.Vector2.get_SqrMagnitude(self__x173, self__y174)
    return ((self__x173 * self__x173) + (self__y174 * self__y174))
end

function SF__.Vector2.get_Normalized(self__x175, self__y176)
    local mag = SF__.Vector2.get_Magnitude(self__x175, self__y176)
    if (mag < 0.0001) then
        return SF__.Vector2.get_Zero()
    end
    return SF__.Vector2.op_Division(self__x175, self__y176, mag)
end

function SF__.Vector2.ClampMagnitude(self__x179, self__y180, mag181)
    return (function()
        local v__x182, v__y183 = SF__.Vector2.get_Normalized(self__x179, self__y180)
        return SF__.Vector2.op_Multiply__ahdf(v__x182, v__y183, mag181)
    end)()
end

function SF__.Vector2.ToString(self__x184, self__y185)
    return SF__.StrConcat__("(", self__x184, ", ", self__y185, ")")
end

function SF__.Vector2.Rotate(self__x186, self__y187, angle188)
    local cos = math.cos(angle188)
    local sin = math.sin(angle188)
    return ((self__x186 * cos) - (self__y187 * sin)), ((self__x186 * sin) + (self__y187 * cos))
end

function SF__.Vector2.UnitMoveTo(self__x189, self__y190, u191)
    SetUnitX(u191, self__x189)
    SetUnitY(u191, self__y190)
end

function SF__.Vector2.GetTerrainZ(self__x192, self__y193)
    MoveLocation(SF__.Vector2._loc, self__x192, self__y193)
    return GetLocationZ(SF__.Vector2._loc)
end

SF__.Vector2._loc = Location(0, 0)

SF__.Program.Main()
end}

require("Main")
end
--sf-builder:000215604/74ca05744daa0fa6
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

function CreateBuildingsForPlayer1()
local p = Player(1)
local u
local unitID
local t
local life

u = BlzCreateUnitWithSkin(p, FourCC("e000"), 760.3, -2429.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 888.3, -2429.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 824.3, -2429.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 952.3, -2429.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 760.3, -2493.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 824.3, -2493.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 888.3, -2493.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 952.3, -2493.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 760.3, -2557.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 824.3, -2557.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 888.3, -2557.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 952.3, -2557.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 760.3, -2621.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 824.3, -2621.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 888.3, -2621.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 952.3, -2621.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1016.3, -2429.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1080.3, -2429.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1144.3, -2429.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1208.3, -2429.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1016.3, -2493.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1080.3, -2493.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1144.3, -2493.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1208.3, -2493.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1016.3, -2557.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1080.3, -2557.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1144.3, -2557.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1208.3, -2557.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1016.3, -2621.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1080.3, -2621.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1144.3, -2621.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1208.3, -2621.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 760.3, -2685.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 824.3, -2685.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 888.3, -2685.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 952.3, -2685.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 760.3, -2749.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 824.3, -2749.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 888.3, -2749.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 952.3, -2749.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 760.3, -2813.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 824.3, -2813.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 888.3, -2813.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 952.3, -2813.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 760.3, -2877.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 824.3, -2877.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 888.3, -2877.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 952.3, -2877.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1016.3, -2685.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1080.3, -2685.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1144.3, -2685.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1208.3, -2685.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1016.3, -2749.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1080.3, -2749.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1144.3, -2749.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1208.3, -2749.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1016.3, -2813.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1080.3, -2813.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1144.3, -2813.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1208.3, -2813.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1016.3, -2877.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1080.3, -2877.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1144.3, -2877.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1208.3, -2877.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1272.3, -2429.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1336.3, -2429.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1400.3, -2429.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1464.3, -2429.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1272.3, -2493.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1336.3, -2493.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1400.3, -2493.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1464.3, -2493.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1272.3, -2557.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1336.3, -2557.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1400.3, -2557.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1464.3, -2557.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1272.3, -2621.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1336.3, -2621.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1400.3, -2621.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1464.3, -2621.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1528.3, -2429.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1592.3, -2429.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1656.3, -2429.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1720.3, -2429.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1528.3, -2493.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1592.3, -2493.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1656.3, -2493.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1720.3, -2493.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1528.3, -2557.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1592.3, -2557.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1656.3, -2557.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1720.3, -2557.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1528.3, -2621.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1592.3, -2621.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1656.3, -2621.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1720.3, -2621.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1272.3, -2685.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1336.3, -2685.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1400.3, -2685.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1464.3, -2685.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1272.3, -2749.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1336.3, -2749.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1400.3, -2749.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1464.3, -2749.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1272.3, -2813.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1336.3, -2813.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1400.3, -2813.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1464.3, -2813.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1272.3, -2877.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1336.3, -2877.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1400.3, -2877.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1464.3, -2877.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1528.3, -2685.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1592.3, -2685.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1656.3, -2685.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1720.3, -2685.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1528.3, -2749.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1592.3, -2749.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1656.3, -2749.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1720.3, -2749.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1528.3, -2813.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1592.3, -2813.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1656.3, -2813.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1720.3, -2813.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1528.3, -2877.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1592.3, -2877.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1656.3, -2877.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1720.3, -2877.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 760.3, -2941.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 824.3, -2941.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 888.3, -2941.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 952.3, -2941.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 760.3, -3005.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 824.3, -3005.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 888.3, -3005.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 952.3, -3005.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 760.3, -3069.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 824.3, -3069.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 888.3, -3069.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 952.3, -3069.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 760.3, -3133.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 824.3, -3133.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 888.3, -3133.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 952.3, -3133.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1016.3, -2941.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1080.3, -2941.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1144.3, -2941.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1208.3, -2941.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1016.3, -3005.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1080.3, -3005.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1144.3, -3005.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1208.3, -3005.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1016.3, -3069.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1080.3, -3069.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1144.3, -3069.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1208.3, -3069.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1016.3, -3133.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1080.3, -3133.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1144.3, -3133.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1208.3, -3133.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 760.3, -3197.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 824.3, -3197.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 888.3, -3197.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 952.3, -3197.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 760.3, -3261.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 824.3, -3261.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 888.3, -3261.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 952.3, -3261.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 760.3, -3325.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 824.3, -3325.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 888.3, -3325.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 952.3, -3325.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 760.3, -3389.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 824.3, -3389.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 888.3, -3389.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 952.3, -3389.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1016.3, -3197.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1080.3, -3197.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1144.3, -3197.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1208.3, -3197.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1016.3, -3261.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1080.3, -3261.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1144.3, -3261.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1208.3, -3261.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1016.3, -3325.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1080.3, -3325.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1144.3, -3325.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1208.3, -3325.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1016.3, -3389.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1080.3, -3389.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1144.3, -3389.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1208.3, -3389.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1272.3, -2941.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1336.3, -2941.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1400.3, -2941.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1464.3, -2941.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1272.3, -3005.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1336.3, -3005.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1400.3, -3005.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1464.3, -3005.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1272.3, -3069.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1336.3, -3069.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1400.3, -3069.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1464.3, -3069.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1272.3, -3133.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1336.3, -3133.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1400.3, -3133.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1464.3, -3133.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1528.3, -2941.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1592.3, -2941.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1656.3, -2941.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1720.3, -2941.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1528.3, -3005.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1592.3, -3005.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1656.3, -3005.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1720.3, -3005.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1528.3, -3069.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1592.3, -3069.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1656.3, -3069.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1720.3, -3069.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1528.3, -3133.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1592.3, -3133.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1656.3, -3133.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1720.3, -3133.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1272.3, -3197.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1336.3, -3197.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1400.3, -3197.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1464.3, -3197.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1272.3, -3261.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1336.3, -3261.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1400.3, -3261.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1464.3, -3261.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1272.3, -3325.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1336.3, -3325.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1400.3, -3325.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1464.3, -3325.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1272.3, -3389.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1336.3, -3389.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1400.3, -3389.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1464.3, -3389.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1528.3, -3197.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1592.3, -3197.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1656.3, -3197.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1720.3, -3197.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1528.3, -3261.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1592.3, -3261.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1656.3, -3261.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1720.3, -3261.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1528.3, -3325.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1592.3, -3325.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1656.3, -3325.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1720.3, -3325.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1528.3, -3389.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1592.3, -3389.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1656.3, -3389.9, 350.820, FourCC("e000"))
u = BlzCreateUnitWithSkin(p, FourCC("e000"), 1720.3, -3389.9, 350.820, FourCC("e000"))
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
CreateBuildingsForPlayer1()
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
    local s, m = xpcall(SF__Bundle, SF__BundleError__)
    if not s then
        error(m)
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

