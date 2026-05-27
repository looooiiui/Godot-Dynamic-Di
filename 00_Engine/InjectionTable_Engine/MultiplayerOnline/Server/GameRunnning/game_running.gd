## Godot 中主机端的对等体(multiplayer.multiplayer_peer)ID 为 1
## 而其他连入的客户端的ID每次加入服务器都是随机产生的
## 所以除了 multiplayer.is_server() 外
## 还可以通过 multiplayer.get_unique_id() == 1 识别主机

extends Node

@export var player_position_dic:		Dictionary[String, Vector2]		= {}  # 玩家同步位置字典
@export var player_information:			Dictionary[String, Dictionary]	= {}  # 玩家同步杂项信息字典
@export var player_list:				Array[String]					= []  # 玩家同步列表
@export var player_chat_messages:		Array[String]					= []  # 客户端自己维护的聊天信息缓存
@export var max_chat_num:				int								= 10  # 最大聊天数量缓存
	
## 服务器主玩家自己从根管理器传进来的信息
## 因为主机不会自己维护自己的信息，需要手动加入
var server_position: 			 		Vector2				= Vector2(0, 0) # 主机玩家位置
var server_dic:							Dictionary			= {}			# 主机玩家属性杂项字典

# 外置调用同步API(这里是给根管理器调用的API，调用后主机端发送玩家位置)
func sync_with_player_position_dic(send_position: Vector2 = Vector2(0, 0)):
	_sync_with_player_position_dic(send_position)
	# 发送函数 _sync_with_player_position_dic()
	_sync_with_player_position_dic.rpc(send_position)
	
# 玩家属性信息发送(这里是给根管理器调用的API，调用后主机端发送玩家杂项信息)
func sync_with_player_information(send_information: Dictionary = {}):
	_sync_with_player_information(send_information)
	# 发送函数 _sync_with_player_information()
	_sync_with_player_information.rpc(send_information)

# 这里是玩家聊天信息发送
func send_player_message(msg: String):
	## 存入格式 [player_id] : information
	## 存入格式在发送前自动处理完毕
	var send_msg = "[" + str(multiplayer.get_unique_id()) + "]: " + msg
	
	## 需要本地先执行一次 rpc_player_chat()
	## 因为 rpc_player_chat.rpc() 发送不会执行本地的函数
	## 所以主机需要提前同步一次
	rpc_player_chat(send_msg)
	rpc_player_chat.rpc(send_msg)
	
## 任意客户端发送位置
## 这里需要输入发送方的位置信息，后自动全网广播
## 其他对等体收到后会均会执行函数，实参为发送方发送(.rpc)的变量
@rpc("any_peer", "unreliable")
func _sync_with_player_position_dic(send_position: Vector2 = Vector2(0, 0)) 				-> void:
	
	## 增加新玩家位置
	## multiplayer.get_unique_id() == 1 的意思是 如果是主机端
	if multiplayer.get_unique_id() == 1:	
		# 得到发送信息的对等体的远程ID
		var player_id: String = str(multiplayer.get_remote_sender_id())
		## 未连接退出
		## 对等体未收到远程消息的时候远程ID默认为0
		## 未连接则包含本地玩家并退出
		if player_id == "0":
			player_position_dic["1"]		= server_position	# 主机端自己更新自己位置
			return
		
		## 这里是为了防止丢包后玩家位置闪回为Vector(0, 0)
		## 因为可以看到在发送位置但是没有传参的情况下 send_position 的值为 Vector(0, 0)
		if send_position == Vector2(0, 0):
			return
	
		player_position_dic[player_id] 	= send_position		# 主机端在位置同步字典中更新服务器发送方玩家位置
		player_position_dic["1"]		= server_position	# 主机端自己更新自己位置
		player_list_get.rpc(player_position_dic)			# 主机端发送玩家数据字典，调用 player_list_get.rpc
		
## 任意客户端发送玩家数据		
## 发送玩家离散数据
@rpc("any_peer", "unreliable")
func _sync_with_player_information(send_information: Dictionary = {})	-> void:
	
	## 主机端收到后更新玩家数据
	if multiplayer.get_unique_id() == 1:
		# 得到远程ID
		var player_id: String = str(multiplayer.get_remote_sender_id())
		
		# 未连接则包含本地玩家并退出
		if player_id == "0":
			player_information["1"]	  = server_dic	# 主机端更新自己的杂项数据
			return
			
		# 防止接收空数据导致外部取到不存在的键值
		if send_information == {}:
			return
			
		player_information[player_id] 	= send_information			# 主机端在玩家杂项数据字典中更新服务器发送方玩家位置
		player_information["1"]	  		= server_dic				# 主机端更新自己的杂项数据
		player_list_information.rpc(player_information)				# 主机端发送玩家数据字典，调用 player_list_information.rpc
	
# 仅主机端可发送，可靠发送
@rpc("authority", "reliable")
func player_list_get(get_player_position_dic: Dictionary) 				-> void:
	## 服务器端发送玩家列表
	## 只有非主机端玩家可执行字典替换操作
	if multiplayer.get_unique_id() != 1:
		player_position_dic = get_player_position_dic

# 仅主机端可发送，可靠发送	
@rpc("authority", "reliable")
func player_list_information(get_player_information: Dictionary)		-> void:
	## 服务器端发送玩家杂项信息
	## 只有非主机端玩家可执行字典替换操作
	if multiplayer.get_unique_id() != 1:
		player_information = get_player_information
	
## 玩家聊天信息广播
## 任何人可发送，可靠发送
@rpc("any_peer", "reliable")
func rpc_player_chat(msg: String):
	## 存入格式 [player_id] : information 
	## 格式处理在上面调用API传入前已经处理完毕
	## 更新聊天缓存列表(直接加入新获取消息)
	player_chat_messages.append(msg)
	
	## 限制消息存储限制
	if player_chat_messages.size() > max_chat_num:
		player_chat_messages.pop_front()
		
#客户端自检测
func _detect_connect()				-> void:
	## 断连有两个表示
	## 1 是 multiplayer.multiplayer_peer == null
	## 2 是 multiplayer.multiplayer_peer is OfflineMultiplayerPeer
	## 检测联机节点
	## 断连自动清除玩家列表
	if multiplayer.multiplayer_peer == null:
		if player_list != []:
			player_list.clear()
			player_position_dic.clear()
			player_chat_messages.clear()
		return
	
	## 这里检测对等体是否为空或者本地离线对等体
	## 检查断线后清除所有同步数据
	if multiplayer.multiplayer_peer is OfflineMultiplayerPeer:
		if player_list != []:
			player_list.clear()
			player_position_dic.clear()
			player_chat_messages.clear()
		return
	
	## 这里是使用Godot内置API获得对等体连接状态
	## 内置状态为断连同样清理一次
	var state = multiplayer.multiplayer_peer.get_connection_status()
	
	#检查断连
	if state == multiplayer.multiplayer_peer.CONNECTION_DISCONNECTED:
		if player_list != []:
			player_list.clear()
			player_position_dic.clear()
			player_chat_messages.clear()
