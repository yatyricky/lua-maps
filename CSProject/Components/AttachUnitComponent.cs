public class AttachUnitComponent : Component
{
    public unit? target { get; private set; }

    public void SetUnit(unit target)
    {
        this.target = target;
    }
}
