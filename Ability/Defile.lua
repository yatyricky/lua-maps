-- 亵渎

local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local BuffBase = require("Objects.BuffBase")
local ProjectileBase = require("Objects.ProjectileBase")
local FesteringWound = require("Ability.FesteringWound")
local Timer = require("Lib.Timer")
local Circle = require("Lib.Circle")
local Vector2 = require("Lib.Vector2")

--region meta

Abilities.Defile = {
    ID = FourCC("A008"),
    Interval = 1,
    Duration = 10,
    AOE = 256,
    AOEGrowth = 32,
    DamageGrowth = 0.1,
    Damage = { 5, 10, 15 },
    CleaveTargets = { 2, 4, 6 },
    FesteringWoundStackPerProc = 1,
}

--BlzSetAbilityResearchTooltip(Abilities.DeathCoil.ID, "学习死亡之握 - [|cffffcc00%d级|r]", 0)
--BlzSetAbilityResearchExtendedTooltip(Abilities.DeathCoil.ID, string.format([[运用笼罩万物的邪恶能量，将目标拉到死亡骑士面前来，并让其无法移动，并根据目标身上的瘟疫数量，延长持续时间。
--
--|cffffcc001级|r - 持续%s秒，英雄%s秒，每个瘟疫延长%s%%。
--|cffffcc002级|r - 持续%s秒，英雄%s秒，每个瘟疫延长%s%%。
--|cffffcc003级|r - 持续%s秒，英雄%s秒，每个瘟疫延长%s%%。]],
--        Abilities.DeathCoil.Duration[1], Abilities.DeathCoil.DurationHero[1], math.round(Abilities.DeathCoil.PlagueLengthen[1] * 100),
--        Abilities.DeathCoil.Duration[2], Abilities.DeathCoil.DurationHero[2], math.round(Abilities.DeathCoil.PlagueLengthen[2] * 100),
--        Abilities.DeathCoil.Duration[3], Abilities.DeathCoil.DurationHero[3], math.round(Abilities.DeathCoil.PlagueLengthen[3] * 100)
--), 0)
--
--for i = 1, #Abilities.DeathCoil.Duration do
--    BlzSetAbilityTooltip(Abilities.DeathCoil.ID, string.format("死亡之握 - [|cffffcc00%s级|r]", i), i - 1)
--    BlzSetAbilityExtendedTooltip(Abilities.DeathCoil.ID, string.format("运用笼罩万物的邪恶能量，将目标拉到死亡骑士面前来，并让其无法移动，持续%s秒，英雄%s秒，目标身上的每个瘟疫可以延长%s%%的持续时间。", Abilities.DeathCoil.Duration[i], Abilities.DeathCoil.DurationHero[i], math.round(Abilities.DeathCoil.PlagueLengthen[i] * 100)), i - 1)
--end

--endregion

local cls = class("Defile")

function cls.ModifyTerrain(circle)
    --print("Make blight @", circle:tostring())
end

function cls.RestoreTerrain(circle)
    --print("Remove blight @", circle:tostring())
end

cls.instances = {}

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Abilities.Defile.ID,
    ---@param data ISpellData
    handler = function(data)
        local circle = Circle.new(Vector2.new(data.x, data.y), Abilities.Defile.AOE)
        print("caster is", data.caster)
        local tab = table.getOrCreateTable(cls.instances, data.caster)
        table.insert(tab, circle)
        cls.ModifyTerrain(circle)
        local casterPlayer = GetOwningPlayer(data.caster)
        local level = GetUnitAbilityLevel(data.caster, Abilities.Defile.ID)
        local bonus = 0

        local timer = Timer.new(function()
            local hasAnyUnit = false
            ExGroupEnumUnitsInRange(data.x, data.y, circle.r, function(e)
                if IsUnitEnemy(e, casterPlayer) and not IsUnitType(e, UNIT_TYPE_STRUCTURE) and not IsUnitType(e, UNIT_TYPE_MECHANICAL) and not ExIsUnitDead(e) then
                    hasAnyUnit = true
                    -- 并叠加溃烂之伤
                    local debuff = BuffBase.FindBuffByClassName(e, FesteringWound.__cname)
                    if debuff then
                        debuff:IncreaseStack(Abilities.Defile.FesteringWoundStackPerProc)
                    else
                        debuff = FesteringWound.new(data.caster, e, Abilities.FesteringWound.Duration, 9999, {})
                    end

                    -- 造成伤害
                    local damage = Abilities.Defile.Damage[level] * (1 + bonus)
                    UnitDamageTarget(data.caster, e, damage, false, true, ATTACK_TYPE_HERO, DAMAGE_TYPE_MAGIC, WEAPON_TYPE_WHOKNOWS)
                end
            end)

            local newR = circle.r
            -- 如果有任意敌人站在被亵渎的土地上
            -- 亵渎面积会扩大，伤害每秒都会提高
            if hasAnyUnit then
                newR = newR + Abilities.Defile.AOEGrowth
                bonus = bonus + Abilities.Defile.DamageGrowth
            end

            circle = circle:Clone()
            circle.r = newR
            table.insert(tab, circle)
            cls.ModifyTerrain(circle)
        end, Abilities.Defile.Interval, Abilities.Defile.Duration)
        timer:Start()

        timer.onStop = function()
            -- 移除黑水效果
            for _, v in ipairs(tab) do
                cls.RestoreTerrain(v)
            end
        end
    end
})

-- 当你站在自己的亵渎范围内时，你的普通攻击会击中目标附近的其他敌人
EventCenter.RegisterPlayerUnitDamaged:Emit(function(caster, target, damage, weaponType, damageType, isAttack)
    if not isAttack then
        return
    end

    if target == nil then
        return
    end

    -- 检查是否站在亵渎里面
    local tab = table.getOrCreateTable(cls.instances, caster)
    local standingOnDefiledGround = false
    local vec = Vector2.FromUnit(caster)
    local circle
    for i = #tab, 1, -1 do
        circle = tab[i]
        if circle:Contains(vec) then
            standingOnDefiledGround = true
            break
        end
    end

    if not standingOnDefiledGround then
        return
    end

    local candidates = {}
    local targetPlayer = GetOwningPlayer(target)
    local v1 = Vector2.FromUnit(target)
    local v2 = Vector2.new(0, 0)
    ExGroupEnumUnitsInRange(GetUnitX(target), GetUnitY(target), circle.r, function(e)
        if not IsUnit(e, target) and IsUnitAlly(e, targetPlayer) and not ExIsUnitDead(e) then
            v2:MoveToUnit(e):Sub(v1)
            table.insert(candidates, { unit = e, dist = v2:GetMagnitude() })
        end
    end)
    table.sort(candidates, function(a, b)
        return a.dist < b.dist
    end)

    local level = GetUnitAbilityLevel(caster, Abilities.Defile.ID)
    local victims = table.slice(candidates, 1, Abilities.Defile.CleaveTargets[level])
    for _, v in ipairs(victims) do
        UnitDamageTarget(caster, v.unit, damage, false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_DIVINE, WEAPON_TYPE_WHOKNOWS)
    end
end)

return cls
