module superAwesome.parsing.events;

import superAwesome.events;
import superAwesome.triggers;
import superAwesome.simObjects;
import superAwesome.parsing.primitives;
import superAwesome.parsing.triggers;
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
	parsers["HaltSimEvent"] = &parseHaltSimEvent;
	parsers["ObjectDestructionEvent"] = &parseObjectDestructionEvent;
}

private Event parseHaltSimEvent(ElementParser xml, SimObject[string] clonableObjects)
{
	Trigger eventTrigger = parseTrigger(xml);
	assert(eventTrigger !is null, "XML has an Event that does not specify a Trigger");
	return new HaltSimEvent(eventTrigger);
}

private Event parseObjectDestructionEvent(ElementParser xml, SimObject[string] clonableObjects)
{
	Trigger eventTrigger = parseTrigger(xml);
	assert(eventTrigger !is null, "XML has an Event that does not specify a Trigger");

	auto newEvent = new ObjectDestructionEvent(eventTrigger);
	xml.onEndTag["TargetName"] = (in Element e) { newEvent.TargetName = e.text; };
	xml.parse();

	return newEvent;
}

private Trigger parseTrigger(ElementParser xml)
{
	Trigger trigger;
	xml.onStartTag["Trigger"] = (ElementParser xml)
	{
		assert(trigger is null, "XML has an Event that specifies multiple Triggers");
		string typeName = xml.tag.attr["type"];
		trigger = GetTriggerParser(typeName)(xml);
	};
	xml.parse();
	return trigger;
}
