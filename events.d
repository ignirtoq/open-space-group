module superAwesome.events;

import superAwesome.simulations;
import superAwesome.geometry;
import superAwesome.simObjects;
import superAwesome.triggers;
import std.stdio;

public abstract class Event
{
	protected this(.Trigger trigger)
	{
		this.trigger = trigger;
	}

	public @property .Trigger Trigger() { return trigger; }
	private .Trigger trigger;

	public abstract void Apply(Simulation sim);
}

public class OneTimeEvent : Event
{
	public this(Event event)
	{
		super(event.Trigger);
		this.innerEvent = event;
	}

	public void Apply(Simulation sim)
	{
		sim.RemoveEvent(this);
		innerEvent.Apply(sim);
	}

	private Event innerEvent;
}

public class ImpulseEvent : Event
{
	public Vector3 Impulse;
	public string TargetName;

	public this(.Trigger trigger)
	{
		super(trigger);
	}

	public void Apply(Simulation sim)
	{
		SimObject target = sim.FindObject(TargetName);
		if(target !is null)
			target.ApplyImpulse(Impulse);
	}
}

public class ObjectCreationEvent : Event
{
	public SimObject Template;
	public string NewName;
	public string Location;

	public this(.Trigger trigger)
	{
		super(trigger);
	}

	public void Apply(Simulation sim)
	{
		SimObject newObject = Template.Clone(NewName);
		SimObject locationObject = Location is null ? null : sim.FindObject(Location);

		if(locationObject is null)
			newObject.Position = Vector3(0,0,0);
		else
			newObject.Position = locationObject.Position;

		sim.AddObject(newObject);
	}
}

public class ObjectDestructionEvent : Event
{
	public string TargetName;

	public this(.Trigger trigger)
	{
		super(trigger);
	}

	public void Apply(Simulation sim)
	{
		sim.RemoveObject(TargetName);
	}
}

public class HaltSimEvent : Event
{
	public this(.Trigger trigger)
	{
		super(trigger);
	}

	public void Apply(Simulation sim)
	{
		sim.IsRunning = false;
	}
}

public class ChangeTimeStepEvent : Event
{
	public real NewTimeStep;
	
	public this(.Trigger trigger)
	{
		super(trigger);
	}
	
	public void Apply(Simulation sim)
	{
		sim.TimeStep = NewTimeStep;
	}
}
