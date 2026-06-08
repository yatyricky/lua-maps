using System.Threading.Tasks;
using StdLib;
using SFLib.Interop;
using LuaWrapper;

public class RetributionPaladinGlobal
{
    public static RetributionPaladinGlobal Instance { get; } = new RetributionPaladinGlobal();

    public static void IncreaseHolyEnergy(unit u, int amount)
    {
        var attr = UnitAttribute.GetAttr(u);
        var before = attr.retPalHolyEnergy;
        attr.retPalHolyEnergy = math.min(attr.retPalHolyEnergy + amount, 5);
        var increased = attr.retPalHolyEnergy - before;
        // wake of ashes
        var buff = BuffBase.FindBuffByClassName(u, "WakeOfAshesBuff");
        if (buff != null)
        {
            var heal = (100 + GetHeroInt(u, true)) * increased;
            EventCenter.Heal.Emit(new IHealData
            {
                caster = u,
                target = u,
                amount = heal,
            });
            ExAddSpecialEffectTarget("Abilities/Spells/Items/AIhe/AIheTarget.mdl", u, "origin", 0.2f);
        }
    }

    public static void ConsumeHolyEnergy(unit u, int amount)
    {
        var attr = UnitAttribute.GetAttr(u);
        var before = attr.retPalHolyEnergy;
        attr.retPalHolyEnergy = math.max(attr.retPalHolyEnergy - amount, 0);
        var consumed = before - attr.retPalHolyEnergy;

        // wake of ashes
        var buff = BuffBase.FindBuffByClassName(u, "WakeOfAshesBuff");
        if (buff != null)
        {
            var quickness = BuffBase.FindBuffByClassName(u, "QuicknessBuff");
            if (quickness == null)
            {
                quickness = new WakeOfAshes.QuicknessBuff(u, u, 9999f, 9999f, new IAwakeData());
            }
            quickness.IncreaseStack(consumed);
            var cd = math.max(10 * (1 - 0.05f * quickness.stack), 1);
            for (int i = 0; i < 3; i++)
            {
                BlzSetUnitAbilityCooldown(u, BladeOfJustice.ID, i, cd);
                BlzSetUnitAbilityCooldown(u, TemplarStrikes.ID, i, cd);
            }
        }
    }

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
                // set word of glory
                if (attr.retPalHolyEnergy >= 3)
                {
                    Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u), FourCC("A006"), "ReplaceableTextures/CommandButtons/BTNinv_helmet_96.tga");
                }
                else
                {
                    Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u), FourCC("A006"), "ReplaceableTextures/PassiveButtons/PASBTNinv_helmet_96.tga");
                }
                // set divine storm
                var hasWoa = BuffBase.FindBuffByClassName(u, "WakeOfAshesBuff") != null;
                if (hasWoa)
                {
                    if (attr.retPalHolyEnergy >= 3)
                    {
                        Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u), FourCC("A005"), "ReplaceableTextures/CommandButtons/BTNinv_mace_1h_gryphonrider_d_02_silver.tga");
                    }
                    else
                    {
                        Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u), FourCC("A005"), "ReplaceableTextures/PassiveButtons/PASBTNinv_mace_1h_gryphonrider_d_02_silver.tga");
                    }
                }
                else
                {
                    if (attr.retPalHolyEnergy >= 3)
                    {
                        Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u), FourCC("A005"), "ReplaceableTextures/CommandButtons/BTNability_paladin_divinestorm.tga");
                    }
                    else
                    {
                        Utils.ExBlzSetAbilityIcon(GetOwningPlayer(u), FourCC("A005"), "ReplaceableTextures/PassiveButtons/PASBTNability_paladin_divinestorm.tga");
                    }
                }
            }

            await Task.Delay(100);
        }
    }

}