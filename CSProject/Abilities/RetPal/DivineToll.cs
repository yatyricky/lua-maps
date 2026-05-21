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

    public static async Task Start(ISpellData data)
    {
        var pos = Vector3.FromUnit(data.caster);
        var targets = Utils.CsGroupGetUnitsInRange(pos.x, pos.y, 1600, u =>
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

        var outer = new GameObject("DivineToll_Outer");
        outer.transform.position = new Vector3(0, 0, 80);

        var moveLayer = new GameObject("MoveLayer", outer);
        moveLayer.transform.position = pos;
        var mtc = moveLayer.AddComponent<MoveTowardsComponent>();
        mtc.targetType = TargetType.Unit;
        mtc.unitTarget = targets[0];
        mtc.speed = 900;
        mtc.lookAtTarget = true;

        // var attachedHoly2 = new GameObject("DivineToll_Holy", moveLayer);
        // attachedHoly2.transform.position = new Vector3(20, 0, 0);
        // var effHoly2 = AddSpecialEffect("Abilities/Weapons/FaerieDragonMissile/FaerieDragonMissile.mdl", pos.x, pos.y);
        // attachedHoly2.AddComponent<AttachEffectComponent>().eff = effHoly2;

        var orientationFixLayer = new GameObject("DivineToll_Bolt", moveLayer);
        orientationFixLayer.transform.rotation = Quaternion.Euler(0, 90, 0);

        var selfRotLayer = new GameObject("dt_hand", orientationFixLayer);
        var trs = selfRotLayer.transform;
        var rot = Quaternion.Euler(450f / 60, 0, 0);

        var boltMis = new GameObject("dt_mis", selfRotLayer);
        boltMis.transform.position = new Vector3(30, 0, 0);
        boltMis.transform.localScale = new Vector3(0.5f, 0.5f, 0.5f);
        var eff = AddSpecialEffect("Abilities/Spells/Human/StormBolt/StormBoltMissile.mdl", pos.x, pos.y);
        boltMis.AddComponent<AttachEffectComponent>().eff = eff;

        var attachedHoly = new GameObject("DivineToll_Holy", boltMis);
        attachedHoly.transform.position = new Vector3(0, 0, 0);
        var effHoly = AddSpecialEffect("Abilities/Weapons/FaerieDragonMissile/FaerieDragonMissile.mdl", pos.x, pos.y);
        attachedHoly.AddComponent<AttachEffectComponent>().eff = effHoly;

        while (true)
        {
            await Task.Delay(Scene.DT);
            trs.rotation = rot * trs.rotation;
        }
    }
}
