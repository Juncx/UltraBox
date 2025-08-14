#!/bin/bash

# 进程监控脚本：通过PID监控进程的CPU、内存等信息，并输出为svc文件
# 使用方法：./process_monitor.sh <pid> [输出文件路径] [监控间隔(秒)]

# 检查参数
if [ $# -lt 1 ]; then
    echo "使用方法: $0 <pid> [输出文件路径] [监控间隔(秒)]"
    echo "示例: $0 1234 process_monitor.svc 5"
    exit 1
fi

PID=$1
OUTPUT_FILE=${2:-process_${PID}_monitor.svc}
INTERVAL=${3:-5}  # 默认5秒采集一次

# 检查PID是否有效
if ! ps -p $PID > /dev/null; then
    echo "错误: 进程ID $PID 不存在或无效"
    exit 1
fi

# 获取进程名称
PROCESS_NAME=$(ps -p $PID -o comm=)

# 写入文件头部信息
echo "## 进程监控日志" > $OUTPUT_FILE
echo "## 进程ID: $PID" >> $OUTPUT_FILE
echo "## 进程名称: $PROCESS_NAME" >> $OUTPUT_FILE
echo "## 监控开始时间: $(date +"%Y-%m-%d %H:%M:%S")" >> $OUTPUT_FILE
echo "## 监控间隔: $INTERVAL 秒" >> $OUTPUT_FILE
echo "## 格式: 时间戳 | 日期时间 | CPU使用率(%) | 内存使用率(%) | 物理内存使用(KB) | 虚拟内存使用(KB) | 进程状态" >> $OUTPUT_FILE
echo "==================================================================================================================" >> $OUTPUT_FILE

echo "开始监控进程 $PID ($PROCESS_NAME)，数据将保存到 $OUTPUT_FILE"
echo "监控间隔: $INTERVAL 秒，按 Ctrl+C 停止监控"

# 监控循环
while true; do
    # 获取当前时间
    TIMESTAMP=$(date +%s)
    DATETIME=$(date +"%Y-%m-%d %H:%M:%S")
    
    # 使用ps命令获取进程信息
    # ps输出格式说明:
    # %cpu: CPU使用率
    # %mem: 内存使用率
    # rss: 物理内存使用(KB)
    # vsz: 虚拟内存使用(KB)
    # stat: 进程状态
    PROCESS_INFO=$(ps -p $PID -o %cpu,%mem,rss,vsz,stat --no-headers)
    
    # 检查进程是否仍在运行
    if [ -z "$PROCESS_INFO" ]; then
        echo "进程 $PID 已结束，监控停止"
        echo "## 监控结束时间: $(date +"%Y-%m-%d %H:%M:%S")" >> $OUTPUT_FILE
        echo "## 进程已终止" >> $OUTPUT_FILE
        exit 0
    fi
    
    # 解析进程信息
    CPU_USAGE=$(echo $PROCESS_INFO | awk '{print $1}')
    MEM_USAGE=$(echo $PROCESS_INFO | awk '{print $2}')
    RSS=$(echo $PROCESS_INFO | awk '{print $3}')
    VSZ=$(echo $PROCESS_INFO | awk '{print $4}')
    STATUS=$(echo $PROCESS_INFO | awk '{print $5}')
    
    # 写入监控数据
    echo "$TIMESTAMP | $DATETIME | $CPU_USAGE | $MEM_USAGE | $RSS | $VSZ | $STATUS" >> $OUTPUT_FILE
    
    # 打印到控制台（可选）
    echo -ne "\r$DATETIME - CPU: $CPU_USAGE%  内存: $MEM_USAGE%  物理内存: $RSS KB  状态: $STATUS"
    
    # 等待指定间隔
    sleep $INTERVAL
done

# 捕获Ctrl+C信号，优雅退出
trap 'echo -e "\n监控已停止"; echo "## 监控结束时间: $(date +"%Y-%m-%d %H:%M:%S")" >> $OUTPUT_FILE; exit 0' SIGINT
