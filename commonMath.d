module superAwesome.commonMath;

import superAwesome.geometry;
import superAwesome.constants;
import std.math;

/*
Implementations of commonly used physics and math.
All functions in this module assume a coordinate system in which
the center of the Earth is at the origin.
*/

public Vector3 GravitationalForce(Vector3 position, real mass)
{
	return (-GRAVITATIONAL_CONSTANT * MASS_OF_EARTH * mass / (position.LengthSquared() * position.Length())) * position;
}

public Vector3 DragForce(Vector3 position, Vector3 velocity, real crossectionalArea, real dragCoefficient, real delegate(Vector3 pos) density)
{
	auto RotatingVelocity = Vector3(velocity.X + position.Y * ANGULAR_VELOCITY_OF_EARTH, velocity.Y - position.X * ANGULAR_VELOCITY_OF_EARTH, velocity.Z);
	return -0.5 * density(position) * dragCoefficient * crossectionalArea * RotatingVelocity.Length() * RotatingVelocity;
}

public Vector3 BuoyantForce(Vector3 position, real mass, real volume, real delegate(Vector3 pos) density)
{
	return 2 * density(position) * volume / (mass + density(position) * volume) * (-1)*GravitationalForce(position, mass);
}
