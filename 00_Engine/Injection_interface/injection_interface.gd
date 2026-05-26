extends Node

# 通用系统状态
class OriginalSystem extends Object:
	static var EXIST_STATE: 	bool	= false
	static var START_STATE: 	bool 	= false
	static var EXTRA_IMPORT: 	bool 	= false
	
# Injection_Login_System 系统状态
class LoginSystemState extends OriginalSystem:
	pass
	
"""
根管理器启动参数(Python)
"0": 解析一次Excel到Json
"""
#==========================子管理器==========================#
@export var Injection_Json_Parsing		: Node
@export var Injection_Noraml_Operator	: Node
#===========================================================#

#=========================================标准执行路径============================================#
@export var injection_python_path: 	String 	= "res://Python_configuration_table_code/FileProcessingMain.py"
@export var injection_json_path: 	String 	= "res://Python_configuration_table_code/InjectionConvert.json"
@export var injection_normal_path: 	String	= "res://Python_configuration_table_code/"
#===============================================================================================#

#=========================字典全局数据类============================#
var injection_dict: Dictionary 			= {}		# 注入字典
var injection_mapping_dict: Dictionary 	= {}		# 注入字典映射表
#=================================================================#

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

# 执行一次Excel转换Json,同时完成依赖字典处理,管理器映射表对应
func injection_start() -> void:
	Injection_Noraml_Operator.injection_start()
	
	# 将转化结果换入结果字典中
	injection_dict = Injection_Json_Parsing.get_Injection_information(injection_json_path)
	# 将转化结果存成Godot相对地址
	injection_dict = Injection_Noraml_Operator.convert_injection_dict_local(injection_dict)
	injection_dict = Injection_Noraml_Operator.convert_injection_dict_local(injection_dict, "AFFILIATED")
	
	# 清空原先映射
	injection_mapping_dict = {}
	# 验证管理器是否已经存入键值对
	var matched: Dictionary[String, bool] = {}
	# 匹配键名建立管理器映射
	for manager_name: String in injection_dict:
		# 转小写匹配字符建立映射
		var search_name = manager_name.to_lower()
		# 仅记录第一个键名映射管理器
		if (search_name.contains("login")) and not matched.has("login"):
			injection_mapping_dict[manager_name] = InjectionLoginSystem
			matched["login"] = true
			
	#print(injection_mapping_dict)
		
# 执行一次依赖注入
func dependency_injection() -> void:
	pass

func _ready() -> void:
	# 先使用Python转化一次
	injection_start()
	
