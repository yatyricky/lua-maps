using LuaWrapper;
using SFLib.Interop;

public class WakeOfAshes
{
    public static readonly int ID = FourCC("A009");

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
        Utils.ExSetAbilityResearchTooltip(p, ID, "学习灰烬觉醒 - [|cffffcc00%d级|r]", 0);
        Utils.ExBlzSetAbilityResearchExtendedTooltip(p, ID, @$"对你前方敌人造成|cffff8c00300|r点光辉伤害，并激活复仇之怒效果，在复仇之怒效果期间：
· 每消耗|cffff8c001|r点神圣能量，圣殿骑士之击与公正之剑的冷却时间缩短|cffff8c0010%|r。
· 圣殿骑士之击的攻击会获得神圣能量。
· 荣耀圣令的治疗效果提高|cffff8c00100%|r。
· 神圣风暴被替换为圣光之锤。

|cffffcc00圣光之锤|r
对当前目标造成|cffff8c00450|r点光辉伤害，另外对附近所有目标造成|cffff8c00350|r点光辉伤害。使神圣之锤的持续时间延长|cffff8c004|r秒。消耗|cffff8c005|r神圣能量", 0);
        for (int i = 0; i < 1; i++)
        {
            Utils.ExBlzSetAbilityTooltip(p, ID, $"灰烬觉醒 - [|cffffcc00{i + 1}级|r]", i);
            Utils.ExBlzSetAbilityExtendedTooltip(p, ID, @$"对你前方敌人造成|cffff8c00300|r点光辉伤害，并激活复仇之怒效果，在复仇之怒效果期间：
· 每消耗|cffff8c001|r点神圣能量，圣殿骑士之击与公正之剑的冷却时间缩短|cffff8c0010%|r。
· 圣殿骑士之击的攻击会获得神圣能量。
· 荣耀圣令的治疗效果提高|cffff8c00100%|r。
· 神圣风暴被替换为圣光之锤。

|cffffcc00圣光之锤|r
对当前目标造成|cffff8c00450|r点光辉伤害，另外对附近所有目标造成|cffff8c00350|r点光辉伤害。使神圣之锤的持续时间延长|cffff8c004|r秒。消耗|cffff8c005|r神圣能量", i);
        }
    }

    public static void Start(ISpellData data)
    {
        var pos = Vector3.FromUnit(data.caster);
        var facing = GetUnitFacing(data.caster);
        var forward = new Vector3(math.cos(facing * bj_DEGTORAD), math.sin(facing * bj_DEGTORAD), 0);
        ExGroupEnumUnitsInRange(pos.x, pos.y, 400f, (u) =>
        {
            if (!IsUnitEnemy(u, GetOwningPlayer(data.caster))) return;
            if (ExIsUnitDead(u)) return;
            var direction = (Vector3.FromUnit(u) - pos).normalized;
            if (Vector3.Dot(forward, direction) < 0.5f) return;

            var attr = UnitAttribute.GetAttr(u);
            EventCenter.Damage.Emit(new IDamageData
            {
                whichUnit = data.caster,
                target = u,
                amount = 200f * (1 - attr.radiantResistance),
                attack = false,
                ranged = true,
                attackType = ATTACK_TYPE_HERO,
                damageType = DAMAGE_TYPE_MAGIC,
                weaponType = WEAPON_TYPE_WHOKNOWS,
                outResult = new IDamageDataResult(),
            });
        });

        var buff = BuffBase.FindBuffByClassName(data.caster, "WakeOfAshesBuff");
        if (buff != null)
        {
            buff.ResetDuration();
        }
        else
        {
            new WakeOfAshesBuff(data.caster, data.caster, 30, 99999f, new IAwakeData
            {
                level = 0,
                charged = 0,
            });
        }
    }

    [Lua(Class = "WakeOfAshesBuff")]
    public class WakeOfAshesBuff : BuffBase
    {
        public WakeOfAshesBuff(unit caster, unit target, float duration, float interval, IAwakeData awakeData) : base(caster, target, duration, interval, awakeData)
        {
        }

        public override void OnDisable()
        {
            var quickness = BuffBase.FindBuffByClassName(target, "QuicknessBuff");
            if (quickness != null)
            {
                quickness.DecreaseStack(quickness.stack);
            }
        }
    }

    [Lua(Class = "QuicknessBuff")]
    public class QuicknessBuff : BuffBase
    {
        public QuicknessBuff(unit caster, unit target, float duration, float interval, IAwakeData awakeData) : base(caster, target, duration, interval, awakeData)
        {
            
        }

        public override void OnDisable()
        {
            for (int i = 0; i < 3; i++)
            {
                BlzSetUnitAbilityCooldown(target, BladeOfJustice.ID, i, 10);
                BlzSetUnitAbilityCooldown(target, TemplarStrikes.ID, i, 10);
            }
        }
    }
}
