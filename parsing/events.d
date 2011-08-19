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
	parsers["ObjectCreationEvent"] = &parseObjectCreationEvent;
	parsers["ChangeTimeStepEvent"] = &parseChangeTimeStepEvent;
	parsers["ChangeMassEvent"] = &parseChangeMassEvent;
	parsers["ReorientEvent"] = &parseReorientEvent;
}

private Event parseHaltSimEvent(ElementParser xml, SimObject[string] clonableObjects)
{
	auto newEvent = new HaltSimEvent();
	hookupTriggerParser(xml, newEvent);
	xml.parse();

	assert(newEvent.Trigger !is null, "XML has an Event that does not specify a Trigger");
	return newEvent;
}

private Event parseObjectCreationEvent(ElementParser xml, SimObject[string] clonableObjects)
{
	auto newEvent = new ObjectCreationEvent();
	string templateName;
	hookupTriggerParser(xml, newEvent);
	xml.onEndTag["TemplateName"] = (in Element e) { templateName = e.text; };
	xml.onEndTag["NewName"] = (in Element e) { newEvent.NewName = e.text; };
	xml.onEndTag["AttributeSourceName"] =  (in Element e) { newEvent.AttributeSourceName = e.text; };
	xml.parse();

	assert(templateName in clonableObjects, "XML has an ObjectCreationEvent that references a non-existant template");
	newEvent.Template = clonableObjects[templateName];
	return newEvent;
}

private Event parseObjectDestructionEvent(ElementParser xml, SimObject[string] clonableObjects)
{
	auto newEvent = new ObjectDestructionEvent();
	hookupTriggerParser(xml, newEvent);
	xml.onEndTag["TargetName"] = (in Element e) { newEvent.TargetName = e.text; };
	xml.parse();

	assert(newEvent.Trigger !is null, "XML has an Event that does not specify a Trigger");
	return newEvent;
}

private Event parseChangeTimeStepEvent(ElementParser xml, SimObject[string] clonableObjects)
{
	auto newEvent = new ChangeTimeStepEvent();
	hookupTriggerParser(xml, newEvent);
	xml.onEndTag["NewTimeStep"] = (in Element e) { newEvent.NewTimeStep = ParseReal(e); };
	xml.parse();
	
	assert(newEvent.Trigger !is null, "XML has an Event that does not specify a Trigger");
	return newEvent;
}

private Event parseChangeMassEvent(ElementParser xml, SimObject[string] clonableObjects)
{
	auto newEvent = new ChangeMassEvent();
	hookupTriggerParser(xml, newEvent);
	xml.onEndTag["TargetName"] = (in Element e) { newEvent.TargetName = e.text; };
	xml.onEndTag["NewMass"] = (in Element e) { newEvent.NewMass = ParseReal(e); };
	xml.parse();

	assert(newEvent.Trigger !is null, "XML has an Event that does not specify a Trigger");
	return newEvent;
}

private Event parseReorientEvent(ElementParser xml, SimObject[string] clonableObjects)
{
	auto newEvent = new ReorientEvent();
	hookupTriggerParser(xml, newEvent);
	xml.onEndTag["TargetName"] = (in Element e) { newEvent.TargetName = e.text; };
	xml.onEndTag["Rotation"] = (in Element e) { newEvent.Rotation = ParseQuaternion(e); };
	xml.parse();

	assert(newEvent.Trigger !is null, "XML has an Event that does not specify a Trigger");
	return newEvent;
}

private void hookupTriggerParser(ElementParser xml, Event event)
{
	xml.onStartTag["Trigger"] = (ElementParser xml)
	{
		assert(event.Trigger is null, "XML has an Event that specifies multiple Triggers");
		string typeName = xml.tag.attr["type"];
		event.Trigger = GetTriggerParser(typeName)(xml);
	};
}
