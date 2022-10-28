local BuffBase = require("Objects.BuffBase")

---@class SlowDebuff : BuffBase
local cls = class("RootDebuff", BuffBase)

function cls:OnEnable()
    SetUnitMoveSpeed(self.target, 0)
end

function cls:OnDisable()
    SetUnitMoveSpeed(self.target, GetUnitDefaultMoveSpeed(self.target))
end

return cls
