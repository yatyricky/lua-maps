local Utils = require("Lib.Utils")

local setmetatable = setmetatable
local type = type
local rawget = rawget
local m_sqrt = math.sqrt

local GetUnitX = GetUnitX
local GetUnitY = GetUnitY

---@class Vector3
local cls = {}

cls._loc = Location(0, 0)

local function getTerrainZ(x, y)
    MoveLocation(cls._loc, x, y)
    return GetLocationZ(cls._loc)
end

---@return Vector3
function cls.new(x, y, z)
    x = x or 0
    y = y or 0
    return setmetatable({
        x = x,
        y = y,
        z = z or getTerrainZ(x, y),
    }, cls)
end

local new = cls.new

---@param unit unit
function cls.FromUnit(unit)
    local x = GetUnitX(unit)
    local y = GetUnitY(unit)
    return new(x, y, getTerrainZ(x, y) + GetUnitFlyHeight(unit))
end

--function cls.InsideUnitCircle()
--    local angle = math.random() * math.pi * 2
--    return new(math.cos(angle), math.sin(angle))
--end

---@param unit unit
function cls:MoveToUnit(unit)
    self.x = GetUnitX(unit)
    self.y = GetUnitY(unit)
    self.z = getTerrainZ(self.x, self.y) + GetUnitFlyHeight(unit)
    return self
end

---@param unit unit
---@param mode integer modes. 1: force flying. 2: force to ground. other|Nil: flying units fly/ ground units grounded
function cls:UnitMoveTo(unit, mode)
    local tz = getTerrainZ(self.x, self.y)
    local defaultFlyHeight = GetUnitDefaultFlyHeight(unit)
    local minZ = tz + defaultFlyHeight
    SetUnitPosition(unit, self.x, self.y)
    if mode == 1 then
        Utils.SetUnitFlyable(unit)
        SetUnitFlyHeight(unit, math.max(minZ, self.z) - minZ, 0)
    elseif mode == 2 then
        SetUnitFlyHeight(unit, defaultFlyHeight, 0)
    else
        if IsUnitType(unit, UNIT_TYPE_FLYING) then
            SetUnitFlyHeight(unit, math.max(minZ, self.z) - minZ, 0)
        else
            SetUnitFlyHeight(unit, defaultFlyHeight, 0)
        end
    end
    return self
end

---@param other Vector3
function cls:SetTo(other)
    self.x = other.x
    self.y = other.y
    self.z = other.z
    return
end

---@param other Vector3
function cls:Add(other)
    self.x = self.x + other.x
    self.y = self.y + other.y
    self.z = self.z + other.z
    return self
end

---@param other Vector3
function cls:Sub(other)
    self.x = self.x - other.x
    self.y = self.y - other.y
    self.z = self.z - other.z
    return self
end

---@param d real
function cls:Div(d)
    self.x = self.x / d
    self.y = self.y / d
    self.z = self.z / d
    return self
end

---@param d real
function cls:Mul(d)
    self.x = self.x * d
    self.y = self.y * d
    self.z = self.z * d
    return self
end

function cls:SetNormalize()
    local magnitude = self:GetMagnitude()

    if magnitude > 1e-05 then
        self:Div(magnitude)
    else
        self.x = 0
        self.y = 0
        self.z = 0
    end

    return self
end

function cls:SetMagnitude(len)
    self:SetNormalize():Mul(len)
    return self
end

function cls:Clone()
    return new(self.x, self.y, self.z)
end

function cls:GetTerrainZ()
    return getTerrainZ(self.x, self.y)
end

function cls:GetMagnitude()
    return m_sqrt(self:SqrMagnitude())
end

function cls:SqrMagnitude()
    return self.x * self.x + self.y * self.y + self.z * self.z
end

function cls.Dot(lhs, rhs)
    return lhs.x * rhs.x + lhs.y * rhs.y + lhs.z * rhs.z
end

function cls.Scale(a, b)
    local x = a.x * b.x
    local y = a.y * b.y
    local z = a.z * b.z
    return new(x, y, z)
end

function cls.Cross(lhs, rhs)
    local x = lhs.y * rhs.z - lhs.z * rhs.y
    local y = lhs.z * rhs.x - lhs.x * rhs.z
    local z = lhs.x * rhs.y - lhs.y * rhs.x
    return new(x, y, z)
end

function cls.Project(v, onNormal)
    local num = onNormal:SqrMagnitude()

    if num < 0.0001 then
        return new(0, 0, 0)
    end

    local num2 = cls.Dot(v, onNormal)
    local v3 = onNormal:Clone()
    v3:Mul(num2 / num)
    return v3
end

function cls.ProjectOnPlane(v, planeNormal)
    local v3 = cls.Project(v, planeNormal)
    v3:Mul(-1)
    v3:Add(v)
    return v3
end

---@return string
function cls:tostring()
    return string.format("(%f,%f,%f)", self.x, self.y, self.z)
end

function cls.__index(_, k)
    return rawget(cls, k)
end

function cls.__add(a, b)
    return new(a.x + b.x, a.y + b.y, a.z + b.z)
end

---@return Vector3
function cls.__sub(a, b)
    return new(a.x - b.x, a.y - b.y, a.z - b.z)
end

function cls.__div(v, d)
    return new(v.x / d, v.y / d, v.y / d)
end

function cls.__mul(a, d)
    if type(d) == "number" then
        return new(a.x * d, a.y * d, a.z * d)
    else
        return a:Clone():MulQuaternion(d)
    end
end

function cls.__unm(v)
    return new(-v.x, -v.y, -v.z)
end

function cls.__eq(a, b)
    return ((a.x - b.x) ^ 2 + (a.y - b.y) ^ 2 + (a.z - b.z) ^ 2) < 9.999999e-11
end

function cls.up()
    return new(0, 0, 1)
end

function cls.down()
    return new(0, 0, -1)
end

function cls.right()
    return new(1, 0, 0)
end

function cls.left()
    return new(-1, 0, 0)
end

function cls.forward()
    return new(0, 1, 0)
end

function cls.back()
    return new(0, -1, 0)
end

function cls.zero()
    return new(0, 0, 0)
end

function cls.one()
    return new(1, 1, 1)
end

setmetatable(cls, cls)

return cls
