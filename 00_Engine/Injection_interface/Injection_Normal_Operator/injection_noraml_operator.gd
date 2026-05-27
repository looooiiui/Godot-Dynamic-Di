extends Node

@export var Injection_interface_node: Node

#=========================模块对应统一键值======================#
var login_model_key		: String = ""
var server_model_key	: String = ""
#============================================================#

"""
标准Godot传入参数:
	[
	Python路径, 
	Python运行参数
	普通Python注入代码绝对路径,
	注入Json文件绝对路径,
	]
"""

# 初始化模块常量
func _ready() -> void:
	login_model_key 	= Injection_interface_node.MATCH_LOGIN_MODEL
	server_model_key 	= Injection_interface_node.MATCH_SERVER_MODEL

# 启动一次注入
func injection_start(start_up_param: int = 0):
	var return_result: Array = []
	
	#  格式化传入参数
	var python_path = Injection_interface_node.get_injection_python_path()
	var json_path	= Injection_interface_node.get_injection_absolute_json_path()
	var normal_path = Injection_interface_node.get_normal_path()
	
	# 启动参数
	var start_argv: Array = [
							python_path, 
							start_up_param,
							normal_path,
							json_path
							] 

	# 尝试传入参数	
	OS.execute("python", start_argv, return_result, true, true)
	for cell in return_result:
		DebugTool.debug_log(cell)

# 将收到的注入字典中的绝对地址转化为相对Godot的地址
func convert_injection_dict_local(injection_dict: Dictionary, 
								  path_head_name: String = "PATH"
								  ) -> Dictionary: 
		# 结果字典
		var result_dict: Dictionary = injection_dict.duplicate(true)
		# 遍历转化
		for manager_name in result_dict:
			# 取出单个数据字典
			var module_data = result_dict[manager_name]
			# 不存在键跳过
			if not module_data.has(path_head_name):
				continue
				
			if (module_data[path_head_name] == null):
				continue
			if not (module_data[path_head_name] is String):
				continue
			# 转化为相对Godot路径
			var original_absolute_path = module_data[path_head_name]
			var convert_result: String = ProjectSettings.localize_path(original_absolute_path).strip_escapes()
			
			# 更新结果字典
			result_dict[manager_name][path_head_name] = convert_result
		return result_dict

# 执行注入地址与游戏内管理器映射
# 传入完整注入表
# 返回结果形如 { "模块名": [对应模块静态实例存储, "模块地址"] }
func injection_mapping(injection_dict: Dictionary, path_head_name: String = "PATH") -> Dictionary:
	if injection_dict.is_empty():
		DebugTool.debug_log("地址映射写入: 传入完整映射原字典为空")
		return {}
		
	# 建立传入副本
	var result_dict: Dictionary = {}
	
	# 验证管理器是否已经存入键值对
	var matched: Dictionary[String, bool] = {}
	# 匹配键名建立管理器映射
	for manager_name: String in injection_dict:
		# 转小写匹配字符建立映射
		var search_name = manager_name.to_lower()
		# 仅记录第一个键名映射管理器
		if (search_name.contains(login_model_key)) and not matched.has(login_model_key):
			result_dict[manager_name] = [InjectionLoginSystem]
			matched[login_model_key] = true
		elif (search_name.contains(server_model_key)) and not matched.has(server_model_key):	
			result_dict[manager_name] = [InjectionServerSystem]
			matched[server_model_key] = true
		
	# 根据映射将地址映入
	for manager_name: String in result_dict:
		if injection_dict[manager_name].has(path_head_name):
			var injection_path = injection_dict[manager_name][path_head_name]
			result_dict[manager_name].append(injection_path)
		else: 
			DebugTool.debug_log("注入警告：模块 %s 不存在路径键 %s" % [manager_name, path_head_name])
			result_dict[manager_name].append(null)
	
	return result_dict
	
# 检查管理器路径存在，返回验证字典，键名对应传入字典
# 传入字典要求格式形如 { "模块名": [对应模块静态实例存储, "模块地址"] }
# 还需要传入地址相应索引位置(默认1)
# 注意验证的是注入的Godot格式的文件
func get_path_verify_result(input_dir: Dictionary, default_path_index: int = 1) -> Dictionary[String, bool]:
	var result_dir: Dictionary[String, bool] = {}
	
	# 空字典直接返回空
	if input_dir.is_empty():
		DebugTool.debug_log("全体注入地址校验: 传入字典为空")
		return result_dir
		
		
	for manager_name in input_dir:
		var inner_info = input_dir[manager_name] 
		
		# 检查传入格式
		if not (inner_info is Array):
			DebugTool.debug_log("全体注入地址校验: %s 不是数组格式" % manager_name)
			result_dir[manager_name] = false
			continue
			
		if len(inner_info) <= default_path_index:
			DebugTool.debug_log("全体注入地址校验: %s 数组长度不足" % manager_name)
			result_dir[manager_name] = false
			continue
		
		# 检查路径是否为 null
		var path_value = inner_info[default_path_index]
		if path_value == null:
			DebugTool.debug_log("全体注入地址校验: %s 路径为 null" % manager_name)
			result_dir[manager_name] = false
			continue	
			
		# 验证文件是否存在
		var to_be_verified_path: String = str(path_value)
		var is_resource_exist: bool = verify_injection_resource_exist(to_be_verified_path)
		
		# 添加验证结果
		result_dir[manager_name] = is_resource_exist
		
	return result_dir


#========================以下为单个工具类函数=========================#

# 验证依赖文件资源存在(Godot类型文件)
func verify_injection_resource_exist(resource_path: String) -> bool:
	if not ResourceLoader.exists(resource_path):
		DebugTool.debug_log("注入验证: 指定资源不存在 %s" % resource_path)
		return false
	return true
