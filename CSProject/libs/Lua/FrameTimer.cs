using System;
using SFLib;

namespace Lua;

[Lua(Module = "Lib.FrameTimer")]
public class FrameTimer : LuaObject
{
#pragma warning disable CS8597 // Thrown value may be null.
    [Lua(StaticMethod = "new")]
    public FrameTimer(Action<float> func, int count, int loops) => throw null;
    public void Start() => throw null;
    public void Stop() => throw null;

#pragma warning restore CS8597 // Thrown value may be null.
}