using System;
using SFLib.Interop;

namespace LuaWrapper;

#pragma warning disable CS8618 // Non-nullable field must contain a non-null value when exiting constructor. Consider adding the 'required' modifier or declaring as nullable.
public class ISpellData
{
    public int abilityId;
    public unit caster;
    public unit target;
    public float x;
    public float y;
    public item item;
    public destructable destructable;
    public bool finished;
    public ISpellData interrupted;
    public bool _effectDone;
}

[Lua(TableLiteral = true)]
public class IRegisterSpellEvent : LuaObject
{
    public int id;
    public Action<ISpellData> handler;
    public LuaObject ctx;
}

[Lua(Module = "Lib.EventCenter")]
public class EventCenter : LuaObject
{
    public static Event<LuaObject, IRegisterSpellEvent> RegisterPlayerUnitSpellChannel;
    public static Event<LuaObject, IRegisterSpellEvent> RegisterPlayerUnitSpellCast;
    public static Event<LuaObject, IRegisterSpellEvent> RegisterPlayerUnitSpellEffect;
    public static Event<LuaObject, IRegisterSpellEvent> RegisterPlayerUnitSpellFinish;
    public static Event<LuaObject, IRegisterSpellEvent> RegisterPlayerUnitSpellEndCast;
}

#pragma warning restore CS8618 // Non-nullable field must contain a non-null value when exiting constructor. Consider adding the 'required' modifier or declaring as nullable.
