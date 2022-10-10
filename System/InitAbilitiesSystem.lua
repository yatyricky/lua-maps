local SystemBase = require("System.SystemBase")

---@class InitAbilitiesSystem : SystemBase
local cls = class("InitAbilitiesSystem", SystemBase)

function cls:Awake()
    require("Ability.DeathGrip")
end

return cls
