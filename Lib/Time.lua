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
