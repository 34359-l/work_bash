#/bin/bash

# 入参：配置文件，包含模型各项参数，参考token_perf.config
# 可选入参：parse，自动将日志生成excel
# 日志文件在./token_perf_log，文件名见脚本执行时打印信息


if [ $# -lt 1 ]; then
    echo "need config file..."
    exit
fi

source $1
set -euo pipefail

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOGDIR="$(pwd)/token_perf_log"
LOGFILE="${LOGDIR}/${TIMESTAMP}.log"

if [ ! -d $LOGDIR ]; then
    mkdir -p $LOGDIR
fi

echo "****************************************************************"
echo "log: $LOGFILE"
echo "****************************************************************"

cd $VLLM_PATH/benchmarks

for i in "${!input[@]}"; do
input_len=${input[$i]}
output_len=${output[$i]} 

    for j in "${!prompts[@]}"; do
    pro=${prompts[$j]}
    con=${concurrency[$j]}
    
        cmd="benchmark_serving.py --host $HOST --port $PORT --backend vllm --model $MODEL_PATH --served-model-name $MODEL_NAME --dataset-name random --max-concurrency $con --num-prompts $pro --random-input-len $input_len --random-output-len $output_len --ignore-eos"

        echo "==================================================" >> $LOGFILE
        echo "Params:"                          >> $LOGFILE
        echo "model:            $MODEL_PATH"    >> $LOGFILE
        echo "max-concurrency:  $con"           >> $LOGFILE
        echo "num-prompts:      $pro"           >> $LOGFILE
        echo "input_len:        $input_len"     >> $LOGFILE
        echo "output_len:       $output_len"    >> $LOGFILE
        echo "==================================================" >> $LOGFILE

        python3 $cmd | tee -a $LOGFILE
    done
done

if [ -n "$2" ]; then
    echo "start parse data..."
    python ./parse_token_data.py $LOGFILE
fi