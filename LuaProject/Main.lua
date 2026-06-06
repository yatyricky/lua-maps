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
SF__.TargetType.None = 2

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

function SF__.Vector3.op_Addition(a__x190, a__y191, a__z192, b__x193, b__y194, b__z195)
    return (a__x190 + b__x193), (a__y191 + b__y194), (a__z192 + b__z195)
end

function SF__.Vector3.op_UnaryNegation(a__x196, a__y197, a__z198)
    return (-a__x196), (-a__y197), (-a__z198)
end

function SF__.Vector3.op_Subtraction(a__x199, a__y200, a__z201, b__x202, b__y203, b__z204)
    return (a__x199 - b__x202), (a__y200 - b__y203), (a__z201 - b__z204)
end

function SF__.Vector3.op_Multiply__osef(v__x205, v__y206, v__z207, f208)
    return (v__x205 * f208), (v__y206 * f208), (v__z207 * f208)
end

function SF__.Vector3.op_Multiply__fose(f209, v__x210, v__y211, v__z212)
    return (v__x210 * f209), (v__y211 * f209), (v__z212 * f209)
end

function SF__.Vector3.op_Division(v__x213, v__y214, v__z215, f216)
    return (v__x213 / f216), (v__y214 / f216), (v__z215 / f216)
end

-- <summary>
-- Warcraft III world space here is right-handed: +x points right, +y points away, +z points up.
-- That means Cross((1,0,0), (0,1,0)) == (0,0,1).
-- </summary>
--
function SF__.Vector3.Cross(a__x217, a__y218, a__z219, b__x220, b__y221, b__z222)
    return ((a__y218 * b__z222) - (a__z219 * b__y221)), ((a__z219 * b__x220) - (a__x217 * b__z222)), ((a__x217 * b__y221) - (a__y218 * b__x220))
end

function SF__.Vector3.Distance(a__x223, a__y224, a__z225, b__x226, b__y227, b__z228)
    return SF__.Vector3.get_magnitude(SF__.Vector3.op_Subtraction(a__x223, a__y224, a__z225, b__x226, b__y227, b__z228))
end

function SF__.Vector3.Dot(a__x229, a__y230, a__z231, b__x232, b__y233, b__z234)
    return (((a__x229 * b__x232) + (a__y230 * b__y233)) + (a__z231 * b__z234))
end

function SF__.Vector3.Lerp(a__x235, a__y236, a__z237, b__x238, b__y239, b__z240, t241)
    t241 = math.clamp01(t241)
    return SF__.Vector3.op_Addition(a__x235, a__y236, a__z237, (function()
        local v__x242, v__y243, v__z244 = SF__.Vector3.op_Subtraction(b__x238, b__y239, b__z240, a__x235, a__y236, a__z237)
        return SF__.Vector3.op_Multiply__osef(v__x242, v__y243, v__z244, t241)
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

function SF__.Vector3.Project(v__x245, v__y246, v__z247, onNormal__x, onNormal__y, onNormal__z)
    local sqrMag = SF__.Vector3.Dot(onNormal__x, onNormal__y, onNormal__z, onNormal__x, onNormal__y, onNormal__z)
    if (sqrMag < 0.0001) then
        return SF__.Vector3.get_zero()
    end
    local dot = SF__.Vector3.Dot(v__x245, v__y246, v__z247, onNormal__x, onNormal__y, onNormal__z)
    return SF__.Vector3.op_Multiply__osef(onNormal__x, onNormal__y, onNormal__z, (dot / sqrMag))
end

function SF__.Vector3.ProjectOnPlane(v__x248, v__y249, v__z250, planeNormal__x, planeNormal__y, planeNormal__z)
    return SF__.Vector3.op_Subtraction(v__x248, v__y249, v__z250, SF__.Vector3.Project(v__x248, v__y249, v__z250, planeNormal__x, planeNormal__y, planeNormal__z))
end

function SF__.Vector3.Reflect(inDirection__x, inDirection__y, inDirection__z, inNormal__x, inNormal__y, inNormal__z)
    return SF__.Vector3.op_Subtraction(inDirection__x, inDirection__y, inDirection__z, SF__.Vector3.op_Multiply__fose((2 * SF__.Vector3.Dot(inDirection__x, inDirection__y, inDirection__z, inNormal__x, inNormal__y, inNormal__z)), inNormal__x, inNormal__y, inNormal__z))
end

function SF__.Vector3.RotateTowards(current__x251, current__y252, current__z253, target__x254, target__y255, target__z256, maxRadiansDelta, maxMagnitudeDelta)
    local currentMag = SF__.Vector3.get_magnitude(current__x251, current__y252, current__z253)
    local targetMag = SF__.Vector3.get_magnitude(target__x254, target__y255, target__z256)
    if ((currentMag == 0) or (targetMag == 0)) then
        return SF__.Vector3.MoveTowards(current__x251, current__y252, current__z253, target__x254, target__y255, target__z256, maxMagnitudeDelta)
    end
    local currentNorm__x, currentNorm__y, currentNorm__z = SF__.Vector3.op_Division(current__x251, current__y252, current__z253, currentMag)
    local targetNorm__x, targetNorm__y, targetNorm__z = SF__.Vector3.op_Division(target__x254, target__y255, target__z256, targetMag)
    local dot257 = math.clamp(SF__.Vector3.Dot(currentNorm__x, currentNorm__y, currentNorm__z, targetNorm__x, targetNorm__y, targetNorm__z), (-1), 1)
    local angle258 = math.acos(dot257)
    if (angle258 == 0) then
        return SF__.Vector3.MoveTowards(current__x251, current__y252, current__z253, target__x254, target__y255, target__z256, maxMagnitudeDelta)
    end
    local t259 = math.min(1, (maxRadiansDelta / angle258))
    local newDir__x, newDir__y, newDir__z = SF__.Vector3.Slerp(currentNorm__x, currentNorm__y, currentNorm__z, targetNorm__x, targetNorm__y, targetNorm__z, t259)
    local newMag = math.moveTowards(currentMag, targetMag, maxMagnitudeDelta)
    return SF__.Vector3.op_Multiply__osef(newDir__x, newDir__y, newDir__z, newMag)
end

function SF__.Vector3.Scale(a__x260, a__y261, a__z262, b__x263, b__y264, b__z265)
    return (a__x260 * b__x263), (a__y261 * b__y264), (a__z262 * b__z265)
end

function SF__.Vector3.Slerp(a__x266, a__y267, a__z268, b__x269, b__y270, b__z271, t272)
    local magA = SF__.Vector3.get_magnitude(a__x266, a__y267, a__z268)
    local magB = SF__.Vector3.get_magnitude(b__x269, b__y270, b__z271)
    if ((magA == 0) or (magB == 0)) then
        return SF__.Vector3.MoveTowards(a__x266, a__y267, a__z268, b__x269, b__y270, b__z271, math.huge)
    end
    local normA__x, normA__y, normA__z = SF__.Vector3.op_Division(a__x266, a__y267, a__z268, magA)
    local normB__x, normB__y, normB__z = SF__.Vector3.op_Division(b__x269, b__y270, b__z271, magB)
    local dot273 = math.clamp(SF__.Vector3.Dot(normA__x, normA__y, normA__z, normB__x, normB__y, normB__z), (-1), 1)
    local angle274 = math.acos(dot273)
    local sinAngle = math.sin(angle274)
    if (sinAngle < 0.0001) then
        return SF__.Vector3.MoveTowards(a__x266, a__y267, a__z268, b__x269, b__y270, b__z271, math.huge)
    end
    local tAngle = (angle274 * t272)
    local sinTA = math.sin(tAngle)
    local sinTOneMinusA = math.sin((angle274 - tAngle))
    local newDir__x281, newDir__y282, newDir__z283 = (function()
        local v__x278, v__y279, v__z280 = (function()
            local a__x275, a__y276, a__z277 = SF__.Vector3.op_Multiply__osef(normA__x, normA__y, normA__z, sinTOneMinusA)
            return SF__.Vector3.op_Addition(a__x275, a__y276, a__z277, SF__.Vector3.op_Multiply__osef(normB__x, normB__y, normB__z, sinTA))
        end)()
        return SF__.Vector3.op_Division(v__x278, v__y279, v__z280, sinAngle)
    end)()
    local newMag284 = math.lerp(magA, magB, t272)
    return SF__.Vector3.op_Multiply__osef(newDir__x281, newDir__y282, newDir__z283, newMag284)
end

function SF__.Vector3._getTerrainZ(x285, y286)
    MoveLocation(SF__.Vector3._loc, x285, y286)
    return GetLocationZ(SF__.Vector3._loc)
end

function SF__.Vector3.FromUnit(u287)
    local x288 = GetUnitX(u287)
    local y289 = GetUnitY(u287)
    return x288, y289, (SF__.Vector3._getTerrainZ(x288, y289) + GetUnitFlyHeight(u287))
end

function SF__.Vector3.get_sqrMagnitude(self__x290, self__y291, self__z292)
    return (((self__x290 * self__x290) + (self__y291 * self__y291)) + (self__z292 * self__z292))
end

function SF__.Vector3.get_magnitude(self__x293, self__y294, self__z295)
    return math.sqrt(SF__.Vector3.get_sqrMagnitude(self__x293, self__y294, self__z295))
end

function SF__.Vector3.get_normalized(self__x296, self__y297, self__z298)
    local mag299 = SF__.Vector3.get_magnitude(self__x296, self__y297, self__z298)
    if (mag299 < 0.0001) then
        return SF__.Vector3.get_zero()
    end
    return SF__.Vector3.op_Division(self__x296, self__y297, self__z298, mag299)
end

function SF__.Vector3.ClampMagnitude(self__x303, self__y304, self__z305, mag306)
    return (function()
        local v__x307, v__y308, v__z309 = SF__.Vector3.get_normalized(self__x303, self__y304, self__z305)
        return SF__.Vector3.op_Multiply__osef(v__x307, v__y308, v__z309, mag306)
    end)()
end

function SF__.Vector3.ToString(self__x310, self__y311, self__z312)
    return SF__.StrConcat__("(", self__x310, ", ", self__y311, ", ", self__z312, ")")
end

function SF__.Vector3.UnitMoveTo(self__x313, self__y314, self__z315, u316, mode)
    if mode == nil then mode = SF__.UnitVec3Mode.Auto end
    local tz = SF__.Vector3._getTerrainZ(self__x313, self__y314)
    local LuaUtils = require("Lib.Utils")
    local defaultFlyHeight = GetUnitDefaultFlyHeight(u316)
    local minZ = (tz + defaultFlyHeight)
    SetUnitPosition(u316, self__x313, self__y314)
    repeat
        local switchValue = mode
        if (switchValue == SF__.UnitVec3Mode.ForceFlying) then
            LuaUtils.SetUnitFlyable(u316)
            SetUnitFlyHeight(u316, (math.max(minZ, self__z315) - minZ), 0)
            break
        elseif (switchValue == SF__.UnitVec3Mode.ForceGround) then
            SetUnitFlyHeight(u316, defaultFlyHeight, 0)
            break
        elseif (switchValue == SF__.UnitVec3Mode.Auto) then
            if IsUnitType(u316, UNIT_TYPE_FLYING) then
                SetUnitFlyHeight(u316, (math.max(minZ, self__z315) - minZ), 0)
            else
                SetUnitFlyHeight(u316, defaultFlyHeight, 0)
            end
            break
        end
    until true
end

function SF__.Vector3.GetTerrainZ(self__x317, self__y318, self__z319)
    return SF__.Vector3._getTerrainZ(self__x317, self__y318)
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

function SF__.Quaternion.op_Multiply__iyiose(q__x76, q__y77, q__z78, q__w79, v__x, v__y, v__z)
    -- https://en.wikipedia.org/wiki/Quaternions_and_spatial_rotation#Using_quaternion_as_rotations
    local u__x, u__y, u__z = q__x76, q__y77, q__z78
    local s = q__w79
    return (function()
        local a__x83, a__y84, a__z85 = (function()
            local a__x80, a__y81, a__z82 = SF__.Vector3.op_Multiply__fose((2 * SF__.Vector3.Dot(u__x, u__y, u__z, v__x, v__y, v__z)), u__x, u__y, u__z)
            return SF__.Vector3.op_Addition(a__x80, a__y81, a__z82, SF__.Vector3.op_Multiply__fose(((s * s) - SF__.Vector3.Dot(u__x, u__y, u__z, u__x, u__y, u__z)), v__x, v__y, v__z))
        end)()
        return SF__.Vector3.op_Addition(a__x83, a__y84, a__z85, SF__.Vector3.op_Multiply__fose((2 * s), SF__.Vector3.Cross(u__x, u__y, u__z, v__x, v__y, v__z)))
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
    local x86
    local y87
    local z
    local w
    local trace = ((m00 + m11) + m22)
    if (trace > 0) then
        local s88 = (math.sqrt((trace + 1)) * 2)
        w = (0.25 * s88)
        x86 = ((m21 - m12) / s88)
        y87 = ((m02 - m20) / s88)
        z = ((m10 - m01) / s88)
    elseif ((m00 > m11) and (m00 > m22)) then
        local s89 = (math.sqrt((((1 + m00) - m11) - m22)) * 2)
        w = ((m21 - m12) / s89)
        x86 = (0.25 * s89)
        y87 = ((m01 + m10) / s89)
        z = ((m02 + m20) / s89)
    else
        if (m11 > m22) then
            local s90 = (math.sqrt((((1 + m11) - m00) - m22)) * 2)
            w = ((m02 - m20) / s90)
            x86 = ((m01 + m10) / s90)
            y87 = (0.25 * s90)
            z = ((m12 + m21) / s90)
        else
            local s91 = (math.sqrt((((1 + m22) - m00) - m11)) * 2)
            w = ((m10 - m01) / s91)
            x86 = ((m02 + m20) / s91)
            y87 = ((m12 + m21) / s91)
            z = (0.25 * s91)
        end
    end
    return SF__.Quaternion.Normalize(x86, y87, z, w)
end

function SF__.Quaternion.LookRotation__ose(forward__x92, forward__y93, forward__z94)
    return SF__.Quaternion.LookRotation__oseose(forward__x92, forward__y93, forward__z94, SF__.Vector3.get_up())
end

function SF__.Quaternion.Normalize(q__x95, q__y96, q__z97, q__w98)
    local magnitude = math.sqrt(((((q__x95 * q__x95) + (q__y96 * q__y96)) + (q__z97 * q__z97)) + (q__w98 * q__w98)))
    if (magnitude < 0.0001) then
        return SF__.Quaternion.get_identity()
    end
    return (q__x95 / magnitude), (q__y96 / magnitude), (q__z97 / magnitude), (q__w98 / magnitude)
end

function SF__.Quaternion.get_eulerAngles(self__x, self__y, self__z, self__w)
    -- https://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles#Source_Code_2
    local sinr_cosp = (2 * ((self__w * self__x) + (self__y * self__z)))
    local cosr_cosp = (1 - (2 * ((self__x * self__x) + (self__y * self__y))))
    local roll99 = math.atan(sinr_cosp, cosr_cosp)
    local sinp = (2 * ((self__w * self__y) - (self__z * self__x)))
    local pitch100
    if (math.abs(sinp) >= 1) then
        pitch100 = ((math.sign(sinp) * math.pi) / 2)
        -- use 90 degrees if out of range
    else
        pitch100 = math.asin(sinp)
    end
    local siny_cosp = (2 * ((self__w * self__z) + (self__x * self__y)))
    local cosy_cosp = (1 - (2 * ((self__y * self__y) + (self__z * self__z))))
    local yaw101 = math.atan(siny_cosp, cosy_cosp)
    return (pitch100 * bj_RADTODEG), (yaw101 * bj_RADTODEG), (roll99 * bj_RADTODEG)
end

function SF__.Quaternion.get_normalized(self__x102, self__y103, self__z104, self__w105)
    return SF__.Quaternion.Normalize(self__x102, self__y103, self__z104, self__w105)
end

function SF__.Quaternion.Inverse(rotation__x, rotation__y, rotation__z, rotation__w)
    return (-rotation__x), (-rotation__y), (-rotation__z), rotation__w
end

function SF__.Quaternion.ToString(self__x110, self__y111, self__z112, self__w113)
    return SF__.StrConcat__("(", self__x110, ", ", self__y111, ", ", self__z112, ", ", self__w113, ")")
end

function SF__.Quaternion.ApplyToEffect(self__x114, self__y115, self__z116, self__w117, e)
    local angles__x, angles__y, angles__z = SF__.Quaternion.get_eulerAngles(self__x114, self__y115, self__z116, self__w117)
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
        for _, item585 in (SF__.StdLib.List.IpairsNext)(collection1) do
            repeat
                table.insert(self._items, item585)
                self.Count = (self.Count + 1)
            until true
        end
    end
end

function SF__.StdLib.List.New__xqm20z(collection)
    local self = setmetatable({}, { __index = SF__.StdLib.List })
    SF__.StdLib.List.__Init__xqm20z(self, collection)
    return self
end

function SF__.StdLib.List:get_Item(index586)
    if ((index586 < 0) or (index586 >= self.Count)) then
        error(SF__.StrConcat__("SF__E2e5944b8", "Index out of range"))
    end
    return self._items[(index586 + 1)]
end

function SF__.StdLib.List:set_Item(index587, value588)
    if ((index587 < 0) or (index587 >= self.Count)) then
        error(SF__.StrConcat__("SF__E2e5944b8", "Index out of range"))
    end
    self._items[(index587 + 1)] = value588
end

function SF__.StdLib.List:AddRange(collection589)
    do
        local collection2 = collection589
        for _, item590 in (SF__.StdLib.List.IpairsNext)(collection2) do
            repeat
                table.insert(self._items, item590)
                self.Count = (self.Count + 1)
            until true
        end
    end
    self._version = (self._version + 1)
end

function SF__.StdLib.List:Add(item591)
    table.insert(self._items, item591)
    self.Count = (self.Count + 1)
    self._version = (self._version + 1)
end

function SF__.StdLib.List:Clear()
    self._items = {}
    self.Count = 0
    self._version = (self._version + 1)
end

function SF__.StdLib.List:Remove(item592)
    local index593 = self:IndexOf(item592)
    if (index593 < 0) then
        return false
    end
    self:RemoveAt(index593)
    return true
end

function SF__.StdLib.List:RemoveAt(index594)
    table.remove(self._items, (index594 + 1))
    self.Count = (self.Count - 1)
    self._version = (self._version + 1)
end

function SF__.StdLib.List:IndexOf(item595)
    do
        local i596 = 0
        while (i596 < self.Count) do
            repeat
                local current597 = self._items[(i596 + 1)]
                if (current597 == item595) then
                    return i596
                end
            until true
            i596 = (i596 + 1)
        end
    end
    return (-1)
end

function SF__.StdLib.List.DefaultCompare(a598, b599)
    if (a598 == b599) then
        return 0
    end
    if (a598 < b599) then
        return (-1)
    end
    return 1
end

function SF__.StdLib.List:Sort(comparison)
    if (comparison == nil) then
        comparison = SF__.StdLib.List.DefaultCompare
    end
    local version600 = self._version
    table.sort(self._items, function(a603, b604)
        return (comparison(a603, b604) < 0)
    end)
    if (version600 ~= self._version) then
        error(SF__.StrConcat__("SF__E2e5944b8", "Collection was modified"))
    end
    self._version = (self._version + 1)
end

function SF__.StdLib.List:IpairsNext()
    local version605 = self._version
    local index606 = 0
    return function()
        if (version605 ~= self._version) then
            error(SF__.StrConcat__("SF__E2e5944b8", "Collection was modified"))
        end
        index606 = (index606 + 1)
        local value607 = self._items[index606]
        if (value607 == nil) then
            return nil
        end
        return index606, value607
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
    local globalPos__x12, globalPos__y13, globalPos__z14 = self.localPosition__x, self.localPosition__y, self.localPosition__z
    local globalRot__x15, globalRot__y16, globalRot__z17, globalRot__w18 = self.localRotation__x, self.localRotation__y, self.localRotation__z, self.localRotation__w
    local globalScale__x19, globalScale__y20, globalScale__z21 = self.localScale__x, self.localScale__y, self.localScale__z
    local myParent = self.parent
    while (myParent ~= nil) do
        repeat
            globalPos__x12, globalPos__y13, globalPos__z14 = SF__.Vector3.op_Addition(myParent.localPosition__x, myParent.localPosition__y, myParent.localPosition__z, SF__.Quaternion.op_Multiply__iyiose(myParent.localRotation__x, myParent.localRotation__y, myParent.localRotation__z, myParent.localRotation__w, SF__.Vector3.Scale(myParent.localScale__x, myParent.localScale__y, myParent.localScale__z, globalPos__x12, globalPos__y13, globalPos__z14)))
            globalRot__x15, globalRot__y16, globalRot__z17, globalRot__w18 = SF__.Quaternion.op_Multiply__iyiiyi(myParent.localRotation__x, myParent.localRotation__y, myParent.localRotation__z, myParent.localRotation__w, globalRot__x15, globalRot__y16, globalRot__z17, globalRot__w18)
            globalScale__x19, globalScale__y20, globalScale__z21 = SF__.Vector3.Scale(myParent.localScale__x, myParent.localScale__y, myParent.localScale__z, globalScale__x19, globalScale__y20, globalScale__z21)
            myParent = myParent.parent
        until true
    end
    return globalPos__x12, globalPos__y13, globalPos__z14
end

function SF__.Transform:set_position(value__x, value__y, value__z)
    if (self.parent == nil) then
        self.localPosition__x, self.localPosition__y, self.localPosition__z = value__x, value__y, value__z
        return
    end
    local pos__x, pos__y, pos__z = value__x, value__y, value__z
    local myParent22 = self.parent
    while (myParent22 ~= nil) do
        repeat
            pos__x, pos__y, pos__z = SF__.Vector3.op_Subtraction(pos__x, pos__y, pos__z, myParent22.localPosition__x, myParent22.localPosition__y, myParent22.localPosition__z)
            pos__x, pos__y, pos__z = SF__.Vector3.Scale((1 / myParent22.localScale__x), (1 / myParent22.localScale__y), (1 / myParent22.localScale__z), pos__x, pos__y, pos__z)
            pos__x, pos__y, pos__z = (function()
                local q__x, q__y, q__z, q__w = SF__.Quaternion.Inverse(myParent22.localRotation__x, myParent22.localRotation__y, myParent22.localRotation__z, myParent22.localRotation__w)
                return SF__.Quaternion.op_Multiply__iyiose(q__x, q__y, q__z, q__w, pos__x, pos__y, pos__z)
            end)()
            myParent22 = myParent22.parent
        until true
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
            repeat
                if (child.gameObject.name == parts[(index + 1)]) then
                    local found = SF__.Transform._Find(child, parts, (index + 1))
                    if (found ~= nil) then
                        return found
                    end
                end
            until true
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
    local parts23 = SF__.StrSplit__(name, "/")
    return SF__.Transform._Find(self, parts23, 0)
end
-- GameObject
SF__.GameObject = SF__.GameObject or {}
SF__.GameObject.Name = "GameObject"
SF__.GameObject.FullName = "GameObject"
function SF__.GameObject.MarkDestroyQueuedDepthFirst(obj26)
    if (obj26.isDestroyQueued or obj26.isDestroyed) then
        return
    end
    obj26.isDestroyQueued = true
    do
        local collection4 = obj26.transform.children
        for _, child27 in (SF__.StdLib.List.IpairsNext)(collection4) do
            repeat
                SF__.GameObject.MarkDestroyQueuedDepthFirst(child27.gameObject)
            until true
        end
    end
end

function SF__.GameObject.DestroyDepthFirst(obj28)
    if obj28.isDestroyed then
        return
    end
    local children = obj28.transform.children
    do
        local i = (children.Count - 1)
        while (i >= 0) do
            repeat
                SF__.GameObject.DestroyDepthFirst(children:get_Item(i).gameObject)
            until true
            i = (i - 1)
        end
    end
    obj28.transform:SetParent(nil)
    do
        local collection5 = obj28._components
        for _, comp in (SF__.StdLib.List.IpairsNext)(collection5) do
            repeat
                comp:OnDisable()
                comp:OnDestroy()
            until true
        end
    end
    obj28._components:Clear()
    SF__.Scene.get_Instance().gameObjs:Remove(obj28)
    obj28.isDestroyed = true
end

function SF__.GameObject:get_components()
    return self._components
end

function SF__.GameObject.__Init__s(self, name29)
    self.__sf_type = SF__.GameObject
    self.name = nil
    self.transform = nil
    self._components = SF__.StdLib.List.New__0()
    self.isDestroyQueued = false
    self.isDestroyed = false
    self.name = name29
    self.transform = self:AddComponent(SF__.Transform)
    SF__.Scene.get_Instance():AddGameObject(self)
end

function SF__.GameObject.New__s(name29)
    local self = setmetatable({}, { __index = SF__.GameObject })
    SF__.GameObject.__Init__s(self, name29)
    return self
end

function SF__.GameObject.__Init__sx13(self, name30, parent31)
    SF__.GameObject.__Init__s(self, name30)
    self.transform:SetParent(parent31.transform)
end

function SF__.GameObject.New__sx13(name30, parent31)
    local self = setmetatable({}, { __index = SF__.GameObject })
    SF__.GameObject.__Init__sx13(self, name30, parent31)
    return self
end

function SF__.GameObject:GetComponent(T)
    do
        local collection6 = self._components
        for _, comp32 in (SF__.StdLib.List.IpairsNext)(collection6) do
            repeat
                do
                    local tComp = comp32
                    if SF__.TypeIs__(tComp, T) then
                        return tComp
                    end
                end
            until true
        end
    end
    return nil
end

function SF__.GameObject:AddComponent(T33)
    local comp34 = (function()
        local obj35 = T33.New()
        obj35.gameObject = self
        return obj35
    end)()
    self._components:Add(comp34)
    comp34:Awake()
    comp34:OnEnable()
    comp34:Start()
    return comp34
end

function SF__.GameObject:RemoveAllComponents(T36)
    do
        local i37 = (self._components.Count - 1)
        while (i37 >= 0) do
            repeat
                if SF__.TypeIs__(self._components:get_Item(i37), T36) then
                    self._components:get_Item(i37):OnDisable()
                    self._components:get_Item(i37):OnDestroy()
                    self._components:RemoveAt(i37)
                end
            until true
            i37 = (i37 - 1)
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
        for _, comp38 in (SF__.StdLib.List.IpairsNext)(collection7) do
            repeat
                comp38:Update()
            until true
        end
    end
end

function SF__.GameObject:LateUpdate()
    if (self.isDestroyQueued or self.isDestroyed) then
        return
    end
    local snapshot39 = SF__.StdLib.List.New__xqm20z(self._components)
    do
        local collection8 = snapshot39
        for _, comp40 in (SF__.StdLib.List.IpairsNext)(collection8) do
            repeat
                comp40:LateUpdate()
            until true
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

function SF__.GameObject.DestroyQueued(obj41)
    SF__.GameObject.DestroyDepthFirst(obj41)
end

function SF__.GameObject:GetComponentInChildren(T42)
    do
        local collection9 = self.transform.children
        for _, child43 in (SF__.StdLib.List.IpairsNext)(collection9) do
            repeat
                local comp44 = child43.gameObject:GetComponent(T42)
                if (comp44 ~= nil) then
                    return comp44
                end
                comp44 = child43.gameObject:GetComponentInChildren(T42)
                if (comp44 ~= nil) then
                    return comp44
                end
            until true
        end
    end
    return nil
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

function SF__.Scene:AddGameObject(obj45)
    self.gameObjs:Add(obj45)
end

function SF__.Scene:QueueDestroy(obj46)
    self._destroyQueue:Add(obj46)
end

function SF__.Scene:FlushDestroyQueue()
    do
        local i47 = 0
        while (i47 < self._destroyQueue.Count) do
            repeat
                SF__.GameObject.DestroyQueued(self._destroyQueue:get_Item(i47))
            until true
            i47 = (i47 + 1)
        end
    end
    self._destroyQueue:Clear()
end

function SF__.Scene:Run()
    return SF__.CorRun__(function()
        while true do
            repeat
                SF__.CorWait__(SF__.Scene.DT)
                local count = self.gameObjs.Count
                do
                    local i48 = 0
                    while (i48 < count) do
                        repeat
                            self.gameObjs:get_Item(i48):Update()
                        until true
                        i48 = (i48 + 1)
                    end
                end
                do
                    local i49 = 0
                    while (i49 < count) do
                        repeat
                            self.gameObjs:get_Item(i49):LateUpdate()
                        until true
                        i49 = (i49 + 1)
                    end
                end
                self:FlushDestroyQueue()
            until true
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
        repeat
            globalPos__x, globalPos__y, globalPos__z = SF__.Vector3.op_Addition(parent.localPosition__x, parent.localPosition__y, parent.localPosition__z, SF__.Quaternion.op_Multiply__iyiose(parent.localRotation__x, parent.localRotation__y, parent.localRotation__z, parent.localRotation__w, SF__.Vector3.Scale(parent.localScale__x, parent.localScale__y, parent.localScale__z, globalPos__x, globalPos__y, globalPos__z)))
            globalRot__x, globalRot__y, globalRot__z, globalRot__w = SF__.Quaternion.op_Multiply__iyiiyi(parent.localRotation__x, parent.localRotation__y, parent.localRotation__z, parent.localRotation__w, globalRot__x, globalRot__y, globalRot__z, globalRot__w)
            globalScale__x, globalScale__y, globalScale__z = SF__.Vector3.Scale(parent.localScale__x, parent.localScale__y, parent.localScale__z, globalScale__x, globalScale__y, globalScale__z)
            parent = parent.parent
        until true
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
-- AttachUnitComponent
SF__.AttachUnitComponent = SF__.AttachUnitComponent or {}
SF__.AttachUnitComponent.Name = "AttachUnitComponent"
SF__.AttachUnitComponent.FullName = "AttachUnitComponent"
setmetatable(SF__.AttachUnitComponent, { __index = SF__.Component })
SF__.AttachUnitComponent.__sf_base = SF__.Component
function SF__.AttachUnitComponent:SetUnit(target)
    self.target = target
end

function SF__.AttachUnitComponent.__Init(self)
    SF__.Component.__Init(self)
    self.__sf_type = SF__.AttachUnitComponent
    self.target = nil
end

function SF__.AttachUnitComponent.New()
    local self = setmetatable({}, { __index = SF__.AttachUnitComponent })
    SF__.AttachUnitComponent.__Init(self)
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

function SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p119, abilCode120, researchExtendedTooltip, level121)
    if (GetLocalPlayer() ~= p119) then
        return
    end
    BlzSetAbilityResearchExtendedTooltip(abilCode120, researchExtendedTooltip, level121)
end

function SF__.Utils.ExBlzSetAbilityTooltip(p122, abilCode123, tooltip, level124)
    if (GetLocalPlayer() ~= p122) then
        return
    end
    BlzSetAbilityTooltip(abilCode123, tooltip, level124)
end

function SF__.Utils.ExBlzSetAbilityExtendedTooltip(p125, abilCode126, extendedTooltip, level127)
    if (GetLocalPlayer() ~= p125) then
        return
    end
    BlzSetAbilityExtendedTooltip(abilCode126, extendedTooltip, level127)
end

function SF__.Utils.ExBlzSetAbilityIcon(p128, abilCode129, iconPath)
    if (GetLocalPlayer() ~= p128) then
        return
    end
    BlzSetAbilityIcon(abilCode129, iconPath)
end

function SF__.Utils.CsGroupGetUnitsInRange(x130, y131, radius, filter)
    local result = SF__.StdLib.List.New__0()
    ExGroupEnumUnitsInRange(x130, y131, radius, function(u133)
        if filter(u133) then
            result:Add(u133)
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
function SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(u499, amount)
    local UnitAttribute501 = require("Objects.UnitAttribute")
    local attr500 = UnitAttribute501.GetAttr(u499)
    attr500.retPalHolyEnergy = math.min((attr500.retPalHolyEnergy + amount), 5)
end

function SF__.RetributionPaladinGlobal.ConsumeHolyEnergy(u502, amount503)
    local UnitAttribute505 = require("Objects.UnitAttribute")
    local attr504 = UnitAttribute505.GetAttr(u502)
    attr504.retPalHolyEnergy = math.max((attr504.retPalHolyEnergy - amount503), 0)
end

function SF__.RetributionPaladinGlobal:Init()
    ExTriggerRegisterNewUnit(function(u507)
        if (GetUnitTypeId(u507) == FourCC("Hpal")) then
            self._units:Add(u507)
        end
    end)
    _ = self:Start()
end

function SF__.RetributionPaladinGlobal:Start()
    return SF__.CorRun__(function()
        local UnitAttribute510 = require("Objects.UnitAttribute")
        while true do
            repeat
                do
                    local collection10 = self._units
                    for _, u508 in (SF__.StdLib.List.IpairsNext)(collection10) do
                        repeat
                            local attr509 = UnitAttribute510.GetAttr(u508)
                            ExSetUnitMana(u508, ((ExGetUnitMaxMana(u508) * attr509.retPalHolyEnergy) * 0.2))
                            if (attr509.retPalHolyEnergy >= 3) then
                                SF__.Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u508), FourCC("A006"), "ReplaceableTextures/CommandButtons/BTNinv_helmet_96.tga")
                            else
                                SF__.Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u508), FourCC("A006"), "ReplaceableTextures/PassiveButtons/PASBTNinv_helmet_96.tga")
                            end
                        until true
                    end
                end
                SF__.CorWait__(100)
            until true
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
function SF__.BladeOfJustice.GetAbilityData(level320)
    return (75 * level320), 5, (10 * level320)
end

function SF__.BladeOfJustice.Init()
    local EventCenter = require("Lib.EventCenter")
    EventCenter.RegisterPlayerUnitSpellEffect:Emit({id = SF__.BladeOfJustice.ID, handler = SF__.BladeOfJustice.Start})
    ExTriggerRegisterNewUnit(function(u322)
        if (GetUnitTypeId(u322) == FourCC("Hpal")) then
            SF__.BladeOfJustice.UpdateAbilityMeta(u322)
        end
    end)
end

function SF__.BladeOfJustice.UpdateAbilityMeta(u323)
    local p324 = GetOwningPlayer(u323)
    local datas = SF__.StdLib.List.New__0()
    do
        local i325 = 0
        while (i325 < 3) do
            repeat
                local __pack_Damage, __pack_Duration, __pack_DamagePerSecond = SF__.BladeOfJustice.GetAbilityData((i325 + 1))
                datas:Add({Damage = __pack_Damage, Duration = __pack_Duration, DamagePerSecond = __pack_DamagePerSecond})
            until true
            i325 = (i325 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p324, SF__.BladeOfJustice.ID, "学习公正之剑 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p324, SF__.BladeOfJustice.ID, SF__.StrConcat__("用圣光的利刃刺穿目标，造成法术伤害，在一定时间内对附近敌人每秒造成光辉伤害。产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 10秒\n\n|cffffcc001级|r - 造成|cffff8c00", datas:get_Item(0).Damage, "|r的直接法术伤害，|cffff8c00", datas:get_Item(0).Duration, "|r秒内对附近敌人每秒造成|cffff8c00", datas:get_Item(0).DamagePerSecond, "|r的光辉伤害。产生|cffff8c001|r点圣能。\n|cffffcc002级|r - 造成|cffff8c00", datas:get_Item(1).Damage, "|r的直接法术伤害，|cffff8c00", datas:get_Item(1).Duration, "|r秒内对附近敌人每秒造成|cffff8c00", datas:get_Item(1).DamagePerSecond, "|r的光辉伤害。产生|cffff8c001|r点圣能。\n|cffffcc003级|r - 造成|cffff8c00", datas:get_Item(2).Damage, "|r的直接法术伤害，|cffff8c00", datas:get_Item(2).Duration, "|r秒内对附近敌人每秒造成|cffff8c00", datas:get_Item(2).DamagePerSecond, "|r的光辉伤害。产生|cffff8c001|r点圣能。"), 0)
    do
        local i326 = 0
        while (i326 < 3) do
            repeat
                local __unpack_tmp = datas:get_Item(i326)
                local data__Damage, data__Duration, data__DamagePerSecond = __unpack_tmp.Damage, __unpack_tmp.Duration, __unpack_tmp.DamagePerSecond
                SF__.Utils.ExBlzSetAbilityTooltip(p324, SF__.BladeOfJustice.ID, SF__.StrConcat__("公正之剑 - [|cffffcc00", (i326 + 1), "级|r]"), i326)
                SF__.Utils.ExBlzSetAbilityExtendedTooltip(p324, SF__.BladeOfJustice.ID, SF__.StrConcat__("用圣光的利刃刺穿目标，造成|cffff8c00", data__Damage, "|r的直接法术伤害，在|cffff8c00", data__Duration, "|r秒内对附近敌人每秒造成|cffff8c00", data__DamagePerSecond, "|r的光辉伤害。产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 10秒"), i326)
            until true
            i326 = (i326 + 1)
        end
    end
end

function SF__.BladeOfJustice.Start(data)
    local level327 = GetUnitAbilityLevel(data.caster, SF__.BladeOfJustice.ID)
    local EventCenter328 = require("Lib.EventCenter")
    local ad__Damage, ad__Duration, ad__DamagePerSecond = SF__.BladeOfJustice.GetAbilityData(level327)
    EventCenter328.Damage:Emit({whichUnit = data.caster, target = data.target, amount = ad__Damage, attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
    SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(data.caster, 1)
    SF__.BladeOfJustice.New():StartGroudDamage(data.caster, data.target, ad__Damage, ad__Duration, ad__DamagePerSecond)
end

function SF__.BladeOfJustice:StartGroudDamage(caster, target329, ad__Damage330, ad__Duration331, ad__DamagePerSecond332)
    return SF__.CorRun__(function()
        local pos__x333, pos__y334 = SF__.Vector2.FromUnit(target329)
        local UnitAttribute = require("Objects.UnitAttribute")
        local EventCenter339 = require("Lib.EventCenter")
        local eff335 = ExAddSpecialEffect("Abilities/Spells/Orc/LiquidFire/Liquidfire.mdl", pos__x333, pos__y334, ad__Duration331)
        local p336 = GetOwningPlayer(caster)
        do
            local i337 = 0
            while (i337 < ad__Duration331) do
                repeat
                    SF__.CorWait__(1000)
                    ExGroupEnumUnitsInRange(pos__x333, pos__y334, 300, function(u340)
                        if (not IsUnitEnemy(u340, p336)) then
                            return
                        end
                        if ExIsUnitDead(u340) then
                            return
                        end
                        local tarAttr341 = UnitAttribute.GetAttr(u340)
                        local damage342 = (ad__DamagePerSecond332 * (1 - tarAttr341.radiantResistance))
                        EventCenter339.Damage:Emit({whichUnit = caster, target = u340, amount = damage342, attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
                    end)
                until true
                i337 = (i337 + 1)
            end
        end
        DestroyEffect(eff335)
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
function SF__.CrusaderStrike.GetAbilityData(level343)
    return (0.65 + (0.35 * level343)), (0.15 * (level343 - 1))
end

function SF__.CrusaderStrike.Init()
    local EventCenter344 = require("Lib.EventCenter")
    EventCenter344.RegisterPlayerUnitSpellEffect:Emit({id = SF__.CrusaderStrike.ID, handler = SF__.CrusaderStrike.Start})
    ExTriggerRegisterNewUnit(function(u346)
        if (GetUnitTypeId(u346) == FourCC("Hpal")) then
            SF__.CrusaderStrike.UpdateAbilityMeta(u346)
        end
    end)
end

function SF__.CrusaderStrike.UpdateAbilityMeta(u347)
    local p348 = GetOwningPlayer(u347)
    local datas349 = SF__.StdLib.List.New__0()
    do
        local i350 = 0
        while (i350 < 3) do
            repeat
                local __pack_DamageScaling, __pack_ArtOfWarChance = SF__.CrusaderStrike.GetAbilityData((i350 + 1))
                datas349:Add({DamageScaling = __pack_DamageScaling, ArtOfWarChance = __pack_ArtOfWarChance})
            until true
            i350 = (i350 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p348, SF__.CrusaderStrike.ID, "学习十字军打击 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p348, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击造成一次攻击伤害，伤害系数随技能等级提升。产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 6秒\n\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas349:get_Item(0).DamageScaling * 100)), "%|r的攻击伤害。\n|cffffcc002级|r - |cffff8c00", string.format("%.0f", (datas349:get_Item(1).DamageScaling * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas349:get_Item(1).ArtOfWarChance * 100)), "%的战争艺术触发几率。\n|cffffcc003级|r - |cffff8c00", string.format("%.0f", (datas349:get_Item(2).DamageScaling * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas349:get_Item(2).ArtOfWarChance * 100)), "%的战争艺术触发几率。"), 0)
    do
        local i351 = 0
        while (i351 < 3) do
            repeat
                local __unpack_tmp352 = datas349:get_Item(i351)
                local data__DamageScaling, data__ArtOfWarChance = __unpack_tmp352.DamageScaling, __unpack_tmp352.ArtOfWarChance
                SF__.Utils.ExBlzSetAbilityTooltip(p348, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击 - [|cffffcc00", (i351 + 1), "级|r]"), i351)
                SF__.Utils.ExBlzSetAbilityExtendedTooltip(p348, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击造成一次攻击伤害，造成|cffff8c00", string.format("%.0f", (data__DamageScaling * 100)), "%|r的攻击伤害", (function() if (i351 > 0) then return SF__.StrConcat__("，", string.format("%.0f", (data__ArtOfWarChance * 100)), "%的战争艺术触发几率") else return "" end end)(), "。产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 6秒"), i351)
            until true
            i351 = (i351 + 1)
        end
    end
    -- datas.Remove(new IAbilityData { DamageScaling = 0.65f, ArtOfWarChance = 0 });
    datas349:RemoveAt(0)
end

function SF__.CrusaderStrike.Start(data353)
    local level354 = GetUnitAbilityLevel(data353.caster, SF__.CrusaderStrike.ID)
    local UnitAttribute355 = require("Objects.UnitAttribute")
    local EventCenter357 = require("Lib.EventCenter")
    local ad__DamageScaling, ad__ArtOfWarChance = SF__.CrusaderStrike.GetAbilityData(level354)
    local attr = UnitAttribute355.GetAttr(data353.caster)
    local damage356 = (attr:SimAttack(UnitAttribute355.HeroAttributeType.Strength) * ad__DamageScaling)
    EventCenter357.Damage:Emit({whichUnit = data353.caster, target = data353.target, amount = damage356, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
    SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(data353.caster, 1)
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
-- TimerComponent
SF__.TimerComponent = SF__.TimerComponent or {}
SF__.TimerComponent.Name = "TimerComponent"
SF__.TimerComponent.FullName = "TimerComponent"
setmetatable(SF__.TimerComponent, { __index = SF__.Component })
SF__.TimerComponent.__sf_base = SF__.Component
-- <summary>
--
-- </summary>
-- <param name="duration">seconds</param>
-- <param name="onComplete"></param>
--
function SF__.TimerComponent:StartTimer(duration10, onComplete)
    self.duration = (duration10 * 1000)
    self.elapsed = 0
    self.onComplete = onComplete
    self._running = true
end

function SF__.TimerComponent:Update()
    if (not self._running) then
        return
    end
    self.elapsed = (self.elapsed + SF__.Scene.DT)
    if (self.elapsed >= self.duration) then
        -- Timer has completed, trigger an event or callback here
        local delegate11 = self.onComplete
        if (delegate11 ~= nil) then
            delegate11()
        end
        self._running = false
    end
end

function SF__.TimerComponent.__Init(self)
    SF__.Component.__Init(self)
    self.__sf_type = SF__.TimerComponent
    self.duration = (-1)
    self.elapsed = 0
    self.onComplete = nil
    self._running = false
end

function SF__.TimerComponent.New()
    local self = setmetatable({}, { __index = SF__.TimerComponent })
    SF__.TimerComponent.__Init(self)
    return self
end
-- DivineStorm
SF__.DivineStorm = SF__.DivineStorm or {}
SF__.DivineStorm.Name = "DivineStorm"
SF__.DivineStorm.FullName = "DivineStorm"
function SF__.DivineStorm.Init()
    local EventCenter358 = require("Lib.EventCenter")
    EventCenter358.RegisterPlayerUnitSpellChannel:Emit({id = SF__.DivineStorm.ID, handler = SF__.DivineStorm.Check})
    EventCenter358.RegisterPlayerUnitSpellEffect:Emit({id = SF__.DivineStorm.ID, handler = SF__.DivineStorm.Start})
    ExTriggerRegisterNewUnit(function(u360)
        if (GetUnitTypeId(u360) == FourCC("Hpal")) then
            SF__.DivineStorm.UpdateAbilityMeta(u360)
        end
    end)
end

function SF__.DivineStorm.Check(data361)
    local UnitAttribute363 = require("Objects.UnitAttribute")
    local attr362 = UnitAttribute363.GetAttr(data361.caster)
    if (attr362.retPalHolyEnergy < 3) then
        IssueImmediateOrderById(data361.caster, SF__.ConstOrderId.Stop)
        ExTextState(data361.caster, "圣能不足")
    end
end

function SF__.DivineStorm.UpdateAbilityMeta(u364)
    local p365 = GetOwningPlayer(u364)
    SF__.Utils.ExSetAbilityResearchTooltip(p365, SF__.DivineStorm.ID, "学习神圣风暴 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p365, SF__.DivineStorm.ID, "对周围敌人造成200点光辉伤害。消耗|cffff8c003|r点圣能。", 0)
    do
        local i366 = 0
        while (i366 < 1) do
            repeat
                SF__.Utils.ExBlzSetAbilityTooltip(p365, SF__.DivineStorm.ID, SF__.StrConcat__("神圣风暴 - [|cffffcc00", (i366 + 1), "级|r]"), i366)
                SF__.Utils.ExBlzSetAbilityExtendedTooltip(p365, SF__.DivineStorm.ID, "神圣风暴对周围敌人造成200点光辉伤害。消耗|cffff8c003|r点圣能。", i366)
            until true
            i366 = (i366 + 1)
        end
    end
end

function SF__.DivineStorm.Start(data367)
    local pos__x368, pos__y369, pos__z370 = SF__.Vector3.FromUnit(data367.caster)
    local UnitAttribute373 = require("Objects.UnitAttribute")
    local EventCenter374 = require("Lib.EventCenter")
    ExGroupEnumUnitsInRange(pos__x368, pos__y369, 250, function(u375)
        if (not IsUnitEnemy(u375, GetOwningPlayer(data367.caster))) then
            return
        end
        if ExIsUnitDead(u375) then
            return
        end
        local attr376 = UnitAttribute373.GetAttr(data367.caster)
        EventCenter374.Damage:Emit({whichUnit = data367.caster, target = u375, amount = (200 * (1 - attr376.radiantResistance)), attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
    end)
    SF__.RetributionPaladinGlobal.ConsumeHolyEnergy(data367.caster, 3)
    local leviation = SF__.GameObject.New__s("ds_leviation")
    leviation.transform.localPosition__x, leviation.transform.localPosition__y, leviation.transform.localPosition__z = 0, 0, 50
    leviation:AddComponent(SF__.TimerComponent):StartTimer(0.6, function()
        leviation:Destroy()
    end)
    do
        local i377 = (-5)
        while (i377 <= 5) do
            repeat
                if (i377 == 0) then
                    break
                end
                local attach = SF__.GameObject.New__sx13("ds_visual", leviation)
                attach.transform.localPosition__x, attach.transform.localPosition__y, attach.transform.localPosition__z = pos__x368, pos__y369, pos__z370
                attach.transform.localRotation__x, attach.transform.localRotation__y, attach.transform.localRotation__z, attach.transform.localRotation__w = SF__.Quaternion.Euler(0, ((((360 / 5) * math.abs(i377)) - 10) + (20 * math.random())), 0)
                local att = attach:AddComponent(SF__.AutoTRSComponent)
                att.followUnit = data367.caster
                att.rotation__x, att.rotation__y, att.rotation__z, att.rotation__w = SF__.Quaternion.Euler(0, (((math.sign(i377) * ((math.random() * 200) + 700)) * SF__.Scene.DT) / 1000), 0)
                local arm = SF__.GameObject.New__sx13("ds_arm", attach)
                arm.transform.localPosition__x, arm.transform.localPosition__y, arm.transform.localPosition__z = 250, 0, 0
                local effHoly = AddSpecialEffect("Abilities/Weapons/FaerieDragonMissile/FaerieDragonMissile.mdl", pos__x368, pos__y369)
                local effC = arm:AddComponent(SF__.AttachEffectComponent)
                effC:AttachEffect(effHoly)
                effC:LerpIn(700)
            until true
            i377 = (i377 + 1)
        end
    end
end

function SF__.DivineStorm.__Init(self)
    self.__sf_type = SF__.DivineStorm
end

function SF__.DivineStorm.New()
    local self = setmetatable({}, { __index = SF__.DivineStorm })
    SF__.DivineStorm.__Init(self)
    return self
end

SF__.DivineStorm.ID = FourCC("A005")
-- DivineToll
SF__.DivineToll = SF__.DivineToll or {}
SF__.DivineToll.Name = "DivineToll"
SF__.DivineToll.FullName = "DivineToll"
function SF__.DivineToll.GetAbilityData(level378)
    return (2 + level378), (50 * level378), 0.1, 10, (5 + (5 * level378)), 10
end

function SF__.DivineToll.Init()
    local EventCenter381 = require("Lib.EventCenter")
    EventCenter381.RegisterPlayerUnitSpellEffect:Emit({id = SF__.DivineToll.ID, handler = function(data380)
        SF__.DivineToll.Start(data380)
    end})
    ExTriggerRegisterNewUnit(function(u383)
        if (GetUnitTypeId(u383) == FourCC("Hpal")) then
            SF__.DivineToll.UpdateAbilityMeta(u383)
        end
    end)
end

function SF__.DivineToll.UpdateAbilityMeta(u384)
    local p385 = GetOwningPlayer(u384)
    local datas386 = SF__.StdLib.List.New__0()
    do
        local i387 = 0
        while (i387 < 3) do
            repeat
                local __pack_TargetCount, __pack_Damage388, __pack_RadiantDmgAmp, __pack_Duration389, __pack_BHDamage, __pack_DebuffDuration = SF__.DivineToll.GetAbilityData((i387 + 1))
                datas386:Add({TargetCount = __pack_TargetCount, Damage = __pack_Damage388, RadiantDmgAmp = __pack_RadiantDmgAmp, Duration = __pack_Duration389, BHDamage = __pack_BHDamage, DebuffDuration = __pack_DebuffDuration})
            until true
            i387 = (i387 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p385, SF__.DivineToll.ID, "学习圣洁鸣钟 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p385, SF__.DivineToll.ID, SF__.StrConcat__("对附近的多个目标施展审判，造成法术伤害，然后神圣之锤环绕圣殿骑士，每次命中敌人使其受到的光辉伤害提高。每个审判产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 30秒\n\n|cffffcc001级|r - 审判最多|cffff8c00", datas386:get_Item(0).TargetCount, "|r个目标，造成|cffff8c00", datas386:get_Item(0).Damage, "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas386:get_Item(0).RadiantDmgAmp * 100)), "%|r的光辉易伤，持续|cffff8c00", datas386:get_Item(0).Duration, "|r秒。\n|cffffcc002级|r - 审判最多|cffff8c00", datas386:get_Item(1).TargetCount, "|r个目标，造成|cffff8c00", datas386:get_Item(1).Damage, "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas386:get_Item(1).RadiantDmgAmp * 100)), "%|r的光辉易伤，持续|cffff8c00", datas386:get_Item(1).Duration, "|r秒。\n|cffffcc003级|r - 审判最多|cffff8c00", datas386:get_Item(2).TargetCount, "|r个目标，造成|cffff8c00", datas386:get_Item(2).Damage, "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas386:get_Item(2).RadiantDmgAmp * 100)), "%|r的光辉易伤，持续|cffff8c00", datas386:get_Item(2).Duration, "|r秒。"), 0)
    do
        local i390 = 0
        while (i390 < 3) do
            repeat
                local __unpack_tmp393 = datas386:get_Item(i390)
                local data__TargetCount, data__Damage391, data__RadiantDmgAmp, data__Duration392, data__BHDamage, data__DebuffDuration = __unpack_tmp393.TargetCount, __unpack_tmp393.Damage, __unpack_tmp393.RadiantDmgAmp, __unpack_tmp393.Duration, __unpack_tmp393.BHDamage, __unpack_tmp393.DebuffDuration
                SF__.Utils.ExBlzSetAbilityTooltip(p385, SF__.DivineToll.ID, SF__.StrConcat__("圣洁鸣钟 - [|cffffcc00", (i390 + 1), "级|r]"), i390)
                SF__.Utils.ExBlzSetAbilityExtendedTooltip(p385, SF__.DivineToll.ID, SF__.StrConcat__("对附近的最多|cffff8c00", data__TargetCount, "|r个目标施展审判，造成|cffff8c00", data__Damage391, "|r点法术伤害，然后神圣之锤环绕圣殿骑士，每次命中敌人使其受到的光辉伤害提高|cffff8c00", string.format("%.0f", (data__RadiantDmgAmp * 100)), "%|r，持续|cffff8c00", data__Duration392, "|r秒。每个审判产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 30秒"), i390)
            until true
            i390 = (i390 + 1)
        end
    end
end

function SF__.DivineToll.HurlToTarget(caster394, target395, pos__x396, pos__y397, pos__z398)
    local outer = SF__.GameObject.New__s("DivineToll_Outer")
    local EventCenter405 = require("Lib.EventCenter")
    local UnitAttribute411 = require("Objects.UnitAttribute")
    outer.transform.localPosition__x, outer.transform.localPosition__y, outer.transform.localPosition__z = 0, 0, 80
    local moveLayer = SF__.GameObject.New__sx13("MoveLayer", outer)
    moveLayer.transform.localPosition__x, moveLayer.transform.localPosition__y, moveLayer.transform.localPosition__z = pos__x396, pos__y397, pos__z398
    local missile = moveLayer:AddComponent(SF__.Missile)
    missile:SetupUnitTarget(target395, 900, function(mis422, tar423)
        local cPos__x424, cPos__y425, cPos__z426 = mis422.gameObject.transform:get_position()
        local eff427 = ExAddSpecialEffect("Abilities/Spells/Human/StormBolt/StormBoltMissile.mdl", cPos__x424, cPos__y425, 0.1)
        BlzSetSpecialEffectColor(eff427, 255, 255, 0)
        local ad__TargetCount428, ad__Damage429, ad__RadiantDmgAmp430, ad__Duration431, ad__BHDamage432, ad__DebuffDuration433 = SF__.DivineToll.GetAbilityData(GetUnitAbilityLevel(caster394, SF__.DivineToll.ID))
        EventCenter405.Damage:Emit({whichUnit = caster394, target = tar423, amount = ad__Damage429, attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
        SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(caster394, 1)
        -- setup new missile
        mis422:SetupPiercer(function(m442, u443)
            local cPos__x444, cPos__y445, cPos__z446 = m442.gameObject.transform:get_position()
            ExAddSpecialEffectTarget("Abilities/Weapons/FaerieDragonMissile/FaerieDragonMissile.mdl", u443, "origin", 0.1)
            local tarAttr447 = UnitAttribute411.GetAttr(u443)
            local damage448 = (ad__BHDamage432 * (1 - tarAttr447.radiantResistance))
            EventCenter405.Damage:Emit({whichUnit = caster394, target = u443, amount = damage448, attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
            SF__.DivineToll.ApplyDebuff(caster394, u443)
        end, function(u449)
            if (not IsUnitEnemy(u449, GetOwningPlayer(caster394))) then
                return false
            end
            if IsUnitType(u449, UNIT_TYPE_STRUCTURE) then
                return false
            end
            if ExIsUnitDead(u449) then
                return false
            end
            return true
        end, 50, 9999, 0.3)
        -- change movement behaviour
        local aec1450 = moveLayer.transform:Find("DivineToll_Bolt/dt_hand/dt_mis").gameObject:GetComponent(SF__.AttachEffectComponent)
        aec1450:LerpIn(1300)
        local aec2451 = aec1450.gameObject.transform:Find("DivineToll_Holy").gameObject:GetComponent(SF__.AttachEffectComponent)
        aec2451:LerpIn(1300)
        local casterPos__x452, casterPos__y453, casterPos__z454 = SF__.Vector3.FromUnit(caster394)
        local circulator455 = SF__.GameObject.New__sx13("Circulator", outer)
        circulator455.transform.localPosition__x, circulator455.transform.localPosition__y, circulator455.transform.localPosition__z = casterPos__x452, casterPos__y453, casterPos__z454
        local rot456 = circulator455:AddComponent(SF__.AutoTRSComponent)
        rot456.rotation__x, rot456.rotation__y, rot456.rotation__z, rot456.rotation__w = SF__.Quaternion.Euler(0, ((300 * SF__.Scene.DT) / 1000), 0)
        rot456.followUnit = caster394
        moveLayer.transform:SetParent(circulator455.transform)
        moveLayer.transform.localPosition__x, moveLayer.transform.localPosition__y, moveLayer.transform.localPosition__z = 200, 0, 0
        -- set timeout
        local umo457 = SF__.UnitManager.GetGameObjectByUnit(caster394)
        local dtData458 = umo457:GetComponentInChildren(SF__.DivineToll.DivineTollUnitData)
        local dtTimer459
        if (dtData458 == nil) then
            local dtObj460 = SF__.GameObject.New__sx13("DivineTollData", umo457)
            dtData458 = dtObj460:AddComponent(SF__.DivineToll.DivineTollUnitData)
            dtTimer459 = dtObj460:AddComponent(SF__.TimerComponent)
        else
            dtTimer459 = dtData458.gameObject:GetComponent(SF__.TimerComponent)
        end
        dtData458:SetData(outer)
        dtTimer459:StartTimer(ad__Duration431, function()
            dtData458:TimesUp()
        end)
    end)
    missile.onLostTarget = function()
        outer:Destroy()
    end
    local orientationFixLayer = SF__.GameObject.New__sx13("DivineToll_Bolt", moveLayer)
    orientationFixLayer.transform.localRotation__x, orientationFixLayer.transform.localRotation__y, orientationFixLayer.transform.localRotation__z, orientationFixLayer.transform.localRotation__w = SF__.Quaternion.Euler(0, 90, 0)
    local selfRotLayer = SF__.GameObject.New__sx13("dt_hand", orientationFixLayer)
    local receiver = selfRotLayer:AddComponent(SF__.AutoTRSComponent)
    receiver.rotation__x, receiver.rotation__y, receiver.rotation__z, receiver.rotation__w = SF__.Quaternion.Euler(((1800 * SF__.Scene.DT) / 1000), 0, 0)
    local boltMis = SF__.GameObject.New__sx13("dt_mis", selfRotLayer)
    boltMis.transform.localPosition__x, boltMis.transform.localPosition__y, boltMis.transform.localPosition__z = 15, 0, 0
    boltMis.transform.localScale__x, boltMis.transform.localScale__y, boltMis.transform.localScale__z = 0.5, 0.5, 0.5
    local eff461 = AddSpecialEffect("Abilities/Spells/Human/StormBolt/StormBoltMissile.mdl", pos__x396, pos__y397)
    boltMis:AddComponent(SF__.AttachEffectComponent):AttachEffect(eff461)
    local attachedHoly = SF__.GameObject.New__sx13("DivineToll_Holy", boltMis)
    attachedHoly.transform.localPosition__x, attachedHoly.transform.localPosition__y, attachedHoly.transform.localPosition__z = 15, 0, 0
    local effHoly462 = AddSpecialEffect("Abilities/Weapons/FaerieDragonMissile/FaerieDragonMissile.mdl", pos__x396, pos__y397)
    attachedHoly:AddComponent(SF__.AttachEffectComponent):AttachEffect(effHoly462)
    BlzSetSpecialEffectColor(effHoly462, 20, 20, 20)
end

function SF__.DivineToll.Start(data463)
    return SF__.CorRun__(function()
        local pos__x464, pos__y465, pos__z466 = SF__.Vector3.FromUnit(data463.caster)
        local targets = SF__.Utils.CsGroupGetUnitsInRange(pos__x464, pos__y465, 600, function(u467)
            if (not IsUnitEnemy(u467, GetOwningPlayer(data463.caster))) then
                return false
            end
            if IsUnitType(u467, UNIT_TYPE_STRUCTURE) then
                return false
            end
            if ExIsUnitDead(u467) then
                return false
            end
            return true
        end)
        if (targets.Count == 0) then
            return
        end
        targets:Sort(function(a470, b471)
            local distA472 = SF__.Vector3.Distance(pos__x464, pos__y465, pos__z466, SF__.Vector3.FromUnit(a470))
            local distB473 = SF__.Vector3.Distance(pos__x464, pos__y465, pos__z466, SF__.Vector3.FromUnit(b471))
            return (function() if (distA472 == distB473) then return 0 else return (function() if (distA472 < distB473) then return (-1) else return 1 end end)() end end)()
        end)
        do
            local i474 = 0
            while (i474 < (function()
                local field__TargetCount, field__Damage, field__RadiantDmgAmp, field__Duration, field__BHDamage, field__DebuffDuration = SF__.DivineToll.GetAbilityData(GetUnitAbilityLevel(data463.caster, SF__.DivineToll.ID))
                return math.min(targets.Count, field__TargetCount)
            end)()) do
                repeat
                    SF__.DivineToll.HurlToTarget(data463.caster, targets:get_Item(i474), pos__x464, pos__y465, pos__z466)
                    SF__.CorWait__(200)
                until true
                i474 = (i474 + 1)
            end
        end
    end)
end

function SF__.DivineToll.ApplyDebuff(caster475, target476)
    local BuffBase = require("Objects.BuffBase")
    local buff = BuffBase.FindBuffByClassName(target476, "RadiantVulnerability")
    if (buff ~= nil) then
        buff:ResetDuration()
    else
        local ad__TargetCount477, ad__Damage478, ad__RadiantDmgAmp479, ad__Duration480, ad__BHDamage481, ad__DebuffDuration482 = SF__.DivineToll.GetAbilityData(GetUnitAbilityLevel(caster475, SF__.DivineToll.ID))
        SF__.DivineToll.RadiantVulnerability.New(caster475, target476, ad__DebuffDuration482, 99999, {level = 0, charged = 0})
    end
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
SF__.DivineToll = SF__.DivineToll or {}
-- DivineToll.RadiantVulnerability
local BuffBase483 = require("Objects.BuffBase")
SF__.DivineToll.RadiantVulnerability = SF__.DivineToll.RadiantVulnerability or class("RadiantVulnerability", BuffBase483)
SF__.DivineToll.RadiantVulnerability.Name = "RadiantVulnerability"
SF__.DivineToll.RadiantVulnerability.FullName = "DivineToll.RadiantVulnerability"
SF__.DivineToll.RadiantVulnerability.__sf_base = BuffBase483
function SF__.DivineToll.RadiantVulnerability.__Init(self, caster484, target485, duration486, interval, awakeData)
    self.__sf_type = SF__.DivineToll.RadiantVulnerability
    self._vulVal = 0
end

function SF__.DivineToll.RadiantVulnerability.New(caster484, target485, duration486, interval, awakeData)
    local self = SF__.DivineToll.RadiantVulnerability.new(caster484, target485, duration486, interval, awakeData)
    SF__.DivineToll.RadiantVulnerability.__Init(self, caster484, target485, duration486, interval, awakeData)
    return self
end

function SF__.DivineToll.RadiantVulnerability:Awake()
    local ad__TargetCount487, ad__Damage488, ad__RadiantDmgAmp489, ad__Duration490, ad__BHDamage491, ad__DebuffDuration492 = SF__.DivineToll.GetAbilityData(GetUnitAbilityLevel(self.caster, SF__.DivineToll.ID))
    self._vulVal = ad__RadiantDmgAmp489
end

function SF__.DivineToll.RadiantVulnerability:OnEnable()
    local UnitAttribute494 = require("Objects.UnitAttribute")
    local attr493 = UnitAttribute494.GetAttr(self.target)
    attr493.radiantResistance = (attr493.radiantResistance - self._vulVal)
end

function SF__.DivineToll.RadiantVulnerability:OnDisable()
    local UnitAttribute496 = require("Objects.UnitAttribute")
    local attr495 = UnitAttribute496.GetAttr(self.target)
    attr495.radiantResistance = (attr495.radiantResistance + self._vulVal)
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
    -- Move
    local cPos__x, cPos__y, cPos__z = self.gameObject.transform:get_position()
    local tPos__x, tPos__y, tPos__z = self.pointTarget__x, self.pointTarget__y, self.pointTarget__z
    if ((self.targetType == SF__.TargetType.Unit) or (self.targetType == SF__.TargetType.Point)) then
        if (self.targetType == SF__.TargetType.Unit) then
            if ((self.unitTarget == nil) or ExIsUnitDead(self.unitTarget)) then
                self:OnDisappear()
                return
            end
            tPos__x, tPos__y, tPos__z = SF__.Vector3.FromUnit(self.unitTarget)
        end
        if self.lookAtTarget then
            self.gameObject.transform.localRotation__x, self.gameObject.transform.localRotation__y, self.gameObject.transform.localRotation__z, self.gameObject.transform.localRotation__w = SF__.Quaternion.LookRotation__ose(SF__.Vector3.op_Subtraction(tPos__x, tPos__y, tPos__z, cPos__x, cPos__y, cPos__z))
        end
        cPos__x, cPos__y, cPos__z = SF__.Vector3.MoveTowards(cPos__x, cPos__y, cPos__z, tPos__x, tPos__y, tPos__z, ((self.speed * SF__.Scene.DT) / 1000))
        self.gameObject.transform:set_position(cPos__x, cPos__y, cPos__z)
    end
    -- Collision
    local now3 = os.clock()
    if (self.onThrough ~= nil) then
        ExGroupEnumUnitsInRange(cPos__x, cPos__y, self.colliderSize, function(u4)
            if ((self.onThroughFilter ~= nil) and (not self.onThroughFilter(u4))) then
                return
            end
            if (self.collisionCount <= 0) then
                return
            end
            local nhdPass5
            local __ret7, lastHitTime6 = self._hitUnits:TryGetValue(u4)
            if __ret7 then
                nhdPass5 = ((now3 - lastHitTime6) >= self.nextHitDelay)
            else
                nhdPass5 = true
            end
            if (not nhdPass5) then
                return
            end
            self._hitUnits:set_Item(u4, now3)
            self.collisionCount = (self.collisionCount - 1)
            self.onThrough(self, u4)
        end)
    end
    if (self.targetType ~= SF__.TargetType.None) then
        if (SF__.Vector3.Distance(cPos__x, cPos__y, cPos__z, tPos__x, tPos__y, tPos__z) <= 0.001) then
            self.hasArrived = true
            if ((self.onArrivedUnit ~= nil) and (self.targetType == SF__.TargetType.Unit)) then
                self._hitUnits:set_Item(self.unitTarget, now3)
                self.collisionCount = (self.collisionCount - 1)
                self.onArrivedUnit(self, self.unitTarget)
            end
            if ((self.onArrivedPoint ~= nil) and (self.targetType == SF__.TargetType.Point)) then
                self.onArrivedPoint(self, self.pointTarget__x, self.pointTarget__y, self.pointTarget__z)
            end
        end
    end
end

function SF__.Missile:GetInspectorText()
    return SF__.StrConcat__("targetType: ", self.targetType, "\nunitTarget: ", (function() if (self.unitTarget == nil) then return "None" else return GetUnitName(self.unitTarget) end end)(), "\npointTarget: ", SF__.Vector3.ToString(self.pointTarget__x, self.pointTarget__y, self.pointTarget__z), "\nspeed: ", self.speed, "\nlookAtTarget: ", self.lookAtTarget, "\ncolliderSize: ", self.colliderSize, "\nonArrived: ", (function() if (self.onArrivedUnit == nil) then return "None" else return "Set" end end)(), "\nhasArrived: ", self.hasArrived, "\n")
end

function SF__.Missile:SetupUnitTarget(target8, speed, onArrived, colliderSize, lookAtTarget)
    if colliderSize == nil then colliderSize = 32 end
    if lookAtTarget == nil then lookAtTarget = true end
    self.targetType = SF__.TargetType.Unit
    self.unitTarget = target8
    self.speed = speed
    self.lookAtTarget = lookAtTarget
    self.colliderSize = colliderSize
    self.onArrivedUnit = onArrived
    self.hasArrived = false
end

function SF__.Missile:SetupPiercer(onThrough, onThroughFilter, colliderSize9, collisionCount, nextHitDelay)
    self.targetType = SF__.TargetType.None
    self.unitTarget = nil
    self.colliderSize = colliderSize9
    self.onThrough = onThrough
    self.onThroughFilter = onThroughFilter
    self.collisionCount = collisionCount
    self.nextHitDelay = nextHitDelay
    self.hasArrived = false
end

function SF__.Missile:OnDisappear()
    self.hasArrived = true
    local delegate = self.onLostTarget
    if (delegate ~= nil) then
        delegate()
    end
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
    self.colliderSize = 0
    self.onArrivedUnit = nil
    self.onArrivedPoint = nil
    self.onThrough = nil
    self.onThroughFilter = nil
    self.onLostTarget = nil
    self.collisionCount = 1
    -- <summary>
    -- unit: s
    -- The delay between each hit when colliding with the same unit.
    -- Lower this value to hit the same unit multiple times in a short period.
    -- </summary>
    --
    self.nextHitDelay = 9999
    self._hitUnits = SF__.StdLib.Dictionary.New()
    self.hasArrived = true
end

function SF__.Missile.New()
    local self = setmetatable({}, { __index = SF__.Missile })
    SF__.Missile.__Init(self)
    return self
end
-- DivineToll.DivineTollUnitData
SF__.DivineToll.DivineTollUnitData = SF__.DivineToll.DivineTollUnitData or {}
SF__.DivineToll.DivineTollUnitData.Name = "DivineTollUnitData"
SF__.DivineToll.DivineTollUnitData.FullName = "DivineToll.DivineTollUnitData"
setmetatable(SF__.DivineToll.DivineTollUnitData, { __index = SF__.Component })
SF__.DivineToll.DivineTollUnitData.__sf_base = SF__.Component
function SF__.DivineToll.DivineTollUnitData:SetData(missile497)
    self._missiles:Add(missile497)
end

function SF__.DivineToll.DivineTollUnitData:TimesUp()
    do
        local collection11 = self._missiles
        for _, mis498 in (SF__.StdLib.List.IpairsNext)(collection11) do
            repeat
                mis498:Destroy()
            until true
        end
    end
    self._missiles:Clear()
end

function SF__.DivineToll.DivineTollUnitData.__Init(self)
    SF__.Component.__Init(self)
    self.__sf_type = SF__.DivineToll.DivineTollUnitData
    self._missiles = SF__.StdLib.List.New__0()
end

function SF__.DivineToll.DivineTollUnitData.New()
    local self = setmetatable({}, { __index = SF__.DivineToll.DivineTollUnitData })
    SF__.DivineToll.DivineTollUnitData.__Init(self)
    return self
end
-- Easing
SF__.Easing = SF__.Easing or {}
SF__.Easing.Name = "Easing"
SF__.Easing.FullName = "Easing"
function SF__.Easing.Linear(t)
    return t
end

function SF__.Easing.OutQubic(t75)
    return (1 - ((1 - t75) ^ 3))
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
function SF__.TemplarStrikes.GetAbilityData(level511)
    return 2, (0.5 + (0.25 * level511)), (0.05 * level511)
end

function SF__.TemplarStrikes.Init()
    local EventCenter512 = require("Lib.EventCenter")
    EventCenter512.RegisterPlayerUnitSpellEffect:Emit({id = SF__.TemplarStrikes.ID, handler = SF__.TemplarStrikes.Start})
    ExTriggerRegisterNewUnit(function(u514)
        if (GetUnitTypeId(u514) == FourCC("Hpal")) then
            SF__.TemplarStrikes.UpdateAbilityMeta(u514)
            SetHeroLevel(u514, 10, true)
        end
    end)
    EventCenter512.RegisterPlayerUnitDamaged:Emit(function(caster518, target519, damage520, weapType521, dmgType522, isAttack523)
        if (GetUnitAbilityLevel(caster518, SF__.TemplarStrikes.ID) <= 0) then
            return
        end
        if (not isAttack523) then
            return
        end
        if (target519 == nil) then
            return
        end
        if ExIsUnitDead(target519) then
            return
        end
        SF__.TemplarStrikes.TryResetBOJ(caster518)
    end)
end

function SF__.TemplarStrikes.TryResetBOJ(caster524)
    local level525 = GetUnitAbilityLevel(caster524, SF__.TemplarStrikes.ID)
    local ad__AttackCount, ad__DamageScaling526, ad__ResetBOJChance = SF__.TemplarStrikes.GetAbilityData(level525)
    if (math.random() >= ad__ResetBOJChance) then
        return
    end
    BlzEndUnitAbilityCooldown(caster524, SF__.BladeOfJustice.ID)
    ExAddSpecialEffectTarget("Abilities/Spells/Items/AIam/AIamTarget.mdl", caster524, "origin", 0.3)
end

function SF__.TemplarStrikes.UpdateAbilityMeta(u527)
    local p528 = GetOwningPlayer(u527)
    local datas529 = SF__.StdLib.List.New__0()
    do
        local i530 = 0
        while (i530 < SF__.TemplarStrikes.MaxLevel) do
            repeat
                local __pack_AttackCount, __pack_DamageScaling531, __pack_ResetBOJChance = SF__.TemplarStrikes.GetAbilityData((i530 + 1))
                datas529:Add({AttackCount = __pack_AttackCount, DamageScaling = __pack_DamageScaling531, ResetBOJChance = __pack_ResetBOJChance})
            until true
            i530 = (i530 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p528, SF__.TemplarStrikes.ID, "学习圣殿骑士之击 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p528, SF__.TemplarStrikes.ID, SF__.StrConcat__("快速攻击目标|cffff8c00", datas529:get_Item(0).AttackCount, "|r次，第一次造成普通攻击伤害，第二次造成光辉伤害，有一定几率重置公正之剑的冷却时间，普通攻击也会触发。\n\n|cff99ccff冷却时间|r - 10秒\n\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas529:get_Item(0).DamageScaling * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas529:get_Item(0).ResetBOJChance * 100)), "%|r的几率重置公正之剑。\n|cffffcc002级|r - |cffff8c00", string.format("%.0f", (datas529:get_Item(1).DamageScaling * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas529:get_Item(1).ResetBOJChance * 100)), "%|r的几率重置公正之剑。\n|cffffcc003级|r - |cffff8c00", string.format("%.0f", (datas529:get_Item(2).DamageScaling * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas529:get_Item(2).ResetBOJChance * 100)), "%|r的几率重置公正之剑。"), 0)
    do
        local i532 = 0
        while (i532 < SF__.TemplarStrikes.MaxLevel) do
            repeat
                local __unpack_tmp534 = datas529:get_Item(i532)
                local data__AttackCount, data__DamageScaling533, data__ResetBOJChance = __unpack_tmp534.AttackCount, __unpack_tmp534.DamageScaling, __unpack_tmp534.ResetBOJChance
                SF__.Utils.ExBlzSetAbilityTooltip(p528, SF__.TemplarStrikes.ID, SF__.StrConcat__("圣殿骑士之击 - [|cffffcc00", (i532 + 1), "级|r]"), i532)
                SF__.Utils.ExBlzSetAbilityExtendedTooltip(p528, SF__.TemplarStrikes.ID, SF__.StrConcat__("快速攻击目标|cffff8c00", data__AttackCount, "|r次，第一次造成普通攻击伤害，第二次造成普通攻击|cffff8c00", string.format("%.0f", (data__DamageScaling533 * 100)), "%|r的光辉伤害，|cffff8c00", string.format("%.0f", (data__ResetBOJChance * 100)), "%|r几率重置公正之剑的冷却时间，普通攻击也会触发。\n\n|cff99ccff冷却时间|r - 10秒"), i532)
            until true
            i532 = (i532 + 1)
        end
    end
end

function SF__.TemplarStrikes.Start(data535)
    return SF__.CorRun__(function()
        local level536 = GetUnitAbilityLevel(data535.caster, SF__.TemplarStrikes.ID)
        local UnitAttribute538 = require("Objects.UnitAttribute")
        local EventCenter539 = require("Lib.EventCenter")
        local attr537 = UnitAttribute538.GetAttr(data535.caster)
        local normalDamage = attr537:SimMeleeAttack()
        EventCenter539.Damage:Emit({whichUnit = data535.caster, target = data535.target, amount = normalDamage, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
        SF__.TemplarStrikes.TryResetBOJ(data535.caster)
        SetUnitTimeScale(data535.caster, 3)
        ResetUnitAnimation(data535.caster)
        SetUnitAnimation(data535.caster, "attack - 2")
        SF__.CorWait__(math.round(((1.166 * 0.33) * 1000)))
        local tarAttr540 = UnitAttribute538.GetAttr(data535.target)
        local ad__AttackCount541, ad__DamageScaling542, ad__ResetBOJChance543 = SF__.TemplarStrikes.GetAbilityData(level536)
        local radiantDamage = ((attr537:SimMeleeAttack() * ad__DamageScaling542) * (1 - tarAttr540.radiantResistance))
        EventCenter539.Damage:Emit({whichUnit = data535.caster, target = data535.target, amount = radiantDamage, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
        SF__.TemplarStrikes.TryResetBOJ(data535.caster)
        SetUnitTimeScale(data535.caster, 1)
        ResetUnitAnimation(data535.caster)
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
    local EventCenter566 = require("Lib.EventCenter")
    EventCenter566.RegisterPlayerUnitSpellChannel:Emit({id = SF__.WordOfGlory.ID, handler = SF__.WordOfGlory.Check})
    EventCenter566.RegisterPlayerUnitSpellEffect:Emit({id = SF__.WordOfGlory.ID, handler = SF__.WordOfGlory.Start})
    ExTriggerRegisterNewUnit(function(u568)
        if (GetUnitTypeId(u568) == FourCC("Hpal")) then
            SF__.WordOfGlory.UpdateAbilityMeta(u568)
        end
    end)
end

function SF__.WordOfGlory.Check(data569)
    local UnitAttribute571 = require("Objects.UnitAttribute")
    local attr570 = UnitAttribute571.GetAttr(data569.caster)
    if (attr570.retPalHolyEnergy < 3) then
        IssueImmediateOrderById(data569.caster, SF__.ConstOrderId.Stop)
        ExTextState(data569.caster, "圣能不足")
    end
end

function SF__.WordOfGlory.UpdateAbilityMeta(u572)
    local p573 = GetOwningPlayer(u572)
    SF__.Utils.ExSetAbilityResearchTooltip(p573, SF__.WordOfGlory.ID, "学习荣耀圣令 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p573, SF__.WordOfGlory.ID, "治疗目标300生命。消耗|cffff8c003|r点圣能。", 0)
    do
        local i574 = 0
        while (i574 < 1) do
            repeat
                SF__.Utils.ExBlzSetAbilityTooltip(p573, SF__.WordOfGlory.ID, SF__.StrConcat__("荣耀圣令 - [|cffffcc00", (i574 + 1), "级|r]"), i574)
                SF__.Utils.ExBlzSetAbilityExtendedTooltip(p573, SF__.WordOfGlory.ID, "荣耀圣令治疗目标300生命。消耗|cffff8c003|r点圣能。", i574)
            until true
            i574 = (i574 + 1)
        end
    end
end

function SF__.WordOfGlory.Start(data575)
    local EventCenter576 = require("Lib.EventCenter")
    EventCenter576.Heal:Emit({caster = data575.caster, target = data575.target, amount = 300})
    SF__.RetributionPaladinGlobal.ConsumeHolyEnergy(data575.caster, 3)
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
    SF__.DivineStorm.Init()
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
local SystemBase50 = require("System.SystemBase")
SF__.Systems.InspectorSystem = SF__.Systems.InspectorSystem or class("InspectorSystem", SystemBase50)
SF__.Systems.InspectorSystem.Name = "InspectorSystem"
SF__.Systems.InspectorSystem.FullName = "Systems.InspectorSystem"
SF__.Systems.InspectorSystem.__sf_base = SystemBase50
function SF__.Systems.InspectorSystem:Awake()
    self:CreateFrames()
    self:RefreshHierarchy()
    self:SelectFirstVisibleObject()
    self:SetPanelVisible(false)
end

function SF__.Systems.InspectorSystem:Update(dt51)
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
        local i52 = 0
        while (i52 < SF__.Systems.InspectorSystem.MaxHierarchyRows) do
            repeat
                self._hierarchyRows:Add(self:CreateHierarchyRow(i52))
            until true
            i52 = (i52 + 1)
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

function SF__.Systems.InspectorSystem:CreateHierarchyRow(index53)
    local y54 = ((-0.061) - (index53 * (SF__.Systems.InspectorSystem.RowHeight + SF__.Systems.InspectorSystem.RowGap)))
    local button = BlzCreateFrameByType("BUTTON", "FdfInspectorHierarchyRow", self._panel, "ScoreScreenTabButtonTemplate", index53)
    BlzFrameSetPoint(button, FRAMEPOINT_TOPLEFT, self._panel, FRAMEPOINT_TOPLEFT, (SF__.Systems.InspectorSystem.Padding * 2), y54)
    BlzFrameSetSize(button, (SF__.Systems.InspectorSystem.LeftWidth - (SF__.Systems.InspectorSystem.Padding * 4)), SF__.Systems.InspectorSystem.RowHeight)
    local label55 = BlzCreateFrameByType("TEXT", "FdfInspectorHierarchyRowText", button, "", index53)
    BlzFrameSetPoint(label55, FRAMEPOINT_TOPLEFT, button, FRAMEPOINT_TOPLEFT, 0.004, (-0.002))
    BlzFrameSetSize(label55, (SF__.Systems.InspectorSystem.LeftWidth - (SF__.Systems.InspectorSystem.Padding * 5)), (SF__.Systems.InspectorSystem.RowHeight - 0.003))
    BlzFrameSetEnable(label55, false)
    BlzFrameSetTextAlignment(label55, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_LEFT)
    BlzFrameSetText(label55, "")
    local row = SF__.Systems.InspectorSystem.HierarchyRow.New(button, label55)
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

function SF__.Systems.InspectorSystem:SelectRow(row56)
    if (row56.gameObject == nil) then
        return
    end
    self._selectedGameObject = row56.gameObject
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
        local collection12 = SF__.Scene.get_Instance().gameObjs
        for _, obj57 in (SF__.StdLib.List.IpairsNext)(collection12) do
            repeat
                if (obj57.transform.parent == nil) then
                    self:AddHierarchyObject(obj57, 0)
                end
            until true
        end
    end
    do
        local i58 = 0
        while (i58 < self._hierarchyRows.Count) do
            repeat
                local row59 = self._hierarchyRows:get_Item(i58)
                if (i58 < self._visibleObjects.Count) then
                    local obj60 = self._visibleObjects:get_Item(i58)
                    row59.gameObject = obj60
                    row59.depth = self:GetDepth(obj60)
                    self:SetRowLabel(row59, obj60.name, row59.depth)
                    BlzFrameSetVisible(row59.button, self._isVisible)
                else
                    row59.gameObject = nil
                    BlzFrameSetVisible(row59.button, false)
                end
            until true
            i58 = (i58 + 1)
        end
    end
    BlzFrameSetVisible(self._emptyText, (self._isVisible and (self._visibleObjects.Count == 0)))
    self._lastObjectCount = SF__.Scene.get_Instance().gameObjs.Count
    self:RefreshHierarchySelection()
end

function SF__.Systems.InspectorSystem:AddHierarchyObject(obj61, depth)
    if (self._visibleObjects.Count >= SF__.Systems.InspectorSystem.MaxHierarchyRows) then
        return
    end
    self._visibleObjects:Add(obj61)
    do
        local collection13 = obj61.transform.children
        for _, child62 in (SF__.StdLib.List.IpairsNext)(collection13) do
            repeat
                self:AddHierarchyObject(child62.gameObject, (depth + 1))
            until true
        end
    end
end

function SF__.Systems.InspectorSystem:GetDepth(obj63)
    local depth64 = 0
    local parent65 = obj63.transform.parent
    while (parent65 ~= nil) do
        repeat
            depth64 = (depth64 + 1)
            parent65 = parent65.parent
        until true
    end
    return depth64
end

function SF__.Systems.InspectorSystem:SetRowLabel(row66, text67, depth68)
    BlzFrameClearAllPoints(row66.label)
    BlzFrameSetPoint(row66.label, FRAMEPOINT_TOPLEFT, row66.button, FRAMEPOINT_TOPLEFT, (0.004 + (depth68 * SF__.Systems.InspectorSystem.IndentWidth)), (-0.002))
    BlzFrameSetSize(row66.label, ((SF__.Systems.InspectorSystem.LeftWidth - (SF__.Systems.InspectorSystem.Padding * 5)) - (depth68 * SF__.Systems.InspectorSystem.IndentWidth)), (SF__.Systems.InspectorSystem.RowHeight - 0.003))
    BlzFrameSetText(row66.label, text67)
end

function SF__.Systems.InspectorSystem:RefreshHierarchySelection()
    do
        local collection14 = self._hierarchyRows
        for _, row69 in (SF__.StdLib.List.IpairsNext)(collection14) do
            repeat
                local isSelected = ((row69.gameObject ~= nil) and (row69.gameObject == self._selectedGameObject))
                BlzFrameSetTextColor(row69.label, (function() if isSelected then return BlzConvertColor(255, 255, 220, 80) else return BlzConvertColor(255, 230, 230, 230) end end)())
            until true
        end
    end
end

function SF__.Systems.InspectorSystem:RefreshInspectorText()
    if (self._selectedGameObject == nil) then
        BlzFrameSetText(self._inspectorText, "")
        return
    end
    local text70 = SF__.StrConcat__(self._selectedGameObject.name, "\n")
    do
        local collection15 = self._selectedGameObject:get_components()
        for _, component in (SF__.StdLib.List.IpairsNext)(collection15) do
            repeat
                text70 = SF__.StrConcat__(text70, "\n[", component.__sf_type.Name, "]")
                local inspectorText = component:GetInspectorText()
                if (inspectorText ~= "") then
                    text70 = SF__.StrConcat__(text70, "\n", inspectorText)
                end
            until true
        end
    end
    BlzFrameSetText(self._inspectorText, text70)
end

function SF__.Systems.InspectorSystem:SceneContains(gameObject)
    do
        local collection16 = SF__.Scene.get_Instance().gameObjs
        for _, obj71 in (SF__.StdLib.List.IpairsNext)(collection16) do
            repeat
                if (obj71 == gameObject) then
                    return true
                end
            until true
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
function SF__.Systems.InspectorSystem.HierarchyRow.__Init(self, button72, label73)
    self.__sf_type = SF__.Systems.InspectorSystem.HierarchyRow
    self.button = nil
    self.label = nil
    self.gameObject = nil
    self.depth = 0
    self.button = button72
    self.label = label73
end

function SF__.Systems.InspectorSystem.HierarchyRow.New(button72, label73)
    local self = setmetatable({}, { __index = SF__.Systems.InspectorSystem.HierarchyRow })
    SF__.Systems.InspectorSystem.HierarchyRow.__Init(self, button72, label73)
    return self
end
-- Systems.MeleeGameSystem
local SystemBase74 = require("System.SystemBase")
SF__.Systems.MeleeGameSystem = SF__.Systems.MeleeGameSystem or class("MeleeGameSystem", SystemBase74)
SF__.Systems.MeleeGameSystem.Name = "MeleeGameSystem"
SF__.Systems.MeleeGameSystem.FullName = "Systems.MeleeGameSystem"
SF__.Systems.MeleeGameSystem.__sf_base = SystemBase74
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
-- UnitManager
SF__.UnitManager = SF__.UnitManager or {}
SF__.UnitManager.Name = "UnitManager"
SF__.UnitManager.FullName = "UnitManager"
setmetatable(SF__.UnitManager, { __index = SF__.Component })
SF__.UnitManager.__sf_base = SF__.Component
function SF__.UnitManager:Awake()
    if (SF__.UnitManager.Instance ~= nil) then
        SF__.UnitManager.Instance.gameObject:Destroy()
    end
    SF__.UnitManager.Instance = self
end

function SF__.UnitManager.GetGameObjectByUnit(u24)
    if (SF__.UnitManager.Instance == nil) then
        error(SF__.StrConcat__("SF__E2e5944b8", "This is weird"))
    end
    local __ret25, obj = SF__.UnitManager.Instance._map:TryGetValue(u24)
    if __ret25 then
        return obj
    end
    local __inc = SF__.UnitManager.unitCounter
    SF__.UnitManager.unitCounter = (SF__.UnitManager.unitCounter + 1)
    obj = SF__.GameObject.New__sx13(SF__.StrConcat__("Unit_", GetUnitName(u24), "_", __inc), SF__.UnitManager.Instance.gameObject)
    SF__.UnitManager.Instance._map:set_Item(u24, obj)
    obj:AddComponent(SF__.AttachUnitComponent):SetUnit(u24)
    return obj
end

function SF__.UnitManager.__Init(self)
    SF__.Component.__Init(self)
    self.__sf_type = SF__.UnitManager
    self._map = SF__.StdLib.Dictionary.New()
end

function SF__.UnitManager.New()
    local self = setmetatable({}, { __index = SF__.UnitManager })
    SF__.UnitManager.__Init(self)
    return self
end

SF__.UnitManager.Instance = nil
SF__.UnitManager.unitCounter = 0
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
        local collection17 = systems
        for _, system in (SF__.StdLib.List.IpairsNext)(collection17) do
            repeat
                system:Awake()
            until true
        end
    end
    local group = CreateGroup()
    GroupEnumUnitsInRect(group, bj_mapInitialPlayableArea, Filter(function()
        ExTriggerRegisterNewUnitExec(GetFilterUnit())
        return false
    end))
    DestroyGroup(group)
    do
        local collection18 = systems
        for _, system1 in (SF__.StdLib.List.IpairsNext)(collection18) do
            repeat
                system1:OnEnable()
            until true
        end
    end
    local game = FrameTimer.new(function(dt)
        local now = (MathRound((Time.Time * 100)) * 0.01)
        do
            local collection19 = systems
            for _, system2 in (SF__.StdLib.List.IpairsNext)(collection19) do
                repeat
                    system2:Update(dt, now)
                until true
            end
        end
    end, 1, (-1))
    game:Start()
    SF__.Scene.get_Instance():Run()
    SF__.GameObject.New__s("UnitManager"):AddComponent(SF__.UnitManager)
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
    local item118 = self._items:get_Item((self._items.Count - 1))
    self._items:RemoveAt((self._items.Count - 1))
    return item118
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
    self._table = nil
    self._version = 0
    self._keys = nil
    self.Count = 0
    self._table = {}
    self._keys = SF__.StdLib.List.New__0()
    self._version = 0
    self.Count = 0
end

function SF__.StdLib.Dictionary.New()
    local self = setmetatable({}, { __index = SF__.StdLib.Dictionary })
    SF__.StdLib.Dictionary.__Init(self)
    return self
end

function SF__.StdLib.Dictionary:get_Item(key)
    if (key == nil) then
        error(SF__.StrConcat__("SF__E2e5944b8", "Key cannot be null"))
    end
    return (function()
        local __coalesce = self._table[key]
        if (__coalesce == nil) then
            error(SF__.StrConcat__("SF__E2e5944b8", "Key not found"))
        end
        return __coalesce
    end)()
end

function SF__.StdLib.Dictionary:set_Item(key577, value)
    if (key577 == nil) then
        error(SF__.StrConcat__("SF__E2e5944b8", "Key cannot be null"))
    end
    local existing = self._table[key577]
    self._table[key577] = value
    if (existing == nil) then
        self.Count = (self.Count + 1)
        self._keys:Add(key577)
    end
    self._version = (self._version + 1)
end

function SF__.StdLib.Dictionary:PairsNext()
    local version = self._version
    local index578 = 0
    return function()
        if (version ~= self._version) then
            error(SF__.StrConcat__("SF__E2e5944b8", "Collection was modified"))
        end
        index578 = (index578 + 1)
        if (index578 > self._keys.Count) then
            return nil
        end
        local key579 = self._keys:get_Item((index578 - 1))
        local value580 = self._table[key579]
        return key579, value580
    end
end

function SF__.StdLib.Dictionary:ContainsKey(key581)
    if (key581 == nil) then
        error(SF__.StrConcat__("SF__E2e5944b8", "Key cannot be null"))
    end
    return (self._table[key581] ~= nil)
end

function SF__.StdLib.Dictionary:TryGetValue(key582)
    if (key582 == nil) then
        error(SF__.StrConcat__("SF__E2e5944b8", "Key cannot be null"))
    end
    local result584 = self._table[key582]
    if (result584 ~= nil) then
        value583 = result584
        return true, value583
    end
    value583 = nil
    return false, value583
end

function SF__.StdLib.Dictionary:GetEnumerator()
    return nil
end
SF__.StdLib.Dictionary = SF__.StdLib.Dictionary or {}
-- StdLib.Dictionary.Enumerator
SF__.StdLib.Dictionary.Enumerator = SF__.StdLib.Dictionary.Enumerator or {}
SF__.StdLib.Dictionary.Enumerator.Name = "Enumerator"
SF__.StdLib.Dictionary.Enumerator.FullName = "StdLib.Dictionary.Enumerator"
function SF__.StdLib.Dictionary.Enumerator:get_Current()
    return nil
end

function SF__.StdLib.Dictionary.Enumerator:MoveNext()
    return nil
end

function SF__.StdLib.Dictionary.Enumerator.__Init(self)
    self.__sf_type = SF__.StdLib.Dictionary.Enumerator
end

function SF__.StdLib.Dictionary.Enumerator.New()
    local self = setmetatable({}, { __index = SF__.StdLib.Dictionary.Enumerator })
    SF__.StdLib.Dictionary.Enumerator.__Init(self)
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
function SF__.TemplarVerdict.GetAbilityData(level544)
    return 2.25, 0.3, 0.15
end

function SF__.TemplarVerdict.Init()
    local EventCenter545 = require("Lib.EventCenter")
    EventCenter545.RegisterPlayerUnitSpellChannel:Emit({id = SF__.TemplarVerdict.ID, handler = SF__.TemplarVerdict.Check})
    EventCenter545.RegisterPlayerUnitSpellEffect:Emit({id = SF__.TemplarVerdict.ID, handler = SF__.TemplarVerdict.Start})
    ExTriggerRegisterNewUnit(function(u547)
        if (GetUnitTypeId(u547) == FourCC("Hpal")) then
            SF__.TemplarVerdict.UpdateAbilityMeta(u547)
        end
    end)
end

function SF__.TemplarVerdict.Check(data548)
    local UnitAttribute550 = require("Objects.UnitAttribute")
    local attr549 = UnitAttribute550.GetAttr(data548.caster)
    if (attr549.retPalHolyEnergy < 3) then
        IssueImmediateOrderById(data548.caster, SF__.ConstOrderId.Stop)
        ExTextState(data548.caster, "圣能不足")
    end
end

function SF__.TemplarVerdict.UpdateAbilityMeta(u551)
    local p552 = GetOwningPlayer(u551)
    local datas553 = SF__.StdLib.List.New__0()
    do
        local i554 = 0
        while (i554 < 1) do
            repeat
                local __pack_DamageScaling555, __pack_JudgementDamageScaling, __pack_ChanceToResetJudgement = SF__.TemplarVerdict.GetAbilityData((i554 + 1))
                datas553:Add({DamageScaling = __pack_DamageScaling555, JudgementDamageScaling = __pack_JudgementDamageScaling, ChanceToResetJudgement = __pack_ChanceToResetJudgement})
            until true
            i554 = (i554 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p552, SF__.TemplarVerdict.ID, "学习圣殿骑士的裁决 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p552, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决造成一次攻击伤害，如果目标被审判，造成30%的额外伤害，15%几率重置审判。消耗|cffff8c003|r点圣能。\n\n|cff99ccff冷却时间|r - 5秒\n\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas553:get_Item(0).JudgementDamageScaling * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas553:get_Item(0).ChanceToResetJudgement * 100)), "%的战争艺术触发几率。"), 0)
    do
        local i556 = 0
        while (i556 < 1) do
            repeat
                local __unpack_tmp558 = datas553:get_Item(i556)
                local data__DamageScaling557, data__JudgementDamageScaling, data__ChanceToResetJudgement = __unpack_tmp558.DamageScaling, __unpack_tmp558.JudgementDamageScaling, __unpack_tmp558.ChanceToResetJudgement
                SF__.Utils.ExBlzSetAbilityTooltip(p552, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决 - [|cffffcc00", (i556 + 1), "级|r]"), i556)
                SF__.Utils.ExBlzSetAbilityExtendedTooltip(p552, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决造成一次攻击伤害，造成|cffff8c00", string.format("%.0f", (data__DamageScaling557 * 100)), "%|r的攻击伤害。消耗|cffff8c003|r点圣能。\n\n|cff99ccff冷却时间|r - 5秒"), i556)
            until true
            i556 = (i556 + 1)
        end
    end
end

function SF__.TemplarVerdict.Start(data559)
    local level560 = GetUnitAbilityLevel(data559.caster, SF__.TemplarVerdict.ID)
    local UnitAttribute563 = require("Objects.UnitAttribute")
    local EventCenter565 = require("Lib.EventCenter")
    local ad__DamageScaling561, ad__JudgementDamageScaling, ad__ChanceToResetJudgement = SF__.TemplarVerdict.GetAbilityData(level560)
    local attr562 = UnitAttribute563.GetAttr(data559.caster)
    local damage564 = (attr562:SimAttack(UnitAttribute563.HeroAttributeType.Strength) * ad__DamageScaling561)
    EventCenter565.Damage:Emit({whichUnit = data559.caster, target = data559.target, amount = damage564, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_SLICE, outResult = {}})
    SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(data559.caster, 1)
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

function SF__.Vector2.Dot(a__x134, a__y135, b__x136, b__y137)
    return ((a__x134 * b__x136) + (a__y135 * b__y137))
end

function SF__.Vector2.Cross(a__x138, a__y139, b__x140, b__y141)
    return ((a__y139 * b__x140) - (a__x138 * b__y141))
end

function SF__.Vector2.op_UnaryNegation(a__x142, a__y143)
    return (-a__x142), (-a__y143)
end

function SF__.Vector2.op_Addition(a__x144, a__y145, b__x146, b__y147)
    return (a__x144 + b__x146), (a__y145 + b__y147)
end

function SF__.Vector2.op_Subtraction(a__x148, a__y149, b__x150, b__y151)
    return (a__x148 - b__x150), (a__y149 - b__y151)
end

function SF__.Vector2.op_Multiply__ahdf(v__x152, v__y153, f)
    return (v__x152 * f), (v__y153 * f)
end

function SF__.Vector2.op_Multiply__fahd(f154, v__x155, v__y156)
    return (v__x155 * f154), (v__y156 * f154)
end

function SF__.Vector2.op_Division(v__x157, v__y158, f159)
    return (v__x157 / f159), (v__y158 / f159)
end

function SF__.Vector2.UnitDistance(a, b)
    local v1__x, v1__y = SF__.Vector2.FromUnit(a)
    local v2__x, v2__y = SF__.Vector2.FromUnit(b)
    return SF__.Vector2.get_Magnitude(SF__.Vector2.op_Subtraction(v1__x, v1__y, v2__x, v2__y))
end

function SF__.Vector2.SqrUnitDistance(a160, b161)
    local v1__x162, v1__y163 = SF__.Vector2.FromUnit(a160)
    local v2__x164, v2__y165 = SF__.Vector2.FromUnit(b161)
    return SF__.Vector2.get_SqrMagnitude(SF__.Vector2.op_Subtraction(v1__x162, v1__y163, v2__x164, v2__y165))
end

function SF__.Vector2.FromUnit(u166)
    return GetUnitX(u166), GetUnitY(u166)
end

function SF__.Vector2.get_Magnitude(self__x167, self__y168)
    return math.sqrt(SF__.Vector2.get_SqrMagnitude(self__x167, self__y168))
end

function SF__.Vector2.get_SqrMagnitude(self__x169, self__y170)
    return ((self__x169 * self__x169) + (self__y170 * self__y170))
end

function SF__.Vector2.get_Normalized(self__x171, self__y172)
    local mag = SF__.Vector2.get_Magnitude(self__x171, self__y172)
    if (mag < 0.0001) then
        return SF__.Vector2.get_Zero()
    end
    return SF__.Vector2.op_Division(self__x171, self__y172, mag)
end

function SF__.Vector2.ClampMagnitude(self__x175, self__y176, mag177)
    return (function()
        local v__x178, v__y179 = SF__.Vector2.get_Normalized(self__x175, self__y176)
        return SF__.Vector2.op_Multiply__ahdf(v__x178, v__y179, mag177)
    end)()
end

function SF__.Vector2.ToString(self__x180, self__y181)
    return SF__.StrConcat__("(", self__x180, ", ", self__y181, ")")
end

function SF__.Vector2.Rotate(self__x182, self__y183, angle184)
    local cos = math.cos(angle184)
    local sin = math.sin(angle184)
    return ((self__x182 * cos) - (self__y183 * sin)), ((self__x182 * sin) + (self__y183 * cos))
end

function SF__.Vector2.UnitMoveTo(self__x185, self__y186, u187)
    SetUnitX(u187, self__x185)
    SetUnitY(u187, self__y186)
end

function SF__.Vector2.GetTerrainZ(self__x188, self__y189)
    MoveLocation(SF__.Vector2._loc, self__x188, self__y189)
    return GetLocationZ(SF__.Vector2._loc)
end

SF__.Vector2._loc = Location(0, 0)

SF__.Program.Main()
