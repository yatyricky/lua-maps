local BuffBase = require("Buff.BuffBase")
local Abilities = require("Config.Abilities")

---@class UnholyPlague : BuffBase
local cls = class("UnholyPlague", BuffBase)

function cls:Awake()
    self.level = self.awakeData.level
end

function cls:OnEnable()
    self.sfx = AddSpecialEffectTarget("units/undead/PlagueCloud/PlagueCloud.mdl", self.target, "origin")
end

function cls:Update()
    local hpLossPercent = 1 - GetUnitState(self.target, UNIT_STATE_LIFE) / GetUnitState(self.target, UNIT_STATE_MAX_LIFE)
    local damage = Abilities.PlagueStrike.UnholyPlagueData[self.level] * (1 + hpLossPercent)
    UnitDamageTarget(self.caster, self.target, damage, false, true, ATTACK_TYPE_MAGIC, DAMAGE_TYPE_POISON, WEAPON_TYPE_WHOKNOWS)
end

function cls:OnDisable()
    DestroyEffect(self.sfx)
end

return cls
