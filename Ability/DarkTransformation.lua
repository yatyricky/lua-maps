-- 黑暗突变

local EventCenter = require("Lib.EventCenter")
local Abilities = require("Config.Abilities")
local Vector2 = require("Lib.Vector2")

--region meta

Abilities.DarkTransformation = {
    ID = FourCC("A007"),
    TechID = FourCC("R000"),
    AbominationID = FourCC("u002"),
}

BlzSetAbilityResearchTooltip(Abilities.DarkTransformation.ID, "学习黑暗突变", 0)
BlzSetAbilityResearchExtendedTooltip(Abilities.DarkTransformation.ID, string.format([[学习此技能后，你的食尸鬼和石像鬼部队永久获得|cffff8c00+10|r攻击力和|cffff8c00+100|r生命值。

对一个食尸鬼施展，可以将其永久转化为一个拥有|cffff8c001800|r生命值的憎恶，并获得|cffff8c004个全新的强力技能|r。

|cff99ccff法力消耗|r - 1000点
|cff99ccff冷却时间|r - 60秒]]), 0)

for i = 1, 1 do
    BlzSetAbilityTooltip(Abilities.DarkTransformation.ID, string.format("黑暗突变", i), i - 1)
    BlzSetAbilityExtendedTooltip(Abilities.DarkTransformation.ID, string.format([[你的食尸鬼和石像鬼部队永久获得|cffff8c00+10|r攻击力和|cffff8c00+100|r生命值。

对一个食尸鬼施展，可以将其永久转化为一个拥有|cffff8c001800|r生命值的憎恶，并获得|cffff8c004个全新的强力技能|r。

|cff99ccff法力消耗|r - 1000点
|cff99ccff冷却时间|r - 60秒]]), i - 1)
end

--endregion

local cls = class("DarkTransformation")

local channelSfx = {}

EventCenter.RegisterPlayerUnitSpellChannel:Emit({
    id = Abilities.DarkTransformation.ID,
    ---@param data ISpellData
    handler = function(data)
        channelSfx[data.caster] = AddSpecialEffectTarget("Abilities/Spells/Undead/Unsummon/UnsummonTarget.mdl", data.target, "origin")
    end
})

EventCenter.RegisterPlayerUnitSpellEffect:Emit({
    id = Abilities.DarkTransformation.ID,
    ---@param data ISpellData
    handler = function(data)
        local pos = Vector2.FromUnit(data.target)
        local facing = GetUnitFacing(data.target)
        KillUnit(data.target)
        ExAddSpecialEffect("Objects/Spawnmodels/Human/HumanBlood/HeroBloodElfBlood.mdl", pos.x, pos.y, 2.0)

        local constructAbomination = AddSpecialEffect("Units/Undead/Abomination/AbominationExplosion.mdl", pos.x, pos.y)
        BlzSetSpecialEffectTime(constructAbomination, 1.8)
        BlzSetSpecialEffectScale(constructAbomination, 1.2)
        BlzSetSpecialEffectColor(constructAbomination, 127, 255, 150)
        BlzSetSpecialEffectTimeScale(constructAbomination, -1)
        coroutine.start(function()
            coroutine.wait(1.6)
            BlzSetSpecialEffectPosition(constructAbomination, 0, 0, -1000)
            DestroyEffect(constructAbomination)
            local summoned = CreateUnit(GetOwningPlayer(data.caster), Abilities.DarkTransformation.AbominationID, pos.x, pos.y, facing)
            ExAddSpecialEffectTarget("Abilities/Spells/Undead/AnimateDead/AnimateDeadTarget.mdl", summoned, "origin", 1)
        end)
    end
})

EventCenter.RegisterPlayerUnitSpellEndCast:Emit({
    id = Abilities.DarkTransformation.ID,
    ---@param data ISpellData
    handler = function(data)
        if channelSfx[data.caster] then
            DestroyEffect(channelSfx[data.caster])
            channelSfx[data.caster] = nil
        end
    end
})

ExTriggerRegisterUnitLearn(Abilities.DarkTransformation.ID, function(unit, _)
    local p = GetOwningPlayer(unit)
    SetPlayerTechResearched(p, Abilities.DarkTransformation.TechID, 1)
end)

return cls

-- 蹒跚冲锋
-- 腐臭壁垒