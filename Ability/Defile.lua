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
    AOEGrowth = 32, -- max = 256 + 32*10 = 576
    DamageGrowth = 0.1,
    Damage = { 5, 10, 15 },
    CleaveTargets = { 2, 4, 6 },
    FesteringWoundStackPerProc = 1,
}

BlzSetAbilityResearchTooltip(Abilities.Defile.ID, "学习亵渎 - [|cffffcc00%d级|r]", 0)
BlzSetAbilityResearchExtendedTooltip(Abilities.Defile.ID, string.format([[亵渎死亡骑士指定的一片土地，每秒对所有敌人造成伤害并叠加一层溃烂之伤，持续|cffff8c00%s|r秒。当你站在自己的亵渎范围内时，你的普通攻击会击中目标附近的其他敌人。如果有任意敌人站在被亵渎的土地上，亵渎面积会扩大，伤害每秒都会提高|cffff8c00%s%%|r。

|cff99ccff施法距离|r - 600
|cff99ccff影响范围|r - 250-550
|cff99ccff法力消耗|r - 30点
|cff99ccff冷却时间|r - 10秒

|cffffcc001级|r - 每秒造成|cffff8c00%s|r点伤害，击中|cffff8c00%s|r个敌人。
|cffffcc002级|r - 每秒造成|cffff8c00%s|r点伤害，击中|cffff8c00%s|r个敌人。
|cffffcc003级|r - 每秒造成|cffff8c00%s|r点伤害，击中|cffff8c00%s|r个敌人。]],
        Abilities.Defile.Duration, math.round(Abilities.Defile.DamageGrowth * 100),
        Abilities.Defile.Damage[1], Abilities.Defile.CleaveTargets[1],
        Abilities.Defile.Damage[2], Abilities.Defile.CleaveTargets[2],
        Abilities.Defile.Damage[3], Abilities.Defile.CleaveTargets[3]
), 0)

for i = 1, #Abilities.Defile.Damage do
    BlzSetAbilityTooltip(Abilities.Defile.ID, string.format("亵渎 - [|cffffcc00%s级|r]", i), i - 1)
    BlzSetAbilityExtendedTooltip(Abilities.Defile.ID, string.format([[亵渎死亡骑士指定的一片土地，每秒对所有敌人造成|cffff8c00%s|r点伤害并叠加一层溃烂之伤，持续|cffff8c00%s|r秒。当你站在自己的亵渎范围内时，你的普通攻击会击中目标附近的|cffff8c00%s|r个敌人。如果有任意敌人站在被亵渎的土地上，亵渎面积会扩大，伤害每秒都会提高|cffff8c00%s%%|r。

|cff99ccff施法距离|r - 600
|cff99ccff影响范围|r - 250-550
|cff99ccff法力消耗|r - 30点
|cff99ccff冷却时间|r - 10秒]],
            Abilities.Defile.Damage[i], Abilities.Defile.Duration, Abilities.Defile.CleaveTargets[i], math.round(Abilities.Defile.DamageGrowth * 100)), i - 1)
end

--endregion

local cls = class("Defile")

cls.instances = {}

-- test
-- 32 ~ 0.3  416/4.5
--local ringR = 256
--local cacheRing = {}
--local function renderRing()
--    for i, v in ipairs(cacheRing) do
--        DestroyEffect(v)
--    end
--
--    cacheRing = {}
--    for i = 1, 36 do
--        local x = math.cos(i * 10 * bj_DEGTORAD) * ringR
--        local y = math.sin(i * 10 * bj_DEGTORAD) * ringR
--        local eff = AddSpecialEffect("Doodads/Cinematic/GlowingRunes/GlowingRunes2.mdl", x, y)
--        table.insert(cacheRing, eff)
--    end
--end
--renderRing()
--
--local scale = 3
--local aura = AddSpecialEffect("Abilities/Spells/Undead/UnholyAura/UnholyAura.mdl", 0, 0)
--
--local trigger = CreateTrigger()
--TriggerRegisterPlayerChatEvent(trigger, Player(0), "", false)
--ExTriggerAddAction(trigger, function()
--    local msg = GetEventPlayerChatString()
--    if msg == "q" then
--        ringR = ringR - 32
--        print("Ring radius is ", ringR)
--        renderRing()
--    elseif msg == "w" then
--        ringR = ringR + 32
--        print("Ring radius is ", ringR)
--        renderRing()
--    elseif msg == "a" then
--        scale = scale - 0.3
--        print("Aura scale is ", scale)
--        BlzSetSpecialEffectScale(aura, scale)
--    elseif msg == "s" then
--        scale = scale + 0.3
--        print("Aura scale is ", scale)
--        BlzSetSpecialEffectScale(aura, scale)
--    end
--end)

local function radius2scale(r)
    return (r - 256) / 32 * 0.3 + 3
end

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Abilities.Defile.ID,
    ---@param data ISpellData
    handler = function(data)
        local circle = Circle.new(Vector2.new(data.x, data.y), Abilities.Defile.AOE)
        print("caster is", data.caster)
        local tab = table.getOrCreateTable(cls.instances, data.caster)
        table.insert(tab, circle)
        local casterPlayer = GetOwningPlayer(data.caster)
        local level = GetUnitAbilityLevel(data.caster, Abilities.Defile.ID)
        local bonus = 0

        local aura = AddSpecialEffect("Abilities/Spells/Undead/UnholyAura/UnholyAura.mdl", circle.center.x, circle.center.y)
        BlzSetSpecialEffectScale(aura, radius2scale(circle.r))
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
                    print("defile did damage", damage)
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

            --circle = circle:Clone()
            circle.r = newR
            --table.insert(tab, circle)
            BlzSetSpecialEffectScale(aura, radius2scale(circle.r))
        end, Abilities.Defile.Interval, Abilities.Defile.Duration)
        timer:Start()

        timer.onStop = function()
            -- 移除黑水效果
            for i, v in ipairs(tab) do
                tab[i] = nil
                --cls.RestoreTerrain(v)
            end
            BlzSetSpecialEffectColor(aura, 0, 0, 0)
            DestroyEffect(aura)
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
