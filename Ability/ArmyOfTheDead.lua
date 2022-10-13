local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local Vector2 = require("Lib.Vector2")
local Timer = require("Lib.Timer")
local Time = require("Lib.Time")

local instances = {} ---@type table<unit, ArmyOfTheDead>

local LesserColor = { r = 0.2, g = 0, b = 0.4, a = 1 }
local GreaterColor = { r = 0.6, g = 0.15, b = 0.4, a = 1 }

---@class ArmyOfTheDead
local cls = class("ArmyOfTheDead")

function cls:ctor(caster)
    local casterPos = Vector2.FromUnit(caster)
    self.sfxTimer = Timer.new(function()
        local pos = (Vector2.InsideUnitCircle() * math.random(200, 600)):Add(casterPos)
        ExAddLightningPosPos("CLSB", casterPos.x, casterPos.y, 200, pos.x, pos.y, 0, math.random() * 0.4 + 0.2, LesserColor)
        ExAddSpecialEffect("Abilities/Spells/Undead/DeathandDecay/DeathandDecayTarget.mdl", pos.x, pos.y, 0.2)
    end, 0.2, -1)
    self.sfxTimer:Start()

    local player = GetOwningPlayer(caster)
    self.summonTimer = Timer.new(function()
        local pos = (Vector2.InsideUnitCircle() * math.random(200, 600)):Add(casterPos)
        local summoned = CreateUnit(player, FourCC("u000"), pos.x, pos.y, math.random(360))
        ExAddLightningPosUnit("CLPB", casterPos.x, casterPos.y, 200, summoned, 1, GreaterColor)
        ExAddSpecialEffectTarget("Abilities/Spells/Undead/AnimateDead/AnimateDeadTarget.mdl", summoned, "origin", 0.1)
        UnitApplyTimedLife(summoned, FourCC("BUan"), 40)
    end, 1, -1)
    self.summonTimer:Start()
end

function cls:Stop()
    self.sfxTimer:Stop()
    self.summonTimer:Stop()
end

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Abilities.ArmyOfTheDead.ID,
    ---@param data ISpellData
    handler = function(data)
        instances[data.caster] = cls.new(data.caster, GetUnitAbilityLevel(data.caster, data.abilityId))
    end
})

EventCenter.RegisterPlayerUnitSpellEndCast:Emit({
    id = Abilities.ArmyOfTheDead.ID,
    ---@param data ISpellData
    handler = function(data)
        local inst = instances[data.caster]
        if inst then
            inst:Stop()
            instances[data.caster] = nil
        else
            print("army of the dead end but no instance")
        end
    end
})

return cls
