module superAwesome.parsing.loggers;

import superAwesome.loggers;
import superAwesome.parsing.primitives;
import std.xml;

public alias Logger function(ElementParser xml) LoggerParser;

public LoggerParser GetLoggerParser(string typeName)
{
	assert(typeName in parsers);
	return parsers[typeName];
}
private LoggerParser[string] parsers;

static this()
{
	parsers["SingleObjectPositionLogger"] = &parseSingleObjectPositionLogger;
	parsers["SingleObjectVelocityLogger"] = &parseSingleObjectVelocityLogger;
}

private Logger parseSingleObjectPositionLogger(ElementParser xml)
{
	SingleObjectPositionLogger newLogger = new SingleObjectPositionLogger();

	xml.onEndTag["TargetName"] = (in Element e) { newLogger.TargetName = e.text; };
	xml.onEndTag["LogInterval"] = (in Element e) { newLogger.LogInterval = ParseReal(e); };
	xml.onEndTag["WriteToConsole"] = (in Element e) { newLogger.WriteToConsole = ParseBool(e); };
	xml.parse();

	return newLogger;
}

private Logger parseSingleObjectVelocityLogger(ElementParser xml)
{
	SingleObjectVelocityLogger newLogger = new SingleObjectVelocityLogger();

	xml.onEndTag["TargetName"] = (in Element e) { newLogger.TargetName = e.text; };
	xml.onEndTag["LogInterval"] = (in Element e) { newLogger.LogInterval = ParseReal(e); };
	xml.onEndTag["WriteToConsole"] = (in Element e) { newLogger.WriteToConsole = ParseBool(e); };
	xml.parse();

	return newLogger;
}
/*
private Logger parseMultiObjectPositionLogger(ElementParser xml)
{
	MultiObjectPositionLogger newLogger = new MultiObjectPositionLogger();

	xml.onEndTag["TargetName"] = (in Element e) { newLogger.TargetNames ~= e.text; };
	xml.onEndTag["LogInterval"] = (in Element e) { newLogger.LogInterval = ParseReal(e); };
	xml.onEndTag["WriteToConsole"] = (in Element e) { newLogger.WriteToConsole = ParseBool(e); };
	xml.parse();

	return newLogger;
}
*/