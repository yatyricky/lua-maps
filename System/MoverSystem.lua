local Event = require("Lib.Event")
local EventCenter = require("Lib.EventCenter")
local SystemBase = require("System.SystemBase")
local Vector2 = require("Lib.Vector2")
local Mover = require("Objects.Mover")

EventCenter.NewMover = Event.new()

---@class MoverSystem : SystemBase
local cls = class("MoverSystem", SystemBase)

function cls:ctor()
    self.instances = {} ---@type Mover[]
end

function cls:Awake()
    EventCenter.NewMover:On(self, cls.onNewMover)
end

function cls:Update(dt)
    local toRemove = {}
    for idx, inst in ipairs(self.instances) do
        local dist = inst.moveBehaviour(inst, dt)
        if inst:CheckArrived(dist) then
            if inst.onArrived then
                inst.onArrived()
            end
            table.insert(toRemove, idx)
        end
    end

    for i = #toRemove, 1, -1 do
        table.remove(self.instances, toRemove[i])
    end
end

---@param inst Mover
function cls:onNewMover(inst)
    if inst.destType == Mover.DestinationType.None then
        if inst.onArrived then
            inst.onArrived()
        end
    else
        table.insert(self.instances, inst)
    end
end

return cls
