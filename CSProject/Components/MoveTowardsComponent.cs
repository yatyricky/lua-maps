using System;

public enum TargetType
{
    Unit,
    Point,
}

public class MoveTowardsComponent : Component
{
    public TargetType targetType;
    public unit? unitTarget;
    public Vector3 pointTarget;
    public float speed;
    public bool lookAtTarget = false;
    public Action? onArrived;
    public float colliderSize;
    private bool hasArrived = false;

    public override void Update()
    {
        if (hasArrived) return;

        var currentPosition = gameObject.transform.localPosition;
        var targetPosition = targetType == TargetType.Unit ? Vector3.FromUnit(unitTarget!) : pointTarget;
        var moved = Vector3.MoveTowards(currentPosition, targetPosition, speed * Scene.DT / 1000f);
        gameObject.transform.localPosition = moved;
        if (lookAtTarget)
        {
            gameObject.transform.localRotation = Quaternion.LookRotation(targetPosition - currentPosition);
        }

        if (Vector3.Distance(moved, targetPosition) <= colliderSize && !hasArrived)
        {
            hasArrived = true;
            onArrived?.Invoke();
            onArrived = null;
        }
    }

    public override string GetInspectorText()
    {
        return @$"targetType: {targetType}
unitTarget: {(unitTarget == null ? "None" : GetUnitName(unitTarget))}
pointTarget: {pointTarget}
speed: {speed}
";
    }
}