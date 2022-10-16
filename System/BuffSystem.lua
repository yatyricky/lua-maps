local EventCenter = require("Lib.EventCenter")
local Event = require("Lib.Event")
local SystemBase = require("System.SystemBase")
local Time = require("Lib.Time")

local ExIsUnitDead = ExIsUnitDead
local ipairs = ipairs
local t_insert = table.insert
local t_remove = table.remove

EventCenter.NewBuff = Event.new()

---@class BuffSystem : SystemBase
local cls = class("BuffSystem", SystemBase)

function cls:ctor()
    self.buffs = {} ---@type BuffBase[]
end

function cls:Awake()
    EventCenter.NewBuff:On(self, cls.onNewBuff)
end

function cls:Update(dt)
    local toRemove = {}
    for i, buff in ipairs(self.buffs) do
        if ExIsUnitDead(buff.target) then
            t_insert(toRemove, i)
        else
            local time = Time.Time
            buff.time = time
            if time > buff.expire then
                t_insert(toRemove, i)
            else
                if time >= buff.nextUpdate then
                    buff:Update()
                    buff.nextUpdate = buff.nextUpdate + buff.interval
                end
                if time == buff.expire then
                    t_insert(toRemove, i)
                end
            end
        end
    end

    local removedBuffs = {}
    for i = #toRemove, 1, -1 do
        local removed = t_remove(self.buffs, toRemove[i])
        removed:OnDisable()
        t_insert(removedBuffs, removed)
    end

    for _, buff in ipairs(removedBuffs) do
        buff:OnDestroy()
    end
end

---@param buff BuffBase
function cls:onNewBuff(buff)
    t_insert(self.buffs, buff)
    buff:Awake()
    buff:OnEnable()
end

return cls
