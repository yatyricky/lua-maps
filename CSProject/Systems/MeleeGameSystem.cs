using LuaWrapper;
using SFLib.Interop;

namespace Systems;

[Lua(Class = "MeleeGameSystem")]
public class MeleeGameSystem : SystemBase
{
    public MeleeGameSystem()
    {
        MeleeStartingVisibility();
        MeleeStartingHeroLimit();
        MeleeGrantHeroItems();
        MeleeStartingResources();
        MeleeClearExcessUnits();
        MeleeStartingUnits();
        MeleeStartingAI();
        MeleeInitVictoryDefeat();
    }
}
