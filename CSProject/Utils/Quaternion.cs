using SFLib.Contracts;

public struct Quaternion : IEquatable<Quaternion>
{
    public static Quaternion Identity => new(0, 0, 0, 1);

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
        pitch *= bj_DEGTORAD;
        yaw *= bj_DEGTORAD;
        roll *= bj_DEGTORAD;

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

    public Vector3 EulerAngles
    {
        get
        {
            // https://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles#Source_Code_2
            var sinr_cosp = 2 * (w * x + y * z);
            var cosr_cosp = 1 - 2 * (x * x + y * y);
            var roll = math.atan2(sinr_cosp, cosr_cosp);

            var sinp = 2 * (w * y - z * x);
            float pitch;
            if (math.abs(sinp) >= 1)
                pitch = math.sign(sinp) * math.pi / 2; // use 90 degrees if out of range
            else
                pitch = math.asin(sinp);

            var siny_cosp = 2 * (w * z + x * y);
            var cosy_cosp = 1 - 2 * (y * y + z * z);
            var yaw = math.atan2(siny_cosp, cosy_cosp);

            return new Vector3(pitch, yaw, roll);
        }
    }

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

    public void ApplyToEffect(effect e)
    {
        var angles = EulerAngles;
        BlzSetSpecialEffectOrientation(e, angles.x, angles.y, angles.z);
    }
}