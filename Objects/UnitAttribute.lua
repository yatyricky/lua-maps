local Power = { 1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048 }
local Temp = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }

local PositiveAtk = {
    FourCC("A00C"),
    FourCC("A00D"),
    FourCC("A00E"),
    FourCC("A00F"),
    FourCC("A00G"),
    FourCC("A00H"),
    FourCC("A00I"),
    FourCC("A00J"),
    FourCC("A00K"),
    FourCC("A00L"),
    FourCC("A00M"),
    FourCC("A00N"),
}

local PositiveHp = {
    FourCC("A00O"),
    FourCC("A00P"),
    FourCC("A00Q"),
    FourCC("A00R"),
    FourCC("A00S"),
    FourCC("A00T"),
    FourCC("A00U"),
    FourCC("A00V"),
    FourCC("A00W"),
    FourCC("A00X"),
    FourCC("A00Y"),
    FourCC("A00Z"),
}

local function i2b(v)
    local bin = table.shallow(Temp)
    for i = #Power, 1, -1 do
        local b = Power[i]
        if v >= b then
            v = v - b
            bin[i] = 1
        end
    end
    return bin
end

---@class UnitAttribute
local cls = class("UnitAttribute")

cls.HeroAttributeType = {
    Strength = 1,
    Agility = 2,
    Intelligent = 3,
}

cls.tab = {}---@type table<unit, UnitAttribute>

---@return UnitAttribute
function cls.GetAttr(unit)
    local inst = cls.tab[unit]
    if not inst then
        inst = cls.new(unit)
        if unit == nil then
            print(GetStackTrace())
        end
        cls.tab[unit] = inst
    end

    return inst
end

function cls:ctor(unit)
    self.owner = unit

    self.baseAtk = BlzGetUnitBaseDamage(unit, 0) + (BlzGetUnitDiceSides(unit, 0) + 1) / 2 * BlzGetUnitDiceNumber(unit, 0)
    self.baseHp = BlzGetUnitMaxHP(unit)
    self.baseMs = GetUnitDefaultMoveSpeed(unit)

    self._atk = table.shallow(Temp)
    self.atk = 0

    self._hp = table.shallow(Temp)
    self.hp = 0

    self.ms = 0
    self.msp = 0

    self.dodge = 0

    self.damageAmplification = 0
    self.damageReduction = 0
    self.healingTaken = 0

    self.taunted = {} ---被嘲讽的目标
end

function cls:GetHeroMainAttr(type, ignoreBonus)
    if not IsUnitType(self.owner, UNIT_TYPE_HERO) then
        return 0
    end
    if type == cls.HeroAttributeType.Strength then
        return GetHeroStr(self.owner, not ignoreBonus)
    end
    if type == cls.HeroAttributeType.Agility then
        return GetHeroAgi(self.owner, not ignoreBonus)
    end
    if type == cls.HeroAttributeType.Intelligent then
        return GetHeroInt(self.owner, not ignoreBonus)
    end
    return 0
end

---@param type integer HeroAttributeType
function cls:SimAttack(type)
    return BlzGetUnitBaseDamage(self.owner, 0) + math.random(1, BlzGetUnitDiceSides(self.owner, 0)) * BlzGetUnitDiceNumber(self.owner, 0) + self:GetHeroMainAttr(type)
end

function cls:_reflect(targetValue, currentBits, lookup)
    local newBits = i2b(math.round(targetValue))
    for i, b in ipairs(newBits) do
        if b ~= currentBits[i] then
            if b == 1 then
                UnitAddAbility(self.owner, lookup[i])
                UnitMakeAbilityPermanent(self.owner, true, lookup[i])
            else
                UnitRemoveAbility(self.owner, lookup[i])
            end
            currentBits[i] = b
        end
    end
end

function cls:Commit()
    self:_reflect(self.atk, self._atk, PositiveAtk)
    self:_reflect(self.hp, self._hp, PositiveHp)

    local ms = self.baseMs * (1 + self.msp) + self.ms
    SetUnitMoveSpeed(self.owner, ms)
end

function cls:TauntedBy(caster, duration)
    table.insert(self.taunted, caster)
    coroutine.start(function()
        coroutine.wait(duration)
        table.iRemoveOneLeft(self.taunted, caster)
    end)
end

ExTriggerRegisterNewUnit(cls.GetAttr)

return cls
