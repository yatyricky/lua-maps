using System;
using SFLib.Collections;

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

    public static void ExBlzSetAbilityIcon(player p, int abilCode, string iconPath)
    {
        if (GetLocalPlayer() != p) return;
        BlzSetAbilityIcon(abilCode, iconPath);
    }

    public static List<unit> CsGroupGetUnitsInRange(float x, float y, float radius, Predicate<unit> filter)
    {
        var result = new List<unit>();
        ExGroupEnumUnitsInRange(x, y, radius, u =>
        {
            if (filter(u))
            {
                result.Add(u);
            }
        });
        return result;
    }
}
