using SFLib.Contracts;

public struct Quaternion : IEquatable<Quaternion>
{
    public static Vector3 operator *(Quaternion q, Vector3 v)
    {
        // https://en.wikipedia.org/wiki/Quaternions_and_spatial_rotation#Using_quaternion_as_rotations
        var u = new Vector3(q.x, q.y, q.z);
        var s = q.w;

        return 2.0f * Vector3.Dot(u, v) * u
             + (s * s - Vector3.Dot(u, u)) * v
             + 2.0f * s * Vector3.Cross(u, v);
    }

    public static Quaternion Euler(float pitch, float yaw, float roll)
    {
        // https://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles#Source_Code_2
        var cy = math.cos(yaw * 0.5f);
        var sy = math.sin(yaw * 0.5f);
        var cp = math.cos(pitch * 0.5f);
        var sp = math.sin(pitch * 0.5f);
        var cr = math.cos(roll * 0.5f);
        var sr = math.sin(roll * 0.5f);

        return new Quaternion
        {
            w = cr * cp * cy + sr * sp * sy,
            x = sr * cp * cy - cr * sp * sy,
            y = cr * sp * cy + sr * cp * sy,
            z = cr * cp * sy - sr * sp * cy
        };
    }

    public float x;
    public float y;
    public float z;
    public float w;

    public Quaternion(float x, float y, float z, float w)
    {
        this.x = x;
        this.y = y;
        this.z = z;
        this.w = w;
    }

    public bool Equals(Quaternion other)
    {
        return math.abs(x - other.x) < 0.0001f && math.abs(y - other.y) < 0.0001f && math.abs(z - other.z) < 0.0001f && math.abs(w - other.w) < 0.0001f;
    }

    public override string ToString()
    {
        return $"({x}, {y}, {z}, {w})";
    }
}