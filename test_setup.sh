#!/bin/zsh

TEST_DIR_NAME='test_dir'
REPO_NAME='/TecoGAN'
LOG_PREFIX='log_runGan_'
log_file_array=()

rm_test_dir() {
    if [[ $(pwd) =~ $REPO_NAME'$' ]]
    then
        rm -rf $TEST_DIR_NAME
    fi
}

run_in_docker() {
    command_to_execute="$1"
    docker run --gpus all -it --mount src=$(pwd),target=/TecoGAN,type=bind -w /TecoGAN tecogan_image bash -c "$command_to_execute"
}

run_in_docker_and_log() {
    python_script_to_execute=$1
    log_postfix=$2
    log_file_name="$LOG_PREFIX""$log_postfix"
    log_file_array+=(log_file_name)
    run_in_docker "python3 $python_script_to_execute 2>&1 | tee $log_file_name"
}

print_all_log_endings() {
    for file in $log_file_array
    do
        echo  "
        ========================
        output file: $file"
        tail $file
    done
}

rm_test_dir
remote_url="$(git config --get remote.origin.url)"
git clone $remote_url $TEST_DIR_NAME
cd $TEST_DIR_NAME
docker build docker --no-cache -t tecogan_image

for i in {0..2}
do
    run_in_docker_and_log "runGan.py $i" "$i"
done

print_all_log_endings

run_in_docker_and_log "dataPrepare.py --start_id 2000 --duration 120 --REMOVE --disk_path TrainingDataPath" "dataPrepare"

for i in {3..4}
do
    run_in_docker_and_log "runGan.py $i" "$i"
done

print_all_log_endings
