using LuaWrapper;
using SFLib;

public class CrusaderStrike
{
    private static readonly int _1 = Register();

    private static int Register()
    {
        EventCenter.RegisterPlayerUnitSpellEffect.Emit(new IRegisterSpellEvent
        {
            id = FourCC("A001"),
            handler = data =>
            { 
                var level = GetUnitAbilityLevel(data.caster, FourCC("A001"));
            }
        });
        return 0;
    }

}