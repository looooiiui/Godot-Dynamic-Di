extends VBoxContainer

@export var single_player: 				PackedScene
@export var player_list:				Array[String]

var PlayerList: 						Dictionary[String, Node] = {}

func _physics_process(delta: float) -> void:
	_sync_with_player_list()
	
#获取网络玩家列表数据	
func _get_server_player_list()			-> void:
	player_list = Server.ServerRunning.player_list
	print(player_list)
	
#同步网络玩家数据
func _sync_with_player_list() 			-> void:
	if player_list != Server.get_player_list():
		player_list = Server.get_player_list()
	
	#刷新玩家列表
	for single_player_instantion in PlayerList:
		PlayerList[single_player_instantion].queue_free()
		
	PlayerList.clear()
	for player_id in player_list:
		PlayerList[player_id] = InstantiationTool.instantiationAny(single_player, self)
		PlayerList[player_id].initialize_single_player(player_id)
		
