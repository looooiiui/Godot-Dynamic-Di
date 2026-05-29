extends Node

@export var Injection_interface_node		: Node

#=========================模块对应统一键值======================#
var login_model_key		: String = ""
var server_model_key	: String = ""
var ai_model_key		: String = ""
#============================================================#

#=========================已知需要注入的模块===========================#
@export var Injection_Login_Packedscene		: PackedScene 	= null
@export var Injection_Server_Packedscene	: PackedScene 	= null
@export var Injection_AiModel_Packedscene	: PackedScene	= null
#===================================================================#

# 初始化模块常量
func _ready() -> void:
	login_model_key 	= Injection_interface_node.MATCH_LOGIN_MODEL
	server_model_key 	= Injection_interface_node.MATCH_SERVER_MODEL
	ai_model_key		= Injection_interface_node.MATCH_AI_MODEL
	
# 启动注入加载(核心正式注入)
# 传入参数(原注入表, 对照注入表)
# 返回注册管理器总表,用于总控注入模块
# 传入前完成数据干净处理
func INJECTION_CORE_TSCN_START(
	injection_mapping: Dictionary, 
	injection_verify: Dictionary, 
	injection_path_index: int = 1,			# 注入参数: 路径位于映射的位置
	original_injection: Dictionary = {},
	START_STATE_NAME: String = "START",		# 注入参数: 是否启用
	START_EXTRA_NAME: String = "EXTRA"		# 注入参数: 额外启动参数
	) -> Dictionary:
	
	var result_model_dict: Dictionary = {}		# 存入已经被加载的注入式管理器
	# 全部副本复制
	var inner_injection_mapping 	= injection_mapping.duplicate(true)
	var inner_injection_verify  	= injection_verify.duplicate(true)
	var inner_original_injection	= original_injection.duplicate(true) 
		
	if inner_injection_mapping.is_empty() or inner_injection_verify.is_empty():
		DebugTool.debug_log("注入核心: 传入原映射表或验证映射表为空: 注入终止")
		return {}
	
	# 检验验证表长度是否一致
	if len(inner_injection_mapping) != len(inner_injection_verify):
		DebugTool.debug_log("注入核心: 原映射表与验证映射表长度不一致: 注入终止")
		return {}
	
	# 首先检查对应注入参数的额外参数(启用状态， 额外附加参数)
	if not inner_original_injection.is_empty():
		# 检查未启用直接将地址有效更改为无效
		for manager_name: String in inner_original_injection:
			if !inner_original_injection[manager_name].has(START_STATE_NAME):
				DebugTool.debug_log("注入核心: 在 %s 中检测不到额外启动参数 %s" % [manager_name, START_STATE_NAME])
				continue
			# 检测启动参数,转化为字符串防止数据错乱
			var model_start = str(inner_original_injection[manager_name][START_STATE_NAME])
			if model_start == "false":
				if not inner_injection_verify.has(manager_name):
					DebugTool.debug_log("注入核心: 注入验证表中找不到对应映射，你是不是没有用正确的转化函数？")
					continue
				# 更改有效地址状态
				inner_injection_verify[manager_name] = false
				
	# 输出转换结果			
	DebugTool.debug_log("注入核心: 实际验证字典转换结果: %s" % inner_injection_verify)
	#===========预留额外系统参数===========#
	# 目前逻辑未知，预留
	#====================================#
	
	# 启动注入流程(按需匹配注入模块)
	for manager_name: String in inner_injection_mapping:
		if not inner_injection_verify.has(manager_name):
			DebugTool.debug_log("注入核心: 注入验证表中找不到对应映射，你是不是没有用正确的转化函数？")
			continue
		# 禁用则不注入
		if not inner_injection_verify[manager_name]:
			continue
			
		var lower_search_name: String = manager_name.to_lower() 
		
		#======================启动注入匹配======================#
		
		if lower_search_name.contains(login_model_key):
			# 加载资源
			var load_model: PackedScene = load(inner_injection_mapping[manager_name][injection_path_index])
			var load_instantiation: Node = register_injection(load_model, login_model_key)
			result_model_dict[login_model_key] = load_instantiation
			
		# 服务器匹配注入
		if lower_search_name.contains(server_model_key):
			# 加载资源
			var load_model: PackedScene = load(inner_injection_mapping[manager_name][injection_path_index])
			var load_instantiation: Node = register_injection(load_model, server_model_key)
			result_model_dict[server_model_key] = load_instantiation
			
		# AI模型匹配注入
		if lower_search_name.contains(ai_model_key):
			# 加载资源
			var load_model: PackedScene = load(inner_injection_mapping[manager_name][injection_path_index])
			var load_instantiation: Node = register_injection(load_model, ai_model_key)
			result_model_dict[ai_model_key] = load_instantiation
			
		#==================================================================================#		
	DebugTool.debug_log("注入核心: 注入实例集合: %s" % result_model_dict)		
	return result_model_dict
	
#======================代码工具类==================#
# 注入工具
# 传入对应场景资源，返回注册完的实例
func register_injection(register_pack: PackedScene, register_model: String) -> Node:
	if register_pack == null:
		DebugTool.debug_log("注入模块注册工具: 传入注册实例为空: 注册失败")
		return
		
	var model_map: Dictionary = Injection_interface_node.get_model_register_map()
	if not model_map.has(register_model):
		DebugTool.debug_log("注入模块注册工具: 在注入管理器中找不到对应模块: 注册失败")
		return
		
	# 获得注册模块
	# 返回的是一个总类(AutoLoad)
	var to_be_register_model = model_map[register_model]
	DebugTool.debug_log("注入模块注册工具: 读入映射字典: %s" % model_map)
	# 实体注入子节点
	var register_instantiation: Node = InstantiationTool.instantiationAny(register_pack, to_be_register_model)	
	# 实体将对应模块向规定统一含有的 静态SystemInstantiation 注入对应节点
	to_be_register_model.SystemInstantiation = register_instantiation
	return register_instantiation
				
			
			
