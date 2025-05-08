import re
import os
import sys
import pandas as pd

# 读取文本文件
def read_txt_file(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        return file.read()


# 解析单个数据块
def parse_data_block(block):
    data = {}
    # 使用正则表达式提取关键指标
    patterns = {
        "concurrency": r"max-concurrency:\s+(\d+)",
        "prompts": r"num-prompts:\s+(\d+)",
        "input_len": r"input_len:\s+(\d+)",
        "output_len": r"output_len:\s+(\d+)",
        "Successful requests": r"Successful requests:\s+(\d+)",
        "Benchmark duration (s)": r"Benchmark duration \(s\):\s+([\d.]+)",
        "Total input tokens": r"Total input tokens:\s+(\d+)",
        "Total generated tokens": r"Total generated tokens:\s+(\d+)",
        "Request throughput (req/s)": r"Request throughput \(req/s\):\s+([\d.]+)",
        "Output token throughput (tok/s)": r"Output token throughput \(tok/s\):\s+([\d.]+)",
        "Total Token throughput (tok/s)": r"Total Token throughput \(tok/s\):\s+([\d.]+)",
        "Mean TTFT (ms)": r"Mean TTFT \(ms\):\s+([\d.]+)",
        "Median TTFT (ms)": r"Median TTFT \(ms\):\s+([\d.]+)",
        "P99 TTFT (ms)": r"P99 TTFT \(ms\):\s+([\d.]+)",
        "Mean TPOT (ms)": r"Mean TPOT \(ms\):\s+([\d.]+)",
        "Median TPOT (ms)": r"Median TPOT \(ms\):\s+([\d.]+)",
        "P99 TPOT (ms)": r"P99 TPOT \(ms\):\s+([\d.]+)",
        "Mean ITL (ms)": r"Mean ITL \(ms\):\s+([\d.]+)",
        "Median ITL (ms)": r"Median ITL \(ms\):\s+([\d.]+)",
        "P99 ITL (ms)": r"P99 ITL \(ms\):\s+([\d.]+)",
    }
    for key, pattern in patterns.items():
        match = re.search(pattern, block)
        if match:
            data[key] = float(match.group(1)) if '.' in match.group(1) else int(match.group(1))
    return data


# 解析所有数据块
def parse_all_data(text):
    # 按分隔符分割数据块（假设每个数据块以 "============ Serving Benchmark Result ============" 分隔）
    blocks = re.split(r"==================================================\n==================================================", text)
    data_list = []
    for block in blocks:
        if block.strip():  # 忽略空块
            data = parse_data_block(block)
            data_list.append(data)
    return data_list


# 导出到 Excel
def export_to_excel(data_list, output_file):
    # 创建 DataFrame
    df = pd.DataFrame(data_list)
    # df_transposed = df.transpose()
    df.to_excel(output_file, index=False)


# 主函数
# 入参：日志文件
# 生成excel路径：脚本所在目录
def main():
    if len(sys.argv) != 2:
        print("please input logfile...")
        sys.exit()

    input_file = sys.argv[1]
    output_file=f"output_{os.path.splitext(os.path.basename(input_file))[0]}.xlsx"

    text = read_txt_file(input_file)
    data_list = parse_all_data(text)
    export_to_excel(data_list, output_file)

if __name__ == "__main__":
    main()