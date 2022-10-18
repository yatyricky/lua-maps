--lua-bundler:000059394
local function RunBundle()
local __modules = {}
local require = function(path)
    local module = __modules[path]
    if module == nil then
        local dotPath = string.gsub(path, "/", "%.")
        module = __modules[dotPath]
        __modules[path] = module
    end
    if module ~= nil then
        if not module.inited then
            module.cached = module.loader()
            module.inited = true
        end
        return module.cached
    else
        error("module not found " .. path)
        return nil
    end
end

__modules["Ability.ArmyOfTheDead"]={loader=function()
local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local Vector2 = require("Lib.Vector2")
local Timer = require("Lib.Timer")

--region meta

Abilities.ArmyOfTheDead = {
    ID = FourCC("A003")
}

BlzSetAbilityResearchTooltip(Abilities.ArmyOfTheDead.ID, "学习亡者大军 - [|cffffcc00%d级|r]", 0)
BlzSetAbilityResearchExtendedTooltip(Abilities.ArmyOfTheDead.ID, string.format([[召唤一支食尸鬼军团为你作战。食尸鬼会在你附近的区域横冲直撞，攻击一切它们可以攻击的目标。

|cffffcc001级|r - 召唤6个食尸鬼，每个具有660点生命值。]]
), 0)

for i = 1, 1 do
    BlzSetAbilityTooltip(Abilities.ArmyOfTheDead.ID, string.format("亡者大军 - [|cffffcc00%s级|r]", i), i - 1)
    BlzSetAbilityExtendedTooltip(Abilities.ArmyOfTheDead.ID, string.format("召唤一支食尸鬼军团为你作战。食尸鬼会在你附近的区域横冲直撞，攻击一切它们可以攻击的目标。召唤6个食尸鬼，每个具有660点生命值。"), i - 1)
end

--endregion

local instances = {} ---@type table<unit, ArmyOfTheDead>

local LesserColor = { r = 0.2, g = 0, b = 0.4, a = 1 }
local GreaterColor = { r = 0.6, g = 0.15, b = 0.4, a = 1 }

---@class ArmyOfTheDead
local cls = class("ArmyOfTheDead")

function cls:ctor(caster)
    local casterPos = Vector2.FromUnit(caster)
    self.sfxTimer = Timer.new(function()
        local pos = (Vector2.InsideUnitCircle() * math.random(200, 600)):Add(casterPos)
        ExAddLightningPosPos("CLSB", casterPos.x, casterPos.y, 200, pos.x, pos.y, 0, math.random() * 0.4 + 0.2, LesserColor)
        ExAddSpecialEffect("Abilities/Spells/Undead/DeathandDecay/DeathandDecayTarget.mdl", pos.x, pos.y, 0.2)
    end, 0.2, -1)
    self.sfxTimer:Start()

    local player = GetOwningPlayer(caster)
    self.summonTimer = Timer.new(function()
        local pos = (Vector2.InsideUnitCircle() * math.random(200, 600)):Add(casterPos)
        local summoned = CreateUnit(player, FourCC("u000"), pos.x, pos.y, math.random(360))
        ExAddLightningPosUnit("CLPB", casterPos.x, casterPos.y, 200, summoned, 1, GreaterColor)
        ExAddSpecialEffectTarget("Abilities/Spells/Undead/AnimateDead/AnimateDeadTarget.mdl", summoned, "origin", 0.1)
        UnitApplyTimedLife(summoned, FourCC("BUan"), 40)
    end, 1, -1)
    self.summonTimer:Start()
end

function cls:Stop()
    self.sfxTimer:Stop()
    self.summonTimer:Stop()
end

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Abilities.ArmyOfTheDead.ID,
    ---@param data ISpellData
    handler = function(data)
        instances[data.caster] = cls.new(data.caster, GetUnitAbilityLevel(data.caster, data.abilityId))
    end
})

EventCenter.RegisterPlayerUnitSpellEndCast:Emit({
    id = Abilities.ArmyOfTheDead.ID,
    ---@param data ISpellData
    handler = function(data)
        local inst = instances[data.caster]
        if inst then
            inst:Stop()
            instances[data.caster] = nil
        else
            print("army of the dead end but no instance")
        end
    end
})

return cls

end}

__modules["Ability.BloodPlague"]={loader=function()
local EventCenter = require("Lib.EventCenter")
local BuffBase = require("Buff.BuffBase")
local Abilities = require("Config.Abilities")
local Timer = require("Lib.Timer")

---@class BloodPlague : BuffBase
local cls = class("BloodPlague", BuffBase)

function cls:Awake()
    self.level = self.awakeData.level
end

EventCenter.RegisterPlayerUnitDamaged:Emit(function(caster, target, _, _, _, isAttack)
    if not isAttack then
        return
    end

    local debuff = BuffBase.FindBuffByClassName(target, "BloodPlague")
    if not debuff then
        return
    end

    local maxHp = GetUnitState(target, UNIT_STATE_MAX_LIFE)
    local damage = maxHp * Abilities.PlagueStrike.BloodPlagueData[debuff.level]

    UnitDamageTarget(caster, target, damage, false, true, ATTACK_TYPE_MAGIC, DAMAGE_TYPE_POISON, WEAPON_TYPE_WHOKNOWS)

    local impact = AddSpecialEffectTarget("Objects/Spawnmodels/Human/HumanBlood/HeroBloodElfBlood.mdl", target, "origin")
    local impactTimer = Timer.new(function()
        DestroyEffect(impact)
    end, 2, 1)
    impactTimer:Start()
end)

return cls

end}

__modules["Ability.DeathGrip"]={loader=function()
local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local Const = require("Config.Const")
local Vector2 = require("Lib.Vector2")
local Utils = require("Lib.Utils")
local BuffBase = require("Buff.BuffBase")
local Timer = require("Lib.Timer")

--region meta

Abilities.DeathGrip = {
    ID = FourCC("A000"),
    Duration = { 4, 5, 6 },
    DurationHero = { 2, 3, 4 },
}

BlzSetAbilityResearchTooltip(Abilities.DeathGrip.ID, "学习死亡之握 - [|cffffcc00%d级|r]", 0)
BlzSetAbilityResearchExtendedTooltip(Abilities.DeathGrip.ID, string.format([[运用笼罩万物的邪恶能量，将目标拉到死亡骑士面前来，并让其无法移动。

|cffffcc001级|r - 持续%s秒，英雄%s秒。
|cffffcc002级|r - 持续%s秒，英雄%s秒。
|cffffcc003级|r - 持续%s秒，英雄%s秒。]],
        Abilities.DeathGrip.Duration[1], Abilities.DeathGrip.DurationHero[1],
        Abilities.DeathGrip.Duration[2], Abilities.DeathGrip.DurationHero[2],
        Abilities.DeathGrip.Duration[3], Abilities.DeathGrip.DurationHero[3]
), 0)

for i = 1, #Abilities.DeathGrip.Duration do
    BlzSetAbilityTooltip(Abilities.DeathGrip.ID, string.format("死亡之握 - [|cffffcc00%s级|r]", i), i - 1)
    BlzSetAbilityExtendedTooltip(Abilities.DeathGrip.ID, string.format("运用笼罩万物的邪恶能量，将目标拉到死亡骑士面前来，并让其无法移动，持续%s秒，英雄%s秒。", Abilities.DeathGrip.Duration[i], Abilities.DeathGrip.DurationHero[i]), i - 1)
end

--endregion

--region slow debuff

---@class SlowDebuff : BuffBase
local SlowDebuff = class("SlowDebuff", BuffBase)

function SlowDebuff:ctor(caster, target, duration, interval)
    SlowDebuff.super.ctor(self, caster, target, duration, interval)
end

function SlowDebuff:OnEnable()
    SetUnitMoveSpeed(self.target, 0)
end

function SlowDebuff:OnDisable()
    SetUnitMoveSpeed(self.target, GetUnitDefaultMoveSpeed(self.target))
end

--endregion

local StepLen = 16

local cls = class("DeathGrip")

function cls:ctor(caster, target)
    IssueImmediateOrderById(target, Const.OrderId_Stop)
    PauseUnit(target, true)

    local v1 = Vector2.FromUnit(caster)
    local v2 = Vector2.FromUnit(target)
    local norm = v2 - v1
    local totalLen = norm:GetMagnitude()
    norm:SetNormalize()
    local travelled = 0
    local dest = (norm * 96):Add(v1)
    totalLen = totalLen - 96
    Utils.SetUnitFlyable(target)
    local originalHeight = GetUnitFlyHeight(target)
    local lightning = AddLightningEx("SPLK", false,
            v2.x, v2.y, BlzGetUnitZ(target) + originalHeight,
            v1.x, v1.y, 0)
    SetUnitPathing(target, false)
    SetLightningColor(lightning, 0.5, 0, 0.5, 1)

    local sfxPos = (norm * 150):Add(v1)
    local sfx = AddSpecialEffect("Abilities/Spells/Undead/UndeadMine/UndeadMineCircle.mdl", sfxPos.x, sfxPos.y)
    BlzSetSpecialEffectScale(sfx, 1.3)
    BlzSetSpecialEffectColor(sfx, 128, 0, 128)
    BlzSetSpecialEffectYaw(sfx, math.atan2(norm.y, norm.x))

    coroutine.start(function()
        while true do
            coroutine.step()
            v2:MoveToUnit(target)
            local dir = dest - v2
            dir:SetLength(StepLen):Add(v2):UnitMoveTo(target)
            travelled = travelled + StepLen
            local height = math.bezier3(math.clamp01(travelled / totalLen), 0, totalLen, 0)
            SetUnitFlyHeight(target, height, 0)
            MoveLightningEx(lightning, false,
                    dir.x, dir.y, BlzGetUnitZ(target) + GetUnitFlyHeight(target),
                    dest.x, dest.y, 0)
            if dir:Sub(dest):GetMagnitude() < 96 then
                break
            end
        end

        DestroyLightning(lightning)
        SetUnitFlyHeight(target, originalHeight, 0)
        PauseUnit(target, false)
        SetUnitPathing(target, true)

        local impact = AddSpecialEffectTarget("Abilities/Spells/Undead/DeathCoil/DeathCoilSpecialArt.mdl", target, "origin")
        local impactTimer = Timer.new(function()
            DestroyEffect(impact)
        end, 2, 1)
        impactTimer:Start()

        local duration = IsUnitType(target, UNIT_TYPE_HERO) and 2 or 4
        SlowDebuff.new(caster, target, duration, 999)

        coroutine.wait(duration - 1)
        DestroyEffect(sfx)
    end)
end

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Abilities.DeathGrip.ID,
    ---@param data ISpellData
    handler = function(data)
        cls.new(data.caster, data.target)
    end
})

return cls

end}

__modules["Ability.DeathStrike"]={loader=function()
local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local BuffBase = require("Buff.BuffBase")
local Timer = require("Lib.Timer")
local BloodPlague = require("Ability.BloodPlague")
local FrostPlague = require("Ability.FrostPlague")
local UnholyPlague = require("Ability.UnholyPlague")

--region meta

Abilities.DeathStrike = {
    ID = FourCC("A001"),
    Damage = { 80, 120, 160 },
    Heal = { 0.08, 0.12, 0.16 },
    AOE = { 400, 500, 600 },
}

BlzSetAbilityResearchTooltip(Abilities.DeathStrike.ID, "学习灵界打击 - [|cffffcc00%d级|r]", 0)
BlzSetAbilityResearchExtendedTooltip(Abilities.DeathStrike.ID, string.format([[致命的攻击，对目标造成一次伤害，并根据目标身上的疾病数量，每有一个便为死亡骑士恢复他最大生命值百分比的效果，并且会将目标身上的所有疾病传染给附近所有敌人。

|cffffcc001级|r - 造成%s点伤害，每个疾病恢复%s%%最大生命值，%s传染范围。
|cffffcc002级|r - 造成%s点伤害，每个疾病恢复%s%%最大生命值，%s传染范围。
|cffffcc003级|r - 造成%s点伤害，每个疾病恢复%s%%最大生命值，%s传染范围。]],
        Abilities.DeathStrike.Damage[1], math.round(Abilities.DeathStrike.Heal[1] * 100), Abilities.DeathStrike.AOE[1],
        Abilities.DeathStrike.Damage[2], math.round(Abilities.DeathStrike.Heal[2] * 100), Abilities.DeathStrike.AOE[2],
        Abilities.DeathStrike.Damage[3], math.round(Abilities.DeathStrike.Heal[3] * 100), Abilities.DeathStrike.AOE[3]
), 0)

for i = 1, #Abilities.DeathStrike.Damage do
    BlzSetAbilityTooltip(Abilities.DeathStrike.ID, string.format("灵界打击 - [|cffffcc00%s级|r]", i), i - 1)
    BlzSetAbilityExtendedTooltip(Abilities.DeathStrike.ID, string.format("致命的攻击，对目标造成%s点伤害，并根据目标身上的疾病数量，每有一个便为死亡骑士恢复他最大生命值的%s%%，并且会将目标身上的所有疾病传染给附近%s范围内所有敌人。", Abilities.DeathStrike.Damage[i], math.round(Abilities.DeathStrike.Heal[i] * 100), Abilities.DeathStrike.AOE[i]), i - 1)
end

--endregion

local cls = class("DeathStrike")

cls.Plagues = {
    BloodPlague,
    FrostPlague,
    UnholyPlague,
}

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Abilities.DeathStrike.ID,
    ---@param data ISpellData
    handler = function(data)
        local count = 0
        local existingPlagues = {} ---@type BuffBase[]
        for _, plagueDefine in ipairs(cls.Plagues) do
            local debuff = BuffBase.FindBuffByClassName(data.target, plagueDefine.__cname)
            if debuff then
                table.insert(existingPlagues, debuff)
                count = count + 1
            end
        end

        -- damage
        local level = GetUnitAbilityLevel(data.caster, data.abilityId)
        UnitDamageTarget(data.caster, data.target, Abilities.DeathStrike.Damage[level], false, true, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_METAL_HEAVY_SLICE)

        -- spread
        if table.any(existingPlagues) then
            local color = { r = 0.1, g = 0.7, b = 0.1, a = 1 }
            local targetPlayer = GetOwningPlayer(data.target)
            ExGroupEnumUnitsInRange(GetUnitX(data.target), GetUnitY(data.target), Abilities.DeathStrike.AOE[level], function(e)
                if not IsUnit(e, data.target) and IsUnitAlly(e, targetPlayer) and not IsUnitType(e, UNIT_TYPE_STRUCTURE) and not IsUnitType(e, UNIT_TYPE_MECHANICAL) and not IsUnitDeadBJ(e) then
                    ExAddLightningUnitUnit("SPLK", data.target, e, 0.3, color, false)

                    for _, debuff in ipairs(existingPlagues) do
                        local current = BuffBase.FindBuffByClassName(e, debuff.__cname)
                        if current then
                            current.level = debuff.level
                            if current.__cname ~= "FrostPlague" then
                                current.duration = math.max(debuff.duration, current.duration)
                            end
                        else
                            debuff.class.new(debuff.caster, e, debuff:GetTimeLeft(), debuff.interval, debuff.awakeData)
                        end
                    end
                end
            end)
        end

        -- heal
        if count > 0 then
            EventCenter.Heal:Emit({
                caster = data.caster,
                target = data.caster,
                amount = Abilities.DeathStrike.Heal[level] * count * GetUnitState(data.caster, UNIT_STATE_MAX_LIFE),
            })

            local healEffect = AddSpecialEffectTarget("Abilities/Spells/Items/AIhe/AIheTarget.mdl", data.caster, "origin")
            local healEffectTimer = Timer.new(function()
                DestroyEffect(healEffect)
            end, 2, 1)
            healEffectTimer:Start()
        end

        local impact = AddSpecialEffectTarget("Objects/Spawnmodels/Human/HumanBlood/HeroBloodElfBlood.mdl", data.target, "origin")
        local impactTimer = Timer.new(function()
            DestroyEffect(impact)
        end, 2, 1)
        impactTimer:Start()
    end
})

return cls

end}

__modules["Ability.FrostPlague"]={loader=function()
local BuffBase = require("Buff.BuffBase")
local Abilities = require("Config.Abilities")
local Time = require("Lib.Time")

---@class FrostPlague : BuffBase
local cls = class("FrostPlague", BuffBase)

function cls:Awake()
    self.level = self.awakeData.level
end

function cls:OnEnable()
    ExAddSpecialEffectTarget("Abilities/Spells/Undead/FrostArmor/FrostArmorDamage.mdl", self.target, "origin", Time.Delta)
end

function cls:Update()
    ExAddSpecialEffectTarget("Abilities/Spells/Undead/FrostArmor/FrostArmorDamage.mdl", self.target, "origin", Time.Delta)
end

function cls:OnDisable()
    local speedLossPercent = math.clamp01(1 - GetUnitMoveSpeed(self.target) / 500)
    local damage = Abilities.PlagueStrike.FrostPlagueData[self.level] * (1 + speedLossPercent)
    UnitDamageTarget(self.caster, self.target, damage, false, true, ATTACK_TYPE_MAGIC, DAMAGE_TYPE_POISON, WEAPON_TYPE_WHOKNOWS)

    ExAddSpecialEffectTarget("Abilities/Weapons/ZigguratMissile/ZigguratMissile.mdl", self.target, "origin", Time.Delta)
end

return cls

end}

__modules["Ability.PlagueStrike"]={loader=function()
local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local BuffBase = require("Buff.BuffBase")
local BloodPlague = require("Ability.BloodPlague")
local FrostPlague = require("Ability.FrostPlague")
local UnholyPlague = require("Ability.UnholyPlague")

--region meta

Abilities.PlagueStrike = {
    ID = FourCC("A002"),
    BloodPlagueDuration = { 12, 12, 12 },
    BloodPlagueData = { 0.005, 0.01, 0.015 },
    FrostPlagueDuration = { 6, 6, 6 },
    FrostPlagueData = { 30, 45, 60 },
    UnholyPlagueDuration = { 10, 10, 10 },
    UnholyPlagueInterval = { 2, 2, 2 },
    UnholyPlagueData = { 6, 11, 16 },
}

BlzSetAbilityResearchTooltip(Abilities.PlagueStrike.ID, "学习瘟疫打击 - [|cffffcc00%d级|r]", 0)
BlzSetAbilityResearchExtendedTooltip(Abilities.PlagueStrike.ID, string.format([[每次攻击都会依次给敌人造成鲜血疾病、冰霜疾病、邪恶疾病的效果。
鲜血疾病：目标受到攻击时，受到最大生命值百分比伤害。
冰霜疾病：一段时间后，受到一次冰霜伤害，目标移动速度越低，受到伤害越高。
邪恶疾病：受到持续的伤害，生命值越低，受到伤害越高。

|cffffcc001级|r - 鲜血疾病持续%s秒，造成最大生命%s%%的伤害；冰霜疾病持续%s秒，造成%s伤害；邪恶疾病持续%s秒，没%s秒造成%s伤害。
|cffffcc002级|r - 鲜血疾病持续%s秒，造成最大生命%s%%的伤害；冰霜疾病持续%s秒，造成%s伤害；邪恶疾病持续%s秒，没%s秒造成%s伤害。
|cffffcc003级|r - 鲜血疾病持续%s秒，造成最大生命%s%%的伤害；冰霜疾病持续%s秒，造成%s伤害；邪恶疾病持续%s秒，没%s秒造成%s伤害。]],
        Abilities.PlagueStrike.BloodPlagueDuration[1], (Abilities.PlagueStrike.BloodPlagueData[1] * 100), Abilities.PlagueStrike.FrostPlagueDuration[1], Abilities.PlagueStrike.FrostPlagueData[1], Abilities.PlagueStrike.UnholyPlagueDuration[1], Abilities.PlagueStrike.UnholyPlagueInterval[1], Abilities.PlagueStrike.UnholyPlagueData[1],
        Abilities.PlagueStrike.BloodPlagueDuration[2], (Abilities.PlagueStrike.BloodPlagueData[2] * 100), Abilities.PlagueStrike.FrostPlagueDuration[2], Abilities.PlagueStrike.FrostPlagueData[2], Abilities.PlagueStrike.UnholyPlagueDuration[2], Abilities.PlagueStrike.UnholyPlagueInterval[2], Abilities.PlagueStrike.UnholyPlagueData[2],
        Abilities.PlagueStrike.BloodPlagueDuration[3], (Abilities.PlagueStrike.BloodPlagueData[3] * 100), Abilities.PlagueStrike.FrostPlagueDuration[3], Abilities.PlagueStrike.FrostPlagueData[3], Abilities.PlagueStrike.UnholyPlagueDuration[3], Abilities.PlagueStrike.UnholyPlagueInterval[3], Abilities.PlagueStrike.UnholyPlagueData[3]
), 0)

for i = 1, #Abilities.PlagueStrike.BloodPlagueDuration do
    BlzSetAbilityTooltip(Abilities.PlagueStrike.ID, string.format("瘟疫打击 - [|cffffcc00%s级|r]", i), i - 1)
    BlzSetAbilityExtendedTooltip(Abilities.PlagueStrike.ID, string.format("每次攻击都会依次给敌人造成鲜血疾病、冰霜疾病、邪恶疾病的效果。鲜血疾病：持续%s秒，目标受到攻击时，受到最大生命值%s%%的伤害。冰霜疾病：%s秒后，受到%s点冰霜伤害，目标移动速度越低，受到伤害越高。邪恶疾病：持续%s秒，每%s秒受到%s点伤害，生命值越低，受到伤害越高。", Abilities.PlagueStrike.BloodPlagueDuration[i], (Abilities.PlagueStrike.BloodPlagueData[i] * 100), Abilities.PlagueStrike.FrostPlagueDuration[i], Abilities.PlagueStrike.FrostPlagueData[i], Abilities.PlagueStrike.UnholyPlagueDuration[i], Abilities.PlagueStrike.UnholyPlagueInterval[i], Abilities.PlagueStrike.UnholyPlagueData[i]), i - 1)
end

--endregion

local cls = class("PlagueStrike")

function cls.applyBloodPlague(caster, target, level)
    return BloodPlague.new(caster, target, Abilities.PlagueStrike.BloodPlagueDuration[level], 999, { level = level })
end

function cls.applyFrostPlague(caster, target, level)
    return FrostPlague.new(caster, target, Abilities.PlagueStrike.FrostPlagueDuration[level], 1, { level = level })
end

function cls.applyUnholyPlague(caster, target, level)
    return UnholyPlague.new(caster, target, Abilities.PlagueStrike.UnholyPlagueDuration[level], Abilities.PlagueStrike.UnholyPlagueInterval[level], { level = level })
end

cls.Plagues = {
    { class = BloodPlague, invoker = cls.applyBloodPlague },
    { class = FrostPlague, invoker = cls.applyFrostPlague },
    { class = UnholyPlague, invoker = cls.applyUnholyPlague },
}

EventCenter.RegisterPlayerUnitDamaged:Emit(function(caster, target, _, _, _, isAttack)
    if not isAttack then
        return
    end

    if target == nil then
        return
    end

    local abilityLevel = GetUnitAbilityLevel(caster, Abilities.PlagueStrike.ID)
    if abilityLevel < 1 then
        return
    end

    local existingPlagues = {} ---@type BuffBase[]
    local missingDebuff
    for _, plagueDefine in ipairs(cls.Plagues) do
        local debuff = BuffBase.FindBuffByClassName(target, plagueDefine.class.__cname)
        if not debuff then
            missingDebuff = plagueDefine
            break
        else
            if debuff.class.__cname ~= FrostPlague.__cname then
                table.insert(existingPlagues, debuff)
            end
        end
    end

    if missingDebuff then
        missingDebuff.invoker(caster, target, abilityLevel)
    else
        ---@param a BuffBase
        ---@param b BuffBase
        table.sort(existingPlagues, function(a, b)
            local lta = a.level < abilityLevel
            local ltb = b.level < abilityLevel
            if lta ~= ltb then
                return lta
            end
            return a:GetTimeLeft() < b:GetTimeLeft()
        end)

        local first = existingPlagues[1]
        first.level = abilityLevel
        first:ResetDuration()
    end
end)

return cls

end}

__modules["Ability.UnholyPlague"]={loader=function()
local BuffBase = require("Buff.BuffBase")
local Abilities = require("Config.Abilities")

---@class UnholyPlague : BuffBase
local cls = class("UnholyPlague", BuffBase)

function cls:Awake()
    self.level = self.awakeData.level
end

function cls:OnEnable()
    self.sfx = AddSpecialEffectTarget("Units/Undead/PlagueCloud/PlagueCloudtarget.mdl", self.target, "overhead")
end

function cls:Update()
    local hpLossPercent = 1 - GetUnitState(self.target, UNIT_STATE_LIFE) / GetUnitState(self.target, UNIT_STATE_MAX_LIFE)
    local damage = Abilities.PlagueStrike.UnholyPlagueData[self.level] * (1 + hpLossPercent)
    UnitDamageTarget(self.caster, self.target, damage, false, true, ATTACK_TYPE_MAGIC, DAMAGE_TYPE_POISON, WEAPON_TYPE_WHOKNOWS)
end

function cls:OnDisable()
    DestroyEffect(self.sfx)
end

return cls

end}

__modules["Buff.BuffBase"]={loader=function()
local EventCenter = require("Lib.EventCenter")
local Time = require("Lib.Time")

---@class BuffBase
local cls = class("BuffBase")

cls.unitBuffs = {} ---@type table<unit, BuffBase[]>

---@param unit unit
---@param name string
function cls.FindBuffByClassName(unit, name)
    local arr = cls.unitBuffs[unit]
    if not arr then
        return nil
    end

    return array.find(arr, function(_, v)
        return v.__cname == name
    end)
end

---@param caster unit
---@param target unit
---@param duration real
---@param interval real
function cls:ctor(caster, target, duration, interval, awakeData)
    self.caster = caster
    self.target = target
    self.time = Time.CeilToNextUpdate(Time.Time)
    self.expire = self.time + duration
    self.duration = duration
    self.interval = interval
    self.nextUpdate = self.time + interval

    local unitTab = table.getOrCreateTable(cls.unitBuffs, target)
    table.insert(unitTab, self)

    self.awakeData = awakeData
    EventCenter.NewBuff:Emit(self)
end

function cls:Awake()
end

function cls:OnEnable()
end

function cls:Update()
end

function cls:OnDisable()
end

function cls:OnDestroy()
    local unitTab = cls.unitBuffs[self.target]
    if not array.removeItem(unitTab, self) then
        print("Remove buff unit failed")
    end
end

function cls:ResetDuration(exprTime)
    exprTime = exprTime or (Time.Time + self.duration)
    self.expire = Time.CeilToNextUpdate(exprTime)
end

function cls:GetTimeLeft()
    return self.expire - self.time
end

function cls:GetTimeNorm()
    return math.clamp01(self:GetTimeLeft() / self.duration)
end

return cls

end}

__modules["Config.Abilities"]={loader=function()
local data = {}

local cls = setmetatable({}, {
    __index = function(t, k)
        return data[k]
    end,
    __newindex = function(t, k, v)
        if data[k] then
            print("Error: duplicate ability name:", k)
        else
            data[k] = v
        end
    end
})

return cls

end}

__modules["Config.Const"]={loader=function()
local cls = {}

cls.OrderId_Stop = 851972

return cls

end}

__modules["Lib.ArrayExt"]={loader=function()
local ipairs = ipairs

array = {}

array.add = table.insert

---@generic T
---@param tab T[]
---@param item T
function array.removeItem(tab, item)
    local c = #tab
    local i = 1
    local d = 0
    local removed = false
    while i <= c do
        local it = tab[i]
        if it == item then
            d = d + 1
            removed = true
        else
            if d > 0 then
                tab[i - d] = it
            end
        end
        i = i + 1
    end
    for j = 0, d - 1 do
        tab[c - j] = nil
    end
    return removed
end

---@generic V
---@param t V[]
---@param func fun(i: integer, v: V): boolean
---@return V, integer
function array.find(t, func)
    for i, v in ipairs(t) do
        if func(i, v) == true then
            return v, i
        end
    end
    return nil, nil
end

end}

__modules["Lib.class"]={loader=function()
require("Lib.clone")

function class(classname, super)
    local superType = type(super)
    local cls
    if superType ~= "function" and superType ~= "table" then
        superType = nil
        super = nil
    end
    if superType == "function" or (super and super.__ctype == 1) then
        cls = {}
        if superType == "table" then
            for k, v in pairs(super) do cls[k] = v end
            cls.__create = super.__create
            cls.super    = super
        else
            cls.__create = super
        end
        cls.ctor = function() end
        cls.__cname = classname
        cls.__ctype = 1
        function cls.new(...)
            local instance = cls.__create(...)
            for k, v in pairs(cls) do instance[k] = v end
            instance.class = cls
            instance:ctor(...)
            return instance
        end
    else
        if super then
            cls = clone(super)
            cls.super = super
        else
            cls = { ctor = function() end }
        end

        cls.__cname = classname
        cls.__ctype = 2
        cls.__index = cls
        function cls.new(...)
            local instance = setmetatable({}, cls)
            instance.class = cls
            instance:ctor(...)
            return instance
        end
    end
    return cls
end

end}

__modules["Lib.clone"]={loader=function()
---@generic T
---@param object T
---@return T
function clone(object)
    local lookup_table = {}
    local function _copy(obj)
        if type(obj) ~= "table" then
            return obj
        elseif lookup_table[obj] then
            return lookup_table[obj]
        end
        local new_table = {}
        lookup_table[obj] = new_table
        for key, value in pairs(obj) do
            new_table[_copy(key)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(obj))
    end
    return _copy(object)
end

end}

__modules["Lib.CoroutineExt"]={loader=function()
local Timer = require("Lib.Timer")
local FrameTimer = require("Lib.FrameTimer")

local c_create = coroutine.create
local c_running = coroutine.running
local c_resume = coroutine.resume
local c_yield = coroutine.yield
local t_pack = table.pack
local t_unpack = table.unpack
local print = print

local c2t = setmetatable({}, { __mode = "kv" })

function coroutine.start(f, ...)
    local c = c_create(f)
    local r = c_running()

    if r == nil then
        local success, msg = c_resume(c, ...)
        if not success then
            print(msg)
        end
    else
        local args = t_pack(...)
        local timer
        timer = FrameTimer.new(function()
            c2t[c] = nil
            local success, msg = c_resume(c, t_unpack(args))
            if not success then
                timer:Stop()
                print(msg)
            end
        end, 1, 1)
        c2t[c] = timer
        timer:Start()
    end

    return c
end

function coroutine.wait(t)
    local c = c_running()
    local timer

    local function action()
        c2t[c] = nil

        local success, msg = c_resume(c)
        if not success then
            timer:Stop()
            print(msg)
        end
    end

    timer = Timer.new(action, t, 1)
    c2t[c] = timer
    timer:Start()
    c_yield()
end

function coroutine.step(t)
    local c = c_running()
    local timer

    local function action()
        c2t[c] = nil

        local success, msg = c_resume(c)
        if not success then
            timer:Stop()
            print(msg)
        end
    end

    timer = FrameTimer.new(action, t or 1, 1)
    c2t[c] = timer
    timer:Start()
    c_yield()
end

function coroutine.stop(c)
    local timer = c2t[c]
    if timer ~= nil then
        c2t[c] = nil
        timer:Stop()
    end
end

end}

__modules["Lib.Event"]={loader=function()
require("Lib.class")

local t_insert = table.insert
local t_concat = table.concat
local s_format = string.format
local next = next
local pairs = pairs
local tostring = tostring

---@class Event
local cls = class("Event")

function cls:ctor()
    self._handlers = {}
end

---@generic T, E
---@param context T
---@param listener fun(context: T, data: E)
function cls:On(context, listener)
    local map = self._handlers[context]
    if map == nil then
        map = {}
        self._handlers[context] = map
    end
    map[listener] = 1
end

---@generic T, E
---@param context T
---@param listener fun(context: T, data: E)
function cls:Off(context, listener)
    local map = self._handlers[context]
    if map == nil then
        return
    end
    map[listener] = nil
    if next(map) == nil then
        self._handlers[context] = nil
    end
end

---@generic E
---@param data E
function cls:Emit(data)
    for context, map in pairs(self._handlers) do
        for listener, _ in pairs(map) do
            listener(context, data)
        end
    end
end

function cls:ToString()
    local sb = {}
    for context, map in pairs(self._handlers) do
        for listener, _ in pairs(map) do
            t_insert(sb, s_format("%s -> %s", tostring(context), tostring(listener)))
        end
    end
    return t_concat(sb, ",")
end

return cls

end}

__modules["Lib.EventCenter"]={loader=function()
local Event = require("Lib.Event")

local cls = {}

cls.FrameBegin = Event.new()
cls.FrameUpdate = Event.new()

function cls.Report()
    print("--- FrameBegin ---")
    print(cls.FrameBegin:ToString())
    print("--- FrameUpdate ---")
    print(cls.FrameUpdate:ToString())
end

return cls

end}

__modules["Lib.FrameTimer"]={loader=function()
local FrameUpdate = require("Lib.EventCenter").FrameUpdate

local pcall = pcall
local print = print

local cls = class("FrameTimer")

function cls:ctor(func, count, loops)
    self.func = func
    self.count = count
    self.loops = loops

    self.frames = count
    self.running = false
end

function cls:Start()
    if self.running then
        return
    end

    if self.loops == 0 then
        return
    end

    self.running = true
    FrameUpdate:On(self, cls._update)
end

function cls:Stop()
    if not self.running then
        return
    end

    self.running = false
    FrameUpdate:Off(self, cls._update)
end

function cls:_update(dt)
    if not self.running then
        return
    end

    self.frames = self.frames - 1
    if self.frames <= 0 then
        local s, m = pcall(self.func, dt)
        if not s then
            print(m)
        end

        if self.loops > 0 then
            self.loops = self.loops - 1
            if self.loops == 0 then
                self:Stop()
                return
            end
        end

        self.frames = self.frames + self.count
    end
end

return cls

end}

__modules["Lib.MathExt"]={loader=function()
function math.fuzzyEquals(a, b, precision)
    precision = precision or 0.000001
    return (a == b) or math.abs(a - b) < precision
end

---@param t real ratio 0-1
---@param c1 real
---@param c2 real
---@param c3 real
---@return real
function math.bezier3(t, c1, c2, c3)
    local t1 = 1 - t
    return c1 * t1 * t1 + c2 * 2 * t1 * t + c3 * t * t
end

function math.clamp(value, min, max)
    return math.min(math.max(min, value), max)
end

function math.clamp01(value)
    return math.clamp(value, 0, 1)
end

math.atan2 = Atan2

local m_floor = math.floor
local MathRound = MathRound

function math.round(value)
    return MathRound(value)
end

end}

__modules["Lib.native"]={loader=function()
local Time = require("Lib.Time")

local pcall = pcall
local c_start = coroutine.start
local c_wait = coroutine.wait
local c_step = coroutine.step
local m_round = math.round
local t_insert = table.insert

local TriggerAddAction = TriggerAddAction

---@param trigger trigger
---@param action fun(): void
---@return void
function ExTriggerAddAction(trigger, action)
    TriggerAddAction(trigger, function()
        local s, m = pcall(action)
        if not s then
            print(m)
        end
    end)
end

local GroupEnumUnitsInRange = GroupEnumUnitsInRange
local Filter = Filter
local GetFilterUnit = GetFilterUnit

local group = CreateGroup()

---@param x real
---@param y real
---@param radius real
---@param callback fun(unit: unit): void
---@return void
function ExGroupEnumUnitsInRange(x, y, radius, callback)
    GroupEnumUnitsInRange(group, x, y, radius, Filter(function()
        local s, m = pcall(callback, GetFilterUnit())
        if not s then
            print(m)
        end
        return false
    end))
end

local AddSpecialEffectTarget = AddSpecialEffectTarget
local AddSpecialEffect = AddSpecialEffect
local BlzSetSpecialEffectColor = BlzSetSpecialEffectColor
local DestroyEffect = DestroyEffect

function ExAddSpecialEffectTarget(modelName, target, attachPoint, duration)
    c_start(function()
        local sfx = AddSpecialEffectTarget(modelName, target, attachPoint)
        c_wait(duration)
        DestroyEffect(sfx)
    end)
end

function ExAddSpecialEffect(modelName, x, y, duration, color)
    c_start(function()
        local sfx = AddSpecialEffect(modelName, x, y)
        if color then
            BlzSetSpecialEffectColor(sfx, m_round(color.r * 255), m_round(color.g * 255), m_round(color.b * 255))
        end
        c_wait(duration)
        DestroyEffect(sfx)
    end)
end

local AddLightningEx = AddLightningEx
local SetLightningColor = SetLightningColor
local MoveLightningEx = MoveLightningEx
local DestroyLightning = DestroyLightning
local GetUnitX = GetUnitX
local GetUnitY = GetUnitY
local BlzGetUnitZ = BlzGetUnitZ
local GetUnitFlyHeight = GetUnitFlyHeight

function ExAddLightningPosPos(modelName, x1, y1, z1, x2, y2, z2, duration, color, check)
    c_start(function()
        local lightning = AddLightningEx(modelName, check or false, x1, y1, z1, x2, y2, z2)
        if color then
            SetLightningColor(lightning, color.r, color.g, color.b, color.a)
        end
        c_wait(duration)
        DestroyLightning(lightning)
    end)
end

function ExAddLightningUnitUnit(modelName, unit1, unit2, duration, color, checkVisibility)
    c_start(function()
        checkVisibility = checkVisibility or false
        local expr = Time.Time + duration
        local lightning = AddLightningEx(modelName, checkVisibility,
                GetUnitX(unit1), GetUnitY(unit1), BlzGetUnitZ(unit1) + GetUnitFlyHeight(unit1),
                GetUnitX(unit2), GetUnitY(unit2), BlzGetUnitZ(unit2) + GetUnitFlyHeight(unit2))
        if color then
            SetLightningColor(lightning, color.r, color.g, color.b, color.a)
        end
        while true do
            c_step()
            MoveLightningEx(lightning, checkVisibility,
                    GetUnitX(unit1), GetUnitY(unit1), BlzGetUnitZ(unit1) + GetUnitFlyHeight(unit1),
                    GetUnitX(unit2), GetUnitY(unit2), BlzGetUnitZ(unit2) + GetUnitFlyHeight(unit2))
            if Time.Time >= expr then
                break
            end
        end
        DestroyLightning(lightning)
    end)
end

function ExAddLightningPosUnit(modelName, x1, y1, z1, unit2, duration, color, check)
    c_start(function()
        check = check or false
        local expr = Time.Time + duration
        local lightning = AddLightningEx(modelName, check,
                x1, y1, z1,
                GetUnitX(unit2), GetUnitY(unit2), BlzGetUnitZ(unit2) + GetUnitFlyHeight(unit2))
        if color then
            SetLightningColor(lightning, color.r, color.g, color.b, color.a)
        end
        while true do
            c_step()
            MoveLightningEx(lightning, check,
                    x1, y1, z1,
                    GetUnitX(unit2), GetUnitY(unit2), BlzGetUnitZ(unit2) + GetUnitFlyHeight(unit2))
            if Time.Time >= expr then
                break
            end
        end
        DestroyLightning(lightning)
    end)
end

--local GetTriggerUnit = GetTriggerUnit
--
--local mapArea = CreateRegion()
--RegionAddRect(mapArea, bj_mapInitialPlayableArea)
--local enterTrigger = CreateTrigger()
--local enterMapCalls = {}
--TriggerRegisterEnterRegion(enterTrigger, mapArea, Filter(function() return true end))
--ExTriggerAddAction(enterTrigger, function()
--    local u = GetTriggerUnit()
--    for _, v in ipairs(enterMapCalls) do
--        v(u)
--    end
--end)
--function ExTriggerRegisterNewUnit(callback)
--    t_insert(enterMapCalls, callback)
--end

local GetWidgetLife = GetWidgetLife

function ExIsUnitDead(unit)
    return GetWidgetLife(unit) < 0.406
end

end}

__modules["Lib.TableExt"]={loader=function()
---Add v to k of tab, in place. tab will be mutated.
---@generic K
---@param tab table<K, number>
---@param k K
---@param v number
---@return number result
function table.addNum(tab, k, v)
    local r = tab[k]
    if r == nil then
        r = v
    else
        r = r + v
    end
    tab[k] = r
    return r
end

function table.any(tab)
    return next(tab) ~= nil
end

function table.getOrCreateTable(tab, key)
    local ret = tab[key]
    if not ret then
        ret = {}
        tab[key] = ret
    end
    return ret
end

end}

__modules["Lib.Time"]={loader=function()
local EventCenter = require("Lib.EventCenter")
local Timer = require("Lib.Timer")
local FrameBegin = EventCenter.FrameBegin
local FrameUpdate = EventCenter.FrameUpdate

local TimerGetElapsed = TimerGetElapsed

local TimeTimerInterval = 10

---@class Time
---@field Time real current time
local cls = {}

cls.Frame = 0
cls.Delta = 0.04
local delta = cls.Delta

local time = 0
local timeTimer = Timer.new(function()
    time = time + TimeTimerInterval
end, TimeTimerInterval, -1)
timeTimer:Start()
local tm = timeTimer.timer

FrameBegin:On(cls, function(_, _)
    local f = cls.Frame + 1
    cls.Frame = f
end)

-- main loop
local mainLoopTimer = Timer.new(function(dt)
    FrameBegin:Emit(dt)
    FrameUpdate:Emit(dt)
end, cls.Delta, -1)
mainLoopTimer:Start()

-- cls.Time
setmetatable(cls, {
    __index = function()
        return time + TimerGetElapsed(tm)
    end
})

local MathRound = MathRound
local m_ceil = math.ceil

function cls.CeilToNextUpdate(timestamp)
    return MathRound(m_ceil(timestamp / delta) * delta * 100) * 0.01
end

Time = cls

return cls

end}

__modules["Lib.Timer"]={loader=function()
require("Lib.MathExt")

local pcall = pcall
local t_insert = table.insert
local t_remove = table.remove

local PauseTimer = PauseTimer
local CreateTimer = CreateTimer
local TimerStart = TimerStart
local TimerGetElapsed = TimerGetElapsed

local pool = {}

local function getTimer()
    if #pool == 0 then
        return CreateTimer()
    else
        return t_remove(pool)
    end
end

local function cacheTimer(timer)
    PauseTimer(timer)
    t_insert(pool, timer)
end

local cls = class("Timer")

function cls:ctor(func, duration, loops)
    self.timer = getTimer()
    self.func = func
    self.duration = duration
    if loops == 0 then
        loops = 1
    end
    self.loops = loops
end

function cls:Start()
    TimerStart(self.timer, self.duration, self.loops ~= 1, function()
        local dt = TimerGetElapsed(self.timer)
        local s, m = pcall(self.func, dt)
        if not s then
            print(m)
            return
        end

        if self.loops > 0 then
            self.loops = self.loops - 1
            if self.loops == 0 then
                self:Stop()
                return
            end
        end
    end)
end

function cls:Stop()
    cacheTimer(self.timer)
end

return cls

end}

__modules["Lib.Utils"]={loader=function()
local m_floor = math.floor
local s_sub = string.sub

local cls = {}

local ccMap = ""
        .. "................"
        .. "................"
        .. " !\"#$%&'()*+,-./"
        .. "0123456789:;<=>?"
        .. "@ABCDEFGHIJKLMNO"
        .. "PQRSTUVWXYZ[\\]^_"
        .. "`abcdefghijklmno"
        .. "pqrstuvwxyz{|}~."
        .. "................"
        .. "................"
        .. "................"
        .. "................"
        .. "................"
        .. "................"
        .. "................"
        .. "................"

function cls.CCFour(value)
    local d1 = m_floor(value / 16777216)
    value = value - d1 * 16777216
    d1 = d1 + 1
    local d2 = m_floor(value / 65536)
    value = value - d2 * 65536
    d2 = d2 + 1
    local d3 = m_floor(value / 256)
    value = value - d3 * 256
    d3 = d3 + 1
    value = value + 1
    return s_sub(ccMap, d1, d1) .. s_sub(ccMap, d2, d2) .. s_sub(ccMap, d3, d3) .. s_sub(ccMap, value, value)
end

local AbilIdAmrf = FourCC("Amrf")

function cls.SetUnitFlyable(unit)
    UnitAddAbility(unit, AbilIdAmrf);
    UnitRemoveAbility(unit, AbilIdAmrf);
end

return cls

end}

__modules["Lib.Vector2"]={loader=function()
local setmetatable = setmetatable
local type = type
local rawget = rawget
local m_sqrt = math.sqrt

local GetUnitX = GetUnitX
local GetUnitY = GetUnitY

---@class Vector2
local cls = {}

---@return Vector2
function cls.new(x, y)
    return setmetatable({
        x = x or 0,
        y = y or 0,
    }, cls)
end

local new = cls.new

---@param unit unit
function cls.FromUnit(unit)
    return new(GetUnitX(unit), GetUnitY(unit))
end

function cls.InsideUnitCircle()
    local angle = math.random() * math.pi * 2
    return new(math.cos(angle), math.sin(angle))
end

---@param unit unit
function cls:MoveToUnit(unit)
    self.x = GetUnitX(unit)
    self.y = GetUnitY(unit)
    return self
end

---@param unit unit
function cls:UnitMoveTo(unit)
    SetUnitPosition(unit, self.x, self.y)
    return self
end

---@param other Vector2
function cls:SetTo(other)
    self.x = other.x
    self.y = other.y
    return
end

---@param other Vector2
function cls:Add(other)
    self.x = self.x + other.x
    self.y = self.y + other.y
    return self
end

---@param other Vector2
function cls:Sub(other)
    self.x = self.x - other.x
    self.y = self.y - other.y
    return self
end

---@param d real
function cls:Div(d)
    self.x = self.x / d
    self.y = self.y / d
    return self
end

---@param d real
function cls:Mul(d)
    self.x = self.x * d
    self.y = self.y * d
    return self
end

function cls:SetNormalize()
    local magnitude = self:GetMagnitude()

    if magnitude > 1e-05 then
        self.x = self.x / magnitude
        self.y = self.y / magnitude
    else
        self.x = 0
        self.y = 0
    end

    return self
end

function cls:SetLength(len)
    self:SetNormalize():Mul(len)
    return self
end

function cls:GetMagnitude()
    return m_sqrt(self.x * self.x + self.y * self.y)
end

---@return string
function cls:tostring()
    return string.format("(%f,%f)", self.x, self.y)
end

function cls.__index(_, k)
    return rawget(cls, k)
end

function cls.__add(a, b)
    return new(a.x + b.x, a.y + b.y)
end

---@return Vector2
function cls.__sub(a, b)
    return new(a.x - b.x, a.y - b.y)
end

function cls.__div(v, d)
    return new(v.x / d, v.y / d)
end

function cls.__mul(a, d)
    if type(d) == "number" then
        return new(a.x * d, a.y * d)
    else
        return new(a * d.x, a * d.y)
    end
end

function cls.__unm(v)
    return new(-v.x, -v.y)
end

function cls.__eq(a, b)
    return ((a.x - b.x) ^ 2 + (a.y - b.y) ^ 2) < 9.999999e-11
end

setmetatable(cls, cls)

return cls

end}

__modules["Main"]={loader=function()
local FrameTimer = require("Lib.FrameTimer")
local Time = require("Lib.Time")
require("Lib.CoroutineExt")
require("Lib.ArrayExt")
require("Lib.TableExt")
require("Lib.native")

local ipairs = ipairs

-- main logic

-- game machine

---@type SystemBase[]
local systems = {
    require("System.ItemSystem").new(),
    require("System.SpellSystem").new(),
    require("System.MeleeGameSystem").new(),
    require("System.BuffSystem").new(),
    require("System.DamageSystem").new(),
    --require("System.AbilityEditorSystem").new(),

    require("System.InitAbilitiesSystem").new(),
}

for _, system in ipairs(systems) do
    system:Awake()
end

for _, system in ipairs(systems) do
    system:OnEnable()
end

local MathRound = MathRound

local game = FrameTimer.new(function(dt)
    local now = MathRound(Time.Time * 100) * 0.01
    for _, system in ipairs(systems) do
        system:Update(dt, now)
    end
end, 1, -1)
game:Start()

end}

__modules["System.AbilityEditorSystem"]={loader=function()
local EventCenter = require("Lib.EventCenter")
local Event = require("Lib.Event")
local SystemBase = require("System.SystemBase")

EventCenter.EditUnitAbility = Event.new()

---@class AbilityEditorSystem : SystemBase
local cls = class("AbilityEditorSystem", SystemBase)

function cls:Awake()
    self.map = {}
    EventCenter.EditUnitAbility:On(self, cls.onEditUnitAbility)

    ExTriggerRegisterNewUnit(function(u)
        local uid = GetUnitTypeId(u)
        local tab = table.getOrCreateTable(self.map, uid)
        for aid, handler in pairs(tab) do
            handler(BlzGetUnitAbility(u, aid))
        end
    end)
end

function cls:onEditUnitAbility(data)
    local tab = table.getOrCreateTable(self.map, data.unitId)
    tab[data.abilityId] = data.handler
end

return cls

end}

__modules["System.BuffSystem"]={loader=function()
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

end}

__modules["System.DamageSystem"]={loader=function()
local EventCenter = require("Lib.EventCenter")
local Event = require("Lib.Event")

EventCenter.RegisterPlayerUnitDamaging = Event.new()
EventCenter.RegisterPlayerUnitDamaged = Event.new()
EventCenter.Heal = Event.new()

local SystemBase = require("System.SystemBase")

---@class DamageSystem : SystemBase
local cls = class("DamageSystem", SystemBase)

function cls:ctor()
    cls.super.ctor(self)
    local damagingTrigger = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(damagingTrigger, EVENT_PLAYER_UNIT_DAMAGED)
    ExTriggerAddAction(damagingTrigger, function()
        self:_response(self._damagingHandlers)
    end)

    local damagedTrigger = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(damagedTrigger, EVENT_PLAYER_UNIT_DAMAGED)
    ExTriggerAddAction(damagedTrigger, function()
        self:_response(self._damagedHandlers)
    end)

    --local enterTrigger = CreateTrigger()
    --TriggerRegisterEnterRegion(enterTrigger, CreateRegion(), Filter(function() return true end))
    --TriggerAddAction(enterTrigger, function()
    --    TriggerRegisterUnitEvent(damageTrigger, GetTriggerUnit(), EVENT_UNIT_DAMAGED)
    --end)

    self._damagingHandlers = {}
    self._damagedHandlers = {}
end

function cls:Awake()
    EventCenter.RegisterPlayerUnitDamaging:On(self, cls._registerDamaging)
    EventCenter.RegisterPlayerUnitDamaged:On(self, cls._registerDamaged)
    EventCenter.Heal:On(self, cls._onHeal)
end

function cls:_registerDamaging(handler)
    array.add(self._damagingHandlers, handler)
end

function cls:_registerDamaged(handler)
    array.add(self._damagedHandlers, handler)
end

function cls:_response(whichHandlers)
    local damage = GetEventDamage()
    local caster = GetEventDamageSource()
    local target = BlzGetEventDamageTarget()
    local damageType = BlzGetEventDamageType()
    local weaponType = BlzGetEventWeaponType()
    local isAttack = BlzGetEventIsAttack()
    for _, v in ipairs(whichHandlers) do
        v(caster, target, damage, weaponType, damageType, isAttack)
    end
end

function cls:_onHeal(data)
    local current = GetUnitState(data.target, UNIT_STATE_LIFE)
    SetWidgetLife(data.target, current + data.amount)
end

return cls

end}

__modules["System.InitAbilitiesSystem"]={loader=function()
local SystemBase = require("System.SystemBase")

---@class InitAbilitiesSystem : SystemBase
local cls = class("InitAbilitiesSystem", SystemBase)

function cls:Awake()
    require("Ability.DeathGrip")
    require("Ability.DeathStrike")
    require("Ability.PlagueStrike")
    require("Ability.ArmyOfTheDead")
end

return cls

end}

__modules["System.ItemSystem"]={loader=function()
---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Rick Sun.
--- DateTime: 9/17/2022 1:46 PM
---

local Event = require("Lib.Event")
local EventCenter = require("Lib.EventCenter")
local SystemBase = require("System.SystemBase")

EventCenter.PlayerUnitPickupItem = Event.new()

---@class EventRegisterItemRecipeData
---@field result item
---@field recipe table<item, integer>

---@class EventRegisterItemRecipe : Event
---@field data EventRegisterItemRecipeData
EventCenter.RegisterItemRecipe = Event.new()

---@class ItemSystem : SystemBase
local cls = class("ItemSystem", SystemBase)

function cls:ctor()
    local trigger = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trigger, EVENT_PLAYER_UNIT_PICKUP_ITEM)
    ExTriggerAddAction(trigger, function()
        local item = GetManipulatedItem()
        local unit = GetTriggerUnit()
        local player = GetTriggerPlayer()
        EventCenter.PlayerUnitPickupItem:Emit({
            item = item,
            unit = unit,
            player = player
        })
        self:_mergeItems(item, unit, player)
    end)

    self._recipes = {} ---@type table<item, table<item, integer>[]> key=result, key2=ingredient value2=ingredient count
    self._ingredients = {} ---@type table<item, table<item, integer>> key=ingredient key2=result value2=1
    EventCenter.RegisterItemRecipe:On(self, cls._registerItemRecipe)
end

function cls:_collectItemsInSlot(unit)
    local t = {}
    for i = 0, 5 do
        local item = UnitItemInSlot(unit, i)
        if item then
            table.addNum(t, item, 1)
        end
    end
    return t
end

function cls:_mergeItems(item, unit, player)
    local results = self._ingredients[item]
    if not results then
        return
    end

    local own = self:_collectItemsInSlot(unit)
    for result, _ in pairs(results) do

    end
end

---@param data EventRegisterItemRecipeData
function cls:_registerItemRecipe(data)
    local options = self._recipes[data.result]
    if not options then
        options = {}
        self._recipes[data.result] = options
    end
    table.insert(options, data.recipe)

    for k, _ in pairs(data.recipe) do
        local ingredient = self._ingredients[k]
        if not ingredient then
            ingredient = {}
            self._ingredients[k] = ingredient
        end
        ingredient[data.result] = 1
    end
end

return cls

end}

__modules["System.MeleeGameSystem"]={loader=function()
local SystemBase = require("System.SystemBase")

---@class MeleeGameSystem : SystemBase
local cls = class("MeleeGameSystem", SystemBase)

function cls:ctor()
    MeleeStartingVisibility()
    MeleeStartingHeroLimit()
    MeleeGrantHeroItems()
    MeleeStartingResources()
    MeleeClearExcessUnits()
    MeleeStartingUnits()
    MeleeStartingAI()
    MeleeInitVictoryDefeat()
end

return cls

end}

__modules["System.SpellSystem"]={loader=function()
local Event = require("Lib.Event")
local EventCenter = require("Lib.EventCenter")
local SystemBase = require("System.SystemBase")

---@class ISpellData
---@field abilityId integer
---@field caster unit
---@field target unit
---@field x real
---@field y real
---@field item item
---@field destructable destructable
---@field finished boolean
---@field interrupted ISpellData
---@field _effectDone boolean

---@class IRegisterSpellEvent : Event
---@field Emit fun(arg: { id: integer, handler: (fun(data: ISpellData): void), ctx: table }): void

---@class SpellSystem : SystemBase
local cls = class("SpellSystem", SystemBase)

---@type IRegisterSpellEvent
EventCenter.RegisterPlayerUnitSpellChannel = Event.new()
---@type IRegisterSpellEvent
EventCenter.RegisterPlayerUnitSpellCast = Event.new()
---@type IRegisterSpellEvent
EventCenter.RegisterPlayerUnitSpellEffect = Event.new()
---@type IRegisterSpellEvent
EventCenter.RegisterPlayerUnitSpellFinish = Event.new()
---@type IRegisterSpellEvent
EventCenter.RegisterPlayerUnitSpellEndCast = Event.new()

function cls:ctor()
    self:_register(EVENT_PLAYER_UNIT_SPELL_CHANNEL, function()
        local data = self:_initSpellData()
        self:_invoke(self._channelHandlers, data)
    end)

    self:_register(EVENT_PLAYER_UNIT_SPELL_CAST, function()
        local data = self.castTab[GetTriggerUnit()]
        self:_invoke(self._castHandlers, data)
    end)

    self:_register(EVENT_PLAYER_UNIT_SPELL_EFFECT, function()
        local data = self.castTab[GetTriggerUnit()]
        if data and not data._effectDone then
            data._effectDone = true
            self:_invoke(self._effectHandlers, data)
        end
    end)

    self:_register(EVENT_PLAYER_UNIT_SPELL_FINISH, function()
        local data = self.castTab[GetTriggerUnit()]
        data.finished = true
        self:_invoke(self._finishHandlers, data)
    end)

    self:_register(EVENT_PLAYER_UNIT_SPELL_ENDCAST, function()
        local data = self.castTab[GetTriggerUnit()]
        self:_invoke(self._endCastHandlers, data)
        if data.interrupted then
            self.castTab[data.caster] = data.interrupted
        else
            self.castTab[data.caster] = nil
        end
    end)

    self.castTab = {} ---@type table<unit, ISpellData>

    self._channelHandlers = {}
    self._castHandlers = {}
    self._effectHandlers = {}
    self._finishHandlers = {}
    self._endCastHandlers = {}

    EventCenter.RegisterPlayerUnitSpellChannel:On(self, cls._registerSpellChannel)
    EventCenter.RegisterPlayerUnitSpellCast:On(self, cls._registerSpellCast)
    EventCenter.RegisterPlayerUnitSpellEffect:On(self, cls._registerSpellEffect)
    EventCenter.RegisterPlayerUnitSpellFinish:On(self, cls._registerSpellFinish)
    EventCenter.RegisterPlayerUnitSpellEndCast:On(self, cls._registerSpellEndCast)
end

---@param data ISpellData
function cls:_invoke(handlers, data)
    local tab = handlers[0]
    if tab then
        for _, listener in ipairs(tab) do
            if listener.ctx then
                listener.handler(listener.ctx, data)
            else
                listener.handler(data)
            end
        end
    end
    tab = handlers[data.abilityId]
    if tab then
        for _, listener in ipairs(tab) do
            if listener.ctx then
                listener.handler(listener.ctx, data)
            else
                listener.handler(data)
            end
        end
    end
end

function cls:_register(event, callback)
    local trigger = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trigger, event)
    ExTriggerAddAction(trigger, callback)
end

function cls:_initSpellData()
    local data = {} ---@type ISpellData
    data.abilityId = GetSpellAbilityId()
    data.caster = GetTriggerUnit()
    data.target = GetSpellTargetUnit()
    if data.target ~= nil then
        data.x = GetUnitX(data.target)
        data.y = GetUnitY(data.target)
    else
        data.destructable = GetSpellTargetDestructable()
        if data.destructable ~= nil then
            data.x = GetDestructableX(data.destructable)
            data.y = GetDestructableY(data.destructable)
        else
            data.item = GetSpellTargetItem()
            if data.item ~= nil then
                data.x = GetItemX(data.item)
                data.y = GetItemY(data.item)
            else
                data.x = GetSpellTargetX()
                data.y = GetSpellTargetY()
            end
        end
    end
    data.interrupted = self.castTab[data.caster]
    self.castTab[data.caster] = data
    return data
end

function cls:_registerSpell(data, tab)
    local listeners = tab[data.id]
    if listeners == nil then
        listeners = {}
        tab[data.id] = listeners
    end
    table.insert(listeners, data)
end

function cls:_registerSpellChannel(data)
    self:_registerSpell(data, self._channelHandlers)
end

function cls:_registerSpellCast(data)
    self:_registerSpell(data, self._castHandlers)
end

function cls:_registerSpellEffect(data)
    self:_registerSpell(data, self._effectHandlers)
end

function cls:_registerSpellFinish(data)
    self:_registerSpell(data, self._finishHandlers)
end

function cls:_registerSpellEndCast(data)
    self:_registerSpell(data, self._endCastHandlers)
end

return cls

end}

__modules["System.SystemBase"]={loader=function()
---@class SystemBase
local cls = class("SystemBase")

function cls:Awake()
end

function cls:OnEnable()
end

---@param dt real
function cls:Update(dt)
end

function cls:OnDisable()
end

function cls:OnDestroy()
end

return cls

end}

__modules["Main"].loader()
end
--lua-bundler:000059394

gg_trg_Melee_Initialization = nil
function InitGlobals()
end

function Unit000011_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 1), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000014_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 2), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000015_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 2), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000018_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 4), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000022_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 2), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000023_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 3), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000026_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 3), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000038_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000039_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 2), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000042_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 3), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000056_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_POWERUP, 1), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000059_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_CHARGED, 3), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function Unit000060_DropItems()
local trigWidget = nil
local trigUnit = nil
local itemID = 0
local canDrop = true

trigWidget = bj_lastDyingWidget
if (trigWidget == nil) then
trigUnit = GetTriggerUnit()
end
if (trigUnit ~= nil) then
canDrop = not IsUnitHidden(trigUnit)
if (canDrop and GetChangingUnit() ~= nil) then
canDrop = (GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE))
end
end
if (canDrop) then
RandomDistReset()
RandomDistAddItem(ChooseRandomItemEx(ITEM_TYPE_PERMANENT, 1), 100)
itemID = RandomDistChoose()
if (trigUnit ~= nil) then
UnitDropItem(trigUnit, itemID)
else
WidgetDropItem(trigWidget, itemID)
end
end
bj_lastDyingWidget = nil
DestroyTrigger(GetTriggeringTrigger())
end

function CreateUnitsForPlayer0()
local p = Player(0)
local u
local unitID
local t
local life

u = BlzCreateUnitWithSkin(p, FourCC("Udea"), -8992.7, 1346.7, 159.691, FourCC("Udea"))
end

function CreateNeutralHostile()
local p = Player(PLAYER_NEUTRAL_AGGRESSIVE)
local u
local unitID
local t
local life

u = BlzCreateUnitWithSkin(p, FourCC("ngns"), 3599.4, 2077.1, 160.937, FourCC("ngns"))
u = BlzCreateUnitWithSkin(p, FourCC("nftk"), -263.4, -2508.8, 245.420, FourCC("nftk"))
SetUnitAcquireRange(u, 200.0)
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000018_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nftr"), -438.9, -2488.1, 24.786, FourCC("nftr"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nftr"), -73.5, -2507.4, 172.675, FourCC("nftr"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nftb"), -520.7, -2265.8, 298.530, FourCC("nftb"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nftb"), 28.7, -2310.5, 72.620, FourCC("nftb"))
SetUnitAcquireRange(u, 200.0)
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000014_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nogl"), -291.1, 1.3, 261.250, FourCC("nogl"))
SetUnitAcquireRange(u, 200.0)
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000015_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nogr"), -514.1, 14.0, 237.974, FourCC("nogr"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nogr"), -130.3, 11.9, 297.226, FourCC("nogr"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nfsh"), 9495.5, -3458.4, 138.250, FourCC("nfsh"))
SetUnitAcquireRange(u, 200.0)
IssueImmediateOrder(u, "autodispeloff")
IssueImmediateOrder(u, "healoff")
IssueImmediateOrder(u, "innerfireoff")
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000022_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nfsp"), 3886.2, -518.7, 319.530, FourCC("nfsp"))
IssueImmediateOrder(u, "autodispeloff")
IssueImmediateOrder(u, "healoff")
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000056_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nftr"), 9523.1, -3195.7, 166.668, FourCC("nftr"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nftr"), 9201.8, -3471.8, 107.121, FourCC("nftr"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nfsh"), -9421.2, -3543.7, 44.124, FourCC("nfsh"))
SetUnitAcquireRange(u, 200.0)
IssueImmediateOrder(u, "autodispeloff")
IssueImmediateOrder(u, "healoff")
IssueImmediateOrder(u, "innerfireoff")
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000039_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nftt"), -4717.3, -389.5, 263.855, FourCC("nftt"))
u = BlzCreateUnitWithSkin(p, FourCC("nftr"), -9177.0, -3660.9, 65.053, FourCC("nftr"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nftr"), -9382.7, -3290.6, 11.183, FourCC("nftr"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nftb"), 4129.5, -336.7, 298.911, FourCC("nftb"))
u = BlzCreateUnitWithSkin(p, FourCC("nfsp"), 3871.8, -768.9, 335.372, FourCC("nfsp"))
IssueImmediateOrder(u, "autodispeloff")
IssueImmediateOrder(u, "healoff")
u = BlzCreateUnitWithSkin(p, FourCC("nftb"), 4097.2, -863.3, 334.419, FourCC("nftb"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000059_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nftt"), 4023.1, -613.3, 318.123, FourCC("nftt"))
u = BlzCreateUnitWithSkin(p, FourCC("nggr"), 3389.1, 2173.5, 0.000, FourCC("nggr"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000026_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("ngnb"), 4510.8, -4711.8, 72.915, FourCC("ngnb"))
SetUnitAcquireRange(u, 200.0)
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000060_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("ngns"), 3420.8, 2474.1, 207.260, FourCC("ngns"))
u = BlzCreateUnitWithSkin(p, FourCC("nggr"), -2967.2, 2003.0, 0.000, FourCC("nggr"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000023_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("ngns"), -3027.2, 1728.3, 23.175, FourCC("ngns"))
u = BlzCreateUnitWithSkin(p, FourCC("ngns"), -3145.0, 2239.4, 335.223, FourCC("ngns"))
u = BlzCreateUnitWithSkin(p, FourCC("ngna"), -6809.4, -4459.9, 116.744, FourCC("ngna"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("ngna"), -6906.4, -4600.6, 99.395, FourCC("ngna"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("nfsp"), -4627.5, -249.4, 257.440, FourCC("nfsp"))
IssueImmediateOrder(u, "autodispeloff")
IssueImmediateOrder(u, "healoff")
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000038_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nftb"), -4437.3, -486.5, 242.301, FourCC("nftb"))
u = BlzCreateUnitWithSkin(p, FourCC("nftb"), -4964.7, -472.0, 286.570, FourCC("nftb"))
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000042_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("nfsp"), -4877.9, -243.5, 0.000, FourCC("nfsp"))
IssueImmediateOrder(u, "autodispeloff")
IssueImmediateOrder(u, "healoff")
u = BlzCreateUnitWithSkin(p, FourCC("ngnb"), -6999.1, -4406.9, 92.930, FourCC("ngnb"))
SetUnitAcquireRange(u, 200.0)
t = CreateTrigger()
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
TriggerAddAction(t, Unit000011_DropItems)
u = BlzCreateUnitWithSkin(p, FourCC("ngna"), 4478.0, -4819.3, 47.402, FourCC("ngna"))
SetUnitAcquireRange(u, 200.0)
u = BlzCreateUnitWithSkin(p, FourCC("ngna"), 4400.0, -4699.5, 344.160, FourCC("ngna"))
SetUnitAcquireRange(u, 200.0)
end

function CreateNeutralPassiveBuildings()
local p = Player(PLAYER_NEUTRAL_PASSIVE)
local u
local unitID
local t
local life

u = BlzCreateUnitWithSkin(p, FourCC("ngad"), -320.0, 256.0, 270.000, FourCC("ngad"))
u = BlzCreateUnitWithSkin(p, FourCC("nmoo"), -256.0, -2240.0, 270.000, FourCC("nmoo"))
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), -7936.0, 2432.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), 9216.0, 2048.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), 3584.0, -640.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), -4736.0, 0.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), -3328.0, 1920.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
u = BlzCreateUnitWithSkin(p, FourCC("ngol"), 3712.0, 2432.0, 270.000, FourCC("ngol"))
SetResourceAmount(u, 12500)
end

function CreateNeutralPassive()
local p = Player(PLAYER_NEUTRAL_PASSIVE)
local u
local unitID
local t
local life

u = BlzCreateUnitWithSkin(p, FourCC("nvlw"), 1091.4, -4983.9, 64.338, FourCC("nvlw"))
u = BlzCreateUnitWithSkin(p, FourCC("nshe"), 1183.4, -4875.2, 136.762, FourCC("nshe"))
u = BlzCreateUnitWithSkin(p, FourCC("nshe"), 1121.9, -4881.8, 279.523, FourCC("nshe"))
u = BlzCreateUnitWithSkin(p, FourCC("nshe"), 1152.1, -4810.7, 144.398, FourCC("nshe"))
u = BlzCreateUnitWithSkin(p, FourCC("nshe"), 1249.5, -4840.5, 219.360, FourCC("nshe"))
u = BlzCreateUnitWithSkin(p, FourCC("nshe"), 1234.1, -4886.9, 116.151, FourCC("nshe"))
u = BlzCreateUnitWithSkin(p, FourCC("nshe"), 1179.0, -4921.2, 308.319, FourCC("nshe"))
u = BlzCreateUnitWithSkin(p, FourCC("nshe"), 1307.7, -4869.4, 238.477, FourCC("nshe"))
u = BlzCreateUnitWithSkin(p, FourCC("nshe"), 1213.9, -4783.3, 51.374, FourCC("nshe"))
u = BlzCreateUnitWithSkin(p, FourCC("npig"), -5581.7, -4548.9, 256.495, FourCC("npig"))
u = BlzCreateUnitWithSkin(p, FourCC("npig"), -5719.4, -4560.2, 118.249, FourCC("npig"))
u = BlzCreateUnitWithSkin(p, FourCC("npig"), -5627.1, -4500.0, 106.373, FourCC("npig"))
u = BlzCreateUnitWithSkin(p, FourCC("npig"), -5631.6, -4552.5, 246.684, FourCC("npig"))
u = BlzCreateUnitWithSkin(p, FourCC("npig"), -5502.5, -4454.7, 290.432, FourCC("npig"))
u = BlzCreateUnitWithSkin(p, FourCC("npig"), -5778.7, -4561.3, 80.675, FourCC("npig"))
end

function CreatePlayerBuildings()
end

function CreatePlayerUnits()
CreateUnitsForPlayer0()
end

function CreateAllUnits()
CreateNeutralPassiveBuildings()
CreatePlayerBuildings()
CreateNeutralHostile()
CreateNeutralPassive()
CreatePlayerUnits()
end

function Trig_Melee_Initialization_Actions()
MeleeStartingVisibility()
MeleeStartingHeroLimit()
MeleeGrantHeroItems()
MeleeStartingResources()
MeleeClearExcessUnits()
MeleeStartingUnits()
MeleeStartingAI()
MeleeInitVictoryDefeat()
end

function InitTrig_Melee_Initialization()
gg_trg_Melee_Initialization = CreateTrigger()
TriggerAddAction(gg_trg_Melee_Initialization, Trig_Melee_Initialization_Actions)
end

function InitCustomTriggers()
InitTrig_Melee_Initialization()
end

function RunInitializationTriggers()
ConditionalTriggerExecute(gg_trg_Melee_Initialization)
end

function InitCustomPlayerSlots()
SetPlayerStartLocation(Player(0), 0)
SetPlayerColor(Player(0), ConvertPlayerColor(0))
SetPlayerRacePreference(Player(0), RACE_PREF_HUMAN)
SetPlayerRaceSelectable(Player(0), true)
SetPlayerController(Player(0), MAP_CONTROL_USER)
SetPlayerStartLocation(Player(1), 1)
SetPlayerColor(Player(1), ConvertPlayerColor(1))
SetPlayerRacePreference(Player(1), RACE_PREF_ORC)
SetPlayerRaceSelectable(Player(1), true)
SetPlayerController(Player(1), MAP_CONTROL_USER)
end

function InitCustomTeams()
SetPlayerTeam(Player(0), 0)
SetPlayerTeam(Player(1), 0)
end

function InitAllyPriorities()
SetStartLocPrioCount(0, 1)
SetStartLocPrio(0, 0, 1, MAP_LOC_PRIO_HIGH)
SetStartLocPrioCount(1, 1)
SetStartLocPrio(1, 0, 0, MAP_LOC_PRIO_HIGH)
end

function main()
SetCameraBounds(-10240.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), -5376.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM), 10240.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), 3840.0 - GetCameraMargin(CAMERA_MARGIN_TOP), -10240.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), 3840.0 - GetCameraMargin(CAMERA_MARGIN_TOP), 10240.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), -5376.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM))
SetDayNightModels("Environment\\DNC\\DNCLordaeron\\DNCLordaeronTerrain\\DNCLordaeronTerrain.mdl", "Environment\\DNC\\DNCLordaeron\\DNCLordaeronUnit\\DNCLordaeronUnit.mdl")
NewSoundEnvironment("Default")
SetAmbientDaySound("LordaeronSummerDay")
SetAmbientNightSound("LordaeronSummerNight")
SetMapMusic("Music", true, 0)
CreateAllUnits()
InitBlizzard()
InitGlobals()
InitCustomTriggers()
RunInitializationTriggers()
local s, m = pcall(RunBundle)
if not s then
    print(m)
end
end

function config()
SetMapName("TRIGSTR_003")
SetMapDescription("TRIGSTR_005")
SetPlayers(2)
SetTeams(2)
SetGamePlacement(MAP_PLACEMENT_TEAMS_TOGETHER)
DefineStartLocation(0, -8384.0, 1792.0)
DefineStartLocation(1, 8448.0, 2048.0)
InitCustomPlayerSlots()
SetPlayerSlotAvailable(Player(0), MAP_CONTROL_USER)
SetPlayerSlotAvailable(Player(1), MAP_CONTROL_USER)
InitGenericPlayerSlots()
InitAllyPriorities()
end
