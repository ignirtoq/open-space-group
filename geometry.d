module superAwesome.geometry;

import std.string;
import std.math;

public struct Vector3
{
	public string toString()
	{
		return format("(%f, %f, %f)", X, Y, Z);
	}
	
	public real LengthSquared()
	{
		return X*X + Y*Y + Z*Z;
	}
	
	public real Length()
	{
		return sqrt(LengthSquared());
	}
	
	public Vector3 opBinary(string op)(Vector3 other)
	{
		static if(op == "+")
			return Vector3(X+other.X, Y+other.Y, Z+other.Z);
		else static if(op == "-")
			return Vector3(X-other.X, Y-other.Y, Z-other.Z);
		else static if(op == "*")
			return Vector3(X*other.X, Y*other.Y, Z*other.Z);
		else
			static assert(false);
	}
	
	public real Dot(Vector3 other)
	{
		return X*other.X + Y*other.Y + Z*other.Z;
	}
	
	public Vector3 opBinary(string op)(real scalar)
	{
		static if(op == "*")
			return Vector3(scalar*X, scalar*Y, scalar*Z);
		else
			static assert(false);
	}
	
	public Vector3 opBinaryRight(string op)(real scalar)
	{
		static if(op == "*")
			return Vector3(scalar*X, scalar*Y, scalar*Z);
		else
			static assert(false);
	}

	public Vector3 Normalize()
	{
		real length = Length();
		return Vector3(X/length, Y/length, Z/length);
	}
	
	public Vector3 Cross(Vector3 other)
	{
		return Vector3
		(
			Y*other.Z - other.Y*Z,
			Z*other.X - other.Z*X,
			X*other.Y - other.X*Y
		);
	}
	
	public Vector3 ProjectedOnto(Vector3 other)
	{
		if (other.LengthSquared() == 0.0)
			return Vector3(0,0,0);
		
		return (1.0/other.LengthSquared()) * this.Dot(other) * other;
	}
	
	public real ComponentInDirection(Vector3 other)
	{
		if (other.LengthSquared() == 0.0)
			return 0.0;
			
		return this.Dot(other.Normalize());
	}
	
	public Vector3 RotateBy(Quaternion rotation)
	{
		if (rotation.Scalar == 0)
			return this;
		
		return (rotation*Quaternion(0,this)*rotation.Conjugate()).Vector;
	}
	
	public real X,Y,Z;
}

public struct Quaternion
{
	public real Scalar;
	public Vector3 Vector;
	
	public string toString()
	{
		return format("(%f, %f, %f, %f)", Scalar, Vector.X, Vector.Y, Vector.Z);
	}
	
	public real ModulusSquared()
	{
		return Scalar*Scalar + Vector.LengthSquared();
	}
	
	public real Modulus()
	{
		return sqrt(ModulusSquared());
	}
	
	public static Quaternion FromAxisAngle(Vector3 axis, real angle)
	{
		return Quaternion(cos(angle/2),sin(angle/2)*axis);
	}
	
	public Quaternion opBinary(string op)(Quaternion other)
	{
		static if(op == "+")
			return Quaternion(Scalar+other.Scalar, Vector+other.Vector);
		else static if(op == "-")
			return Quaternion(Scalar-other.Scalar, Vector-other.Vector);
		else static if(op == "*")
			return Quaternion(Scalar*other.Scalar - Vector.Dot(other.Vector), Scalar*other.Vector + Vector*other.Scalar + Vector.Cross(other.Vector));
		else
			static assert(false);
	}
	
	public Quaternion opBinary(string op)(real multiplier)
	{
		static if(op == "*")
			return Quaternion(multiplier*Scalar, multiplier*Vector);
		else
			static assert(false);
	}
	
	public Quaternion opBinaryRight(string op)(real multiplier)
	{
		static if(op == "*")
			return Quaternion(multiplier*Scalar, multiplier*Vector);
		else
			static assert(false);
	}

	public Quaternion Conjugate()
	{
		return Quaternion(Scalar, (-1.0) * Vector);
	}
}
