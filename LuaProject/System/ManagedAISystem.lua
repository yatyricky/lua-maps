local SystemBase = require("System.SystemBase")
local EventCenter = require("Lib.EventCenter")
local Event = require("Lib.Event")
local Vector2 = require("Lib.Vector2")

---positions: {x, y, out hp}[]
EventCenter.InitCamp = Event.new()

local CampFlag = FourCC("e001")

---@class ManagedAISystem : SystemBase
local cls = class("ManagedAISystem", SystemBase)

function cls:ctor()
    self.ais = {}
    self.campPositions = {}
end

function cls:Awake()
    EventCenter.InitCamp:On(self, cls.onInitCamp)

    ExGroupEnumUnitsInMap(function(unit)
        if GetUnitTypeId(unit) == CampFlag then
            table.insert(self.campPositions, Vector2.FromUnit(unit))
            RemoveUnit(unit)
        end
    end)

    table.insert(self.ais, require("AI.TwistedMeadows").new())
    -- table.insert(self.ais, require("AI.MoonGlade").new())
end

function cls:Update(dt)
    for _, v in ipairs(self.ais) do
        v:Update(dt)
    end
end

function cls:onInitCamp(data)
    for _, p in ipairs(self.campPositions) do
        local hp = 0
        ExGroupEnumUnitsInRange(p.x, p.y, 400, function(unit)
            if ExGetUnitPlayerId(unit) == 24 and not IsUnitType(unit, UNIT_TYPE_STRUCTURE) then
                hp = hp + GetWidgetLife(unit)
            end
        end)
        if hp > 5 then
            table.insert(data, {
                p = p,
                hp = hp,
            })
        end
    end
end

--ExTriggerRegisterUnitLearn(0, function(unit, level, skill)
--    local Utils = require("Lib.Utils")
--    print(GetUnitName(unit), "learn", Utils.CCFour(skill), level)
--end)

return cls
