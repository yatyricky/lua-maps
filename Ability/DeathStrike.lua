local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local Const = require("Config.Const")
local Vector2 = require("Lib.Vector2")
local Utils = require("Lib.Utils")
local BuffBase = require("Buff.BuffBase")
local Timer = require("Lib.Timer")
local BloodPlague = require("Ability.BloodPlague")
local FrostPlague = require("Ability.FrostPlague")
local UnholyPlague = require("Ability.UnholyPlague")

local cls = class("DeathStrike")

cls.Plagues = {
    BloodPlague,
    FrostPlague,
    UnholyPlague,
}

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Abilities.DeathStrike.ID,
    ---@param data ISpellData
    handler = function(data)
        local count = 0
        local existingPlagues = {} ---@type BuffBase[]
        for _, plagueDefine in ipairs(cls.Plagues) do
            local debuff = BuffBase.FindBuffByClassName(data.target, plagueDefine.__cname)
            if debuff then
                table.insert(existingPlagues, debuff)
                count = count + 1
            end
        end

        -- damage
        local level = GetUnitAbilityLevel(data.caster, data.abilityId)
        UnitDamageTarget(data.caster, data.target, Abilities.DeathStrike.Damage[level], false, true, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_METAL_HEAVY_SLICE)

        -- spread
        if table.any(existingPlagues) then
            local color = { r = 0.1, g = 0.7, b = 0.1, a = 1 }
            local g = CreateGroup()
            local targetPlayer = GetOwningPlayer(data.target)
            GroupEnumUnitsInRange(g, GetUnitX(data.target), GetUnitY(data.target), Abilities.DeathStrike.AOE[level], Filter(function()
                local e = GetFilterUnit()
                if not IsUnit(e, data.target) and IsUnitAlly(e, targetPlayer) and not IsUnitType(e, UNIT_TYPE_STRUCTURE) and not IsUnitType(e, UNIT_TYPE_MECHANICAL) and not IsUnitDeadBJ(e) then
                    Utils.AddTimedLightningAtUnits("SPLK", data.caster, e, 0.3, color, false)

                    for _, debuff in ipairs(existingPlagues) do
                        local current = BuffBase.FindBuffByClassName(e, debuff.__cname)
                        if current then
                            current.level = debuff.level
                            if current.__cname ~= "FrostPlague" then
                                current.duration = debuff.duration
                            end
                        else
                            debuff.class.new(debuff.caster, e, debuff:GetTimeLeft(), debuff.interval, debuff.awakeData)
                        end
                    end
                end
                return false
            end))
            DestroyGroup(g)
        end

        -- heal
        if count > 0 then
            EventCenter.Heal:Emit({
                caster = data.caster,
                target = data.caster,
                amount = Abilities.DeathStrike.Heal[level] * count * GetUnitState(data.caster, UNIT_STATE_MAX_LIFE),
            })

            local healEffect = AddSpecialEffectTarget("Abilities/Spells/Items/AIhe/AIheTarget.mdl", data.caster, "origin")
            local healEffectTimer = Timer.new(function()
                DestroyEffect(healEffect)
            end, 2, 1)
            healEffectTimer:Start()
        end

        local impact = AddSpecialEffectTarget("Objects/Spawnmodels/Human/HumanBlood/HeroBloodElfBlood.mdl", data.target, "origin")
        local impactTimer = Timer.new(function()
            DestroyEffect(impact)
        end, 2, 1)
        impactTimer:Start()
    end
})

return cls
