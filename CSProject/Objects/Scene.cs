using System.Threading.Tasks;
using StdLib;

public class Scene
{
    public const int DT = 20;

    private static Scene? _instance;
    public static Scene Instance => _instance ??= new Scene();

    public List<GameObject> gameObjs = new();
    private readonly List<GameObject> _destroyQueue = new();

    public void AddGameObject(GameObject obj)
    {
        gameObjs.Add(obj);
    }

    public void QueueDestroy(GameObject obj)
    {
        _destroyQueue.Add(obj);
    }

    private void FlushDestroyQueue()
    {
        for (int i = 0; i < _destroyQueue.Count; i++)
        {
            GameObject.DestroyQueued(_destroyQueue[i]);
        }

        _destroyQueue.Clear();
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

            FlushDestroyQueue();
        }
    }
}