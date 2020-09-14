#!/bin/zsh

TEST_DIR_NAME='test_dir'
REPO_NAME='/TecoGAN'
LOG_PREFIX='log_runGan_'
docker_run_co

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

rm_test_dir
remote_url="$(git config --get remote.origin.url)"
git clone $remote_url $TEST_DIR_NAME
cd $TEST_DIR_NAME
docker build docker --no-cache -t tecogan_image

for i in {0..2}
do
    run_in_docker "python3 runGan.py $i 2>&1 | tee ""$LOG_PREFIX""$i"
done
for i in {0..2}
do
    file="$LOG_PREFIX""$i"  
    echo  "
    ========================
    output file: $file"
    tail $file
done

