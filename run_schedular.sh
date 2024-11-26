#!/bin/bash
# words=('Cora' 'chameleon' 'squirrel' 'PubMed' 'CiteSeer')
cuda_0=()
cuda_1=()
remove_invalid_pids() {
    local pids=("$@")  # Receive all arguments as an array
    local valid_pids=()  # Array to store valid PIDs

    for pid in "${pids[@]}"; do
        if kill -0 $pid 2> /dev/null; then
            valid_pids+=($pid)
        fi
    done

    echo "${valid_pids[@]}"  # Output the valid PIDs as a space-separated string
}

check_and_wait() {
    local args="$1"
    while true; do
        # Count the number of running instances of Main.py
        # process_count=$(pgrep -f "python3 Main.py" | wc -l)
        sleep 3
        # Create a temporary array to store valid PIDs
        
        current_time=$(date +"%H_%M_%S")
        if [ ${#cuda_0[@]} -lt 2 ]; then
            
            # CUDA_VISIBLE_DEVICES=0 $args &
            tmux new-session -d -s "$current_time" "CUDA_VISIBLE_DEVICES=0 $args"
            pid=$(tmux list-panes -t "$current_time" -F "#{pane_pid}")
            cuda_0+=($pid)

            break
        elif [ ${#cuda_1[@]} -lt 0 ]; then
            CUDA_VISIBLE_DEVICES=1 $args &
            cuda_1+=($!)
            break
        else
            cuda_0=($(remove_invalid_pids "${cuda_0[@]}"))
            cuda_1=($(remove_invalid_pids "${cuda_1[@]}"))
            sleep 3
        fi
    done
}

    check_and_wait "<your commands>"
