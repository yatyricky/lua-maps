local EventCenter = require("Lib.EventCenter")
local Event = require("Lib.Event")
local SystemBase = require("System.SystemBase")

EventCenter.EditUnitAbility = Event.new()

---@class AbilityEditorSystem : SystemBase
local cls = class("AbilityEditorSystem", SystemBase)

function cls:Awake()
    self.map = {}
    EventCenter.EditUnitAbility:On(self, cls.onEditUnitAbility)

    ExTriggerRegisterNewUnit(function(u)
        local uid = GetUnitTypeId(u)
        local tab = table.getOrCreateTable(self.map, uid)
        for aid, handler in pairs(tab) do
            handler(BlzGetUnitAbility(u, aid))
        end
    end)
end

function cls:onEditUnitAbility(data)
    local tab = table.getOrCreateTable(self.map, data.unitId)
    tab[data.abilityId] = data.handler
end

return cls
