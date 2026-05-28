extends CanvasLayer

@export var OnlineWindows: 			Window
@export var HostWindows: 			Window
@export var JoinWindows: 			Window

func _ready() -> void:
	_windows_initialize()
	
func _process(delta: float) -> void:
	pass

#窗口初始化
func _windows_initialize() -> void:
	OnlineWindows.visible 		= false
	HostWindows.visible			= false
	JoinWindows.visible			= false
