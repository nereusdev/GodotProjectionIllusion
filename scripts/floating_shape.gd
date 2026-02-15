extends StaticBody3D

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

func _ready():
	var verts = [
		# Bottom face
		Vector3(0, 0, 0),
		Vector3(0, 0, 1),
		Vector3(1, 0, 0),
		# Top face
		Vector3(0, 1, 0),
		Vector3(1, 1, 0),
		Vector3(0, 1, 1),
		# X face
		Vector3(1, 0, 0),
		Vector3(1, 1, 0),
		Vector3(0, 1, 0),
		Vector3(0, 0, 0),
		Vector3(1, 0, 0),
		Vector3(0, 1, 0),
		# Z face
		Vector3(0, 0, 0),
		Vector3(0, 1, 0),
		Vector3(0, 0, 1),
		Vector3(0, 0, 1),
		Vector3(0, 1, 0),
		Vector3(0, 1, 1),
		# X-Z face
		Vector3(1, 1, 0),
		Vector3(1, 0, 0),
		Vector3(0, 1, 1),
		Vector3(0, 1, 1),
		Vector3(1, 0, 0),
		Vector3(0, 0, 1)
	]
	
	var tris = [
		# Bottom face
		0, 1, 2,
		# Top face
		3, 4, 5,
		# X face
		6, 7, 8,
		9, 10, 11,
		## Z face
		12, 13, 14,
		15, 16, 17,
		# X-Z face
		18, 19, 20,
		21, 22, 23
	]
	
	var normals = [
		# Bottom face
		Vector3(0, -1, 0),
		Vector3(0, -1, 0),
		Vector3(0, -1, 0),
		# Top face
		Vector3(0, 1, 0),
		Vector3(0, 1, 0),
		Vector3(0, 1, 0),
		# X face
		Vector3(0, 0, -1),
		Vector3(0, 0, -1),
		Vector3(0, 0, -1),
		Vector3(0, 0, -1),
		Vector3(0, 0, -1),
		Vector3(0, 0, -1),
		# Z face
		Vector3(-1, 0, 0),
		Vector3(-1, 0, 0),
		Vector3(-1, 0, 0),
		Vector3(-1, 0, 0),
		Vector3(-1, 0, 0),
		Vector3(-1, 0, 0),
		# X-Z face
		Vector3(1, 0, 1).normalized(),
		Vector3(1, 0, 1).normalized(),
		Vector3(1, 0, 1).normalized(),
		Vector3(1, 0, 1).normalized(),
		Vector3(1, 0, 1).normalized(),
		Vector3(1, 0, 1).normalized(),
	]
	
	var mesh = build_mesh_fast(verts, tris, normals)
	mesh_instance.mesh = mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color.RED
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	mesh_instance.set_surface_override_material(0, mat)
	
	# --- Create collider ---
	var shape = ConvexPolygonShape3D.new()
	shape.points = PackedVector3Array(verts)
	collision_shape.shape = shape

func build_mesh_fast(vertices: PackedVector3Array, indices: PackedInt32Array, normals: PackedVector3Array) -> ArrayMesh:
	var mesh = ArrayMesh.new()

	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)

	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices
	arrays[Mesh.ARRAY_NORMAL] = normals

	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh
