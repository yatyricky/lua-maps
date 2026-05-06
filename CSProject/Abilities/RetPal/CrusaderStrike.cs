using LuaWrapper;
using SFLib;

public class CrusaderStrike
{
    public static readonly int ID = FourCC("A000");
    public static readonly player thePlayer = Player(0);

    public static void Init()
    {
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

    public static void UpdateAbilityMeta(unit u)
    {
        var p = GetOwningPlayer(u);
        Utils.ExSetAbilityResearchTooltip(p, ID, "学习十字军打击 - [|cffffcc00%d级|r]", 0);
        var attr = UnitAttribute.GetAttr(u);
    }

    public static void Start(ISpellData data)
    {
        var level = GetUnitAbilityLevel(data.caster, ID);
    }
}
