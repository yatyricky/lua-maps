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

function SF__.Vector3.op_Addition(a__x165, a__y166, a__z167, b__x168, b__y169, b__z170)
    return (a__x165 + b__x168), (a__y166 + b__y169), (a__z167 + b__z170)
end

function SF__.Vector3.op_UnaryNegation(a__x171, a__y172, a__z173)
    return (-a__x171), (-a__y172), (-a__z173)
end

function SF__.Vector3.op_Subtraction(a__x174, a__y175, a__z176, b__x177, b__y178, b__z179)
    return (a__x174 - b__x177), (a__y175 - b__y178), (a__z176 - b__z179)
end

function SF__.Vector3.op_Multiply__vector3f(v__x180, v__y181, v__z182, f183)
    return (v__x180 * f183), (v__y181 * f183), (v__z182 * f183)
end

function SF__.Vector3.op_Multiply__fvector3(f184, v__x185, v__y186, v__z187)
    return (v__x185 * f184), (v__y186 * f184), (v__z187 * f184)
end

function SF__.Vector3.op_Division(v__x188, v__y189, v__z190, f191)
    return (v__x188 / f191), (v__y189 / f191), (v__z190 / f191)
end

-- <summary>
-- Warcraft III world space here is right-handed: +x points right, +y points away, +z points up.
-- That means Cross((1,0,0), (0,1,0)) == (0,0,1).
-- </summary>
--
function SF__.Vector3.Cross(a__x192, a__y193, a__z194, b__x195, b__y196, b__z197)
    return ((a__y193 * b__z197) - (a__z194 * b__y196)), ((a__z194 * b__x195) - (a__x192 * b__z197)), ((a__x192 * b__y196) - (a__y193 * b__x195))
end

function SF__.Vector3.Distance(a__x198, a__y199, a__z200, b__x201, b__y202, b__z203)
    return SF__.Vector3.get_magnitude(SF__.Vector3.op_Subtraction(a__x198, a__y199, a__z200, b__x201, b__y202, b__z203))
end

function SF__.Vector3.Dot(a__x204, a__y205, a__z206, b__x207, b__y208, b__z209)
    return (((a__x204 * b__x207) + (a__y205 * b__y208)) + (a__z206 * b__z209))
end

function SF__.Vector3.MoveTowards(current__x, current__y, current__z, target__x, target__y, target__z, maxDistanceDelta)
    local toVector__x, toVector__y, toVector__z = SF__.Vector3.op_Subtraction(target__x, target__y, target__z, current__x, current__y, current__z)
    local dist = SF__.Vector3.get_magnitude(toVector__x, toVector__y, toVector__z)
    if ((dist <= maxDistanceDelta) or (dist == 0)) then
        return target__x, target__y, target__z
    end
    return SF__.Vector3.op_Addition(current__x, current__y, current__z, SF__.Vector3.op_Division(toVector__x, toVector__y, toVector__z, (dist / maxDistanceDelta)))
end

function SF__.Vector3.Project(v__x210, v__y211, v__z212, onNormal__x, onNormal__y, onNormal__z)
    local sqrMag = SF__.Vector3.Dot(onNormal__x, onNormal__y, onNormal__z, onNormal__x, onNormal__y, onNormal__z)
    if (sqrMag < 0.0001) then
        return SF__.Vector3.get_zero()
    end
    local dot = SF__.Vector3.Dot(v__x210, v__y211, v__z212, onNormal__x, onNormal__y, onNormal__z)
    return SF__.Vector3.op_Multiply__vector3f(onNormal__x, onNormal__y, onNormal__z, (dot / sqrMag))
end

function SF__.Vector3.ProjectOnPlane(v__x213, v__y214, v__z215, planeNormal__x, planeNormal__y, planeNormal__z)
    return SF__.Vector3.op_Subtraction(v__x213, v__y214, v__z215, SF__.Vector3.Project(v__x213, v__y214, v__z215, planeNormal__x, planeNormal__y, planeNormal__z))
end

function SF__.Vector3.Reflect(inDirection__x, inDirection__y, inDirection__z, inNormal__x, inNormal__y, inNormal__z)
    return SF__.Vector3.op_Subtraction(inDirection__x, inDirection__y, inDirection__z, SF__.Vector3.op_Multiply__fvector3((2 * SF__.Vector3.Dot(inDirection__x, inDirection__y, inDirection__z, inNormal__x, inNormal__y, inNormal__z)), inNormal__x, inNormal__y, inNormal__z))
end

function SF__.Vector3.RotateTowards(current__x216, current__y217, current__z218, target__x219, target__y220, target__z221, maxRadiansDelta, maxMagnitudeDelta)
    local currentMag = SF__.Vector3.get_magnitude(current__x216, current__y217, current__z218)
    local targetMag = SF__.Vector3.get_magnitude(target__x219, target__y220, target__z221)
    if ((currentMag == 0) or (targetMag == 0)) then
        return SF__.Vector3.MoveTowards(current__x216, current__y217, current__z218, target__x219, target__y220, target__z221, maxMagnitudeDelta)
    end
    local currentNorm__x, currentNorm__y, currentNorm__z = SF__.Vector3.op_Division(current__x216, current__y217, current__z218, currentMag)
    local targetNorm__x, targetNorm__y, targetNorm__z = SF__.Vector3.op_Division(target__x219, target__y220, target__z221, targetMag)
    local dot222 = math.clamp(SF__.Vector3.Dot(currentNorm__x, currentNorm__y, currentNorm__z, targetNorm__x, targetNorm__y, targetNorm__z), (-1), 1)
    local angle223 = math.acos(dot222)
    if (angle223 == 0) then
        return SF__.Vector3.MoveTowards(current__x216, current__y217, current__z218, target__x219, target__y220, target__z221, maxMagnitudeDelta)
    end
    local t224 = math.min(1, (maxRadiansDelta / angle223))
    local newDir__x, newDir__y, newDir__z = SF__.Vector3.Slerp(currentNorm__x, currentNorm__y, currentNorm__z, targetNorm__x, targetNorm__y, targetNorm__z, t224)
    local newMag = math.moveTowards(currentMag, targetMag, maxMagnitudeDelta)
    return SF__.Vector3.op_Multiply__vector3f(newDir__x, newDir__y, newDir__z, newMag)
end

function SF__.Vector3.Scale(a__x225, a__y226, a__z227, b__x228, b__y229, b__z230)
    return (a__x225 * b__x228), (a__y226 * b__y229), (a__z227 * b__z230)
end

function SF__.Vector3.Slerp(a__x231, a__y232, a__z233, b__x234, b__y235, b__z236, t237)
    local magA = SF__.Vector3.get_magnitude(a__x231, a__y232, a__z233)
    local magB = SF__.Vector3.get_magnitude(b__x234, b__y235, b__z236)
    if ((magA == 0) or (magB == 0)) then
        return SF__.Vector3.MoveTowards(a__x231, a__y232, a__z233, b__x234, b__y235, b__z236, math.huge)
    end
    local normA__x, normA__y, normA__z = SF__.Vector3.op_Division(a__x231, a__y232, a__z233, magA)
    local normB__x, normB__y, normB__z = SF__.Vector3.op_Division(b__x234, b__y235, b__z236, magB)
    local dot238 = math.clamp(SF__.Vector3.Dot(normA__x, normA__y, normA__z, normB__x, normB__y, normB__z), (-1), 1)
    local angle239 = math.acos(dot238)
    local sinAngle = math.sin(angle239)
    if (sinAngle < 0.0001) then
        return SF__.Vector3.MoveTowards(a__x231, a__y232, a__z233, b__x234, b__y235, b__z236, math.huge)
    end
    local tAngle = (angle239 * t237)
    local sinTA = math.sin(tAngle)
    local sinTOneMinusA = math.sin((angle239 - tAngle))
    local newDir__x246, newDir__y247, newDir__z248 = (function()
        local v__x243, v__y244, v__z245 = (function()
            local a__x240, a__y241, a__z242 = SF__.Vector3.op_Multiply__vector3f(normA__x, normA__y, normA__z, sinTOneMinusA)
            return SF__.Vector3.op_Addition(a__x240, a__y241, a__z242, SF__.Vector3.op_Multiply__vector3f(normB__x, normB__y, normB__z, sinTA))
        end)()
        return SF__.Vector3.op_Division(v__x243, v__y244, v__z245, sinAngle)
    end)()
    local newMag249 = math.lerp(magA, magB, t237)
    return SF__.Vector3.op_Multiply__vector3f(newDir__x246, newDir__y247, newDir__z248, newMag249)
end

function SF__.Vector3._getTerrainZ(x250, y251)
    MoveLocation(SF__.Vector3._loc, x250, y251)
    return GetLocationZ(SF__.Vector3._loc)
end

function SF__.Vector3.FromUnit(u252)
    local x253 = GetUnitX(u252)
    local y254 = GetUnitY(u252)
    return x253, y254, (SF__.Vector3._getTerrainZ(x253, y254) + GetUnitFlyHeight(u252))
end

function SF__.Vector3.get_sqrMagnitude(self__x255, self__y256, self__z257)
    return (((self__x255 * self__x255) + (self__y256 * self__y256)) + (self__z257 * self__z257))
end

function SF__.Vector3.get_magnitude(self__x258, self__y259, self__z260)
    return math.sqrt(SF__.Vector3.get_sqrMagnitude(self__x258, self__y259, self__z260))
end

function SF__.Vector3.get_normalized(self__x261, self__y262, self__z263)
    local mag264 = SF__.Vector3.get_magnitude(self__x261, self__y262, self__z263)
    if (mag264 < 0.0001) then
        return SF__.Vector3.get_zero()
    end
    return SF__.Vector3.op_Division(self__x261, self__y262, self__z263, mag264)
end

function SF__.Vector3.ClampMagnitude(self__x268, self__y269, self__z270, mag271)
    return (function()
        local v__x272, v__y273, v__z274 = SF__.Vector3.get_normalized(self__x268, self__y269, self__z270)
        return SF__.Vector3.op_Multiply__vector3f(v__x272, v__y273, v__z274, mag271)
    end)()
end

function SF__.Vector3.ToString(self__x275, self__y276, self__z277)
    return SF__.StrConcat__("(", self__x275, ", ", self__y276, ", ", self__z277, ")")
end

function SF__.Vector3.UnitMoveTo(self__x278, self__y279, self__z280, u281, mode)
    if mode == nil then mode = SF__.UnitVec3Mode.Auto end
    local tz = SF__.Vector3._getTerrainZ(self__x278, self__y279)
    local LuaUtils = require("Lib.Utils")
    local defaultFlyHeight = GetUnitDefaultFlyHeight(u281)
    local minZ = (tz + defaultFlyHeight)
    SetUnitPosition(u281, self__x278, self__y279)
    repeat
        local switchValue = mode
        if (switchValue == SF__.UnitVec3Mode.ForceFlying) then
            LuaUtils.SetUnitFlyable(u281)
            SetUnitFlyHeight(u281, (math.max(minZ, self__z280) - minZ), 0)
            break
        elseif (switchValue == SF__.UnitVec3Mode.ForceGround) then
            SetUnitFlyHeight(u281, defaultFlyHeight, 0)
            break
        elseif (switchValue == SF__.UnitVec3Mode.Auto) then
            if IsUnitType(u281, UNIT_TYPE_FLYING) then
                SetUnitFlyHeight(u281, (math.max(minZ, self__z280) - minZ), 0)
            else
                SetUnitFlyHeight(u281, defaultFlyHeight, 0)
            end
            break
        end
    until true
end

function SF__.Vector3.GetTerrainZ(self__x282, self__y283, self__z284)
    return SF__.Vector3._getTerrainZ(self__x282, self__y283)
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
        local a__x59, a__y60, a__z61 = (function()
            local a__x56, a__y57, a__z58 = SF__.Vector3.op_Multiply__fvector3((2 * SF__.Vector3.Dot(u__x, u__y, u__z, v__x, v__y, v__z)), u__x, u__y, u__z)
            return SF__.Vector3.op_Addition(a__x56, a__y57, a__z58, SF__.Vector3.op_Multiply__fvector3(((s * s) - SF__.Vector3.Dot(u__x, u__y, u__z, u__x, u__y, u__z)), v__x, v__y, v__z))
        end)()
        return SF__.Vector3.op_Addition(a__x59, a__y60, a__z61, SF__.Vector3.op_Multiply__fvector3((2 * s), SF__.Vector3.Cross(u__x, u__y, u__z, v__x, v__y, v__z)))
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
    local x62
    local y63
    local z
    local w
    local trace = ((m00 + m11) + m22)
    if (trace > 0) then
        local s64 = (math.sqrt((trace + 1)) * 2)
        w = (0.25 * s64)
        x62 = ((m21 - m12) / s64)
        y63 = ((m02 - m20) / s64)
        z = ((m10 - m01) / s64)
    elseif ((m00 > m11) and (m00 > m22)) then
        local s65 = (math.sqrt((((1 + m00) - m11) - m22)) * 2)
        w = ((m21 - m12) / s65)
        x62 = (0.25 * s65)
        y63 = ((m01 + m10) / s65)
        z = ((m02 + m20) / s65)
    else
        if (m11 > m22) then
            local s66 = (math.sqrt((((1 + m11) - m00) - m22)) * 2)
            w = ((m02 - m20) / s66)
            x62 = ((m01 + m10) / s66)
            y63 = (0.25 * s66)
            z = ((m12 + m21) / s66)
        else
            local s67 = (math.sqrt((((1 + m22) - m00) - m11)) * 2)
            w = ((m10 - m01) / s67)
            x62 = ((m02 + m20) / s67)
            y63 = ((m12 + m21) / s67)
            z = (0.25 * s67)
        end
    end
    return SF__.Quaternion.Normalize(x62, y63, z, w)
end

function SF__.Quaternion.LookRotation__vector3(forward__x68, forward__y69, forward__z70)
    return SF__.Quaternion.LookRotation__vector3vector3(forward__x68, forward__y69, forward__z70, SF__.Vector3.get_up())
end

function SF__.Quaternion.Normalize(q__x71, q__y72, q__z73, q__w74)
    local magnitude = math.sqrt(((((q__x71 * q__x71) + (q__y72 * q__y72)) + (q__z73 * q__z73)) + (q__w74 * q__w74)))
    if (magnitude < 0.0001) then
        return SF__.Quaternion.get_identity()
    end
    return (q__x71 / magnitude), (q__y72 / magnitude), (q__z73 / magnitude), (q__w74 / magnitude)
end

function SF__.Quaternion.get_eulerAngles(self__x, self__y, self__z, self__w)
    -- https://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles#Source_Code_2
    local sinr_cosp = (2 * ((self__w * self__x) + (self__y * self__z)))
    local cosr_cosp = (1 - (2 * ((self__x * self__x) + (self__y * self__y))))
    local roll75 = math.atan(sinr_cosp, cosr_cosp)
    local sinp = (2 * ((self__w * self__y) - (self__z * self__x)))
    local pitch76
    if (math.abs(sinp) >= 1) then
        pitch76 = ((math.sign(sinp) * math.pi) / 2)
        -- use 90 degrees if out of range
    else
        pitch76 = math.asin(sinp)
    end
    local siny_cosp = (2 * ((self__w * self__z) + (self__x * self__y)))
    local cosy_cosp = (1 - (2 * ((self__y * self__y) + (self__z * self__z))))
    local yaw77 = math.atan(siny_cosp, cosy_cosp)
    return (pitch76 * bj_RADTODEG), (yaw77 * bj_RADTODEG), (roll75 * bj_RADTODEG)
end

function SF__.Quaternion.get_normalized(self__x78, self__y79, self__z80, self__w81)
    return SF__.Quaternion.Normalize(self__x78, self__y79, self__z80, self__w81)
end

function SF__.Quaternion.ToString(self__x86, self__y87, self__z88, self__w89)
    return SF__.StrConcat__("(", self__x86, ", ", self__y87, ", ", self__z88, ", ", self__w89, ")")
end

function SF__.Quaternion.ApplyToEffect(self__x90, self__y91, self__z92, self__w93, e)
    local angles__x, angles__y, angles__z = SF__.Quaternion.get_eulerAngles(self__x90, self__y91, self__z92, self__w93)
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

function SF__.StdLib.List:Add(item435)
    table.insert(self._items, item435)
    self.Count = (self.Count + 1)
    self._version = (self._version + 1)
end

function SF__.StdLib.List:Clear()
    self._items = {}
    self.Count = 0
    self._version = (self._version + 1)
end

function SF__.StdLib.List:Remove(item436)
    local index437 = self:IndexOf(item436)
    if (index437 < 0) then
        return false
    end
    self:RemoveAt(index437)
    return true
end

function SF__.StdLib.List:RemoveAt(index438)
    table.remove(self._items, (index438 + 1))
    self.Count = (self.Count - 1)
    self._version = (self._version + 1)
end

function SF__.StdLib.List:IndexOf(item439)
    do
        local i440 = 0
        while (i440 < self.Count) do
            local current = self._items[(i440 + 1)]
            if (current == item439) then
                return i440
            end
            ::continue::
            i440 = (i440 + 1)
        end
    end
    return (-1)
end

function SF__.StdLib.List.DefaultCompare(a441, b442)
    if (a441 == b442) then
        return 0
    end
    if (a441 < b442) then
        return (-1)
    end
    return 1
end

function SF__.StdLib.List:Sort(comparison)
    if (comparison == nil) then
        comparison = SF__.StdLib.List.DefaultCompare
    end
    local version = self._version
    table.sort(self._items, function(a445, b446)
        return (comparison(a445, b446) < 0)
    end)
    if (version ~= self._version) then
        error(SF__.StrConcat__("SF__E2e5944b8", "Collection was modified"))
    end
    self._version = (self._version + 1)
end

function SF__.StdLib.List:IpairsNext()
    local version447 = self._version
    local index448 = 0
    return function()
        if (version447 ~= self._version) then
            error(SF__.StrConcat__("SF__E2e5944b8", "Collection was modified"))
        end
        index448 = (index448 + 1)
        local value449 = self._items[index448]
        if (value449 == nil) then
            return nil
        end
        return index448, value449
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

function SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p95, abilCode96, researchExtendedTooltip, level97)
    if (GetLocalPlayer() ~= p95) then
        return
    end
    BlzSetAbilityResearchExtendedTooltip(abilCode96, researchExtendedTooltip, level97)
end

function SF__.Utils.ExBlzSetAbilityTooltip(p98, abilCode99, tooltip, level100)
    if (GetLocalPlayer() ~= p98) then
        return
    end
    BlzSetAbilityTooltip(abilCode99, tooltip, level100)
end

function SF__.Utils.ExBlzSetAbilityExtendedTooltip(p101, abilCode102, extendedTooltip, level103)
    if (GetLocalPlayer() ~= p101) then
        return
    end
    BlzSetAbilityExtendedTooltip(abilCode102, extendedTooltip, level103)
end

function SF__.Utils.ExBlzSetAbilityIcon(p104, abilCode105, iconPath)
    if (GetLocalPlayer() ~= p104) then
        return
    end
    BlzSetAbilityIcon(abilCode105, iconPath)
end

function SF__.Utils.CsGroupGetUnitsInRange(x106, y107, radius, filter)
    local result = SF__.StdLib.List.New__0()
    ExGroupEnumUnitsInRange(x106, y107, radius, function(u108)
        if filter(u108) then
            result:Add(u108)
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
                local collection2 = self._units
                for _, u361 in (SF__.StdLib.List.IpairsNext)(collection2) do
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
function SF__.BladeOfJustice.GetAbilityData(level285)
    return (75 * level285), 5, (10 * level285)
end

function SF__.BladeOfJustice.Init()
    local EventCenter = require("Lib.EventCenter")
    EventCenter.RegisterPlayerUnitSpellEffect:Emit({id = SF__.BladeOfJustice.ID, handler = SF__.BladeOfJustice.Start})
    ExTriggerRegisterNewUnit(function(u287)
        if (GetUnitTypeId(u287) == FourCC("Hpal")) then
            SF__.BladeOfJustice.UpdateAbilityMeta(u287)
        end
    end)
end

function SF__.BladeOfJustice.UpdateAbilityMeta(u288)
    local p289 = GetOwningPlayer(u288)
    local datas = SF__.StdLib.List.New__0()
    do
        local i290 = 0
        while (i290 < 3) do
            local __pack_Damage, __pack_Duration, __pack_DamagePerSecond = SF__.BladeOfJustice.GetAbilityData((i290 + 1))
            datas:Add({Damage = __pack_Damage, Duration = __pack_Duration, DamagePerSecond = __pack_DamagePerSecond})
            ::continue::
            i290 = (i290 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p289, SF__.BladeOfJustice.ID, "学习公正之剑 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p289, SF__.BladeOfJustice.ID, SF__.StrConcat__("用圣光的利刃刺穿目标，造成法术伤害，在一定时间内对附近敌人每秒造成光辉伤害。产生|cffff8c001|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 10秒\r\n\r\n|cffffcc001级|r - 造成|cffff8c00", datas:get_Item(0).Damage, "|r的直接法术伤害，|cffff8c00", datas:get_Item(0).Duration, "|r秒内对附近敌人每秒造成|cffff8c00", datas:get_Item(0).DamagePerSecond, "|r的光辉伤害。产生|cffff8c001|r点圣能。\r\n|cffffcc002级|r - 造成|cffff8c00", datas:get_Item(1).Damage, "|r的直接法术伤害，|cffff8c00", datas:get_Item(1).Duration, "|r秒内对附近敌人每秒造成|cffff8c00", datas:get_Item(1).DamagePerSecond, "|r的光辉伤害。产生|cffff8c001|r点圣能。\r\n|cffffcc003级|r - 造成|cffff8c00", datas:get_Item(2).Damage, "|r的直接法术伤害，|cffff8c00", datas:get_Item(2).Duration, "|r秒内对附近敌人每秒造成|cffff8c00", datas:get_Item(2).DamagePerSecond, "|r的光辉伤害。产生|cffff8c001|r点圣能。"), 0)
    do
        local i291 = 0
        while (i291 < 3) do
            local __unpack_tmp = datas:get_Item(i291)
            local data__Damage, data__Duration, data__DamagePerSecond = __unpack_tmp.Damage, __unpack_tmp.Duration, __unpack_tmp.DamagePerSecond
            SF__.Utils.ExBlzSetAbilityTooltip(p289, SF__.BladeOfJustice.ID, SF__.StrConcat__("公正之剑 - [|cffffcc00", (i291 + 1), "级|r]"), i291)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p289, SF__.BladeOfJustice.ID, SF__.StrConcat__("用圣光的利刃刺穿目标，造成|cffff8c00", data__Damage, "|r的直接法术伤害，在|cffff8c00", data__Duration, "|r秒内对附近敌人每秒造成|cffff8c00", data__DamagePerSecond, "|r的光辉伤害。产生|cffff8c001|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 10秒"), i291)
            ::continue::
            i291 = (i291 + 1)
        end
    end
end

function SF__.BladeOfJustice.Start(data)
    local level292 = GetUnitAbilityLevel(data.caster, SF__.BladeOfJustice.ID)
    local EventCenter293 = require("Lib.EventCenter")
    local ad__Damage, ad__Duration, ad__DamagePerSecond = SF__.BladeOfJustice.GetAbilityData(level292)
    EventCenter293.Damage:Emit({whichUnit = data.caster, target = data.target, amount = ad__Damage, attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
    SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(data.caster, 1)
    SF__.BladeOfJustice.New():StartGroudDamage(data.caster, data.target, ad__Damage, ad__Duration, ad__DamagePerSecond)
end

function SF__.BladeOfJustice:StartGroudDamage(caster, target, ad__Damage294, ad__Duration295, ad__DamagePerSecond296)
    return SF__.CorRun__(function()
        local pos__x, pos__y = SF__.Vector2.FromUnit(target)
        local UnitAttribute = require("Objects.UnitAttribute")
        local EventCenter300 = require("Lib.EventCenter")
        local eff = ExAddSpecialEffect("Abilities/Spells/Orc/LiquidFire/Liquidfire.mdl", pos__x, pos__y, ad__Duration295)
        local p297 = GetOwningPlayer(caster)
        do
            local i298 = 0
            while (i298 < ad__Duration295) do
                SF__.CorWait__(1000)
                ExGroupEnumUnitsInRange(pos__x, pos__y, 300, function(u301)
                    if (not IsUnitEnemy(u301, p297)) then
                        return
                    end
                    if ExIsUnitDead(u301) then
                        return
                    end
                    local tarAttr302 = UnitAttribute.GetAttr(u301)
                    local damage303 = (ad__DamagePerSecond296 * (1 - tarAttr302.radiantResistance))
                    EventCenter300.Damage:Emit({whichUnit = caster, target = u301, amount = damage303, attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
                end)
                ::continue::
                i298 = (i298 + 1)
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
function SF__.CrusaderStrike.GetAbilityData(level304)
    return (0.65 + (0.35 * level304)), (0.15 * (level304 - 1))
end

function SF__.CrusaderStrike.Init()
    local EventCenter305 = require("Lib.EventCenter")
    EventCenter305.RegisterPlayerUnitSpellEffect:Emit({id = SF__.CrusaderStrike.ID, handler = SF__.CrusaderStrike.Start})
    ExTriggerRegisterNewUnit(function(u307)
        if (GetUnitTypeId(u307) == FourCC("Hpal")) then
            SF__.CrusaderStrike.UpdateAbilityMeta(u307)
        end
    end)
end

function SF__.CrusaderStrike.UpdateAbilityMeta(u308)
    local p309 = GetOwningPlayer(u308)
    local datas310 = SF__.StdLib.List.New__0()
    do
        local i311 = 0
        while (i311 < 3) do
            local __pack_DamageScaling, __pack_ArtOfWarChance = SF__.CrusaderStrike.GetAbilityData((i311 + 1))
            datas310:Add({DamageScaling = __pack_DamageScaling, ArtOfWarChance = __pack_ArtOfWarChance})
            ::continue::
            i311 = (i311 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p309, SF__.CrusaderStrike.ID, "学习十字军打击 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p309, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击造成一次攻击伤害，伤害系数随技能等级提升。产生|cffff8c001|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 6秒\r\n\r\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas310:get_Item(0).DamageScaling * 100)), "%|r的攻击伤害。\r\n|cffffcc002级|r - |cffff8c00", string.format("%.0f", (datas310:get_Item(1).DamageScaling * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas310:get_Item(1).ArtOfWarChance * 100)), "%的战争艺术触发几率。\r\n|cffffcc003级|r - |cffff8c00", string.format("%.0f", (datas310:get_Item(2).DamageScaling * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas310:get_Item(2).ArtOfWarChance * 100)), "%的战争艺术触发几率。"), 0)
    do
        local i312 = 0
        while (i312 < 3) do
            local __unpack_tmp313 = datas310:get_Item(i312)
            local data__DamageScaling, data__ArtOfWarChance = __unpack_tmp313.DamageScaling, __unpack_tmp313.ArtOfWarChance
            SF__.Utils.ExBlzSetAbilityTooltip(p309, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击 - [|cffffcc00", (i312 + 1), "级|r]"), i312)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p309, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击造成一次攻击伤害，造成|cffff8c00", string.format("%.0f", (data__DamageScaling * 100)), "%|r的攻击伤害", (function() if (i312 > 0) then return SF__.StrConcat__("，", string.format("%.0f", (data__ArtOfWarChance * 100)), "%的战争艺术触发几率") else return "" end end)(), "。产生|cffff8c001|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 6秒"), i312)
            ::continue::
            i312 = (i312 + 1)
        end
    end
    -- datas.Remove(new IAbilityData { DamageScaling = 0.65f, ArtOfWarChance = 0 });
    datas310:RemoveAt(0)
end

function SF__.CrusaderStrike.Start(data314)
    local level315 = GetUnitAbilityLevel(data314.caster, SF__.CrusaderStrike.ID)
    local UnitAttribute316 = require("Objects.UnitAttribute")
    local EventCenter318 = require("Lib.EventCenter")
    local ad__DamageScaling, ad__ArtOfWarChance = SF__.CrusaderStrike.GetAbilityData(level315)
    local attr = UnitAttribute316.GetAttr(data314.caster)
    local damage317 = (attr:SimAttack(UnitAttribute316.HeroAttributeType.Strength) * ad__DamageScaling)
    EventCenter318.Damage:Emit({whichUnit = data314.caster, target = data314.target, amount = damage317, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
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

function SF__.Scene:AddGameObject(obj26)
    self.gameObjs:Add(obj26)
end

function SF__.Scene:QueueDestroy(obj27)
    self._destroyQueue:Add(obj27)
end

function SF__.Scene:FlushDestroyQueue()
    do
        local i28 = 0
        while (i28 < self._destroyQueue.Count) do
            SF__.GameObject.DestroyQueued(self._destroyQueue:get_Item(i28))
            ::continue::
            i28 = (i28 + 1)
        end
    end
    self._destroyQueue:Clear()
end

function SF__.Scene:Run()
    return SF__.CorRun__(function()
        while true do
            SF__.CorWait__(SF__.Scene.DT)
            local rootObjs = SF__.StdLib.List.New__0()
            do
                local collection3 = self.gameObjs
                for _, obj29 in (SF__.StdLib.List.IpairsNext)(collection3) do
                    if (obj29.transform.parent == nil) then
                        rootObjs:Add(obj29)
                    end
                end
            end
            do
                local collection4 = rootObjs
                for _, obj30 in (SF__.StdLib.List.IpairsNext)(collection4) do
                    obj30:Update()
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
        local collection5 = obj.transform.children
        for _, child in (SF__.StdLib.List.IpairsNext)(collection5) do
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
        local collection6 = obj13._components
        for _, comp in (SF__.StdLib.List.IpairsNext)(collection6) do
            comp:OnDisable()
            comp:OnDestroy()
        end
    end
    obj13._components:Clear()
    SF__.Scene.get_Instance().gameObjs:Remove(obj13)
    obj13.isDestroyed = true
end

function SF__.GameObject.UpdateBFS(obj14)
    if (obj14.isDestroyQueued or obj14.isDestroyed) then
        return
    end
    do
        local collection7 = obj14._components
        for _, comp15 in (SF__.StdLib.List.IpairsNext)(collection7) do
            comp15:Update()
        end
    end
    do
        local collection8 = obj14.transform.children
        for _, child16 in (SF__.StdLib.List.IpairsNext)(collection8) do
            SF__.GameObject.UpdateBFS(child16.gameObject)
        end
    end
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

function SF__.GameObject.__Init__sgameobject(self, name17, parent18)
    SF__.GameObject.__Init__s(self, name17)
    self.transform:SetParent(parent18.transform)
end

function SF__.GameObject.New__sgameobject(name17, parent18)
    local self = setmetatable({}, { __index = SF__.GameObject })
    SF__.GameObject.__Init__sgameobject(self, name17, parent18)
    return self
end

function SF__.GameObject:GetComponent(T)
    do
        local collection9 = self._components
        for _, comp19 in (SF__.StdLib.List.IpairsNext)(collection9) do
            do
                local tComp = comp19
                if SF__.TypeIs__(tComp, T) then
                    return tComp
                end
            end
        end
    end
    return nil
end

function SF__.GameObject:AddComponent(T20)
    local comp21 = (function()
        local obj22 = T20.New()
        obj22.gameObject = self
        return obj22
    end)()
    self._components:Add(comp21)
    comp21:Awake()
    comp21:OnEnable()
    comp21:Start()
    return comp21
end

function SF__.GameObject:RemoveAllComponents(T23)
    do
        local i24 = (self._components.Count - 1)
        while (i24 >= 0) do
            if SF__.TypeIs__(self._components:get_Item(i24), T23) then
                self._components:get_Item(i24):OnDisable()
                self._components:get_Item(i24):OnDestroy()
                self._components:RemoveAt(i24)
            end
            ::continue::
            i24 = (i24 - 1)
        end
    end
end

function SF__.GameObject:Update()
    SF__.GameObject.UpdateBFS(self)
end

function SF__.GameObject:Destroy()
    if (self.isDestroyQueued or self.isDestroyed) then
        return
    end
    SF__.GameObject.MarkDestroyQueuedDepthFirst(self)
    SF__.Scene.get_Instance():QueueDestroy(self)
end

function SF__.GameObject.DestroyQueued(obj25)
    SF__.GameObject.DestroyDepthFirst(obj25)
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
    return SF__.StrConcat__("targetType: ", self.targetType, "\r\nunitTarget: ", (function() if (self.unitTarget == nil) then return "None" else return GetUnitName(self.unitTarget) end end)(), "\r\npointTarget: ", SF__.Vector3.ToString(self.pointTarget__x, self.pointTarget__y, self.pointTarget__z), "\r\nspeed: ", self.speed, "\r\nlookAtTarget: ", self.lookAtTarget, "\r\ncolliderSize: ", self.colliderSize, "\r\nonArrived: ", (function() if (self.onArrived == nil) then return "None" else return "Set" end end)(), "\r\nhasArrived: ", self.hasArrived, "\r\n")
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
function SF__.DivineToll.GetAbilityData(level319)
    return (2 + level319), (50 * level319), 0.1, 10
end

function SF__.DivineToll.Init()
    local EventCenter322 = require("Lib.EventCenter")
    EventCenter322.RegisterPlayerUnitSpellEffect:Emit({id = SF__.DivineToll.ID, handler = function(data321)
        SF__.DivineToll.Start(data321)
    end})
    ExTriggerRegisterNewUnit(function(u324)
        if (GetUnitTypeId(u324) == FourCC("Hpal")) then
            SF__.DivineToll.UpdateAbilityMeta(u324)
        end
    end)
end

function SF__.DivineToll.UpdateAbilityMeta(u325)
    local p326 = GetOwningPlayer(u325)
    local datas327 = SF__.StdLib.List.New__0()
    do
        local i328 = 0
        while (i328 < 3) do
            local __pack_TargetCount, __pack_Damage329, __pack_RadiantDmgAmp, __pack_Duration330 = SF__.DivineToll.GetAbilityData((i328 + 1))
            datas327:Add({TargetCount = __pack_TargetCount, Damage = __pack_Damage329, RadiantDmgAmp = __pack_RadiantDmgAmp, Duration = __pack_Duration330})
            ::continue::
            i328 = (i328 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p326, SF__.DivineToll.ID, "学习圣洁鸣钟 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p326, SF__.DivineToll.ID, SF__.StrConcat__("对附近的多个目标施展审判，造成法术伤害，然后神圣之锤环绕圣殿骑士，每次命中敌人使其受到的光辉伤害提高。每个审判产生|cffff8c001|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 30秒\r\n\r\n|cffffcc001级|r - 审判最多|cffff8c00", datas327:get_Item(0).TargetCount, "|r个目标，造成|cffff8c00", datas327:get_Item(0).Damage, "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas327:get_Item(0).RadiantDmgAmp * 100)), "%|r的光辉易伤，持续|cffff8c00", datas327:get_Item(0).Duration, "|r秒。\r\n|cffffcc002级|r - 审判最多|cffff8c00", datas327:get_Item(1).TargetCount, "|r个目标，造成|cffff8c00", datas327:get_Item(1).Damage, "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas327:get_Item(1).RadiantDmgAmp * 100)), "%|r的光辉易伤，持续|cffff8c00", datas327:get_Item(1).Duration, "|r秒。\r\n|cffffcc003级|r - 审判最多|cffff8c00", datas327:get_Item(2).TargetCount, "|r个目标，造成|cffff8c00", datas327:get_Item(2).Damage, "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas327:get_Item(2).RadiantDmgAmp * 100)), "%|r的光辉易伤，持续|cffff8c00", datas327:get_Item(2).Duration, "|r秒。"), 0)
    do
        local i331 = 0
        while (i331 < 3) do
            local __unpack_tmp334 = datas327:get_Item(i331)
            local data__TargetCount, data__Damage332, data__RadiantDmgAmp, data__Duration333 = __unpack_tmp334.TargetCount, __unpack_tmp334.Damage, __unpack_tmp334.RadiantDmgAmp, __unpack_tmp334.Duration
            SF__.Utils.ExBlzSetAbilityTooltip(p326, SF__.DivineToll.ID, SF__.StrConcat__("圣洁鸣钟 - [|cffffcc00", (i331 + 1), "级|r]"), i331)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p326, SF__.DivineToll.ID, SF__.StrConcat__("对附近的最多|cffff8c00", data__TargetCount, "|r个目标施展审判，造成|cffff8c00", data__Damage332, "|r点法术伤害，然后神圣之锤环绕圣殿骑士，每次命中敌人使其受到的光辉伤害提高|cffff8c00", string.format("%.0f", (data__RadiantDmgAmp * 100)), "%|r，持续|cffff8c00", data__Duration333, "|r秒。每个审判产生|cffff8c001|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 30秒"), i331)
            ::continue::
            i331 = (i331 + 1)
        end
    end
end

function SF__.DivineToll.HurlToTarget(caster335, target336, pos__x337, pos__y338, pos__z)
    local outer = SF__.GameObject.New__s("DivineToll_Outer")
    local EventCenter342 = require("Lib.EventCenter")
    outer.transform.localPosition__x, outer.transform.localPosition__y, outer.transform.localPosition__z = 0, 0, 80
    local moveLayer = SF__.GameObject.New__sgameobject("MoveLayer", outer)
    moveLayer.transform.localPosition__x, moveLayer.transform.localPosition__y, moveLayer.transform.localPosition__z = pos__x337, pos__y338, pos__z
    local mis = moveLayer:AddComponent(SF__.Missile)
    mis.targetType = SF__.TargetType.Unit
    mis.unitTarget = target336
    mis.speed = 900
    mis.lookAtTarget = true
    mis.colliderSize = 32
    mis.onArrived = function()
        local cPos__x, cPos__y, cPos__z = mis.gameObject.transform:get_position()
        local eff339 = ExAddSpecialEffect("Abilities/Spells/Human/StormBolt/StormBoltCaster.mdl", cPos__x, cPos__y, 0.1)
        BlzSetSpecialEffectTimeScale(eff339, 0.5)
        BlzSetSpecialEffectColor(eff339, 255, 255, 0)
        local ad__TargetCount, ad__Damage340, ad__RadiantDmgAmp, ad__Duration341 = SF__.DivineToll.GetAbilityData(GetUnitAbilityLevel(caster335, SF__.DivineToll.ID))
        EventCenter342.Damage:Emit({whichUnit = caster335, target = target336, amount = ad__Damage340, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
        SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(caster335, 1)
        outer:Destroy()
        -- moveLayer.RemoveAllComponents<Missile>();
    end
    local orientationFixLayer = SF__.GameObject.New__sgameobject("DivineToll_Bolt", moveLayer)
    orientationFixLayer.transform.localRotation__x, orientationFixLayer.transform.localRotation__y, orientationFixLayer.transform.localRotation__z, orientationFixLayer.transform.localRotation__w = SF__.Quaternion.Euler(0, 90, 0)
    local selfRotLayer = SF__.GameObject.New__sgameobject("dt_hand", orientationFixLayer)
    local receiver = selfRotLayer:AddComponent(SF__.AutoTRSComponent)
    receiver.rotation__x, receiver.rotation__y, receiver.rotation__z, receiver.rotation__w = SF__.Quaternion.Euler(((1800 * SF__.Scene.DT) / 1000), 0, 0)
    local boltMis = SF__.GameObject.New__sgameobject("dt_mis", selfRotLayer)
    boltMis.transform.localPosition__x, boltMis.transform.localPosition__y, boltMis.transform.localPosition__z = 15, 0, 0
    boltMis.transform.localScale__x, boltMis.transform.localScale__y, boltMis.transform.localScale__z = 0.5, 0.5, 0.5
    local eff343 = AddSpecialEffect("Abilities/Spells/Human/StormBolt/StormBoltMissile.mdl", pos__x337, pos__y338)
    boltMis:AddComponent(SF__.AttachEffectComponent).eff = eff343
    local attachedHoly = SF__.GameObject.New__sgameobject("DivineToll_Holy", boltMis)
    attachedHoly.transform.localPosition__x, attachedHoly.transform.localPosition__y, attachedHoly.transform.localPosition__z = 15, 0, 0
    local effHoly = AddSpecialEffect("Abilities/Weapons/FaerieDragonMissile/FaerieDragonMissile.mdl", pos__x337, pos__y338)
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

function SF__.Easing.OutQubic(t55)
    return (1 - ((1 - t55) ^ 3))
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
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p381, SF__.TemplarStrikes.ID, SF__.StrConcat__("快速攻击目标|cffff8c00", datas382:get_Item(0).AttackCount, "|r次，第一次造成普通攻击伤害，第二次造成光辉伤害，有一定几率重置公正之剑的冷却时间，普通攻击也会触发。\r\n\r\n|cff99ccff冷却时间|r - 10秒\r\n\r\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas382:get_Item(0).DamageScaling * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas382:get_Item(0).ResetBOJChance * 100)), "%|r的几率重置公正之剑。\r\n|cffffcc002级|r - |cffff8c00", string.format("%.0f", (datas382:get_Item(1).DamageScaling * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas382:get_Item(1).ResetBOJChance * 100)), "%|r的几率重置公正之剑。\r\n|cffffcc003级|r - |cffff8c00", string.format("%.0f", (datas382:get_Item(2).DamageScaling * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas382:get_Item(2).ResetBOJChance * 100)), "%|r的几率重置公正之剑。"), 0)
    do
        local i385 = 0
        while (i385 < SF__.TemplarStrikes.MaxLevel) do
            local __unpack_tmp387 = datas382:get_Item(i385)
            local data__AttackCount, data__DamageScaling386, data__ResetBOJChance = __unpack_tmp387.AttackCount, __unpack_tmp387.DamageScaling, __unpack_tmp387.ResetBOJChance
            SF__.Utils.ExBlzSetAbilityTooltip(p381, SF__.TemplarStrikes.ID, SF__.StrConcat__("圣殿骑士之击 - [|cffffcc00", (i385 + 1), "级|r]"), i385)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p381, SF__.TemplarStrikes.ID, SF__.StrConcat__("快速攻击目标|cffff8c00", data__AttackCount, "|r次，第一次造成普通攻击伤害，第二次造成普通攻击|cffff8c00", string.format("%.0f", (data__DamageScaling386 * 100)), "%|r的光辉伤害，|cffff8c00", string.format("%.0f", (data__ResetBOJChance * 100)), "%|r几率重置公正之剑的冷却时间，普通攻击也会触发。\r\n\r\n|cff99ccff冷却时间|r - 10秒"), i385)
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
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p426, SF__.WordOfGlory.ID, "圣殿骑士的裁决造成一次攻击伤害，如果目标被审判，造成30%的额外伤害，15%几率重置审判。消耗|cffff8c003|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 5秒\r\n\r\n|cffffcc001级|r - |cffff8c00100%|r的攻击伤害，100%的战争艺术触发几率。", 0)
    do
        local i427 = 0
        while (i427 < 1) do
            SF__.Utils.ExBlzSetAbilityTooltip(p426, SF__.WordOfGlory.ID, SF__.StrConcat__("圣殿骑士的裁决 - [|cffffcc00", (i427 + 1), "级|r]"), i427)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p426, SF__.WordOfGlory.ID, "圣殿骑士的裁决造成一次攻击伤害，造成|cffff8c00100%|r的攻击伤害。消耗|cffff8c003|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 5秒", i427)
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
local SystemBase31 = require("System.SystemBase")
SF__.Systems.InspectorSystem = SF__.Systems.InspectorSystem or class("InspectorSystem", SystemBase31)
SF__.Systems.InspectorSystem.Name = "InspectorSystem"
SF__.Systems.InspectorSystem.FullName = "Systems.InspectorSystem"
SF__.Systems.InspectorSystem.__sf_base = SystemBase31
function SF__.Systems.InspectorSystem:Awake()
    self:CreateFrames()
    self:RefreshHierarchy()
    self:SelectFirstVisibleObject()
    self:SetPanelVisible(false)
end

function SF__.Systems.InspectorSystem:Update(dt32)
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
        local i33 = 0
        while (i33 < SF__.Systems.InspectorSystem.MaxHierarchyRows) do
            self._hierarchyRows:Add(self:CreateHierarchyRow(i33))
            ::continue::
            i33 = (i33 + 1)
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
    local y34 = ((-0.061) - (index * (SF__.Systems.InspectorSystem.RowHeight + SF__.Systems.InspectorSystem.RowGap)))
    local button = BlzCreateFrameByType("BUTTON", "FdfInspectorHierarchyRow", self._panel, "ScoreScreenTabButtonTemplate", index)
    BlzFrameSetPoint(button, FRAMEPOINT_TOPLEFT, self._panel, FRAMEPOINT_TOPLEFT, (SF__.Systems.InspectorSystem.Padding * 2), y34)
    BlzFrameSetSize(button, (SF__.Systems.InspectorSystem.LeftWidth - (SF__.Systems.InspectorSystem.Padding * 4)), SF__.Systems.InspectorSystem.RowHeight)
    local label35 = BlzCreateFrameByType("TEXT", "FdfInspectorHierarchyRowText", button, "", index)
    BlzFrameSetPoint(label35, FRAMEPOINT_TOPLEFT, button, FRAMEPOINT_TOPLEFT, 0.004, (-0.002))
    BlzFrameSetSize(label35, (SF__.Systems.InspectorSystem.LeftWidth - (SF__.Systems.InspectorSystem.Padding * 5)), (SF__.Systems.InspectorSystem.RowHeight - 0.003))
    BlzFrameSetEnable(label35, false)
    BlzFrameSetTextAlignment(label35, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_LEFT)
    BlzFrameSetText(label35, "")
    local row = SF__.Systems.InspectorSystem.HierarchyRow.New(button, label35)
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

function SF__.Systems.InspectorSystem:SelectRow(row36)
    if (row36.gameObject == nil) then
        return
    end
    self._selectedGameObject = row36.gameObject
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
        local collection10 = SF__.Scene.get_Instance().gameObjs
        for _, obj37 in (SF__.StdLib.List.IpairsNext)(collection10) do
            if (obj37.transform.parent == nil) then
                self:AddHierarchyObject(obj37, 0)
            end
        end
    end
    do
        local i38 = 0
        while (i38 < self._hierarchyRows.Count) do
            local row39 = self._hierarchyRows:get_Item(i38)
            if (i38 < self._visibleObjects.Count) then
                local obj40 = self._visibleObjects:get_Item(i38)
                row39.gameObject = obj40
                row39.depth = self:GetDepth(obj40)
                self:SetRowLabel(row39, obj40.name, row39.depth)
                BlzFrameSetVisible(row39.button, self._isVisible)
            else
                row39.gameObject = nil
                BlzFrameSetVisible(row39.button, false)
            end
            ::continue::
            i38 = (i38 + 1)
        end
    end
    BlzFrameSetVisible(self._emptyText, (self._isVisible and (self._visibleObjects.Count == 0)))
    self._lastObjectCount = SF__.Scene.get_Instance().gameObjs.Count
    self:RefreshHierarchySelection()
end

function SF__.Systems.InspectorSystem:AddHierarchyObject(obj41, depth)
    if (self._visibleObjects.Count >= SF__.Systems.InspectorSystem.MaxHierarchyRows) then
        return
    end
    self._visibleObjects:Add(obj41)
    do
        local collection11 = obj41.transform.children
        for _, child42 in (SF__.StdLib.List.IpairsNext)(collection11) do
            self:AddHierarchyObject(child42.gameObject, (depth + 1))
        end
    end
end

function SF__.Systems.InspectorSystem:GetDepth(obj43)
    local depth44 = 0
    local parent45 = obj43.transform.parent
    while (parent45 ~= nil) do
        depth44 = (depth44 + 1)
        parent45 = parent45.parent
        ::continue::
    end
    return depth44
end

function SF__.Systems.InspectorSystem:SetRowLabel(row46, text47, depth48)
    BlzFrameClearAllPoints(row46.label)
    BlzFrameSetPoint(row46.label, FRAMEPOINT_TOPLEFT, row46.button, FRAMEPOINT_TOPLEFT, (0.004 + (depth48 * SF__.Systems.InspectorSystem.IndentWidth)), (-0.002))
    BlzFrameSetSize(row46.label, ((SF__.Systems.InspectorSystem.LeftWidth - (SF__.Systems.InspectorSystem.Padding * 5)) - (depth48 * SF__.Systems.InspectorSystem.IndentWidth)), (SF__.Systems.InspectorSystem.RowHeight - 0.003))
    BlzFrameSetText(row46.label, text47)
end

function SF__.Systems.InspectorSystem:RefreshHierarchySelection()
    do
        local collection12 = self._hierarchyRows
        for _, row49 in (SF__.StdLib.List.IpairsNext)(collection12) do
            local isSelected = ((row49.gameObject ~= nil) and (row49.gameObject == self._selectedGameObject))
            BlzFrameSetTextColor(row49.label, (function() if isSelected then return BlzConvertColor(255, 255, 220, 80) else return BlzConvertColor(255, 230, 230, 230) end end)())
        end
    end
end

function SF__.Systems.InspectorSystem:RefreshInspectorText()
    if (self._selectedGameObject == nil) then
        BlzFrameSetText(self._inspectorText, "")
        return
    end
    local text50 = SF__.StrConcat__(self._selectedGameObject.name, "\n")
    do
        local collection13 = self._selectedGameObject:get_components()
        for _, component in (SF__.StdLib.List.IpairsNext)(collection13) do
            text50 = SF__.StrConcat__(text50, "\n[", component.__sf_type.Name, "]")
            local inspectorText = component:GetInspectorText()
            if (inspectorText ~= "") then
                text50 = SF__.StrConcat__(text50, "\n", inspectorText)
            end
        end
    end
    BlzFrameSetText(self._inspectorText, text50)
end

function SF__.Systems.InspectorSystem:SceneContains(gameObject)
    do
        local collection14 = SF__.Scene.get_Instance().gameObjs
        for _, obj51 in (SF__.StdLib.List.IpairsNext)(collection14) do
            if (obj51 == gameObject) then
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
function SF__.Systems.InspectorSystem.HierarchyRow.__Init(self, button52, label53)
    self.__sf_type = SF__.Systems.InspectorSystem.HierarchyRow
    self.button = nil
    self.label = nil
    self.gameObject = nil
    self.depth = 0
    self.button = button52
    self.label = label53
end

function SF__.Systems.InspectorSystem.HierarchyRow.New(button52, label53)
    local self = setmetatable({}, { __index = SF__.Systems.InspectorSystem.HierarchyRow })
    SF__.Systems.InspectorSystem.HierarchyRow.__Init(self, button52, label53)
    return self
end
-- Systems.MeleeGameSystem
local SystemBase54 = require("System.SystemBase")
SF__.Systems.MeleeGameSystem = SF__.Systems.MeleeGameSystem or class("MeleeGameSystem", SystemBase54)
SF__.Systems.MeleeGameSystem.Name = "MeleeGameSystem"
SF__.Systems.MeleeGameSystem.FullName = "Systems.MeleeGameSystem"
SF__.Systems.MeleeGameSystem.__sf_base = SystemBase54
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
        local collection15 = systems
        for _, system in (SF__.StdLib.List.IpairsNext)(collection15) do
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
        local collection16 = systems
        for _, system1 in (SF__.StdLib.List.IpairsNext)(collection16) do
            system1:OnEnable()
        end
    end
    local game = FrameTimer.new(function(dt)
        local now = (MathRound((Time.Time * 100)) * 0.01)
        do
            local collection17 = systems
            for _, system2 in (SF__.StdLib.List.IpairsNext)(collection17) do
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
    local item94 = self._items:get_Item((self._items.Count - 1))
    self._items:RemoveAt((self._items.Count - 1))
    return item94
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
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p405, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决造成一次攻击伤害，如果目标被审判，造成30%的额外伤害，15%几率重置审判。消耗|cffff8c003|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 5秒\r\n\r\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas406:get_Item(0).JudgementDamageScaling * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas406:get_Item(0).ChanceToResetJudgement * 100)), "%的战争艺术触发几率。"), 0)
    do
        local i409 = 0
        while (i409 < 1) do
            local __unpack_tmp411 = datas406:get_Item(i409)
            local data__DamageScaling410, data__JudgementDamageScaling, data__ChanceToResetJudgement = __unpack_tmp411.DamageScaling, __unpack_tmp411.JudgementDamageScaling, __unpack_tmp411.ChanceToResetJudgement
            SF__.Utils.ExBlzSetAbilityTooltip(p405, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决 - [|cffffcc00", (i409 + 1), "级|r]"), i409)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p405, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决造成一次攻击伤害，造成|cffff8c00", string.format("%.0f", (data__DamageScaling410 * 100)), "%|r的攻击伤害。消耗|cffff8c003|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 5秒"), i409)
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

function SF__.Vector2.Dot(a__x109, a__y110, b__x111, b__y112)
    return ((a__x109 * b__x111) + (a__y110 * b__y112))
end

function SF__.Vector2.Cross(a__x113, a__y114, b__x115, b__y116)
    return ((a__y114 * b__x115) - (a__x113 * b__y116))
end

function SF__.Vector2.op_UnaryNegation(a__x117, a__y118)
    return (-a__x117), (-a__y118)
end

function SF__.Vector2.op_Addition(a__x119, a__y120, b__x121, b__y122)
    return (a__x119 + b__x121), (a__y120 + b__y122)
end

function SF__.Vector2.op_Subtraction(a__x123, a__y124, b__x125, b__y126)
    return (a__x123 - b__x125), (a__y124 - b__y126)
end

function SF__.Vector2.op_Multiply__vector2f(v__x127, v__y128, f)
    return (v__x127 * f), (v__y128 * f)
end

function SF__.Vector2.op_Multiply__fvector2(f129, v__x130, v__y131)
    return (v__x130 * f129), (v__y131 * f129)
end

function SF__.Vector2.op_Division(v__x132, v__y133, f134)
    return (v__x132 / f134), (v__y133 / f134)
end

function SF__.Vector2.UnitDistance(a, b)
    local v1__x, v1__y = SF__.Vector2.FromUnit(a)
    local v2__x, v2__y = SF__.Vector2.FromUnit(b)
    return SF__.Vector2.get_Magnitude(SF__.Vector2.op_Subtraction(v1__x, v1__y, v2__x, v2__y))
end

function SF__.Vector2.SqrUnitDistance(a135, b136)
    local v1__x137, v1__y138 = SF__.Vector2.FromUnit(a135)
    local v2__x139, v2__y140 = SF__.Vector2.FromUnit(b136)
    return SF__.Vector2.get_SqrMagnitude(SF__.Vector2.op_Subtraction(v1__x137, v1__y138, v2__x139, v2__y140))
end

function SF__.Vector2.FromUnit(u141)
    return GetUnitX(u141), GetUnitY(u141)
end

function SF__.Vector2.get_Magnitude(self__x142, self__y143)
    return math.sqrt(SF__.Vector2.get_SqrMagnitude(self__x142, self__y143))
end

function SF__.Vector2.get_SqrMagnitude(self__x144, self__y145)
    return ((self__x144 * self__x144) + (self__y145 * self__y145))
end

function SF__.Vector2.get_Normalized(self__x146, self__y147)
    local mag = SF__.Vector2.get_Magnitude(self__x146, self__y147)
    if (mag < 0.0001) then
        return SF__.Vector2.get_Zero()
    end
    return SF__.Vector2.op_Division(self__x146, self__y147, mag)
end

function SF__.Vector2.ClampMagnitude(self__x150, self__y151, mag152)
    return (function()
        local v__x153, v__y154 = SF__.Vector2.get_Normalized(self__x150, self__y151)
        return SF__.Vector2.op_Multiply__vector2f(v__x153, v__y154, mag152)
    end)()
end

function SF__.Vector2.ToString(self__x155, self__y156)
    return SF__.StrConcat__("(", self__x155, ", ", self__y156, ")")
end

function SF__.Vector2.Rotate(self__x157, self__y158, angle159)
    local cos = math.cos(angle159)
    local sin = math.sin(angle159)
    return ((self__x157 * cos) - (self__y158 * sin)), ((self__x157 * sin) + (self__y158 * cos))
end

function SF__.Vector2.UnitMoveTo(self__x160, self__y161, u162)
    SetUnitX(u162, self__x160)
    SetUnitY(u162, self__y161)
end

function SF__.Vector2.GetTerrainZ(self__x163, self__y164)
    MoveLocation(SF__.Vector2._loc, self__x163, self__y164)
    return GetLocationZ(SF__.Vector2._loc)
end

SF__.Vector2._loc = Location(0, 0)

SF__.Program.Main()
