using LuaWrapper;
using SFLib;

public class CrusaderStrike
{
    public struct IAbilityData
    {
        public float DamageScaling;
        public float ArtOfWarChance;
    }

    public static readonly int ID = FourCC("A000");
    public static readonly player thePlayer = Player(0);

    public static IAbilityData GetAbilityData(int level)
    {
        return new IAbilityData
        {
            DamageScaling = 0.65f + 0.35f * level,
            ArtOfWarChance = 0.15f * (level - 1)
        };
    }

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
        for (int i = 0; i < 3; i++)
        {
            var data = GetAbilityData(i + 1);
            BJDebugMsg($"十字军打击{i + 1}级：伤害系数{data.DamageScaling:F2}，战术大师触发几率{data.ArtOfWarChance * 100:F2}%");
        }
    }

    public static void Start(ISpellData data)
    {
        var level = GetUnitAbilityLevel(data.caster, ID);
    }

    private IAbilityData _template;

    private void OnInspector()
    {
        var scaleX = _template.DamageScaling * 15;
        BJDebugMsg($"十字军打击伤害系数：{scaleX} {_template.ArtOfWarChance}");
    }
}
