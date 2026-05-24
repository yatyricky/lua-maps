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
public class List<T>
{
    private LuaObject _items;
    private int _version;

    public int Count { get; private set; }

    /// <summary>
    /// Sentinel value representing nil in the Lua table.
    /// Lua tables cannot store nil, so nil values are replaced with this placeholder.
    /// </summary>
    public static T Nil = (T)(object)LuaInterop.CreateTable();

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
            table.insert(_items, Wrap(item));
            Count++;
        }
    }

    public T this[int index]
    {
        get
        {
            if (index < 0 || index >= Count) throw new Exception("Index out of range");
            return Unwrap(LuaInterop.Get<T>(_items, index + 1));
        }
        set
        {
            if (index < 0 || index >= Count) throw new Exception("Index out of range");
            LuaInterop.Set(_items, index + 1, Wrap(value));
        }
    }

    public void Add(T item)
    {
        table.insert(_items, Wrap(item));
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
        return IndexOf(item, null);
    }

    public int IndexOf(T item, Func<T, T, bool>? equals)
    {
        var wrapped = Wrap(item);
        for (var i = 0; i < Count; i++)
        {
            var current = LuaInterop.Get<T>(_items, i + 1);
            if (equals != null)
            {
                if (equals(Unwrap(current), item)) return i;
            }
            else
            {
                if (LuaInterop.Equals(current, wrapped)) return i;
            }
        }

        return -1;
    }

    public void Sort()
    {
        Sort(null);
    }

    public void Sort(Func<T, T, int>? comparison)
    {
        for (var i = 1; i < Count; i++)
        {
            var value = LuaInterop.Get<T>(_items, i + 1);
            var j = i - 1;
            while (j >= 0)
            {
                var current = LuaInterop.Get<T>(_items, j + 1);
                var cmp = comparison != null
                    ? comparison(Unwrap(value), Unwrap(current))
                    : DefaultCompare(Unwrap(value), Unwrap(current));
                if (cmp >= 0) break;
                LuaInterop.Set(_items, j + 2, current);
                j--;
            }
            LuaInterop.Set(_items, j + 2, value);
        }
        _version++;
    }

    private static T Wrap(T value)
    {
        return LuaInterop.Equals(value, default!) ? Nil : value;
    }

    private static T Unwrap(T value)
    {
        return LuaInterop.Equals(value, Nil) ? default! : value;
    }

    private static int DefaultCompare(T a, T b)
    {
        if (LuaInterop.Equals(a, b)) return 0;
        var comparable = a as IComparable<T>;
        if (comparable != null) return comparable.CompareTo(b);
        throw new Exception("No comparison defined for type");
    }

    public Enumerator GetEnumerator() => default!;

    public class Enumerator
    {
        public T Current => default!;
        public bool MoveNext() => default!;
    }
}
