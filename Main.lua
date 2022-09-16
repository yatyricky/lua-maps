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

coroutine.start(function ()
    for i = 1, 10, 1 do
        print("Good", i, Time.Time, Time.Frame)
        -- coroutine.step()
    end
end)

-- main loop
local dt = Time.Delta
TimerStart(CreateTimer(), dt, true, function ()
    FrameBegin:Emit(dt)
    FrameUpdate:Emit(dt)
end)
