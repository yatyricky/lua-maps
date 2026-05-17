namespace LuaWrapper;

using SFLib.Interop;

[Lua(Module = "Lib.Utils")]
public class LuaUtils : LuaObject
{
#pragma warning disable CS8597 // Thrown value may be null.
    public static string CCFour(int value) => throw null;
    public static void SetUnitFlyable(unit unit) => throw null;
#pragma warning restore CS8597 // Thrown value may be null.
}