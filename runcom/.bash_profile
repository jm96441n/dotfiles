# echo is like puts for bash (bash is the program running in your terminal)
echo "Loading ~/.bash_profile a shell script that runs in every new terminal you open"

# If not running interactively, don't do anything

[ -z "$PS1" ] && return

# Resolve DOTFILES_DIR (assuming ~/.dotfiles on distros without readlink and/or $BASH_SOURCE/$0)

READLINK=$(which greadlink || which readlink)
CURRENT_SCRIPT=$BASH_SOURCE

if [[ -n $CURRENT_SCRIPT && -x "$READLINK" ]]; then
  SCRIPT_PATH=$($READLINK -f "$CURRENT_SCRIPT")
  DOTFILES_DIR=$(dirname "$(dirname "$SCRIPT_PATH")")
elif [ -d "$HOME/.dotfiles" ]; then
  DOTFILES_DIR="$HOME/.dotfiles"
else
  echo "Unable to find dotfiles, exiting."
  return
fi

# Finally we can source the dotfiles (order matters)

for DOTFILE in "$DOTFILES_DIR"/system/.{function,path,env,private_env,alias,private_alias,completion,prompt,asdf,custom}; do
  [ -f "$DOTFILE" ] && . "$DOTFILE"
done

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

eval "$(rbenv init -)"

source "$DOTFILES_DIR"/git/.git-completion.bash
# Set LSCOLORS

# eval "$(dircolors "$DOTFILES_DIR"/system/.dir_colors)"

# Clean up

unset READLINK CURRENT_SCRIPT SCRIPT_PATH DOTFILE EXTRAFILE

# Export

export DOTFILES_DIR DOTFILES_EXTRA_DIR

# $VARIABLE will render before the rest of the command is executed
echo "Logged in as $USER at $(hostname)"


. $HOME/.asdf/asdf.sh

. $HOME/.asdf/completions/asdf.bash

. $HOME/.asdf/asdf.sh

. $HOME/.asdf/completions/asdf.bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH="/usr/local/opt/mysql@5.7/bin:$PATH"
export PATH="/usr/local/opt/mysql@5.7/bin:$PATH"
export PATH="/usr/local/opt/mysql@5.7/bin:$PATH"
export PATH=/usr/local/opt/mysql@5.7/bin:/usr/local/opt/mysql@5.7/bin:/usr/local/opt/mysql@5.7/bin:/Users/jmaguire/.nvm/versions/node/v8.11.3/bin:/Users/jmaguire/.rbenv/shims:/usr/local/opt/asdf/shims:/usr/local/opt/asdf/bin:/usr/local/Cellar/qt@5.5/5.5.1_1/bin:/usr/local/sbin:/usr/sbin:/sbin:/Users/jmaguire/.dotfiles/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/mysql/bin
export PATH="/usr/local/opt/mysql@5.7/bin:$PATH"
export PATH="/usr/local/opt/mysql@5.7/bin:$PATH"
