using System.Threading.Tasks;
using SFLib.Collections;

public class Scene
{
    private static Scene? _instance;
    public static Scene Instance => _instance ??= new Scene();

    public List<GameObject> gameObjs = new();

    public void AddGameObject(GameObject obj)
    {
        gameObjs.Add(obj);
    }

    public async void Run()
    {
        foreach (var obj in gameObjs)
        {
            await Task.Delay(20);
            obj.Update();
        }
    }
}