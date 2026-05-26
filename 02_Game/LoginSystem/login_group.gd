extends Control

func _ready() -> void:
	_signal_initialize()
	
# 初始化信号连接
func _signal_initialize() -> void:
	LoginSystem.login_success.connect(_on_login_success)

# 连接成功，登录界面系统退出
func _on_login_success() -> void:
	queue_free()
	
