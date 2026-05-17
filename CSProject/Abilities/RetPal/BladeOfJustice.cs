using LuaWrapper;
using SFLib.Contracts;
using SFLib.Collections;
using System.Threading.Tasks;

public class BladeOfJustice
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
        for (int i = 0; i < 3; i++)
        {
            datas.Add(GetAbilityData(i + 1));
        }
        Utils.ExSetAbilityResearchTooltip(p, ID, "学习公正之剑 - [|cffffcc00%d级|r]", 0);
        Utils.ExBlzSetAbilityResearchExtendedTooltip(p, ID, @$"用圣光的利刃刺穿目标，造成法术伤害，在一定时间内对附近敌人每秒造成光辉伤害。产生|cffff8c001|r点圣能。

|cff99ccff冷却时间|r - 10秒

|cffffcc001级|r - 造成|cffff8c00{datas[0].Damage}|r的直接法术伤害，|cffff8c00{datas[0].Duration}|r秒内对附近敌人每秒造成|cffff8c00{datas[0].DamagePerSecond}|r的光辉伤害。产生|cffff8c001|r点圣能。
|cffffcc002级|r - 造成|cffff8c00{datas[1].Damage}|r的直接法术伤害，|cffff8c00{datas[1].Duration}|r秒内对附近敌人每秒造成|cffff8c00{datas[1].DamagePerSecond}|r的光辉伤害。产生|cffff8c001|r点圣能。
|cffffcc003级|r - 造成|cffff8c00{datas[2].Damage}|r的直接法术伤害，|cffff8c00{datas[2].Duration}|r秒内对附近敌人每秒造成|cffff8c00{datas[2].DamagePerSecond}|r的光辉伤害。产生|cffff8c001|r点圣能。", 0);
        for (int i = 0; i < 3; i++)
        {
            var data = datas[i];
            Utils.ExBlzSetAbilityTooltip(p, ID, $"公正之剑 - [|cffffcc00{i + 1}级|r]", i);
            Utils.ExBlzSetAbilityExtendedTooltip(p, ID, @$"用圣光的利刃刺穿目标，造成|cffff8c00{data.Damage}|r的直接法术伤害，在|cffff8c00{data.Duration}|r秒内对附近敌人每秒造成|cffff8c00{data.DamagePerSecond}|r的光辉伤害。产生|cffff8c001|r点圣能。

|cff99ccff冷却时间|r - 10秒", i);
        }
    }

    public static void Start(ISpellData data)
    {
        var level = GetUnitAbilityLevel(data.caster, ID);
        var ad = GetAbilityData(level);

        EventCenter.Damage.Emit(new IDamageData
        {
            whichUnit = data.caster,
            target = data.target,
            amount = ad.Damage,
            attack = false,
            ranged = true,
            attackType = ATTACK_TYPE_HERO,
            damageType = DAMAGE_TYPE_MAGIC,
            weaponType = WEAPON_TYPE_WHOKNOWS,
            outResult = new IDamageDataResult(),
        });

        RetributionPaladinGlobal.IncreaseHolyEnergy(data.caster, 1);
        new BladeOfJustice().StartGroudDamage(data.caster, data.target, ad);
    }

    private float x;
    private float y;

    private async void StartGroudDamage(unit caster, unit target, IAbilityData ad)
    {
        x = GetUnitX(target);
        y = GetUnitY(target);
        var eff = ExAddSpecialEffect("Abilities/Spells/Orc/LiquidFire/Liquidfire.mdl", x, y, ad.Duration);
        var p = GetOwningPlayer(caster);

        for (int i = 0; i < ad.Duration; i++)
        {
            await Task.Delay(1000);
            ExGroupEnumUnitsInRange(x, y, 300f, u =>
            {
                if (!IsUnitEnemy(u, p)) return;
                if (ExIsUnitDead(u)) return;

                var tarAttr = UnitAttribute.GetAttr(u);
                var damage = ad.DamagePerSecond * (1 - tarAttr.radiantResistance);
                EventCenter.Damage.Emit(new IDamageData
                {
                    whichUnit = caster,
                    target = u,
                    amount = damage,
                    attack = false,
                    ranged = true,
                    attackType = ATTACK_TYPE_HERO,
                    damageType = DAMAGE_TYPE_MAGIC,
                    weaponType = WEAPON_TYPE_WHOKNOWS,
                    outResult = new IDamageDataResult(),
                });
            });
        }

        DestroyEffect(eff);
    }
}
