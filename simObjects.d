module superAwesome.simObjects;

import superAwesome.physics;
import superAwesome.environments;
import superAwesome.geometry;
import superAwesome.constants;
import superAwesome.commonMath;
import std.math;
import std.stdio;

template CopySimObject(string from, string to)
{
	const string CopySimObject = "
	" ~ to ~ ".State.Position = " ~ from ~ ".State.Position;
	" ~ to ~ ".State.Velocity = " ~ from ~ ".State.Velocity;
	" ~ to ~ ".State.Orientation = " ~ from ~ ".State.Orientation;
	" ~ to ~ ".State.AngularMomentum = " ~ from ~ ".State.AngularMomentum;
	" ~ to ~ ".State.Mass = " ~ from ~ ".State.Mass;
	" ~ to ~ ".State.MomentOfInertia = " ~ from ~ ".State.MomentOfInertia;
	" ~ to ~ ".State.CalculateSecondaries();
	";
}

public abstract class SimObject
{
	public PhysicalState State;

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
		Vector3 force(PhysicalState state)
		{
			return GravitationalForce(state.Position, state.Mass)
				+ DragForce(state.Position, state.Velocity, area, dragConstant, &environment.Density)
				+ BuoyantForce(state.Position, state.Mass, volume, &environment.Density);
		}
		
		Vector3 torque(PhysicalState state)
		{
			return Vector3(0,0,0);
		}

		State.Update(timeStep, &force, &torque);
	}

	public SimObject Clone(string newName)
	{
		Balloon newBalloon = new Balloon(newName);
		mixin(CopySimObject!("this", "newBalloon"));
		return newBalloon;
	}

	public void ApplyImpulse(Vector3 impulse)
	{
		State.Velocity = State.Velocity + ((1.0 / State.Mass) * impulse);
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
		Vector3 force(PhysicalState state)
		{
			Vector3 f = GravitationalForce(state.Position, state.Mass)
				+ DragForce(state.Position, state.Velocity, area, 0.5, &environment.Density).ProjectedOnto(CenterOfPressure.RotateBy(state.Orientation));
			if(burnedTime < BurnTime)
				f = f + -Thrust * CenterOfPressure.RotateBy(state.Orientation).Normalize();
			return f;
		}
		
		Vector3 torque(PhysicalState state)
		{
			Vector3 drag = DragForce(state.Position, state.Velocity, area, 0.5, &environment.Density);
			Vector3 dragParallel = drag.ProjectedOnto(CenterOfPressure.RotateBy(state.Orientation));
			Vector3 dragOrthogonal = drag-dragParallel;
			return CenterOfPressure.RotateBy(state.Orientation).Cross(dragOrthogonal);
		}

		State.Update(timeStep, &force, &torque);

		if(burnedTime < BurnTime)
			State.Mass = State.Mass - FuelMass * timeStep / BurnTime;
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
		State.Velocity = State.Velocity + ((1.0 / State.Mass) * impulse);
	}

	private real burnedTime = 0;
	private @property real area() { return PI * Radius*Radius; }
}

public class Satellite : SimObject
{
	public real Radius = 0.1;

	public this(string name)
	{
		super(name);
	}
	
	public void Update(real timeStep, EnvironmentService environment)
	{
		Vector3 force(PhysicalState state)
		{
			return GravitationalForce(state.Position, state.Mass)
				+ DragForce(state.Position, state.Velocity, area, 0.47, &environment.Density);
		}

		Vector3 torque(PhysicalState state)
		{
			return Vector3(0,0,0);
		}
			
		State.Update(timeStep, &force, &torque);
	}
	
	public SimObject Clone(string newName)
	{
		Satellite newSatellite = new Satellite(newName);
		newSatellite.Radius = Radius;
		mixin(CopySimObject!("this", "newSatellite"));
		return newSatellite;
	}

	public void ApplyImpulse(Vector3 impulse)
	{
		State.Velocity = State.Velocity + ((1.0 / State.Mass) * impulse);
	}
	
	private @property real area() { return PI * Radius*Radius; }
}

public class TestRotationalObject : SimObject
{
	public this(string name)
	{
		super(name);
	}

	public void Update(real timeStep, EnvironmentService environment)
	{
		Vector3 force(PhysicalState state)
		{
			return Vector3(0,0,0);
		}
	
		Vector3 torque(PhysicalState state)
		{
			return Vector3(0,0,0.00001);
		}

		State.Update(timeStep, &force, &torque);
	}
	
	private Vector3 applyVelocity(Vector3 position, Vector3 velocity, real timeStep)
	{
		return position + (velocity * timeStep);
	}
	
	private Vector3 applyAcceleration(Vector3 velocity, Vector3 acceleration, real timeStep)
	{
		return velocity + (acceleration * timeStep);
	}
	
	private Quaternion applyAngularVelocity(Quaternion orientation, Vector3 angularVelocity, real timeStep)
	{
		return Quaternion.FromAxisAngle(angularVelocity.Normalize(), angularVelocity.Length() * timeStep) * orientation;
	}
	
	private Vector3 applyTorque(Vector3 angularMomentum, Vector3 torque, real timeStep)
	{
		return angularMomentum + (torque * timeStep);
	}

	public SimObject Clone(string newName)
	{
		TestRotationalObject newRotObject = new TestRotationalObject(newName);
		mixin(CopySimObject!("this", "newRotObject"));
		return newRotObject;
	}

	public void ApplyImpulse(Vector3 impulse)
	{
		State.Velocity = State.Velocity + ((1.0 / State.Mass) * impulse);
	}
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
