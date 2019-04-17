#!/bin/bash
# Made by Martin Widen and Ted Jangius
# at Linkoping University 2018
# This script uninstalls Java 7, 8, 9 and 10.

worker="Java Uninstaller"
javaPluginPath="/Library/Internet Plug-Ins/JavaAppletPlugin.plugin"
javaPrefpanePath="/Library/PreferencePanes/JavaControlPanel.prefPane"
javaJdkBasePath="/Library/Java/JavaVirtualMachines"
jdkPaths=("jdk1.7"
          "jdk1.8"
          "jdk-9"
          "jdk-10")

# Function to check if the file is a symlink or any other existing file.
pathExists() {
    case "$1" in
        sym)
        [ -L "$2" ] && return 0 || return 1;;
        *)
        [ -e "$1" ] && return 0 || return 1;;
    esac
}

# Function to remove files.
removeFile() {
    if [ "${1?}" == "/" -o -z "${1?}" ]; then
        echo "$worker:remove:invalid or missing parameter: $1"; return 1;
    fi
    rm -rf "${1}" && echo "$worker:remove:$1 removed" || echo "$worker:remove:unable to remove $1"
}

main() {
    # Function to check which directories are located in /Library/Java/JavaVirtualMachines
    # Then matches the directories and removes them.
    emptyPath="$(find "$javaJdkBasePath" -maxdepth 0 -empty)"
    javaRemoved="false"
    if [ "$emptyPath" != "$javaJdkBasePath" ]; then
        for javajdk in "${javaJdkBasePath}/"*; do
            for javaPath in "${jdkPaths[@]}"; do
                case $javajdk in
                "$javaJdkBasePath/$javaPath"*)
                    pathExists "$javajdk" && removeFile "$javajdk" &&\
                    javaRemoved="true";;
                esac
            done
        done
        if [ $javaRemoved != "true" ]; then
            echo "Found no Java versions to remove"
        fi
    fi

    # If statements to remove the files in
    # /Library/Internet Plug-Ins/JavaAppletPlugin.plugin and /Library/PreferencePanes/JavaControlPanel.prefPane
    pathExists "$javaPluginPath" && removeFile "$javaPluginPath" || echo "$javaPluginPath not found"
    pathExists sym "$javaPrefpanePath" && removeFile "$javaPrefpanePath" || echo "$javaPrefpanePath not found"
}

main