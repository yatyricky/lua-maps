local EventCenter = require("Lib.EventCenter")
local FrameBegin = EventCenter.FrameBegin
local FrameUpdate = EventCenter.FrameUpdate
local Timer = require("Lib.Timer")
local FrameTimer = require("Lib.FrameTimer")
local Time = require("Lib.Time")
local Utils = require("Lib.Utils")
require("Lib.CoroutineExt")

-- main loop
local dt = Time.Delta
TimerStart(CreateTimer(), dt, true, function()
    FrameBegin:Emit(dt)
    FrameUpdate:Emit(dt)
end)

-- main logic

require("System.ItemSystem").new()
require("System.SpellSystem").new()

EventCenter.PlayerUnitPickupItem:On({}, function(context, data)
    print(GetUnitName(data.unit), "got", GetItemName(data.item))
end)

EventCenter.RegisterPlayerUnitSpellChannel:Emit({
    id = FourCC("AHds"),
    handler = function(data)
        print(GetUnitName(data.caster), "cast", Utils.CCFour(data.abilityId))
    end,
})

EventCenter.RegisterPlayerUnitSpellChannel:Emit({
    id = 0,
    handler = function(data)
        print(GetUnitName(data.caster), "channel any", Utils.CCFour(data.abilityId))
    end,
})

EventCenter.RegisterPlayerUnitSpellCast:Emit({
    id = 0,
    handler = function(data)
        print(GetUnitName(data.caster), "cast any", Utils.CCFour(data.abilityId))
    end,
})

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = 0,
    handler = function(data)
        print(GetUnitName(data.caster), "effect any", Utils.CCFour(data.abilityId))
    end,
})

EventCenter.RegisterPlayerUnitSpellFinish:Emit({
    id = 0,
    handler = function(data)
        print(GetUnitName(data.caster), "finish any", Utils.CCFour(data.abilityId))
    end,
})

EventCenter.RegisterPlayerUnitSpellEndCast:Emit({
    id = 0,
    handler = function(data)
        print(GetUnitName(data.caster), "end_cast any", Utils.CCFour(data.abilityId))
    end,
})
