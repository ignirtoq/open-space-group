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
}


