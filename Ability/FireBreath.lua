local Vector2 = require("Lib.Vector2")
local EventCenter = require("Lib.EventCenter")
local Timer = require("Lib.Timer")
local Pill = require("Lib.Pill")
local Circle = require("Lib.Circle")
local UnitAttribute = require("Objects.UnitAttribute")
local Abilities = require("Config.Abilities")

local cls = class("FireBreath")

local Meta = {
    ID = FourCC("A01D"),
    Duration = 6,
    Interval = 2,
    ChargeInterval = 1,
    ChargeAmp = 0.15,
    ChannelDuration = 3,
    Damage = 80,
    DOT = 10,
    Heal = 160,
}

BlzSetAbilityResearchTooltip(Meta.ID, "学习火焰吐息 - [|cffffcc00%d级|r]", 0)
BlzSetAbilityResearchExtendedTooltip(Meta.ID, string.format([[深吸一口气然后喷出，造成前方锥形龙息并击飞的效果，对敌军造成伤害并在接下来的|cffff8c00%s|r秒内每|cffff8c00%s|r秒灼烧目标，或者治疗友军单位。每蓄力|cffff8c00%s|r秒可以使效果增幅|cffff8c00%s|r，最多|cffff8c00%s|r秒。

|cff99ccff冷却时间|r - 10秒

|cffffcc001级|r - 造成|cffff8c00%s|r点基础伤害，|cffff8c00%s|r点持续伤害，|cffff8c00%s|r点治疗。]],
        Meta.Duration, Meta.Interval, Meta.ChargeInterval, string.formatPercentage(Meta.ChargeAmp), Meta.ChannelDuration,
        Meta.Damage, Meta.DOT, Meta.Heal
), 0)

for i = 1, 1 do
    BlzSetAbilityTooltip(Meta.ID, string.format("火焰吐息 - [|cffffcc00%s级|r]", i), i - 1)
    BlzSetAbilityExtendedTooltip(Meta.ID, string.format(
            [[深吸一口气然后喷出，造成前方锥形龙息并击飞的效果，对敌军造成|cffff8c00%s|r点伤害并在接下来的|cffff8c00%s|r秒内每|cffff8c00%s|r秒灼烧目标，造成|cffff8c00%s|r点伤害，或者治疗友军单位|cffff8c00%s|r点生命。每蓄力|cffff8c00%s|r秒可以使效果增幅|cffff8c00%s|r，最多|cffff8c00%s|r秒。

|cff99ccff冷却时间|r - 10秒]],
            Meta.Damage, Meta.Duration, Meta.Interval, Meta.DOT, Meta.Heal, Meta.ChargeInterval, string.formatPercentage(Meta.ChargeAmp), Meta.ChannelDuration
    ), i - 1)
end

Abilities.FireBreath = Meta

local instances = {}

function cls:ctor(caster, x, y)
    self.charging = AddSpecialEffect("Abilities/Weapons/RedDragonBreath/RedDragonMissile.mdl", GetUnitX(caster), GetUnitY(caster))
    BlzSetSpecialEffectScale(self.charging, 0.1)
    self.charged = 0
    self.caster = caster
    self.targetPos = Vector2.new(x, y)

    self.timer = Timer.new(function()
        self.charged = self.charged + 1
        BlzSetSpecialEffectScale(self.charging, 0.1 + self.charged * 0.3)
    end, 1, -1)
    self.timer:Start()
end

function cls:stop()
    self.timer:Stop()

    local sfx = ExAddSpecialEffect("Abilities/Spells/Other/BreathOfFire/BreathOfFireMissile.mdl", GetUnitX(self.caster), GetUnitY(self.caster), 1)
    local dir = (self.targetPos - Vector2.FromUnit(self.caster)):SetNormalize()
    BlzSetSpecialEffectYaw(sfx, math.atan2(dir.y, dir.x))
end

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        instances[data.caster] = cls.new(data.caster, data.x, data.y)
    end
})

EventCenter.RegisterPlayerUnitSpellEndCast:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        local inst = instances[data.caster]
        if inst then
            inst:stop()
            instances[data.caster] = nil
        else
            print("Disintegrate end but no instance")
        end
    end
})

return cls
