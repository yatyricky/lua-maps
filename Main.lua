local EventCenter = require("Lib.EventCenter")
local FrameBegin = EventCenter.FrameBegin
local FrameUpdate = EventCenter.FrameUpdate
local Timer = require("Lib.Timer")
local FrameTimer = require("Lib.FrameTimer")
local Time = require("Lib.Time")
require("Lib.CoroutineExt")

-- main loop
local dt = Time.Delta
TimerStart(CreateTimer(), dt, true, function()
    FrameBegin:Emit(dt)
    FrameUpdate:Emit(dt)
end)

-- main logic

local ItemSystem = require("System.ItemSystem")
ItemSystem.new()

EventCenter.PlayerUnitPickupItem:On({}, function(context, data)
    print(GetUnitName(data.unit), "got", GetItemName(data.item))
end)
