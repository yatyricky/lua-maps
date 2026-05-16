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
        Utils.ExSetAbilityResearchTooltip(p, ID, "学习圣殿骑士的裁决 - [|cffffcc00%d级|r]", 0);
        Utils.ExBlzSetAbilityResearchExtendedTooltip(p, ID, @$"圣殿骑士的裁决造成一次攻击伤害，如果目标被审判，造成30%的额外伤害，15%几率重置审判。消耗|cffff8c003|r点圣能。

|cff99ccff冷却时间|r - 5秒

|cffffcc001级|r - |cffff8c00100%|r的攻击伤害，100%的战争艺术触发几率。", 0);
        for (int i = 0; i < 1; i++)
        {
            Utils.ExBlzSetAbilityTooltip(p, ID, $"圣殿骑士的裁决 - [|cffffcc00{i + 1}级|r]", i);
            Utils.ExBlzSetAbilityExtendedTooltip(p, ID, @$"圣殿骑士的裁决造成一次攻击伤害，造成|cffff8c00100%|r的攻击伤害。消耗|cffff8c003|r点圣能。

|cff99ccff冷却时间|r - 5秒", i);
        }
    }

    public static void Start(ISpellData data)
    {
        var attr = UnitAttribute.GetAttr(data.caster);
        EventCenter.Heal.Emit(new IHealData
        {
            caster = data.caster,
            target = data.target,
            amount = 300f,
        });

        attr.retPalHolyEnergy -= 3;
    }
}
