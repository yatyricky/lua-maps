#nullable enable
#pragma warning disable CS8981, CS1591

using SFLib.Interop;

namespace StdLib;

/// <summary>
/// A basic dictionary backed by a Lua table with direct key access.
/// C# indexer (dict[key]) maps to direct table field access via get_Item/set_Item.
/// </summary>
public partial class Dictionary<K, V>
{
    private LuaObject _data;
    private int _size;

    public int Count => _size;

    public V this[K key]
    {
        get => default!;
        set { }
    }

    public void Add(K key, V value)
    {
        this[key] = value;
    }

    public bool ContainsKey(K key)
    {
        return this[key] != null;
    }

    public bool Remove(K key)
    {
        if (!ContainsKey(key)) return false;
        this[key] = default!;
        _size = _size - 1;
        return true;
    }

    public void Clear()
    {
        _data = new LuaObject();
        _size = 0;
    }
}
