import sys                                                          # Python环境工具
from typing import Optional                                         # 引入类型标注工具 
from pathlib import Path   
                                         # 路径工具
# 项目根目录
ROOT_DIR = Path(__file__).parent
# 子模块目录 spreadsheet_processing 文件夹
SP_DIR = ROOT_DIR / "spreadsheet_processing"

# 加入目录搜索路径
sys.path.append(str(ROOT_DIR))
sys.path.append(str(SP_DIR))

from spreadsheet_processing.excel_format_convert            import ExcelFormatConversion         # 导入格式转换工具
from spreadsheet_processing.debug_tool.debug_util           import DebugTool                     # 导入调试工具
from spreadsheet_processing.excel_processing                import ExcelManager                  # 导入Excel管理器
from spreadsheet_processing.json_processing                 import JsonProcessing                # 导入Json处理器

#==========================默认文件路径==========================#
DEFAULT_EXCEL_PATH  : str   = "Injection_Table/InjectionTable.xlsx"
DEFAULT_JSON_PATH   : str   = "InjectionConvert.json"
#===============================================================#

#=====================Godot注入启动默认传参=======================#
DEFAULT_PARAM_NUM:          int = 4     # Godot传入参数数量
DEFAULT_PYTHON_PATH:        int = 0     # Godot传入Python路径(绝对)
DEFAULT_START_PARAM:        int = 1     # Godot传入启动参量
DEFAULT_GODOT_NORMAL_PATH:  int = 2     # Godot默认地址传参
DEFAULT_GODOT_JSON_PATH:    int = 3     # Godot默认注入Json路径
#===============================================================#

#========================Godot启动参量===========================#
START_EXCEL_CONVERT_JSON:   str = "0"

#===============================================================#


#======================默认接收全局变量===========================#
receive_param : str          = "0"              # 程序运行参数
receive_excel : Optional[ExcelManager] = None   # 程序Excel管理器
#===============================================================#


#============= 一下为统一接口调用函数 ===============#

# 加载Godot运行参数
def load_godot_arguments() -> None:
    # 主程序传参限制
    if (len(sys.argv) < DEFAULT_PARAM_NUM): 
        DebugTool.debug_log(f"传参: 传参数量不足, 当前传参: {len(sys.argv)}, 程序终止")
        sys.exit()
    
    # 声明全局，修改全局路径
    global receive_param
    global DEFAULT_EXCEL_PATH
    global DEFAULT_JSON_PATH

    # 初始化收到参数
    receive_param       = sys.argv[DEFAULT_START_PARAM]
    godot_base_path     = sys.argv[DEFAULT_GODOT_NORMAL_PATH]
    godot_json_path     = sys.argv[DEFAULT_GODOT_JSON_PATH]


    DEFAULT_EXCEL_PATH = godot_base_path + DEFAULT_EXCEL_PATH
    DEFAULT_JSON_PATH  = godot_json_path

# 参数为 0 执行一次Excel转换Json
def injection_convert_json() -> None:
    # 声明全局，修改全局对象
    global receive_excel

    if receive_excel is None:
        DebugTool.debug_log(f"主程序: 当前Excel管理器为空")
        return
    
    # 转换Excel数据为Json
    sheet = receive_excel.get_sheet("InjectionTable")

    convert_dict: dict = ExcelFormatConversion.convert_injection_dict(sheet)

    JsonProcessing.convert_dir_to_json(convert_dict, DEFAULT_JSON_PATH)  


"""
规定Python参数接收标准
    [
        Python路径(Godot规定必传),
        Godot运行要求指令参数,
        Python注入代码补充路径,
        注入Json文件绝对路径
    ]
"""


#=========================主程序执行=========================#
if __name__ == "__main__":
    try:
        # 初始化加载参数
        load_godot_arguments()

        # Excel管理器初始化
        receive_excel = ExcelManager(DEFAULT_EXCEL_PATH)

        #================程序执行部分================#

        # 根据参数选择执行函数
        if (receive_param == START_EXCEL_CONVERT_JSON):

            injection_convert_json()
        #================程序执行末尾================#

    except Exception as e:
        DebugTool.debug_log(f"主程序: 程序运行异常：{str(e)}")
        sys.exit()

    # 关闭Excel
    finally:
        if receive_excel is not None:
            receive_excel.close_workbook()
