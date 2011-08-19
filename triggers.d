module superAwesome.triggers;

import superAwesome.simulations;
import superAwesome.simObjects;
import superAwesome.geometry;

public abstract class Trigger
{
	public abstract bool IsTriggered(Simulation sim);
}

public class TurnAroundTrigger : Trigger
{
	public string TargetName;

	public bool IsTriggered(Simulation sim)
	{
		auto target = sim.FindObject(TargetName);
		if(target is null)
		{
			reset();
			return false;
		}

		scope(exit) lastVelocity = target.Velocity;
	
		if(hasPreviousVelocity)
		{
			if(lastVelocity.Dot(target.Velocity) < 0)
				return true;
			else
				return false;

		}
		hasPreviousVelocity = true;
		return false;
	}

	private void reset()
	{
		hasPreviousVelocity = false;
	}

	private Vector3 lastVelocity;
	private bool hasPreviousVelocity = false;
}

public class FloorTrigger : Trigger
{
	public real Floor;
	public string TargetName;

	public bool IsTriggered(Simulation sim)
	{
		if(TargetName !is null)
			return isTriggeredForTarget(TargetName, sim);
		else
			return isTriggeredForAny(sim);
	}

	private bool isTriggeredForTarget(string targetName, Simulation sim)
	{
		auto target = sim.FindObject(targetName);
		if(target !is null && target.Position.Length() < Floor)
			return true;
		else
			return false;
	}

	private bool isTriggeredForAny(Simulation sim)
	{
		foreach(simObject; sim.Objects)
		{
			if(simObject.Position.Length() < Floor)
				return true;
		}
		return false;
	}
}

public class TangentVelocityTrigger : Trigger
{
	public string TargetName;
	
	public bool IsTriggered(Simulation sim)
	{
		auto target = sim.FindObject(TargetName);
		if(target is null)
		{
			reset();
			return false;
		}

		scope(exit) lastVelocity = target.Velocity;
	
		if(hasPreviousVelocity)
		{
			if(lastVelocity.Dot(target.Position) > 0 && target.Velocity.Dot(target.Position) <= 0)
				return true;
			else
				return false;

		}
		hasPreviousVelocity = true;
		return false;
	}

	private void reset()
	{
		hasPreviousVelocity = false;
	}
	
	private Vector3 lastVelocity;
	private bool hasPreviousVelocity = false;
}