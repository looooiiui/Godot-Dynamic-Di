#====引入的 Openpyxl 库中的工作簿，工作表，以及加载函数====#
from debug_tool.debug_util          import DebugTool        # 导入调试工具
from excel_processing               import ExcelManager
from excel_processing               import excel_sheet_get_pure_max_col
from excel_processing               import excel_sheet_get_pure_max_row 
from openpyxl.worksheet.worksheet   import Worksheet        # 工作表类
from openpyxl.workbook.workbook     import Workbook         # 工作簿类
from openpyxl                       import load_workbook    # 加载Excel函数
from typing                         import Optional         # 多类型注释，用于函数返回多类型
import sys      # 引入系统

class ExcelFormatConversion:
    #====将格式转为形如 { "NAME" : {"PATH": "?"}(乱序) ...}====#
    #================可以选择表头名字, 前提存在=================#
    @staticmethod
    def convert_injection_dict(input_sheet: Optional[Worksheet], head_name: str = "NAME") -> dict:
        if input_sheet is None:
            DebugTool.debug_log(f"Excel注入格式转换: 没有传入表格")
            return {}
        # 获得最大行列(处理多余后)
        processed_max_row = excel_sheet_get_pure_max_row(input_sheet)
        processed_max_col = excel_sheet_get_pure_max_col(input_sheet)
        if (processed_max_col == -1 or processed_max_row == -1):
            DebugTool.debug_log(f"Excel注入格式转换: 表格数据不符合规范")
            return {}

        # 建立键值对映射
        head_mapping: dict = {}
        for col_index in range(1, processed_max_col + 1):
            call_value = input_sheet.cell(row = 1, column = col_index).value

            # 空表头跳过
            if call_value is None:
                continue

            name_value: str = str(call_value).strip()

            # 重复表头
            if name_value in head_mapping:
                DebugTool.debug_log(f"Excel注入格式转换: 表格出现重复表头(属性): {name_value},停止键值对映射,程序终止")
                sys.exit()

            head_mapping[name_value] = col_index
        
        # 检查表头存在
        if head_name not in head_mapping:
            DebugTool.debug_log(f"Excel注入格式转换: 需求表头 {head_name} 不存在,程序终止")
            sys.exit()

        convert_result: dict = {}
        # 建立转换字典
        for row_index in range(2, processed_max_row + 1):
            attribute_dict: dict = {}

            # 获取表头列元素(主键)
            main_name_map_index: int = head_mapping[head_name]
            main_name: str = str(input_sheet.cell(row = row_index, column = main_name_map_index).value).strip()

            # 表头为空跳过
            if (main_name is None or str(main_name).strip() == ""):
                continue

            main_name = main_name.strip()

            # 将属性整理成字典(乱序)
            for attribute_name in head_mapping:
            
                # 如果是表头列则跳过
                if attribute_name == head_name:
                    continue
                
                attribute_index: int = head_mapping[attribute_name]
                attribute_value = input_sheet.cell(row = row_index, column = attribute_index).value

                if (attribute_value is None or str(attribute_value).strip() == ""):
                    attribute_value = None
                # 加入键值对(乱序)
                attribute_dict[attribute_name] = attribute_value
        
            # 加入结果表
            convert_result[main_name] = attribute_dict

        DebugTool.debug_log(f"Excel注入格式转换: 注入字典转换成功")
        return convert_result
        
