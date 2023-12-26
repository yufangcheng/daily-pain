#! /bin/sh

localBranches() {
    echo `git -P branch | awk -F ' *' '{print $2}'`
}

remoteBranches() {
    echo `git -P branch -r | grep -v "\->"`
}

currentBranch() {
    echo `git -P branch | grep "*" | awk '{print $2}'`
}

updateLocalBranch() {
    echo "updating branch \033[32m${1}\033[0m"
    git checkout $1 && git pull
    if [ $? -eq 0 ];then
        echo "\033[32mupdated\033[0m\r\n"
    else
        echo "\033[31mfailed to update branch ${1}\033[0m\r\n"
    fi
}

checkoutRemoteBranch() {
    echo "checkout remote branch \033[32m${2}\033[0m"
    git checkout -b $2 --track $1/$2
    if [ $? -eq 0 ];then
        echo "\033[32mchecked out\033[0m\r\n"
    else
        echo "\033[31mfailed to checkout remote branch ${2}\033[0m\r\n"
    fi
}

isProjectClean() {
    c=`git status -s | wc -l`
    if [ $c -eq 0 ]; then
        return 0
    else
        return 1
    fi
}

update() {
    echo "\r\n===================== project: \033[32m#${1} ${d}\033[0m\r\n"

    currentBr=`currentBranch`
    echo "current branch is \033[32m${currentBr}\033[0m"

    for lb in `localBranches`
    do
        updateLocalBranch $lb
    done

    for rb in `remoteBranches`
    do
        rbName=`awk -F "/" '{for(i=2; i<=NF; i++) printf $i "/"}' <<< $rb | sed 's/.$//'`
        remote=`awk -F "/" '{print $1}' <<< $rb`
        for lb in `localBranches`
        do
            if [ "$lb" == "$rbName" ]; then
                continue 2
            fi
        done
        checkoutRemoteBranch $remote $rbName
    done

    if [ `currentBranch` != $currentBr ]; then
        echo "restore current branch \033[32m${currentBr}\033[0m"
        updateLocalBranch $currentBr
    fi
}

changeDir() {
    set c=$1
    for d in `ls`
    do
        if [ -d $d ]; then
            cd $d
            if [ -d .git ]; then
                ((c++))
                update $c
            else
                changeDir $c
            fi
            cd ..
        fi
    done
}

c=0
changeDir $c
