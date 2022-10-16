local EventCenter = require("Lib.EventCenter")
local Event = require("Lib.Event")
local SystemBase = require("System.SystemBase")
local Time = require("Lib.Time")

EventCenter.NewBuff = Event.new()

---@class BuffSystem : SystemBase
local cls = class("BuffSystem", SystemBase)

function cls:ctor()
    EventCenter.NewBuff:On(self, cls.onNewBuff)
    self.buffs = {} ---@type BuffBase[]
end

function cls:Update(_, now)
    local toRemove = {}
    for i, buff in ipairs(self.buffs) do
        if ExIsUnitDead(buff.target) then
            table.insert(toRemove, i)
        else
            buff.time = now
            if now > buff.expire then
                table.insert(toRemove, i)
            else
                if now >= buff.nextUpdate then
                    buff:Update()
                    buff.nextUpdate = now + buff.interval
                end
                if now == buff.expire then
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
