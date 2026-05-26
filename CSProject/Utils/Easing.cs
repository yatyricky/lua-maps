using SFLib.Interop;

public class Easing
{
    public static float Linear(float t)
    {
        return t;
    }

    public static float OutQubic(float t)
    {
        return 1 - math.pow(1 - t, 3);
    }
}