extends Node

static var SystemInstantiation: Node = null

# 登录信息信号
signal login_success	# 登录成功信号
signal login_out		# 账户登出信号

# 登录和注册两个子管理器
@export var Login		: Node
@export var Register	: Node

# 存储当前账号状态
var current_account_id: String 	= ""		# 当前成功登录玩家ID
var is_Login: bool 				= false		# 当前是否登录

func _ready() -> void:
	InjectionInterface.refresh_model_info.connect(_on_connect_updata)
	
	# 等待注入
	while SystemInstantiation == null:
		await get_tree().create_timer(0.2).timeout
	# 信号连接
	_initialize_injection_signal()
	
#==============================连接注入模块信号================================#
func _initialize_injection_signal() -> void:
	SystemInstantiation.login_success.connect(_signal_login_success)
	SystemInstantiation.login_out.connect(_signal_login_out)

# 信号二次发送
func _signal_login_success() -> void:
	login_success.emit()
	
# 信号二次发送
func _signal_login_out() -> void:
	login_out.emit()
#===========================================================================#
# 根据主注入提示更新一次当前信息与注入模块
func _on_connect_updata() -> void:
	if SystemInstantiation == null:
		return
	# 更新数据
	var updata_id = SystemInstantiation.current_account_id
	var updata_is_login = SystemInstantiation.is_Login
	current_account_id = updata_id
	is_Login = updata_is_login

# 获得默认python脚本路径(转化后的绝对路径)
func get_python_processing_path() 	-> String:
	var result = SystemInstantiation.get_python_processing_path()
	return result

# 获得默认excel路径(转化后的绝对路径)
func get_excel_path() 				-> String:
	var result = SystemInstantiation.get_excel_path()
	return result

# 进行登录验证
func login_verify(name: String, password: String)		-> String:
	var result = SystemInstantiation.login_verify(name, password)
	return result

# 进行注册验证
func register_verify(name: String, password: String)	-> String:
	var result = SystemInstantiation.register_verify(name, password)
	return result

# 获得当前登录玩家ID
func get_current_id() -> String:
	var result = SystemInstantiation.get_current_id()
	return result
	
# 更改当前玩家登录ID
func change_current_id(new_id: String) -> void:
	SystemInstantiation.change_current_id(new_id)

# 获得登录状态
func get_login_state() -> bool:
	var result = SystemInstantiation.get_login_state()
	return result

# 登录成功验证
func verify_login_success(verify_result: String, verift_account_name: String) -> void:
	SystemInstantiation.verify_login_success(verify_result, verift_account_name)

# 退出登录，同时更新服务器信息
func exit_login() -> void:
	SystemInstantiation.exit_login()
