module superAwesome.triggers;

import superAwesome.simulations;
import superAwesome.simObjects;

public abstract class Trigger
{
	public abstract bool IsTriggered(Simulation sim);
}

public class RadiusTrigger : Trigger
{
	public real Radius;
	public string TargetName;

	public bool IsTriggered(Simulation sim)
	{
		if(TargetName !is null)
		{
			SimObject target = sim.FindObject(TargetName);
			if(target !is null && target.Position.Length() >= Radius)
				return true;
			else
				return false;
		}
		else
		{
			foreach(simObject; sim.Objects)
			{
				if(simObject.Position.Length() >= Radius)
					return true;
			}
			return false;
		}
	}
}

public class FloorTrigger : Trigger
{
	public real Floor;
	public string TargetName;

	public bool IsTriggered(Simulation sim)
	{
		if(TargetName !is null)
		{
			SimObject target = sim.FindObject(TargetName);
			if(target !is null && target.Position.Length() < Floor)
				return true;
			else
				return false;
		}
		else
		{
			foreach(simObject; sim.Objects)
			{
				if(simObject.Position.Length() < Floor)
					return true;
			}
			return false;
		}
	}
}
