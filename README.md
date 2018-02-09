# Dotfiles!
This is a collection of useful functions, aliases, and git configurations.

### How to use?
1) Pull down this repo to your home directory.
2) Symlink to these files:
  ```
    ln -s ~/.dotfiles/runcom/.bash_profile ~/.bash_profile
    ln -s ~/.dotfiles/runcom/.inputrc ~./inputrc
    ln -s ~/.dotfiles/git/.gitconfig ~/.gitconfig
  ```
NOTE: Be careful doing running these lines, you probably have existing versions of these files. If so, back them up then remove them and then perform the symlink.
OPTIONAL: For VS Code settings, navigate to the current location of your VS Code settings (if on macOS it should be /Users/${YOUR USER NAME}/Library/Application\ Support/Code/User/settings.json, remove that file and then symlink it like outlined above:
  ```
    ln -s ~/.dotfiles/editor_configs/settings.json /Users/${YOUR USER NAME}/Library/Application\ Support/Code/User/settings.json
  ```
  
### Plans for the future?
Of course! Down the line I want to add the necessary dotfiles to install necessary software for a fresh install of a new OS. Once those are complete, these docs will updated to reflect those new changes.
