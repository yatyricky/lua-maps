local Event = require("Lib.Event")
local EventCenter = require("Lib.EventCenter")

---@class ISpellData
---@field abilityId integer
---@field caster unit
---@field target unit
---@field x real
---@field y real
---@field item item
---@field destructable destructable
---@field finished boolean
---@field interrupted ISpellData
---@field _effectDone boolean

---@class SpellSystem
local cls = class("SpellSystem")

EventCenter.RegisterPlayerUnitSpellChannel = Event.new()
EventCenter.RegisterPlayerUnitSpellCast = Event.new()
EventCenter.RegisterPlayerUnitSpellEffect = Event.new()
EventCenter.RegisterPlayerUnitSpellFinish = Event.new()
EventCenter.RegisterPlayerUnitSpellEndCast = Event.new()

function cls:ctor()
    self:_register(EVENT_PLAYER_UNIT_SPELL_CHANNEL, function()
        local data = self:_initSpellData()
        self:_invoke(self._channelHandlers, data)
    end)

    self:_register(EVENT_PLAYER_UNIT_SPELL_CAST, function()
        local data = self.castTab[GetTriggerUnit()]
        self:_invoke(self._castHandlers, data)
    end)

    self:_register(EVENT_PLAYER_UNIT_SPELL_EFFECT, function()
        local data = self.castTab[GetTriggerUnit()]
        if data and not data._effectDone then
            data._effectDone = true
            self:_invoke(self._effectHandlers, data)
        end
    end)

    self:_register(EVENT_PLAYER_UNIT_SPELL_FINISH, function()
        local data = self.castTab[GetTriggerUnit()]
        data.finished = true
        self:_invoke(self._finishHandlers, data)
    end)

    self:_register(EVENT_PLAYER_UNIT_SPELL_ENDCAST, function()
        local data = self.castTab[GetTriggerUnit()]
        self:_invoke(self._endCastHandlers, data)
        if data.interrupted then
            self.castTab[data.caster] = data.interrupted
        else
            self.castTab[data.caster] = nil
        end
    end)

    self.castTab = {} ---@type table<unit, ISpellData>

    self._channelHandlers = {}
    self._castHandlers = {}
    self._effectHandlers = {}
    self._finishHandlers = {}
    self._endCastHandlers = {}

    EventCenter.RegisterPlayerUnitSpellChannel:On(self, cls._registerSpellChannel)
    EventCenter.RegisterPlayerUnitSpellCast:On(self, cls._registerSpellCast)
    EventCenter.RegisterPlayerUnitSpellEffect:On(self, cls._registerSpellEffect)
    EventCenter.RegisterPlayerUnitSpellFinish:On(self, cls._registerSpellFinish)
    EventCenter.RegisterPlayerUnitSpellEndCast:On(self, cls._registerSpellEndCast)
end

---@param data ISpellData
function cls:_invoke(handlers, data)
    local tab = handlers[0]
    if tab then
        for _, listener in ipairs(tab) do
            if listener.ctx then
                listener.handler(listener.ctx, data)
            else
                listener.handler(data)
            end
        end
    end
    tab = handlers[data.abilityId]
    if tab then
        for _, listener in ipairs(tab) do
            if listener.ctx then
                listener.handler(listener.ctx, data)
            else
                listener.handler(data)
            end
        end
    end
end

function cls:_register(event, callback)
    local trigger = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trigger, event)
    TriggerAddAction(trigger, callback)
end

function cls:_initSpellData()
    local data = {} ---@type ISpellData
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
    data.interrupted = self.castTab[data.caster]
    self.castTab[data.caster] = data
    return data
end

function cls:_registerSpell(data, tab)
    local listeners = tab[data.id]
    if listeners == nil then
        listeners = {}
        tab[data.id] = listeners
    end
    table.insert(listeners, data)
end

function cls:_registerSpellChannel(data)
    self:_registerSpell(data, self._channelHandlers)
end

function cls:_registerSpellCast(data)
    self:_registerSpell(data, self._castHandlers)
end

function cls:_registerSpellEffect(data)
    self:_registerSpell(data, self._effectHandlers)
end

function cls:_registerSpellFinish(data)
    self:_registerSpell(data, self._finishHandlers)
end

function cls:_registerSpellEndCast(data)
    self:_registerSpell(data, self._endCastHandlers)
end

return cls
