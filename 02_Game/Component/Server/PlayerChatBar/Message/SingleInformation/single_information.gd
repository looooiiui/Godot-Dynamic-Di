extends Label

# 初始化聊天信息，尝试同步一次服务器最新信息
func _ready() -> void:
	_initialize_text()

# 初始化获得最新消息
func _initialize_text()		-> void:
	
	# 获得最新消息(获取服务器聊天缓存)
	var chat_list_size: int = InjectionServerSystem.get_player_chat_list().size()
	
	# 空消息不执行
	if chat_list_size == 0:
		return
		
	# 最新消息赋值(服务器的最新消息缓存放在数组末尾)
	text = InjectionServerSystem.get_player_chat_list()[chat_list_size - 1]

# 外部给予ID更改需要显示的服务器缓存的消息(工具第几条消息)
func change_text_by_id(id: int)	-> void:
	
	# 得到服务器消息数量
	var chat_list_size: int = InjectionServerSystem.get_player_chat_list().size()
	# 超出服务器消息限制不改
	if id >= chat_list_size or id < 0:
		return
	
	# 更改text到对应玩家信息列表位置(最新第 id 条)
	text = InjectionServerSystem.get_player_chat_list()[chat_list_size - id - 1]
