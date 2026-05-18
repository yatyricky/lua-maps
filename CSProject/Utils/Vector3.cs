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

    public static Vector3 Zero => new(0, 0, 0);
    public static Vector3 Up => new(0, 0, 1);
    public static Vector3 Down => new(0, 0, -1);
    public static Vector3 Right => new(1, 0, 0);
    public static Vector3 Left => new(-1, 0, 0);
    public static Vector3 Forward => new(0, 1, 0);
    public static Vector3 Back => new(0, -1, 0);
    public static Vector3 One => new(1, 1, 1);

    public static Vector3 operator +(Vector3 a, Vector3 b)
    {
        return new Vector3(a.x + b.x, a.y + b.y, a.z + b.z);
    }

    public static Vector3 operator -(Vector3 a)
    {
        return new Vector3(-a.x, -a.y, -a.z);
    }

    public static Vector3 operator -(Vector3 a, Vector3 b)
    {
        return new Vector3(a.x - b.x, a.y - b.y, a.z - b.z);
    }

    public static Vector3 operator *(Vector3 v, float f)
    {
        return new Vector3(v.x * f, v.y * f, v.z * f);
    }

    public static Vector3 operator *(float f, Vector3 v)
    {
        return new Vector3(v.x * f, v.y * f, v.z * f);
    }

    public static Vector3 operator /(Vector3 v, float f)
    {
        return new Vector3(v.x / f, v.y / f, v.z / f);
    }

    public static bool operator ==(Vector3 a, Vector3 b)
    {
        return math.abs(a.x - b.x) < 0.0001f && math.abs(a.y - b.y) < 0.0001f && math.abs(a.z - b.z) < 0.0001f;
    }

    public static bool operator !=(Vector3 a, Vector3 b)
    {
        return !(a == b);
    }

    public static float Dot(Vector3 a, Vector3 b)
    {
        return a.x * b.x + a.y * b.y + a.z * b.z;
    }

    public static Vector3 Scale(Vector3 a, Vector3 b)
    {
        return new Vector3(a.x * b.x, a.y * b.y, a.z * b.z);
    }

    /// <summary>
    /// Warcraft III world space here is right-handed: +x points right, +y points away, +z points up.
    /// That means Cross((1,0,0), (0,1,0)) == (0,0,1).
    /// </summary>
    public static Vector3 Cross(Vector3 a, Vector3 b)
    {
        return new Vector3(a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x);
    }

    public static Vector3 Project(Vector3 v, Vector3 onNormal)
    {
        var sqrMag = Dot(onNormal, onNormal);
        if (sqrMag < 0.0001f)
        {
            return Zero;
        }
        var dot = Dot(v, onNormal);
        return onNormal * (dot / sqrMag);
    }

    public static Vector3 ProjectOnPlane(Vector3 v, Vector3 planeNormal)
    {
        return v - Project(v, planeNormal);
    }

    private static float _getTerrainZ(float x, float y)
    {
        MoveLocation(_loc, x, y);
        return GetLocationZ(_loc);
    }

    public static Vector3 FromUnit(unit u)
    {
        var x = GetUnitX(u);
        var y = GetUnitY(u);
        return new Vector3(x, y, _getTerrainZ(x, y) + GetUnitFlyHeight(u));
    }

    public float x;
    public float y;
    public float z;

    public float SqrMagnitude => x * x + y * y + z * z;
    public float Magnitude => math.sqrt(SqrMagnitude);

    public Vector3 Normalized
    {
        get
        {
            var mag = Magnitude;
            if (mag < 0.0001f)
            {
                return Zero;
            }
            return this / mag;
        }
    }

    public Vector3(float x, float y, float z)
    {
        this.x = x;
        this.y = y;
        this.z = z;
    }

    public Vector3 ClampMagnitude(float mag)
    {
        return Normalized * mag;
    }

    public bool Equals(Vector3 other)
    {
        return this == other;
    }

    public override string ToString()
    {
        return $"({x}, {y}, {z})";
    }

    public void UnitMoveTo(unit u, UnitVec3Mode mode = UnitVec3Mode.Auto)
    {
        var tz = _getTerrainZ(x, y);
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

    public float GetTerrainZ()
    {
        return _getTerrainZ(x, y);
    }
}

#pragma warning restore CS0661 // Type defines operator == or operator != but does not override Object.GetHashCode()
#pragma warning restore CS0660 // Type defines operator == or operator != but does not override Object.Equals(object o)