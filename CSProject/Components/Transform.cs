using System.Collections.Generic;

public class Transform : Component
{
    public Vector3 position;
    public Quaternion rotation;
    public Vector3 scale;

    public List<Transform> children = new List<Transform>();
    public Transform? parent { get; private set; }

    public Transform()
    {
        position = new Vector3(0f, 0f, 0f);
        rotation = Quaternion.Euler(0f, 0f, 0f);
        scale = new Vector3(1f, 1f, 1f);
    }

    public void SetParent(Transform newParent)
    {
        if (parent != null)
        {
            parent.children.Remove(this);
        }

        parent = newParent;

        if (parent != null)
        {
            parent.children.Add(this);
        }
    }
}
