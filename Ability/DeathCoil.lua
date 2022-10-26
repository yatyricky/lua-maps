local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local BuffBase = require("Objects.BuffBase")
local ProjectileBase = require("Objects.ProjectileBase")
local FesteringWound = require("Ability.FesteringWound")

--region meta

Abilities.DeathCoil = {
    ID = FourCC("A007"),
    Heal = { 0.4, 0.6, 0.8 },
    Damage = { 100, 200, 300 },
    Wounds = { 3, 5, 7 },
    AmplificationPerStack = 0.05,
    ProcPerStack = 0.05,
    ManaCost = 100,
}

BlzSetAbilityResearchTooltip(Abilities.DeathCoil.ID, "学习死亡缠绕 - [|cffffcc00%d级|r]", 0)
BlzSetAbilityResearchExtendedTooltip(Abilities.DeathCoil.ID, string.format([[释放邪恶的能量，对一个敌对目标造成点伤害，或者为一个友方亡灵目标恢复生命值。目标身上的每层溃烂之伤会为死亡缠绕增幅|cffff8c005%%|r。并叠加溃烂之伤。普通攻击时，目标身上的每层溃烂之伤提供|cffff8c00%s%%|r的几率立即冷却死亡缠绕并且不消耗法力值。

|cff99ccff施法距离|r - 700
|cff99ccff法力消耗|r - %s点
|cff99ccff冷却时间|r - 8秒

|cffffcc001级|r - 恢复|cffff8c00%s%%|r生命值，造成|cffff8c00%s|r点伤害，叠加|cffff8c00%s|r层溃烂之伤。
|cffffcc002级|r - 恢复|cffff8c00%s%%|r生命值，造成|cffff8c00%s|r点伤害，叠加|cffff8c00%s|r层溃烂之伤。
|cffffcc003级|r - 恢复|cffff8c00%s%%|r生命值，造成|cffff8c00%s|r点伤害，叠加|cffff8c00%s|r层溃烂之伤。]],
        math.round(Abilities.DeathCoil.ProcPerStack * 100), Abilities.DeathCoil.ManaCost,
        math.round(Abilities.DeathCoil.Heal[1] * 100), Abilities.DeathCoil.Damage[1], Abilities.DeathCoil.Wounds[1],
        math.round(Abilities.DeathCoil.Heal[2] * 100), Abilities.DeathCoil.Damage[2], Abilities.DeathCoil.Wounds[2],
        math.round(Abilities.DeathCoil.Heal[3] * 100), Abilities.DeathCoil.Damage[3], Abilities.DeathCoil.Wounds[3]
), 0)

for i = 1, #Abilities.DeathCoil.Heal do
    BlzSetAbilityTooltip(Abilities.DeathCoil.ID, string.format("死亡缠绕 - [|cffffcc00%s级|r]", i), i - 1)
    BlzSetAbilityExtendedTooltip(Abilities.DeathCoil.ID, string.format(
            [[释放邪恶的能量，对一个敌对目标造成|cffff8c00%s|r点伤害，或者为一个友方亡灵目标恢复|cffff8c00%s%%|r生命值。目标身上的每层溃烂之伤会为死亡缠绕增幅|cffff8c005%%|r。并叠加|cffff8c00%s|r层溃烂之伤。普通攻击时，目标身上的每层溃烂之伤提供|cffff8c005%%|r的几率立即冷却死亡缠绕并且不消耗法力值。

|cff99ccff施法距离|r - 700
|cff99ccff法力消耗|r - 100点
|cff99ccff冷却时间|r - 8秒]],
            Abilities.DeathCoil.Damage[i], math.round(Abilities.DeathCoil.Heal[i] * 100), Abilities.DeathCoil.Wounds[i]),
            i - 1)
end

--endregion

local cls = class("DeathCoil")

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Abilities.DeathCoil.ID,
    ---@param data ISpellData
    handler = function(data)
        ProjectileBase.new(data.caster, data.target, "Abilities/Spells/Undead/DeathCoil/DeathCoilMissile.mdl", 600, function()
            local level = GetUnitAbilityLevel(data.caster, data.abilityId)
            if IsUnitAlly(data.target, GetOwningPlayer(data.caster)) then
                -- 友军，治疗
                EventCenter.Heal:Emit({
                    caster = data.caster,
                    target = data.target,
                    amount = Abilities.DeathCoil.Heal[level] * GetUnitState(data.target, UNIT_STATE_MAX_LIFE),
                })
            else
                -- 敌军，伤害+debuff
                local debuff = BuffBase.FindBuffByClassName(data.target, FesteringWound.__cname)
                local stack = debuff and debuff.stack or 0
                local damage = Abilities.DeathCoil.Damage[level] * (1 + Abilities.DeathCoil.AmplificationPerStack * stack)
                UnitDamageTarget(data.caster, data.target, damage, false, true, ATTACK_TYPE_HERO, DAMAGE_TYPE_MAGIC, WEAPON_TYPE_WHOKNOWS)

                -- 并叠加溃烂之伤
                if debuff then
                    debuff:IncreaseStack(Abilities.DeathCoil.Wounds[level])
                else
                    debuff = FesteringWound.new(data.caster, data.target, Abilities.FesteringWound.Duration, 9999, {})
                    debuff:IncreaseStack(Abilities.DeathCoil.Wounds[level] - 1)
                end
            end

            -- sfx
            ExAddSpecialEffectTarget("Abilities/Spells/Undead/DeathCoil/DeathCoilSpecialArt.mdl", data.target, "origin", 2)
        end, nil)
    end
})

EventCenter.RegisterPlayerUnitSpellEndCast:Emit({
    id = Abilities.DeathCoil.ID,
    ---@param data ISpellData
    handler = function(data)
        local level = GetUnitAbilityLevel(data.caster, data.abilityId)
        BlzSetUnitAbilityManaCost(data.caster, Abilities.DeathCoil.ID, level - 1, Abilities.DeathCoil.ManaCost)
        IssueImmediateOrder(data.caster, "slowoff")
    end
})

-- 普通攻击时，目标身上的每层溃烂之伤提供5%%的几率立即冷却死亡缠绕并且不消耗法力值。
EventCenter.RegisterPlayerUnitDamaged:Emit(function(caster, target, _, _, _, isAttack)
    if not isAttack then
        return
    end

    local level = GetUnitAbilityLevel(caster, Abilities.DeathCoil.ID)
    if level <= 0 then
        return
    end

    local debuff = BuffBase.FindBuffByClassName(target, FesteringWound.__cname)
    if not debuff then
        return
    end

    local chance = math.random() < debuff.stack * Abilities.DeathCoil.ProcPerStack
    if chance then
        BlzEndUnitAbilityCooldown(caster, Abilities.DeathCoil.ID)
        BlzSetUnitAbilityManaCost(caster, Abilities.DeathCoil.ID, level - 1, 0)
        IssueImmediateOrder(caster, "slowon")
    end
end)

return cls
