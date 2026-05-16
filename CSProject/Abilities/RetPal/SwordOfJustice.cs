using LuaWrapper;
using SFLib.Contracts;
using SFLib.Collections;
using System.Threading.Tasks;

public class SwordOfJustice
{
    public static readonly int ID = FourCC("A001");

    public struct IAbilityData : IEquatable<IAbilityData>
    {
        public float Damage;
        public float Duration;
        public float DamagePerSecond;

        public bool Equals(IAbilityData other)
        {
            return math.abs(Damage - other.Damage) < 0.0001f && math.abs(Duration - other.Duration) < 0.0001f && math.abs(DamagePerSecond - other.DamagePerSecond) < 0.0001f;
        }
    }

    public static IAbilityData GetAbilityData(int level)
    {
        return new IAbilityData
        {
            Damage = 75f * level,
            Duration = 5f,
            DamagePerSecond = 10f * level
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
        for (int i = 0; i < 1; i++)
        {
            datas.Add(GetAbilityData(i + 1));
        }
        Utils.ExSetAbilityResearchTooltip(p, ID, "学习公正之剑 - [|cffffcc00%d级|r]", 0);
        Utils.ExBlzSetAbilityResearchExtendedTooltip(p, ID, @$"公正之剑造成一次攻击伤害，如果目标被审判，造成30%的额外伤害，15%几率重置审判。消耗|cffff8c003|r点圣能。

|cff99ccff冷却时间|r - 5秒

|cffffcc001级|r - |cffff8c00{datas[0].Damage * 100:F0}%|r的攻击伤害，{datas[0].Damage * 100:F0}%的战争艺术触发几率。", 0);
        for (int i = 0; i < 1; i++)
        {
            var data = datas[i];
            Utils.ExBlzSetAbilityTooltip(p, ID, $"公正之剑 - [|cffffcc00{i + 1}级|r]", i);
            Utils.ExBlzSetAbilityExtendedTooltip(p, ID, @$"公正之剑造成一次攻击伤害，造成|cffff8c00{data.Damage * 100:F0}%|r的攻击伤害。消耗|cffff8c003|r点圣能。

|cff99ccff冷却时间|r - 5秒", i);
        }
    }

    public static void Start(ISpellData data)
    {
        var level = GetUnitAbilityLevel(data.caster, ID);
        var ad = GetAbilityData(level);
        var attr = UnitAttribute.GetAttr(data.caster);

        EventCenter.Damage.Emit(new IDamageData
        {
            whichUnit = data.caster,
            target = data.target,
            amount = ad.Damage,
            attack = false,
            ranged = true,
            attackType = ATTACK_TYPE_MAGIC,
            damageType = DAMAGE_TYPE_MAGIC,
            weaponType = WEAPON_TYPE_WHOKNOWS,
            outResult = new IDamageDataResult(),
        });

        attr.retPalHolyEnergy++;

        new SwordOfJustice().StartGroudDamage(data.caster, data.target, ad);
    }

    private float x;
    private float y;

    private async void StartGroudDamage(unit caster, unit target, IAbilityData ad)
    {
        x = GetUnitX(target);
        y = GetUnitY(target);
        var eff = ExAddSpecialEffect("Abilities/Spells/Orc/LiquidFire/Liquidfire.mdl", x, y, ad.Duration);

        for (int i = 0; i < ad.Duration; i++)
        {
            await Task.Delay(1000);
            ExGroupEnumUnitsInRange(x, y, 300f, u =>
            {
                if (!IsUnitEnemy(u, GetOwningPlayer(caster))) return;
            });
        }

        DestroyEffect(eff);
    }
}
