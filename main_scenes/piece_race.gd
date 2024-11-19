extends Node

func _ready() -> void:
	ScoreManager.set_victory_condition("pieces", ScoreManager.victory_target)
