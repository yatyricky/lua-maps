using System;
using System.Collections;
using System.Collections.Generic;
using SFLib.Interop;

namespace StdLib;

/// <summary>
/// A basic list backed by a Lua sequential table.
/// Uses table.insert/table.remove for array operations.
/// C# indexer (0-based) maps to Lua table (1-based) via get_Item/set_Item.
/// </summary>
public class List<T> : IIpairs<T>
{
    private LuaObject _items;
    private int _version;

    public int Count { get; private set; }

    public List()
    {
        _items = LuaInterop.CreateTable();
        _version = 0;
        Count = 0;
    }

    public List(List<T> collection) : this()
    {
        foreach (var item in collection)
        {
            table.insert(_items, item);
            Count++;
        }
    }

    public T this[int index]
    {
        get
        {
            if (index < 0 || index >= Count) throw new Exception("Index out of range");
            return LuaInterop.Get<T>(_items, index + 1);
        }
        set
        {
            if (index < 0 || index >= Count) throw new Exception("Index out of range");
            LuaInterop.Set(_items, index + 1, value);
        }
    }

    public void Add(T item)
    {
        table.insert(_items, item);
        Count++;
        _version++;
    }

    public void Clear()
    {
        _items = LuaInterop.CreateTable();
        Count = 0;
        _version++;
    }

    public bool Remove(T item)
    {
        var index = IndexOf(item);
        if (index < 0) return false;
        RemoveAt(index);
        return true;
    }

    public void RemoveAt(int index)
    {
        table.remove(_items, index + 1);
        Count--;
        _version++;
    }

    public int IndexOf(T item)
    {
        for (var i = 0; i < Count; i++)
        {
            var current = LuaInterop.Get<T>(_items, i + 1);
            if (LuaInterop.Eq(current, item)) return i;
        }

        return -1;
    }

    private static int DefaultCompare(T a, T b)
    {
        if (LuaInterop.Eq(a, b)) return 0;
        if (LuaInterop.Lt(a, b)) return -1;
        return 1;
    }

    public void Sort(Func<T, T, int>? comparison)
    {
        comparison ??= DefaultCompare;

        for (var i = 1; i < Count; i++)
        {
            var value = LuaInterop.Get<T>(_items, i + 1);
            var j = i - 1;
            while (j >= 0)
            {
                var current = LuaInterop.Get<T>(_items, j + 1);
                var cmp = comparison(value, current);
                if (cmp >= 0) break;
                LuaInterop.Set(_items, j + 2, current);
                j--;
            }
            LuaInterop.Set(_items, j + 2, value);
        }
        _version++;
    }

    public Func<(int, T)> IpairsNext(LuaObject table)
    {
        var version = _version;
        var index = 0;
        return () =>
        {
            if (version != _version) throw new Exception("Collection was modified");
            index++;
            var value = LuaInterop.Get<T>(table, index);
            if (value == null) return (0, default!);
            return (index, value);
        };
    }

    public Enumerator GetEnumerator() => default!;

    public class Enumerator
    {
        public T Current => default!;
        public bool MoveNext() => default!;
    }
}
