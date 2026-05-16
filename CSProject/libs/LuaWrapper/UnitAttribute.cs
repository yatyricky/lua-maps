using SFLib.Collections;
using SFLib.Interop;

namespace LuaWrapper;

public class CHeroAttributeType
{
    public int Strength;
    public int Agility;
    public int Intelligent;
}

[Lua(Module = "Objects.UnitAttribute")]
public class UnitAttribute : LuaObject
{
#pragma warning disable CS8597 // Thrown value may be null.
    public static CHeroAttributeType HeroAttributeType => throw null;
    public static UnitAttribute GetAttr(unit u) => throw null;

    public unit owner;
    public int baseAtk;
    public int baseHp;
    public float baseMs;
    public float atk;
    public int hp;
    public float ms;
    public float msp;
    public float dodge;
    public float damageAmplification;
    public float damageReduction;
    public float healingTaken;
    public List<unit> taunted;
    public List<BuffBase> absorbShields;
    public float sanity;
    public int retPalHolyEnergy;

    public UnitAttribute(unit u) => throw null;
    public int GetHeroMainAttr(unittype type, bool ignoreBonus) => throw null;
    public int SimAttack(int type) => throw null;
    public void Commit() => throw null;
    public void TauntedBy(unit caster, float duration) => throw null;
#pragma warning restore CS8597 // Thrown value may be null.
}