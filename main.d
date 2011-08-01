module superAwesome.main;

import superAwesome.simulations;
import superAwesome.parsing.simulations;
import superAwesome.loggers;
import std.stdio;
import std.conv;
import std.math;
import std.getopt;

void main(string[] args)
{
	real startTime = 0;
	real endTime = 60*60*5;

	getopt(
		args,
		"start-time|s", &startTime,
		"end-time|e", &endTime
	);

	if(args.length != 2)
	{
		printUsage(args[0]);
		return;
	}
	
	runSimulation(args[1], startTime, endTime);	
}

void printUsage(string exeName)
{
	writefln("Usage: %s [options] simulation-file", exeName);
}

void runSimulation(string xmlName, real startTime, real endTime)
{
	Simulation sim = ParseSimulation(xmlName);
	assert(sim !is null, "sim is null");

	sim.Run(startTime, endTime);
}
