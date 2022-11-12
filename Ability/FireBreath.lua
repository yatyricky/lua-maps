local Vector2 = require("Lib.Vector2")
local EventCenter = require("Lib.EventCenter")
local Timer = require("Lib.Timer")
local Abilities = require("Config.Abilities")
local Ease = require("Lib.Ease")
local BuffBase = require("Objects.BuffBase")

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
    AOE = 600,
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

---@class FireBreathBurn : BuffBase
local FireBreathBurn = class("FireBreathBurn", BuffBase)

function FireBreathBurn:Awake()
    self.charged = self.awakeData.charged
end

function FireBreathBurn:OnEnable()
    self.sfx = AddSpecialEffectTarget("Abilities/Spells/Other/BreathOfFire/BreathOfFireDamage.mdl", self.target, "overhead")
end

function FireBreathBurn:Update()
    EventCenter.Damage:Emit({
        whichUnit = self.caster,
        target = self.target,
        amount = Meta.DOT * (1 + Meta.ChargeAmp * self.charged),
        attack = false,
        ranged = true,
        attackType = ATTACK_TYPE_HERO,
        damageType = DAMAGE_TYPE_FIRE,
        weaponType = WEAPON_TYPE_WHOKNOWS,
        outResult = {}
    })
end

function FireBreathBurn:OnDisable()
    DestroyEffect(self.sfx)
end

function FireBreathBurn.Cast(caster, target, charged)
    local debuff = BuffBase.FindBuffByClassName(target, FireBreathBurn.__cname)
    if debuff then
        debuff:ResetDuration()
    else
        FireBreathBurn.new(caster, target, Meta.Duration, Meta.Interval, { charged = charged })
    end
end

local instances = {}

function cls:ctor(caster, x, y)
    self.charging = AddSpecialEffectTarget("Abilities/Weapons/RedDragonBreath/RedDragonMissile.mdl", caster, "weapon")
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
    DestroyEffect(self.charging)

    local casterPos = Vector2.FromUnit(self.caster)
    local dir = (self.targetPos - casterPos):SetNormalize()
    local offset = dir * 270
    local v = casterPos + offset
    local sfx = AddSpecialEffect("Abilities/Spells/Other/BreathOfFire/BreathOfFireMissile.mdl", v.x, v.y)
    BlzSetSpecialEffectYaw(sfx, math.atan2(dir.y, dir.x))
    local travelled = 0
    Ease.To(function()
        return travelled
    end, function(value)
        travelled = value
        local now = v + dir * travelled
        BlzSetSpecialEffectX(sfx, now.x)
        BlzSetSpecialEffectY(sfx, now.y)
    end, 600, 1)

    if self.charged < 1 then
        return
    end

    local casterPlayer = GetOwningPlayer(self.caster)
    local enumPos = casterPos - dir * 10
    ExGroupEnumUnitsInRange(enumPos.x, enumPos.y, 750, function(unit)
        if Vector2.Dot(dir, Vector2.FromUnit(unit):Sub(enumPos):SetNormalize()) > 0.28 and not ExIsUnitDead(unit) then
            if IsUnitEnemy(unit, casterPlayer) then
                EventCenter.Damage:Emit({
                    whichUnit = self.caster,
                    target = unit,
                    amount = Meta.Damage * (1 + Meta.ChargeAmp * self.charged),
                    attack = false,
                    ranged = true,
                    attackType = ATTACK_TYPE_HERO,
                    damageType = DAMAGE_TYPE_FIRE,
                    weaponType = WEAPON_TYPE_WHOKNOWS,
                    outResult = {}
                })
                FireBreathBurn.Cast(self.caster, unit, self.charged)
            else
                EventCenter.Heal:Emit({ caster = self.caster, target = unit, amount = Meta.Heal * (1 + Meta.ChargeAmp * self.charged) })
                ExAddSpecialEffectTarget("Abilities/Spells/Human/Heal/HealTarget.mdl", unit, "origin", 1)
            end
        end
    end)
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
        end
    end
})

return cls
