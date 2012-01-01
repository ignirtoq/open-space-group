module superAwesome.physics;

import superAwesome.geometry;
import std.stdio;

public class PhysicalState
{
	public Vector3 Position;
	public Vector3 Velocity;
	public Quaternion Orientation;
	public Vector3 AngularMomentum;
	
	public @property real Mass(){ return mass; }
	public @property real Mass(real value){ mass = value; inverseMass = 1.0/value; return mass; }
	private real mass;

	public @property Matrix3 MomentOfInertia(){ return momentOfInertia; }
	public @property Matrix3 MomentOfInertia(Matrix3 value){ momentOfInertia = value; inverseMomentOfInertia = value.Inverse(); return momentOfInertia; }
	private Matrix3 momentOfInertia;

	//Secondaries
	public @property real InverseMass(){ return inverseMass; }
	private real inverseMass;

	public @property Matrix3 InverseMomentOfInertia(){ return inverseMomentOfInertia; }
	private Matrix3 inverseMomentOfInertia;

	public void Update(real timeStep, Vector3 delegate(PhysicalState) force, Vector3 delegate(PhysicalState) torque)
	{
		EulerUpdate(this, timeStep, force, torque);
	} 
}

public void EulerUpdate(PhysicalState state, real timeStep, Vector3 delegate(PhysicalState) force, Vector3 delegate(PhysicalState) torque)
{
	state.Position = state.Position + state.Velocity * timeStep;
	state.Velocity = state.Velocity + state.InverseMass * force(state) * timeStep;

	Vector3 angularVelocity = state.InverseMomentOfInertia.MultiplyVector(state.AngularMomentum);
	state.Orientation = Quaternion.FromAxisAngle(angularVelocity.Normalize(), angularVelocity.Length() * timeStep) * state.Orientation;
	state.AngularMomentum = state.AngularMomentum + torque(state) * timeStep;
}
