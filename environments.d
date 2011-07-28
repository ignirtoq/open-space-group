module superAwesome.environments;

import superAwesome.geometry;
import superAwesome.constants;
import std.math;

public abstract class EnvironmentService
{
	public abstract real Temperature(Vector3 position);
	public abstract real Pressure(Vector3 position);
	public abstract real Density(Vector3 position);
}

public class OneLayerSteadyStateEnvironment : EnvironmentService
{
	public real Temperature(Vector3 position)
	{
		assert(false);
	}

	public real Pressure(Vector3 position)
	{
		assert(false);
	}

	public real Density(Vector3 position)
	{
		real height = position.Length() - RADIUS_OF_EARTH;
		return densityAirSTP * exp(-height / 8e3);
	}
	private const real densityAirSTP = 1.21;
}
