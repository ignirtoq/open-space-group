module superAwesome.simulations;

import superAwesome.simObjects;
import superAwesome.events;
import superAwesome.environments;
import superAwesome.loggers;
import std.range;
import std.stdio;

public class Simulation
{
	public bool IsRunning = false;
	public real TimeStep;
	public EnvironmentService Environment;
	public .Logger[] Loggers;

	public this()
	{
		objects = new SimObject[0];
		events = new Event[0];
	}

	public @property InputRange!(SimObject) Objects() { return inputRangeObject(objects); }
	public void AddObject(SimObject newObject)
	{
		objects ~= newObject;
	}
	public void RemoveObject(string name)
	{
		assert(false);
	}
	public SimObject FindObject(string name)
	{
		foreach(simObject; Objects)
		{
			if(simObject.Name == name)
				return simObject;
		}
		return null;
	}

	public @property InputRange!(Event) Events() { return inputRangeObject(events); }
	public void AddEvent(Event newEvent)
	{
		events ~= newEvent;
	}
	public void RemoveEvent(Event oldEvent)
	{
		Event[] newEvents = new Event[0];
		foreach(event; events)
		{
			if(event !is oldEvent)
				newEvents ~= event;
		}
		events = newEvents;
	}

	public void Run(real startTime, real endTime)
	{
		IsRunning = true;
		for(currentTime = startTime; currentTime < endTime && IsRunning; currentTime += TimeStep)
		{
			foreach(logger; Loggers)
			{
				logger.BeginTimeStep(currentTime);
				logger.LogSimulation(this);
				foreach(simObject; Objects)
					logger.LogSimObject(simObject);
				logger.EndTimeStep();
			}

			Event[] eventsToApply = new Event[0];

			foreach(event; Events)
			{
				if(event.Trigger.IsTriggered(this))
					eventsToApply ~= event;
			}

			foreach(event; eventsToApply)
			{
				event.Apply(this);
				RemoveEvent(event);
			}

			foreach(simObject; Objects)
				simObject.Update(TimeStep, Environment);
		}
		foreach(logger; Loggers)
			logger.EndSimulation();
		IsRunning = false;
	}

	private SimObject[] objects;
	private Event[] events;
	private real currentTime;
}
