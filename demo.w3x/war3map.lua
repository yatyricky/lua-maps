--lua-bundler:000009108
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

__modules["Lib.class"]={loader=function()
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

__modules["Lib.CoroutineExt"]={loader=function()
local Timer = require("Lib.Timer")
local FrameTimer = require("Lib.FrameTimer")

local c2t = setmetatable({}, { __mode = "kv" })

function coroutine.start(f, ...)
    local c = coroutine.create(f)

    if coroutine.running() == nil then
        local success, msg = coroutine.resume(c, ...)
        if not success then
            print(msg)
        end
    else
        local args = { ... }
        local timer = FrameTimer.new(function()
            c2t[c] = nil
            local success, msg = coroutine.resume(c, unpack(args))
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
    local c = coroutine.running()
    local timer = nil

    local function action()
        c2t[c] = nil

        local success, msg = coroutine.resume(c)
        if not success then
            timer:Stop()
            print(msg)
        end
    end

    timer = Timer.new(action, t, 1)
    c2t[c] = timer
    timer:Start()
    coroutine.yield()
end

function coroutine.step(t)
    local c = coroutine.running()
    local timer = nil

    local function action()
        c2t[c] = nil

        local success, msg = coroutine.resume(c)
        if not success then
            timer:Stop()
            print(msg)
        end
    end

    timer = FrameTimer.new(action, t or 1, 1)
    c2t[c] = timer
    timer:Start()
    coroutine.yield()
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

local function f2s(func)
    local info = debug.getinfo(func, "S")
    if info.what == "C" then
        return "CFunc:" .. so
    else
        return string.format("%s:%s-%s", info.source, info.linedefined, info.lastlinedefined)
    end
end

function cls:ToString()
    local sb = {}
    for context, map in pairs(self._handlers) do
        for listener, _ in pairs(map) do
            table.insert(sb, string.format("%s -> %s", tostring(context), f2s(listener)))
        end
    end
    return table.concat(sb, ",")
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
        self.func()

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
local FrameBegin = require("Lib.EventCenter").FrameBegin

local cls = {}

cls.Time = 0
cls.Frame = 0
cls.Delta = 1 / 30

FrameBegin:On(cls, function(_, dt)
    cls.Time = cls.Time + dt
    cls.Frame = cls.Frame + 1
end)

return cls

end}

__modules["Lib.Timer"]={loader=function()
local FrameUpdate = require("Lib.EventCenter").FrameUpdate

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
    if self.time <= 1e-14 then
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

__modules["Main"]={loader=function()
local EventCenter = require("Lib.EventCenter")
local FrameBegin = EventCenter.FrameBegin
local FrameUpdate = EventCenter.FrameUpdate
local Timer = require("Lib.Timer")
local FrameTimer = require("Lib.FrameTimer")
local Time = require("Lib.Time")
require("Lib.CoroutineExt")

-- local tminus = 5
-- local tm = Timer.new(function()
--     print(tminus, "@", Time.Time)
--     tminus = tminus - 1
-- end, 1, 5)
-- tm:Start()

-- local ftc = 5
-- local ft = FrameTimer.new(function ()
--     FrameTimer.new(function ()
--         print("frame", ftc, "@", Time.Time, Time.Frame)
--         ftc = ftc - 1
--     end, 1, 5):Start()
-- end, 30, 1):Start()

-- coroutine.start(function ()
--     for i = 1, 10, 1 do
--         print("Good", i, Time.Time, Time.Frame)
--         coroutine.step()
--     end
-- end)

local c = coroutine.create(function ()
    print("run in co")
end)

coroutine.resume(c)

-- main loop
local dt = Time.Delta
TimerStart(CreateTimer(), dt, true, function ()
    FrameBegin:Emit(dt)
    FrameUpdate:Emit(dt)
end)

end}

__modules["Main"].loader()
end

function InitGlobals()
end

function CreateUnitsForPlayer0()
local p = Player(0)
local u
local unitID
local t
local life

u = BlzCreateUnitWithSkin(p, FourCC("hdhw"), 2336.3, 1897.0, 206.714, FourCC("hdhw"))
end

function CreatePlayerBuildings()
end

function CreatePlayerUnits()
CreateUnitsForPlayer0()
end

function CreateAllUnits()
CreatePlayerBuildings()
CreatePlayerUnits()
end

function InitCustomPlayerSlots()
SetPlayerStartLocation(Player(0), 0)
SetPlayerColor(Player(0), ConvertPlayerColor(0))
SetPlayerRacePreference(Player(0), RACE_PREF_HUMAN)
SetPlayerRaceSelectable(Player(0), true)
SetPlayerController(Player(0), MAP_CONTROL_USER)
end

function InitCustomTeams()
SetPlayerTeam(Player(0), 0)
end

function main()
SetCameraBounds(-3328.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), -3584.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM), 3328.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), 3072.0 - GetCameraMargin(CAMERA_MARGIN_TOP), -3328.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), 3072.0 - GetCameraMargin(CAMERA_MARGIN_TOP), 3328.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), -3584.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM))
SetDayNightModels("Environment\\DNC\\DNCLordaeron\\DNCLordaeronTerrain\\DNCLordaeronTerrain.mdl", "Environment\\DNC\\DNCLordaeron\\DNCLordaeronUnit\\DNCLordaeronUnit.mdl")
NewSoundEnvironment("Default")
SetAmbientDaySound("LordaeronSummerDay")
SetAmbientNightSound("LordaeronSummerNight")
SetMapMusic("Music", true, 0)
CreateAllUnits()
InitBlizzard()
InitGlobals()
RunBundle()
end

function config()
SetMapName("TRIGSTR_001")
SetMapDescription("TRIGSTR_003")
SetPlayers(1)
SetTeams(1)
SetGamePlacement(MAP_PLACEMENT_USE_MAP_SETTINGS)
DefineStartLocation(0, 0.0, -1408.0)
InitCustomPlayerSlots()
SetPlayerSlotAvailable(Player(0), MAP_CONTROL_USER)
InitGenericPlayerSlots()
end

