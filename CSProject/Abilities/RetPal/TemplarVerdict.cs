using LuaWrapper;
using SFLib.Contracts;
using SFLib.Collections;

public class TemplarVerdict
{
    public struct IAbilityData : IEquatable<IAbilityData>
    {
        public float DamageScaling;
        public float JudgementDamageScaling;
        public float ChanceToResetJudgement;

        public bool Equals(IAbilityData other)
        {
            return math.abs(JudgementDamageScaling - other.JudgementDamageScaling) < 0.0001f && math.abs(ChanceToResetJudgement - other.ChanceToResetJudgement) < 0.0001f;
        }
    }


    public static readonly int ID = FourCC("A004");

    public static IAbilityData GetAbilityData(int level)
    {
        return new IAbilityData
        {
            DamageScaling = 2.25f,
            JudgementDamageScaling = 0.3f,
            ChanceToResetJudgement = 0.15f
        };
    }

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
        var datas = new List<IAbilityData>();
        for (int i = 0; i < 1; i++)
        {
            datas.Add(GetAbilityData(i + 1));
        }
        Utils.ExSetAbilityResearchTooltip(p, ID, "学习圣殿骑士的裁决 - [|cffffcc00%d级|r]", 0);
        Utils.ExBlzSetAbilityResearchExtendedTooltip(p, ID, @$"圣殿骑士的裁决造成一次攻击伤害，如果目标被审判，造成30%的额外伤害，15%几率重置审判。消耗|cffff8c003|r点圣能。

|cff99ccff冷却时间|r - 5秒

|cffffcc001级|r - |cffff8c00{datas[0].JudgementDamageScaling * 100:F0}%|r的攻击伤害，{datas[0].ChanceToResetJudgement * 100:F0}%的战争艺术触发几率。", 0);
        for (int i = 0; i < 1; i++)
        {
            var data = datas[i];
            Utils.ExBlzSetAbilityTooltip(p, ID, $"圣殿骑士的裁决 - [|cffffcc00{i + 1}级|r]", i);
            Utils.ExBlzSetAbilityExtendedTooltip(p, ID, @$"圣殿骑士的裁决造成一次攻击伤害，造成|cffff8c00{data.DamageScaling * 100:F0}%|r的攻击伤害。消耗|cffff8c003|r点圣能。

|cff99ccff冷却时间|r - 5秒", i);
        }
    }

    public static void Start(ISpellData data)
    {
        var level = GetUnitAbilityLevel(data.caster, ID);
        var ad = GetAbilityData(level);
        var attr = UnitAttribute.GetAttr(data.caster);
        var damage = attr.SimAttack(UnitAttribute.HeroAttributeType.Strength) * ad.DamageScaling;

        EventCenter.Damage.Emit(new IDamageData
        {
            whichUnit = data.caster,
            target = data.target,
            amount = damage,
            attack = true,
            ranged = false,
            attackType = ATTACK_TYPE_HERO,
            damageType = DAMAGE_TYPE_NORMAL,
            weaponType = WEAPON_TYPE_METAL_HEAVY_SLICE,
            outResult = new IDamageDataResult(),
        });

        attr.retPalHolyEnergy -= 3;
    }
}
