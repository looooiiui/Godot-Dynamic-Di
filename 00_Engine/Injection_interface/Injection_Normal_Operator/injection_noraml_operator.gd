extends Node

@export var Injection_interface_node: Node

"""
标准Godot传入参数:
	[
	Python路径, 
	Python运行参数
	普通Python注入代码绝对路径,
	注入Json文件绝对路径,
	]
"""

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
		print(cell)

# 将收到的注入字典中的绝对地址转化为相对Godot的地址
func convert_injection_dict_local(injection_dict: Dictionary, 
								  path_head_name: String = "PATH"
								  ) -> Dictionary: 
		# 结果字典
		var result_dict: Dictionary = injection_dict.duplicate()
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
			var convert_result: String = ProjectSettings.localize_path(original_absolute_path)
			
			# 更新结果字典
			result_dict[manager_name][path_head_name] = convert_result
		return result_dict
