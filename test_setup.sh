#!/bin/bash

TEST_DIR_NAME='test_dir'
REPO_NAME='/TecoGAN'
LOG_PREFIX='log_runGan_'

rm_test_dir() {
    if [[ $(pwd) =~ $REPO_NAME'$' ]]
    then
        rm -rf $TEST_DIR_NAME
    fi
}

rm_test_dir
remote_url="$(git config --get remote.origin.url)"
git clone $remote_url $TEST_DIR_NAME
cd $TEST_DIR_NAME
docker build docker --no-cache -t tecogan_image

#python3 runGan.py 0 > log_runGan_0
#python3 runGan.py 1 > log_runGan_1
#python3 runGan.py 2 > log_runGan_2
for i in {0..2}
do
    python3 runGan.py $i > "$LOG_PREFIX""$i"
done
for i in {0..2}
do
    file="$LOG_PREFIX""$i"  
    echo  \n file: $file
    tail $file
done

