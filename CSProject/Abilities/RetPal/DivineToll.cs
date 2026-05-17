using LuaWrapper;
using SFLib.Contracts;
using SFLib.Collections;
using System.Threading.Tasks;

public class DivineToll
{
    public static readonly int ID = FourCC("A008");

    public struct IAbilityData : IEquatable<IAbilityData>
    {
        public int TargetCount;
        public float Damage;
        public float RadiantDmgAmp;
        public float Duration;

        public bool Equals(IAbilityData other)
        {
            return math.abs(Damage - other.Damage) < 0.0001f && math.abs(Duration - other.Duration) < 0.0001f && math.abs(RadiantDmgAmp - other.RadiantDmgAmp) < 0.0001f;
        }
    }

    public static IAbilityData GetAbilityData(int level)
    {
        return new IAbilityData
        {
            TargetCount = 2 + level,
            Damage = 50f * level,
            RadiantDmgAmp = 0.1f,
            Duration = 10f,
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
        Utils.ExSetAbilityResearchTooltip(p, ID, "学习圣洁鸣钟 - [|cffffcc00%d级|r]", 0);
        Utils.ExBlzSetAbilityResearchExtendedTooltip(p, ID, @$"对附近的多个目标施展审判，造成法术伤害，然后神圣之锤环绕圣殿骑士，每次命中敌人使其受到的光辉伤害提高。每个审判产生|cffff8c001|r点圣能。

|cff99ccff冷却时间|r - 30秒

|cffffcc001级|r - 审判最多|cffff8c00{datas[0].TargetCount}|r个目标，造成|cffff8c00{datas[0].Damage}|r点法术伤害，神圣之锤造成|cffff8c00{datas[0].RadiantDmgAmp*100:F0}%|r的光辉易伤，持续|cffff8c00{datas[0].Duration}|r秒。
|cffffcc002级|r - 审判最多|cffff8c00{datas[1].TargetCount}|r个目标，造成|cffff8c00{datas[1].Damage}|r点法术伤害，神圣之锤造成|cffff8c00{datas[1].RadiantDmgAmp*100:F0}%|r的光辉易伤，持续|cffff8c00{datas[1].Duration}|r秒。
|cffffcc003级|r - 审判最多|cffff8c00{datas[2].TargetCount}|r个目标，造成|cffff8c00{datas[2].Damage}|r点法术伤害，神圣之锤造成|cffff8c00{datas[2].RadiantDmgAmp*100:F0}%|r的光辉易伤，持续|cffff8c00{datas[2].Duration}|r秒。", 0);
        for (int i = 0; i < 3; i++)
        {
            var data = datas[i];
            Utils.ExBlzSetAbilityTooltip(p, ID, $"圣洁鸣钟 - [|cffffcc00{i + 1}级|r]", i);
            Utils.ExBlzSetAbilityExtendedTooltip(p, ID, @$"对附近的最多|cffff8c00{data.TargetCount}|r个目标施展审判，造成|cffff8c00{data.Damage}|r点法术伤害，然后神圣之锤环绕圣殿骑士，每次命中敌人使其受到的光辉伤害提高|cffff8c00{data.RadiantDmgAmp*100:F0}%|r，持续|cffff8c00{data.Duration}|r秒。每个审判产生|cffff8c001|r点圣能。

|cff99ccff冷却时间|r - 30秒", i);
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
        // new BladeOfJustice().StartGroudDamage(data.caster, data.target, ad);
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
                // var damage = ad.DamagePerSecond * (1 - tarAttr.radiantResistance);
                EventCenter.Damage.Emit(new IDamageData
                {
                    whichUnit = caster,
                    target = u,
                    amount = 100f,
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
