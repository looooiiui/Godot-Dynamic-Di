extends Node

@export var LoginSystemMain: Node
"""
注意传输路径
Godot传出去的参数到Python接收，全部会被转化为字符串类型
这里给python传入的脚本格式为:
[python主脚本地址, str Excel请求路径, int 请求操作, 账户ID， 账户密码]
且传递内容全部统一为 str 类型
"""
## 登录信息验证(阻塞线程，运行的时候主程序会暂停)
## 这里的 input_info 传入的是[ID, Password]
func login_info_verify(input_info: Array[String]) -> String:
	var receive_return: 	Array[String]	= []		# 接收Python的返回值
	var transmit_argv: 		Array			= []		# Godot传给Python的参数
	
	# 补全玩家输入的信息
	while len(input_info) < 2:
		input_info.append("None")
		
	## 转化传输标准格式
	var python_path: String = LoginSystemMain.get_python_processing_path()
	
	## 这里是先将传入的参数放进一个数组 
	## [Python程序路径, Excel文件路径, Godot人为规定的给Python指令， 账户ID， 账户密码]
	transmit_argv = [python_path,
					LoginSystemMain.get_excel_path(), 
					str(0), 
					input_info[0],
					input_info[1]]
	
	## 向python传输基本信息
	## 格式 OS.execute(程序运行编译环境(没有会从环境变量自动找)，
	##				  传入参数(第一个是程序路径，给Godot找脚本同时也会被作为参数被传过去),
	##				  用于接收返回值的数组
	##				  决定是否接收没被Python收走的异常报错(try 模型收走报错所以不会被接收)
	##				  如果程序是命令终端类的，可以为True打开一个命令终端运行脚本，为False则后台静默运行
	OS.execute("python", 
				transmit_argv, 
				receive_return, 
				true, 
				true)
				
	##  由于接收为数组，需要使用 join 函数将数组拼起来转化为 string， 前面 "" 代表每一个元素之间连接为空字符串
	##  由于Python返回值中包含转义符，使用strip_escapes()删除所有转义符
	var result_output: String = "".join(receive_return).strip_escapes()
	# 返回Python处理结果
	return result_output
	
				
	
