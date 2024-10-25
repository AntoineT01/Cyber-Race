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

@export var player_id: int = 1  # Identifiant unique pour chaque joueur

@export var max_engine_force = 300.0
@export var max_brake_force = 10.0
@export var max_steer_angle = 0.5

@export var steering_control = "steering"
@export var throttle_control = "throttle"
@export var brake_control = "brake"
@export var reverse_control = "reverse"  # Nouveau contrôle pour la marche arrière

@export var collision_push_force = 50.0

@export var respawn_position: Vector3 = Vector3(0, 5, 0)  # Position de respawn par défaut
@export var respawn_rotation: Vector3 = Vector3.ZERO  # Rotation de respawn par défaut (angles d'Euler en radians)
@export var fall_threshold: float = -5.0  # Seuil de chute en Y

@export var respawn_if_upside_down_time: float = 3.0  # Temps en secondes avant respawn si à l'envers

@onready var left_taillight = $Taillights/LeftTaillight
@onready var right_taillight = $Taillights/RightTaillight
@onready var left_brake_light = $LeftBrakeLight
@onready var right_brake_light = $RightBrakeLight

var last_collision_force = Vector3.ZERO
var score = 0
var brake_light_material: StandardMaterial3D

# Variables pour gérer le respawn lorsqu'à l'envers
var upside_down_timer: float = 0.0
var is_respawn_timer_active: bool = false  # Variable pour suivre l'état du timer

# Définition des seuils de vitesse
const MAX_LINEAR_VELOCITY = 5.0  # Unités par seconde
const MAX_ANGULAR_VELOCITY = 1.0  # Radians par seconde

func _ready():
	add_to_group("players")
	brake_light_material = left_taillight.get_surface_override_material(0).duplicate()
	left_taillight.set_surface_override_material(0, brake_light_material)
	right_taillight.set_surface_override_material(0, brake_light_material)
	set_brake_lights(false)

func _physics_process(_delta):
	var throttle = Input.get_action_strength(throttle_control)
	var reverse = Input.get_action_strength(reverse_control)  # Nouvelle entrée pour la marche arrière
	var brake_strength = Input.get_action_strength(brake_control)
	var steer_left = Input.get_action_strength("left_" + steering_control)
	var steer_right = Input.get_action_strength("right_" + steering_control)

	# Calcul de la force du moteur en tenant compte de la marche avant et arrière
	engine_force = (throttle - reverse) * max_engine_force
	brake = brake_strength * max_brake_force
	steering = (steer_left - steer_right) * max_steer_angle

	# Activation des feux de freinage pour le freinage et la marche arrière
	set_brake_lights(brake_strength > 0 or reverse > 0)

	# Vérifier si la voiture est tombée
	if global_transform.origin.y < fall_threshold:
		respawn()

	# Vérifier si la voiture est à l'envers ET si elle ne bouge pas beaucoup
	var currently_upside_down = is_upside_down() and is_moving_little()
	if currently_upside_down:
		if not is_respawn_timer_active:
			is_respawn_timer_active = true
			upside_down_timer = 0.0
			emit_signal("respawn_timer_started", player_id, respawn_if_upside_down_time)
		upside_down_timer += _delta
		var time_left = respawn_if_upside_down_time - upside_down_timer
		if upside_down_timer >= respawn_if_upside_down_time:
			respawn()
			emit_signal("respawn_timer_finished", player_id)
			is_respawn_timer_active = false
		else:
			emit_signal("respawn_timer_updated", player_id, clamp(time_left, 0, respawn_if_upside_down_time))
	else:
		if is_respawn_timer_active:
			is_respawn_timer_active = false
			emit_signal("respawn_timer_cancelled", player_id)  # Émettre le signal lorsque le timer est annulé
		upside_down_timer = 0.0

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
		if on:
			brake_light_material.emission_energy_multiplier = 5.0
		else:
			brake_light_material.emission_energy_multiplier = 0.1

	left_brake_light.visible = on
	right_brake_light.visible = on

func respawn():
	# Réinitialiser la position
	global_transform.origin = respawn_position

	# Réinitialiser la rotation en utilisant Quat.from_euler
	var new_quat = Quaternion.from_euler(respawn_rotation)
	global_transform.basis = Basis(new_quat)

	# Réinitialiser la vélocité et les forces
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO

	# Réinitialiser le timer de l'envers
	upside_down_timer = 0.0
	is_respawn_timer_active = false
	if ScoreManager.victory_type == ScoreManager.VictoryType.LAPS:
		var race_manager = get_node("/root/Race/RaceManager")
		if race_manager:
			race_manager.reset_car_counters(self)
			print("Réinitialisation des compteurs pour ", self.name)
		else:
			print("RaceManager non trouvé!")

	# Optionnel : Afficher un message ou des effets de respawn
	print(name + " a été respawné!")

# Fonction pour vérifier si la voiture est à l'envers
func is_upside_down() -> bool:
	# Le vecteur up local de la voiture
	var up_vector = global_transform.basis.y
	# Seuil pour considérer la voiture comme à l'envers (par exemple, y < 0)
	return up_vector.y < 0.0
