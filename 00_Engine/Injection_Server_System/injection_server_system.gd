extends Node

static var SystemInstantiation: Node = null

# 是否已经创建服务端，即服务器状态管理(客户端)
var alreadyCreateServe: bool 		= false
var alreadyCreateClient: bool		= false
		
func _ready() -> void:
	# 连接注入模块循环连接
	InjectionInterface.refresh_model_info.connect(_on_connect_updata)
	
	# 等待注入
	while SystemInstantiation == null:
		await get_tree().create_timer(0.2).timeout
		
func _on_connect_updata() -> void:
	if SystemInstantiation == null:
		return
	alreadyCreateServe 		= SystemInstantiation.alreadyCreateServe
	alreadyCreateClient 	= SystemInstantiation.alreadyCreateClient
	
#创建服务端
func create_serve() -> void:
	SystemInstantiation.create_serve()

# 创建客户端
func create_client() 				-> void:
	SystemInstantiation.create_client()

# 对外开放 关闭服务器
func close_serve() 					-> void:
	SystemInstantiation.close_serve()
	
# 对外开放 关闭客户端
func close_client() 				-> void:
	SystemInstantiation.close_client()
	
# 同步玩家位置信息
func sync_position(send_position: Vector2)-> void:
	SystemInstantiation.sync_position(send_position)
	
# 同步玩家杂项属性信息(补充)
func sync_infomation(send_information: Dictionary) -> void:
	SystemInstantiation.sync_infomation(send_information)
	
# 网络全局场景切换	
func change_all_scene(path: String) -> void:
	SystemInstantiation.change_all_scene(path)

# 得到玩家列表
func get_player_list()				-> Array:
	var result = SystemInstantiation.get_player_list()
	return result
	
# 得到玩家位置信息字典
func get_player_position_dic()						-> Dictionary:
	var result = SystemInstantiation.get_player_position_dic()
	return result

# 得到玩家杂项信息字典(补充)
func get_player_information()						-> Dictionary:
	var result = SystemInstantiation.get_player_information()
	return result
	
# 更新主机玩家位置
func change_main_player_position(main_position: Vector2)			-> void:
	SystemInstantiation.change_main_player_position(main_position)
	
# 更新主机玩家信息(补充)
func change_main_player_infomation(main_information: Dictionary)	-> void:
	SystemInstantiation.change_main_player_infomation(main_information)
	
# 发送信息
func send_message(msg: String) 		-> void:
	SystemInstantiation.send_message(msg)
	
# 获取玩家信息列表
func get_player_chat_list() 		-> Array:
	var result = SystemInstantiation.get_player_chat_list()
	return result

# 返回服务器(客户端)连接状态
func is_connect() -> bool:
	var result = SystemInstantiation.is_connect()
	return result

# 得到玩家网络ID
func get_player_id() -> int:
	var result = SystemInstantiation.get_player_id()
	return result
		
# 切换场景全局广播
func rpc_change_scene(path: String):
	SystemInstantiation.rpc_change_scene(path)
