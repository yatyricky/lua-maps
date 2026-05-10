using System;
using SFLib.Interop;
using SFLib.Collections;

[Lua(TableLiteral = true)]
public class IColor : LuaObject
{
    public float r;
    public float g;
    public float b;
    public float a = 1f;
}

public static partial class JASS
{
    public static void ExTriggerAddAction(trigger trigger, Action action) => throw null!;
    public static void ExGroupEnumUnitsInRange(float x, float y, float radius, Action<unit> callback) => throw null!;
    public static void ExGroupEnumUnitsInMap(Action<unit> callback) => throw null!;
    public static List<unit> ExGroupGetUnitsInRange(float x, float y, float radius, Action<unit> filter) => throw null!;
    public static void ExAddSpecialEffectTarget(string modelName, unit target, string attachPoint, float duration) => throw null!;
    public static effect ExAddSpecialEffect(string modelName, float x, float y, float duration, IColor color) => throw null!;
    public static void ExAddLightningPosPos(string modelName, float x1, float y1, float z1, float x2, float y2, float z2, float duration, IColor color, bool check) => throw null!;
    public static Tuple<lightning, LuaObject> ExAddLightningUnitUnit(string modelName, unit unit1, unit unit2, float duration, IColor color, bool checkVisibility) => throw null!;
    public static void ExAddLightningPosUnit(string modelName, float x1, float y1, float z1, unit unit2, float duration, IColor color, bool check) => throw null!;
    public static void ExTriggerRegisterUnitAcquire(Action<unit, unit> callback) => throw null!;
    public static void ExTriggerRegisterNewUnitExec(unit u) => throw null!;
    public static void ExTriggerRegisterNewUnit(Action<unit> callback) => throw null!;
    public static bool ExIsUnitDead(unit u) => throw null!;
    public static void ExTriggerRegisterUnitDeath(Action<unit> callback) => throw null!;
    public static void ExTriggerRegisterUnitLearn(int id, Action<unit, int, int> callback) => throw null!;
    public static string GetStackTrace(bool oneline_yn) => throw null!;
    public static void PrintStackTrace() => throw null!;
    public static void ExTextTag(unit whichUnit, float dmg, IColor color) => throw null!;
    public static void ExTextCriticalStrike(unit whichUnit, float dmg) => throw null!;
    public static void ExTextMiss(unit whichUnit) => throw null!;
    public static void ExTextState(unit whichUnit, string text) => throw null!;
    public static float ExGetUnitMana(unit whichUnit) => throw null!;
    public static float ExGetUnitMaxMana(unit whichUnit) => throw null!;
    public static float ExGetUnitManaPortion(unit whichUnit) => throw null!;
    public static void ExSetUnitMana(unit whichUnit, float amount) => throw null!;
    public static void ExAddUnitMana(unit whichUnit, float amount) => throw null!;
    public static float ExGetUnitManaLoss(unit whichUnit) => throw null!;
    public static float ExGetUnitLifeLoss(unit whichUnit) => throw null!;
    public static float ExGetUnitLifePortion(unit whichUnit) => throw null!;
    public static float ExGetUnitPlayerId(unit whichUnit) => throw null!;
}