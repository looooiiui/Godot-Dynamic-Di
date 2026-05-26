extends Node

@export var LoginSystemMain: Node
"""
注意传输路径
这里给python传入的脚本格式为:
[python主脚本地址, str Excel请求路径, int 请求操作, 账户ID， 账户密码]
且传递内容全部统一为 str 类型
"""

# 注册信息验证(阻塞线程)
func register_info_verify(input_info: Array[String]) -> String:
	var receive_return: 	Array[String]	= []
	var transmit_argv: 		Array			= []
	# 防止数组越界
	while len(input_info) < 2:
		input_info.append("None")
		
	# 转化传输标准格式	
	var python_path: String = LoginSystemMain.get_python_processing_path()
	transmit_argv = [python_path,
					LoginSystemMain.get_excel_path(), 
					str(1), 
					input_info[0],
					input_info[1]]
	
	# 向python传输基本信息
	OS.execute("python", 
				transmit_argv, 
				receive_return, 
				true, 
				true)
				
	# 返回结果
	var result_output: String = "".join(receive_return).strip_escapes()
	return result_output
