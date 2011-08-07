module superAwesome.parsing.simulations;

import superAwesome.simulations;
import superAwesome.simObjects;
import superAwesome.events;
import superAwesome.loggers;
import superAwesome.parsing.primitives;
import superAwesome.parsing.simObjects;
import superAwesome.parsing.environments;
import superAwesome.parsing.loggers;
import superAwesome.parsing.events;
import std.file;
import std.stdio;
import std.xml;
import std.conv;

public Simulation ParseSimulation(string simFile)
{
	string simFileText = cast(string)read(simFile);
	check(simFileText);

	auto xmlParser = new DocumentParser(simFileText);
	Simulation parsedSimulation;

	assert(xmlParser.tag.name == "Simulation", "XML does not have correct root tag");
	parsedSimulation = new Simulation();
	SimObject[string] simObjects;

	xmlParser.onStartTag["SimObject"] = (ElementParser simObjectParser)
	{
		string typeName = simObjectParser.tag.attr["type"];
		bool reserved = ("reserved" in simObjectParser.tag.attr) !is null && to!(bool)(simObjectParser.tag.attr["reserved"]);
		SimObject newObject = GetSimObjectParser(typeName)(simObjectParser);
		assert((newObject.Name in simObjects) is null, "XML has a SimObject name collision");
		simObjects[newObject.Name] = newObject;

		if(!reserved)
			parsedSimulation.AddObject(newObject);
	};

	xmlParser.onStartTag["Environment"] = (ElementParser environmentParser)
	{
		assert(parsedSimulation.Environment is null, "XML contains multiple environments");
		string typeName = environmentParser.tag.attr["type"];
		parsedSimulation.Environment = GetEnvironmentParser(typeName)(environmentParser);
	};

	xmlParser.onStartTag["Event"] = (ElementParser eventParser)
	{
		string typeName = eventParser.tag.attr["type"];
		Event newEvent = GetEventParser(typeName)(eventParser, simObjects);
		parsedSimulation.AddEvent(newEvent);
	};

	xmlParser.onStartTag["Logger"] = (ElementParser loggerParser)
	{
		string typeName = loggerParser.tag.attr["type"];
		parsedSimulation.Loggers ~= GetLoggerParser(typeName)(loggerParser);
	};

	xmlParser.onEndTag["TimeStep"] = (in Element e) { parsedSimulation.TimeStep = ParseReal(e); };
	xmlParser.parse();

	assert(parsedSimulation.TimeStep > 0, "XML file defined an invalid TimeStep or provided no TimeStep at all");
	assert(parsedSimulation.Environment !is null, "XML file provided no Environment");
	assert(parsedSimulation.Loggers[0] !is null, "XML file provided no Logger");

	return parsedSimulation;
}
