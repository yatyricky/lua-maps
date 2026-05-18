using SFLib.Contracts;

#pragma warning disable CS0660 // Type defines operator == or operator != but does not override Object.Equals(object o)
#pragma warning disable CS0661 // Type defines operator == or operator != but does not override Object.GetHashCode()
public struct Vector2 : IEquatable<Vector2>
{
    public static Vector2 Zero => new(0, 0);

    private static location _loc = Location(0, 0);

    public static Vector2 InsideUnitCircle()
    {
        var angle = math.random() * 2 * math.pi;
        return new Vector2(math.cos(angle), math.sin(angle));
    }

    public static float Dot(Vector2 a, Vector2 b)
    {
        return a.x * b.x + a.y * b.y;
    }

    public static float Cross(Vector2 a, Vector2 b)
    {
        return a.y * b.x - a.x * b.y;
    }

    public static Vector2 operator -(Vector2 a)
    {
        return new Vector2(-a.x, -a.y);
    }

    public static Vector2 operator +(Vector2 a, Vector2 b)
    {
        return new Vector2(a.x + b.x, a.y + b.y);
    }

    public static Vector2 operator -(Vector2 a, Vector2 b)
    {
        return new Vector2(a.x - b.x, a.y - b.y);
    }

    public static Vector2 operator *(Vector2 v, float f)
    {
        return new Vector2(v.x * f, v.y * f);
    }

    public static Vector2 operator *(float f, Vector2 v)
    {
        return new Vector2(v.x * f, v.y * f);
    }

    public static Vector2 operator /(Vector2 v, float f)
    {
        return new Vector2(v.x / f, v.y / f);
    }

    public static bool operator ==(Vector2 a, Vector2 b)
    {
        return math.abs(a.x - b.x) < 0.0001f && math.abs(a.y - b.y) < 0.0001f;
    }

    public static bool operator !=(Vector2 a, Vector2 b)
    {
        return !(a == b);
    }

    public static float UnitDistance(unit a, unit b)
    {
        var v1 = FromUnit(a);
        var v2 = FromUnit(b);
        return (v1 - v2).Magnitude;
    }

    public static float SqrUnitDistance(unit a, unit b)
    {
        var v1 = FromUnit(a);
        var v2 = FromUnit(b);
        return (v1 - v2).SqrMagnitude;
    }

    public static Vector2 FromUnit(unit u)
    {
        return new Vector2(GetUnitX(u), GetUnitY(u));
    }

    public float x;
    public float y;

    public float Magnitude => math.sqrt(SqrMagnitude);
    public float SqrMagnitude => x * x + y * y;

    public Vector2 Normalized
    {
        get
        {
            var mag = Magnitude;
            if (mag < 0.0001f) return Zero;
            return this / mag;
        }
    }

    public Vector2(float x, float y)
    {
        this.x = x;
        this.y = y;
    }

    public Vector2 ClampMagnitude(float mag)
    {
        return Normalized * mag;
    }

    public bool Equals(Vector2 other)
    {
        return this == other;
    }

    public override string ToString()
    {
        return $"({x}, {y})";
    }

    public Vector2 Rotate(float angle)
    {
        var cos = math.cos(angle);
        var sin = math.sin(angle);
        return new Vector2(x * cos - y * sin, x * sin + y * cos);
    }

    public void UnitMoveTo(unit u)
    {
        SetUnitX(u, x);
        SetUnitY(u, y);
    }

    public float GetTerrainZ()
    {
        MoveLocation(_loc, x, y);
        return GetLocationZ(_loc);
    }
}

#pragma warning restore CS0661 // Type defines operator == or operator != but does not override Object.GetHashCode()
#pragma warning restore CS0660 // Type defines operator == or operator != but does not override Object.Equals(object o)