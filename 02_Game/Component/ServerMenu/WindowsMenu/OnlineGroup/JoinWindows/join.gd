extends Window

const DOT_INTERVAL: float = 0.3

@export var Search_Label: 				Label


var dot_count: int 						= 0
var dot_timer: float 					= 0.0


func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	_search_state(delta)

func _search_state(delta: float) -> void:
	var dot_group: Array = ["", ".", "..", "..."]
	#小点点计时
	if multiplayer.multiplayer_peer == null:
		Search_Label.text = "等待创建连接"
		return
		
	if multiplayer.multiplayer_peer.get_connection_status() == multiplayer.multiplayer_peer.CONNECTION_CONNECTING:
		dot_timer += delta
		if dot_timer > DOT_INTERVAL:
			dot_timer = 0.0
			dot_count = (dot_count + 1) % 4
			
	
		Search_Label.text = "正在连接到服务器" + dot_group[dot_count]
	
	if multiplayer.multiplayer_peer.get_connection_status() == multiplayer.multiplayer_peer.CONNECTION_DISCONNECTED:
		Search_Label.text = "连接失败"
	
	if multiplayer.multiplayer_peer.get_connection_status() == multiplayer.multiplayer_peer.CONNECTION_CONNECTED:
		Search_Label.text = "已连接服务器"

func _on_exit_pressed() -> void:
	Server.close_client()
	visible = false
