namespace LuaWrapper;

using SFLib;

[Lua(Module = "Lib.Time")]
public class Time : LuaObject
{
    public static int Frame;
    public static float Delta;
    [Lua(Name = "Time")]
    public static float CurrentTime;
    public static float CeilToNextUpdate(float timestamp) => 0f;
}