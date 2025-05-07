#/bin/bash

# 参数为配置文件
if [ $# -lt 1 ]
then
    echo "need params..."
    exit
fi

source $1
set -euo pipefail

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOGDIR="$(pwd)/token_perf_log/${TIMESTAMP}"
mkdir -p "$LOGDIR"
echo "****************************************************************"
echo "log: $LOGDIR"
echo "****************************************************************"

cd $VLLM_PATH/benchmarks
for i in "${!input[@]}"; do
    input_len=${input[$i]}
    output_len=${output[$i]} 
    logfile="$LOGDIR/${input_len}_${output_len}.log"

    for j in "${!prompts[@]}"; do
        pro=${prompts[$j]}
        con=${concurrency[$j]}

        cmd="benchmark_serving.py --host $HOST --port $PORT --backend vllm --model $MODEL_PATH --served-model-name $MODEL_NAME --dataset-name random --max-concurrency $con --num-prompts $pro --random-input-len $input_len --random-output-len $output_len --ignore-eos"

        echo "==================================================" >> $logfile
        echo "Params:"                          >> $logfile
        echo "model:            $MODEL_PATH"    >> $logfile
        echo "max-concurrency:  $con"           >> $logfile
        echo "num-prompts:      $pro"           >> $logfile
        echo "input_len:        $input_len"     >> $logfile
        echo "output_len:       $output_len"    >> $logfile
        echo "==================================================" >> $logfile

        python3 $cmd | tee -a $logfile
    done
done