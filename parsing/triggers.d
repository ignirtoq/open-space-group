module superAwesome.parsing.triggers;

import superAwesome.triggers;
import superAwesome.parsing.primitives;
import std.xml;

public alias Trigger function(ElementParser xml) TriggerParser;

public TriggerParser GetTriggerParser(string typeName)
{
	assert(typeName in parsers, typeName);
	return parsers[typeName];
}
private TriggerParser[string] parsers;

static this()
{
	parsers["TurnAroundTrigger"] = &parseTurnAroundTrigger;
	parsers["FloorTrigger"] = &parseFloorTrigger;
}

private Trigger parseTurnAroundTrigger(ElementParser xml)
{
	auto newTrigger = new TurnAroundTrigger();

	xml.onEndTag["TargetName"] = (in Element e) { newTrigger.TargetName = e.text; };
	xml.parse();

	return newTrigger;
}

private Trigger parseFloorTrigger(ElementParser xml)
{
	auto newTrigger = new FloorTrigger();

	xml.onEndTag["Floor"] = (in Element e) { newTrigger.Floor = ParseReal(e); };
	xml.onEndTag["TargetName"] = (in Element e) { newTrigger.TargetName = e.text; };
	xml.parse();

	return newTrigger;
}
