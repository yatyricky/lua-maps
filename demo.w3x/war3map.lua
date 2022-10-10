--lua-bundler:000029750
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

__modules["Ability.DeathGrip"]={loader=function()
local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local Const = require("Config.Const")
local Vector2 = require("Lib.Vector2")
local Utils = require("Lib.Utils")
local BuffBase = require("Buff.BuffBase")
local Timer = require("Lib.Timer")

---@class SlowDebuff : BuffBase
local SlowDebuff = class("SlowDebuff", BuffBase)

function SlowDebuff:ctor(caster, target, duration, interval)
    SlowDebuff.super.ctor(self, caster, target, duration, interval)
end

function SlowDebuff:OnEnable()
    SetUnitMoveSpeed(self.target, 0)
end

function SlowDebuff:OnDisable()
    SetUnitMoveSpeed(self.target, GetUnitDefaultMoveSpeed(self.target))
end

local StepLen = 16

local cls = class("DeathGrip")

function cls:ctor(caster, target)
    IssueImmediateOrderById(target, Const.OrderId_Stop)
    PauseUnit(target, true)

    local v1 = Vector2.FromUnit(caster)
    local v2 = Vector2.FromUnit(target)
    local norm = v2 - v1
    local totalLen = norm:GetMagnitude()
    norm:SetNormalize()
    local travelled = 0
    local dest = (norm * 96):Add(v1)
    totalLen = totalLen - 96
    Utils.SetUnitFlyable(target)
    local originalHeight = GetUnitFlyHeight(target)
    local lightning = AddLightningEx("SPLK", false,
            v2.x, v2.y, BlzGetUnitZ(target) + originalHeight,
            v1.x, v1.y, 0)
    SetUnitPathing(target, false)
    SetLightningColor(lightning, 0.5, 0, 0.5, 1)

    local sfxPos = (norm * 150):Add(v1)
    local sfx = AddSpecialEffect("Abilities/Spells/Undead/UndeadMine/UndeadMineCircle.mdl", sfxPos.x, sfxPos.y)
    BlzSetSpecialEffectScale(sfx, 1.3)
    BlzSetSpecialEffectColor(sfx, 128, 0, 128)
    BlzSetSpecialEffectYaw(sfx, math.atan2(norm.y, norm.x))

    coroutine.start(function()
        while true do
            coroutine.step()
            v2:MoveToUnit(target)
            local dir = dest - v2
            dir:SetLength(StepLen):Add(v2):UnitMoveTo(target)
            travelled = travelled + StepLen
            local height = math.bezier3(math.clamp01(travelled / totalLen), 0, totalLen, 0)
            SetUnitFlyHeight(target, height, 0)
            MoveLightningEx(lightning, false,
                    dir.x, dir.y, BlzGetUnitZ(target) + GetUnitFlyHeight(target),
                    dest.x, dest.y, 0)
            if dir:Sub(dest):GetMagnitude() < 96 then
                break
            end
        end

        DestroyLightning(lightning)
        SetUnitFlyHeight(target, originalHeight, 0)
        PauseUnit(target, false)
        SetUnitPathing(target, true)

        local impact = AddSpecialEffectTarget("Abilities/Spells/Undead/AnimateDead/AnimateDeadTarget.mdl", target, "origin")
        local impactTimer = Timer.new(function()
            DestroyEffect(impact)
        end, 2, 1)
        impactTimer:Start()

        local duration = IsUnitType(target, UNIT_TYPE_HERO) and 2 or 4
        SlowDebuff.new(caster, target, duration, 999)

        coroutine.wait(duration - 1)
        DestroyEffect(sfx)
    end)
end

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Abilities.DeathGrip.ID,
    ---@param data ISpellData
    handler = function(data)
        cls.new(data.caster, data.target)
    end
})

return cls

end}

__modules["Buff.BuffBase"]={loader=function()
local EventCenter = require("Lib.EventCenter")
local Time = require("Lib.Time")

---@class BuffBase
local cls = class("BuffBase")

---@param caster unit
---@param target unit
---@param duration real
---@param interval real
function cls:ctor(caster, target, duration, interval)
    self.caster = caster
    self.target = target
    self.time = Time.Time
    self.expire = self.time + duration
    self.duration = duration
    self.interval = interval
    self.nextUpdate = self.time + interval
    EventCenter.NewBuff:Emit(self)
end

function cls:OnEnable()
end

function cls:Update()
end

function cls:OnDisable()
end

return cls

end}

__modules["Config.Abilities"]={loader=function()
local cls = {}

cls.DeathGrip = {
    ID = FourCC("A000")
}

return cls

end}

__modules["Config.Const"]={loader=function()
local cls = {}

cls.OrderId_Stop = 851972

return cls

end}

__modules["Lib.class"]={loader=function()
require("Lib.clone")

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
                timer:Stop()
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
            timer:Stop()
            print(msg)
        end
    end

    timer = Timer.new(action, t, 1)
    c2t[c] = timer
    timer:Start()
    c_yield()
end

function coroutine.step(t)
    local c = c_running()
    local timer

    local function action()
        c2t[c] = nil

        local success, msg = c_resume(c)
        if not success then
            timer:Stop()
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

function cls:_update(_)
    if not self.running then
        return
    end

    self.frames = self.frames - 1
    if self.frames <= 0 then
        local s, m = pcall(self.func)
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
    return c1 * t1 * t1  + c2 * 2 * t1 * t  + c3 * t * t
end

math.clamp = function(value, min, max)
    return math.min(math.max(min, value), max)
end

math.clamp01 = function(value)
    return math.clamp(value, 0, 1)
end

math.atan2 = Atan2

end}

__modules["Lib.TableExt"]={loader=function()
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

end}

__modules["Lib.Time"]={loader=function()
local FrameBegin = require("Lib.EventCenter").FrameBegin

local cls = {}

cls.Time = 0
cls.Frame = 0
cls.Delta = 1 / 30

FrameBegin:On(cls, function(_, dt)
    local f = cls.Frame + 1
    cls.Frame = f
    cls.Time = f * dt
end)

return cls

end}

__modules["Lib.Timer"]={loader=function()
local FrameUpdate = require("Lib.EventCenter").FrameUpdate
require("Lib.MathExt")

local cls = class("Timer")

function cls:ctor(func, duration, loops)
    self.func = func
    self.duration = duration
    self.loops = loops

    self.time = duration
    self.running = false
end

function cls:Start()
    if self.loops == 0 then
        return
    end

    self.running = true
    FrameUpdate:On(self, cls._update)
end

function cls:Stop()
    self.running = false
    FrameUpdate:Off(self, cls._update)
end

function cls:_update(dt)
    if not self.running then
        return
    end

    self.time = self.time - dt
    if self.time <= 0.00001 then
        self.func()

        if self.loops > 0 then
            self.loops = self.loops - 1
            if self.loops == 0 then
                self:Stop()
                return
            end
        end
        self.time = self.time + self.duration
    end
end

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

__modules["Lib.Vector2"]={loader=function()
local setmetatable = setmetatable
local type = type
local rawget = rawget
local m_sqrt = math.sqrt

local GetUnitX = GetUnitX
local GetUnitY = GetUnitY

---@class Vector2
local cls = {}

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
    local magnitude = self:GetMagnitude()

    if magnitude > 1e-05 then
        self.x = self.x / magnitude
        self.y = self.y / magnitude
    else
        self.x = 0
        self.y = 0
    end

    return self
end

function cls:SetLength(len)
    self:SetNormalize():Mul(len)
    return self
end

function cls:GetMagnitude()
    return m_sqrt(self.x * self.x + self.y * self.y)
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

__modules["Main"]={loader=function()
local EventCenter = require("Lib.EventCenter")
local FrameBegin = EventCenter.FrameBegin
local FrameUpdate = EventCenter.FrameUpdate
local Timer = require("Lib.Timer")
local FrameTimer = require("Lib.FrameTimer")
local Time = require("Lib.Time")
local Utils = require("Lib.Utils")
require("Lib.CoroutineExt")

local ipairs = ipairs
local pcall = pcall

local _native_TriggerAddAction = TriggerAddAction

function TriggerAddAction(trigger, action)
    _native_TriggerAddAction(trigger, function()
        local s, m = pcall(action)
        if not s then
            print(m)
        end
    end)
end

-- main loop
local dt = Time.Delta
TimerStart(CreateTimer(), dt, true, function()
    FrameBegin:Emit(dt)
    FrameUpdate:Emit(dt)
end)

-- main logic

-- game machine

---@type SystemBase[]
local systems = {
    require("System.ItemSystem").new(),
    require("System.SpellSystem").new(),
    require("System.MeleeGameSystem").new(),
    require("System.BuffSystem").new(),

    require("System.InitAbilitiesSystem").new(),
}

for _, system in ipairs(systems) do
    system:Awake()
end

for _, system in ipairs(systems) do
    system:OnEnable()
end

local game = FrameTimer.new(function()
    for _, system in ipairs(systems) do
        system:Update(dt)
    end
end, 1, -1)
game:Start()

end}

__modules["System.BuffSystem"]={loader=function()
local EventCenter = require("Lib.EventCenter")
local Event = require("Lib.Event")
local SystemBase = require("System.SystemBase")

EventCenter.NewBuff = Event.new()

---@class BuffSystem : SystemBase
local cls = class("BuffSystem", SystemBase)

function cls:ctor()
    EventCenter.NewBuff:On(self, cls.onNewBuff)
    self.buffs = {} ---@type BuffBase[]
end

function cls:Update(dt)
    local toRemove = {}
    for i, buff in ipairs(self.buffs) do
        local time = buff.time + dt
        buff.time = time
        if time > buff.expire then
            table.insert(toRemove, i)
        else
            if time >= buff.nextUpdate then
                buff:Update()
                buff.nextUpdate = buff.nextUpdate + buff.interval
            end
            if time == buff.expire then
                table.insert(toRemove, i)
            end
        end
    end

    for i = #toRemove, 1, -1 do
        local removed = table.remove(self.buffs, toRemove[i])
        removed:OnDisable()
    end
end

---@param buff BuffBase
function cls:onNewBuff(buff)
    table.insert(self.buffs, buff)
    buff:OnEnable()
end

return cls

end}

__modules["System.InitAbilitiesSystem"]={loader=function()
local SystemBase = require("System.SystemBase")

---@class InitAbilitiesSystem : SystemBase
local cls = class("InitAbilitiesSystem", SystemBase)

function cls:Awake()
    require("Ability.DeathGrip")
end

return cls

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
    TriggerAddAction(trigger, function()
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

    self._recipes = {} ---@type table<item, table<item, integer>[]> key=result, key2=ingredient value2=ingredient count
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

__modules["System.MeleeGameSystem"]={loader=function()
local SystemBase = require("System.SystemBase")

---@class MeleeGameSystem : SystemBase
local cls = class("MeleeGameSystem", SystemBase)

function cls:ctor()
    MeleeStartingVisibility()
    MeleeStartingHeroLimit()
    MeleeGrantHeroItems()
    MeleeStartingResources()
    MeleeClearExcessUnits()
    MeleeStartingUnits()
    MeleeStartingAI()
    MeleeInitVictoryDefeat()
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
    TriggerAddAction(trigger, callback)
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

__modules["Main"].loader()
end
--lua-bundler:000029750

function InitGlobals()
end

function CreateAllItems()
local itemID

BlzCreateItemWithSkin(FourCC("rlif"), -883.4, -107.4, FourCC("rlif"))
end

function CreateUnitsForPlayer0()
local p = Player(0)
local u
local unitID
local t
local life

u = BlzCreateUnitWithSkin(p, FourCC("hdhw"), -1148.7, 2131.6, 206.714, FourCC("hdhw"))
u = BlzCreateUnitWithSkin(p, FourCC("Hpal"), -1089.7, 0.0, 332.300, FourCC("Hpal"))
SetHeroLevel(u, 10, false)
u = BlzCreateUnitWithSkin(p, FourCC("hmpr"), -1225.0, 1133.3, 337.620, FourCC("hmpr"))
u = BlzCreateUnitWithSkin(p, FourCC("hmpr"), -1178.5, 1035.4, 79.038, FourCC("hmpr"))
u = BlzCreateUnitWithSkin(p, FourCC("hmpr"), -1146.8, 945.0, 66.030, FourCC("hmpr"))
u = BlzCreateUnitWithSkin(p, FourCC("hmpr"), -1130.9, 881.8, 124.600, FourCC("hmpr"))
u = BlzCreateUnitWithSkin(p, FourCC("hmpr"), -1126.4, 833.9, 30.587, FourCC("hmpr"))
u = BlzCreateUnitWithSkin(p, FourCC("Udea"), -1174.0, -187.4, 341.390, FourCC("Udea"))
SetHeroLevel(u, 10, false)
end

function CreateUnitsForPlayer1()
local p = Player(1)
local u
local unitID
local t
local life

u = BlzCreateUnitWithSkin(p, FourCC("hdhw"), 575.0, 1840.7, 329.930, FourCC("hdhw"))
u = BlzCreateUnitWithSkin(p, FourCC("hdhw"), 610.6, 1663.4, 329.930, FourCC("hdhw"))
u = BlzCreateUnitWithSkin(p, FourCC("hdhw"), 546.8, 2092.4, 128.412, FourCC("hdhw"))
u = BlzCreateUnitWithSkin(p, FourCC("hdhw"), 467.6, 2247.5, 254.418, FourCC("hdhw"))
u = BlzCreateUnitWithSkin(p, FourCC("hdhw"), 277.7, 2330.8, 142.189, FourCC("hdhw"))
u = BlzCreateUnitWithSkin(p, FourCC("hdhw"), 592.6, 1513.6, 79.313, FourCC("hdhw"))
u = BlzCreateUnitWithSkin(p, FourCC("hdhw"), 429.5, 1424.9, 97.000, FourCC("hdhw"))
u = BlzCreateUnitWithSkin(p, FourCC("ogru"), -14.4, -58.7, 77.379, FourCC("ogru"))
u = BlzCreateUnitWithSkin(p, FourCC("ogru"), 16.4, -244.9, 9.306, FourCC("ogru"))
u = BlzCreateUnitWithSkin(p, FourCC("ogru"), 145.3, 17.0, 227.138, FourCC("ogru"))
end

function CreateNeutralPassiveBuildings()
local p = Player(PLAYER_NEUTRAL_PASSIVE)
local u
local unitID
local t
local life

u = BlzCreateUnitWithSkin(p, FourCC("ngol"), -2560.0, 320.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), 2880.0, 640.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), -192.0, 2368.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), 512.0, -3264.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
end

function CreatePlayerBuildings()
end

function CreatePlayerUnits()
CreateUnitsForPlayer0()
CreateUnitsForPlayer1()
end

function CreateAllUnits()
CreateNeutralPassiveBuildings()
CreatePlayerBuildings()
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
SetPlayerController(Player(1), MAP_CONTROL_COMPUTER)
end

function InitCustomTeams()
SetPlayerTeam(Player(0), 0)
SetPlayerTeam(Player(1), 1)
end

function InitAllyPriorities()
SetStartLocPrioCount(1, 2)
SetStartLocPrio(1, 0, 0, MAP_LOC_PRIO_HIGH)
end

function main()
SetCameraBounds(-3328.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), -3584.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM), 3328.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), 3072.0 - GetCameraMargin(CAMERA_MARGIN_TOP), -3328.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), 3072.0 - GetCameraMargin(CAMERA_MARGIN_TOP), 3328.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), -3584.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM))
SetDayNightModels("Environment\\DNC\\DNCLordaeron\\DNCLordaeronTerrain\\DNCLordaeronTerrain.mdl", "Environment\\DNC\\DNCLordaeron\\DNCLordaeronUnit\\DNCLordaeronUnit.mdl")
NewSoundEnvironment("Default")
SetAmbientDaySound("LordaeronSummerDay")
SetAmbientNightSound("LordaeronSummerNight")
SetMapMusic("Music", true, 0)
CreateAllItems()
CreateAllUnits()
InitBlizzard()
InitGlobals()
local s, m = pcall(RunBundle)
if not s then
    print(m)
end
end

function config()
SetMapName("TRIGSTR_001")
SetMapDescription("TRIGSTR_003")
SetPlayers(2)
SetTeams(2)
SetGamePlacement(MAP_PLACEMENT_USE_MAP_SETTINGS)
DefineStartLocation(0, -1984.0, -128.0)
DefineStartLocation(1, 2368.0, 320.0)
InitCustomPlayerSlots()
InitCustomTeams()
InitAllyPriorities()
end

