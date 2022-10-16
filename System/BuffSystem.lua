local EventCenter = require("Lib.EventCenter")
local Event = require("Lib.Event")
local SystemBase = require("System.SystemBase")

EventCenter.NewBuff = Event.new()

---@class BuffSystem : SystemBase
local cls = class("BuffSystem", SystemBase)

function cls:ctor()
    EventCenter.NewBuff:On(self, cls.onNewBuff)
    self.buffs = {} ---@type BuffBase[]
end

function cls:Update(dt)
    local toRemove = {}
    for i, buff in ipairs(self.buffs) do
        if IsUnitDeadBJ(buff.target) then
            table.insert(toRemove, i)
        else
            local time = buff.time + dt
            buff.time = time
            if time > buff.expire then
                table.insert(toRemove, i)
            else
                if time >= buff.nextUpdate then
                    buff:Update()
                    buff.nextUpdate = buff.nextUpdate + buff.interval
                end
                if time == buff.expire then
                    table.insert(toRemove, i)
                end
            end
        end
    end

    local removedBuffs = {}
    for i = #toRemove, 1, -1 do
        local removed = table.remove(self.buffs, toRemove[i])
        removed:OnDisable()
        table.insert(removedBuffs, removed)
    end

    for _, buff in ipairs(removedBuffs) do
        buff:OnDestroy()
    end
end

---@param buff BuffBase
function cls:onNewBuff(buff)
    table.insert(self.buffs, buff)
    buff:Awake()
    buff:OnEnable()
end

return cls
