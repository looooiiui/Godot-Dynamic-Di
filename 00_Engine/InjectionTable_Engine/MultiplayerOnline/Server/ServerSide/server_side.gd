extends Node

#演示，固定端口 7777，以及最大连接数量为4
var PORT: int							= 7777
var MAX_PLAYER: int 					= 4

#创建服务器
func create_server() -> bool:
	#创建连接器(创建对等体，注意此时还没有规定服务端)
	var peer = ENetMultiplayerPeer.new()
	
	if peer == null:
		push_error("服务器启动失败")
		return false
		
	#创建服务端(这时候规定了此对等体为服务端)
	var err = peer.create_server(PORT, MAX_PLAYER)
	if err != OK:
		push_error("服务器启动失败")
		return false
	multiplayer.multiplayer_peer = peer
	
	## 启动监听
	## peer_connected 			是Godot中网络连接自带信号，负责监听是否有新连接
	##	peer_disconnected 		是Godot中网络连接自带信号，负责监听是否有连接断开
	
	multiplayer.peer_connected.connect(_on_peer_connect)
	multiplayer.peer_disconnected.connect(_on_peer_disconnect)
	print("服务器启动，端口号:", PORT)
	return true
	
#服务器接入端口
func _on_peer_connect(peer_id) -> void:
	print("玩家连入: ID:", peer_id)
	rpc_id(peer_id, "attend_game")
	
#服务器接出端口
func _on_peer_disconnect(peer_id) -> void:
	print("玩家断开: ID:", peer_id)
	
#关闭服务器
func close_serve() -> bool:
	#获取服务器对等体并断开(关闭服务器)
	var peer = multiplayer.multiplayer_peer
	if peer == null:
		return false
	
	#关闭服务器(防止客户端因为某种原因点击关闭服务器后误关客户端自己)
	if !(multiplayer.get_unique_id() == 1):
		return false
	
	#断开信号连接
	multiplayer.peer_connected.disconnect(_on_peer_connect)
	multiplayer.peer_disconnected.disconnect(_on_peer_disconnect)
	
	peer.close()
	#清空网络设置
	multiplayer.multiplayer_peer = null
	if multiplayer.multiplayer_peer != null:
		return false

	print("服务器已关闭")
	return true
