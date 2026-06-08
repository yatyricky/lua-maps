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

function SF__.Vector3.op_Addition(a__x195, a__y196, a__z197, b__x198, b__y199, b__z200)
    return (a__x195 + b__x198), (a__y196 + b__y199), (a__z197 + b__z200)
end

function SF__.Vector3.op_UnaryNegation(a__x201, a__y202, a__z203)
    return (-a__x201), (-a__y202), (-a__z203)
end

function SF__.Vector3.op_Subtraction(a__x204, a__y205, a__z206, b__x207, b__y208, b__z209)
    return (a__x204 - b__x207), (a__y205 - b__y208), (a__z206 - b__z209)
end

function SF__.Vector3.op_Multiply__osef(v__x210, v__y211, v__z212, f213)
    return (v__x210 * f213), (v__y211 * f213), (v__z212 * f213)
end

function SF__.Vector3.op_Multiply__fose(f214, v__x215, v__y216, v__z217)
    return (v__x215 * f214), (v__y216 * f214), (v__z217 * f214)
end

function SF__.Vector3.op_Division(v__x218, v__y219, v__z220, f221)
    return (v__x218 / f221), (v__y219 / f221), (v__z220 / f221)
end

-- <summary>
-- Warcraft III world space here is right-handed: +x points right, +y points away, +z points up.
-- That means Cross((1,0,0), (0,1,0)) == (0,0,1).
-- </summary>
--
function SF__.Vector3.Cross(a__x222, a__y223, a__z224, b__x225, b__y226, b__z227)
    return ((a__y223 * b__z227) - (a__z224 * b__y226)), ((a__z224 * b__x225) - (a__x222 * b__z227)), ((a__x222 * b__y226) - (a__y223 * b__x225))
end

function SF__.Vector3.Distance(a__x228, a__y229, a__z230, b__x231, b__y232, b__z233)
    return SF__.Vector3.get_magnitude(SF__.Vector3.op_Subtraction(a__x228, a__y229, a__z230, b__x231, b__y232, b__z233))
end

function SF__.Vector3.Dot(a__x234, a__y235, a__z236, b__x237, b__y238, b__z239)
    return (((a__x234 * b__x237) + (a__y235 * b__y238)) + (a__z236 * b__z239))
end

function SF__.Vector3.Lerp(a__x240, a__y241, a__z242, b__x243, b__y244, b__z245, t246)
    t246 = math.clamp01(t246)
    return SF__.Vector3.op_Addition(a__x240, a__y241, a__z242, (function()
        local v__x247, v__y248, v__z249 = SF__.Vector3.op_Subtraction(b__x243, b__y244, b__z245, a__x240, a__y241, a__z242)
        return SF__.Vector3.op_Multiply__osef(v__x247, v__y248, v__z249, t246)
    end)())
end

function SF__.Vector3.MoveTowards(current__x, current__y, current__z, target__x250, target__y251, target__z252, maxDistanceDelta)
    local toVector__x, toVector__y, toVector__z = SF__.Vector3.op_Subtraction(target__x250, target__y251, target__z252, current__x, current__y, current__z)
    local dist = SF__.Vector3.get_magnitude(toVector__x, toVector__y, toVector__z)
    if ((dist <= maxDistanceDelta) or (dist == 0)) then
        return target__x250, target__y251, target__z252
    end
    return SF__.Vector3.op_Addition(current__x, current__y, current__z, SF__.Vector3.op_Division(toVector__x, toVector__y, toVector__z, (dist / maxDistanceDelta)))
end

function SF__.Vector3.Project(v__x253, v__y254, v__z255, onNormal__x, onNormal__y, onNormal__z)
    local sqrMag = SF__.Vector3.Dot(onNormal__x, onNormal__y, onNormal__z, onNormal__x, onNormal__y, onNormal__z)
    if (sqrMag < 0.0001) then
        return SF__.Vector3.get_zero()
    end
    local dot = SF__.Vector3.Dot(v__x253, v__y254, v__z255, onNormal__x, onNormal__y, onNormal__z)
    return SF__.Vector3.op_Multiply__osef(onNormal__x, onNormal__y, onNormal__z, (dot / sqrMag))
end

function SF__.Vector3.ProjectOnPlane(v__x256, v__y257, v__z258, planeNormal__x, planeNormal__y, planeNormal__z)
    return SF__.Vector3.op_Subtraction(v__x256, v__y257, v__z258, SF__.Vector3.Project(v__x256, v__y257, v__z258, planeNormal__x, planeNormal__y, planeNormal__z))
end

function SF__.Vector3.Reflect(inDirection__x, inDirection__y, inDirection__z, inNormal__x, inNormal__y, inNormal__z)
    return SF__.Vector3.op_Subtraction(inDirection__x, inDirection__y, inDirection__z, SF__.Vector3.op_Multiply__fose((2 * SF__.Vector3.Dot(inDirection__x, inDirection__y, inDirection__z, inNormal__x, inNormal__y, inNormal__z)), inNormal__x, inNormal__y, inNormal__z))
end

function SF__.Vector3.RotateTowards(current__x259, current__y260, current__z261, target__x262, target__y263, target__z264, maxRadiansDelta, maxMagnitudeDelta)
    local currentMag = SF__.Vector3.get_magnitude(current__x259, current__y260, current__z261)
    local targetMag = SF__.Vector3.get_magnitude(target__x262, target__y263, target__z264)
    if ((currentMag == 0) or (targetMag == 0)) then
        return SF__.Vector3.MoveTowards(current__x259, current__y260, current__z261, target__x262, target__y263, target__z264, maxMagnitudeDelta)
    end
    local currentNorm__x, currentNorm__y, currentNorm__z = SF__.Vector3.op_Division(current__x259, current__y260, current__z261, currentMag)
    local targetNorm__x, targetNorm__y, targetNorm__z = SF__.Vector3.op_Division(target__x262, target__y263, target__z264, targetMag)
    local dot265 = math.clamp(SF__.Vector3.Dot(currentNorm__x, currentNorm__y, currentNorm__z, targetNorm__x, targetNorm__y, targetNorm__z), (-1), 1)
    local angle266 = math.acos(dot265)
    if (angle266 == 0) then
        return SF__.Vector3.MoveTowards(current__x259, current__y260, current__z261, target__x262, target__y263, target__z264, maxMagnitudeDelta)
    end
    local t267 = math.min(1, (maxRadiansDelta / angle266))
    local newDir__x, newDir__y, newDir__z = SF__.Vector3.Slerp(currentNorm__x, currentNorm__y, currentNorm__z, targetNorm__x, targetNorm__y, targetNorm__z, t267)
    local newMag = math.moveTowards(currentMag, targetMag, maxMagnitudeDelta)
    return SF__.Vector3.op_Multiply__osef(newDir__x, newDir__y, newDir__z, newMag)
end

function SF__.Vector3.Scale(a__x268, a__y269, a__z270, b__x271, b__y272, b__z273)
    return (a__x268 * b__x271), (a__y269 * b__y272), (a__z270 * b__z273)
end

function SF__.Vector3.Slerp(a__x274, a__y275, a__z276, b__x277, b__y278, b__z279, t280)
    local magA = SF__.Vector3.get_magnitude(a__x274, a__y275, a__z276)
    local magB = SF__.Vector3.get_magnitude(b__x277, b__y278, b__z279)
    if ((magA == 0) or (magB == 0)) then
        return SF__.Vector3.MoveTowards(a__x274, a__y275, a__z276, b__x277, b__y278, b__z279, math.huge)
    end
    local normA__x, normA__y, normA__z = SF__.Vector3.op_Division(a__x274, a__y275, a__z276, magA)
    local normB__x, normB__y, normB__z = SF__.Vector3.op_Division(b__x277, b__y278, b__z279, magB)
    local dot281 = math.clamp(SF__.Vector3.Dot(normA__x, normA__y, normA__z, normB__x, normB__y, normB__z), (-1), 1)
    local angle282 = math.acos(dot281)
    local sinAngle = math.sin(angle282)
    if (sinAngle < 0.0001) then
        return SF__.Vector3.MoveTowards(a__x274, a__y275, a__z276, b__x277, b__y278, b__z279, math.huge)
    end
    local tAngle = (angle282 * t280)
    local sinTA = math.sin(tAngle)
    local sinTOneMinusA = math.sin((angle282 - tAngle))
    local newDir__x289, newDir__y290, newDir__z291 = (function()
        local v__x286, v__y287, v__z288 = (function()
            local a__x283, a__y284, a__z285 = SF__.Vector3.op_Multiply__osef(normA__x, normA__y, normA__z, sinTOneMinusA)
            return SF__.Vector3.op_Addition(a__x283, a__y284, a__z285, SF__.Vector3.op_Multiply__osef(normB__x, normB__y, normB__z, sinTA))
        end)()
        return SF__.Vector3.op_Division(v__x286, v__y287, v__z288, sinAngle)
    end)()
    local newMag292 = math.lerp(magA, magB, t280)
    return SF__.Vector3.op_Multiply__osef(newDir__x289, newDir__y290, newDir__z291, newMag292)
end

function SF__.Vector3._getTerrainZ(x293, y294)
    MoveLocation(SF__.Vector3._loc, x293, y294)
    return GetLocationZ(SF__.Vector3._loc)
end

function SF__.Vector3.FromUnit(u295)
    local x296 = GetUnitX(u295)
    local y297 = GetUnitY(u295)
    return x296, y297, (SF__.Vector3._getTerrainZ(x296, y297) + GetUnitFlyHeight(u295))
end

function SF__.Vector3.get_sqrMagnitude(self__x298, self__y299, self__z300)
    return (((self__x298 * self__x298) + (self__y299 * self__y299)) + (self__z300 * self__z300))
end

function SF__.Vector3.get_magnitude(self__x301, self__y302, self__z303)
    return math.sqrt(SF__.Vector3.get_sqrMagnitude(self__x301, self__y302, self__z303))
end

function SF__.Vector3.get_normalized(self__x304, self__y305, self__z306)
    local mag307 = SF__.Vector3.get_magnitude(self__x304, self__y305, self__z306)
    if (mag307 < 0.0001) then
        return SF__.Vector3.get_zero()
    end
    return SF__.Vector3.op_Division(self__x304, self__y305, self__z306, mag307)
end

function SF__.Vector3.ClampMagnitude(self__x311, self__y312, self__z313, mag314)
    return (function()
        local v__x315, v__y316, v__z317 = SF__.Vector3.get_normalized(self__x311, self__y312, self__z313)
        return SF__.Vector3.op_Multiply__osef(v__x315, v__y316, v__z317, mag314)
    end)()
end

function SF__.Vector3.ToString(self__x318, self__y319, self__z320)
    return SF__.StrConcat__("(", self__x318, ", ", self__y319, ", ", self__z320, ")")
end

function SF__.Vector3.UnitMoveTo(self__x321, self__y322, self__z323, u324, mode)
    if mode == nil then mode = SF__.UnitVec3Mode.Auto end
    local tz = SF__.Vector3._getTerrainZ(self__x321, self__y322)
    local LuaUtils = require("Lib.Utils")
    local defaultFlyHeight = GetUnitDefaultFlyHeight(u324)
    local minZ = (tz + defaultFlyHeight)
    SetUnitPosition(u324, self__x321, self__y322)
    repeat
        local switchValue = mode
        if (switchValue == SF__.UnitVec3Mode.ForceFlying) then
            LuaUtils.SetUnitFlyable(u324)
            SetUnitFlyHeight(u324, (math.max(minZ, self__z323) - minZ), 0)
            break
        elseif (switchValue == SF__.UnitVec3Mode.ForceGround) then
            SetUnitFlyHeight(u324, defaultFlyHeight, 0)
            break
        elseif (switchValue == SF__.UnitVec3Mode.Auto) then
            if IsUnitType(u324, UNIT_TYPE_FLYING) then
                SetUnitFlyHeight(u324, (math.max(minZ, self__z323) - minZ), 0)
            else
                SetUnitFlyHeight(u324, defaultFlyHeight, 0)
            end
            break
        end
    until true
end

function SF__.Vector3.GetTerrainZ(self__x325, self__y326, self__z327)
    return SF__.Vector3._getTerrainZ(self__x325, self__y326)
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

function SF__.Quaternion.op_Multiply__iyiose(q__x81, q__y82, q__z83, q__w84, v__x, v__y, v__z)
    -- https://en.wikipedia.org/wiki/Quaternions_and_spatial_rotation#Using_quaternion_as_rotations
    local u__x, u__y, u__z = q__x81, q__y82, q__z83
    local s = q__w84
    return (function()
        local a__x88, a__y89, a__z90 = (function()
            local a__x85, a__y86, a__z87 = SF__.Vector3.op_Multiply__fose((2 * SF__.Vector3.Dot(u__x, u__y, u__z, v__x, v__y, v__z)), u__x, u__y, u__z)
            return SF__.Vector3.op_Addition(a__x85, a__y86, a__z87, SF__.Vector3.op_Multiply__fose(((s * s) - SF__.Vector3.Dot(u__x, u__y, u__z, u__x, u__y, u__z)), v__x, v__y, v__z))
        end)()
        return SF__.Vector3.op_Addition(a__x88, a__y89, a__z90, SF__.Vector3.op_Multiply__fose((2 * s), SF__.Vector3.Cross(u__x, u__y, u__z, v__x, v__y, v__z)))
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
    local x91
    local y92
    local z
    local w
    local trace = ((m00 + m11) + m22)
    if (trace > 0) then
        local s93 = (math.sqrt((trace + 1)) * 2)
        w = (0.25 * s93)
        x91 = ((m21 - m12) / s93)
        y92 = ((m02 - m20) / s93)
        z = ((m10 - m01) / s93)
    elseif ((m00 > m11) and (m00 > m22)) then
        local s94 = (math.sqrt((((1 + m00) - m11) - m22)) * 2)
        w = ((m21 - m12) / s94)
        x91 = (0.25 * s94)
        y92 = ((m01 + m10) / s94)
        z = ((m02 + m20) / s94)
    else
        if (m11 > m22) then
            local s95 = (math.sqrt((((1 + m11) - m00) - m22)) * 2)
            w = ((m02 - m20) / s95)
            x91 = ((m01 + m10) / s95)
            y92 = (0.25 * s95)
            z = ((m12 + m21) / s95)
        else
            local s96 = (math.sqrt((((1 + m22) - m00) - m11)) * 2)
            w = ((m10 - m01) / s96)
            x91 = ((m02 + m20) / s96)
            y92 = ((m12 + m21) / s96)
            z = (0.25 * s96)
        end
    end
    return SF__.Quaternion.Normalize(x91, y92, z, w)
end

function SF__.Quaternion.LookRotation__ose(forward__x97, forward__y98, forward__z99)
    return SF__.Quaternion.LookRotation__oseose(forward__x97, forward__y98, forward__z99, SF__.Vector3.get_up())
end

function SF__.Quaternion.Normalize(q__x100, q__y101, q__z102, q__w103)
    local magnitude = math.sqrt(((((q__x100 * q__x100) + (q__y101 * q__y101)) + (q__z102 * q__z102)) + (q__w103 * q__w103)))
    if (magnitude < 0.0001) then
        return SF__.Quaternion.get_identity()
    end
    return (q__x100 / magnitude), (q__y101 / magnitude), (q__z102 / magnitude), (q__w103 / magnitude)
end

function SF__.Quaternion.get_eulerAngles(self__x, self__y, self__z, self__w)
    -- https://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles#Source_Code_2
    local sinr_cosp = (2 * ((self__w * self__x) + (self__y * self__z)))
    local cosr_cosp = (1 - (2 * ((self__x * self__x) + (self__y * self__y))))
    local roll104 = math.atan(sinr_cosp, cosr_cosp)
    local sinp = (2 * ((self__w * self__y) - (self__z * self__x)))
    local pitch105
    if (math.abs(sinp) >= 1) then
        pitch105 = ((math.sign(sinp) * math.pi) / 2)
        -- use 90 degrees if out of range
    else
        pitch105 = math.asin(sinp)
    end
    local siny_cosp = (2 * ((self__w * self__z) + (self__x * self__y)))
    local cosy_cosp = (1 - (2 * ((self__y * self__y) + (self__z * self__z))))
    local yaw106 = math.atan(siny_cosp, cosy_cosp)
    return (pitch105 * bj_RADTODEG), (yaw106 * bj_RADTODEG), (roll104 * bj_RADTODEG)
end

function SF__.Quaternion.get_normalized(self__x107, self__y108, self__z109, self__w110)
    return SF__.Quaternion.Normalize(self__x107, self__y108, self__z109, self__w110)
end

function SF__.Quaternion.Inverse(rotation__x, rotation__y, rotation__z, rotation__w)
    return (-rotation__x), (-rotation__y), (-rotation__z), rotation__w
end

function SF__.Quaternion.ToString(self__x115, self__y116, self__z117, self__w118)
    return SF__.StrConcat__("(", self__x115, ", ", self__y116, ", ", self__z117, ", ", self__w118, ")")
end

function SF__.Quaternion.ApplyToEffect(self__x119, self__y120, self__z121, self__w122, e)
    local angles__x, angles__y, angles__z = SF__.Quaternion.get_eulerAngles(self__x119, self__y120, self__z121, self__w122)
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
        for _, item673 in (SF__.StdLib.List.IpairsNext)(collection1) do
            repeat
                table.insert(self._items, item673)
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

function SF__.StdLib.List:get_Item(index674)
    if ((index674 < 0) or (index674 >= self.Count)) then
        error(SF__.StrConcat__("SF__E2e5944b8", "Index out of range"))
    end
    return self._items[(index674 + 1)]
end

function SF__.StdLib.List:set_Item(index675, value676)
    if ((index675 < 0) or (index675 >= self.Count)) then
        error(SF__.StrConcat__("SF__E2e5944b8", "Index out of range"))
    end
    self._items[(index675 + 1)] = value676
end

function SF__.StdLib.List:AddRange(collection677)
    do
        local collection2 = collection677
        for _, item678 in (SF__.StdLib.List.IpairsNext)(collection2) do
            repeat
                table.insert(self._items, item678)
                self.Count = (self.Count + 1)
            until true
        end
    end
    self._version = (self._version + 1)
end

function SF__.StdLib.List:Add(item679)
    table.insert(self._items, item679)
    self.Count = (self.Count + 1)
    self._version = (self._version + 1)
end

function SF__.StdLib.List:Clear()
    self._items = {}
    self.Count = 0
    self._version = (self._version + 1)
end

function SF__.StdLib.List:Remove(item680)
    local index681 = self:IndexOf(item680)
    if (index681 < 0) then
        return false
    end
    self:RemoveAt(index681)
    return true
end

function SF__.StdLib.List:RemoveAt(index682)
    table.remove(self._items, (index682 + 1))
    self.Count = (self.Count - 1)
    self._version = (self._version + 1)
end

function SF__.StdLib.List:IndexOf(item683)
    do
        local i684 = 0
        while (i684 < self.Count) do
            repeat
                local current685 = self._items[(i684 + 1)]
                if (current685 == item683) then
                    return i684
                end
            until true
            i684 = (i684 + 1)
        end
    end
    return (-1)
end

function SF__.StdLib.List.DefaultCompare(a686, b687)
    if (a686 == b687) then
        return 0
    end
    if (a686 < b687) then
        return (-1)
    end
    return 1
end

function SF__.StdLib.List:Sort(comparison)
    if (comparison == nil) then
        comparison = SF__.StdLib.List.DefaultCompare
    end
    local version688 = self._version
    table.sort(self._items, function(a691, b692)
        return (comparison(a691, b692) < 0)
    end)
    if (version688 ~= self._version) then
        error(SF__.StrConcat__("SF__E2e5944b8", "Collection was modified"))
    end
    self._version = (self._version + 1)
end

function SF__.StdLib.List:IpairsNext()
    local version693 = self._version
    local index694 = 0
    return function()
        if (version693 ~= self._version) then
            error(SF__.StrConcat__("SF__E2e5944b8", "Collection was modified"))
        end
        index694 = (index694 + 1)
        local value695 = self._items[index694]
        if (value695 == nil) then
            return nil
        end
        return index694, value695
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
    local globalPos__x17, globalPos__y18, globalPos__z19 = self.localPosition__x, self.localPosition__y, self.localPosition__z
    local globalRot__x20, globalRot__y21, globalRot__z22, globalRot__w23 = self.localRotation__x, self.localRotation__y, self.localRotation__z, self.localRotation__w
    local globalScale__x24, globalScale__y25, globalScale__z26 = self.localScale__x, self.localScale__y, self.localScale__z
    local myParent = self.parent
    while (myParent ~= nil) do
        repeat
            globalPos__x17, globalPos__y18, globalPos__z19 = SF__.Vector3.op_Addition(myParent.localPosition__x, myParent.localPosition__y, myParent.localPosition__z, SF__.Quaternion.op_Multiply__iyiose(myParent.localRotation__x, myParent.localRotation__y, myParent.localRotation__z, myParent.localRotation__w, SF__.Vector3.Scale(myParent.localScale__x, myParent.localScale__y, myParent.localScale__z, globalPos__x17, globalPos__y18, globalPos__z19)))
            globalRot__x20, globalRot__y21, globalRot__z22, globalRot__w23 = SF__.Quaternion.op_Multiply__iyiiyi(myParent.localRotation__x, myParent.localRotation__y, myParent.localRotation__z, myParent.localRotation__w, globalRot__x20, globalRot__y21, globalRot__z22, globalRot__w23)
            globalScale__x24, globalScale__y25, globalScale__z26 = SF__.Vector3.Scale(myParent.localScale__x, myParent.localScale__y, myParent.localScale__z, globalScale__x24, globalScale__y25, globalScale__z26)
            myParent = myParent.parent
        until true
    end
    return globalPos__x17, globalPos__y18, globalPos__z19
end

function SF__.Transform:set_position(value__x, value__y, value__z)
    if (self.parent == nil) then
        self.localPosition__x, self.localPosition__y, self.localPosition__z = value__x, value__y, value__z
        return
    end
    local pos__x, pos__y, pos__z = value__x, value__y, value__z
    local myParent27 = self.parent
    while (myParent27 ~= nil) do
        repeat
            pos__x, pos__y, pos__z = SF__.Vector3.op_Subtraction(pos__x, pos__y, pos__z, myParent27.localPosition__x, myParent27.localPosition__y, myParent27.localPosition__z)
            pos__x, pos__y, pos__z = SF__.Vector3.Scale((1 / myParent27.localScale__x), (1 / myParent27.localScale__y), (1 / myParent27.localScale__z), pos__x, pos__y, pos__z)
            pos__x, pos__y, pos__z = (function()
                local q__x, q__y, q__z, q__w = SF__.Quaternion.Inverse(myParent27.localRotation__x, myParent27.localRotation__y, myParent27.localRotation__z, myParent27.localRotation__w)
                return SF__.Quaternion.op_Multiply__iyiose(q__x, q__y, q__z, q__w, pos__x, pos__y, pos__z)
            end)()
            myParent27 = myParent27.parent
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
    local parts28 = SF__.StrSplit__(name, "/")
    return SF__.Transform._Find(self, parts28, 0)
end
-- GameObject
SF__.GameObject = SF__.GameObject or {}
SF__.GameObject.Name = "GameObject"
SF__.GameObject.FullName = "GameObject"
function SF__.GameObject.MarkDestroyQueuedDepthFirst(obj31)
    if (obj31.isDestroyQueued or obj31.isDestroyed) then
        return
    end
    obj31.isDestroyQueued = true
    do
        local collection4 = obj31.transform.children
        for _, child32 in (SF__.StdLib.List.IpairsNext)(collection4) do
            repeat
                SF__.GameObject.MarkDestroyQueuedDepthFirst(child32.gameObject)
            until true
        end
    end
end

function SF__.GameObject.DestroyDepthFirst(obj33)
    if obj33.isDestroyed then
        return
    end
    local children = obj33.transform.children
    do
        local i = (children.Count - 1)
        while (i >= 0) do
            repeat
                SF__.GameObject.DestroyDepthFirst(children:get_Item(i).gameObject)
            until true
            i = (i - 1)
        end
    end
    obj33.transform:SetParent(nil)
    do
        local collection5 = obj33._components
        for _, comp in (SF__.StdLib.List.IpairsNext)(collection5) do
            repeat
                comp:OnDisable()
                comp:OnDestroy()
            until true
        end
    end
    obj33._components:Clear()
    SF__.Scene.get_Instance().gameObjs:Remove(obj33)
    obj33.isDestroyed = true
end

function SF__.GameObject:get_components()
    return self._components
end

function SF__.GameObject.__Init__s(self, name34)
    self.__sf_type = SF__.GameObject
    self.name = nil
    self.transform = nil
    self._components = SF__.StdLib.List.New__0()
    self.isDestroyQueued = false
    self.isDestroyed = false
    self.name = name34
    self.transform = self:AddComponent(SF__.Transform)
    SF__.Scene.get_Instance():AddGameObject(self)
end

function SF__.GameObject.New__s(name34)
    local self = setmetatable({}, { __index = SF__.GameObject })
    SF__.GameObject.__Init__s(self, name34)
    return self
end

function SF__.GameObject.__Init__sx13(self, name35, parent36)
    SF__.GameObject.__Init__s(self, name35)
    self.transform:SetParent(parent36.transform)
end

function SF__.GameObject.New__sx13(name35, parent36)
    local self = setmetatable({}, { __index = SF__.GameObject })
    SF__.GameObject.__Init__sx13(self, name35, parent36)
    return self
end

function SF__.GameObject:GetComponent(T)
    do
        local collection6 = self._components
        for _, comp37 in (SF__.StdLib.List.IpairsNext)(collection6) do
            repeat
                do
                    local tComp = comp37
                    if SF__.TypeIs__(tComp, T) then
                        return tComp
                    end
                end
            until true
        end
    end
    return nil
end

function SF__.GameObject:AddComponent(T38)
    local comp39 = (function()
        local obj40 = T38.New()
        obj40.gameObject = self
        return obj40
    end)()
    self._components:Add(comp39)
    comp39:Awake()
    comp39:OnEnable()
    comp39:Start()
    return comp39
end

function SF__.GameObject:RemoveAllComponents(T41)
    do
        local i42 = (self._components.Count - 1)
        while (i42 >= 0) do
            repeat
                if SF__.TypeIs__(self._components:get_Item(i42), T41) then
                    self._components:get_Item(i42):OnDisable()
                    self._components:get_Item(i42):OnDestroy()
                    self._components:RemoveAt(i42)
                end
            until true
            i42 = (i42 - 1)
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
        for _, comp43 in (SF__.StdLib.List.IpairsNext)(collection7) do
            repeat
                comp43:Update()
            until true
        end
    end
end

function SF__.GameObject:LateUpdate()
    if (self.isDestroyQueued or self.isDestroyed) then
        return
    end
    local snapshot44 = SF__.StdLib.List.New__xqm20z(self._components)
    do
        local collection8 = snapshot44
        for _, comp45 in (SF__.StdLib.List.IpairsNext)(collection8) do
            repeat
                comp45:LateUpdate()
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

function SF__.GameObject.DestroyQueued(obj46)
    SF__.GameObject.DestroyDepthFirst(obj46)
end

function SF__.GameObject:GetComponentInChildren(T47)
    do
        local collection9 = self.transform.children
        for _, child48 in (SF__.StdLib.List.IpairsNext)(collection9) do
            repeat
                local comp49 = child48.gameObject:GetComponent(T47)
                if (comp49 ~= nil) then
                    return comp49
                end
                comp49 = child48.gameObject:GetComponentInChildren(T47)
                if (comp49 ~= nil) then
                    return comp49
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

function SF__.Scene:AddGameObject(obj50)
    self.gameObjs:Add(obj50)
end

function SF__.Scene:QueueDestroy(obj51)
    self._destroyQueue:Add(obj51)
end

function SF__.Scene:FlushDestroyQueue()
    do
        local i52 = 0
        while (i52 < self._destroyQueue.Count) do
            repeat
                SF__.GameObject.DestroyQueued(self._destroyQueue:get_Item(i52))
            until true
            i52 = (i52 + 1)
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
                    local i53 = 0
                    while (i53 < count) do
                        repeat
                            self.gameObjs:get_Item(i53):Update()
                        until true
                        i53 = (i53 + 1)
                    end
                end
                do
                    local i54 = 0
                    while (i54 < count) do
                        repeat
                            self.gameObjs:get_Item(i54):LateUpdate()
                        until true
                        i54 = (i54 + 1)
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
    return SF__.StrConcat__("Effect: ", (function() if (self.eff == nil) then return "None" else return "Attached" end end)(), "\n_tarPos: ", SF__.Vector3.ToString(self._tarPos__x, self._tarPos__y, self._tarPos__z))
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
    self._tarPos__x, self._tarPos__y, self._tarPos__z = globalPos__x, globalPos__y, globalPos__z
    if (self._lerpElapsed < self._lerpDuration) then
        self._tarPos__x, self._tarPos__y, self._tarPos__z = SF__.Vector3.Lerp(self._lastPos__x, self._lastPos__y, self._lastPos__z, globalPos__x, globalPos__y, globalPos__z, (self._lerpElapsed / self._lerpDuration))
    end
    BlzSetSpecialEffectPosition(self.eff, self._tarPos__x, self._tarPos__y, self._tarPos__z)
    self._lastPos__x, self._lastPos__y, self._lastPos__z = self._tarPos__x, self._tarPos__y, self._tarPos__z
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
    self._tarPos__x = 0
    self._tarPos__y = 0
    self._tarPos__z = 0
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

function SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p124, abilCode125, researchExtendedTooltip, level126)
    if (GetLocalPlayer() ~= p124) then
        return
    end
    BlzSetAbilityResearchExtendedTooltip(abilCode125, researchExtendedTooltip, level126)
end

function SF__.Utils.ExBlzSetAbilityTooltip(p127, abilCode128, tooltip, level129)
    if (GetLocalPlayer() ~= p127) then
        return
    end
    BlzSetAbilityTooltip(abilCode128, tooltip, level129)
end

function SF__.Utils.ExBlzSetAbilityExtendedTooltip(p130, abilCode131, extendedTooltip, level132)
    if (GetLocalPlayer() ~= p130) then
        return
    end
    BlzSetAbilityExtendedTooltip(abilCode131, extendedTooltip, level132)
end

function SF__.Utils.ExBlzSetAbilityIcon(p133, abilCode134, iconPath)
    if (GetLocalPlayer() ~= p133) then
        return
    end
    BlzSetAbilityIcon(abilCode134, iconPath)
end

function SF__.Utils.CsGroupGetUnitsInRange(x135, y136, radius, filter)
    local result = SF__.StdLib.List.New__0()
    ExGroupEnumUnitsInRange(x135, y136, radius, function(u138)
        if filter(u138) then
            result:Add(u138)
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
-- TemplarStrikes
SF__.TemplarStrikes = SF__.TemplarStrikes or {}
SF__.TemplarStrikes.Name = "TemplarStrikes"
SF__.TemplarStrikes.FullName = "TemplarStrikes"
function SF__.TemplarStrikes.GetAbilityData(level534)
    return 2, (0.5 + (0.25 * level534)), (0.1 * level534)
end

function SF__.TemplarStrikes.Init()
    local EventCenter535 = require("Lib.EventCenter")
    EventCenter535.RegisterPlayerUnitSpellEffect:Emit({id = SF__.TemplarStrikes.ID, handler = SF__.TemplarStrikes.Start})
    ExTriggerRegisterNewUnit(function(u537)
        if (GetUnitTypeId(u537) == FourCC("Hpal")) then
            SF__.TemplarStrikes.UpdateAbilityMeta(u537)
        end
    end)
    EventCenter535.RegisterPlayerUnitDamaged:Emit(function(caster541, target542, damage543, weapType544, dmgType545, isAttack546)
        if (GetUnitAbilityLevel(caster541, SF__.TemplarStrikes.ID) <= 0) then
            return
        end
        if (not isAttack546) then
            return
        end
        if (target542 == nil) then
            return
        end
        if ExIsUnitDead(target542) then
            return
        end
        SF__.TemplarStrikes.TryResetBOJ(caster541)
    end)
end

function SF__.TemplarStrikes.TryResetBOJ(caster547)
    local level548 = GetUnitAbilityLevel(caster547, SF__.TemplarStrikes.ID)
    local ad__AttackCount, ad__DamageScaling549, ad__ResetBOJChance = SF__.TemplarStrikes.GetAbilityData(level548)
    if (math.random() >= ad__ResetBOJChance) then
        return
    end
    BlzEndUnitAbilityCooldown(caster547, SF__.BladeOfJustice.ID)
    ExAddSpecialEffectTarget("Abilities/Spells/Items/AIam/AIamTarget.mdl", caster547, "origin", 0.3)
end

function SF__.TemplarStrikes.UpdateAbilityMeta(u550)
    local p551 = GetOwningPlayer(u550)
    local datas552 = SF__.StdLib.List.New__0()
    do
        local i553 = 0
        while (i553 < SF__.TemplarStrikes.MaxLevel) do
            repeat
                local __pack_AttackCount, __pack_DamageScaling554, __pack_ResetBOJChance = SF__.TemplarStrikes.GetAbilityData((i553 + 1))
                datas552:Add({AttackCount = __pack_AttackCount, DamageScaling = __pack_DamageScaling554, ResetBOJChance = __pack_ResetBOJChance})
            until true
            i553 = (i553 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p551, SF__.TemplarStrikes.ID, "学习圣殿骑士之击 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p551, SF__.TemplarStrikes.ID, SF__.StrConcat__("快速攻击目标|cffff8c00", datas552:get_Item(0).AttackCount, "|r次，第一次造成普通攻击伤害，第二次造成光辉伤害，有一定几率重置公正之剑的冷却时间，普通攻击也会触发。\n\n|cff99ccff冷却时间|r - 10秒\n\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas552:get_Item(0).DamageScaling * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas552:get_Item(0).ResetBOJChance * 100)), "%|r的几率重置公正之剑。\n|cffffcc002级|r - |cffff8c00", string.format("%.0f", (datas552:get_Item(1).DamageScaling * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas552:get_Item(1).ResetBOJChance * 100)), "%|r的几率重置公正之剑。\n|cffffcc003级|r - |cffff8c00", string.format("%.0f", (datas552:get_Item(2).DamageScaling * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas552:get_Item(2).ResetBOJChance * 100)), "%|r的几率重置公正之剑。"), 0)
    do
        local i555 = 0
        while (i555 < SF__.TemplarStrikes.MaxLevel) do
            repeat
                local __unpack_tmp557 = datas552:get_Item(i555)
                local data__AttackCount, data__DamageScaling556, data__ResetBOJChance = __unpack_tmp557.AttackCount, __unpack_tmp557.DamageScaling, __unpack_tmp557.ResetBOJChance
                SF__.Utils.ExBlzSetAbilityTooltip(p551, SF__.TemplarStrikes.ID, SF__.StrConcat__("圣殿骑士之击 - [|cffffcc00", (i555 + 1), "级|r]"), i555)
                SF__.Utils.ExBlzSetAbilityExtendedTooltip(p551, SF__.TemplarStrikes.ID, SF__.StrConcat__("快速攻击目标|cffff8c00", data__AttackCount, "|r次，第一次造成普通攻击伤害，第二次造成普通攻击|cffff8c00", string.format("%.0f", (data__DamageScaling556 * 100)), "%|r的光辉伤害，|cffff8c00", string.format("%.0f", (data__ResetBOJChance * 100)), "%|r几率重置公正之剑的冷却时间，普通攻击也会触发。\n\n|cff99ccff冷却时间|r - 10秒"), i555)
            until true
            i555 = (i555 + 1)
        end
    end
end

function SF__.TemplarStrikes.Start(data558)
    return SF__.CorRun__(function()
        local level559 = GetUnitAbilityLevel(data558.caster, SF__.TemplarStrikes.ID)
        local UnitAttribute561 = require("Objects.UnitAttribute")
        local BuffBase563 = require("Objects.BuffBase")
        local EventCenter564 = require("Lib.EventCenter")
        local attr560 = UnitAttribute561.GetAttr(data558.caster)
        local normalDamage = attr560:SimMeleeAttack()
        local hasWoa562 = (BuffBase563.FindBuffByClassName(data558.caster, "WakeOfAshesBuff") ~= nil)
        EventCenter564.Damage:Emit({whichUnit = data558.caster, target = data558.target, amount = normalDamage, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
        SF__.TemplarStrikes.TryResetBOJ(data558.caster)
        if hasWoa562 then
            SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(data558.caster, 1)
        end
        SetUnitTimeScale(data558.caster, 3)
        ResetUnitAnimation(data558.caster)
        SetUnitAnimation(data558.caster, "attack - 2")
        SF__.CorWait__(math.round(((1.166 * 0.33) * 1000)))
        local tarAttr565 = UnitAttribute561.GetAttr(data558.target)
        local ad__AttackCount566, ad__DamageScaling567, ad__ResetBOJChance568 = SF__.TemplarStrikes.GetAbilityData(level559)
        local radiantDamage = ((attr560:SimMeleeAttack() * ad__DamageScaling567) * (1 - tarAttr565.radiantResistance))
        EventCenter564.Damage:Emit({whichUnit = data558.caster, target = data558.target, amount = radiantDamage, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
        SF__.TemplarStrikes.TryResetBOJ(data558.caster)
        if hasWoa562 then
            SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(data558.caster, 1)
        end
        SetUnitTimeScale(data558.caster, 1)
        ResetUnitAnimation(data558.caster)
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
-- WakeOfAshes
SF__.WakeOfAshes = SF__.WakeOfAshes or {}
SF__.WakeOfAshes.Name = "WakeOfAshes"
SF__.WakeOfAshes.FullName = "WakeOfAshes"
function SF__.WakeOfAshes.Init()
    local EventCenter591 = require("Lib.EventCenter")
    EventCenter591.RegisterPlayerUnitSpellEffect:Emit({id = SF__.WakeOfAshes.ID, handler = SF__.WakeOfAshes.Start})
    ExTriggerRegisterNewUnit(function(u593)
        if (GetUnitTypeId(u593) == FourCC("Hpal")) then
            SF__.WakeOfAshes.UpdateAbilityMeta(u593)
        end
    end)
end

function SF__.WakeOfAshes.UpdateAbilityMeta(u594)
    local p595 = GetOwningPlayer(u594)
    SF__.Utils.ExSetAbilityResearchTooltip(p595, SF__.WakeOfAshes.ID, "学习灰烬觉醒 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p595, SF__.WakeOfAshes.ID, "对你前方敌人造成|cffff8c00300|r点光辉伤害，并激活复仇之怒效果，在复仇之怒效果期间：\n· 每消耗|cffff8c001|r点神圣能量，圣殿骑士之击与公正之剑的冷却时间缩短|cffff8c005%|r。\n· 每产生|cffff8c001|r点神圣能量，治疗自己|cffff8c00100|r生命值，享受智力加成。\n· 圣殿骑士之击的攻击会获得神圣能量。\n· 荣耀圣令的治疗效果提高|cffff8c00100%|r。\n· 神圣风暴被替换为圣光之锤。\n\n|cff99ccff冷却时间|r - 60秒\n\n|cffffcc00圣光之锤|r\n对当前目标造成|cffff8c00450|r点光辉伤害，另外对附近所有目标造成|cffff8c00350|r点光辉伤害。使神圣之锤的持续时间延长|cffff8c008|r秒。消耗|cffff8c003|r神圣能量", 0)
    do
        local i596 = 0
        while (i596 < 1) do
            repeat
                SF__.Utils.ExBlzSetAbilityTooltip(p595, SF__.WakeOfAshes.ID, SF__.StrConcat__("灰烬觉醒 - [|cffffcc00", (i596 + 1), "级|r]"), i596)
                SF__.Utils.ExBlzSetAbilityExtendedTooltip(p595, SF__.WakeOfAshes.ID, "对你前方敌人造成|cffff8c00300|r点光辉伤害，并激活复仇之怒效果，在复仇之怒效果期间：\n· 每消耗|cffff8c001|r点神圣能量，圣殿骑士之击与公正之剑的冷却时间缩短|cffff8c005%|r。\n· 每产生|cffff8c001|r点神圣能量，治疗自己|cffff8c00100|r生命值，享受智力加成。\n· 圣殿骑士之击的攻击会获得神圣能量。\n· 荣耀圣令的治疗效果提高|cffff8c00100%|r。\n· 神圣风暴被替换为圣光之锤。\n\n|cff99ccff冷却时间|r - 60秒\n\n|cffffcc00圣光之锤|r\n神圣能量重击地面，对附近所有目标造成|cffff8c00350|r点光辉伤害。使神圣之锤的持续时间延长|cffff8c008|r秒。消耗|cffff8c003|r神圣能量", i596)
            until true
            i596 = (i596 + 1)
        end
    end
end

function SF__.WakeOfAshes.Start(data597)
    local pos__x598, pos__y599, pos__z600 = SF__.Vector3.FromUnit(data597.caster)
    local UnitAttribute609 = require("Objects.UnitAttribute")
    local EventCenter610 = require("Lib.EventCenter")
    local BuffBase636 = require("Objects.BuffBase")
    local facing = GetUnitFacing(data597.caster)
    local forward__x601, forward__y602, forward__z603 = math.cos((facing * bj_DEGTORAD)), math.sin((facing * bj_DEGTORAD)), 0
    ExGroupEnumUnitsInRange(pos__x598, pos__y599, 400, function(u611)
        if (not IsUnitEnemy(u611, GetOwningPlayer(data597.caster))) then
            return
        end
        if ExIsUnitDead(u611) then
            return
        end
        local direction__x615, direction__y616, direction__z617 = SF__.Vector3.get_normalized((function()
            local a__x612, a__y613, a__z614 = SF__.Vector3.FromUnit(u611)
            return SF__.Vector3.op_Subtraction(a__x612, a__y613, a__z614, pos__x598, pos__y599, pos__z600)
        end)())
        if (SF__.Vector3.Dot(forward__x601, forward__y602, forward__z603, direction__x615, direction__y616, direction__z617) < 0.5) then
            return
        end
        local attr618 = UnitAttribute609.GetAttr(u611)
        EventCenter610.Damage:Emit({whichUnit = data597.caster, target = u611, amount = (200 * (1 - attr618.radiantResistance)), attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
    end)
    -- fire breath visual
    local eff619 = AddSpecialEffect("Abilities/Spells/Other/BreathOfFire/BreathOfFireMissile.mdl", pos__x598, pos__y599)
    local rotation__x620, rotation__y621, rotation__z622, rotation__w623 = SF__.Quaternion.Euler(0, facing, 0)
    local effPos__x, effPos__y, effPos__z = pos__x598, pos__y599, 0
    local effStart__x, effStart__y, effStart__z = SF__.Vector3.op_Addition(effPos__x, effPos__y, effPos__z, (function()
        local v__x624, v__y625, v__z626 = SF__.Quaternion.op_Multiply__iyiose(rotation__x620, rotation__y621, rotation__z622, rotation__w623, SF__.Vector3.get_right())
        return SF__.Vector3.op_Multiply__osef(v__x624, v__y625, v__z626, 200)
    end)())
    local dest__x, dest__y, dest__z = SF__.Vector3.op_Addition(effPos__x, effPos__y, effPos__z, (function()
        local v__x627, v__y628, v__z629 = SF__.Quaternion.op_Multiply__iyiose(rotation__x620, rotation__y621, rotation__z622, rotation__w623, SF__.Vector3.get_right())
        return SF__.Vector3.op_Multiply__osef(v__x627, v__y628, v__z629, 800)
    end)())
    local fireRoot = SF__.GameObject.New__s("fire_breath")
    fireRoot.transform.localPosition__x, fireRoot.transform.localPosition__y, fireRoot.transform.localPosition__z = effStart__x, effStart__y, pos__z600
    fireRoot:AddComponent(SF__.Missile):SetupPointTarget(dest__x, dest__y, pos__z600, 900, function(mis631, arrivedAt__x632, arrivedAt__y633, arrivedAt__z634)
        mis631.gameObject:Destroy()
    end)
    local rotOffset = SF__.GameObject.New__sx13("rot_offset", fireRoot)
    rotOffset.transform.localRotation__x, rotOffset.transform.localRotation__y, rotOffset.transform.localRotation__z, rotOffset.transform.localRotation__w = SF__.Quaternion.Euler(0, 90, 0)
    rotOffset:AddComponent(SF__.AttachEffectComponent):AttachEffect(eff619)
    -- buffs
    local buff635 = BuffBase636.FindBuffByClassName(data597.caster, "WakeOfAshesBuff")
    if (buff635 ~= nil) then
        buff635:ResetDuration()
    else
        SF__.WakeOfAshes.WakeOfAshesBuff.New(data597.caster, data597.caster, 30, 1, {level = 0, charged = 0})
    end
end

function SF__.WakeOfAshes.__Init(self)
    self.__sf_type = SF__.WakeOfAshes
end

function SF__.WakeOfAshes.New()
    local self = setmetatable({}, { __index = SF__.WakeOfAshes })
    SF__.WakeOfAshes.__Init(self)
    return self
end

SF__.WakeOfAshes.ID = FourCC("A009")
SF__.WakeOfAshes = SF__.WakeOfAshes or {}
-- WakeOfAshes.QuicknessBuff
local BuffBase645 = require("Objects.BuffBase")
SF__.WakeOfAshes.QuicknessBuff = SF__.WakeOfAshes.QuicknessBuff or class("QuicknessBuff", BuffBase645)
SF__.WakeOfAshes.QuicknessBuff.Name = "QuicknessBuff"
SF__.WakeOfAshes.QuicknessBuff.FullName = "WakeOfAshes.QuicknessBuff"
SF__.WakeOfAshes.QuicknessBuff.__sf_base = BuffBase645
function SF__.WakeOfAshes.QuicknessBuff.__Init(self, caster646, target647, duration648, interval649, awakeData650)
    self.__sf_type = SF__.WakeOfAshes.QuicknessBuff
end

function SF__.WakeOfAshes.QuicknessBuff.New(caster646, target647, duration648, interval649, awakeData650)
    local self = SF__.WakeOfAshes.QuicknessBuff.new(caster646, target647, duration648, interval649, awakeData650)
    SF__.WakeOfAshes.QuicknessBuff.__Init(self, caster646, target647, duration648, interval649, awakeData650)
    return self
end

function SF__.WakeOfAshes.QuicknessBuff:OnDisable()
    do
        local i651 = 0
        while (i651 < 3) do
            repeat
                BlzSetUnitAbilityCooldown(self.target, SF__.BladeOfJustice.ID, i651, 10)
                BlzSetUnitAbilityCooldown(self.target, SF__.TemplarStrikes.ID, i651, 10)
            until true
            i651 = (i651 + 1)
        end
    end
end
-- RetributionPaladinGlobal
SF__.RetributionPaladinGlobal = SF__.RetributionPaladinGlobal or {}
SF__.RetributionPaladinGlobal.Name = "RetributionPaladinGlobal"
SF__.RetributionPaladinGlobal.FullName = "RetributionPaladinGlobal"
function SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(u513, amount)
    local UnitAttribute515 = require("Objects.UnitAttribute")
    local BuffBase517 = require("Objects.BuffBase")
    local EventCenter518 = require("Lib.EventCenter")
    local attr514 = UnitAttribute515.GetAttr(u513)
    local before = attr514.retPalHolyEnergy
    attr514.retPalHolyEnergy = math.min((attr514.retPalHolyEnergy + amount), 5)
    local increased = (attr514.retPalHolyEnergy - before)
    -- wake of ashes
    local buff516 = BuffBase517.FindBuffByClassName(u513, "WakeOfAshesBuff")
    if (buff516 ~= nil) then
        local heal = ((100 + GetHeroInt(u513, true)) * increased)
        EventCenter518.Heal:Emit({caster = u513, target = u513, amount = heal})
        ExAddSpecialEffectTarget("Abilities/Spells/Items/AIhe/AIheTarget.mdl", u513, "origin", 0.2)
    end
end

function SF__.RetributionPaladinGlobal.ConsumeHolyEnergy(u519, amount520)
    local UnitAttribute522 = require("Objects.UnitAttribute")
    local BuffBase525 = require("Objects.BuffBase")
    local attr521 = UnitAttribute522.GetAttr(u519)
    local before523 = attr521.retPalHolyEnergy
    attr521.retPalHolyEnergy = math.max((attr521.retPalHolyEnergy - amount520), 0)
    local consumed = (before523 - attr521.retPalHolyEnergy)
    -- wake of ashes
    local buff524 = BuffBase525.FindBuffByClassName(u519, "WakeOfAshesBuff")
    if (buff524 ~= nil) then
        local quickness = BuffBase525.FindBuffByClassName(u519, "QuicknessBuff")
        if (quickness == nil) then
            quickness = SF__.WakeOfAshes.QuicknessBuff.New(u519, u519, 9999, 9999, {})
        end
        quickness:IncreaseStack(consumed)
        local cd = math.max((10 * (1 - (0.05 * quickness.stack))), 1)
        do
            local i526 = 0
            while (i526 < 3) do
                repeat
                    BlzSetUnitAbilityCooldown(u519, SF__.BladeOfJustice.ID, i526, cd)
                    BlzSetUnitAbilityCooldown(u519, SF__.TemplarStrikes.ID, i526, cd)
                until true
                i526 = (i526 + 1)
            end
        end
    end
end

function SF__.RetributionPaladinGlobal:Init()
    ExTriggerRegisterNewUnit(function(u528)
        if (GetUnitTypeId(u528) == FourCC("Hpal")) then
            self._units:Add(u528)
        end
    end)
    _ = self:Start()
end

function SF__.RetributionPaladinGlobal:Start()
    return SF__.CorRun__(function()
        local UnitAttribute531 = require("Objects.UnitAttribute")
        local BuffBase533 = require("Objects.BuffBase")
        while true do
            repeat
                do
                    local collection10 = self._units
                    for _, u529 in (SF__.StdLib.List.IpairsNext)(collection10) do
                        repeat
                            local attr530 = UnitAttribute531.GetAttr(u529)
                            ExSetUnitMana(u529, ((ExGetUnitMaxMana(u529) * attr530.retPalHolyEnergy) * 0.2))
                            -- set word of glory
                            if (attr530.retPalHolyEnergy >= 3) then
                                SF__.Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u529), FourCC("A006"), "ReplaceableTextures/CommandButtons/BTNinv_helmet_96.tga")
                            else
                                SF__.Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u529), FourCC("A006"), "ReplaceableTextures/PassiveButtons/PASBTNinv_helmet_96.tga")
                            end
                            -- set divine storm
                            local hasWoa532 = (BuffBase533.FindBuffByClassName(u529, "WakeOfAshesBuff") ~= nil)
                            if hasWoa532 then
                                if (attr530.retPalHolyEnergy >= 3) then
                                    SF__.Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u529), FourCC("A005"), "ReplaceableTextures/CommandButtons/BTNinv_mace_1h_gryphonrider_d_02_silver.tga")
                                else
                                    SF__.Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u529), FourCC("A005"), "ReplaceableTextures/PassiveButtons/PASBTNinv_mace_1h_gryphonrider_d_02_silver.tga")
                                end
                            elseif (attr530.retPalHolyEnergy >= 3) then
                                SF__.Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u529), FourCC("A005"), "ReplaceableTextures/CommandButtons/BTNability_paladin_divinestorm.tga")
                            else
                                SF__.Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u529), FourCC("A005"), "ReplaceableTextures/PassiveButtons/PASBTNability_paladin_divinestorm.tga")
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
function SF__.BladeOfJustice.GetAbilityData(level328)
    return (75 * level328), 5, (10 * level328)
end

function SF__.BladeOfJustice.Init()
    local EventCenter = require("Lib.EventCenter")
    EventCenter.RegisterPlayerUnitSpellEffect:Emit({id = SF__.BladeOfJustice.ID, handler = SF__.BladeOfJustice.Start})
    ExTriggerRegisterNewUnit(function(u330)
        if (GetUnitTypeId(u330) == FourCC("Hpal")) then
            SF__.BladeOfJustice.UpdateAbilityMeta(u330)
        end
    end)
end

function SF__.BladeOfJustice.UpdateAbilityMeta(u331)
    local p332 = GetOwningPlayer(u331)
    local datas = SF__.StdLib.List.New__0()
    do
        local i333 = 0
        while (i333 < 3) do
            repeat
                local __pack_Damage, __pack_Duration, __pack_DamagePerSecond = SF__.BladeOfJustice.GetAbilityData((i333 + 1))
                datas:Add({Damage = __pack_Damage, Duration = __pack_Duration, DamagePerSecond = __pack_DamagePerSecond})
            until true
            i333 = (i333 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p332, SF__.BladeOfJustice.ID, "学习公正之剑 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p332, SF__.BladeOfJustice.ID, SF__.StrConcat__("用圣光的利刃刺穿目标，造成法术伤害，在一定时间内对附近敌人每秒造成光辉伤害。产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 10秒\n\n|cffffcc001级|r - 造成|cffff8c00", datas:get_Item(0).Damage, "|r的直接法术伤害，|cffff8c00", datas:get_Item(0).Duration, "|r秒内对附近敌人每秒造成|cffff8c00", datas:get_Item(0).DamagePerSecond, "|r的光辉伤害。产生|cffff8c001|r点圣能。\n|cffffcc002级|r - 造成|cffff8c00", datas:get_Item(1).Damage, "|r的直接法术伤害，|cffff8c00", datas:get_Item(1).Duration, "|r秒内对附近敌人每秒造成|cffff8c00", datas:get_Item(1).DamagePerSecond, "|r的光辉伤害。产生|cffff8c001|r点圣能。\n|cffffcc003级|r - 造成|cffff8c00", datas:get_Item(2).Damage, "|r的直接法术伤害，|cffff8c00", datas:get_Item(2).Duration, "|r秒内对附近敌人每秒造成|cffff8c00", datas:get_Item(2).DamagePerSecond, "|r的光辉伤害。产生|cffff8c001|r点圣能。"), 0)
    do
        local i334 = 0
        while (i334 < 3) do
            repeat
                local __unpack_tmp = datas:get_Item(i334)
                local data__Damage, data__Duration, data__DamagePerSecond = __unpack_tmp.Damage, __unpack_tmp.Duration, __unpack_tmp.DamagePerSecond
                SF__.Utils.ExBlzSetAbilityTooltip(p332, SF__.BladeOfJustice.ID, SF__.StrConcat__("公正之剑 - [|cffffcc00", (i334 + 1), "级|r]"), i334)
                SF__.Utils.ExBlzSetAbilityExtendedTooltip(p332, SF__.BladeOfJustice.ID, SF__.StrConcat__("用圣光的利刃刺穿目标，造成|cffff8c00", data__Damage, "|r的直接法术伤害，在|cffff8c00", data__Duration, "|r秒内对附近敌人每秒造成|cffff8c00", data__DamagePerSecond, "|r的光辉伤害。产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 10秒"), i334)
            until true
            i334 = (i334 + 1)
        end
    end
end

function SF__.BladeOfJustice.Start(data)
    local level335 = GetUnitAbilityLevel(data.caster, SF__.BladeOfJustice.ID)
    local EventCenter336 = require("Lib.EventCenter")
    local ad__Damage, ad__Duration, ad__DamagePerSecond = SF__.BladeOfJustice.GetAbilityData(level335)
    EventCenter336.Damage:Emit({whichUnit = data.caster, target = data.target, amount = ad__Damage, attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
    SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(data.caster, 1)
    SF__.BladeOfJustice.New():StartGroudDamage(data.caster, data.target, ad__Damage, ad__Duration, ad__DamagePerSecond)
end

function SF__.BladeOfJustice:StartGroudDamage(caster, target337, ad__Damage338, ad__Duration339, ad__DamagePerSecond340)
    return SF__.CorRun__(function()
        local pos__x341, pos__y342 = SF__.Vector2.FromUnit(target337)
        local UnitAttribute = require("Objects.UnitAttribute")
        local EventCenter347 = require("Lib.EventCenter")
        local eff343 = ExAddSpecialEffect("Abilities/Spells/Orc/LiquidFire/Liquidfire.mdl", pos__x341, pos__y342, ad__Duration339)
        local p344 = GetOwningPlayer(caster)
        do
            local i345 = 0
            while (i345 < ad__Duration339) do
                repeat
                    SF__.CorWait__(1000)
                    ExGroupEnumUnitsInRange(pos__x341, pos__y342, 300, function(u348)
                        if (not IsUnitEnemy(u348, p344)) then
                            return
                        end
                        if ExIsUnitDead(u348) then
                            return
                        end
                        local tarAttr349 = UnitAttribute.GetAttr(u348)
                        local damage350 = (ad__DamagePerSecond340 * (1 - tarAttr349.radiantResistance))
                        EventCenter347.Damage:Emit({whichUnit = caster, target = u348, amount = damage350, attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
                    end)
                until true
                i345 = (i345 + 1)
            end
        end
        DestroyEffect(eff343)
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
function SF__.CrusaderStrike.GetAbilityData(level351)
    return (0.65 + (0.35 * level351)), (0.15 * (level351 - 1))
end

function SF__.CrusaderStrike.Init()
    local EventCenter352 = require("Lib.EventCenter")
    EventCenter352.RegisterPlayerUnitSpellEffect:Emit({id = SF__.CrusaderStrike.ID, handler = SF__.CrusaderStrike.Start})
    ExTriggerRegisterNewUnit(function(u354)
        if (GetUnitTypeId(u354) == FourCC("Hpal")) then
            SF__.CrusaderStrike.UpdateAbilityMeta(u354)
        end
    end)
end

function SF__.CrusaderStrike.UpdateAbilityMeta(u355)
    local p356 = GetOwningPlayer(u355)
    local datas357 = SF__.StdLib.List.New__0()
    do
        local i358 = 0
        while (i358 < 3) do
            repeat
                local __pack_DamageScaling, __pack_ArtOfWarChance = SF__.CrusaderStrike.GetAbilityData((i358 + 1))
                datas357:Add({DamageScaling = __pack_DamageScaling, ArtOfWarChance = __pack_ArtOfWarChance})
            until true
            i358 = (i358 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p356, SF__.CrusaderStrike.ID, "学习十字军打击 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p356, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击造成一次攻击伤害，伤害系数随技能等级提升。产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 6秒\n\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas357:get_Item(0).DamageScaling * 100)), "%|r的攻击伤害。\n|cffffcc002级|r - |cffff8c00", string.format("%.0f", (datas357:get_Item(1).DamageScaling * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas357:get_Item(1).ArtOfWarChance * 100)), "%的战争艺术触发几率。\n|cffffcc003级|r - |cffff8c00", string.format("%.0f", (datas357:get_Item(2).DamageScaling * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas357:get_Item(2).ArtOfWarChance * 100)), "%的战争艺术触发几率。"), 0)
    do
        local i359 = 0
        while (i359 < 3) do
            repeat
                local __unpack_tmp360 = datas357:get_Item(i359)
                local data__DamageScaling, data__ArtOfWarChance = __unpack_tmp360.DamageScaling, __unpack_tmp360.ArtOfWarChance
                SF__.Utils.ExBlzSetAbilityTooltip(p356, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击 - [|cffffcc00", (i359 + 1), "级|r]"), i359)
                SF__.Utils.ExBlzSetAbilityExtendedTooltip(p356, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击造成一次攻击伤害，造成|cffff8c00", string.format("%.0f", (data__DamageScaling * 100)), "%|r的攻击伤害", (function() if (i359 > 0) then return SF__.StrConcat__("，", string.format("%.0f", (data__ArtOfWarChance * 100)), "%的战争艺术触发几率") else return "" end end)(), "。产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 6秒"), i359)
            until true
            i359 = (i359 + 1)
        end
    end
    -- datas.Remove(new IAbilityData { DamageScaling = 0.65f, ArtOfWarChance = 0 });
    datas357:RemoveAt(0)
end

function SF__.CrusaderStrike.Start(data361)
    local level362 = GetUnitAbilityLevel(data361.caster, SF__.CrusaderStrike.ID)
    local UnitAttribute363 = require("Objects.UnitAttribute")
    local EventCenter365 = require("Lib.EventCenter")
    local ad__DamageScaling, ad__ArtOfWarChance = SF__.CrusaderStrike.GetAbilityData(level362)
    local attr = UnitAttribute363.GetAttr(data361.caster)
    local damage364 = (attr:SimAttack(UnitAttribute363.HeroAttributeType.Strength) * ad__DamageScaling)
    EventCenter365.Damage:Emit({whichUnit = data361.caster, target = data361.target, amount = damage364, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
    SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(data361.caster, 1)
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
-- DivineToll
SF__.DivineToll = SF__.DivineToll or {}
SF__.DivineToll.Name = "DivineToll"
SF__.DivineToll.FullName = "DivineToll"
function SF__.DivineToll.GetAbilityData(level387)
    return (2 + level387), (50 * level387), 0.1, 10, (5 + (5 * level387)), 10
end

function SF__.DivineToll.Init()
    local EventCenter390 = require("Lib.EventCenter")
    EventCenter390.RegisterPlayerUnitSpellEffect:Emit({id = SF__.DivineToll.ID, handler = function(data389)
        SF__.DivineToll.Start(data389)
    end})
    ExTriggerRegisterNewUnit(function(u392)
        if (GetUnitTypeId(u392) == FourCC("Hpal")) then
            SF__.DivineToll.UpdateAbilityMeta(u392)
        end
    end)
end

function SF__.DivineToll.UpdateAbilityMeta(u393)
    local p394 = GetOwningPlayer(u393)
    local datas395 = SF__.StdLib.List.New__0()
    do
        local i396 = 0
        while (i396 < 3) do
            repeat
                local __pack_TargetCount, __pack_Damage397, __pack_RadiantDmgAmp, __pack_Duration398, __pack_BHDamage, __pack_DebuffDuration = SF__.DivineToll.GetAbilityData((i396 + 1))
                datas395:Add({TargetCount = __pack_TargetCount, Damage = __pack_Damage397, RadiantDmgAmp = __pack_RadiantDmgAmp, Duration = __pack_Duration398, BHDamage = __pack_BHDamage, DebuffDuration = __pack_DebuffDuration})
            until true
            i396 = (i396 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p394, SF__.DivineToll.ID, "学习圣洁鸣钟 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p394, SF__.DivineToll.ID, SF__.StrConcat__("对附近的多个目标施展审判，造成法术伤害，然后神圣之锤环绕圣殿骑士，每次命中敌人使其受到的光辉伤害提高。每个审判产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 30秒\n\n|cffffcc001级|r - 审判最多|cffff8c00", datas395:get_Item(0).TargetCount, "|r个目标，造成|cffff8c00", datas395:get_Item(0).Damage, "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas395:get_Item(0).RadiantDmgAmp * 100)), "%|r的光辉易伤，持续|cffff8c00", datas395:get_Item(0).Duration, "|r秒。\n|cffffcc002级|r - 审判最多|cffff8c00", datas395:get_Item(1).TargetCount, "|r个目标，造成|cffff8c00", datas395:get_Item(1).Damage, "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas395:get_Item(1).RadiantDmgAmp * 100)), "%|r的光辉易伤，持续|cffff8c00", datas395:get_Item(1).Duration, "|r秒。\n|cffffcc003级|r - 审判最多|cffff8c00", datas395:get_Item(2).TargetCount, "|r个目标，造成|cffff8c00", datas395:get_Item(2).Damage, "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas395:get_Item(2).RadiantDmgAmp * 100)), "%|r的光辉易伤，持续|cffff8c00", datas395:get_Item(2).Duration, "|r秒。"), 0)
    do
        local i399 = 0
        while (i399 < 3) do
            repeat
                local __unpack_tmp402 = datas395:get_Item(i399)
                local data__TargetCount, data__Damage400, data__RadiantDmgAmp, data__Duration401, data__BHDamage, data__DebuffDuration = __unpack_tmp402.TargetCount, __unpack_tmp402.Damage, __unpack_tmp402.RadiantDmgAmp, __unpack_tmp402.Duration, __unpack_tmp402.BHDamage, __unpack_tmp402.DebuffDuration
                SF__.Utils.ExBlzSetAbilityTooltip(p394, SF__.DivineToll.ID, SF__.StrConcat__("圣洁鸣钟 - [|cffffcc00", (i399 + 1), "级|r]"), i399)
                SF__.Utils.ExBlzSetAbilityExtendedTooltip(p394, SF__.DivineToll.ID, SF__.StrConcat__("对附近的最多|cffff8c00", data__TargetCount, "|r个目标施展审判，造成|cffff8c00", data__Damage400, "|r点法术伤害，然后神圣之锤环绕圣殿骑士，每次命中敌人使其受到的光辉伤害提高|cffff8c00", string.format("%.0f", (data__RadiantDmgAmp * 100)), "%|r，持续|cffff8c00", data__Duration401, "|r秒。每个审判产生|cffff8c001|r点圣能。\n\n|cff99ccff冷却时间|r - 30秒"), i399)
            until true
            i399 = (i399 + 1)
        end
    end
end

function SF__.DivineToll.HurlToTarget(caster403, target404, pos__x405, pos__y406, pos__z407)
    local outer = SF__.GameObject.New__s("DivineToll_Outer")
    local EventCenter414 = require("Lib.EventCenter")
    local UnitAttribute420 = require("Objects.UnitAttribute")
    outer.transform.localPosition__x, outer.transform.localPosition__y, outer.transform.localPosition__z = 0, 0, 80
    local moveLayer = SF__.GameObject.New__sx13("MoveLayer", outer)
    moveLayer.transform.localPosition__x, moveLayer.transform.localPosition__y, moveLayer.transform.localPosition__z = pos__x405, pos__y406, pos__z407
    local missile = moveLayer:AddComponent(SF__.Missile)
    missile:SetupUnitTarget(target404, 900, function(mis431, tar432)
        local cPos__x433, cPos__y434, cPos__z435 = mis431.gameObject.transform:get_position()
        local eff436 = ExAddSpecialEffect("Abilities/Spells/Human/StormBolt/StormBoltMissile.mdl", cPos__x433, cPos__y434, 0.1)
        BlzSetSpecialEffectColor(eff436, 255, 255, 0)
        local ad__TargetCount437, ad__Damage438, ad__RadiantDmgAmp439, ad__Duration440, ad__BHDamage441, ad__DebuffDuration442 = SF__.DivineToll.GetAbilityData(GetUnitAbilityLevel(caster403, SF__.DivineToll.ID))
        EventCenter414.Damage:Emit({whichUnit = caster403, target = tar432, amount = ad__Damage438, attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
        SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(caster403, 1)
        -- setup new missile
        mis431:SetupPiercer(function(m451, u452)
            local cPos__x453, cPos__y454, cPos__z455 = m451.gameObject.transform:get_position()
            ExAddSpecialEffectTarget("Abilities/Weapons/FaerieDragonMissile/FaerieDragonMissile.mdl", u452, "origin", 0.1)
            local tarAttr456 = UnitAttribute420.GetAttr(u452)
            local damage457 = (ad__BHDamage441 * (1 - tarAttr456.radiantResistance))
            EventCenter414.Damage:Emit({whichUnit = caster403, target = u452, amount = damage457, attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
            SF__.DivineToll.ApplyDebuff(caster403, u452)
        end, function(u458)
            if (not IsUnitEnemy(u458, GetOwningPlayer(caster403))) then
                return false
            end
            if IsUnitType(u458, UNIT_TYPE_STRUCTURE) then
                return false
            end
            if ExIsUnitDead(u458) then
                return false
            end
            return true
        end, 50, 9999, 0.3)
        -- change movement behaviour
        local aec1459 = moveLayer.transform:Find("DivineToll_Bolt/dt_hand/dt_mis").gameObject:GetComponent(SF__.AttachEffectComponent)
        aec1459:LerpIn(1300)
        local aec2460 = aec1459.gameObject.transform:Find("DivineToll_Holy").gameObject:GetComponent(SF__.AttachEffectComponent)
        aec2460:LerpIn(1300)
        local casterPos__x461, casterPos__y462, casterPos__z463 = SF__.Vector3.FromUnit(caster403)
        local circulator464 = SF__.GameObject.New__sx13("Circulator", outer)
        circulator464.transform.localPosition__x, circulator464.transform.localPosition__y, circulator464.transform.localPosition__z = casterPos__x461, casterPos__y462, casterPos__z463
        local rot465 = circulator464:AddComponent(SF__.AutoTRSComponent)
        rot465.rotation__x, rot465.rotation__y, rot465.rotation__z, rot465.rotation__w = SF__.Quaternion.Euler(0, ((300 * SF__.Scene.DT) / 1000), 0)
        rot465.followUnit = caster403
        moveLayer.transform:SetParent(circulator464.transform)
        moveLayer.transform.localPosition__x, moveLayer.transform.localPosition__y, moveLayer.transform.localPosition__z = 200, 0, 0
        -- set timeout
        local umo466 = SF__.UnitManager.GetGameObjectByUnit(caster403)
        local dtData467 = umo466:GetComponentInChildren(SF__.DivineToll.DivineTollUnitData)
        local dtTimer468
        if (dtData467 == nil) then
            local dtObj469 = SF__.GameObject.New__sx13("DivineTollData", umo466)
            dtData467 = dtObj469:AddComponent(SF__.DivineToll.DivineTollUnitData)
            dtTimer468 = dtObj469:AddComponent(SF__.TimerComponent)
        else
            dtTimer468 = dtData467.gameObject:GetComponent(SF__.TimerComponent)
        end
        dtData467:SetData(outer)
        dtTimer468:StartTimer(ad__Duration440, function()
            dtData467:TimesUp()
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
    local eff470 = AddSpecialEffect("Abilities/Spells/Human/StormBolt/StormBoltMissile.mdl", pos__x405, pos__y406)
    boltMis:AddComponent(SF__.AttachEffectComponent):AttachEffect(eff470)
    local attachedHoly = SF__.GameObject.New__sx13("DivineToll_Holy", boltMis)
    attachedHoly.transform.localPosition__x, attachedHoly.transform.localPosition__y, attachedHoly.transform.localPosition__z = 15, 0, 0
    local effHoly471 = AddSpecialEffect("Abilities/Weapons/FaerieDragonMissile/FaerieDragonMissile.mdl", pos__x405, pos__y406)
    attachedHoly:AddComponent(SF__.AttachEffectComponent):AttachEffect(effHoly471)
    BlzSetSpecialEffectColor(effHoly471, 20, 20, 20)
end

function SF__.DivineToll.ExtendBlessedHammer(caster472)
    local umo473 = SF__.UnitManager.GetGameObjectByUnit(caster472)
    local dtData474 = umo473:GetComponentInChildren(SF__.DivineToll.DivineTollUnitData)
    if (dtData474 == nil) then
        return
    end
    local dtTimer475 = dtData474.gameObject:GetComponent(SF__.TimerComponent)
    dtTimer475:ExtendTime(8)
end

function SF__.DivineToll.Start(data476)
    return SF__.CorRun__(function()
        local pos__x477, pos__y478, pos__z479 = SF__.Vector3.FromUnit(data476.caster)
        local targets = SF__.Utils.CsGroupGetUnitsInRange(pos__x477, pos__y478, 600, function(u480)
            if (not IsUnitEnemy(u480, GetOwningPlayer(data476.caster))) then
                return false
            end
            if IsUnitType(u480, UNIT_TYPE_STRUCTURE) then
                return false
            end
            if ExIsUnitDead(u480) then
                return false
            end
            return true
        end)
        if (targets.Count == 0) then
            return
        end
        targets:Sort(function(a483, b484)
            local distA485 = SF__.Vector3.Distance(pos__x477, pos__y478, pos__z479, SF__.Vector3.FromUnit(a483))
            local distB486 = SF__.Vector3.Distance(pos__x477, pos__y478, pos__z479, SF__.Vector3.FromUnit(b484))
            return (function() if (distA485 == distB486) then return 0 else return (function() if (distA485 < distB486) then return (-1) else return 1 end end)() end end)()
        end)
        do
            local i487 = 0
            while (i487 < (function()
                local field__TargetCount, field__Damage, field__RadiantDmgAmp, field__Duration, field__BHDamage, field__DebuffDuration = SF__.DivineToll.GetAbilityData(GetUnitAbilityLevel(data476.caster, SF__.DivineToll.ID))
                return math.min(targets.Count, field__TargetCount)
            end)()) do
                repeat
                    SF__.DivineToll.HurlToTarget(data476.caster, targets:get_Item(i487), pos__x477, pos__y478, pos__z479)
                    SF__.CorWait__(200)
                until true
                i487 = (i487 + 1)
            end
        end
    end)
end

function SF__.DivineToll.ApplyDebuff(caster488, target489)
    local BuffBase490 = require("Objects.BuffBase")
    local buff = BuffBase490.FindBuffByClassName(target489, "RadiantVulnerability")
    if (buff ~= nil) then
        buff:ResetDuration()
    else
        local ad__TargetCount491, ad__Damage492, ad__RadiantDmgAmp493, ad__Duration494, ad__BHDamage495, ad__DebuffDuration496 = SF__.DivineToll.GetAbilityData(GetUnitAbilityLevel(caster488, SF__.DivineToll.ID))
        SF__.DivineToll.RadiantVulnerability.New(caster488, target489, ad__DebuffDuration496, 99999, {level = 0, charged = 0})
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
-- DivineToll.DivineTollUnitData
SF__.DivineToll.DivineTollUnitData = SF__.DivineToll.DivineTollUnitData or {}
SF__.DivineToll.DivineTollUnitData.Name = "DivineTollUnitData"
SF__.DivineToll.DivineTollUnitData.FullName = "DivineToll.DivineTollUnitData"
setmetatable(SF__.DivineToll.DivineTollUnitData, { __index = SF__.Component })
SF__.DivineToll.DivineTollUnitData.__sf_base = SF__.Component
function SF__.DivineToll.DivineTollUnitData:SetData(missile511)
    self._missiles:Add(missile511)
end

function SF__.DivineToll.DivineTollUnitData:TimesUp()
    do
        local collection11 = self._missiles
        for _, mis512 in (SF__.StdLib.List.IpairsNext)(collection11) do
            repeat
                mis512:Destroy()
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
-- DivineToll.RadiantVulnerability
local BuffBase497 = require("Objects.BuffBase")
SF__.DivineToll.RadiantVulnerability = SF__.DivineToll.RadiantVulnerability or class("RadiantVulnerability", BuffBase497)
SF__.DivineToll.RadiantVulnerability.Name = "RadiantVulnerability"
SF__.DivineToll.RadiantVulnerability.FullName = "DivineToll.RadiantVulnerability"
SF__.DivineToll.RadiantVulnerability.__sf_base = BuffBase497
function SF__.DivineToll.RadiantVulnerability.__Init(self, caster498, target499, duration500, interval, awakeData)
    self.__sf_type = SF__.DivineToll.RadiantVulnerability
    self._vulVal = 0
end

function SF__.DivineToll.RadiantVulnerability.New(caster498, target499, duration500, interval, awakeData)
    local self = SF__.DivineToll.RadiantVulnerability.new(caster498, target499, duration500, interval, awakeData)
    SF__.DivineToll.RadiantVulnerability.__Init(self, caster498, target499, duration500, interval, awakeData)
    return self
end

function SF__.DivineToll.RadiantVulnerability:Awake()
    local ad__TargetCount501, ad__Damage502, ad__RadiantDmgAmp503, ad__Duration504, ad__BHDamage505, ad__DebuffDuration506 = SF__.DivineToll.GetAbilityData(GetUnitAbilityLevel(self.caster, SF__.DivineToll.ID))
    self._vulVal = ad__RadiantDmgAmp503
end

function SF__.DivineToll.RadiantVulnerability:OnEnable()
    local UnitAttribute508 = require("Objects.UnitAttribute")
    local attr507 = UnitAttribute508.GetAttr(self.target)
    attr507.radiantResistance = (attr507.radiantResistance - self._vulVal)
end

function SF__.DivineToll.RadiantVulnerability:OnDisable()
    local UnitAttribute510 = require("Objects.UnitAttribute")
    local attr509 = UnitAttribute510.GetAttr(self.target)
    attr509.radiantResistance = (attr509.radiantResistance + self._vulVal)
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

function SF__.Missile:SetupPointTarget(target__x, target__y, target__z, speed9, onArrived10, colliderSize11, lookAtTarget12)
    if colliderSize11 == nil then colliderSize11 = 32 end
    if lookAtTarget12 == nil then lookAtTarget12 = true end
    self.targetType = SF__.TargetType.Point
    self.pointTarget__x, self.pointTarget__y, self.pointTarget__z = target__x, target__y, target__z
    self.speed = speed9
    self.lookAtTarget = lookAtTarget12
    self.colliderSize = colliderSize11
    self.onArrivedPoint = onArrived10
    self.hasArrived = false
end

function SF__.Missile:SetupPiercer(onThrough, onThroughFilter, colliderSize13, collisionCount, nextHitDelay)
    self.targetType = SF__.TargetType.None
    self.unitTarget = nil
    self.colliderSize = colliderSize13
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
function SF__.TimerComponent:StartTimer(duration14, onComplete)
    self.duration = (duration14 * 1000)
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
        local delegate15 = self.onComplete
        if (delegate15 ~= nil) then
            delegate15()
        end
        self._running = false
    end
end

-- <summary>
--
-- </summary>
-- <param name="duration"> seconds</param>
--
function SF__.TimerComponent:ExtendTime(duration16)
    self.duration = (self.duration + (duration16 * 1000))
end

function SF__.TimerComponent.__Init(self)
    SF__.Component.__Init(self)
    self.__sf_type = SF__.TimerComponent
    self.duration = 0
    self.elapsed = 0
    self.onComplete = nil
    self._running = false
end

function SF__.TimerComponent.New()
    local self = setmetatable({}, { __index = SF__.TimerComponent })
    SF__.TimerComponent.__Init(self)
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

function SF__.UnitManager.GetGameObjectByUnit(u29)
    if (SF__.UnitManager.Instance == nil) then
        error(SF__.StrConcat__("SF__E2e5944b8", "This is weird"))
    end
    local __ret30, obj = SF__.UnitManager.Instance._map:TryGetValue(u29)
    if __ret30 then
        return obj
    end
    local __inc = SF__.UnitManager.unitCounter
    SF__.UnitManager.unitCounter = (SF__.UnitManager.unitCounter + 1)
    obj = SF__.GameObject.New__sx13(SF__.StrConcat__("Unit_", GetUnitName(u29), "_", __inc), SF__.UnitManager.Instance.gameObject)
    SF__.UnitManager.Instance._map:set_Item(u29, obj)
    obj:AddComponent(SF__.AttachUnitComponent):SetUnit(u29)
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
-- DivineStorm
SF__.DivineStorm = SF__.DivineStorm or {}
SF__.DivineStorm.Name = "DivineStorm"
SF__.DivineStorm.FullName = "DivineStorm"
function SF__.DivineStorm.Init()
    local EventCenter366 = require("Lib.EventCenter")
    EventCenter366.RegisterPlayerUnitSpellChannel:Emit({id = SF__.DivineStorm.ID, handler = SF__.DivineStorm.Check})
    EventCenter366.RegisterPlayerUnitSpellEffect:Emit({id = SF__.DivineStorm.ID, handler = SF__.DivineStorm.Start})
    ExTriggerRegisterNewUnit(function(u368)
        if (GetUnitTypeId(u368) == FourCC("Hpal")) then
            SF__.DivineStorm.UpdateAbilityMeta(u368)
        end
    end)
end

function SF__.DivineStorm.Check(data369)
    local UnitAttribute371 = require("Objects.UnitAttribute")
    local attr370 = UnitAttribute371.GetAttr(data369.caster)
    if (attr370.retPalHolyEnergy < 3) then
        IssueImmediateOrderById(data369.caster, SF__.ConstOrderId.Stop)
        ExTextState(data369.caster, "圣能不足")
    end
end

function SF__.DivineStorm.UpdateAbilityMeta(u372)
    local p373 = GetOwningPlayer(u372)
    SF__.Utils.ExSetAbilityResearchTooltip(p373, SF__.DivineStorm.ID, "学习神圣风暴 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p373, SF__.DivineStorm.ID, "对周围敌人造成200点光辉伤害。消耗|cffff8c003|r点圣能。", 0)
    do
        local i374 = 0
        while (i374 < 1) do
            repeat
                SF__.Utils.ExBlzSetAbilityTooltip(p373, SF__.DivineStorm.ID, SF__.StrConcat__("神圣风暴 - [|cffffcc00", (i374 + 1), "级|r]"), i374)
                SF__.Utils.ExBlzSetAbilityExtendedTooltip(p373, SF__.DivineStorm.ID, "神圣风暴对周围敌人造成200点光辉伤害。消耗|cffff8c003|r点圣能。", i374)
            until true
            i374 = (i374 + 1)
        end
    end
end

function SF__.DivineStorm.Start(data375)
    local pos__x376, pos__y377, pos__z378 = SF__.Vector3.FromUnit(data375.caster)
    local BuffBase = require("Objects.BuffBase")
    local UnitAttribute381 = require("Objects.UnitAttribute")
    local EventCenter382 = require("Lib.EventCenter")
    local hasWoa = (BuffBase.FindBuffByClassName(data375.caster, "WakeOfAshesBuff") ~= nil)
    local range = (function() if hasWoa then return 350 else return 250 end end)()
    ExGroupEnumUnitsInRange(pos__x376, pos__y377, range, function(u383)
        if (not IsUnitEnemy(u383, GetOwningPlayer(data375.caster))) then
            return
        end
        if ExIsUnitDead(u383) then
            return
        end
        local attr384 = UnitAttribute381.GetAttr(u383)
        EventCenter382.Damage:Emit({whichUnit = data375.caster, target = u383, amount = ((function() if hasWoa then return 350 else return 200 end end)() * (1 - attr384.radiantResistance)), attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
    end)
    SF__.RetributionPaladinGlobal.ConsumeHolyEnergy(data375.caster, 3)
    -- visuals
    local leviation = SF__.GameObject.New__s("ds_leviation")
    leviation.transform.localPosition__x, leviation.transform.localPosition__y, leviation.transform.localPosition__z = 0, 0, 50
    leviation:AddComponent(SF__.TimerComponent):StartTimer(0.6, function()
        leviation:Destroy()
    end)
    do
        local i385 = (-5)
        while (i385 <= 5) do
            repeat
                if (i385 == 0) then
                    break
                end
                local attach = SF__.GameObject.New__sx13("ds_visual", leviation)
                attach.transform.localPosition__x, attach.transform.localPosition__y, attach.transform.localPosition__z = pos__x376, pos__y377, pos__z378
                attach.transform.localRotation__x, attach.transform.localRotation__y, attach.transform.localRotation__z, attach.transform.localRotation__w = SF__.Quaternion.Euler(0, ((((360 / 5) * math.abs(i385)) - 10) + (20 * math.random())), 0)
                local att = attach:AddComponent(SF__.AutoTRSComponent)
                att.followUnit = data375.caster
                att.rotation__x, att.rotation__y, att.rotation__z, att.rotation__w = SF__.Quaternion.Euler(0, (((math.sign(i385) * ((math.random() * 200) + 700)) * SF__.Scene.DT) / 1000), 0)
                local arm = SF__.GameObject.New__sx13("ds_arm", attach)
                arm.transform.localPosition__x, arm.transform.localPosition__y, arm.transform.localPosition__z = range, 0, 0
                local effHoly = AddSpecialEffect("Abilities/Weapons/FaerieDragonMissile/FaerieDragonMissile.mdl", pos__x376, pos__y377)
                local effC = arm:AddComponent(SF__.AttachEffectComponent)
                effC:AttachEffect(effHoly)
                effC:LerpIn(700)
            until true
            i385 = (i385 + 1)
        end
    end
    if hasWoa then
        local eff386 = ExAddSpecialEffect("Abilities/Spells/Human/Thunderclap/ThunderClapCaster.mdl", pos__x376, pos__y377, 1)
        BlzSetSpecialEffectColor(eff386, 255, 255, 0)
        SF__.DivineToll.ExtendBlessedHammer(data375.caster)
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
-- Easing
SF__.Easing = SF__.Easing or {}
SF__.Easing.Name = "Easing"
SF__.Easing.FullName = "Easing"
function SF__.Easing.Linear(t)
    return t
end

function SF__.Easing.OutQubic(t80)
    return (1 - ((1 - t80) ^ 3))
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
-- WakeOfAshes.WakeOfAshesBuff
local BuffBase637 = require("Objects.BuffBase")
SF__.WakeOfAshes.WakeOfAshesBuff = SF__.WakeOfAshes.WakeOfAshesBuff or class("WakeOfAshesBuff", BuffBase637)
SF__.WakeOfAshes.WakeOfAshesBuff.Name = "WakeOfAshesBuff"
SF__.WakeOfAshes.WakeOfAshesBuff.FullName = "WakeOfAshes.WakeOfAshesBuff"
SF__.WakeOfAshes.WakeOfAshesBuff.__sf_base = BuffBase637
function SF__.WakeOfAshes.WakeOfAshesBuff.__Init(self, caster638, target639, duration640, interval641, awakeData642)
    self.__sf_type = SF__.WakeOfAshes.WakeOfAshesBuff
    self._eff = nil
    self._kf = 0
    self._effLooping = false
end

function SF__.WakeOfAshes.WakeOfAshesBuff.New(caster638, target639, duration640, interval641, awakeData642)
    local self = SF__.WakeOfAshes.WakeOfAshesBuff.new(caster638, target639, duration640, interval641, awakeData642)
    SF__.WakeOfAshes.WakeOfAshesBuff.__Init(self, caster638, target639, duration640, interval641, awakeData642)
    return self
end

function SF__.WakeOfAshes.WakeOfAshesBuff:OnEnable()
    return SF__.CorRun__(function()
        SF__.CorWait__(1)
        self._eff = AddSpecialEffectTarget("Abilities/Spells/Human/Resurrect/ResurrectCaster.mdl", self.caster, "origin")
        self._kf = 0
        self._effLooping = true
    end)
end

function SF__.WakeOfAshes.WakeOfAshesBuff:Update()
    self._kf = (self._kf + self.interval)
    if ((self._kf > 1) and self._effLooping) then
        BlzSetSpecialEffectTime(self._eff, 1)
    end
end

function SF__.WakeOfAshes.WakeOfAshesBuff:OnDisable()
    return SF__.CorRun__(function()
        local BuffBase644 = require("Objects.BuffBase")
        local quickness643 = BuffBase644.FindBuffByClassName(self.target, "QuicknessBuff")
        if (quickness643 ~= nil) then
            quickness643:DecreaseStack(quickness643.stack)
        end
        if (self._eff ~= nil) then
            self._effLooping = false
            SF__.CorWait__(3000)
            DestroyEffect(self._eff)
            self._eff = nil
        end
    end)
end
-- WordOfGlory
SF__.WordOfGlory = SF__.WordOfGlory or {}
SF__.WordOfGlory.Name = "WordOfGlory"
SF__.WordOfGlory.FullName = "WordOfGlory"
function SF__.WordOfGlory.Init()
    local EventCenter652 = require("Lib.EventCenter")
    EventCenter652.RegisterPlayerUnitSpellChannel:Emit({id = SF__.WordOfGlory.ID, handler = SF__.WordOfGlory.Check})
    EventCenter652.RegisterPlayerUnitSpellEffect:Emit({id = SF__.WordOfGlory.ID, handler = SF__.WordOfGlory.Start})
    ExTriggerRegisterNewUnit(function(u654)
        if (GetUnitTypeId(u654) == FourCC("Hpal")) then
            SF__.WordOfGlory.UpdateAbilityMeta(u654)
        end
    end)
end

function SF__.WordOfGlory.Check(data655)
    local UnitAttribute657 = require("Objects.UnitAttribute")
    local attr656 = UnitAttribute657.GetAttr(data655.caster)
    if (attr656.retPalHolyEnergy < 3) then
        IssueImmediateOrderById(data655.caster, SF__.ConstOrderId.Stop)
        ExTextState(data655.caster, "圣能不足")
    end
end

function SF__.WordOfGlory.UpdateAbilityMeta(u658)
    local p659 = GetOwningPlayer(u658)
    SF__.Utils.ExSetAbilityResearchTooltip(p659, SF__.WordOfGlory.ID, "学习荣耀圣令 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p659, SF__.WordOfGlory.ID, "治疗目标300生命。消耗|cffff8c003|r点圣能。", 0)
    do
        local i660 = 0
        while (i660 < 1) do
            repeat
                SF__.Utils.ExBlzSetAbilityTooltip(p659, SF__.WordOfGlory.ID, SF__.StrConcat__("荣耀圣令 - [|cffffcc00", (i660 + 1), "级|r]"), i660)
                SF__.Utils.ExBlzSetAbilityExtendedTooltip(p659, SF__.WordOfGlory.ID, "荣耀圣令治疗目标300生命。消耗|cffff8c003|r点圣能。", i660)
            until true
            i660 = (i660 + 1)
        end
    end
end

function SF__.WordOfGlory.Start(data661)
    local BuffBase663 = require("Objects.BuffBase")
    local EventCenter664 = require("Lib.EventCenter")
    local hasWoa662 = (BuffBase663.FindBuffByClassName(data661.caster, "WakeOfAshesBuff") ~= nil)
    EventCenter664.Heal:Emit({caster = data661.caster, target = data661.target, amount = (300 * (function() if hasWoa662 then return 2 else return 1 end end)())})
    SF__.RetributionPaladinGlobal.ConsumeHolyEnergy(data661.caster, 3)
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
    SF__.WakeOfAshes.Init()
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
local SystemBase55 = require("System.SystemBase")
SF__.Systems.InspectorSystem = SF__.Systems.InspectorSystem or class("InspectorSystem", SystemBase55)
SF__.Systems.InspectorSystem.Name = "InspectorSystem"
SF__.Systems.InspectorSystem.FullName = "Systems.InspectorSystem"
SF__.Systems.InspectorSystem.__sf_base = SystemBase55
function SF__.Systems.InspectorSystem:Awake()
    self:CreateFrames()
    self:RefreshHierarchy()
    self:SelectFirstVisibleObject()
    self:SetPanelVisible(false)
end

function SF__.Systems.InspectorSystem:Update(dt56)
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
        local i57 = 0
        while (i57 < SF__.Systems.InspectorSystem.MaxHierarchyRows) do
            repeat
                self._hierarchyRows:Add(self:CreateHierarchyRow(i57))
            until true
            i57 = (i57 + 1)
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

function SF__.Systems.InspectorSystem:CreateHierarchyRow(index58)
    local y59 = ((-0.061) - (index58 * (SF__.Systems.InspectorSystem.RowHeight + SF__.Systems.InspectorSystem.RowGap)))
    local button = BlzCreateFrameByType("BUTTON", "FdfInspectorHierarchyRow", self._panel, "ScoreScreenTabButtonTemplate", index58)
    BlzFrameSetPoint(button, FRAMEPOINT_TOPLEFT, self._panel, FRAMEPOINT_TOPLEFT, (SF__.Systems.InspectorSystem.Padding * 2), y59)
    BlzFrameSetSize(button, (SF__.Systems.InspectorSystem.LeftWidth - (SF__.Systems.InspectorSystem.Padding * 4)), SF__.Systems.InspectorSystem.RowHeight)
    local label60 = BlzCreateFrameByType("TEXT", "FdfInspectorHierarchyRowText", button, "", index58)
    BlzFrameSetPoint(label60, FRAMEPOINT_TOPLEFT, button, FRAMEPOINT_TOPLEFT, 0.004, (-0.002))
    BlzFrameSetSize(label60, (SF__.Systems.InspectorSystem.LeftWidth - (SF__.Systems.InspectorSystem.Padding * 5)), (SF__.Systems.InspectorSystem.RowHeight - 0.003))
    BlzFrameSetEnable(label60, false)
    BlzFrameSetTextAlignment(label60, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_LEFT)
    BlzFrameSetText(label60, "")
    local row = SF__.Systems.InspectorSystem.HierarchyRow.New(button, label60)
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

function SF__.Systems.InspectorSystem:SelectRow(row61)
    if (row61.gameObject == nil) then
        return
    end
    self._selectedGameObject = row61.gameObject
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
        for _, obj62 in (SF__.StdLib.List.IpairsNext)(collection12) do
            repeat
                if (obj62.transform.parent == nil) then
                    self:AddHierarchyObject(obj62, 0)
                end
            until true
        end
    end
    do
        local i63 = 0
        while (i63 < self._hierarchyRows.Count) do
            repeat
                local row64 = self._hierarchyRows:get_Item(i63)
                if (i63 < self._visibleObjects.Count) then
                    local obj65 = self._visibleObjects:get_Item(i63)
                    row64.gameObject = obj65
                    row64.depth = self:GetDepth(obj65)
                    self:SetRowLabel(row64, obj65.name, row64.depth)
                    BlzFrameSetVisible(row64.button, self._isVisible)
                else
                    row64.gameObject = nil
                    BlzFrameSetVisible(row64.button, false)
                end
            until true
            i63 = (i63 + 1)
        end
    end
    BlzFrameSetVisible(self._emptyText, (self._isVisible and (self._visibleObjects.Count == 0)))
    self._lastObjectCount = SF__.Scene.get_Instance().gameObjs.Count
    self:RefreshHierarchySelection()
end

function SF__.Systems.InspectorSystem:AddHierarchyObject(obj66, depth)
    if (self._visibleObjects.Count >= SF__.Systems.InspectorSystem.MaxHierarchyRows) then
        return
    end
    self._visibleObjects:Add(obj66)
    do
        local collection13 = obj66.transform.children
        for _, child67 in (SF__.StdLib.List.IpairsNext)(collection13) do
            repeat
                self:AddHierarchyObject(child67.gameObject, (depth + 1))
            until true
        end
    end
end

function SF__.Systems.InspectorSystem:GetDepth(obj68)
    local depth69 = 0
    local parent70 = obj68.transform.parent
    while (parent70 ~= nil) do
        repeat
            depth69 = (depth69 + 1)
            parent70 = parent70.parent
        until true
    end
    return depth69
end

function SF__.Systems.InspectorSystem:SetRowLabel(row71, text72, depth73)
    BlzFrameClearAllPoints(row71.label)
    BlzFrameSetPoint(row71.label, FRAMEPOINT_TOPLEFT, row71.button, FRAMEPOINT_TOPLEFT, (0.004 + (depth73 * SF__.Systems.InspectorSystem.IndentWidth)), (-0.002))
    BlzFrameSetSize(row71.label, ((SF__.Systems.InspectorSystem.LeftWidth - (SF__.Systems.InspectorSystem.Padding * 5)) - (depth73 * SF__.Systems.InspectorSystem.IndentWidth)), (SF__.Systems.InspectorSystem.RowHeight - 0.003))
    BlzFrameSetText(row71.label, text72)
end

function SF__.Systems.InspectorSystem:RefreshHierarchySelection()
    do
        local collection14 = self._hierarchyRows
        for _, row74 in (SF__.StdLib.List.IpairsNext)(collection14) do
            repeat
                local isSelected = ((row74.gameObject ~= nil) and (row74.gameObject == self._selectedGameObject))
                BlzFrameSetTextColor(row74.label, (function() if isSelected then return BlzConvertColor(255, 255, 220, 80) else return BlzConvertColor(255, 230, 230, 230) end end)())
            until true
        end
    end
end

function SF__.Systems.InspectorSystem:RefreshInspectorText()
    if (self._selectedGameObject == nil) then
        BlzFrameSetText(self._inspectorText, "")
        return
    end
    local text75 = SF__.StrConcat__(self._selectedGameObject.name, "\n")
    do
        local collection15 = self._selectedGameObject:get_components()
        for _, component in (SF__.StdLib.List.IpairsNext)(collection15) do
            repeat
                text75 = SF__.StrConcat__(text75, "\n[", component.__sf_type.Name, "]")
                local inspectorText = component:GetInspectorText()
                if (inspectorText ~= "") then
                    text75 = SF__.StrConcat__(text75, "\n", inspectorText)
                end
            until true
        end
    end
    BlzFrameSetText(self._inspectorText, text75)
end

function SF__.Systems.InspectorSystem:SceneContains(gameObject)
    do
        local collection16 = SF__.Scene.get_Instance().gameObjs
        for _, obj76 in (SF__.StdLib.List.IpairsNext)(collection16) do
            repeat
                if (obj76 == gameObject) then
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
function SF__.Systems.InspectorSystem.HierarchyRow.__Init(self, button77, label78)
    self.__sf_type = SF__.Systems.InspectorSystem.HierarchyRow
    self.button = nil
    self.label = nil
    self.gameObject = nil
    self.depth = 0
    self.button = button77
    self.label = label78
end

function SF__.Systems.InspectorSystem.HierarchyRow.New(button77, label78)
    local self = setmetatable({}, { __index = SF__.Systems.InspectorSystem.HierarchyRow })
    SF__.Systems.InspectorSystem.HierarchyRow.__Init(self, button77, label78)
    return self
end
-- Systems.MeleeGameSystem
local SystemBase79 = require("System.SystemBase")
SF__.Systems.MeleeGameSystem = SF__.Systems.MeleeGameSystem or class("MeleeGameSystem", SystemBase79)
SF__.Systems.MeleeGameSystem.Name = "MeleeGameSystem"
SF__.Systems.MeleeGameSystem.FullName = "Systems.MeleeGameSystem"
SF__.Systems.MeleeGameSystem.__sf_base = SystemBase79
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
    local item123 = self._items:get_Item((self._items.Count - 1))
    self._items:RemoveAt((self._items.Count - 1))
    return item123
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

function SF__.StdLib.Dictionary:set_Item(key665, value)
    if (key665 == nil) then
        error(SF__.StrConcat__("SF__E2e5944b8", "Key cannot be null"))
    end
    local existing = self._table[key665]
    self._table[key665] = value
    if (existing == nil) then
        self.Count = (self.Count + 1)
        self._keys:Add(key665)
    end
    self._version = (self._version + 1)
end

function SF__.StdLib.Dictionary:PairsNext()
    local version = self._version
    local index666 = 0
    return function()
        if (version ~= self._version) then
            error(SF__.StrConcat__("SF__E2e5944b8", "Collection was modified"))
        end
        index666 = (index666 + 1)
        if (index666 > self._keys.Count) then
            return nil
        end
        local key667 = self._keys:get_Item((index666 - 1))
        local value668 = self._table[key667]
        return key667, value668
    end
end

function SF__.StdLib.Dictionary:ContainsKey(key669)
    if (key669 == nil) then
        error(SF__.StrConcat__("SF__E2e5944b8", "Key cannot be null"))
    end
    return (self._table[key669] ~= nil)
end

function SF__.StdLib.Dictionary:TryGetValue(key670)
    if (key670 == nil) then
        error(SF__.StrConcat__("SF__E2e5944b8", "Key cannot be null"))
    end
    local result672 = self._table[key670]
    if (result672 ~= nil) then
        value671 = result672
        return true, value671
    end
    value671 = nil
    return false, value671
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
function SF__.TemplarVerdict.GetAbilityData(level569)
    return 2.25, 0.3, 0.15
end

function SF__.TemplarVerdict.Init()
    local EventCenter570 = require("Lib.EventCenter")
    EventCenter570.RegisterPlayerUnitSpellChannel:Emit({id = SF__.TemplarVerdict.ID, handler = SF__.TemplarVerdict.Check})
    EventCenter570.RegisterPlayerUnitSpellEffect:Emit({id = SF__.TemplarVerdict.ID, handler = SF__.TemplarVerdict.Start})
    ExTriggerRegisterNewUnit(function(u572)
        if (GetUnitTypeId(u572) == FourCC("Hpal")) then
            SF__.TemplarVerdict.UpdateAbilityMeta(u572)
        end
    end)
end

function SF__.TemplarVerdict.Check(data573)
    local UnitAttribute575 = require("Objects.UnitAttribute")
    local attr574 = UnitAttribute575.GetAttr(data573.caster)
    if (attr574.retPalHolyEnergy < 3) then
        IssueImmediateOrderById(data573.caster, SF__.ConstOrderId.Stop)
        ExTextState(data573.caster, "圣能不足")
    end
end

function SF__.TemplarVerdict.UpdateAbilityMeta(u576)
    local p577 = GetOwningPlayer(u576)
    local datas578 = SF__.StdLib.List.New__0()
    do
        local i579 = 0
        while (i579 < 1) do
            repeat
                local __pack_DamageScaling580, __pack_JudgementDamageScaling, __pack_ChanceToResetJudgement = SF__.TemplarVerdict.GetAbilityData((i579 + 1))
                datas578:Add({DamageScaling = __pack_DamageScaling580, JudgementDamageScaling = __pack_JudgementDamageScaling, ChanceToResetJudgement = __pack_ChanceToResetJudgement})
            until true
            i579 = (i579 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p577, SF__.TemplarVerdict.ID, "学习圣殿骑士的裁决 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p577, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决造成一次攻击伤害，如果目标被审判，造成30%的额外伤害，15%几率重置审判。消耗|cffff8c003|r点圣能。\n\n|cff99ccff冷却时间|r - 5秒\n\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas578:get_Item(0).JudgementDamageScaling * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas578:get_Item(0).ChanceToResetJudgement * 100)), "%的战争艺术触发几率。"), 0)
    do
        local i581 = 0
        while (i581 < 1) do
            repeat
                local __unpack_tmp583 = datas578:get_Item(i581)
                local data__DamageScaling582, data__JudgementDamageScaling, data__ChanceToResetJudgement = __unpack_tmp583.DamageScaling, __unpack_tmp583.JudgementDamageScaling, __unpack_tmp583.ChanceToResetJudgement
                SF__.Utils.ExBlzSetAbilityTooltip(p577, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决 - [|cffffcc00", (i581 + 1), "级|r]"), i581)
                SF__.Utils.ExBlzSetAbilityExtendedTooltip(p577, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决造成一次攻击伤害，造成|cffff8c00", string.format("%.0f", (data__DamageScaling582 * 100)), "%|r的攻击伤害。消耗|cffff8c003|r点圣能。\n\n|cff99ccff冷却时间|r - 5秒"), i581)
            until true
            i581 = (i581 + 1)
        end
    end
end

function SF__.TemplarVerdict.Start(data584)
    local level585 = GetUnitAbilityLevel(data584.caster, SF__.TemplarVerdict.ID)
    local UnitAttribute588 = require("Objects.UnitAttribute")
    local EventCenter590 = require("Lib.EventCenter")
    local ad__DamageScaling586, ad__JudgementDamageScaling, ad__ChanceToResetJudgement = SF__.TemplarVerdict.GetAbilityData(level585)
    local attr587 = UnitAttribute588.GetAttr(data584.caster)
    local damage589 = (attr587:SimAttack(UnitAttribute588.HeroAttributeType.Strength) * ad__DamageScaling586)
    EventCenter590.Damage:Emit({whichUnit = data584.caster, target = data584.target, amount = damage589, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_SLICE, outResult = {}})
    SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(data584.caster, 1)
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

function SF__.Vector2.Dot(a__x139, a__y140, b__x141, b__y142)
    return ((a__x139 * b__x141) + (a__y140 * b__y142))
end

function SF__.Vector2.Cross(a__x143, a__y144, b__x145, b__y146)
    return ((a__y144 * b__x145) - (a__x143 * b__y146))
end

function SF__.Vector2.op_UnaryNegation(a__x147, a__y148)
    return (-a__x147), (-a__y148)
end

function SF__.Vector2.op_Addition(a__x149, a__y150, b__x151, b__y152)
    return (a__x149 + b__x151), (a__y150 + b__y152)
end

function SF__.Vector2.op_Subtraction(a__x153, a__y154, b__x155, b__y156)
    return (a__x153 - b__x155), (a__y154 - b__y156)
end

function SF__.Vector2.op_Multiply__ahdf(v__x157, v__y158, f)
    return (v__x157 * f), (v__y158 * f)
end

function SF__.Vector2.op_Multiply__fahd(f159, v__x160, v__y161)
    return (v__x160 * f159), (v__y161 * f159)
end

function SF__.Vector2.op_Division(v__x162, v__y163, f164)
    return (v__x162 / f164), (v__y163 / f164)
end

function SF__.Vector2.UnitDistance(a, b)
    local v1__x, v1__y = SF__.Vector2.FromUnit(a)
    local v2__x, v2__y = SF__.Vector2.FromUnit(b)
    return SF__.Vector2.get_Magnitude(SF__.Vector2.op_Subtraction(v1__x, v1__y, v2__x, v2__y))
end

function SF__.Vector2.SqrUnitDistance(a165, b166)
    local v1__x167, v1__y168 = SF__.Vector2.FromUnit(a165)
    local v2__x169, v2__y170 = SF__.Vector2.FromUnit(b166)
    return SF__.Vector2.get_SqrMagnitude(SF__.Vector2.op_Subtraction(v1__x167, v1__y168, v2__x169, v2__y170))
end

function SF__.Vector2.FromUnit(u171)
    return GetUnitX(u171), GetUnitY(u171)
end

function SF__.Vector2.get_Magnitude(self__x172, self__y173)
    return math.sqrt(SF__.Vector2.get_SqrMagnitude(self__x172, self__y173))
end

function SF__.Vector2.get_SqrMagnitude(self__x174, self__y175)
    return ((self__x174 * self__x174) + (self__y175 * self__y175))
end

function SF__.Vector2.get_Normalized(self__x176, self__y177)
    local mag = SF__.Vector2.get_Magnitude(self__x176, self__y177)
    if (mag < 0.0001) then
        return SF__.Vector2.get_Zero()
    end
    return SF__.Vector2.op_Division(self__x176, self__y177, mag)
end

function SF__.Vector2.ClampMagnitude(self__x180, self__y181, mag182)
    return (function()
        local v__x183, v__y184 = SF__.Vector2.get_Normalized(self__x180, self__y181)
        return SF__.Vector2.op_Multiply__ahdf(v__x183, v__y184, mag182)
    end)()
end

function SF__.Vector2.ToString(self__x185, self__y186)
    return SF__.StrConcat__("(", self__x185, ", ", self__y186, ")")
end

function SF__.Vector2.Rotate(self__x187, self__y188, angle189)
    local cos = math.cos(angle189)
    local sin = math.sin(angle189)
    return ((self__x187 * cos) - (self__y188 * sin)), ((self__x187 * sin) + (self__y188 * cos))
end

function SF__.Vector2.UnitMoveTo(self__x190, self__y191, u192)
    SetUnitX(u192, self__x190)
    SetUnitY(u192, self__y191)
end

function SF__.Vector2.GetTerrainZ(self__x193, self__y194)
    MoveLocation(SF__.Vector2._loc, self__x193, self__y194)
    return GetLocationZ(SF__.Vector2._loc)
end

SF__.Vector2._loc = Location(0, 0)

SF__.Program.Main()
