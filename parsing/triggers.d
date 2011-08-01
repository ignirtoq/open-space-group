module superAwesome.parsing.triggers;

import superAwesome.triggers;
import superAwesome.parsing.primitives;
import std.xml;

public alias Trigger function(ElementParser xml) TriggerParser;

public TriggerParser GetEventParser(string typeName)
{
	assert(typeName in parsers);
	return parsers[typeName];
}
private TriggerParser[string] parsers;

static this()
{
}
