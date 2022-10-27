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
    require("Ability.FesteringWound")
    require("Ability.DeathCoil")
    require("Ability.Defile")
    require("Ability.Apocalypse")
    --require("Ability.DarkTransformation")
    --require("Ability.MonstrousBlow")
    --require("Ability.ShamblingRush")
    --require("Ability.PutridBulwark")
end

return cls
