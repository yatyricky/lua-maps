using SFLib.Collections;
using SFLib.Interop;

namespace LuaWrapper;

[Lua(TableLiteral = true)]
public class IAwakeData
{
    public int level;
    public int charged;
}

[Lua(Module = "Objects.BuffBase")]
public class BuffBase : LuaObject
{
#pragma warning disable CS8597 // Thrown value may be null.
    public static Dictionary<unit, List<BuffBase>> unitBuffs => throw null;
    public static T? FindBuffByClassName<T>(unit unit, string name) where T : BuffBase => throw null;

    public unit caster;
    public unit target;
    public float time;
    public float expire;
    public float duration;
    public float interval;
    public float nextUpdate;
    public int stack;
    public string icon;
    public string buffName;
    public string description;
    public IAwakeData awakeData;

    public BuffBase(unit caster, unit target, float duration, float interval, IAwakeData awakeData) => throw null;
    public void Awake() => throw null;
    public void OnEnable() => throw null;
    public void Update() => throw null;
    public void OnDisable() => throw null;
    public void OnDestroy() => throw null;
    public void ResetDuration(float exprTime) => throw null;
    public float GetTimeLeft() => throw null;
    public float GetTimeNorm() => throw null;
    /// <summary>
    /// 叠一层buff
    /// </summary>
    /// <param name="stacks"></param>
    /// <exception cref="System.NullReferenceException"></exception>
    public void IncreaseStack(int stacks) => throw null;
    public void DecreaseStack(int stacks) => throw null;
#pragma warning restore CS8597 // Thrown value may be null.
}