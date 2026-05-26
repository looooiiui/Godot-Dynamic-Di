extends Node

@export var Injection_interface_node: Node
#获得注入信息
func get_Injection_information(filePath: String) -> Dictionary:
	
	#如果文件不存在，就直接返回空字典
	if !FileAccess.file_exists(filePath):
		return {}
		
	#打开文件
	var file = FileAccess.open(filePath, FileAccess.READ)
	#将文件内的数据以字符串的形式读入，注意不是直接读入字典
	var tempText = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	##这里parse()函数负责解析String，解析完后的数据在json中
	##这里解析完后, json.data 就是字典
	json.parse(tempText)
	
	#返回解析后得到的字典
	return json.data as Dictionary
