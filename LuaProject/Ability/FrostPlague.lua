local BuffBase = require("Objects.BuffBase")
local Abilities = require("Config.Abilities")
local Time = require("Lib.Time")

---@class FrostPlague : BuffBase
local cls = class("FrostPlague", BuffBase)

function cls:Awake()
    self.level = self.awakeData.level
end

function cls:OnEnable()
    ExAddSpecialEffectTarget("Abilities/Spells/Undead/FrostArmor/FrostArmorDamage.mdl", self.target, "origin", Time.Delta)
end

function cls:Update()
    ExAddSpecialEffectTarget("Abilities/Spells/Undead/FrostArmor/FrostArmorDamage.mdl", self.target, "origin", Time.Delta)
end

function cls:OnDisable()
    local speedLossPercent = math.clamp01(1 - GetUnitMoveSpeed(self.target) / 500)
    local damage = Abilities.PlagueStrike.FrostPlagueData[self.level] * (1 + speedLossPercent)
    UnitDamageTarget(self.caster, self.target, damage, false, true, ATTACK_TYPE_MAGIC, DAMAGE_TYPE_POISON, WEAPON_TYPE_WHOKNOWS)

    ExAddSpecialEffectTarget("Abilities/Weapons/ZigguratMissile/ZigguratMissile.mdl", self.target, "origin", Time.Delta)
end

return cls
