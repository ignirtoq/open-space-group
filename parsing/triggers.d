module superAwesome.parsing.triggers;

import superAwesome.triggers;
import superAwesome.parsing.primitives;
import std.xml;

public alias Trigger function(ElementParser xml) TriggerParser;

public TriggerParser GetTriggerParser(string typeName)
{
	assert(typeName in parsers);
	return parsers[typeName];
}
private TriggerParser[string] parsers;

static this()
{
	parsers["TurnAroundTrigger"] = &parseTurnAroundTrigger;
}

private Trigger parseTurnAroundTrigger(ElementParser xml)
{
	auto newTrigger = new TurnAroundTrigger();

	xml.onEndTag["TargetName"] = (in Element e) { newTrigger.TargetName = e.text; };
	xml.parse();

	return newTrigger;
}
