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
