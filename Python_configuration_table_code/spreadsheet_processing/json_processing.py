import os               # 引入 os 系统库
import json             # 引入 Json 库
from debug_tool.debug_util import DebugTool        # 导入调试工具

class JsonProcessing:
        
    # 字典创建JSON文件
    # 这里是将字典的数据转化为Json的
    # 传参为 (字典，Json输出路径)
    @staticmethod
    def convert_dir_to_json(out_dir: dict, json_out_path: str) -> None:
        try:
            # ============ 1. 自动创建输出文件夹 =========== #
            # 获取文件所在目录路径
            output_dir = os.path.dirname(json_out_path)
            # 如果目录不存在，则创建
            if output_dir and not os.path.exists(output_dir):
                os.makedirs(output_dir)

            # ============ 2. 字典转 JSON 字符串（格式化） ========== #
            convert_dir: str = json.dumps(
                out_dir, 
                ensure_ascii=False, # 中文不转义乱码
                indent=4,           # 4格固定可读缩进
                sort_keys=False     # 保持表格顺序
                )
            # ============ 3. 写入文件（UTF-8编码） ============= #
            with open(json_out_path, "w", encoding="utf-8") as file:
                file.write(convert_dir)

            DebugTool.debug_log(f"JSON文件创建成功: {json_out_path}")
            
        # 异常捕获：权限、路径错误、数据格式错误等
        except Exception as e:
            DebugTool.debug_log(f"字典创建JSON失败: {str(e)}")

