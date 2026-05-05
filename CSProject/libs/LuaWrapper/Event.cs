namespace LuaWrapper;

using System;
using SFLib;

[Lua(Module = "Lib.Event.lua")]
public class Event<T, E> : LuaObject
{
#pragma warning disable CS8597 // Thrown value may be null.
    public void On(T context, Action<T, E> listener) => throw null;
    public void Off(T context, Action<T, E> listener) => throw null;
    public void Emit(E data) => throw null;
    public override string ToString() => default!;
#pragma warning restore CS8597 // Thrown value may be null.
}