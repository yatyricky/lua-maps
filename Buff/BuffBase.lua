local Time = require("Lib.Time")
local Timer = require("Lib.Timer")

local ExIsUnitDead = ExIsUnitDead

---@class BuffBase
local cls = class("BuffBase")

cls.unitBuffs = {} ---@type table<unit, BuffBase[]>

---@param unit unit
---@param name string
function cls.FindBuffByClassName(unit, name)
    local arr = cls.unitBuffs[unit]
    if not arr then
        return nil
    end

    return array.find(arr, function(_, v)
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
    self.duration = duration
    self.interval = interval
    self.awakeData = awakeData

    self:Awake()
    self:OnEnable()
    local ticks = math.floor(duration / interval)
    local reminder = duration - ticks * interval
    local timerTicks
    if ticks > 0 then
        timerTicks = Timer.new(function(dt)
            self:_onUpdate(dt)
        end, interval, ticks)
    end

    local timerReminder = Timer.new(function(_)
        self:OnDisable()
        self:OnDestroy()
    end, reminder, 1)

    if timerTicks then
        timerTicks:Next(timerReminder)
        self.timer = timerTicks
    else
        self.timer = timerReminder
    end
    self.timer:Start()

    local unitTab = table.getOrCreateTable(cls.unitBuffs, target)
    table.insert(unitTab, self)
end

ExTriggerRegisterUnitDeath(function(deadUnit)
    local unitTab = cls.unitBuffs[deadUnit]
    if unitTab then
        for i, v in ipairs() do

        end
        local len = #unitTab

        for i = len, 1, -1 do
            local buff = unitTab[i]
            buff.timer:Cancel()
            buff:OnDisable()
            buff:OnDestroy()
        end
    end
end)

function cls:Awake()
end

function cls:OnEnable()
end

function cls:Update(dt)
    dt = dt
end

function cls:OnDisable()
end

function cls:OnDestroy()
    local unitTab = cls.unitBuffs[self.target]
    if not unitTab then
        Log("buff onDestroy but unitTab is nil")
    else
        if not array.removeItem(unitTab, self) then
            Log("Remove buff unit failed", self.class.__cname, tostring(self.target), debug.traceback())
            Log("existing:")
            for _, v in ipairs(unitTab) do
                Log(v.class.__cname)
            end
        end
    end
end

function cls:_onUpdate(dt)
    --if ExIsUnitDead(self.target) then
    --    self.timer:Cancel()
    --    self.timer = nil
    --    self:OnDisable()
    --    print("ondestroy from 2")
    --    self:OnDestroy()
    --    return
    --end

    self:Update(dt)
end

function cls:ResetDuration(exprTime)
    local elapsed = self.timer:GetElapsed()
    if elapsed < 0 then
        Log("Attempting to reset expired buff")
        return
    end

    self.timer:Cancel()
    self.timer = nil
    local duration = exprTime and (exprTime - Time.Time) or self.duration

    local firstTick = self.interval - elapsed
    if firstTick < 0 then
        Log("interval > elapsed???")
        return
    end

    local normalTickDuration = duration - firstTick
    local head ---@type Timer
    local curr ---@type Timer
    if normalTickDuration >= 0 then
        head = Timer.new(function(dt)
            self:_onUpdate(dt)
        end, firstTick, 1)
        curr = head

        local reminder
        if normalTickDuration > 0 then
            local ticks = math.floor(normalTickDuration / self.interval)
            reminder = normalTickDuration - ticks * self.interval
            if ticks > 0 then
                local timerNormalTicks = Timer.new(function(dt)
                    self:_onUpdate(dt)
                end, self.interval, ticks)
                curr:Next(timerNormalTicks)
                curr = timerNormalTicks
            end
        else
            reminder = normalTickDuration
        end

        local lastTimer = Timer.new(function(_)
            self:OnDisable()

            self:OnDestroy()
        end, reminder, 1)
        curr:Next(lastTimer)
        curr = lastTimer
    else
        head = Timer.new(function(_)
            self:OnDisable()

            self:OnDestroy()
        end, duration, 1)
    end

    self.timer = head
    head:Start()
end

function cls:GetTimeLeft()
    return self.timer:GetTimeLeft()
end

function cls:GetTimeNorm()
    return math.clamp01(self:GetTimeLeft() / self.duration)
end

return cls
