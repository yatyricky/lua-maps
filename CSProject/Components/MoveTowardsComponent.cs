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

    public override void Update()
    {
        var currentPosition = gameObject.transform.position;
        var targetPosition = targetType == TargetType.Unit ? Vector3.FromUnit(unitTarget!) : pointTarget;
        var moved = Vector3.MoveTowards(currentPosition, targetPosition, speed * Scene.DT / 1000f);
        gameObject.transform.position = moved;
        if (lookAtTarget)
        {
            gameObject.transform.rotation = Quaternion.LookRotation(targetPosition - currentPosition);
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