using Godot;
using System;
using System.Diagnostics;

public struct vectorPlan((Vector2, Vector2, int)[] vectors, int floor_number)
{
	public (Vector2, Vector2, int)[] data = vectors;
	public int floor_number = floor_number;
}

public partial class Floorplanner : Node
{
	///Testing stuff///
	/// 
	vectorPlan testFloor = new vectorPlan([(new Vector2(0, 0), new Vector2(1, 1), 0)], 0);

	[Export]
	public Mesh wallMesh;

	bool called = false;
	public override void _Ready()
	{

	}
    public override void _Process(double delta)
    {
		if (!called)
		{
			GenerateFloor(testFloor, new Vector3(0, 0, 0), this.GetParent<Node3D>());
			called=true;
		}
    }

	///
	/// 

	public void GenerateFloor(vectorPlan floorPlan, Vector3 origin, Node3D building)
	{
		foreach ((Vector2, Vector2, int) vector in floorPlan.data)
		{
			Vector3 startPoint = building.Position + new Vector3(vector.Item1.X, 0, vector.Item1.Y);
			Vector3 endPoint = building.Position + new Vector3(vector.Item2.X, 0, vector.Item2.Y);
			int lineType = vector.Item3;
			float distance = startPoint.DistanceTo(endPoint);

			//Walls
			if (lineType == 0)
			{
				MeshInstance3D wall = new MeshInstance3D();
				building.AddChild(wall);
				wall.Mesh = wallMesh;
				wall.Scale = new Vector3(distance, wall.Scale.Y, wall.Scale.Z);
				wall.Position = (endPoint - startPoint) / 2;
				wall.Rotation = new Vector3(0, Vector3.Right.AngleTo(endPoint - startPoint), 0);
			}
		}
	}
}
