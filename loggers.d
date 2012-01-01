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
			currentPosition = simObject.State.Position;
		}
	}
	
	public void EndSimulation()
	{
		if(!WriteToConsole)
		{
			if(!exists("output"))
				mkdir("output");
			else
				assert(isDir("output"),"\"output\" exists and is not a directory.");
		
			chdir("output");
			if(exists(TargetName ~ ".pos.dat"))
				remove(TargetName ~ ".pos.dat");
			append(TargetName ~ ".pos.dat", outputFileContent);
			chdir("..");
		}
	}

	public void LogSimulation(Simulation sim) { }

	private bool isReadyToLog()
	{
		return !(isnan(currentTime) || isnan(currentPosition.X));
	}

	private bool isLogging = false;
	private real lastLog = 0;
	private real currentTime;
	private string outputFileContent;
	private Vector3 currentPosition;
}

public class SingleObjectVelocityLogger : Logger
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
					writefln("%f %f %f %f", currentTime, currentVelocity.X, currentVelocity.Y, currentVelocity.Z);
				else
					outputFileContent ~= format("%f %f %f %f\n", currentTime, currentVelocity.X, currentVelocity.Y, currentVelocity.Z);
			}
			currentTime = real.nan;
			currentVelocity = Vector3(real.nan, real.nan, real.nan);
		}
	}

	public void LogSimObject(SimObject simObject)
	{
		if(isLogging && simObject.Name == TargetName)
		{
			currentVelocity = simObject.State.Velocity;
		}
	}
	
	public void EndSimulation()
	{
		if(!WriteToConsole)
		{
			if(!exists("output"))
				mkdir("output");
			else
				assert(isDir("output"),"\"output\" exists and is not a directory.");
		
			chdir("output");
			if(exists(TargetName ~ ".vel.dat"))
				remove(TargetName ~ ".vel.dat");
			append(TargetName ~ ".vel.dat", outputFileContent);
			chdir("..");
		}
	}

	public void LogSimulation(Simulation sim) { }

	private bool isReadyToLog()
	{
		return !(isnan(currentTime) || isnan(currentVelocity.X));
	}

	private bool isLogging = false;
	private real lastLog = 0;
	private real currentTime;
	private string outputFileContent;
	private Vector3 currentVelocity;
}

public class SingleObjectOrientationLogger : Logger
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
					writefln("%f %f %f %f", currentTime, currentAxis.X, currentAxis.Y, currentAxis.Z);
				else
					outputFileContent ~= format("%f %f %f %f\n", currentTime, currentAxis.X, currentAxis.Y, currentAxis.Z);
			}
			currentTime = real.nan;
			currentAxis = Vector3(real.nan, real.nan, real.nan);
		}
	}

	public void LogSimObject(SimObject simObject)
	{
		if(isLogging && simObject.Name == TargetName)
		{
			currentOrientation = simObject.State.Orientation;
			currentAxis = Vector3(1,0,0).RotateBy(currentOrientation);
		}
	}
	
	public void EndSimulation()
	{
		if(!WriteToConsole)
		{
			if(!exists("output"))
				mkdir("output");
			else
				assert(isDir("output"),"\"output\" exists and is not a directory.");
		
			chdir("output");
			if(exists(TargetName ~ ".ang.dat"))
				remove(TargetName ~ ".ang.dat");
			append(TargetName ~ ".ang.dat", outputFileContent);
			chdir("..");
		}
	}

	public void LogSimulation(Simulation sim) { }

	private bool isReadyToLog()
	{
		return !(isnan(currentTime) || isnan(currentAxis.X));
	}

	private bool isLogging = false;
	private real lastLog = 0;
	private real currentTime;
	private string outputFileContent;
	private Quaternion currentOrientation;
	private Vector3 currentAxis;
}
/*
public class MultiObjectPositionLogger : Logger
{
	public real LogInterval;
	public string[] TargetNames;

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
				foreach(name; TargetNames)
					outputFilesContent[name] ~= format("%f %f %f %f\n", currentTime, currentPositions[name].X, currentPositions[name].Y, currentPositions[name].Z);
			}
			currentTime = real.nan;
			foreach(name; TargetNames)
				currentPositions[name] = Vector3(real.nan, real.nan, real.nan);
		}
	}

	public void LogSimObject(SimObject simObject)
	{
		if(isLogging && LoggedObject(simObject))
		{
			currentPositions[simObject.Name] = simObject.Position;
		}
	}
	
	public void EndSimulation()
	{
		foreach(name; TargetNames)
		{
			remove(TargetName ~ ".pos.dat");
			append(TargetName ~ ".pos.dat", outputFilesContent[name]);
		}
	}

	public void LogSimulation(Simulation sim) { }
	
	public bool LoggedObject(SimObject object)
	{
		foreach(name; TargetNames)
			if (object.Name = name)
				return true;

		return false;
	}

	private bool isReadyToLog()
	{
		return !(isnan(currentTime) || isnan(currentPosition.X));
	}

	private bool isLogging = false;
	private real lastLog = 0;
	private real currentTime;
	private string[] outputFilesContent;
	private Vector3[] currentPositions;
}*/
