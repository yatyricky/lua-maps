using SFLib.Collections;

public class Stack<T>
{
    private List<T> _items = new List<T>();

    public void Push(T item)
    {
        _items.Add(item);
    }

    public T Pop()
    {
        if (_items.Count == 0)
        {
            BJDebugMsg("Stack is empty.");
        }
        var item = _items[_items.Count - 1];
        _items.RemoveAt(_items.Count - 1);
        return item;
    }

    public T Peek()
    {
        if (_items.Count == 0)
        {
            BJDebugMsg("Stack is empty.");
        }
        return _items[_items.Count - 1];
    }

    public int Count => _items.Count;
}
