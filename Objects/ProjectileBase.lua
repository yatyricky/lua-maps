local EventCenter = require("Lib.EventCenter")
local Timer = require("Lib.Timer")
local Vector2 = require("Lib.Vector2")

---@class ProjectileBase
local cls = class("ProjectileBase")

---@param caster unit
---@param target unit
---@param model string
---@param onHit fun(): void
---@param casterOffset Vector3 | Nil
function cls:ctor(caster, target, model, speed, onHit, casterOffset)
    local startPos = Vector2.FromUnit(caster)
    if casterOffset then
        startPos.x = startPos.x + casterOffset.x
        startPos.y = startPos.y + casterOffset.y
    end
    self.sfx = AddSpecialEffect(model, startPos.x, startPos.y)

    self.pos = startPos
    self.speed = speed
    self.targetType = "unit"
    self.target = target
    self.caster = caster
    self.onHit = onHit

    print("?????")

    EventCenter.NewProjectile:Emit({ inst = self })
end

return cls
