using SFLib.Collections;
using SFLib.Async;
using LuaWrapper;

public class RetributionPaladinGlobal
{
    public static RetributionPaladinGlobal Instance { get; } = new RetributionPaladinGlobal();

    private List<unit> _units = new();

    public void Init()
    {
        ExTriggerRegisterNewUnit(u =>
        {
            if (GetUnitTypeId(u) == FourCC("Hpal"))
            {
                _units.Add(u);
            }
        });
        _ = Start();
    }

    private async Task Start()
    {
        while (true)
        {
            foreach (var u in _units)
            {
                var attr = UnitAttribute.GetAttr(u);
                ExSetUnitMana(u, ExGetUnitMaxMana(u) * attr.retPalHolyEnergy * 0.2f);
                if (attr.retPalHolyEnergy >= 3)
                {
                    Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u), FourCC("A004"), "ReplaceableTextures/CommandButtons/BTNspell_paladin_templarsverdict.tga");
                }
                else
                {
                    Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u), FourCC("A004"), "ReplaceableTextures/CommandButtonsDisabled/DISBTNspell_paladin_templarsverdict.tga");
                }
            }

            await Task.Delay(100);
        }
    }

}