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

public class NaiveNASAEnvironment : EnvironmentService
{

//Returns the air temperature at a given position above Earth's surface.
//Vector3 position is relative to Earth's center.
	public real Temperature(Vector3 position)
	{
		if(position.Length() - RADIUS_OF_EARTH < 11019)
			return (position.Length() - RADIUS_OF_EARTH) / 1000 * (-9.8) + AIR_SURFACE_TEMPERATURE;
		else if(position.Length() - RADIUS_OF_EARTH < 25098)
			return 216.483333;
		else
			return (-205.05 + .00164 * 3.2808399 * (position.Length() - RADIUS_OF_EARTH) - 32) * 5 / 9 + 273.15;
	}

//Returns the air pressure at a given position above Earth's surface.
//Vector3 position is relative to Earth's center.
//Converted from NASA's website.  Crazy bastards use imperial units.
//http://www.grc.nasa.gov/WWW/K-12/airplane/atmos.html
	public real Pressure(Vector3 position)
	{
		if(position.Length() - RADIUS_OF_EARTH < 11019)
			return 47.8477908 * (2116 * pow((59 - .00356 * 3.2808399 * (position.Length() - RADIUS_OF_EARTH) + 459.7)/518.6, 5.256));
		else if(position.Length() - RADIUS_OF_EARTH < 25098)
			return 47.8477908 * (473.1 * exp(1.73 - .000048 * 3.2808399 * (position.Length() - RADIUS_OF_EARTH)));
		else
			return 47.8477908 * (51.97 * pow((254.65 + .00164 * 3.2808399 * (position.Length() - RADIUS_OF_EARTH)) / 398.98,-11.388));
	}

	public real Density(Vector3 position)
	{
		return Pressure(position) / AIR_SPECIFIC_GAS_CONSTANT / Temperature(position);
	}
}

public class NaiveWikiEnvironment : EnvironmentService
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