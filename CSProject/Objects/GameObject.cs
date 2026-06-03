using StdLib;

public class GameObject
{
    private static void MarkDestroyQueuedDepthFirst(GameObject obj)
    {
        if (obj.isDestroyQueued || obj.isDestroyed)
        {
            return;
        }

        obj.isDestroyQueued = true;

        foreach (var child in obj.transform.children)
        {
            MarkDestroyQueuedDepthFirst(child.gameObject);
        }
    }

    private static void DestroyDepthFirst(GameObject obj)
    {
        if (obj.isDestroyed)
        {
            return;
        }

        var children = obj.transform.children;
        for (int i = children.Count - 1; i >= 0; i--)
        {
            DestroyDepthFirst(children[i].gameObject);
        }

        obj.transform.SetParent(null);
        foreach (var comp in obj._components)
        {
            comp.OnDisable();
            comp.OnDestroy();
        }

        obj._components.Clear();
        Scene.Instance.gameObjs.Remove(obj);
        obj.isDestroyed = true;
    }


    public string name { get; private set; }
    public Transform transform { get; private set; }
    private List<Component> _components = new List<Component>();
    public List<Component> components => _components;
    public bool isDestroyQueued { get; private set; }
    public bool isDestroyed { get; private set; }

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
        if (isDestroyQueued || isDestroyed) return;
        var snapshot = new List<Component>(_components);
        foreach (var comp in snapshot) comp.Update();
    }

    public void LateUpdate()
    {
        if (isDestroyQueued || isDestroyed) return;
        var snapshot = new List<Component>(_components);
        foreach (var comp in snapshot) comp.LateUpdate();
    }

    public void Destroy()
    {
        if (isDestroyQueued || isDestroyed)
        {
            return;
        }

        MarkDestroyQueuedDepthFirst(this);
        Scene.Instance.QueueDestroy(this);
    }

    internal static void DestroyQueued(GameObject obj)
    {
        DestroyDepthFirst(obj);
    }
}
