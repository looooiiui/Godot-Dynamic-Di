extends VBoxContainer

@export var single_message:			PackedScene		# 单个聊天信息场景
@export var message_label_list:		Array[Node]		# 数组存所有聊天信息实例
@export var Input_Line_Edit:		LineEdit		# 聊天信息输入栏
@export var current_message_num:	int = 0			# 当前显示消息数量
@export var max_message_num:		int = 6			# 最大消息显示数量

# 先前服务器聊天缓存，用来对比最新数据，实现仅服务器更新而更新消息列表
var per_chat_message_list:			Array = []

# 主要聊天栏循环
func _physics_process(delta: float) -> void:
	_chat_detection()					# 聊天信息检查，管理
	_disconnect_clear_dectection()		# 断连聊天栏处理
	
# 检测聊天状态并显示
func _chat_detection()	-> void:
	
	# 如果先前缓存的服务器信息和服务器最新信息不一致
	if (per_chat_message_list != Server.get_player_chat_list()):
		per_chat_message_list = Server.get_player_chat_list()

		# 聊天栏显示消息未满首先实例化单个聊天信息
		if current_message_num < max_message_num:
			# 将最新单个聊天信息存入聊天信息实例数组，统一管理
			message_label_list.append(InstantiationTool.instantiationAny(single_message, self))
			current_message_num += 1
			return
		
		# 满信息则循环替换所有单个信息显示的信息，从最底下开始同步服务器最新消息
		for index in range(0, message_label_list.size()):
			## 这里使用 message_label_list.size() - index - 1
			## 主要是因为单个信息读取的服务器信息是 0 为最新
			## 而数组从 0 开始的索引是最上面也就是最旧的消息
			message_label_list[index].change_text_by_id(message_label_list.size() - index - 1)
			
# 这里是接受到 LineEdit(单行输入) 的信号，开始向服务器调用发送消息的信号
func _on_input_chat_text_submitted(chat_text: String) -> void:
	Server.send_message(chat_text)
	Input_Line_Edit.clear()

# 断连清空聊天栏
func _disconnect_clear_dectection() -> void:
	# 连接服务器状态不清空聊天栏
	if Server.is_connect():
		return
		
	# 聊天栏为空则不清空
	if message_label_list.is_empty():
		return
	
	# 遍历清空聊天栏	
	for massage_label in message_label_list:
		massage_label.queue_free()
	message_label_list.clear()
		
