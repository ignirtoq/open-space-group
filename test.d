import superAwesome.simObjects;
import superAwesome.simulations;
import superAwesome.parsing.simulations;
import std.stdio;

void main()
{
	Simulation sim = ParseSimulation("test2.xml");	
	auto balloon = cast(Rocket)sim.FindObject("Rocket1");
	foreach(x; sim.Objects)
		writeln(x.Name,x);
	assert(balloon !is null);
	writeln(balloon.Position);
	writeln(balloon.Velocity);
	writeln(balloon.Orientation);
	writeln(balloon.AngularVelocity);
	writeln(balloon.Radius);
	writeln(balloon.Mass);
}
