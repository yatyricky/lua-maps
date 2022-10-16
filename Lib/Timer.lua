require("Lib.MathExt")

local pcall = pcall
local t_insert = table.insert
local t_remove = table.remove

local PauseTimer = PauseTimer
local CreateTimer = CreateTimer
local TimerStart = TimerStart
local TimerGetElapsed = TimerGetElapsed
local TimerGetRemaining = TimerGetRemaining

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
    self.func = func
    self.duration = duration
    if loops == 0 then
        loops = 1
    end
    self.loops = loops
    self.running = false
    self.nextTimer = nil ---@type Timer
end

function cls:Start()
    self.timer = getTimer()
    TimerStart(self.timer, self.duration, self.loops ~= 1, function()
        local dt = TimerGetElapsed(self.timer)
        local s, m = pcall(self.func, dt)
        if not s then
            print(m)
            self:Stop()
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
    self.running = true
end

function cls:Stop()
    cacheTimer(self.timer)
    self.running = false
    if self.nextTimer then
        self.nextTimer:Start()
    end
end

function cls:Next(timer)
    self.nextTimer = timer
end

function cls:Cancel()
    if self.running then
        cacheTimer(self.timer)
        self.running = false
    end
    if self.nextTimer then
        self.nextTimer:Cancel()
    end
end

--function cls:GetRemaining()
--    if self.running then
--        return TimerGetRemaining(self.timer)
--    end
--    if self.nextTimer then
--        return self.nextTimer:GetRemaining()
--    end
--    return -1
--end

function cls:GetElapsed()
    if self.running then
        return TimerGetElapsed(self.timer)
    end
    if self.nextTimer then
        return self.nextTimer:GetElapsed()
    end
    return -1
end

function cls:GetTimeLeft()
    local time = TimerGetRemaining(self.timer)
    if self.loops > 1 then
        time = time + (self.loops - 1) * self.duration
    elseif self.loops == -1 then
        time = time + 9999
    end
    if self.nextTimer then
        time = time + self.nextTimer:GetTimeLeft()
    end
    return time
end

return cls
