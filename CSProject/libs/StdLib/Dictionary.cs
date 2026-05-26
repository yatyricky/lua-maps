#nullable enable
#pragma warning disable CS8981, CS1591

using System;
using SFLib.Interop;

namespace StdLib;

/// <summary>
/// A basic dictionary backed by a Lua table with direct key access.
/// C# indexer (dict[key]) maps to direct table field access via get_Item/set_Item.
/// </summary>
public partial class Dictionary<K, V>
{
}
