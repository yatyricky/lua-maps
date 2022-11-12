local Timer = require("Lib.Timer")
local Time = require("Lib.Time")

local cls = class("Ease")

cls.Type = {
    Linear = 1,
}

local function efLinear(t, c1, c2)
    return c1 + (c2 - c1) * t
end

local funcMap = {
    [cls.Type.Linear] = efLinear,
}

---@param getter fun(): real
---@param setter fun(value: real): void
---@param target real
---@param duration real
---@param ease integer | Nil Ease.Type.*
function cls.To(getter, setter, target, duration, ease)
    ease = ease or cls.Type.Linear
    local func = funcMap[ease]
    local frames = math.ceil(duration / Time.Delta)
    local c1 = getter()
    local t = 0
    local tm = Timer.new(function()
        t = t + 1
        local value = func(t / frames, c1, target)
        setter(value)
    end, Time.Delta, frames)
    tm:Start()
end

return cls
