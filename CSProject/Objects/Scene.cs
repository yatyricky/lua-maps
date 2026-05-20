using System.Threading.Tasks;
using SFLib.Collections;

public class Scene
{
    public const int DT = 20;

    private static Scene? _instance;
    public static Scene Instance => _instance ??= new Scene();

    public List<GameObject> gameObjs = new();

    public void AddGameObject(GameObject obj)
    {
        gameObjs.Add(obj);
    }

    public async void Run()
    {
        while (true)
        {
            await Task.Delay(DT);
            var rootObjs = new List<GameObject>();
            foreach (var obj in gameObjs)
            {
                if (obj.transform.parent == null)
                {
                    rootObjs.Add(obj);
                }
            }
            foreach (var obj in rootObjs)
            {
                obj.Update();
            }
        }
    }
}