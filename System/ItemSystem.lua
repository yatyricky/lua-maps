---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Rick Sun.
--- DateTime: 9/17/2022 1:46 PM
---

---@class ItemSystem
local cls = class("ItemSystem")

function cls:ctor()
    local trigger = CreateTrigger
    local i = 0
    while i < bj_MAX_PLAYER_SLOTS do
        TriggerRegisterPlayerUnitEvent(trigger, Player(i), EVENT_PLAYER_UNIT_PICKUP_ITEM, nil)
        i = i + 1
    end
    TriggerAddCondition(trigger, Condition(function()
        local item = GetManipulatedItem()
        local itemId = GetItemTypeId(item)
        local unit = GetTriggerUnit()
        print(GetUnitName(unit), "got", GetItemName(item))
        return false
    end))
end

return cls
