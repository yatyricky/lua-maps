local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local BuffBase = require("Buff.BuffBase")
local BloodPlague = require("Ability.BloodPlague")
local FrostPlague = require("Ability.FrostPlague")
local UnholyPlague = require("Ability.UnholyPlague")

local cls = class("PlagueStrike")

function cls.applyBloodPlague(caster, target, level)
    return BloodPlague.new(caster, target, Abilities.PlagueStrike.BloodPlagueDuration[level], 999, { level = level })
end

function cls.applyFrostPlague(caster, target, level)
    return FrostPlague.new(caster, target, Abilities.PlagueStrike.FrostPlagueDuration[level], 1, { level = level })
end

function cls.applyUnholyPlague(caster, target, level)
    return UnholyPlague.new(caster, target, Abilities.PlagueStrike.UnholyPlagueDuration[level], Abilities.PlagueStrike.UnholyPlagueInterval[level], { level = level })
end

cls.Plagues = {
    { class = BloodPlague, invoker = cls.applyBloodPlague },
    { class = FrostPlague, invoker = cls.applyFrostPlague },
    { class = UnholyPlague, invoker = cls.applyUnholyPlague },
}

EventCenter.RegisterPlayerUnitDamaged:Emit(function(caster, target, _, _, _, isAttack)
    if not isAttack then
        return
    end

    if target == nil then
        return
    end

    local abilityLevel = GetUnitAbilityLevel(caster, Abilities.PlagueStrike.ID)
    if abilityLevel < 1 then
        return
    end

    local existingPlagues = {} ---@type BuffBase[]
    local missingDebuff
    for _, plagueDefine in ipairs(cls.Plagues) do
        local debuff = BuffBase.FindBuffByClassName(target, plagueDefine.class.__cname)
        if not debuff then
            missingDebuff = plagueDefine
            break
        else
            table.insert(existingPlagues, debuff)
        end
    end

    if missingDebuff then
        missingDebuff.invoker(caster, target, abilityLevel)
    else
        ---@param a BuffBase
        ---@param b BuffBase
        table.sort(existingPlagues, function(a, b)
            local lta = a.level < abilityLevel
            local ltb = b.level < abilityLevel
            if lta ~= ltb then
                return lta
            end
            return a:GetTimeLeft() < b:GetTimeLeft()
        end)

        local first = existingPlagues[1]
        first.level = abilityLevel
        if first.__cname ~= FrostPlague.__cname then
            first:ResetDuration()
        end
    end
end)

return cls
