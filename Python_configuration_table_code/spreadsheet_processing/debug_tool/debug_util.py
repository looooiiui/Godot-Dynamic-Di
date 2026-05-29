class DebugTool:
    #====允许调试信息(防止 print() 输出到Godot捕获参数列表)====#
    DEBUG = True
    
    # 调试信息输出
    @staticmethod
    def debug_log(msg):
        """只有 DEBUG=True 时才打印，否则不输出任何东西"""
        if DebugTool.DEBUG:
            try: print(msg) 
            except Exception as e:
                import sys
                sys.stderr.write(f"调试出现问题: {msg}\n")
    #====允许调试信息(防止 print() 输出到Godot捕获参数列表)====#