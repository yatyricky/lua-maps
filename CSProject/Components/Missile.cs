using System;
using StdLib;
using SFLib.Interop;

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
    None,
}

public class Missile : Component
{
    public TargetType targetType;
    public unit? unitTarget;
    public Vector3 pointTarget;
    public float speed;
    public bool lookAtTarget = false;
    public float colliderSize;
    public Action<Missile, unit>? onArrivedUnit;
    public Action<Missile, Vector3>? onArrivedPoint;
    public Action<Missile, unit>? onThrough;
    public Predicate<unit>? onThroughFilter;
    public Action? onLostTarget;
    public int collisionCount = 1;
    /// <summary>
    /// unit: s
    /// The delay between each hit when colliding with the same unit.
    /// Lower this value to hit the same unit multiple times in a short period.
    /// </summary>
    public double nextHitDelay = 9999f;
    private Dictionary<unit, double> _hitUnits = new();
    private bool hasArrived = true;

    public override void Update()
    {
        if (hasArrived) return;

        // Move
        var cPos = gameObject.transform.position;
        var tPos = pointTarget;
        if (targetType == TargetType.Unit || targetType == TargetType.Point)
        {
            if (targetType == TargetType.Unit)
            {
                if (unitTarget == null || ExIsUnitDead(unitTarget))
                {
                    OnDisappear();
                    return;
                }
                tPos = Vector3.FromUnit(unitTarget);
            }
            if (lookAtTarget)
            {
                gameObject.transform.localRotation = Quaternion.LookRotation(tPos - cPos);
            }
            cPos = Vector3.MoveTowards(cPos, tPos, speed * Scene.DT / 1000f);
            gameObject.transform.position = cPos;
        }

        // Collision
        var now = os.clock();
        if (onThrough != null)
        {
            ExGroupEnumUnitsInRange(cPos.x, cPos.y, colliderSize, u =>
            {
                if (onThroughFilter != null && !onThroughFilter(u)) return;
                if (collisionCount <= 0) return;

                bool nhdPass;
                if (_hitUnits.TryGetValue(u, out var lastHitTime))
                {
                    nhdPass = now - lastHitTime >= nextHitDelay;
                }
                else
                {
                    nhdPass = true;
                }
                if (!nhdPass) return;

                _hitUnits[u] = now;
                collisionCount--;
                onThrough.Invoke(this, u);
            });
        }

        if (targetType != TargetType.None)
        {
            if (Vector3.Distance(cPos, tPos) <= 0.001f)
            {
                hasArrived = true;
                if (onArrivedUnit != null && targetType == TargetType.Unit)
                {
                    _hitUnits[unitTarget!] = now;
                    collisionCount--;
                    onArrivedUnit.Invoke(this, unitTarget!);
                }
                if (onArrivedPoint != null && targetType == TargetType.Point)
                {
                    onArrivedPoint.Invoke(this, pointTarget);
                }
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
onArrived: {(onArrivedUnit == null ? "None" : "Set")}
hasArrived: {hasArrived}
";
    }

    public void SetupUnitTarget(unit target, float speed, Action<Missile, unit> onArrived, float colliderSize = 32f, bool lookAtTarget = true)
    {
        targetType = TargetType.Unit;
        unitTarget = target;
        this.speed = speed;
        this.lookAtTarget = lookAtTarget;
        this.colliderSize = colliderSize;
        onArrivedUnit = onArrived;
        hasArrived = false;
    }

    public void SetupPiercer(Action<Missile, unit> onThrough, Predicate<unit> onThroughFilter, float colliderSize, int collisionCount, double nextHitDelay)
    {
        targetType = TargetType.None;
        unitTarget = null;
        this.colliderSize = colliderSize;
        this.onThrough = onThrough;
        this.onThroughFilter = onThroughFilter;
        this.collisionCount = collisionCount;
        this.nextHitDelay = nextHitDelay;
        hasArrived = false;
    }

    private void OnDisappear()
    {
        hasArrived = true;
        onLostTarget?.Invoke();
    }
}