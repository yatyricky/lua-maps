-- 闪避

local Abilities = require("Config.Abilities")
local UnitAttribute = require("Objects.UnitAttribute")

--region meta

local Meta = {
    ID = FourCC("A015"),
    Chance = { 0.1, 0.2, 0.3 },
    ChanceInc = { 0.1, 0.1, 0.1 },
    --Chance = { 1, 1, 1 },
    --ChanceInc = { 1, 0, 0 },
}

Abilities.Evasion = Meta

--BlzSetAbilityTooltip(Abilities.Evasion.ID, string.format("腐臭壁垒", 0), 0)
--BlzSetAbilityExtendedTooltip(Abilities.Evasion.ID, string.format("发出固守咆哮，受到的所有伤害降低|cffff8c00%s|r，持续|cffff8c00%s|r秒。",
--        string.formatPercentage(Abilities.Evasion.Reduction), Abilities.Evasion.Duration), 0)

--endregion

---@class Evasion
local cls = class("Evasion")

ExTriggerRegisterUnitLearn(Meta.ID, function(unit, level, _)
    local attr = UnitAttribute.GetAttr(unit)
    attr.dodge = attr.dodge + Meta.ChanceInc[level]
end)

ExTriggerRegisterNewUnit(function(unit)
    local level = GetUnitAbilityLevel(unit, Meta.ID)
    if level > 0 then
        local attr = UnitAttribute.GetAttr(unit)
        attr.dodge = attr.dodge + Meta.Chance[level]
    end
end)

return cls
