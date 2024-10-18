extends VehicleBody3D

@export var max_engine_force = 300.0
@export var max_brake_force = 10.0
@export var max_steer_angle = 0.5

@export var steering_control = "steering"
@export var throttle_control = "throttle"
@export var brake_control = "brake"

@export var collision_push_force = 50.0

@onready var left_taillight = $Taillights/LeftTaillight
@onready var right_taillight = $Taillights/RightTaillight
@onready var left_brake_light = $LeftBrakeLight
@onready var right_brake_light = $RightBrakeLight

var last_collision_force = Vector3.ZERO
var score = 0
var brake_light_material: StandardMaterial3D

func _ready():
	add_to_group("players")
	brake_light_material = left_taillight.get_surface_override_material(0).duplicate()
	left_taillight.set_surface_override_material(0, brake_light_material)
	right_taillight.set_surface_override_material(0, brake_light_material)
	set_brake_lights(false)

func _physics_process(delta):
	var throttle = Input.get_action_strength(throttle_control)
	var brake_strength = Input.get_action_strength(brake_control)
	var steer_left = Input.get_action_strength("left_" + steering_control)
	var steer_right = Input.get_action_strength("right_" + steering_control)

	engine_force = throttle * max_engine_force
	brake = brake_strength * max_brake_force
	steering = (steer_left - steer_right) * max_steer_angle

	set_brake_lights(brake_strength > 0)

func _integrate_forces(state):
	if last_collision_force != Vector3.ZERO:
		apply_central_impulse(last_collision_force)
		last_collision_force = Vector3.ZERO

func _on_body_entered(body):
	if body is VehicleBody3D and body != self:
		var collision_force = global_transform.origin - body.global_transform.origin
		collision_force = collision_force.normalized() * collision_push_force
		last_collision_force = collision_force

func collect_piece():
	score += 1
	print(name + " a collecté une pièce! Score: " + str(score))

func set_brake_lights(on: bool):
	if brake_light_material:
		if on:
			brake_light_material.emission_energy_multiplier = 5.0
		else:
			brake_light_material.emission_energy_multiplier = 0.1

	left_brake_light.visible = on
	right_brake_light.visible = on
