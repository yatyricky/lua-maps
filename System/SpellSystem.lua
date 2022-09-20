local Event = require("Event")
local EventCenter = require("Lib.EventCenter")
local Vector2 = require("Lib.Vector2")

---@class SpellSystem
local cls = class("SpellSystem")

EventCenter.PlayerUnitSpellChannel = Event.new()
EventCenter.PlayerUnitSpellCast = Event.new()
EventCenter.PlayerUnitSpellEffect = Event.new()
EventCenter.PlayerUnitSpellFinish = Event.new()
EventCenter.PlayerUnitSpellEndCast = Event.new()

function cls:ctor()
    self:_register(EVENT_PLAYER_UNIT_SPELL_CHANNEL, function()
        self:_onChannel()
    end)
    self:_register(EVENT_PLAYER_UNIT_SPELL_CAST, function()
        self:_onCast()
    end)
    self:_register(EVENT_PLAYER_UNIT_SPELL_EFFECT, function()
        self:_onEffect()
    end)
    self:_register(EVENT_PLAYER_UNIT_SPELL_FINISH, function()
        self:_onFinish()
    end)
    self:_register(EVENT_PLAYER_UNIT_SPELL_ENDCAST, function()
        self:_onEndCast()
    end)
end

function cls:_register(event, callback)
    local trigger = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trigger, event)
    TriggerAddAction(trigger, callback)
end

local function _getSpellData()
    local data = {}
    data.abilityId = GetSpellAbilityId()
    data.caster = GetTriggerUnit()
    data.target = GetSpellTargetUnit()
    if data.target ~= nil then
        data.x = GetUnitX(data.target)
        data.y = GetUnitY(data.target)
    else
        data.destructable = GetSpellTargetDestructable()
        if data.destructable ~= nil then
            data.x = GetDestructableX(data.destructable)
            data.y = GetDestructableY(data.destructable)
        else
            data.item = GetSpellTargetItem()
            if data.item ~= nil then
                data.x = GetItemX(data.item)
                data.y = GetItemY(data.item)
            else
                data.x = GetSpellTargetX()
                data.y = GetSpellTargetY()
            end
        end
    end
    --set s.interrupt=spellEvent.casterTable[s.CastingUnit]
    return data
end

function cls:_onChannel()
    EventCenter.PlayerUnitSpellChannel:Emit(_getSpellData())
end

function cls:_onCast()
    EventCenter.PlayerUnitSpellCast:Emit(_getSpellData())
end

function cls:_onEffect()
    EventCenter.PlayerUnitSpellEffect:Emit(_getSpellData())
end

function cls:_onFinish()

end

function cls:_onEndCast()

end

return cls