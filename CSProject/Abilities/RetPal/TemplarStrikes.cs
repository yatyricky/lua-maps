using SFLib.Interop;
using System.Threading.Tasks;
using LuaWrapper;
using StdLib;

public class TemplarStrikes
{
    public struct IAbilityData
    {
        public int AttackCount;
        public float DamageScaling;
        public float ResetBOJChance;
    }

    public static readonly int ID = FourCC("A007");
    public static readonly int MaxLevel = 3;

    public static IAbilityData GetAbilityData(int level)
    {
        return new IAbilityData
        {
            AttackCount = 2,
            DamageScaling = 0.5f + 0.25f * level,
            ResetBOJChance = 0.1f * level,
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

        EventCenter.RegisterPlayerUnitDamaged.Emit((caster, target, damage, weapType, dmgType, isAttack) =>
        {
            if (GetUnitAbilityLevel(caster, ID) <= 0) return;
            if (!isAttack) return;
            if (target == null) return;
            if (ExIsUnitDead(target)) return;

            TryResetBOJ(caster);
        });
    }

    private static void TryResetBOJ(unit caster)
    {
        var level = GetUnitAbilityLevel(caster, ID);
        var ad = GetAbilityData(level);
        if (math.random() >= ad.ResetBOJChance) return;

        BlzEndUnitAbilityCooldown(caster, BladeOfJustice.ID);
        ExAddSpecialEffectTarget("Abilities/Spells/Items/AIam/AIamTarget.mdl", caster, "origin", 0.3f);
    }

    public static void UpdateAbilityMeta(unit u)
    {
        var p = GetOwningPlayer(u);
        var datas = new List<IAbilityData>();
        for (int i = 0; i < MaxLevel; i++)
        {
            datas.Add(GetAbilityData(i + 1));
        }
        Utils.ExSetAbilityResearchTooltip(p, ID, "学习圣殿骑士之击 - [|cffffcc00%d级|r]", 0);
        Utils.ExBlzSetAbilityResearchExtendedTooltip(p, ID, @$"快速攻击目标|cffff8c00{datas[0].AttackCount}|r次，第一次造成普通攻击伤害，第二次造成光辉伤害，有一定几率重置公正之剑的冷却时间，普通攻击也会触发。

|cff99ccff冷却时间|r - 10秒

|cffffcc001级|r - |cffff8c00{datas[0].DamageScaling * 100:F0}%|r的光辉攻击伤害，|cffff8c00{datas[0].ResetBOJChance * 100:F0}%|r的几率重置公正之剑。
|cffffcc002级|r - |cffff8c00{datas[1].DamageScaling * 100:F0}%|r的光辉攻击伤害，|cffff8c00{datas[1].ResetBOJChance * 100:F0}%|r的几率重置公正之剑。
|cffffcc003级|r - |cffff8c00{datas[2].DamageScaling * 100:F0}%|r的光辉攻击伤害，|cffff8c00{datas[2].ResetBOJChance * 100:F0}%|r的几率重置公正之剑。", 0);
        for (int i = 0; i < MaxLevel; i++)
        {
            var data = datas[i];
            Utils.ExBlzSetAbilityTooltip(p, ID, $"圣殿骑士之击 - [|cffffcc00{i + 1}级|r]", i);
            Utils.ExBlzSetAbilityExtendedTooltip(p, ID, @$"快速攻击目标|cffff8c00{data.AttackCount}|r次，第一次造成普通攻击伤害，第二次造成普通攻击|cffff8c00{data.DamageScaling * 100:F0}%|r的光辉伤害，|cffff8c00{data.ResetBOJChance * 100:F0}%|r几率重置公正之剑的冷却时间，普通攻击也会触发。

|cff99ccff冷却时间|r - 10秒", i);
        }
    }

    public async static void Start(ISpellData data)
    {
        var level = GetUnitAbilityLevel(data.caster, ID);
        var attr = UnitAttribute.GetAttr(data.caster);
        var normalDamage = attr.SimMeleeAttack();
        var hasWoa = BuffBase.FindBuffByClassName(data.caster, "WakeOfAshesBuff") != null;

        EventCenter.Damage.Emit(new IDamageData
        {
            whichUnit = data.caster,
            target = data.target,
            amount = normalDamage,
            attack = true,
            ranged = false,
            attackType = ATTACK_TYPE_HERO,
            damageType = DAMAGE_TYPE_NORMAL,
            weaponType = WEAPON_TYPE_METAL_HEAVY_BASH,
            outResult = new IDamageDataResult(),
        });
        TryResetBOJ(data.caster);
        if (hasWoa)
        {
            RetributionPaladinGlobal.IncreaseHolyEnergy(data.caster, 1);
        }

        SetUnitTimeScale(data.caster, 3f);
        ResetUnitAnimation(data.caster);
        SetUnitAnimation(data.caster, "attack - 2");
        await Task.Delay(math.round(1.166f * 0.33f * 1000));

        var tarAttr = UnitAttribute.GetAttr(data.target);
        var ad = GetAbilityData(level);
        var radiantDamage = attr.SimMeleeAttack() * ad.DamageScaling * (1 - tarAttr.radiantResistance);
        EventCenter.Damage.Emit(new IDamageData
        {
            whichUnit = data.caster,
            target = data.target,
            amount = radiantDamage,
            attack = true,
            ranged = false,
            attackType = ATTACK_TYPE_HERO,
            damageType = DAMAGE_TYPE_MAGIC,
            weaponType = WEAPON_TYPE_METAL_HEAVY_BASH,
            outResult = new IDamageDataResult(),
        });
        TryResetBOJ(data.caster);
        if (hasWoa)
        {
            RetributionPaladinGlobal.IncreaseHolyEnergy(data.caster, 1);
        }

        SetUnitTimeScale(data.caster, 1f);
        ResetUnitAnimation(data.caster);
    }
}
