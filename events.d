module superAwesome.events;

import superAwesome.simulations;
import superAwesome.geometry;
import superAwesome.simObjects;
import superAwesome.triggers;
import std.stdio;

public abstract class Event
{
	public .Trigger Trigger;

	public abstract void Apply(Simulation sim);
}

public class ImpulseEvent : Event
{
	public Vector3 Impulse;
	public string TargetName;

	public void Apply(Simulation sim)
	{
		SimObject target = sim.FindObject(TargetName);
		if(target !is null)
			target.ApplyImpulse(Impulse);
	}
}

public class ObjectDestructionEvent : Event
{
	public string TargetName;

	public void Apply(Simulation sim)
	{
		sim.RemoveObject(TargetName);
	}
}

public class HaltSimEvent : Event
{
	public void Apply(Simulation sim)
	{
		sim.IsRunning = false;
	}
}

public class ChangeTimeStepEvent : Event
{
	public real NewTimeStep;
	
	public void Apply(Simulation sim)
	{
		sim.TimeStep = NewTimeStep;
	}
}
