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

function SF__.Vector3.op_Addition(a__x181, a__y182, a__z183, b__x184, b__y185, b__z186)
    return (a__x181 + b__x184), (a__y182 + b__y185), (a__z183 + b__z186)
end

function SF__.Vector3.op_UnaryNegation(a__x187, a__y188, a__z189)
    return (-a__x187), (-a__y188), (-a__z189)
end

function SF__.Vector3.op_Subtraction(a__x190, a__y191, a__z192, b__x193, b__y194, b__z195)
    return (a__x190 - b__x193), (a__y191 - b__y194), (a__z192 - b__z195)
end

function SF__.Vector3.op_Multiply__osef(v__x196, v__y197, v__z198, f199)
    return (v__x196 * f199), (v__y197 * f199), (v__z198 * f199)
end

function SF__.Vector3.op_Multiply__fose(f200, v__x201, v__y202, v__z203)
    return (v__x201 * f200), (v__y202 * f200), (v__z203 * f200)
end

function SF__.Vector3.op_Division(v__x204, v__y205, v__z206, f207)
    return (v__x204 / f207), (v__y205 / f207), (v__z206 / f207)
end

-- <summary>
-- Warcraft III world space here is right-handed: +x points right, +y points away, +z points up.
-- That means Cross((1,0,0), (0,1,0)) == (0,0,1).
-- </summary>
--
function SF__.Vector3.Cross(a__x208, a__y209, a__z210, b__x211, b__y212, b__z213)
    return ((a__y209 * b__z213) - (a__z210 * b__y212)), ((a__z210 * b__x211) - (a__x208 * b__z213)), ((a__x208 * b__y212) - (a__y209 * b__x211))
end

function SF__.Vector3.Distance(a__x214, a__y215, a__z216, b__x217, b__y218, b__z219)
    return SF__.Vector3.get_magnitude(SF__.Vector3.op_Subtraction(a__x214, a__y215, a__z216, b__x217, b__y218, b__z219))
end

function SF__.Vector3.Dot(a__x220, a__y221, a__z222, b__x223, b__y224, b__z225)
    return (((a__x220 * b__x223) + (a__y221 * b__y224)) + (a__z222 * b__z225))
end

function SF__.Vector3.Lerp(a__x226, a__y227, a__z228, b__x229, b__y230, b__z231, t232)
    t232 = math.clamp01(t232)
    return SF__.Vector3.op_Addition(a__x226, a__y227, a__z228, (function()
        local v__x233, v__y234, v__z235 = SF__.Vector3.op_Subtraction(b__x229, b__y230, b__z231, a__x226, a__y227, a__z228)
        return SF__.Vector3.op_Multiply__osef(v__x233, v__y234, v__z235, t232)
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

function SF__.Vector3.Project(v__x236, v__y237, v__z238, onNormal__x, onNormal__y, onNormal__z)
    local sqrMag = SF__.Vector3.Dot(onNormal__x, onNormal__y, onNormal__z, onNormal__x, onNormal__y, onNormal__z)
    if (sqrMag < 0.0001) then
        return SF__.Vector3.get_zero()
    end
    local dot = SF__.Vector3.Dot(v__x236, v__y237, v__z238, onNormal__x, onNormal__y, onNormal__z)
    return SF__.Vector3.op_Multiply__osef(onNormal__x, onNormal__y, onNormal__z, (dot / sqrMag))
end

function SF__.Vector3.ProjectOnPlane(v__x239, v__y240, v__z241, planeNormal__x, planeNormal__y, planeNormal__z)
    return SF__.Vector3.op_Subtraction(v__x239, v__y240, v__z241, SF__.Vector3.Project(v__x239, v__y240, v__z241, planeNormal__x, planeNormal__y, planeNormal__z))
end

function SF__.Vector3.Reflect(inDirection__x, inDirection__y, inDirection__z, inNormal__x, inNormal__y, inNormal__z)
    return SF__.Vector3.op_Subtraction(inDirection__x, inDirection__y, inDirection__z, SF__.Vector3.op_Multiply__fose((2 * SF__.Vector3.Dot(inDirection__x, inDirection__y, inDirection__z, inNormal__x, inNormal__y, inNormal__z)), inNormal__x, inNormal__y, inNormal__z))
end

function SF__.Vector3.RotateTowards(current__x242, current__y243, current__z244, target__x245, target__y246, target__z247, maxRadiansDelta, maxMagnitudeDelta)
    local currentMag = SF__.Vector3.get_magnitude(current__x242, current__y243, current__z244)
    local targetMag = SF__.Vector3.get_magnitude(target__x245, target__y246, target__z247)
    if ((currentMag == 0) or (targetMag == 0)) then
        return SF__.Vector3.MoveTowards(current__x242, current__y243, current__z244, target__x245, target__y246, target__z247, maxMagnitudeDelta)
    end
    local currentNorm__x, currentNorm__y, currentNorm__z = SF__.Vector3.op_Division(current__x242, current__y243, current__z244, currentMag)
    local targetNorm__x, targetNorm__y, targetNorm__z = SF__.Vector3.op_Division(target__x245, target__y246, target__z247, targetMag)
    local dot248 = math.clamp(SF__.Vector3.Dot(currentNorm__x, currentNorm__y, currentNorm__z, targetNorm__x, targetNorm__y, targetNorm__z), (-1), 1)
    local angle249 = math.acos(dot248)
    if (angle249 == 0) then
        return SF__.Vector3.MoveTowards(current__x242, current__y243, current__z244, target__x245, target__y246, target__z247, maxMagnitudeDelta)
    end
    local t250 = math.min(1, (maxRadiansDelta / angle249))
    local newDir__x, newDir__y, newDir__z = SF__.Vector3.Slerp(currentNorm__x, currentNorm__y, currentNorm__z, targetNorm__x, targetNorm__y, targetNorm__z, t250)
    local newMag = math.moveTowards(currentMag, targetMag, maxMagnitudeDelta)
    return SF__.Vector3.op_Multiply__osef(newDir__x, newDir__y, newDir__z, newMag)
end

function SF__.Vector3.Scale(a__x251, a__y252, a__z253, b__x254, b__y255, b__z256)
    return (a__x251 * b__x254), (a__y252 * b__y255), (a__z253 * b__z256)
end

function SF__.Vector3.Slerp(a__x257, a__y258, a__z259, b__x260, b__y261, b__z262, t263)
    local magA = SF__.Vector3.get_magnitude(a__x257, a__y258, a__z259)
    local magB = SF__.Vector3.get_magnitude(b__x260, b__y261, b__z262)
    if ((magA == 0) or (magB == 0)) then
        return SF__.Vector3.MoveTowards(a__x257, a__y258, a__z259, b__x260, b__y261, b__z262, math.huge)
    end
    local normA__x, normA__y, normA__z = SF__.Vector3.op_Division(a__x257, a__y258, a__z259, magA)
    local normB__x, normB__y, normB__z = SF__.Vector3.op_Division(b__x260, b__y261, b__z262, magB)
    local dot264 = math.clamp(SF__.Vector3.Dot(normA__x, normA__y, normA__z, normB__x, normB__y, normB__z), (-1), 1)
    local angle265 = math.acos(dot264)
    local sinAngle = math.sin(angle265)
    if (sinAngle < 0.0001) then
        return SF__.Vector3.MoveTowards(a__x257, a__y258, a__z259, b__x260, b__y261, b__z262, math.huge)
    end
    local tAngle = (angle265 * t263)
    local sinTA = math.sin(tAngle)
    local sinTOneMinusA = math.sin((angle265 - tAngle))
    local newDir__x272, newDir__y273, newDir__z274 = (function()
        local v__x269, v__y270, v__z271 = (function()
            local a__x266, a__y267, a__z268 = SF__.Vector3.op_Multiply__osef(normA__x, normA__y, normA__z, sinTOneMinusA)
            return SF__.Vector3.op_Addition(a__x266, a__y267, a__z268, SF__.Vector3.op_Multiply__osef(normB__x, normB__y, normB__z, sinTA))
        end)()
        return SF__.Vector3.op_Division(v__x269, v__y270, v__z271, sinAngle)
    end)()
    local newMag275 = math.lerp(magA, magB, t263)
    return SF__.Vector3.op_Multiply__osef(newDir__x272, newDir__y273, newDir__z274, newMag275)
end

function SF__.Vector3._getTerrainZ(x276, y277)
    MoveLocation(SF__.Vector3._loc, x276, y277)
    return GetLocationZ(SF__.Vector3._loc)
end

function SF__.Vector3.FromUnit(u278)
    local x279 = GetUnitX(u278)
    local y280 = GetUnitY(u278)
    return x279, y280, (SF__.Vector3._getTerrainZ(x279, y280) + GetUnitFlyHeight(u278))
end

function SF__.Vector3.get_sqrMagnitude(self__x281, self__y282, self__z283)
    return (((self__x281 * self__x281) + (self__y282 * self__y282)) + (self__z283 * self__z283))
end

function SF__.Vector3.get_magnitude(self__x284, self__y285, self__z286)
    return math.sqrt(SF__.Vector3.get_sqrMagnitude(self__x284, self__y285, self__z286))
end

function SF__.Vector3.get_normalized(self__x287, self__y288, self__z289)
    local mag290 = SF__.Vector3.get_magnitude(self__x287, self__y288, self__z289)
    if (mag290 < 0.0001) then
        return SF__.Vector3.get_zero()
    end
    return SF__.Vector3.op_Division(self__x287, self__y288, self__z289, mag290)
end

function SF__.Vector3.ClampMagnitude(self__x294, self__y295, self__z296, mag297)
    return (function()
        local v__x298, v__y299, v__z300 = SF__.Vector3.get_normalized(self__x294, self__y295, self__z296)
        return SF__.Vector3.op_Multiply__osef(v__x298, v__y299, v__z300, mag297)
    end)()
end

function SF__.Vector3.ToString(self__x301, self__y302, self__z303)
    return SF__.StrConcat__("(", self__x301, ", ", self__y302, ", ", self__z303, ")")
end

function SF__.Vector3.UnitMoveTo(self__x304, self__y305, self__z306, u307, mode)
    if mode == nil then mode = SF__.UnitVec3Mode.Auto end
    local tz = SF__.Vector3._getTerrainZ(self__x304, self__y305)
    local LuaUtils = require("Lib.Utils")
    local defaultFlyHeight = GetUnitDefaultFlyHeight(u307)
    local minZ = (tz + defaultFlyHeight)
    SetUnitPosition(u307, self__x304, self__y305)
    repeat
        local switchValue = mode
        if (switchValue == SF__.UnitVec3Mode.ForceFlying) then
            LuaUtils.SetUnitFlyable(u307)
            SetUnitFlyHeight(u307, (math.max(minZ, self__z306) - minZ), 0)
            break
        elseif (switchValue == SF__.UnitVec3Mode.ForceGround) then
            SetUnitFlyHeight(u307, defaultFlyHeight, 0)
            break
        elseif (switchValue == SF__.UnitVec3Mode.Auto) then
            if IsUnitType(u307, UNIT_TYPE_FLYING) then
                SetUnitFlyHeight(u307, (math.max(minZ, self__z306) - minZ), 0)
            else
                SetUnitFlyHeight(u307, defaultFlyHeight, 0)
            end
            break
        end
    until true
end

function SF__.Vector3.GetTerrainZ(self__x308, self__y309, self__z310)
    return SF__.Vector3._getTerrainZ(self__x308, self__y309)
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

function SF__.Quaternion.op_Multiply__iyiose(q__x67, q__y68, q__z69, q__w70, v__x, v__y, v__z)
    -- https://en.wikipedia.org/wiki/Quaternions_and_spatial_rotation#Using_quaternion_as_rotations
    local u__x, u__y, u__z = q__x67, q__y68, q__z69
    local s = q__w70
    return (function()
        local a__x74, a__y75, a__z76 = (function()
            local a__x71, a__y72, a__z73 = SF__.Vector3.op_Multiply__fose((2 * SF__.Vector3.Dot(u__x, u__y, u__z, v__x, v__y, v__z)), u__x, u__y, u__z)
            return SF__.Vector3.op_Addition(a__x71, a__y72, a__z73, SF__.Vector3.op_Multiply__fose(((s * s) - SF__.Vector3.Dot(u__x, u__y, u__z, u__x, u__y, u__z)), v__x, v__y, v__z))
        end)()
        return SF__.Vector3.op_Addition(a__x74, a__y75, a__z76, SF__.Vector3.op_Multiply__fose((2 * s), SF__.Vector3.Cross(u__x, u__y, u__z, v__x, v__y, v__z)))
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
    local x77
    local y78
    local z
    local w
    local trace = ((m00 + m11) + m22)
    if (trace > 0) then
        local s79 = (math.sqrt((trace + 1)) * 2)
        w = (0.25 * s79)
        x77 = ((m21 - m12) / s79)
        y78 = ((m02 - m20) / s79)
        z = ((m10 - m01) / s79)
    elseif ((m00 > m11) and (m00 > m22)) then
        local s80 = (math.sqrt((((1 + m00) - m11) - m22)) * 2)
        w = ((m21 - m12) / s80)
        x77 = (0.25 * s80)
        y78 = ((m01 + m10) / s80)
        z = ((m02 + m20) / s80)
    else
        if (m11 > m22) then
            local s81 = (math.sqrt((((1 + m11) - m00) - m22)) * 2)
            w = ((m02 - m20) / s81)
            x77 = ((m01 + m10) / s81)
            y78 = (0.25 * s81)
            z = ((m12 + m21) / s81)
        else
            local s82 = (math.sqrt((((1 + m22) - m00) - m11)) * 2)
            w = ((m10 - m01) / s82)
            x77 = ((m02 + m20) / s82)
            y78 = ((m12 + m21) / s82)
            z = (0.25 * s82)
        end
    end
    return SF__.Quaternion.Normalize(x77, y78, z, w)
end

function SF__.Quaternion.LookRotation__ose(forward__x83, forward__y84, forward__z85)
    return SF__.Quaternion.LookRotation__oseose(forward__x83, forward__y84, forward__z85, SF__.Vector3.get_up())
end

function SF__.Quaternion.Normalize(q__x86, q__y87, q__z88, q__w89)
    local magnitude = math.sqrt(((((q__x86 * q__x86) + (q__y87 * q__y87)) + (q__z88 * q__z88)) + (q__w89 * q__w89)))
    if (magnitude < 0.0001) then
        return SF__.Quaternion.get_identity()
    end
    return (q__x86 / magnitude), (q__y87 / magnitude), (q__z88 / magnitude), (q__w89 / magnitude)
end

function SF__.Quaternion.get_eulerAngles(self__x, self__y, self__z, self__w)
    -- https://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles#Source_Code_2
    local sinr_cosp = (2 * ((self__w * self__x) + (self__y * self__z)))
    local cosr_cosp = (1 - (2 * ((self__x * self__x) + (self__y * self__y))))
    local roll90 = math.atan(sinr_cosp, cosr_cosp)
    local sinp = (2 * ((self__w * self__y) - (self__z * self__x)))
    local pitch91
    if (math.abs(sinp) >= 1) then
        pitch91 = ((math.sign(sinp) * math.pi) / 2)
        -- use 90 degrees if out of range
    else
        pitch91 = math.asin(sinp)
    end
    local siny_cosp = (2 * ((self__w * self__z) + (self__x * self__y)))
    local cosy_cosp = (1 - (2 * ((self__y * self__y) + (self__z * self__z))))
    local yaw92 = math.atan(siny_cosp, cosy_cosp)
    return (pitch91 * bj_RADTODEG), (yaw92 * bj_RADTODEG), (roll90 * bj_RADTODEG)
end

function SF__.Quaternion.get_normalized(self__x93, self__y94, self__z95, self__w96)
    return SF__.Quaternion.Normalize(self__x93, self__y94, self__z95, self__w96)
end

function SF__.Quaternion.Inverse(rotation__x, rotation__y, rotation__z, rotation__w)
    return (-rotation__x), (-rotation__y), (-rotation__z), rotation__w
end

function SF__.Quaternion.ToString(self__x101, self__y102, self__z103, self__w104)
    return SF__.StrConcat__("(", self__x101, ", ", self__y102, ", ", self__z103, ", ", self__w104, ")")
end

function SF__.Quaternion.ApplyToEffect(self__x105, self__y106, self__z107, self__w108, e)
    local angles__x, angles__y, angles__z = SF__.Quaternion.get_eulerAngles(self__x105, self__y106, self__z107, self__w108)
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
        for _, item537 in (SF__.StdLib.List.IpairsNext)(collection1) do
            table.insert(self._items, item537)
            self.Count = (self.Count + 1)
        end
    end
end

function SF__.StdLib.List.New__xqm20z(collection)
    local self = setmetatable({}, { __index = SF__.StdLib.List })
    SF__.StdLib.List.__Init__xqm20z(self, collection)
    return self
end

function SF__.StdLib.List:get_Item(index538)
    if ((index538 < 0) or (index538 >= self.Count)) then
        error(SF__.StrConcat__("SF__E2e5944b8", "Index out of range"))
    end
    return self._items[(index538 + 1)]
end

function SF__.StdLib.List:set_Item(index539, value540)
    if ((index539 < 0) or (index539 >= self.Count)) then
        error(SF__.StrConcat__("SF__E2e5944b8", "Index out of range"))
    end
    self._items[(index539 + 1)] = value540
end

function SF__.StdLib.List:AddRange(collection541)
    do
        local collection2 = collection541
        for _, item542 in (SF__.StdLib.List.IpairsNext)(collection2) do
            table.insert(self._items, item542)
            self.Count = (self.Count + 1)
        end
    end
    self._version = (self._version + 1)
end

function SF__.StdLib.List:Add(item543)
    table.insert(self._items, item543)
    self.Count = (self.Count + 1)
    self._version = (self._version + 1)
end

function SF__.StdLib.List:Clear()
    self._items = {}
    self.Count = 0
    self._version = (self._version + 1)
end

function SF__.StdLib.List:Remove(item544)
    local index545 = self:IndexOf(item544)
    if (index545 < 0) then
        return false
    end
    self:RemoveAt(index545)
    return true
end

function SF__.StdLib.List:RemoveAt(index546)
    table.remove(self._items, (index546 + 1))
    self.Count = (self.Count - 1)
    self._version = (self._version + 1)
end

function SF__.StdLib.List:IndexOf(item547)
    do
        local i548 = 0
        while (i548 < self.Count) do
            local current549 = self._items[(i548 + 1)]
            if (current549 == item547) then
                return i548
            end
            ::continue::
            i548 = (i548 + 1)
        end
    end
    return (-1)
end

function SF__.StdLib.List.DefaultCompare(a550, b551)
    if (a550 == b551) then
        return 0
    end
    if (a550 < b551) then
        return (-1)
    end
    return 1
end

function SF__.StdLib.List:Sort(comparison)
    if (comparison == nil) then
        comparison = SF__.StdLib.List.DefaultCompare
    end
    local version552 = self._version
    table.sort(self._items, function(a555, b556)
        return (comparison(a555, b556) < 0)
    end)
    if (version552 ~= self._version) then
        error(SF__.StrConcat__("SF__E2e5944b8", "Collection was modified"))
    end
    self._version = (self._version + 1)
end

function SF__.StdLib.List:IpairsNext()
    local version557 = self._version
    local index558 = 0
    return function()
        if (version557 ~= self._version) then
            error(SF__.StrConcat__("SF__E2e5944b8", "Collection was modified"))
        end
        index558 = (index558 + 1)
        local value559 = self._items[index558]
        if (value559 == nil) then
            return nil
        end
        return index558, value559
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
    local globalPos__x9, globalPos__y10, globalPos__z11 = self.localPosition__x, self.localPosition__y, self.localPosition__z
    local globalRot__x12, globalRot__y13, globalRot__z14, globalRot__w15 = self.localRotation__x, self.localRotation__y, self.localRotation__z, self.localRotation__w
    local globalScale__x16, globalScale__y17, globalScale__z18 = self.localScale__x, self.localScale__y, self.localScale__z
    local myParent = self.parent
    while (myParent ~= nil) do
        globalPos__x9, globalPos__y10, globalPos__z11 = SF__.Vector3.op_Addition(myParent.localPosition__x, myParent.localPosition__y, myParent.localPosition__z, SF__.Quaternion.op_Multiply__iyiose(myParent.localRotation__x, myParent.localRotation__y, myParent.localRotation__z, myParent.localRotation__w, SF__.Vector3.Scale(myParent.localScale__x, myParent.localScale__y, myParent.localScale__z, globalPos__x9, globalPos__y10, globalPos__z11)))
        globalRot__x12, globalRot__y13, globalRot__z14, globalRot__w15 = SF__.Quaternion.op_Multiply__iyiiyi(myParent.localRotation__x, myParent.localRotation__y, myParent.localRotation__z, myParent.localRotation__w, globalRot__x12, globalRot__y13, globalRot__z14, globalRot__w15)
        globalScale__x16, globalScale__y17, globalScale__z18 = SF__.Vector3.Scale(myParent.localScale__x, myParent.localScale__y, myParent.localScale__z, globalScale__x16, globalScale__y17, globalScale__z18)
        myParent = myParent.parent
        ::continue::
    end
    return globalPos__x9, globalPos__y10, globalPos__z11
end

function SF__.Transform:set_position(value__x, value__y, value__z)
    if (self.parent == nil) then
        self.localPosition__x, self.localPosition__y, self.localPosition__z = value__x, value__y, value__z
        return
    end
    local pos__x, pos__y, pos__z = value__x, value__y, value__z
    local myParent19 = self.parent
    while (myParent19 ~= nil) do
        pos__x, pos__y, pos__z = SF__.Vector3.op_Subtraction(pos__x, pos__y, pos__z, myParent19.localPosition__x, myParent19.localPosition__y, myParent19.localPosition__z)
        pos__x, pos__y, pos__z = SF__.Vector3.Scale((1 / myParent19.localScale__x), (1 / myParent19.localScale__y), (1 / myParent19.localScale__z), pos__x, pos__y, pos__z)
        pos__x, pos__y, pos__z = (function()
            local q__x, q__y, q__z, q__w = SF__.Quaternion.Inverse(myParent19.localRotation__x, myParent19.localRotation__y, myParent19.localRotation__z, myParent19.localRotation__w)
            return SF__.Quaternion.op_Multiply__iyiose(q__x, q__y, q__z, q__w, pos__x, pos__y, pos__z)
        end)()
        myParent19 = myParent19.parent
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
    local parts20 = SF__.StrSplit__(name, "/")
    return SF__.Transform._Find(self, parts20, 0)
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
        for _, child21 in (SF__.StdLib.List.IpairsNext)(collection4) do
            SF__.GameObject.MarkDestroyQueuedDepthFirst(child21.gameObject)
        end
    end
end

function SF__.GameObject.DestroyDepthFirst(obj22)
    if obj22.isDestroyed then
        return
    end
    local children = obj22.transform.children
    do
        local i = (children.Count - 1)
        while (i >= 0) do
            SF__.GameObject.DestroyDepthFirst(children:get_Item(i).gameObject)
            ::continue::
            i = (i - 1)
        end
    end
    obj22.transform:SetParent(nil)
    do
        local collection5 = obj22._components
        for _, comp in (SF__.StdLib.List.IpairsNext)(collection5) do
            comp:OnDisable()
            comp:OnDestroy()
        end
    end
    obj22._components:Clear()
    SF__.Scene.get_Instance().gameObjs:Remove(obj22)
    obj22.isDestroyed = true
end

function SF__.GameObject:get_components()
    return self._components
end

function SF__.GameObject.__Init__s(self, name23)
    self.__sf_type = SF__.GameObject
    self.name = nil
    self.transform = nil
    self._components = SF__.StdLib.List.New__0()
    self.isDestroyQueued = false
    self.isDestroyed = false
    self.name = name23
    self.transform = self:AddComponent(SF__.Transform)
    SF__.Scene.get_Instance():AddGameObject(self)
end

function SF__.GameObject.New__s(name23)
    local self = setmetatable({}, { __index = SF__.GameObject })
    SF__.GameObject.__Init__s(self, name23)
    return self
end

function SF__.GameObject.__Init__sx13(self, name24, parent25)
    SF__.GameObject.__Init__s(self, name24)
    self.transform:SetParent(parent25.transform)
end

function SF__.GameObject.New__sx13(name24, parent25)
    local self = setmetatable({}, { __index = SF__.GameObject })
    SF__.GameObject.__Init__sx13(self, name24, parent25)
    return self
end

function SF__.GameObject:GetComponent(T)
    do
        local collection6 = self._components
        for _, comp26 in (SF__.StdLib.List.IpairsNext)(collection6) do
            do
                local tComp = comp26
                if SF__.TypeIs__(tComp, T) then
                    return tComp
                end
            end
        end
    end
    return nil
end

function SF__.GameObject:AddComponent(T27)
    local comp28 = (function()
        local obj29 = T27.New()
        obj29.gameObject = self
        return obj29
    end)()
    self._components:Add(comp28)
    comp28:Awake()
    comp28:OnEnable()
    comp28:Start()
    return comp28
end

function SF__.GameObject:RemoveAllComponents(T30)
    do
        local i31 = (self._components.Count - 1)
        while (i31 >= 0) do
            if SF__.TypeIs__(self._components:get_Item(i31), T30) then
                self._components:get_Item(i31):OnDisable()
                self._components:get_Item(i31):OnDestroy()
                self._components:RemoveAt(i31)
            end
            ::continue::
            i31 = (i31 - 1)
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
        for _, comp32 in (SF__.StdLib.List.IpairsNext)(collection7) do
            comp32:Update()
        end
    end
end

function SF__.GameObject:LateUpdate()
    if (self.isDestroyQueued or self.isDestroyed) then
        return
    end
    local snapshot33 = SF__.StdLib.List.New__xqm20z(self._components)
    do
        local collection8 = snapshot33
        for _, comp34 in (SF__.StdLib.List.IpairsNext)(collection8) do
            comp34:LateUpdate()
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

function SF__.GameObject.DestroyQueued(obj35)
    SF__.GameObject.DestroyDepthFirst(obj35)
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

function SF__.Scene:AddGameObject(obj36)
    self.gameObjs:Add(obj36)
end

function SF__.Scene:QueueDestroy(obj37)
    self._destroyQueue:Add(obj37)
end

function SF__.Scene:FlushDestroyQueue()
    do
        local i38 = 0
        while (i38 < self._destroyQueue.Count) do
            SF__.GameObject.DestroyQueued(self._destroyQueue:get_Item(i38))
            ::continue::
            i38 = (i38 + 1)
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
                local i39 = 0
                while (i39 < count) do
                    self.gameObjs:get_Item(i39):Update()
                    ::continue::
                    i39 = (i39 + 1)
                end
            end
            do
                local i40 = 0
                while (i40 < count) do
                    self.gameObjs:get_Item(i40):LateUpdate()
                    ::continue::
                    i40 = (i40 + 1)
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

function SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p110, abilCode111, researchExtendedTooltip, level112)
    if (GetLocalPlayer() ~= p110) then
        return
    end
    BlzSetAbilityResearchExtendedTooltip(abilCode111, researchExtendedTooltip, level112)
end

function SF__.Utils.ExBlzSetAbilityTooltip(p113, abilCode114, tooltip, level115)
    if (GetLocalPlayer() ~= p113) then
        return
    end
    BlzSetAbilityTooltip(abilCode114, tooltip, level115)
end

function SF__.Utils.ExBlzSetAbilityExtendedTooltip(p116, abilCode117, extendedTooltip, level118)
    if (GetLocalPlayer() ~= p116) then
        return
    end
    BlzSetAbilityExtendedTooltip(abilCode117, extendedTooltip, level118)
end

function SF__.Utils.ExBlzSetAbilityIcon(p119, abilCode120, iconPath)
    if (GetLocalPlayer() ~= p119) then
        return
    end
    BlzSetAbilityIcon(abilCode120, iconPath)
end

function SF__.Utils.CsGroupGetUnitsInRange(x121, y122, radius, filter)
    local result = SF__.StdLib.List.New__0()
    ExGroupEnumUnitsInRange(x121, y122, radius, function(u124)
        if filter(u124) then
            result:Add(u124)
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
function SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(u453, amount)
    local UnitAttribute455 = require("Objects.UnitAttribute")
    local attr454 = UnitAttribute455.GetAttr(u453)
    attr454.retPalHolyEnergy = math.min((attr454.retPalHolyEnergy + amount), 5)
end

function SF__.RetributionPaladinGlobal:Init()
    ExTriggerRegisterNewUnit(function(u457)
        if (GetUnitTypeId(u457) == FourCC("Hpal")) then
            self._units:Add(u457)
        end
    end)
    _ = self:Start()
end

function SF__.RetributionPaladinGlobal:Start()
    return SF__.CorRun__(function()
        local UnitAttribute460 = require("Objects.UnitAttribute")
        while true do
            do
                local collection9 = self._units
                for _, u458 in (SF__.StdLib.List.IpairsNext)(collection9) do
                    local attr459 = UnitAttribute460.GetAttr(u458)
                    ExSetUnitMana(u458, ((ExGetUnitMaxMana(u458) * attr459.retPalHolyEnergy) * 0.2))
                    if (attr459.retPalHolyEnergy >= 3) then
                        SF__.Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u458), FourCC("A006"), "ReplaceableTextures/CommandButtons/BTNinv_helmet_96.tga")
                    else
                        SF__.Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u458), FourCC("A006"), "ReplaceableTextures/PassiveButtons/PASBTNinv_helmet_96.tga")
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
function SF__.BladeOfJustice.GetAbilityData(level311)
    return (75 * level311), 5, (10 * level311)
end

function SF__.BladeOfJustice.Init()
    local EventCenter = require("Lib.EventCenter")
    EventCenter.RegisterPlayerUnitSpellEffect:Emit({id = SF__.BladeOfJustice.ID, handler = SF__.BladeOfJustice.Start})
    ExTriggerRegisterNewUnit(function(u313)
        if (GetUnitTypeId(u313) == FourCC("Hpal")) then
            SF__.BladeOfJustice.UpdateAbilityMeta(u313)
        end
    end)
end

function SF__.BladeOfJustice.UpdateAbilityMeta(u314)
    local p315 = GetOwningPlayer(u314)
    local datas = SF__.StdLib.List.New__0()
    do
        local i316 = 0
        while (i316 < 3) do
            local __pack_Damage, __pack_Duration, __pack_DamagePerSecond = SF__.BladeOfJustice.GetAbilityData((i316 + 1))
            datas:Add({Damage = __pack_Damage, Duration = __pack_Duration, DamagePerSecond = __pack_DamagePerSecond})
            ::continue::
            i316 = (i316 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p315, SF__.BladeOfJustice.ID, "学习公正之剑 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p315, SF__.BladeOfJustice.ID, SF__.StrConcat__("用圣光的利刃刺穿目标，造成法术伤害，在一定时间内对附近敌人每秒造成光辉伤害。产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 10秒\n\n|cffffcc001级|r - 造成|cffff8c00", datas:get_Item(0).Damage, "|r的直接法术伤害，|cffff8c00", datas:get_Item(0).Duration, "|r秒内对附近敌人每秒造成|cffff8c00", datas:get_Item(0).DamagePerSecond, "|r的光辉伤害。产生|cffff8c001|r点圣能。\n|cffffcc002级|r - 造成|cffff8c00", datas:get_Item(1).Damage, "|r的直接法术伤害，|cffff8c00", datas:get_Item(1).Duration, "|r秒内对附近敌人每秒造成|cffff8c00", datas:get_Item(1).DamagePerSecond, "|r的光辉伤害。产生|cffff8c001|r点圣能。\n|cffffcc003级|r - 造成|cffff8c00", datas:get_Item(2).Damage, "|r的直接法术伤害，|cffff8c00", datas:get_Item(2).Duration, "|r秒内对附近敌人每秒造成|cffff8c00", datas:get_Item(2).DamagePerSecond, "|r的光辉伤害。产生|cffff8c001|r点圣能。"), 0)
    do
        local i317 = 0
        while (i317 < 3) do
            local __unpack_tmp = datas:get_Item(i317)
            local data__Damage, data__Duration, data__DamagePerSecond = __unpack_tmp.Damage, __unpack_tmp.Duration, __unpack_tmp.DamagePerSecond
            SF__.Utils.ExBlzSetAbilityTooltip(p315, SF__.BladeOfJustice.ID, SF__.StrConcat__("公正之剑 - [|cffffcc00", (i317 + 1), "级|r]"), i317)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p315, SF__.BladeOfJustice.ID, SF__.StrConcat__("用圣光的利刃刺穿目标，造成|cffff8c00", data__Damage, "|r的直接法术伤害，在|cffff8c00", data__Duration, "|r秒内对附近敌人每秒造成|cffff8c00", data__DamagePerSecond, "|r的光辉伤害。产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 10秒"), i317)
            ::continue::
            i317 = (i317 + 1)
        end
    end
end

function SF__.BladeOfJustice.Start(data)
    local level318 = GetUnitAbilityLevel(data.caster, SF__.BladeOfJustice.ID)
    local EventCenter319 = require("Lib.EventCenter")
    local ad__Damage, ad__Duration, ad__DamagePerSecond = SF__.BladeOfJustice.GetAbilityData(level318)
    EventCenter319.Damage:Emit({whichUnit = data.caster, target = data.target, amount = ad__Damage, attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
    SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(data.caster, 1)
    SF__.BladeOfJustice.New():StartGroudDamage(data.caster, data.target, ad__Damage, ad__Duration, ad__DamagePerSecond)
end

function SF__.BladeOfJustice:StartGroudDamage(caster, target320, ad__Damage321, ad__Duration322, ad__DamagePerSecond323)
    return SF__.CorRun__(function()
        local pos__x324, pos__y325 = SF__.Vector2.FromUnit(target320)
        local UnitAttribute = require("Objects.UnitAttribute")
        local EventCenter330 = require("Lib.EventCenter")
        local eff326 = ExAddSpecialEffect("Abilities/Spells/Orc/LiquidFire/Liquidfire.mdl", pos__x324, pos__y325, ad__Duration322)
        local p327 = GetOwningPlayer(caster)
        do
            local i328 = 0
            while (i328 < ad__Duration322) do
                SF__.CorWait__(1000)
                ExGroupEnumUnitsInRange(pos__x324, pos__y325, 300, function(u331)
                    if (not IsUnitEnemy(u331, p327)) then
                        return
                    end
                    if ExIsUnitDead(u331) then
                        return
                    end
                    local tarAttr332 = UnitAttribute.GetAttr(u331)
                    local damage333 = (ad__DamagePerSecond323 * (1 - tarAttr332.radiantResistance))
                    EventCenter330.Damage:Emit({whichUnit = caster, target = u331, amount = damage333, attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
                end)
                ::continue::
                i328 = (i328 + 1)
            end
        end
        DestroyEffect(eff326)
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
function SF__.CrusaderStrike.GetAbilityData(level334)
    return (0.65 + (0.35 * level334)), (0.15 * (level334 - 1))
end

function SF__.CrusaderStrike.Init()
    local EventCenter335 = require("Lib.EventCenter")
    EventCenter335.RegisterPlayerUnitSpellEffect:Emit({id = SF__.CrusaderStrike.ID, handler = SF__.CrusaderStrike.Start})
    ExTriggerRegisterNewUnit(function(u337)
        if (GetUnitTypeId(u337) == FourCC("Hpal")) then
            SF__.CrusaderStrike.UpdateAbilityMeta(u337)
        end
    end)
end

function SF__.CrusaderStrike.UpdateAbilityMeta(u338)
    local p339 = GetOwningPlayer(u338)
    local datas340 = SF__.StdLib.List.New__0()
    do
        local i341 = 0
        while (i341 < 3) do
            local __pack_DamageScaling, __pack_ArtOfWarChance = SF__.CrusaderStrike.GetAbilityData((i341 + 1))
            datas340:Add({DamageScaling = __pack_DamageScaling, ArtOfWarChance = __pack_ArtOfWarChance})
            ::continue::
            i341 = (i341 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p339, SF__.CrusaderStrike.ID, "学习十字军打击 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p339, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击造成一次攻击伤害，伤害系数随技能等级提升。产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 6秒\n\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas340:get_Item(0).DamageScaling * 100)), "%|r的攻击伤害。\n|cffffcc002级|r - |cffff8c00", string.format("%.0f", (datas340:get_Item(1).DamageScaling * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas340:get_Item(1).ArtOfWarChance * 100)), "%的战争艺术触发几率。\n|cffffcc003级|r - |cffff8c00", string.format("%.0f", (datas340:get_Item(2).DamageScaling * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas340:get_Item(2).ArtOfWarChance * 100)), "%的战争艺术触发几率。"), 0)
    do
        local i342 = 0
        while (i342 < 3) do
            local __unpack_tmp343 = datas340:get_Item(i342)
            local data__DamageScaling, data__ArtOfWarChance = __unpack_tmp343.DamageScaling, __unpack_tmp343.ArtOfWarChance
            SF__.Utils.ExBlzSetAbilityTooltip(p339, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击 - [|cffffcc00", (i342 + 1), "级|r]"), i342)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p339, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击造成一次攻击伤害，造成|cffff8c00", string.format("%.0f", (data__DamageScaling * 100)), "%|r的攻击伤害", (function() if (i342 > 0) then return SF__.StrConcat__("，", string.format("%.0f", (data__ArtOfWarChance * 100)), "%的战争艺术触发几率") else return "" end end)(), "。产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 6秒"), i342)
            ::continue::
            i342 = (i342 + 1)
        end
    end
    -- datas.Remove(new IAbilityData { DamageScaling = 0.65f, ArtOfWarChance = 0 });
    datas340:RemoveAt(0)
end

function SF__.CrusaderStrike.Start(data344)
    local level345 = GetUnitAbilityLevel(data344.caster, SF__.CrusaderStrike.ID)
    local UnitAttribute346 = require("Objects.UnitAttribute")
    local EventCenter348 = require("Lib.EventCenter")
    local ad__DamageScaling, ad__ArtOfWarChance = SF__.CrusaderStrike.GetAbilityData(level345)
    local attr = UnitAttribute346.GetAttr(data344.caster)
    local damage347 = (attr:SimAttack(UnitAttribute346.HeroAttributeType.Strength) * ad__DamageScaling)
    EventCenter348.Damage:Emit({whichUnit = data344.caster, target = data344.target, amount = damage347, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
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

function SF__.Missile:SetupUnitTarget(target, speed, onArrived, colliderSize, lookAtTarget)
    if colliderSize == nil then colliderSize = 32 end
    if lookAtTarget == nil then lookAtTarget = true end
    self.targetType = SF__.TargetType.Unit
    self.unitTarget = target
    self.speed = speed
    self.lookAtTarget = lookAtTarget
    self.colliderSize = colliderSize
    self.onArrivedUnit = onArrived
    self.hasArrived = false
end

function SF__.Missile:SetupPiercer(onThrough, onThroughFilter, colliderSize8, collisionCount, nextHitDelay)
    self.targetType = SF__.TargetType.None
    self.unitTarget = nil
    self.colliderSize = colliderSize8
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
-- DivineToll
SF__.DivineToll = SF__.DivineToll or {}
SF__.DivineToll.Name = "DivineToll"
SF__.DivineToll.FullName = "DivineToll"
function SF__.DivineToll.GetAbilityData(level349)
    return (2 + level349), (50 * level349), 0.1, 10, (20 * level349), 0
end

function SF__.DivineToll.Init()
    local EventCenter352 = require("Lib.EventCenter")
    EventCenter352.RegisterPlayerUnitSpellEffect:Emit({id = SF__.DivineToll.ID, handler = function(data351)
        SF__.DivineToll.Start(data351)
    end})
    ExTriggerRegisterNewUnit(function(u354)
        if (GetUnitTypeId(u354) == FourCC("Hpal")) then
            SF__.DivineToll.UpdateAbilityMeta(u354)
        end
    end)
end

function SF__.DivineToll.UpdateAbilityMeta(u355)
    local p356 = GetOwningPlayer(u355)
    local datas357 = SF__.StdLib.List.New__0()
    do
        local i358 = 0
        while (i358 < 3) do
            local __pack_TargetCount, __pack_Damage359, __pack_RadiantDmgAmp, __pack_Duration360, __pack_BHDamage, __pack_DebuffDuration = SF__.DivineToll.GetAbilityData((i358 + 1))
            datas357:Add({TargetCount = __pack_TargetCount, Damage = __pack_Damage359, RadiantDmgAmp = __pack_RadiantDmgAmp, Duration = __pack_Duration360, BHDamage = __pack_BHDamage, DebuffDuration = __pack_DebuffDuration})
            ::continue::
            i358 = (i358 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p356, SF__.DivineToll.ID, "学习圣洁鸣钟 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p356, SF__.DivineToll.ID, SF__.StrConcat__("对附近的多个目标施展审判，造成法术伤害，然后神圣之锤环绕圣殿骑士，每次命中敌人使其受到的光辉伤害提高。每个审判产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 30秒\n\n|cffffcc001级|r - 审判最多|cffff8c00", datas357:get_Item(0).TargetCount, "|r个目标，造成|cffff8c00", datas357:get_Item(0).Damage, "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas357:get_Item(0).RadiantDmgAmp * 100)), "%|r的光辉易伤，持续|cffff8c00", datas357:get_Item(0).Duration, "|r秒。\n|cffffcc002级|r - 审判最多|cffff8c00", datas357:get_Item(1).TargetCount, "|r个目标，造成|cffff8c00", datas357:get_Item(1).Damage, "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas357:get_Item(1).RadiantDmgAmp * 100)), "%|r的光辉易伤，持续|cffff8c00", datas357:get_Item(1).Duration, "|r秒。\n|cffffcc003级|r - 审判最多|cffff8c00", datas357:get_Item(2).TargetCount, "|r个目标，造成|cffff8c00", datas357:get_Item(2).Damage, "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas357:get_Item(2).RadiantDmgAmp * 100)), "%|r的光辉易伤，持续|cffff8c00", datas357:get_Item(2).Duration, "|r秒。"), 0)
    do
        local i361 = 0
        while (i361 < 3) do
            local __unpack_tmp364 = datas357:get_Item(i361)
            local data__TargetCount, data__Damage362, data__RadiantDmgAmp, data__Duration363, data__BHDamage, data__DebuffDuration = __unpack_tmp364.TargetCount, __unpack_tmp364.Damage, __unpack_tmp364.RadiantDmgAmp, __unpack_tmp364.Duration, __unpack_tmp364.BHDamage, __unpack_tmp364.DebuffDuration
            SF__.Utils.ExBlzSetAbilityTooltip(p356, SF__.DivineToll.ID, SF__.StrConcat__("圣洁鸣钟 - [|cffffcc00", (i361 + 1), "级|r]"), i361)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p356, SF__.DivineToll.ID, SF__.StrConcat__("对附近的最多|cffff8c00", data__TargetCount, "|r个目标施展审判，造成|cffff8c00", data__Damage362, "|r点法术伤害，然后神圣之锤环绕圣殿骑士，每次命中敌人使其受到的光辉伤害提高|cffff8c00", string.format("%.0f", (data__RadiantDmgAmp * 100)), "%|r，持续|cffff8c00", data__Duration363, "|r秒。每个审判产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 30秒"), i361)
            ::continue::
            i361 = (i361 + 1)
        end
    end
end

function SF__.DivineToll.HurlToTarget(caster365, target366, pos__x367, pos__y368, pos__z369)
    local outer = SF__.GameObject.New__s("DivineToll_Outer")
    local EventCenter376 = require("Lib.EventCenter")
    local UnitAttribute382 = require("Objects.UnitAttribute")
    outer.transform.localPosition__x, outer.transform.localPosition__y, outer.transform.localPosition__z = 0, 0, 80
    local moveLayer = SF__.GameObject.New__sx13("MoveLayer", outer)
    moveLayer.transform.localPosition__x, moveLayer.transform.localPosition__y, moveLayer.transform.localPosition__z = pos__x367, pos__y368, pos__z369
    local missile = moveLayer:AddComponent(SF__.Missile)
    missile:SetupUnitTarget(target366, 900, function(mis394, tar395)
        local cPos__x396, cPos__y397, cPos__z398 = mis394.gameObject.transform:get_position()
        local eff399 = ExAddSpecialEffect("Abilities/Spells/Human/StormBolt/StormBoltMissile.mdl", cPos__x396, cPos__y397, 0.1)
        BlzSetSpecialEffectColor(eff399, 255, 255, 0)
        local ad__TargetCount400, ad__Damage401, ad__RadiantDmgAmp402, ad__Duration403, ad__BHDamage404, ad__DebuffDuration405 = SF__.DivineToll.GetAbilityData(GetUnitAbilityLevel(caster365, SF__.DivineToll.ID))
        EventCenter376.Damage:Emit({whichUnit = caster365, target = tar395, amount = ad__Damage401, attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
        SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(caster365, 1)
        -- setup new missile
        mis394:SetupPiercer(function(m415, u416)
            local cPos__x417, cPos__y418, cPos__z419 = m415.gameObject.transform:get_position()
            ExAddSpecialEffectTarget("Abilities/Weapons/FaerieDragonMissile/FaerieDragonMissile.mdl", u416, "origin", 0.1)
            local tarAttr420 = UnitAttribute382.GetAttr(u416)
            local damage421 = (ad__BHDamage404 * (1 - tarAttr420.radiantResistance))
            EventCenter376.Damage:Emit({whichUnit = caster365, target = u416, amount = damage421, attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
            local debuff422 = SF__.DivineToll.RadiantVulnerability.New(caster365, u416, ad__DebuffDuration405, 0.5, {level = 1, charged = 0})
        end, function(u423)
            if (not IsUnitEnemy(u423, GetOwningPlayer(caster365))) then
                return false
            end
            if IsUnitType(u423, UNIT_TYPE_STRUCTURE) then
                return false
            end
            if ExIsUnitDead(u423) then
                return false
            end
            return true
        end, 50, 9999, 0.3)
        -- change movement behaviour
        local aec1424 = moveLayer.transform:Find("DivineToll_Bolt/dt_hand/dt_mis").gameObject:GetComponent(SF__.AttachEffectComponent)
        aec1424:LerpIn(1300)
        local aec2425 = aec1424.gameObject.transform:Find("DivineToll_Holy").gameObject:GetComponent(SF__.AttachEffectComponent)
        aec2425:LerpIn(1300)
        local casterPos__x426, casterPos__y427, casterPos__z428 = SF__.Vector3.FromUnit(caster365)
        local circulator429 = SF__.GameObject.New__sx13("Circulator", outer)
        circulator429.transform.localPosition__x, circulator429.transform.localPosition__y, circulator429.transform.localPosition__z = casterPos__x426, casterPos__y427, casterPos__z428
        local rot430 = circulator429:AddComponent(SF__.AutoTRSComponent)
        rot430.rotation__x, rot430.rotation__y, rot430.rotation__z, rot430.rotation__w = SF__.Quaternion.Euler(0, ((300 * SF__.Scene.DT) / 1000), 0)
        rot430.followUnit = caster365
        moveLayer.transform:SetParent(circulator429.transform)
        moveLayer.transform.localPosition__x, moveLayer.transform.localPosition__y, moveLayer.transform.localPosition__z = 200, 0, 0
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
    local eff431 = AddSpecialEffect("Abilities/Spells/Human/StormBolt/StormBoltMissile.mdl", pos__x367, pos__y368)
    boltMis:AddComponent(SF__.AttachEffectComponent):AttachEffect(eff431)
    local attachedHoly = SF__.GameObject.New__sx13("DivineToll_Holy", boltMis)
    attachedHoly.transform.localPosition__x, attachedHoly.transform.localPosition__y, attachedHoly.transform.localPosition__z = 15, 0, 0
    local effHoly = AddSpecialEffect("Abilities/Weapons/FaerieDragonMissile/FaerieDragonMissile.mdl", pos__x367, pos__y368)
    attachedHoly:AddComponent(SF__.AttachEffectComponent):AttachEffect(effHoly)
    BlzSetSpecialEffectColor(effHoly, 20, 20, 20)
end

function SF__.DivineToll.Start(data432)
    return SF__.CorRun__(function()
        local pos__x433, pos__y434, pos__z435 = SF__.Vector3.FromUnit(data432.caster)
        local targets = SF__.Utils.CsGroupGetUnitsInRange(pos__x433, pos__y434, 600, function(u436)
            if (not IsUnitEnemy(u436, GetOwningPlayer(data432.caster))) then
                return false
            end
            if IsUnitType(u436, UNIT_TYPE_STRUCTURE) then
                return false
            end
            if ExIsUnitDead(u436) then
                return false
            end
            return true
        end)
        if (targets.Count == 0) then
            return
        end
        targets:Sort(function(a439, b440)
            local distA441 = SF__.Vector3.Distance(pos__x433, pos__y434, pos__z435, SF__.Vector3.FromUnit(a439))
            local distB442 = SF__.Vector3.Distance(pos__x433, pos__y434, pos__z435, SF__.Vector3.FromUnit(b440))
            return (function() if (distA441 == distB442) then return 0 else return (function() if (distA441 < distB442) then return (-1) else return 1 end end)() end end)()
        end)
        do
            local i443 = 0
            while (i443 < (function()
                local field__TargetCount, field__Damage, field__RadiantDmgAmp, field__Duration, field__BHDamage, field__DebuffDuration = SF__.DivineToll.GetAbilityData(GetUnitAbilityLevel(data432.caster, SF__.DivineToll.ID))
                return math.min(targets.Count, field__TargetCount)
            end)()) do
                SF__.DivineToll.HurlToTarget(data432.caster, targets:get_Item(i443), pos__x433, pos__y434, pos__z435)
                SF__.CorWait__(200)
                ::continue::
                i443 = (i443 + 1)
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
SF__.DivineToll = SF__.DivineToll or {}
-- DivineToll.RadiantVulnerability
local BuffBase = require("Objects.BuffBase")
SF__.DivineToll.RadiantVulnerability = SF__.DivineToll.RadiantVulnerability or class("RadiantVulnerability", BuffBase)
SF__.DivineToll.RadiantVulnerability.Name = "RadiantVulnerability"
SF__.DivineToll.RadiantVulnerability.FullName = "DivineToll.RadiantVulnerability"
SF__.DivineToll.RadiantVulnerability.__sf_base = BuffBase
function SF__.DivineToll.RadiantVulnerability.__Init(self, caster444, target445, duration446, interval, awakeData)
    SF__.LuaWrapper.BuffBase.__Init(self, caster444, target445, duration446, interval, awakeData)
    self.__sf_type = SF__.DivineToll.RadiantVulnerability
    self._spec = 0
    self._spec = 15
end

function SF__.DivineToll.RadiantVulnerability.New(caster444, target445, duration446, interval, awakeData)
    local self = SF__.DivineToll.RadiantVulnerability.new(caster444, target445, duration446, interval, awakeData)
    SF__.DivineToll.RadiantVulnerability.__Init(self, caster444, target445, duration446, interval, awakeData)
    return self
end

function SF__.DivineToll.RadiantVulnerability:Awake()
    SF__.LuaWrapper.BuffBase.Awake(self)
    local ad__TargetCount447, ad__Damage448, ad__RadiantDmgAmp449, ad__Duration450, ad__BHDamage451, ad__DebuffDuration452 = SF__.DivineToll.GetAbilityData(GetUnitAbilityLevel(self.caster, SF__.DivineToll.ID))
    self._spec = ad__RadiantDmgAmp449
end
-- Easing
SF__.Easing = SF__.Easing or {}
SF__.Easing.Name = "Easing"
SF__.Easing.FullName = "Easing"
function SF__.Easing.Linear(t)
    return t
end

function SF__.Easing.OutQubic(t66)
    return (1 - ((1 - t66) ^ 3))
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
function SF__.TemplarStrikes.GetAbilityData(level461)
    return 2, (0.5 + (0.25 * level461)), (0.05 * level461)
end

function SF__.TemplarStrikes.Init()
    local EventCenter462 = require("Lib.EventCenter")
    EventCenter462.RegisterPlayerUnitSpellEffect:Emit({id = SF__.TemplarStrikes.ID, handler = SF__.TemplarStrikes.Start})
    ExTriggerRegisterNewUnit(function(u464)
        if (GetUnitTypeId(u464) == FourCC("Hpal")) then
            SF__.TemplarStrikes.UpdateAbilityMeta(u464)
            SetHeroLevel(u464, 10, true)
        end
    end)
    EventCenter462.RegisterPlayerUnitDamaged:Emit(function(caster468, target469, damage470, weapType471, dmgType472, isAttack473)
        if (GetUnitAbilityLevel(caster468, SF__.TemplarStrikes.ID) <= 0) then
            return
        end
        if (not isAttack473) then
            return
        end
        if (target469 == nil) then
            return
        end
        if ExIsUnitDead(target469) then
            return
        end
        SF__.TemplarStrikes.TryResetBOJ(caster468)
    end)
end

function SF__.TemplarStrikes.TryResetBOJ(caster474)
    local level475 = GetUnitAbilityLevel(caster474, SF__.TemplarStrikes.ID)
    local ad__AttackCount, ad__DamageScaling476, ad__ResetBOJChance = SF__.TemplarStrikes.GetAbilityData(level475)
    if (math.random() >= ad__ResetBOJChance) then
        return
    end
    BlzEndUnitAbilityCooldown(caster474, SF__.BladeOfJustice.ID)
    ExAddSpecialEffectTarget("Abilities/Spells/Items/AIam/AIamTarget.mdl", caster474, "origin", 0.3)
end

function SF__.TemplarStrikes.UpdateAbilityMeta(u477)
    local p478 = GetOwningPlayer(u477)
    local datas479 = SF__.StdLib.List.New__0()
    do
        local i480 = 0
        while (i480 < SF__.TemplarStrikes.MaxLevel) do
            local __pack_AttackCount, __pack_DamageScaling481, __pack_ResetBOJChance = SF__.TemplarStrikes.GetAbilityData((i480 + 1))
            datas479:Add({AttackCount = __pack_AttackCount, DamageScaling = __pack_DamageScaling481, ResetBOJChance = __pack_ResetBOJChance})
            ::continue::
            i480 = (i480 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p478, SF__.TemplarStrikes.ID, "学习圣殿骑士之击 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p478, SF__.TemplarStrikes.ID, SF__.StrConcat__("快速攻击目标|cffff8c00", datas479:get_Item(0).AttackCount, "|r次，第一次造成普通攻击伤害，第二次造成光辉伤害，有一定几率重置公正之剑的冷却时间，普通攻击也会触发。\n\n|cff99ccff冷却时间|r - 10秒\n\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas479:get_Item(0).DamageScaling * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas479:get_Item(0).ResetBOJChance * 100)), "%|r的几率重置公正之剑。\n|cffffcc002级|r - |cffff8c00", string.format("%.0f", (datas479:get_Item(1).DamageScaling * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas479:get_Item(1).ResetBOJChance * 100)), "%|r的几率重置公正之剑。\n|cffffcc003级|r - |cffff8c00", string.format("%.0f", (datas479:get_Item(2).DamageScaling * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas479:get_Item(2).ResetBOJChance * 100)), "%|r的几率重置公正之剑。"), 0)
    do
        local i482 = 0
        while (i482 < SF__.TemplarStrikes.MaxLevel) do
            local __unpack_tmp484 = datas479:get_Item(i482)
            local data__AttackCount, data__DamageScaling483, data__ResetBOJChance = __unpack_tmp484.AttackCount, __unpack_tmp484.DamageScaling, __unpack_tmp484.ResetBOJChance
            SF__.Utils.ExBlzSetAbilityTooltip(p478, SF__.TemplarStrikes.ID, SF__.StrConcat__("圣殿骑士之击 - [|cffffcc00", (i482 + 1), "级|r]"), i482)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p478, SF__.TemplarStrikes.ID, SF__.StrConcat__("快速攻击目标|cffff8c00", data__AttackCount, "|r次，第一次造成普通攻击伤害，第二次造成普通攻击|cffff8c00", string.format("%.0f", (data__DamageScaling483 * 100)), "%|r的光辉伤害，|cffff8c00", string.format("%.0f", (data__ResetBOJChance * 100)), "%|r几率重置公正之剑的冷却时间，普通攻击也会触发。\n\n|cff99ccff冷却时间|r - 10秒"), i482)
            ::continue::
            i482 = (i482 + 1)
        end
    end
end

function SF__.TemplarStrikes.Start(data485)
    return SF__.CorRun__(function()
        local level486 = GetUnitAbilityLevel(data485.caster, SF__.TemplarStrikes.ID)
        local UnitAttribute488 = require("Objects.UnitAttribute")
        local EventCenter489 = require("Lib.EventCenter")
        local attr487 = UnitAttribute488.GetAttr(data485.caster)
        local normalDamage = attr487:SimMeleeAttack()
        EventCenter489.Damage:Emit({whichUnit = data485.caster, target = data485.target, amount = normalDamage, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
        SF__.TemplarStrikes.TryResetBOJ(data485.caster)
        SetUnitTimeScale(data485.caster, 3)
        ResetUnitAnimation(data485.caster)
        SetUnitAnimation(data485.caster, "attack - 2")
        SF__.CorWait__(math.round(((1.166 * 0.33) * 1000)))
        local tarAttr490 = UnitAttribute488.GetAttr(data485.target)
        local ad__AttackCount491, ad__DamageScaling492, ad__ResetBOJChance493 = SF__.TemplarStrikes.GetAbilityData(level486)
        local radiantDamage = ((attr487:SimMeleeAttack() * ad__DamageScaling492) * (1 - tarAttr490.radiantResistance))
        EventCenter489.Damage:Emit({whichUnit = data485.caster, target = data485.target, amount = radiantDamage, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
        SF__.TemplarStrikes.TryResetBOJ(data485.caster)
        SetUnitTimeScale(data485.caster, 1)
        ResetUnitAnimation(data485.caster)
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
    local EventCenter516 = require("Lib.EventCenter")
    EventCenter516.RegisterPlayerUnitSpellChannel:Emit({id = SF__.WordOfGlory.ID, handler = SF__.WordOfGlory.Check})
    EventCenter516.RegisterPlayerUnitSpellEffect:Emit({id = SF__.WordOfGlory.ID, handler = SF__.WordOfGlory.Start})
    ExTriggerRegisterNewUnit(function(u518)
        if (GetUnitTypeId(u518) == FourCC("Hpal")) then
            SF__.WordOfGlory.UpdateAbilityMeta(u518)
        end
    end)
end

function SF__.WordOfGlory.Check(data519)
    local UnitAttribute521 = require("Objects.UnitAttribute")
    local attr520 = UnitAttribute521.GetAttr(data519.caster)
    if (attr520.retPalHolyEnergy < 3) then
        IssueImmediateOrderById(data519.caster, SF__.ConstOrderId.Stop)
        ExTextState(data519.caster, "圣能不足")
    end
end

function SF__.WordOfGlory.UpdateAbilityMeta(u522)
    local p523 = GetOwningPlayer(u522)
    SF__.Utils.ExSetAbilityResearchTooltip(p523, SF__.WordOfGlory.ID, "学习圣殿骑士的裁决 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p523, SF__.WordOfGlory.ID, "圣殿骑士的裁决造成一次攻击伤害，如果目标被审判，造成30%的额外伤害，15%几率重置审判。消耗|cffff8c003|r点圣能。\n\n|cff99ccff冷却时间|r - 5秒\n\n|cffffcc001级|r - |cffff8c00100%|r的攻击伤害，100%的战争艺术触发几率。", 0)
    do
        local i524 = 0
        while (i524 < 1) do
            SF__.Utils.ExBlzSetAbilityTooltip(p523, SF__.WordOfGlory.ID, SF__.StrConcat__("圣殿骑士的裁决 - [|cffffcc00", (i524 + 1), "级|r]"), i524)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p523, SF__.WordOfGlory.ID, "圣殿骑士的裁决造成一次攻击伤害，造成|cffff8c00100%|r的攻击伤害。消耗|cffff8c003|r点圣能。\n\n|cff99ccff冷却时间|r - 5秒", i524)
            ::continue::
            i524 = (i524 + 1)
        end
    end
end

function SF__.WordOfGlory.Start(data525)
    local UnitAttribute527 = require("Objects.UnitAttribute")
    local EventCenter528 = require("Lib.EventCenter")
    local attr526 = UnitAttribute527.GetAttr(data525.caster)
    EventCenter528.Heal:Emit({caster = data525.caster, target = data525.target, amount = 300})
    attr526.retPalHolyEnergy = (attr526.retPalHolyEnergy - 3)
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
local SystemBase41 = require("System.SystemBase")
SF__.Systems.InspectorSystem = SF__.Systems.InspectorSystem or class("InspectorSystem", SystemBase41)
SF__.Systems.InspectorSystem.Name = "InspectorSystem"
SF__.Systems.InspectorSystem.FullName = "Systems.InspectorSystem"
SF__.Systems.InspectorSystem.__sf_base = SystemBase41
function SF__.Systems.InspectorSystem:Awake()
    self:CreateFrames()
    self:RefreshHierarchy()
    self:SelectFirstVisibleObject()
    self:SetPanelVisible(false)
end

function SF__.Systems.InspectorSystem:Update(dt42)
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
        local i43 = 0
        while (i43 < SF__.Systems.InspectorSystem.MaxHierarchyRows) do
            self._hierarchyRows:Add(self:CreateHierarchyRow(i43))
            ::continue::
            i43 = (i43 + 1)
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

function SF__.Systems.InspectorSystem:CreateHierarchyRow(index44)
    local y45 = ((-0.061) - (index44 * (SF__.Systems.InspectorSystem.RowHeight + SF__.Systems.InspectorSystem.RowGap)))
    local button = BlzCreateFrameByType("BUTTON", "FdfInspectorHierarchyRow", self._panel, "ScoreScreenTabButtonTemplate", index44)
    BlzFrameSetPoint(button, FRAMEPOINT_TOPLEFT, self._panel, FRAMEPOINT_TOPLEFT, (SF__.Systems.InspectorSystem.Padding * 2), y45)
    BlzFrameSetSize(button, (SF__.Systems.InspectorSystem.LeftWidth - (SF__.Systems.InspectorSystem.Padding * 4)), SF__.Systems.InspectorSystem.RowHeight)
    local label46 = BlzCreateFrameByType("TEXT", "FdfInspectorHierarchyRowText", button, "", index44)
    BlzFrameSetPoint(label46, FRAMEPOINT_TOPLEFT, button, FRAMEPOINT_TOPLEFT, 0.004, (-0.002))
    BlzFrameSetSize(label46, (SF__.Systems.InspectorSystem.LeftWidth - (SF__.Systems.InspectorSystem.Padding * 5)), (SF__.Systems.InspectorSystem.RowHeight - 0.003))
    BlzFrameSetEnable(label46, false)
    BlzFrameSetTextAlignment(label46, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_LEFT)
    BlzFrameSetText(label46, "")
    local row = SF__.Systems.InspectorSystem.HierarchyRow.New(button, label46)
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

function SF__.Systems.InspectorSystem:SelectRow(row47)
    if (row47.gameObject == nil) then
        return
    end
    self._selectedGameObject = row47.gameObject
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
        for _, obj48 in (SF__.StdLib.List.IpairsNext)(collection10) do
            if (obj48.transform.parent == nil) then
                self:AddHierarchyObject(obj48, 0)
            end
        end
    end
    do
        local i49 = 0
        while (i49 < self._hierarchyRows.Count) do
            local row50 = self._hierarchyRows:get_Item(i49)
            if (i49 < self._visibleObjects.Count) then
                local obj51 = self._visibleObjects:get_Item(i49)
                row50.gameObject = obj51
                row50.depth = self:GetDepth(obj51)
                self:SetRowLabel(row50, obj51.name, row50.depth)
                BlzFrameSetVisible(row50.button, self._isVisible)
            else
                row50.gameObject = nil
                BlzFrameSetVisible(row50.button, false)
            end
            ::continue::
            i49 = (i49 + 1)
        end
    end
    BlzFrameSetVisible(self._emptyText, (self._isVisible and (self._visibleObjects.Count == 0)))
    self._lastObjectCount = SF__.Scene.get_Instance().gameObjs.Count
    self:RefreshHierarchySelection()
end

function SF__.Systems.InspectorSystem:AddHierarchyObject(obj52, depth)
    if (self._visibleObjects.Count >= SF__.Systems.InspectorSystem.MaxHierarchyRows) then
        return
    end
    self._visibleObjects:Add(obj52)
    do
        local collection11 = obj52.transform.children
        for _, child53 in (SF__.StdLib.List.IpairsNext)(collection11) do
            self:AddHierarchyObject(child53.gameObject, (depth + 1))
        end
    end
end

function SF__.Systems.InspectorSystem:GetDepth(obj54)
    local depth55 = 0
    local parent56 = obj54.transform.parent
    while (parent56 ~= nil) do
        depth55 = (depth55 + 1)
        parent56 = parent56.parent
        ::continue::
    end
    return depth55
end

function SF__.Systems.InspectorSystem:SetRowLabel(row57, text58, depth59)
    BlzFrameClearAllPoints(row57.label)
    BlzFrameSetPoint(row57.label, FRAMEPOINT_TOPLEFT, row57.button, FRAMEPOINT_TOPLEFT, (0.004 + (depth59 * SF__.Systems.InspectorSystem.IndentWidth)), (-0.002))
    BlzFrameSetSize(row57.label, ((SF__.Systems.InspectorSystem.LeftWidth - (SF__.Systems.InspectorSystem.Padding * 5)) - (depth59 * SF__.Systems.InspectorSystem.IndentWidth)), (SF__.Systems.InspectorSystem.RowHeight - 0.003))
    BlzFrameSetText(row57.label, text58)
end

function SF__.Systems.InspectorSystem:RefreshHierarchySelection()
    do
        local collection12 = self._hierarchyRows
        for _, row60 in (SF__.StdLib.List.IpairsNext)(collection12) do
            local isSelected = ((row60.gameObject ~= nil) and (row60.gameObject == self._selectedGameObject))
            BlzFrameSetTextColor(row60.label, (function() if isSelected then return BlzConvertColor(255, 255, 220, 80) else return BlzConvertColor(255, 230, 230, 230) end end)())
        end
    end
end

function SF__.Systems.InspectorSystem:RefreshInspectorText()
    if (self._selectedGameObject == nil) then
        BlzFrameSetText(self._inspectorText, "")
        return
    end
    local text61 = SF__.StrConcat__(self._selectedGameObject.name, "\n")
    do
        local collection13 = self._selectedGameObject:get_components()
        for _, component in (SF__.StdLib.List.IpairsNext)(collection13) do
            text61 = SF__.StrConcat__(text61, "\n[", component.__sf_type.Name, "]")
            local inspectorText = component:GetInspectorText()
            if (inspectorText ~= "") then
                text61 = SF__.StrConcat__(text61, "\n", inspectorText)
            end
        end
    end
    BlzFrameSetText(self._inspectorText, text61)
end

function SF__.Systems.InspectorSystem:SceneContains(gameObject)
    do
        local collection14 = SF__.Scene.get_Instance().gameObjs
        for _, obj62 in (SF__.StdLib.List.IpairsNext)(collection14) do
            if (obj62 == gameObject) then
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
function SF__.Systems.InspectorSystem.HierarchyRow.__Init(self, button63, label64)
    self.__sf_type = SF__.Systems.InspectorSystem.HierarchyRow
    self.button = nil
    self.label = nil
    self.gameObject = nil
    self.depth = 0
    self.button = button63
    self.label = label64
end

function SF__.Systems.InspectorSystem.HierarchyRow.New(button63, label64)
    local self = setmetatable({}, { __index = SF__.Systems.InspectorSystem.HierarchyRow })
    SF__.Systems.InspectorSystem.HierarchyRow.__Init(self, button63, label64)
    return self
end
-- Systems.MeleeGameSystem
local SystemBase65 = require("System.SystemBase")
SF__.Systems.MeleeGameSystem = SF__.Systems.MeleeGameSystem or class("MeleeGameSystem", SystemBase65)
SF__.Systems.MeleeGameSystem.Name = "MeleeGameSystem"
SF__.Systems.MeleeGameSystem.FullName = "Systems.MeleeGameSystem"
SF__.Systems.MeleeGameSystem.__sf_base = SystemBase65
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
    local item109 = self._items:get_Item((self._items.Count - 1))
    self._items:RemoveAt((self._items.Count - 1))
    return item109
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

function SF__.StdLib.Dictionary:set_Item(key529, value)
    if (key529 == nil) then
        error(SF__.StrConcat__("SF__E2e5944b8", "Key cannot be null"))
    end
    local existing = self._table[key529]
    self._table[key529] = value
    if (existing == nil) then
        self.Count = (self.Count + 1)
        self._keys:Add(key529)
    end
    self._version = (self._version + 1)
end

function SF__.StdLib.Dictionary:PairsNext()
    local version = self._version
    local index530 = 0
    return function()
        if (version ~= self._version) then
            error(SF__.StrConcat__("SF__E2e5944b8", "Collection was modified"))
        end
        index530 = (index530 + 1)
        if (index530 > self._keys.Count) then
            return nil
        end
        local key531 = self._keys:get_Item((index530 - 1))
        local value532 = self._table[key531]
        return key531, value532
    end
end

function SF__.StdLib.Dictionary:ContainsKey(key533)
    if (key533 == nil) then
        error(SF__.StrConcat__("SF__E2e5944b8", "Key cannot be null"))
    end
    return (self._table[key533] ~= nil)
end

function SF__.StdLib.Dictionary:TryGetValue(key534)
    if (key534 == nil) then
        error(SF__.StrConcat__("SF__E2e5944b8", "Key cannot be null"))
    end
    local result536 = self._table[key534]
    if (result536 ~= nil) then
        value535 = result536
        return true, value535
    end
    value535 = nil
    return false, value535
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
function SF__.TemplarVerdict.GetAbilityData(level494)
    return 2.25, 0.3, 0.15
end

function SF__.TemplarVerdict.Init()
    local EventCenter495 = require("Lib.EventCenter")
    EventCenter495.RegisterPlayerUnitSpellChannel:Emit({id = SF__.TemplarVerdict.ID, handler = SF__.TemplarVerdict.Check})
    EventCenter495.RegisterPlayerUnitSpellEffect:Emit({id = SF__.TemplarVerdict.ID, handler = SF__.TemplarVerdict.Start})
    ExTriggerRegisterNewUnit(function(u497)
        if (GetUnitTypeId(u497) == FourCC("Hpal")) then
            SF__.TemplarVerdict.UpdateAbilityMeta(u497)
        end
    end)
end

function SF__.TemplarVerdict.Check(data498)
    local UnitAttribute500 = require("Objects.UnitAttribute")
    local attr499 = UnitAttribute500.GetAttr(data498.caster)
    if (attr499.retPalHolyEnergy < 3) then
        IssueImmediateOrderById(data498.caster, SF__.ConstOrderId.Stop)
        ExTextState(data498.caster, "圣能不足")
    end
end

function SF__.TemplarVerdict.UpdateAbilityMeta(u501)
    local p502 = GetOwningPlayer(u501)
    local datas503 = SF__.StdLib.List.New__0()
    do
        local i504 = 0
        while (i504 < 1) do
            local __pack_DamageScaling505, __pack_JudgementDamageScaling, __pack_ChanceToResetJudgement = SF__.TemplarVerdict.GetAbilityData((i504 + 1))
            datas503:Add({DamageScaling = __pack_DamageScaling505, JudgementDamageScaling = __pack_JudgementDamageScaling, ChanceToResetJudgement = __pack_ChanceToResetJudgement})
            ::continue::
            i504 = (i504 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p502, SF__.TemplarVerdict.ID, "学习圣殿骑士的裁决 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p502, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决造成一次攻击伤害，如果目标被审判，造成30%的额外伤害，15%几率重置审判。消耗|cffff8c003|r点圣能。\n\n|cff99ccff冷却时间|r - 5秒\n\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas503:get_Item(0).JudgementDamageScaling * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas503:get_Item(0).ChanceToResetJudgement * 100)), "%的战争艺术触发几率。"), 0)
    do
        local i506 = 0
        while (i506 < 1) do
            local __unpack_tmp508 = datas503:get_Item(i506)
            local data__DamageScaling507, data__JudgementDamageScaling, data__ChanceToResetJudgement = __unpack_tmp508.DamageScaling, __unpack_tmp508.JudgementDamageScaling, __unpack_tmp508.ChanceToResetJudgement
            SF__.Utils.ExBlzSetAbilityTooltip(p502, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决 - [|cffffcc00", (i506 + 1), "级|r]"), i506)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p502, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决造成一次攻击伤害，造成|cffff8c00", string.format("%.0f", (data__DamageScaling507 * 100)), "%|r的攻击伤害。消耗|cffff8c003|r点圣能。\n\n|cff99ccff冷却时间|r - 5秒"), i506)
            ::continue::
            i506 = (i506 + 1)
        end
    end
end

function SF__.TemplarVerdict.Start(data509)
    local level510 = GetUnitAbilityLevel(data509.caster, SF__.TemplarVerdict.ID)
    local UnitAttribute513 = require("Objects.UnitAttribute")
    local EventCenter515 = require("Lib.EventCenter")
    local ad__DamageScaling511, ad__JudgementDamageScaling, ad__ChanceToResetJudgement = SF__.TemplarVerdict.GetAbilityData(level510)
    local attr512 = UnitAttribute513.GetAttr(data509.caster)
    local damage514 = (attr512:SimAttack(UnitAttribute513.HeroAttributeType.Strength) * ad__DamageScaling511)
    EventCenter515.Damage:Emit({whichUnit = data509.caster, target = data509.target, amount = damage514, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_SLICE, outResult = {}})
    attr512.retPalHolyEnergy = (attr512.retPalHolyEnergy - 3)
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

function SF__.Vector2.Dot(a__x125, a__y126, b__x127, b__y128)
    return ((a__x125 * b__x127) + (a__y126 * b__y128))
end

function SF__.Vector2.Cross(a__x129, a__y130, b__x131, b__y132)
    return ((a__y130 * b__x131) - (a__x129 * b__y132))
end

function SF__.Vector2.op_UnaryNegation(a__x133, a__y134)
    return (-a__x133), (-a__y134)
end

function SF__.Vector2.op_Addition(a__x135, a__y136, b__x137, b__y138)
    return (a__x135 + b__x137), (a__y136 + b__y138)
end

function SF__.Vector2.op_Subtraction(a__x139, a__y140, b__x141, b__y142)
    return (a__x139 - b__x141), (a__y140 - b__y142)
end

function SF__.Vector2.op_Multiply__ahdf(v__x143, v__y144, f)
    return (v__x143 * f), (v__y144 * f)
end

function SF__.Vector2.op_Multiply__fahd(f145, v__x146, v__y147)
    return (v__x146 * f145), (v__y147 * f145)
end

function SF__.Vector2.op_Division(v__x148, v__y149, f150)
    return (v__x148 / f150), (v__y149 / f150)
end

function SF__.Vector2.UnitDistance(a, b)
    local v1__x, v1__y = SF__.Vector2.FromUnit(a)
    local v2__x, v2__y = SF__.Vector2.FromUnit(b)
    return SF__.Vector2.get_Magnitude(SF__.Vector2.op_Subtraction(v1__x, v1__y, v2__x, v2__y))
end

function SF__.Vector2.SqrUnitDistance(a151, b152)
    local v1__x153, v1__y154 = SF__.Vector2.FromUnit(a151)
    local v2__x155, v2__y156 = SF__.Vector2.FromUnit(b152)
    return SF__.Vector2.get_SqrMagnitude(SF__.Vector2.op_Subtraction(v1__x153, v1__y154, v2__x155, v2__y156))
end

function SF__.Vector2.FromUnit(u157)
    return GetUnitX(u157), GetUnitY(u157)
end

function SF__.Vector2.get_Magnitude(self__x158, self__y159)
    return math.sqrt(SF__.Vector2.get_SqrMagnitude(self__x158, self__y159))
end

function SF__.Vector2.get_SqrMagnitude(self__x160, self__y161)
    return ((self__x160 * self__x160) + (self__y161 * self__y161))
end

function SF__.Vector2.get_Normalized(self__x162, self__y163)
    local mag = SF__.Vector2.get_Magnitude(self__x162, self__y163)
    if (mag < 0.0001) then
        return SF__.Vector2.get_Zero()
    end
    return SF__.Vector2.op_Division(self__x162, self__y163, mag)
end

function SF__.Vector2.ClampMagnitude(self__x166, self__y167, mag168)
    return (function()
        local v__x169, v__y170 = SF__.Vector2.get_Normalized(self__x166, self__y167)
        return SF__.Vector2.op_Multiply__ahdf(v__x169, v__y170, mag168)
    end)()
end

function SF__.Vector2.ToString(self__x171, self__y172)
    return SF__.StrConcat__("(", self__x171, ", ", self__y172, ")")
end

function SF__.Vector2.Rotate(self__x173, self__y174, angle175)
    local cos = math.cos(angle175)
    local sin = math.sin(angle175)
    return ((self__x173 * cos) - (self__y174 * sin)), ((self__x173 * sin) + (self__y174 * cos))
end

function SF__.Vector2.UnitMoveTo(self__x176, self__y177, u178)
    SetUnitX(u178, self__x176)
    SetUnitY(u178, self__y177)
end

function SF__.Vector2.GetTerrainZ(self__x179, self__y180)
    MoveLocation(SF__.Vector2._loc, self__x179, self__y180)
    return GetLocationZ(SF__.Vector2._loc)
end

SF__.Vector2._loc = Location(0, 0)

SF__.Program.Main()
