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
}

private Logger parseSingleObjectPositionLogger(ElementParser xml)
{
	SingleObjectPositionLogger newLogger = new SingleObjectPositionLogger();

	xml.onEndTag["TargetName"] = (in Element e) { newLogger.TargetName = e.text; };
	xml.onEndTag["LogInterval"] = (in Element e) { newLogger.LogInterval = ParseReal(e); };
	xml.parse();

	return newLogger;
}
