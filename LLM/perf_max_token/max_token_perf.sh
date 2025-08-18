#/bin/bash

# 入参：配置文件，包含模型各项参数，参考token_perf.config
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

for i in "${!input[@]}"; do
input_len=${input[$i]}
output_len=${output[$i]} 

    for j in "${!prompts[@]}"; do
        pro=${prompts[$j]}
        con=${concurrency[$j]}

        if [[ $tool == "vllm" ]]; then
            cmd="vllm bench serve --host $HOST \
                                --port $PORT \
                                --backend vllm \
                                --model $MODEL_PATH \
                                --served-model-name $MODEL_NAME \
                                --dataset-name random \
                                --max-concurrency $con \
                                --num-prompts $pro \
                                --random-input-len $input_len \
                                --random-output-len $output_len"
        elif [[ $tool == "sglang" ]]; then
            cmd="python3 -m sglang.bench_serving \
                    --backend sglang-oai \
                    --model $MODEL_PATH \
                    --host localhost --port 8000 \
                    --dataset-name random \
                    --random-input-len $input_len \
                    --random-output-len $output_len \
                    --random-range-ratio 0.85 \
                    --num-prompt $pro \
                    --max-concurrency $con"
        fi

        echo "==================================================" >> $LOGFILE
        echo "Params:"                          >> $LOGFILE
        echo "model:            $MODEL_PATH"    >> $LOGFILE
        echo "max-concurrency:  $con"           >> $LOGFILE
        echo "num-prompts:      $pro"           >> $LOGFILE
        echo "input_len:        $input_len"     >> $LOGFILE
        echo "output_len:       $output_len"    >> $LOGFILE
        echo "==================================================" >> $LOGFILE

        $cmd | tee -a $LOGFILE
    done
done