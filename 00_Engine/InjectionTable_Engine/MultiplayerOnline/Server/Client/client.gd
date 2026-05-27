extends Node

#固定连接端口(演示)
var PORT: int 			= 7777
#本机测试地址
var SERVER_IP: String 	= "26.224.10.101"

#服务器连接超时信号
signal server_connect_failed

#创建客户端
func create_client() -> bool:
	var peer = ENetMultiplayerPeer.new()
	if peer == null:
		push_error("客户端启动失败")
		
	#创建客户端(对等体连接IP)
	var err = peer.create_client(SERVER_IP, PORT)
	if err != OK:
		push_error("服务器启动失败")
		return false
	multiplayer.multiplayer_peer = peer
	
	## 监听连接结果
	## connected_to_server 			为Godot中网络自带API，负责检测成功连接到服务器(连接成功)
	## connection_failed			为Godot中网络自带API，负责检测未能连接到服务器(连接超时)
	
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	print("正在连接服务器")
	
	return true

func _on_connected_ok() -> void:
	print("成功连接到服务器")
	
func _on_connected_fail() -> void:
	print("连接服务器失败")
	
	#连接超时发送连接超时信号
	server_connect_failed.emit()

# 断开客户端连接
func close_client() -> bool:
	# 获取客户端对等体并清空
	var peer = multiplayer.multiplayer_peer
	if peer == null:
		return false
	
	#关闭客户端(防止服务器端口误点击关闭客户端而关闭服务端)
	if multiplayer.get_unique_id() == 1:
		push_error("本机器为服务端口，不是客户端口，不可使用客户端口关闭")
		return false
	
	#断开信号连接
	multiplayer.connected_to_server.disconnect(_on_connected_ok)
	multiplayer.connection_failed.disconnect(_on_connected_fail)

	peer.close()
	#清空网络设置
	multiplayer.multiplayer_peer = null
	if multiplayer.multiplayer_peer != null:
		return false
	
	print("已断开连接")
	return true
