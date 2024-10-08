-- 腐臭壁垒

local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local BuffBase = require("Objects.BuffBase")

--region meta

Abilities.PutridBulwark = {
    ID = FourCC("A014"),
    Reduction = 0.5,
    Duration = 10,
}

BlzSetAbilityTooltip(Abilities.PutridBulwark.ID, string.format("腐臭壁垒", 0), 0)
BlzSetAbilityExtendedTooltip(Abilities.PutridBulwark.ID, string.format("发出固守咆哮，受到的所有伤害降低|cffff8c00%s|r，持续|cffff8c00%s|r秒。",
        string.formatPercentage(Abilities.PutridBulwark.Reduction), Abilities.PutridBulwark.Duration), 0)

--endregion

---@class PutridBulwark : BuffBase
local cls = class("PutridBulwark", BuffBase)

function cls:OnEnable()
    self.sfx = AddSpecialEffectTarget("Abilities/Spells/Items/AIda/AIdaTarget.mdl", self.target, "overhead")
    BlzSetSpecialEffectColor(self.sfx, 96, 255, 96)
end

function cls:OnDisable()
    DestroyEffect(self.sfx)
end

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Abilities.PutridBulwark.ID,
    ---@param data ISpellData
    handler = function(data)
        ExAddSpecialEffectTarget("Abilities/Spells/Other/HowlOfTerror/HowlCaster.mdl", data.caster, "overhead", 2)
        local buff = BuffBase.FindBuffByClassName(data.caster, cls.__cname)
        if buff then
            buff:ResetDuration()
        else
            buff = cls.new(data.caster, data.caster, Abilities.PutridBulwark.Duration, 999)
        end
    end
})

EventCenter.RegisterPlayerUnitDamaging:Emit(function(caster, target, damage, weaponType, damageType, isAttack)
    local buff = BuffBase.FindBuffByClassName(target, cls.__cname)
    if not buff then
        return
    end

    BlzSetEventDamage(damage * Abilities.PutridBulwark.Reduction)
end)

return cls
