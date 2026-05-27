extends Node

class_name InstantiationTool

# instantiationAny 示例化节点
# 输入参数为( 被实例化场景， 作为谁的子节点， 实例化位置(可选) )
static func instantiationAny(
	any_case: PackedScene, 						# 任何场景
	any_node: Variant, 							# 作为任何节点的子节点
	extra_position: Vector2 = Vector2(0, 0)		# 任意位置实例化
) -> Variant:
	
	# 检查节点输入是否存在
	if any_node == null:
		push_error("实例化失败: 传入的实例节点为空")
		return
	
	# 检查父节点是否存在
	if any_case == null:
		push_error("实例化失败: 传入的场景为空")
		return
		
	# 安全范围判断(判断是否是场景中的可实例化节点)
	if not any_node is Node:
		push_error("实例化失败: 传入节点不为有效节点")
		return
	
	# 场景实例化检查并实例化
	var any_instantiation = any_case.instantiate()
	if any_instantiation == null:
		push_error("实例化失败: 节点实例化步骤失败")
		return
		
	# 实例化位置更改
	if any_instantiation is Node2D:
		any_instantiation.global_position = extra_position 
	
	# 作为输入节点的子节点被加入场景
	any_node.add_child(any_instantiation)
	return any_instantiation
