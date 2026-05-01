public class Program
{
    public static void Main(string[] args)
    {
        BJDebugMsg("Hello SharpForge");
        var unit = CreateUnit(Player(0), FourCC("hfoo"), 0, 0, 0);
        BJDebugMsg(GetUnitName(unit));
        BJDebugMsg(GetPlayerName(GetOwningPlayer(unit)));
    }
}