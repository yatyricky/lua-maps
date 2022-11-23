local EventCenter = require("Lib.EventCenter")
local Event = require("Lib.Event")
local UnitAttribute = require("Objects.UnitAttribute")
local Const = require("Config.Const")

EventCenter.RegisterPlayerUnitDamaging = Event.new()
EventCenter.RegisterPlayerUnitDamaged = Event.new()
---data {whichUnit=unit,target=unit,amount=real,attack=boolean,ranged=boolean,attackType=attacktype,damageType=damagetype,weaponType=weapontype,outResult=table}
EventCenter.Damage = Event.new()
---data: {caster=unit,target=unit,amount=real}
EventCenter.Heal = Event.new()
---{caster=caster,target=target,amount=amount,isPercentage=isPercentage}
EventCenter.HealMana = Event.new()
EventCenter.PlayerUnitAttackMiss = Event.new()

local SystemBase = require("System.SystemBase")

---@class DamageSystem : SystemBase
local cls = class("DamageSystem", SystemBase)

function cls:ctor()
    cls.super.ctor(self)
    local damagingTrigger = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(damagingTrigger, EVENT_PLAYER_UNIT_DAMAGING)
    ExTriggerAddAction(damagingTrigger, function()
        self:_response(self._damagingHandlers)
    end)

    local damagedTrigger = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(damagedTrigger, EVENT_PLAYER_UNIT_DAMAGED)
    ExTriggerAddAction(damagedTrigger, function()
        self:_response(self._damagedHandlers)
    end)

    --local enterTrigger = CreateTrigger()
    --TriggerRegisterEnterRegion(enterTrigger, CreateRegion(), Filter(function() return true end))
    --TriggerAddAction(enterTrigger, function()
    --    TriggerRegisterUnitEvent(damageTrigger, GetTriggerUnit(), EVENT_UNIT_DAMAGED)
    --end)

    self._damagingHandlers = {}
    self._damagedHandlers = {}
end

function cls:Awake()
    EventCenter.RegisterPlayerUnitDamaging:On(self, cls._registerDamaging)
    EventCenter.RegisterPlayerUnitDamaged:On(self, cls._registerDamaged)
    EventCenter.Damage:On(self, cls._onDamage)
    EventCenter.Heal:On(self, cls._onHeal)
    EventCenter.HealMana:On(self, cls._onHealMana)
end

function cls:OnEnable()
    EventCenter.RegisterPlayerUnitDamaging:Emit(function(caster, target, damage, weaponType, damageType, isAttack)
        --print("Damage from native")
        if not isAttack then
            --print("not attack, skip")
            return
        end

        local b = UnitAttribute.GetAttr(target)
        if b.dodge > 0 then
            if math.random() < b.dodge then
                BlzSetEventDamage(0)
                BlzSetEventWeaponType(WEAPON_TYPE_WHOKNOWS)
                ExTextMiss(target)

                EventCenter.PlayerUnitAttackMiss:Emit({
                    caster = caster,
                    target = target,
                })
                return
            end
        end

        local a = UnitAttribute.GetAttr(caster)
        damage = damage * math.max(1 + a.damageAmplification - b.damageReduction, 0)

        -- shield
        local bas = b.absorbShields
        if table.any(bas) then
            while #bas > 0 and damage > 0 do
                local shieldBuff = bas[1]
                if shieldBuff.shield >= damage then
                    shieldBuff.shield = shieldBuff.shield - damage
                    damage = 0
                else
                    damage = damage - shieldBuff.shield
                    shieldBuff.shield = 0
                end
                if shieldBuff.shield <= 0 then
                    EventCenter.KillBuff:Emit(shieldBuff)
                    table.remove(bas, 1)
                end
            end
        end

        BlzSetEventDamage(damage)
    end)
end

function cls:_registerDamaging(handler)
    table.insert(self._damagingHandlers, handler)
end

function cls:_registerDamaged(handler)
    table.insert(self._damagedHandlers, handler)
end

function cls:_response(whichHandlers)
    local damage = GetEventDamage()
    local caster = GetEventDamageSource()
    local target = BlzGetEventDamageTarget()
    local damageType = BlzGetEventDamageType()
    local weaponType = BlzGetEventWeaponType()
    local isAttack = BlzGetEventIsAttack()
    for _, v in ipairs(whichHandlers) do
        v(caster, target, damage, weaponType, damageType, isAttack)
    end
end

-- whichUnit, target, amount, attack, ranged, attackType, damageType, weaponType, outResult
function cls:_onDamage(d)
    --print("DamageEvent:", GetUnitName(d.whichUnit), GetUnitName(d.target), d.amount, d.attack, d.ranged, d.attackType, d.damageType, d.weaponType)
    local a = UnitAttribute.GetAttr(d.whichUnit)
    local b = UnitAttribute.GetAttr(d.target)
    if d.attack then
        if math.random() < b.dodge then
            d.outResult.hitResult = Const.HitResult_Miss
            EventCenter.PlayerUnitAttackMiss:Emit({
                caster = d.whichUnit,
                target = d.target,
            })
            ExTextMiss(d.target)
            return
        end
    end

    local amount = d.amount * (1 + a.damageAmplification - b.damageReduction)
    --print("DamageEvent-Native:", GetUnitName(d.whichUnit), GetUnitName(d.target), amount, d.attack, d.ranged, d.attackType, d.damageType, d.weaponType)
    UnitDamageTarget(d.whichUnit, d.target, amount, d.attack, d.ranged, d.attackType, d.damageType, d.weaponType)
    d.outResult.hitResult = Const.HitResult_Hit
    d.outResult.damage = amount
end

function cls:_onHeal(data)
    local current = GetUnitState(data.target, UNIT_STATE_LIFE)
    local attr = UnitAttribute.GetAttr(data.target)
    local healed = data.amount * (1 + attr.healingTaken)
    SetWidgetLife(data.target, current + healed)
end

function cls:_onHealMana(data)
    local current = GetUnitState(data.target, UNIT_STATE_MANA)
    local amount
    if data.isPercentage then
        amount = data.amount * GetUnitState(data.target, UNIT_STATE_MAX_MANA)
    else
        amount = data.amount
    end
    SetUnitState(data.target, UNIT_STATE_MANA, current + amount)
end

return cls
