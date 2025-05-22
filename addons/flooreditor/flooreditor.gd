@tool
extends EditorPlugin

var editorUI

var sphere_instance : MeshInstance3D
var snap_increment : float = 0.5

var vectors = []

func _enter_tree() -> void:
	set_input_event_forwarding_always_enabled()
	
	add_custom_type("FloorEditorUI","Button",preload("res://addons/flooreditor/flooreditor_button.gd"),preload("res://icon.svg"))
	# Initialization of the plugin goes here.
	editorUI = preload("res://addons/flooreditor/FloorEditorUI.tscn").instantiate()
		
	add_control_to_dock(DOCK_SLOT_LEFT_UR,editorUI)

func _exit_tree() -> void:
	if sphere_instance and sphere_instance.is_inside_tree():
		sphere_instance.queue_free()
	remove_custom_type("FloorEditorUI")
	# Clean-up of the plugin goes here.
	remove_control_from_docks(editorUI)
	editorUI.free()
	
func _handles(object: Object) -> bool:
	# Return true if your plugin should be active for the current object
	return true

func _forward_3d_gui_input(viewport_camera: Camera3D, event: InputEvent) -> int:

	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		print("click")
		return 0
	
	if event is InputEventMouseMotion:
		_update_sphere_position(viewport_camera, event.position)
		
	return 0

func _update_sphere_position(camera: Camera3D, mouse_pos: Vector2):
	var from := camera.project_ray_origin(mouse_pos)
	var dir := camera.project_ray_normal(mouse_pos)
	var to := from + dir * 1000.0

	var plane := Plane(Vector3.UP, 0.0)
	var intersection := plane.intersects_ray(from, dir)
	
	if intersection == null:
		return

	if sphere_instance == null:
		_spawn_sphere()
		# Wait for it to enter the tree before setting position
		await sphere_instance.ready
		sphere_instance.global_position = intersection
		
	elif sphere_instance.is_inside_tree():
		sphere_instance.global_position = intersection.snappedf(snap_increment)
		
func _spawn_sphere():
	sphere_instance = MeshInstance3D.new()
	var sphere_mesh := SphereMesh.new()
	sphere_mesh.radius = 0.1
	sphere_mesh.height = 0.2
	sphere_instance.mesh = sphere_mesh
	sphere_instance.name = "MouseFollowerSphere"
	sphere_instance.visible = true

	# Add to the current edited scene
	var scene_root := get_editor_interface().get_edited_scene_root()
	print(scene_root)
	if scene_root:
		scene_root.add_child(sphere_instance)
		sphere_instance.owner = scene_root  # So it saves in the scene

# Function to draw a line between two points
"""
func draw_line(start: Vector3, end: Vector3):
	line_node.clear()  # Clear any previous geometry
	line_node.begin(Mesh.PRIMITIVE_LINES, null)  # Begin drawing a line
	line_node.add_vertex(start)  # Add the starting point
	line_node.add_vertex(end)    # Add the ending point
	line_node.end()  # End drawing
"""
func _set_editor_camera_orthographic():
	var editor_viewport := get_editor_interface().get_editor_viewport_3d()
	var camera := editor_viewport.find_child("EditorCamera3D", true, false)
	if camera and camera is Camera3D:
		var transform = Transform3D()
		transform.origin = Vector3(0,0,0)
		transform.basis = Basis.looking_at(Vector3(0,0,0),Vector3.UP)
		camera.transform = transform
		camera.projection = Camera3D.PROJECTION_ORTHOGONAL
		camera.size = 10.0  # Optional: adjust orthographic size
		print("Switched editor camera to orthographic")
	else:
		print("Editor camera not found")
