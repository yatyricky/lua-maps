using LuaWrapper;

public class WordOfGlory
{
    public static readonly int ID = FourCC("A006");

    public static void Init()
    {
        EventCenter.RegisterPlayerUnitSpellChannel.Emit(new IRegisterSpellEvent
        {
            id = ID,
            handler = Check,
        });

        EventCenter.RegisterPlayerUnitSpellEffect.Emit(new IRegisterSpellEvent
        {
            id = ID,
            handler = Start
        });

        ExTriggerRegisterNewUnit(u =>
        {
            if (GetUnitTypeId(u) == FourCC("Hpal"))
            {
                UpdateAbilityMeta(u);
            }
        });
    }

    public static void Check(ISpellData data)
    {
        var attr = UnitAttribute.GetAttr(data.caster);
        if (attr.retPalHolyEnergy < 3)
        {
            IssueImmediateOrderById(data.caster, ConstOrderId.Stop);
            ExTextState(data.caster, "圣能不足");
        }
    }

    public static void UpdateAbilityMeta(unit u)
    {
        var p = GetOwningPlayer(u);
        Utils.ExSetAbilityResearchTooltip(p, ID, "学习荣耀圣令 - [|cffffcc00%d级|r]", 0);
        Utils.ExBlzSetAbilityResearchExtendedTooltip(p, ID, @$"治疗目标300生命。消耗|cffff8c003|r点圣能。", 0);
        for (int i = 0; i < 1; i++)
        {
            Utils.ExBlzSetAbilityTooltip(p, ID, $"荣耀圣令 - [|cffffcc00{i + 1}级|r]", i);
            Utils.ExBlzSetAbilityExtendedTooltip(p, ID, @$"荣耀圣令治疗目标300生命。消耗|cffff8c003|r点圣能。", i);
        }
    }

    public static void Start(ISpellData data)
    {
        EventCenter.Heal.Emit(new IHealData
        {
            caster = data.caster,
            target = data.target,
            amount = 300f,
        });

        RetributionPaladinGlobal.ConsumeHolyEnergy(data.caster, 3);
    }
}
