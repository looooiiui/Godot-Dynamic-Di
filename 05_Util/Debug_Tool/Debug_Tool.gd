extends Node

class_name DebugTool

static var is_Debug: bool = true

static func debug_log(msg: Variant) -> void:
	if is_Debug:
		print(msg)
		
