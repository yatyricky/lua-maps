public class AutoTRSComponent : Component
{
    public Quaternion rotation = Quaternion.identity;
    public unit followUnit = null!;

    public override void Update()
    {
        var trs = gameObject.transform;
        trs.localRotation = rotation * trs.localRotation;
        if (followUnit != null)
        {
            trs.localPosition = Vector3.FromUnit(followUnit);
        }
    }
}