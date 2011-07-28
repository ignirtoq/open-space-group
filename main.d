module main;

import superAwesome.util;
import superAwesome.simObjects;
import superAwesome.events;
import std.stdio;
import std.algorithm;

void main(string[] argv)
{
	Simulation sim = createSimulation();
	
	real simTime = 0;
	
	bool stageCmp(Stage stage1, Stage stage2)
	{
		return stage1.StartTime < stage2.StartTime;
	}
	
	Stage[] sortedStages = new Stage[0];
	foreach(stage; sort!(stageCmp)(sim.Stages))
		sortedStages ~= stage;
	assert(sortedStages.length > 0);
	simTime = sortedStages[0].StartTime;
	
	for(int i = 0; i < sortedStages.length; i++)
	{
		for(; simTime < (i+1 < sortedStages.length ? sortedStages[i+1].StartTime : sim.EndTime); simTime += sortedStages[i].TimeStep)
		{
			foreach(event; sim.GetEvents(simTime, simTime + sortedStages[i].TimeStep))
			{
				foreach(simObject; sortedStages[i].Objects)
				{
					//std.stdio.writefln("Before %s", simObject.Velocity);
					event.Apply(simObject);
					//std.stdio.writefln("After %s", simObject.Velocity);
				}
			}
			foreach(simObject; sortedStages[i].Objects)
			{
				std.stdio.writefln("%s %e %e %e %e", simObject.Name, simTime, simObject.Position.X, simObject.Position.Y, simObject.Position.Z);
				simObject.Update(sortedStages[i].TimeStep);
			}
		}
	}
	
	
	
	//real simTime = stages[0].StartTime;
	//for(; simTime < simEndTime; simTime += stages[0].TimeStep)
	//{
	//    foreach(simObject; stages[0].Objects)
	//    {
	//        std.stdio.writefln("%s %e %e %e %e", simObject.Name, simTime, simObject.Position.X, simObject.Position.Y, simObject.Position.Z);
	//        simObject.Update(stages[0].TimeStep);
	//    }
	//}
}

Simulation createSimulation()
{
	SimObject[] objects = [new Balloon("Test_Ballon", 1, 1)];
	Stage[] stages = new Stage[0];
	Event[] events = new Event[0];
	stages ~= Stage(0, 0.01, objects);
	events ~= new ImpulseEvent(6000, Vector3(0, -1000, 0));
	
	return Simulation(10000, stages, events);
}
