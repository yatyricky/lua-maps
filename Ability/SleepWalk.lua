local Vector2 = require("Lib.Vector2")
local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local Ease = require("Lib.Ease")

local cls = class("SleepWalk")

local Meta = {
    ID = FourCC("A01F"),
    EveryYards = 100,
    ManaRestore = 20,
    Speed = 50,
    MaxDuration = 10,
}

Abilities.SleepWalk = Meta

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        coroutine.start(function()
            PauseUnit(data.target, true)
            SetUnitPathing(data.target, false)
            --SetUnitAnimationByIndex(data.target, 0)

            ExAddSpecialEffectTarget("Abilities/Spells/Undead/Sleep/SleepSpecialArt.mdl", data.target, "overhead", 0.1)
            local sfx = AddSpecialEffectTarget("Abilities/Spells/Undead/Sleep/SleepTarget.mdl", data.target, "overhead")
            local travelled = 0
            local timeStart = Time.Time
            local frames = 0
            while true do
                coroutine.step()
                frames = frames + 1
                local dest = Vector2.FromUnit(data.caster)
                local curr = Vector2.FromUnit(data.target)
                local dir = (dest - curr):SetNormalize()
                local stepLen = Meta.Speed * Time.Delta

                --if frames % 9 == 0 then
                --    local shade = AddSpecialEffect("units/nightelf/MountainGiant/MountainGiant.mdl", curr.x, curr.y)
                --    BlzSetSpecialEffectYaw(shade, GetUnitFacing(data.target) * bj_DEGTORAD)
                --    local alpha = 1
                --    Ease.To(function()
                --        return alpha
                --    end, function(value)
                --        BlzSetSpecialEffectAlpha(shade, math.floor(value * 255))
                --    end, 0, 1)
                --end

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
                    ExAddSpecialEffectTarget("Abilities/Spells/Items/AIma/AImaTarget.mdl", data.caster, "origin", 1)
                end
                if curr:Sub(dest):Magnitude() < 96 or (Time.Time - timeStart) > Meta.MaxDuration then
                    break
                end
            end

            DestroyEffect(sfx)
            PauseUnit(data.target, false)
            SetUnitPathing(data.target, true)
        end)
    end
})

return cls
