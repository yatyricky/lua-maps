using StdLib;

public class UnitManager : Component
{
    private Dictionary<unit, GameObject> _map = new Dictionary<unit, GameObject>();
    public static UnitManager? Instance { get; private set; }
    private static int unitCounter = 0;

    public override void Awake()
    {
        if (Instance != null)
        {
            Instance.gameObject.Destroy();
        }
        Instance = this;
    }

    public static GameObject GetGameObjectByUnit(unit u)
    {
        if (Instance == null)
        {
            throw new System.Exception("This is weird");
        }
        if (Instance._map.TryGetValue(u, out var obj))
        {
            return obj;
        }
        obj = new GameObject($"Unit_{GetUnitName(u)}_{unitCounter++}", Instance.gameObject);
        Instance._map[u] = obj;
        obj.AddComponent<AttachUnitComponent>().SetUnit(u);
        return obj;
    }
}
