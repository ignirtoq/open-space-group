module superAwesome.commonMath;

import superAwesome.geometry;
import superAwesome.constants;
import std.math;

/*
Implementations of commonly used physics and math.
All functions in this module assume a coordinate system in which
the center of the Earth is at the origin.
*/

//Returns the force vector due to gravity at the specified position
public Vector3 GravitationalForce(Vector3 position, real mass)
{
	return (-GRAVITATIONAL_CONSTANT * MASS_OF_EARTH * mass / (position.LengthSquared() * position.Length())) * position;
}

//Returns the air pressure at a given position above Earth's surface.
//Vector3 position is relative to Earth's center.
//Converted from NASA's website.  Crazy bastards use imperial units.
//http://www.grc.nasa.gov/WWW/K-12/airplane/atmos.html
public real AirPressure(Vector3 position)
{
	if(position.Length() - RADIUS_OF_EARTH < 11019)
		return 47.8477908 * (2116 * pow((59 - .00356 * 3.2808399 * (position.Length() - RADIUS_OF_EARTH) + 459.7)/518.6, 5.256));
	else if(position.Length() - RADIUS_OF_EARTH < 25098)
		return 47.8477908 * (473.1 * exp(1.73 - .000048 * 3.2808399 * (position.Length() - RADIUS_OF_EARTH)));
	else
		return 47.8477908 * (51.97 * pow((254.65 + .00164 * 3.2808399 * (position.Length() - RADIUS_OF_EARTH)) / 398.98,-11.388));
}

//Returns the air temperature at a given position above Earth's surface.
//Vector3 position is relative to Earth's center.
public real AirTemperature(Vector3 position)
{
	if(position.Length() - RADIUS_OF_EARTH < 11019)
		return (position.Length() - RADIUS_OF_EARTH) / 1000 * (-9.8) + AIR_SURFACE_TEMPERATURE;
	else if(position.Length() - RADIUS_OF_EARTH < 25098)
		return 216.483333;
	else
		return (-205.05 + .00164 * 3.2808399 * (position.Length() - RADIUS_OF_EARTH) - 32) * 5 / 9 + 273.15;
}

//Returns the density of air at a given position above Earth's surface.
//Vector3 position is relative to Earth's center.
public real AirDensity(Vector3 position)
{
	return AirPressure(position) / AIR_SPECIFIC_GAS_CONSTANT / AirTemperature(position);
}

//Returns the force due to drag
public Vector3 DragForce(Vector3 position, Vector3 velocity, real crossectionalArea, real dragCoefficient, real delegate(Vector3 pos) density)
{
	return -0.5 * density(position) * dragCoefficient * crossectionalArea * velocity.Length() * velocity;
}

//Returns force due to buoyancy
public Vector3 BuoyantForce(Vector3 position, real mass, real volume, real delegate(Vector3 pos) density)
{
	return 2 * density(position) * volume / (mass + density(position) * volume) * (-1)*GravitationalForce(position, mass);
}

public Quaternion AngularVelocityToQuaternion(Vector3 torque, real timeStep)
{
//Ignore me
	assert(false);
}
