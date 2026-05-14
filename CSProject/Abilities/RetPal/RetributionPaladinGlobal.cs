using SFLib.Collections;
using SFLib.Async;
using LuaWrapper;

public class RetributionPaladinGlobal
{
    public static RetributionPaladinGlobal Instance { get; } = new RetributionPaladinGlobal();

    private List<unit> _units = new();

    public void Init()
    {
        ExTriggerRegisterNewUnit(_units.Add);
        _ = Start();
    }

    private async Task Start()
    {
        while (true)
        {
            foreach (var u in _units)
            {
                var attr = UnitAttribute.GetAttr(u);
            }

            await Task.Delay(100);
        }
    }

}