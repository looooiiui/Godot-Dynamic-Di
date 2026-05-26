extends Node

"""
需要注意的是，下文的所有返回值
均可以换成全局枚举类型
本文使用的是字符串比对
使用全局枚举的在登录界面演示中会使用
"""

# 登录信息信号
signal login_success	# 登录成功信号
signal login_out		# 账户登出信号

# 登录和注册两个子管理器
@export var Login		: Node
@export var Register	: Node

# 存储当前账号状态
var current_account_id: String 	= ""		# 当前成功登录玩家ID
var is_Login: bool 				= false		# 当前是否登录

# 主管理器提供统一 Excel 文件地址，这里使用绝对地址，当然也可以使用相对Godot的相对地址
# 主管理器同样要提供 Python脚本 的地址
var excel_path 		= "res://00_Engine/InjectionTable_Engine/LoginSystem/LoginPython/AccountInfomation.xlsx"
var python_script 	= "res://00_Engine/InjectionTable_Engine/LoginSystem/LoginPython/FileProcessingMain.py"

# 获得默认python脚本路径(转化后的绝对路径)
func get_python_processing_path() 	-> String:
	var absolute_result: String = ProjectSettings.globalize_path(python_script) 
	return absolute_result

# 获得默认excel路径(转化后的绝对路径)
func get_excel_path() 				-> String:
	var absolute_result: String = ProjectSettings.globalize_path(excel_path) 
	return absolute_result

"""
以下登录返回值类型
返回 0 登录成功
返回 1 账户信息不存在
返回 2 账户信息验证错误(密码错误)
"""
# 进行登录验证
func login_verify(name: String, password: String)		-> String:
	
	# 将获得的输入改为标准格式: ["名字", "密码"]
	var input_info: Array[String] = [name, password]
	# 调用子登录管理器验证并获得返回值
	var verify_result = Login.login_info_verify(input_info)
	
	# 登录器自验证注册是否成功，成功则更改登录服务器存储信息
	# 登录自验证函数在下文
	verify_login_success(verify_result, name)
	return verify_result

"""
以下注册返回值类型
返回 0 注册成功
返回 1 账户注册出现问题(非法字符/账户密码问题)
返回 2 账户已被注册
"""		
# 进行注册验证
func register_verify(name: String, password: String)	-> String:
	
	# 将获得的输入改为标准格式: ["名字", "密码"]
	var input_info: Array[String] = [name, password]
	var verify_result = Register.register_info_verify(input_info)
	
	# 登录器自验证注册是否成功
	verify_login_success(verify_result, name)
	return verify_result

# 获得当前登录玩家ID
func get_current_id() -> String:
	return current_account_id
	
# 更改当前玩家登录ID
func change_current_id(new_id: String) -> void:
	current_account_id = new_id

# 获得登录状态
func get_login_state() -> bool:
	return is_Login

# 登录成功验证
func verify_login_success(verify_result: String, verift_account_name: String) -> void:
	
	# 验证结果为 "0"(通过) 则更新当前登录系统登录状态 
	if verify_result == "0":
		is_Login = true
		login_success.emit()	# 发出登录信号
	
	# 更新服务器信息
	if is_Login:
		current_account_id = verift_account_name

# 退出登录，同时更新服务器信息
func exit_login() -> void:
	is_Login = false			# 登录状态为 未登录
	current_account_id = ""		# 重置当前登录ID
	login_out.emit()			# 发送登出信号
