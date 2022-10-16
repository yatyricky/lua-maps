local Time = require("Lib.Time")

local pcall = pcall
local c_start = coroutine.start
local c_wait = coroutine.wait
local c_step = coroutine.step
local m_round = math.round
local t_insert = table.insert

local TriggerAddAction = TriggerAddAction

---@param trigger trigger
---@param action fun(): void
---@return void
function ExTriggerAddAction(trigger, action)
    TriggerAddAction(trigger, function()
        local s, m = pcall(action)
        if not s then
            print(m)
        end
    end)
end

local GroupEnumUnitsInRange = GroupEnumUnitsInRange
local Filter = Filter
local GetFilterUnit = GetFilterUnit

local group = CreateGroup()

---@param x real
---@param y real
---@param radius real
---@param callback fun(unit: unit): void
---@return void
function ExGroupEnumUnitsInRange(x, y, radius, callback)
    GroupEnumUnitsInRange(group, x, y, radius, Filter(function()
        local s, m = pcall(callback, GetFilterUnit())
        if not s then
            print(m)
        end
        return false
    end))
end

local AddSpecialEffectTarget = AddSpecialEffectTarget
local AddSpecialEffect = AddSpecialEffect
local BlzSetSpecialEffectColor = BlzSetSpecialEffectColor
local DestroyEffect = DestroyEffect

function ExAddSpecialEffectTarget(modelName, target, attachPoint, duration)
    c_start(function()
        local sfx = AddSpecialEffectTarget(modelName, target, attachPoint)
        c_wait(duration)
        DestroyEffect(sfx)
    end)
end

function ExAddSpecialEffect(modelName, x, y, duration, color)
    c_start(function()
        local sfx = AddSpecialEffect(modelName, x, y)
        if color then
            BlzSetSpecialEffectColor(sfx, m_round(color.r * 255), m_round(color.g * 255), m_round(color.b * 255))
        end
        c_wait(duration)
        DestroyEffect(sfx)
    end)
end

local AddLightningEx = AddLightningEx
local SetLightningColor = SetLightningColor
local MoveLightningEx = MoveLightningEx
local DestroyLightning = DestroyLightning
local GetUnitX = GetUnitX
local GetUnitY = GetUnitY
local BlzGetUnitZ = BlzGetUnitZ
local GetUnitFlyHeight = GetUnitFlyHeight

function ExAddLightningPosPos(modelName, x1, y1, z1, x2, y2, z2, duration, color, check)
    c_start(function()
        local lightning = AddLightningEx(modelName, check or false, x1, y1, z1, x2, y2, z2)
        if color then
            SetLightningColor(lightning, color.r, color.g, color.b, color.a)
        end
        c_wait(duration)
        DestroyLightning(lightning)
    end)
end

function ExAddLightningUnitUnit(modelName, unit1, unit2, duration, color, checkVisibility)
    c_start(function()
        checkVisibility = checkVisibility or false
        local expr = Time.Time + duration
        local lightning = AddLightningEx(modelName, checkVisibility,
                GetUnitX(unit1), GetUnitY(unit1), BlzGetUnitZ(unit1) + GetUnitFlyHeight(unit1),
                GetUnitX(unit2), GetUnitY(unit2), BlzGetUnitZ(unit2) + GetUnitFlyHeight(unit2))
        if color then
            SetLightningColor(lightning, color.r, color.g, color.b, color.a)
        end
        while true do
            c_step()
            MoveLightningEx(lightning, checkVisibility,
                    GetUnitX(unit1), GetUnitY(unit1), BlzGetUnitZ(unit1) + GetUnitFlyHeight(unit1),
                    GetUnitX(unit2), GetUnitY(unit2), BlzGetUnitZ(unit2) + GetUnitFlyHeight(unit2))
            if Time.Time >= expr then
                break
            end
        end
        DestroyLightning(lightning)
    end)
end

function ExAddLightningPosUnit(modelName, x1, y1, z1, unit2, duration, color, check)
    c_start(function()
        check = check or false
        local expr = Time.Time + duration
        local lightning = AddLightningEx(modelName, check,
                x1, y1, z1,
                GetUnitX(unit2), GetUnitY(unit2), BlzGetUnitZ(unit2) + GetUnitFlyHeight(unit2))
        if color then
            SetLightningColor(lightning, color.r, color.g, color.b, color.a)
        end
        while true do
            c_step()
            MoveLightningEx(lightning, check,
                    x1, y1, z1,
                    GetUnitX(unit2), GetUnitY(unit2), BlzGetUnitZ(unit2) + GetUnitFlyHeight(unit2))
            if Time.Time >= expr then
                break
            end
        end
        DestroyLightning(lightning)
    end)
end

--local GetTriggerUnit = GetTriggerUnit
--
--local mapArea = CreateRegion()
--RegionAddRect(mapArea, bj_mapInitialPlayableArea)
--local enterTrigger = CreateTrigger()
--local enterMapCalls = {}
--TriggerRegisterEnterRegion(enterTrigger, mapArea, Filter(function() return true end))
--ExTriggerAddAction(enterTrigger, function()
--    local u = GetTriggerUnit()
--    for _, v in ipairs(enterMapCalls) do
--        v(u)
--    end
--end)
--function ExTriggerRegisterNewUnit(callback)
--    t_insert(enterMapCalls, callback)
--end

local GetWidgetLife = GetWidgetLife

function ExIsUnitDead(unit)
    return GetWidgetLife(unit) < 0.406
end
