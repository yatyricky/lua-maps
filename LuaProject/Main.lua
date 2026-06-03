SF__ = SF__ or {}
function SF__.TypeIs__(obj, target)
    if obj == nil then return false end
    local type = obj.__sf_type
    while type ~= nil do
        if type == target then return true end
        if type.__sf_interfaces ~= nil and type.__sf_interfaces[target] then return true end
        type = type.__sf_base
    end
    return false
end

function SF__.TypeAs__(obj, target)
    if SF__.TypeIs__(obj, target) then return obj end
    return nil
end

function SF__.StrConcat__(...)
    local result = ""
    for i = 1, select("#", ...) do
        local part = select(i, ...)
        if part ~= nil then
            result = result .. tostring(part)
        end
    end
    return result
end

SF__.CorTimerPool__ = SF__.CorTimerPool__ or {}
SF__.CorTimerPoolSize__ = SF__.CorTimerPoolSize__ or 0
SF__.CorMaxTimerPoolSize__ = SF__.CorMaxTimerPoolSize__ or 256

function SF__.CorAcquireTimer__()
    local size = SF__.CorTimerPoolSize__
    if size > 0 then
        local timer = SF__.CorTimerPool__[size]
        SF__.CorTimerPool__[size] = nil
        SF__.CorTimerPoolSize__ = size - 1
        return timer
    end
    return CreateTimer()
end

function SF__.CorReleaseTimer__(timer)
    PauseTimer(timer)
    local size = SF__.CorTimerPoolSize__
    if size < SF__.CorMaxTimerPoolSize__ then
        size = size + 1
        SF__.CorTimerPool__[size] = timer
        SF__.CorTimerPoolSize__ = size
    else
        DestroyTimer(timer)
    end
end

function SF__.CorRun__(fn)
    local thread = coroutine.create(fn)
    local ok, err = coroutine.resume(thread)
    if not ok then error(err) end
    return thread
end

function SF__.CorWait__(milliseconds)
    if milliseconds <= 0 then return end
    local thread = coroutine.running()
    if thread == nil then error("CorWait must be called from a coroutine") end
    if coroutine.isyieldable ~= nil and not coroutine.isyieldable() then error("CorWait cannot yield from this context") end
    local timer = SF__.CorAcquireTimer__()
    TimerStart(timer, milliseconds / 1000, false, function()
        local ok, err = coroutine.resume(thread)
        SF__.CorReleaseTimer__(timer)
        if not ok then error(err) end
    end)
    return coroutine.yield()
end

require("Lib.class")
SF__.LuaWrapper = SF__.LuaWrapper or {}
-- LuaWrapper.HitResult
SF__.LuaWrapper.HitResult = SF__.LuaWrapper.HitResult or {}
SF__.LuaWrapper.HitResult.Hit = 1
SF__.LuaWrapper.HitResult.Miss = 2
SF__.LuaWrapper.HitResult.Critical = 4

-- TargetType
SF__.TargetType = SF__.TargetType or {}
SF__.TargetType.Unit = 0
SF__.TargetType.Point = 1

-- UnitVec3Mode
SF__.UnitVec3Mode = SF__.UnitVec3Mode or {}
SF__.UnitVec3Mode.ForceFlying = 0
SF__.UnitVec3Mode.ForceGround = 1
-- <summary>
-- Flying units fly, ground units grounded.
-- </summary>
--
SF__.UnitVec3Mode.Auto = 2

-- Component
SF__.Component = SF__.Component or {}
SF__.Component.Name = "Component"
SF__.Component.FullName = "Component"
function SF__.Component:GetInspectorText()
    return ""
end

function SF__.Component:Awake()
end

function SF__.Component:OnEnable()
end

function SF__.Component:Start()
end

function SF__.Component:Update()
end

function SF__.Component:LateUpdate()
end

function SF__.Component:OnDisable()
end

function SF__.Component:OnDestroy()
end

function SF__.Component.__Init(self)
    self.__sf_type = SF__.Component
    self.gameObject = nil
end

function SF__.Component.New()
    local self = setmetatable({}, { __index = SF__.Component })
    SF__.Component.__Init(self)
    return self
end
-- Vector3
SF__.Vector3 = SF__.Vector3 or {}
SF__.Vector3.Name = "Vector3"
SF__.Vector3.FullName = "Vector3"
function SF__.Vector3.get_zero()
    return 0, 0, 0
end

function SF__.Vector3.get_up()
    return 0, 0, 1
end

function SF__.Vector3.get_down()
    return 0, 0, (-1)
end

function SF__.Vector3.get_right()
    return 1, 0, 0
end

function SF__.Vector3.get_left()
    return (-1), 0, 0
end

function SF__.Vector3.get_forward()
    return 0, 1, 0
end

function SF__.Vector3.get_back()
    return 0, (-1), 0
end

function SF__.Vector3.get_one()
    return 1, 1, 1
end

function SF__.Vector3.op_Addition(a__x164, a__y165, a__z166, b__x167, b__y168, b__z169)
    return (a__x164 + b__x167), (a__y165 + b__y168), (a__z166 + b__z169)
end

function SF__.Vector3.op_UnaryNegation(a__x170, a__y171, a__z172)
    return (-a__x170), (-a__y171), (-a__z172)
end

function SF__.Vector3.op_Subtraction(a__x173, a__y174, a__z175, b__x176, b__y177, b__z178)
    return (a__x173 - b__x176), (a__y174 - b__y177), (a__z175 - b__z178)
end

function SF__.Vector3.op_Multiply__vector3f(v__x179, v__y180, v__z181, f182)
    return (v__x179 * f182), (v__y180 * f182), (v__z181 * f182)
end

function SF__.Vector3.op_Multiply__fvector3(f183, v__x184, v__y185, v__z186)
    return (v__x184 * f183), (v__y185 * f183), (v__z186 * f183)
end

function SF__.Vector3.op_Division(v__x187, v__y188, v__z189, f190)
    return (v__x187 / f190), (v__y188 / f190), (v__z189 / f190)
end

-- <summary>
-- Warcraft III world space here is right-handed: +x points right, +y points away, +z points up.
-- That means Cross((1,0,0), (0,1,0)) == (0,0,1).
-- </summary>
--
function SF__.Vector3.Cross(a__x191, a__y192, a__z193, b__x194, b__y195, b__z196)
    return ((a__y192 * b__z196) - (a__z193 * b__y195)), ((a__z193 * b__x194) - (a__x191 * b__z196)), ((a__x191 * b__y195) - (a__y192 * b__x194))
end

function SF__.Vector3.Distance(a__x197, a__y198, a__z199, b__x200, b__y201, b__z202)
    return SF__.Vector3.get_magnitude(SF__.Vector3.op_Subtraction(a__x197, a__y198, a__z199, b__x200, b__y201, b__z202))
end

function SF__.Vector3.Dot(a__x203, a__y204, a__z205, b__x206, b__y207, b__z208)
    return (((a__x203 * b__x206) + (a__y204 * b__y207)) + (a__z205 * b__z208))
end

function SF__.Vector3.MoveTowards(current__x, current__y, current__z, target__x, target__y, target__z, maxDistanceDelta)
    local toVector__x, toVector__y, toVector__z = SF__.Vector3.op_Subtraction(target__x, target__y, target__z, current__x, current__y, current__z)
    local dist = SF__.Vector3.get_magnitude(toVector__x, toVector__y, toVector__z)
    if ((dist <= maxDistanceDelta) or (dist == 0)) then
        return target__x, target__y, target__z
    end
    return SF__.Vector3.op_Addition(current__x, current__y, current__z, SF__.Vector3.op_Division(toVector__x, toVector__y, toVector__z, (dist / maxDistanceDelta)))
end

function SF__.Vector3.Project(v__x209, v__y210, v__z211, onNormal__x, onNormal__y, onNormal__z)
    local sqrMag = SF__.Vector3.Dot(onNormal__x, onNormal__y, onNormal__z, onNormal__x, onNormal__y, onNormal__z)
    if (sqrMag < 0.0001) then
        return SF__.Vector3.get_zero()
    end
    local dot = SF__.Vector3.Dot(v__x209, v__y210, v__z211, onNormal__x, onNormal__y, onNormal__z)
    return SF__.Vector3.op_Multiply__vector3f(onNormal__x, onNormal__y, onNormal__z, (dot / sqrMag))
end

function SF__.Vector3.ProjectOnPlane(v__x212, v__y213, v__z214, planeNormal__x, planeNormal__y, planeNormal__z)
    return SF__.Vector3.op_Subtraction(v__x212, v__y213, v__z214, SF__.Vector3.Project(v__x212, v__y213, v__z214, planeNormal__x, planeNormal__y, planeNormal__z))
end

function SF__.Vector3.Reflect(inDirection__x, inDirection__y, inDirection__z, inNormal__x, inNormal__y, inNormal__z)
    return SF__.Vector3.op_Subtraction(inDirection__x, inDirection__y, inDirection__z, SF__.Vector3.op_Multiply__fvector3((2 * SF__.Vector3.Dot(inDirection__x, inDirection__y, inDirection__z, inNormal__x, inNormal__y, inNormal__z)), inNormal__x, inNormal__y, inNormal__z))
end

function SF__.Vector3.RotateTowards(current__x215, current__y216, current__z217, target__x218, target__y219, target__z220, maxRadiansDelta, maxMagnitudeDelta)
    local currentMag = SF__.Vector3.get_magnitude(current__x215, current__y216, current__z217)
    local targetMag = SF__.Vector3.get_magnitude(target__x218, target__y219, target__z220)
    if ((currentMag == 0) or (targetMag == 0)) then
        return SF__.Vector3.MoveTowards(current__x215, current__y216, current__z217, target__x218, target__y219, target__z220, maxMagnitudeDelta)
    end
    local currentNorm__x, currentNorm__y, currentNorm__z = SF__.Vector3.op_Division(current__x215, current__y216, current__z217, currentMag)
    local targetNorm__x, targetNorm__y, targetNorm__z = SF__.Vector3.op_Division(target__x218, target__y219, target__z220, targetMag)
    local dot221 = math.clamp(SF__.Vector3.Dot(currentNorm__x, currentNorm__y, currentNorm__z, targetNorm__x, targetNorm__y, targetNorm__z), (-1), 1)
    local angle222 = math.acos(dot221)
    if (angle222 == 0) then
        return SF__.Vector3.MoveTowards(current__x215, current__y216, current__z217, target__x218, target__y219, target__z220, maxMagnitudeDelta)
    end
    local t223 = math.min(1, (maxRadiansDelta / angle222))
    local newDir__x, newDir__y, newDir__z = SF__.Vector3.Slerp(currentNorm__x, currentNorm__y, currentNorm__z, targetNorm__x, targetNorm__y, targetNorm__z, t223)
    local newMag = math.moveTowards(currentMag, targetMag, maxMagnitudeDelta)
    return SF__.Vector3.op_Multiply__vector3f(newDir__x, newDir__y, newDir__z, newMag)
end

function SF__.Vector3.Scale(a__x224, a__y225, a__z226, b__x227, b__y228, b__z229)
    return (a__x224 * b__x227), (a__y225 * b__y228), (a__z226 * b__z229)
end

function SF__.Vector3.Slerp(a__x230, a__y231, a__z232, b__x233, b__y234, b__z235, t236)
    local magA = SF__.Vector3.get_magnitude(a__x230, a__y231, a__z232)
    local magB = SF__.Vector3.get_magnitude(b__x233, b__y234, b__z235)
    if ((magA == 0) or (magB == 0)) then
        return SF__.Vector3.MoveTowards(a__x230, a__y231, a__z232, b__x233, b__y234, b__z235, math.huge)
    end
    local normA__x, normA__y, normA__z = SF__.Vector3.op_Division(a__x230, a__y231, a__z232, magA)
    local normB__x, normB__y, normB__z = SF__.Vector3.op_Division(b__x233, b__y234, b__z235, magB)
    local dot237 = math.clamp(SF__.Vector3.Dot(normA__x, normA__y, normA__z, normB__x, normB__y, normB__z), (-1), 1)
    local angle238 = math.acos(dot237)
    local sinAngle = math.sin(angle238)
    if (sinAngle < 0.0001) then
        return SF__.Vector3.MoveTowards(a__x230, a__y231, a__z232, b__x233, b__y234, b__z235, math.huge)
    end
    local tAngle = (angle238 * t236)
    local sinTA = math.sin(tAngle)
    local sinTOneMinusA = math.sin((angle238 - tAngle))
    local newDir__x245, newDir__y246, newDir__z247 = (function()
        local v__x242, v__y243, v__z244 = (function()
            local a__x239, a__y240, a__z241 = SF__.Vector3.op_Multiply__vector3f(normA__x, normA__y, normA__z, sinTOneMinusA)
            return SF__.Vector3.op_Addition(a__x239, a__y240, a__z241, SF__.Vector3.op_Multiply__vector3f(normB__x, normB__y, normB__z, sinTA))
        end)()
        return SF__.Vector3.op_Division(v__x242, v__y243, v__z244, sinAngle)
    end)()
    local newMag248 = math.lerp(magA, magB, t236)
    return SF__.Vector3.op_Multiply__vector3f(newDir__x245, newDir__y246, newDir__z247, newMag248)
end

function SF__.Vector3._getTerrainZ(x249, y250)
    MoveLocation(SF__.Vector3._loc, x249, y250)
    return GetLocationZ(SF__.Vector3._loc)
end

function SF__.Vector3.FromUnit(u251)
    local x252 = GetUnitX(u251)
    local y253 = GetUnitY(u251)
    return x252, y253, (SF__.Vector3._getTerrainZ(x252, y253) + GetUnitFlyHeight(u251))
end

function SF__.Vector3.get_sqrMagnitude(self__x254, self__y255, self__z256)
    return (((self__x254 * self__x254) + (self__y255 * self__y255)) + (self__z256 * self__z256))
end

function SF__.Vector3.get_magnitude(self__x257, self__y258, self__z259)
    return math.sqrt(SF__.Vector3.get_sqrMagnitude(self__x257, self__y258, self__z259))
end

function SF__.Vector3.get_normalized(self__x260, self__y261, self__z262)
    local mag263 = SF__.Vector3.get_magnitude(self__x260, self__y261, self__z262)
    if (mag263 < 0.0001) then
        return SF__.Vector3.get_zero()
    end
    return SF__.Vector3.op_Division(self__x260, self__y261, self__z262, mag263)
end

function SF__.Vector3.ClampMagnitude(self__x267, self__y268, self__z269, mag270)
    return (function()
        local v__x271, v__y272, v__z273 = SF__.Vector3.get_normalized(self__x267, self__y268, self__z269)
        return SF__.Vector3.op_Multiply__vector3f(v__x271, v__y272, v__z273, mag270)
    end)()
end

function SF__.Vector3.ToString(self__x274, self__y275, self__z276)
    return SF__.StrConcat__("(", self__x274, ", ", self__y275, ", ", self__z276, ")")
end

function SF__.Vector3.UnitMoveTo(self__x277, self__y278, self__z279, u280, mode)
    if mode == nil then mode = SF__.UnitVec3Mode.Auto end
    local tz = SF__.Vector3._getTerrainZ(self__x277, self__y278)
    local LuaUtils = require("Lib.Utils")
    local defaultFlyHeight = GetUnitDefaultFlyHeight(u280)
    local minZ = (tz + defaultFlyHeight)
    SetUnitPosition(u280, self__x277, self__y278)
    repeat
        local switchValue = mode
        if (switchValue == SF__.UnitVec3Mode.ForceFlying) then
            LuaUtils.SetUnitFlyable(u280)
            SetUnitFlyHeight(u280, (math.max(minZ, self__z279) - minZ), 0)
            break
        elseif (switchValue == SF__.UnitVec3Mode.ForceGround) then
            SetUnitFlyHeight(u280, defaultFlyHeight, 0)
            break
        elseif (switchValue == SF__.UnitVec3Mode.Auto) then
            if IsUnitType(u280, UNIT_TYPE_FLYING) then
                SetUnitFlyHeight(u280, (math.max(minZ, self__z279) - minZ), 0)
            else
                SetUnitFlyHeight(u280, defaultFlyHeight, 0)
            end
            break
        end
    until true
end

function SF__.Vector3.GetTerrainZ(self__x281, self__y282, self__z283)
    return SF__.Vector3._getTerrainZ(self__x281, self__y282)
end

SF__.Vector3._loc = Location(0, 0)
-- Quaternion
SF__.Quaternion = SF__.Quaternion or {}
SF__.Quaternion.Name = "Quaternion"
SF__.Quaternion.FullName = "Quaternion"
function SF__.Quaternion.get_identity()
    return 0, 0, 0, 1
end

function SF__.Quaternion.op_Multiply__quaternionquaternion(a__x, a__y, a__z, a__w, b__x, b__y, b__z, b__w)
    return ((((a__w * b__x) + (a__x * b__w)) + (a__y * b__z)) - (a__z * b__y)), ((((a__w * b__y) - (a__x * b__z)) + (a__y * b__w)) + (a__z * b__x)), ((((a__w * b__z) + (a__x * b__y)) - (a__y * b__x)) + (a__z * b__w)), ((((a__w * b__w) - (a__x * b__x)) - (a__y * b__y)) - (a__z * b__z))
end

function SF__.Quaternion.op_Multiply__quaternionvector3(q__x, q__y, q__z, q__w, v__x, v__y, v__z)
    -- https://en.wikipedia.org/wiki/Quaternions_and_spatial_rotation#Using_quaternion_as_rotations
    local u__x, u__y, u__z = q__x, q__y, q__z
    local s = q__w
    return (function()
        local a__x58, a__y59, a__z60 = (function()
            local a__x55, a__y56, a__z57 = SF__.Vector3.op_Multiply__fvector3((2 * SF__.Vector3.Dot(u__x, u__y, u__z, v__x, v__y, v__z)), u__x, u__y, u__z)
            return SF__.Vector3.op_Addition(a__x55, a__y56, a__z57, SF__.Vector3.op_Multiply__fvector3(((s * s) - SF__.Vector3.Dot(u__x, u__y, u__z, u__x, u__y, u__z)), v__x, v__y, v__z))
        end)()
        return SF__.Vector3.op_Addition(a__x58, a__y59, a__z60, SF__.Vector3.op_Multiply__fvector3((2 * s), SF__.Vector3.Cross(u__x, u__y, u__z, v__x, v__y, v__z)))
    end)()
end

function SF__.Quaternion.Euler(pitch, yaw, roll)
    pitch = (pitch * bj_DEGTORAD)
    yaw = (yaw * bj_DEGTORAD)
    roll = (roll * bj_DEGTORAD)
    -- https://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles#Source_Code_2
    local cy = math.cos((yaw * 0.5))
    local sy = math.sin((yaw * 0.5))
    local cp = math.cos((pitch * 0.5))
    local sp = math.sin((pitch * 0.5))
    local cr = math.cos((roll * 0.5))
    local sr = math.sin((roll * 0.5))
    return (((sr * cp) * cy) - ((cr * sp) * sy)), (((cr * sp) * cy) + ((sr * cp) * sy)), (((cr * cp) * sy) - ((sr * sp) * cy)), (((cr * cp) * cy) + ((sr * sp) * sy))
end

function SF__.Quaternion.LookRotation__vector3vector3(forward__x, forward__y, forward__z, upwards__x, upwards__y, upwards__z)
    local worldForward__x, worldForward__y, worldForward__z = SF__.Vector3.get_normalized(forward__x, forward__y, forward__z)
    if (SF__.Vector3.get_sqrMagnitude(worldForward__x, worldForward__y, worldForward__z) < 0.0001) then
        return SF__.Quaternion.get_identity()
    end
    local worldUp__x, worldUp__y, worldUp__z = SF__.Vector3.get_normalized(SF__.Vector3.ProjectOnPlane(upwards__x, upwards__y, upwards__z, worldForward__x, worldForward__y, worldForward__z))
    if (SF__.Vector3.get_sqrMagnitude(worldUp__x, worldUp__y, worldUp__z) < 0.0001) then
        local fallbackUp__x, fallbackUp__y, fallbackUp__z
        do
            if (math.abs(worldForward__z) < 0.999) then
                fallbackUp__x, fallbackUp__y, fallbackUp__z = SF__.Vector3.get_up()
            else
                fallbackUp__x, fallbackUp__y, fallbackUp__z = SF__.Vector3.get_right()
            end
        end
        worldUp__x, worldUp__y, worldUp__z = SF__.Vector3.get_normalized(SF__.Vector3.ProjectOnPlane(fallbackUp__x, fallbackUp__y, fallbackUp__z, worldForward__x, worldForward__y, worldForward__z))
    end
    local worldRight__x, worldRight__y, worldRight__z = SF__.Vector3.get_normalized(SF__.Vector3.Cross(worldForward__x, worldForward__y, worldForward__z, worldUp__x, worldUp__y, worldUp__z))
    worldUp__x, worldUp__y, worldUp__z = SF__.Vector3.Cross(worldRight__x, worldRight__y, worldRight__z, worldForward__x, worldForward__y, worldForward__z)
    local m00 = worldRight__x
    local m01 = worldForward__x
    local m02 = worldUp__x
    local m10 = worldRight__y
    local m11 = worldForward__y
    local m12 = worldUp__y
    local m20 = worldRight__z
    local m21 = worldForward__z
    local m22 = worldUp__z
    local x61
    local y62
    local z
    local w
    local trace = ((m00 + m11) + m22)
    if (trace > 0) then
        local s63 = (math.sqrt((trace + 1)) * 2)
        w = (0.25 * s63)
        x61 = ((m21 - m12) / s63)
        y62 = ((m02 - m20) / s63)
        z = ((m10 - m01) / s63)
    elseif ((m00 > m11) and (m00 > m22)) then
        local s64 = (math.sqrt((((1 + m00) - m11) - m22)) * 2)
        w = ((m21 - m12) / s64)
        x61 = (0.25 * s64)
        y62 = ((m01 + m10) / s64)
        z = ((m02 + m20) / s64)
    else
        if (m11 > m22) then
            local s65 = (math.sqrt((((1 + m11) - m00) - m22)) * 2)
            w = ((m02 - m20) / s65)
            x61 = ((m01 + m10) / s65)
            y62 = (0.25 * s65)
            z = ((m12 + m21) / s65)
        else
            local s66 = (math.sqrt((((1 + m22) - m00) - m11)) * 2)
            w = ((m10 - m01) / s66)
            x61 = ((m02 + m20) / s66)
            y62 = ((m12 + m21) / s66)
            z = (0.25 * s66)
        end
    end
    return SF__.Quaternion.Normalize(x61, y62, z, w)
end

function SF__.Quaternion.LookRotation__vector3(forward__x67, forward__y68, forward__z69)
    return SF__.Quaternion.LookRotation__vector3vector3(forward__x67, forward__y68, forward__z69, SF__.Vector3.get_up())
end

function SF__.Quaternion.Normalize(q__x70, q__y71, q__z72, q__w73)
    local magnitude = math.sqrt(((((q__x70 * q__x70) + (q__y71 * q__y71)) + (q__z72 * q__z72)) + (q__w73 * q__w73)))
    if (magnitude < 0.0001) then
        return SF__.Quaternion.get_identity()
    end
    return (q__x70 / magnitude), (q__y71 / magnitude), (q__z72 / magnitude), (q__w73 / magnitude)
end

function SF__.Quaternion.get_eulerAngles(self__x, self__y, self__z, self__w)
    -- https://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles#Source_Code_2
    local sinr_cosp = (2 * ((self__w * self__x) + (self__y * self__z)))
    local cosr_cosp = (1 - (2 * ((self__x * self__x) + (self__y * self__y))))
    local roll74 = math.atan(sinr_cosp, cosr_cosp)
    local sinp = (2 * ((self__w * self__y) - (self__z * self__x)))
    local pitch75
    if (math.abs(sinp) >= 1) then
        pitch75 = ((math.sign(sinp) * math.pi) / 2)
        -- use 90 degrees if out of range
    else
        pitch75 = math.asin(sinp)
    end
    local siny_cosp = (2 * ((self__w * self__z) + (self__x * self__y)))
    local cosy_cosp = (1 - (2 * ((self__y * self__y) + (self__z * self__z))))
    local yaw76 = math.atan(siny_cosp, cosy_cosp)
    return (pitch75 * bj_RADTODEG), (yaw76 * bj_RADTODEG), (roll74 * bj_RADTODEG)
end

function SF__.Quaternion.get_normalized(self__x77, self__y78, self__z79, self__w80)
    return SF__.Quaternion.Normalize(self__x77, self__y78, self__z79, self__w80)
end

function SF__.Quaternion.ToString(self__x85, self__y86, self__z87, self__w88)
    return SF__.StrConcat__("(", self__x85, ", ", self__y86, ", ", self__z87, ", ", self__w88, ")")
end

function SF__.Quaternion.ApplyToEffect(self__x89, self__y90, self__z91, self__w92, e)
    local angles__x, angles__y, angles__z = SF__.Quaternion.get_eulerAngles(self__x89, self__y90, self__z91, self__w92)
    BlzSetSpecialEffectOrientation(e, (angles__y * bj_DEGTORAD), (angles__x * bj_DEGTORAD), (angles__z * bj_DEGTORAD))
end
-- AttachEffectComponent
SF__.AttachEffectComponent = SF__.AttachEffectComponent or {}
SF__.AttachEffectComponent.Name = "AttachEffectComponent"
SF__.AttachEffectComponent.FullName = "AttachEffectComponent"
setmetatable(SF__.AttachEffectComponent, { __index = SF__.Component })
SF__.AttachEffectComponent.__sf_base = SF__.Component
function SF__.AttachEffectComponent:GetInspectorText()
    return SF__.StrConcat__("Effect: ", (function() if (self.eff == nil) then return "None" else return "Attached" end end)())
end

function SF__.AttachEffectComponent:Update()
    if (self.eff == nil) then
        return
    end
    -- calculate global TRS from transform and ancestor transforms
    local globalPos__x, globalPos__y, globalPos__z = self.gameObject.transform.localPosition__x, self.gameObject.transform.localPosition__y, self.gameObject.transform.localPosition__z
    local globalRot__x, globalRot__y, globalRot__z, globalRot__w = self.gameObject.transform.localRotation__x, self.gameObject.transform.localRotation__y, self.gameObject.transform.localRotation__z, self.gameObject.transform.localRotation__w
    local globalScale__x, globalScale__y, globalScale__z = self.gameObject.transform.localScale__x, self.gameObject.transform.localScale__y, self.gameObject.transform.localScale__z
    local parent = self.gameObject.transform.parent
    while (parent ~= nil) do
        globalPos__x, globalPos__y, globalPos__z = SF__.Vector3.op_Addition(parent.localPosition__x, parent.localPosition__y, parent.localPosition__z, SF__.Quaternion.op_Multiply__quaternionvector3(parent.localRotation__x, parent.localRotation__y, parent.localRotation__z, parent.localRotation__w, SF__.Vector3.Scale(parent.localScale__x, parent.localScale__y, parent.localScale__z, globalPos__x, globalPos__y, globalPos__z)))
        globalRot__x, globalRot__y, globalRot__z, globalRot__w = SF__.Quaternion.op_Multiply__quaternionquaternion(parent.localRotation__x, parent.localRotation__y, parent.localRotation__z, parent.localRotation__w, globalRot__x, globalRot__y, globalRot__z, globalRot__w)
        globalScale__x, globalScale__y, globalScale__z = SF__.Vector3.Scale(parent.localScale__x, parent.localScale__y, parent.localScale__z, globalScale__x, globalScale__y, globalScale__z)
        parent = parent.parent
        ::continue::
    end
    BlzSetSpecialEffectPosition(self.eff, globalPos__x, globalPos__y, globalPos__z)
    SF__.Quaternion.ApplyToEffect(globalRot__x, globalRot__y, globalRot__z, globalRot__w, self.eff)
    BlzSetSpecialEffectMatrixScale(self.eff, globalScale__x, globalScale__y, globalScale__z)
end

function SF__.AttachEffectComponent:OnDestroy()
    if (self.eff ~= nil) then
        DestroyEffect(self.eff)
        self.eff = nil
    end
end

function SF__.AttachEffectComponent.__Init(self)
    SF__.Component.__Init(self)
    self.__sf_type = SF__.AttachEffectComponent
    self.eff = nil
end

function SF__.AttachEffectComponent.New()
    local self = setmetatable({}, { __index = SF__.AttachEffectComponent })
    SF__.AttachEffectComponent.__Init(self)
    return self
end
-- AutoTRSComponent
SF__.AutoTRSComponent = SF__.AutoTRSComponent or {}
SF__.AutoTRSComponent.Name = "AutoTRSComponent"
SF__.AutoTRSComponent.FullName = "AutoTRSComponent"
setmetatable(SF__.AutoTRSComponent, { __index = SF__.Component })
SF__.AutoTRSComponent.__sf_base = SF__.Component
function SF__.AutoTRSComponent:Update()
    local trs = self.gameObject.transform
    trs.localRotation__x, trs.localRotation__y, trs.localRotation__z, trs.localRotation__w = SF__.Quaternion.op_Multiply__quaternionquaternion(self.rotation__x, self.rotation__y, self.rotation__z, self.rotation__w, trs.localRotation__x, trs.localRotation__y, trs.localRotation__z, trs.localRotation__w)
end

function SF__.AutoTRSComponent.__Init(self)
    SF__.Component.__Init(self)
    self.__sf_type = SF__.AutoTRSComponent
    self.rotation = SF__.Quaternion.get_identity()
end

function SF__.AutoTRSComponent.New()
    local self = setmetatable({}, { __index = SF__.AutoTRSComponent })
    SF__.AutoTRSComponent.__Init(self)
    return self
end
-- <summary>
-- A basic list backed by a Lua sequential table.
-- Uses table.insert/table.remove for array operations.
-- C# indexer (0-based) maps to Lua table (1-based) via get_Item/set_Item.
-- </summary>
--
SF__.StdLib = SF__.StdLib or {}
-- StdLib.List
SF__.StdLib.List = SF__.StdLib.List or {}
SF__.StdLib.List.Name = "List"
SF__.StdLib.List.FullName = "StdLib.List"
function SF__.StdLib.List.__Init__0(self)
    self.__sf_type = SF__.StdLib.List
    self._items = nil
    self._version = 0
    self.Count = 0
    self._items = {}
    self._version = 0
    self.Count = 0
end

function SF__.StdLib.List.New__0()
    local self = setmetatable({}, { __index = SF__.StdLib.List })
    SF__.StdLib.List.__Init__0(self)
    return self
end

function SF__.StdLib.List.__Init__listt(self, collection)
    SF__.StdLib.List.__Init__0(self)
    do
        local collection1 = collection
        for _, item432 in (SF__.StdLib.List.IpairsNext)(collection1) do
            table.insert(self._items, item432)
            self.Count = (self.Count + 1)
        end
    end
end

function SF__.StdLib.List.New__listt(collection)
    local self = setmetatable({}, { __index = SF__.StdLib.List })
    SF__.StdLib.List.__Init__listt(self, collection)
    return self
end

function SF__.StdLib.List:get_Item(index433)
    if ((index433 < 0) or (index433 >= self.Count)) then
        error(SF__.StrConcat__("SF__E2e5944b8", "Index out of range"))
    end
    return self._items[(index433 + 1)]
end

function SF__.StdLib.List:set_Item(index434, value)
    if ((index434 < 0) or (index434 >= self.Count)) then
        error(SF__.StrConcat__("SF__E2e5944b8", "Index out of range"))
    end
    self._items[(index434 + 1)] = value
end

function SF__.StdLib.List:AddRange(collection435)
    do
        local collection2 = collection435
        for _, item436 in (SF__.StdLib.List.IpairsNext)(collection2) do
            table.insert(self._items, item436)
            self.Count = (self.Count + 1)
        end
    end
    self._version = (self._version + 1)
end

function SF__.StdLib.List:Add(item437)
    table.insert(self._items, item437)
    self.Count = (self.Count + 1)
    self._version = (self._version + 1)
end

function SF__.StdLib.List:Clear()
    self._items = {}
    self.Count = 0
    self._version = (self._version + 1)
end

function SF__.StdLib.List:Remove(item438)
    local index439 = self:IndexOf(item438)
    if (index439 < 0) then
        return false
    end
    self:RemoveAt(index439)
    return true
end

function SF__.StdLib.List:RemoveAt(index440)
    table.remove(self._items, (index440 + 1))
    self.Count = (self.Count - 1)
    self._version = (self._version + 1)
end

function SF__.StdLib.List:IndexOf(item441)
    do
        local i442 = 0
        while (i442 < self.Count) do
            local current = self._items[(i442 + 1)]
            if (current == item441) then
                return i442
            end
            ::continue::
            i442 = (i442 + 1)
        end
    end
    return (-1)
end

function SF__.StdLib.List.DefaultCompare(a443, b444)
    if (a443 == b444) then
        return 0
    end
    if (a443 < b444) then
        return (-1)
    end
    return 1
end

function SF__.StdLib.List:Sort(comparison)
    if (comparison == nil) then
        comparison = SF__.StdLib.List.DefaultCompare
    end
    local version = self._version
    table.sort(self._items, function(a447, b448)
        return (comparison(a447, b448) < 0)
    end)
    if (version ~= self._version) then
        error(SF__.StrConcat__("SF__E2e5944b8", "Collection was modified"))
    end
    self._version = (self._version + 1)
end

function SF__.StdLib.List:IpairsNext()
    local version449 = self._version
    local index450 = 0
    return function()
        if (version449 ~= self._version) then
            error(SF__.StrConcat__("SF__E2e5944b8", "Collection was modified"))
        end
        index450 = (index450 + 1)
        local value451 = self._items[index450]
        if (value451 == nil) then
            return nil
        end
        return index450, value451
    end
end

function SF__.StdLib.List:GetEnumerator()
    return nil
end
-- Utils
SF__.Utils = SF__.Utils or {}
SF__.Utils.Name = "Utils"
SF__.Utils.FullName = "Utils"
function SF__.Utils.ExSetAbilityResearchTooltip(p, abilCode, researchTooltip, level)
    if (GetLocalPlayer() ~= p) then
        return
    end
    BlzSetAbilityResearchTooltip(abilCode, researchTooltip, level)
end

function SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p94, abilCode95, researchExtendedTooltip, level96)
    if (GetLocalPlayer() ~= p94) then
        return
    end
    BlzSetAbilityResearchExtendedTooltip(abilCode95, researchExtendedTooltip, level96)
end

function SF__.Utils.ExBlzSetAbilityTooltip(p97, abilCode98, tooltip, level99)
    if (GetLocalPlayer() ~= p97) then
        return
    end
    BlzSetAbilityTooltip(abilCode98, tooltip, level99)
end

function SF__.Utils.ExBlzSetAbilityExtendedTooltip(p100, abilCode101, extendedTooltip, level102)
    if (GetLocalPlayer() ~= p100) then
        return
    end
    BlzSetAbilityExtendedTooltip(abilCode101, extendedTooltip, level102)
end

function SF__.Utils.ExBlzSetAbilityIcon(p103, abilCode104, iconPath)
    if (GetLocalPlayer() ~= p103) then
        return
    end
    BlzSetAbilityIcon(abilCode104, iconPath)
end

function SF__.Utils.CsGroupGetUnitsInRange(x105, y106, radius, filter)
    local result = SF__.StdLib.List.New__0()
    ExGroupEnumUnitsInRange(x105, y106, radius, function(u107)
        if filter(u107) then
            result:Add(u107)
        end
    end)
    return result
end

function SF__.Utils.__Init(self)
    self.__sf_type = SF__.Utils
end

function SF__.Utils.New()
    local self = setmetatable({}, { __index = SF__.Utils })
    SF__.Utils.__Init(self)
    return self
end
-- RetributionPaladinGlobal
SF__.RetributionPaladinGlobal = SF__.RetributionPaladinGlobal or {}
SF__.RetributionPaladinGlobal.Name = "RetributionPaladinGlobal"
SF__.RetributionPaladinGlobal.FullName = "RetributionPaladinGlobal"
function SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(u356, amount)
    local UnitAttribute358 = require("Objects.UnitAttribute")
    local attr357 = UnitAttribute358.GetAttr(u356)
    attr357.retPalHolyEnergy = math.min((attr357.retPalHolyEnergy + amount), 5)
end

function SF__.RetributionPaladinGlobal:Init()
    ExTriggerRegisterNewUnit(function(u360)
        if (GetUnitTypeId(u360) == FourCC("Hpal")) then
            self._units:Add(u360)
        end
    end)
    _ = self:Start()
end

function SF__.RetributionPaladinGlobal:Start()
    return SF__.CorRun__(function()
        local UnitAttribute363 = require("Objects.UnitAttribute")
        while true do
            do
                local collection3 = self._units
                for _, u361 in (SF__.StdLib.List.IpairsNext)(collection3) do
                    local attr362 = UnitAttribute363.GetAttr(u361)
                    ExSetUnitMana(u361, ((ExGetUnitMaxMana(u361) * attr362.retPalHolyEnergy) * 0.2))
                    if (attr362.retPalHolyEnergy >= 3) then
                        SF__.Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u361), FourCC("A006"), "ReplaceableTextures/CommandButtons/BTNinv_helmet_96.tga")
                    else
                        SF__.Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u361), FourCC("A006"), "ReplaceableTextures/PassiveButtons/PASBTNinv_helmet_96.tga")
                    end
                end
            end
            SF__.CorWait__(100)
            ::continue::
        end
    end)
end

function SF__.RetributionPaladinGlobal.__Init(self)
    self.__sf_type = SF__.RetributionPaladinGlobal
    self._units = SF__.StdLib.List.New__0()
end

function SF__.RetributionPaladinGlobal.New()
    local self = setmetatable({}, { __index = SF__.RetributionPaladinGlobal })
    SF__.RetributionPaladinGlobal.__Init(self)
    return self
end

SF__.RetributionPaladinGlobal.Instance = SF__.RetributionPaladinGlobal.New()
-- BladeOfJustice
SF__.BladeOfJustice = SF__.BladeOfJustice or {}
SF__.BladeOfJustice.Name = "BladeOfJustice"
SF__.BladeOfJustice.FullName = "BladeOfJustice"
function SF__.BladeOfJustice.GetAbilityData(level284)
    return (75 * level284), 5, (10 * level284)
end

function SF__.BladeOfJustice.Init()
    local EventCenter = require("Lib.EventCenter")
    EventCenter.RegisterPlayerUnitSpellEffect:Emit({id = SF__.BladeOfJustice.ID, handler = SF__.BladeOfJustice.Start})
    ExTriggerRegisterNewUnit(function(u286)
        if (GetUnitTypeId(u286) == FourCC("Hpal")) then
            SF__.BladeOfJustice.UpdateAbilityMeta(u286)
        end
    end)
end

function SF__.BladeOfJustice.UpdateAbilityMeta(u287)
    local p288 = GetOwningPlayer(u287)
    local datas = SF__.StdLib.List.New__0()
    do
        local i289 = 0
        while (i289 < 3) do
            local __pack_Damage, __pack_Duration, __pack_DamagePerSecond = SF__.BladeOfJustice.GetAbilityData((i289 + 1))
            datas:Add({Damage = __pack_Damage, Duration = __pack_Duration, DamagePerSecond = __pack_DamagePerSecond})
            ::continue::
            i289 = (i289 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p288, SF__.BladeOfJustice.ID, "学习公正之剑 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p288, SF__.BladeOfJustice.ID, SF__.StrConcat__("用圣光的利刃刺穿目标，造成法术伤害，在一定时间内对附近敌人每秒造成光辉伤害。产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 10秒\n\n|cffffcc001级|r - 造成|cffff8c00", datas:get_Item(0).Damage, "|r的直接法术伤害，|cffff8c00", datas:get_Item(0).Duration, "|r秒内对附近敌人每秒造成|cffff8c00", datas:get_Item(0).DamagePerSecond, "|r的光辉伤害。产生|cffff8c001|r点圣能。\n|cffffcc002级|r - 造成|cffff8c00", datas:get_Item(1).Damage, "|r的直接法术伤害，|cffff8c00", datas:get_Item(1).Duration, "|r秒内对附近敌人每秒造成|cffff8c00", datas:get_Item(1).DamagePerSecond, "|r的光辉伤害。产生|cffff8c001|r点圣能。\n|cffffcc003级|r - 造成|cffff8c00", datas:get_Item(2).Damage, "|r的直接法术伤害，|cffff8c00", datas:get_Item(2).Duration, "|r秒内对附近敌人每秒造成|cffff8c00", datas:get_Item(2).DamagePerSecond, "|r的光辉伤害。产生|cffff8c001|r点圣能。"), 0)
    do
        local i290 = 0
        while (i290 < 3) do
            local __unpack_tmp = datas:get_Item(i290)
            local data__Damage, data__Duration, data__DamagePerSecond = __unpack_tmp.Damage, __unpack_tmp.Duration, __unpack_tmp.DamagePerSecond
            SF__.Utils.ExBlzSetAbilityTooltip(p288, SF__.BladeOfJustice.ID, SF__.StrConcat__("公正之剑 - [|cffffcc00", (i290 + 1), "级|r]"), i290)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p288, SF__.BladeOfJustice.ID, SF__.StrConcat__("用圣光的利刃刺穿目标，造成|cffff8c00", data__Damage, "|r的直接法术伤害，在|cffff8c00", data__Duration, "|r秒内对附近敌人每秒造成|cffff8c00", data__DamagePerSecond, "|r的光辉伤害。产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 10秒"), i290)
            ::continue::
            i290 = (i290 + 1)
        end
    end
end

function SF__.BladeOfJustice.Start(data)
    local level291 = GetUnitAbilityLevel(data.caster, SF__.BladeOfJustice.ID)
    local EventCenter292 = require("Lib.EventCenter")
    local ad__Damage, ad__Duration, ad__DamagePerSecond = SF__.BladeOfJustice.GetAbilityData(level291)
    EventCenter292.Damage:Emit({whichUnit = data.caster, target = data.target, amount = ad__Damage, attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
    SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(data.caster, 1)
    SF__.BladeOfJustice.New():StartGroudDamage(data.caster, data.target, ad__Damage, ad__Duration, ad__DamagePerSecond)
end

function SF__.BladeOfJustice:StartGroudDamage(caster, target, ad__Damage293, ad__Duration294, ad__DamagePerSecond295)
    return SF__.CorRun__(function()
        local pos__x, pos__y = SF__.Vector2.FromUnit(target)
        local UnitAttribute = require("Objects.UnitAttribute")
        local EventCenter299 = require("Lib.EventCenter")
        local eff = ExAddSpecialEffect("Abilities/Spells/Orc/LiquidFire/Liquidfire.mdl", pos__x, pos__y, ad__Duration294)
        local p296 = GetOwningPlayer(caster)
        do
            local i297 = 0
            while (i297 < ad__Duration294) do
                SF__.CorWait__(1000)
                ExGroupEnumUnitsInRange(pos__x, pos__y, 300, function(u300)
                    if (not IsUnitEnemy(u300, p296)) then
                        return
                    end
                    if ExIsUnitDead(u300) then
                        return
                    end
                    local tarAttr301 = UnitAttribute.GetAttr(u300)
                    local damage302 = (ad__DamagePerSecond295 * (1 - tarAttr301.radiantResistance))
                    EventCenter299.Damage:Emit({whichUnit = caster, target = u300, amount = damage302, attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
                end)
                ::continue::
                i297 = (i297 + 1)
            end
        end
        DestroyEffect(eff)
    end)
end

function SF__.BladeOfJustice.__Init(self)
    self.__sf_type = SF__.BladeOfJustice
end

function SF__.BladeOfJustice.New()
    local self = setmetatable({}, { __index = SF__.BladeOfJustice })
    SF__.BladeOfJustice.__Init(self)
    return self
end

SF__.BladeOfJustice.ID = FourCC("A001")
-- ConstOrderId
SF__.ConstOrderId = SF__.ConstOrderId or {}
SF__.ConstOrderId.Name = "ConstOrderId"
SF__.ConstOrderId.FullName = "ConstOrderId"
function SF__.ConstOrderId.__Init(self)
    self.__sf_type = SF__.ConstOrderId
end

function SF__.ConstOrderId.New()
    local self = setmetatable({}, { __index = SF__.ConstOrderId })
    SF__.ConstOrderId.__Init(self)
    return self
end

SF__.ConstOrderId.Stop = 851972
SF__.ConstOrderId.Smart = 851971
SF__.ConstOrderId.Attack = 851983
-- CrusaderStrike
SF__.CrusaderStrike = SF__.CrusaderStrike or {}
SF__.CrusaderStrike.Name = "CrusaderStrike"
SF__.CrusaderStrike.FullName = "CrusaderStrike"
function SF__.CrusaderStrike.GetAbilityData(level303)
    return (0.65 + (0.35 * level303)), (0.15 * (level303 - 1))
end

function SF__.CrusaderStrike.Init()
    local EventCenter304 = require("Lib.EventCenter")
    EventCenter304.RegisterPlayerUnitSpellEffect:Emit({id = SF__.CrusaderStrike.ID, handler = SF__.CrusaderStrike.Start})
    ExTriggerRegisterNewUnit(function(u306)
        if (GetUnitTypeId(u306) == FourCC("Hpal")) then
            SF__.CrusaderStrike.UpdateAbilityMeta(u306)
        end
    end)
end

function SF__.CrusaderStrike.UpdateAbilityMeta(u307)
    local p308 = GetOwningPlayer(u307)
    local datas309 = SF__.StdLib.List.New__0()
    do
        local i310 = 0
        while (i310 < 3) do
            local __pack_DamageScaling, __pack_ArtOfWarChance = SF__.CrusaderStrike.GetAbilityData((i310 + 1))
            datas309:Add({DamageScaling = __pack_DamageScaling, ArtOfWarChance = __pack_ArtOfWarChance})
            ::continue::
            i310 = (i310 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p308, SF__.CrusaderStrike.ID, "学习十字军打击 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p308, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击造成一次攻击伤害，伤害系数随技能等级提升。产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 6秒\n\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas309:get_Item(0).DamageScaling * 100)), "%|r的攻击伤害。\n|cffffcc002级|r - |cffff8c00", string.format("%.0f", (datas309:get_Item(1).DamageScaling * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas309:get_Item(1).ArtOfWarChance * 100)), "%的战争艺术触发几率。\n|cffffcc003级|r - |cffff8c00", string.format("%.0f", (datas309:get_Item(2).DamageScaling * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas309:get_Item(2).ArtOfWarChance * 100)), "%的战争艺术触发几率。"), 0)
    do
        local i311 = 0
        while (i311 < 3) do
            local __unpack_tmp312 = datas309:get_Item(i311)
            local data__DamageScaling, data__ArtOfWarChance = __unpack_tmp312.DamageScaling, __unpack_tmp312.ArtOfWarChance
            SF__.Utils.ExBlzSetAbilityTooltip(p308, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击 - [|cffffcc00", (i311 + 1), "级|r]"), i311)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p308, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击造成一次攻击伤害，造成|cffff8c00", string.format("%.0f", (data__DamageScaling * 100)), "%|r的攻击伤害", (function() if (i311 > 0) then return SF__.StrConcat__("，", string.format("%.0f", (data__ArtOfWarChance * 100)), "%的战争艺术触发几率") else return "" end end)(), "。产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 6秒"), i311)
            ::continue::
            i311 = (i311 + 1)
        end
    end
    -- datas.Remove(new IAbilityData { DamageScaling = 0.65f, ArtOfWarChance = 0 });
    datas309:RemoveAt(0)
end

function SF__.CrusaderStrike.Start(data313)
    local level314 = GetUnitAbilityLevel(data313.caster, SF__.CrusaderStrike.ID)
    local UnitAttribute315 = require("Objects.UnitAttribute")
    local EventCenter317 = require("Lib.EventCenter")
    local ad__DamageScaling, ad__ArtOfWarChance = SF__.CrusaderStrike.GetAbilityData(level314)
    local attr = UnitAttribute315.GetAttr(data313.caster)
    local damage316 = (attr:SimAttack(UnitAttribute315.HeroAttributeType.Strength) * ad__DamageScaling)
    EventCenter317.Damage:Emit({whichUnit = data313.caster, target = data313.target, amount = damage316, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
    attr.retPalHolyEnergy = (attr.retPalHolyEnergy + 1)
end

function SF__.CrusaderStrike.__Init(self)
    self.__sf_type = SF__.CrusaderStrike
end

function SF__.CrusaderStrike.New()
    local self = setmetatable({}, { __index = SF__.CrusaderStrike })
    SF__.CrusaderStrike.__Init(self)
    return self
end

SF__.CrusaderStrike.ID = FourCC("A000")
SF__.CrusaderStrike = SF__.CrusaderStrike or {}
-- CrusaderStrike.IAbilityData
SF__.CrusaderStrike.IAbilityData = SF__.CrusaderStrike.IAbilityData or {}
SF__.CrusaderStrike.IAbilityData.Name = "IAbilityData"
SF__.CrusaderStrike.IAbilityData.FullName = "CrusaderStrike.IAbilityData"
function SF__.CrusaderStrike.IAbilityData.Scale(self__DamageScaling, self__ArtOfWarChance, scale)
    return (self__DamageScaling * scale), (self__ArtOfWarChance * scale)
end
-- Scene
SF__.Scene = SF__.Scene or {}
SF__.Scene.Name = "Scene"
SF__.Scene.FullName = "Scene"
function SF__.Scene.get_Instance()
    return (function()
        if SF__.Scene._instance ~= nil then
            return SF__.Scene._instance
        end
        SF__.Scene._instance = SF__.Scene.New()
        return SF__.Scene._instance
    end)()
end

function SF__.Scene:AddGameObject(obj25)
    self.gameObjs:Add(obj25)
end

function SF__.Scene:QueueDestroy(obj26)
    self._destroyQueue:Add(obj26)
end

function SF__.Scene:FlushDestroyQueue()
    do
        local i27 = 0
        while (i27 < self._destroyQueue.Count) do
            SF__.GameObject.DestroyQueued(self._destroyQueue:get_Item(i27))
            ::continue::
            i27 = (i27 + 1)
        end
    end
    self._destroyQueue:Clear()
end

function SF__.Scene:Run()
    return SF__.CorRun__(function()
        while true do
            SF__.CorWait__(SF__.Scene.DT)
            local count = self.gameObjs.Count
            do
                local i28 = 0
                while (i28 < count) do
                    self.gameObjs:get_Item(i28):Update()
                    ::continue::
                    i28 = (i28 + 1)
                end
            end
            do
                local i29 = 0
                while (i29 < count) do
                    self.gameObjs:get_Item(i29):LateUpdate()
                    ::continue::
                    i29 = (i29 + 1)
                end
            end
            self:FlushDestroyQueue()
            ::continue::
        end
    end)
end

function SF__.Scene.__Init(self)
    self.__sf_type = SF__.Scene
    self.gameObjs = SF__.StdLib.List.New__0()
    self._destroyQueue = SF__.StdLib.List.New__0()
end

function SF__.Scene.New()
    local self = setmetatable({}, { __index = SF__.Scene })
    SF__.Scene.__Init(self)
    return self
end

SF__.Scene.DT = 20
SF__.Scene._instance = nil
-- Transform
SF__.Transform = SF__.Transform or {}
SF__.Transform.Name = "Transform"
SF__.Transform.FullName = "Transform"
setmetatable(SF__.Transform, { __index = SF__.Component })
SF__.Transform.__sf_base = SF__.Component
function SF__.Transform:get_position()
    if (self.parent == nil) then
        return self.localPosition__x, self.localPosition__y, self.localPosition__z
    end
    local globalPos__x3, globalPos__y4, globalPos__z5 = self.localPosition__x, self.localPosition__y, self.localPosition__z
    local globalRot__x6, globalRot__y7, globalRot__z8, globalRot__w9 = self.localRotation__x, self.localRotation__y, self.localRotation__z, self.localRotation__w
    local globalScale__x10, globalScale__y11, globalScale__z12 = self.localScale__x, self.localScale__y, self.localScale__z
    local myParent = self.parent
    while (myParent ~= nil) do
        globalPos__x3, globalPos__y4, globalPos__z5 = SF__.Vector3.op_Addition(myParent.localPosition__x, myParent.localPosition__y, myParent.localPosition__z, SF__.Quaternion.op_Multiply__quaternionvector3(myParent.localRotation__x, myParent.localRotation__y, myParent.localRotation__z, myParent.localRotation__w, SF__.Vector3.Scale(myParent.localScale__x, myParent.localScale__y, myParent.localScale__z, globalPos__x3, globalPos__y4, globalPos__z5)))
        globalRot__x6, globalRot__y7, globalRot__z8, globalRot__w9 = SF__.Quaternion.op_Multiply__quaternionquaternion(myParent.localRotation__x, myParent.localRotation__y, myParent.localRotation__z, myParent.localRotation__w, globalRot__x6, globalRot__y7, globalRot__z8, globalRot__w9)
        globalScale__x10, globalScale__y11, globalScale__z12 = SF__.Vector3.Scale(myParent.localScale__x, myParent.localScale__y, myParent.localScale__z, globalScale__x10, globalScale__y11, globalScale__z12)
        myParent = myParent.parent
        ::continue::
    end
    return globalPos__x3, globalPos__y4, globalPos__z5
end

function SF__.Transform.__Init(self)
    SF__.Component.__Init(self)
    self.__sf_type = SF__.Transform
    self.localPosition__x = 0
    self.localPosition__y = 0
    self.localPosition__z = 0
    self.localRotation__x = 0
    self.localRotation__y = 0
    self.localRotation__z = 0
    self.localRotation__w = 0
    self.localScale__x = 0
    self.localScale__y = 0
    self.localScale__z = 0
    self.children = SF__.StdLib.List.New__0()
    self.parent = nil
    self.localPosition__x, self.localPosition__y, self.localPosition__z = 0, 0, 0
    self.localRotation__x, self.localRotation__y, self.localRotation__z, self.localRotation__w = SF__.Quaternion.Euler(0, 0, 0)
    self.localScale__x, self.localScale__y, self.localScale__z = 1, 1, 1
end

function SF__.Transform.New()
    local self = setmetatable({}, { __index = SF__.Transform })
    SF__.Transform.__Init(self)
    return self
end

function SF__.Transform:GetInspectorText()
    return SF__.StrConcat__("Position: ", SF__.Vector3.ToString(self.localPosition__x, self.localPosition__y, self.localPosition__z), "\n", "Rotation: ", SF__.Vector3.ToString(SF__.Quaternion.get_eulerAngles(self.localRotation__x, self.localRotation__y, self.localRotation__z, self.localRotation__w)), "\n", "Scale: ", SF__.Vector3.ToString(self.localScale__x, self.localScale__y, self.localScale__z), "\n", "Children: ", self.children.Count)
end

function SF__.Transform:SetParent(newParent)
    if (self.parent ~= nil) then
        self.parent.children:Remove(self)
    end
    self.parent = newParent
    if (self.parent ~= nil) then
        self.parent.children:Add(self)
    end
end
-- GameObject
SF__.GameObject = SF__.GameObject or {}
SF__.GameObject.Name = "GameObject"
SF__.GameObject.FullName = "GameObject"
function SF__.GameObject.MarkDestroyQueuedDepthFirst(obj)
    if (obj.isDestroyQueued or obj.isDestroyed) then
        return
    end
    obj.isDestroyQueued = true
    do
        local collection4 = obj.transform.children
        for _, child in (SF__.StdLib.List.IpairsNext)(collection4) do
            SF__.GameObject.MarkDestroyQueuedDepthFirst(child.gameObject)
        end
    end
end

function SF__.GameObject.DestroyDepthFirst(obj13)
    if obj13.isDestroyed then
        return
    end
    local children = obj13.transform.children
    do
        local i = (children.Count - 1)
        while (i >= 0) do
            SF__.GameObject.DestroyDepthFirst(children:get_Item(i).gameObject)
            ::continue::
            i = (i - 1)
        end
    end
    obj13.transform:SetParent(nil)
    do
        local collection5 = obj13._components
        for _, comp in (SF__.StdLib.List.IpairsNext)(collection5) do
            comp:OnDisable()
            comp:OnDestroy()
        end
    end
    obj13._components:Clear()
    SF__.Scene.get_Instance().gameObjs:Remove(obj13)
    obj13.isDestroyed = true
end

function SF__.GameObject:get_components()
    return self._components
end

function SF__.GameObject.__Init__s(self, name)
    self.__sf_type = SF__.GameObject
    self.name = nil
    self.transform = nil
    self._components = SF__.StdLib.List.New__0()
    self.isDestroyQueued = false
    self.isDestroyed = false
    self.name = name
    self.transform = self:AddComponent(SF__.Transform)
    SF__.Scene.get_Instance():AddGameObject(self)
end

function SF__.GameObject.New__s(name)
    local self = setmetatable({}, { __index = SF__.GameObject })
    SF__.GameObject.__Init__s(self, name)
    return self
end

function SF__.GameObject.__Init__sgameobject(self, name14, parent15)
    SF__.GameObject.__Init__s(self, name14)
    self.transform:SetParent(parent15.transform)
end

function SF__.GameObject.New__sgameobject(name14, parent15)
    local self = setmetatable({}, { __index = SF__.GameObject })
    SF__.GameObject.__Init__sgameobject(self, name14, parent15)
    return self
end

function SF__.GameObject:GetComponent(T)
    do
        local collection6 = self._components
        for _, comp16 in (SF__.StdLib.List.IpairsNext)(collection6) do
            do
                local tComp = comp16
                if SF__.TypeIs__(tComp, T) then
                    return tComp
                end
            end
        end
    end
    return nil
end

function SF__.GameObject:AddComponent(T17)
    local comp18 = (function()
        local obj19 = T17.New()
        obj19.gameObject = self
        return obj19
    end)()
    self._components:Add(comp18)
    comp18:Awake()
    comp18:OnEnable()
    comp18:Start()
    return comp18
end

function SF__.GameObject:RemoveAllComponents(T20)
    do
        local i21 = (self._components.Count - 1)
        while (i21 >= 0) do
            if SF__.TypeIs__(self._components:get_Item(i21), T20) then
                self._components:get_Item(i21):OnDisable()
                self._components:get_Item(i21):OnDestroy()
                self._components:RemoveAt(i21)
            end
            ::continue::
            i21 = (i21 - 1)
        end
    end
end

function SF__.GameObject:Update()
    if (self.isDestroyQueued or self.isDestroyed) then
        return
    end
    do
        local collection7 = self._components
        for _, comp22 in (SF__.StdLib.List.IpairsNext)(collection7) do
            comp22:Update()
        end
    end
end

function SF__.GameObject:LateUpdate()
    if (self.isDestroyQueued or self.isDestroyed) then
        return
    end
    do
        local collection8 = self._components
        for _, comp23 in (SF__.StdLib.List.IpairsNext)(collection8) do
            comp23:LateUpdate()
        end
    end
end

function SF__.GameObject:Destroy()
    if (self.isDestroyQueued or self.isDestroyed) then
        return
    end
    SF__.GameObject.MarkDestroyQueuedDepthFirst(self)
    SF__.Scene.get_Instance():QueueDestroy(self)
end

function SF__.GameObject.DestroyQueued(obj24)
    SF__.GameObject.DestroyDepthFirst(obj24)
end
-- Missile
SF__.Missile = SF__.Missile or {}
SF__.Missile.Name = "Missile"
SF__.Missile.FullName = "Missile"
setmetatable(SF__.Missile, { __index = SF__.Component })
SF__.Missile.__sf_base = SF__.Component
function SF__.Missile:Update()
    if self.hasArrived then
        return
    end
    local currentPosition__x, currentPosition__y, currentPosition__z = self.gameObject.transform.localPosition__x, self.gameObject.transform.localPosition__y, self.gameObject.transform.localPosition__z
    local targetPosition__x, targetPosition__y, targetPosition__z
    do
        if (self.targetType == SF__.TargetType.Unit) then
            targetPosition__x, targetPosition__y, targetPosition__z = SF__.Vector3.FromUnit(self.unitTarget)
        else
            targetPosition__x, targetPosition__y, targetPosition__z = self.pointTarget__x, self.pointTarget__y, self.pointTarget__z
        end
    end
    local moved__x, moved__y, moved__z = SF__.Vector3.MoveTowards(currentPosition__x, currentPosition__y, currentPosition__z, targetPosition__x, targetPosition__y, targetPosition__z, ((self.speed * SF__.Scene.DT) / 1000))
    self.gameObject.transform.localPosition__x, self.gameObject.transform.localPosition__y, self.gameObject.transform.localPosition__z = moved__x, moved__y, moved__z
    if self.lookAtTarget then
        self.gameObject.transform.localRotation__x, self.gameObject.transform.localRotation__y, self.gameObject.transform.localRotation__z, self.gameObject.transform.localRotation__w = SF__.Quaternion.LookRotation__vector3(SF__.Vector3.op_Subtraction(targetPosition__x, targetPosition__y, targetPosition__z, currentPosition__x, currentPosition__y, currentPosition__z))
    end
    if ((SF__.Vector3.Distance(moved__x, moved__y, moved__z, targetPosition__x, targetPosition__y, targetPosition__z) <= self.colliderSize) and (not self.hasArrived)) then
        self.hasArrived = true
        local delegate = self.onArrived
        if (delegate ~= nil) then
            delegate()
        end
        self.onArrived = nil
    end
end

function SF__.Missile:GetInspectorText()
    return SF__.StrConcat__("targetType: ", self.targetType, "\nunitTarget: ", (function() if (self.unitTarget == nil) then return "None" else return GetUnitName(self.unitTarget) end end)(), "\npointTarget: ", SF__.Vector3.ToString(self.pointTarget__x, self.pointTarget__y, self.pointTarget__z), "\nspeed: ", self.speed, "\nlookAtTarget: ", self.lookAtTarget, "\ncolliderSize: ", self.colliderSize, "\nonArrived: ", (function() if (self.onArrived == nil) then return "None" else return "Set" end end)(), "\nhasArrived: ", self.hasArrived, "\n")
end

function SF__.Missile.__Init(self)
    SF__.Component.__Init(self)
    self.__sf_type = SF__.Missile
    self.targetType = 0
    self.unitTarget = nil
    self.pointTarget__x = 0
    self.pointTarget__y = 0
    self.pointTarget__z = 0
    self.speed = 0
    self.lookAtTarget = false
    self.onArrived = nil
    self.colliderSize = 0
    self.hasArrived = false
end

function SF__.Missile.New()
    local self = setmetatable({}, { __index = SF__.Missile })
    SF__.Missile.__Init(self)
    return self
end
-- DivineToll
SF__.DivineToll = SF__.DivineToll or {}
SF__.DivineToll.Name = "DivineToll"
SF__.DivineToll.FullName = "DivineToll"
function SF__.DivineToll.GetAbilityData(level318)
    return (2 + level318), (50 * level318), 0.1, 10
end

function SF__.DivineToll.Init()
    local EventCenter321 = require("Lib.EventCenter")
    EventCenter321.RegisterPlayerUnitSpellEffect:Emit({id = SF__.DivineToll.ID, handler = function(data320)
        SF__.DivineToll.Start(data320)
    end})
    ExTriggerRegisterNewUnit(function(u323)
        if (GetUnitTypeId(u323) == FourCC("Hpal")) then
            SF__.DivineToll.UpdateAbilityMeta(u323)
        end
    end)
end

function SF__.DivineToll.UpdateAbilityMeta(u324)
    local p325 = GetOwningPlayer(u324)
    local datas326 = SF__.StdLib.List.New__0()
    do
        local i327 = 0
        while (i327 < 3) do
            local __pack_TargetCount, __pack_Damage328, __pack_RadiantDmgAmp, __pack_Duration329 = SF__.DivineToll.GetAbilityData((i327 + 1))
            datas326:Add({TargetCount = __pack_TargetCount, Damage = __pack_Damage328, RadiantDmgAmp = __pack_RadiantDmgAmp, Duration = __pack_Duration329})
            ::continue::
            i327 = (i327 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p325, SF__.DivineToll.ID, "学习圣洁鸣钟 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p325, SF__.DivineToll.ID, SF__.StrConcat__("对附近的多个目标施展审判，造成法术伤害，然后神圣之锤环绕圣殿骑士，每次命中敌人使其受到的光辉伤害提高。每个审判产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 30秒\n\n|cffffcc001级|r - 审判最多|cffff8c00", datas326:get_Item(0).TargetCount, "|r个目标，造成|cffff8c00", datas326:get_Item(0).Damage, "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas326:get_Item(0).RadiantDmgAmp * 100)), "%|r的光辉易伤，持续|cffff8c00", datas326:get_Item(0).Duration, "|r秒。\n|cffffcc002级|r - 审判最多|cffff8c00", datas326:get_Item(1).TargetCount, "|r个目标，造成|cffff8c00", datas326:get_Item(1).Damage, "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas326:get_Item(1).RadiantDmgAmp * 100)), "%|r的光辉易伤，持续|cffff8c00", datas326:get_Item(1).Duration, "|r秒。\n|cffffcc003级|r - 审判最多|cffff8c00", datas326:get_Item(2).TargetCount, "|r个目标，造成|cffff8c00", datas326:get_Item(2).Damage, "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas326:get_Item(2).RadiantDmgAmp * 100)), "%|r的光辉易伤，持续|cffff8c00", datas326:get_Item(2).Duration, "|r秒。"), 0)
    do
        local i330 = 0
        while (i330 < 3) do
            local __unpack_tmp333 = datas326:get_Item(i330)
            local data__TargetCount, data__Damage331, data__RadiantDmgAmp, data__Duration332 = __unpack_tmp333.TargetCount, __unpack_tmp333.Damage, __unpack_tmp333.RadiantDmgAmp, __unpack_tmp333.Duration
            SF__.Utils.ExBlzSetAbilityTooltip(p325, SF__.DivineToll.ID, SF__.StrConcat__("圣洁鸣钟 - [|cffffcc00", (i330 + 1), "级|r]"), i330)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p325, SF__.DivineToll.ID, SF__.StrConcat__("对附近的最多|cffff8c00", data__TargetCount, "|r个目标施展审判，造成|cffff8c00", data__Damage331, "|r点法术伤害，然后神圣之锤环绕圣殿骑士，每次命中敌人使其受到的光辉伤害提高|cffff8c00", string.format("%.0f", (data__RadiantDmgAmp * 100)), "%|r，持续|cffff8c00", data__Duration332, "|r秒。每个审判产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 30秒"), i330)
            ::continue::
            i330 = (i330 + 1)
        end
    end
end

function SF__.DivineToll.HurlToTarget(caster334, target335, pos__x336, pos__y337, pos__z)
    local outer = SF__.GameObject.New__s("DivineToll_Outer")
    local EventCenter341 = require("Lib.EventCenter")
    outer.transform.localPosition__x, outer.transform.localPosition__y, outer.transform.localPosition__z = 0, 0, 80
    local moveLayer = SF__.GameObject.New__sgameobject("MoveLayer", outer)
    moveLayer.transform.localPosition__x, moveLayer.transform.localPosition__y, moveLayer.transform.localPosition__z = pos__x336, pos__y337, pos__z
    local mis = moveLayer:AddComponent(SF__.Missile)
    mis.targetType = SF__.TargetType.Unit
    mis.unitTarget = target335
    mis.speed = 900
    mis.lookAtTarget = true
    mis.colliderSize = 32
    mis.onArrived = function()
        local cPos__x, cPos__y, cPos__z = mis.gameObject.transform:get_position()
        local eff338 = ExAddSpecialEffect("Abilities/Spells/Human/StormBolt/StormBoltCaster.mdl", cPos__x, cPos__y, 0.1)
        BlzSetSpecialEffectTimeScale(eff338, 0.5)
        BlzSetSpecialEffectColor(eff338, 255, 255, 0)
        local ad__TargetCount, ad__Damage339, ad__RadiantDmgAmp, ad__Duration340 = SF__.DivineToll.GetAbilityData(GetUnitAbilityLevel(caster334, SF__.DivineToll.ID))
        EventCenter341.Damage:Emit({whichUnit = caster334, target = target335, amount = ad__Damage339, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
        SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(caster334, 1)
        moveLayer:RemoveAllComponents(SF__.Missile)
        local casterPos__x, casterPos__y, casterPos__z = SF__.Vector3.FromUnit(caster334)
        local circulator342 = SF__.GameObject.New__sgameobject("Circulator", outer)
        circulator342.transform.localPosition__x, circulator342.transform.localPosition__y, circulator342.transform.localPosition__z = casterPos__x, casterPos__y, casterPos__z
        local rot = circulator342:AddComponent(SF__.AutoTRSComponent)
        rot.rotation__x, rot.rotation__y, rot.rotation__z, rot.rotation__w = SF__.Quaternion.Euler(0, 0, ((360 * SF__.Scene.DT) / 1000))
        moveLayer.transform:SetParent(circulator342.transform)
        moveLayer.transform.localPosition__x, moveLayer.transform.localPosition__y, moveLayer.transform.localPosition__z = 250, 0, 0
    end
    local orientationFixLayer = SF__.GameObject.New__sgameobject("DivineToll_Bolt", moveLayer)
    orientationFixLayer.transform.localRotation__x, orientationFixLayer.transform.localRotation__y, orientationFixLayer.transform.localRotation__z, orientationFixLayer.transform.localRotation__w = SF__.Quaternion.Euler(0, 90, 0)
    local selfRotLayer = SF__.GameObject.New__sgameobject("dt_hand", orientationFixLayer)
    local receiver = selfRotLayer:AddComponent(SF__.AutoTRSComponent)
    receiver.rotation__x, receiver.rotation__y, receiver.rotation__z, receiver.rotation__w = SF__.Quaternion.Euler(((1800 * SF__.Scene.DT) / 1000), 0, 0)
    local boltMis = SF__.GameObject.New__sgameobject("dt_mis", selfRotLayer)
    boltMis.transform.localPosition__x, boltMis.transform.localPosition__y, boltMis.transform.localPosition__z = 15, 0, 0
    boltMis.transform.localScale__x, boltMis.transform.localScale__y, boltMis.transform.localScale__z = 0.5, 0.5, 0.5
    local eff343 = AddSpecialEffect("Abilities/Spells/Human/StormBolt/StormBoltMissile.mdl", pos__x336, pos__y337)
    boltMis:AddComponent(SF__.AttachEffectComponent).eff = eff343
    local attachedHoly = SF__.GameObject.New__sgameobject("DivineToll_Holy", boltMis)
    attachedHoly.transform.localPosition__x, attachedHoly.transform.localPosition__y, attachedHoly.transform.localPosition__z = 15, 0, 0
    local effHoly = AddSpecialEffect("Abilities/Weapons/FaerieDragonMissile/FaerieDragonMissile.mdl", pos__x336, pos__y337)
    attachedHoly:AddComponent(SF__.AttachEffectComponent).eff = effHoly
    BlzSetSpecialEffectColor(effHoly, 20, 20, 20)
end

function SF__.DivineToll.Start(data344)
    return SF__.CorRun__(function()
        local pos__x345, pos__y346, pos__z347 = SF__.Vector3.FromUnit(data344.caster)
        local targets = SF__.Utils.CsGroupGetUnitsInRange(pos__x345, pos__y346, 600, function(u348)
            if (not IsUnitEnemy(u348, GetOwningPlayer(data344.caster))) then
                return false
            end
            if IsUnitType(u348, UNIT_TYPE_STRUCTURE) then
                return false
            end
            if ExIsUnitDead(u348) then
                return false
            end
            return true
        end)
        if (targets.Count == 0) then
            return
        end
        targets:Sort(function(a351, b352)
            local distA353 = SF__.Vector3.Distance(pos__x345, pos__y346, pos__z347, SF__.Vector3.FromUnit(a351))
            local distB354 = SF__.Vector3.Distance(pos__x345, pos__y346, pos__z347, SF__.Vector3.FromUnit(b352))
            return (function() if (distA353 == distB354) then return 0 else return (function() if (distA353 < distB354) then return (-1) else return 1 end end)() end end)()
        end)
        do
            local i355 = 0
            while (i355 < (function()
                local field__TargetCount, field__Damage, field__RadiantDmgAmp, field__Duration = SF__.DivineToll.GetAbilityData(GetUnitAbilityLevel(data344.caster, SF__.DivineToll.ID))
                return math.min(targets.Count, field__TargetCount)
            end)()) do
                SF__.DivineToll.HurlToTarget(data344.caster, targets:get_Item(i355), pos__x345, pos__y346, pos__z347)
                SF__.CorWait__(200)
                ::continue::
                i355 = (i355 + 1)
            end
        end
    end)
end

function SF__.DivineToll.__Init(self)
    self.__sf_type = SF__.DivineToll
end

function SF__.DivineToll.New()
    local self = setmetatable({}, { __index = SF__.DivineToll })
    SF__.DivineToll.__Init(self)
    return self
end

SF__.DivineToll.ID = FourCC("A008")
-- Easing
SF__.Easing = SF__.Easing or {}
SF__.Easing.Name = "Easing"
SF__.Easing.FullName = "Easing"
function SF__.Easing.Linear(t)
    return t
end

function SF__.Easing.OutQubic(t54)
    return (1 - ((1 - t54) ^ 3))
end

function SF__.Easing.__Init(self)
    self.__sf_type = SF__.Easing
end

function SF__.Easing.New()
    local self = setmetatable({}, { __index = SF__.Easing })
    SF__.Easing.__Init(self)
    return self
end
-- LuaWrapper.CHeroAttributeType
SF__.LuaWrapper.CHeroAttributeType = SF__.LuaWrapper.CHeroAttributeType or {}
SF__.LuaWrapper.CHeroAttributeType.Name = "CHeroAttributeType"
SF__.LuaWrapper.CHeroAttributeType.FullName = "LuaWrapper.CHeroAttributeType"
function SF__.LuaWrapper.CHeroAttributeType.__Init(self)
    self.__sf_type = SF__.LuaWrapper.CHeroAttributeType
    self.Strength = 0
    self.Agility = 0
    self.Intelligent = 0
end

function SF__.LuaWrapper.CHeroAttributeType.New()
    local self = setmetatable({}, { __index = SF__.LuaWrapper.CHeroAttributeType })
    SF__.LuaWrapper.CHeroAttributeType.__Init(self)
    return self
end
-- LuaWrapper.ISpellData
SF__.LuaWrapper.ISpellData = SF__.LuaWrapper.ISpellData or {}
SF__.LuaWrapper.ISpellData.Name = "ISpellData"
SF__.LuaWrapper.ISpellData.FullName = "LuaWrapper.ISpellData"
function SF__.LuaWrapper.ISpellData.__Init(self)
    self.__sf_type = SF__.LuaWrapper.ISpellData
    self.abilityId = 0
    self.caster = nil
    self.target = nil
    self.x = 0
    self.y = 0
    self.item = nil
    self.destructable = nil
    self.finished = false
    self.interrupted = nil
    self._effectDone = false
end

function SF__.LuaWrapper.ISpellData.New()
    local self = setmetatable({}, { __index = SF__.LuaWrapper.ISpellData })
    SF__.LuaWrapper.ISpellData.__Init(self)
    return self
end
-- TemplarStrikes
SF__.TemplarStrikes = SF__.TemplarStrikes or {}
SF__.TemplarStrikes.Name = "TemplarStrikes"
SF__.TemplarStrikes.FullName = "TemplarStrikes"
function SF__.TemplarStrikes.GetAbilityData(level364)
    return 2, (0.5 + (0.25 * level364)), (0.05 * level364)
end

function SF__.TemplarStrikes.Init()
    local EventCenter365 = require("Lib.EventCenter")
    EventCenter365.RegisterPlayerUnitSpellEffect:Emit({id = SF__.TemplarStrikes.ID, handler = SF__.TemplarStrikes.Start})
    ExTriggerRegisterNewUnit(function(u367)
        if (GetUnitTypeId(u367) == FourCC("Hpal")) then
            SF__.TemplarStrikes.UpdateAbilityMeta(u367)
            SetHeroLevel(u367, 10, true)
        end
    end)
    EventCenter365.RegisterPlayerUnitDamaged:Emit(function(caster371, target372, damage373, weapType374, dmgType375, isAttack376)
        if (GetUnitAbilityLevel(caster371, SF__.TemplarStrikes.ID) <= 0) then
            return
        end
        if (not isAttack376) then
            return
        end
        if (target372 == nil) then
            return
        end
        if ExIsUnitDead(target372) then
            return
        end
        SF__.TemplarStrikes.TryResetBOJ(caster371)
    end)
end

function SF__.TemplarStrikes.TryResetBOJ(caster377)
    local level378 = GetUnitAbilityLevel(caster377, SF__.TemplarStrikes.ID)
    local ad__AttackCount, ad__DamageScaling379, ad__ResetBOJChance = SF__.TemplarStrikes.GetAbilityData(level378)
    if (math.random() >= ad__ResetBOJChance) then
        return
    end
    BlzEndUnitAbilityCooldown(caster377, SF__.BladeOfJustice.ID)
    ExAddSpecialEffectTarget("Abilities/Spells/Items/AIam/AIamTarget.mdl", caster377, "origin", 0.3)
end

function SF__.TemplarStrikes.UpdateAbilityMeta(u380)
    local p381 = GetOwningPlayer(u380)
    local datas382 = SF__.StdLib.List.New__0()
    do
        local i383 = 0
        while (i383 < SF__.TemplarStrikes.MaxLevel) do
            local __pack_AttackCount, __pack_DamageScaling384, __pack_ResetBOJChance = SF__.TemplarStrikes.GetAbilityData((i383 + 1))
            datas382:Add({AttackCount = __pack_AttackCount, DamageScaling = __pack_DamageScaling384, ResetBOJChance = __pack_ResetBOJChance})
            ::continue::
            i383 = (i383 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p381, SF__.TemplarStrikes.ID, "学习圣殿骑士之击 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p381, SF__.TemplarStrikes.ID, SF__.StrConcat__("快速攻击目标|cffff8c00", datas382:get_Item(0).AttackCount, "|r次，第一次造成普通攻击伤害，第二次造成光辉伤害，有一定几率重置公正之剑的冷却时间，普通攻击也会触发。\n\n|cff99ccff冷却时间|r - 10秒\n\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas382:get_Item(0).DamageScaling * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas382:get_Item(0).ResetBOJChance * 100)), "%|r的几率重置公正之剑。\n|cffffcc002级|r - |cffff8c00", string.format("%.0f", (datas382:get_Item(1).DamageScaling * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas382:get_Item(1).ResetBOJChance * 100)), "%|r的几率重置公正之剑。\n|cffffcc003级|r - |cffff8c00", string.format("%.0f", (datas382:get_Item(2).DamageScaling * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas382:get_Item(2).ResetBOJChance * 100)), "%|r的几率重置公正之剑。"), 0)
    do
        local i385 = 0
        while (i385 < SF__.TemplarStrikes.MaxLevel) do
            local __unpack_tmp387 = datas382:get_Item(i385)
            local data__AttackCount, data__DamageScaling386, data__ResetBOJChance = __unpack_tmp387.AttackCount, __unpack_tmp387.DamageScaling, __unpack_tmp387.ResetBOJChance
            SF__.Utils.ExBlzSetAbilityTooltip(p381, SF__.TemplarStrikes.ID, SF__.StrConcat__("圣殿骑士之击 - [|cffffcc00", (i385 + 1), "级|r]"), i385)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p381, SF__.TemplarStrikes.ID, SF__.StrConcat__("快速攻击目标|cffff8c00", data__AttackCount, "|r次，第一次造成普通攻击伤害，第二次造成普通攻击|cffff8c00", string.format("%.0f", (data__DamageScaling386 * 100)), "%|r的光辉伤害，|cffff8c00", string.format("%.0f", (data__ResetBOJChance * 100)), "%|r几率重置公正之剑的冷却时间，普通攻击也会触发。\n\n|cff99ccff冷却时间|r - 10秒"), i385)
            ::continue::
            i385 = (i385 + 1)
        end
    end
end

function SF__.TemplarStrikes.Start(data388)
    return SF__.CorRun__(function()
        local level389 = GetUnitAbilityLevel(data388.caster, SF__.TemplarStrikes.ID)
        local UnitAttribute391 = require("Objects.UnitAttribute")
        local EventCenter392 = require("Lib.EventCenter")
        local attr390 = UnitAttribute391.GetAttr(data388.caster)
        local normalDamage = attr390:SimMeleeAttack()
        EventCenter392.Damage:Emit({whichUnit = data388.caster, target = data388.target, amount = normalDamage, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
        SF__.TemplarStrikes.TryResetBOJ(data388.caster)
        SetUnitTimeScale(data388.caster, 3)
        ResetUnitAnimation(data388.caster)
        SetUnitAnimation(data388.caster, "attack - 2")
        SF__.CorWait__(math.round(((1.166 * 0.33) * 1000)))
        local tarAttr393 = UnitAttribute391.GetAttr(data388.target)
        local ad__AttackCount394, ad__DamageScaling395, ad__ResetBOJChance396 = SF__.TemplarStrikes.GetAbilityData(level389)
        local radiantDamage = ((attr390:SimMeleeAttack() * ad__DamageScaling395) * (1 - tarAttr393.radiantResistance))
        EventCenter392.Damage:Emit({whichUnit = data388.caster, target = data388.target, amount = radiantDamage, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
        SF__.TemplarStrikes.TryResetBOJ(data388.caster)
        SetUnitTimeScale(data388.caster, 1)
        ResetUnitAnimation(data388.caster)
    end)
end

function SF__.TemplarStrikes.__Init(self)
    self.__sf_type = SF__.TemplarStrikes
end

function SF__.TemplarStrikes.New()
    local self = setmetatable({}, { __index = SF__.TemplarStrikes })
    SF__.TemplarStrikes.__Init(self)
    return self
end

SF__.TemplarStrikes.ID = FourCC("A007")
SF__.TemplarStrikes.MaxLevel = 3
-- WordOfGlory
SF__.WordOfGlory = SF__.WordOfGlory or {}
SF__.WordOfGlory.Name = "WordOfGlory"
SF__.WordOfGlory.FullName = "WordOfGlory"
function SF__.WordOfGlory.Init()
    local EventCenter419 = require("Lib.EventCenter")
    EventCenter419.RegisterPlayerUnitSpellChannel:Emit({id = SF__.WordOfGlory.ID, handler = SF__.WordOfGlory.Check})
    EventCenter419.RegisterPlayerUnitSpellEffect:Emit({id = SF__.WordOfGlory.ID, handler = SF__.WordOfGlory.Start})
    ExTriggerRegisterNewUnit(function(u421)
        if (GetUnitTypeId(u421) == FourCC("Hpal")) then
            SF__.WordOfGlory.UpdateAbilityMeta(u421)
        end
    end)
end

function SF__.WordOfGlory.Check(data422)
    local UnitAttribute424 = require("Objects.UnitAttribute")
    local attr423 = UnitAttribute424.GetAttr(data422.caster)
    if (attr423.retPalHolyEnergy < 3) then
        IssueImmediateOrderById(data422.caster, SF__.ConstOrderId.Stop)
        ExTextState(data422.caster, "圣能不足")
    end
end

function SF__.WordOfGlory.UpdateAbilityMeta(u425)
    local p426 = GetOwningPlayer(u425)
    SF__.Utils.ExSetAbilityResearchTooltip(p426, SF__.WordOfGlory.ID, "学习圣殿骑士的裁决 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p426, SF__.WordOfGlory.ID, "圣殿骑士的裁决造成一次攻击伤害，如果目标被审判，造成30%的额外伤害，15%几率重置审判。消耗|cffff8c003|r点圣能。\n\n|cff99ccff冷却时间|r - 5秒\n\n|cffffcc001级|r - |cffff8c00100%|r的攻击伤害，100%的战争艺术触发几率。", 0)
    do
        local i427 = 0
        while (i427 < 1) do
            SF__.Utils.ExBlzSetAbilityTooltip(p426, SF__.WordOfGlory.ID, SF__.StrConcat__("圣殿骑士的裁决 - [|cffffcc00", (i427 + 1), "级|r]"), i427)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p426, SF__.WordOfGlory.ID, "圣殿骑士的裁决造成一次攻击伤害，造成|cffff8c00100%|r的攻击伤害。消耗|cffff8c003|r点圣能。\n\n|cff99ccff冷却时间|r - 5秒", i427)
            ::continue::
            i427 = (i427 + 1)
        end
    end
end

function SF__.WordOfGlory.Start(data428)
    local UnitAttribute430 = require("Objects.UnitAttribute")
    local EventCenter431 = require("Lib.EventCenter")
    local attr429 = UnitAttribute430.GetAttr(data428.caster)
    EventCenter431.Heal:Emit({caster = data428.caster, target = data428.target, amount = 300})
    attr429.retPalHolyEnergy = (attr429.retPalHolyEnergy - 3)
end

function SF__.WordOfGlory.__Init(self)
    self.__sf_type = SF__.WordOfGlory
end

function SF__.WordOfGlory.New()
    local self = setmetatable({}, { __index = SF__.WordOfGlory })
    SF__.WordOfGlory.__Init(self)
    return self
end

SF__.WordOfGlory.ID = FourCC("A006")
SF__.Systems = SF__.Systems or {}
-- Systems.InitAbilitiesSystem
local SystemBase = require("System.SystemBase")
SF__.Systems.InitAbilitiesSystem = SF__.Systems.InitAbilitiesSystem or class("InitAbilitiesSystem", SystemBase)
SF__.Systems.InitAbilitiesSystem.Name = "InitAbilitiesSystem"
SF__.Systems.InitAbilitiesSystem.FullName = "Systems.InitAbilitiesSystem"
SF__.Systems.InitAbilitiesSystem.__sf_base = SystemBase
function SF__.Systems.InitAbilitiesSystem:Awake()
    SF__.RetributionPaladinGlobal.Instance:Init()
    SF__.TemplarStrikes.Init()
    SF__.BladeOfJustice.Init()
    SF__.DivineToll.Init()
    SF__.WordOfGlory.Init()
end

function SF__.Systems.InitAbilitiesSystem.__Init(self)
    self.__sf_type = SF__.Systems.InitAbilitiesSystem
end

function SF__.Systems.InitAbilitiesSystem.New()
    local self = SF__.Systems.InitAbilitiesSystem.new()
    SF__.Systems.InitAbilitiesSystem.__Init(self)
    return self
end
-- Systems.InspectorSystem
local SystemBase30 = require("System.SystemBase")
SF__.Systems.InspectorSystem = SF__.Systems.InspectorSystem or class("InspectorSystem", SystemBase30)
SF__.Systems.InspectorSystem.Name = "InspectorSystem"
SF__.Systems.InspectorSystem.FullName = "Systems.InspectorSystem"
SF__.Systems.InspectorSystem.__sf_base = SystemBase30
function SF__.Systems.InspectorSystem:Awake()
    self:CreateFrames()
    self:RefreshHierarchy()
    self:SelectFirstVisibleObject()
    self:SetPanelVisible(false)
end

function SF__.Systems.InspectorSystem:Update(dt31)
    if (not self._isVisible) then
        return
    end
    if (self._lastObjectCount ~= SF__.Scene.get_Instance().gameObjs.Count) then
        self:RefreshHierarchy()
    end
    if ((self._selectedGameObject == nil) or (not self:SceneContains(self._selectedGameObject))) then
        self:SelectFirstVisibleObject()
    end
    self:RefreshInspectorText()
end

function SF__.Systems.InspectorSystem:CreateFrames()
    self._root = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
    self._toggleButton = BlzCreateFrameByType("BUTTON", "FdfInspectorToggle", self._root, "ScoreScreenTabButtonTemplate", 0)
    BlzFrameSetAbsPoint(self._toggleButton, FRAMEPOINT_BOTTOMLEFT, 0.006, 0.006)
    BlzFrameSetSize(self._toggleButton, SF__.Systems.InspectorSystem.ToggleSize, SF__.Systems.InspectorSystem.ToggleSize)
    self._toggleText = BlzCreateFrameByType("TEXT", "FdfInspectorToggleText", self._toggleButton, "", 0)
    BlzFrameSetAllPoints(self._toggleText, self._toggleButton)
    BlzFrameSetEnable(self._toggleText, false)
    BlzFrameSetTextAlignment(self._toggleText, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_CENTER)
    BlzFrameSetText(self._toggleText, "IN")
    local toggleTrigger = CreateTrigger()
    BlzTriggerRegisterFrameEvent(toggleTrigger, self._toggleButton, FRAMEEVENT_CONTROL_CLICK)
    TriggerAddAction(toggleTrigger, function()
        self:TogglePanel()
    end)
    self._panel = BlzCreateFrameByType("FRAME", "FdfInspectorPanel", self._root, "", 0)
    BlzFrameSetAbsPoint(self._panel, FRAMEPOINT_BOTTOMLEFT, 0.006, 0.048)
    BlzFrameSetSize(self._panel, SF__.Systems.InspectorSystem.PanelWidth, SF__.Systems.InspectorSystem.PanelHeight)
    local panelBackdrop = BlzCreateFrame("EscMenuBackdrop", self._panel, 0, 0)
    BlzFrameSetAllPoints(panelBackdrop, self._panel)
    self:CreatePanelText("FDF Inspector", 0.012, (-0.012), 0.14, 0.016, TEXT_JUSTIFY_LEFT)
    self:CreatePanelText("Hierarchy", SF__.Systems.InspectorSystem.Padding, (-0.034), (SF__.Systems.InspectorSystem.LeftWidth - (SF__.Systems.InspectorSystem.Padding * 2)), 0.014, TEXT_JUSTIFY_LEFT)
    self:CreatePanelText("Components", (SF__.Systems.InspectorSystem.LeftWidth + (SF__.Systems.InspectorSystem.Padding * 2)), (-0.034), ((SF__.Systems.InspectorSystem.PanelWidth - SF__.Systems.InspectorSystem.LeftWidth) - (SF__.Systems.InspectorSystem.Padding * 3)), 0.014, TEXT_JUSTIFY_LEFT)
    local leftBackdrop = BlzCreateFrame("QuestButtonBaseTemplate", self._panel, 0, 0)
    BlzFrameSetPoint(leftBackdrop, FRAMEPOINT_TOPLEFT, self._panel, FRAMEPOINT_TOPLEFT, SF__.Systems.InspectorSystem.Padding, (-0.052))
    BlzFrameSetSize(leftBackdrop, (SF__.Systems.InspectorSystem.LeftWidth - (SF__.Systems.InspectorSystem.Padding * 2)), (SF__.Systems.InspectorSystem.PanelHeight - 0.066))
    local rightBackdrop = BlzCreateFrame("QuestButtonBaseTemplate", self._panel, 0, 0)
    BlzFrameSetPoint(rightBackdrop, FRAMEPOINT_TOPLEFT, self._panel, FRAMEPOINT_TOPLEFT, (SF__.Systems.InspectorSystem.LeftWidth + SF__.Systems.InspectorSystem.Padding), (-0.052))
    BlzFrameSetSize(rightBackdrop, ((SF__.Systems.InspectorSystem.PanelWidth - SF__.Systems.InspectorSystem.LeftWidth) - (SF__.Systems.InspectorSystem.Padding * 2)), (SF__.Systems.InspectorSystem.PanelHeight - 0.066))
    do
        local i32 = 0
        while (i32 < SF__.Systems.InspectorSystem.MaxHierarchyRows) do
            self._hierarchyRows:Add(self:CreateHierarchyRow(i32))
            ::continue::
            i32 = (i32 + 1)
        end
    end
    self._inspectorText = BlzCreateFrameByType("TEXT", "FdfInspectorDetailsText", self._panel, "", 0)
    BlzFrameSetPoint(self._inspectorText, FRAMEPOINT_TOPLEFT, self._panel, FRAMEPOINT_TOPLEFT, (SF__.Systems.InspectorSystem.LeftWidth + (SF__.Systems.InspectorSystem.Padding * 2)), (-0.061))
    BlzFrameSetSize(self._inspectorText, ((SF__.Systems.InspectorSystem.PanelWidth - SF__.Systems.InspectorSystem.LeftWidth) - (SF__.Systems.InspectorSystem.Padding * 4)), (SF__.Systems.InspectorSystem.PanelHeight - 0.082))
    BlzFrameSetEnable(self._inspectorText, false)
    BlzFrameSetTextAlignment(self._inspectorText, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_LEFT)
    BlzFrameSetText(self._inspectorText, "")
    self._emptyText = BlzCreateFrameByType("TEXT", "FdfInspectorEmptyText", self._panel, "", 0)
    BlzFrameSetPoint(self._emptyText, FRAMEPOINT_TOPLEFT, self._panel, FRAMEPOINT_TOPLEFT, (SF__.Systems.InspectorSystem.Padding * 2), (-0.066))
    BlzFrameSetSize(self._emptyText, (SF__.Systems.InspectorSystem.LeftWidth - (SF__.Systems.InspectorSystem.Padding * 4)), 0.04)
    BlzFrameSetEnable(self._emptyText, false)
    BlzFrameSetTextAlignment(self._emptyText, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_LEFT)
    BlzFrameSetText(self._emptyText, "No GameObjects")
end

function SF__.Systems.InspectorSystem:CreatePanelText(text, x, y, width, height, horizontalAlign)
    local label = BlzCreateFrameByType("TEXT", "FdfInspectorLabel", self._panel, "", 0)
    BlzFrameSetPoint(label, FRAMEPOINT_TOPLEFT, self._panel, FRAMEPOINT_TOPLEFT, x, y)
    BlzFrameSetSize(label, width, height)
    BlzFrameSetEnable(label, false)
    BlzFrameSetTextAlignment(label, TEXT_JUSTIFY_TOP, horizontalAlign)
    BlzFrameSetText(label, text)
end

function SF__.Systems.InspectorSystem:CreateHierarchyRow(index)
    local y33 = ((-0.061) - (index * (SF__.Systems.InspectorSystem.RowHeight + SF__.Systems.InspectorSystem.RowGap)))
    local button = BlzCreateFrameByType("BUTTON", "FdfInspectorHierarchyRow", self._panel, "ScoreScreenTabButtonTemplate", index)
    BlzFrameSetPoint(button, FRAMEPOINT_TOPLEFT, self._panel, FRAMEPOINT_TOPLEFT, (SF__.Systems.InspectorSystem.Padding * 2), y33)
    BlzFrameSetSize(button, (SF__.Systems.InspectorSystem.LeftWidth - (SF__.Systems.InspectorSystem.Padding * 4)), SF__.Systems.InspectorSystem.RowHeight)
    local label34 = BlzCreateFrameByType("TEXT", "FdfInspectorHierarchyRowText", button, "", index)
    BlzFrameSetPoint(label34, FRAMEPOINT_TOPLEFT, button, FRAMEPOINT_TOPLEFT, 0.004, (-0.002))
    BlzFrameSetSize(label34, (SF__.Systems.InspectorSystem.LeftWidth - (SF__.Systems.InspectorSystem.Padding * 5)), (SF__.Systems.InspectorSystem.RowHeight - 0.003))
    BlzFrameSetEnable(label34, false)
    BlzFrameSetTextAlignment(label34, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_LEFT)
    BlzFrameSetText(label34, "")
    local row = SF__.Systems.InspectorSystem.HierarchyRow.New(button, label34)
    local trigger = CreateTrigger()
    BlzTriggerRegisterFrameEvent(trigger, button, FRAMEEVENT_CONTROL_CLICK)
    TriggerAddAction(trigger, function()
        self:SelectRow(row)
    end)
    BlzFrameSetVisible(button, false)
    return row
end

function SF__.Systems.InspectorSystem:TogglePanel()
    self:SetPanelVisible((not self._isVisible))
end

function SF__.Systems.InspectorSystem:SetPanelVisible(visible)
    self._isVisible = visible
    BlzFrameSetVisible(self._panel, visible)
    BlzFrameSetText(self._toggleText, (function() if visible then return "X" else return "IN" end end)())
    if visible then
        self:RefreshHierarchy()
        if (self._selectedGameObject == nil) then
            self:SelectFirstVisibleObject()
        end
        self:RefreshInspectorText()
    end
end

function SF__.Systems.InspectorSystem:SelectRow(row35)
    if (row35.gameObject == nil) then
        return
    end
    self._selectedGameObject = row35.gameObject
    self:RefreshHierarchySelection()
    self:RefreshInspectorText()
end

function SF__.Systems.InspectorSystem:SelectFirstVisibleObject()
    self._selectedGameObject = (function() if (self._visibleObjects.Count > 0) then return self._visibleObjects:get_Item(0) else return nil end end)()
    self:RefreshHierarchySelection()
    self:RefreshInspectorText()
end

function SF__.Systems.InspectorSystem:RefreshHierarchy()
    self._visibleObjects:Clear()
    do
        local collection9 = SF__.Scene.get_Instance().gameObjs
        for _, obj36 in (SF__.StdLib.List.IpairsNext)(collection9) do
            if (obj36.transform.parent == nil) then
                self:AddHierarchyObject(obj36, 0)
            end
        end
    end
    do
        local i37 = 0
        while (i37 < self._hierarchyRows.Count) do
            local row38 = self._hierarchyRows:get_Item(i37)
            if (i37 < self._visibleObjects.Count) then
                local obj39 = self._visibleObjects:get_Item(i37)
                row38.gameObject = obj39
                row38.depth = self:GetDepth(obj39)
                self:SetRowLabel(row38, obj39.name, row38.depth)
                BlzFrameSetVisible(row38.button, self._isVisible)
            else
                row38.gameObject = nil
                BlzFrameSetVisible(row38.button, false)
            end
            ::continue::
            i37 = (i37 + 1)
        end
    end
    BlzFrameSetVisible(self._emptyText, (self._isVisible and (self._visibleObjects.Count == 0)))
    self._lastObjectCount = SF__.Scene.get_Instance().gameObjs.Count
    self:RefreshHierarchySelection()
end

function SF__.Systems.InspectorSystem:AddHierarchyObject(obj40, depth)
    if (self._visibleObjects.Count >= SF__.Systems.InspectorSystem.MaxHierarchyRows) then
        return
    end
    self._visibleObjects:Add(obj40)
    do
        local collection10 = obj40.transform.children
        for _, child41 in (SF__.StdLib.List.IpairsNext)(collection10) do
            self:AddHierarchyObject(child41.gameObject, (depth + 1))
        end
    end
end

function SF__.Systems.InspectorSystem:GetDepth(obj42)
    local depth43 = 0
    local parent44 = obj42.transform.parent
    while (parent44 ~= nil) do
        depth43 = (depth43 + 1)
        parent44 = parent44.parent
        ::continue::
    end
    return depth43
end

function SF__.Systems.InspectorSystem:SetRowLabel(row45, text46, depth47)
    BlzFrameClearAllPoints(row45.label)
    BlzFrameSetPoint(row45.label, FRAMEPOINT_TOPLEFT, row45.button, FRAMEPOINT_TOPLEFT, (0.004 + (depth47 * SF__.Systems.InspectorSystem.IndentWidth)), (-0.002))
    BlzFrameSetSize(row45.label, ((SF__.Systems.InspectorSystem.LeftWidth - (SF__.Systems.InspectorSystem.Padding * 5)) - (depth47 * SF__.Systems.InspectorSystem.IndentWidth)), (SF__.Systems.InspectorSystem.RowHeight - 0.003))
    BlzFrameSetText(row45.label, text46)
end

function SF__.Systems.InspectorSystem:RefreshHierarchySelection()
    do
        local collection11 = self._hierarchyRows
        for _, row48 in (SF__.StdLib.List.IpairsNext)(collection11) do
            local isSelected = ((row48.gameObject ~= nil) and (row48.gameObject == self._selectedGameObject))
            BlzFrameSetTextColor(row48.label, (function() if isSelected then return BlzConvertColor(255, 255, 220, 80) else return BlzConvertColor(255, 230, 230, 230) end end)())
        end
    end
end

function SF__.Systems.InspectorSystem:RefreshInspectorText()
    if (self._selectedGameObject == nil) then
        BlzFrameSetText(self._inspectorText, "")
        return
    end
    local text49 = SF__.StrConcat__(self._selectedGameObject.name, "\n")
    do
        local collection12 = self._selectedGameObject:get_components()
        for _, component in (SF__.StdLib.List.IpairsNext)(collection12) do
            text49 = SF__.StrConcat__(text49, "\n[", component.__sf_type.Name, "]")
            local inspectorText = component:GetInspectorText()
            if (inspectorText ~= "") then
                text49 = SF__.StrConcat__(text49, "\n", inspectorText)
            end
        end
    end
    BlzFrameSetText(self._inspectorText, text49)
end

function SF__.Systems.InspectorSystem:SceneContains(gameObject)
    do
        local collection13 = SF__.Scene.get_Instance().gameObjs
        for _, obj50 in (SF__.StdLib.List.IpairsNext)(collection13) do
            if (obj50 == gameObject) then
                return true
            end
        end
    end
    return false
end

function SF__.Systems.InspectorSystem.__Init(self)
    self.__sf_type = SF__.Systems.InspectorSystem
    self._hierarchyRows = SF__.StdLib.List.New__0()
    self._visibleObjects = SF__.StdLib.List.New__0()
    self._isVisible = false
    self._selectedGameObject = nil
    self._root = nil
    self._toggleButton = nil
    self._toggleText = nil
    self._panel = nil
    self._inspectorText = nil
    self._emptyText = nil
    self._lastObjectCount = (-1)
end

function SF__.Systems.InspectorSystem.New()
    local self = SF__.Systems.InspectorSystem.new()
    SF__.Systems.InspectorSystem.__Init(self)
    return self
end

SF__.Systems.InspectorSystem.MaxHierarchyRows = 18
SF__.Systems.InspectorSystem.ToggleSize = 0.036
SF__.Systems.InspectorSystem.PanelWidth = 0.48
SF__.Systems.InspectorSystem.PanelHeight = 0.34
SF__.Systems.InspectorSystem.RowHeight = 0.016
SF__.Systems.InspectorSystem.RowGap = 0.002
SF__.Systems.InspectorSystem.LeftWidth = 0.18
SF__.Systems.InspectorSystem.Padding = 0.008
SF__.Systems.InspectorSystem.IndentWidth = 0.012
-- Systems.InspectorSystem.HierarchyRow
SF__.Systems.InspectorSystem.HierarchyRow = SF__.Systems.InspectorSystem.HierarchyRow or {}
SF__.Systems.InspectorSystem.HierarchyRow.Name = "HierarchyRow"
SF__.Systems.InspectorSystem.HierarchyRow.FullName = "Systems.InspectorSystem.HierarchyRow"
function SF__.Systems.InspectorSystem.HierarchyRow.__Init(self, button51, label52)
    self.__sf_type = SF__.Systems.InspectorSystem.HierarchyRow
    self.button = nil
    self.label = nil
    self.gameObject = nil
    self.depth = 0
    self.button = button51
    self.label = label52
end

function SF__.Systems.InspectorSystem.HierarchyRow.New(button51, label52)
    local self = setmetatable({}, { __index = SF__.Systems.InspectorSystem.HierarchyRow })
    SF__.Systems.InspectorSystem.HierarchyRow.__Init(self, button51, label52)
    return self
end
-- Systems.MeleeGameSystem
local SystemBase53 = require("System.SystemBase")
SF__.Systems.MeleeGameSystem = SF__.Systems.MeleeGameSystem or class("MeleeGameSystem", SystemBase53)
SF__.Systems.MeleeGameSystem.Name = "MeleeGameSystem"
SF__.Systems.MeleeGameSystem.FullName = "Systems.MeleeGameSystem"
SF__.Systems.MeleeGameSystem.__sf_base = SystemBase53
function SF__.Systems.MeleeGameSystem.__Init(self)
    self.__sf_type = SF__.Systems.MeleeGameSystem
    MeleeStartingVisibility()
    MeleeStartingHeroLimit()
    MeleeGrantHeroItems()
    MeleeStartingResources()
    MeleeClearExcessUnits()
    MeleeStartingUnits()
    MeleeStartingAI()
    MeleeInitVictoryDefeat()
end

function SF__.Systems.MeleeGameSystem.New()
    local self = SF__.Systems.MeleeGameSystem.new()
    SF__.Systems.MeleeGameSystem.__Init(self)
    return self
end
-- Program
SF__.Program = SF__.Program or {}
SF__.Program.Name = "Program"
SF__.Program.FullName = "Program"
function SF__.Program.Main(args)
    CLI = {}
    local Time = require("Lib.Time")
    local FrameTimer = require("Lib.FrameTimer")
    require("Lib.CoroutineExt")
    require("Lib.TableExt")
    require("Lib.StringExt")
    require("Lib.native")
    local systems = SF__.StdLib.List.New__0()
    systems:Add(require("System.ItemSystem").new())
    systems:Add(require("System.SpellSystem").new())
    systems:Add(require("System.BuffSystem").new())
    systems:Add(require("System.DamageSystem").new())
    systems:Add(require("System.ProjectileSystem").new())
    systems:Add(SF__.Systems.InitAbilitiesSystem.New())
    systems:Add(SF__.Systems.InspectorSystem.New())
    systems:Add(require("System.BuffDisplaySystem").new())
    systems:Add(SF__.Systems.MeleeGameSystem.New())
    do
        local collection14 = systems
        for _, system in (SF__.StdLib.List.IpairsNext)(collection14) do
            system:Awake()
        end
    end
    local group = CreateGroup()
    GroupEnumUnitsInRect(group, bj_mapInitialPlayableArea, Filter(function()
        ExTriggerRegisterNewUnitExec(GetFilterUnit())
        return false
    end))
    DestroyGroup(group)
    do
        local collection15 = systems
        for _, system1 in (SF__.StdLib.List.IpairsNext)(collection15) do
            system1:OnEnable()
        end
    end
    local game = FrameTimer.new(function(dt)
        local now = (MathRound((Time.Time * 100)) * 0.01)
        do
            local collection16 = systems
            for _, system2 in (SF__.StdLib.List.IpairsNext)(collection16) do
                system2:Update(dt, now)
            end
        end
    end, 1, (-1))
    game:Start()
    SF__.Scene.get_Instance():Run()
end

function SF__.Program.__Init(self)
    self.__sf_type = SF__.Program
end

function SF__.Program.New()
    local self = setmetatable({}, { __index = SF__.Program })
    SF__.Program.__Init(self)
    return self
end
-- Stack
SF__.Stack = SF__.Stack or {}
SF__.Stack.Name = "Stack"
SF__.Stack.FullName = "Stack"
function SF__.Stack:Push(item)
    self._items:Add(item)
end

function SF__.Stack:Pop()
    if (self._items.Count == 0) then
        BJDebugMsg("Stack is empty.")
    end
    local item93 = self._items:get_Item((self._items.Count - 1))
    self._items:RemoveAt((self._items.Count - 1))
    return item93
end

function SF__.Stack:Peek()
    if (self._items.Count == 0) then
        BJDebugMsg("Stack is empty.")
    end
    return self._items:get_Item((self._items.Count - 1))
end

function SF__.Stack:get_Count()
    return self._items.Count
end

function SF__.Stack.__Init(self)
    self.__sf_type = SF__.Stack
    self._items = SF__.StdLib.List.New__0()
end

function SF__.Stack.New()
    local self = setmetatable({}, { __index = SF__.Stack })
    SF__.Stack.__Init(self)
    return self
end
-- <summary>
-- A basic dictionary backed by a Lua table with direct key access.
-- C# indexer (dict[key]) maps to direct table field access via get_Item/set_Item.
-- </summary>
--
-- StdLib.Dictionary
SF__.StdLib.Dictionary = SF__.StdLib.Dictionary or {}
SF__.StdLib.Dictionary.Name = "Dictionary"
SF__.StdLib.Dictionary.FullName = "StdLib.Dictionary"
function SF__.StdLib.Dictionary.__Init(self)
    self.__sf_type = SF__.StdLib.Dictionary
end

function SF__.StdLib.Dictionary.New()
    local self = setmetatable({}, { __index = SF__.StdLib.Dictionary })
    SF__.StdLib.Dictionary.__Init(self)
    return self
end
SF__.StdLib.List = SF__.StdLib.List or {}
-- StdLib.List.Enumerator
SF__.StdLib.List.Enumerator = SF__.StdLib.List.Enumerator or {}
SF__.StdLib.List.Enumerator.Name = "Enumerator"
SF__.StdLib.List.Enumerator.FullName = "StdLib.List.Enumerator"
function SF__.StdLib.List.Enumerator:get_Current()
    return nil
end

function SF__.StdLib.List.Enumerator:MoveNext()
    return nil
end

function SF__.StdLib.List.Enumerator.__Init(self)
    self.__sf_type = SF__.StdLib.List.Enumerator
end

function SF__.StdLib.List.Enumerator.New()
    local self = setmetatable({}, { __index = SF__.StdLib.List.Enumerator })
    SF__.StdLib.List.Enumerator.__Init(self)
    return self
end
-- TemplarVerdict
SF__.TemplarVerdict = SF__.TemplarVerdict or {}
SF__.TemplarVerdict.Name = "TemplarVerdict"
SF__.TemplarVerdict.FullName = "TemplarVerdict"
function SF__.TemplarVerdict.GetAbilityData(level397)
    return 2.25, 0.3, 0.15
end

function SF__.TemplarVerdict.Init()
    local EventCenter398 = require("Lib.EventCenter")
    EventCenter398.RegisterPlayerUnitSpellChannel:Emit({id = SF__.TemplarVerdict.ID, handler = SF__.TemplarVerdict.Check})
    EventCenter398.RegisterPlayerUnitSpellEffect:Emit({id = SF__.TemplarVerdict.ID, handler = SF__.TemplarVerdict.Start})
    ExTriggerRegisterNewUnit(function(u400)
        if (GetUnitTypeId(u400) == FourCC("Hpal")) then
            SF__.TemplarVerdict.UpdateAbilityMeta(u400)
        end
    end)
end

function SF__.TemplarVerdict.Check(data401)
    local UnitAttribute403 = require("Objects.UnitAttribute")
    local attr402 = UnitAttribute403.GetAttr(data401.caster)
    if (attr402.retPalHolyEnergy < 3) then
        IssueImmediateOrderById(data401.caster, SF__.ConstOrderId.Stop)
        ExTextState(data401.caster, "圣能不足")
    end
end

function SF__.TemplarVerdict.UpdateAbilityMeta(u404)
    local p405 = GetOwningPlayer(u404)
    local datas406 = SF__.StdLib.List.New__0()
    do
        local i407 = 0
        while (i407 < 1) do
            local __pack_DamageScaling408, __pack_JudgementDamageScaling, __pack_ChanceToResetJudgement = SF__.TemplarVerdict.GetAbilityData((i407 + 1))
            datas406:Add({DamageScaling = __pack_DamageScaling408, JudgementDamageScaling = __pack_JudgementDamageScaling, ChanceToResetJudgement = __pack_ChanceToResetJudgement})
            ::continue::
            i407 = (i407 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p405, SF__.TemplarVerdict.ID, "学习圣殿骑士的裁决 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p405, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决造成一次攻击伤害，如果目标被审判，造成30%的额外伤害，15%几率重置审判。消耗|cffff8c003|r点圣能。\n\n|cff99ccff冷却时间|r - 5秒\n\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas406:get_Item(0).JudgementDamageScaling * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas406:get_Item(0).ChanceToResetJudgement * 100)), "%的战争艺术触发几率。"), 0)
    do
        local i409 = 0
        while (i409 < 1) do
            local __unpack_tmp411 = datas406:get_Item(i409)
            local data__DamageScaling410, data__JudgementDamageScaling, data__ChanceToResetJudgement = __unpack_tmp411.DamageScaling, __unpack_tmp411.JudgementDamageScaling, __unpack_tmp411.ChanceToResetJudgement
            SF__.Utils.ExBlzSetAbilityTooltip(p405, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决 - [|cffffcc00", (i409 + 1), "级|r]"), i409)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p405, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决造成一次攻击伤害，造成|cffff8c00", string.format("%.0f", (data__DamageScaling410 * 100)), "%|r的攻击伤害。消耗|cffff8c003|r点圣能。\n\n|cff99ccff冷却时间|r - 5秒"), i409)
            ::continue::
            i409 = (i409 + 1)
        end
    end
end

function SF__.TemplarVerdict.Start(data412)
    local level413 = GetUnitAbilityLevel(data412.caster, SF__.TemplarVerdict.ID)
    local UnitAttribute416 = require("Objects.UnitAttribute")
    local EventCenter418 = require("Lib.EventCenter")
    local ad__DamageScaling414, ad__JudgementDamageScaling, ad__ChanceToResetJudgement = SF__.TemplarVerdict.GetAbilityData(level413)
    local attr415 = UnitAttribute416.GetAttr(data412.caster)
    local damage417 = (attr415:SimAttack(UnitAttribute416.HeroAttributeType.Strength) * ad__DamageScaling414)
    EventCenter418.Damage:Emit({whichUnit = data412.caster, target = data412.target, amount = damage417, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_SLICE, outResult = {}})
    attr415.retPalHolyEnergy = (attr415.retPalHolyEnergy - 3)
end

function SF__.TemplarVerdict.__Init(self)
    self.__sf_type = SF__.TemplarVerdict
end

function SF__.TemplarVerdict.New()
    local self = setmetatable({}, { __index = SF__.TemplarVerdict })
    SF__.TemplarVerdict.__Init(self)
    return self
end

SF__.TemplarVerdict.ID = FourCC("A004")
-- Vector2
SF__.Vector2 = SF__.Vector2 or {}
SF__.Vector2.Name = "Vector2"
SF__.Vector2.FullName = "Vector2"
function SF__.Vector2.get_Zero()
    return 0, 0
end

function SF__.Vector2.InsideUnitCircle()
    local angle = ((math.random() * 2) * math.pi)
    return math.cos(angle), math.sin(angle)
end

function SF__.Vector2.Dot(a__x108, a__y109, b__x110, b__y111)
    return ((a__x108 * b__x110) + (a__y109 * b__y111))
end

function SF__.Vector2.Cross(a__x112, a__y113, b__x114, b__y115)
    return ((a__y113 * b__x114) - (a__x112 * b__y115))
end

function SF__.Vector2.op_UnaryNegation(a__x116, a__y117)
    return (-a__x116), (-a__y117)
end

function SF__.Vector2.op_Addition(a__x118, a__y119, b__x120, b__y121)
    return (a__x118 + b__x120), (a__y119 + b__y121)
end

function SF__.Vector2.op_Subtraction(a__x122, a__y123, b__x124, b__y125)
    return (a__x122 - b__x124), (a__y123 - b__y125)
end

function SF__.Vector2.op_Multiply__vector2f(v__x126, v__y127, f)
    return (v__x126 * f), (v__y127 * f)
end

function SF__.Vector2.op_Multiply__fvector2(f128, v__x129, v__y130)
    return (v__x129 * f128), (v__y130 * f128)
end

function SF__.Vector2.op_Division(v__x131, v__y132, f133)
    return (v__x131 / f133), (v__y132 / f133)
end

function SF__.Vector2.UnitDistance(a, b)
    local v1__x, v1__y = SF__.Vector2.FromUnit(a)
    local v2__x, v2__y = SF__.Vector2.FromUnit(b)
    return SF__.Vector2.get_Magnitude(SF__.Vector2.op_Subtraction(v1__x, v1__y, v2__x, v2__y))
end

function SF__.Vector2.SqrUnitDistance(a134, b135)
    local v1__x136, v1__y137 = SF__.Vector2.FromUnit(a134)
    local v2__x138, v2__y139 = SF__.Vector2.FromUnit(b135)
    return SF__.Vector2.get_SqrMagnitude(SF__.Vector2.op_Subtraction(v1__x136, v1__y137, v2__x138, v2__y139))
end

function SF__.Vector2.FromUnit(u140)
    return GetUnitX(u140), GetUnitY(u140)
end

function SF__.Vector2.get_Magnitude(self__x141, self__y142)
    return math.sqrt(SF__.Vector2.get_SqrMagnitude(self__x141, self__y142))
end

function SF__.Vector2.get_SqrMagnitude(self__x143, self__y144)
    return ((self__x143 * self__x143) + (self__y144 * self__y144))
end

function SF__.Vector2.get_Normalized(self__x145, self__y146)
    local mag = SF__.Vector2.get_Magnitude(self__x145, self__y146)
    if (mag < 0.0001) then
        return SF__.Vector2.get_Zero()
    end
    return SF__.Vector2.op_Division(self__x145, self__y146, mag)
end

function SF__.Vector2.ClampMagnitude(self__x149, self__y150, mag151)
    return (function()
        local v__x152, v__y153 = SF__.Vector2.get_Normalized(self__x149, self__y150)
        return SF__.Vector2.op_Multiply__vector2f(v__x152, v__y153, mag151)
    end)()
end

function SF__.Vector2.ToString(self__x154, self__y155)
    return SF__.StrConcat__("(", self__x154, ", ", self__y155, ")")
end

function SF__.Vector2.Rotate(self__x156, self__y157, angle158)
    local cos = math.cos(angle158)
    local sin = math.sin(angle158)
    return ((self__x156 * cos) - (self__y157 * sin)), ((self__x156 * sin) + (self__y157 * cos))
end

function SF__.Vector2.UnitMoveTo(self__x159, self__y160, u161)
    SetUnitX(u161, self__x159)
    SetUnitY(u161, self__y160)
end

function SF__.Vector2.GetTerrainZ(self__x162, self__y163)
    MoveLocation(SF__.Vector2._loc, self__x162, self__y163)
    return GetLocationZ(SF__.Vector2._loc)
end

SF__.Vector2._loc = Location(0, 0)

SF__.Program.Main()
