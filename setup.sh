#!/bin/bash
set -e
OS="$(uname -s)"
DOT_DIRECTORY="${HOME}/dotfiles"
DOT_TARBALL="https://github.com/odokedene/dotfiles/tarball/master"
REMOTE_URL="git@github.com:odokedene/dotfiles.git"

has() {
    type "$1" > /dev/null 2>&1
}

usage() {
    name=`basename $0`
    cat <<EOF
Usage:
    $name [arguments] [command]

Commands:
    deploy
    initialize

Arguments:
    -f $(tput setaf 1)** warning **$(tput sgr0) Overwrite dotfiles.
    -h Print help (this message)
EOF
    exit 1
}

while getopts :f:h opt; do
    case ${opt} in
        f)
            OVERWRITE=true
            ;;
        h)
            usage
            ;;
    esac
done
shift $((OPTIND - 1))

# If missing, download and extract the dotfiles repository
if [ -n "${OVERWRITE}" -o ! -d ${DOT_DIRECTORY} ]; then
    echo "Downloading dotfiles..."
    mkdir ${DOT_DIRECTORY}

    if has "git"; then
        git clone --recursive "${REMOTE_URL}" "${DOT_DIRECTORY}"
    else
        curl -fsSLo ${HOME}/dotfiles.tar.gz ${DOT_TARBALL}
        tar -zxf ${HOME}/dotfiles.tar.gz --strip-components 1 -c ${DOT_DIRECTORY}
        rm -f ${HOME}/dotfiles.tar.gz
    fi

    echo $(tput setaf 2)Download dotfiles complate!. ✔$(tput sgr0)
fi

link_files(){
    # Deploy処理
    cd ${DOT_DIRECTORY}

    for f in .??*
    do
        # 無視したいファイルやディレクトリの追加
        [[ ${f} = ".git" ]] && continue
        [[ ${f} = ".gitignore" ]] && continue
        ln -snfv ${DOT_DIRECTORY}/${f} ${HOME}/${f}
    done
    echo $(tput setaf 2)Deploy dotfiles complete!. ✔$(tput sgr0)
}

#initialize(){
    # Initialize処理
#}

# 引数によって場合わけ
command=$1
[ $# -gt 0 ] && shift

# 引数がなければヘルプ
case $command in
    deploy)
        link_files
        ;;
#    init*)
#        initialize
#        ;;
    *)
        usage
        ;;
    esac

    exit 0


