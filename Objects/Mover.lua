local EventCenter = require("Lib.EventCenter")
local Vector3 = require("Lib.Vector3")

---@class Mover
local cls = class("Mover")

cls.unitInstMap = {} ---@type table<unit, Mover>
cls.effectInstMap = {} ---@type table<effect, Mover>

---@param inst Mover
function cls.LinearMoveBehaviour(inst, dt)
    local dest = inst:GetTargetPos()
    local norm = (dest - inst.pos):SetNormalize()
    local dir = norm * ((inst.speed or 600) * dt)
    inst.pos:Add(dir)

    if inst.attachType == cls.AttachType.Effect then
        BlzSetSpecialEffectPosition(inst.effect, inst.pos.x, inst.pos.y, inst.pos.z)
        local p = Vector3.ProjectOnPlane(norm, Vector3.up()):SetNormalize()
        BlzSetSpecialEffectYaw(inst.effect, math.atan2(p.y, p.x)) -- todo use quaternion
    elseif inst.attachType == cls.AttachType.Unit then
        inst.pos:UnitMoveTo(inst.unit)
        local p = Vector3.ProjectOnPlane(norm, Vector3.up()):SetNormalize()
        SetUnitFacing(inst.unit, (math.atan2(p.y, p.x)) * bj_RADTODEG)
    end

    return dest:Sub(inst.pos):Magnitude()
end

function cls.GetOrCreateFromUnit(unit, onArrived, moveBehaviour)
    local inst = cls.unitInstMap[unit]
    if inst then
        inst.onArrived = onArrived
        inst.moveBehaviour = moveBehaviour or cls.LinearMoveBehaviour
        return inst
    end

    inst = cls.new(onArrived, moveBehaviour)
    inst:InitAttachUnit(unit)
    return inst
end

function cls.GetOrCreateFromEffect(effect, onArrived, moveBehaviour, x, y, z)
    local inst = cls.effectInstMap[effect]
    if inst then
        inst.onArrived = onArrived
        inst.moveBehaviour = moveBehaviour or cls.LinearMoveBehaviour
        return inst
    end

    inst = cls.new(onArrived, moveBehaviour)
    inst:InitAttachEffect(effect, x, y, z)
    return inst
end

function cls:ctor(onArrived, moveBehaviour)
    self.moveBehaviour = moveBehaviour or cls.LinearMoveBehaviour
    self.attachType = cls.AttachType.None
    self.destType = cls.DestinationType.None
    self.onArrived = onArrived
    EventCenter.NewMover:Emit(self)
end

function cls:InitAttachUnit(unit)
    self.pos = Vector3.FromUnit(unit)
    self.attachType = cls.AttachType.Unit
    self.unit = unit
    cls.unitInstMap[unit] = self
    return self
end

function cls:InitAttachEffect(effect, x, y, z)
    self.pos = Vector3.new(x, y, z)
    self.attachType = cls.AttachType.Effect
    self.effect = effect
    return self
end

---@param vec3 Vector3
function cls:InitDestinationPoint(vec3)
    self.destType = cls.DestinationType.Point
    self.targetPoint = vec3
    return self
end

function cls:InitDestinationUnit(unit)
    self.destType = cls.DestinationType.Unit
    self.targetUnit = unit
    return self
end

function cls:GetTargetPos()
    if self.destType == cls.DestinationType.Unit then
        return Vector3.FromUnit(self.targetUnit)
    elseif self.destType == cls.DestinationType.Point then
        return self.targetPoint:Clone()
    else
        return Vector3.zero()
    end
end

function cls:CheckArrived(distance)
    if self.attachType == cls.AttachType.Effect then
        return distance < 1
    elseif self.attachType == cls.AttachType.Unit then
        return distance < 96
    elseif self.attachType == cls.AttachType.None then
        return true
    else
        return true
    end
end

return cls
