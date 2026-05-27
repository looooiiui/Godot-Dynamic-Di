extends Node

##	这里先演示同步玩家ID
##	这里是手动同步，Godot可以使用multiplayer.get_peers()直接获得玩家列表
##	拆开的手写同步的目的是:
##	1. Godot中同步的玩家数据不会有服务器ID，需要手动加
##	2. 将玩家列表从 服务器AutoLoad传出去而不是直接调用Godot网络API
##	需要注意，@rpc 关键字标明的代码需要使用如 player_list_get.rpc(player_list) 来进行发射
##	.rpc() 发射代码，括号里面可以写入传参

#玩家列表
var player_list: Array[String]				= []

func _ready() -> void:
	#初始化玩家信号连接
	_initialize_signal()
	
func _physics_process(delta: float) -> void:
	#	持续检测玩家连接(注意这里是清空列表，不是持续更新列表)，更新列表
	#	不是持续更新玩家列表，这里条件到了只执行一次
	_detect_connect()

#	接收到玩家连接信号，后将玩家列表更新
func online_player_connect(peer_id: int) 			-> void:
	
	##	只有服务器端第一时间更新数据
	##	multiplayer.get_unique_id() == 1 这句是判断是否为服务器端
	if multiplayer.get_unique_id() == 1:
		print("服务器接收: 新玩家加入: ID: %d" % peer_id)
		player_list.append(str(peer_id))
		#发送数据给其他客户端对等体
		player_list_get.rpc(player_list)
		print("服务端口: ", player_list)
	
	#	客户端受到玩家加入信号，输出玩家信息	
	if multiplayer.get_unique_id() != 1:
		print("客户端接收: 新玩家加入: ID: %d" % peer_id)

#	接收玩家断连接信号，更新玩家列表
func online_player_disconnect(disconnect_peer_id: int)						-> void:
	# 先转换为字典种存储的字符串类型
	var peer_id: String = str(disconnect_peer_id)
	# 断开连接清空数据(只有服务端)
	if multiplayer.get_unique_id() == 1:
		player_list.erase(peer_id)
		# 服务器端发送玩家列表
		player_list_get.rpc(player_list)

		# 清理玩家数据
		var game = get_parent().GameRunning
		if game:
			# 擦除玩家字典与属性
			if game.player_position_dic.has(peer_id):
				game.player_position_dic.erase(peer_id)
			if game.player_information.has(peer_id):
				game.player_information.erase(peer_id)
				
			# 重新发送玩家数据同步
			game.player_list_get.rpc(game.player_position_dic)
			game.player_list_information.rpc(game.player_information)


## 统一发送玩家列表
## @rpc("authority", "reliable")
## 意思为 1. 可发送端: 服务权威端  2. 发送模式: 可靠不丢包发送
@rpc("authority", "reliable")
func player_list_get(get_player_list: Array[String]) 				-> void:
	# 服务器端发送玩家列表
	if multiplayer.get_unique_id() != 1:
		player_list = get_player_list
		print("客户端口: ", player_list)

#初始化连接所有玩家信号
func _initialize_signal() 				-> void:
	## 连接玩家连接，断连数据
	## 连接函数 online_player_connect()
	## 连接函数 online_player_disconnect()
	## 触发信号自动连接发送函数
	multiplayer.peer_connected.connect(online_player_connect)
	multiplayer.peer_disconnected.connect(online_player_disconnect)
	
#客户端自检测
func _detect_connect()				-> void:
	## 检测联机节点
	## 断连自动清除玩家列表
	if multiplayer.multiplayer_peer == null:
		if player_list != []:
			player_list.clear()
		return
	
	# 这里检测对等体是否为空或者本地离线对等体，清空玩家列表
	if multiplayer.multiplayer_peer is OfflineMultiplayerPeer:
		if player_list != []:
			player_list.clear()
		return
	
	var state = multiplayer.multiplayer_peer.get_connection_status()
	
	#检查断连
	if state == multiplayer.multiplayer_peer.CONNECTION_DISCONNECTED:
		if player_list != []:
			player_list.clear()
			

	
