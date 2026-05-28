extends Node

# 计时,定时刷新接口与子模块的信息
signal refresh_model_info

# 通用系统状态
class OriginalSystem extends Object:
	static var EXIST_STATE: 	bool	= false
	static var START_STATE: 	bool 	= false
	static var EXTRA_IMPORT: 	bool 	= false
	# 状态重置
	static func RESET_STATE() -> void:
		EXIST_STATE 	= false
		START_STATE 	= false
		EXTRA_IMPORT 	= false
		
# Injection_Login_System 系统状态
class LoginSystemState extends OriginalSystem:
	pass
		
# ServerSystemState 系统状态
class ServerSystemState extends OriginalSystem:
	pass
	
"""
根管理器启动参数(Python)
	"0": 解析一次Excel到Json

管理器规定映射:
	检查映射管理器:
		登录: 	"login"
		服务器: 	"register"
	对应模块映射:
		登录: 	"login"
		服务器: 	"register"		
"""

#==========================子管理器==========================#
@export var Injection_Json_Parsing		: Node
@export var Injection_Noraml_Operator	: Node
@export var INJECTIONCORE				: Node
#===========================================================#

#=========================================标准执行路径============================================#
@export var injection_python_path: 	String 	= "res://Python_configuration_table_code/FileProcessingMain.py"
@export var injection_json_path: 	String 	= "res://Python_configuration_table_code/InjectionConvert.json"
@export var injection_normal_path: 	String	= "res://Python_configuration_table_code/"
#===============================================================================================#

#=========================字典全局数据类============================#
var injection_dict: Dictionary 			= {}		# 完整注入字典
var injection_mapping_dict: Dictionary 	= {}		# 注入字典映射游戏内管理器表
#=================================================================#

#===============================模块常值匹配表===============================#
static var MATCH_LOGIN_MODEL		: String 	= "login"
static var MATCH_SERVER_MODEL		: String 	= "server"
static var MODELREGISTERMAP: Dictionary = {
	MATCH_LOGIN_MODEL	: InjectionLoginSystem, 
	MATCH_SERVER_MODEL	: InjectionServerSystem
	}
#==========================================================================#

func load_to_main_scene() -> void:
	get_tree().change_scene_to_file("res://02_Game/Component/ServerMenu/ServerUi.tscn")
	#get_tree().change_scene_to_file("res://02_Game/Level/MenuScene/menu_scene.tscn")

# 获得注入Json获取路径(res://路径)
func get_injection_json_path() -> String:
	return injection_json_path
	
# 获得注入Json路径(绝对路径)
func get_injection_absolute_json_path() -> String:
	var absolute_result: String = ProjectSettings.globalize_path(get_injection_json_path())
	return absolute_result
	 
# 获得注入Python脚本路径(绝对路径)
func get_injection_python_path() -> String:
	var absolute_result: String = ProjectSettings.globalize_path(injection_python_path) 
	return absolute_result

# 得到Python注入脚本的根目录
func get_normal_path() -> String:
	var absolute_result: String = ProjectSettings.globalize_path(injection_normal_path)
	return absolute_result

# 得到注册模块常值映射
func get_model_register_map() -> Dictionary:
	return MODELREGISTERMAP.duplicate(true)

# 执行一次Excel转换Json,同时完成依赖字典处理,管理器映射表对应
# 格式为 { "模块名": [对应模块静态实例存储, "模块地址"] }
func injection_start(path_head_name: String = "PATH") -> void:
	Injection_Noraml_Operator.injection_start()
	
	# 将转化结果换入结果字典中
	injection_dict = Injection_Json_Parsing.get_Injection_information(injection_json_path)
	# 将转化结果存成Godot相对地址
	injection_dict = Injection_Noraml_Operator.convert_injection_dict_local(injection_dict)
	injection_dict = Injection_Noraml_Operator.convert_injection_dict_local(injection_dict, "AFFILIATED")
	
	injection_mapping_dict = Injection_Noraml_Operator.injection_mapping(injection_dict, "PATH")
			
	DebugTool.debug_log("初始化注入: 初始转换映射字典: %s " % injection_mapping_dict)
	DebugTool.debug_log("完成流程: 注入初始化映射表")
		
# 尝试一次依赖注入
func try_dependency_injection() -> void:
	# 得到验证映射表
	var verify_path_result = Injection_Noraml_Operator.get_path_verify_result(injection_mapping_dict)
	# 执行依赖主流程
	INJECTIONCORE.INJECTION_CORE_TSCN_START(injection_mapping_dict, verify_path_result, 1, injection_dict)
	DebugTool.debug_log("完成流程: 执行注入")

# 初始化全局静态数据
func _initialize_global_data() -> void:
	MATCH_LOGIN_MODEL 	= "login"
	MATCH_SERVER_MODEL	= "server"
	MODELREGISTERMAP = {
	MATCH_LOGIN_MODEL	: InjectionLoginSystem, 
	MATCH_SERVER_MODEL	: InjectionServerSystem
	}

# 发射状态刷新信号
func _refresh_injection_info() -> void:
	refresh_model_info.emit()

# 注入流程
func _ready() -> void:
	
	_initialize_global_data()
	# 先使用Python转化一次
	injection_start()
	# 启动依赖注入
	try_dependency_injection()
	# 等待场景加载完成
	load_to_main_scene()
