extends Node

#服务端口,客户端口,服务器运行端口的变量(子管理器)
@export var ServerSide: 		Node		# 服务端管理器
@export var Client: 			Node		# 客户端管理器
@export var ServerRunning:		Node		# 服务器运行时管理器
@export var GameRunning:		Node		# 游戏运行时管理器

# 是否已经创建服务端，即服务器状态管理(客户端)
var alreadyCreateServe: bool 		= false
var alreadyCreateClient: bool		= false
		
func _ready() -> void:
	#这里接收所有子管理器信号as
	_signal_initialize()
	
#创建服务端
func create_serve() -> void:
	# 只启动服务端或者客户端
	if alreadyCreateServe or alreadyCreateClient:
		return
	
	# 调用子管理器创建，得到是否创建成功的返回值
	if ServerSide.create_server():
		alreadyCreateServe = true
		ServerRunning.player_list.append("1")

# 创建客户端
func create_client() 				-> void:
	# 只启动服务端或者客户端
	if alreadyCreateClient or alreadyCreateServe:
		return
	
	## 创建客户端成功，但是没有连接成功返回true
	## 连接失败返回信号并重新变更为false，信号函数在下文
	if Client.create_client():
		alreadyCreateClient = true

# 对外开放 关闭服务器
func close_serve() 					-> void:
	if !alreadyCreateServe:
		return
	
	# 关闭服务器
	if !ServerSide.close_serve():
		print("服务器关闭失败")
		return
	alreadyCreateServe = false
	
# 对外开放 关闭客户端
func close_client() 				-> void:
	if !alreadyCreateClient:
		return
	
	# 关闭客户端连接
	if !Client.close_client():
		print("客户端关闭失败")
		return
	alreadyCreateClient = false
	
## 子管理器信号连接
func _signal_initialize()					-> void:
	#这里连接的是子管理器客户端连接超时的信号
	Client.server_connect_failed.connect(_on_client_connect_failed)

# 客户端连接失败
func _on_client_connect_failed()			-> void:
	alreadyCreateClient = false
	
# 同步玩家位置信息
func sync_position(send_position: Vector2)-> void:
	GameRunning.sync_with_player_position_dic(send_position)
	
# 同步玩家杂项属性信息(补充)
func sync_infomation(send_information: Dictionary) -> void:
	GameRunning.sync_with_player_information(send_information)
	
# 网络全局场景切换	
func change_all_scene(path: String) -> void:
	# 服务器切换场景
	if !(multiplayer.get_unique_id() == 1):
		return
	
	rpc_change_scene(path)
	rpc_change_scene.rpc(path)

# 得到玩家列表
func get_player_list()				-> Array:
	# 这里 .duplicate() 返回的是数组的副本，防止篡改内部信息
	return ServerRunning.player_list.duplicate()
	
# 得到玩家位置信息字典
func get_player_position_dic()						-> Dictionary:
	# 这里 .duplicate() 返回的是字典的副本，防止篡改内部信息
	return GameRunning.player_position_dic.duplicate()

# 得到玩家杂项信息字典(补充)
func get_player_information()						-> Dictionary:
	# 这里 .duplicate() 返回的是字典的副本，防止篡改内部信息
	return GameRunning.player_information.duplicate()
	
# 更新主机玩家位置
func change_main_player_position(main_position: Vector2)			-> void:
	GameRunning.server_position = main_position
	
# 更新主机玩家信息(补充)
func change_main_player_infomation(main_information: Dictionary)	-> void:
	GameRunning.server_dic = main_information
	
# 发送信息
func send_message(msg: String) 		-> void:
	GameRunning.send_player_message(msg)
	
# 获取玩家信息列表
func get_player_chat_list() 		-> Array:
	# 这里 .duplicate() 返回的是数组的副本，防止篡改内部信息
	return GameRunning.player_chat_messages.duplicate()

# 返回服务器(客户端)连接状态
func is_connect() -> bool:
	var peer = multiplayer.multiplayer_peer
	if peer == null or peer is OfflineMultiplayerPeer:
		return false

	return peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED

# 得到玩家网络ID
func get_player_id() -> int:
	return multiplayer.get_unique_id()
		
# 切换场景全局广播
@rpc("any_peer", "reliable")
func rpc_change_scene(path: String):
	get_tree().change_scene_to_file(path)
