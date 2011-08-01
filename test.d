import superAwesome.simObjects;
import superAwesome.simulations;
import superAwesome.parsing.simulations;
import std.stdio;

void main()
{
	Simulation sim = ParseSimulation("test.xml");	
	Balloon balloon = cast(Balloon)sim.FindObject("Balloon1");
	assert(balloon !is null);
	writeln(balloon.Position);
	writeln(balloon.Velocity);
	writeln(balloon.Orientation);
	writeln(balloon.AngularVelocity);
	writeln(balloon.Radius);
	writeln(balloon.Mass);
}
