extends Node3D

## Look around rotation speed.
@export var look_speed : float = 0.002

@onready var camera: Camera3D = $Camera3D

var mouse_captured: bool = false
var can_click: bool = true
var look_rotation : Vector2

func _unhandled_input(event: InputEvent) -> void:
	if (
		mouse_captured
		and can_click
		and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	):
		can_click = false
		handle_click()
	# Mouse capturing
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		capture_mouse()
	if Input.is_key_pressed(KEY_ESCAPE):
		release_mouse()
	# Look around
	if mouse_captured and event is InputEventMouseMotion:
		rotate_look(event.relative)

func capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

## When the user moves the mouse, we should rotate the camera in a sphere, such
## that it is always pointing at the center of the ground plane.
func rotate_look(rot_input : Vector2):
	if not can_click:
		return
	look_rotation.x -= rot_input.y * look_speed
	look_rotation.x = clamp(look_rotation.x, deg_to_rad(-85), deg_to_rad(85))
	look_rotation.y -= rot_input.x * look_speed
	# Resetting the basis resets the rotation and scale.
	transform.basis = Basis()
	# Note: The order of axis rotation matters, refer to
	# Node3D -> Transform -> Rotation Order.
	rotate_x(look_rotation.x)
	rotate_y(look_rotation.y)
	# Should not rotate on the Z axis.
	rotation.z = 0

## Performs a raycast from the floating shape position (plus an offset) and in
## the opposite direction that the camera is looking. The intent is to return
## the point on the ground plane that intersects it.
func raycast_to_ground_plane(
	floating_shape_position: Vector3, position_offset: Vector3
) -> Variant:
	var start_pos = floating_shape_position + position_offset
	var direction = (start_pos - camera.global_position).normalized()
	var query = PhysicsRayQueryParameters3D.create(
		start_pos,
		start_pos + direction * 20.0,
	)
	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(query)
	if not result:
		return null
	return result.position

func handle_click() -> void:
	var floating_shape = get_parent().get_node("FloatingShape")
	var p1 = raycast_to_ground_plane(floating_shape.position, Vector3(0, 0, 0))
	var p2 = raycast_to_ground_plane(floating_shape.position, Vector3(1, 0, 0))
	if p1 and p2:
		print("Hit!")
		var new_scale = abs(p2.x - p1.x)
		floating_shape.position = p1
		floating_shape.scale = Vector3(new_scale, new_scale, new_scale)
		
		# Apply impulse to move the soccer ball towards the grounded
		# floating shape.
		var soccer_ball = get_parent().get_node("SoccerBall")
		soccer_ball.apply_central_impulse(
			(floating_shape.position + Vector3(0.5, 0, 0.5))
			- soccer_ball.position
		)
		
		# Start timer for resetting the floating shape.
		get_parent().get_node("ResetFloatingShape").start()

## A couple of seconds after clicking:
##	-	The floating shape should leave the ground and start floating again.
##	-	The soccer ball should stop moving.
##	-	The user should be allowed to move the camera and click again.
func _on_reset_floating_shape_timeout() -> void:
	# Reset floating shape position
	var floating_shape = get_parent().get_node("FloatingShape")
	floating_shape.position = Vector3(0, 1.794, 0.469)
	floating_shape.scale = Vector3(1, 1, 1)
	# Stop soccer ball from moving
	var soccer_ball = get_parent().get_node("SoccerBall")
	soccer_ball.sleeping = true
	# Allow user to move the mouse and click again
	can_click = true
