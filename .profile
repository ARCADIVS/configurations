#!/bin/sh

# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

#uim-fep will launch $SHELL _again_, so this should run before anything else.
if [ "$TERM" = "linux" ] && [ -z "$UIM_FEP_PID" ]; then
    exec uim-fep
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    export PATH="$PATH:$HOME/bin"
fi
export EDITOR=vim

eval `dircolors $HOME/.config/dir_colors`
