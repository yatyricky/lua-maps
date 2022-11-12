local Vector2 = require("Lib.Vector2")
local EventCenter = require("Lib.EventCenter")

local cls = class("SleepWalk")

local Meta = {
    ID = FourCC("A000")
}

Abilities.SleepWalk = Meta

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Abilities.DeathCoil.ID,
    ---@param data ISpellData
    handler = function(data)
        coroutine.start(function()
            PauseUnit(data.target, true)
            SetUnitPathing(data.target, false)
            SetUnitAnimationByIndex(data.target, 0)
            local sfx = AddSpecialEffectTarget("sleep", data.target, "overhead")
            local travelled = 0
            while true do
                coroutine.step()
                local dest = Vector2.FromUnit(data.caster)
                local curr = Vector2.FromUnit(data.target)
                local dir = (dest - curr):SetNormalize()
                local stepLen = speed * Time.Delta
                curr:Add(dir * stepLen):UnitMoveTo(data.target)
                SetUnitFacing(data.target, math.atan2(dir.y, dir.x) * bj_RADTODEG)
                travelled = travelled + stepLen
                if travelled >= Meta.EveryYards then
                    travelled = travelled - Meta.EveryYards
                    EventCenter.HealMana:Emit({
                        caster = data.caster,
                        target = data.caster,
                        amount = Meta.ManaRestore,
                        isPercentage = false
                    })
                end
                if curr:Sub(dest):Magnitude() < 96 then
                    break
                end
            end

            DestroyEffect(sfx)
            PauseUnit(target, false)
            SetUnitPathing(target, true)
        end)
    end
})

return cls
