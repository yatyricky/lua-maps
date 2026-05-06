public class Utils
{
    public static void ExSetAbilityResearchTooltip(player p, int abilCode, string researchTooltip, int level)
    {
        if (GetLocalPlayer() == p)
        {
            BlzSetAbilityResearchTooltip(abilCode, researchTooltip, level);
            BJDebugMsg("update tooltip for ");
        }
    }
}
