local EventCenter = require("Lib.EventCenter")
local BuffBase = require("Objects.BuffBase")
local Abilities = require("Config.Abilities")
local Timer = require("Lib.Timer")

---@class BloodPlague : BuffBase
local cls = class("BloodPlague", BuffBase)

function cls:Awake()
    self.level = self.awakeData.level
end

EventCenter.RegisterPlayerUnitDamaged:Emit(function(caster, target, _, _, _, isAttack)
    if not isAttack then
        return
    end

    local debuff = BuffBase.FindBuffByClassName(target, "BloodPlague")
    if not debuff then
        return
    end

    local maxHp = GetUnitState(target, UNIT_STATE_MAX_LIFE)
    local damage = maxHp * Abilities.PlagueStrike.BloodPlagueData[debuff.level]

    UnitDamageTarget(caster, target, damage, false, true, ATTACK_TYPE_MAGIC, DAMAGE_TYPE_POISON, WEAPON_TYPE_WHOKNOWS)

    local impact = AddSpecialEffectTarget("Objects/Spawnmodels/Human/HumanBlood/HeroBloodElfBlood.mdl", target, "origin")
    local impactTimer = Timer.new(function()
        DestroyEffect(impact)
    end, 2, 1)
    impactTimer:Start()
end)

return cls
