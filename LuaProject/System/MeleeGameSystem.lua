local SystemBase = require("System.SystemBase")

---@class MeleeGameSystem : SystemBase, __ClassBase<MeleeGameSystem>
local cls = class("MeleeGameSystem", SystemBase)

function cls:ctor()
    MeleeStartingVisibility()
    MeleeStartingHeroLimit()
    MeleeGrantHeroItems()
    MeleeStartingResources()
    MeleeClearExcessUnits()
    MeleeStartingUnits()
    MeleeStartingAI()
    MeleeInitVictoryDefeat()
end

return cls
