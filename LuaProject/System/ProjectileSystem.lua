local Event = require("Lib.Event")
local EventCenter = require("Lib.EventCenter")
local SystemBase = require("System.SystemBase")
local Vector2 = require("Lib.Vector2")

EventCenter.NewProjectile = Event.new()

---@class ProjectileSystem : SystemBase
local cls = class("ProjectileSystem", SystemBase)

function cls:ctor()
    self.projectiles = {} ---@type ProjectileBase[]
end

function cls:Awake()
    EventCenter.NewProjectile:On(self, cls.onNewProjectile)
end

function cls:Update(dt)
    local toRemove = {}
    for idx, proj in ipairs(self.projectiles) do
        if proj.targetType == "unit" then
            local curr = proj.pos
            local dest = Vector2.FromUnit(proj.target)
            local norm = (dest - curr):SetNormalize()
            local dir = norm * (proj.speed * dt)
            curr:Add(dir)
            BlzSetSpecialEffectX(proj.sfx, curr.x)
            BlzSetSpecialEffectY(proj.sfx, curr.y)
            BlzSetSpecialEffectZ(proj.sfx, curr:GetTerrainZ() + 60) -- todo, use vec3
            BlzSetSpecialEffectYaw(proj.sfx, math.atan2(norm.y, norm.x))

            if dest:Sub(curr):Magnitude() < 20 then
                DestroyEffect(proj.sfx)
                proj.onHit()

                table.insert(toRemove, idx)
            end
        end
    end

    for i = #toRemove, 1, -1 do
        table.remove(self.projectiles, toRemove[i])
    end
end

function cls:onNewProjectile(data)
    table.insert(self.projectiles, data.inst)
end

return cls
