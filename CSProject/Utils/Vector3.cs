using LuaWrapper;
using SFLib.Contracts;

public enum UnitVec3Mode
{
    ForceFlying,
    ForceGround,
    /// <summary>
    /// Flying units fly, ground units grounded.
    /// </summary>
    Auto,
}

#pragma warning disable CS0660 // Type defines operator == or operator != but does not override Object.Equals(object o)
#pragma warning disable CS0661 // Type defines operator == or operator != but does not override Object.GetHashCode()
public struct Vector3 : IEquatable<Vector3>
{
    private static location _loc = Location(0, 0);
    private static float GetTerrainZ(float x, float y)
    {
        MoveLocation(_loc, x, y);
        return GetLocationZ(_loc);
    }

    public static Vector3 FromUnit(unit u)
    {
        var x = GetUnitX(u);
        var y = GetUnitY(u);
        return new Vector3(x, y, GetTerrainZ(x, y) + GetUnitFlyHeight(u));
    }

    public float x;
    public float y;
    public float z;

    public Vector3(float x, float y, float z)
    {
        this.x = x;
        this.y = y;
        this.z = z;
    }

    public void UnitMoveTo(unit u, UnitVec3Mode mode = UnitVec3Mode.Auto)
    {
        var tz = GetTerrainZ(x, y);
        var defaultFlyHeight = GetUnitDefaultFlyHeight(u);
        var minZ = tz + defaultFlyHeight;
        SetUnitPosition(u, x, y);
        switch (mode)
        {
            case UnitVec3Mode.ForceFlying:
                LuaUtils.SetUnitFlyable(u);
                SetUnitFlyHeight(u, math.max(minZ, z) - minZ, 0f);
                break;
            case UnitVec3Mode.ForceGround:
                SetUnitFlyHeight(u, defaultFlyHeight, 0f);
                break;
            case UnitVec3Mode.Auto:
                if (IsUnitType(u, UNIT_TYPE_FLYING))
                {
                    SetUnitFlyHeight(u, math.max(minZ, z) - minZ, 0f);
                }
                else
                {
                    SetUnitFlyHeight(u, defaultFlyHeight, 0f);
                }
                break;
        }
    }

    public bool Equals(Vector3 other)
    {
        return true;
    }
}

#pragma warning restore CS0661 // Type defines operator == or operator != but does not override Object.GetHashCode()
#pragma warning restore CS0660 // Type defines operator == or operator != but does not override Object.Equals(object o)