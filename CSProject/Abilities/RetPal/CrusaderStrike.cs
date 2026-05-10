using LuaWrapper;
using SFLib.Contracts;
using SFLib.Collections;

public class CrusaderStrike
{
    public struct IAbilityData : IEquatable<IAbilityData>
    {
        public float DamageScaling;
        public float ArtOfWarChance;

        public IAbilityData Scale(int scale)
        {
            return new IAbilityData
            {
                DamageScaling = DamageScaling * scale,
                ArtOfWarChance = ArtOfWarChance * scale
            };
        }

        public bool Equals(IAbilityData other)
        {
            return math.abs(DamageScaling - other.DamageScaling) < 0.0001f && math.abs(ArtOfWarChance - other.ArtOfWarChance) < 0.0001f;
        }

        public int GetHashValue()
        {
            return 0;
        }
    }

    public class BluntData : IEquatable<BluntData>
    {
        public float BluntDamage;

        public bool Equals(BluntData other)
        {
            return math.abs(BluntDamage - other.BluntDamage) < 0.0001f;
        }

        public int GetHashValue()
        {
            return 0;
        }
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
        var datas = new List<IAbilityData>();
        for (int i = 0; i < 3; i++)
        {
            datas.Add(GetAbilityData(i + 1));
        }
        Utils.ExSetAbilityResearchTooltip(p, ID, "学习十字军打击 - [|cffffcc00%d级|r]", 0);
        Utils.ExBlzSetAbilityResearchExtendedTooltip(p, ID, @$"十字军打击造成一次攻击伤害，伤害系数随技能等级提升。产生|cffff8c001|r点圣能。

|cff99ccff冷却时间|r - 6秒

|cffffcc001级|r - |cffff8c00{datas[0].DamageScaling * 100:F0}%|r的攻击伤害。
|cffffcc002级|r - |cffff8c00{datas[1].DamageScaling * 100:F0}%|r的攻击伤害，{datas[1].ArtOfWarChance * 100:F0}%的战争艺术触发几率。
|cffffcc003级|r - |cffff8c00{datas[2].DamageScaling * 100:F0}%|r的攻击伤害，{datas[2].ArtOfWarChance * 100:F0}%的战争艺术触发几率。", 0);
        for (int i = 0; i < 3; i++)
        {
            var data = datas[i];
            Utils.ExBlzSetAbilityTooltip(p, ID, $"十字军打击 - [|cffffcc00{i + 1}级|r]", i);
            Utils.ExBlzSetAbilityExtendedTooltip(p, ID, @$"十字军打击造成一次攻击伤害，造成|cffff8c00{data.DamageScaling * 100:F0}%|r的攻击伤害{(i > 0 ? $"，{data.ArtOfWarChance * 100:F0}%的战争艺术触发几率" : "")}。产生|cffff8c001|r点圣能。

|cff99ccff冷却时间|r - 6秒", i);
        }

        // datas.Remove(new IAbilityData { DamageScaling = 0.65f, ArtOfWarChance = 0 });
        datas.RemoveAt(0);
    }

    public static void Start(ISpellData data)
    {
        var level = GetUnitAbilityLevel(data.caster, ID);
        var ad = GetAbilityData(level);
        var attr = UnitAttribute.GetAttr(data.caster);
        var damage = attr.SimAttack(UnitAttribute.HeroAttributeType.Strength) * ad.DamageScaling;
    }

    private IAbilityData _template;

    private void OnInspector()
    {
        var scaleX = _template.DamageScaling * 15;
        BJDebugMsg($"十字军打击伤害系数：{scaleX} {_template.ArtOfWarChance}");
    }
}
