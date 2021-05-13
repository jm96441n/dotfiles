if [[ $(is-macos) == 0 ]]; then
  grep "/usr/local/bin/zsh" /private/etc/shells &>/dev/null || sudo zsh -c "echo /usr/local/bin/zsh >> /private/etc/shells"
fi
# Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# Gruvbox Theme
curl -L https://raw.githubusercontent.com/sbugzu/gruvbox-zsh/master/gruvbox.zsh-theme > ~/.oh-my-zsh/custom/themes/gruvbox.zsh-theme
# zsh autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# fzf-tab
git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab
# zsh syntax highlightin
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
# color ls
git clone https://github.com/Kallahan23/zsh-colorls ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-colorls
