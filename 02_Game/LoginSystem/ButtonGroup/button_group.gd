extends VBoxContainer

@export var Login_Window		: Window	# 登录界面窗口
@export var Login_Group			: Control	# 登录UI管理器(LoginGroup)

# 初始化
func _ready() -> void:
	_initialize()

# 按下登录按键，向登录UI管理器发送状态更改
func _on_login_pressed() -> void:
	Login_Window.visible = true			# 显示窗口
	Login_Group.change_user_state(0)	# 发送状态更改值为 0，上文已演示API对应代码

# 按下注册按键，向登录UI管理器发送状态更改
func _on_register_pressed() -> void:
	Login_Window.visible = true			# 显示窗口
	Login_Group.change_user_state(1)	# 发送状态更改值为 1，上文已演示API对应代码

# 退出登录系统(这里退出游戏)
func _on_exit_game_pressed() -> void:
	get_tree().quit()
	
# 初始化
func _initialize() -> void:
	# 窗口初始化登录窗口为不可见
	Login_Window.visible = false
