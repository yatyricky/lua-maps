using SFLib;
using Lua;

public class Program
{
    public static void Main(string[] args)
    {
        LuaInterop.SetGlobal("CLI", LuaInterop.CreateTable());
        LuaInterop.Require("Lib.CoroutineExt");
        LuaInterop.Require("Lib.TableExt");
        LuaInterop.Require("Lib.StringExt");
        LuaInterop.Require("Lib.native");

        var systems = new List<LuaObject>();
        systems.Add(LuaInterop.Call<LuaObject>(LuaInterop.Require("System.ItemSystem"), "new"));
        systems.Add(LuaInterop.Call<LuaObject>(LuaInterop.Require("System.SpellSystem"), "new"));
        systems.Add(LuaInterop.Call<LuaObject>(LuaInterop.Require("System.BuffSystem"), "new"));
        systems.Add(LuaInterop.Call<LuaObject>(LuaInterop.Require("System.DamageSystem"), "new"));
        systems.Add(LuaInterop.Call<LuaObject>(LuaInterop.Require("System.ProjectileSystem"), "new"));
        
        systems.Add(LuaInterop.Call<LuaObject>(LuaInterop.Require("System.InitAbilitiesSystem"), "new"));
        systems.Add(LuaInterop.Call<LuaObject>(LuaInterop.Require("System.BuffDisplaySystem"), "new"));

#if MAP_NAME_moonglade
        systems.Add(LuaInterop.Call<LuaObject>(LuaInterop.Require("System.MoonGladeSystem"), "new"));
#endif

#if MAP_NAME_twistedmeadows
        systems.Add(LuaInterop.Call<LuaObject>(LuaInterop.Require("System.TwistedMeadowsSystem"), "new"));
#endif

#if MAP_NAME_echoisles || MAP_NAME_turtlerock || MAP_NAME_twistedmeadows
        systems.Add(LuaInterop.Call<LuaObject>(LuaInterop.Require("System.MeleeGameSystem"), "new"));
#endif

        foreach (var system in systems)
        {
            LuaInterop.CallMethod(system, "Awake");
        }

        var group = CreateGroup();
        GroupEnumUnitsInRect(group, bj_mapInitialPlayableArea, Filter(() =>
        {
            LuaInterop.CallGlobal("ExTriggerRegisterNewUnitExec", GetFilterUnit());
            return false;
        }));
        DestroyGroup(group);

        foreach (var system in systems)
        {
            LuaInterop.CallMethod(system, "OnEnable");
        }

        var game = new FrameTimer(dt =>
        {
            var now = MathRound(Time.CurrentTime * 100) * 0.01f;
            foreach (var system in systems)
            {
                LuaInterop.CallMethod(system, "Update", dt, now);
            }
        }, 1, -1);
        game.Start();
    }
}