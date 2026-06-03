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
SF__.TargetType.Unit = 0
SF__.TargetType.Point = 1
SF__.TargetType.Pierce = 2

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

function SF__.Vector3.op_Addition(a__x169, a__y170, a__z171, b__x172, b__y173, b__z174)
    return (a__x169 + b__x172), (a__y170 + b__y173), (a__z171 + b__z174)
end

function SF__.Vector3.op_UnaryNegation(a__x175, a__y176, a__z177)
    return (-a__x175), (-a__y176), (-a__z177)
end

function SF__.Vector3.op_Subtraction(a__x178, a__y179, a__z180, b__x181, b__y182, b__z183)
    return (a__x178 - b__x181), (a__y179 - b__y182), (a__z180 - b__z183)
end

function SF__.Vector3.op_Multiply__osef(v__x184, v__y185, v__z186, f187)
    return (v__x184 * f187), (v__y185 * f187), (v__z186 * f187)
end

function SF__.Vector3.op_Multiply__fose(f188, v__x189, v__y190, v__z191)
    return (v__x189 * f188), (v__y190 * f188), (v__z191 * f188)
end

function SF__.Vector3.op_Division(v__x192, v__y193, v__z194, f195)
    return (v__x192 / f195), (v__y193 / f195), (v__z194 / f195)
end

-- <summary>
-- Warcraft III world space here is right-handed: +x points right, +y points away, +z points up.
-- That means Cross((1,0,0), (0,1,0)) == (0,0,1).
-- </summary>
--
function SF__.Vector3.Cross(a__x196, a__y197, a__z198, b__x199, b__y200, b__z201)
    return ((a__y197 * b__z201) - (a__z198 * b__y200)), ((a__z198 * b__x199) - (a__x196 * b__z201)), ((a__x196 * b__y200) - (a__y197 * b__x199))
end

function SF__.Vector3.Distance(a__x202, a__y203, a__z204, b__x205, b__y206, b__z207)
    return SF__.Vector3.get_magnitude(SF__.Vector3.op_Subtraction(a__x202, a__y203, a__z204, b__x205, b__y206, b__z207))
end

function SF__.Vector3.Dot(a__x208, a__y209, a__z210, b__x211, b__y212, b__z213)
    return (((a__x208 * b__x211) + (a__y209 * b__y212)) + (a__z210 * b__z213))
end

function SF__.Vector3.Lerp(a__x214, a__y215, a__z216, b__x217, b__y218, b__z219, t220)
    t220 = math.clamp01(t220)
    return SF__.Vector3.op_Addition(a__x214, a__y215, a__z216, (function()
        local v__x221, v__y222, v__z223 = SF__.Vector3.op_Subtraction(b__x217, b__y218, b__z219, a__x214, a__y215, a__z216)
        return SF__.Vector3.op_Multiply__osef(v__x221, v__y222, v__z223, t220)
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

function SF__.Vector3.Project(v__x224, v__y225, v__z226, onNormal__x, onNormal__y, onNormal__z)
    local sqrMag = SF__.Vector3.Dot(onNormal__x, onNormal__y, onNormal__z, onNormal__x, onNormal__y, onNormal__z)
    if (sqrMag < 0.0001) then
        return SF__.Vector3.get_zero()
    end
    local dot = SF__.Vector3.Dot(v__x224, v__y225, v__z226, onNormal__x, onNormal__y, onNormal__z)
    return SF__.Vector3.op_Multiply__osef(onNormal__x, onNormal__y, onNormal__z, (dot / sqrMag))
end

function SF__.Vector3.ProjectOnPlane(v__x227, v__y228, v__z229, planeNormal__x, planeNormal__y, planeNormal__z)
    return SF__.Vector3.op_Subtraction(v__x227, v__y228, v__z229, SF__.Vector3.Project(v__x227, v__y228, v__z229, planeNormal__x, planeNormal__y, planeNormal__z))
end

function SF__.Vector3.Reflect(inDirection__x, inDirection__y, inDirection__z, inNormal__x, inNormal__y, inNormal__z)
    return SF__.Vector3.op_Subtraction(inDirection__x, inDirection__y, inDirection__z, SF__.Vector3.op_Multiply__fose((2 * SF__.Vector3.Dot(inDirection__x, inDirection__y, inDirection__z, inNormal__x, inNormal__y, inNormal__z)), inNormal__x, inNormal__y, inNormal__z))
end

function SF__.Vector3.RotateTowards(current__x230, current__y231, current__z232, target__x233, target__y234, target__z235, maxRadiansDelta, maxMagnitudeDelta)
    local currentMag = SF__.Vector3.get_magnitude(current__x230, current__y231, current__z232)
    local targetMag = SF__.Vector3.get_magnitude(target__x233, target__y234, target__z235)
    if ((currentMag == 0) or (targetMag == 0)) then
        return SF__.Vector3.MoveTowards(current__x230, current__y231, current__z232, target__x233, target__y234, target__z235, maxMagnitudeDelta)
    end
    local currentNorm__x, currentNorm__y, currentNorm__z = SF__.Vector3.op_Division(current__x230, current__y231, current__z232, currentMag)
    local targetNorm__x, targetNorm__y, targetNorm__z = SF__.Vector3.op_Division(target__x233, target__y234, target__z235, targetMag)
    local dot236 = math.clamp(SF__.Vector3.Dot(currentNorm__x, currentNorm__y, currentNorm__z, targetNorm__x, targetNorm__y, targetNorm__z), (-1), 1)
    local angle237 = math.acos(dot236)
    if (angle237 == 0) then
        return SF__.Vector3.MoveTowards(current__x230, current__y231, current__z232, target__x233, target__y234, target__z235, maxMagnitudeDelta)
    end
    local t238 = math.min(1, (maxRadiansDelta / angle237))
    local newDir__x, newDir__y, newDir__z = SF__.Vector3.Slerp(currentNorm__x, currentNorm__y, currentNorm__z, targetNorm__x, targetNorm__y, targetNorm__z, t238)
    local newMag = math.moveTowards(currentMag, targetMag, maxMagnitudeDelta)
    return SF__.Vector3.op_Multiply__osef(newDir__x, newDir__y, newDir__z, newMag)
end

function SF__.Vector3.Scale(a__x239, a__y240, a__z241, b__x242, b__y243, b__z244)
    return (a__x239 * b__x242), (a__y240 * b__y243), (a__z241 * b__z244)
end

function SF__.Vector3.Slerp(a__x245, a__y246, a__z247, b__x248, b__y249, b__z250, t251)
    local magA = SF__.Vector3.get_magnitude(a__x245, a__y246, a__z247)
    local magB = SF__.Vector3.get_magnitude(b__x248, b__y249, b__z250)
    if ((magA == 0) or (magB == 0)) then
        return SF__.Vector3.MoveTowards(a__x245, a__y246, a__z247, b__x248, b__y249, b__z250, math.huge)
    end
    local normA__x, normA__y, normA__z = SF__.Vector3.op_Division(a__x245, a__y246, a__z247, magA)
    local normB__x, normB__y, normB__z = SF__.Vector3.op_Division(b__x248, b__y249, b__z250, magB)
    local dot252 = math.clamp(SF__.Vector3.Dot(normA__x, normA__y, normA__z, normB__x, normB__y, normB__z), (-1), 1)
    local angle253 = math.acos(dot252)
    local sinAngle = math.sin(angle253)
    if (sinAngle < 0.0001) then
        return SF__.Vector3.MoveTowards(a__x245, a__y246, a__z247, b__x248, b__y249, b__z250, math.huge)
    end
    local tAngle = (angle253 * t251)
    local sinTA = math.sin(tAngle)
    local sinTOneMinusA = math.sin((angle253 - tAngle))
    local newDir__x260, newDir__y261, newDir__z262 = (function()
        local v__x257, v__y258, v__z259 = (function()
            local a__x254, a__y255, a__z256 = SF__.Vector3.op_Multiply__osef(normA__x, normA__y, normA__z, sinTOneMinusA)
            return SF__.Vector3.op_Addition(a__x254, a__y255, a__z256, SF__.Vector3.op_Multiply__osef(normB__x, normB__y, normB__z, sinTA))
        end)()
        return SF__.Vector3.op_Division(v__x257, v__y258, v__z259, sinAngle)
    end)()
    local newMag263 = math.lerp(magA, magB, t251)
    return SF__.Vector3.op_Multiply__osef(newDir__x260, newDir__y261, newDir__z262, newMag263)
end

function SF__.Vector3._getTerrainZ(x264, y265)
    MoveLocation(SF__.Vector3._loc, x264, y265)
    return GetLocationZ(SF__.Vector3._loc)
end

function SF__.Vector3.FromUnit(u266)
    local x267 = GetUnitX(u266)
    local y268 = GetUnitY(u266)
    return x267, y268, (SF__.Vector3._getTerrainZ(x267, y268) + GetUnitFlyHeight(u266))
end

function SF__.Vector3.get_sqrMagnitude(self__x269, self__y270, self__z271)
    return (((self__x269 * self__x269) + (self__y270 * self__y270)) + (self__z271 * self__z271))
end

function SF__.Vector3.get_magnitude(self__x272, self__y273, self__z274)
    return math.sqrt(SF__.Vector3.get_sqrMagnitude(self__x272, self__y273, self__z274))
end

function SF__.Vector3.get_normalized(self__x275, self__y276, self__z277)
    local mag278 = SF__.Vector3.get_magnitude(self__x275, self__y276, self__z277)
    if (mag278 < 0.0001) then
        return SF__.Vector3.get_zero()
    end
    return SF__.Vector3.op_Division(self__x275, self__y276, self__z277, mag278)
end

function SF__.Vector3.ClampMagnitude(self__x282, self__y283, self__z284, mag285)
    return (function()
        local v__x286, v__y287, v__z288 = SF__.Vector3.get_normalized(self__x282, self__y283, self__z284)
        return SF__.Vector3.op_Multiply__osef(v__x286, v__y287, v__z288, mag285)
    end)()
end

function SF__.Vector3.ToString(self__x289, self__y290, self__z291)
    return SF__.StrConcat__("(", self__x289, ", ", self__y290, ", ", self__z291, ")")
end

function SF__.Vector3.UnitMoveTo(self__x292, self__y293, self__z294, u295, mode)
    if mode == nil then mode = SF__.UnitVec3Mode.Auto end
    local tz = SF__.Vector3._getTerrainZ(self__x292, self__y293)
    local LuaUtils = require("Lib.Utils")
    local defaultFlyHeight = GetUnitDefaultFlyHeight(u295)
    local minZ = (tz + defaultFlyHeight)
    SetUnitPosition(u295, self__x292, self__y293)
    repeat
        local switchValue = mode
        if (switchValue == SF__.UnitVec3Mode.ForceFlying) then
            LuaUtils.SetUnitFlyable(u295)
            SetUnitFlyHeight(u295, (math.max(minZ, self__z294) - minZ), 0)
            break
        elseif (switchValue == SF__.UnitVec3Mode.ForceGround) then
            SetUnitFlyHeight(u295, defaultFlyHeight, 0)
            break
        elseif (switchValue == SF__.UnitVec3Mode.Auto) then
            if IsUnitType(u295, UNIT_TYPE_FLYING) then
                SetUnitFlyHeight(u295, (math.max(minZ, self__z294) - minZ), 0)
            else
                SetUnitFlyHeight(u295, defaultFlyHeight, 0)
            end
            break
        end
    until true
end

function SF__.Vector3.GetTerrainZ(self__x296, self__y297, self__z298)
    return SF__.Vector3._getTerrainZ(self__x296, self__y297)
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

function SF__.Quaternion.op_Multiply__iyiose(q__x, q__y, q__z, q__w, v__x, v__y, v__z)
    -- https://en.wikipedia.org/wiki/Quaternions_and_spatial_rotation#Using_quaternion_as_rotations
    local u__x, u__y, u__z = q__x, q__y, q__z
    local s = q__w
    return (function()
        local a__x63, a__y64, a__z65 = (function()
            local a__x60, a__y61, a__z62 = SF__.Vector3.op_Multiply__fose((2 * SF__.Vector3.Dot(u__x, u__y, u__z, v__x, v__y, v__z)), u__x, u__y, u__z)
            return SF__.Vector3.op_Addition(a__x60, a__y61, a__z62, SF__.Vector3.op_Multiply__fose(((s * s) - SF__.Vector3.Dot(u__x, u__y, u__z, u__x, u__y, u__z)), v__x, v__y, v__z))
        end)()
        return SF__.Vector3.op_Addition(a__x63, a__y64, a__z65, SF__.Vector3.op_Multiply__fose((2 * s), SF__.Vector3.Cross(u__x, u__y, u__z, v__x, v__y, v__z)))
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
    local x66
    local y67
    local z
    local w
    local trace = ((m00 + m11) + m22)
    if (trace > 0) then
        local s68 = (math.sqrt((trace + 1)) * 2)
        w = (0.25 * s68)
        x66 = ((m21 - m12) / s68)
        y67 = ((m02 - m20) / s68)
        z = ((m10 - m01) / s68)
    elseif ((m00 > m11) and (m00 > m22)) then
        local s69 = (math.sqrt((((1 + m00) - m11) - m22)) * 2)
        w = ((m21 - m12) / s69)
        x66 = (0.25 * s69)
        y67 = ((m01 + m10) / s69)
        z = ((m02 + m20) / s69)
    else
        if (m11 > m22) then
            local s70 = (math.sqrt((((1 + m11) - m00) - m22)) * 2)
            w = ((m02 - m20) / s70)
            x66 = ((m01 + m10) / s70)
            y67 = (0.25 * s70)
            z = ((m12 + m21) / s70)
        else
            local s71 = (math.sqrt((((1 + m22) - m00) - m11)) * 2)
            w = ((m10 - m01) / s71)
            x66 = ((m02 + m20) / s71)
            y67 = ((m12 + m21) / s71)
            z = (0.25 * s71)
        end
    end
    return SF__.Quaternion.Normalize(x66, y67, z, w)
end

function SF__.Quaternion.LookRotation__ose(forward__x72, forward__y73, forward__z74)
    return SF__.Quaternion.LookRotation__oseose(forward__x72, forward__y73, forward__z74, SF__.Vector3.get_up())
end

function SF__.Quaternion.Normalize(q__x75, q__y76, q__z77, q__w78)
    local magnitude = math.sqrt(((((q__x75 * q__x75) + (q__y76 * q__y76)) + (q__z77 * q__z77)) + (q__w78 * q__w78)))
    if (magnitude < 0.0001) then
        return SF__.Quaternion.get_identity()
    end
    return (q__x75 / magnitude), (q__y76 / magnitude), (q__z77 / magnitude), (q__w78 / magnitude)
end

function SF__.Quaternion.get_eulerAngles(self__x, self__y, self__z, self__w)
    -- https://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles#Source_Code_2
    local sinr_cosp = (2 * ((self__w * self__x) + (self__y * self__z)))
    local cosr_cosp = (1 - (2 * ((self__x * self__x) + (self__y * self__y))))
    local roll79 = math.atan(sinr_cosp, cosr_cosp)
    local sinp = (2 * ((self__w * self__y) - (self__z * self__x)))
    local pitch80
    if (math.abs(sinp) >= 1) then
        pitch80 = ((math.sign(sinp) * math.pi) / 2)
        -- use 90 degrees if out of range
    else
        pitch80 = math.asin(sinp)
    end
    local siny_cosp = (2 * ((self__w * self__z) + (self__x * self__y)))
    local cosy_cosp = (1 - (2 * ((self__y * self__y) + (self__z * self__z))))
    local yaw81 = math.atan(siny_cosp, cosy_cosp)
    return (pitch80 * bj_RADTODEG), (yaw81 * bj_RADTODEG), (roll79 * bj_RADTODEG)
end

function SF__.Quaternion.get_normalized(self__x82, self__y83, self__z84, self__w85)
    return SF__.Quaternion.Normalize(self__x82, self__y83, self__z84, self__w85)
end

function SF__.Quaternion.ToString(self__x90, self__y91, self__z92, self__w93)
    return SF__.StrConcat__("(", self__x90, ", ", self__y91, ", ", self__z92, ", ", self__w93, ")")
end

function SF__.Quaternion.ApplyToEffect(self__x94, self__y95, self__z96, self__w97, e)
    local angles__x, angles__y, angles__z = SF__.Quaternion.get_eulerAngles(self__x94, self__y95, self__z96, self__w97)
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
        for _, item448 in (SF__.StdLib.List.IpairsNext)(collection1) do
            table.insert(self._items, item448)
            self.Count = (self.Count + 1)
        end
    end
end

function SF__.StdLib.List.New__xqm20z(collection)
    local self = setmetatable({}, { __index = SF__.StdLib.List })
    SF__.StdLib.List.__Init__xqm20z(self, collection)
    return self
end

function SF__.StdLib.List:get_Item(index449)
    if ((index449 < 0) or (index449 >= self.Count)) then
        error(SF__.StrConcat__("SF__E2e5944b8", "Index out of range"))
    end
    return self._items[(index449 + 1)]
end

function SF__.StdLib.List:set_Item(index450, value)
    if ((index450 < 0) or (index450 >= self.Count)) then
        error(SF__.StrConcat__("SF__E2e5944b8", "Index out of range"))
    end
    self._items[(index450 + 1)] = value
end

function SF__.StdLib.List:AddRange(collection451)
    do
        local collection2 = collection451
        for _, item452 in (SF__.StdLib.List.IpairsNext)(collection2) do
            table.insert(self._items, item452)
            self.Count = (self.Count + 1)
        end
    end
    self._version = (self._version + 1)
end

function SF__.StdLib.List:Add(item453)
    table.insert(self._items, item453)
    self.Count = (self.Count + 1)
    self._version = (self._version + 1)
end

function SF__.StdLib.List:Clear()
    self._items = {}
    self.Count = 0
    self._version = (self._version + 1)
end

function SF__.StdLib.List:Remove(item454)
    local index455 = self:IndexOf(item454)
    if (index455 < 0) then
        return false
    end
    self:RemoveAt(index455)
    return true
end

function SF__.StdLib.List:RemoveAt(index456)
    table.remove(self._items, (index456 + 1))
    self.Count = (self.Count - 1)
    self._version = (self._version + 1)
end

function SF__.StdLib.List:IndexOf(item457)
    do
        local i458 = 0
        while (i458 < self.Count) do
            local current459 = self._items[(i458 + 1)]
            if (current459 == item457) then
                return i458
            end
            ::continue::
            i458 = (i458 + 1)
        end
    end
    return (-1)
end

function SF__.StdLib.List.DefaultCompare(a460, b461)
    if (a460 == b461) then
        return 0
    end
    if (a460 < b461) then
        return (-1)
    end
    return 1
end

function SF__.StdLib.List:Sort(comparison)
    if (comparison == nil) then
        comparison = SF__.StdLib.List.DefaultCompare
    end
    local version = self._version
    table.sort(self._items, function(a464, b465)
        return (comparison(a464, b465) < 0)
    end)
    if (version ~= self._version) then
        error(SF__.StrConcat__("SF__E2e5944b8", "Collection was modified"))
    end
    self._version = (self._version + 1)
end

function SF__.StdLib.List:IpairsNext()
    local version466 = self._version
    local index467 = 0
    return function()
        if (version466 ~= self._version) then
            error(SF__.StrConcat__("SF__E2e5944b8", "Collection was modified"))
        end
        index467 = (index467 + 1)
        local value468 = self._items[index467]
        if (value468 == nil) then
            return nil
        end
        return index467, value468
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
    local parts13 = SF__.StrSplit__(name, "/")
    return SF__.Transform._Find(self, parts13, 0)
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
        for _, child14 in (SF__.StdLib.List.IpairsNext)(collection4) do
            SF__.GameObject.MarkDestroyQueuedDepthFirst(child14.gameObject)
        end
    end
end

function SF__.GameObject.DestroyDepthFirst(obj15)
    if obj15.isDestroyed then
        return
    end
    local children = obj15.transform.children
    do
        local i = (children.Count - 1)
        while (i >= 0) do
            SF__.GameObject.DestroyDepthFirst(children:get_Item(i).gameObject)
            ::continue::
            i = (i - 1)
        end
    end
    obj15.transform:SetParent(nil)
    do
        local collection5 = obj15._components
        for _, comp in (SF__.StdLib.List.IpairsNext)(collection5) do
            comp:OnDisable()
            comp:OnDestroy()
        end
    end
    obj15._components:Clear()
    SF__.Scene.get_Instance().gameObjs:Remove(obj15)
    obj15.isDestroyed = true
end

function SF__.GameObject:get_components()
    return self._components
end

function SF__.GameObject.__Init__s(self, name16)
    self.__sf_type = SF__.GameObject
    self.name = nil
    self.transform = nil
    self._components = SF__.StdLib.List.New__0()
    self.isDestroyQueued = false
    self.isDestroyed = false
    self.name = name16
    self.transform = self:AddComponent(SF__.Transform)
    SF__.Scene.get_Instance():AddGameObject(self)
end

function SF__.GameObject.New__s(name16)
    local self = setmetatable({}, { __index = SF__.GameObject })
    SF__.GameObject.__Init__s(self, name16)
    return self
end

function SF__.GameObject.__Init__sx13(self, name17, parent18)
    SF__.GameObject.__Init__s(self, name17)
    self.transform:SetParent(parent18.transform)
end

function SF__.GameObject.New__sx13(name17, parent18)
    local self = setmetatable({}, { __index = SF__.GameObject })
    SF__.GameObject.__Init__sx13(self, name17, parent18)
    return self
end

function SF__.GameObject:GetComponent(T)
    do
        local collection6 = self._components
        for _, comp19 in (SF__.StdLib.List.IpairsNext)(collection6) do
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
    if (self.isDestroyQueued or self.isDestroyed) then
        return
    end
    local snapshot = SF__.StdLib.List.New__xqm20z(self._components)
    do
        local collection7 = snapshot
        for _, comp25 in (SF__.StdLib.List.IpairsNext)(collection7) do
            comp25:Update()
        end
    end
end

function SF__.GameObject:LateUpdate()
    if (self.isDestroyQueued or self.isDestroyed) then
        return
    end
    local snapshot26 = SF__.StdLib.List.New__xqm20z(self._components)
    do
        local collection8 = snapshot26
        for _, comp27 in (SF__.StdLib.List.IpairsNext)(collection8) do
            comp27:LateUpdate()
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

function SF__.GameObject.DestroyQueued(obj28)
    SF__.GameObject.DestroyDepthFirst(obj28)
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

function SF__.Scene:AddGameObject(obj29)
    self.gameObjs:Add(obj29)
end

function SF__.Scene:QueueDestroy(obj30)
    self._destroyQueue:Add(obj30)
end

function SF__.Scene:FlushDestroyQueue()
    do
        local i31 = 0
        while (i31 < self._destroyQueue.Count) do
            SF__.GameObject.DestroyQueued(self._destroyQueue:get_Item(i31))
            ::continue::
            i31 = (i31 + 1)
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
                local i32 = 0
                while (i32 < count) do
                    self.gameObjs:get_Item(i32):Update()
                    ::continue::
                    i32 = (i32 + 1)
                end
            end
            do
                local i33 = 0
                while (i33 < count) do
                    self.gameObjs:get_Item(i33):LateUpdate()
                    ::continue::
                    i33 = (i33 + 1)
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

function SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p99, abilCode100, researchExtendedTooltip, level101)
    if (GetLocalPlayer() ~= p99) then
        return
    end
    BlzSetAbilityResearchExtendedTooltip(abilCode100, researchExtendedTooltip, level101)
end

function SF__.Utils.ExBlzSetAbilityTooltip(p102, abilCode103, tooltip, level104)
    if (GetLocalPlayer() ~= p102) then
        return
    end
    BlzSetAbilityTooltip(abilCode103, tooltip, level104)
end

function SF__.Utils.ExBlzSetAbilityExtendedTooltip(p105, abilCode106, extendedTooltip, level107)
    if (GetLocalPlayer() ~= p105) then
        return
    end
    BlzSetAbilityExtendedTooltip(abilCode106, extendedTooltip, level107)
end

function SF__.Utils.ExBlzSetAbilityIcon(p108, abilCode109, iconPath)
    if (GetLocalPlayer() ~= p108) then
        return
    end
    BlzSetAbilityIcon(abilCode109, iconPath)
end

function SF__.Utils.CsGroupGetUnitsInRange(x110, y111, radius, filter)
    local result = SF__.StdLib.List.New__0()
    ExGroupEnumUnitsInRange(x110, y111, radius, function(u112)
        if filter(u112) then
            result:Add(u112)
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
function SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(u372, amount)
    local UnitAttribute374 = require("Objects.UnitAttribute")
    local attr373 = UnitAttribute374.GetAttr(u372)
    attr373.retPalHolyEnergy = math.min((attr373.retPalHolyEnergy + amount), 5)
end

function SF__.RetributionPaladinGlobal:Init()
    ExTriggerRegisterNewUnit(function(u376)
        if (GetUnitTypeId(u376) == FourCC("Hpal")) then
            self._units:Add(u376)
        end
    end)
    _ = self:Start()
end

function SF__.RetributionPaladinGlobal:Start()
    return SF__.CorRun__(function()
        local UnitAttribute379 = require("Objects.UnitAttribute")
        while true do
            do
                local collection9 = self._units
                for _, u377 in (SF__.StdLib.List.IpairsNext)(collection9) do
                    local attr378 = UnitAttribute379.GetAttr(u377)
                    ExSetUnitMana(u377, ((ExGetUnitMaxMana(u377) * attr378.retPalHolyEnergy) * 0.2))
                    if (attr378.retPalHolyEnergy >= 3) then
                        SF__.Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u377), FourCC("A006"), "ReplaceableTextures/CommandButtons/BTNinv_helmet_96.tga")
                    else
                        SF__.Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u377), FourCC("A006"), "ReplaceableTextures/PassiveButtons/PASBTNinv_helmet_96.tga")
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
function SF__.BladeOfJustice.GetAbilityData(level299)
    return (75 * level299), 5, (10 * level299)
end

function SF__.BladeOfJustice.Init()
    local EventCenter = require("Lib.EventCenter")
    EventCenter.RegisterPlayerUnitSpellEffect:Emit({id = SF__.BladeOfJustice.ID, handler = SF__.BladeOfJustice.Start})
    ExTriggerRegisterNewUnit(function(u301)
        if (GetUnitTypeId(u301) == FourCC("Hpal")) then
            SF__.BladeOfJustice.UpdateAbilityMeta(u301)
        end
    end)
end

function SF__.BladeOfJustice.UpdateAbilityMeta(u302)
    local p303 = GetOwningPlayer(u302)
    local datas = SF__.StdLib.List.New__0()
    do
        local i304 = 0
        while (i304 < 3) do
            local __pack_Damage, __pack_Duration, __pack_DamagePerSecond = SF__.BladeOfJustice.GetAbilityData((i304 + 1))
            datas:Add({Damage = __pack_Damage, Duration = __pack_Duration, DamagePerSecond = __pack_DamagePerSecond})
            ::continue::
            i304 = (i304 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p303, SF__.BladeOfJustice.ID, "学习公正之剑 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p303, SF__.BladeOfJustice.ID, SF__.StrConcat__("用圣光的利刃刺穿目标，造成法术伤害，在一定时间内对附近敌人每秒造成光辉伤害。产生|cffff8c001|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 10秒\r\n\r\n|cffffcc001级|r - 造成|cffff8c00", datas:get_Item(0).Damage, "|r的直接法术伤害，|cffff8c00", datas:get_Item(0).Duration, "|r秒内对附近敌人每秒造成|cffff8c00", datas:get_Item(0).DamagePerSecond, "|r的光辉伤害。产生|cffff8c001|r点圣能。\r\n|cffffcc002级|r - 造成|cffff8c00", datas:get_Item(1).Damage, "|r的直接法术伤害，|cffff8c00", datas:get_Item(1).Duration, "|r秒内对附近敌人每秒造成|cffff8c00", datas:get_Item(1).DamagePerSecond, "|r的光辉伤害。产生|cffff8c001|r点圣能。\r\n|cffffcc003级|r - 造成|cffff8c00", datas:get_Item(2).Damage, "|r的直接法术伤害，|cffff8c00", datas:get_Item(2).Duration, "|r秒内对附近敌人每秒造成|cffff8c00", datas:get_Item(2).DamagePerSecond, "|r的光辉伤害。产生|cffff8c001|r点圣能。"), 0)
    do
        local i305 = 0
        while (i305 < 3) do
            local __unpack_tmp = datas:get_Item(i305)
            local data__Damage, data__Duration, data__DamagePerSecond = __unpack_tmp.Damage, __unpack_tmp.Duration, __unpack_tmp.DamagePerSecond
            SF__.Utils.ExBlzSetAbilityTooltip(p303, SF__.BladeOfJustice.ID, SF__.StrConcat__("公正之剑 - [|cffffcc00", (i305 + 1), "级|r]"), i305)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p303, SF__.BladeOfJustice.ID, SF__.StrConcat__("用圣光的利刃刺穿目标，造成|cffff8c00", data__Damage, "|r的直接法术伤害，在|cffff8c00", data__Duration, "|r秒内对附近敌人每秒造成|cffff8c00", data__DamagePerSecond, "|r的光辉伤害。产生|cffff8c001|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 10秒"), i305)
            ::continue::
            i305 = (i305 + 1)
        end
    end
end

function SF__.BladeOfJustice.Start(data)
    local level306 = GetUnitAbilityLevel(data.caster, SF__.BladeOfJustice.ID)
    local EventCenter307 = require("Lib.EventCenter")
    local ad__Damage, ad__Duration, ad__DamagePerSecond = SF__.BladeOfJustice.GetAbilityData(level306)
    EventCenter307.Damage:Emit({whichUnit = data.caster, target = data.target, amount = ad__Damage, attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
    SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(data.caster, 1)
    SF__.BladeOfJustice.New():StartGroudDamage(data.caster, data.target, ad__Damage, ad__Duration, ad__DamagePerSecond)
end

function SF__.BladeOfJustice:StartGroudDamage(caster, target, ad__Damage308, ad__Duration309, ad__DamagePerSecond310)
    return SF__.CorRun__(function()
        local pos__x, pos__y = SF__.Vector2.FromUnit(target)
        local UnitAttribute = require("Objects.UnitAttribute")
        local EventCenter315 = require("Lib.EventCenter")
        local eff311 = ExAddSpecialEffect("Abilities/Spells/Orc/LiquidFire/Liquidfire.mdl", pos__x, pos__y, ad__Duration309)
        local p312 = GetOwningPlayer(caster)
        do
            local i313 = 0
            while (i313 < ad__Duration309) do
                SF__.CorWait__(1000)
                ExGroupEnumUnitsInRange(pos__x, pos__y, 300, function(u316)
                    if (not IsUnitEnemy(u316, p312)) then
                        return
                    end
                    if ExIsUnitDead(u316) then
                        return
                    end
                    local tarAttr317 = UnitAttribute.GetAttr(u316)
                    local damage318 = (ad__DamagePerSecond310 * (1 - tarAttr317.radiantResistance))
                    EventCenter315.Damage:Emit({whichUnit = caster, target = u316, amount = damage318, attack = false, ranged = true, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
                end)
                ::continue::
                i313 = (i313 + 1)
            end
        end
        DestroyEffect(eff311)
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
function SF__.CrusaderStrike.GetAbilityData(level319)
    return (0.65 + (0.35 * level319)), (0.15 * (level319 - 1))
end

function SF__.CrusaderStrike.Init()
    local EventCenter320 = require("Lib.EventCenter")
    EventCenter320.RegisterPlayerUnitSpellEffect:Emit({id = SF__.CrusaderStrike.ID, handler = SF__.CrusaderStrike.Start})
    ExTriggerRegisterNewUnit(function(u322)
        if (GetUnitTypeId(u322) == FourCC("Hpal")) then
            SF__.CrusaderStrike.UpdateAbilityMeta(u322)
        end
    end)
end

function SF__.CrusaderStrike.UpdateAbilityMeta(u323)
    local p324 = GetOwningPlayer(u323)
    local datas325 = SF__.StdLib.List.New__0()
    do
        local i326 = 0
        while (i326 < 3) do
            local __pack_DamageScaling, __pack_ArtOfWarChance = SF__.CrusaderStrike.GetAbilityData((i326 + 1))
            datas325:Add({DamageScaling = __pack_DamageScaling, ArtOfWarChance = __pack_ArtOfWarChance})
            ::continue::
            i326 = (i326 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p324, SF__.CrusaderStrike.ID, "学习十字军打击 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p324, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击造成一次攻击伤害，伤害系数随技能等级提升。产生|cffff8c001|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 6秒\r\n\r\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas325:get_Item(0).DamageScaling * 100)), "%|r的攻击伤害。\r\n|cffffcc002级|r - |cffff8c00", string.format("%.0f", (datas325:get_Item(1).DamageScaling * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas325:get_Item(1).ArtOfWarChance * 100)), "%的战争艺术触发几率。\r\n|cffffcc003级|r - |cffff8c00", string.format("%.0f", (datas325:get_Item(2).DamageScaling * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas325:get_Item(2).ArtOfWarChance * 100)), "%的战争艺术触发几率。"), 0)
    do
        local i327 = 0
        while (i327 < 3) do
            local __unpack_tmp328 = datas325:get_Item(i327)
            local data__DamageScaling, data__ArtOfWarChance = __unpack_tmp328.DamageScaling, __unpack_tmp328.ArtOfWarChance
            SF__.Utils.ExBlzSetAbilityTooltip(p324, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击 - [|cffffcc00", (i327 + 1), "级|r]"), i327)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p324, SF__.CrusaderStrike.ID, SF__.StrConcat__("十字军打击造成一次攻击伤害，造成|cffff8c00", string.format("%.0f", (data__DamageScaling * 100)), "%|r的攻击伤害", (function() if (i327 > 0) then return SF__.StrConcat__("，", string.format("%.0f", (data__ArtOfWarChance * 100)), "%的战争艺术触发几率") else return "" end end)(), "。产生|cffff8c001|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 6秒"), i327)
            ::continue::
            i327 = (i327 + 1)
        end
    end
    -- datas.Remove(new IAbilityData { DamageScaling = 0.65f, ArtOfWarChance = 0 });
    datas325:RemoveAt(0)
end

function SF__.CrusaderStrike.Start(data329)
    local level330 = GetUnitAbilityLevel(data329.caster, SF__.CrusaderStrike.ID)
    local UnitAttribute331 = require("Objects.UnitAttribute")
    local EventCenter333 = require("Lib.EventCenter")
    local ad__DamageScaling, ad__ArtOfWarChance = SF__.CrusaderStrike.GetAbilityData(level330)
    local attr = UnitAttribute331.GetAttr(data329.caster)
    local damage332 = (attr:SimAttack(UnitAttribute331.HeroAttributeType.Strength) * ad__DamageScaling)
    EventCenter333.Damage:Emit({whichUnit = data329.caster, target = data329.target, amount = damage332, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
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
        self.gameObject.transform.localRotation__x, self.gameObject.transform.localRotation__y, self.gameObject.transform.localRotation__z, self.gameObject.transform.localRotation__w = SF__.Quaternion.LookRotation__ose(SF__.Vector3.op_Subtraction(targetPosition__x, targetPosition__y, targetPosition__z, currentPosition__x, currentPosition__y, currentPosition__z))
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
function SF__.DivineToll.GetAbilityData(level334)
    return (2 + level334), (50 * level334), 0.1, 10
end

function SF__.DivineToll.Init()
    local EventCenter337 = require("Lib.EventCenter")
    EventCenter337.RegisterPlayerUnitSpellEffect:Emit({id = SF__.DivineToll.ID, handler = function(data336)
        SF__.DivineToll.Start(data336)
    end})
    ExTriggerRegisterNewUnit(function(u339)
        if (GetUnitTypeId(u339) == FourCC("Hpal")) then
            SF__.DivineToll.UpdateAbilityMeta(u339)
        end
    end)
end

function SF__.DivineToll.UpdateAbilityMeta(u340)
    local p341 = GetOwningPlayer(u340)
    local datas342 = SF__.StdLib.List.New__0()
    do
        local i343 = 0
        while (i343 < 3) do
            local __pack_TargetCount, __pack_Damage344, __pack_RadiantDmgAmp, __pack_Duration345 = SF__.DivineToll.GetAbilityData((i343 + 1))
            datas342:Add({TargetCount = __pack_TargetCount, Damage = __pack_Damage344, RadiantDmgAmp = __pack_RadiantDmgAmp, Duration = __pack_Duration345})
            ::continue::
            i343 = (i343 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p341, SF__.DivineToll.ID, "学习圣洁鸣钟 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p341, SF__.DivineToll.ID, SF__.StrConcat__("对附近的多个目标施展审判，造成法术伤害，然后神圣之锤环绕圣殿骑士，每次命中敌人使其受到的光辉伤害提高。每个审判产生|cffff8c001|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 30秒\r\n\r\n|cffffcc001级|r - 审判最多|cffff8c00", datas342:get_Item(0).TargetCount, "|r个目标，造成|cffff8c00", datas342:get_Item(0).Damage, "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas342:get_Item(0).RadiantDmgAmp * 100)), "%|r的光辉易伤，持续|cffff8c00", datas342:get_Item(0).Duration, "|r秒。\r\n|cffffcc002级|r - 审判最多|cffff8c00", datas342:get_Item(1).TargetCount, "|r个目标，造成|cffff8c00", datas342:get_Item(1).Damage, "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas342:get_Item(1).RadiantDmgAmp * 100)), "%|r的光辉易伤，持续|cffff8c00", datas342:get_Item(1).Duration, "|r秒。\r\n|cffffcc003级|r - 审判最多|cffff8c00", datas342:get_Item(2).TargetCount, "|r个目标，造成|cffff8c00", datas342:get_Item(2).Damage, "|r点法术伤害，神圣之锤造成|cffff8c00", string.format("%.0f", (datas342:get_Item(2).RadiantDmgAmp * 100)), "%|r的光辉易伤，持续|cffff8c00", datas342:get_Item(2).Duration, "|r秒。"), 0)
    do
        local i346 = 0
        while (i346 < 3) do
            local __unpack_tmp349 = datas342:get_Item(i346)
            local data__TargetCount, data__Damage347, data__RadiantDmgAmp, data__Duration348 = __unpack_tmp349.TargetCount, __unpack_tmp349.Damage, __unpack_tmp349.RadiantDmgAmp, __unpack_tmp349.Duration
            SF__.Utils.ExBlzSetAbilityTooltip(p341, SF__.DivineToll.ID, SF__.StrConcat__("圣洁鸣钟 - [|cffffcc00", (i346 + 1), "级|r]"), i346)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p341, SF__.DivineToll.ID, SF__.StrConcat__("对附近的最多|cffff8c00", data__TargetCount, "|r个目标施展审判，造成|cffff8c00", data__Damage347, "|r点法术伤害，然后神圣之锤环绕圣殿骑士，每次命中敌人使其受到的光辉伤害提高|cffff8c00", string.format("%.0f", (data__RadiantDmgAmp * 100)), "%|r，持续|cffff8c00", data__Duration348, "|r秒。每个审判产生|cffff8c001|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 30秒"), i346)
            ::continue::
            i346 = (i346 + 1)
        end
    end
end

function SF__.DivineToll.HurlToTarget(caster350, target351, pos__x352, pos__y353, pos__z)
    local outer = SF__.GameObject.New__s("DivineToll_Outer")
    local EventCenter357 = require("Lib.EventCenter")
    outer.transform.localPosition__x, outer.transform.localPosition__y, outer.transform.localPosition__z = 0, 0, 80
    local moveLayer = SF__.GameObject.New__sx13("MoveLayer", outer)
    moveLayer.transform.localPosition__x, moveLayer.transform.localPosition__y, moveLayer.transform.localPosition__z = pos__x352, pos__y353, pos__z
    local mis = moveLayer:AddComponent(SF__.Missile)
    mis.targetType = SF__.TargetType.Unit
    mis.unitTarget = target351
    mis.speed = 900
    mis.lookAtTarget = true
    mis.colliderSize = 32
    mis.onArrived = function()
        local cPos__x, cPos__y, cPos__z = mis.gameObject.transform:get_position()
        local eff354 = ExAddSpecialEffect("Abilities/Spells/Human/StormBolt/StormBoltMissile.mdl", cPos__x, cPos__y, 0.1)
        BlzSetSpecialEffectColor(eff354, 255, 255, 0)
        local ad__TargetCount, ad__Damage355, ad__RadiantDmgAmp, ad__Duration356 = SF__.DivineToll.GetAbilityData(GetUnitAbilityLevel(caster350, SF__.DivineToll.ID))
        EventCenter357.Damage:Emit({whichUnit = caster350, target = target351, amount = ad__Damage355, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_WHOKNOWS, outResult = {}})
        SF__.RetributionPaladinGlobal.IncreaseHolyEnergy(caster350, 1)
        moveLayer:RemoveAllComponents(SF__.Missile)
        local aec1 = moveLayer.transform:Find("DivineToll_Bolt/dt_hand/dt_mis").gameObject:GetComponent(SF__.AttachEffectComponent)
        aec1:LerpIn(1300)
        local aec2 = aec1.gameObject.transform:Find("DivineToll_Holy").gameObject:GetComponent(SF__.AttachEffectComponent)
        aec2:LerpIn(1300)
        local casterPos__x, casterPos__y, casterPos__z = SF__.Vector3.FromUnit(caster350)
        local circulator358 = SF__.GameObject.New__sx13("Circulator", outer)
        circulator358.transform.localPosition__x, circulator358.transform.localPosition__y, circulator358.transform.localPosition__z = casterPos__x, casterPos__y, casterPos__z
        local rot = circulator358:AddComponent(SF__.AutoTRSComponent)
        rot.rotation__x, rot.rotation__y, rot.rotation__z, rot.rotation__w = SF__.Quaternion.Euler(0, ((300 * SF__.Scene.DT) / 1000), 0)
        rot.followUnit = caster350
        moveLayer.transform:SetParent(circulator358.transform)
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
    local eff359 = AddSpecialEffect("Abilities/Spells/Human/StormBolt/StormBoltMissile.mdl", pos__x352, pos__y353)
    boltMis:AddComponent(SF__.AttachEffectComponent):AttachEffect(eff359)
    local attachedHoly = SF__.GameObject.New__sx13("DivineToll_Holy", boltMis)
    attachedHoly.transform.localPosition__x, attachedHoly.transform.localPosition__y, attachedHoly.transform.localPosition__z = 15, 0, 0
    local effHoly = AddSpecialEffect("Abilities/Weapons/FaerieDragonMissile/FaerieDragonMissile.mdl", pos__x352, pos__y353)
    attachedHoly:AddComponent(SF__.AttachEffectComponent):AttachEffect(effHoly)
    BlzSetSpecialEffectColor(effHoly, 20, 20, 20)
end

function SF__.DivineToll.Start(data360)
    return SF__.CorRun__(function()
        local pos__x361, pos__y362, pos__z363 = SF__.Vector3.FromUnit(data360.caster)
        local targets = SF__.Utils.CsGroupGetUnitsInRange(pos__x361, pos__y362, 600, function(u364)
            if (not IsUnitEnemy(u364, GetOwningPlayer(data360.caster))) then
                return false
            end
            if IsUnitType(u364, UNIT_TYPE_STRUCTURE) then
                return false
            end
            if ExIsUnitDead(u364) then
                return false
            end
            return true
        end)
        if (targets.Count == 0) then
            return
        end
        targets:Sort(function(a367, b368)
            local distA369 = SF__.Vector3.Distance(pos__x361, pos__y362, pos__z363, SF__.Vector3.FromUnit(a367))
            local distB370 = SF__.Vector3.Distance(pos__x361, pos__y362, pos__z363, SF__.Vector3.FromUnit(b368))
            return (function() if (distA369 == distB370) then return 0 else return (function() if (distA369 < distB370) then return (-1) else return 1 end end)() end end)()
        end)
        do
            local i371 = 0
            while (i371 < (function()
                local field__TargetCount, field__Damage, field__RadiantDmgAmp, field__Duration = SF__.DivineToll.GetAbilityData(GetUnitAbilityLevel(data360.caster, SF__.DivineToll.ID))
                return math.min(targets.Count, field__TargetCount)
            end)()) do
                SF__.DivineToll.HurlToTarget(data360.caster, targets:get_Item(i371), pos__x361, pos__y362, pos__z363)
                SF__.CorWait__(200)
                ::continue::
                i371 = (i371 + 1)
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

function SF__.Easing.OutQubic(t59)
    return (1 - ((1 - t59) ^ 3))
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
function SF__.TemplarStrikes.GetAbilityData(level380)
    return 2, (0.5 + (0.25 * level380)), (0.05 * level380)
end

function SF__.TemplarStrikes.Init()
    local EventCenter381 = require("Lib.EventCenter")
    EventCenter381.RegisterPlayerUnitSpellEffect:Emit({id = SF__.TemplarStrikes.ID, handler = SF__.TemplarStrikes.Start})
    ExTriggerRegisterNewUnit(function(u383)
        if (GetUnitTypeId(u383) == FourCC("Hpal")) then
            SF__.TemplarStrikes.UpdateAbilityMeta(u383)
            SetHeroLevel(u383, 10, true)
        end
    end)
    EventCenter381.RegisterPlayerUnitDamaged:Emit(function(caster387, target388, damage389, weapType390, dmgType391, isAttack392)
        if (GetUnitAbilityLevel(caster387, SF__.TemplarStrikes.ID) <= 0) then
            return
        end
        if (not isAttack392) then
            return
        end
        if (target388 == nil) then
            return
        end
        if ExIsUnitDead(target388) then
            return
        end
        SF__.TemplarStrikes.TryResetBOJ(caster387)
    end)
end

function SF__.TemplarStrikes.TryResetBOJ(caster393)
    local level394 = GetUnitAbilityLevel(caster393, SF__.TemplarStrikes.ID)
    local ad__AttackCount, ad__DamageScaling395, ad__ResetBOJChance = SF__.TemplarStrikes.GetAbilityData(level394)
    if (math.random() >= ad__ResetBOJChance) then
        return
    end
    BlzEndUnitAbilityCooldown(caster393, SF__.BladeOfJustice.ID)
    ExAddSpecialEffectTarget("Abilities/Spells/Items/AIam/AIamTarget.mdl", caster393, "origin", 0.3)
end

function SF__.TemplarStrikes.UpdateAbilityMeta(u396)
    local p397 = GetOwningPlayer(u396)
    local datas398 = SF__.StdLib.List.New__0()
    do
        local i399 = 0
        while (i399 < SF__.TemplarStrikes.MaxLevel) do
            local __pack_AttackCount, __pack_DamageScaling400, __pack_ResetBOJChance = SF__.TemplarStrikes.GetAbilityData((i399 + 1))
            datas398:Add({AttackCount = __pack_AttackCount, DamageScaling = __pack_DamageScaling400, ResetBOJChance = __pack_ResetBOJChance})
            ::continue::
            i399 = (i399 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p397, SF__.TemplarStrikes.ID, "学习圣殿骑士之击 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p397, SF__.TemplarStrikes.ID, SF__.StrConcat__("快速攻击目标|cffff8c00", datas398:get_Item(0).AttackCount, "|r次，第一次造成普通攻击伤害，第二次造成光辉伤害，有一定几率重置公正之剑的冷却时间，普通攻击也会触发。\r\n\r\n|cff99ccff冷却时间|r - 10秒\r\n\r\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas398:get_Item(0).DamageScaling * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas398:get_Item(0).ResetBOJChance * 100)), "%|r的几率重置公正之剑。\r\n|cffffcc002级|r - |cffff8c00", string.format("%.0f", (datas398:get_Item(1).DamageScaling * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas398:get_Item(1).ResetBOJChance * 100)), "%|r的几率重置公正之剑。\r\n|cffffcc003级|r - |cffff8c00", string.format("%.0f", (datas398:get_Item(2).DamageScaling * 100)), "%|r的光辉攻击伤害，|cffff8c00", string.format("%.0f", (datas398:get_Item(2).ResetBOJChance * 100)), "%|r的几率重置公正之剑。"), 0)
    do
        local i401 = 0
        while (i401 < SF__.TemplarStrikes.MaxLevel) do
            local __unpack_tmp403 = datas398:get_Item(i401)
            local data__AttackCount, data__DamageScaling402, data__ResetBOJChance = __unpack_tmp403.AttackCount, __unpack_tmp403.DamageScaling, __unpack_tmp403.ResetBOJChance
            SF__.Utils.ExBlzSetAbilityTooltip(p397, SF__.TemplarStrikes.ID, SF__.StrConcat__("圣殿骑士之击 - [|cffffcc00", (i401 + 1), "级|r]"), i401)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p397, SF__.TemplarStrikes.ID, SF__.StrConcat__("快速攻击目标|cffff8c00", data__AttackCount, "|r次，第一次造成普通攻击伤害，第二次造成普通攻击|cffff8c00", string.format("%.0f", (data__DamageScaling402 * 100)), "%|r的光辉伤害，|cffff8c00", string.format("%.0f", (data__ResetBOJChance * 100)), "%|r几率重置公正之剑的冷却时间，普通攻击也会触发。\r\n\r\n|cff99ccff冷却时间|r - 10秒"), i401)
            ::continue::
            i401 = (i401 + 1)
        end
    end
end

function SF__.TemplarStrikes.Start(data404)
    return SF__.CorRun__(function()
        local level405 = GetUnitAbilityLevel(data404.caster, SF__.TemplarStrikes.ID)
        local UnitAttribute407 = require("Objects.UnitAttribute")
        local EventCenter408 = require("Lib.EventCenter")
        local attr406 = UnitAttribute407.GetAttr(data404.caster)
        local normalDamage = attr406:SimMeleeAttack()
        EventCenter408.Damage:Emit({whichUnit = data404.caster, target = data404.target, amount = normalDamage, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
        SF__.TemplarStrikes.TryResetBOJ(data404.caster)
        SetUnitTimeScale(data404.caster, 3)
        ResetUnitAnimation(data404.caster)
        SetUnitAnimation(data404.caster, "attack - 2")
        SF__.CorWait__(math.round(((1.166 * 0.33) * 1000)))
        local tarAttr409 = UnitAttribute407.GetAttr(data404.target)
        local ad__AttackCount410, ad__DamageScaling411, ad__ResetBOJChance412 = SF__.TemplarStrikes.GetAbilityData(level405)
        local radiantDamage = ((attr406:SimMeleeAttack() * ad__DamageScaling411) * (1 - tarAttr409.radiantResistance))
        EventCenter408.Damage:Emit({whichUnit = data404.caster, target = data404.target, amount = radiantDamage, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_MAGIC, weaponType = WEAPON_TYPE_METAL_HEAVY_BASH, outResult = {}})
        SF__.TemplarStrikes.TryResetBOJ(data404.caster)
        SetUnitTimeScale(data404.caster, 1)
        ResetUnitAnimation(data404.caster)
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
    local EventCenter435 = require("Lib.EventCenter")
    EventCenter435.RegisterPlayerUnitSpellChannel:Emit({id = SF__.WordOfGlory.ID, handler = SF__.WordOfGlory.Check})
    EventCenter435.RegisterPlayerUnitSpellEffect:Emit({id = SF__.WordOfGlory.ID, handler = SF__.WordOfGlory.Start})
    ExTriggerRegisterNewUnit(function(u437)
        if (GetUnitTypeId(u437) == FourCC("Hpal")) then
            SF__.WordOfGlory.UpdateAbilityMeta(u437)
        end
    end)
end

function SF__.WordOfGlory.Check(data438)
    local UnitAttribute440 = require("Objects.UnitAttribute")
    local attr439 = UnitAttribute440.GetAttr(data438.caster)
    if (attr439.retPalHolyEnergy < 3) then
        IssueImmediateOrderById(data438.caster, SF__.ConstOrderId.Stop)
        ExTextState(data438.caster, "圣能不足")
    end
end

function SF__.WordOfGlory.UpdateAbilityMeta(u441)
    local p442 = GetOwningPlayer(u441)
    SF__.Utils.ExSetAbilityResearchTooltip(p442, SF__.WordOfGlory.ID, "学习圣殿骑士的裁决 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p442, SF__.WordOfGlory.ID, "圣殿骑士的裁决造成一次攻击伤害，如果目标被审判，造成30%的额外伤害，15%几率重置审判。消耗|cffff8c003|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 5秒\r\n\r\n|cffffcc001级|r - |cffff8c00100%|r的攻击伤害，100%的战争艺术触发几率。", 0)
    do
        local i443 = 0
        while (i443 < 1) do
            SF__.Utils.ExBlzSetAbilityTooltip(p442, SF__.WordOfGlory.ID, SF__.StrConcat__("圣殿骑士的裁决 - [|cffffcc00", (i443 + 1), "级|r]"), i443)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p442, SF__.WordOfGlory.ID, "圣殿骑士的裁决造成一次攻击伤害，造成|cffff8c00100%|r的攻击伤害。消耗|cffff8c003|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 5秒", i443)
            ::continue::
            i443 = (i443 + 1)
        end
    end
end

function SF__.WordOfGlory.Start(data444)
    local UnitAttribute446 = require("Objects.UnitAttribute")
    local EventCenter447 = require("Lib.EventCenter")
    local attr445 = UnitAttribute446.GetAttr(data444.caster)
    EventCenter447.Heal:Emit({caster = data444.caster, target = data444.target, amount = 300})
    attr445.retPalHolyEnergy = (attr445.retPalHolyEnergy - 3)
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
local SystemBase34 = require("System.SystemBase")
SF__.Systems.InspectorSystem = SF__.Systems.InspectorSystem or class("InspectorSystem", SystemBase34)
SF__.Systems.InspectorSystem.Name = "InspectorSystem"
SF__.Systems.InspectorSystem.FullName = "Systems.InspectorSystem"
SF__.Systems.InspectorSystem.__sf_base = SystemBase34
function SF__.Systems.InspectorSystem:Awake()
    self:CreateFrames()
    self:RefreshHierarchy()
    self:SelectFirstVisibleObject()
    self:SetPanelVisible(false)
end

function SF__.Systems.InspectorSystem:Update(dt35)
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
        local i36 = 0
        while (i36 < SF__.Systems.InspectorSystem.MaxHierarchyRows) do
            self._hierarchyRows:Add(self:CreateHierarchyRow(i36))
            ::continue::
            i36 = (i36 + 1)
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

function SF__.Systems.InspectorSystem:CreateHierarchyRow(index37)
    local y38 = ((-0.061) - (index37 * (SF__.Systems.InspectorSystem.RowHeight + SF__.Systems.InspectorSystem.RowGap)))
    local button = BlzCreateFrameByType("BUTTON", "FdfInspectorHierarchyRow", self._panel, "ScoreScreenTabButtonTemplate", index37)
    BlzFrameSetPoint(button, FRAMEPOINT_TOPLEFT, self._panel, FRAMEPOINT_TOPLEFT, (SF__.Systems.InspectorSystem.Padding * 2), y38)
    BlzFrameSetSize(button, (SF__.Systems.InspectorSystem.LeftWidth - (SF__.Systems.InspectorSystem.Padding * 4)), SF__.Systems.InspectorSystem.RowHeight)
    local label39 = BlzCreateFrameByType("TEXT", "FdfInspectorHierarchyRowText", button, "", index37)
    BlzFrameSetPoint(label39, FRAMEPOINT_TOPLEFT, button, FRAMEPOINT_TOPLEFT, 0.004, (-0.002))
    BlzFrameSetSize(label39, (SF__.Systems.InspectorSystem.LeftWidth - (SF__.Systems.InspectorSystem.Padding * 5)), (SF__.Systems.InspectorSystem.RowHeight - 0.003))
    BlzFrameSetEnable(label39, false)
    BlzFrameSetTextAlignment(label39, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_LEFT)
    BlzFrameSetText(label39, "")
    local row = SF__.Systems.InspectorSystem.HierarchyRow.New(button, label39)
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

function SF__.Systems.InspectorSystem:SelectRow(row40)
    if (row40.gameObject == nil) then
        return
    end
    self._selectedGameObject = row40.gameObject
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
        for _, obj41 in (SF__.StdLib.List.IpairsNext)(collection10) do
            if (obj41.transform.parent == nil) then
                self:AddHierarchyObject(obj41, 0)
            end
        end
    end
    do
        local i42 = 0
        while (i42 < self._hierarchyRows.Count) do
            local row43 = self._hierarchyRows:get_Item(i42)
            if (i42 < self._visibleObjects.Count) then
                local obj44 = self._visibleObjects:get_Item(i42)
                row43.gameObject = obj44
                row43.depth = self:GetDepth(obj44)
                self:SetRowLabel(row43, obj44.name, row43.depth)
                BlzFrameSetVisible(row43.button, self._isVisible)
            else
                row43.gameObject = nil
                BlzFrameSetVisible(row43.button, false)
            end
            ::continue::
            i42 = (i42 + 1)
        end
    end
    BlzFrameSetVisible(self._emptyText, (self._isVisible and (self._visibleObjects.Count == 0)))
    self._lastObjectCount = SF__.Scene.get_Instance().gameObjs.Count
    self:RefreshHierarchySelection()
end

function SF__.Systems.InspectorSystem:AddHierarchyObject(obj45, depth)
    if (self._visibleObjects.Count >= SF__.Systems.InspectorSystem.MaxHierarchyRows) then
        return
    end
    self._visibleObjects:Add(obj45)
    do
        local collection11 = obj45.transform.children
        for _, child46 in (SF__.StdLib.List.IpairsNext)(collection11) do
            self:AddHierarchyObject(child46.gameObject, (depth + 1))
        end
    end
end

function SF__.Systems.InspectorSystem:GetDepth(obj47)
    local depth48 = 0
    local parent49 = obj47.transform.parent
    while (parent49 ~= nil) do
        depth48 = (depth48 + 1)
        parent49 = parent49.parent
        ::continue::
    end
    return depth48
end

function SF__.Systems.InspectorSystem:SetRowLabel(row50, text51, depth52)
    BlzFrameClearAllPoints(row50.label)
    BlzFrameSetPoint(row50.label, FRAMEPOINT_TOPLEFT, row50.button, FRAMEPOINT_TOPLEFT, (0.004 + (depth52 * SF__.Systems.InspectorSystem.IndentWidth)), (-0.002))
    BlzFrameSetSize(row50.label, ((SF__.Systems.InspectorSystem.LeftWidth - (SF__.Systems.InspectorSystem.Padding * 5)) - (depth52 * SF__.Systems.InspectorSystem.IndentWidth)), (SF__.Systems.InspectorSystem.RowHeight - 0.003))
    BlzFrameSetText(row50.label, text51)
end

function SF__.Systems.InspectorSystem:RefreshHierarchySelection()
    do
        local collection12 = self._hierarchyRows
        for _, row53 in (SF__.StdLib.List.IpairsNext)(collection12) do
            local isSelected = ((row53.gameObject ~= nil) and (row53.gameObject == self._selectedGameObject))
            BlzFrameSetTextColor(row53.label, (function() if isSelected then return BlzConvertColor(255, 255, 220, 80) else return BlzConvertColor(255, 230, 230, 230) end end)())
        end
    end
end

function SF__.Systems.InspectorSystem:RefreshInspectorText()
    if (self._selectedGameObject == nil) then
        BlzFrameSetText(self._inspectorText, "")
        return
    end
    local text54 = SF__.StrConcat__(self._selectedGameObject.name, "\n")
    do
        local collection13 = self._selectedGameObject:get_components()
        for _, component in (SF__.StdLib.List.IpairsNext)(collection13) do
            text54 = SF__.StrConcat__(text54, "\n[", component.__sf_type.Name, "]")
            local inspectorText = component:GetInspectorText()
            if (inspectorText ~= "") then
                text54 = SF__.StrConcat__(text54, "\n", inspectorText)
            end
        end
    end
    BlzFrameSetText(self._inspectorText, text54)
end

function SF__.Systems.InspectorSystem:SceneContains(gameObject)
    do
        local collection14 = SF__.Scene.get_Instance().gameObjs
        for _, obj55 in (SF__.StdLib.List.IpairsNext)(collection14) do
            if (obj55 == gameObject) then
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
function SF__.Systems.InspectorSystem.HierarchyRow.__Init(self, button56, label57)
    self.__sf_type = SF__.Systems.InspectorSystem.HierarchyRow
    self.button = nil
    self.label = nil
    self.gameObject = nil
    self.depth = 0
    self.button = button56
    self.label = label57
end

function SF__.Systems.InspectorSystem.HierarchyRow.New(button56, label57)
    local self = setmetatable({}, { __index = SF__.Systems.InspectorSystem.HierarchyRow })
    SF__.Systems.InspectorSystem.HierarchyRow.__Init(self, button56, label57)
    return self
end
-- Systems.MeleeGameSystem
local SystemBase58 = require("System.SystemBase")
SF__.Systems.MeleeGameSystem = SF__.Systems.MeleeGameSystem or class("MeleeGameSystem", SystemBase58)
SF__.Systems.MeleeGameSystem.Name = "MeleeGameSystem"
SF__.Systems.MeleeGameSystem.FullName = "Systems.MeleeGameSystem"
SF__.Systems.MeleeGameSystem.__sf_base = SystemBase58
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
    local item98 = self._items:get_Item((self._items.Count - 1))
    self._items:RemoveAt((self._items.Count - 1))
    return item98
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
function SF__.TemplarVerdict.GetAbilityData(level413)
    return 2.25, 0.3, 0.15
end

function SF__.TemplarVerdict.Init()
    local EventCenter414 = require("Lib.EventCenter")
    EventCenter414.RegisterPlayerUnitSpellChannel:Emit({id = SF__.TemplarVerdict.ID, handler = SF__.TemplarVerdict.Check})
    EventCenter414.RegisterPlayerUnitSpellEffect:Emit({id = SF__.TemplarVerdict.ID, handler = SF__.TemplarVerdict.Start})
    ExTriggerRegisterNewUnit(function(u416)
        if (GetUnitTypeId(u416) == FourCC("Hpal")) then
            SF__.TemplarVerdict.UpdateAbilityMeta(u416)
        end
    end)
end

function SF__.TemplarVerdict.Check(data417)
    local UnitAttribute419 = require("Objects.UnitAttribute")
    local attr418 = UnitAttribute419.GetAttr(data417.caster)
    if (attr418.retPalHolyEnergy < 3) then
        IssueImmediateOrderById(data417.caster, SF__.ConstOrderId.Stop)
        ExTextState(data417.caster, "圣能不足")
    end
end

function SF__.TemplarVerdict.UpdateAbilityMeta(u420)
    local p421 = GetOwningPlayer(u420)
    local datas422 = SF__.StdLib.List.New__0()
    do
        local i423 = 0
        while (i423 < 1) do
            local __pack_DamageScaling424, __pack_JudgementDamageScaling, __pack_ChanceToResetJudgement = SF__.TemplarVerdict.GetAbilityData((i423 + 1))
            datas422:Add({DamageScaling = __pack_DamageScaling424, JudgementDamageScaling = __pack_JudgementDamageScaling, ChanceToResetJudgement = __pack_ChanceToResetJudgement})
            ::continue::
            i423 = (i423 + 1)
        end
    end
    SF__.Utils.ExSetAbilityResearchTooltip(p421, SF__.TemplarVerdict.ID, "学习圣殿骑士的裁决 - [|cffffcc00%d级|r]", 0)
    SF__.Utils.ExBlzSetAbilityResearchExtendedTooltip(p421, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决造成一次攻击伤害，如果目标被审判，造成30%的额外伤害，15%几率重置审判。消耗|cffff8c003|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 5秒\r\n\r\n|cffffcc001级|r - |cffff8c00", string.format("%.0f", (datas422:get_Item(0).JudgementDamageScaling * 100)), "%|r的攻击伤害，", string.format("%.0f", (datas422:get_Item(0).ChanceToResetJudgement * 100)), "%的战争艺术触发几率。"), 0)
    do
        local i425 = 0
        while (i425 < 1) do
            local __unpack_tmp427 = datas422:get_Item(i425)
            local data__DamageScaling426, data__JudgementDamageScaling, data__ChanceToResetJudgement = __unpack_tmp427.DamageScaling, __unpack_tmp427.JudgementDamageScaling, __unpack_tmp427.ChanceToResetJudgement
            SF__.Utils.ExBlzSetAbilityTooltip(p421, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决 - [|cffffcc00", (i425 + 1), "级|r]"), i425)
            SF__.Utils.ExBlzSetAbilityExtendedTooltip(p421, SF__.TemplarVerdict.ID, SF__.StrConcat__("圣殿骑士的裁决造成一次攻击伤害，造成|cffff8c00", string.format("%.0f", (data__DamageScaling426 * 100)), "%|r的攻击伤害。消耗|cffff8c003|r点圣能。\r\n\r\n|cff99ccff冷却时间|r - 5秒"), i425)
            ::continue::
            i425 = (i425 + 1)
        end
    end
end

function SF__.TemplarVerdict.Start(data428)
    local level429 = GetUnitAbilityLevel(data428.caster, SF__.TemplarVerdict.ID)
    local UnitAttribute432 = require("Objects.UnitAttribute")
    local EventCenter434 = require("Lib.EventCenter")
    local ad__DamageScaling430, ad__JudgementDamageScaling, ad__ChanceToResetJudgement = SF__.TemplarVerdict.GetAbilityData(level429)
    local attr431 = UnitAttribute432.GetAttr(data428.caster)
    local damage433 = (attr431:SimAttack(UnitAttribute432.HeroAttributeType.Strength) * ad__DamageScaling430)
    EventCenter434.Damage:Emit({whichUnit = data428.caster, target = data428.target, amount = damage433, attack = true, ranged = false, attackType = ATTACK_TYPE_HERO, damageType = DAMAGE_TYPE_NORMAL, weaponType = WEAPON_TYPE_METAL_HEAVY_SLICE, outResult = {}})
    attr431.retPalHolyEnergy = (attr431.retPalHolyEnergy - 3)
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

function SF__.Vector2.Dot(a__x113, a__y114, b__x115, b__y116)
    return ((a__x113 * b__x115) + (a__y114 * b__y116))
end

function SF__.Vector2.Cross(a__x117, a__y118, b__x119, b__y120)
    return ((a__y118 * b__x119) - (a__x117 * b__y120))
end

function SF__.Vector2.op_UnaryNegation(a__x121, a__y122)
    return (-a__x121), (-a__y122)
end

function SF__.Vector2.op_Addition(a__x123, a__y124, b__x125, b__y126)
    return (a__x123 + b__x125), (a__y124 + b__y126)
end

function SF__.Vector2.op_Subtraction(a__x127, a__y128, b__x129, b__y130)
    return (a__x127 - b__x129), (a__y128 - b__y130)
end

function SF__.Vector2.op_Multiply__ahdf(v__x131, v__y132, f)
    return (v__x131 * f), (v__y132 * f)
end

function SF__.Vector2.op_Multiply__fahd(f133, v__x134, v__y135)
    return (v__x134 * f133), (v__y135 * f133)
end

function SF__.Vector2.op_Division(v__x136, v__y137, f138)
    return (v__x136 / f138), (v__y137 / f138)
end

function SF__.Vector2.UnitDistance(a, b)
    local v1__x, v1__y = SF__.Vector2.FromUnit(a)
    local v2__x, v2__y = SF__.Vector2.FromUnit(b)
    return SF__.Vector2.get_Magnitude(SF__.Vector2.op_Subtraction(v1__x, v1__y, v2__x, v2__y))
end

function SF__.Vector2.SqrUnitDistance(a139, b140)
    local v1__x141, v1__y142 = SF__.Vector2.FromUnit(a139)
    local v2__x143, v2__y144 = SF__.Vector2.FromUnit(b140)
    return SF__.Vector2.get_SqrMagnitude(SF__.Vector2.op_Subtraction(v1__x141, v1__y142, v2__x143, v2__y144))
end

function SF__.Vector2.FromUnit(u145)
    return GetUnitX(u145), GetUnitY(u145)
end

function SF__.Vector2.get_Magnitude(self__x146, self__y147)
    return math.sqrt(SF__.Vector2.get_SqrMagnitude(self__x146, self__y147))
end

function SF__.Vector2.get_SqrMagnitude(self__x148, self__y149)
    return ((self__x148 * self__x148) + (self__y149 * self__y149))
end

function SF__.Vector2.get_Normalized(self__x150, self__y151)
    local mag = SF__.Vector2.get_Magnitude(self__x150, self__y151)
    if (mag < 0.0001) then
        return SF__.Vector2.get_Zero()
    end
    return SF__.Vector2.op_Division(self__x150, self__y151, mag)
end

function SF__.Vector2.ClampMagnitude(self__x154, self__y155, mag156)
    return (function()
        local v__x157, v__y158 = SF__.Vector2.get_Normalized(self__x154, self__y155)
        return SF__.Vector2.op_Multiply__ahdf(v__x157, v__y158, mag156)
    end)()
end

function SF__.Vector2.ToString(self__x159, self__y160)
    return SF__.StrConcat__("(", self__x159, ", ", self__y160, ")")
end

function SF__.Vector2.Rotate(self__x161, self__y162, angle163)
    local cos = math.cos(angle163)
    local sin = math.sin(angle163)
    return ((self__x161 * cos) - (self__y162 * sin)), ((self__x161 * sin) + (self__y162 * cos))
end

function SF__.Vector2.UnitMoveTo(self__x164, self__y165, u166)
    SetUnitX(u166, self__x164)
    SetUnitY(u166, self__y165)
end

function SF__.Vector2.GetTerrainZ(self__x167, self__y168)
    MoveLocation(SF__.Vector2._loc, self__x167, self__y168)
    return GetLocationZ(SF__.Vector2._loc)
end

SF__.Vector2._loc = Location(0, 0)

SF__.Program.Main()
