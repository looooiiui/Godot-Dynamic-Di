from debug_tool.debug_util              import DebugTool        # 导入调试工具
import json             # 引入 Json 库
import os               # 引入 os 系统库
#===============================================================================#

class JsonProcessing:
        
    # 字典创建JSON文件
    # 这里是将字典的数据转化为Json的
    # 传参为 (字典，Json输出路径)
    @staticmethod
    def convert_dir_to_json(out_dir: dict, json_out_path: str) -> None:
        # 尝试创建JSON文件
        try:
            # 检查文件夹存在，不存在创建
            output_dir = os.path.dirname(json_out_path)
            if output_dir and not os.path.exists(output_dir):
                os.makedirs(output_dir)

            convert_dir: str = json.dumps(
                out_dir, 
                ensure_ascii=False, # 中文不转义乱码
                indent=4,           # 4格固定可读缩进
                sort_keys=False     # 保持表格顺序
                )
            #  # 写入文件(utf-8 编码)
            with open(json_out_path, "w", encoding="utf-8") as file:
                file.write(convert_dir)

            DebugTool.debug_log(f"JSON文件创建成功: {json_out_path}")
            
        # 创建失败
        except Exception as e:
            DebugTool.debug_log(f"字典创建JSON失败: {str(e)}")

