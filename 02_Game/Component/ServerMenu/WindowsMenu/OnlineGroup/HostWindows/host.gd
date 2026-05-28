extends Window


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	pass


func _on_exit_pressed() -> void:
	Server.close_serve()
	visible = false


func _on_start_game_pressed() -> void:
	Server.change_all_scene("res://02Scenes/MainTestRoot/multiplayer.tscn")
