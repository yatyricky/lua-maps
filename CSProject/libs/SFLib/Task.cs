using System;
using System.Runtime.CompilerServices;

namespace SFLib;

[AsyncMethodBuilder(typeof(TaskMethodBuilder))]
public readonly struct Task
{
    public static Task Delay(int milliseconds) => default;

    public TaskAwaiter GetAwaiter() => default;
}

public readonly struct TaskAwaiter : ICriticalNotifyCompletion
{
    public bool IsCompleted => false;

    public void GetResult()
    {
    }

    public void OnCompleted(Action continuation)
    {
    }

    public void UnsafeOnCompleted(Action continuation)
    {
    }
}

public struct TaskMethodBuilder
{
    public static TaskMethodBuilder Create() => default;

    public Task Task => default;

    public void Start<TStateMachine>(ref TStateMachine stateMachine)
        where TStateMachine : IAsyncStateMachine
    {
    }

    public void SetStateMachine(IAsyncStateMachine stateMachine)
    {
    }

    public void SetException(Exception exception)
    {
    }

    public void SetResult()
    {
    }

    public void AwaitOnCompleted<TAwaiter, TStateMachine>(ref TAwaiter awaiter, ref TStateMachine stateMachine)
        where TAwaiter : INotifyCompletion
        where TStateMachine : IAsyncStateMachine
    {
    }

    public void AwaitUnsafeOnCompleted<TAwaiter, TStateMachine>(ref TAwaiter awaiter, ref TStateMachine stateMachine)
        where TAwaiter : ICriticalNotifyCompletion
        where TStateMachine : IAsyncStateMachine
    {
    }
}
