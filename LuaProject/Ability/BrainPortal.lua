local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local BuffBase = require("Objects.BuffBase")
local FesteringWound = require("Ability.FesteringWound")
local UnitAttribute = require("Objects.UnitAttribute")
local Vector2 = require("Lib.Vector2")
local Timer = require("Lib.Timer")

--region meta

local Meta = {
    Range = 600,
    AllowedPeople = 2,
    PortalRange = 256,
}

Abilities.BrainConnection = Meta

--endregion

---@class BrainPortal
local cls = class("BrainPortal")

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Abilities.Apocalypse.ID,
    ---@param data ISpellData
    handler = function(data)
        local v = Vector2.new(1, 0):RotateSelf(math.random() * 2 * math.pi):Mul(Meta.Range)
        local portalPos = Vector2.FromUnit(data.caster):Add(v)
        local sfx = AddSpecialEffect("dark_portal", portalPos.x, portalPos.y)

        local allowedPeople = Meta.AllowedPeople

        coroutine.start(function()
            while true do
                coroutine.wait(0.1)
                local nearby = ExGroupGetUnitsInRange(portalPos.x, portalPos.y, Meta.PortalRange, function(unit)
                    if IsUnitAlly(unit, Player(1)) and not ExIsUnitDead(unit) then
                        return true
                    else
                        return false
                    end
                end)
                if table.any(nearby) then
                    -- teleport unit
                    allowedPeople = allowedPeople - 1
                end

                if allowedPeople <= 0 then
                    DestroyEffect(sfx)
                    break
                end
            end
        end)

    end
})

return cls
