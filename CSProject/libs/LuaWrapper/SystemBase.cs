namespace LuaWrapper;

using SFLib.Interop;

[Lua(Module = "System.SystemBase")]
public class SystemBase : LuaObject
{
    [Lua(StaticMethod = "new")]
    public SystemBase() {}
    public virtual void Awake() { }
    public virtual void OnEnable() { }
    public virtual void Update(float dt) { }
    public virtual void OnDisable() { }
    public virtual void OnDestroy() { }
}
