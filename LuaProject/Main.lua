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
        if not ok then print(tostring(err)) end
    end)
    return coroutine.yield()
end

function SF__.StrSplit__(str, sep)
    local result = {}
    if str == nil or str == "" then return result end
    if sep == nil or sep == "" then
        for i = 1, #str do
            result[i] = str:sub(i, i)
        end
        return result
    end
    local pos = 1
    while true do
        local start, finish = string.find(str, sep, pos, true)
        if start == nil then
            table.insert(result, string.sub(str, pos))
            break
        end
        table.insert(result, string.sub(str, pos, start - 1))
        pos = finish + 1
    end
    return result
end

require("Lib.class")
-- CollisionType
SF__.CollisionType = SF__.CollisionType or {}
-- <summary>
-- Invoke onArrived when the missile reaches the target point or unit.
-- </summary>
--
SF__.CollisionType.WhenArrived = 0
-- <summary>
-- Invoke onArrived when the missile collides with any unit within colliderSize, regardless of whether it has reached the target point or unit. If the missile is set to lookAtTarget, it will be destroyed upon collision. Otherwise, it will continue moving until it reaches the target point or unit, but onArrived will only be invoked once. If you want to invoke onArrived multiple times for each collision, you can set onArrived to null after the first invocation and handle subsequent collisions in the Update method. Note that if the missile is set to lookAtTarget, it will be destroyed upon collision and will not continue moving or invoking onArrived for subsequent collisions.
-- </summary>
--
SF__.CollisionType.WhenMoving = 1

SF__.LuaWrapper = SF__.LuaWrapper or {}
-- LuaWrapper.HitResult
SF__.LuaWrapper.HitResult = SF__.LuaWrapper.HitResult or {}
SF__.LuaWrapper.HitResult.Hit = 1
SF__.LuaWrapper.HitResult.Miss = 2
SF__.LuaWrapper.HitResult.Critical = 4

-- TargetType
SF__.TargetType = SF__.TargetType or {}
-- <summary>
-- Move towards a unit.
-- </summary>
--
SF__.TargetType.Unit = 0
-- <summary>
-- Move towards a point.
-- </summary>
--
SF__.TargetType.Point = 1
-- <summary>
-- No movement.
-- </summary>
--
SF__.TargetType.Passive = 2

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

function SF__.Vector3.op_Addition(a__x174, a__y175, a__z176, b__x177, b__y178, b__z179)
    return (a__x174 + b__x177), (a__y175 + b__y178), (a__z176 + b__z179)
end

function SF__.Vector3.op_UnaryNegation(a__x180, a__y181, a__z182)
    return (-a__x180), (-a__y181), (-a__z182)
end

function SF__.Vector3.op_Subtraction(a__x183, a__y184, a__z185, b__x186, b__y187, b__z188)
    return (a__x183 - b__x186), (a__y184 - b__y187), (a__z185 - b__z188)
end

function SF__.Vector3.op_Multiply__osef(v__x189, v__y190, v__z191, f192)
    return (v__x189 * f192), (v__y190 * f192), (v__z191 * f192)
end

function SF__.Vector3.op_Multiply__fose(f193, v__x194, v__y195, v__z196)
    return (v__x194 * f193), (v__y195 * f193), (v__z196 * f193)
end

function SF__.Vector3.op_Division(v__x197, v__y198, v__z199, f200)
    return (v__x197 / f200), (v__y198 / f200), (v__z199 / f200)
end

-- <summary>
-- Warcraft III world space here is right-handed: +x points right, +y points away, +z points up.
-- That means Cross((1,0,0), (0,1,0)) == (0,0,1).
-- </summary>
--
function SF__.Vector3.Cross(a__x201, a__y202, a__z203, b__x204, b__y205, b__z206)
    return ((a__y202 * b__z206) - (a__z203 * b__y205)), ((a__z203 * b__x204) - (a__x201 * b__z206)), ((a__x201 * b__y205) - (a__y202 * b__x204))
end

function SF__.Vector3.Distance(a__x207, a__y208, a__z209, b__x210, b__y211, b__z212)
    return SF__.Vector3.get_magnitude(SF__.Vector3.op_Subtraction(a__x207, a__y208, a__z209, b__x210, b__y211, b__z212))
end

function SF__.Vector3.Dot(a__x213, a__y214, a__z215, b__x216, b__y217, b__z218)
    return (((a__x213 * b__x216) + (a__y214 * b__y217)) + (a__z215 * b__z218))
end

function SF__.Vector3.Lerp(a__x219, a__y220, a__z221, b__x222, b__y223, b__z224, t225)
    t225 = math.clamp01(t225)
    return SF__.Vector3.op_Addition(a__x219, a__y220, a__z221, (function()
        local v__x226, v__y227, v__z228 = SF__.Vector3.op_Subtraction(b__x222, b__y223, b__z224, a__x219, a__y220, a__z221)
        return SF__.Vector3.op_Multiply__osef(v__x226, v__y227, v__z228, t225)
    end)())
end

function SF__.Vector3.MoveTowards(current__x, current__y, current__z, target__x, target__y, target__z, maxDistanceDelta)
    local toVector__x, toVector__y, toVector__z = SF__.Vector3.op_Subtraction(target__x, target__y, target__z, current__x, current__y, current__z)
    local dist = SF__.Vector3.get_magnitude(toVector__x, toVector__y, toVector__z)
    if ((dist <= maxDistanceDelta) or (dist == 0)) then
        return target__x, target__y, target__z
    end
    return SF__.Vector3.op_Addition(current__x, current__y, current__z, SF__.Vector3.op_Division(toVector__x, toVector__y, toVector__z, (dist / maxDistanceDelta)))
end

function SF__.Vector3.Project(v__x229, v__y230, v__z231, onNormal__x, onNormal__y, onNormal__z)
    local sqrMag = SF__.Vector3.Dot(onNormal__x, onNormal__y, onNormal__z, onNormal__x, onNormal__y, onNormal__z)
    if (sqrMag < 0.0001) then
        return SF__.Vector3.get_zero()
    end
    local dot = SF__.Vector3.Dot(v__x229, v__y230, v__z231, onNormal__x, onNormal__y, onNormal__z)
    return SF__.Vector3.op_Multiply__osef(onNormal__x, onNormal__y, onNormal__z, (dot / sqrMag))
end

function SF__.Vector3.ProjectOnPlane(v__x232, v__y233, v__z234, planeNormal__x, planeNormal__y, planeNormal__z)
    return SF__.Vector3.op_Subtraction(v__x232, v__y233, v__z234, SF__.Vector3.Project(v__x232, v__y233, v__z234, planeNormal__x, planeNormal__y, planeNormal__z))
end

function SF__.Vector3.Reflect(inDirection__x, inDirection__y, inDirection__z, inNormal__x, inNormal__y, inNormal__z)
    return SF__.Vector3.op_Subtraction(inDirection__x, inDirection__y, inDirection__z, SF__.Vector3.op_Multiply__fose((2 * SF__.Vector3.Dot(inDirection__x, inDirection__y, inDirection__z, inNormal__x, inNormal__y, inNormal__z)), inNormal__x, inNormal__y, inNormal__z))
end

function SF__.Vector3.RotateTowards(current__x235, current__y236, current__z237, target__x238, target__y239, target__z240, maxRadiansDelta, maxMagnitudeDelta)
    local currentMag = SF__.Vector3.get_magnitude(current__x235, current__y236, current__z237)
    local targetMag = SF__.Vector3.get_magnitude(target__x238, target__y239, target__z240)
    if ((currentMag == 0) or (targetMag == 0)) then
        return SF__.Vector3.MoveTowards(current__x235, current__y236, current__z237, target__x238, target__y239, target__z240, maxMagnitudeDelta)
    end
    local currentNorm__x, currentNorm__y, currentNorm__z = SF__.Vector3.op_Division(current__x235, current__y236, current__z237, currentMag)
    local targetNorm__x, targetNorm__y, targetNorm__z = SF__.Vector3.op_Division(target__x238, target__y239, target__z240, targetMag)
    local dot241 = math.clamp(SF__.Vector3.Dot(currentNorm__x, currentNorm__y, currentNorm__z, targetNorm__x, targetNorm__y, targetNorm__z), (-1), 1)
    local angle242 = math.acos(dot241)
    if (angle242 == 0) then
        return SF__.Vector3.MoveTowards(current__x235, current__y236, current__z237, target__x238, target__y239, target__z240, maxMagnitudeDelta)
    end
    local t243 = math.min(1, (maxRadiansDelta / angle242))
    local newDir__x, newDir__y, newDir__z = SF__.Vector3.Slerp(currentNorm__x, currentNorm__y, currentNorm__z, targetNorm__x, targetNorm__y, targetNorm__z, t243)
    local newMag = math.moveTowards(currentMag, targetMag, maxMagnitudeDelta)
    return SF__.Vector3.op_Multiply__osef(newDir__x, newDir__y, newDir__z, newMag)
end

function SF__.Vector3.Scale(a__x244, a__y245, a__z246, b__x247, b__y248, b__z249)
    return (a__x244 * b__x247), (a__y245 * b__y248), (a__z246 * b__z249)
end

function SF__.Vector3.Slerp(a__x250, a__y251, a__z252, b__x253, b__y254, b__z255, t256)
    local magA = SF__.Vector3.get_magnitude(a__x250, a__y251, a__z252)
    local magB = SF__.Vector3.get_magnitude(b__x253, b__y254, b__z255)
    if ((magA == 0) or (magB == 0)) then
        return SF__.Vector3.MoveTowards(a__x250, a__y251, a__z252, b__x253, b__y254, b__z255, math.huge)
    end
    local normA__x, normA__y, normA__z = SF__.Vector3.op_Division(a__x250, a__y251, a__z252, magA)
    local normB__x, normB__y, normB__z = SF__.Vector3.op_Division(b__x253, b__y254, b__z255, magB)
    local dot257 = math.clamp(SF__.Vector3.Dot(normA__x, normA__y, normA__z, normB__x, normB__y, normB__z), (-1), 1)
    local angle258 = math.acos(dot257)
    local sinAngle = math.sin(angle258)
    if (sinAngle < 0.0001) then
        return SF__.Vector3.MoveTowards(a__x250, a__y251, a__z252, b__x253, b__y254, b__z255, math.huge)
    end
    local tAngle = (angle258 * t256)
    local sinTA = math.sin(tAngle)
    local sinTOneMinusA = math.sin((angle258 - tAngle))
    local newDir__x265, newDir__y266, newDir__z267 = (function()
        local v__x262, v__y263, v__z264 = (function()
            local a__x259, a__y260, a__z261 = SF__.Vector3.op_Multiply__osef(normA__x, normA__y, normA__z, sinTOneMinusA)
            return SF__.Vector3.op_Addition(a__x259, a__y260, a__z261, SF__.Vector3.op_Multiply__osef(normB__x, normB__y, normB__z, sinTA))
        end)()
        return SF__.Vector3.op_Division(v__x262, v__y263, v__z264, sinAngle)
    end)()
    local newMag268 = math.lerp(magA, magB, t256)
    return SF__.Vector3.op_Multiply__osef(newDir__x265, newDir__y266, newDir__z267, newMag268)
end

function SF__.Vector3._getTerrainZ(x269, y270)
    MoveLocation(SF__.Vector3._loc, x269, y270)
    return GetLocationZ(SF__.Vector3._loc)
end

function SF__.Vector3.FromUnit(u271)
    local x272 = GetUnitX(u271)
    local y273 = GetUnitY(u271)
    return x272, y273, (SF__.Vector3._getTerrainZ(x272, y273) + GetUnitFlyHeight(u271))
end

function SF__.Vector3.get_sqrMagnitude(self__x274, self__y275, self__z276)
    return (((self__x274 * self__x274) + (self__y275 * self__y275)) + (self__z276 * self__z276))
end

function SF__.Vector3.get_magnitude(self__x277, self__y278, self__z279)
    return math.sqrt(SF__.Vector3.get_sqrMagnitude(self__x277, self__y278, self__z279))
end

function SF__.Vector3.get_normalized(self__x280, self__y281, self__z282)
    local mag283 = SF__.Vector3.get_magnitude(self__x280, self__y281, self__z282)
    if (mag283 < 0.0001) then
        return SF__.Vector3.get_zero()
    end
    return SF__.Vector3.op_Division(self__x280, self__y281, self__z282, mag283)
end

function SF__.Vector3.ClampMagnitude(self__x287, self__y288, self__z289, mag290)
    return (function()
        local v__x291, v__y292, v__z293 = SF__.Vector3.get_normalized(self__x287, self__y288, self__z289)
        return SF__.Vector3.op_Multiply__osef(v__x291, v__y292, v__z293, mag290)
    end)()
end

function SF__.Vector3.ToString(self__x294, self__y295, self__z296)
    return SF__.StrConcat__("(", self__x294, ", ", self__y295, ", ", self__z296, ")")
end

function SF__.Vector3.UnitMoveTo(self__x297, self__y298, self__z299, u300, mode)
    if mode == nil then mode = SF__.UnitVec3Mode.Auto end
    local tz = SF__.Vector3._getTerrainZ(self__x297, self__y298)
    local LuaUtils = require("Lib.Utils")
    local defaultFlyHeight = GetUnitDefaultFlyHeight(u300)
    local minZ = (tz + defaultFlyHeight)
    SetUnitPosition(u300, self__x297, self__y298)
    repeat
        local switchValue = mode
        if (switchValue == SF__.UnitVec3Mode.ForceFlying) then
            LuaUtils.SetUnitFlyable(u300)
            SetUnitFlyHeight(u300, (math.max(minZ, self__z299) - minZ), 0)
            break
        elseif (switchValue == SF__.UnitVec3Mode.ForceGround) then
            SetUnitFlyHeight(u300, defaultFlyHeight, 0)
            break
        elseif (switchValue == SF__.UnitVec3Mode.Auto) then
            if IsUnitType(u300, UNIT_TYPE_FLYING) then
                SetUnitFlyHeight(u300, (math.max(minZ, self__z299) - minZ), 0)
            else
                SetUnitFlyHeight(u300, defaultFlyHeight, 0)
            end
            break
        end
    until true
end

function SF__.Vector3.GetTerrainZ(self__x301, self__y302, self__z303)
    return SF__.Vector3._getTerrainZ(self__x301, self__y302)
end

SF__.Vector3._loc = Location(0, 0)
-- Quaternion
SF__.Quaternion = SF__.Quaternion or {}
SF__.Quaternion.Name = "Quaternion"
SF__.Quaternion.FullName = "Quaternion"
function SF__.Quaternion.get_identity()
    return 0, 0, 0, 1
end

function SF__.Quaternion.op_Multiply__iyiiyi(a__x, a__y, a__z, a__w, b__x, b__y, b__z, b__w)
    return ((((a__w * b__x) + (a__x * b__w)) + (a__y * b__z)) - (a__z * b__y)), ((((a__w * b__y) - (a__x * b__z)) + (a__y * b__w)) + (a__z * b__x)), ((((a__w * b__z) + (a__x * b__y)) - (a__y * b__x)) + (a__z * b__w)), ((((a__w * b__w) - (a__x * b__x)) - (a__y * b__y)) - (a__z * b__z))
end

function SF__.Quaternion.op_Multiply__iyiose(q__x61, q__y62, q__z63, q__w64, v__x, v__y, v__z)
    -- https://en.wikipedia.org/wiki/Quaternions_and_spatial_rotation#Using_quaternion_as_rotations
    local u__x, u__y, u__z = q__x61, q__y62, q__z63
    local s = q__w64
    return (function()
        local a__x68, a__y69, a__z70 = (function()
            local a__x65, a__y66, a__z67 = SF__.Vector3.op_Multiply__fose((2 * SF__.Vector3.Dot(u__x, u__y, u__z, v__x, v__y, v__z)), u__x, u__y, u__z)
            return SF__.Vector3.op_Addition(a__x65, a__y66, a__z67, SF__.Vector3.op_Multiply__fose(((s * s) - SF__.Vector3.Dot(u__x, u__y, u__z, u__x, u__y, u__z)), v__x, v__y, v__z))
        end)()
        return SF__.Vector3.op_Addition(a__x68, a__y69, a__z70, SF__.Vector3.op_Multiply__fose((2 * s), SF__.Vector3.Cross(u__x, u__y, u__z, v__x, v__y, v__z)))
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

function SF__.Quaternion.LookRotation__oseose(forward__x, forward__y, forward__z, upwards__x, upwards__y, upwards__z)
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
    local x71
    local y72
    local z
    local w
    local trace = ((m00 + m11) + m22)
    if (trace > 0) then
        local s73 = (math.sqrt((trace + 1)) * 2)
        w = (0.25 * s73)
        x71 = ((m21 - m12) / s73)
        y72 = ((m02 - m20) / s73)
        z = ((m10 - m01) / s73)
    elseif ((m00 > m11) and (m00 > m22)) then
        local s74 = (math.sqrt((((1 + m00) - m11) - m22)) * 2)
        w = ((m21 - m12) / s74)
        x71 = (0.25 * s74)
        y72 = ((m01 + m10) / s74)
        z = ((m02 + m20) / s74)
    else
        if (m11 > m22) then
            local s75 = (math.sqrt((((1 + m11) - m00) - m22)) * 2)
            w = ((m02 - m20) / s75)
            x71 = ((m01 + m10) / s75)
            y72 = (0.25 * s75)
            z = ((m12 + m21) / s75)
        else
            local s76 = (math.sqrt((((1 + m22) - m00) - m11)) * 2)
            w = ((m10 - m01) / s76)
            x71 = ((m02 + m20) / s76)
            y72 = ((m12 + m21) / s76)
            z = (0.25 * s76)
        end
    end
    return SF__.Quaternion.Normalize(x71, y72, z, w)
end

function SF__.Quaternion.LookRotation__ose(forward__x77, forward__y78, forward__z79)
    return SF__.Quaternion.LookRotation__oseose(forward__x77, forward__y78, forward__z79, SF__.Vector3.get_up())
end

function SF__.Quaternion.Normalize(q__x80, q__y81, q__z82, q__w83)
    local magnitude = math.sqrt(((((q__x80 * q__x80) + (q__y81 * q__y81)) + (q__z82 * q__z82)) + (q__w83 * q__w83)))
    if (magnitude < 0.0001) then
        return SF__.Quaternion.get_identity()
    end
    return (q__x80 / magnitude), (q__y81 / magnitude), (q__z82 / magnitude), (q__w83 / magnitude)
end

function SF__.Quaternion.get_eulerAngles(self__x, self__y, self__z, self__w)
    -- https://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles#Source_Code_2
    local sinr_cosp = (2 * ((self__w * self__x) + (self__y * self__z)))
    local cosr_cosp = (1 - (2 * ((self__x * self__x) + (self__y * self__y))))
    local roll84 = math.atan(sinr_cosp, cosr_cosp)
    local sinp = (2 * ((self__w * self__y) - (self__z * self__x)))
    local pitch85
    if (math.abs(sinp) >= 1) then
        pitch85 = ((math.sign(sinp) * math.pi) / 2)
        -- use 90 degrees if out of range
    else
        pitch85 = math.asin(sinp)
    end
    local siny_cosp = (2 * ((self__w * self__z) + (self__x * self__y)))
    local cosy_cosp = (1 - (2 * ((self__y * self__y) + (self__z * self__z))))
    local yaw86 = math.atan(siny_cosp, cosy_cosp)
    return (pitch85 * bj_RADTODEG), (yaw86 * bj_RADTODEG), (roll84 * bj_RADTODEG)
end

function SF__.Quaternion.get_normalized(self__x87, self__y88, self__z89, self__w90)
    return SF__.Quaternion.Normalize(self__x87, self__y88, self__z89, self__w90)
end

function SF__.Quaternion.Inverse(rotation__x, rotation__y, rotation__z, rotation__w)
    return (-rotation__x), (-rotation__y), (-rotation__z), rotation__w
end

function SF__.Quaternion.ToString(self__x95, self__y96, self__z97, self__w98)
    return SF__.StrConcat__("(", self__x95, ", ", self__y96, ", ", self__z97, ", ", self__w98, ")")
end

function SF__.Quaternion.ApplyToEffect(self__x99, self__y100, self__z101, self__w102, e)
    local angles__x, angles__y, angles__z = SF__.Quaternion.get_eulerAngles(self__x99, self__y100, self__z101, self__w102)
    BlzSetSpecialEffectOrientation(e, (angles__y * bj_DEGTORAD), (angles__x * bj_DEGTORAD), (angles__z * bj_DEGTORAD))
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

function SF__.StdLib.List.__Init__xqm20z(self, collection)
    SF__.StdLib.List.__Init__0(self)
    do
        local collection1 = collection
        for _, item455 in (SF__.StdLib.List.IpairsNext)(collection1) do
            table.insert(self._items, item455)
            self.Count = (self.Count + 1)
        end
    end
end

function SF__.StdLib.List.New__xqm20z(collection)
    local self = setmetatable({}, { __index = SF__.StdLib.List })
    SF__.StdLib.List.__Init__xqm20z(self, collection)
    return self
end

function SF__.StdLib.List:get_Item(index456)
    if ((index456 < 0) or (index456 >= self.Count)) then
        error(SF__.StrConcat__("SF__E2e5944b8", "Index out of range"))
    end
    return self._items[(index456 + 1)]
end

function SF__.StdLib.List:set_Item(index457, value)
    if ((index457 < 0) or (index457 >= self.Count)) then
        error(SF__.StrConcat__("SF__E2e5944b8", "Index out of range"))
    end
    self._items[(index457 + 1)] = value
end

function SF__.StdLib.List:AddRange(collection458)
    do
        local collection2 = collection458
        for _, item459 in (SF__.StdLib.List.IpairsNext)(collection2) do
            table.insert(self._items, item459)
            self.Count = (self.Count + 1)
        end
    end
    self._version = (self._version + 1)
end

function SF__.StdLib.List:Add(item460)
    table.insert(self._items, item460)
    self.Count = (self.Count + 1)
    self._version = (self._version + 1)
end

function SF__.StdLib.List:Clear()
    self._items = {}
    self.Count = 0
    self._version = (self._version + 1)
end

function SF__.StdLib.List:Remove(item461)
    local index462 = self:IndexOf(item461)
    if (index462 < 0) then
        return false
    end
    self:RemoveAt(index462)
    return true
end

function SF__.StdLib.List:RemoveAt(index463)
    table.remove(self._items, (index463 + 1))
    self.Count = (self.Count - 1)
    self._version = (self._version + 1)
end

function SF__.StdLib.List:IndexOf(item464)
    do
        local i465 = 0
        while (i465 < self.Count) do
            local current466 = self._items[(i465 + 1)]
            if (current466 == item464) then
                return i465
            end
            ::continue::
            i465 = (i465 + 1)
        end
    end
    return (-1)
end

function SF__.StdLib.List.DefaultCompare(a467, b468)
    if (a467 == b468) then
        return 0
    end
    if (a467 < b468) then
        return (-1)
    end
    return 1
end

function SF__.StdLib.List:Sort(comparison)
    if (comparison == nil) then
        comparison = SF__.StdLib.List.DefaultCompare
    end
    local version = self._version
    table.sort(self._items, function(a471, b472)
        return (comparison(a471, b472) < 0)
    end)
    if (version ~= self._version) then
        error(SF__.StrConcat__("SF__E2e5944b8", "Collection was modified"))
    end
    self._version = (self._version + 1)
end

function SF__.StdLib.List:IpairsNext()
    local version473 = self._version
    local index474 = 0
    return function()
        if (version473 ~= self._version) then
            error(SF__.StrConcat__("SF__E2e5944b8", "Collection was modified"))
        end
        index474 = (index474 + 1)
        local value475 = self._items[index474]
        if (value475 == nil) then
            return nil
        end
        return index474, value475
    end
end

function SF__.StdLib.List:GetEnumerator()
    return nil
end
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
        globalPos__x3, globalPos__y4, globalPos__z5 = SF__.Vector3.op_Addition(myParent.localPosition__x, myParent.localPosition__y, myParent.localPosition__z, SF__.Quaternion.op_Multiply__iyiose(myParent.localRotation__x, myParent.localRotation__y, myParent.localRotation__z, myParent.localRotation__w, SF__.Vector3.Scale(myParent.localScale__x, myParent.localScale__y, myParent.localScale__z, globalPos__x3, globalPos__y4, globalPos__z5)))
        globalRot__x6, globalRot__y7, globalRot__z8, globalRot__w9 = SF__.Quaternion.op_Multiply__iyiiyi(myParent.localRotation__x, myParent.localRotation__y, myParent.localRotation__z, myParent.localRotation__w, globalRot__x6, globalRot__y7, globalRot__z8, globalRot__w9)
        globalScale__x10, globalScale__y11, globalScale__z12 = SF__.Vector3.Scale(myParent.localScale__x, myParent.localScale__y, myParent.localScale__z, globalScale__x10, globalScale__y11, globalScale__z12)
        myParent = myParent.parent
        ::continue::
    end
    return globalPos__x3, globalPos__y4, globalPos__z5
end

function SF__.Transform:set_position(value__x, value__y, value__z)
    if (self.parent == nil) then
        self.localPosition__x, self.localPosition__y, self.localPosition__z = value__x, value__y, value__z
        return
    end
    local pos__x, pos__y, pos__z = value__x, value__y, value__z
    local myParent13 = self.parent
    while (myParent13 ~= nil) do
        pos__x, pos__y, pos__z = SF__.Vector3.op_Subtraction(pos__x, pos__y, pos__z, myParent13.localPosition__x, myParent13.localPosition__y, myParent13.localPosition__z)
        pos__x, pos__y, pos__z = SF__.Vector3.Scale((1 / myParent13.localScale__x), (1 / myParent13.localScale__y), (1 / myParent13.localScale__z), pos__x, pos__y, pos__z)
        pos__x, pos__y, pos__z = (function()
            local q__x, q__y, q__z, q__w = SF__.Quaternion.Inverse(myParent13.localRotation__x, myParent13.localRotation__y, myParent13.localRotation__z, myParent13.localRotation__w)
            return SF__.Quaternion.op_Multiply__iyiose(q__x, q__y, q__z, q__w, pos__x, pos__y, pos__z)
        end)()
        myParent13 = myParent13.parent
        ::continue::
    end
    self.localPosition__x, self.localPosition__y, self.localPosition__z = pos__x, pos__y, pos__z
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

function SF__.Transform._Find(current, parts, index)
    if (index >= #parts) then
        return current
    end
    do
        local collection3 = current.children
        for _, child in (SF__.StdLib.List.IpairsNext)(collection3) do
            if (child.gameObject.name == parts[(index + 1)]) then
                local found = SF__.Transform._Find(child, parts, (index + 1))
                if (found ~= nil) then
                    return found
                end
            end
        end
    end
    return nil
end

-- <summary>
-- Finds a child by name n and returns it.
-- If no child with name n can be found, null is returned. If n contains a '/' character it will access the Transform in the hierarchy like a path name.
-- </summary>
-- <param name="name"></param>
-- <returns></returns>
--
function SF__.Transform:Find(name)
    local parts14 = SF__.StrSplit__(name, "/")
    return SF__.Transform._Find(self, parts14, 0)
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
        for _, child15 in (SF__.StdLib.List.IpairsNext)(collection4) do
            SF__.GameObject.MarkDestroyQueuedDepthFirst(child15.gameObject)
        end
    end
end

function SF__.GameObject.DestroyDepthFirst(obj16)
    if obj16.isDestroyed then
        return
    end
    local children = obj16.transform.children
    do
        local i = (children.Count - 1)
        while (i >= 0) do
            SF__.GameObject.DestroyDepthFirst(children:get_Item(i).gameObject)
            ::continue::
            i = (i - 1)
        end
    end
    obj16.transform:SetParent(nil)
    do
        local collection5 = obj16._components
        for _, comp in (SF__.StdLib.List.IpairsNext)(collection5) do
            comp:OnDisable()
            comp:OnDestroy()
        end
    end
    obj16._components:Clear()
    SF__.Scene.get_Instance().gameObjs:Remove(obj16)
    obj16.isDestroyed = true
end

function SF__.GameObject:get_components()
    return self._components
end

function SF__.GameObject.__Init__s(self, name17)
    self.__sf_type = SF__.GameObject
    self.name = nil
    self.transform = nil
    self._components = SF__.StdLib.List.New__0()
    self.isDestroyQueued = false
    self.isDestroyed = false
    self.name = name17
    self.transform = self:AddComponent(SF__.Transform)
    SF__.Scene.get_Instance():AddGameObject(self)
end

function SF__.GameObject.New__s(name17)
    local self = setmetatable({}, { __index = SF__.GameObject })
    SF__.GameObject.__Init__s(self, name17)
    return self
end

function SF__.GameObject.__Init__sx13(self, name18, parent19)
    SF__.GameObject.__Init__s(self, name18)
    self.transform:SetParent(parent19.transform)
end

function SF__.GameObject.New__sx13(name18, parent19)
    local self = setmetatable({}, { __index = SF__.GameObject })
    SF__.GameObject.__Init__sx13(self, name18, parent19)
    return self
end

function SF__.GameObject:GetComponent(T)
    do
        local collection6 = self._components
        for _, comp20 in (SF__.StdLib.List.IpairsNext)(collection6) do
            do
                local tComp = comp20
                if SF__.TypeIs__(tComp, T) then
                    return tComp
                end
            end
        end
    end
    return nil
end

function SF__.GameObject:AddComponent(T21)
    local comp22 = (function()
        local obj23 = T21.New()
        obj23.gameObject = self
        return obj23
    end)()
    self._components:Add(comp22)
    comp22:Awake()
    comp22:OnEnable()
    comp22:Start()
    return comp22
end

function SF__.GameObject:RemoveAllComponents(T24)
    do
        local i25 = (self._components.Count - 1)
        while (i25 >= 0) do
            if SF__.TypeIs__(self._components:get_Item(i25), T24) then
                self._components:get_Item(i25):OnDisable()
                self._components:get_Item(i25):OnDestroy()
                self._components:RemoveAt(i25)
            end
            ::continue::
            i25 = (i25 - 1)
        end
    end
end

function SF__.GameObject:Update()
    if (self.isDestroyQueued or self.isDestroyed) then
        return
    end
    local snapshot = SF__.StdLib.List.New__xqm20z(self._components)
    do
        local collection7 = snapshot
        for _, comp26 in (SF__.StdLib.List.IpairsNext)(collection7) do
            comp26:Update()
        end
    end
end

function SF__.GameObject:LateUpdate()
    if (self.isDestroyQueued or self.isDestroyed) then
        return
    end
    local snapshot27 = SF__.StdLib.List.New__xqm20z(self._components)
    do
        local collection8 = snapshot27
        for _, comp28 in (SF__.StdLib.List.IpairsNext)(collection8) do
            comp28:LateUpdate()
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

function SF__.GameObject.DestroyQueued(obj29)
    SF__.GameObject.DestroyDepthFirst(obj29)
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

function SF__.Scene:AddGameObject(obj30)
    self.gameObjs:Add(obj30)
end

function SF__.Scene:QueueDestroy(obj31)
    self._destroyQueue:Add(obj31)
end

function SF__.Scene:FlushDestroyQueue()
    do
        local i32 = 0
        while (i32 < self._destroyQueue.Count) do
            SF__.GameObject.DestroyQueued(self._destroyQueue:get_Item(i32))
            ::continue::
            i32 = (i32 + 1)
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
                local i33 = 0
                while (i33 < count) do
                    self.gameObjs:get_Item(i33):Update()
                    ::continue::
                    i33 = (i33 + 1)
                end
            end
            do
                local i34 = 0
                while (i34 < count) do
                    self.gameObjs:get_Item(i34):LateUpdate()
                    ::continue::
                    i34 = (i34 + 1)
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
        globalPos__x, globalPos__y, globalPos__z = SF__.Vector3.op_Addition(parent.localPosition__x, parent.localPosition__y, parent.localPosition__z, SF__.Quaternion.op_Multiply__iyiose(parent.localRotation__x, parent.localRotation__y, parent.localRotation__z, parent.localRotation__w, SF__.Vector3.Scale(parent.localScale__x, parent.localScale__y, parent.localScale__z, globalPos__x, globalPos__y, globalPos__z)))
        globalRot__x, globalRot__y, globalRot__z, globalRot__w = SF__.Quaternion.op_Multiply__iyiiyi(parent.localRotation__x, parent.localRotation__y, parent.localRotation__z, parent.localRotation__w, globalRot__x, globalRot__y, globalRot__z, globalRot__w)
        globalScale__x, globalScale__y, globalScale__z = SF__.Vector3.Scale(parent.localScale__x, parent.localScale__y, parent.localScale__z, globalScale__x, globalScale__y, globalScale__z)
        parent = parent.parent
        ::continue::
    end
    self._lerpElapsed = (self._lerpElapsed + SF__.Scene.DT)
    local tarPos__x, tarPos__y, tarPos__z = globalPos__x, globalPos__y, globalPos__z
    if (self._lerpElapsed < self._lerpDuration) then
        tarPos__x, tarPos__y, tarPos__z = SF__.Vector3.Lerp(self._lastPos__x, self._lastPos__y, self._lastPos__z, globalPos__x, globalPos__y, globalPos__z, (self._lerpElapsed / self._lerpDuration))
    end
    BlzSetSpecialEffectPosition(self.eff, tarPos__x, tarPos__y, tarPos__z)
    self._lastPos__x, self._lastPos__y, self._lastPos__z = tarPos__x, tarPos__y, tarPos__z
    SF__.Quaternion.ApplyToEffect(globalRot__x, globalRot__y, globalRot__z, globalRot__w, self.eff)
    BlzSetSpecialEffectMatrixScale(self.eff, globalScale__x, globalScale__y, globalScale__z)
end

function SF__.AttachEffectComponent:OnDestroy()
    if (self.eff ~= nil) then
        DestroyEffect(self.eff)
        self.eff = nil
    end
end

function SF__.AttachEffectComponent:AttachEffect(eff)
    self.eff = eff
    self._lastPos__x, self._lastPos__y, self._lastPos__z = BlzGetLocalSpecialEffectX(eff), BlzGetLocalSpecialEffectY(eff), BlzGetLocalSpecialEffectZ(eff)
end

-- <summary>
--
-- </summary>
-- <param name="duration">ms</param>
--
function SF__.AttachEffectComponent:LerpIn(duration)
    if (self.eff == nil) then
        return
    end
    self._lerpDuration = duration
    self._lerpElapsed = 0
end

function SF__.AttachEffectComponent.__Init(self)
    SF__.Component.__Init(self)
    self.__sf_type = SF__.AttachEffectComponent
    self._lastPos__x = 0
    self._lastPos__y = 0
    self._lastPos__z = 0
    self._lerpDuration = 0
    self._lerpElapsed = 0
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
    trs.localRotation__x, trs.localRotation__y, trs.localRotation__z, trs.localRotation__w = SF__.Quaternion.op_Multiply__iyiiyi(self.rotation__x, self.rotation__y, self.rotation__z, self.rotation__w, trs.localRotation__x, trs.localRotation__y, trs.localRotation__z, trs.localRotation__w)
    if (self.followUnit ~= nil) then
        trs.localPosition__x, trs.localPosition__y, trs.localPosition__z = SF__.Vector3.FromUnit(self.followUnit)
    end
end

function SF__.AutoTRSComponent.__Init(self)
    SF__.Component.__Init(self)
    self.__sf_type = SF__.AutoTRSComponent
    self.rotation = SF__.Quaternion.get_identity()
    self.followUnit = nil
end

function SF__.AutoTRSComponent.New()
    local self = setmetatable({}, { __index = SF__.AutoTRSComponent })
    SF__.AutoTRSComponent.__Init(self)
    return self
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

function SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p104, abilCode105, researchExtendedTooltip, level106)
    if (GetLocalPlayer() ~= p104) then
        return
    end
    BlzSetAbilityResearchExtendedTooltip(abilCode105, researchExtendedTooltip, level106)
end

function SF__.Utils.ExBlzSetAbilityTooltip(p107, abilCode108, tooltip, level109)
    if (GetLocalPlayer() ~= p107) then
        return
    end
    BlzSetAbilityTooltip(abilCode108, tooltip, level109)
end

function SF__.Utils.ExBlzSetAbilityExtendedTooltip(p110, abilCode111, extendedTooltip, level112)
    if (GetLocalPlayer() ~= p110) then
        return
    end
    BlzSetAbilityExtendedTooltip(abilCode111, extendedTooltip, level112)
end

function SF__.Utils.ExBlzSetAbilityIcon(p113, abilCode114, iconPath)
    if (GetLocalPlayer() ~= p113) then
        return
    end
    BlzSetAbilityIcon(abilCode114, iconPath)
end

function SF__.Utils.CsGroupGetUnitsInRange(x115, y116, radius, filter)
    local result = SF__.StdLib.List.New__0()
    ExGroupEnumUnitsInRange(x115, y116, radius, function(u117)
        if filter(u117) then
            result:Add(u117)
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
function SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(u379, amount)
    local UnitAttribute381 = require("Objects.UnitAttribute")
    local attr380 = UnitAttribute381.GetAttr(u379)
    attr380.retPalHolyEnergy = math.min((attr380.retPalHolyEnergy + amount), 5)
end

function SF__.RetributionPaladinGlobal:Init()
    ExTriggerRegisterNewUnit(function(u383)
        if (GetUnitTypeId(u383) == FourCC("Hpal")) then
            self._units:Add(u383)
        end
    end)
    _ = self:Start()
end

function SF__.RetributionPaladinGlobal:Start()
    return SF__.CorRun__(function()
        local UnitAttribute386 = require("Objects.UnitAttribute")
        while true do
            do
                local collection9 = self._units
                for _, u384 in (SF__.StdLib.List.IpairsNext)(collection9) do
                    local attr385 = UnitAttribute386.GetAttr(u384)
                    ExSetUnitMana(u384, ((ExGetUnitMaxMana(u384) * attr385.retPalHolyEnergy) * 0.2))
                    if (attr385.retPalHolyEnergy >= 3) then
                        SF__.Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u384), FourCC("A006"), "ReplaceableTextures/CommandButtons/BTNinv_helmet_96.tga")
                    else
                        SF__.Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u384), FourCC("A006"), "ReplaceableTextures/PassiveButtons/PASBTNinv_helmet_96.tga")
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
function SF__.BladeOfJustice.GetAbilityData(level304)
    return (75 * level304), 5, (10 * level304)
end

function SF__.BladeOfJustice.Init()
    local EventCenter = require("Lib.EventCenter")
    EventCenter.RegisterPlayerUnitSpellEffect:Emit({id = SF__.BladeOfJustice.ID, handler = SF__.BladeOfJustice.Start})
    ExTriggerRegisterNewUnit(function(u306)
        if (GetUnitTypeId(u306) == FourCC("Hpal")) then
            SF__.BladeOfJustice.UpdateAbilityMeta(u306)
        end
    end)
end

function SF__.BladeOfJustice.UpdateAbilityMeta(u307)
    local p308 = GetOwningPlayer(u307)
    local datas = SF__.StdLib.List.New__0()
    do
        local i309 = 0
        while (i309 < 3) do
            local __pack_Damage, __pack_Duration, __pack_DamagePerSecond = SF__.BladeOfJustice.GetAbilityData((i309 + 1))
            datas:Add({Damage = __pack_Damage, Duration = __pack_Duration, DamagePerSecond = __pack_DamagePerSecond})
            ::continue::
            i309 = (i309 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p308, SF__.BladeOfJustice.ID, "学习公正之剑 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p308, SF__.BladeOfJustice.ID, SF__.StrConcat__("用圣光的利刃刺穿目标，造成法术伤害，在一定时间内对附近敌人每秒造成光辉伤害。产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 10秒\n\n|cffffcc001级|r - 造成|cffff8c00", datas:get_Item(0).Damage, "|r的直接法术伤害，|cffff8c00", datas:get_Item(0).Duration, "|r秒内对附近敌人每秒造成|cffff8c00", datas:get_Item(0).DamagePerSecond, "|r的光辉伤害。产生|cffff8c001|r点圣能。\n|cffffcc002级|r - 造成|cffff8c00", datas:get_Item(1).Damage, "|r的直接法术伤害，|cffff8c00", datas:get_Item(1).Duration, "|r秒内对附近敌人每秒造成|cffff8c00", datas:get_Item(1).DamagePerSecond, "|r的光辉伤害。产生|cffff8c001|r点圣能。\n|cffffcc003级|r - 造成|cffff8c00", datas:get_Item(2).Damage, "|r的直接法术伤害，|cffff8c00", datas:get_Item(2).Duration, "|r秒内对附近敌人每秒造成|cffff8c00", datas:get_Item(2).DamagePerSecond, "|r的光辉伤害。产生|cffff8c001|r点圣能。"), 0)
    do
        local i310 = 0
        while (i310 < 3) do
            local __unpack_tmp = datas:get_Item(i310)
            local data__Damage, data__Duration, data__DamagePerSecond = __unpack_tmp.Damage, __unpack_tmp.Duration, __unpack_tmp.DamagePerSecond
            SF__.Utils.ExBlzSetAbilityTooltip(p308, SF__.BladeOfJustice.ID, SF__.StrConcat__("公正之剑 - [|cffffcc00", (i310 + 1), "级|r]"), i310)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p308, SF__.BladeOfJustice.ID, SF__.StrConcat__("用圣光的利刃刺穿目标，造成|cffff8c00", data__Damage, "|r的直接法术伤害，在|cffff8c00", data__Duration, "|r秒内对附近敌人每秒造成|cffff8c00", data__DamagePerSecond, "|r的光辉伤害。产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 10秒"), i310)
            ::continue::
            i310 = (i310 + 1)
        end
    end
end

function SF__.BladeOfJustice.Start(data)
    local level311 = GetUnitAbilityLevel(data.caster, SF__.BladeOfJustice.ID)
    local EventCenter312 = require("Lib.EventCenter")
    local ad__Damage, ad__Duration, ad__DamagePerSecond = SF__.BladeOfJustice.GetAbilityData(level311)
    EventCenter312.Damage:Emit({whichUnit = data.caster, target = data.target, amount = ad__Damage, attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
    SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(data.caster, 1)
    SF__.BladeOfJustice.New():StartGroudDamage(data.caster, data.target, ad__Damage, ad__Duration, ad__DamagePerSecond)
end

function SF__.BladeOfJustice:StartGroudDamage(caster, target, ad__Damage313, ad__Duration314, ad__DamagePerSecond315)
    return SF__.CorRun__(function()
        local pos__x316, pos__y317 = SF__.Vector2.FromUnit(target)
        local UnitAttribute = require("Objects.UnitAttribute")
        local EventCenter322 = require("Lib.EventCenter")
        local eff318 = ExAddSpecialEffect("Abilities/Spells/Orc/LiquidFire/Liquidfire.mdl", pos__x316, pos__y317, ad__Duration314)
        local p319 = GetOwningPlayer(caster)
        do
            local i320 = 0
            while (i320 < ad__Duration314) do
                SF__.CorWait__(1000)
                ExGroupEnumUnitsInRange(pos__x316, pos__y317, 300, function(u323)
                    if (not IsUnitEnemy(u323, p319)) then
                        return
                    end
                    if ExIsUnitDead(u323) then
                        return
                    end
                    local tarAttr324 = UnitAttribute.GetAttr(u323)
                    local damage325 = (ad__DamagePerSecond315 * (1 - tarAttr324.radiantResistance))
                    EventCenter322.Damage:Emit({whichUnit = caster, target = u323, amount = damage325, attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
                end)
                ::continue::
                i320 = (i320 + 1)
            end
        end
        DestroyEffect(eff318)
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
function SF__.CrusaderStrike.GetAbilityData(level326)
    return (0.65 + (0.35 * level326)), (0.15 * (level326 - 1))
end

function SF__.CrusaderStrike.Init()
    local EventCenter327 = require("Lib.EventCenter")
    EventCenter327.RegisterPlayerUnitSpellEffect:Emit({id = SF__.CrusaderStrike.ID, handler = SF__.CrusaderStrike.Start})
    ExTriggerRegisterNewUnit(function(u329)
        if (GetUnitTypeId(u329) == FourCC("Hpal")) then
            SF__.CrusaderStrike.UpdateAbilityMeta(u329)
        end
    end)
end

function SF__.CrusaderStrike.UpdateAbilityMeta(u330)
    local p331 = GetOwningPlayer(u330)
    local datas332 = SF__.StdLib.List.New__0()
    do
        local i333 = 0
        while (i333 < 3) do
            local __pack_DamageScaling, __pack_ArtOfWarChance = SF__.CrusaderStrike.GetAbilityData((i333 + 1))
            datas332:Add({DamageScaling = __pack_DamageScaling, ArtOfWarChance = __pack_ArtOfWarChance})
            ::continue::
            i333 = (i333 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p331, SF__.CrusaderStrike.ID, "学习十字军打击 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p331, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击造成一次攻击伤害，伤害系数随技能等级提升。产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 6秒\n\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas332:get_Item(0).DamageScaling * 100)), "%|r的攻击伤害。\n|cffffcc002级|r - |cffff8c00", string.format("%.0f", (datas332:get_Item(1).DamageScaling * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas332:get_Item(1).ArtOfWarChance * 100)), "%的战争艺术触发几率。\n|cffffcc003级|r - |cffff8c00", string.format("%.0f", (datas332:get_Item(2).DamageScaling * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas332:get_Item(2).ArtOfWarChance * 100)), "%的战争艺术触发几率。"), 0)
    do
        local i334 = 0
        while (i334 < 3) do
            local __unpack_tmp335 = datas332:get_Item(i334)
            local data__DamageScaling, data__ArtOfWarChance = __unpack_tmp335.DamageScaling, __unpack_tmp335.ArtOfWarChance
            SF__.Utils.ExBlzSetAbilityTooltip(p331, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击 - [|cffffcc00", (i334 + 1), "级|r]"), i334)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p331, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击造成一次攻击伤害，造成|cffff8c00", string.format("%.0f", (data__DamageScaling * 100)), "%|r的攻击伤害", (function() if (i334 > 0) then return SF__.StrConcat__("，", string.format("%.0f", (data__ArtOfWarChance * 100)), "%的战争艺术触发几率") else return "" end end)(), "。产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 6秒"), i334)
            ::continue::
            i334 = (i334 + 1)
        end
    end
    -- datas.Remove(new IAbilityData { DamageScaling = 0.65f, ArtOfWarChance = 0 });
    datas332:RemoveAt(0)
end

function SF__.CrusaderStrike.Start(data336)
    local level337 = GetUnitAbilityLevel(data336.caster, SF__.CrusaderStrike.ID)
    local UnitAttribute338 = require("Objects.UnitAttribute")
    local EventCenter340 = require("Lib.EventCenter")
    local ad__DamageScaling, ad__ArtOfWarChance = SF__.CrusaderStrike.GetAbilityData(level337)
    local attr = UnitAttribute338.GetAttr(data336.caster)
    local damage339 = (attr:SimAttack(UnitAttribute338.HeroAttributeType.Strength) * ad__DamageScaling)
    EventCenter340.Damage:Emit({whichUnit = data336.caster, target = data336.target, amount = damage339, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
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
    local currentPosition__x, currentPosition__y, currentPosition__z = self.gameObject.transform:get_position()
    local targetPosition__x, targetPosition__y, targetPosition__z = self.pointTarget__x, self.pointTarget__y, self.pointTarget__z
    if ((self.targetType == SF__.TargetType.Unit) or (self.targetType == SF__.TargetType.Point)) then
        if (self.targetType == SF__.TargetType.Unit) then
            if (self.unitTarget == nil) then
                return
            end
            if ExIsUnitDead(self.unitTarget) then
                self:OnDisappear()
                return
            end
            targetPosition__x, targetPosition__y, targetPosition__z = SF__.Vector3.FromUnit(self.unitTarget)
        end
        if self.lookAtTarget then
            self.gameObject.transform.localRotation__x, self.gameObject.transform.localRotation__y, self.gameObject.transform.localRotation__z, self.gameObject.transform.localRotation__w = SF__.Quaternion.LookRotation__ose(SF__.Vector3.op_Subtraction(targetPosition__x, targetPosition__y, targetPosition__z, currentPosition__x, currentPosition__y, currentPosition__z))
        end
        currentPosition__x, currentPosition__y, currentPosition__z = SF__.Vector3.MoveTowards(currentPosition__x, currentPosition__y, currentPosition__z, targetPosition__x, targetPosition__y, targetPosition__z, ((self.speed * SF__.Scene.DT) / 1000))
        self.gameObject.transform:set_position(currentPosition__x, currentPosition__y, currentPosition__z)
    end
    if ((SF__.Vector3.Distance(currentPosition__x, currentPosition__y, currentPosition__z, targetPosition__x, targetPosition__y, targetPosition__z) <= self.colliderSize) and (not self.hasArrived)) then
        self:OnCollision(true)
    end
end

function SF__.Missile:GetInspectorText()
    return SF__.StrConcat__("targetType: ", self.targetType, "\nunitTarget: ", (function() if (self.unitTarget == nil) then return "None" else return GetUnitName(self.unitTarget) end end)(), "\npointTarget: ", SF__.Vector3.ToString(self.pointTarget__x, self.pointTarget__y, self.pointTarget__z), "\nspeed: ", self.speed, "\nlookAtTarget: ", self.lookAtTarget, "\ncolliderSize: ", self.colliderSize, "\nonArrived: ", (function() if (self.onCollision == nil) then return "None" else return "Set" end end)(), "\nhasArrived: ", self.hasArrived, "\n")
end

function SF__.Missile:OnCollision(arrived)
    self.hasArrived = arrived
    local delegate = self.onCollision
    if (delegate ~= nil) then
        delegate()
    end
    if arrived then
        self.onCollision = nil
    end
end

function SF__.Missile:OnDisappear()
    self.hasArrived = true
    self.onCollision = nil
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
    self.onCollision = nil
    self.colliderSize = 0
    self.collisionCount = 1
    -- <summary>
    -- The delay between each hit when colliding with the same unit.
    -- Lower this value to hit the same unit multiple times in a short period.
    -- </summary>
    --
    self.nextHitDelay = 9999
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
function SF__.DivineToll.GetAbilityData(level341)
    return (2 + level341), (50 * level341), 0.1, 10
end

function SF__.DivineToll.Init()
    local EventCenter344 = require("Lib.EventCenter")
    EventCenter344.RegisterPlayerUnitSpellEffect:Emit({id = SF__.DivineToll.ID, handler = function(data343)
        SF__.DivineToll.Start(data343)
    end})
    ExTriggerRegisterNewUnit(function(u346)
        if (GetUnitTypeId(u346) == FourCC("Hpal")) then
            SF__.DivineToll.UpdateAbilityMeta(u346)
        end
    end)
end

function SF__.DivineToll.UpdateAbilityMeta(u347)
    local p348 = GetOwningPlayer(u347)
    local datas349 = SF__.StdLib.List.New__0()
    do
        local i350 = 0
        while (i350 < 3) do
            local __pack_TargetCount, __pack_Damage351, __pack_RadiantDmgAmp, __pack_Duration352 = SF__.DivineToll.GetAbilityData((i350 + 1))
            datas349:Add({TargetCount = __pack_TargetCount, Damage = __pack_Damage351, RadiantDmgAmp = __pack_RadiantDmgAmp, Duration = __pack_Duration352})
            ::continue::
            i350 = (i350 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p348, SF__.DivineToll.ID, "学习圣洁鸣钟 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p348, SF__.DivineToll.ID, SF__.StrConcat__("对附近的多个目标施展审判，造成法术伤害，然后神圣之锤环绕圣殿骑士，每次命中敌人使其受到的光辉伤害提高。每个审判产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 30秒\n\n|cffffcc001级|r - 审判最多|cffff8c00", datas349:get_Item(0).TargetCount, "|r个目标，造成|cffff8c00", datas349:get_Item(0).Damage, "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas349:get_Item(0).RadiantDmgAmp * 100)), "%|r的光辉易伤，持续|cffff8c00", datas349:get_Item(0).Duration, "|r秒。\n|cffffcc002级|r - 审判最多|cffff8c00", datas349:get_Item(1).TargetCount, "|r个目标，造成|cffff8c00", datas349:get_Item(1).Damage, "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas349:get_Item(1).RadiantDmgAmp * 100)), "%|r的光辉易伤，持续|cffff8c00", datas349:get_Item(1).Duration, "|r秒。\n|cffffcc003级|r - 审判最多|cffff8c00", datas349:get_Item(2).TargetCount, "|r个目标，造成|cffff8c00", datas349:get_Item(2).Damage, "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas349:get_Item(2).RadiantDmgAmp * 100)), "%|r的光辉易伤，持续|cffff8c00", datas349:get_Item(2).Duration, "|r秒。"), 0)
    do
        local i353 = 0
        while (i353 < 3) do
            local __unpack_tmp356 = datas349:get_Item(i353)
            local data__TargetCount, data__Damage354, data__RadiantDmgAmp, data__Duration355 = __unpack_tmp356.TargetCount, __unpack_tmp356.Damage, __unpack_tmp356.RadiantDmgAmp, __unpack_tmp356.Duration
            SF__.Utils.ExBlzSetAbilityTooltip(p348, SF__.DivineToll.ID, SF__.StrConcat__("圣洁鸣钟 - [|cffffcc00", (i353 + 1), "级|r]"), i353)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p348, SF__.DivineToll.ID, SF__.StrConcat__("对附近的最多|cffff8c00", data__TargetCount, "|r个目标施展审判，造成|cffff8c00", data__Damage354, "|r点法术伤害，然后神圣之锤环绕圣殿骑士，每次命中敌人使其受到的光辉伤害提高|cffff8c00", string.format("%.0f", (data__RadiantDmgAmp * 100)), "%|r，持续|cffff8c00", data__Duration355, "|r秒。每个审判产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 30秒"), i353)
            ::continue::
            i353 = (i353 + 1)
        end
    end
end

function SF__.DivineToll.HurlToTarget(caster357, target358, pos__x359, pos__y360, pos__z361)
    local outer = SF__.GameObject.New__s("DivineToll_Outer")
    local EventCenter365 = require("Lib.EventCenter")
    outer.transform.localPosition__x, outer.transform.localPosition__y, outer.transform.localPosition__z = 0, 0, 80
    local moveLayer = SF__.GameObject.New__sx13("MoveLayer", outer)
    moveLayer.transform.localPosition__x, moveLayer.transform.localPosition__y, moveLayer.transform.localPosition__z = pos__x359, pos__y360, pos__z361
    local mis = moveLayer:AddComponent(SF__.Missile)
    mis.targetType = SF__.TargetType.Unit
    mis.unitTarget = target358
    mis.speed = 900
    mis.lookAtTarget = true
    mis.colliderSize = 32
    mis.onCollision = function()
        local cPos__x, cPos__y, cPos__z = mis.gameObject.transform:get_position()
        local eff362 = ExAddSpecialEffect("Abilities/Spells/Human/StormBolt/StormBoltMissile.mdl", cPos__x, cPos__y, 0.1)
        BlzSetSpecialEffectColor(eff362, 255, 255, 0)
        local ad__TargetCount, ad__Damage363, ad__RadiantDmgAmp, ad__Duration364 = SF__.DivineToll.GetAbilityData(GetUnitAbilityLevel(caster357, SF__.DivineToll.ID))
        EventCenter365.Damage:Emit({whichUnit = caster357, target = target358, amount = ad__Damage363, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
        SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(caster357, 1)
        moveLayer:RemoveAllComponents(SF__.Missile)
        local aec1 = moveLayer.transform:Find("DivineToll_Bolt/dt_hand/dt_mis").gameObject:GetComponent(SF__.AttachEffectComponent)
        aec1:LerpIn(1300)
        local aec2 = aec1.gameObject.transform:Find("DivineToll_Holy").gameObject:GetComponent(SF__.AttachEffectComponent)
        aec2:LerpIn(1300)
        local casterPos__x, casterPos__y, casterPos__z = SF__.Vector3.FromUnit(caster357)
        local circulator = SF__.GameObject.New__sx13("Circulator", outer)
        circulator.transform.localPosition__x, circulator.transform.localPosition__y, circulator.transform.localPosition__z = casterPos__x, casterPos__y, casterPos__z
        local rot = circulator:AddComponent(SF__.AutoTRSComponent)
        rot.rotation__x, rot.rotation__y, rot.rotation__z, rot.rotation__w = SF__.Quaternion.Euler(0, ((300 * SF__.Scene.DT) / 1000), 0)
        rot.followUnit = caster357
        moveLayer.transform:SetParent(circulator.transform)
        moveLayer.transform.localPosition__x, moveLayer.transform.localPosition__y, moveLayer.transform.localPosition__z = 200, 0, 0
    end
    local orientationFixLayer = SF__.GameObject.New__sx13("DivineToll_Bolt", moveLayer)
    orientationFixLayer.transform.localRotation__x, orientationFixLayer.transform.localRotation__y, orientationFixLayer.transform.localRotation__z, orientationFixLayer.transform.localRotation__w = SF__.Quaternion.Euler(0, 90, 0)
    local selfRotLayer = SF__.GameObject.New__sx13("dt_hand", orientationFixLayer)
    local receiver = selfRotLayer:AddComponent(SF__.AutoTRSComponent)
    receiver.rotation__x, receiver.rotation__y, receiver.rotation__z, receiver.rotation__w = SF__.Quaternion.Euler(((1800 * SF__.Scene.DT) / 1000), 0, 0)
    local boltMis = SF__.GameObject.New__sx13("dt_mis", selfRotLayer)
    boltMis.transform.localPosition__x, boltMis.transform.localPosition__y, boltMis.transform.localPosition__z = 15, 0, 0
    boltMis.transform.localScale__x, boltMis.transform.localScale__y, boltMis.transform.localScale__z = 0.5, 0.5, 0.5
    local eff366 = AddSpecialEffect("Abilities/Spells/Human/StormBolt/StormBoltMissile.mdl", pos__x359, pos__y360)
    boltMis:AddComponent(SF__.AttachEffectComponent):AttachEffect(eff366)
    local attachedHoly = SF__.GameObject.New__sx13("DivineToll_Holy", boltMis)
    attachedHoly.transform.localPosition__x, attachedHoly.transform.localPosition__y, attachedHoly.transform.localPosition__z = 15, 0, 0
    local effHoly = AddSpecialEffect("Abilities/Weapons/FaerieDragonMissile/FaerieDragonMissile.mdl", pos__x359, pos__y360)
    attachedHoly:AddComponent(SF__.AttachEffectComponent):AttachEffect(effHoly)
    BlzSetSpecialEffectColor(effHoly, 20, 20, 20)
end

function SF__.DivineToll.Start(data367)
    return SF__.CorRun__(function()
        local pos__x368, pos__y369, pos__z370 = SF__.Vector3.FromUnit(data367.caster)
        local targets = SF__.Utils.CsGroupGetUnitsInRange(pos__x368, pos__y369, 600, function(u371)
            if (not IsUnitEnemy(u371, GetOwningPlayer(data367.caster))) then
                return false
            end
            if IsUnitType(u371, UNIT_TYPE_STRUCTURE) then
                return false
            end
            if ExIsUnitDead(u371) then
                return false
            end
            return true
        end)
        if (targets.Count == 0) then
            return
        end
        targets:Sort(function(a374, b375)
            local distA376 = SF__.Vector3.Distance(pos__x368, pos__y369, pos__z370, SF__.Vector3.FromUnit(a374))
            local distB377 = SF__.Vector3.Distance(pos__x368, pos__y369, pos__z370, SF__.Vector3.FromUnit(b375))
            return (function() if (distA376 == distB377) then return 0 else return (function() if (distA376 < distB377) then return (-1) else return 1 end end)() end end)()
        end)
        do
            local i378 = 0
            while (i378 < (function()
                local field__TargetCount, field__Damage, field__RadiantDmgAmp, field__Duration = SF__.DivineToll.GetAbilityData(GetUnitAbilityLevel(data367.caster, SF__.DivineToll.ID))
                return math.min(targets.Count, field__TargetCount)
            end)()) do
                SF__.DivineToll.HurlToTarget(data367.caster, targets:get_Item(i378), pos__x368, pos__y369, pos__z370)
                SF__.CorWait__(200)
                ::continue::
                i378 = (i378 + 1)
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

function SF__.Easing.OutQubic(t60)
    return (1 - ((1 - t60) ^ 3))
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
function SF__.TemplarStrikes.GetAbilityData(level387)
    return 2, (0.5 + (0.25 * level387)), (0.05 * level387)
end

function SF__.TemplarStrikes.Init()
    local EventCenter388 = require("Lib.EventCenter")
    EventCenter388.RegisterPlayerUnitSpellEffect:Emit({id = SF__.TemplarStrikes.ID, handler = SF__.TemplarStrikes.Start})
    ExTriggerRegisterNewUnit(function(u390)
        if (GetUnitTypeId(u390) == FourCC("Hpal")) then
            SF__.TemplarStrikes.UpdateAbilityMeta(u390)
            SetHeroLevel(u390, 10, true)
        end
    end)
    EventCenter388.RegisterPlayerUnitDamaged:Emit(function(caster394, target395, damage396, weapType397, dmgType398, isAttack399)
        if (GetUnitAbilityLevel(caster394, SF__.TemplarStrikes.ID) <= 0) then
            return
        end
        if (not isAttack399) then
            return
        end
        if (target395 == nil) then
            return
        end
        if ExIsUnitDead(target395) then
            return
        end
        SF__.TemplarStrikes.TryResetBOJ(caster394)
    end)
end

function SF__.TemplarStrikes.TryResetBOJ(caster400)
    local level401 = GetUnitAbilityLevel(caster400, SF__.TemplarStrikes.ID)
    local ad__AttackCount, ad__DamageScaling402, ad__ResetBOJChance = SF__.TemplarStrikes.GetAbilityData(level401)
    if (math.random() >= ad__ResetBOJChance) then
        return
    end
    BlzEndUnitAbilityCooldown(caster400, SF__.BladeOfJustice.ID)
    ExAddSpecialEffectTarget("Abilities/Spells/Items/AIam/AIamTarget.mdl", caster400, "origin", 0.3)
end

function SF__.TemplarStrikes.UpdateAbilityMeta(u403)
    local p404 = GetOwningPlayer(u403)
    local datas405 = SF__.StdLib.List.New__0()
    do
        local i406 = 0
        while (i406 < SF__.TemplarStrikes.MaxLevel) do
            local __pack_AttackCount, __pack_DamageScaling407, __pack_ResetBOJChance = SF__.TemplarStrikes.GetAbilityData((i406 + 1))
            datas405:Add({AttackCount = __pack_AttackCount, DamageScaling = __pack_DamageScaling407, ResetBOJChance = __pack_ResetBOJChance})
            ::continue::
            i406 = (i406 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p404, SF__.TemplarStrikes.ID, "学习圣殿骑士之击 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p404, SF__.TemplarStrikes.ID, SF__.StrConcat__("快速攻击目标|cffff8c00", datas405:get_Item(0).AttackCount, "|r次，第一次造成普通攻击伤害，第二次造成光辉伤害，有一定几率重置公正之剑的冷却时间，普通攻击也会触发。\n\n|cff99ccff冷却时间|r - 10秒\n\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas405:get_Item(0).DamageScaling * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas405:get_Item(0).ResetBOJChance * 100)), "%|r的几率重置公正之剑。\n|cffffcc002级|r - |cffff8c00", string.format("%.0f", (datas405:get_Item(1).DamageScaling * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas405:get_Item(1).ResetBOJChance * 100)), "%|r的几率重置公正之剑。\n|cffffcc003级|r - |cffff8c00", string.format("%.0f", (datas405:get_Item(2).DamageScaling * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas405:get_Item(2).ResetBOJChance * 100)), "%|r的几率重置公正之剑。"), 0)
    do
        local i408 = 0
        while (i408 < SF__.TemplarStrikes.MaxLevel) do
            local __unpack_tmp410 = datas405:get_Item(i408)
            local data__AttackCount, data__DamageScaling409, data__ResetBOJChance = __unpack_tmp410.AttackCount, __unpack_tmp410.DamageScaling, __unpack_tmp410.ResetBOJChance
            SF__.Utils.ExBlzSetAbilityTooltip(p404, SF__.TemplarStrikes.ID, SF__.StrConcat__("圣殿骑士之击 - [|cffffcc00", (i408 + 1), "级|r]"), i408)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p404, SF__.TemplarStrikes.ID, SF__.StrConcat__("快速攻击目标|cffff8c00", data__AttackCount, "|r次，第一次造成普通攻击伤害，第二次造成普通攻击|cffff8c00", string.format("%.0f", (data__DamageScaling409 * 100)), "%|r的光辉伤害，|cffff8c00", string.format("%.0f", (data__ResetBOJChance * 100)), "%|r几率重置公正之剑的冷却时间，普通攻击也会触发。\n\n|cff99ccff冷却时间|r - 10秒"), i408)
            ::continue::
            i408 = (i408 + 1)
        end
    end
end

function SF__.TemplarStrikes.Start(data411)
    return SF__.CorRun__(function()
        local level412 = GetUnitAbilityLevel(data411.caster, SF__.TemplarStrikes.ID)
        local UnitAttribute414 = require("Objects.UnitAttribute")
        local EventCenter415 = require("Lib.EventCenter")
        local attr413 = UnitAttribute414.GetAttr(data411.caster)
        local normalDamage = attr413:SimMeleeAttack()
        EventCenter415.Damage:Emit({whichUnit = data411.caster, target = data411.target, amount = normalDamage, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
        SF__.TemplarStrikes.TryResetBOJ(data411.caster)
        SetUnitTimeScale(data411.caster, 3)
        ResetUnitAnimation(data411.caster)
        SetUnitAnimation(data411.caster, "attack - 2")
        SF__.CorWait__(math.round(((1.166 * 0.33) * 1000)))
        local tarAttr416 = UnitAttribute414.GetAttr(data411.target)
        local ad__AttackCount417, ad__DamageScaling418, ad__ResetBOJChance419 = SF__.TemplarStrikes.GetAbilityData(level412)
        local radiantDamage = ((attr413:SimMeleeAttack() * ad__DamageScaling418) * (1 - tarAttr416.radiantResistance))
        EventCenter415.Damage:Emit({whichUnit = data411.caster, target = data411.target, amount = radiantDamage, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
        SF__.TemplarStrikes.TryResetBOJ(data411.caster)
        SetUnitTimeScale(data411.caster, 1)
        ResetUnitAnimation(data411.caster)
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
    local EventCenter442 = require("Lib.EventCenter")
    EventCenter442.RegisterPlayerUnitSpellChannel:Emit({id = SF__.WordOfGlory.ID, handler = SF__.WordOfGlory.Check})
    EventCenter442.RegisterPlayerUnitSpellEffect:Emit({id = SF__.WordOfGlory.ID, handler = SF__.WordOfGlory.Start})
    ExTriggerRegisterNewUnit(function(u444)
        if (GetUnitTypeId(u444) == FourCC("Hpal")) then
            SF__.WordOfGlory.UpdateAbilityMeta(u444)
        end
    end)
end

function SF__.WordOfGlory.Check(data445)
    local UnitAttribute447 = require("Objects.UnitAttribute")
    local attr446 = UnitAttribute447.GetAttr(data445.caster)
    if (attr446.retPalHolyEnergy < 3) then
        IssueImmediateOrderById(data445.caster, SF__.ConstOrderId.Stop)
        ExTextState(data445.caster, "圣能不足")
    end
end

function SF__.WordOfGlory.UpdateAbilityMeta(u448)
    local p449 = GetOwningPlayer(u448)
    SF__.Utils.ExSetAbilityResearchTooltip(p449, SF__.WordOfGlory.ID, "学习圣殿骑士的裁决 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p449, SF__.WordOfGlory.ID, "圣殿骑士的裁决造成一次攻击伤害，如果目标被审判，造成30%的额外伤害，15%几率重置审判。消耗|cffff8c003|r点圣能。\n\n|cff99ccff冷却时间|r - 5秒\n\n|cffffcc001级|r - |cffff8c00100%|r的攻击伤害，100%的战争艺术触发几率。", 0)
    do
        local i450 = 0
        while (i450 < 1) do
            SF__.Utils.ExBlzSetAbilityTooltip(p449, SF__.WordOfGlory.ID, SF__.StrConcat__("圣殿骑士的裁决 - [|cffffcc00", (i450 + 1), "级|r]"), i450)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p449, SF__.WordOfGlory.ID, "圣殿骑士的裁决造成一次攻击伤害，造成|cffff8c00100%|r的攻击伤害。消耗|cffff8c003|r点圣能。\n\n|cff99ccff冷却时间|r - 5秒", i450)
            ::continue::
            i450 = (i450 + 1)
        end
    end
end

function SF__.WordOfGlory.Start(data451)
    local UnitAttribute453 = require("Objects.UnitAttribute")
    local EventCenter454 = require("Lib.EventCenter")
    local attr452 = UnitAttribute453.GetAttr(data451.caster)
    EventCenter454.Heal:Emit({caster = data451.caster, target = data451.target, amount = 300})
    attr452.retPalHolyEnergy = (attr452.retPalHolyEnergy - 3)
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
local SystemBase35 = require("System.SystemBase")
SF__.Systems.InspectorSystem = SF__.Systems.InspectorSystem or class("InspectorSystem", SystemBase35)
SF__.Systems.InspectorSystem.Name = "InspectorSystem"
SF__.Systems.InspectorSystem.FullName = "Systems.InspectorSystem"
SF__.Systems.InspectorSystem.__sf_base = SystemBase35
function SF__.Systems.InspectorSystem:Awake()
    self:CreateFrames()
    self:RefreshHierarchy()
    self:SelectFirstVisibleObject()
    self:SetPanelVisible(false)
end

function SF__.Systems.InspectorSystem:Update(dt36)
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
        local i37 = 0
        while (i37 < SF__.Systems.InspectorSystem.MaxHierarchyRows) do
            self._hierarchyRows:Add(self:CreateHierarchyRow(i37))
            ::continue::
            i37 = (i37 + 1)
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

function SF__.Systems.InspectorSystem:CreateHierarchyRow(index38)
    local y39 = ((-0.061) - (index38 * (SF__.Systems.InspectorSystem.RowHeight + SF__.Systems.InspectorSystem.RowGap)))
    local button = BlzCreateFrameByType("BUTTON", "FdfInspectorHierarchyRow", self._panel, "ScoreScreenTabButtonTemplate", index38)
    BlzFrameSetPoint(button, FRAMEPOINT_TOPLEFT, self._panel, FRAMEPOINT_TOPLEFT, (SF__.Systems.InspectorSystem.Padding * 2), y39)
    BlzFrameSetSize(button, (SF__.Systems.InspectorSystem.LeftWidth - (SF__.Systems.InspectorSystem.Padding * 4)), SF__.Systems.InspectorSystem.RowHeight)
    local label40 = BlzCreateFrameByType("TEXT", "FdfInspectorHierarchyRowText", button, "", index38)
    BlzFrameSetPoint(label40, FRAMEPOINT_TOPLEFT, button, FRAMEPOINT_TOPLEFT, 0.004, (-0.002))
    BlzFrameSetSize(label40, (SF__.Systems.InspectorSystem.LeftWidth - (SF__.Systems.InspectorSystem.Padding * 5)), (SF__.Systems.InspectorSystem.RowHeight - 0.003))
    BlzFrameSetEnable(label40, false)
    BlzFrameSetTextAlignment(label40, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_LEFT)
    BlzFrameSetText(label40, "")
    local row = SF__.Systems.InspectorSystem.HierarchyRow.New(button, label40)
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

function SF__.Systems.InspectorSystem:SelectRow(row41)
    if (row41.gameObject == nil) then
        return
    end
    self._selectedGameObject = row41.gameObject
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
        for _, obj42 in (SF__.StdLib.List.IpairsNext)(collection10) do
            if (obj42.transform.parent == nil) then
                self:AddHierarchyObject(obj42, 0)
            end
        end
    end
    do
        local i43 = 0
        while (i43 < self._hierarchyRows.Count) do
            local row44 = self._hierarchyRows:get_Item(i43)
            if (i43 < self._visibleObjects.Count) then
                local obj45 = self._visibleObjects:get_Item(i43)
                row44.gameObject = obj45
                row44.depth = self:GetDepth(obj45)
                self:SetRowLabel(row44, obj45.name, row44.depth)
                BlzFrameSetVisible(row44.button, self._isVisible)
            else
                row44.gameObject = nil
                BlzFrameSetVisible(row44.button, false)
            end
            ::continue::
            i43 = (i43 + 1)
        end
    end
    BlzFrameSetVisible(self._emptyText, (self._isVisible and (self._visibleObjects.Count == 0)))
    self._lastObjectCount = SF__.Scene.get_Instance().gameObjs.Count
    self:RefreshHierarchySelection()
end

function SF__.Systems.InspectorSystem:AddHierarchyObject(obj46, depth)
    if (self._visibleObjects.Count >= SF__.Systems.InspectorSystem.MaxHierarchyRows) then
        return
    end
    self._visibleObjects:Add(obj46)
    do
        local collection11 = obj46.transform.children
        for _, child47 in (SF__.StdLib.List.IpairsNext)(collection11) do
            self:AddHierarchyObject(child47.gameObject, (depth + 1))
        end
    end
end

function SF__.Systems.InspectorSystem:GetDepth(obj48)
    local depth49 = 0
    local parent50 = obj48.transform.parent
    while (parent50 ~= nil) do
        depth49 = (depth49 + 1)
        parent50 = parent50.parent
        ::continue::
    end
    return depth49
end

function SF__.Systems.InspectorSystem:SetRowLabel(row51, text52, depth53)
    BlzFrameClearAllPoints(row51.label)
    BlzFrameSetPoint(row51.label, FRAMEPOINT_TOPLEFT, row51.button, FRAMEPOINT_TOPLEFT, (0.004 + (depth53 * SF__.Systems.InspectorSystem.IndentWidth)), (-0.002))
    BlzFrameSetSize(row51.label, ((SF__.Systems.InspectorSystem.LeftWidth - (SF__.Systems.InspectorSystem.Padding * 5)) - (depth53 * SF__.Systems.InspectorSystem.IndentWidth)), (SF__.Systems.InspectorSystem.RowHeight - 0.003))
    BlzFrameSetText(row51.label, text52)
end

function SF__.Systems.InspectorSystem:RefreshHierarchySelection()
    do
        local collection12 = self._hierarchyRows
        for _, row54 in (SF__.StdLib.List.IpairsNext)(collection12) do
            local isSelected = ((row54.gameObject ~= nil) and (row54.gameObject == self._selectedGameObject))
            BlzFrameSetTextColor(row54.label, (function() if isSelected then return BlzConvertColor(255, 255, 220, 80) else return BlzConvertColor(255, 230, 230, 230) end end)())
        end
    end
end

function SF__.Systems.InspectorSystem:RefreshInspectorText()
    if (self._selectedGameObject == nil) then
        BlzFrameSetText(self._inspectorText, "")
        return
    end
    local text55 = SF__.StrConcat__(self._selectedGameObject.name, "\n")
    do
        local collection13 = self._selectedGameObject:get_components()
        for _, component in (SF__.StdLib.List.IpairsNext)(collection13) do
            text55 = SF__.StrConcat__(text55, "\n[", component.__sf_type.Name, "]")
            local inspectorText = component:GetInspectorText()
            if (inspectorText ~= "") then
                text55 = SF__.StrConcat__(text55, "\n", inspectorText)
            end
        end
    end
    BlzFrameSetText(self._inspectorText, text55)
end

function SF__.Systems.InspectorSystem:SceneContains(gameObject)
    do
        local collection14 = SF__.Scene.get_Instance().gameObjs
        for _, obj56 in (SF__.StdLib.List.IpairsNext)(collection14) do
            if (obj56 == gameObject) then
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
function SF__.Systems.InspectorSystem.HierarchyRow.__Init(self, button57, label58)
    self.__sf_type = SF__.Systems.InspectorSystem.HierarchyRow
    self.button = nil
    self.label = nil
    self.gameObject = nil
    self.depth = 0
    self.button = button57
    self.label = label58
end

function SF__.Systems.InspectorSystem.HierarchyRow.New(button57, label58)
    local self = setmetatable({}, { __index = SF__.Systems.InspectorSystem.HierarchyRow })
    SF__.Systems.InspectorSystem.HierarchyRow.__Init(self, button57, label58)
    return self
end
-- Systems.MeleeGameSystem
local SystemBase59 = require("System.SystemBase")
SF__.Systems.MeleeGameSystem = SF__.Systems.MeleeGameSystem or class("MeleeGameSystem", SystemBase59)
SF__.Systems.MeleeGameSystem.Name = "MeleeGameSystem"
SF__.Systems.MeleeGameSystem.FullName = "Systems.MeleeGameSystem"
SF__.Systems.MeleeGameSystem.__sf_base = SystemBase59
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
    local item103 = self._items:get_Item((self._items.Count - 1))
    self._items:RemoveAt((self._items.Count - 1))
    return item103
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
function SF__.TemplarVerdict.GetAbilityData(level420)
    return 2.25, 0.3, 0.15
end

function SF__.TemplarVerdict.Init()
    local EventCenter421 = require("Lib.EventCenter")
    EventCenter421.RegisterPlayerUnitSpellChannel:Emit({id = SF__.TemplarVerdict.ID, handler = SF__.TemplarVerdict.Check})
    EventCenter421.RegisterPlayerUnitSpellEffect:Emit({id = SF__.TemplarVerdict.ID, handler = SF__.TemplarVerdict.Start})
    ExTriggerRegisterNewUnit(function(u423)
        if (GetUnitTypeId(u423) == FourCC("Hpal")) then
            SF__.TemplarVerdict.UpdateAbilityMeta(u423)
        end
    end)
end

function SF__.TemplarVerdict.Check(data424)
    local UnitAttribute426 = require("Objects.UnitAttribute")
    local attr425 = UnitAttribute426.GetAttr(data424.caster)
    if (attr425.retPalHolyEnergy < 3) then
        IssueImmediateOrderById(data424.caster, SF__.ConstOrderId.Stop)
        ExTextState(data424.caster, "圣能不足")
    end
end

function SF__.TemplarVerdict.UpdateAbilityMeta(u427)
    local p428 = GetOwningPlayer(u427)
    local datas429 = SF__.StdLib.List.New__0()
    do
        local i430 = 0
        while (i430 < 1) do
            local __pack_DamageScaling431, __pack_JudgementDamageScaling, __pack_ChanceToResetJudgement = SF__.TemplarVerdict.GetAbilityData((i430 + 1))
            datas429:Add({DamageScaling = __pack_DamageScaling431, JudgementDamageScaling = __pack_JudgementDamageScaling, ChanceToResetJudgement = __pack_ChanceToResetJudgement})
            ::continue::
            i430 = (i430 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p428, SF__.TemplarVerdict.ID, "学习圣殿骑士的裁决 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p428, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决造成一次攻击伤害，如果目标被审判，造成30%的额外伤害，15%几率重置审判。消耗|cffff8c003|r点圣能。\n\n|cff99ccff冷却时间|r - 5秒\n\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas429:get_Item(0).JudgementDamageScaling * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas429:get_Item(0).ChanceToResetJudgement * 100)), "%的战争艺术触发几率。"), 0)
    do
        local i432 = 0
        while (i432 < 1) do
            local __unpack_tmp434 = datas429:get_Item(i432)
            local data__DamageScaling433, data__JudgementDamageScaling, data__ChanceToResetJudgement = __unpack_tmp434.DamageScaling, __unpack_tmp434.JudgementDamageScaling, __unpack_tmp434.ChanceToResetJudgement
            SF__.Utils.ExBlzSetAbilityTooltip(p428, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决 - [|cffffcc00", (i432 + 1), "级|r]"), i432)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p428, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决造成一次攻击伤害，造成|cffff8c00", string.format("%.0f", (data__DamageScaling433 * 100)), "%|r的攻击伤害。消耗|cffff8c003|r点圣能。\n\n|cff99ccff冷却时间|r - 5秒"), i432)
            ::continue::
            i432 = (i432 + 1)
        end
    end
end

function SF__.TemplarVerdict.Start(data435)
    local level436 = GetUnitAbilityLevel(data435.caster, SF__.TemplarVerdict.ID)
    local UnitAttribute439 = require("Objects.UnitAttribute")
    local EventCenter441 = require("Lib.EventCenter")
    local ad__DamageScaling437, ad__JudgementDamageScaling, ad__ChanceToResetJudgement = SF__.TemplarVerdict.GetAbilityData(level436)
    local attr438 = UnitAttribute439.GetAttr(data435.caster)
    local damage440 = (attr438:SimAttack(UnitAttribute439.HeroAttributeType.Strength) * ad__DamageScaling437)
    EventCenter441.Damage:Emit({whichUnit = data435.caster, target = data435.target, amount = damage440, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_SLICE, outResult = {}})
    attr438.retPalHolyEnergy = (attr438.retPalHolyEnergy - 3)
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

function SF__.Vector2.Dot(a__x118, a__y119, b__x120, b__y121)
    return ((a__x118 * b__x120) + (a__y119 * b__y121))
end

function SF__.Vector2.Cross(a__x122, a__y123, b__x124, b__y125)
    return ((a__y123 * b__x124) - (a__x122 * b__y125))
end

function SF__.Vector2.op_UnaryNegation(a__x126, a__y127)
    return (-a__x126), (-a__y127)
end

function SF__.Vector2.op_Addition(a__x128, a__y129, b__x130, b__y131)
    return (a__x128 + b__x130), (a__y129 + b__y131)
end

function SF__.Vector2.op_Subtraction(a__x132, a__y133, b__x134, b__y135)
    return (a__x132 - b__x134), (a__y133 - b__y135)
end

function SF__.Vector2.op_Multiply__ahdf(v__x136, v__y137, f)
    return (v__x136 * f), (v__y137 * f)
end

function SF__.Vector2.op_Multiply__fahd(f138, v__x139, v__y140)
    return (v__x139 * f138), (v__y140 * f138)
end

function SF__.Vector2.op_Division(v__x141, v__y142, f143)
    return (v__x141 / f143), (v__y142 / f143)
end

function SF__.Vector2.UnitDistance(a, b)
    local v1__x, v1__y = SF__.Vector2.FromUnit(a)
    local v2__x, v2__y = SF__.Vector2.FromUnit(b)
    return SF__.Vector2.get_Magnitude(SF__.Vector2.op_Subtraction(v1__x, v1__y, v2__x, v2__y))
end

function SF__.Vector2.SqrUnitDistance(a144, b145)
    local v1__x146, v1__y147 = SF__.Vector2.FromUnit(a144)
    local v2__x148, v2__y149 = SF__.Vector2.FromUnit(b145)
    return SF__.Vector2.get_SqrMagnitude(SF__.Vector2.op_Subtraction(v1__x146, v1__y147, v2__x148, v2__y149))
end

function SF__.Vector2.FromUnit(u150)
    return GetUnitX(u150), GetUnitY(u150)
end

function SF__.Vector2.get_Magnitude(self__x151, self__y152)
    return math.sqrt(SF__.Vector2.get_SqrMagnitude(self__x151, self__y152))
end

function SF__.Vector2.get_SqrMagnitude(self__x153, self__y154)
    return ((self__x153 * self__x153) + (self__y154 * self__y154))
end

function SF__.Vector2.get_Normalized(self__x155, self__y156)
    local mag = SF__.Vector2.get_Magnitude(self__x155, self__y156)
    if (mag < 0.0001) then
        return SF__.Vector2.get_Zero()
    end
    return SF__.Vector2.op_Division(self__x155, self__y156, mag)
end

function SF__.Vector2.ClampMagnitude(self__x159, self__y160, mag161)
    return (function()
        local v__x162, v__y163 = SF__.Vector2.get_Normalized(self__x159, self__y160)
        return SF__.Vector2.op_Multiply__ahdf(v__x162, v__y163, mag161)
    end)()
end

function SF__.Vector2.ToString(self__x164, self__y165)
    return SF__.StrConcat__("(", self__x164, ", ", self__y165, ")")
end

function SF__.Vector2.Rotate(self__x166, self__y167, angle168)
    local cos = math.cos(angle168)
    local sin = math.sin(angle168)
    return ((self__x166 * cos) - (self__y167 * sin)), ((self__x166 * sin) + (self__y167 * cos))
end

function SF__.Vector2.UnitMoveTo(self__x169, self__y170, u171)
    SetUnitX(u171, self__x169)
    SetUnitY(u171, self__y170)
end

function SF__.Vector2.GetTerrainZ(self__x172, self__y173)
    MoveLocation(SF__.Vector2._loc, self__x172, self__y173)
    return GetLocationZ(SF__.Vector2._loc)
end

SF__.Vector2._loc = Location(0, 0)

SF__.Program.Main()
