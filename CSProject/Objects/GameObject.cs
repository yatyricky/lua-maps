using SFLib.Collections;

public class GameObject
{
    private static void DestroyDepthFirst(GameObject obj)
    {
        foreach (var child in obj.transform.children)
        {
            DestroyDepthFirst(child.gameObject);
        }

        foreach (var comp in obj._components)
        {
            comp.OnDisable();
            comp.OnDestroy();
        }

        obj._components.Clear();
        obj.transform.SetParent(null);
        Scene.Instance.gameObjs.Remove(obj);
    }

    private static void UpdateBFS(GameObject obj)
    {
        foreach (var comp in obj._components)
        {
            comp.Update();
        }
        foreach (var child in obj.transform.children)
        {
            UpdateBFS(child.gameObject);
        }
    }

    public string name { get; private set; }
    public Transform transform { get; private set; }
    private List<Component> _components = new List<Component>();
    public List<Component> components => _components;

    public GameObject(string name)
    {
        this.name = name;
        transform = AddComponent<Transform>();

        Scene.Instance.AddGameObject(this);
    }

    public GameObject(string name, GameObject parent) : this(name)
    {
        transform.SetParent(parent.transform);
    }

    public T? GetComponent<T>() where T : Component
    {
        foreach (var comp in _components)
        {
            if (comp is T tComp)
            {
                return tComp;
            }
        }
        return null;
    }

    public T AddComponent<T>() where T : Component, new()
    {
        var comp = new T
        {
            gameObject = this
        };
        _components.Add(comp);
        comp.Awake();
        comp.OnEnable();
        comp.Start();
        return comp;
    }

    public void RemoveAllComponents<T>() where T : Component
    {
        for (int i = _components.Count - 1; i >= 0; i--)
        {
            if (_components[i] is T)
            {
                _components[i].OnDisable();
                _components[i].OnDestroy();
                _components.RemoveAt(i);
            }
        }
    }

    public void Update()
    {
        UpdateBFS(this);
    }

    public void Destroy()
    {
        DestroyDepthFirst(this);
    }
}
