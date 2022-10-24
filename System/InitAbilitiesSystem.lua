local SystemBase = require("System.SystemBase")

---@class InitAbilitiesSystem : SystemBase
local cls = class("InitAbilitiesSystem", SystemBase)

function cls:Awake()
    -- 血DK
    require("Ability.DeathGrip")
    require("Ability.DeathStrike")
    require("Ability.PlagueStrike")
    require("Ability.ArmyOfTheDead")

    -- 邪DK
    require("Ability.DeathCoil")
end

return cls
