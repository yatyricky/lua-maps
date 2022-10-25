-- 溃烂之伤

local Abilities = require("Config.Abilities")
local BuffBase = require("Objects.BuffBase")

Abilities.FesteringWound = {
    Duration = 30,
}

local cls = class("FesteringWound", BuffBase)

return cls
