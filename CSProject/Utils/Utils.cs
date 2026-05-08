public class Utils
{
    public static void ExSetAbilityResearchTooltip(player p, int abilCode, string researchTooltip, int level)
    {
        if (GetLocalPlayer() != p) return;
        BlzSetAbilityResearchTooltip(abilCode, researchTooltip, level);
    }

    public static void ExBlzSetAbilityResearchExtendedTooltip(player p, int abilCode, string researchExtendedTooltip, int level)
    {
        if (GetLocalPlayer() != p) return;
        BlzSetAbilityResearchExtendedTooltip(abilCode, researchExtendedTooltip, level);
    }

    public static void ExBlzSetAbilityTooltip(player p, int abilCode, string tooltip, int level)
    {
        if (GetLocalPlayer() != p) return;
        BlzSetAbilityTooltip(abilCode, tooltip, level);
    }

    public static void ExBlzSetAbilityExtendedTooltip(player p, int abilCode, string extendedTooltip, int level)
    {
        if (GetLocalPlayer() != p) return;
        BlzSetAbilityExtendedTooltip(abilCode, extendedTooltip, level);
    }
}
