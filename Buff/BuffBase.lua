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
