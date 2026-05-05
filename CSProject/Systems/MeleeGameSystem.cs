namespace Systems;

using LuaWrapper;
using SFLib;

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
