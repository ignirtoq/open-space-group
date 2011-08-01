module superAwesome.parsing.events;

import superAwesome.events;
import superAwesome.simObjects;
import superAwesome.parsing.primitives;
import std.xml;

public alias Event function(ElementParser xml, SimObject[string] clonableObjects) EventParser;

public EventParser GetEventParser(string typeName)
{
	assert(typeName in parsers);
	return parsers[typeName];
}
private EventParser[string] parsers;

static this()
{
}
