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
        try
        {
            while (true)
            {
                await Task.Delay(100);
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
        catch (System.Exception e)
        {
            BJDebugMsg($"{e}");
            PrintStackTrace();
        }
    }
}