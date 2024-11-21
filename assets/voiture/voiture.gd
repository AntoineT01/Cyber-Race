extends VehicleBody3D

# Définition des signaux
@warning_ignore("unused_signal")
signal respawn_timer_started(player_id: int, time_left: float)
@warning_ignore("unused_signal")
signal respawn_timer_updated(player_id: int, time_left: float)
@warning_ignore("unused_signal")
signal respawn_timer_finished(player_id: int)
@warning_ignore("unused_signal")
signal respawn_timer_cancelled(player_id: int)

# Paramètres du joueur et des contrôles
@export var player_id: int = 1
@export var max_engine_force = 300.0
@export var max_brake_force = 20.0
@export var max_steer_angle = 0.5

@export var steering_control = "steering"
@export var throttle_control = "throttle"
@export var brake_control = "brake"
@export var reverse_control = "reverse"

@export var collision_push_force = 50.0

# Paramètres de respawn
@export var respawn_position: Vector3 = Vector3(0, 5, 0)
@export var respawn_rotation: Vector3 = Vector3.ZERO
@export var fall_threshold: float = -5.0
@export var respawn_if_upside_down_time: float = 3.0

# Paramètres des roues et de la suspension
@export var wheel_radius: float = 0.45
@export var suspension_travel: float = 0.3
@export var suspension_stiffness: float = 80.0
@export var wheel_friction_slip: float = 8.0

# Références aux nodes
@onready var left_taillight = $Taillights/LeftTaillight
@onready var right_taillight = $Taillights/RightTaillight
@onready var left_brake_light = $LeftBrakeLight
@onready var right_brake_light = $RightBrakeLight

# Variables internes
var last_collision_force = Vector3.ZERO
var score = 0
var brake_light_material: StandardMaterial3D
var upside_down_timer: float = 0.0
var is_respawn_timer_active: bool = false

# Constantes
const MAX_LINEAR_VELOCITY = 5.0
const MAX_ANGULAR_VELOCITY = 1.0

func _ready():
	add_to_group("players")

	# Configuration de la physique
	physics_material_override = PhysicsMaterial.new()
	physics_material_override.bounce = 0.1
	gravity_scale = 2.0

	setup_wheels()
	setup_lights()

func setup_lights():
	brake_light_material = left_taillight.get_surface_override_material(0).duplicate()
	left_taillight.set_surface_override_material(0, brake_light_material)
	right_taillight.set_surface_override_material(0, brake_light_material)
	set_brake_lights(false)

func setup_wheels():
	var wheels = [$FrontLeftWheel, $FrontRightWheel, $RearLeftWheel, $RearRightWheel]

	for wheel in wheels:
		wheel.wheel_radius = wheel_radius
		wheel.suspension_travel = suspension_travel
		wheel.suspension_stiffness = suspension_stiffness
		wheel.wheel_friction_slip = wheel_friction_slip
		wheel.suspension_max_force = 8000

func _physics_process(delta):
	handle_vehicle_input()
	check_fall_condition()
	handle_upside_down_check(delta)
	handle_manual_respawn()

func handle_vehicle_input():
	var throttle = Input.get_action_strength(throttle_control)
	var reverse = Input.get_action_strength(reverse_control)
	var brake_strength = Input.get_action_strength(brake_control)
	var steer_left = Input.get_action_strength("left_" + steering_control)
	var steer_right = Input.get_action_strength("right_" + steering_control)

	engine_force = (throttle - reverse) * max_engine_force
	brake = brake_strength * max_brake_force
	steering = (steer_left - steer_right) * max_steer_angle

	set_brake_lights(brake_strength > 0 or reverse > 0)

func check_fall_condition():
	if global_transform.origin.y < fall_threshold:
		respawn()

func handle_upside_down_check(delta):
	var currently_upside_down = is_upside_down() and is_moving_little()

	if currently_upside_down:
		if not is_respawn_timer_active:
			start_respawn_timer()
		update_respawn_timer(delta)
	else:
		cancel_respawn_timer()

func start_respawn_timer():
	is_respawn_timer_active = true
	upside_down_timer = 0.0
	emit_signal("respawn_timer_started", player_id, respawn_if_upside_down_time)

func update_respawn_timer(delta):
	upside_down_timer += delta
	var time_left = respawn_if_upside_down_time - upside_down_timer

	if upside_down_timer >= respawn_if_upside_down_time:
		respawn()
		emit_signal("respawn_timer_finished", player_id)
		is_respawn_timer_active = false
	else:
		emit_signal("respawn_timer_updated", player_id, clamp(time_left, 0, respawn_if_upside_down_time))

func cancel_respawn_timer():
	if is_respawn_timer_active:
		is_respawn_timer_active = false
		emit_signal("respawn_timer_cancelled", player_id)
	upside_down_timer = 0.0

func handle_manual_respawn():
	var respawn_action = "respawn_player" + str(player_id) if player_id in [1, 2] else "respawn"

	if Input.is_action_just_pressed(respawn_action):
		print("Respawn manuelle pour le Joueur ", player_id)
		respawn()

func is_moving_little() -> bool:
	return linear_velocity.length() < MAX_LINEAR_VELOCITY and angular_velocity.length() < MAX_ANGULAR_VELOCITY

func _integrate_forces(_state):
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
		brake_light_material.emission_energy_multiplier = 5.0 if on else 0.1
	left_brake_light.visible = on
	right_brake_light.visible = on

func respawn():
	global_transform.origin = respawn_position
	global_transform.basis = Basis(Quaternion.from_euler(respawn_rotation))

	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO

	upside_down_timer = 0.0
	is_respawn_timer_active = false

	if ScoreManager.victory_type == ScoreManager.VictoryType.LAPS:
		var race_manager = get_node("/root/Race/RaceManager")
		if race_manager:
			race_manager.reset_car_counters(self)
			print("Réinitialisation des compteurs pour ", self.name)
		else:
			print("RaceManager non trouvé!")

	print(name + " a été respawné!")

func is_upside_down() -> bool:
	var up_vector = global_transform.basis.y
	return up_vector.y < 0.0
