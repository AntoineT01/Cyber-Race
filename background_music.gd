extends Node

class_name BackgroundMusicManager

# Nœud singleton pour la musique de fond
var music_player: AudioStreamPlayer = null
var current_music: AudioStream = null
var default_volume_db: float = 0.0

func _ready():
	# Créer le lecteur audio comme enfant de ce nœud
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	
	# Configure le lecteur pour la musique de fond
	music_player.bus = "Music"  # Utilise le bus "Music" pour une meilleure gestion du volume
	music_player.volume_db = default_volume_db
	
	# Active la lecture en boucle pour la musique de fond
	music_player.stream_paused = false
	
	# S'assure que la musique continue même si la scène change
	music_player.process_mode = Node.PROCESS_MODE_ALWAYS

func play_music(stream: AudioStream) -> void:
	if current_music != stream:
		current_music = stream
		music_player.stream = stream
		music_player.play()

func stop_music() -> void:
	music_player.stop()
	current_music = null

func set_volume(volume_db: float) -> void:
	music_player.volume_db = volume_db

func pause_music() -> void:
	music_player.stream_paused = true

func resume_music() -> void:
	music_player.stream_paused = false

# Exemple d'utilisation de fondu
func fade_out(duration: float = 1.0) -> void:
	var tween = create_tween()
	tween.tween_property(music_player, "volume_db", -80.0, duration)
	await tween.finished
	stop_music()

func fade_in(stream: AudioStream, duration: float = 1.0) -> void:
	music_player.volume_db = -80.0
	play_music(stream)
	var tween = create_tween()
	tween.tween_property(music_player, "volume_db", default_volume_db, duration)
