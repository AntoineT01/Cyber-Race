extends CanvasLayer

# On récupère le nœud PauseMenu
@onready var pause_menu = $PauseMenu

func _ready():
	pause_menu.visible = false  # Cache le menu de pause au démarrage
