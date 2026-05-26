extends Control

@export var Login_Windows: 		Window	# 子节点，登录注册复用窗口
@export var Confirm_Button: 	Button	# 子节点，确认登录按钮

# 管理器中存储的当前用户选择的注册或者登录状态，以及先前的注册或者登录状态
# 枚举状态从全局枚举类获得
var user_state: GlobalEnum.User_State 			= GlobalEnum.User_State.LOGIN
var user_per_state: GlobalEnum.User_State 		= GlobalEnum.User_State.REGISTER

# 初始化,函数在下文
func _ready() -> void:
	_initialize()
	
# 用户操作状态检测
func _user_operator_detected() -> void:
	# 仅在用户切换状态的时候触发
	if (user_state == user_per_state):
		return
	
	# 状态检测
	match user_state:
		#  用户处于登录状态，窗口为登录窗口
		GlobalEnum.User_State.LOGIN:
			Login_Windows.title = "登录"
			Confirm_Button.text = "登录"	
		#  用户处于注册状态，窗口为注册窗口
		GlobalEnum.User_State.REGISTER:
			Login_Windows.title = "注册"
			Confirm_Button.text = "注册"	
			
	# 更新完后更新用户先前状态与现在一致
	user_per_state = user_state
	
# 执行一次用户状态检测使第一次进入游戏窗口标题为登录
func _initialize() -> void:
	# 窗口初始化
	_user_operator_detected()

"""
改变用户状态
状态 0 登录
状态 1 注册
"""
# 这里是对两个选择(登录，注册)开放的API接口，用于改变当前用户选择状态
# 0 表示登录状态, 1 表示注册状态
# 这里 0 和 1 同样可以换成常量
func change_user_state(state: int) -> void:
	match state:
		0: user_state = GlobalEnum.User_State.LOGIN
		1: user_state = GlobalEnum.User_State.REGISTER
	# 更新一次用户选择状态
	_user_operator_detected() 

# 返回当前用户选择状态
func get_user_state() -> GlobalEnum.User_State:
	return user_state
