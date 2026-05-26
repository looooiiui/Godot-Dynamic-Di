from openpyxl.worksheet.worksheet import Worksheet
from typing import Optional
import json             # 引入 Json 库

#====允许调试信息(防止 print() 输出到Godot捕获参数列表)====#
DEBUG = False
# 调试信息输出
def log(msg):
    """只有 DEBUG=True 时才打印，否则不输出任何东西"""
    if DEBUG:
        print(msg)
#====允许调试信息(防止 print() 输出到Godot捕获参数列表)====#

# 转换工作表为字典(默认字典格式，所有标题散装)
# 这里是转化玩家存档数据的不是账户数据的
# 输入为 Excel工作表
# 输出为字典类型 { "属性": 值 }
def convert_excel_to_dir(out_excel_worksheet: Optional[Worksheet]) -> dict:
    #===Excel工作表传值判断===#
    if out_excel_worksheet is None:
        log("默认字典转换: 传入的是空表")
        return {}
    
    try:
        """
        这里的列表转化循环为
        str(cell.value) if cell.value is not None 满足添加单元格的值
        else "None" 不满足补齐 "None"
        cell 来源于工作表的第一列，可以用常量换，表示名字列或者数据列
        """
        # 转换属性列表
        excel_title_name: list[str | None]  = [str(cell.value) if cell.value is not None 
                                               else "None"
                                               for cell in out_excel_worksheet[1]]
        
        # 转化属性值列表
        excel_value: list[str | int | None] = [cell.value if cell.value is not None
                                               else "None"
                                               for cell in out_excel_worksheet[2]]
        
        # 用 zip 将两组数据对应拼成字元组
        excel_zip_result = zip(excel_title_name, excel_value)
        # 元组转换字典
        excel_zip_to_dir = dict(excel_zip_result)
        # 返回玩家存档信息字典
        return excel_zip_to_dir
    # 转换失败
    except Exception as e:
        log(f"Excel转换字典失败: {str(e)}")
        return {}

# ===============================================================================#
# 转换工作表为账号格式 { "名字": ["密码", "昵称"] }
# 适配 Godot本地登录，查字典完成账号校验
# 传参 (Excel工作表)，返回上述字典
# ===============================================================================#
def convert_excel_to_account(out_excel_worksheet: Optional[Worksheet]) -> dict:
    #===Excel工作表传值判断===#
    if out_excel_worksheet is None:
        log("账号字典转换: 传入的是空表")
        return {}

    try:
        # 转换账户信息ID，需要的list容器
        excel_id_list:          list[str | None]        = []
        excel_password_list:    list[str | None]        = []
        excel_name_list:        list[str | None]        = []
        excel_account_dir:      dict[str , list]         = {}

        # 添加数据内置的用于转化特定列的数据到存储列表的函数
        # 思路同上转化玩家存档数据
        def append_value(cell: tuple, excel_list: list):
            # 遍历得到的当前列
            for cell_value in cell:
                    append_case: str = ""
                    # 没有数据添加 "None"
                    if cell_value.value is None:
                        append_case = "None"
                    else:
                        append_case = str(cell_value.value)
                    # 添加玩家信息
                    excel_list.append(append_case)

        #==注意传进来的工作表不要 read_only=True 否则无法使用列迭代器 ==#
        # 这里遍历 1 到 3 列 ，同样可以换成常数，分别指 ID PASSWORD NAME
        for col_num, cell in enumerate(out_excel_worksheet.iter_cols(min_col=1, 
                                                                     max_col=3, 
                                                                     min_row=2, 
                                                                     max_row=None), 
                                       start=1):

            # 添加玩家信息到对应列表
            # 用match匹配当前列
            match col_num:
                # 玩家账户ID信息
                case 1:
                    append_value(cell, excel_id_list)
                # 玩家密码信息
                case 2: 
                    append_value(cell, excel_password_list)
                # 玩家名字信息
                case 3:
                    append_value(cell, excel_name_list)
                
        # 获得当前最小的数据列表长度
        min_valid_length = min(len(excel_password_list), len(excel_name_list), len(excel_id_list))

        # 截断列表, 保证每一个数据所存的数据长度一致
        # 方便后续 zip 转化
        excel_id_list           = excel_id_list[:min_valid_length]
        excel_name_list         = excel_name_list[:min_valid_length]
        excel_password_list     = excel_password_list[:min_valid_length]
        
        # 这里的思路是先将后面的所有数据整合成列表
        # 然后再和 ID 匹配转化成字典
        # 中间数组
        result_info_list: list[list[str]] = []
        # 整合结果字典 [[password, name]]
        result_info_list = [
            [password, name]
            for password, name in zip(excel_password_list, 
                                      excel_name_list)
        ]

        # 转换字典
        excel_account_dir = dict(zip(excel_id_list, result_info_list))
        return excel_account_dir
        
    # 账户字典转换失败          
    except Exception as e:
        log(f"账户字典创建失败: {str(e)}")
        return {}
#===============================================================================#

# 字典创建JSON文件
# 这里是将字典的数据转化为Json的
# 传参为 (字典，Json输出路径)
def convert_dir_to_json(out_dir: dict, json_out_path: str) -> None:
    # 尝试创建JSON文件
    try:
        convert_dir: str = json.dumps(
            out_dir, 
            ensure_ascii=False, 
            indent=4,
            sort_keys=False
            )
        # 写入JSON
        with open(json_out_path, "w", encoding="utf-8") as file:
            file.write(convert_dir)
        log(f"JSON文件创建成功: {json_out_path}")
    # 创建失败
    except Exception as e:
        log(f"字典创建JSON失败: {str(e)}")

"""
校验玩家登录信息（账号 + 密码）

返回值说明:
- 元组第1位:是否校验通过(True=通过,False=不通过)
- 元组第2位:状态码
    - 0 : 账号验证通过
    - 1 : 账户信息不存在
    - 2 : 账号信息验证错误（信息不全/密码错误）
"""
#=====使用玩家信息字典校验登录信息=====#
# 传值为 (玩家信息字典，登录信息)
# 返回 tuple[bool, int] 元组
# 第一个bool为校验是否通过，int 为校验得到的结果码
def detect_login_information(input_info_dict: dict, 
                             login_info: Optional[list[str]]
                             ) -> tuple[bool, int]:

    # 空信息校验
    if login_info is None:
        log("登录验证: 传入的是空信息")
        return False, 1

    # 校验输入长度
    if len(login_info) < 2:
        log("登录信息不全")
        return False, 2
    
    # 校验玩家ID存在
    if not (login_info[0] in input_info_dict):
        log("账号不存在!")
        return False, 1

    # 校验密码
    input_password = login_info[1]
    stored_password = input_info_dict[login_info[0]][0]
    if input_password != stored_password:
        log("账号密码错误!")
        return False, 2
        
    # 校验通过
    log("校验通过")
    return True, 0
    