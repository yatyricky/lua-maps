using System;

public class TimerComponent : Component
{
    public float duration { get; private set; }
    private float elapsed;
    private Action? onComplete;
    private bool _running = false;

    /// <summary>
    /// 
    /// </summary>
    /// <param name="duration">seconds</param>
    /// <param name="onComplete"></param>
    public void StartTimer(float duration, Action onComplete)
    {
        this.duration = duration * 1000f;
        elapsed = 0f;
        this.onComplete = onComplete;
        _running = true;
    }

    public override void Update()
    {
        if (!_running) return;
        elapsed += Scene.DT;
        if (elapsed >= duration)
        {
            // Timer has completed, trigger an event or callback here
            onComplete?.Invoke();
            _running = false;
        }
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="duration"> seconds</param>
    public void ExtendTime(float duration)
    {
        this.duration += duration * 1000f;
    }
}