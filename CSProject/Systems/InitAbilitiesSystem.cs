namespace Systems;

using LuaWrapper;
using SFLib;

[Lua(Class = "InitAbilitiesSystem")]
public class InitAbilitiesSystem : SystemBase
{
    public override void Awake()
    {
#if MAP_NAME_echoisles
        // 血DK
        LuaInterop.Require("Ability.DeathGrip");
        LuaInterop.Require("Ability.GorefiendsGrasp");
        LuaInterop.Require("Ability.DeathStrike");
        LuaInterop.Require("Ability.PlagueStrike");
        LuaInterop.Require("Ability.ArmyOfTheDead");
#endif

#if MAP_NAME_turtlerock
        // 邪DK
        LuaInterop.Require("Ability.FesteringWound");
        LuaInterop.Require("Ability.DeathCoil");
        LuaInterop.Require("Ability.Defile");
        LuaInterop.Require("Ability.Apocalypse");
        LuaInterop.Require("Ability.DarkTransformation");
        LuaInterop.Require("Ability.MonstrousBlow");
        LuaInterop.Require("Ability.ShamblingRush");
        LuaInterop.Require("Ability.PutridBulwark");
#endif

#if MAP_NAME_twistedmeadows
        // 默认 技能
        LuaInterop.Require("Ability.Evasion");
        LuaInterop.Require("Ability.MoonWellHeal");
        LuaInterop.Require("Ability.NativeRejuvenation");

        // 武器战
        LuaInterop.Require("Ability.RageGenerator");
        LuaInterop.Require("Ability.DeepWounds");
        LuaInterop.Require("Ability.Overpower");
        LuaInterop.Require("Ability.Charge");
        LuaInterop.Require("Ability.MortalStrike");
        LuaInterop.Require("Ability.Condemn");
        LuaInterop.Require("Ability.BladeStorm");
#endif

#if MAP_NAME_moonglade
        // 唤魔师
        LuaInterop.Require("Ability.FireBreath");
        LuaInterop.Require("Ability.Disintegrate");
        LuaInterop.Require("Ability.SleepWalk");
        LuaInterop.Require("Ability.TimeWarp");
        LuaInterop.Require("Ability.MagmaBreath");
#endif

#if MAP_NAME_demo
        // 地穴领主
        LuaInterop.Require("Ability.PassiveDamageWithImpaleVisuals");

        // 术士-克尔苏加德
        LuaInterop.Require("Ability.SoulSiphon");
        LuaInterop.Require("Ability.ShadowBolt");

        // 牧师-希尔盖
        LuaInterop.Require("Ability.DarkHeal");
        LuaInterop.Require("Ability.DarkShield");
#endif
    }
}
