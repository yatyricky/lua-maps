local Vector2 = require("Lib.Vector2")
local Timer = require("Lib.Timer")
local Const = require("Config.Const")
local EventCenter = require("Lib.EventCenter")
local Event = require("Lib.Event")

EventCenter.DefaultOrder = Event.new()

local MyBase = Vector2.new(4022, 4110)
local EnemyBase = Vector2.new(-4248, -5806)
local MyPlayer = Player(0)
local EnemyPlayer = Player(3)

local Interval = 30
local DefaultOrder = {}

local MyArmy = {
    { [FourCC("earc")] = 4 },
    { [FourCC("esen")] = 4 },
    { [FourCC("earc")] = 4, [FourCC("esen")] = 2 },
    { [FourCC("esen")] = 2, [FourCC("ebal")] = 2 },
    { [FourCC("earc")] = 2, [FourCC("esen")] = 4 },
    { [FourCC("edry")] = 4 },
    { [FourCC("edoc")] = 4 },
    { [FourCC("earc")] = 4, [FourCC("edoc")] = 2 },
    { [FourCC("earc")] = 6 },
}

local EnemyArmy = {
    { [FourCC("nfel")] = 4 },
    { [FourCC("nfel")] = 4, [FourCC("nbal")] = 1 },
    { [FourCC("nfel")] = 4, [FourCC("nvde")] = 1 },
    { [FourCC("nfel")] = 6, [FourCC("nbal")] = 1 },
    { [FourCC("nfel")] = 6, [FourCC("ninf")] = 1 },
    { [FourCC("nfel")] = 6, [FourCC("nbal")] = 1 },
    { [FourCC("nfel")] = 8, [FourCC("ndqs")] = 1 },
    { [FourCC("nfel")] = 8, [FourCC("nbal")] = 1 },
    { [FourCC("nfel")] = 8, [FourCC("nerw")] = 1 },
}

local cls = class("MoonGlade")

function cls:ctor()
    local index = 1
    local function spawn()
        local myArmy = MyArmy[math.clamp(index, 1, #MyArmy)]
        for utid, count in pairs(myArmy) do
            for _ = 1, count do
                local u = CreateUnit(MyPlayer, utid, MyBase.x, MyBase.y, 0)
                IssuePointOrderById(u, Const.OrderId_Attack, EnemyBase.x, EnemyBase.y)
                DefaultOrder[u] = { Const.OrderId_Attack, EnemyBase.x, EnemyBase.y }
            end
        end
        local enemyArmy = EnemyArmy[math.clamp(index, 1, #EnemyArmy)]
        for utid, count in pairs(enemyArmy) do
            for _ = 1, count do
                local u = CreateUnit(EnemyPlayer, utid, EnemyBase.x, EnemyBase.y, 0)
                IssuePointOrderById(u, Const.OrderId_Attack, MyBase.x, MyBase.y)
                DefaultOrder[u] = { Const.OrderId_Attack, MyBase.x, MyBase.y }
            end
        end
        index = index + 1
    end
    spawn()
    Timer.new(spawn, Interval, -1):Start()

    local hero = CreateUnit(MyPlayer, FourCC("E001"), MyBase.x, MyBase.y, 0)
    --ExTriggerRegisterUnitDeath(function(unit)
    --    if GetUnitTypeId(unit) == FourCC("nbal") then
    --        SetHeroLevel(hero, GetHeroLevel(hero) + 1, true)
    --    end
    --end)

    EventCenter.DefaultOrder:On(self, cls.onDefaultOrder)
end

function cls:Update()
end

function cls:onDefaultOrder(unit)
    local order = DefaultOrder[unit]
    if not order then
        return
    end
    IssuePointOrderById(unit, order[1], order[2], order[3])
end

return cls
