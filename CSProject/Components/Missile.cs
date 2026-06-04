using System;

public enum TargetType
{
    /// <summary>
    /// Move towards a unit.
    /// </summary>
    Unit,
    /// <summary>
    /// Move towards a point.
    /// </summary>
    Point,
    /// <summary>
    /// No movement.
    /// </summary>
    Passive,
}

public enum CollisionType
{
    /// <summary>
    /// Invoke onArrived when the missile reaches the target point or unit.
    /// </summary>
    WhenArrived,
    /// <summary>
    /// Invoke onArrived when the missile collides with any unit within colliderSize, regardless of whether it has reached the target point or unit. If the missile is set to lookAtTarget, it will be destroyed upon collision. Otherwise, it will continue moving until it reaches the target point or unit, but onArrived will only be invoked once. If you want to invoke onArrived multiple times for each collision, you can set onArrived to null after the first invocation and handle subsequent collisions in the Update method. Note that if the missile is set to lookAtTarget, it will be destroyed upon collision and will not continue moving or invoking onArrived for subsequent collisions.
    /// </summary>
    WhenMoving,
}

public class Missile : Component
{
    public TargetType targetType;
    public CollisionType collisionType = CollisionType.WhenArrived;
    public unit? unitTarget;
    public Vector3 pointTarget;
    public float speed;
    public bool lookAtTarget = false;
    public Action? onCollision;
    public float colliderSize;
    public int collisionCount = 1;
    /// <summary>
    /// The delay between each hit when colliding with the same unit.
    /// Lower this value to hit the same unit multiple times in a short period.
    /// </summary>
    public float nextHitDelay = 9999f;
    private bool hasArrived = false;

    public override void Update()
    {
        if (hasArrived) return;

        var currentPosition = gameObject.transform.position;
        var targetPosition = pointTarget;
        if (targetType == TargetType.Unit || targetType == TargetType.Point)
        {
            if (targetType == TargetType.Unit)
            {
                if (unitTarget == null) return;
                if (ExIsUnitDead(unitTarget))
                {
                    OnDisappear();
                    return;
                }
                targetPosition = Vector3.FromUnit(unitTarget);
            }
            if (lookAtTarget)
            {
                gameObject.transform.localRotation = Quaternion.LookRotation(targetPosition - currentPosition);
            }
            currentPosition = Vector3.MoveTowards(currentPosition, targetPosition, speed * Scene.DT / 1000f);
            gameObject.transform.position = currentPosition;
        }

        if (collisionType == CollisionType.WhenMoving)
        {

        }
        else if (collisionType == CollisionType.WhenArrived)
        {
            if (Vector3.Distance(currentPosition, targetPosition) <= colliderSize && !hasArrived)
            {
                OnCollision(true);
            }
        }
    }

    public override string GetInspectorText()
    {
        return @$"targetType: {targetType}
unitTarget: {(unitTarget == null ? "None" : GetUnitName(unitTarget))}
pointTarget: {pointTarget}
speed: {speed}
lookAtTarget: {lookAtTarget}
colliderSize: {colliderSize}
onArrived: {(onCollision == null ? "None" : "Set")}
hasArrived: {hasArrived}
";
    }

    private void OnCollision(bool arrived)
    {
        hasArrived = arrived;
        onCollision?.Invoke();
        if (arrived)
        {
            onCollision = null;
        }
    }

    private void OnDisappear()
    {
        hasArrived = true;
        onCollision = null;
    }
}