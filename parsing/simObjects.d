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
	parsers["Rocket"] = &parseRocket;
	parsers["Satellite"] = &parseSatellite;
	parsers["TestRotationalObject"] = &parseTestRotationalObject;
}

private SimObject parseBalloon(ElementParser xml)
{
	Balloon newBalloon = new Balloon(xml.tag.attr["name"]);
	readyBaseParser(xml, newBalloon);
	xml.onEndTag["Radius"] = (in Element e) { newBalloon.Radius = ParseReal(e); };
	xml.parse();
	return newBalloon;
} 

private SimObject parseRocket(ElementParser xml)
{
	Rocket newRocket = new Rocket(xml.tag.attr["name"]);
	readyBaseParser(xml, newRocket);
	xml.onEndTag["Thrust"] = (in Element e) { newRocket.Thrust = ParseReal(e); };
	xml.onEndTag["BurnTime"] = (in Element e) { newRocket.BurnTime = ParseReal(e); };
	xml.onEndTag["FuelMass"] = (in Element e) { newRocket.FuelMass = ParseReal(e); };
	xml.onEndTag["Radius"] = (in Element e) { newRocket.Radius = ParseReal(e); };
	xml.parse();
	return newRocket;
} 

private SimObject parseSatellite(ElementParser xml)
{
	Satellite newSatellite = new Satellite(xml.tag.attr["name"]);
	readyBaseParser(xml, newSatellite);
	xml.onEndTag["MaxThrust"] = (in Element e) { newSatellite.MaxThrust = ParseReal(e); };
	xml.onEndTag["BurnTime"] = (in Element e) { newSatellite.BurnTime = ParseReal(e); };
	xml.onEndTag["Radius"] = (in Element e) { newSatellite.Radius = ParseReal(e); };
	xml.parse();
	return newSatellite;
} 

private SimObject parseTestRotationalObject(ElementParser xml)
{
	TestRotationalObject newRotObject = new TestRotationalObject(xml.tag.attr["name"]);
	readyBaseParser(xml, newRotObject);
	xml.parse();
	return newRotObject;
} 

private void readyBaseParser(ElementParser xml, SimObject simObject)
{
	xml.onEndTag["Position"] = (in Element e) { simObject.Position = ParseVector3(e); };
	xml.onEndTag["Velocity"] = (in Element e) { simObject.Velocity = ParseVector3(e); };
	xml.onEndTag["AngularMomentum"] = (in Element e) { simObject.AngularMomentum = ParseVector3(e); };
	xml.onEndTag["Orientation"] = (in Element e) { simObject.Orientation = ParseQuaternion(e); };
	xml.onEndTag["Mass"] = (in Element e) { simObject.Mass = ParseReal(e); };
	xml.onEndTag["InertiaColumn1"] = (in Element e) { Vector3 column = ParseVector3(e);
	simObject.MomentOfInertia.Components[0][0] = column.X;
	simObject.MomentOfInertia.Components[1][0] = column.Y;
	simObject.MomentOfInertia.Components[2][0] = column.Z;};
	xml.onEndTag["InertiaColumn2"] = (in Element e) { Vector3 column = ParseVector3(e);
	simObject.MomentOfInertia.Components[0][1] = column.X;
	simObject.MomentOfInertia.Components[1][1] = column.Y;
	simObject.MomentOfInertia.Components[2][1] = column.Z;};
	xml.onEndTag["InertiaColumn3"] = (in Element e) { Vector3 column = ParseVector3(e);
	simObject.MomentOfInertia.Components[0][2] = column.X;
	simObject.MomentOfInertia.Components[1][2] = column.Y;
	simObject.MomentOfInertia.Components[2][2] = column.Z;};
}
