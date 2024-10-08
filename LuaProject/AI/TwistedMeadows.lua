local Vector2 = require("Lib.Vector2")

local basePos = Vector2.new(-3202, 4121)
local Interval = 10
local p1 = Player(1)
local TrainCount = 3

local UTID_Archer = FourCC("earc")
local UTID_Huntress = FourCC("esen")
local UTID_Dryad = FourCC("edry")
local UTID_Ballista = FourCC("ebal")
local UTID_Chimaera = FourCC("echm")
local UTID_Druid = FourCC("edoc")

local Army = {
    [UTID_Druid] = 4, -- 16
    [UTID_Ballista] = 2, -- 6
    [UTID_Huntress] = 3, -- 15
    [UTID_Archer] = 7, -- 8
}

local cls = class("TwistedMeadows")

function cls:ctor()
    self.time = 0
    self.army = {}

    ExTriggerRegisterNewUnit(function(unit)
        if ExGetUnitPlayerId(unit) == 1 then
            table.addNum(self.army, GetUnitTypeId(unit), 1)
        end
    end)

    ExTriggerRegisterUnitDeath(function(unit)
        if ExGetUnitPlayerId(unit) == 1 then
            table.addNum(self.army, GetUnitTypeId(unit), -1)
        end
    end)
end

function cls:Update(dt)
    self.time = self.time + dt
    if self.time >= Interval then
        self.time = self.time % Interval
        self:run()
    end
end

function cls:run()
    if Time.Time < 360 then
        return
    end
    local trained = TrainCount
    for utid, maxSize in pairs(Army) do
        local current = self.army[utid] or 0
        local diff = maxSize - current
        if diff > 0 then
            local train = math.min(diff, trained)
            for _ = 1, train do
                CreateUnit(p1, utid, basePos.x, basePos.y, 0)
            end
            trained = trained - train
        end

        if trained <= 0 then
            break
        end
    end

    if Time.Time > 300 and trained <= 0 then
        Interval = Interval + 0.4
    end
end

return cls
