-- 蛮兽打击

local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local Const = require("Config.Const")
local Timer = require("Lib.Timer")

--region meta

Abilities.MonstrousBlow = {
    ID = FourCC("A00B"),
    Duration = 2,
    Damage = 150,
}

BlzSetAbilityTooltip(Abilities.MonstrousBlow.ID, string.format("蛮兽打击"), 0)
BlzSetAbilityExtendedTooltip(Abilities.MonstrousBlow.ID, string.format("一次野蛮的攻击，对目标造成|cffff8c00%s|r点伤害并使其昏迷|cffff8c00%s|r秒。",
        Abilities.MonstrousBlow.Damage, Abilities.MonstrousBlow.Duration), 0)

--endregion

local cls = class("MonstrousBlow")

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Abilities.MonstrousBlow.ID,
    ---@param data ISpellData
    handler = function(data)
        UnitDamageTarget(data.caster, data.target, Abilities.MonstrousBlow.Damage, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WOOD_HEAVY_BASH)

        IssueImmediateOrderById(data.target, Const.OrderId_Stop)
        local sfx = AddSpecialEffectTarget("Abilities/Spells/Human/Thunderclap/ThunderclapTarget.mdl", data.target, "overhead")
        PauseUnit(data.target, true)
        local timer = Timer.new(function()
            PauseUnit(data.target, false)
            DestroyEffect(sfx)
        end, Abilities.MonstrousBlow.Duration, 1)
        timer:Start()
    end
})

return cls
