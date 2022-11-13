local EventCenter = require("Lib.EventCenter")
local Timer = require("Lib.Timer")
local Abilities = require("Config.Abilities")
local Tween = require("Lib.Tween")
local Vector3 = require("Lib.Vector3")

local cls = class("MagmaBreath")

local Meta = {
    ID = FourCC("A01H"),
}

Abilities.MagmaBreath = Meta

local function aoeDamage(caster, x, y, damage, checkMap)
    local casterPlayer = GetOwningPlayer(caster)
    ExGroupEnumUnitsInRange(x, y, 120, function(unit)
        if IsUnitEnemy(unit, casterPlayer) and not ExIsUnitDead(unit) and not checkMap[unit] then
            EventCenter.Damage:Emit({
                whichUnit = caster,
                target = unit,
                amount = damage,
                attack = false,
                ranged = true,
                attackType = ATTACK_TYPE_HERO,
                damageType = DAMAGE_TYPE_FIRE,
                weaponType = WEAPON_TYPE_WHOKNOWS,
                outResult = {}
            })
            checkMap[unit] = true
        end
    end)
end

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Meta.ID,
    ---@param data ISpellData
    handler = function(data)
        local myPos = Vector3.FromUnit(data.caster)
        local damaged1 = {}
        local damaged2 = {}
        myPos.z = myPos.z + 100
        local emitter = AddSpecialEffect("Abilities/Weapons/VengeanceMissile/VengeanceMissile.mdl", myPos.x, myPos.y)
        BlzSetSpecialEffectZ(emitter, myPos.z)
        BlzSetSpecialEffectScale(emitter, 3)
        local tarPos = Vector3.new(data.x, data.y)
        local dir = (tarPos - myPos):SetNormalize()
        local curr = myPos + dir
        local lightning = AddLightningEx("SPLK", false, myPos.x, myPos.y, myPos.z, curr.x, curr.y, curr:GetTerrainZ())
        SetLightningColor(lightning, 1, 0.5, 0.5, 1)
        local travelled = 0
        local i = 0
        local p1 = myPos:Clone()
        local casterPlayer = GetOwningPlayer(data.caster)

        local function run(value)
            curr = p1 + dir * value
            MoveLightningEx(lightning, false, myPos.x, myPos.y, myPos.z, curr.x, curr.y, curr:GetTerrainZ())
            ExAddSpecialEffect("Abilities/Weapons/FireBallMissile/FireBallMissile.mdl", curr.x, curr.y, 0.0)
            aoeDamage(data.caster, curr.x, curr.y, 20, damaged1)

            local currIndex = math.floor(value / 50)
            while i <= currIndex do
                local cx, cy = curr.x, curr.y
                local tm = Timer.new(function()
                    ExAddSpecialEffect("Abilities/Weapons/Mortar/MortarMissile.mdl", cx, cy, 0.0)
                    aoeDamage(data.caster, cx, cy, 80, damaged2)
                end, 0.7, 1)
                tm:Start()
                i = i + 1
            end
        end

        local tween = Tween.To(function()
            return travelled
        end, run, 2400, 2, Tween.Type.InQuint)
        local nearTargets = ExGroupGetUnitsInRange(myPos.x, myPos.y, 300)
        table.iFilterInPlace(nearTargets, function(item)
            if ExIsUnitDead(item) then
                return false
            end
            if IsUnitAlly(item, casterPlayer) then
                return false
            end
            if IsUnit(item, data.caster) then
                return false
            end
            return true
        end)
        if #nearTargets > 0 then
            local firstTarget = table.iGetRandom(nearTargets)
            tween:AppendCallback(function()
                travelled = 0
                p1 = curr:Clone()
                dir = (Vector3.FromUnit(firstTarget) - p1):SetNormalize()
                damaged1 = {}
                damaged2 = {}
                i = 0
            end)
            tween = tween:Append(Tween.To(function()
                return travelled
            end, run, 2400, 2, Tween.Type.InQuint, true))
        end
        tween:AppendCallback(function()
            DestroyEffect(emitter)
            DestroyLightning(lightning)
        end)
    end
})

return cls
