module superAwesome.loggers;

import superAwesome.simObjects;
import superAwesome.simulations;
import superAwesome.geometry;
import std.stdio;
import std.math;
import std.file;
import std.string;

public abstract class Logger
{
	public abstract void BeginTimeStep(real time);
	public abstract void EndTimeStep();
	public abstract void LogSimObject(SimObject simObject);
	public abstract void LogSimulation(Simulation sim);
	public abstract void EndSimulation();
}

public class SingleObjectPositionLogger : Logger
{
	public real LogInterval;
	public string TargetName;
	public bool WriteToConsole = false;

	public void BeginTimeStep(real time)
	{
		if(time - lastLog >= LogInterval)
		{
			currentTime = time;
			isLogging = true;
		}
	}

	public void EndTimeStep()
	{
		if(isLogging)
		{
			lastLog = currentTime;
			isLogging = false;
			if(isReadyToLog())
			{
				if(WriteToConsole)
					writefln("%f %f %f %f", currentTime, currentPosition.X, currentPosition.Y, currentPosition.Z);
				else
					outputFileContent ~= format("%f %f %f %f\n", currentTime, currentPosition.X, currentPosition.Y, currentPosition.Z);
			}
			currentTime = real.nan;
			currentPosition = Vector3(real.nan, real.nan, real.nan);
		}
	}

	public void LogSimObject(SimObject simObject)
	{
		if(isLogging && simObject.Name == TargetName)
		{
			currentPosition = simObject.Position;
		}
	}

	public void LogSimulation(Simulation sim) { }

	private bool isReadyToLog()
	{
		return !(isnan(currentTime) || isnan(currentPosition.X));
	}
	
	void EndSimulation()
	{
		remove(TargetName ~ ".pos.dat");
		append(TargetName ~ ".pos.dat", outputFileContent);
	}

	private bool isLogging = false;
	private real lastLog = 0;
	private real currentTime;
	private string outputFileContent;
	private Vector3 currentPosition;
}
