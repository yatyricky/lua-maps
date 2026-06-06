using LuaWrapper;
using SFLib.Interop;

public class DivineStorm
{
    public static readonly int ID = FourCC("A005");

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
        Utils.ExSetAbilityResearchTooltip(p, ID, "学习神圣风暴 - [|cffffcc00%d级|r]", 0);
        Utils.ExBlzSetAbilityResearchExtendedTooltip(p, ID, @$"对周围敌人造成200点光辉伤害。消耗|cffff8c003|r点圣能。", 0);
        for (int i = 0; i < 1; i++)
        {
            Utils.ExBlzSetAbilityTooltip(p, ID, $"神圣风暴 - [|cffffcc00{i + 1}级|r]", i);
            Utils.ExBlzSetAbilityExtendedTooltip(p, ID, @$"神圣风暴对周围敌人造成200点光辉伤害。消耗|cffff8c003|r点圣能。", i);
        }
    }

    public static void Start(ISpellData data)
    {
        var pos = Vector3.FromUnit(data.caster);
        ExGroupEnumUnitsInRange(pos.x, pos.y, 250f, (u) =>
        {
            if (!IsUnitEnemy(u, GetOwningPlayer(data.caster))) return;
            if (ExIsUnitDead(u)) return;

            var attr = UnitAttribute.GetAttr(data.caster);
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

        RetributionPaladinGlobal.ConsumeHolyEnergy(data.caster, 3);

        var leviation = new GameObject("ds_leviation");
        leviation.transform.localPosition = new Vector3(0, 0, 50f);
        leviation.AddComponent<TimerComponent>().StartTimer(0.6f, () => leviation.Destroy());
        for (int i = -5; i <= 5; i++)
        {
            if (i == 0) continue;
            var attach = new GameObject("ds_visual", leviation);
            attach.transform.localPosition = pos;
            attach.transform.localRotation = Quaternion.Euler(0, 360f / 5 * math.abs(i) - 10 + 20 * math.random(), 0);
            var att = attach.AddComponent<AutoTRSComponent>();
            att.followUnit = data.caster;
            att.rotation = Quaternion.Euler(0, math.sign(i) * (math.random() * 200 + 700) * Scene.DT / 1000f, 0);

            var arm = new GameObject("ds_arm", attach);
            arm.transform.localPosition = new Vector3(250f, 0, 0);
            var effHoly = AddSpecialEffect("Abilities/Weapons/FaerieDragonMissile/FaerieDragonMissile.mdl", pos.x, pos.y);
            var effC = arm.AddComponent<AttachEffectComponent>();
            effC.AttachEffect(effHoly);
            effC.LerpIn(700);
        }
    }
}
