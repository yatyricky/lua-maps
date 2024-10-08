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
