extends Window

@export var Host_Windows: Window
@export var Join_Windows: Window

func _on_exit_pressed() -> void:
	visible = false

func _on_start_pressed() -> void:
	visible = true

#创建服务器
func _on_create_server_pressed() -> void:		
	if Server.alreadyCreateClient:
		return
	Host_Windows.visible = true
	Server.create_serve()

#加入游戏
func _on_join_server_pressed() -> void:
	if Server.alreadyCreateServe:
		return
	Join_Windows.visible = true
	Server.create_client()
