module superAwesome.physics;

import superAwesome.geometry;

public class PhysicalState
{
	public Vector3 Position;
	public Vector3 Velocity;
	public Quaternion Orientation;
	public Vector3 AngularMomentum;
	public real Mass;
	public Matrix3 MomentOfInertia;

	//Secondaries
	public real InverseMass;
	public Matrix3 InverseMomentOfInertia;

	public void CalculateSecondaries()
	{
		InverseMass = 1.0/Mass;
		InverseMomentOfInertia = MomentOfInertia.Inverse();
	}

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
