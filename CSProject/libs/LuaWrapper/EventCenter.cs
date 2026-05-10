using System;
using SFLib.Interop;

namespace LuaWrapper;

#pragma warning disable CS8618 // Non-nullable field must contain a non-null value when exiting constructor. Consider adding the 'required' modifier or declaring as nullable.

#region SpellSystem

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

#endregion

#region DamageSystem

[Lua(TableLiteral = true)]
public class IDamageDataResult
{
    public HitResult hitResult;
    public float damage;
}

[Lua(TableLiteral = true)]
public class IDamageData
{
    public unit whichUnit;
    public unit target;
    public float amount;
    public bool attack;
    public bool ranged;
    public attacktype attackType;
    public damagetype damageType;
    public weapontype weaponType;
    public IDamageDataResult outResult;
}

[Lua(TableLiteral = true)]
public class IHealData
{
    public unit caster;
    public unit target;
    public float amount;
}

[Lua(TableLiteral = true)]
public class IHealManaData
{
    public unit caster;
    public unit target;
    public float amount;
    public bool isPercentage;
}

[Lua(TableLiteral = true)]
public class IPlayerUnitAttackMissData
{
    public unit caster;
    public unit target;
}

#endregion

[Lua(Module = "Lib.EventCenter")]
public class EventCenter : LuaObject
{
    public static Event<LuaObject, IRegisterSpellEvent> RegisterPlayerUnitSpellChannel;
    public static Event<LuaObject, IRegisterSpellEvent> RegisterPlayerUnitSpellCast;
    public static Event<LuaObject, IRegisterSpellEvent> RegisterPlayerUnitSpellEffect;
    public static Event<LuaObject, IRegisterSpellEvent> RegisterPlayerUnitSpellFinish;
    public static Event<LuaObject, IRegisterSpellEvent> RegisterPlayerUnitSpellEndCast;

    public static Event<LuaObject, Action<unit, unit, float, weapontype, damagetype, bool>> RegisterPlayerUnitDamaging;
    public static Event<LuaObject, Action<unit, unit, float, weapontype, damagetype, bool>> RegisterPlayerUnitDamaged;
    public static Event<LuaObject, IDamageData> Damage;
    public static Event<LuaObject, IHealData> Heal;
    public static Event<LuaObject, IHealManaData> HealMana;
    public static Event<LuaObject, IPlayerUnitAttackMissData> PlayerUnitAttackMiss;
}

#pragma warning restore CS8618 // Non-nullable field must contain a non-null value when exiting constructor. Consider adding the 'required' modifier or declaring as nullable.
