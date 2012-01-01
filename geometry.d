module superAwesome.geometry;

import std.string;
import std.math;

public struct Vector3
{
	public real X,Y,Z;

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
	
	public static Vector3 AxisAngleFromQuaternion(Quaternion q)
	{
		return 2 * acos(q.Scalar) / sqrt(1 - q.Scalar * q.Scalar) * q.Vector;
	}
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
		if(angle == 0)
			return Quaternion(1,Vector3(0,0,0));

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

public struct Matrix3
{
	real[3][3] Components;
	
	public real Determinant()
	{
		return (Components[0][0] * Components[1][1] * Components[2][2] + Components[0][1] * Components[1][2] * Components[2][0] + Components[0][2] * Components[1][0] * Components[2][1]) - (Components[0][2] * Components[1][1] * Components[2][0] + Components[1][2] * Components[2][1] * Components[0][0] + Components[2][2] * Components[0][1] * Components[1][0]);
	}
	
	public real Trace()
	{
		return Components[0][0] + Components[1][1] + Components[2][2];
	}
	
	public Matrix3 Inverse()
	{
		if(Determinant() != 0)
		{
			real[3][3] inverse;
			real inverseDeterminant = 1.0 / Determinant();
			
			inverse[0][0] = inverseDeterminant * (Components[1][1] * Components[2][2] - Components[1][2] * Components[2][1]);
			inverse[0][1] = inverseDeterminant * (Components[0][2] * Components[2][1] - Components[0][1] * Components[2][2]);
			inverse[0][2] = inverseDeterminant * (Components[0][1] * Components[1][2] - Components[0][2] * Components[1][1]);
			
			inverse[1][0] = inverseDeterminant * (Components[1][2] * Components[2][0] - Components[1][0] * Components[2][2]);
			inverse [1][1] = inverseDeterminant * (Components[0][0] * Components[2][2] - Components[0][2] * Components[2][0]);
			inverse [1][2] = inverseDeterminant * (Components[0][2] * Components[1][0] - Components[0][0] * Components[1][2]);
			
			inverse[2][0] = inverseDeterminant * (Components[1][0] * Components[2][1] - Components[1][1] * Components[2][0]);
			inverse[2][1] = inverseDeterminant * (Components[0][1] * Components[2][0] - Components[0][0] * Components[2][1]);
			inverse[2][2] = inverseDeterminant * (Components[0][0] * Components[1][1] - Components[0][1] * Components[1][0]);
			
			return Matrix3(inverse);
		}
		else
			assert(false,"Matrix is singular.");
	}
	
	public Vector3 MultiplyVector(Vector3 vector)
	{
		return Vector3(Components[0][0] * vector.X + Components[0][1] * vector.Y + Components[0][2] * vector.Z, Components[1][0] * vector.X + Components[1][1] * vector.Y + Components[1][2] * vector.Z, Components[2][0] * vector.X + Components[2][1] * vector.Y + Components[2][2] * vector.Z);
	}
	
	public Matrix3 MultiplyMatrix(Matrix3 other)
	{
		real[3][3] newMatrix;
		
		for(int i = 0; i < 3; i++)
		{
			for(int j = 0; j < 3; j++)
			{
				newMatrix[i][j] = 0.0;
				for(int n = 0; n < 3; n++)
					newMatrix[i][j] = this.Components[i][n] * other.Components[n][j];
			}
		}
		
		return Matrix3(newMatrix);
	}
	
	public static Matrix3 FromQuaternion(Quaternion q)
	{
		real[3][3] newMatrix;
		newMatrix[0][0] = q.Scalar*q.Scalar + q.Vector.X*q.Vector.X - q.Vector.Y*q.Vector.Y - q.Vector.Z*q.Vector.Z;
		newMatrix[1][1] = q.Scalar*q.Scalar - q.Vector.X*q.Vector.X + q.Vector.Y*q.Vector.Y - q.Vector.Z*q.Vector.Z;
		newMatrix[2][2] = q.Scalar*q.Scalar - q.Vector.X*q.Vector.X - q.Vector.Y*q.Vector.Y + q.Vector.Z*q.Vector.Z;
		
		newMatrix[0][1] = 2*q.Vector.X*q.Vector.Y - 2*q.Scalar*q.Vector.Z;
		newMatrix[1][0] = 2*q.Vector.X*q.Vector.Y + 2*q.Scalar*q.Vector.Z;
		
		newMatrix[0][2] = 2*q.Vector.X*q.Vector.Z + 2*q.Scalar*q.Vector.Y;
		newMatrix[2][0] = 2*q.Vector.X*q.Vector.Z - 2*q.Scalar*q.Vector.Y;
		
		newMatrix[1][2] = 2*q.Vector.Y*q.Vector.Z - 2*q.Scalar*q.Vector.X;
		newMatrix[2][1] = 2*q.Vector.Y*q.Vector.Z + 2*q.Scalar*q.Vector.X;
		
		return Matrix3(newMatrix);
	}
	
	public static Quaternion ToQuaternion(Matrix3 matrix)
	{
		if(matrix.Components[0][0] + matrix.Components[1][1] + matrix.Components[2][2] > 0)
		{
			real radical = 2 * sqrt(1 + matrix.Components[0][0] + matrix.Components[1][1] + matrix.Components[2][2]);
			real scalar = 0.25 * radical;
			real X = (matrix.Components[2][1] - matrix.Components[1][2]) / radical;
			real Y = (matrix.Components[0][2] - matrix.Components[2][0]) / radical;
			real Z = (matrix.Components[1][0] - matrix.Components[0][1]) / radical;
			
			return Quaternion(scalar, Vector3(X,Y,Z));
		}
		else
			assert(false);
	}
}