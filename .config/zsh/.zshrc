if [ -z "${DISPLAY}" ] && [ "${XDG_VTNR}" -eq 1 ]; then
    exec startx
fi

eval "$(ssh-agent -s)" &>/dev/null
ssh-add ~/.ssh/github_rsa &>/dev/null
ssh-add ~/.ssh/hashi &>/dev/null

# Path to your oh-my-zsh installation.
export ZSH=~"/.oh-my-zsh"
export ZSH_PATH=$(which zsh)
export SHELL=$(which zsh)

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    autojump
    direnv
    fzf
    fzf-tab
    git
    git-extras
    git-prompt
    kubectl
    terraform
    tmux
    tmuxinator
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# User configuration
DOTFILES_DIR="$HOME/.dotfiles"

# Finally we can source the dotfiles (order matters)
for DOTFILE in "$DOTFILES_DIR"/system/.{function,private_function,env,path,private_env,alias,private_alias,completion,custom}; do
    [ -f "$DOTFILE" ] && . "$DOTFILE"
done

export DOTFILES_DIR

#export PATH="$HOME/.cargo/bin:$PATH"
complete -C /usr/local/bin/vault vault

if type brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH

    autoload -Uz compinit
    compinit
fi

eval "$(/usr/bin/mise activate zsh)"

fastfetch # --logo "~/.dotfiles/wallpaper/wave_wallpaper.png" --crop_mode fit

eval "$(starship init zsh)"

bindkey -s ^f "tmux-sessionizer\n"
bindkey -s ^bd "tmux-sessionizer ~/.dotfiles\n"

source <(kubectl completion zsh)

eval "$(direnv hook zsh)"
welcome
