module superAwesome.util;

import superAwesome.simObjects;
import superAwesome.events;
import std.math;
import std.string;

public struct Vector3
{
	public string toString()
	{
		return format("(%f, %f, %f)", X, Y, Z);
	}
	
	public real LengthSquared()
	{
		return X*X + Y*Y + Z*Z;
	}
	
	public real Length()
	{
		return sqrt(LengthSquared());
	}
	
	public Vector3 Add(Vector3 other)
	{
		return Vector3(X+other.X, Y+other.Y, Z+other.Z);
	}

	public Vector3 Subtract(Vector3 other)
	{
		return Vector3(X-other.X, Y-other.Y, Z-other.Z);
	}
	
	public real Dot(Vector3 other)
	{
		return X*other.X + Y*other.Y + Z*other.Z;
	}
	
	public Vector3 Scale(real scalar)
	{
		return Vector3(scalar*X, scalar*Y, scalar*Z);
	}
	
	public Vector3 Normalize()
	{
		real length = Length();
		return Vector3(X/length, Y/length, Z/length);
	}
	
	public Vector3 Cross(Vector3 other)
	{
		return Vector3
		(
			Y*other.Z - other.Y*Z,
			Z*other.X - other.Z*X,
			X*other.Y - other.X*Y
		);
	}
	
	public real X,Y,Z;
}

public struct Stage
{
	public real StartTime;
	public real TimeStep;
	public SimObject[] Objects;
}

public struct Simulation
{
	public Event[] GetEvents(real startTime, real endTime)
	{
		Event[] matchedEvents = new Event[0];
		foreach(event; Events)
		{
			if(event.Time > startTime && event.Time < endTime)
				matchedEvents ~= event;
		}
		return matchedEvents;
	}
	
	real EndTime;
	Stage[] Stages;
	Event[] Events;
}