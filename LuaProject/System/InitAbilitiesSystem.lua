local SystemBase = require("System.SystemBase")

---@class InitAbilitiesSystem : SystemBase
local cls = class("InitAbilitiesSystem", SystemBase)

function cls:Awake()
    -- 血DK
    require("Ability.DeathGrip")
    require("Ability.GorefiendsGrasp")
    require("Ability.DeathStrike")
    require("Ability.PlagueStrike")
    require("Ability.ArmyOfTheDead")

    -- 邪DK
    require("Ability.FesteringWound")
    require("Ability.DeathCoil")
    require("Ability.Defile")
    require("Ability.Apocalypse")
    require("Ability.DarkTransformation")
    require("Ability.MonstrousBlow")
    require("Ability.ShamblingRush")
    require("Ability.PutridBulwark")

    -- 默认 技能
    require("Ability.Evasion")
    require("Ability.MoonWellHeal")
    require("Ability.NativeRejuvenation")

    -- 武器战
    require("Ability.RageGenerator")
    require("Ability.DeepWounds")
    require("Ability.Overpower")
    require("Ability.Charge")
    require("Ability.MortalStrike")
    require("Ability.Condemn")
    require("Ability.BladeStorm")

    -- 唤魔师
    require("Ability.FireBreath")
    require("Ability.Disintegrate")
    require("Ability.SleepWalk")
    require("Ability.TimeWarp")
    require("Ability.MagmaBreath")

    -- 地穴领主
    require("Ability.PassiveDamageWithImpaleVisuals")

    -- 术士-克尔苏加德
    require("Ability.SoulSiphon")
    require("Ability.ShadowBolt")

    -- 牧师-希尔盖
    require("Ability.DarkHeal")
    require("Ability.DarkShield")
end

return cls
