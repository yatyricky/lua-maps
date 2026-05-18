using SFLib.Collections;

public class GameObject
{
    public string name { get; private set; }
    public Transform transform { get; private set; }
    private List<Component> _components = new List<Component>();

    public GameObject(string name)
    {
        this.name = name;
        transform = AddComponent<Transform>();
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
        var comp = new T();
        _components.Add(comp);
        return comp;
    }

    public void RemoveComponent<T>() where T : Component
    {
        _components.RemoveAll(c => c is T);
    }
}
