module superAwesome.parsing.primitives;

import superAwesome.geometry;
import std.xml;
import std.conv;

public Vector3 ParseVector3(in Element e)
{
	Vector3 vector;
	vector.X = to!(real)(e.tag.attr["x"]);
	vector.Y = to!(real)(e.tag.attr["y"]);
	vector.Z = to!(real)(e.tag.attr["z"]);
	return vector;
}

public Quaternion ParseQuaternion(in Element e)
{
	Quaternion quaternion;
	quaternion.Scalar = to!(real)(e.tag.attr["real"]);
	quaternion.Vector.X = to!(real)(e.tag.attr["i"]);
	quaternion.Vector.Y = to!(real)(e.tag.attr["j"]);
	quaternion.Vector.Z = to!(real)(e.tag.attr["k"]);
	return quaternion;
}

public real ParseReal(in Element e)
{
	return to!(real)(e.text);
}

public bool ParseBool(in Element e)
{
	return to!(bool)(e.text);
}
