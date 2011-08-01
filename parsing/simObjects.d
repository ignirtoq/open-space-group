module superAwesome.parsing.simObjects;

import superAwesome.geometry;
import superAwesome.simObjects;
import superAwesome.parsing.primitives;
import std.xml;
import std.stdio;

public alias SimObject function(ElementParser xml) SimObjectParser;

public SimObjectParser GetSimObjectParser(string typeName)
{
	assert(typeName in parsers);
	return parsers[typeName];
}
private SimObjectParser[string] parsers;

static this()
{
	parsers["Balloon"] = &parseBalloon;
}

public SimObject parseBalloon(ElementParser xml)
{
	Balloon newBalloon = new Balloon(xml.tag.attr["name"]);
	readyBaseParser(xml, newBalloon);
	xml.onEndTag["Radius"] = (in Element e) { newBalloon.Radius = ParseReal(e); };
	xml.onEndTag["Mass"] = (in Element e) { newBalloon.Mass = ParseReal(e); };
	xml.parse();
	return newBalloon;
} 

private void readyBaseParser(ElementParser xml, SimObject simObject)
{
	xml.onEndTag["Position"] = (in Element e) { simObject.Position = ParseVector3(e); };
	xml.onEndTag["Velocity"] = (in Element e) { simObject.Velocity = ParseVector3(e); };
	xml.onEndTag["AngularVelocity"] = (in Element e) { simObject.AngularVelocity = ParseVector3(e); };
	xml.onEndTag["Orientation"] = (in Element e) { simObject.Orientation = ParseQuaternion(e); };
}
