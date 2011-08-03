import superAwesome.simObjects;
import superAwesome.simulations;
import superAwesome.parsing.simulations;
import std.stdio;

void main()
{
	Simulation sim = ParseSimulation("test.xml");
	foreach(x; sim.Events)
		writeln(x);
}
