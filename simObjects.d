module superAwesome.simObjects;

import superAwesome.environments;
import superAwesome.geometry;
import superAwesome.constants;
import superAwesome.commonMath;
import std.math;
import std.stdio;

template CopySimObject(string from, string to)
{
	const string CopySimObject = "
	" ~ to ~ ".Position = " ~ from ~ ".Position;
	" ~ to ~ ".Velocity = " ~ from ~ ".Velocity;
	" ~ to ~ ".Orientation = " ~ from ~ ".Orientation;
	" ~ to ~ ".AngularVelocity = " ~ from ~ ".AngularVelocity;
	";
}

public abstract class SimObject
{
	public Vector3 Position;
	public Vector3 Velocity;
	public Quaternion Orientation;
	public Vector3 AngularVelocity;
	public real Mass = 1.0;
	public Vector3 MomentOfInertia;

	public @property string Name() { return name; }
	private string name;
	
	public abstract void Update(real timeStep, EnvironmentService environment);
	public abstract SimObject Clone(string newName);
	public abstract void ApplyImpulse(Vector3 impulse);
	
	public this(string name)
	{
		this.name = name;
	}
}

public class Balloon : SimObject
{
	public real Radius;

	public this(string name)
	{
		super(name);
	}

	public void Update(real timeStep, EnvironmentService environment)
	{
		Vector3 gravity = (1.0 / Mass) * GravitationalForce(Position, Mass);
		Vector3 drag = (1.0 / Mass) * DragForce(Position, Velocity, area, dragConstant, &environment.Density);
		Vector3 buoyancy = (1.0 / Mass) * BuoyantForce(Position, Mass, volume, &environment.Density);

		Vector3 acceleration = gravity + buoyancy + drag;
		Velocity = Velocity + (acceleration * timeStep);
		Position = Position + (Velocity * timeStep);
	}

	public SimObject Clone(string newName)
	{
		Balloon newBalloon = new Balloon(newName);
		newBalloon.Radius = Radius;
		newBalloon.Mass = Mass;
		mixin(CopySimObject!("this", "newBalloon"));
		return newBalloon;
	}

	public void ApplyImpulse(Vector3 impulse)
	{
		Velocity = Velocity + ((1.0 / Mass) * impulse);
	}
	
	private @property real volume() { return 4.0/3.0 * PI * pow(Radius, 3); }
	private @property real area() { return PI * pow(Radius, 2); }
	private real dragConstant = 0.47;
}

public class Rocket : SimObject
{
	public Vector3 CenterOfPressure = Vector3(0,0,-1);
	public real Thrust;
	public real BurnTime = 0;
	public real FuelMass = 0;
	public real Radius = 0.15;

	public this(string name)
	{
		super(name);
	}
	
	public void Update(real timeStep, EnvironmentService environment)
	{
		Vector3 gravity = (1.0 / Mass) * GravitationalForce(Position, Mass);
		Vector3 drag = (1.0 / Mass) * DragForce(Position, Velocity, area, 0.5, &environment.Density);

		Vector3 thrustVector = -Thrust / Mass * CenterOfPressure.Normalize();

		Vector3 acceleration = gravity + drag;
		if(burnedTime < BurnTime)
		{
			acceleration = acceleration + thrustVector;
			Mass = Mass - FuelMass * timeStep / BurnTime;
		}
		Velocity = Velocity + (acceleration * timeStep);
		Position = Position + (Velocity * timeStep);

		burnedTime += timeStep;
	}
	
	public SimObject Clone(string newName)
	{
		Rocket newRocket = new Rocket(newName);
		newRocket.CenterOfPressure = CenterOfPressure;
		newRocket.Thrust = Thrust;
		newRocket.BurnTime = BurnTime;
		newRocket.FuelMass = FuelMass;
		newRocket.Radius = Radius;
		mixin(CopySimObject!("this", "newRocket"));
		return newRocket;
	}

	public void ApplyImpulse(Vector3 impulse)
	{
		Velocity = Velocity + ((1.0 / Mass) * impulse);
	}

	private real burnedTime = 0;
	private @property real area() { return PI * Radius*Radius; }
}

public class Satellite : SimObject
{
	public real MaxThrust = 1.0;
	public real BurnTime = 0;
	public real Radius = 0.1;

	public this(string name)
	{
		super(name);
	}
	
	public void Update(real timeStep, EnvironmentService environment)
	{
		Vector3 gravity = (1.0 / Mass) * GravitationalForce(Position, Mass);
		Vector3 drag = (1.0 / Mass) * DragForce(Position, Velocity, area, 0.47, &environment.Density);
		Vector3 thrust = Vector3(0,0,0);
		
		if(BurnTime == 0 || burnedTime < BurnTime)
		{
			thrust = thrustVector(gravity, timeStep, environment);
			if(BurnTime != 0 && thrust != Vector3(0,0,0))
				burnedTime += timeStep;
		}
		
		Vector3 acceleration = gravity + drag + thrust;
		Velocity = Velocity + (acceleration * timeStep);
		Position = Position + (Velocity * timeStep);
	}
	
	public SimObject Clone(string newName)
	{
		Satellite newSatellite = new Satellite(newName);
		newSatellite.MaxThrust = MaxThrust;
		newSatellite.BurnTime = BurnTime;
		newSatellite.Radius = Radius;
		mixin(CopySimObject!("this", "newSatellite"));
		return newSatellite;
	}

	public void ApplyImpulse(Vector3 impulse)
	{
		Velocity = Velocity + ((1.0 / Mass) * impulse);
	}
	
	private Vector3 thrustVector(Vector3 gravity, real timeStep, EnvironmentService environment)
	{
		real idealVelocityMagnitude = sqrt(GRAVITATIONAL_CONSTANT * MASS_OF_EARTH / Position.Length());
		Vector3 idealVelocity = idealVelocityDirection() * idealVelocityMagnitude;
		
		if (Velocity.ComponentInDirection(idealVelocity) < idealVelocityMagnitude)
			return idealThrust(idealVelocity, gravity, timeStep, environment) * idealVelocity.Normalize();
		else
			return -idealThrust(idealVelocity, gravity, timeStep, environment) * (Velocity - Velocity.ProjectedOnto(idealVelocity)).Normalize();
	}
	
	private Vector3 idealVelocityDirection()
	{
		if (Position.Cross(Velocity).LengthSquared() != 0)
			return Position.Cross(Velocity.Cross(Position)).Normalize();
		else if (Position.Cross(Vector3(0,0,1)).LengthSquared() != 0)
			return Position.RotateBy(Quaternion.FromAxisAngle(Vector3(0,0,1),PI/2)).Normalize();
		else
			return Position.RotateBy(Quaternion.FromAxisAngle(Vector3(1,0,0),PI/2)).Normalize();
	}
	
	private real idealThrust(Vector3 idealVelocity, Vector3 gravity, real timeStep, EnvironmentService environment)
	{
		if ((idealVelocity - Velocity).Length() / idealVelocity.Length() < 0.02)
			return 0.0;
	
		return fmin(MaxThrust / Mass, gravity.Length() + (Velocity - idealVelocity).Length() / timeStep);
	}
	
	private real burnedTime = 0;
	private @property real area() { return PI * Radius*Radius; }
}

/*
public class Balloon// : SimObject
{
	public this(string name, real mass, real radius, Vector3 initialPosition = Vector3(0,0,0), Vector3 initialVelocity= Vector3(0,0,0))
	{
		super(name, mass,  initialPosition, initialVelocity);
		this.radius = radius;
	}
	
	public void Update(real timeStep)
	{
		Vector3 gravity = Vector3(0,-1,0).Scale(G * massEarth / pow(radiusEarth + Position.Y, 2));
		Vector3 buoyancy = gravity.Scale(-2 *Mass * densityAir(Position.Y) * volume / (Mass + densityAir(Position.Y) * volume)); 
		Vector3 drag = Velocity.Scale(-0.5 * area * dragConstant * densityAir(Position.Y) * Velocity.Length());

		Vector3 acceleration = gravity.Add(buoyancy).Add(drag);
		Velocity = Velocity.Add(acceleration.Scale(timeStep));
		Position = Position.Add(Velocity.Scale(timeStep));
	}
		
	private @property real volume() { return 4.0/3.0 * PI * pow(radius,3); }
	private @property real area() { return PI * pow(radius, 2); }
	private real dragConstant = 0.47;
	private real radius;
}

public class StubObject// : SimObject
{
	public this(string name, real mass, real acceleration, Vector3 initialPosition = Vector3(0,0,0), Vector3 initialVelocity= Vector3(0,0,0))
	{
		super(name, mass, initialPosition, initialVelocity);
		this.acceleration = acceleration;
	}
	
	public void Update(real timeStep)
	{
		Velocity.Y += acceleration * timeStep;
		Position.Y += timeStep * Velocity.Y;
	}
	
	private real acceleration;
}
*/

private const real G = 6.67e-11;
private const real massEarth = 5.97e24;
private const real radiusEarth = 6371e3;
private const real densityAirSTP = 1.21;

private real densityAir(real height)
{
	return densityAirSTP * exp(-height / 8e3);
}

static this()
{
	//std.stdio.writeln(8e3 * log(4*PI*densityAirSTP / 3));
	//assert(false);
}
