#pragma warning disable CS8981 // The type name only contains lower-cased ascii characters. Such names may become reserved for the language.
#pragma warning disable CS8597 // Thrown value may be null.
namespace SFLib.Interop;

public partial class math : LuaObject
{ 
    public static bool fuzzyEquals(float a, float b, float epsilon = 1e-6f) => throw null;
    public static float bezier3(float t, float c1, float c2, float c3) => throw null;
    public static float clamp(float value, float min, float max) => throw null;
    public static float clamp01(float value) => throw null;
    public static int round(float value) => throw null;
    public static int sign(float value) => throw null;
    public static float lerp(float a, float b, float t) => throw null;
    public static float moveTowards(float current, float target, float maxDelta) => throw null;
}

#pragma warning restore CS8597 // Thrown value may be null.
#pragma warning restore CS8981 // The type name only contains lower-cased ascii characters. Such names may become reserved for the language.
