using System;

public class TimerComponent : Component
{
    private float duration = -1f;
    private float elapsed;
    private Action? onComplete;
    private bool _running = false;

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
}