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
    private bool hasArrived = false;

    public override void Update()
    {
        if (hasArrived) return;

        var currentPosition = gameObject.transform.position;
        var targetPosition = targetType == TargetType.Unit ? Vector3.FromUnit(unitTarget!) : pointTarget;
        var moved = Vector3.MoveTowards(currentPosition, targetPosition, speed * Scene.DT / 1000f);
        gameObject.transform.position = moved;
        if (lookAtTarget)
        {
            gameObject.transform.rotation = Quaternion.LookRotation(targetPosition - currentPosition);
        }

        if (moved == targetPosition && !hasArrived)
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