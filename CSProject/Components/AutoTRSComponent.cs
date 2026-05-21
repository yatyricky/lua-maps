public class AutoTRSComponent : Component
{
    public Quaternion rotation = Quaternion.identity;

    public override void Update()
    {
        var trs = gameObject.transform;
        trs.localRotation = rotation * trs.localRotation;
    }
}