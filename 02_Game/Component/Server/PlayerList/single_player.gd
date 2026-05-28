extends Label


#玩家本身数据初始化
func initialize_single_player(player_id: String) 	-> void:
	if multiplayer.multiplayer_peer != null:
		text = "ID: " + player_id

func _check_mutil_exist()			-> void:
	if multiplayer.multiplayer_peer == null:
		queue_free()
