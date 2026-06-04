using LuaWrapper;
using StdLib;
using System.Threading.Tasks;
using SFLib.Interop;

public class DivineToll
{
    public static readonly int ID = FourCC("A008");

    public struct IAbilityData
    {
        public int TargetCount;
        public float Damage;
        public float RadiantDmgAmp;
        public float Duration;
        public float BHDamage;
    }

    public static IAbilityData GetAbilityData(int level)
    {
        return new IAbilityData
        {
            TargetCount = 2 + level,
            Damage = 50f * level,
            RadiantDmgAmp = 0.1f,
            Duration = 10f,
            BHDamage = 20f * level,
        };
    }

    public static void Init()
    {
        EventCenter.RegisterPlayerUnitSpellEffect.Emit(new IRegisterSpellEvent
        {
            id = ID,
            handler = async data => await Start(data)
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

|cffffcc001级|r - 审判最多|cffff8c00{datas[0].TargetCount}|r个目标，造成|cffff8c00{datas[0].Damage}|r点法术伤害，神圣之锤造成|cffff8c00{datas[0].RadiantDmgAmp * 100:F0}%|r的光辉易伤，持续|cffff8c00{datas[0].Duration}|r秒。
|cffffcc002级|r - 审判最多|cffff8c00{datas[1].TargetCount}|r个目标，造成|cffff8c00{datas[1].Damage}|r点法术伤害，神圣之锤造成|cffff8c00{datas[1].RadiantDmgAmp * 100:F0}%|r的光辉易伤，持续|cffff8c00{datas[1].Duration}|r秒。
|cffffcc003级|r - 审判最多|cffff8c00{datas[2].TargetCount}|r个目标，造成|cffff8c00{datas[2].Damage}|r点法术伤害，神圣之锤造成|cffff8c00{datas[2].RadiantDmgAmp * 100:F0}%|r的光辉易伤，持续|cffff8c00{datas[2].Duration}|r秒。", 0);
        for (int i = 0; i < 3; i++)
        {
            var data = datas[i];
            Utils.ExBlzSetAbilityTooltip(p, ID, $"圣洁鸣钟 - [|cffffcc00{i + 1}级|r]", i);
            Utils.ExBlzSetAbilityExtendedTooltip(p, ID, @$"对附近的最多|cffff8c00{data.TargetCount}|r个目标施展审判，造成|cffff8c00{data.Damage}|r点法术伤害，然后神圣之锤环绕圣殿骑士，每次命中敌人使其受到的光辉伤害提高|cffff8c00{data.RadiantDmgAmp * 100:F0}%|r，持续|cffff8c00{data.Duration}|r秒。每个审判产生|cffff8c001|r点圣能。

|cff99ccff冷却时间|r - 30秒", i);
        }
    }

    private static void HurlToTarget(unit caster, unit target, Vector3 pos)
    {
        var outer = new GameObject("DivineToll_Outer");
        outer.transform.localPosition = new Vector3(0, 0, 80);

        var moveLayer = new GameObject("MoveLayer", outer);
        moveLayer.transform.localPosition = pos;
        var missile = moveLayer.AddComponent<Missile>();
        missile.SetupUnitTarget(target, 900f, (mis, tar) =>
        {
            var cPos = mis.gameObject.transform.position;
            var eff = ExAddSpecialEffect("Abilities/Spells/Human/StormBolt/StormBoltMissile.mdl", cPos.x, cPos.y, 0.1f);
            BlzSetSpecialEffectColor(eff, 255, 255, 0);

            var ad = GetAbilityData(GetUnitAbilityLevel(caster, ID));

            EventCenter.Damage.Emit(new IDamageData
            {
                whichUnit = caster,
                target = tar,
                amount = ad.Damage,
                attack = false,
                ranged = true,
                attackType = ATTACK_TYPE_HERO,
                damageType = DAMAGE_TYPE_MAGIC,
                weaponType = WEAPON_TYPE_WHOKNOWS,
                outResult = new IDamageDataResult(),
            });

            RetributionPaladinGlobal.IncreaseHolyEnergy(caster, 1);

            // setup new missile
            mis.SetupPiercer((m, u) =>
            {
                var cPos = m.gameObject.transform.position;
                ExAddSpecialEffectTarget("Abilities/Weapons/FaerieDragonMissile/FaerieDragonMissile.mdl", u, "origin", 0.1f);
                var tarAttr = UnitAttribute.GetAttr(u);
                var damage = ad.BHDamage * (1 - tarAttr.radiantResistance);
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
            }, u =>
            {
                if (!IsUnitEnemy(u, GetOwningPlayer(caster))) return false;
                if (IsUnitType(u, UNIT_TYPE_STRUCTURE)) return false;
                if (ExIsUnitDead(u)) return false;
                return true;
            }, 50f, 9999, 0.3f);

            // change movement behaviour
            var aec1 = moveLayer.transform.Find("DivineToll_Bolt/dt_hand/dt_mis")!.gameObject.GetComponent<AttachEffectComponent>()!;
            aec1.LerpIn(1300);
            var aec2 = aec1.gameObject.transform.Find("DivineToll_Holy")!.gameObject.GetComponent<AttachEffectComponent>()!;
            aec2.LerpIn(1300);

            var casterPos = Vector3.FromUnit(caster);
            var circulator = new GameObject("Circulator", outer);
            circulator.transform.localPosition = casterPos;
            var rot = circulator.AddComponent<AutoTRSComponent>();
            rot.rotation = Quaternion.Euler(0, 300 * Scene.DT / 1000f, 0);
            rot.followUnit = caster;

            moveLayer.transform.SetParent(circulator.transform);
            moveLayer.transform.localPosition = new Vector3(200, 0, 0);
        });
        missile.onLostTarget = () =>
        {
            outer.Destroy();
        };

        var orientationFixLayer = new GameObject("DivineToll_Bolt", moveLayer);
        orientationFixLayer.transform.localRotation = Quaternion.Euler(0, 90, 0);

        var selfRotLayer = new GameObject("dt_hand", orientationFixLayer);
        selfRotLayer.AddComponent<AutoTRSComponent>().rotation = Quaternion.Euler(1800 * Scene.DT / 1000f, 0, 0);

        var boltMis = new GameObject("dt_mis", selfRotLayer);
        boltMis.transform.localPosition = new Vector3(15, 0, 0);
        boltMis.transform.localScale = new Vector3(0.5f, 0.5f, 0.5f);
        var eff = AddSpecialEffect("Abilities/Spells/Human/StormBolt/StormBoltMissile.mdl", pos.x, pos.y);
        boltMis.AddComponent<AttachEffectComponent>().AttachEffect(eff);

        var attachedHoly = new GameObject("DivineToll_Holy", boltMis);
        attachedHoly.transform.localPosition = new Vector3(15, 0, 0);
        var effHoly = AddSpecialEffect("Abilities/Weapons/FaerieDragonMissile/FaerieDragonMissile.mdl", pos.x, pos.y);
        attachedHoly.AddComponent<AttachEffectComponent>().AttachEffect(effHoly);
        BlzSetSpecialEffectColor(effHoly, 20, 20, 20);
    }

    public static async Task Start(ISpellData data)
    {
        var pos = Vector3.FromUnit(data.caster);
        var targets = Utils.CsGroupGetUnitsInRange(pos.x, pos.y, 600, u =>
        {
            if (!IsUnitEnemy(u, GetOwningPlayer(data.caster))) return false;
            if (IsUnitType(u, UNIT_TYPE_STRUCTURE)) return false;
            if (ExIsUnitDead(u)) return false;
            return true;
        });
        if (targets.Count == 0)
        {
            return;
        }

        targets.Sort((a, b) =>
        {
            var distA = Vector3.Distance(pos, Vector3.FromUnit(a));
            var distB = Vector3.Distance(pos, Vector3.FromUnit(b));
            return distA == distB ? 0 : distA < distB ? -1 : 1;
        });

        for (int i = 0; i < math.min(targets.Count, GetAbilityData(GetUnitAbilityLevel(data.caster, ID)).TargetCount); i++)
        {
            HurlToTarget(data.caster, targets[i], pos);
            await Task.Delay(200);
        }
    }
}
