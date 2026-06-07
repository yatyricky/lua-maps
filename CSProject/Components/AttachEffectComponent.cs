public class AttachEffectComponent : Component
{
    private Vector3 _lastPos;
    private float _lerpDuration;
    private float _lerpElapsed;
    private Vector3 _tarPos;
    public effect? eff;

    public override string GetInspectorText()
    {
        return @$"Effect: {(eff == null ? "None" : "Attached")}
_tarPos: {_tarPos}";
    }

    public override void Update()
    {
        if (eff == null) return;

        // calculate global TRS from transform and ancestor transforms
        var globalPos = gameObject.transform.localPosition;
        var globalRot = gameObject.transform.localRotation;
        var globalScale = gameObject.transform.localScale;
        var parent = gameObject.transform.parent;
        while (parent != null)
        {
            globalPos = parent.localPosition + parent.localRotation * Vector3.Scale(parent.localScale, globalPos);
            globalRot = parent.localRotation * globalRot;
            globalScale = Vector3.Scale(parent.localScale, globalScale);
            parent = parent.parent;
        }

        _lerpElapsed += Scene.DT;
        _tarPos = globalPos;
        if (_lerpElapsed < _lerpDuration)
        {
            _tarPos = Vector3.Lerp(_lastPos, globalPos, _lerpElapsed / _lerpDuration);
        }
        BlzSetSpecialEffectPosition(eff, _tarPos.x, _tarPos.y, _tarPos.z);
        _lastPos = _tarPos;
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

    public void AttachEffect(effect eff)
    {
        this.eff = eff;
        _lastPos = new Vector3(BlzGetLocalSpecialEffectX(eff), BlzGetLocalSpecialEffectY(eff), BlzGetLocalSpecialEffectZ(eff));
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="duration">ms</param>
    public void LerpIn(float duration)
    {
        if (eff == null) return;

        _lerpDuration = duration;
        _lerpElapsed = 0;
    }
}