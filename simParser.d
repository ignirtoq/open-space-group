module superAwesome.simParser;

import superAwesome.geometry;
import superAwesome.simulations;
import std.file;
import std.stdio;

private delegate 

public Simulation ParseSimulation(string simFile)
{
	string simFileText = cast(string)read(simFile);
	check(simFileText);

	auto xmlParser = DocumentParser(simFileText);
	Simulation parsedSimulation = new Simulation();
	xmlParser.parse();
	return parsedSimulation;
}

private Vector3 parseVector(in Element e)
{
}

private Quaternion parseQuaternion(in Element e)
{
}

private real parseReal(in Element e)
{
}
