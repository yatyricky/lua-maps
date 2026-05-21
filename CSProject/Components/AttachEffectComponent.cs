public class AttachEffectComponent : Component
{
    public effect? eff;

    public override string GetInspectorText()
    {
        return "Effect: " + (eff == null ? "None" : "Attached");
    }

    public override void Update()
    {
        if (eff == null) return;

        // calculate global TRS from transform and ancestor transforms
        var globalPos = gameObject.transform.position;
        var globalRot = gameObject.transform.rotation;
        var globalScale = gameObject.transform.localScale;
        var parent = gameObject.transform.parent;
        while (parent != null)
        {
            globalPos = parent.position + parent.rotation * Vector3.Scale(parent.localScale, globalPos);
            globalRot = parent.rotation * globalRot;
            globalScale = Vector3.Scale(parent.localScale, globalScale);
            parent = parent.parent;
        }

        BlzSetSpecialEffectPosition(eff, globalPos.x, globalPos.y, globalPos.z);
        globalRot.ApplyToEffect(eff);
        BlzSetSpecialEffectMatrixScale(eff, globalScale.x, globalScale.y, globalScale.z);
    }

    public override void OnDestroy()
    {
        if (eff != null)
        {
            DestroyEffect(eff);
            eff = null;
        }
    }
}