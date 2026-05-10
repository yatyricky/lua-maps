#pragma warning disable CA1050 // Declare types in namespaces
#pragma warning disable CS8981 // The type name only contains lower-cased ascii characters. Such names may become reserved for the language.
#pragma warning disable CS8597 // Thrown value may be null.
using SFLib.Interop;

public class math : LuaObject
{ 
    public static float abs(float value) => throw null;
}

#pragma warning restore CS8597 // Thrown value may be null.
#pragma warning restore CS8981 // The type name only contains lower-cased ascii characters. Such names may become reserved for the language.
#pragma warning restore CA1050 // Declare types in namespaces
