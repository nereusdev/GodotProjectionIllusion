extends Node3D

## Look around rotation speed.
@export var look_speed : float = 0.002

## Name of Input Action to move Left.
@export var input_left : String = "ui_left"
## Name of Input Action to move Right.
@export var input_right : String = "ui_right"
## Name of Input Action to move Forward.
@export var input_forward : String = "ui_up"
## Name of Input Action to move Backward.
@export var input_back : String = "ui_down"

@onready var camera: Camera3D = $Camera3D

var mouse_captured: bool = false
var can_click: bool = true
var look_rotation : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _unhandled_input(event: InputEvent) -> void:
	if mouse_captured and can_click and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
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

## Rotate us to look around.
## Base of controller rotates around y (left/right). Head rotates around x (up/down).
## Modifies look_rotation based on rot_input, then resets basis and rotates by look_rotation.
func rotate_look(rot_input : Vector2):
	if not can_click:
		return
	
	look_rotation.x -= rot_input.y * look_speed
	look_rotation.x = clamp(look_rotation.x, deg_to_rad(-85), deg_to_rad(85))
	look_rotation.y -= rot_input.x * look_speed
	transform.basis = Basis()
	rotate_x(look_rotation.x)
	rotate_y(look_rotation.y)
	rotation.z = 0

func handle_click() -> void:
	var floating_shape = get_parent().get_node("FloatingShape")
	var direction = (floating_shape.position - camera.global_position).normalized()
	var query = PhysicsRayQueryParameters3D.create(
		floating_shape.position,
		floating_shape.position + direction * 20.0,
	)
	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(query)
	if result:
		print("Hit:", result.collider, result.position)
		
		var p1 = result.position
		
		var start_pos = floating_shape.position + Vector3(1, 0, 0)
		direction = (start_pos - camera.global_position).normalized()
		query = PhysicsRayQueryParameters3D.create(
			start_pos,
			start_pos + direction * 20.0,
		)
		space_state = get_world_3d().direct_space_state
		result = space_state.intersect_ray(query)
		if result:
			print("Another hit: ", result.collider, result.position)
			var p2 = result.position
			var new_scale = abs(p2.x - p1.x)
			floating_shape.position = p1
			floating_shape.scale = Vector3(new_scale, new_scale, new_scale)
			
			# Apply impulse to move the soccer ball towards the grounded
			# floating shape.
			var soccer_ball = get_parent().get_node("SoccerBall")
			soccer_ball.apply_central_impulse((floating_shape.position + Vector3(0.5, 0, 0.5)) - soccer_ball.position)
			get_parent().get_node("ResetFloatingShape").start()
	else:
		print("No hit")
	pass


func _on_reset_floating_shape_timeout() -> void:
	var floating_shape = get_parent().get_node("FloatingShape")
	floating_shape.position = Vector3(0, 1.794, 0.469)
	floating_shape.scale = Vector3(1, 1, 1)
	var soccer_ball = get_parent().get_node("SoccerBall")
	soccer_ball.sleeping = true
	can_click = true
